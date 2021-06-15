codeunit 6150872 "NPR POSAction: DocPrepayRefund"
{
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
        exit('SALES_DOC_PRE_REFUND');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
  ActionCode(),
  ActionDescription,
  ActionVersion(),
  Sender.Type::Generic,
  Sender."Subscriber Instances Allowed"::Multiple) then begin
            Sender.RegisterWorkflowStep('RefundPrepay', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterBooleanParameter('PrintPrepaymentCreditNote', false);
            Sender.RegisterBooleanParameter('DeleteDocumentAfterRefund', false);
            Sender.RegisterBooleanParameter('SelectCustomer', true);
            Sender.RegisterBooleanParameter('SendDocument', false);
            Sender.RegisterBooleanParameter('Pdf2NavDocument', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        JSON: Codeunit "NPR POS JSON Management";
        PrintPrepaymentCreditNote: Boolean;
        DeleteDocumentAfterRefund: Boolean;
        SelectCustomer: Boolean;
        Send: Boolean;
        Pdf2Nav: Boolean;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        PrintPrepaymentCreditNote := JSON.GetBooleanParameterOrFail('PrintPrepaymentCreditNote', ActionCode());
        DeleteDocumentAfterRefund := JSON.GetBooleanParameterOrFail('DeleteDocumentAfterRefund', ActionCode());
        SelectCustomer := JSON.GetBooleanParameterOrFail('SelectCustomer', ActionCode());
        Send := JSON.GetBooleanParameterOrFail('SendDocument', ActionCode());
        Pdf2Nav := JSON.GetBooleanParameterOrFail('Pdf2NavDocument', ActionCode());

        if not CheckCustomer(POSSession, SelectCustomer) then
            exit;

        if not SelectDocument(POSSession, SalesHeader) then
            exit;

        CreatePrepaymentRefundLine(POSSession, SalesHeader, PrintPrepaymentCreditNote, DeleteDocumentAfterRefund, Send, Pdf2Nav);

        POSSession.RequestRefreshData();
    end;

    local procedure CheckCustomer(POSSession: Codeunit "NPR POS Session"; SelectCustomer: Boolean): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
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
        Commit();
        exit(true);
    end;

    local procedure SelectDocument(POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        exit(RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GetView(false), SalesHeader));
    end;

    local procedure CreatePrepaymentRefundLine(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Print: Boolean; DeleteDocumentAfterRefund: Boolean; Send: Boolean; Pdf2Nav: Boolean)
    var
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
    begin
        if POSPrepaymentMgt.GetPrepaymentAmountToDeductInclVAT(SalesHeader) <= 0 then
            Error(NO_PREPAYMENT, SalesHeader."Document Type", SalesHeader."No.");

        RetailSalesDocMgt.CreatePrepaymentRefundLine(POSSession, SalesHeader, Print, Send, Pdf2Nav, true, DeleteDocumentAfterRefund);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'PrintPrepaymentCreditNote':
                Caption := CaptionPrintDoc;
            'DeleteDocumentAfterRefund':
                Caption := CaptionDeleteAfter;
            'SelectCustomer':
                Caption := CaptionSelectCustomer;
            'SendDocument':
                Caption := CaptionSendDoc;
            'Pdf2NavDocument':
                Caption := CaptionPdf2NavDoc;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'PrintPrepaymentCreditNote':
                Caption := DescPrintDoc;
            'DeleteDocumentAfterRefund':
                Caption := DescDeleteAfter;
            'SelectCustomer':
                Caption := DescSelectCustomer;
            'SendDocument':
                Caption := DescSendDoc;
            'Pdf2NavDocument':
                Caption := DescPdf2NavDoc;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
        end;
    end;
}
