page 6150625 "NPR POS NPRE Restaur. Profiles"
{
    // NPR5.55/ALPO/20200730 CASE 414938 POS Store/POS Unit - Restaurant link

    PageType = ListPlus;
    UsageCategory = Administration;
    SourceTable = "NPR POS NPRE Rest. Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Restaurant Code"; "Restaurant Code")
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

    actions
    {
    }
}

