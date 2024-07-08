codeunit 6150862 "NPR POS Action: Doc. Pay&Post" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Create a payment line to balance an open sales order and post the order upon POS sale end.';
        CaptionPrintDocument: Label 'Print Document';
        DescPrintDocument: Label 'Print the sales documents after posting';
        CaptionSelectCustomer: Label 'Select Customer';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        CaptionOpenDoc: Label 'Open Document';
        DescOpenDoc: Label 'Open the selected order before remaining amount is imported';
        CaptionSendDoc: Label 'Send Document';
        DescSendDoc: Label 'Use Document Sending Profiles to send the posted document';
        CaptionPdf2NavDoc: Label 'Pdf2Nav Send Document';
        DescPdf2NavDoc: Label 'Use Pdf2Nav to send the posted document';
        CaptionAutoQtyToInvoice: Label 'Auto. Qty. to Invoice';
        CaptionAutoQtyToShip: Label 'Auto. Qty. to Ship';
        CaptionAutoQtyToReceive: Label 'Auto. Qty. to Receive';
        DescAutoQtyToInvoice: Label 'Configure if the document lines quantity to invoice should be handled automatically';
        DescAutoQtyToShip: Label 'Configure if the document lines quantity to ship should be handled automatically';
        DescAutoQtyToReceive: Label 'Configure if the document lines quantity to receive should be handled automatically';
        SalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        AutoQtyOptionNamesLbl: Label 'Disabled,None,All', Locked = true;
        AutoQtyOptionCptLbl: Label 'Disabled,None,All';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter('PrintDocument', false, CaptionPrintDocument, DescPrintDocument);
        WorkflowConfig.AddBooleanParameter('OpenDocument', false, CaptionOpenDoc, DescOpenDoc);
        WorkflowConfig.AddBooleanParameter('SelectCustomer', true, CaptionSelectCustomer, DescSelectCustomer);
        WorkflowConfig.AddBooleanParameter('SendDocument', false, CaptionSendDoc, DescSendDoc);
        WorkflowConfig.AddBooleanParameter('Pdf2NavDocument', false, CaptionPdf2NavDoc, DescPdf2NavDoc);
        WorkflowConfig.AddBooleanParameter('ConfirmInvDiscAmt', false, SalesDocImpMgt.GetConfirmInvDiscAmtLbl(), SalesDocImpMgt.GetConfirmInvDiscAmtDescLbl());
        WorkflowConfig.AddOptionParameter('AutoQtyToInvoice',
                                            AutoQtyOptionNamesLbl,
#pragma warning disable AA0139
                                            SelectStr(1, AutoQtyOptionNamesLbl),
# pragma warning restore
                                            CaptionAutoQtyToInvoice,
                                            DescAutoQtyToInvoice,
                                            AutoQtyOptionCptLbl);
        WorkflowConfig.AddOptionParameter('AutoQtyToShip',
                                            AutoQtyOptionNamesLbl,
#pragma warning disable AA0139
                                            SelectStr(1, AutoQtyOptionNamesLbl),
# pragma warning restore
                                            CaptionAutoQtyToShip,
                                            DescAutoQtyToShip,
                                            AutoQtyOptionCptLbl);
        WorkflowConfig.AddOptionParameter('AutoQtyToReceive',
                                            AutoQtyOptionNamesLbl,
#pragma warning disable AA0139
                                            SelectStr(1, AutoQtyOptionNamesLbl),
# pragma warning restore
                                            CaptionAutoQtyToReceive,
                                            DescAutoQtyToReceive,
                                            AutoQtyOptionCptLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var

    begin
        case Step of
            'PayAndPostDocument':
                FrontEnd.WorkflowResponse(PayAndPost(Context, Sale));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionDocPayPost.js###
'let main=async({})=>await workflow.respond("PayAndPostDocument");'
        );
    end;

    local procedure PayAndPost(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"): JsonObject
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        SelectCustomer, OpenDocument, PrintDocument, Send, Pdf2Nav, ConfirmInvDiscAmt : Boolean;
        AutoQtyToInvoice: Integer;
        AutoQtyToShip: Integer;
        AutoQtyToReceive: Integer;
        POSActionDocPayPostB: Codeunit "NPR POS Action: Doc.Pay&Post B";
        POSSession: Codeunit "NPR POS Session";
        POSAsyncPosting: Codeunit "NPR POS Async. Posting Mgt.";
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        Sale.GetCurrentSale(SalePOS);

        SelectCustomer := Context.GetBooleanParameter('SelectCustomer');
        OpenDocument := Context.GetBooleanParameter('OpenDocument');
        PrintDocument := Context.GetBooleanParameter('PrintDocument');
        Send := Context.GetBooleanParameter('SendDocument');
        Pdf2Nav := Context.GetBooleanParameter('Pdf2NavDocument');
        ConfirmInvDiscAmt := Context.GetBooleanParameter('ConfirmInvDiscAmt');
        AutoQtyToInvoice := Context.GetIntegerParameter('AutoQtyToInvoice');
        AutoQtyToShip := Context.GetIntegerParameter('AutoQtyToShip');
        AutoQtyToReceive := Context.GetIntegerParameter('AutoQtyToReceive');

        if not POSActionDocPayPostB.CheckCustomer(SalePOS, Sale, SelectCustomer) then
            exit;
        if not POSActionDocPayPostB.SelectDocument(SalePOS, SalesHeader) then
            exit;
        POSActionDocPayPostB.SetLinesToPost(SalesHeader, AutoQtyToInvoice, AutoQtyToShip, AutoQtyToReceive); //Commits

        if not POSActionDocPayPostB.ConfirmDocument(SalesHeader, OpenDocument) then
            exit;
        if not POSActionDocPayPostB.ConfirmIfInvoiceQuantityIncreased(SalesHeader, AutoQtyToInvoice) then
            exit;
        if not POSActionDocPayPostB.ConfirmImportInvDiscAmt(SalesHeader, ConfirmInvDiscAmt) then
            exit;

        POSSalesDocumentPost := POSAsyncPosting.GetPOSSalePostingMandatoryFlow();
        if not OpenDocument then
            if POSSalesDocumentPost = POSSalesDocumentPost::Asynchronous then
                POSAsyncPosting.FromPOSRelatedPOSTransExist(SalesHeader);

        POSActionDocPayPostB.CreateDocumentPaymentLine(POSSession, SalesHeader, PrintDocument, Send, Pdf2Nav, POSSalesDocumentPost);
    end;
}
