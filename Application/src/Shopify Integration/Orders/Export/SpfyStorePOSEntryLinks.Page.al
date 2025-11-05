#if not (BC17 or BC18 or BC19 or BC20)
page 6185127 "NPR Spfy Store-POS Entry Links"
{
    Extensible = false;
    Caption = 'Shopify Store-POS Entry Links';
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
                field("POS Entry No."; SpfyStorePOSEntryLink."POS Entry No.")
                {
                    Caption = 'POS Entry No.';
                    ToolTip = 'Specifies the POS entry number the link is created for.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Order ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStorePOSEntryLink.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Shopify Order ID';
                    ToolTip = 'Specifies the Shopify order ID created from the POS entry.';
                    ApplicationArea = NPRShopify;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        ChangeShopifyID: Page "NPR Spfy Change Assigned ID";
                    begin
                        SpfyStorePOSEntryLink.TestField("POS Entry No.");
                        SpfyStorePOSEntryLink.TestField("Shopify Store Code");

                        Clear(ChangeShopifyID);
                        ChangeShopifyID.SetOptions(SpfyStorePOSEntryLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                        ChangeShopifyID.RunModal();

                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SpfyStorePOSEntryLink."Shopify Store Code" := Rec.Code;
    end;

    internal procedure SetPOSEntry(PosEntryNo: Integer)
    begin
        SpfyStorePOSEntryLink."POS Entry No." := PosEntryNo;
    end;

    var
        SpfyStorePOSEntryLink: Record "NPR Spfy Store-POS Entry Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
}
#endif