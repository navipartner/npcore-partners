page 6150687 "NPR NPRE Kitchen Station Slct."
{
    Caption = 'Kitchen Station Selection Setup';
    DataCaptionExpression = '';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NPRE Kitchen Station Slct.";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                }
                field("Seating Location"; Rec."Seating Location")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seating Location field';
                }
                field("Serving Step"; Rec."Serving Step")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serving Step field';
                }
                field("Print Category Code"; Rec."Print Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Category Code field';
                }
                field("Production Restaurant Code"; Rec."Production Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Production Restaurant Code field';
                }
                field("Kitchen Station"; Rec."Kitchen Station")
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
}