query 6014496 "NPR NpDc Arch.Coupon Entry"
{
    Caption = 'Archived Coupon Entry';
    QueryType = Normal;


    elements
    {
        dataitem(NpDcArchCouponEntry; "NPR NpDc Arch.Coupon Entry")
        {
            column(Arch__Coupon_No_; "Arch. Coupon No.")
            {
            }
            column(Coupon_Type; "Coupon Type")
            {
            }
            column(Amount; Amount)
            {
                Method = Sum;
            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
            filter(Posting_Date; "Posting Date")
            {
            }

            filter(Register_No_; "Register No.")
            {
            }
            filter(Document_Type; "Document Type")
            {
            }
            filter(Document_No_; "Document No.")
            {
            }
            filter(Entry_Type; "Entry Type")
            {
            }
        }
    }
}