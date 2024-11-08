codeunit 6150658 "NPR UPG POS Pay View Dimension"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeDimensionMandatoryTrueForListOption();
    end;

    local procedure UpgradeDimensionMandatoryTrueForListOption()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Pay View Dimension', 'SetDimensionMandatoryTrueForListOption');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SetDimensionMandatoryTrueForListOption')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        SetDimensionMandatoryTrueForListOption();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'SetDimensionMandatoryTrueForListOption'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure SetDimensionMandatoryTrueForListOption()
    var
        POSPaymViewEventSetup: Record "NPR POS Paym. View Event Setup";
    begin
        if not POSPaymViewEventSetup.Get() then
            exit;
        if not ((POSPaymViewEventSetup."Popup Mode" = POSPaymViewEventSetup."Popup Mode"::List) and (not POSPaymViewEventSetup."Dimension Mandatory on POS")) then
            exit;
        POSPaymViewEventSetup."Dimension Mandatory on POS" := true;
        POSPaymViewEventSetup.Modify();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POS Pay View Dimension");
    end;
}
