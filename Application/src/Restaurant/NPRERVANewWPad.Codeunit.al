codeunit 6150682 "NPR NPRE RVA: New WPad" implements "NPR IPOS Workflow"
{
    Access = Internal;

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
        POSSession: Codeunit "NPR POS Session";
    begin
        if (Context.GetString('waiterpadInfo') = '') then
            exit;

        NewWaiterPad(POSSession, FrontEnd, Context);
    end;

    procedure NewWaiterPad(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: Codeunit "NPR POS JSON Helper");
    var
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        SalePOS: Record "NPR POS Sale";
        NPREFrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SeatingCode: Code[20];
        Description: Text;
        NumberOfGuests: Integer;
        NotValidSettingErr: Label 'The provided seating code "%1" is invalid. A new waiterpad was not created.';
    begin
        SeatingCode := CopyStr(Context.GetStringParameter('SeatingCode'), 1, MaxStrLen(SeatingCode));

        if not Seating.Get(SeatingCode) then begin
            Message(NotValidSettingErr, SeatingCode);
            exit;
        end;

        Description := GetConfigurableOption(Context, 'waiterpadInfo', 'tablename');
        if not Evaluate(NumberOfGuests, GetConfigurableOption(Context, 'waiterpadInfo', 'guests')) then
            NumberOfGuests := 1;

        POSSession.GetSetup(Setup);
        WaiterPadMgt.CreateNewWaiterPad(Seating.Code, NumberOfGuests, Setup.Salesperson(), Description, WaiterPad);

        SeatingLocation.Get(Seating."Seating Location");
        NPREFrontendAssistant.RefreshWaiterPadData(POSSession, FrontEnd, SeatingLocation."Restaurant Code", '');
        NPREFrontendAssistant.RefreshWaiterPadContent(POSSession, FrontEnd, WaiterPad."No.");

        if Context.GetBooleanParameter('SwitchToSaleView') then begin
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            SalePOS.Find();
            SalePOS."NPRE Number of Guests" := NumberOfGuests;
            SalePOS."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
            SalePOS.Validate("NPRE Pre-Set Seating Code", SeatingCode);
            POSSale.Refresh(SalePOS);
            POSSale.Modify(true, false);

            SelectSalesView(POSSession);
        end;
    end;

    local procedure SelectSalesView(POSSession: Codeunit "NPR POS Session");
    begin
        POSSession.ChangeViewSale();
    end;

    local procedure GetConfigurableOption(Context: Codeunit "NPR POS JSON Helper"; Scope: Text; "Key": Text): Text;
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
        //###NPR_INJECT_FROM_FILE:NPRERVANewWPad.js###
'let main=async({workflow:e,context:a})=>{let t={caption:"Welcome",title:"New Waiterpad",settings:[{type:"plusminus",id:"guests",caption:"Number of Guests",minvalue:1,maxvalue:100,value:1},{type:"text",id:"tablename",caption:"Name"}]};a.waiterpadInfo=await popup.configuration(t),await e.respond()};'
        );
    end;
}
