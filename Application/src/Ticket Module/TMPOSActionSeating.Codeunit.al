codeunit 6151132 "NPR TM POS Action - Seating" implements "NPR IPOS Workflow"
{
    Access = Internal;
    // TM1.43/TSA /20190618 CASE 357359 Initial Version
    // TM1.45/TSA /20191112 CASE 322432 edit reservation
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Version 3 UX missing';


    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for running the ticket seating functionality';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        ShowSeating(FrontEnd, POSSession);
    end;

    local procedure ShowSeating(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SeatingUI: Codeunit "NPR TM Seating UI";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        TicketToken: Text[100];
    begin

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        TicketRequestManager.GetTokenFromReceipt(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", TicketToken);
        SeatingUI.ShowSelectSeatUI(FrontEnd, TicketToken, true);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:TMPOSActionSeating.js###
'let main=async({})=>await workflow.respond();'
        )
    end;
}

