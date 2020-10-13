codeunit 6151127 "NPR POS Action: Ins. ItemAddOn"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        CurrNpIaItemAddOn: Record "NPR NpIa Item AddOn";
        [WithEvents]
        Model: DotNet NPRNetModel;
        ActiveModelID: Guid;
        Text000: Label 'Insert Item AddOns directly from POS Action';

    local procedure ActionCode(): Text
    begin
        exit('INSERT_ITEM_ADDONS');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do begin
            if DiscoverAction(
              ActionCode(),
              Text000,
              ActionVersion(),
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('select_addon',
                  'if (param.ItemAddOnNo) {' +
                  '  context.item_addon = param.ItemAddOnNo;' +
                  '} else {' +
                  '  respond();' +
                  '}'
                );
                RegisterWorkflowStep('insert_addons',
                  'if (context.item_addon) {' +
                  '  respond();' +
                  '}'
                );
                RegisterWorkflow(false);

                RegisterTextParameter('ItemAddOnNo', '');
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupItemAddOn(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        NpIaItemAddOn: Record "NPR NpIa Item AddOn";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'ItemAddOnNo' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        Handled := true;

        NpIaItemAddOn.SetRange(Enabled, true);
        if PAGE.RunModal(0, NpIaItemAddOn) = ACTION::LookupOK then
            POSParameterValue.Value := NpIaItemAddOn."No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'select_addon':
                OnActionSelectAddOn(JSON, FrontEnd);
            'insert_addons':
                OnActionInsertAddOns(JSON, POSSession, FrontEnd);
        end;

        Handled := true;
    end;

    local procedure OnActionSelectAddOn(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NpIaItemAddOn: Record "NPR NpIa Item AddOn";
    begin
        NpIaItemAddOn.SetRange(Enabled, true);
        if PAGE.RunModal(0, NpIaItemAddOn) <> ACTION::LookupOK then
            exit;

        JSON.SetContext('item_addon', NpIaItemAddOn."No.");
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionInsertAddOns(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        NpIaItemAddOn: Record "NPR NpIa Item AddOn";
        SalePOS: Record "NPR Sale POS";
        AppliesToSaleLinePOS: Record "NPR Sale Line POS";
        NpIaItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        AddOnNo: Code[20];
    begin
        JSON.SetScope('/', true);
        AddOnNo := JSON.GetString('item_addon', true);
        NpIaItemAddOn.Get(AddOnNo);
        NpIaItemAddOn.TestField(Enabled);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        CurrNpIaItemAddOn := NpIaItemAddOn;
        Clear(AppliesToSaleLinePOS);
        FindBaseLine(POSSession, AppliesToSaleLinePOS);
        NpIaItemAddOnMgt.CreateUserInterface(Model, SalePOS, AppliesToSaleLinePOS, NpIaItemAddOn);
        ActiveModelID := FrontEnd.ShowModel(Model);
    end;

    local procedure FindBaseLine(POSSession: Codeunit "NPR POS Session"; var AppliesToSaleLinePOS: Record "NPR Sale Line POS")
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        NpIaItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NoBaseLineFound: Label 'Item AddOn lines must be associated to a base item sale line. Please add a base item to the sale and then continue with the AddOns.';
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(AppliesToSaleLinePOS);
        NpIaItemAddOnMgt.FilterSaleLinePOS2ItemAddOnPOSLine(AppliesToSaleLinePOS, SaleLinePOSAddOn);
        if SaleLinePOSAddOn.FindFirst then
            if SaleLinePOSAddOn."Applies-to Line No." <> 0 then
                AppliesToSaleLinePOS.Get(
                  AppliesToSaleLinePOS."Register No.",
                  AppliesToSaleLinePOS."Sales Ticket No.",
                  AppliesToSaleLinePOS.Date,
                  AppliesToSaleLinePOS."Sale Type",
                  SaleLinePOSAddOn."Applies-to Line No.");

        if AppliesToSaleLinePOS."Line No." = 0 then
            Error(NoBaseLineFound);
    end;

    //--- Approve ---

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnProtocolUIResponse', '', true, true)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    begin
        if ModelID <> ActiveModelID then
            exit;

        Handled := true;

        Approve(EventName, FrontEnd, Sender <> 'approve');
        FrontEnd.CloseModel(ModelID);
    end;

    local procedure Approve(JsonText: Text; FrontEnd: Codeunit "NPR POS Front End Management"; OnlyFixedQtyLines: Boolean)
    var
        AppliesToSaleLinePOS: Record "NPR Sale Line POS";
        POSSession: Codeunit "NPR POS Session";
        NpIaItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        POSJavaScriptInterface: Codeunit "NPR POS JavaScript Interface";
        AddOnLines: DotNet JToken;
    begin
        AddOnLines := AddOnLines.Parse(JsonText);
        FrontEnd.GetSession(POSSession);
        FindBaseLine(POSSession, AppliesToSaleLinePOS);
        Clear(NpIaItemAddOnMgt);
        NpIaItemAddOnMgt.InsertPOSAddOnLines(
          CurrNpIaItemAddOn, AddOnLines, POSSession, AppliesToSaleLinePOS."Line No.", OnlyFixedQtyLines);
        if NpIaItemAddOnMgt.InsertedWithAutoSplitKey() then
            POSSession.ChangeViewSale();  //there is no other way to refresh the lines, so they appear in correct order

        POSSession.RequestRefreshData();
        POSJavaScriptInterface.RefreshData(POSSession, FrontEnd);
    end;

    trigger Model::OnModelControlEvent(control: DotNet NPRNetControl; eventName: Text; data: DotNet NPRNetDictionary_Of_T_U)
    begin
    end;

    trigger Model::OnTimer()
    begin
    end;
}