codeunit 6059824 "NPR POS Action: Cust. Select-B"
{
    Access = Internal;

    procedure AttachCustomer(var SalePOS: Record "NPR POS Sale"; CustomerTableView: Text; CustomerLookupPage: Integer; SpecificCustomerNo: Text; CustomerOverdueCheck: Boolean) Success: Boolean;
    var
        Customer: Record Customer;
        POSActionPublishers: Codeunit "NPR POS Action Publishers";
        CustomerCreditWarningLbl: Label 'The customer has overdue balance of %1. Do you want to continue?';
        BalanceAmt: Decimal;
    begin
        if SpecificCustomerNo = '' then begin
            if CustomerTableView <> '' then
                Customer.SetView(CustomerTableView);
            if Page.RunModal(CustomerLookupPage, Customer) <> ACTION::LookupOK then
                exit;
        end else begin
            Customer."No." := CopyStr(SpecificCustomerNo, 1, MaxStrLen(Customer."No."));
            Customer.Find();
        end;
        if CustomerOverdueCheck then
            if CheckCustomerBalanceOverDue(Customer."No.", BalanceAmt) then
                if not Confirm(StrSubstNo(customerCreditWarningLbl, BalanceAmt)) then
                    exit;

        POSActionPublishers.OnBeforeAddCustomertoSales(SalePOS, Customer);

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        Success := true;

        OnAfterAttachCustomer(SalePOS, Success);
    end;

    procedure AttachCustomerRequired(SalePOS: Record "NPR POS Sale") Success: Boolean
    var
        Customer: Record Customer;
        POSActionPublishers: Codeunit "NPR POS Action Publishers";
        PrevRec: Text;
        CustomerHasBeenBlockedMsg: Label 'The customer has been blocked for further business and cannot be selected.';
    begin
        repeat
            while (PAGE.RunModal(0, Customer) <> ACTION::LookupOK) do
                Clear(Customer);

            if Customer.Blocked = Customer.Blocked::All then
                Message(CustomerHasBeenBlockedMsg);

        until not (Customer.Blocked = Customer.Blocked::All);

        PrevRec := Format(SalePOS);

        POSActionPublishers.OnBeforeAddCustomertoSales(SalePOS, Customer);

        SalePOS.Validate("Customer No.", Customer."No.");

        if PrevRec <> Format(SalePOS) then
            SalePOS.Modify(true);

        Success := true;
        OnAfterAttachCustomer(SalePOS, Success);
    end;


    procedure RemoveCustomer(var SalePOS: Record "NPR POS Sale") Success: Boolean;
    begin
        SalePOS.Validate("Customer No.", '');
        SalePOS.Modify(true);

        Success := true;
    end;

    local procedure CheckCustomerBalanceOverDue(CustNo: code[20]; var BalanceAmount: Decimal): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.get(CustNo);
        Customer.SetFilter("Date Filter", '..%1', WorkDate());
        Customer.CalcFields("Balance Due (LCY)");
        BalanceAmount := Customer."Balance Due (LCY)";
        exit(BalanceAmount > 0);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAttachCustomer(SaleHeader: Record "NPR POS Sale"; Success: Boolean)
    begin
    end;


}