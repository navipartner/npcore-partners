page 6151163 "NPR MM Loyalty Alter Members."
{

    Caption = 'Loyalty Alter Membership';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Loyalty Alter Members.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Loyalty Code"; "Loyalty Code")
                {
                    ApplicationArea = All;
                }
                field("From Membership Code"; "From Membership Code")
                {
                    ApplicationArea = All;
                }
                field("Change Direction"; "Change Direction")
                {
                    ApplicationArea = All;
                }
                field("To Membership Code"; "To Membership Code")
                {
                    ApplicationArea = All;
                }
                field("Points Threshold"; "Points Threshold")
                {
                    ApplicationArea = All;
                }
                field("Sales Item No."; "Sales Item No.")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
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

