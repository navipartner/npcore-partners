page 6184668 "NPR Item - Lot Number"
{
    Extensible = false;
    ApplicationArea = NPRRetail;
    Caption = 'Item - Lot Number';
    PageType = List;
    SourceTable = "Item Ledger Entry";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Lot No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Expiration Date field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
            }
        }
    }
}
