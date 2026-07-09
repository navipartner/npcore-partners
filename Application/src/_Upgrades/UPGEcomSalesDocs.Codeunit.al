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
        UpgradeEcomJQs();
        UpgradeBucketId();
        UpdateJobTimeout();
        UpdateLastOrdersImportedAt();
        FixMonitoredJQEcomSalesDoc();
        FixMonitoredJQEcomSalesRetDoc();
    end;

    local procedure UpgradeEcomJQs()
    var
        // EcomCreateCouponJQ: Codeunit "NPR EcomCreateCouponJQ";
        // EcomCreateMembershipJQ: Codeunit "NPR EcomCreateMembershipJQ";
        // EcomCreateTicketJQ: Codeunit "NPR EcomCreateTicketJQ";
        // EcomCreateVoucherJQ: Codeunit "NPR EcomCreateVoucherJQ";
        // EcomDigitalNotifJQ: Codeunit "NPR EcomDigitalNotifJQ";
        // EcomProcessWalletsJQ: Codeunit "NPR EcomProcessWalletsJQ";
        // EcomSaleCaptureJQ: Codeunit "NPR EcomSaleCaptureJQ";
        EcomSalesOrderProcJQ: Codeunit "NPR EcomSalesOrderProcJQ";
        EcomSalesRetOrderProcJQ: Codeunit "NPR EcomSalesRetOrderProcJQ";
        EcomDocsExist: Boolean;
    begin
        EcomDocsExist := CheckIfEcomDocsExist();

        // UpgradeEcomJQ('UpgradeEcomCreateCouponJQ', EcomCreateCouponJQ.GetCodeunitId(), EcomCreateCouponJQ.GetJQDescription(), EcomDocsExist);
        // UpgradeEcomJQ('UpgradeEcomCreateMembershipJQ', EcomCreateMembershipJQ.GetCodeunitId(), EcomCreateMembershipJQ.GetJQDescription(), EcomDocsExist);
        // UpgradeEcomJQ('UpgradeEcomCreateTicketJQ', EcomCreateTicketJQ.GetCodeunitId(), EcomCreateTicketJQ.GetJQDescription(), EcomDocsExist);
        // UpgradeEcomJQ('UpgradeEcomCreateVoucherJQ', EcomCreateVoucherJQ.GetCodeunitId(), EcomCreateVoucherJQ.GetJQDescription(), EcomDocsExist);
        // UpgradeEcomJQ('UpgradeEcomDigitalNotifJQ', EcomDigitalNotifJQ.GetCodeunitId(), EcomDigitalNotifJQ.GetJQDescription(), EcomDocsExist);
        // UpgradeEcomJQ('UpgradeEcomProcessWalletsJQ', EcomProcessWalletsJQ.GetCodeunitId(), EcomProcessWalletsJQ.GetJQDescription(), EcomDocsExist);
        // UpgradeEcomJQ('UpgradeEcomSaleCaptureJQ', EcomSaleCaptureJQ.GetCodeunitId(), EcomSaleCaptureJQ.GetJQDescription(), EcomDocsExist);
        UpgradeEcomJQ('UpgradeEcomSalesDocJQ', EcomSalesOrderProcJQ.GetCodeunitId(), EcomSalesOrderProcJQ.GetJQDescription(), EcomDocsExist);
        UpgradeEcomJQ('UpgradeEcomSalesReturnDocJQ', EcomSalesRetOrderProcJQ.GetCodeunitId(), EcomSalesRetOrderProcJQ.GetJQDescription(), EcomDocsExist);
    end;

    local procedure UpgradeEcomJQ(UpgradeStepName: Text; CodeunitId: Integer; JQDescription: Text; EcomDocsExist: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
    begin
        UpgradeStep := UpgradeStepName;
        if HasUpgradeTag() then
            exit;

        JobQueueEntry.SetRange("Object ID to Run", CodeunitId);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);

        if not EcomDocsExist then begin
            if JobQueueEntry.FindFirst() then
                DeleteMonitoredJobQueueEntry(JobQueueEntry);
        end else begin
            if not JobQueueEntry.FindFirst() then
                EcomJobManagement.ScheduleJobQueue(CodeunitId, JQDescription, JobQueueEntry)
            else begin
                SetBucketParameterString(JobQueueEntry);
                SetMonitoredJobQueueEntry(JobQueueEntry);
            end;
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

    local procedure SetBucketParameterString(var JobQueueEntry: Record "Job Queue Entry")
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
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        NewTimeout: Duration;
    begin
        UpgradeStep := 'UpdateJobTimeout';
        if HasUpgradeTag() then
            exit;

        NewTimeout := EcomJobManagement.GetTargetJobTimeout();
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

    local procedure FixMonitoredJQEcomSalesDoc()
    var
        EcomSalesOrderProcJQ: Codeunit "NPR EcomSalesOrderProcJQ";
    begin
        UpgradeStep := 'FixMonitoredJQEcomSalesDoc';
        if HasUpgradeTag() then
            exit;
        FixEcomJQEntry(EcomSalesOrderProcJQ.GetCodeunitId());
        SetUpgradeTag();
    end;

    local procedure FixMonitoredJQEcomSalesRetDoc()
    var
        EcomSalesRetOrderProcJQ: Codeunit "NPR EcomSalesRetOrderProcJQ";
    begin
        UpgradeStep := 'FixMonitoredJQEcomSalesRetDoc';
        if HasUpgradeTag() then
            exit;
        FixEcomJQEntry(EcomSalesRetOrderProcJQ.GetCodeunitId());
        SetUpgradeTag();
    end;

    local procedure FixEcomJQEntry(CodeunitId: Integer)
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        ExpectedParamString: Text[250];
        ExpectedTimeout: Duration;
        Modified: Boolean;
    begin
        ExpectedParamString := CopyStr(EcomJobManagement.CreateParameterSting(), 1, MaxStrLen(MonitoredJQEntry."Parameter String"));
        ExpectedTimeout := EcomJobManagement.GetTargetJobTimeout();

        MonitoredJQEntry.SetCurrentKey("Object ID to Run", "Object Type to Run");
        MonitoredJQEntry.SetRange("Object ID to Run", CodeunitId);
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        if MonitoredJQEntry.FindSet(true) then
            repeat
                Modified := false;
                if BucketParamIsBroken(MonitoredJQEntry."Parameter String") then begin
                    MonitoredJQEntry."Parameter String" := ExpectedParamString;
                    Modified := true;
                end;
                if MonitoredJQEntry."Job Timeout" < ExpectedTimeout then begin
                    MonitoredJQEntry."Job Timeout" := ExpectedTimeout;
                    Modified := true;
                end;
                if Modified then
                    MonitoredJQEntry.Modify();
            until MonitoredJQEntry.Next() = 0;

        JobQueueEntry.SetCurrentKey("Object Type to Run", "Object ID to Run");
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitId);
        if JobQueueEntry.FindSet() then
            repeat
                if BucketParamIsBroken(JobQueueEntry."Parameter String") or (JobQueueEntry."Job Timeout" < ExpectedTimeout) then begin
                    JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
                    if BucketParamIsBroken(JobQueueEntry."Parameter String") then
                        JobQueueEntry."Parameter String" := ExpectedParamString;
                    if JobQueueEntry."Job Timeout" < ExpectedTimeout then
                        JobQueueEntry."Job Timeout" := ExpectedTimeout;
                    JobQueueEntry.Modify();
                    if not JobQueueEntry."NPR Manually Set On Hold" then
                        JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
                end;
            until JobQueueEntry.Next() = 0;
    end;

    local procedure BucketParamIsBroken(ParamString: Text): Boolean
    var
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
    begin
        JQParamStrMgt.Parse(ParamString);
        if not JQParamStrMgt.ContainsParam(EcomJobManagement.ParamBucketFilter()) then
            exit(true);
        exit(JQParamStrMgt.GetParamValueAsText(EcomJobManagement.ParamBucketFilter()) = '');
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

    local procedure UpdateLastOrdersImportedAt()
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        UpgradeStep := 'UpdateLastOrdersImportedAt';
        if HasUpgradeTag() then
            exit;
        if EntriaStore.FindSet() then
            repeat
                if EntriaStore."Last Orders Imported At" <> 0DT then begin
                    EntriaStore.SetLastOrdersImportedAt(EntriaStore.Code, EntriaStore."Last Orders Imported At");
                    EntriaStore."Last Orders Imported At" := 0DT;
                    EntriaStore.Modify();
                end;
            until EntriaStore.Next() = 0;

        SetUpgradeTag();
    end;
}
#endif
