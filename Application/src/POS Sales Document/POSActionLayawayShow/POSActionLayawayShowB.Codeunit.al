codeunit 6060007 "NPR POS Action: LayawayShow-B"
{
    Access = Internal;
    procedure RunDocument(SelectCustomer: Boolean; OrderPaymentTerms: Text; Sale: Codeunit "NPR POS Sale")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
    begin
        if not CheckCustomer(Sale, SelectCustomer) then
            exit;

        Sale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then
            SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        if OrderPaymentTerms <> '' then
            SalesHeader.SetRange("Payment Terms Code", OrderPaymentTerms);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);

        if not PromptSalesOrderList(SalesHeader) then
            exit;

        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        PAGE.RunModal(PAGE::"NPR POS Prepaym. Invoices", SalesInvoiceHeader);
    end;

    local procedure CheckCustomer(POSSale: Codeunit "NPR POS Sale"; SelectCustomer: Boolean): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
    begin
        POSSale.GetCurrentSale(SalePOS);
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

    local procedure PromptSalesOrderList(var SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(PAGE.RunModal(PAGE::"Sales Order List", SalesHeader) = ACTION::LookupOK);
    end;
}