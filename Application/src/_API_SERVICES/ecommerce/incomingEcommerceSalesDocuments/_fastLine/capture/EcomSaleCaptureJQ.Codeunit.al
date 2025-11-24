codeunit 6248538 "NPR EcomSaleCaptureJQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
    begin
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        Process(Rec)
#endif
    end;
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    local procedure Process(var JobQueueEntry: Record "Job Queue Entry")
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        StartTime: DateTime;
        MaxDuration: Duration;
    begin
        StartTime := CurrentDateTime;
        MaxDuration := GetDefaultDuration();

        repeat
            ProcessRecords(JobQueueEntry);
            Sleep(1000);
        until EcomJobManagement.DurationLimitReached(StartTime, MaxDuration);
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
        JobDescriptionLbl: label 'Capture virtual items from Ecommerce Sales Documents';
    begin
        exit(JobDescriptionLbl);
    end;

    internal procedure ScheduleJobQueue()
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
    begin
        EcomJobManagement.ScheduleJobQueue(GetCodeunitId(), SetJQDescription());
    end;

    internal procedure ScheduleJobQueueWithConfirmation()
    var
        ConfirmManagemnet: Codeunit "Confirm Management";
        ScheduleJobQueueConfirmLbl: Label 'Are you sure you want to configure the job queue for ecommerce document virtual items capture processing?';
    begin
        if not ConfirmManagemnet.GetResponseOrDefault(ScheduleJobQueueConfirmLbl, true) then
            exit;

        ScheduleJobQueue();
    end;

    local procedure ProcessRecords(var JobQueueEntry: Record "Job Queue Entry")
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        EcomSaleDocCaptureProcess: Codeunit "NPR EcomSaleDocCaptureProcess";
        BucketFilter: Text;
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        JQParamStrMgt.Parse(JobQueueEntry."Parameter String");
        if JQParamStrMgt.ContainsParam(EcomJobManagement.ParamBucketFilter()) then
            BucketFilter := JQParamStrMgt.GetParamValueAsText(EcomJobManagement.ParamBucketFilter());

        EcomSalesHeader.Reset();
        EcomSalesHeader.SetRange("Creation Status", EcomSalesHeader."Creation Status"::Pending);
        EcomSalesHeader.SetRange("Virtual Items Exist", true);
        EcomSalesHeader.SetFilter("Capture Processing Status", '%1|%2', EcomSalesHeader."Capture Processing Status"::Pending, EcomSalesHeader."Capture Processing Status"::"Partially Processed");
        EcomSalesHeader.SetFilter("Bucket Id", BucketFilter);
        EcomSalesHeader.SetFilter("Capture Retry Count", '<=%1', IncEcomSalesDocSetup."Max Capture Retry Count");
        if EcomSalesHeader.FindSet() then
            repeat
                Clear(EcomSaleDocCaptureProcess);
                EcomSaleDocCaptureProcess.SetUpdateRetryCount(true);
                EcomSaleDocCaptureProcess.SetShowError(false);
                if EcomSaleDocCaptureProcess.Run(EcomSalesHeader) then;
            until EcomSalesHeader.Next() = 0;
    end;

#endif
    #region interface procedures
    internal procedure GetCodeunitId(): Integer;
    begin
        exit(codeunit::"NPR EcomSaleCaptureJQ");
    end;
    #endregion

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
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
#endif
}