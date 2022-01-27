page 6150687 "NPR NPRE Kitchen Station Slct."
{
    Extensible = False;
    Caption = 'Kitchen Station Selection Setup';
    DataCaptionExpression = '';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NPRE Kitchen Station Slct.";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Restaurant Code"; Rec."Restaurant Code")
                {

                    ToolTip = 'Specifies the value of the Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Seating Location"; Rec."Seating Location")
                {

                    ToolTip = 'Specifies the value of the Seating Location field';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step"; Rec."Serving Step")
                {

                    ToolTip = 'Specifies the value of the Serving Step field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Category Code"; Rec."Print Category Code")
                {

                    ToolTip = 'Specifies the value of the Print Category Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Production Restaurant Code"; Rec."Production Restaurant Code")
                {

                    ToolTip = 'Specifies the value of the Production Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Kitchen Station"; Rec."Kitchen Station")
                {

                    ToolTip = 'Specifies the value of the Kitchen Station field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014409; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

            }
            systempart(Control6014410; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;

            }
        }
    }
}
