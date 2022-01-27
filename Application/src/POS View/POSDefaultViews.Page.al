page 6150712 "NPR POS Default Views"
{
    Extensible = False;
    Caption = 'POS Default Views';
    PageType = List;
    SourceTable = "NPR POS Default View";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'It defines the type for which the POS view is applicable. The Values are Login, Sale, Payment, Balance, Locked, Restaurant';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Filter"; Rec."Salesperson Filter")
                {

                    ToolTip = 'Specifies any filter by Sales Person';
                    ApplicationArea = NPRRetail;
                }
                field("Register Filter"; Rec."Register Filter")
                {

                    ToolTip = 'Specifies any filter by POS Unit';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    ToolTip = 'Specifies the Starting Date for which the view is enabled';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {

                    ToolTip = 'Specifies the Ending Date for which the view is enabled';
                    ApplicationArea = NPRRetail;
                }
                field(Monday; Rec.Monday)
                {

                    Visible = false;
                    ToolTip = 'Indicates if applicable on Monday';
                    ApplicationArea = NPRRetail;
                }
                field(Tuesday; Rec.Tuesday)
                {

                    Visible = false;
                    ToolTip = 'Indicates if applicable on Tuesday';
                    ApplicationArea = NPRRetail;
                }
                field(Wednesday; Rec.Wednesday)
                {

                    Visible = false;
                    ToolTip = 'Indicates if applicable on Wednesday';
                    ApplicationArea = NPRRetail;
                }
                field(Thursday; Rec.Thursday)
                {

                    Visible = false;
                    ToolTip = 'Indicates if applicable on Thursday';
                    ApplicationArea = NPRRetail;
                }
                field(Friday; Rec.Friday)
                {

                    Visible = false;
                    ToolTip = 'Indicates if applicable on Friday';
                    ApplicationArea = NPRRetail;
                }
                field(Saturday; Rec.Saturday)
                {

                    Visible = false;
                    ToolTip = 'Indicates if applicable on Saturday';
                    ApplicationArea = NPRRetail;
                }
                field(Sunday; Rec.Sunday)
                {

                    Visible = false;
                    ToolTip = 'Indicates if applicable on Sunday';
                    ApplicationArea = NPRRetail;
                }
                field("POS View Code"; Rec."POS View Code")
                {

                    ToolTip = 'Specifies the POS View Code to be used';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
