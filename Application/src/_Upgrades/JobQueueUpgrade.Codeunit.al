codeunit 6014489 "NPR Job Queue Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    var
        JobQueueInstall: Codeunit "NPR Job Queue Install";
    begin
        JobQueueInstall.AddJobQueues();
        RemoveObsoleteEntraApp();
        RecreateMonitoredJobQueueEntries();
    end;

    local procedure RemoveObsoleteEntraApp()
    var
        AADApplication: Record "AAD Application";
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
        User: Record User;
        UserID: Guid;
    begin
        UpgradeStep := 'RemoveObsoleteEntraApp';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Job Queue Upgrade', UpgradeStep);

        JobQueueRefreshSetup.GetSetup();
        if JobQueueRefreshSetup."Use External JQ Refresher" then begin
            JobQueueRefreshSetup.Validate("Use External JQ Refresher", false);
            JobQueueRefreshSetup.Modify();
        end;

        if AADApplication.Get('bdf6bb95-9dad-4504-91ab-8404427f4043') then begin
            UserID := AADApplication."User ID";
            AADApplication.Delete();
            if User.Get(UserID) then
                User.Delete();
        end;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure RecreateMonitoredJobQueueEntries()
    var
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
    begin
        UpgradeStep := 'RecreateMonitoredJobQueueEntries';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Job Queue Upgrade', UpgradeStep);

        MonitoredJobQueueMgt.RecreateMonitoredJobQueueEntries();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
