page 6151378 "NPR Create TicketItems Step"
{
    Extensible = False;
    Caption = 'Ticket Items';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = Item;
    SourceTableTemporary = true;
    UsageCategory = None;
    SourceTableView = where("NPR Ticket Type" = filter(<> ''));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                }
                field("Ticket Type"; Rec."NPR Ticket Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the ticket type that will be used with the item.';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the VAT product posting group. Links business transactions made for the item, resource, or G/L account with the general ledger, to account for VAT amounts resulting from trade with that record.';
                }
            }
        }
    }

    internal procedure CopyLiveData()
    var
        Items: Record "Item";
    begin
        Rec.DeleteAll();

        if Items.FindSet() then
            repeat
                Rec := Items;
                if not Rec.Insert() then
                    Rec.Modify();
            until Items.Next() = 0;
    end;

    internal procedure TicketItemsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateTicketItems()
    var
        Items: Record "Item";
    begin
        if Rec.FindSet() then
            repeat
                Items := Rec;
                if not Items.Insert() then
                    Items.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempTicketItems(var TempTicketItems: Record "Item")
    begin
        TempTicketItems.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempTicketItems := Rec;
                if not TempTicketItems.Insert() then
                    TempTicketItems.Modify();
            until Rec.Next() = 0;
    end;
}
