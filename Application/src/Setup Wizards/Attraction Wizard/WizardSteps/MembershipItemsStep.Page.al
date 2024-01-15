page 6151382 "NPR Membership Items Step"
{
    Extensible = False;
    Caption = 'Membership Items';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = Item;
    SourceTableTemporary = true;
    UsageCategory = None;

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

    trigger OnOpenPage()
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Item: Record Item;
    begin
        Rec.DeleteAll();
        if MembershipSalesSetup.FindSet() then
            repeat
                if Item.Get(MembershipSalesSetup."No.") then
                    Rec := Item;
                if Rec.Insert() then;
            until MembershipSalesSetup.Next() = 0;

        if MembershipAlterationSetup.FindSet() then
            repeat
                if Item.Get(MembershipAlterationSetup."Sales Item No.") then
                    Rec := Item;
                if Rec.Insert() then;
            until MembershipAlterationSetup.Next() = 0;
    end;

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

    internal procedure MembershipItemsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateMembershipItems()
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

    internal procedure CopyTempMembershipItems(var TempItems: Record "Item")
    begin
        TempItems.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempItems := Rec;
                if not TempItems.Insert() then
                    TempItems.Modify();
            until Rec.Next() = 0;
    end;
}
