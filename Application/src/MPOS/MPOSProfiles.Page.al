page 6150677 "NPR MPOS Profiles"
{
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MPOS Profile";
    Caption = 'MPOS Profiles';
    Editable = false;
    CardPageID = "NPR MPOS Profile Card";
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
            }
        }
    }
}