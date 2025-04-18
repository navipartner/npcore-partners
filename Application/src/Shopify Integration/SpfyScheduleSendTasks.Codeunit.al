#if not BC17
codeunit 6184817 "NPR Spfy Schedule Send Tasks"
{
    Access = Internal;
    Permissions =
        tabledata "NPR Nc Task Setup" = rimd,
        tabledata "NPR Nc Task Processor" = rimd;

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";

    procedure SetupTaskProcessingJobQueues()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        if ShopifyStore.IsEmpty() then
            exit;
        SetupTaskProcessingJobQueues(ShopifyStore);
    end;

    procedure SetupTaskProcessingJobQueues(var ShopifyStore: Record "NPR Spfy Store")
    begin
        SpfyIntegrationMgt.SetRereadSetup();
        if ShopifyStore.FindSet() then
            repeat
                SetupTaskProcessingJobQueue(ShopifyStore.Code, SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::" ", ShopifyStore));
            until ShopifyStore.Next() = 0;
    end;

    local procedure SetupTaskProcessingJobQueue(ShopifyStoreCode: Code[20]; Enable: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NcTaskListProcessing: Codeunit "NPR Nc Task List Processing";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
        FilterPlaceholderTok: Label '@*%1?%2*', Locked = true;
    begin
        if Enable then begin
            JobQueueMgt.SetStoreCode(ShopifyStoreCode);
            JobQueueMgt.ScheduleNcTaskProcessing(JobQueueEntry, GetShopifyTaskProcessorCode(true), true, '', 1);
        end else begin
            JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
            JobQueueEntry.SetRange("Object ID to Run", NcSetupMgt.TaskListProcessingCodeunit());
            JobQueueEntry.SetFilter("Parameter String", '%1&%2',
                StrSubstNo(FilterPlaceholderTok, NcTaskListProcessing.ParamProcessor(), GetShopifyTaskProcessorCode(false)),
                StrSubstNo(FilterPlaceholderTok, NcTaskListProcessing.ParamStoreCode(), ShopifyStoreCode));
            if not JobQueueEntry.IsEmpty() then
                JobQueueMgt.CancelNpManagedJobs(JobQueueEntry);
        end;
    end;

    procedure GetShopifyTaskProcessorCode(AutoCreate: Boolean): Code[20]
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        ShopifyTaskProcessorDescription: Label 'Shopify updates', MaxLength = 50;
    begin
        NcTaskProcessor.Code := SpfyIntegrationMgt.DataProcessingHandlerID(AutoCreate);
        if (NcTaskProcessor.Code <> '') and AutoCreate then
            if not NcTaskProcessor.Find() then begin
                NcTaskProcessor.Init();
                NcTaskProcessor.Description := ShopifyTaskProcessorDescription;
                NcTaskProcessor.Insert(true);
            end;
        exit(NcTaskProcessor.Code);
    end;

    local procedure CreateTaskSetupEntry(TaskProcessorCode: Code[20]; TableId: Integer; CodeunitId: Integer)
    var
        NcTaskSetup: Record "NPR Nc Task Setup";
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
        NcTaskSetup."Codeunit ID" := CodeunitId;
        NcTaskSetup.Insert();
    end;

    procedure InitNcTask(ShopifyStoreCode: Code[20]; RecRef: RecordRef; TaskRecordValue: Text; TaskType: Option; var NcTask: Record "NPR Nc Task"): Boolean
    begin
        exit(InitNcTask(ShopifyStoreCode, RecRef, TaskRecordValue, TaskType, CurrentDateTime(), NcTask));
    end;

    procedure InitNcTask(ShopifyStoreCode: Code[20]; RecRef: RecordRef; TaskRecordValue: Text; TaskType: Option; LogDateTime: DateTime; var NcTask: Record "NPR Nc Task"): Boolean
    begin
        exit(InitNcTask(ShopifyStoreCode, RecRef, RecRef.RecordId(), TaskRecordValue, TaskType, LogDateTime, 0DT, NcTask));
    end;

    procedure InitNcTask(ShopifyStoreCode: Code[20]; RecRef: RecordRef; RecID: RecordId; TaskRecordValue: Text; TaskType: Option; LogDateTime: DateTime; NotBeforeDateTime: DateTime; var NcTask: Record "NPR Nc Task"): Boolean
    var
        NcTask2: Record "NPR Nc Task";
    begin
        NcTask.Init();
        NcTask."Entry No." := 0;
        NcTask."Task Processor Code" := GetShopifyTaskProcessorCode(true);
        NcTask.Type := TaskType;
        NcTask."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(NcTask."Company Name"));
        NcTask."Table No." := RecRef.Number();
        NcTask."Table Name" := CopyStr(RecRef.Name(), 1, MaxStrLen(NcTask."Table Name"));
        NcTask."Record Position" := CopyStr(RecRef.GetPosition(false), 1, MaxStrLen(NcTask."Record Position"));
        NcTask."Record ID" := RecID;
        NcTask."Record Value" := CopyStr(TaskRecordValue, 1, MaxStrLen(NcTask."Record Value"));
        NcTask."Store Code" := ShopifyStoreCode;
        NcTask."Not Before Date-Time" := NotBeforeDateTime;

        NcTask2.SetCurrentKey(Type, "Table No.", "Record Position");
        if NcTask.Type = NcTask.Type::Modify then
            NcTask2.SetRange(Type, NcTask.Type::Insert, NcTask.Type::Modify)
        else
            NcTask2.SetRange(Type, NcTask.Type);
        NcTask2.SetRange("Table No.", NcTask."Table No.");
        NcTask2.SetRange(Processed, false);
        NcTask2.SetRange("Task Processor Code", NcTask."Task Processor Code");
        NcTask2.SetRange("Company Name", NcTask."Company Name");
        NcTask2.SetRange("Record ID", NcTask."Record ID");
        NcTask2.SetRange("Record Value", NcTask."Record Value");
        NcTask2.SetRange("Store Code", NcTask."Store Code");
        NcTask2.SetRange("Not Before Date-Time", NcTask."Not Before Date-Time");
        NcTask2.SetFilter("Log Date", '%1..', CreateDateTime(Today() - 1, 0T));
        if NcTask2.FindLast() then begin
            NcTask := NcTask2;
            exit(false);
        end;

        if LogDateTime <> 0DT then
            NcTask."Log Date" := LogDateTime
        else
            NcTask."Log Date" := CurrentDateTime();
        NcTask.Insert(true);
        exit(true);
    end;

    procedure ToggleSpfyItemPriceSyncJobQueue(Enabled: Boolean)
    var
        SpfyItemPriceMgt: Codeunit "NPR Spfy Item Price Mgt.";
        JobDescription: Label 'Calculate Shopify Item Prices', MaxLength = 250;
    begin
        if Enabled then
            SpfyItemPriceMgt.CreateSpfyItemPriceSyncJob(JobDescription)
        else
            SpfyItemPriceMgt.CancelSpfyItemPriceSyncJob();
    end;

    local procedure ProcessAndEnqueueDataLogRecord(DataLogRecord: Record "NPR Data Log Record") NewTasksInserted: Boolean
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyRetailVoucherMgt: Codeunit "NPR Spfy Retail Voucher Mgt.";
    begin
        NewTasksInserted := false;
        case DataLogRecord."Table ID" of
            Database::Item,
            Database::"Item Variant",
            Database::"Stockkeeping Unit",
            Database::"Item Reference",
            Database::"NPR Spfy Store-Item Link",
            Database::"NPR Spfy Item Variant Modif.",
            Database::"NPR Spfy Entity Metafield",
            Database::"NPR Spfy Item Price",
            Database::"NPR Spfy Inventory Level":
                NewTasksInserted := SpfyItemMgt.ProcessDataLogRecord(DataLogRecord);

            Database::"Sales Line",
            Database::"Transfer Line",
            Database::"Item Ledger Entry":
                Codeunit.Run(Codeunit::"NPR Spfy Inventory Level Mgt.", DataLogRecord);

            Database::"NPR NpRv Voucher",
            Database::"NPR NpRv Arch. Voucher",
            Database::"NPR NpRv Voucher Entry":
                NewTasksInserted := SpfyRetailVoucherMgt.ProcessDataLogRecord(DataLogRecord);
        end;
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Sync. Mgt.", 'OnBeforeProcessTask', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Sync. Mgt.", OnBeforeProcessTask, '', true, false)]
#endif
    local procedure CreateTaskSetup_OnBeforeProcessTask(var Task: Record "NPR Nc Task")
    begin
        CreateTaskSetup(Task);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Sync. Mgt.", 'OnBeforeProcessTaskBatch', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Sync. Mgt.", OnBeforeProcessTaskBatch, '', true, false)]
