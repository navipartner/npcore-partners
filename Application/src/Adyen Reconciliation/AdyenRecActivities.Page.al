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

    trigger OnOpenPage()
    var
        AdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integrat.";
        AdyenLocalIntegration: Codeunit "NPR EFT Adyen Local Integrat.";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        FilterPGCodes: Text;
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
            Commit();
        end;
        Rec.SetFilter("EFT Tr. Date Filter", '<=%1', CreateDateTime(CalcDate('<-4D>', Today()), DT2Time(CurrentDateTime())));
        Rec.SetFilter("EC Payment Date Filter", '<=%1', (CalcDate('<-4D>', Today())));
        Rec.SetFilter("EFT Tr. Integr. Type Filter", '%1|%2', AdyenCloudIntegration.IntegrationType(), AdyenLocalIntegration.IntegrationType());

        PaymentGateway.Reset();
        PaymentGateway.SetRange("Integration Type", Enum::"NPR PG Integrations"::Adyen);
        if PaymentGateway.FindSet() then begin
            repeat
                FilterPGCodes += PaymentGateway.Code + '|';
            until PaymentGateway.Next() = 0;
            if StrLen(FilterPGCodes) > 0 then
                FilterPGCodes := FilterPGCodes.TrimEnd('|');
            Rec.SetFilter("EC PG Filter", FilterPGCodes);
            CalculateOutstandingECPaymentLines();
        end;

        CalculateCueFieldValues();
    end;

    procedure CalculateCueFieldValues()
    begin
        Rec.CalcFields("Unposted Documents", "Outstanding EFT Tr. Requests");
    end;

    procedure CalculateOutstandingECPaymentLines()
    begin
        Rec.CalcFields("Outstanding EC Payment Lines");
    end;
}
