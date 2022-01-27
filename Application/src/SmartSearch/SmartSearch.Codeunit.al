codeunit 6014623 "NPR Smart Search"
{
    Access = Internal;
    internal procedure SearchCustomer(SearchTerm: Text[100]; var Customer: Record Customer)
    begin
        CustomerSearchWorker(SearchTerm, Customer);
    end;

    internal procedure SearchItemAndItemReference(SearchTerm: Text[100]; var Item: Record Item)
    begin
        ItemSearchWorker(SearchTerm, Item);
        ItemReferenceSearchWorker(SearchTerm, Item);
    end;

    local procedure CustomerSearchWorker(SearchTerm: Text[100]; var Customer: Record Customer)
    begin
        Customer.FilterGroup := -1;
        ApplyCustomerFilter(SearchTerm, Customer);
        Customer.SetLoadFields("No.");

        if Customer.GetFilters() <> '' then begin
            if Customer.FindSet() then
                repeat
                    Customer.Mark(true);
                until Customer.Next() = 0;
        end;
        Customer.FilterGroup := 0;
    end;

    local procedure ItemSearchWorker(SearchTerm: Text[100]; var Item: Record Item)
    begin
        Item.FilterGroup := -1;
        ApplyItemFilter(SearchTerm, Item);
        Item.SetLoadFields("No.");

        if Item.GetFilters() <> '' then begin
            if Item.FindSet() then
                repeat
                    Item.Mark(true);
                until Item.Next() = 0;
        end;
        Item.FilterGroup := 0;
    end;

    local procedure ItemReferenceSearchWorker(SearchTerm: Text[100]; var Item: Record Item)
    var
        ItemReference: Record "Item Reference";
    begin
        if StrLen(SearchTerm) > MaxStrLen(ItemReference."Reference No.") then
            exit;

        //to avoid performance issues '*' character is not allowed in front of the search term when searching the Item References
        if StrPos(SearchTerm, '*') = 1 then
            exit;

        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetFilter("Reference No.", '%1', UpperCase(SearchTerm));
        ItemReference.SetLoadFields("Item No.");
        if ItemReference.FindSet() then
            repeat
                if Item.Get(ItemReference."Item No.") then
                    Item.Mark(true);
            until ItemReference.Next() = 0;
    end;

    local procedure ApplyCustomerFilter(SearchTerm: Text; var Customer: Record Customer)
    begin
        if (StrLen(SearchTerm) <= MaxStrLen(Customer."No.")) then
            Customer.SetFilter("No.", '%1', UpperCase(SearchTerm));

        if (StrLen(SearchTerm) <= MaxStrLen(Customer."Phone No.")) then
            Customer.SetFilter("Phone No.", '%1', SearchTerm);

        Customer.SetFilter("Name", '%1', '@' + ConvertSpaceToWildcard(SearchTerm));
        Customer.SetFilter("Contact", '%1', '@' + ConvertSpaceToWildcard(SearchTerm));

        OnAfterApplyCustomerFilter(SearchTerm, Customer);
    end;

    local procedure ApplyItemFilter(SearchTerm: Text; var Item: Record Item)
    begin
        if CheckLength(SearchTerm, MaxStrLen(Item."No.")) then
            Item.SetFilter("No.", UpperCase(SearchTerm));

        if (StrLen(SearchTerm) <= MaxStrLen(Item."Description 2")) then
            Item.SetFilter("Description 2", '%1', '@' + ConvertSpaceToWildcard(SearchTerm));

        if (StrLen(SearchTerm) + 1 <= MaxStrLen(Item."Search Description")) then
            Item.SetFilter("Search Description", '%1', ConvertSpaceToWildcard(UpperCase(SearchTerm)));

        Item.SetFilter(Description, '%1', '@' + ConvertSpaceToWildcard(SearchTerm));

        OnAfterApplyItemFilter(SearchTerm, Item);
    end;

    local procedure CheckLength(SearchTerm: Text; MaxLength: Integer): Boolean
    var
        SearchList: List of [Text];
        SearchPart: Text;
    begin
        if StrLen(SearchTerm) <= MaxLength then
            exit(true);

        SearchList := SearchTerm.Split('|', '..');
        foreach SearchPart in SearchList do
            if StrLen(SearchPart) > MaxLength then
                exit(false);

        exit(true);
    end;

    local procedure ConvertSpaceToWildcard(SearchTerm: Text): Text
    var
    begin
        exit(ConvertStr(SearchTerm, ' ', '*') + '*');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyItemFilter(SearchTerm: Text; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyCustomerFilter(SearchTerm: Text; var Customer: Record Customer)
    begin
    end;
}
