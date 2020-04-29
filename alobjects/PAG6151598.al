page 6151598 "NpDc Sale Line POS Coupons"
{
    // NPR5.34/MHA /20170724  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon

    Caption = 'Sale Line POS Coupons';
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NpDc Sale Line POS Coupon";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No.";"Register No.")
                {
                }
                field("Sales Ticket No.";"Sales Ticket No.")
                {
                }
                field("Sale Date";"Sale Date")
                {
                }
                field("Sale Line No.";"Sale Line No.")
                {
                }
                field(Type;Type)
                {
                }
                field("Coupon Type";"Coupon Type")
                {
                }
                field("Coupon No.";"Coupon No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Discount Amount";"Discount Amount")
                {
                }
            }
        }
    }

    actions
    {
    }
}

