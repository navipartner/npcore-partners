codeunit 6151040 "NPR CMJobQueueSetup"
{
    Access = Internal;

    internal procedure EnsureJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        DescriptionLbl: Label 'OTA Channel Manager Job Queue Runner', Locked = true;
        CreatedMsg: Label 'Job Queue Entry for the OTA Channel Manager Runner has been created and started.';
        ExistsMsg: Label 'A Job Queue Entry for the OTA Channel Manager Runner already exists.';
    begin
        if (JobQueueEntryExists()) then begin
            Message(ExistsMsg);
            exit;
        end;

        // Restart-on-error: 30-second delay, no email notification.
        JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 30, '');

        if (JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR CMJobQueueRunner",
            '',
            DescriptionLbl,
            CurrentDateTime(),
            1,
            '',
            JobQueueEntry)) then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);

        Message(CreatedMsg);
    end;

    internal procedure JobQueueEntryExists(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetCurrentKey("Object Type to Run", "Object ID to Run");
        JobQueueEntry.SetFilter("Object Type to Run", '=%1', JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter("Object ID to Run", '=%1', Codeunit::"NPR CMJobQueueRunner");
        exit(not JobQueueEntry.IsEmpty());
    end;

    internal procedure ShowMissingJobQueueEntryNotification()
    var
        Notif: Notification;
        Msg: Label 'No Job Queue Entry exists for the OTA Channel Manager Runner. Submitted orders will not be processed automatically until one is created.';
        ActionLbl: Label 'Create Job Queue Entry';
    begin
        if (JobQueueEntryExists()) then
            exit;

        Notif.Message := Msg;
        Notif.AddAction(ActionLbl, Codeunit::"NPR CMJobQueueSetup", 'CreateJobQueueEntryFromNotification');
        Notif.Send();
    end;

    internal procedure CreateJobQueueEntryFromNotification(NotificationFromAction: Notification)
    begin
        EnsureJobQueueEntry();
    end;
}
