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
                field("Entry Type";"Entry Type")
                {
                }
                field("Posting Date";"Posting Date")
                {
                }
                field(Amount;Amount)
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Remaining Quantity";"Remaining Quantity")
                {
                }
                field("Amount per Qty.";"Amount per Qty.")
                {
                }
                field(Open;Open)
                {
                }
                field("Document Type";"Document Type")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("User ID";"User ID")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
                field("Closed by Entry No.";"Closed by Entry No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

