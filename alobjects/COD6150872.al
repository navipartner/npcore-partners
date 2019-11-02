codeunit 6150872 "POS Action - Doc.Prepay Refund"
{
    // NPR5.50/MMV /20181105 CASE 300557 Created object
    // NPR5.52/MMV /20191004 CASE 352473 Added send & pdf2nav support.
    // 
    // This action does the reverse of action SALES_DOC_PREPAY.
    // It should only be used when full refund of prepayment invoices via the POS is intended. If the prepayment invoice(s) was not actually paid, a credit memo should just be applied manually to cancel it.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Create a refund line for any paid prepayments of the selected line. A credit memo for all prepayment invoices will be posted upon POS sale end.';
        DescPrintDoc: Label 'Print standard report for prepayment credit note.';
        DescDeleteAfter: Label 'Delete open sales document after prepayment credit memo has been posted and refunded.';
        CaptionPrintDoc: Label 'Print Document';
        CaptionDeleteAfter: Label 'Delete Document';
        NO_PREPAYMENT: Label '%1 %2 has no refundable prepayments!';
        CaptionSelectCustomer: Label 'Select Customer';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        CaptionSendDoc: Label 'Send Document';
        DescSendDoc: Label 'Use Document Sending Profiles to send the posted document';
        CaptionPdf2NavDoc: Label 'Pdf2Nav Send Document';
        DescPdf2NavDoc: Label 'Use Pdf2Nav to send the posted document';

    local procedure ActionCode(): Text
    begin
        exit ('SALES_DOC_PRE_REFUND');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.2'); //NPR5.52 [352473]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
          if DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then
          begin
            RegisterWorkflowStep('RefundPrepay','respond();');
            RegisterWorkflow(false);

            RegisterBooleanParameter('PrintPrepaymentCreditNote', false);
            RegisterBooleanParameter('DeleteDocumentAfterRefund', false);
            RegisterBooleanParameter('SelectCustomer', true);
        //-NPR5.52 [352473]
            RegisterBooleanParameter('SendDocument', false);
            RegisterBooleanParameter('Pdf2NavDocument', false);
        //+NPR5.52 [352473]
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        JSON: Codeunit "POS JSON Management";
        PrintPrepaymentCreditNote: Boolean;
        DeleteDocumentAfterRefund: Boolean;
        SelectCustomer: Boolean;
        Send: Boolean;
        Pdf2Nav: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        PrintPrepaymentCreditNote := JSON.GetBooleanParameter('PrintPrepaymentCreditNote', true);
        DeleteDocumentAfterRefund := JSON.GetBooleanParameter('DeleteDocumentAfterRefund', true);
        SelectCustomer := JSON.GetBooleanParameter('SelectCustomer', true);
        //-NPR5.52 [352473]
        Send := JSON.GetBooleanParameter('SendDocument', true);
        Pdf2Nav := JSON.GetBooleanParameter('Pdf2NavDocument', true);
        //+NPR5.52 [352473]

        if not CheckCustomer(POSSession, SelectCustomer) then
          exit;

        if not SelectDocument(Context, POSSession, FrontEnd, SalesHeader) then
          exit;

        //-NPR5.52 [352473]
        CreatePrepaymentRefundLine(POSSession, SalesHeader, PrintPrepaymentCreditNote, DeleteDocumentAfterRefund, Send, Pdf2Nav);
        //+NPR5.52 [352473]

        POSSession.RequestRefreshData();
    end;

    local procedure CheckCustomer(POSSession: Codeunit "POS Session";SelectCustomer: Boolean): Boolean
    var
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        Customer: Record Customer;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then begin
          SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
          exit(true);
        end;

        if not SelectCustomer then
          exit(true);

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
          exit(false);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit;
        exit(true);
    end;

    local procedure SelectDocument(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var SalesHeader: Record "Sales Header"): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."Customer No." <> '' then
          SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        exit(RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GetView(false), SalesHeader));
    end;

    local procedure CreatePrepaymentRefundLine(POSSession: Codeunit "POS Session";SalesHeader: Record "Sales Header";Print: Boolean;DeleteDocumentAfterRefund: Boolean;Send: Boolean;Pdf2Nav: Boolean)
    var
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
        POSPrepaymentMgt: Codeunit "POS Prepayment Mgt.";
    begin
        //-NPR5.52 [352473]
        // IF RetailSalesDocMgt.GetTotalPrepaidAmountNotDeducted(SalesHeader) <= 0 THEN
        //  ERROR(NO_PREPAYMENT, SalesHeader."Document Type", SalesHeader."No.");
        // RetailSalesDocMgt.CreatePrepaymentRefundLine(POSSession, SalesHeader, PrintPrepaymentCreditNote, TRUE, DeleteDocumentAfterRefund);
        if POSPrepaymentMgt.GetPrepaymentAmountToDeductInclVAT(SalesHeader) <= 0 then
          Error(NO_PREPAYMENT, SalesHeader."Document Type", SalesHeader."No.");

        RetailSalesDocMgt.CreatePrepaymentRefundLine(POSSession, SalesHeader, Print, Send, Pdf2Nav, true, DeleteDocumentAfterRefund);
        //+NPR5.52 [352473]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'PrintPrepaymentCreditNote' : Caption := CaptionPrintDoc;
          'DeleteDocumentAfterRefund' : Caption := CaptionDeleteAfter;
          'SelectCustomer' : Caption := CaptionSelectCustomer;
        //-NPR5.52 [352473]
          'SendDocument' : Caption := CaptionSendDoc;
          'Pdf2NavDocument' : Caption := CaptionPdf2NavDoc;
        //+NPR5.52 [352473]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'PrintPrepaymentCreditNote' : Caption := DescPrintDoc;
          'DeleteDocumentAfterRefund' : Caption := DescDeleteAfter;
          'SelectCustomer' : Caption := DescSelectCustomer;
        //-NPR5.52 [352473]
          'SendDocument' : Caption := DescSendDoc;
          'Pdf2NavDocument' : Caption := DescPdf2NavDoc;
        //+NPR5.52 [352473]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
        end;
    end;
}

