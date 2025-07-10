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
        UpdateJobQueueFieldsFromMonitoredEntry();
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

    local procedure UpdateJobQueueFieldsFromMonitoredEntry()
    var
        MonitoredJobQueueEntry: Record "NPR Monitored Job Queue Entry";
        xMonitoredJobQueueEntry: Record "NPR Monitored Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        UpgradeStep := 'UpdateJobQueueFieldsFromMonitoredEntry';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Job Queue Upgrade', UpgradeStep);

        if MonitoredJobQueueEntry.FindSet() then
            repeat
                if JobQueueEntry.Get(MonitoredJobQueueEntry."Job Queue Entry ID") then begin
                    xMonitoredJobQueueEntry := MonitoredJobQueueEntry;
                    MonitoredJobQueueEntry."Notif. Profile on Error" := JobQueueEntry."NPR Notif. Profile on Error";
                    MonitoredJobQueueEntry."Job Queue Category Code" := JobQueueEntry."Job Queue Category Code";
                    MonitoredJobQueueEntry.Description := JobQueueEntry.Description;
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
                    MonitoredJobQueueEntry."Priority Within Category" := JobQueueEntry."Priority Within Category";
#endif
                    if JobQueueEntry."Expiration Date/Time" <> 0DT then
                        MonitoredJobQueueEntry."Expiration Date/Time" := JobQueueEntry."Expiration Date/Time";
                    MonitoredJobQueueEntry."NPR Auto-Resched. after Error" := JobQueueEntry."NPR Auto-Resched. after Error";
                    MonitoredJobQueueEntry."NPR Auto-Resched. Delay (sec.)" := JobQueueEntry."NPR Auto-Resched. Delay (sec.)";
                    MonitoredJobQueueEntry."NPR Heartbeat URL" := JobQueueEntry."NPR Heartbeat URL";
                    MonitoredJobQueueEntry."Notify On Success" := JobQueueEntry."Notify On Success";
                    if Format(MonitoredJobQueueEntry) <> Format(xMonitoredJobQueueEntry) then
                        MonitoredJobQueueEntry.Modify();
                end;
            until MonitoredJobQueueEntry.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Job Queue Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
