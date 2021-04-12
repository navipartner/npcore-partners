page 6060107 "NPR MM Loy. Item Point Setup"
{

    Caption = 'Loyalty Item Point Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Loy. Item Point Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Constraint; Rec.Constraint)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Constraint field';
                }
                field("Allow On Discounted Sale"; Rec."Allow On Discounted Sale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow On Discounted Sale field';
                }
                field(Award; Rec.Award)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Award field';
                }
                field(Points; Rec.Points)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points field';
                }
                field("Amount Factor"; Rec."Amount Factor")
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

