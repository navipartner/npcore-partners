page 6150625 "NPR POS NPRE Restaur. Profiles"
{
    Extensible = False;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS NPRE Rest. Profile";
    Caption = 'POS Restaur. Profiles';
    CardPageId = "NPR POS Restaur. Profile Card";
    Editable = false;
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this restaurant profile.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the profile.';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ToolTip = 'Specifies the restaurant code, which is selected by default on POS Restaurant View for POS units with this profile assigned.';
                    ApplicationArea = NPRRetail;
                }
                field("Default Seating Location"; Rec."Default Seating Location")
                {
                    ToolTip = 'Specifies the seating location, which is selected by default on POS Restaurant View for POS units with this profile assigned.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014406; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
            systempart(Control6014407; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
        }
    }
}
