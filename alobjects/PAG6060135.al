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
                field("Membership  Code"; "Membership  Code")
                {
                    ApplicationArea = All;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                }
                field("Ticket No. Type"; "Ticket No. Type")
                {
                    ApplicationArea = All;
                }
                field("Ticket No."; "Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Cardinality Type"; "Cardinality Type")
                {
                    ApplicationArea = All;
                }
                field("Max Cardinality"; "Max Cardinality")
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

