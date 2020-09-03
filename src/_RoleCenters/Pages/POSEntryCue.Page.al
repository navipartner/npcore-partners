page 6151260 "NPR POS Entry Cue"
{
    PageType = CardPart;
    SourceTable = "NPR POS Entry Cue.";


    layout
    {
        area(content)
        {
            cuegroup("POS ENTRY POSTING")
            {
                ShowCaption = false;
                field("Failed G/L Posting Trans."; "Failed G/L Posting Trans.")
                {
                    ApplicationArea = All;
                }
                field("Unposted Item Trans."; "Unposted Item Trans.")
                {
                    ApplicationArea = All;
                }
                field("Unposted G/L Trans."; "Unposted G/L Trans.")
                {
                    ApplicationArea = All;
                }
                field("Failed Item Transaction."; "Failed Item Transaction.")
                {
                    ApplicationArea = All;
                }
            }

            cuegroup("Active Discounts, Coupons & Vouchers")
            {
                field("Campaign Discount"; "Campaign Discount List")
                {
                    Caption = 'Campaign Discount';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NPR Campaign Discount List";

                }
                field("Mix Discount"; "Mix Discount List")
                {
                    Caption = 'Mix Discount';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NPR Mixed Discount List";
                }
                field(Voucher; "Voucher List")
                {
                    Caption = 'Voucher';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NPR NpRv Vouchers";
                }
                field(Coupon; "Coupon List")

                {
                    Caption = 'Coupon';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NPR NpDc Coupons";
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}

