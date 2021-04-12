codeunit 6151213 "NPR NpCs Cr.Ord: Handle Prepmt"
{
    trigger OnRun()
    begin
        HandlePrepayment();
    end;

    var
        PreviousSalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        PrepaymentPct: Decimal;
        PrintPrepaymentInvoice: Boolean;

    procedure SetParameters(POSSessionIn: Codeunit "NPR POS Session"; RetailSalesDocMgtIn: Codeunit "NPR Sales Doc. Exp. Mgt."; PrepaymentPctIn: Decimal; PrintPrepaymentInvoiceIn: Boolean; PreviousSalePOSIn: Record "NPR POS Sale")
    begin
        POSSession := POSSessionIn;
        RetailSalesDocMgt := RetailSalesDocMgtIn;
        PrepaymentPct := PrepaymentPctIn;
        PrintPrepaymentInvoice := PrintPrepaymentInvoiceIn;
        PreviousSalePOS := PreviousSalePOSIn;
    end;

    local procedure HandlePrepayment()
    var
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);
        if not SalesHeader.Find() then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Customer Type", PreviousSalePOS."Customer Type");
        SalePOS.Validate("Customer No.", PreviousSalePOS."Customer No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();

        RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentPct, PrintPrepaymentInvoice, false, false, true, false);

        POSSession.RequestRefreshData();
    end;
}