pageextension 6014458 "NPR Item Variants" extends "Item Variants"
{
    layout
    {
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22
        addafter("Description 2")
        {
            field("NPR Blocked"; Rec."NPR Blocked")
            {
                ToolTip = 'Specifies if the Item Variant is blocked or not';
                ApplicationArea = NPRRetail;
            }
        }
#endif
#if not BC17
        addlast(Control1)
        {
            field("NPR Variety 1"; Rec."NPR Variety 1")
            {
                ToolTip = 'Specifies the 1st variety to be used for the item variant.';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            field("NPR Variety 1 Table"; Rec."NPR Variety 1 Table")
            {
                ToolTip = 'Specifies the 1st variety table that contains the values for the variety.';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            field("NPR Variety 1 Value"; Rec."NPR Variety 1 Value")
            {
                ToolTip = 'Specified the 1st variety value to be used for the item variant.';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            field("NPR Variety 2"; Rec."NPR Variety 2")
            {
                ToolTip = 'Specifies the 2nd variety to be used for the item variant.';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            field("NPR Variety 2 Table"; Rec."NPR Variety 2 Table")
            {
                ToolTip = 'Specifies the 2nd variety table that contains the values for the variety.';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            field("NPR Variety 2 Value"; Rec."NPR Variety 2 Value")
            {
                ToolTip = 'Specified the 2nd variety value to be used for the item variant.';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            field("NPR Variety 3"; Rec."NPR Variety 3")
            {
                ToolTip = 'Specifies the 3rd variety to be used for the item variant.';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            field("NPR Variety 3 Table"; Rec."NPR Variety 3 Table")
            {
                ToolTip = 'Specifies the 3rd variety table that contains the values for the variety.';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            field("NPR Variety 3 Value"; Rec."NPR Variety 3 Value")
            {
                ToolTip = 'Specified the 3rd variety value to be used for the item variant.';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            field("NPR Variety 4"; Rec."NPR Variety 4")
            {
                ToolTip = 'Specifies the 4th variety to be used for the item variant.';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            field("NPR Variety 4 Table"; Rec."NPR Variety 4 Table")
            {
                ToolTip = 'Specifies the 4th variety table that contains the values for the variety.';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
            field("NPR Variety 4 Value"; Rec."NPR Variety 4 Value")
            {
                ToolTip = 'Specified the 4th variety value to be used for the item variant.';
                ApplicationArea = NPRRetail;
                Visible = false;
            }
        }
        addafter(Control1)
        {
            part("NPR ShopifyIDs"; "NPR Spfy Item Variant IDs Subp")
            {
                ApplicationArea = NPRShopify;
                Caption = 'Shopify Integration';
                Visible = ShopifyStoreListGenerated;
                SubPageLink = Type = const(Item), "Item No." = field("Item No."), "Variant Code" = const('');
            }
        }
#endif
    }

#if not BC17
    var
        ShopifyIntegrationIsEnabled: Boolean;
        ShopifyStoreListGenerated: Boolean;

    trigger OnOpenPage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items);
        NPR_UpdateShopifyStoreListGenerated();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage."NPR ShopifyIDs".Page.SetItemVariant(Rec);
        CurrPage."NPR ShopifyIDs".Page.Update(false);
    end;

    local procedure NPR_UpdateShopifyStoreListGenerated()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
    begin
        ShopifyStoreListGenerated := false;
        if not ShopifyIntegrationIsEnabled then
            exit;
        if Rec.GetFilter("Item No.") <> '' then
            Item."No." := Rec.GetRangeMin("Item No.");
        if Item."No." = '' then
            exit;
        SpfyStoreLinkMgt.FilterStoreItemLinks(Item.RecordId(), SpfyStoreItemLink);
        ShopifyStoreListGenerated := not SpfyStoreItemLink.IsEmpty();
    end;
#endif
}