#endif
    local procedure CreateTaskSetup_OnBeforeProcessTaskBatch(var Task: Record "NPR Nc Task")
    begin
        CreateTaskSetup(Task);
    end;

    local procedure CreateTaskSetup(var Task: Record "NPR Nc Task")
    begin
        if (Task."Task Processor Code" = '') or (Task."Task Processor Code" <> GetShopifyTaskProcessorCode(false)) then
            exit;
        case Task."Table No." of
            Database::Item,
            Database::"Item Variant",
            Database::"Item Reference",
            Database::"Inventory Buffer",
            Database::"NPR Spfy Tag Update Request",
            Database::"NPR Spfy Entity Metafield",
            Database::"NPR Spfy Inventory Level",
            Database::"NPR Spfy Item Price":
                CreateTaskSetupEntry(Task."Task Processor Code", Task."Table No.", Codeunit::"NPR Spfy Send Items&Inventory");

            Database::"NPR NpRv Voucher",
            Database::"NPR NpRv Arch. Voucher",
            Database::"NPR NpRv Voucher Entry":
                CreateTaskSetupEntry(Task."Task Processor Code", Task."Table No.", Codeunit::"NPR Spfy Send Voucher");

            Database::"Sales Shipment Header",
            Database::"Return Receipt Header":
                CreateTaskSetupEntry(Task."Task Processor Code", Task."Table No.", Codeunit::"NPR Spfy Send Fulfillment");

            Database::"Sales Invoice Header",
            Database::"NPR Magento Payment Line":
                CreateTaskSetupEntry(Task."Task Processor Code", Task."Table No.", Codeunit::"NPR Spfy Capture Payment");
        end;
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Task Mgt.", 'OnBeforeUpdateTasks', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Task Mgt.", OnBeforeUpdateTasks, '', false, false)]
#endif
    local procedure CheckIfSpfyIntegrationIsEnabled(TaskProcessor: Record "NPR Nc Task Processor"; var MaxNoOfDataLogRecordsToProcess: Integer; var SkipProcessing: Boolean)
    begin
        if (TaskProcessor.Code = '') or (TaskProcessor.Code <> GetShopifyTaskProcessorCode(false)) then
            exit;
        SkipProcessing := not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::" ", '');
        MaxNoOfDataLogRecordsToProcess := 0;
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Data Log Sub. Mgt.", 'OnCheckIfDataLogSubscriberIsEnabled', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Data Log Sub. Mgt.", OnCheckIfDataLogSubscriberIsEnabled, '', false, false)]
#endif
    local procedure CheckIfDataLogSubscriberShouldBeProcessed(DataLogSubscriber: Record "NPR Data Log Subscriber"; var IsEnabled: Boolean)
    begin
        if (DataLogSubscriber.Code = '') or (DataLogSubscriber.Code <> SpfyIntegrationMgt.DataProcessingHandlerID(false)) then
            exit;
        case DataLogSubscriber."Table ID" of
            Database::Item,
            Database::"NPR Spfy Store-Item Link":
                begin
                    IsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items);
                    if not IsEnabled then
                        IsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels");
                end;

            Database::"Item Variant",
            Database::"Item Reference",
            Database::"NPR Spfy Item Variant Modif.",
            Database::"NPR Spfy Entity Metafield":
                IsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items);

            Database::"Stockkeeping Unit",
            Database::"NPR Spfy Inventory Level",
            Database::"Sales Line",
            Database::"Transfer Line",
            Database::"Item Ledger Entry":
                IsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels");

            Database::"NPR Spfy Item Price":
                IsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Item Prices");

            Database::"NPR NpRv Voucher",
            Database::"NPR NpRv Arch. Voucher",
            Database::"NPR NpRv Voucher Entry":
                IsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Retail Vouchers");
        end;
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Task Mgt.", 'OnUpdateTasksOnAfterGetNewSetOfDataLogRecords', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Task Mgt.", OnUpdateTasksOnAfterGetNewSetOfDataLogRecords, '', false, false)]
#endif
    local procedure ProcessSpfyDataLogRecords(TaskProcessor: Record "NPR Nc Task Processor"; ProcessCompanyName: Text[30]; var TempDataLogRecord: Record "NPR Data Log Record"; var NewTasksInserted: Boolean; var Handled: Boolean)
    begin
        if (TaskProcessor.Code = '') or (TaskProcessor.Code <> GetShopifyTaskProcessorCode(false)) then
            exit;
        Handled := true;
        SelectLatestVersion();
        if TempDataLogRecord.FindSet() then
            repeat
                NewTasksInserted := ProcessAndEnqueueDataLogRecord(TempDataLogRecord) or NewTasksInserted;
            until TempDataLogRecord.Next() = 0;
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RefreshJobQueueEntry()
    begin
        SetupTaskProcessingJobQueues();
    end;
}
#endif