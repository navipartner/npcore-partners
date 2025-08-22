#if not BC17
page 6185087 "NPR Spfy Store-Item Cat. Links"
{
    Extensible = false;
    Caption = 'Shopify Store-Item Category Links';
    PageType = List;
    SourceTable = "NPR Spfy Store";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shopify Store Code"; Rec.Code)
                {
                    Caption = 'Store Code';
                    ToolTip = 'Specifies the Shopify store the item category is related to.';
                    ApplicationArea = NPRShopify;
                }
                field("Item Category Code"; SpfyStoreItemCatLink."Item Category Code")
                {
                    Caption = 'Item Category Code';
                    ToolTip = 'Specifies a BC item category the link to be created for.';
                    ApplicationArea = NPRShopify;
                }
                field("Metafield Value ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemCatLink.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Metafield Value ID';
                    ToolTip = 'Specifies the metafield value ID created for the item category.';
                    ApplicationArea = NPRShopify;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        ChangeShopifyID: Page "NPR Spfy Change Assigned ID";
                    begin
                        SpfyStoreItemCatLink.TestField("Item Category Code");
                        SpfyStoreItemCatLink.TestField("Shopify Store Code");

                        Clear(ChangeShopifyID);
                        ChangeShopifyID.SetOptions(SpfyStoreItemCatLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                        ChangeShopifyID.RunModal();

                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SpfyStoreItemCatLink."Shopify Store Code" := Rec.Code;
    end;

    internal procedure SetItemCategory(ItemCategoryCodeIn: Code[20])
    begin
        SpfyStoreItemCatLink."Item Category Code" := ItemCategoryCodeIn;
    end;

    var
        SpfyStoreItemCatLink: Record "NPR Spfy Store-Item Cat. Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
}
#endif