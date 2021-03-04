page 6150699 "NPR SS Profile Card"
{
    Caption = 'POS Self Service Profile';
    PageType = Card;
    SourceTable = "NPR SS Profile";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Kiosk Mode Unlock PIN"; Rec."Kiosk Mode Unlock PIN")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kios Mode Unlock PIN field';
                }
            }
        }
    }


}
