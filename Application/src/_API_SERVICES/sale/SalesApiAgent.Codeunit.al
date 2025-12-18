#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248182 "NPR SalesApiAgent"
{
    Access = Internal;

    internal procedure GetInvoiceByDocumentNoAsPdf(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ReportSelections: Record "Report Selections";
        DocumentNoText: Text;
        PdfSalesInvoice: Text;
        ReportId: Integer;
        RecRef: RecordRef;
    begin
        Request.SkipCacheIfNonStickyRequest(GetSalesInvoiceTableIds());
        if (not Request.Paths().Get(3, DocumentNoText)) then
            exit(Response.RespondBadRequest('Missing required parameter: documentNo'));

        SalesInvoiceHeader.ReadIsolation := SalesInvoiceHeader.ReadIsolation::ReadCommitted;
        if (not SalesInvoiceHeader.Get(DocumentNoText)) then
            exit(Response.RespondResourceNotFound());

        ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Invoice");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        if not ReportSelections.FindFirst() then
            exit(Response.RespondBadRequest('No report configured in Report Selections for usage "S.Invoice"'));
        ReportId := ReportSelections."Report ID";

        SalesInvoiceHeader.SetRecFilter();
        RecRef.GetTable(SalesInvoiceHeader);
        PdfSalesInvoice := ReportToBase64(ReportId, RecRef);

        exit(Response.RespondOK(PdfSalesInvoice));
    end;

#region Private Methods
    local procedure GetSalesInvoiceTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"Sales Invoice Header");
        TableIds.Add(Database::"Sales Invoice Line");
    end;

    local procedure ReportToBase64(ReportID: Integer; RecRef: RecordRef): Text
    var
        Base64Codeunit: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
    begin
        TempBlob.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        Report.SaveAs(ReportID, '', ReportFormat::Pdf, OutStr, RecRef);
        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF8);

        exit(Base64Codeunit.ToBase64(InStr));
    end;
#endregion Private Methods
}
#endif
