codeunit 6150635 "NPR POS Page Navigation"
{
    trigger OnRun()
    begin
    end;

    local procedure OpenPOSSalesLineListFromItem(Item: Record Item)
    var
        POSSalesLine: Record "NPR POS Sales Line";
        POSSalesLineList: Page "NPR POS Sales Line List";
    begin
        Clear(POSSalesLineList);
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        POSSalesLine.SetRange("No.", Item."No.");
        POSSalesLineList.SetTableView(POSSalesLine);
        POSSalesLineList.Run;
    end;

    local procedure OpenPOSEntryListFromContact(Contact: Record Contact)
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryList: Page "NPR POS Entry List";
    begin
        Clear(POSEntryList);
        POSEntry.SetRange("Contact No.", Contact."No.");
        POSEntryList.SetTableView(POSEntry);
        POSEntryList.Run;
    end;

    local procedure OpenPOSEntryListFromCustomer(Customer: Record Customer)
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryList: Page "NPR POS Entry List";
    begin
        Clear(POSEntryList);
        POSEntry.SetRange("Customer No.", Customer."No.");
        POSEntryList.SetTableView(POSEntry);
        POSEntryList.Run;
    end;

    local procedure OpenPOSEntryListFromSalesDocument(SalesHeader: Record "Sales Header")
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryList: Page "NPR POS Entry List";
    begin
        Clear(POSEntryList);
        POSEntry.SetRange("Sales Document Type", SalesHeader."Document Type");
        POSEntry.SetRange("Sales Document No.", SalesHeader."No.");
        if POSEntry.IsEmpty then
            exit;
        POSEntryList.SetTableView(POSEntry);
        POSEntryList.Run;
    end;

    #region Subscribers
    [EventSubscriber(ObjectType::Page, 30, 'OnAfterActionEvent', 'NPR POSSalesEntries', true, true)]
    local procedure Page30OnAfterActionPOSSalesLines(var Rec: Record Item)
    begin
        OpenPOSSalesLineListFromItem(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 31, 'OnAfterActionEvent', 'NPR POS Sales Entries', true, true)]
    local procedure Page31OnAfterActionPOSSalesLines(var Rec: Record Item)
    begin
        OpenPOSSalesLineListFromItem(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 21, 'OnAfterActionEvent', 'NPR POS Entries', true, true)]
    local procedure Page21OnAfterActionPOSEntries(var Rec: Record Customer)
    begin
        OpenPOSEntryListFromCustomer(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 22, 'OnAfterActionEvent', 'NPR POS Entries', true, true)]
    local procedure Page22OnAfterActionPOSEntries(var Rec: Record Customer)
    begin
        OpenPOSEntryListFromCustomer(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 5050, 'OnAfterActionEvent', 'NPR POS Entries', true, true)]
    local procedure Page5050OnAfterActionPOSEntries(var Rec: Record Contact)
    begin
        OpenPOSEntryListFromContact(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 5052, 'OnAfterActionEvent', 'NPR POS Entries', true, true)]
    local procedure Page5052OnAfterActionPOSEntries(var Rec: Record Contact)
    begin
        OpenPOSEntryListFromContact(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'NPR POS Entry', true, true)]
    local procedure Page42OnAfterActionPOSEntry(var Rec: Record "Sales Header")
    begin
        OpenPOSEntryListFromSalesDocument(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 43, 'OnAfterActionEvent', 'NPR POS Entry', true, true)]
    local procedure Page43OnAfterActionPOSEntry(var Rec: Record "Sales Header")
    begin
        OpenPOSEntryListFromSalesDocument(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 44, 'OnAfterActionEvent', 'NPR POS Entry', true, true)]
    local procedure Page44OnAfterActionPOSEntry(var Rec: Record "Sales Header")
    begin
        OpenPOSEntryListFromSalesDocument(Rec);
    end;
    #endregion
}