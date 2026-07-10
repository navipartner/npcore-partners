codeunit 6248734 "NPR NPEmailPostSIDocType" implements "NPR INPEmailDocType"
{
    Access = Internal;

    procedure GetDataProvider(): Enum "NPR DynTemplateDataProvider"
    begin
        exit(Enum::"NPR DynTemplateDataProvider"::POST_SALES_DOC_NOTIFICATION);
    end;

    procedure GetSourceTableId(): Integer
    begin
        exit(Database::"Sales Invoice Header");
    end;

    procedure TrySendNPEmail(RecRef: RecordRef; TemplateId: Code[20]): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ReportSelections: Record "Report Selections";
        NPEmail: Codeunit "NPR NP Email";
        Sentry: Codeunit "NPR Sentry";
        RecipientAddress: Text[250];
    begin
        if RecRef.Number() <> Database::"Sales Invoice Header" then
            exit(false);
        RecRef.SetTable(SalesInvoiceHeader);
        if not SalesInvoiceHeader.Get(SalesInvoiceHeader."No.") then
            exit(false);

        // Resolve the recipient the same way the standard send does - from the Bill-to customer - so NP
        // Email reaches the same address the standard e-mail would have (Sell-to and Bill-to may differ).
        RecipientAddress := ReportSelections.GetEmailAddressIgnoringLayout("Report Selection Usage"::"S.Invoice", SalesInvoiceHeader, SalesInvoiceHeader."Bill-to Customer No.");
        if RecipientAddress = '' then
            exit(false);

        if NPEmail.TrySendEmail(TemplateId, SalesInvoiceHeader, RecipientAddress, SalesInvoiceHeader."Language Code") then
            exit(true);

        Sentry.AddLastErrorIfProgrammingBug();
        exit(false);
    end;
}
