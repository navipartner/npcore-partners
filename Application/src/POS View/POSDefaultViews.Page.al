page 6150712 "NPR POS Default Views"
{
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

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Filter"; Rec."Salesperson Filter")
                {

                    ToolTip = 'Specifies the value of the Salesperson Filter field';
                    ApplicationArea = NPRRetail;
                }
                field("Register Filter"; Rec."Register Filter")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. Filter field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {

                    ToolTip = 'Specifies the value of the Ending Date field';
                    ApplicationArea = NPRRetail;
                }
                field(Monday; Rec.Monday)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Monday field';
                    ApplicationArea = NPRRetail;
                }
                field(Tuesday; Rec.Tuesday)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Tuesday field';
                    ApplicationArea = NPRRetail;
                }
                field(Wednesday; Rec.Wednesday)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Wednesday field';
                    ApplicationArea = NPRRetail;
                }
                field(Thursday; Rec.Thursday)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Thursday field';
                    ApplicationArea = NPRRetail;
                }
                field(Friday; Rec.Friday)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Friday field';
                    ApplicationArea = NPRRetail;
                }
                field(Saturday; Rec.Saturday)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Saturday field';
                    ApplicationArea = NPRRetail;
                }
                field(Sunday; Rec.Sunday)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Sunday field';
                    ApplicationArea = NPRRetail;
                }
                field("POS View Code"; Rec."POS View Code")
                {

                    ToolTip = 'Specifies the value of the POS View Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}