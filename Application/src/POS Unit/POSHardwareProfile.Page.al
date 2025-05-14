page 6185054 "NPR POS Hardware Profile"
{
    Extensible = False;
    Caption = 'NPR POS Hardware Profile';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR POS Hardware Profile";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique code for a profile.';
                }
                field("IP Address"; Rec."IP Address")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the IP address of the profile.';
                }
            }
        }
    }
}