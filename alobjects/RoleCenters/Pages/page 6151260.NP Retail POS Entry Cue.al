page 6151260 "NP Retail POS Entry Cue"
{
    PageType = CardPart;
    SourceTable = "NP Retail POS Entry Cue.";


    layout
    {
        area(content)
        {
            cuegroup("POS ENTRY POSTING")
            {
                ShowCaption = false;
                field("Failed G/L Posting Trans."; "Failed G/L Posting Trans.")
                {
                }
                field("Unposted Item Trans."; "Unposted Item Trans.")
                {
                }
                field("Unposted G/L Trans."; "Unposted G/L Trans.")
                {
                }
                field("Failed Item Transaction."; "Failed Item Transaction.")
                {
                }
            }

            cuegroup("Active Discounts, Coupons & Vouchers")
            {
                field("Campaign Discount"; "Campaign Discount List")
                {
                    Caption = 'Campaign Discount';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Campaign Discount List";

                }
                field("Mix Discount"; "Mix Discount List")
                {
                    Caption = 'Mix Discount';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Mixed Discount List";
                }
                field(Voucher; "Voucher List")
                {
                    Caption = 'Voucher';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NpRv Vouchers";
                }
                field(Coupon; "Coupon List")

                {
                    Caption = 'Coupon';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NpDc Coupons";
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

