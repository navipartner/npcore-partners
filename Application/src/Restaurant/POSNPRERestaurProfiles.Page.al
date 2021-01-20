page 6150625 "NPR POS NPRE Restaur. Profiles"
{
    PageType = ListPlus;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS NPRE Rest. Profile";

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
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014406; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control6014407; Links)
            {
                Visible = false;
                ApplicationArea = All;
            }
        }
    }
}