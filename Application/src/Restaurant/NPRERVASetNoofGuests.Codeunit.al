codeunit 6150686 "NPR NPRE RVA: Set No.of Guests" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action sets number of guests for a waiter pad from Restaurant View';
        ParamSeatingCode_CptLbl: Label 'Seating Code';
        ParamSeatingCode_DescLbl: Label 'Selected seating code.';
        ParamWaiterPadCode_CptLbl: Label 'Waiter Pad Code';
        ParamWaiterPadCode_DescLbl: Label 'Selected waiter pad code.';
        ParamNoOfGuests_CptLbl: Label 'Number of Guests';
        ParamNoOfGuests_DescLbl: Label 'Number of guests at the selcted table.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('SeatingCode', '', ParamSeatingCode_CptLbl, ParamSeatingCode_DescLbl);
        WorkflowConfig.AddTextParameter('WaiterPadCode', '', ParamWaiterPadCode_CptLbl, ParamWaiterPadCode_DescLbl);
        WorkflowConfig.AddIntegerParameter('NoOfGuests', 0, ParamNoOfGuests_CptLbl, ParamNoOfGuests_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        WaiterPad."No." := CopyStr(Context.GetStringParameter('WaiterPadCode'), 1, MaxStrLen(WaiterPad."No."));
        Context.GetStringParameter('SeatingCode');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPRERVASetNoofGuests.js###
'let main=async({})=>await workflow.respond();'
        );
    end;
}
