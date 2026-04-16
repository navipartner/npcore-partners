codeunit 6151069 "NPR EcomProcessWalletsJQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
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
        StartTime := CurrentDateTime();
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

    local procedure ProcessRecords(var JobQueueEntry: Record "Job Queue Entry")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        EcomCreateWalletMgt: Codeunit "NPR EcomCreateWalletMgt";
        BucketFilter: Text;
    begin
        JQParamStrMgt.Parse(JobQueueEntry."Parameter String");
        if JQParamStrMgt.ContainsParam(EcomJobManagement.ParamBucketFilter()) then
            BucketFilter := JQParamStrMgt.GetParamValueAsText(EcomJobManagement.ParamBucketFilter());

        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Creation Status", EcomSalesHeader."Creation Status"::Pending);
        EcomSalesHeader.SetRange("Attraction Wallets Exist", true);
        EcomSalesHeader.SetFilter("Capture Processing Status", '%1|%2', EcomSalesHeader."Capture Processing Status"::"Partially Processed", EcomSalesHeader."Capture Processing Status"::Processed);
        EcomSalesHeader.SetFilter("Attr. Wallet Processing Status", '%1|%2', EcomSalesHeader."Attr. Wallet Processing Status"::"Partially Processed", EcomSalesHeader."Attr. Wallet Processing Status"::Pending);
        EcomSalesHeader.SetFilter("Bucket Id", BucketFilter);
        if EcomSalesHeader.FindSet() then
            repeat
                EcomCreateWalletMgt.CreateWallets(EcomSalesHeader, false, true);
            until EcomSalesHeader.Next() = 0;
    end;

#endif
    local procedure SetJQDescription(): Text
    var
        JobDescriptionLbl: Label 'Process Wallets From Ecommerce Document';
    begin
        exit(JobDescriptionLbl);
    end;

    internal procedure GetCodeunitId(): Integer
    begin
        exit(codeunit::"NPR EcomProcessWalletsJQ");
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
        ScheduleJobQueueConfirmLbl: Label 'Are you sure you want to configure the job queue for ecommerce document wallet processing?';
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
