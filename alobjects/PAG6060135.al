page 6060135 "MM Membership Admission Setup"
{
    // MM80.1.08/TSA/20160225  CASE 232494-01 Transport MM1.08 - 16 February 2016

    Caption = 'Membership Admission Setup';
    PageType = List;
    SourceTable = "MM Membership Admission Setup";

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
                field("Ticket No. Type";"Ticket No. Type")
                {
                }
                field("Ticket No.";"Ticket No.")
                {
                }
                field("Cardinality Type";"Cardinality Type")
                {
                }
                field("Max Cardinality";"Max Cardinality")
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

