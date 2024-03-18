codeunit 6184790 "NPR Shipping Provider Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeShippingProviderCodePackageShippingAgent();
    end;

    local procedure UpgradeShippingProviderCodePackageShippingAgent()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagDefinitions: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Shipping Provider Upgrade', 'UpgradeShippingProviderCodePackageShippingAgent');

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR Shipping Provider Upgrade", 'UpgradeShippingProviderCodePackageShippingAgent')) then begin
            UpdateShippingProviderCodePackageShippingAgent();
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetUpgradeTag(Codeunit::"NPR Shipping Provider Upgrade", 'UpgradeShippingProviderCodePackageShippingAgent'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateShippingProviderCodePackageShippingAgent()
    var
        PackageShippingAgent: Record "NPR Package Shipping Agent";
    begin
        PackageShippingAgent.Reset();
        PackageShippingAgent.SetRange("Shipping Provider Code", '');
        if not PackageShippingAgent.FindSet(true) then
            exit;

        repeat
            PackageShippingAgent."Shipping Provider Code" := PackageShippingAgent.Code;
            PackageShippingAgent.Modify();
        until PackageShippingAgent.Next() = 0;
    end;
}
