page 6150860 "NPR ReturnInfo Device Settings"
{
    Extensible = false;
    Caption = 'Return Information Device Settings';
    PageType = ListPart;
    SourceTable = "NPR Return Info Device Setting";
    CardPageId = "NPR Return Info Device Setting";
    UsageCategory = None;

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
