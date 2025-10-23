#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248467 "NPR UPG Inc Ecom Sales Docs"
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
        CreateIncEcomSalesDocSetup();
        UpgradeSalesOrderJQ();
        UpgradeSalesReturnOrderJQ();
        UpgradeDocumentsToNewTables();
    end;

    internal procedure CreateIncEcomSalesDocSetup()
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        UpgradeStep := 'CreateIncEcomSalesDocSetup';
        if HasUpgradeTag() then
            exit;

        if not IncEcomSalesDocSetup.Get() then begin
            IncEcomSalesDocSetup.Init();
            IncEcomSalesDocSetup.Insert();

            IncEcomSalesDocSetup.Validate("Auto Proc Sales Order", true);
            IncEcomSalesDocSetup.Validate("Auto Proc Sales Ret Order", true);
            IncEcomSalesDocSetup.Modify(true);
        end;

        SetUpgradeTag();
    end;

    internal procedure UpgradeSalesOrderJQ()
    var
        JobQueueEntry: Record "Job Queue Entry";
        EcomSalesDocProcess: Codeunit "NPR EcomSalesDocProcess";
    begin
        UpgradeStep := 'UpgradeSalesOrderJQ';
        if HasUpgradeTag() then
            exit;

        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR IncEcomSalesOrderProcJQ");
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        if JobQueueEntry.FindSet() then
            repeat
                JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
                JobQueueEntry.Delete(true)
            until JobQueueEntry.Next() = 0;

        EcomSalesDocProcess.HandleSalesOrderProcessJQScheduleConfirmation(true);
        SetUpgradeTag();
    end;

    internal procedure UpgradeSalesReturnOrderJQ()
    var
        JobQueueEntry: Record "Job Queue Entry";
        EcomSalesDocProcess: Codeunit "NPR EcomSalesDocProcess";
    begin
        UpgradeStep := 'UpgradeSalesReturnOrderJQ';
        if HasUpgradeTag() then
            exit;

        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR IncEcomSalesRetOrderProcJQ");
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        if JobQueueEntry.FindSet() then
            repeat
                JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
                JobQueueEntry.Delete(true)
            until JobQueueEntry.Next() = 0;

        EcomSalesDocProcess.HandleSalesReturnOrderProcessJQScheduleConfirmation(true);
        SetUpgradeTag();
    end;

    internal procedure UpgradeDocumentsToNewTables()
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        IncEcomSalesLine: Record "NPR Inc Ecom Sales Line";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        UpgradeStep := 'UpgradeDocumentsToNewTables';
        if HasUpgradeTag() then
            exit;

        IncEcomSalesHeader.Reset();
        IncEcomSalesHeader.ReadIsolation := IncEcomSalesHeader.ReadIsolation::UpdLock;
        IncEcomSalesHeader.SetCurrentKey(SystemCreatedAt);
        if not IncEcomSalesHeader.FindSet() then
            exit;

        repeat
            Clear(EcomSalesHeader);
            EcomSalesHeader.Init();
            EcomSalesHeader.TransferFields(IncEcomSalesHeader);
            EcomSalesHeader.SystemId := IncEcomSalesHeader.SystemId;
            EcomSalesHeader.Insert(false, true);
            RecordLinkManagement.CopyLinks(IncEcomSalesHeader, EcomSalesHeader);

            IncEcomSalesLine.Reset();
            IncEcomSalesLine.SetRange("Document Type", IncEcomSalesHeader."Document Type");
            IncEcomSalesLine.SetRange("External Document No.", IncEcomSalesHeader."External No.");
            IncEcomSalesLine.ReadIsolation := IncEcomSalesLine.ReadIsolation::UpdLock;
            if IncEcomSalesLine.FindSet() then
                repeat
                    Clear(EcomSalesLine);
                    EcomSalesLine.Init();
                    EcomSalesLine.TransferFields(IncEcomSalesLine);
                    EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
                    EcomSalesLine.SystemId := IncEcomSalesLine.SystemId;
                    EcomSalesLine.Insert(false, true);
                until IncEcomSalesLine.Next() = 0;

            IncEcomSalesPmtLine.Reset();
            IncEcomSalesPmtLine.SetRange("Document Type", IncEcomSalesHeader."Document Type");
            IncEcomSalesPmtLine.SetRange("External Document No.", IncEcomSalesHeader."External No.");
            IncEcomSalesPmtLine.ReadIsolation := IncEcomSalesPmtLine.ReadIsolation::UpdLock;
            if IncEcomSalesPmtLine.FindSet() then
                repeat
                    Clear(EcomSalesPmtLine);
                    EcomSalesPmtLine.Init();
                    EcomSalesPmtLine.TransferFields(IncEcomSalesPmtLine);
                    EcomSalesPmtLine."Document Entry No." := EcomSalesHeader."Entry No.";
                    EcomSalesPmtLine.SystemId := IncEcomSalesPmtLine.SystemId;
                    EcomSalesPmtLine.Insert(false, true);
                until IncEcomSalesPmtLine.Next() = 0;
        until IncEcomSalesHeader.Next() = 0;

        SetUpgradeTag();
    end;

    local procedure HasUpgradeTag(): Boolean
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Inc Ecom Sales Docs", UpgradeStep)) then
            exit(true);
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Inc Ecom Sales Docs', UpgradeStep);
    end;

    local procedure SetUpgradeTag()
    begin
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Inc Ecom Sales Docs", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
#endif