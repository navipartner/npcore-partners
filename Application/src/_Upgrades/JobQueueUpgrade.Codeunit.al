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
        UpdateRefresherUserAssignment();
        UpdateRefresherUserSettings();
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

    local procedure UpdateRefresherUserAssignment()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        UpgradeStep := 'UpdateRefresherUserAssignment';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Job Queue Upgrade', UpgradeStep);

        if JQRefreshSetup.Get() and (JQRefreshSetup."Default Refresher User" <> '') then begin
            JQRefreshSetup."Default Refresher User Name" := CopyStr(JQRefreshSetup."Default Refresher User", 1, MaxStrLen(JQRefreshSetup."Default Refresher User Name"));
            JQRefreshSetup.Modify();
        end;

        if MonitoredJQEntry.FindSet(true) then
            repeat
                if MonitoredJQEntry."NPR Entra App User Name" <> '' then begin
                    MonitoredJQEntry."JQ Runner User Name" := CopyStr(MonitoredJQEntry."NPR Entra App User Name", 1, MaxStrLen(MonitoredJQEntry."JQ Runner User Name"));
                    MonitoredJQEntry.Modify();
                end;
            until MonitoredJQEntry.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateRefresherUserSettings()
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
    begin
        UpgradeStep := 'UpdateRefresherUserSettings';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Job Queue Upgrade', UpgradeStep);

        if JQRefreshSetup.Get() then
            JQRefreshSetup.UpdateRefresherUsers();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
