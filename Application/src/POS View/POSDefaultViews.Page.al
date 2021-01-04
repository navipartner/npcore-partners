page 6150712 "NPR POS Default Views"
{
    Caption = 'POS Default Views';
    PageType = List;
    SourceTable = "NPR POS Default View";
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
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Salesperson Filter"; "Salesperson Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Filter field';
                }
                field("Register Filter"; "Register Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. Filter field';
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Date field';
                }
                field(Monday; Monday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Monday field';
                }
                field(Tuesday; Tuesday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Tuesday field';
                }
                field(Wednesday; Wednesday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Wednesday field';
                }
                field(Thursday; Thursday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Thursday field';
                }
                field(Friday; Friday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Friday field';
                }
                field(Saturday; Saturday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Saturday field';
                }
                field(Sunday; Sunday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sunday field';
                }
                field("POS View Code"; "POS View Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS View Code field';
                }
            }
        }
    }

    actions
    {
    }
}

