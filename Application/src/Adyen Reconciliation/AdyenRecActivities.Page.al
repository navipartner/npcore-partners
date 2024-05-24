page 6184535 "NPR Adyen Rec. Activities"
{
    Caption = 'Adyen Rec. Activities';
    PageType = CardPart;
    SourceTable = "NPR Adyen Reconciliation Cue";
    Extensible = false;
    RefreshOnActivate = true;
    ShowFilter = false;
    Editable = false;
    UsageCategory = Documents;
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            cuegroup("Adyen Reconciliation")
            {
                Caption = 'Adyen Reconciliation';
                field("Unposted Documents"; Rec."Unposted Documents")
                {
                    Caption = 'Unposted Documents';
                    ApplicationArea = NPRRetail;
                    StyleExpr = 'Unfavorable';
                    DrillDownPageID = "NPR Adyen Reconciliation List";
                    ToolTip = 'Specifies Adyen Reconciliation Documents that have not yet been posted.';
                }
                field("Outstanding EFT Tr. Requests"; Rec."Outstanding EFT Tr. Requests")
                {
                    Caption = 'Outstanding EFT Transaction Requests';
                    ApplicationArea = NPRRetail;
                    StyleExpr = 'Unfavorable';
                    DrillDownPageId = "NPR EFT Transaction Requests";
                    ToolTip = 'Specifies EFT Transaction Request Entries that are yet to be Reconciled.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
            Commit();
        end;
        Rec.SetFilter("EFT Tr. Date Filter", '<=%1', CreateDateTime(CalcDate('<-4D>', Today()), DT2Time(CurrentDateTime())));
        CalculateCueFieldValues();
    end;

    procedure CalculateCueFieldValues()
    begin
        Rec.CalcFields("Unposted Documents", "Outstanding EFT Tr. Requests");
    end;
}
