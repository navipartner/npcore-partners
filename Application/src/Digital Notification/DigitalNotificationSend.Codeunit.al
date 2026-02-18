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
        NotifEntry2: Record "NPR Digital Notification Entry";
    begin
        FilterNotificationsToSend(NotifEntry);

        if NotifEntry.FindSet(true) then begin
            repeat
                NotifEntry2 := NotifEntry;
                SendNotification(NotifEntry2);
            until NotifEntry.Next() = 0;

            // inside SendNotification -> TrySendEmail commits at the start of each iteration, which saves the previous iteration's Modify().
            // This final Commit() is needed to save the last iteration's changes (no next iteration to commit it).
            Commit();
        end;
    end;

    internal procedure SendNotification(var NotifEntry: Record "NPR Digital Notification Entry"): Boolean
    var
        NPEmail: Codeunit "NPR NP Email";
    begin
        NotifEntry."Attempt Count" += 1;
        ClearLastError();
        if NPEmail.TrySendEmail(
            NotifEntry."Email Template Id",
            NotifEntry,
            NotifEntry."Recipient E-mail",
            NotifEntry."Language Code"
        ) then begin
            NotifEntry.Sent := true;
            NotifEntry."Sent Date-Time" := CurrentDateTime;
            NotifEntry."Error Message" := '';
            NotifEntry.Modify();
            exit(true);
        end else begin
            NotifEntry."Error Message" := CopyStr(GetLastErrorText(), 1, 250);
            NotifEntry.Modify();
            exit(false);
        end;
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

        if not DigitalNotifSetup.Get() then
            exit;

        if DigitalNotifSetup."Max Attempts" > 0 then
            NotifEntry.SetFilter("Attempt Count", '<%1', DigitalNotifSetup."Max Attempts");
    end;

    internal procedure IsJobQueueActive(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Digital Notification Send");
        JobQueueEntry.SetFilter(Status, '%1|%2', JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process");
        exit(not JobQueueEntry.IsEmpty);
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
