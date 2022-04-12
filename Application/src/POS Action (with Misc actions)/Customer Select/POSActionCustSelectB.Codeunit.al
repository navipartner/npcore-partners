codeunit 6059824 "NPR POS Action: Cust. Select-B"
{
    Access = Internal;

    procedure AttachCustomer(var SalePOS: Record "NPR POS Sale"; CustomerTableView: Text; CustomerLookupPage: Integer; SpecificCustomerNo: Text)
    var
        Customer: Record Customer;
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

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
    end;

    procedure RemoveCustomer(var SalePOS: Record "NPR POS Sale")
    begin
        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", '');
        SalePOS.Modify(true);
    end;
}