page 6151599 "NpDc Arch. Coupons"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.37/MHA /20171012  CASE 293232 Object renamed from "NpDc Posted Coupons" to "NpDc Arch. Coupons"

    Caption = 'Archived Coupons';
    CardPageID = "NpDc Arch. Coupon Card";
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NpDc Arch. Coupon";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field("Coupon Type";"Coupon Type")
                {
                }
                field(Description;Description)
                {
                }
                field(Open;Open)
                {
                }
                field("Remaining Quantity";"Remaining Quantity")
                {
                }
                field("Starting Date";"Starting Date")
                {
                }
                field("Ending Date";"Ending Date")
                {
                }
                field("Reference No.";"Reference No.")
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Arch. Coupon Entries")
            {
                Caption = 'Archived Coupon Entries';
                Image = Entries;
                RunObject = Page "NpDc Arch. Coupon Entries";
                RunPageLink = "Arch. Coupon No."=FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
            }
        }
    }
}

