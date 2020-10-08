page 6060135 "NPR MM Members. Admis. Setup"
{

    Caption = 'Membership Admission Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Members. Admis. Setup";

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

