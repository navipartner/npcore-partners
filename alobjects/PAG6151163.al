page 6151163 "MM Loyalty Alter Membership"
{
    // MM1.40/TSA /20190816 CASE 361664 Initial Version

    Caption = 'Loyalty Alter Membership';
    PageType = List;
    SourceTable = "MM Loyalty Alter Membership";

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

