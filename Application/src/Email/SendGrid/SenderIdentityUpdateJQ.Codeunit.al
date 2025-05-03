#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248273 "NPR Sender Identity Update JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Feature: Codeunit "NPR NP Email Feature";
        NPEmailAccount: Record "NPR NP Email Account";
        Client: Codeunit "NPR SendGrid Client";
    begin
        // Use feature and the setup to figure out if the module is enabled
        if (not Feature.IsFeatureEnabled()) or (NPEmailAccount.IsEmpty()) then
            exit;

        Client.UpdateLocalSenderIdentities();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", OnAfterValidateEvent, "Object ID to Run", true, true)]
    local procedure SetJobQueueEntryName(var Rec: Record "Job Queue Entry")
    begin
        if (Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit) then
            exit;
        if (Rec."Object ID to Run" <> Codeunit::"NPR Sender Identity Update JQ") then
            exit;

        Rec.Description := CopyStr(GetJobDescription(), 1, MaxStrLen(Rec.Description));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', true, true)]
    local procedure OnRefreshNPRJobQueueList()
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobQueueEntry: Record "Job Queue Entry";
        Feature: Codeunit "NPR NP Email Feature";
    begin
        if (not Feature.IsFeatureEnabled()) then
            exit;

        if JobQueueManagement.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR Sender Identity Update JQ",
                '',
                GetJobDescription(),
                CurrentDateTime(),
                5,
                'NP EMAIL',
                JobQueueEntry
        ) then
            JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnCheckIfIsNPRecurringJob, '', true, true)]
    local procedure OnCheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" = Codeunit::"NPR Sender Identity Update JQ")
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;

    local procedure GetJobDescription(): Text[250]
    var
        FetchLatestTemplatesLbl: Label 'Fetch NP Email Sender Identities', MaxLength = 250;
    begin
        exit(FetchLatestTemplatesLbl);
    end;
}
#endif