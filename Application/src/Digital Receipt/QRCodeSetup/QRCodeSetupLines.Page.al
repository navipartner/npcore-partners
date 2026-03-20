page 6150954 "NPR QR Code Setup Lines"
{
    Extensible = false;
    Caption = 'QR Code Setup Lines';
    PageType = ListPart;
    SourceTable = "NPR QR Code Setup Line";
    CardPageId = "NPR QR Code Setup Line";
    UsageCategory = None;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
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
