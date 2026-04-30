#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6150963 "NPR Digital Notification Send"
{
    Access = Internal;

    trigger OnRun()
    begin
        SendNotifications();
    end;

    local procedure SendNotifications()
    var
        NotifEntry: Record "NPR Digital Notification Entry";
    begin
        FilterNotificationsToSend(NotifEntry);

        if NotifEntry.FindSet() then begin
            repeat
                SendNotification(NotifEntry);
            until NotifEntry.Next() = 0;
            Commit();
        end;
    end;

    internal procedure SendNotification(var NotifEntry: Record "NPR Digital Notification Entry"): Boolean
    var
        AlreadySentIgnored: Boolean;
    begin
        exit(SendNotification(NotifEntry, AlreadySentIgnored));
    end;

    internal procedure SendNotification(var NotifEntry: Record "NPR Digital Notification Entry"; var AlreadySent: Boolean): Boolean
    var
        NotifEntryLocked: Record "NPR Digital Notification Entry";
        NPEmail: Codeunit "NPR NP Email";
        TrySendResult: Boolean;
        LastErrorText: Text;
    begin
        AlreadySent := false;
        NotifEntryLocked.ReadIsolation := IsolationLevel::UpdLock;
        if not NotifEntryLocked.Get(NotifEntry."Entry No.") then
            exit(false);
        if NotifEntryLocked.Sent then begin
            AlreadySent := true;
            NotifEntry := NotifEntryLocked;
            exit(true);
        end;

        ClearLastError();
        TrySendResult := NPEmail.TrySendEmail(
            NotifEntryLocked."Email Template Id",
            NotifEntryLocked,
            NotifEntryLocked."Recipient E-mail",
            NotifEntryLocked."Language Code");
        if not TrySendResult then
            LastErrorText := GetLastErrorText();

        // Re-acquire lock + re-read fresh DB state so the final Modify is serialized with any concurrent worker.
        NotifEntryLocked.ReadIsolation := IsolationLevel::UpdLock;
        NotifEntryLocked.Get(NotifEntryLocked."Entry No.");
        NotifEntryLocked."Attempt Count" += 1;
        if TrySendResult then begin
            NotifEntryLocked.Sent := true;
            NotifEntryLocked."Sent Date-Time" := CurrentDateTime;
            NotifEntryLocked."Error Message" := '';
        end else
            NotifEntryLocked."Error Message" := CopyStr(LastErrorText, 1, MaxStrLen(NotifEntryLocked."Error Message"));
        NotifEntryLocked.Modify();
        Commit();
        NotifEntry := NotifEntryLocked;
        exit(TrySendResult);
    end;

    internal procedure SetJobQueueEntry(Create: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JobQueueDescriptionLbl: Label 'Digital Order Notifications Processor';
    begin
        if Create then begin
            JobQueueMgt.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR Digital Notification Send",
                '',
                JobQueueDescriptionLbl,
                CurrentDateTime(),
                1, // Every 1 minute
                '',
                JobQueueEntry);
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
        end else
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR Digital Notification Send");
    end;

    internal procedure ResetAttemptCount(var NotifEntry: Record "NPR Digital Notification Entry")
    begin
        NotifEntry."Attempt Count" := 0;
        NotifEntry."Error Message" := '';
        NotifEntry.Sent := false;
        NotifEntry.Modify();
    end;

    internal procedure FilterNotificationsToSend(var NotifEntry: Record "NPR Digital Notification Entry")
    var
        DigitalNotifSetup: Record "NPR Digital Notification Setup";
    begin
        NotifEntry.SetRange(Sent, false);
        NotifEntry.SetFilter("Document Type", '<>%1', "NPR Digital Document Type"::"Ecom Sales Document");

        if not DigitalNotifSetup.Get() then
            exit;

        if DigitalNotifSetup."Max Attempts" > 0 then
            NotifEntry.SetFilter("Attempt Count", '<%1', DigitalNotifSetup."Max Attempts");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntry()
    var
        DigitalNotifSetup: Record "NPR Digital Notification Setup";
    begin
        if not DigitalNotifSetup.Get() then
            exit;

        if not DigitalNotifSetup.Enabled then
            exit;

        SetJobQueueEntry(true);
    end;
}
#endif
