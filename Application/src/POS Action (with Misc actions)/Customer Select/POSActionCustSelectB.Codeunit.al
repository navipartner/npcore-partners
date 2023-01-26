codeunit 6059824 "NPR POS Action: Cust. Select-B"
{
    Access = Internal;

    procedure AttachCustomer(var SalePOS: Record "NPR POS Sale"; CustomerTableView: Text; CustomerLookupPage: Integer; SpecificCustomerNo: Text; CustomerOverdueCheck: Boolean)
    var
        Customer: Record Customer;
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

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
    end;

    procedure RemoveCustomer(var SalePOS: Record "NPR POS Sale")
    begin
        SalePOS.Validate("Customer No.", '');
        SalePOS.Modify(true);
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
}