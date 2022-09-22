codeunit 85088 "NPR Library - Event"
{
    procedure CreateEvent(var Job: Record Job)
    var
        LibraryJob: Codeunit "Library - Job";
    begin
        LibraryJob.CreateJob(Job);
        Job.Validate("NPR Event", true);
        Job.Modify(true);
    end;

    procedure CreateEvent(var Job: Record Job; var JobTask: Record "Job Task")
    var
        LibraryJob: Codeunit "Library - Job";
    begin
        CreateEvent(Job);
        LibraryJob.CreateJobTask(Job, JobTask);
    end;

    procedure CreateEvent(JobTaskNo: Code[20]; var Job: Record Job; var JobTask: Record "Job Task")
    begin
        CreateEvent(Job);
        JobTask.Init();
        JobTask.Validate("Job No.", Job."No.");
        JobTask.Validate("Job Task No.", JobTaskNo);
        JobTask.Insert(true);

        JobTask.Validate("Job Task Type", JobTask."Job Task Type"::Posting);
        JobTask.Modify(true);
    end;

    procedure GetRandomOption(TableNo: Integer; FieldNo: Integer): Integer
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        exit(Random(LibraryUtility.GetMaxFieldOptionIndex(TableNo, FieldNo) - 1));
    end;

    procedure GetRandomOption(TableNo: Integer; FieldNo: Integer; ExcludingValue: Integer): Integer
    var
        RandomOption: Integer;
    begin
        repeat
            RandomOption := GetRandomOption(TableNo, FieldNo);
        until RandomOption <> ExcludingValue;
        exit(RandomOption);
    end;
}