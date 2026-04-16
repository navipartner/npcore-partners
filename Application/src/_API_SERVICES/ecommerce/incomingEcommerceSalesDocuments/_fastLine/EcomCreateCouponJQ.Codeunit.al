codeunit 6151117 "NPR EcomCreateCouponJQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        Process(Rec)
#endif
    end;
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
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
            ProcessRecords(JobQueueEntry);
            Commit();
            if JobQueueEntry."Recurring Job" then
                Sleep(1000);
        until not JobQueueEntry."Recurring Job" or EcomJobManagement.DurationLimitReached(StartTime, MaxDuration);
    end;

    local procedure GetDefaultDuration(): Duration
    var
        Timeout: Duration;
    begin
        Timeout := 60 * 60 * 1000 * 6; // 6H
        exit(Timeout);
    end;

    local procedure ProcessRecords(var JobQueueEntry: Record "Job Queue Entry");
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        BucketFilter: Text;
    begin
        JQParamStrMgt.Parse(JobQueueEntry."Parameter String");
        if JQParamStrMgt.ContainsParam(EcomJobManagement.ParamBucketFilter()) then
            BucketFilter := JQParamStrMgt.GetParamValueAsText(EcomJobManagement.ParamBucketFilter());

        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Creation Status", EcomSalesHeader."Creation Status"::Pending);
        EcomSalesHeader.SetRange("Coupons Exist", true);
        EcomSalesHeader.SetFilter("Capture Processing Status", '%1|%2', EcomSalesHeader."Capture Processing Status"::"Partially Processed", EcomSalesHeader."Capture Processing Status"::Processed);
        EcomSalesHeader.SetFilter("Coupon Processing Status", '%1|%2', EcomSalesHeader."Coupon Processing Status"::"Partially Processed", EcomSalesHeader."Coupon Processing Status"::Pending);
        EcomSalesHeader.SetFilter("Bucket Id", BucketFilter);
        if EcomSalesHeader.FindSet() then
            repeat
                EcomVirtualItemMgt.CreateCoupons(EcomSalesHeader, false, true);
            until EcomSalesHeader.Next() = 0;
    end;
#endif
    local procedure SetJQDescription(): Text;
    var
        JobDescriptionLbl: label 'Process Coupon From Ecommerce Document';
    begin
        exit(JobDescriptionLbl);
    end;

    internal procedure GetCodeunitId(): Integer;
    begin
        exit(codeunit::"NPR EcomCreateCouponJQ");
    end;

    local procedure ScheduleJobQueue()
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
    begin
        EcomJobManagement.ScheduleJobQueue(GetCodeunitId(), SetJQDescription());
    end;

    internal procedure ScheduleJobQueueWithConfirmation()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ScheduleJobQueueConfirmLbl: Label 'Are you sure you want to configure the job queue for ecommerce document coupon processing?';
    begin
        if not ConfirmManagement.GetResponseOrDefault(ScheduleJobQueueConfirmLbl, true) then
            exit;

        ScheduleJobQueue();
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", OnAfterValidateEvent, 'Object ID to Run', true, true)]
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
