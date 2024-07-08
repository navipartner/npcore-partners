codeunit 6151202 "NPR POSAction Proc. CnC Order" implements "NPR IPOS Workflow"
{
    Access = Internal;

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
                    CollectInStoreOrders(Context, SetupMgr);
                end;
            'is_workflow_disabled':
                begin
                    FrontEnd.WorkflowResponse(SetWorkflowState(Context, SetupMgr));
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
//###NPR_INJECT_FROM_FILE:POSActionProcessCnCOrder.js###
'let main=async({workflow:r})=>await r.respond("run_collect_in_store_orders"),isWorkflowDisabled=async({workflow:r})=>await r.respond("is_workflow_disabled");'
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

    local procedure GetLocationFilter(Context: Codeunit "NPR POS JSON Helper"; POSSetup: Codeunit "NPR POS Setup"): Text
    var
        POSStore: Record "NPR POS Store";
        LocationFrom: Integer;
        LocationFilter: Text;
    begin
        if not Context.GetIntegerParameter('Location From', LocationFrom) then
            LocationFrom := 0;

        LocationFilter := '';
        case LocationFrom of
            0:
                begin
                    POSSetup.GetPOSStore(POSStore);
                    LocationFilter := POSStore."Location Code";
                end;
            1:
                if not Context.GetStringParameter('Location Filter', LocationFilter) then;
        end;
        exit(UpperCase(LocationFilter));
    end;

    local procedure CollectInStoreOrders(var Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup")
    var
        NpCsPOSActionProcOrderB: Codeunit "NPR POSAction Proc. CnC OrderB";
        LocationFilter: Text;
        SortingInt: Integer;
    begin
        LocationFilter := GetLocationFilter(Context, Setup);
        SortingInt := Context.GetIntegerParameter('Sorting');
        NpCsPOSActionProcOrderB.RunCollectInStoreOrders(LocationFilter, SortingInt);
    end;

    local procedure SetWorkflowState(var Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup"): JsonObject
    var
        NpCsPOSActionProcOrderB: Codeunit "NPR POSAction Proc. CnC OrderB";
        LocationFilter: Text;
    begin
        LocationFilter := GetLocationFilter(Context, Setup);
        Context.SetContext('disabled', not NpCsPOSActionProcOrderB.HasUnprocessedOrders(LocationFilter));
    end;
}
