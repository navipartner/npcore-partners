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
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Constraint; Constraint)
                {
                    ApplicationArea = All;
                }
                field("Allow On Discounted Sale"; "Allow On Discounted Sale")
                {
                    ApplicationArea = All;
                }
                field(Award; Award)
                {
                    ApplicationArea = All;
                }
                field(Points; Points)
                {
                    ApplicationArea = All;
                }
                field("Amount Factor"; "Amount Factor")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

