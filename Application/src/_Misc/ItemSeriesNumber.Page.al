page 6014442 "NPR Item - Series Number"
{
    Extensible = False;
    Caption = 'Item Serial No.';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "Item Ledger Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("Serial No."; Rec."Serial No.")
                {

                    ToolTip = 'Specifies the value of the Serial No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {

                    ToolTip = 'Specifies the value of the Expiration Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

