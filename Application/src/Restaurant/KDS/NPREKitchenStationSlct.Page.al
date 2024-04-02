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
                    ToolTip = 'Specifies the restaurant this kitchen station selection setup line is used at. Leave the field blank if you want the setup line to be used for all restaurants.';
                    ApplicationArea = NPRRetail;
                }
                field("Seating Location"; Rec."Seating Location")
                {
                    ToolTip = 'Specifies the seating location this kitchen station selection setup line is used at. Leave the field blank if you want the setup line to be used for all seating locations.';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step"; Rec."Serving Step")
                {
                    ToolTip = 'Specifies the meal flow serving step this kitchen station selection setup line is used at. Leave the field blank if you want the setup line to be used regardless of the serving step.';
                    ApplicationArea = NPRRetail;
                }
                field("Print Category Code"; Rec."Print Category Code")
                {
                    ToolTip = 'Specifies the item print/production category this kitchen station selection setup line is used for. Leave the field blank if you want the setup line to be used regardless of the category.';
                    ApplicationArea = NPRRetail;
                }
                field("Production Restaurant Code"; Rec."Production Restaurant Code")
                {
                    ToolTip = 'Specifies the restaurant system should send kitchen requests to for the setup line.';
                    ApplicationArea = NPRRetail;
                }
                field("Kitchen Station"; Rec."Kitchen Station")
                {
                    ToolTip = 'Specifies the production restaurant kitchen station system should send kitchen requests to for the setup line.';
                    ApplicationArea = NPRRetail;
                }
                field("Production Step"; Rec."Production Step")
                {
                    ToolTip = 'Specifies the production step at which this kitchen station should be engaged. This can be used if you have a sequential produciton flow where there are kitchen stations that depend on the production results of other kitchen stations.';
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if (Rec."Production Restaurant Code" <> '') and (Rec."Restaurant Code" = '') then
            Rec."Restaurant Code" := Rec."Production Restaurant Code";
    end;
}
