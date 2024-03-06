codeunit 6060092 "NPR UPG Standard Exch. Rate"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpdateStandardExchangeRateForBalancing();
    end;

    local procedure UpdateStandardExchangeRateForBalancing()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Standard Exch. Rate', 'UpdateStandardExchangeRateForBalancing');
        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateStandardExchangeRateForBalancing')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        SetStandardExchangeRateForBalancingFalse();
        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateStandardExchangeRateForBalancing'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure SetStandardExchangeRateForBalancingFalse()
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        POSPaymentMethod.Reset();
        POSPaymentMethod.SetRange("Use Stand. Exc. Rate for Bal.", true);
        if not POSPaymentMethod.IsEmpty() then
            POSPaymentMethod.ModifyAll("Use Stand. Exc. Rate for Bal.", false);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG Standard Exch. Rate");
    end;
}
