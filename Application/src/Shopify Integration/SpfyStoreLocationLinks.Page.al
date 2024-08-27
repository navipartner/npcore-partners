#if not BC17
page 6184558 "NPR Spfy Store-Location Links"
{
    Extensible = false;
    Caption = 'Shopify Store-Location Links';
    PageType = List;
    SourceTable = "NPR Spfy Store-Location Link";
    UsageCategory = None;
    DelayedInsert = true;
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies a Shopify store the linked location is related to.';
                    ApplicationArea = NPRShopify;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies a BC location the link to be created for.';
                    ApplicationArea = NPRShopify;
                    Visible = LocationCodeVisible;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Shopify Location ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Shopify Location ID';
                    ToolTip = 'Specifies a Shopify location ID the link is created with.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        ChangeShopifyID: Page "NPR Spfy Change Assigned ID";
                    begin
                        Rec.TestField("Location Code");
                        Rec.TestField("Shopify Store Code");
                        CurrPage.SaveRecord();
                        Commit();

                        Clear(ChangeShopifyID);
                        ChangeShopifyID.SetOptions(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                        ChangeShopifyID.RunModal();

                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        LocationCodeVisible := Rec.GetFilter("Location Code") = '';
    end;

    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        LocationCodeVisible: Boolean;
}
#endif