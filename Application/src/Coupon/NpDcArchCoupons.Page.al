page 6151599 "NPR NpDc Arch. Coupons"
{
    Caption = 'Archived Coupons';
    CardPageID = "NPR NpDc Arch. Coupon Card";
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NPR NpDc Arch. Coupon";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Coupon Type"; "Coupon Type")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
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
                RunObject = Page "NPR NpDc Arch.Coupon Entries";
                RunPageLink = "Arch. Coupon No." = FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea = All;
            }
        }
    }
}

