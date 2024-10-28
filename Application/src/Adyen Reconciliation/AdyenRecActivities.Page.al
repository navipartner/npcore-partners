page 6184535 "NPR Adyen Rec. Activities"
{
    Caption = 'NP Pay Reconciliation Activities';
    PageType = CardPart;
    SourceTable = "NPR Adyen Reconciliation Cue";
    Extensible = false;
    RefreshOnActivate = true;
    ShowFilter = false;
    Editable = false;
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteTag = '2024-10-25';
    ObsoleteReason = 'Replaced with NPR POS Entry Cue. "Reconc. Batches with Errors"';

    layout
    {
        area(content)
        {
            cuegroup("Adyen Reconciliation")
            {
                Caption = 'NP Pay Reconciliation';
                field("Unposted Documents"; Rec."Unposted Documents")
                {
                    Caption = 'Unposted Documents';
                    ApplicationArea = NPRRetail;
                    StyleExpr = 'Unfavorable';
                    DrillDownPageID = "NPR Adyen Reconciliation List";
                    ToolTip = 'Specifies NP Pay Reconciliation Documents that have not yet been posted.';
                }
                field("Outstanding EFT Tr. Requests"; Rec."Outstanding EFT Tr. Requests")
                {
                    Caption = 'Outstanding EFT Transaction Requests';
                    ApplicationArea = NPRRetail;
                    StyleExpr = 'Unfavorable';
                    DrillDownPageId = "NPR EFT Transaction Requests";
                    ToolTip = 'Specifies EFT Transaction Request Entries that are yet to be Reconciled.';
                }
                field("Outstanding EC Payment Lines"; Rec."Outstanding EC Payment Lines")
                {
                    Caption = 'Outstanding E-commerce Payment Lines';
                    ApplicationArea = NPRRetail;
                    StyleExpr = 'Unfavorable';
                    DrillDownPageId = "NPR Magento Payment Line List";
                    ToolTip = 'Specifies E-commerce Payment Lines that are yet to be Reconciled.';
                }
            }
        }
    }

    [Obsolete('Cue replaced with NPR POS Entry Cue. "Reconc. Batches with Errors"', '2024-10-25')]
    procedure CalculateCueFieldValues()
    begin
    end;

    [Obsolete('Cue replaced with NPR POS Entry Cue. "Reconc. Batches with Errors"', '2024-10-25')]
    procedure CalculateOutstandingECPaymentLines()
    begin
    end;
}
