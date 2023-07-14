codeunit 6151202 "NPR NpCs POSAction Proc. Order" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        NpCsPOSActionProcOrderB: Codeunit "NPR NpCs POSAction Proc.OrderB";

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        ActionDescriptionLbl: Label 'This built-in action process Collect in Store Orders.';
        ParamLocationFilterLbl: Label 'Location Filter';
        ParamFromLocation_OptLbl: Label 'POS Store,Location Filter Parameter', Locked = true;
        ParamFromLocation_CaptOptLbl: Label 'POS Store,Location Filter Parameter';
        ParamFromLocation_NameLbl: Label 'Location From';
        ParamFromLocation_DescLbl: Label 'Specifies from location';
        ParamSorting_OptLbl: Label 'Entry No.,Reference No.,Processing expires at,Entry No. (Desc.)', Locked = true;
        ParamSorting_NameLbl: Label 'Sorting';
        ParamSorting_DescLbl: Label 'Specifies sorting';
    begin
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSale());
        WorkflowConfig.SetCustomJavaScriptLogic('enable', 'return row.getField("CollectInStore.UnprocessedOrdersExists").rawValue;');
        WorkflowConfig.AddOptionParameter('Location From',
                                          ParamFromLocation_OptLbl,
#pragma warning disable AA0139
                                          SelectStr(1, ParamFromLocation_OptLbl),
#pragma warning restore
                                          ParamFromLocation_NameLbl,
                                          ParamFromLocation_DescLbl,
                                          ParamFromLocation_CaptOptLbl);
        WorkflowConfig.AddTextParameter('Location Filter', '', ParamLocationFilterLbl, ParamLocationFilterLbl);
        WorkflowConfig.AddOptionParameter('Sorting',
                                          ParamSorting_OptLbl,
#pragma warning disable AA0139
                                          SelectStr(1, ParamSorting_OptLbl),
#pragma warning restore
                                          ParamSorting_NameLbl,
                                          ParamSorting_DescLbl,
                                          ParamSorting_OptLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; SaleMgr: Codeunit "NPR POS Sale"; SaleLineMgr: Codeunit "NPR POS Sale Line"; PaymentLineMgr: Codeunit "NPR POS Payment Line"; SetupMgr: Codeunit "NPR POS Setup");
    begin
        case Step of
            'run_collect_in_store_orders':
                begin
                    CollectInStoreOrders(Context, SaleMgr);
                end;
        end;
    end;

    local procedure ActionCode(): Text[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::PROCESS_COLLECT_ORD));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionProcessOrder.js###
'let main=async({})=>await workflow.respond("run_collect_in_store_orders");'
        );
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupLocationFilter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'Location Filter' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        Handled := true;

        if StrLen(POSParameterValue.Value) > MaxStrLen(Location.Code) then
            if Location.Get(UpperCase(POSParameterValue.Value)) then;

        if PAGE.RunModal(0, Location) = ACTION::LookupOK then
            POSParameterValue.Value := Location.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateLocationFilter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'Location Filter' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        Location.SetFilter(Code, POSParameterValue.Value);
        if not Location.FindFirst() then begin
            Location.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            if Location.FindFirst() then
                POSParameterValue.Value := Location.Code;
        end;
    end;

    local procedure GetLocationFilter(Context: Codeunit "NPR POS JSON Helper") LocationFilter: Text
    var
        POSStore: Record "NPR POS Store";
        POSSetup: Codeunit "NPR POS Setup";
        POSSession: Codeunit "NPR POS Session";
    begin
        case Context.GetIntegerParameter('Location From') of
            0:
                begin
                    POSSession.GetSetup(POSSetup);
                    POSSetup.GetPOSStore(POSStore);
                    LocationFilter := POSStore."Location Code";
                end;
            1:
                begin
                    LocationFilter := UpperCase(Context.GetStringParameter('Location Filter'));
                end;
        end;

        exit(LocationFilter);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscover(DataSourceName: Text; Extensions: List of [Text])
    var
        NpCsStore: Record "NPR NpCs Store";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale() then
            exit;
        if NpCsStore.IsEmpty then
            exit;

        Extensions.Add('CollectInStore');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        DataType: Enum "NPR Data Type";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale() then
            exit;
        if ExtensionName <> 'CollectInStore' then
            exit;

        Handled := true;

        DataSource.AddColumn('UnprocessedOrdersExists', 'Unprocessed Orders Exists', DataType::Boolean, false);
        DataSource.AddColumn('UnprocessedOrdersQty', 'Unprocessed Orders Qty.', DataType::Integer, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        POSMenuMgt: Codeunit "NPR POS Menu Mgt.";
        UnprocessedOrdersExists: Boolean;
        LocationFilter: Text;
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale() then
            exit;
        if ExtensionName <> 'CollectInStore' then
            exit;

        Handled := true;

        LocationFilter := POSMenuMgt.GetPOSMenuButtonLocationFilter(POSSession, ActionCode());
        UnprocessedOrdersExists := NpCsPOSActionProcOrderB.GetUnprocessedOrdersExists(LocationFilter);
        DataRow.Fields().Add('UnprocessedOrdersExists', UnprocessedOrdersExists);
        if UnprocessedOrdersExists then
            DataRow.Fields().Add('UnprocessedOrdersQty', NpCsPOSActionProcOrderB.GetUnprocessedOrdersQty(LocationFilter))
        else
            DataRow.Fields().Add('UnprocessedOrdersQty', 0);
    end;


    local procedure CollectInStoreOrders(var Context: Codeunit "NPR POS JSON Helper"; var POSSale: Codeunit "NPR POS Sale")
    var
        LocationFilter: Text;
        SortingInt: Integer;
    begin
        LocationFilter := GetLocationFilter(Context);
        SortingInt := Context.GetIntegerParameter('Sorting');
        NpCsPOSActionProcOrderB.RunCollectInStoreOrders(LocationFilter, SortingInt);
        POSSale.RefreshCurrent();
    end;
}
