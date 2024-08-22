pageextension 6014458 "NPR Item Variants" extends "Item Variants"
{
    layout
    {
        addafter("Description 2")
        {
            field("NPR Blocked"; Rec."NPR Blocked")
            {
                ToolTip = 'Specifies if the Item Variant is blocked or not';
                ApplicationArea = NPRRetail;
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                ObsoleteState = Pending;
                ObsoleteTag = '2024-02-28';
                ObsoleteReason = 'Replaced with standard Microsoft field "Blocked"';
                Visible = false;
                Enabled = false;
#ENDIF
            }
        }

#if not BC17
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