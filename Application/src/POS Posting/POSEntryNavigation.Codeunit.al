codeunit 6150635 "NPR POS Entry Navigation"
{
    Access = Internal;
    procedure OpenPOSSalesLineListFromItem(Item: Record Item)
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSSalesLineList: Page "NPR POS Entry Sales Line List";
    begin
        Clear(POSSalesLineList);
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        POSSalesLine.SetRange("No.", Item."No.");
        POSSalesLineList.SetTableView(POSSalesLine);
        POSSalesLineList.Run();
    end;

    procedure OpenPOSEntryListFromContact(Contact: Record Contact)
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryList: Page "NPR POS Entry List";
    begin
        Clear(POSEntryList);
        POSEntry.SetRange("Contact No.", Contact."No.");
        POSEntryList.SetTableView(POSEntry);
        POSEntryList.Run();
    end;

    procedure OpenPOSEntryListFromCustomer(Customer: Record Customer)
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryList: Page "NPR POS Entry List";
    begin
        Clear(POSEntryList);
        POSEntry.SetRange("Customer No.", Customer."No.");
        POSEntryList.SetTableView(POSEntry);
        POSEntryList.Run();
    end;

    procedure OpenPOSEntryListFromSalesDocument(SalesHeader: Record "Sales Header")
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryList: Page "NPR POS Entry List";
    begin
        Clear(POSEntryList);
        POSEntry.SetRange("Sales Document Type", SalesHeader."Document Type");
        POSEntry.SetRange("Sales Document No.", SalesHeader."No.");
        if POSEntry.IsEmpty() then
            exit;
        POSEntryList.SetTableView(POSEntry);
        POSEntryList.Run();
    end;
}
