codeunit 6059918 "NPR POS Action: Doc. Prepay B"
{
    Access = Internal;
    internal procedure CheckCustomer(var SalePOS: Record "NPR POS Sale"; POSSale: Codeunit "NPR POS Sale"; SelectCustomer: Boolean): Boolean
    var
        Customer: Record Customer;
    begin
        if SalePOS."Customer No." <> '' then
            exit(true);

        if not SelectCustomer then
            exit(true);

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
            exit(false);

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit();
        exit(true);
    end;

    internal procedure SelectDocument(SalePOS: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header"): Boolean
    var
        GLSetup: Record "General Ledger Setup";
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        FCYNotSupportedErr: Label 'Prepayment handling for foreign currency sales orders is not supported in POS. Instead, please create and post the required prepayment invoice/credit memo directly from the sales order page. Then, use POS to register the matching payment or refund transaction.';
    begin
        GLSetup.Get();
        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetFilter("Currency Code", '%1|%2', '', GLSetup."LCY Code");
        SetFilterSalesHeader(SalePOS, SalesHeader);
        if not RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GetView(false), SalesHeader) then
            exit(false);
        if not (SalesHeader."Currency Code" in ['', GLSetup."LCY Code"]) then
            Error(FCYNotSupportedErr);
        exit(true);
    end;

    internal procedure ConfirmImportInvDiscAmt(SalesHeader: Record "Sales Header"; ConfirmInvDiscAmt: Boolean): Boolean
    var
        SalesLine: Record "Sales Line";
        SalesDocImpMgt: codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        if ConfirmInvDiscAmt then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetFilter("Inv. Discount Amount", '>%1', 0);
            SalesLine.CalcSums("Inv. Discount Amount");
            if SalesLine."Inv. Discount Amount" > 0 then begin
                if not Confirm(SalesDocImpMgt.GetImportInvDiscAmtQst()) then
                    exit;
            end;
        end;
        exit(true);
    end;

    local procedure SetFilterSalesHeader(SalePOS: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header")
    var
        POSSaleLine: Record "NPR POS Sale Line";
        FilterSalesNo: text;
    begin
        POSSaleLine.SetRange("Register No.", SalePOS."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        POSSaleLine.SetFilter("Sales Document No.", '<>%1', '');
        if POSSaleLine.FindSet() then
            repeat
                if FilterSalesNo = '' then
                    FilterSalesNo := '<>' + POSSaleLine."Sales Document No."
                else
                    FilterSalesNo += '&<>' + POSSaleLine."Sales Document No.";
            until POSSaleLine.Next() = 0;

        SalesHeader.SetFilter("No.", FilterSalesNo);
    end;

    internal procedure CreatePrepaymentLine(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Print: Boolean; PrepaymentValue: Decimal; ValueIsAmount: Boolean; Send: Boolean; Pdf2Nav: Boolean; SalePostingIn: Enum "NPR POS Sales Document Post")
    var
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        POSAsyncPosting: Codeunit "NPR POS Async. Posting Mgt.";
    begin
        if SalePostingIn = SalePostingIn::Asynchronous then
            POSAsyncPosting.CheckPostingStatusFromPOS(SalesHeader);
        RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentValue, Print, Send, Pdf2Nav, SalePostingIn, ValueIsAmount);
    end;

    internal procedure CreatePrepaymentRefundLine(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Print: Boolean; DeleteDocumentAfterRefund: Boolean; Send: Boolean; Pdf2Nav: Boolean; SalePostingIn: Enum "NPR POS Sales Document Post")
    var
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
        NO_PREPAYMENT: Label '%1 %2 has no refundable prepayments!';
        POSAsyncPosting: Codeunit "NPR POS Async. Posting Mgt.";
    begin
        if SalePostingIn = SalePostingIn::Asynchronous then
            POSAsyncPosting.CheckPostingStatusFromPOS(SalesHeader);
        if (POSPrepaymentMgt.GetPrepaymentAmountToDeductInclVAT(SalesHeader) <= 0) THEN
            Error(NO_PREPAYMENT, SalesHeader."Document Type", SalesHeader."No.");
        RetailSalesDocMgt.CreatePrepaymentRefundLine(POSSession, SalesHeader, Print, Send, Pdf2Nav, true, DeleteDocumentAfterRefund, SalePostingIn);
    end;
}
