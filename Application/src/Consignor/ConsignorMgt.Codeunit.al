codeunit 6184601 "NPR Consignor Mgt."
{
    // NPR5.55/MHA /20200506  CASE 403383 Object created - schedules Job Queue Entry for Consignor Task Processing


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6184601, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertConsignorEntry(var Rec: Record "NPR Consignor Entry"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if Rec.IsTemporary then
            exit;

        ScheduleJobQueueEntries();
    end;

    local procedure ScheduleJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        NpXmlTemplate: Record "NPR NpXml Template";
    begin
        if not JobQueueEntry.WritePermission then
            exit;

        NpXmlTemplate.SetRange("Table No.", DATABASE::"NPR Consignor Entry");
        NpXmlTemplate.SetRange("Transaction Task", true);
        NpXmlTemplate.SetFilter("Task Processor Code", '<>%1', '');
        if not NpXmlTemplate.FindFirst then
            exit;

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"NPR Nc Task List Processing");
        JobQueueEntry.SetFilter("Parameter String", '*processor?' + NpXmlTemplate."Task Processor Code" + '*');
        if JobQueueEntry.IsEmpty then
            exit;

        JobQueueEntry.FindSet;
        repeat
            ScheduleJobQueueEntry(JobQueueEntry);
        until JobQueueEntry.Next = 0;
    end;

    local procedure ScheduleJobQueueEntry(JobQueueEntry: Record "Job Queue Entry")
    begin
        if (JobQueueEntry."Earliest Start Date/Time" <= CurrentDateTime) and
          (JobQueueEntry.Status in [JobQueueEntry.Status::"In Process", JobQueueEntry.Status::Ready])
        then
            exit;

        JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");

        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime + 1000;
        JobQueueEntry.Modify(true);
        JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
    end;
}

