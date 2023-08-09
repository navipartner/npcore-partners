codeunit 6059996 "NPR HL Schedule Send Tasks"
{
    Access = Internal;
    Permissions =
        tabledata "NPR Nc Task Setup" = rimd,
        tabledata "NPR Nc Task Processor" = rimd;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        ScheduleTaskProcessing(Rec);
    end;

    local procedure ScheduleTaskProcessing(var NcTask: Record "NPR Nc Task");
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JobQueueEntry: Record "Job Queue Entry";
        NoOfMinutesBetweenRuns: Integer;
    begin
        if NcTask.Processed then
            exit;

        if NcTask."Task Processor Code" = '' then begin
            NcTask."Task Processor Code" := GetHeyLoyaltyTaskProcessorCode();
            if NcTask."Entry No." <> 0 then
                NcTask.Modify();
        end;

        NoOfMinutesBetweenRuns := 10;

        JobQueueMgt.ScheduleNcTaskProcessing(JobQueueEntry, NcTask."Task Processor Code", true, '', NoOfMinutesBetweenRuns);
    end;

    procedure GetHeyLoyaltyTaskProcessorCode(): Code[20]
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        HeyLoyaltyTaskProcessorDescription: Label 'HeyLoyalty updates', MaxLength = 50;
    begin
        if not NcTaskProcessor.Get(HLIntegrationMgt.HeyLoyaltyCode()) then begin
            NcTaskProcessor.Init();
            NcTaskProcessor.Code := HLIntegrationMgt.HeyLoyaltyCode();
            NcTaskProcessor.Description := HeyLoyaltyTaskProcessorDescription;
            NcTaskProcessor.Insert(true);
        end;
        exit(NcTaskProcessor.Code);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Sync. Mgt.", 'OnBeforeProcessTask', '', true, false)]
    local procedure CreateTaskSetup(var Task: Record "NPR Nc Task")
    var
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
    begin
        if Task."Task Processor Code" <> HLIntegrationMgt.HeyLoyaltyCode() then
            exit;

        GetHeyLoyaltyTaskProcessorCode();  //Make sure HeyLoyality task processor is created
        if HLIntegrationMgt.IsEnabled("NPR HL Integration Area"::Members) then
            CreateTaskSetupEntry(Task."Task Processor Code", Database::"NPR HL HeyLoyalty Member");
    end;

    local procedure CreateTaskSetupEntry(TaskProcessorCode: Code[20]; TableId: Integer)
    var
        NcTaskSetup: Record "NPR Nc Task Setup";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
    begin
        NcTaskSetup.SetCurrentKey("Table No.");
        NcTaskSetup.SetRange("Table No.", TableId);
        NcTaskSetup.SetRange("Task Processor Code", TaskProcessorCode);
        if not NcTaskSetup.IsEmpty() then
            exit;

        NcTaskSetup.Init();
        NcTaskSetup."Entry No." := 0;
        NcTaskSetup."Task Processor Code" := TaskProcessorCode;
        NcTaskSetup."Table No." := TableId;
        case true of
            HLIntegrationMgt.IsIntegratedTable("NPR HL Integration Area"::Members, TableId),
            TableId = Database::"NPR HL HeyLoyalty Member":
                NcTaskSetup."Codeunit ID" := Codeunit::"NPR HL Send Members";
        end;
        NcTaskSetup.Insert();
    end;

    procedure NowWithDelayInSeconds(NoOfSeconds: Integer): DateTime
    begin
        exit(CurrentDateTime() + NoOfSeconds * 1000);
    end;

    procedure InitNcTask(RecRef: RecordRef; TaskRecordValue: Text; TaskType: Option; var NcTask: Record "NPR Nc Task"; DoNotCheckDublicates: Boolean): Boolean
    begin
        exit(InitNcTask(RecRef, TaskRecordValue, TaskType, CurrentDateTime, NcTask, DoNotCheckDublicates));
    end;

    procedure InitNcTask(RecRef: RecordRef; TaskRecordValue: Text; TaskType: Option; LogDateTime: DateTime; var NcTask: Record "NPR Nc Task"; DoNotCheckDublicates: Boolean): Boolean
    var
        NcTask2: Record "NPR Nc Task";
    begin
        NcTask.Init();
        NcTask."Entry No." := 0;
        NcTask.Type := TaskType;
        NcTask."Task Processor Code" := GetHeyLoyaltyTaskProcessorCode();
        NcTask."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(NcTask."Company Name"));
        NcTask."Table No." := RecRef.Number;
        NcTask."Record Position" := CopyStr(RecRef.GetPosition(false), 1, MaxStrLen(NcTask."Record Position"));
        NcTask."Record ID" := RecRef.RecordId;
        NcTask."Record Value" := CopyStr(TaskRecordValue, 1, MaxStrLen(NcTask."Record Value"));

        if not DoNotCheckDublicates then begin
            NcTask2.SetCurrentKey(Type, "Table No.", "Record Position");
            if NcTask.Type = NcTask.Type::Modify then
                NcTask2.SetFilter(Type, '%1|%2', NcTask2.Type::Insert, NcTask2.Type::Modify)
            else
                NcTask2.SetRange(Type, NcTask.Type);
            NcTask2.SetRange("Table No.", NcTask."Table No.");
            NcTask2.SetRange("Record Position", NcTask."Record Position");
            NcTask2.SetRange(Processed, false);
            NcTask2.SetRange("Task Processor Code", NcTask."Task Processor Code");
            NcTask2.SetRange("Company Name", NcTask."Company Name");
            NcTask2.SetRange("Record ID", NcTask."Record ID");
            NcTask2.SetRange("Record Value", NcTask."Record Value");
            //NcTask2.SetFilter("Log Date", '%1..', CreateDateTime(Today - 1, 0T));
            NcTask2.LockTable();
            if NcTask2.FindLast() then begin
                NcTask := NcTask2;
                if NcTask."Process Count" > 0 then begin
                    NcTask."Process Count" := 0;
                    NcTask.Modify();
                end;
                exit(false);
            end;
        end;

        if LogDateTime <> 0DT then
            NcTask."Log Date" := LogDateTime
        else
            NcTask."Log Date" := CurrentDateTime;
        NcTask.Insert(true);
        exit(true);
    end;

    procedure Enqueue(NcTask: Record "NPR Nc Task"; NotBeforeDateTime: DateTime)
    var
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
    begin
        if HLIntegrationMgt.IsInstantTaskEnqueue() then
            Codeunit.Run(Codeunit::"NPR HL Schedule Send Tasks", NcTask)
        else
            if TaskScheduler.CanCreateTask() then
                TaskScheduler.CreateTask(Codeunit::"NPR HL Schedule Send Tasks", 0, true, CompanyName, NotBeforeDateTime, NcTask.RecordId);
    end;
}