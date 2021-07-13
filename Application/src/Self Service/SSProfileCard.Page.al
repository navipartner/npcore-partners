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
