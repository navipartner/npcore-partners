#if not BC17
page 6184567 "NPR Spfy Store-Item Links"
{
    Extensible = false;
    Caption = 'Shopify Store-Item Links';
    PageType = List;
    SourceTable = "NPR Spfy Store-Item Link";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies whether the entry is related to an item or item variant.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies a BC item the link to be created for.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies a BC item variant the link to be created for.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies a Shopify store the linked item is integrated to.';
                    ApplicationArea = NPRShopify;
                }
                field("Integrate with This Store"; Rec."Sync. to this Store")
                {
                    ToolTip = 'Specifies whether the item has been requested to be integrated with the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Product ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Shopify Product ID';
                    ToolTip = 'Specifies a Shopify Product ID assigned to the item.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Variant ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Shopify Variant ID';
                    ToolTip = 'Specifies a Shopify Variant ID assigned to the item variant.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Inventory Item ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID"))
                {
                    Caption = 'Shopify Inventory Item ID';
                    ToolTip = 'Specifies a Shopify Inventory Item ID assigned to the item variant.';
                    ApplicationArea = NPRShopify;
                }
                field("Synchronization Enabled"; Rec."Synchronization Is Enabled")
                {
                    ToolTip = 'Specifies whether synchronization has been successfully enabled/disabled on Shopify.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
            }
        }
    }

    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";

    trigger OnAfterGetCurrRecord()
    begin
        SpfyStoreItemLink := Rec;
        SpfyStoreItemVariantLink := Rec;
        if Rec.Type = Rec.Type::Item then begin
            SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
        end else begin
            SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
            SpfyStoreItemLink."Variant Code" := '';
        end;
    end;
}
#endif