codeunit 6150863 "NPR POS Action: Doc. Prepay" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Create a prepayment line for a sales order. Prepayment invoice will be posted & applied immediately upon sale end.';
        TextPrepaymentTitle: Label 'Prepayment';
        TextPrepaymentPctLead: Label 'Please specify prepayment % to be paid after export';
        TextPrepaymentAmountLead: Label 'Please specify prepayment amount to be paid after export';
        CaptionPrepaymentDlg: Label 'Prompt Prepayment Value';
        CaptionFixedPrepaymentValue: Label 'Fixed Prepayment Value';
        CaptionPrintDoc: Label 'Print Prepayment Document';
        CaptionPrepaymentIsAmount: Label 'Prepayment Value Is Amount';
        DescPrepaymentDlg: Label 'Ask user for prepayment percentage';
        DescFixedPrepaymentValue: Label 'Prepayment value to use either silently or as dialog default value';
        DescPrintDoc: Label 'Print standard prepayment document after posting.';
        DescPrepaymentIsAmount: Label 'The prompt or silent prepayment value is interpreted as an amount instead of percent';
        CaptionSelectCustomer: Label 'Select Customer';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        CaptionSendDocument: Label 'Send Document';
        CaptionPdf2NavDocument: Label 'Pdf2Nav Document';
        DescSendDocument: Label 'Handle output via document sending profiles';
        DescPdf2NavDocument: Label 'Handle output via PDF2NAV';
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter('InputIsAmount', false, CaptionPrepaymentIsAmount, DescPrepaymentIsAmount);
        WorkflowConfig.AddBooleanParameter('Dialog', true, CaptionPrepaymentDlg, DescPrepaymentDlg);
        WorkflowConfig.AddDecimalParameter('FixedValue', 0, CaptionFixedPrepaymentValue, DescFixedPrepaymentValue);
        WorkflowConfig.AddBooleanParameter('SendDocument', false, CaptionSendDocument, DescSendDocument);
        WorkflowConfig.AddBooleanParameter('Pdf2NavDocument', false, CaptionPdf2NavDocument, DescPdf2NavDocument);
        WorkflowConfig.AddBooleanParameter('PrintDocument', false, CaptionPrintDoc, DescPrintDoc);
        WorkflowConfig.AddBooleanParameter('SelectCustomer', true, CaptionSelectCustomer, DescSelectCustomer);
        WorkflowConfig.AddBooleanParameter('ConfirmInvDiscAmt', false, SalesDocImpMgt.GetConfirmInvDiscAmtLbl(), SalesDocImpMgt.GetConfirmInvDiscAmtDescLbl());
        WorkflowConfig.AddLabel('prepaymentDialogTitle', TextPrepaymentTitle);
        WorkflowConfig.AddLabel('prepaymentPctLead', TextPrepaymentPctLead);
        WorkflowConfig.AddLabel('prepaymentAmountLead', TextPrepaymentAmountLead);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var

    begin
        case Step of
            'prepayDocument':
                FrontEnd.WorkflowResponse(PrepayDocument(Context, Sale));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionDocPrepay.js###
'let main=async({workflow:n,captions:a,parameters:l,popup:t})=>{let e;if(l.Dialog){if(l.InputIsAmount){if(e=await t.numpad({caption:a.prepaymentAmountLead,title:a.prepaymentDialogTitle,value:l.FixedValue}),e===null)return}else if(e=await t.numpad({caption:a.prepaymentPctLead,title:a.prepaymentDialogTitle,value:l.FixedValue}),e===null)return}else e=l.FixedValue;return await n.respond("prepayDocument",{prepaymentValue:e})};'
                );
    end;

    local procedure PrepayDocument(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"): JsonObject
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        PrintPrepaymentDocument, SelectCustomer, InputIsAmount, Send, Pdf2Nav, ConfirmInvDiscAmt : Boolean;
        PrepaymentValue: Decimal;
        POSActionDocPrepayB: Codeunit "NPR POS Action: Doc. Prepay B";
        POSAsyncPosting: Codeunit "NPR POS Async. Posting Mgt.";
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        Sale.GetCurrentSale(SalePOS);

        PrintPrepaymentDocument := Context.GetBooleanParameter('PrintDocument');
        SelectCustomer := Context.GetBooleanParameter('SelectCustomer');
        Send := Context.GetBooleanParameter('SendDocument');
        Pdf2Nav := Context.GetBooleanParameter('Pdf2NavDocument');
        InputIsAmount := Context.GetBooleanParameter('InputIsAmount');
        ConfirmInvDiscAmt := Context.GetBooleanParameter('ConfirmInvDiscAmt');
        PrepaymentValue := Context.GetDecimal('prepaymentValue');

        POSSalesDocumentPost := POSAsyncPosting.GetPOSSalePostingMandatoryFlow(SalePOS."POS Store Code");

        if not POSActionDocPrepayB.CheckCustomer(SalePOS, Sale, SelectCustomer) then
            exit;

        if not POSActionDocPrepayB.SelectDocument(SalePOS, SalesHeader) then
            exit;

        if not POSActionDocPrepayB.ConfirmImportInvDiscAmt(SalesHeader, ConfirmInvDiscAmt) then
            exit;

        if POSSalesDocumentPost = POSSalesDocumentPost::Asynchronous then
            POSAsyncPosting.FromPOSRelatedPOSTransExist(SalesHeader);
        POSActionDocPrepayB.CreatePrepaymentLine(POSSession, SalesHeader, PrintPrepaymentDocument, PrepaymentValue, InputIsAmount, Send, Pdf2Nav, POSSalesDocumentPost);

    end;
}