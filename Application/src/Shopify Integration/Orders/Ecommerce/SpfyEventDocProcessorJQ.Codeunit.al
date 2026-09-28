#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248591 "NPR Spfy Event Doc ProcessorJQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";
    Permissions = tabledata "NPR Spfy Store" = rm;
    trigger OnRun()
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
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
            if EcomJobManagement.ShouldSoftExit(Rec.ID) then
                exit;
            ProcessLogEntries(BucketFilter);
            Commit();
            if Rec."Recurring Job" then
                Sleep(1000);
        until not Rec."Recurring Job" or EcomJobManagement.DurationLimitReached(StartTime, MaxDuration);
    end;

    local procedure ProcessLogEntries(BucketFilter: Text)
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
    begin
        SpfyIntegrationMgt.SetRereadSetup();

        ApplyProcessableEventLogFilters(SpfyEventLogEntry, BucketFilter);
        if SpfyEventLogEntry.FindSet() then
            repeat
                if EcomJobManagement.ApplicationChanged() then
                    exit;
                ProcessLogEntry(SpfyEventLogEntry);
            until SpfyEventLogEntry.Next() = 0;
    end;

    local procedure ProcessLogEntry(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    begin
        SpfyEcomSalesDocPrcssr.ProcessLogEntry(SpfyEventLogEntry);
    end;

    internal procedure ApplyProcessableEventLogFilters(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; BucketFilter: Text)
    begin
        SpfyEventLogEntry.SetCurrentKey("Processing Status", "Process Retry Count", "Not Before Date-Time", "Document Type", "Bucket Id");
        SpfyEventLogEntry.SetFilter("Processing Status", '<>%1', SpfyEventLogEntry."Processing Status"::Processed);
        SpfyEventLogEntry.SetFilter("Process Retry Count", '<=%1', SpfyIntegrationMgt.GetMaxDocRetryCount());
        SpfyEventLogEntry.SetFilter("Not Before Date-Time", '<=%1', CurrentDateTime());
        SpfyEventLogEntry.SetRange("Document Type", SpfyEventLogEntry."Document Type"::Order);
        SpfyEventLogEntry.SetFilter("Bucket Id", BucketFilter);
    end;

    internal procedure SetupJobQueues()
    begin
        SetupJobQueue(IsJobQueueNeeded(false));
    end;

    internal procedure CancelJobQueueIfNotEligible()
    begin
        if IsJobQueueNeeded(true) then
            exit;
        SetupJobQueue(false);
    end;

    local procedure IsJobQueueNeeded(CommittedRead: Boolean): Boolean
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        SpfyIntegrationMgt.SetRereadSetup();
        if CommittedRead then
            ShopifyStore.ReadIsolation := IsolationLevel::ReadCommitted;
        if SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders", ShopifyStore) then
            exit(true);
        exit(SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Returns", ShopifyStore));
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
        MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        ParameterString: Text[250];
    begin
        if not Enable then begin
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId());
            RemoveOrphanedMonitoredJQEntries();
            exit;
        end;

        //Purge before creating, never after: if the registration below is ever reached with a blank job queue
        //entry, a purge running afterwards would judge the row it had just created to be orphaned and delete it.
        RemoveOrphanedMonitoredJQEntries();

        //Reuse an existing entry's Parameter String when present so that a manually-created row (whose
        //OnValidate subscriber wrote just 'bucket id' without the '=1..100' range, or a sharded
        //deployment that partitioned the buckets across entries) is updated in place. JQEntryExists
        //filters "Parameter String" exactly, so passing CreateParameterString() unconditionally would
        //miss such a row and insert a duplicate that then processes all buckets.
        if not TryGetExistingBucketParameterString(ParameterString) then
            ParameterString := CopyStr(CreateParameterString(), 1, MaxStrLen(JobQueueEntry."Parameter String"));

        JobQueueMgt.SetJobTimeout(7, 0); //shouldn't be less than loop in the specific job queue
        JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 30, '');
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId(),
            ParameterString, GetOrdersFromShopifyLbl,
            CreateDateTime(Today(), 070000T), 1,
            '', JobQueueEntry)
        then begin
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
            if not IsNullGuid(JobQueueEntry.ID) then
                MonitoredJQMgt.AssignJobQueueEntryToManagedAndMonitored(false, true, JobQueueEntry);
        end;
    end;

    // Deletes this codeunit's monitored rows whose job queue entry no longer exists. When the refresher is not allowed to recreate the entry, such a row fails on every refresh cycle.
    local procedure RemoveOrphanedMonitoredJQEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        MonitoredJQEntry.SetCurrentKey("Object ID to Run", "Object Type to Run");
        MonitoredJQEntry.SetRange("Object ID to Run", CurrCodeunitId());
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        if not MonitoredJQEntry.FindSet(true) then
            exit;
        repeat
            if not JobQueueEntry.Get(MonitoredJQEntry."Job Queue Entry ID") then
                MonitoredJQEntry.Delete(true);
        until MonitoredJQEntry.Next() = 0;
    end;

    internal procedure CreateParameterString(): text
    var
        ParamScope: Label '=1..100', Locked = true;
    begin
        exit(ParamBucketFilter() + ParamScope);
    end;

    local procedure TryGetExistingBucketParameterString(var ParameterString: Text[250]): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        FirstParameterString: Text[250];
    begin
        JobQueueEntry.SetCurrentKey("Object Type to Run", "Object ID to Run");
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CurrCodeunitId());
        if not JobQueueEntry.FindSet() then
            exit(false);
        FirstParameterString := JobQueueEntry."Parameter String";
        repeat
            if StrPos(JobQueueEntry."Parameter String", ParamBucketFilter()) > 0 then begin
                ParameterString := CopyStr(JobQueueEntry."Parameter String", 1, MaxStrLen(ParameterString));
                exit(true);
            end;
            if JobQueueEntry."Parameter String" = '' then begin
                JobQueueEntry."Parameter String" := CopyStr(CreateParameterString(), 1, MaxStrLen(JobQueueEntry."Parameter String"));
                JobQueueEntry.Modify(false);
                ParameterString := JobQueueEntry."Parameter String";
                exit(true);
            end;
        until JobQueueEntry.Next() = 0;

        //No entry carries a bucket filter: reuse the first one's Parameter String as it is, so it is updated in
        //place rather than duplicated by an entry with the default bucket filter.
        ParameterString := FirstParameterString;
        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeValidateCreateMissingCustomJQs, '', false, false)]
    local procedure SkipValidateCreateMissingCustomJQs(JobQueueEntry: Record "Job Queue Entry"; var SkipValidation: Boolean)
    var
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
    begin
        if JobQueueEntry."Object Type to Run" <> JobQueueEntry."Object Type to Run"::Codeunit then
            exit;
        if JobQueueEntry."Object ID to Run" <> CurrCodeunitId() then
            exit;

        if not ShopifyEcommOrderExp.IsFeatureEnabled() then
            exit;

        SpfyIntegrationMgt.SetRereadSetup();
        if SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders") or
           SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Returns")
        then
            SkipValidation := true;
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

    internal procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Spfy Event Doc ProcessorJQ");
    end;

    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
        GetOrdersFromShopifyLbl: Label 'Process Sales Orders from Shopify Event Log';

}
#endif