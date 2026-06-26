#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248182 "NPR SalesApiAgent"
{
    Access = Internal;

    internal procedure GetInvoiceByDocumentNoAsPdf(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ReportSelections: Record "Report Selections";
        TempBlob: Codeunit "Temp Blob";
        Base64Codeunit: Codeunit "Base64 Convert";
        DocumentNoText: Text;
        PdfSalesInvoice: Text;
        ReportUsage: Enum "Report Selection Usage";
        InStr: InStream;
    begin
        Request.SkipCacheIfNonStickyRequest(GetSalesInvoiceTableIds());
        if (not Request.Paths().Get(3, DocumentNoText)) then
            exit(Response.RespondBadRequest('Missing required parameter: documentNo'));

        SalesInvoiceHeader.ReadIsolation := SalesInvoiceHeader.ReadIsolation::ReadCommitted;
        if (not SalesInvoiceHeader.Get(DocumentNoText)) then
            exit(Response.RespondResourceNotFound());

        SalesInvoiceHeader.SetRange("No.", SalesInvoiceHeader."No.");
        ReportUsage := "Report Selection Usage"::"S.Invoice";
        ReportSelections.GetPdfReportForCust(TempBlob, ReportUsage, SalesInvoiceHeader, SalesInvoiceHeader."Sell-to Customer No.");

        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF8);
        PdfSalesInvoice := Base64Codeunit.ToBase64(InStr);

        exit(Response.RespondOK(PdfSalesInvoice));
    end;

    internal procedure GetCrMemoByDocumentNoAsPdf(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReportSelections: Record "Report Selections";
        Base64Codeunit: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        DocumentNoText: Text;
        PdfSalesCrMemo: Text;
        ReportUsage: Enum "Report Selection Usage";
        InStr: InStream;
    begin
        Request.SkipCacheIfNonStickyRequest(GetSalesCrMemoTableIds());
        if (not Request.Paths().Get(3, DocumentNoText)) then
            exit(Response.RespondBadRequest('Missing required parameter: documentNo'));

        SalesCrMemoHeader.ReadIsolation := SalesCrMemoHeader.ReadIsolation::ReadCommitted;
        if (not SalesCrMemoHeader.Get(DocumentNoText)) then
            exit(Response.RespondResourceNotFound());

        SalesCrMemoHeader.SetRange("No.", SalesCrMemoHeader."No.");
        ReportUsage := "Report Selection Usage"::"S.Cr.Memo";
        ReportSelections.GetPdfReportForCust(TempBlob, ReportUsage, SalesCrMemoHeader, SalesCrMemoHeader."Sell-to Customer No.");

        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF8);
        PdfSalesCrMemo := Base64Codeunit.ToBase64(InStr);

        exit(Response.RespondOK(PdfSalesCrMemo));
    end;

    #region Private Methods
    local procedure GetSalesInvoiceTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"Sales Invoice Header");
        TableIds.Add(Database::"Sales Invoice Line");
    end;

    local procedure GetSalesCrMemoTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"Sales Cr.Memo Header");
        TableIds.Add(Database::"Sales Cr.Memo Line");
    end;
    #endregion Private Methods
}
#endif
