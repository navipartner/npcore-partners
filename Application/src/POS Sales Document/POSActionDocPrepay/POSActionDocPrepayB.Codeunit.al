codeunit 6059918 "NPR POS Action: Doc. Prepay B"
{
    Access = Internal;
    internal procedure CheckCustomer(var SalePOS: Record "NPR POS Sale"; POSSale: Codeunit "NPR POS Sale"; SelectCustomer: Boolean): Boolean
    var
        Customer: Record Customer;
    begin
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

    internal procedure SelectDocument(SalePOS: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header"): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        exit(RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GetView(false), SalesHeader));
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

    internal procedure CreatePrepaymentLine(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Print: Boolean; PrepaymentValue: Decimal; ValueIsAmount: Boolean; Send: Boolean; Pdf2Nav: Boolean)
    var
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
    begin
        RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentValue, Print, Send, Pdf2Nav, true, ValueIsAmount);
    end;
}
