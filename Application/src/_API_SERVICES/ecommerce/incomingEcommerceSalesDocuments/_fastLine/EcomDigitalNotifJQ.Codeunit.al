#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6151116 "NPR EcomDigitalNotifJQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        Process(Rec);
    end;

    local procedure Process(var JobQueueEntry: Record "Job Queue Entry")
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        StartTime: DateTime;
        MaxDuration: Duration;
    begin
        StartTime := CurrentDateTime;
        MaxDuration := GetDefaultDuration();
        repeat
            if EcomJobManagement.ShouldSoftExit(JobQueueEntry.ID) then
                exit;
            ProcessRecords(JobQueueEntry);
            Commit();
            Sleep(1000);
        until (not JobQueueEntry."Recurring Job") or EcomJobManagement.DurationLimitReached(StartTime, MaxDuration);
    end;

    local procedure GetDefaultDuration(): Duration
    var
        Timeout: Duration;
    begin
        Timeout := 60 * 60 * 1000 * 6; // 6H
        exit(Timeout);
    end;

    local procedure ProcessRecords(var JobQueueEntry: Record "Job Queue Entry")
    var
        DigitalNotifSetup: Record "NPR Digital Notification Setup";
        DigitalNotifEntry: Record "NPR Digital Notification Entry";
        DigitalNotificationSend: Codeunit "NPR Digital Notification Send";
        DigitalOrderNotifMgt: Codeunit "NPR Digital Order Notif. Mgt.";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        DigitalAssetsEnabled, OrderConfirmationEnabled : Boolean;
        BucketFilter: Text;
    begin
        if not DigitalOrderNotifMgt.ValidateAnyEcomNotifEnabled(DigitalNotifSetup) then
            exit;

        // Mirror the per-type checks ValidateAnyEcomNotifEnabled uses internally.
        DigitalAssetsEnabled := DigitalNotifSetup.Enabled and (DigitalNotifSetup."Email Template Id Order" <> '');
        OrderConfirmationEnabled := DigitalNotifSetup."Send Ecom Order Confirmation" and (DigitalNotifSetup."Ecom Order Confirm Template Id" <> '');

        JQParamStrMgt.Parse(JobQueueEntry."Parameter String");
        if JQParamStrMgt.ContainsParam(EcomJobManagement.ParamBucketFilter()) then
            BucketFilter := JQParamStrMgt.GetParamValueAsText(EcomJobManagement.ParamBucketFilter());

        DigitalNotifEntry.SetRange("Document Type", "NPR Digital Document Type"::"Ecom Sales Document");
        DigitalNotifEntry.SetRange(Sent, false);
        // Skip leftover entries of a notification type whose toggle is currently off. When both are
        // enabled, no Notification Type filter is applied.
        case true of
            DigitalAssetsEnabled and not OrderConfirmationEnabled:
                DigitalNotifEntry.SetRange("Notification Type", "NPR Dig. Notif. Type"::"Digital Assets");
            OrderConfirmationEnabled and not DigitalAssetsEnabled:
                DigitalNotifEntry.SetRange("Notification Type", "NPR Dig. Notif. Type"::"Order Confirmation");
        end;
        if DigitalNotifSetup."Max Attempts" > 0 then
            DigitalNotifEntry.SetFilter("Attempt Count", '<%1', DigitalNotifSetup."Max Attempts");
        if BucketFilter <> '' then
            DigitalNotifEntry.SetFilter("Bucket Id", BucketFilter);

        if not DigitalNotifEntry.FindSet() then
            exit;

        repeat
            DigitalNotificationSend.SendNotification(DigitalNotifEntry);
            Commit();
        until DigitalNotifEntry.Next() = 0;
    end;

    internal procedure GetJQDescription(): Text
    var
        JobDescriptionLbl: Label 'Send Digital Notifications for Ecommerce Documents';
    begin
        exit(JobDescriptionLbl);
    end;

    internal procedure GetCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR EcomDigitalNotifJQ");
    end;

    internal procedure ScheduleJobQueue(var JobQueueEntry: Record "Job Queue Entry")
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
    begin
        EcomJobManagement.ScheduleJobQueue(GetCodeunitId(), GetJQDescription(), JobQueueEntry);
    end;

    internal procedure ScheduleJobQueueWithConfirmation()
    var
        JobQueueEntry: Record "Job Queue Entry";
        ConfirmManagement: Codeunit "Confirm Management";
        ScheduleJobQueueConfirmLbl: Label 'Are you sure you want to configure the job queue for ecommerce digital notification processing?';
    begin
        if not ConfirmManagement.GetResponseOrDefault(ScheduleJobQueueConfirmLbl, true) then
            exit;

        ScheduleJobQueue(JobQueueEntry);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry")
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> GetCodeunitId() then
            exit;
        if Rec.Description = '' then
            Rec.Description := CopyStr(GetJQDescription(), 1, MaxStrLen(Rec.Description));
        if Rec."Parameter String" = '' then
            Rec."Parameter String" := CopyStr((EcomJobManagement.ParamBucketFilter() + '='), 1, MaxStrLen(Rec."Parameter String"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeValidateCreateMissingCustomJQs, '', false, false)]
    local procedure SkipValidateCreateMissingCustomJQs(JobQueueEntry: Record "Job Queue Entry"; var SkipValidation: Boolean)
    begin
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and (JobQueueEntry."Object ID to Run" = GetCodeunitId()) then
            SkipValidation := true;
    end;
}
#endif
