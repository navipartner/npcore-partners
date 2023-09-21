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
        ParamSeatingCode_CptLbl: Label 'Seating Code';
        ParamSeatingCode_DescLbl: Label 'Selected seating code.';
        ParamSwitchToSaleView_CptLbl: Label 'Switch To Sale View';
        ParamSwitchToSaleView_DescLbl: Label 'Switch back to sale view if true.';
        LabelWelcome_CptLbl: Label 'Welcome';
        LabelNewWaiterpad_CptLbl: Label 'New Waiterpad';
        LabelNumberOfGuests_CptLbl: Label 'Number of guests';
        LabelName_CptLbl: Label 'Name';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('SeatingCode', '', ParamSeatingCode_CptLbl, ParamSeatingCode_DescLbl);
        WorkflowConfig.AddBooleanParameter('SwitchToSaleView', false, ParamSwitchToSaleView_CptLbl, ParamSwitchToSaleView_DescLbl);
        WorkflowConfig.AddLabel('Welcome', LabelWelcome_CptLbl);
        WorkflowConfig.AddLabel('NewWaiterpad', LabelNewWaiterpad_CptLbl);
        WorkflowConfig.AddLabel('NumberOfGuests', LabelNumberOfGuests_CptLbl);
        WorkflowConfig.AddLabel('Name', LabelName_CptLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        BusinessLogic: Codeunit "NPR POSAct. RV New WPad-B";
        FrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSession: Codeunit "NPR POS Session";
        RestaurantCode: Code[20];
        SwitchToSaleView: Boolean;
    begin
        If Step = 'checkSeating' then begin
            BusinessLogic.CheckSeating(SeatingCode(Context));
            Context.SetContext('defaultNumberOfGuests', BusinessLogic.GetDefaultNumberOfGuests(SeatingCode(Context)));
            Exit;
        end;

        SwitchToSaleView := Context.GetBooleanParameter('SwitchToSaleView');
        BusinessLogic.NewWaiterPad(Sale, Setup, SeatingCode(Context), TableName(Context), PartySize(Context), SwitchToSaleView, WaiterPad, RestaurantCode);
        FrontendAssistant.RefreshWaiterPadData(POSSession, FrontEnd, RestaurantCode, '');
        FrontendAssistant.RefreshWaiterPadContent(POSSession, FrontEnd, WaiterPad);
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
'let main=async({workflow:t,context:a,captions:e})=>{await t.respond("checkSeating");let i={caption:e.Welcome,title:e.NewWaiterpad,settings:[{type:"plusminus",id:"guests",caption:e.NumberOfGuests,minvalue:0,maxvalue:100,value:a.defaultNumberOfGuests},{type:"text",id:"tablename",caption:e.Name}]};a.waiterpadInfo=await popup.configuration(i),a.waiterpadInfo&&await t.respond()};'
        );
    end;
}
