#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248591 "NPR Spfy Event Doc ProcessorJQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";
    Permissions = tabledata "NPR Spfy Store" = rm;
    trigger OnRun()
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
        StartTime: DateTime;
        MaxDuration: Duration;
        BucketFilter: text;
    begin
        JQParamStrMgt.Parse(Rec."Parameter String");
        if JQParamStrMgt.ContainsParam(ParamBucketFilter()) then
            BucketFilter := JQParamStrMgt.GetParamValueAsText(ParamBucketFilter());

        StartTime := CurrentDateTime;
        MaxDuration := JobQueueManagement.HoursToDuration(6);
        repeat
            if SpfyEcomSalesDocPrcssr.ShouldSoftExit(Rec.ID) then
                exit;
            ProcessLogEntries(BucketFilter);
            Sleep(1000);
        until DurationLimitReached(StartTime, MaxDuration);
    end;

    local procedure DurationLimitReached(StartDateTime: DateTime; DurationLimit: Duration): Boolean
    begin
        exit(CurrentDateTime - StartDateTime >= DurationLimit);
    end;

    local procedure ProcessLogEntries(BucketFilter: Text)
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        SpfyEventLogEntry.SetCurrentKey("Processing Status", "Process Retry Count", "Not Before Date-Time", "Document Type", "Bucket Id");
        SpfyEventLogEntry.SetFilter("Processing Status", '<>%1', SpfyEventLogEntry."Processing Status"::Processed);
        SpfyEventLogEntry.Setfilter("Process Retry Count", '<=%1', SpfyIntegrationMgt.GetMaxDocRetryCount());
        SpfyEventLogEntry.SetFilter("Not Before Date-Time", '<=%1', CurrentDateTime());
        SpfyEventLogEntry.SetRange("Document Type", SpfyEventLogEntry."Document Type"::Order);
        SpfyEventLogEntry.SetFilter("Bucket Id", BucketFilter);
        if SpfyEventLogEntry.FindSet() then
            repeat
                ProcessLogEntry(SpfyEventLogEntry);
            until SpfyEventLogEntry.Next() = 0;
    end;

    local procedure ProcessLogEntry(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
    begin
        SpfyEcomSalesDocPrcssr.ProcessLogEntry(SpfyEventLogEntry);
    end;

    internal procedure SetupJobQueues()
    begin
        SpfyIntegrationMgt.SetRereadSetup();
        SetupJobQueue(SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders"));
    end;

    local procedure ParamBucketFilter(): Text
    Var
        StatusLbl: label 'bucket id', Locked = true;
    begin
        exit(StatusLbl);
    end;

    internal procedure SetupJobQueue(Enable: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        if Enable then begin
            JobQueueEntry.SetCurrentKey("Object Type to Run", "Object ID to Run");
            JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
            JobQueueEntry.SetRange("Object ID to Run", CurrCodeunitId());
            if not JobQueueEntry.FindFirst() then begin
                JobQueueEntry."Parameter String" := CopyStr(CreateParameterSting(), 1, MaxStrLen(JobQueueEntry."Parameter String"));
                JobQueueEntry.Description := CopyStr(GetOrdersFromShopifyLbl, 1, MaxStrLen(JobQueueEntry.Description));
                JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
                JobQueueEntry."Object ID to Run" := CurrCodeunitId();
                ScheduleJobQueue(JobQueueEntry);
            end else
                ScheduleJobQueue(JobQueueEntry);
        end else
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId());
    end;

    local procedure ScheduleJobQueue(JobQueueEntry: Record "Job Queue Entry")
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        JobQueueMgt.SetJobTimeout(7, 0); //shouldn't be less than loop in the specific job queue
        JobQueueMgt.SetProtected(true);
        JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 30, '');
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            JobQueueEntry."Object ID to Run",
            JobQueueEntry."Parameter String",
             JobQueueEntry.Description,
             CreateDateTime(Today(), 070000T),
                1,
                '',
                JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);

    end;

    internal procedure CreateParameterSting(): text
    var
        ParamScope: Label '=1..100', Locked = true;
    begin
        exit(ParamBucketFilter() + ParamScope);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
    local procedure RefreshJobQueueEntry()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        If ShopifySetup.IsEmpty() then
            exit;
        SetupJobQueues();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry")
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        if Rec."Parameter String" = '' then
            Rec."Parameter String" := CopyStr(ParamBucketFilter(), 1, MaxStrLen(Rec."Parameter String"));
        if Rec.Description = '' then
            Rec.Description := CopyStr(GetOrdersFromShopifyLbl, 1, MaxStrLen(Rec.Description));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Spfy Event Doc ProcessorJQ");
    end;

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        GetOrdersFromShopifyLbl: Label 'Process Sales Orders from Shopify Event Log';

}
#endif