#if not BC17
page 6184565 "NPR Spfy Item Variant IDs Subp"
{
    Extensible = false;
    Caption = 'Shopify Item Variant IDs';
    PageType = ListPart;
    SourceTable = "NPR Spfy Store-Item Link";
    Editable = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies a Shopify store the linked item is integrated to.';
                    ApplicationArea = NPRShopify;
                }
                field("Store Integration Is Enabled"; Rec."Store Integration Is Enabled")
                {
                    ToolTip = 'Specifies whether the item is integrated with the Shopify store.';
                    ApplicationArea = NPRShopify;
                    DrillDown = false;
                }
                field("NPR Spfy Variant ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Shopify Variant ID';
                    ToolTip = 'Specifies a Shopify Variant ID assigned to the item variant.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        ChangeShopifyID: Page "NPR Spfy Change Assigned ID";
                    begin
                        TestRequiredFields();
                        Clear(ChangeShopifyID);
                        ChangeShopifyID.SetOptions(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                        ChangeShopifyID.RunModal();
                    end;
                }
                field("NPR Spfy Inventory Item ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID"))
                {
                    Caption = 'Shopify Inventory Item ID';
                    ToolTip = 'Specifies a Shopify Inventory Item ID assigned to the item variant.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        ChangeShopifyID: Page "NPR Spfy Change Assigned ID";
                    begin
                        TestRequiredFields();
                        Clear(ChangeShopifyID);
                        ChangeShopifyID.SetOptions(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
                        ChangeShopifyID.RunModal();
                    end;
                }
            }
        }
    }

    var
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";

    trigger OnAfterGetRecord()
    begin
        SpfyStoreItemVariantLink."Shopify Store Code" := Rec."Shopify Store Code";
    end;

    procedure SetItemVariant(ItemVariant: Record "Item Variant")
    begin
        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::Variant;
        SpfyStoreItemVariantLink."Item No." := ItemVariant."Item No.";
        SpfyStoreItemVariantLink."Variant Code" := ItemVariant.Code;
    end;

    local procedure TestRequiredFields()
    var
        NotInitializedErr: Label 'The page has not been initialized properly. It must be run in an Item Variant context, and %1 must be specifed.', Comment = '%1 - Shopify Store Code fieldcaption';
    begin
        if (SpfyStoreItemVariantLink.Type = SpfyStoreItemVariantLink.Type::Variant) and
           (SpfyStoreItemVariantLink."Item No." <> '') and
           (SpfyStoreItemVariantLink."Variant Code" <> '') and
           (SpfyStoreItemVariantLink."Shopify Store Code" <> '')
        then
            exit;
        Error(NotInitializedErr, SpfyStoreItemVariantLink.FieldCaption("Shopify Store Code"));
    end;
}
#endif