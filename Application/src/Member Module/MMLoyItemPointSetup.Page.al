page 6060107 "NPR MM Loy. Item Point Setup"
{

    Caption = 'Loyalty Item Point Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Loy. Item Point Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Constraint; Rec.Constraint)
                {

                    ToolTip = 'Specifies the value of the Constraint field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow On Discounted Sale"; Rec."Allow On Discounted Sale")
                {

                    ToolTip = 'Specifies the value of the Allow On Discounted Sale field';
                    ApplicationArea = NPRRetail;
                }
                field(Award; Rec.Award)
                {

                    ToolTip = 'Specifies the value of the Award field';
                    ApplicationArea = NPRRetail;
                }
                field(Points; Rec.Points)
                {

                    ToolTip = 'Specifies the value of the Points field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Factor"; Rec."Amount Factor")
                {

                    ToolTip = 'Specifies the value of the Amount Factor field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

