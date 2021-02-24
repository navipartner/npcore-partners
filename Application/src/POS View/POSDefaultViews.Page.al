page 6150712 "NPR POS Default Views"
{
    Caption = 'POS Default Views';
    PageType = List;
    SourceTable = "NPR POS Default View";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Salesperson Filter"; Rec."Salesperson Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Filter field';
                }
                field("Register Filter"; Rec."Register Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. Filter field';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Date field';
                }
                field(Monday; Rec.Monday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Monday field';
                }
                field(Tuesday; Rec.Tuesday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Tuesday field';
                }
                field(Wednesday; Rec.Wednesday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Wednesday field';
                }
                field(Thursday; Rec.Thursday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Thursday field';
                }
                field(Friday; Rec.Friday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Friday field';
                }
                field(Saturday; Rec.Saturday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Saturday field';
                }
                field(Sunday; Rec.Sunday)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sunday field';
                }
                field("POS View Code"; Rec."POS View Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS View Code field';
                }
            }
        }
    }
}