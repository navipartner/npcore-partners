page 6150712 "POS Default Views"
{
    Caption = 'POS Default Views';
    PageType = List;
    SourceTable = "POS Default View";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Salesperson Filter"; "Salesperson Filter")
                {
                    ApplicationArea = All;
                }
                field("Register Filter"; "Register Filter")
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                }
                field(Monday; Monday)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Tuesday; Tuesday)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Wednesday; Wednesday)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Thursday; Thursday)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Friday; Friday)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Saturday; Saturday)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Sunday; Sunday)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("POS View Code"; "POS View Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

