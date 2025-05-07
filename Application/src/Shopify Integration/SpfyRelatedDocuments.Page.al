#if not BC17
page 6185053 "NPR Spfy Related Documents"
{
    Extensible = false;
    Caption = 'Related Documents';
    PageType = Worksheet;
    SourceTable = "NPR Spfy Related Document";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the type of the document.';
                    ApplicationArea = NPRShopify;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number.';
                    ApplicationArea = NPRShopify;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowDocument();
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Show Document")
            {
                Caption = 'Show Document';
                ToolTip = 'View the document.';
                Image = ViewOrder;
                ApplicationArea = NPRShopify;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.ShowDocument();
                end;
            }
        }
    }
}
#endif