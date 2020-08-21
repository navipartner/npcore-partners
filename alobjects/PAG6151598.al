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
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket No."; "Sales Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Sale Date"; "Sale Date")
                {
                    ApplicationArea = All;
                }
                field("Sale Line No."; "Sale Line No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
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
                field("Discount Amount"; "Discount Amount")
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

