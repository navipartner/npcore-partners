codeunit 6150635 "POS Page Navigation"
{
    // NPR5.38/BR  /20171116  CASE 295255 Object Added
    // NPR5.38/NPKNAV/20180126  CASE 295255 Transport NPR5.38 - 26 January 2018
    // NPR5.51/THRO/20190717  CASE 361514 EventPublisherElement changed in Page30OnAfterActionPOSSalesLines. Action renamed on Page 30
    //                                    EventPublisherElement changed in Page31OnAfterActionPOSSalesLines. Action renamed on Page 31
    //                                    EventPublisherElement changed in Page6014425OnAfterActionPOSSalesLines. Action renamed on Page 6014425
    //                                    EventPublisherElement changed in Page6014511OnAfterActionPOSSalesLines. Action renamed on Page 6014511


    trigger OnRun()
    begin
    end;

    local procedure OpenPOSSalesLineListFromItem(Item: Record Item)
    var
        POSSalesLine: Record "POS Sales Line";
        POSSalesLineList: Page "POS Sales Line List";
    begin
        Clear(POSSalesLineList);
        POSSalesLine.SetRange(Type,POSSalesLine.Type::Item);
        POSSalesLine.SetRange("No.",Item."No.");
        POSSalesLineList.SetTableView(POSSalesLine);
        POSSalesLineList.Run;
    end;

    local procedure OpenPOSEntryListFromContact(Contact: Record Contact)
    var
        POSEntry: Record "POS Entry";
        POSEntryList: Page "POS Entry List";
    begin
        Clear(POSEntryList);
        POSEntry.SetRange("Contact No.",Contact."No.");
        POSEntryList.SetTableView(POSEntry);
        POSEntryList.Run;
    end;

    local procedure OpenPOSEntryListFromCustomer(Customer: Record Customer)
    var
        POSEntry: Record "POS Entry";
        POSEntryList: Page "POS Entry List";
    begin
        Clear(POSEntryList);
        POSEntry.SetRange("Customer No.",Customer."No.");
        POSEntryList.SetTableView(POSEntry);
        POSEntryList.Run;
    end;

    local procedure OpenPOSEntryListFromSalesDocument(SalesHeader: Record "Sales Header")
    var
        POSEntry: Record "POS Entry";
        POSEntryList: Page "POS Entry List";
    begin
        Clear(POSEntryList);
        POSEntry.SetRange("Sales Document Type",SalesHeader."Document Type");
        POSEntry.SetRange("Sales Document No.",SalesHeader."No.");
        if POSEntry.IsEmpty then
          exit;
        POSEntryList.SetTableView(POSEntry);
        POSEntryList.Run;
    end;

    local procedure "---Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 30, 'OnAfterActionEvent', 'POSSalesEntries', true, true)]
    local procedure Page30OnAfterActionPOSSalesLines(var Rec: Record Item)
    begin
        OpenPOSSalesLineListFromItem(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 31, 'OnAfterActionEvent', 'POSSalesEntries', true, true)]
    local procedure Page31OnAfterActionPOSSalesLines(var Rec: Record Item)
    begin
        OpenPOSSalesLineListFromItem(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 6014425, 'OnAfterActionEvent', 'POSSalesEntries', true, true)]
    local procedure Page6014425OnAfterActionPOSSalesLines(var Rec: Record Item)
    begin
        OpenPOSSalesLineListFromItem(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 6014511, 'OnAfterActionEvent', 'POSSalesEntries', true, true)]
    local procedure Page6014511OnAfterActionPOSSalesLines(var Rec: Record Item)
    begin
        OpenPOSSalesLineListFromItem(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 21, 'OnAfterActionEvent', 'POS Entries', true, true)]
    local procedure Page21OnAfterActionPOSEntries(var Rec: Record Customer)
    begin
        OpenPOSEntryListFromCustomer(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 22, 'OnAfterActionEvent', 'POS Entries', true, true)]
    local procedure Page22OnAfterActionPOSEntries(var Rec: Record Customer)
    begin
        OpenPOSEntryListFromCustomer(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 5050, 'OnAfterActionEvent', 'POS Entries', true, true)]
    local procedure Page5050OnAfterActionPOSEntries(var Rec: Record Contact)
    begin
        OpenPOSEntryListFromContact(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 5052, 'OnAfterActionEvent', 'POS Entries', true, true)]
    local procedure Page5052OnAfterActionPOSEntries(var Rec: Record Contact)
    begin
        OpenPOSEntryListFromContact(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'POS Entry', true, true)]
    local procedure Page42OnAfterActionPOSEntry(var Rec: Record "Sales Header")
    begin
        OpenPOSEntryListFromSalesDocument(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 43, 'OnAfterActionEvent', 'POS Entry', true, true)]
    local procedure Page43OnAfterActionPOSEntry(var Rec: Record "Sales Header")
    begin
        OpenPOSEntryListFromSalesDocument(Rec);
    end;

    [EventSubscriber(ObjectType::Page, 44, 'OnAfterActionEvent', 'POS Entry', true, true)]
    local procedure Page44OnAfterActionPOSEntry(var Rec: Record "Sales Header")
    begin
        OpenPOSEntryListFromSalesDocument(Rec);
    end;
}

