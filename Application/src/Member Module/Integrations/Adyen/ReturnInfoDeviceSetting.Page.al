page 6150861 "NPR Return Info Device Setting"
{
    Extensible = false;
    UsageCategory = None;
    Caption = 'Return Information Device Setting';
    PageType = Card;
    SourceTable = "NPR Return Info Device Setting";

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
