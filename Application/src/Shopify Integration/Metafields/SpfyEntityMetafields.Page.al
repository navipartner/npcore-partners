#if not BC17
page 6184865 "NPR Spfy Entity Metafields"
{
    Extensible = false;
    Caption = 'Shopify Entity Metafields';
    PageType = List;
    SourceTable = "NPR Spfy Entity Metafield";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the BC table the metafield value relates to.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("BC Record ID"; Format(Rec."BC Record ID"))
                {
                    Caption = 'BC Record ID';
                    ToolTip = 'Specifies the BC record the metafield value is attached to.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Owner Type"; Rec."Owner Type")
                {
                    ToolTip = 'Specifies the Shopify object type the metafield was created for.';
                    ApplicationArea = NPRShopify;
                }
                field("Metafield ID"; Rec."Metafield ID")
                {
                    ToolTip = 'Specifies the unique Shopify internal identifier of the metafield.';
                    ApplicationArea = NPRShopify;
                }
                field("Metafield Key"; Rec."Metafield Key")
                {
                    ToolTip = 'Specifies the user-defined unique identifier of the Shopify metafield within its namespace.';
                    ApplicationArea = NPRShopify;
                }
                field("Metafield Value"; Rec.GetMetafieldValue(true))
                {
                    Caption = 'Metafield Value';
                    ToolTip = 'Specifies the data stored in the metafield.';
                    ApplicationArea = NPRShopify;
                }
                field("Metafield Value Version ID"; Rec."Metafield Value Version ID")
                {
                    ToolTip = 'Specifies the metafield stored value version.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
            }
        }
    }
}
#endif