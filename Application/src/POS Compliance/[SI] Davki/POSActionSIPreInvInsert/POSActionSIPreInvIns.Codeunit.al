codeunit 6184559 "NPR POS Action: SIPreInv Ins." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Insert Prenumbered Invoice Book''s information for current sale';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'InsertSalesbookReceiptInfo':
                InsertSalesbookReceiptInfo(Sale);
        end;
    end;

    local procedure InsertSalesbookReceiptInfo(Sale: Codeunit "NPR POS Sale")
    var
        POSActionSIPreInvInsB: Codeunit "NPR POS Action: SIPreInv Ins B";
    begin
        POSActionSIPreInvInsB.InsertSalesbookReceiptInfo(Sale)
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionSIPreInvIns.js###
        'let main = async ({ workflow, popup, captions }) => { return workflow.respond("InsertSalesbookReceiptInfo"); }'
    );
    end;

    #region SI Compliance Test Procedure

    internal procedure InputAuditPreInvoiceNumbersTest(SetNumberNo: Text; SerialNumberNo: Text; ReceiptNo: Text; IssueDate: Date; POSSale: Record "NPR POS Sale")
    var
        SIPOSSale: Record "NPR SI POS Sale";
    begin
        SIPOSSale."POS Sale SystemId" := POSSale.SystemId;
        SIPOSSale."SI SB Set Number" := CopyStr(SetNumberNo, 1, MaxStrLen(SIPOSSale."SI SB Set Number"));
        SIPOSSale."SI SB Serial Number" := CopyStr(SerialNumberNo, 1, MaxStrLen(SIPOSSale."SI SB Serial Number"));
        SIPOSSale."SI SB Receipt No." := CopyStr(ReceiptNo, 1, MaxStrLen(SIPOSSale."SI SB Receipt No."));
        SIPOSSale."SI SB Receipt Issue Date" := IssueDate;

        if not SIPOSSale.Insert() then
            SIPOSSale.Modify();
    end;

    #endregion
}