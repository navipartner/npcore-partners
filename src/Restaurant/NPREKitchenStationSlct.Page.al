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
                }
                field("Seating Location"; "Seating Location")
                {
                    ApplicationArea = All;
                }
                field("Serving Step"; "Serving Step")
                {
                    ApplicationArea = All;
                }
                field("Print Category Code"; "Print Category Code")
                {
                    ApplicationArea = All;
                }
                field("Production Restaurant Code"; "Production Restaurant Code")
                {
                    ApplicationArea = All;
                }
                field("Kitchen Station"; "Kitchen Station")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014409; Notes)
            {
                Visible = false;
            }
            systempart(Control6014410; Links)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

