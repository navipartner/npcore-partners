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
                field("Loyalty Code";"Loyalty Code")
                {
                }
                field("From Membership Code";"From Membership Code")
                {
                }
                field("Change Direction";"Change Direction")
                {
                }
                field("To Membership Code";"To Membership Code")
                {
                }
                field("Points Threshold";"Points Threshold")
                {
                }
                field("Sales Item No.";"Sales Item No.")
                {
                }
                field(Blocked;Blocked)
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
    }
}

