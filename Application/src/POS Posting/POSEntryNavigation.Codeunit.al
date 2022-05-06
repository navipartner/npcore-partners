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
        FilterForCustomer(Contact, POSEntry);

        Clear(POSEntryList);
        if POSEntry.GetFilter("Customer No.") <> '' then
            POSEntry.SetFilter("Contact No.", '%1|%2', '', Contact."No.")
        else
            POSEntry.SetRange("Contact No.", Contact."No.");
        POSEntryList.SetTableView(POSEntry);
        POSEntryList.Run();
    end;

    procedure OpenPOSEntryListFromCustomer(Customer: Record Customer)
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryList: Page "NPR POS Entry List";
    begin
        FilterForContacts(Customer, POSEntry);

        Clear(POSEntryList);
        if POSEntry.GetFilter("Contact No.") <> '' then
            POSEntry.SetFilter("Customer No.", '%1|%2', '', Customer."No.")
        else
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

    local procedure FilterForCustomer(Contact: Record Contact; var POSEntry: Record "NPR POS Entry")
    var
        MarketingSetup: Record "Marketing Setup";
        ContBusRel: Record "Contact Business Relation";
        FilterText: Text;
    begin
        if not MarketingSetup.Get() then
            exit;
        if not HasBusinessRelation("Contact Business Relation Link To Table"::Customer, MarketingSetup."Bus. Rel. Code for Customers", Contact) then
            exit;

        ContBusRel.Reset();
        if (Contact."Company No." = '') or (Contact."Company No." = Contact."No.") then
            ContBusRel.SetRange("Contact No.", Contact."No.")
        else
            ContBusRel.SetFilter("Contact No.", '%1|%2', Contact."No.", Contact."Company No.");
        ContBusRel.SetFilter("No.", '<>''''');
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);

        if ContBusRel.IsEmpty() then
            exit;
        ContBusRel.FindSet();
        repeat
            if not FilterText.Contains(ContBusRel."No.") then
                FilterText += ContBusRel."No." + '|';
        until ContBusRel.Next() = 0;
        FilterText += '''''';
        POSEntry.SetFilter("Customer No.", FilterText);
    end;

    local procedure FilterForContacts(Customer: Record Customer; var POSEntry: Record "NPR POS Entry")
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        Contact: Record Contact;
        FilterText: Text;
    begin
        ContactBusinessRelation.SetCurrentKey("Link to Table", "No.");
        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetRange("No.", Customer."No.");
        if ContactBusinessRelation.IsEmpty() then
            exit;
        ContactBusinessRelation.FindFirst();

        Contact.SetRange("Company No.", ContactBusinessRelation."Contact No.");
        if Contact.IsEmpty() then
            exit;
        Contact.FindSet();
        repeat
            if not FilterText.Contains(Contact."No.") then
                FilterText += Contact."No." + '|';
        until Contact.Next() = 0;
        FilterText += '''''';
        POSEntry.SetFilter("Contact No.", FilterText);
    end;

    local procedure HasBusinessRelation(LinkToTable: Enum "Contact Business Relation Link To Table"; BusRelationCode: Code[10]; Contact: Record Contact): Boolean;
    var
        ContBusRel: Record "Contact Business Relation";
    begin
        FilterBusinessRelations(ContBusRel, LinkToTable, BusRelationCode = '', Contact);
        ContBusRel.SetFilter("Business Relation Code", BusRelationCode);
        exit(not ContBusRel.IsEmpty());
    end;

    local procedure FilterBusinessRelations(var ContBusRel: Record "Contact Business Relation"; LinkToTable: Enum "Contact Business Relation Link To Table"; All: Boolean; Contact: Record Contact)
    begin
        ContBusRel.Reset();
        if (Contact."Company No." = '') or (Contact."Company No." = Contact."No.") then
            ContBusRel.SetRange("Contact No.", Contact."No.")
        else
            ContBusRel.SetFilter("Contact No.", '%1|%2', Contact."No.", Contact."Company No.");
        if not All then
            ContBusRel.SetFilter("No.", '<>''''');
        if LinkToTable <> LinkToTable::" " then
            ContBusRel.SetRange("Link to Table", LinkToTable);
    end;
}
