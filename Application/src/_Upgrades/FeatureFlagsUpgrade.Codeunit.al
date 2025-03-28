codeunit 6151517 "NPR Feature Flags Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        FeatureFlagsInstall: Codeunit "NPR Feature Flags Install";
    begin
        CleanAndRecreateGetFeatureFlagJobQueueEntry();
        PrepareFeatureFlags();
        FeatureFlagsInstall.PrepareStandardFeatureFlags();  //MS standard feature flag handling
    end;

    local procedure PrepareFeatureFlags()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Feature Flags Upgrade", 'PrepareFeatureFlags')) then
            exit;
        FeatureFlagsManagement.InitFeatureFlagSetup();
        FeatureFlagsManagement.ScheduleGetFeatureFlagsIntegration();
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Feature Flags Upgrade", 'PrepareFeatureFlags'));
    end;

    local procedure CleanAndRecreateGetFeatureFlagJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        TempCompany: Record Company temporary;
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Feature Flags Upgrade", 'CleanAndRecreateGetFeatureFlagJobQueueEntry')) then
            exit;

        FeatureFlagsManagement.GetMostUsedCompany(TempCompany);

        if (TempCompany.Name <> CompanyName) then begin
            if FeatureFlagsManagement.GetFeatureFlagsJobQueueEntry(JobQueueEntry, '') then begin
                JobQueueEntry.Delete();
                JobQueueEntry.CancelTask();
            end;
            exit;
        end;

        if not FeatureFlagsManagement.CreateGetFeatureFlagsJobQueueEntry(JobQueueEntry) then
            exit;

        JobQueueManagement.StartJobQueueEntry(JobQueueEntry);

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Feature Flags Upgrade", 'CleanAndRecreateGetFeatureFlagJobQueueEntry'));
    end;
}