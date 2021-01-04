page 6151601 "NPR NpDc Arch.Coupon Entries"
{
    Caption = 'Archived Coupon Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    PopulateAllFields = true;
    SourceTable = "NPR NpDc Arch.Coupon Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = All;
                }
                field("Amount per Qty."; "Amount per Qty.")
                {
                    ApplicationArea = All;
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Closed by Entry No."; "Closed by Entry No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

