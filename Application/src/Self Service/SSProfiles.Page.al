page 6150678 "NPR SS Profiles"
{
    Extensible = False;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR SS Profile";
    Caption = 'POS Self Service Profiles';
    Editable = false;
    CardPAgeID = "NPR SS Profile Card";
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Kiosk Mode Unlock PIN"; Rec."Kiosk Mode Unlock PIN")
                {

                    ToolTip = 'Specifies the value of the Kios Mode Unlock PIN field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
