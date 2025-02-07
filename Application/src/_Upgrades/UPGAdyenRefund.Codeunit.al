codeunit 6248240 "NPR UPG Adyen Refund"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        CreateAdyenRefundJobs();
    end;

    local procedure CreateAdyenRefundJobs()
    var
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
        MMSubsPaymentGateway: Record "NPR MM Subs. Payment Gateway";
        NpPaySetup: Record "NPR Adyen Setup";
        AdyenManagement: Codeunit "NPR Adyen Management";
        RefundEventFilter: Label 'REFUND', Locked = true;
        AdyenWebhookType: Enum "NPR Adyen Webhook Type";
    begin
        UpgradeStep := 'CreateAdyenRefundJobs';
        if HasUpgradeTag() then
            exit;

        if NpPaySetup.Get() then
            if NpPaySetup."Enable Reconciliation" and (NpPaySetup."Management API Key" <> '') then begin

                MMSubsPaymentGateway.SetRange("Integration Type", MMSubsPaymentGateway."Integration Type"::Adyen);
                MMSubsPaymentGateway.SetRange(Status, MMSubsPaymentGateway.Status::Enabled);
                if MMSubsPaymentGateway.FindFirst() then begin

                    SubsAdyenPGSetup.SetLoadFields("Merchant Name");
                    if SubsAdyenPGSetup.Get(MMSubsPaymentGateway.Code) then begin

                        AdyenManagement.EnsureAdyenWebhookSetup(RefundEventFilter, SubsAdyenPGSetup."Merchant Name", AdyenWebhookType::standard);
                        AdyenManagement.ScheduleRefundStatusJQ();
                    end;
                end;
            end;
        SetUpgradeTag();
    end;

    local procedure HasUpgradeTag(): Boolean
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Adyen Refund", UpgradeStep)) then
            exit(true);
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Adyen Refund', UpgradeStep);
    end;

    local procedure SetUpgradeTag()
    begin
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Adyen Refund", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}