page 6151170 "NPR NpGp Det. POS S. Entries"
{
    Caption = 'Detailed Global POS Sales Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpGp Det. POS Sales Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Time"; "Entry Time")
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = All;
                }
                field(Positive; Positive)
                {
                    ApplicationArea = All;
                }
                field("Closed by Entry No."; "Closed by Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Applies to Store Code"; "Applies to Store Code")
                {
                    ApplicationArea = All;
                }
                field("Cross Store Application"; "Cross Store Application")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
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

