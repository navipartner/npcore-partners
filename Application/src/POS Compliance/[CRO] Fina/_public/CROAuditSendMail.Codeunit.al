codeunit 6248659 "NPR CRO Audit Send Mail"
{
    Access = Public;

    procedure SendFiscalBillViaEmail(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        CROFiscalEmailMgt: Codeunit "NPR CRO Fiscal E-Mail Mgt.";
    begin
        exit(CROFiscalEmailMgt.TrySendFiscalBillForInvoice(SalesInvoiceHeader));
    end;
}