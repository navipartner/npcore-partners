page 6060087 "MM Membership Limitation Setup"
{
    // MM1.21/TSA /20170721 CASE 284653 First Version

    Caption = 'Membership Limitation Setup';
    PageType = List;
    SourceTable = "MM Membership Limitation Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership  Code";"Membership  Code")
                {
                }
                field("Admission Code";"Admission Code")
                {
                }
                field("Constraint Type";"Constraint Type")
                {
                }
                field("Constraint Source";"Constraint Source")
                {
                }
                field("Constraint Seconds";"Constraint Seconds")
                {
                }
                field("Constraint From Time";"Constraint From Time")
                {
                }
                field("Constraint Until Time";"Constraint Until Time")
                {
                }
                field("Constraint Dateformula";"Constraint Dateformula")
                {
                }
                field("Event Type";"Event Type")
                {
                    Visible = false;
                }
                field("Event Limit";"Event Limit")
                {
                }
                field("POS Response Action";"POS Response Action")
                {
                }
                field("POS Response Message";"POS Response Message")
                {
                }
                field("WS Response Action";"WS Response Action")
                {
                }
                field("WS Deny Message";"WS Deny Message")
                {
                }
                field("Response Code";"Response Code")
                {
                }
                field(Blocked;Blocked)
                {
                }
            }
        }
    }

    actions
    {
    }
}

