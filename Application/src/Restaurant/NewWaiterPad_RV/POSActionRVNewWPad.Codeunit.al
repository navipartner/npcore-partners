codeunit 6150682 "NPR POSAction: RV New WPad" implements "NPR IPOS Workflow"
{
    Access = Internal;

    internal procedure ActionCode(): Code[20]
    begin
        exit(Format("NPR POS Workflow"::RV_NEW_WAITER_PAD));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action creates a new waiter pad for the selected seating code.';
        ParamAskForNumberOfGuests_CptLbl: Label 'Ask for number of guests';
        ParamAskForNumberOfGuests_DescLbl: Label 'Ask for number of guests before ne waiter pad is created.';
        ParamAskForCustomerEmail_CptLbl: Label 'Request customer email';
        ParamAskForCustomerEmail_DescLbl: Label 'Ask for customer email address.';
        ParamAskForCustomerName_CptLbl: Label 'Request customer name';
        ParamAskForCustomerName_DescLbl: Label 'Ask for customer name.';
        ParamAskForCustomerPhoneNo_CptLbl: Label 'Request customer phone No.';
        ParamAskForCustomerPhoneNo_DescLbl: Label 'Ask for customer phone number.';
        ParamSeatingCode_CptLbl: Label 'Seating Code';
        ParamSeatingCode_DescLbl: Label 'Selected seating code.';
        ParamSwitchToSaleView_CptLbl: Label 'Switch To Sale View';
        ParamSwitchToSaleView_DescLbl: Label 'Switch back to sale view if true.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('SeatingCode', '', ParamSeatingCode_CptLbl, ParamSeatingCode_DescLbl);
        WorkflowConfig.AddBooleanParameter('SwitchToSaleView', false, ParamSwitchToSaleView_CptLbl, ParamSwitchToSaleView_DescLbl);
        WorkflowConfig.AddBooleanParameter('AskForNumberOfGuests', false, ParamAskForNumberOfGuests_CptLbl, ParamAskForNumberOfGuests_DescLbl);
        WorkflowConfig.AddBooleanParameter('RequestCustomerName', false, ParamAskForCustomerName_CptLbl, ParamAskForCustomerName_DescLbl);
        WorkflowConfig.AddBooleanParameter('RequestCustomerPhone', false, ParamAskForCustomerPhoneNo_CptLbl, ParamAskForCustomerPhoneNo_DescLbl);
        WorkflowConfig.AddBooleanParameter('RequestCustomerEmail', false, ParamAskForCustomerEmail_CptLbl, ParamAskForCustomerEmail_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        BusinessLogic: Codeunit "NPR POSAct. RV New WPad-B";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        CustomerDetails: Dictionary of [Text, Text];
        WaiterpadInfoConfig: JsonObject;
        RestaurantCode: Code[20];
        AskForNumberOfGuests: Boolean;
        RequestCustomerName: Boolean;
        RequestCustomerPhone: Boolean;
        RequestCustomerEmail: Boolean;
        SwitchToSaleView: Boolean;
    begin
        If Step = 'checkSeating' then begin
            BusinessLogic.CheckSeating(SeatingCode(Context));
            Sale.GetCurrentSale(SalePOS);
            if Context.GetBooleanParameter('AskForNumberOfGuests', AskForNumberOfGuests) then;
            if Context.GetBooleanParameter('RequestCustomerName', RequestCustomerName) then;
            if Context.GetBooleanParameter('RequestCustomerPhone', RequestCustomerPhone) then;
            if Context.GetBooleanParameter('RequestCustomerEmail', RequestCustomerEmail) then;
            if WaiterPadPOSMgt.GenerateNewWaiterPadConfig(SalePOS, AskForNumberOfGuests, RequestCustomerName, RequestCustomerPhone, RequestCustomerEmail, false, WaiterpadInfoConfig) then begin
                Context.SetContext('requestCustomerInfo', true);
                Context.SetContext('waiterpadInfoConfig', WaiterpadInfoConfig);
                Exit;
            end else
                Context.SetContext('requestCustomerInfo', false);
        end;

        SwitchToSaleView := Context.GetBooleanParameter('SwitchToSaleView');
        CustomerDetails.Add(WaiterPad.FieldName(Description), TableName(Context));
        CustomerDetails.Add(WaiterPad.FieldName("Customer Phone No."), PhoneNo(Context));
        CustomerDetails.Add(WaiterPad.FieldName("Customer E-Mail"), Email(Context));
        BusinessLogic.NewWaiterPad(Sale, Setup, SeatingCode(Context), CustomerDetails, PartySize(Context), SwitchToSaleView, WaiterPad, RestaurantCode);
        FrontendAssistant.RefreshWaiterPadData(POSSession, FrontEnd, RestaurantCode, '');
        if SwitchToSaleView then
            SelectSalesView(POSSession);
    end;

    local procedure SeatingCode(Context: Codeunit "NPR POS JSON Helper"): Code[20]
    begin
        exit(CopyStr(Context.GetStringParameter('SeatingCode'), 1, 20));
    end;

    local procedure TableName(Context: Codeunit "NPR POS JSON Helper"): Text
    begin
        exit(GetConfigurableOption(Context, 'waiterpadInfo', 'tablename'));
    end;

    local procedure PhoneNo(Context: Codeunit "NPR POS JSON Helper"): Text
    begin
        exit(GetConfigurableOption(Context, 'waiterpadInfo', 'phoneNo'));
    end;

    local procedure Email(Context: Codeunit "NPR POS JSON Helper"): Text
    begin
        exit(GetConfigurableOption(Context, 'waiterpadInfo', 'email'));
    end;

    local procedure PartySize(Context: Codeunit "NPR POS JSON Helper"): Integer
    var
        NumberOfGuests: Integer;
    begin
        if not Evaluate(NumberOfGuests, GetConfigurableOption(Context, 'waiterpadInfo', 'guests')) then
            NumberOfGuests := 1;
        exit(NumberOfGuests);
    end;

    local procedure SelectSalesView(POSSession: Codeunit "NPR POS Session")
    begin
        POSSession.ChangeViewSale();
    end;

    local procedure GetConfigurableOption(Context: Codeunit "NPR POS JSON Helper"; Scope: Text; "Key": Text): Text
    var
        ResultOut: text;
    begin
        Context.SetScopeRoot();
        if not Context.TrySetScope(Scope) then
            exit('');

        if Context.GetString("Key", ResultOut) then
            exit(ResultOut)
        else
            exit('');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionRVNewWPad.js###
'let main=async({workflow:i,context:a})=>{await i.respond("checkSeating"),a.requestCustomerInfo&&(a.waiterpadInfo=await popup.configuration(a.waiterpadInfoConfig),a.waiterpadInfo&&await i.respond())};'
        );
    end;
}
