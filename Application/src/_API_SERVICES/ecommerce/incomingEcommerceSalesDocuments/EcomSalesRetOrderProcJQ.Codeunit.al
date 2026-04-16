#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248613 "NPR EcomSalesRetOrderProcJQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        Process(Rec);
    end;

    local procedure Process(var JobQueueEntry: Record "Job Queue Entry")
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        StartTime: DateTime;
        MaxDuration: Duration;
    begin
        StartTime := CurrentDateTime;
        MaxDuration := GetDefaultDuration();

        repeat
            if EcomJobManagement.ShouldSoftExit(JobQueueEntry.ID) then
                exit;
            ProcessSalesReturnOrders(JobQueueEntry);
            Commit();
            if JobQueueEntry."Recurring Job" then
                Sleep(1000);
        until (not JobQueueEntry."Recurring Job") or EcomJobManagement.DurationLimitReached(StartTime, MaxDuration);

    end;

    local procedure ProcessSalesReturnOrders(var JobQueueEntry: Record "Job Queue Entry")
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        EcomSalesDocProcess: Codeunit "NPR EcomSalesDocProcess";
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        SalesOrderNoTextFilter: Text;
        BucketFilter: Text;
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        JQParamStrMgt.Parse(JobQueueEntry."Parameter String");
        if JQParamStrMgt.ContainsParam(EcomJobManagement.ParamBucketFilter()) then
            BucketFilter := JQParamStrMgt.GetParamValueAsText(EcomJobManagement.ParamBucketFilter());

        EcomSalesHeader.Reset();
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::"Return Order");
        EcomSalesHeader.SetRange("Creation Status", EcomSalesHeader."Creation Status"::Pending);
        EcomSalesHeader.SetFilter("Process Retry Count", '<=%1', IncEcomSalesDocSetup."Max Doc Process Retry Count");
        if BucketFilter <> '' then
            EcomSalesHeader.SetFilter("Bucket Id", BucketFilter);

        if JQParamStrMgt.ContainsParam(ParamSalesReturnOrderNo()) then begin
            SalesOrderNoTextFilter := JQParamStrMgt.GetParamValueAsText(ParamSalesReturnOrderNo());
            if SalesOrderNoTextFilter <> '' then
                EcomSalesHeader.SetFilter("External No.", SalesOrderNoTextFilter);
        end;

        if not EcomSalesHeader.FindSet() then
            exit;
        repeat
            Clear(EcomSalesDocProcess);
            EcomSalesDocProcess.SetShowError(false);
            EcomSalesDocProcess.SetUpdateRetryCount(true);
            EcomSalesDocProcess.Run(EcomSalesHeader);
        until EcomSalesHeader.Next() = 0;
    end;

    internal procedure ParamSalesReturnOrderNo(): Text
    begin
        exit('salesReturnOrderNo');
    end;

    local procedure GetDefaultDuration(): Duration
    var
        Timeout: Duration;
    begin
        Timeout := 60 * 60 * 1000 * 6; // 6H
        exit(Timeout);
    end;

    local procedure SetJQDescription(): Text;
    var
        JobDescriptionLbl: label 'Process Ecommerce Sales Return Orders';
    begin
        exit(JobDescriptionLbl);
    end;

    internal procedure GetCodeunitId(): Integer;
    begin
        exit(codeunit::"NPR EcomSalesRetOrderProcJQ");
    end;

    local procedure ScheduleJobQueue()
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
    begin
        EcomJobManagement.ScheduleJobQueue(GetCodeunitId(), SetJQDescription());
    end;

    internal procedure ScheduleJobQueueWithConfirmation()
    var
        ConfirmManagemnet: Codeunit "Confirm Management";
        ScheduleJobQueueConfirmLbl: Label 'Are you sure you want to configure the job queue for Ecommerce sales return orders processing?';
    begin
        if not ConfirmManagemnet.GetResponseOrDefault(ScheduleJobQueueConfirmLbl, true) then
            exit;

        ScheduleJobQueue();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry")
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> GetCodeunitId() then
            exit;
        if Rec.Description = '' then
            Rec.Description := CopyStr(SetJQDescription(), 1, MaxStrLen(Rec.Description));

        if Rec."Parameter String" = '' then
            Rec."Parameter String" := CopyStr((EcomJobManagement.ParamBucketFilter() + '='), 1, MaxStrLen(Rec."Parameter String"));
    end;
}
#endif