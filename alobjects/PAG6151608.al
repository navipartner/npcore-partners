page 6151608 "NpDc Ext. Coupon Reservations"
{
    // NPR5.51/MHA /20190724  CASE 343352 Object Created

    Caption = 'External Coupon Reservations';
    PageType = List;
    SourceTable = "NpDc Ext. Coupon Reservation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Document No.";"External Document No.")
                {
                }
                field("Inserted at";"Inserted at")
                {
                }
                field("Document Type";"Document Type")
                {
                }
                field("Document No.";"Document No.")
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
                field("Reference No.";"Reference No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

