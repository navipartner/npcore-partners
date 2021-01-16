page 6151260 "NPR POS Entry Cue"
{
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Failed G/L Posting Trans. field';
                }
                field("Unposted Item Trans."; "Unposted Item Trans.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unposted Item Trans. field';
                }
                field("Unposted G/L Trans."; "Unposted G/L Trans.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unposted G/L Trans. field';
                }
                field("Failed Item Transaction."; "Failed Item Transaction.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Failed Item Transaction. field';
                }
            }

            cuegroup("Active Discounts, Coupons & Vouchers")
            {
                field("Campaign Discount"; "Campaign Discount List")
                {
                    Caption = 'Campaign Discount';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NPR Campaign Discount List";
                    ToolTip = 'Specifies the value of the Campaign Discount field';

                }
                field("Mix Discount"; "Mix Discount List")
                {
                    Caption = 'Mix Discount';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NPR Mixed Discount List";
                    ToolTip = 'Specifies the value of the Mix Discount field';
                }
                field(Voucher; "Voucher List")
                {
                    Caption = 'Voucher';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NPR NpRv Vouchers";
                    ToolTip = 'Specifies the value of the Voucher field';
                }
                field(Coupon; "Coupon List")

                {
                    Caption = 'Coupon';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NPR NpDc Coupons";
                    ToolTip = 'Specifies the value of the Coupon field';
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

