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
    end;

    local procedure UpgradeEcomSalesDocJQ()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        UpgradeStep := 'UpgradeEcomSalesDocJQ';
        if HasUpgradeTag() then
            exit;

        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR EcomSalesOrderProcJQ");
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        if JobQueueEntry.FindFirst() then begin
            if CheckIfEcomDocsExist() then begin
                SetMonitoredJobQueueEntry(JobQueueEntry);
                SetBucketParameterString(JobQueueEntry);
            end else
                JobQueueEntry.Delete(true);
        end;

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

    local procedure SetMonitoredJobQueueEntry(JobQueueEntry: Record "Job Queue Entry")
    var
        JQRefreshSetup: Record "NPR Job Queue Refresh Setup";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        RefreshJobQueueEntry: Codeunit "NPR Refresh Job Queue Entry";
    begin
        JQRefreshSetup.GetSetup();
        MonitoredJQEntry.Init();
        MonitoredJQEntry."Entry No." := 0;
        MonitoredJQEntry.TransferFields(JobQueueEntry);
        MonitoredJQEntry.Insert();

        RefreshJobQueueEntry.RefreshJobQueueEntry(MonitoredJQEntry, false);
        MonitoredJQEntry.Modify();
    end;

    local procedure UpgradeEcomSalesReturnDocJQ()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        UpgradeStep := 'UpgradeEcomSalesReturnDocJQ';
        if HasUpgradeTag() then
            exit;

        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR EcomSalesRetOrderProcJQ");
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        if JobQueueEntry.FindFirst() then begin
            if CheckIfEcomDocsExist() then begin
                SetMonitoredJobQueueEntry(JobQueueEntry);
                SetBucketParameterString(JobQueueEntry);
            end else
                JobQueueEntry.Delete(true);
        end;

        SetUpgradeTag();
    end;

    local procedure CheckIfEcomDocsExist(): Boolean
    var
        EcomDocSalesHeader: Record "NPR Ecom Sales Header";
    begin
        EcomDocSalesHeader.Reset();
        exit(not EcomDocSalesHeader.IsEmpty());
    end;

    local procedure UpgradeBucketId()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        UpgradeStep := 'UpgradeBucketId';
        if HasUpgradeTag() then
            exit;

        EcomSalesHeader.Reset();
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
}
#endif
