page 6150955 "NPR QR Code Setup Line"
{
    Extensible = false;
    UsageCategory = None;
    Caption = 'QR Code Setup Line';
    PageType = Card;
    SourceTable = "NPR QR Code Setup Line";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Unit No. field.';
                }
                field("Terminal ID"; Rec."Terminal ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Terminal ID field.';
                }
            }
        }
    }
}
