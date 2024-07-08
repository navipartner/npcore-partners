codeunit 6150872 "NPR POSAction: DocPrepayRefund" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Create a refund line for any paid prepayments of the selected line. A credit memo for all prepayment invoices will be posted upon POS sale end.';
        DescPrintDoc: Label 'Print standard report for prepayment credit note.';
        DescDeleteAfter: Label 'Delete open sales document after prepayment credit memo has been posted and refunded.';
        CaptionPrintDoc: Label 'Print Document';
        CaptionDeleteAfter: Label 'Delete Document';
        CaptionSelectCustomer: Label 'Select Customer';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        CaptionSendDoc: Label 'Send Document';
        DescSendDoc: Label 'Use Document Sending Profiles to send the posted document';
        CaptionPdf2NavDoc: Label 'Pdf2Nav Send Document';
        DescPdf2NavDoc: Label 'Use Pdf2Nav to send the posted document';
        SalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter('PrintPrepaymentCreditNote', false, CaptionPrintDoc, DescPrintDoc);
        WorkflowConfig.AddBooleanParameter('DeleteDocumentAfterRefund', false, CaptionDeleteAfter, DescDeleteAfter);
        WorkflowConfig.AddBooleanParameter('SelectCustomer', true, CaptionSelectCustomer, DescSelectCustomer);
        WorkflowConfig.AddBooleanParameter('SendDocument', false, CaptionSendDoc, DescSendDoc);
        WorkflowConfig.AddBooleanParameter('Pdf2NavDocument', false, CaptionPdf2NavDoc, DescPdf2NavDoc);
        WorkflowConfig.AddBooleanParameter('ConfirmInvDiscAmt', false, SalesDocImpMgt.GetConfirmInvDiscAmtLbl(), SalesDocImpMgt.GetConfirmInvDiscAmtDescLbl());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'RefundPrepay':
                FrontEnd.WorkflowResponse(RefundPrepayment(Context, Sale));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionDocPrepayRefund.js###
'let main=async({})=>await workflow.respond("RefundPrepay");'
                );
    end;

    local procedure RefundPrepayment(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"): JsonObject
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSActionDocPrepayB: Codeunit "NPR POS Action: Doc. Prepay B";
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
        POSAsyncPosting: Codeunit "NPR POS Async. Posting Mgt.";
        PrintPrepaymentCreditNote, DeleteDocumentAfterRefund, SelectCustomer, Send, Pdf2Nav, ConfirmInvDiscAmt : Boolean;
    begin
        Sale.GetCurrentSale(SalePOS);
        PrintPrepaymentCreditNote := Context.GetBooleanParameter('PrintPrepaymentCreditNote');
        DeleteDocumentAfterRefund := Context.GetBooleanParameter('DeleteDocumentAfterRefund');
        SelectCustomer := Context.GetBooleanParameter('SelectCustomer');
        Send := Context.GetBooleanParameter('SendDocument');
        Pdf2Nav := Context.GetBooleanParameter('Pdf2NavDocument');
        ConfirmInvDiscAmt := Context.GetBooleanParameter('ConfirmInvDiscAmt');
        POSSalesDocumentPost := POSAsyncPosting.GetPOSSalePostingMandatoryFlow();

        if not POSActionDocPrepayB.CheckCustomer(SalePOS, Sale, SelectCustomer) then
            exit;

        if not POSActionDocPrepayB.SelectDocument(SalePOS, SalesHeader) then
            exit;

        if not POSActionDocPrepayB.ConfirmImportInvDiscAmt(SalesHeader, ConfirmInvDiscAmt) then
            exit;

        if POSSalesDocumentPost = POSSalesDocumentPost::Asynchronous then
            POSAsyncPosting.FromPOSRelatedPOSTransExist(SalesHeader);
        POSActionDocPrepayB.CreatePrepaymentRefundLine(POSSession, SalesHeader, PrintPrepaymentCreditNote, DeleteDocumentAfterRefund, Send, Pdf2Nav, POSSalesDocumentPost);

    end;
}