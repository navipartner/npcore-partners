page 6150694 "NPR NPRE Service Flow Profiles"
{
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Rest. Service Flow Profiles';
    CardPageID = "NPR NPRE Serv. Flow Prof. Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Serv.Flow Profile";
    UsageCategory = Administration;

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
            }
        }
        area(factboxes)
        {
            systempart(Control6014405; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control6014406; Links)
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

