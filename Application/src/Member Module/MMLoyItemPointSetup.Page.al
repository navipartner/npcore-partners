page 6060107 "NPR MM Loy. Item Point Setup"
{

    Caption = 'Loyalty Item Point Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Loy. Item Point Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Constraint; Constraint)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint field';
                }
                field("Allow On Discounted Sale"; "Allow On Discounted Sale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow On Discounted Sale field';
                }
                field(Award; Award)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Award field';
                }
                field(Points; Points)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points field';
                }
                field("Amount Factor"; "Amount Factor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Factor field';
                }
            }
        }
    }

    actions
    {
    }
}

