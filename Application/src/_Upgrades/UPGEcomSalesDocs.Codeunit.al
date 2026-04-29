#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248652 "NPR UPG Ecom Sales Docs"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        UpgradeEcomSalesDocJQ();
        UpgradeEcomSalesReturnDocJQ();
        UpgradeBucketId();
        UpdateJobTimeout();
    end;

    local procedure UpgradeEcomSalesDocJQ()
    var
        JobQueueEntry: Record "Job Queue Entry";
        EcomSalesOrderProcJQ: Codeunit "NPR EcomSalesOrderProcJQ";
        EcomDocsExist: Boolean;
    begin
        UpgradeStep := 'UpgradeEcomSalesDocJQ';
        if HasUpgradeTag() then
            exit;

        EcomDocsExist := CheckIfEcomDocsExist();
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR EcomSalesOrderProcJQ");
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        if not EcomDocsExist then begin
            if JobQueueEntry.FindFirst() then
                DeleteMonitoredJobQueueEntry(JobQueueEntry);
        end else begin
            if not JobQueueEntry.FindFirst() then
                EcomSalesOrderProcJQ.ScheduleJobQueue(JobQueueEntry);
            SetBucketParameterString(JobQueueEntry);
            SetMonitoredJobQueueEntry(JobQueueEntry);
        end;

        SetUpgradeTag();
    end;

    local procedure UpgradeEcomSalesReturnDocJQ()
    var
        JobQueueEntry: Record "Job Queue Entry";
        EcomSalesReturnProcJQ: Codeunit "NPR EcomSalesRetOrderProcJQ";
        EcomDocsExist: Boolean;
    begin
        UpgradeStep := 'UpgradeEcomSalesReturnDocJQ';
        if HasUpgradeTag() then
            exit;

        EcomDocsExist := CheckIfEcomDocsExist();
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR EcomSalesRetOrderProcJQ");
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        if not EcomDocsExist then begin
            if JobQueueEntry.FindFirst() then
                DeleteMonitoredJobQueueEntry(JobQueueEntry);
        end else begin
            if not JobQueueEntry.FindFirst() then
                EcomSalesReturnProcJQ.ScheduleJobQueue(JobQueueEntry);
            SetBucketParameterString(JobQueueEntry);
            SetMonitoredJobQueueEntry(JobQueueEntry);
        end;

        SetUpgradeTag();
    end;

    local procedure SetMonitoredJobQueueEntry(JobQueueEntry: Record "Job Queue Entry")
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
    begin
        JQRefreshSetup.GetSetup();
        MonitoredJQMgt.AssignJobQueueEntryToManagedAndMonitored(false, true, JobQueueEntry);
    end;

    local procedure DeleteMonitoredJobQueueEntry(JobQueueEntry: Record "Job Queue Entry")
    var
        ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
        MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
    begin
        if ManagedByAppJobQueue.Get(JobQueueEntry.ID) then
            ManagedByAppJobQueue.Delete();
        MonitoredJQMgt.RemoveMonitoredJobQueueEntry(JobQueueEntry);

        JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
        JobQueueEntry.Delete(true);
    end;

    local procedure CheckIfEcomDocsExist(): Boolean
    var
        EcomDocSalesHeader: Record "NPR Ecom Sales Header";
    begin
        exit(not EcomDocSalesHeader.IsEmpty());
    end;

    local procedure UpgradeBucketId()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        UpgradeStep := 'UpgradeBucketId';
        if HasUpgradeTag() then
            exit;

        EcomSalesHeader.SetRange("Bucket Id", 0);
        EcomSalesHeader.SetRange("Creation Status", EcomSalesHeader."Creation Status"::Pending);
        if EcomSalesHeader.FindSet() then
            repeat
                AssignBucketLines(EcomSalesHeader);
            until EcomSalesHeader.Next() = 0;

        SetUpgradeTag();
    end;

    local procedure AssignBucketLines(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
    begin
        EcomSalesHeader."Bucket Id" := EcomVirtualItemMgt.AssignBucketLines(EcomSalesHeader);
        EcomSalesHeader.Modify();
    end;

    local procedure SetBucketParameterString(JobQueueEntry: Record "Job Queue Entry")
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        BucketFilterLbl: Label '1..100', Locked = true;
    begin
        if JobQueueEntry."Parameter String" <> '' then
            exit;
        JobQueueEntry."Parameter String" := CopyStr(EcomJobManagement.ParamBucketFilter() + '=' + BucketFilterLbl, 1, MaxStrLen(JobQueueEntry."Parameter String"));
        JobQueueEntry.Modify();
    end;

    local procedure UpdateJobTimeout()
    var
        JobQueueEntry: Record "Job Queue Entry";
        NewTimeout: Duration;
    begin
        UpgradeStep := 'UpdateJobTimeout';
        if HasUpgradeTag() then
            exit;

        NewTimeout := 7 * 60 * 60 * 1000;//7h
        JobQueueEntry.SetCurrentKey("Object Type to Run", "Object ID to Run");
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter("Object ID to Run", '%1|%2', Codeunit::"NPR EcomSalesOrderProcJQ", Codeunit::"NPR EcomSalesRetOrderProcJQ");
        if JobQueueEntry.FindSet() then
            repeat
                If NewTimeout <> JobQueueEntry."Job Timeout" then begin
                    JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
                    JobQueueEntry."Job Timeout" := NewTimeout;
                    JobQueueEntry.Modify();
                    if not JobQueueEntry."NPR Manually Set On Hold" then
                        JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
                end;
            until JobQueueEntry.Next() = 0;

        SetUpgradeTag();
    end;

    local procedure HasUpgradeTag(): Boolean
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Ecom Sales Docs", UpgradeStep)) then
            exit(true);
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Ecom Sales Docs', UpgradeStep);
    end;

    local procedure SetUpgradeTag()
    begin
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Ecom Sales Docs", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
#endif
