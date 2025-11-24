#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248612 "NPR EcomSalesOrderProcJQ"
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
            ProcessSalesOrders(JobQueueEntry);
            Sleep(1000);
        until EcomJobManagement.DurationLimitReached(StartTime, MaxDuration);

    end;

    local procedure ProcessSalesOrders(var JobQueueEntry: Record "Job Queue Entry")
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        EcomSalesDocProcess: Codeunit "NPR EcomSalesDocProcess";
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        BucketFilter: Text;
        SalesOrderNoTextFilter: Text;
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        JQParamStrMgt.Parse(JobQueueEntry."Parameter String");
        if JQParamStrMgt.ContainsParam(EcomJobManagement.ParamBucketFilter()) then
            BucketFilter := JQParamStrMgt.GetParamValueAsText(EcomJobManagement.ParamBucketFilter());


        //We're processing first the vouchers in order to apply filters that will prevent locking. 
        EcomSalesHeader.Reset();
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Creation Status", EcomSalesHeader."Creation Status"::Pending);
        EcomSalesHeader.SetRange("Virtual Items Exist", true);
        EcomSalesHeader.SetRange("Virtual Items Process Status", EcomSalesHeader."Virtual Items Process Status"::Processed);
        EcomSalesHeader.SetFilter("Process Retry Count", '<=%1', IncEcomSalesDocSetup."Max Doc Process Retry Count");
        EcomSalesHeader.SetFilter("Bucket Id", BucketFilter);

        if JQParamStrMgt.ContainsParam(ParamSalesOrderNo()) then begin
            SalesOrderNoTextFilter := JQParamStrMgt.GetParamValueAsText(ParamSalesOrderNo());
            if SalesOrderNoTextFilter <> '' then
                EcomSalesHeader.SetFilter("External No.", SalesOrderNoTextFilter);
        end;

        if EcomSalesHeader.FindSet() then
            repeat
                Clear(EcomSalesDocProcess);
                EcomSalesDocProcess.SetShowError(false);
                EcomSalesDocProcess.SetUpdateRetryCount(true);
                if EcomSalesDocProcess.Run(EcomSalesHeader) then;
            until EcomSalesHeader.Next() = 0;

        //Process non virutal item orders
        EcomSalesHeader.Reset();
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Creation Status", EcomSalesHeader."Creation Status"::Pending);
        EcomSalesHeader.SetFilter("Bucket Id", BucketFilter);
        EcomSalesHeader.SetRange("Virtual Items Exist", false);
        EcomSalesHeader.SetRange("Virtual Items Process Status", EcomSalesHeader."Virtual Items Process Status"::Pending);
        EcomSalesHeader.SetFilter("Process Retry Count", '<=%1', IncEcomSalesDocSetup."Max Doc Process Retry Count");
        EcomSalesHeader.SetFilter("External No.", SalesOrderNoTextFilter);
        if EcomSalesHeader.FindSet() then
            repeat
                Clear(EcomSalesDocProcess);
                EcomSalesDocProcess.SetShowError(false);
                EcomSalesDocProcess.SetUpdateRetryCount(true);
                if EcomSalesDocProcess.Run(EcomSalesHeader) then;
            until EcomSalesHeader.Next() = 0;
    end;

    internal procedure ParamSalesOrderNo(): Text
    begin
        exit('salesOrderNo');
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
        JobDescriptionLbl: label 'Process Ecommerce Sales Orders';
    begin
        exit(JobDescriptionLbl);
    end;

    internal procedure GetCodeunitId(): Integer;
    begin
        exit(codeunit::"NPR EcomSalesOrderProcJQ");
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
        ScheduleJobQueueConfirmLbl: Label 'Are you sure you want to configure the job queue for Ecommerce sales orders processing?';
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