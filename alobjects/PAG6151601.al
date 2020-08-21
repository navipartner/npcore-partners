page 6151601 "NpDc Arch. Coupon Entries"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.37/MHA /20171012  CASE 293232 Object renamed from "NpDc Posted Coupon Entries" to "NpDc Arch. Coupon Entries"
    // NPR5.51/MHA /20190724  CASE 343352 Added "Document Type"

    Caption = 'Archived Coupon Entries';
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NpDc Arch. Coupon Entry";

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

    actions
    {
    }
}

