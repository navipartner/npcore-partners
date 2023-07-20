codeunit 6151203 "NPR NpCs POSAction Deliv.Order" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        DelOrderBL: Codeunit "NPR NpCs POSAct. Deliv.Order-B";

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        CollectInStoreLbl: Label 'Collect in Store';
        DeliverCollectInStoreLbl: Label 'Deliver Collect in Store Documents';
        DeliveryLbl: Label 'Collect %1 %2', Comment = '%1=NpCsDocument."Document Type";%2=NpCsDocument."Reference No."';
        EnterCollectRefNoLbl: Label 'Enter Collect Reference No.';
        LocationFromDescLbl: Label 'Specifies Location from';
        LocationFromParamLbl: Label 'Location from';
        LocationFromPOptLbl: Label 'POS Store,Location Filter Parameter', Locked = true;
        LocationFromPOpt_CptLbl: Label 'POS Store,Location Filter Parameter';
        OpenDocumentDescriptionLbl: Label 'Open the selected order before document is delivered';
        OpenDocumentLbl: Label 'Open Document';
        ParamConfInvDiscLbl: Label 'Confirm Inv. Discount Amount';
        ParamDelivery_CptLbl: Label 'Delivery Text';
        ParamDelivery_DescLbl: Label 'Specifies Delivery Text';
        ParamLocFilter_CptLbl: Label 'Location Filter';
        ParamLocFilter_DescLbl: Label 'Specifies Location Filter';
        ParamPrepaidCaptLbl: Label 'Prepaid Text';
        ParamPrepaidLbl: Label 'Prepaid Text';
        ParamSortingLbl: Label 'Sorting';
        ParamSortingOptLbl: Label 'Entry No.,Reference No.,Delivery expires at', Locked = true;
        ParamSortingOpt_CptLbl: Label 'Entry No.,Reference No.,Delivery expires at';
        PrepaidAmountLbl: Label 'Prepaid Amount %1', Comment = '%1=POS Menu Button Parameter Value';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(DeliverCollectInStoreLbl);

        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSaleLine());
        WorkflowConfig.SetCustomJavaScriptLogic('enable', 'return row.getField("CollectInStore.ProcessedOrdersExists").rawValue;');
        WorkflowConfig.AddLabel('DocumentInputTitle', CollectInStoreLbl);
        WorkflowConfig.AddLabel('ReferenceNo', EnterCollectRefNoLbl);

        WorkflowConfig.AddOptionParameter('Location From',
                                          LocationFromPOptLbl,
#pragma warning disable AA0139
                                          SelectStr(1, LocationFromPOptLbl),
#pragma warning restore
                                          LocationFromParamLbl,
                                          LocationFromDescLbl,
                                          LocationFromPOpt_CptLbl);
        WorkflowConfig.AddTextParameter('Location Filter', '', ParamLocFilter_CptLbl, ParamLocFilter_DescLbl);
        WorkflowConfig.AddTextParameter('Delivery Text', DeliveryLbl, ParamDelivery_CptLbl, ParamDelivery_DescLbl);
        WorkflowConfig.AddTextParameter('Prepaid Text', PrepaidAmountLbl, ParamPrepaidLbl, ParamPrepaidCaptLbl);
        WorkflowConfig.AddOptionParameter('Sorting',
                                          ParamSortingOptLbl,
#pragma warning disable AA0139
                                          SelectStr(1, ParamSortingOptLbl),
#pragma warning restore
                                          ParamSortingLbl,
                                          ParamSortingLbl,
                                          ParamSortingOpt_CptLbl);
        WorkflowConfig.AddBooleanParameter('OpenDocument', false, OpenDocumentLbl, OpenDocumentDescriptionLbl);
        WorkflowConfig.AddBooleanParameter('ConfirmInvDiscAmt', false, ParamConfInvDiscLbl, ParamConfInvDiscLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; SaleMgr: Codeunit "NPR POS Sale"; SaleLineMgr: Codeunit "NPR POS Sale Line"; PaymentLineMgr: Codeunit "NPR POS Payment Line"; SetupMgr: Codeunit "NPR POS Setup");
    begin
        case Step of
            'select_document':
                begin
                    OnActionSelectDocument(Context, SetupMgr);
                end;
            'deliver_document':
                begin
                    OnActionDeliverDocument(Context);
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:NpCsDeliverOrder.js###
'let main=async({workflow:n,context:e,popup:i,captions:t})=>{if(e.document_input=await i.input({title:t.DocumentInputTitle,caption:t.ReferenceNo,value:""}),e.document_input==null)return" ";await n.respond("select_document"),e.entry_no&&await n.respond("deliver_document")};'
        );
    end;

    procedure ActionCode(): Text
    begin
        exit(Format(Enum::"NPR POS Workflow"::DELIVER_COLLECT_ORD));
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

        if Page.RunModal(0, Location) = Action::LookupOK then
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

    local procedure OnActionSelectDocument(Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup")
    var
        NpCsDocument: Record "NPR NpCs Document";
        ConfirmInvDiscAmt, OpenDocument : Boolean;
        ReferenceNo: Text;
        LocationFilter: Text;
        SortingParam: Integer;
    begin
        OpenDocument := Context.GetBooleanParameter('OpenDocument');
        ConfirmInvDiscAmt := Context.GetBooleanParameter('ConfirmInvDiscAmt');
        ReferenceNo := CopyStr(Context.GetString('document_input'), 1, MaxStrLen(NpCsDocument."Reference No."));
        LocationFilter := GetLocationFilter(Context, Setup);
        SortingParam := Context.GetIntegerParameter('Sorting');

        if not DelOrderBL.FindAndConfirmDoc(NpCsDocument, ReferenceNo, LocationFilter, SortingParam, ConfirmInvDiscAmt, OpenDocument) then
            exit;

        Context.SetContext('entry_no', NpCsDocument."Entry No.");
    end;

    local procedure OnActionDeliverDocument(Context: Codeunit "NPR POS JSON Helper")
    var
        ConfirmInvDiscAmt: Boolean;
        EntryNo: Integer;
        DeliverText: Text;
    begin
        Context.SetContext('/', false);
        EntryNo := Context.GetInteger('entry_no');
        DeliverText := Context.GetStringParameter('Delivery Text');
        ConfirmInvDiscAmt := Context.GetBooleanParameter('ConfirmInvDiscAmt');
        if EntryNo = 0 then
            exit;

        DelOrderBL.DeliverDocument(EntryNo, DeliverText, ConfirmInvDiscAmt);
    end;

    local procedure GetLocationFilter(Context: Codeunit "NPR POS JSON Helper"; POSSetup: Codeunit "NPR POS Setup") LocationFilter: Text
    var
        POSStore: Record "NPR POS Store";
    begin
        case Context.GetIntegerParameter('Location From') of
            0:
                begin
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


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale() then
            exit;
        if ExtensionName <> 'CollectInStore' then
            exit;

        Handled := true;

        DataSource.AddColumn('ProcessedOrdersExists', 'Processed Orders Exists', DataType::Boolean, false);
        DataSource.AddColumn('ProcessedOrdersQty', 'Processed Orders Qty.', DataType::Integer, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        POSMenuMgt: Codeunit "NPR POS Menu Mgt.";
        ProcessedOrdersExists: Boolean;
        LocationFilter: Text;
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInSale() then
            exit;
        if ExtensionName <> 'CollectInStore' then
            exit;

        Handled := true;

#pragma warning disable AA0139
        LocationFilter := POSMenuMgt.GetPOSMenuButtonLocationFilter(POSSession, ActionCode());
#pragma warning restore
        ProcessedOrdersExists := GetProcessedOrdersExists(LocationFilter);
        DataRow.Fields().Add('ProcessedOrdersExists', ProcessedOrdersExists);
        if ProcessedOrdersExists then
            DataRow.Fields().Add('ProcessedOrdersQty', GetProcessedOrdersQty(LocationFilter))
        else
            DataRow.Fields().Add('ProcessedOrdersQty', 0);
    end;

    local procedure GetProcessedOrdersExists(LocationFilter: Text): Boolean
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        SetProcessedFilter(LocationFilter, NpCsDocument);
        exit(NpCsDocument.FindFirst());
    end;

    local procedure GetProcessedOrdersQty(LocationFilter: Text): Integer
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        SetProcessedFilter(LocationFilter, NpCsDocument);
        exit(NpCsDocument.Count());
    end;

    local procedure SetProcessedFilter(LocationFilter: Text; var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsPOSActionEvents: Codeunit "NPR NpCs POS Action Events";
        IsHandled: Boolean;
    begin
        NpCsPOSActionEvents.OnBeforeSetProcessedFilter(LocationFilter, NpCsDocument, IsHandled);
        if IsHandled then
            exit;
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Processing Status", NpCsDocument."Processing Status"::Confirmed);
        NpCsDocument.SetRange("Delivery Status", NpCsDocument."Delivery Status"::Ready);
        NpCsDocument.SetFilter("Location Code", LocationFilter);
    end;
}
