codeunit 6151341 "NPR POS Action: Cust.Info-I B"
{
    Access = Internal;
    procedure GetCustomerNo(var Sale: Codeunit "NPR POS Sale"; var CustomerNo: Code[20])
    var
        POSSale: Record "NPR POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        CustomerNo := POSSale."Customer No."
    end;

    procedure ShowCLE(CustomerNo: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if CustomerNo <> '' then begin
            CustLedgerEntry.FilterGroup(2);
            CustLedgerEntry.SetRange("Customer No.", CustomerNo);
            CustLedgerEntry.FilterGroup(0);
        end;
        PAGE.RUN(PAGE::"Customer Ledger Entries", CustLedgerEntry);
    end;

    procedure ShowILE(CustomerNo: Code[20]);
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if CustomerNo <> '' then begin
            ItemLedgerEntry.FilterGroup(2);
            ItemLedgerEntry.SetRange("Source Type", ItemLedgerEntry."Source Type"::Customer);
            ItemLedgerEntry.SetRange("Source No.", CustomerNo);
            ItemLedgerEntry.FilterGroup(0);
        end;
        PAGE.RUN(PAGE::"Item Ledger Entries", ItemLedgerEntry);
    end;

    procedure ShowCustomerCard(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        CustomerNotSelectedLbl: Label 'Customer is not selected!';
    begin
        if Customer.Get(CustomerNo) then
            PAGE.RUN(PAGE::"Customer Card", Customer)
        else
            Message(CustomerNotSelectedLbl);
    end;
}