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
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                }
                field("Inserted at"; "Inserted at")
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
                field("Coupon Type"; "Coupon Type")
                {
                    ApplicationArea = All;
                }
                field("Coupon No."; "Coupon No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Reference No."; "Reference No.")
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

