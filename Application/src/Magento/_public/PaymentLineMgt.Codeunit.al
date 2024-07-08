codeunit 6150650 "NPR Payment Line Mgt."
{
    var
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";

    [Obsolete('Use "CaptureSalesInvoice" procedure instead.', 'NPR23.0')]
    procedure MagentoPmtMgt_CaptureSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        MagentoPmtMgt.CaptureSalesInvoice(SalesInvoiceHeader);
    end;

    /// <summary>
    /// Capture payment lines linked to the given Sales Invoice Header
    /// </summary>
    /// <param name="SalesInvHeader">Sales Invoice Header with payment lines</param>
    procedure CaptureSalesInvoice(SalesInvHeader: Record "Sales Invoice Header")
    begin
        MagentoPmtMgt.CaptureSalesInvoice(SalesInvHeader);
    end;

    /// <summary>
    /// Capture payment lines linked to the given Sales Header.
    /// Only Sales Headers that are not of Credit Type can be captured.
    /// </summary>
    /// <param name="SalesHeader">Sales Header with payment lines</param>
    procedure CaptureSalesHeader(SalesHeader: Record "Sales Header")
    begin
        MagentoPmtMgt.CaptureSalesHeader(SalesHeader);
    end;

    /// <summary>
    /// Refund payment lines linked to the given Sales Cr.Memo Header
    /// </summary>
    /// <param name="SalesCrMemoHeader">Sales Cr.Memo Header with payment lines</param>
    procedure RefundSalesCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        MagentoPmtMgt.RefundSalesCreditMemo(SalesCrMemoHeader);
    end;

    /// <summary>
    /// Refund payment lines linked to the given Sales Header.
    /// Only Sales Headers that are of Credit Type can be refunded.
    /// </summary>
    /// <param name="SalesHeader">Sales Header with payment lines</param>
    procedure RefundSalesHeader(SalesHeader: Record "Sales Header")
    begin
        MagentoPmtMgt.RefundSalesHeader(SalesHeader);
    end;
}
