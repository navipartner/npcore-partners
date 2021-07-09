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
                    Style = Unfavorable;
                    StyleExpr = FailedItemTransExists;
                }
                field("Failed G/L Posting Trans."; Rec."Failed G/L Posting Trans.")
                {
                    ApplicationArea = All;
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
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies Reconciliation EFT Errors in last 30 days';
                }
                field("Unfinished EFT Requests"; "Unfinished EFT Requests")
                {
                    Caption = 'Unfinished EFT Requests';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies Unfinished EFT Requests in last 30 days';
                }
                field("EFT Req. with unknown result"; "EFT Req. with unknown result")
                {
                    Caption = 'EFT Requests with unknown result';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the EFT Requests with unknown result in last 30 days';
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
        FailedItemTransExists := "Failed Item Transaction." > 0;
        FailedGLPostTransExists := "Failed G/L Posting Trans." > 0;
    end;
}