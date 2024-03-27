#if not BC17
page 6184560 "NPR Spfy Assigned IDs"
{
    Extensible = false;
    PageType = List;
    SourceTable = "NPR Spfy Assigned ID";
    Caption = 'Assigned Shopify IDs';
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the value of the Table No. field.';
                    ApplicationArea = NPRShopify;
                }
                field("BC Record ID"; Format(Rec."BC Record ID"))
                {
                    Caption = 'Assigned to BC Record ID';
                    ToolTip = 'Specifies the value of the Assigned to BC Record ID field.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify ID"; Rec."Shopify ID")
                {
                    ToolTip = 'Specifies the value of the Shopify ID field.';
                    ApplicationArea = NPRShopify;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(OpenMember)
            {
                Caption = 'Show Record';
                ToolTip = 'Open related record.';
                ApplicationArea = NPRShopify;
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    PageManagement: Codeunit "Page Management";
                    RecRef: RecordRef;
                begin
                    RecRef.Get(Rec."BC Record ID");
                    PageManagement.PageRun(RecRef);
                end;
            }
        }
    }
}
#endif