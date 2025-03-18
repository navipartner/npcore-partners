query 6014495 "NPR NpDc Coupon Entry"
{
    Caption = 'Coupon Entry';
    QueryType = Normal;


    elements
    {
        dataitem(NpDcCouponEntry; "NPR NpDc Coupon Entry")
        {
            column(Coupon_No_; "Coupon No.")
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