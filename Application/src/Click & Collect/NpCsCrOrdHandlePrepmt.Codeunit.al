codeunit 6151213 "NPR NpCs Cr.Ord: Handle Prepmt"
{
    Access = Internal;
    trigger OnRun()
    begin
        HandlePrepayment();
    end;

    var
        PreviousSalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        PrepaymentPct: Decimal;
        PrintPrepaymentInvoice, PrepaymentIsAmount : Boolean;

    procedure SetParameters(POSSessionIn: Codeunit "NPR POS Session"; RetailSalesDocMgtIn: Codeunit "NPR Sales Doc. Exp. Mgt."; PrepaymentPctIn: Decimal; PrintPrepaymentInvoiceIn: Boolean; PreviousSalePOSIn: Record "NPR POS Sale"; PrepaymentIsAmountIn: Boolean)
    begin
        POSSession := POSSessionIn;
        RetailSalesDocMgt := RetailSalesDocMgtIn;
        PrepaymentPct := PrepaymentPctIn;
        PrintPrepaymentInvoice := PrintPrepaymentInvoiceIn;
        PreviousSalePOS := PreviousSalePOSIn;
        PrepaymentIsAmount := PrepaymentIsAmountIn;
    end;

    local procedure HandlePrepayment()
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);
        if not SalesHeader.Find() then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer No.", PreviousSalePOS."Customer No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        POSSalesDocumentPost := POSSalesDocumentPost::Synchronous;

        RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentPct, PrintPrepaymentInvoice, false, false, POSSalesDocumentPost, PrepaymentIsAmount);

        POSSession.RequestRefreshData();
    end;
}
