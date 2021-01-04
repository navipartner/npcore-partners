page 6150687 "NPR NPRE Kitchen Station Slct."
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Kitchen Station Selection Setup';
    DataCaptionExpression = '';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NPRE Kitchen Station Slct.";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Restaurant Code"; "Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                }
                field("Seating Location"; "Seating Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seating Location field';
                }
                field("Serving Step"; "Serving Step")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serving Step field';
                }
                field("Print Category Code"; "Print Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Category Code field';
                }
                field("Production Restaurant Code"; "Production Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Restaurant Code field';
                }
                field("Kitchen Station"; "Kitchen Station")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Kitchen Station field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014409; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control6014410; Links)
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

