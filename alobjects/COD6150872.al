codeunit 6150872 "POS Action - Doc.Prepay Refund"
{
    // NPR5.50/MMV /20181105 CASE 300557 Created object
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

    local procedure ActionCode(): Text
    begin
        exit ('SALES_DOC_PRE_REFUND');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
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
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        JSON: Codeunit "POS JSON Management";
        PrintPrepaymentCreditNote: Boolean;
        DeleteDocumentAfterRefund: Boolean;
        SelectCustomer: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        PrintPrepaymentCreditNote := JSON.GetBooleanParameter('PrintPrepaymentCreditNote', true);
        DeleteDocumentAfterRefund := JSON.GetBooleanParameter('DeleteDocumentAfterRefund', true);
        SelectCustomer := JSON.GetBooleanParameter('SelectCustomer', true);

        if not CheckCustomer(POSSession, SelectCustomer) then
          exit;

        if not SelectDocument(Context, POSSession, FrontEnd, SalesHeader) then
          exit;

        CreatePrepaymentRefundLine(POSSession, SalesHeader, PrintPrepaymentCreditNote, DeleteDocumentAfterRefund);

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

    local procedure SelectDocument(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var SalesHeader: Record "Sales Header"): Boolean
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

    local procedure CreatePrepaymentRefundLine(POSSession: Codeunit "POS Session";SalesHeader: Record "Sales Header";PrintPrepaymentCreditNote: Boolean;DeleteDocumentAfterRefund: Boolean)
    var
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
    begin
        if RetailSalesDocMgt.GetTotalPrepaidAmountNotDeducted(SalesHeader) <= 0 then
          Error(NO_PREPAYMENT, SalesHeader."Document Type", SalesHeader."No.");
        RetailSalesDocMgt.CreatePrepaymentRefundLine(POSSession, SalesHeader, PrintPrepaymentCreditNote, true, DeleteDocumentAfterRefund);
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

