codeunit 6150650 "NPR Payment Line Mgt."
{
    procedure MagentoPmtMgt_CaptureSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        MagentoPmtMgt.CaptureSalesInvoice(SalesInvoiceHeader);
    end;
}
