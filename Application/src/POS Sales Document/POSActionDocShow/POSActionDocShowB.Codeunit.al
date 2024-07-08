codeunit 6059963 "NPR POS Action: Doc. Show-B"
{
    Access = Internal;
    procedure ShowSaleDocument(Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; SelectCustomer: Boolean; SelectType: Integer; SalesOrderViewString: Text; GroupCodeFilter: Text)
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        PageMgt: Codeunit "Page Management";
    begin
        Sale.GetCurrentSale(SalePOS);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        if not CheckCustomer(SalePOS, SelectCustomer) then
            exit;

        if SelectType = 1 then begin
            if SaleLinePOS."Sales Document No." = '' then
                exit;
            SalesHeader.Get(SaleLinePOS."Sales Document Type", SaleLinePOS."Sales Document No.");
        end else begin
            if SalesOrderViewString <> '' then
                SalesHeader.SetView(SalesOrderViewString);
            if SalePOS."Customer No." <> '' then
                SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
            SalesHeader.SetFilter("NPR Group Code", GroupCodeFilter);
            if not LookupSalesDoc(SalesHeader) then
                exit;
        end;

        Page.RunModal(PageMgt.GetPageID(SalesHeader), SalesHeader);
    end;

    procedure ShowSaleDocument(Sale: Codeunit "NPR POS Sale";
                               SaleLine: Codeunit "NPR POS Sale Line";
                               SelectCustomer: Boolean;
                               SelectType: Integer;
                               SalesOrderViewString: Text)
    begin
        ShowSaleDocument(Sale,
                         SaleLine,
                         SelectCustomer,
                         SelectType,
                         SalesOrderViewString,
                         '');
    end;




    local procedure LookupSalesDoc(var SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(Page.RunModal(0, SalesHeader) = Action::LookupOK);
    end;

    procedure CheckCustomer(var SalePOS: Record "NPR POS Sale"; SelectCustomer: Boolean): Boolean
    var
        Customer: Record Customer;
    begin
        if SalePOS."Customer No." <> '' then
            exit(true);

        if not SelectCustomer then
            exit(true);

        if Page.RunModal(0, Customer) <> Action::LookupOK then
            exit(false);

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        Commit();
        exit(true);
    end;
}