page 6151173 "NPR NpGp POS Info POS Entry"
{
    Caption = 'Global POS Info Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR NpGp POS Info POS Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Info Code"; "POS Info Code")
                {
                    ApplicationArea = All;
                }
                field("POS Info"; "POS Info")
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field(Price; Price)
                {
                    ApplicationArea = All;
                }
                field("Net Amount"; "Net Amount")
                {
                    ApplicationArea = All;
                }
                field("Gross Amount"; "Gross Amount")
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; "Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Sales Line No."; "Sales Line No.")
                {
                    ApplicationArea = All;
                }
                field("POS Entry No."; "POS Entry No.")
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

