codeunit 6248461 "NPR UPG Adyen Warning Days"
{
    Access = Internal;
    Subtype = Upgrade;
    trigger OnUpgradePerCompany()
    begin
        UpdateAdyenSetup();
    end;

    local procedure UpdateAdyenSetup()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Adyen Warning Days', 'UpdateAdyenSetup');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateAdyenSetup')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdateAdyenPostingWarningDays();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateAdyenSetup'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG Adyen Warning Days");
    end;

    local procedure UpdateAdyenPostingWarningDays()
    var
        MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
        PGAdyenSetup: Record "NPR PG Adyen Setup";
    begin
        PGAdyenSetup.SetLoadFields("Authorization Expiry Formula");

        MagentoPaymentGateway.SetLoadFields(Code);
        MagentoPaymentGateway.SetRange("Integration Type", MagentoPaymentGateway."Integration Type"::Adyen);
        if MagentoPaymentGateway.FindSet() then
            repeat
                if PGAdyenSetup.Get(MagentoPaymentGateway.Code) then
                    SetPaymentPostingWarningDays(PGAdyenSetup);
            until MagentoPaymentGateway.Next() = 0;
    end;

    local procedure SetPaymentPostingWarningDays(var AdyenSetup: Record "NPR PG Adyen Setup")
    var
        AdyenSetupInit: Record "NPR PG Adyen Setup";
    begin
        AdyenSetupInit.Init();

        AdyenSetup."Authorization Expiry Formula" := AdyenSetupInit."Authorization Expiry Formula";
        AdyenSetup.Modify();
    end;
}
