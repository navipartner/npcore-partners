page 6150678 "NPR SS Profiles"
{
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR SS Profile";
    Caption = 'POS Self Service Profiles';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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