codeunit 6150635 "NPR POS Entry Navigation"
{
    local procedure OpenPOSSalesLineListFromItem(Item: Record Item)
    var
        POSSalesLine: Record "NPR POS Sales Line";
        POSSalesLineList: Page "NPR POS Sales Line List";
    begin
        Clear(POSSalesLineList);
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        POSSalesLine.SetRange("No.", Item."No.");
        POSSalesLineList.SetTableView(POSSalesLine);
        POSSalesLineList.Run();
    end;

    local procedure OpenPOSEntryListFromContact(Contact: Record Contact)
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryList: Page "NPR POS Entry List";
    begin
        Clear(POSEntryList);
        POSEntry.SetRange("Contact No.", Contact."No.");
        POSEntryList.SetTableView(POSEntry);
        POSEntryList.Run();
    end;

    local procedure OpenPOSEntryListFromCustomer(Customer: Record Customer)
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryList: Page "NPR POS Entry List";
    begin
        Clear(POSEntryList);
        POSEntry.SetRange("Customer No.", Customer."No.");
        POSEntryList.SetTableView(POSEntry);
        POSEntryList.Run();
    end;

    local procedure OpenPOSEntryListFromSalesDocument(SalesHeader: Record "Sales Header")
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

    [EventSubscriber(ObjectType::Page, Page::"Item Card", 'OnAfterActionEvent', 'NPR POSSalesEntries', true, true)]
    local procedure ItemCardOnAfterActionPOSSalesLines(var Rec: Record Item)
    begin
        OpenPOSSalesLineListFromItem(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item List", 'OnAfterActionEvent', 'NPR POS Sales Entries', true, true)]
    local procedure ItemListOnAfterActionPOSSalesLines(var Rec: Record Item)
    begin
        OpenPOSSalesLineListFromItem(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Card", 'OnAfterActionEvent', 'NPR POS Entries', true, true)]
    local procedure CustomerCardOnAfterActionPOSEntries(var Rec: Record Customer)
    begin
        OpenPOSEntryListFromCustomer(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer List", 'OnAfterActionEvent', 'NPR POS Entries', true, true)]
    local procedure CustomerListOnAfterActionPOSEntries(var Rec: Record Customer)
    begin
        OpenPOSEntryListFromCustomer(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Contact Card", 'OnAfterActionEvent', 'NPR POS Entries', true, true)]
    local procedure ContactCardOnAfterActionPOSEntries(var Rec: Record Contact)
    begin
        OpenPOSEntryListFromContact(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Contact List", 'OnAfterActionEvent', 'NPR POS Entries', true, true)]
    local procedure ContactListOnAfterActionPOSEntries(var Rec: Record Contact)
    begin
        OpenPOSEntryListFromContact(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnAfterActionEvent', 'NPR POS Entry', true, true)]
    local procedure SalesOrderOnAfterActionPOSEntry(var Rec: Record "Sales Header")
    begin
        OpenPOSEntryListFromSalesDocument(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnAfterActionEvent', 'NPR POS Entry', true, true)]
    local procedure SalesInvoiceOnAfterActionPOSEntry(var Rec: Record "Sales Header")
    begin
        OpenPOSEntryListFromSalesDocument(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Credit Memo", 'OnAfterActionEvent', 'NPR POS Entry', true, true)]
    local procedure SalesCrMemoOnAfterActionPOSEntry(var Rec: Record "Sales Header")
    begin
        OpenPOSEntryListFromSalesDocument(Rec);
    end;
}