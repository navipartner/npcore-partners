page 6151594 "NpDc Coupon Entries"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon

    Caption = 'Coupon Entries';
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NpDc Coupon Entry";

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
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
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

