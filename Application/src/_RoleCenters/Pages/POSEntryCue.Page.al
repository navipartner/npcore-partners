page 6151260 "NPR POS Entry Cue"
{
    PageType = CardPart;
    SourceTable = "NPR POS Entry Cue.";
    UsageCategory = None;
    Caption = 'POS Entry Cue';

    layout
    {
        area(content)
        {
            cuegroup("POS Entry Unposted Posting")
            {
                Caption = 'Unposted postings';
                field("Unposted Item Trans."; Rec."Unposted Item Trans.")
                {

                    ToolTip = 'Specifies the value of the Unposted Item Trans. field';
                    ApplicationArea = NPRRetail;
                }
                field("Unposted G/L Trans."; Rec."Unposted G/L Trans.")
                {

                    ToolTip = 'Specifies the value of the Unposted G/L Trans. field';
                    ApplicationArea = NPRRetail;
                }
            }
            cuegroup("POS Entry Failed Posting")
            {
                Caption = 'Failed postings';
                field("Failed Item Transaction."; Rec."Failed Item Transaction.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Failed Item Transaction. field';
                    Style = Unfavorable;
                    StyleExpr = FailedItemTransExists;
                }
                field("Failed G/L Posting Trans."; Rec."Failed G/L Posting Trans.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Failed G/L Posting Trans. field';
                    Style = Unfavorable;
                    StyleExpr = FailedGLPostTransExists;
                }
            }
            cuegroup("EFT Errors")
            {
                field("EFT Reconciliation Errors"; Rec."EFT Reconciliation Errors")
                {
                    Caption = 'EFT Reconciliation Errors';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies Reconciliation EFT Errors in last 30 days';
                }
                field("Unfinished EFT Requests"; Rec."Unfinished EFT Requests")
                {
                    Caption = 'Unfinished EFT Requests';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies Unfinished EFT Requests in last 30 days';
                }
                field("EFT Req. with Unknown Result"; Rec."EFT Req. with Unknown Result")
                {
                    Caption = 'EFT Requests with Unknown Result';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the EFT Requests with unknown result in last 30 days';
                }
            }
            cuegroup("Active Discounts, Coupons & Vouchers")
            {
                field("Campaign Discount"; Rec."Campaign Discount List")
                {
                    Caption = 'Campaign Discount';

                    DrillDownPageID = "NPR Campaign Discount List";
                    ToolTip = 'Specifies the value of the Campaign Discount field';
                    ApplicationArea = NPRRetail;

                }
                field("Mix Discount"; Rec."Mix Discount List")
                {
                    Caption = 'Mix Discount';

                    DrillDownPageID = "NPR Mixed Discount List";
                    ToolTip = 'Specifies the value of the Mix Discount field';
                    ApplicationArea = NPRRetail;
                }
            }

        }
    }

    var
        FailedItemTransExists: Boolean;
        FailedGLPostTransExists: Boolean;

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        Rec.SetRange("EFT Errors Date Filter", CalcDate('<-30D>'), Today());
    end;

    trigger OnAfterGetRecord()
    begin
        FailedItemTransExists := Rec."Failed Item Transaction." > 0;
        FailedGLPostTransExists := Rec."Failed G/L Posting Trans." > 0;
    end;
}