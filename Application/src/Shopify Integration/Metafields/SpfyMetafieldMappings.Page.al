#if not BC17
page 6184854 "NPR Spfy Metafield Mappings"
{
    Extensible = false;
    Caption = 'Shopify Metafield Mappings';
    PageType = List;
    SourceTable = "NPR Spfy Metafield Mapping";
    UsageCategory = None;
    PopulateAllFields = true;
    DelayedInsert = true;

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
                    Editable = false;
                    Visible = false;
                }
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the BC table the link is mapped to.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("BC Record ID"; Format(Rec."BC Record ID"))
                {
                    Caption = 'BC Record ID';
                    ToolTip = 'Specifies the BC record the link is mapped to.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies the Shopify store the metafield is created in.';
                    ApplicationArea = NPRShopify;
                }
                field("Owner Type"; Rec."Owner Type")
                {
                    ToolTip = 'Specifies the Shopify object type the metafield was created for.';
                    ApplicationArea = NPRShopify;
                }
                field("Metafield ID"; Rec."Metafield ID")
                {
                    ToolTip = 'Specifies the metafield unique Shopify ID.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
                        SelectedMetafieldID: Text[30];
                    begin
                        Rec.TestField("Shopify Store Code");
                        Rec.TestField("Owner Type");
                        SelectedMetafieldID := Rec."Metafield ID";
                        if SpfyMetafieldMgt.SelectShopifyMetafield(Rec."Shopify Store Code", Rec."Owner Type", SelectedMetafieldID) then begin
                            Rec.Validate("Metafield ID", SelectedMetafieldID);
                            CurrPage.Update(true);
                        end;
                    end;
                }
            }
        }
    }
}
#endif