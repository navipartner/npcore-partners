page 6151260 "NPR POS Entry Cue"
{
    PageType = CardPart;
    SourceTable = "NPR POS Entry Cue.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup("POS Entry Unposted Posting")
            {
                Caption = 'Unposted postings';
                field("Unposted Item Trans."; Rec."Unposted Item Trans.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unposted Item Trans. field';
                }
                field("Unposted G/L Trans."; Rec."Unposted G/L Trans.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unposted G/L Trans. field';
                }
            }
            cuegroup("POS Entry Failed Posting")
            {
                Caption = 'Failed postings';
                field("Failed Item Transaction."; Rec."Failed Item Transaction.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Failed Item Transaction. field';
                }
                field("Failed G/L Posting Trans."; Rec."Failed G/L Posting Trans.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Failed G/L Posting Trans. field';
                }
            }

            cuegroup("Active Discounts, Coupons & Vouchers")
            {
                field("Campaign Discount"; Rec."Campaign Discount List")
                {
                    Caption = 'Campaign Discount';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NPR Campaign Discount List";
                    ToolTip = 'Specifies the value of the Campaign Discount field';

                }
                field("Mix Discount"; Rec."Mix Discount List")
                {
                    Caption = 'Mix Discount';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NPR Mixed Discount List";
                    ToolTip = 'Specifies the value of the Mix Discount field';
                }
                field(Voucher; Rec."Voucher List")
                {
                    Caption = 'Voucher';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NPR NpRv Vouchers";
                    ToolTip = 'Specifies the value of the Voucher field';
                }
                field(Coupon; Rec."Coupon List")

                {
                    Caption = 'Coupon';
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "NPR NpDc Coupons";
                    ToolTip = 'Specifies the value of the Coupon field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;
}

