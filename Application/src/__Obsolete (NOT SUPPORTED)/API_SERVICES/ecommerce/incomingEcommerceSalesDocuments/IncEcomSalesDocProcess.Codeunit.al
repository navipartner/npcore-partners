#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248363 "NPR IncEcomSalesDocProcess"
{
    Access = Internal;
    TableNo = "NPR Inc Ecom Sales Header";
    ObsoleteState = "Pending";
    ObsoleteTag = '2025-10-26';
    ObsoleteReason = 'Replaced with NPR EcomSalesDocProcess';

    trigger OnRun()
    var
        IncEcomSalesDocTryProcess: Codeunit "NPR IncEcomSalesDocTryProcess";
    begin
        ClearLastError();
        Commit();

        Clear(IncEcomSalesDocTryProcess);
        _Success := IncEcomSalesDocTryProcess.Run(Rec);
        Rec.Get(Rec.RecordId);

        HandleResponse(_Success, Rec, _UpdateRetryCount);
        Commit();
        if (not _Success) and _ShowError then
            Error(GetLastErrorText);
    end;

    local procedure HandleResponse(Success: Boolean; var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; UpdateRetryCount: Boolean)
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        IncEcomSalesDocEvents: Codeunit "NPR Inc Ecom Sales Doc Events";
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
        UpdateErrorStatus: Boolean;
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        if UpdateRetryCount then
            IncEcomSalesHeader."Process Retry Count" += 1;

        if not Success then begin
            UpdateErrorStatus := IncEcomSalesHeader."Process Retry Count" >= IncEcomSalesDocSetup."Max Doc Process Retry Count";
            IncEcomSalesDocUtils.SetSalesDocCreationStatusError(IncEcomSalesHeader, CopyStr(GetLastErrorText(), 1, MaxStrLen(IncEcomSalesHeader."Last Error Message")), UpdateErrorStatus, false);
            EmitError(GetLastErrorText());
        end else
            IncEcomSalesDocUtils.SetSalesDocCreationStatusCreated(IncEcomSalesHeader, false);

        IncEcomSalesDocEvents.OnHandleResponseBeforeModifyRecord(Success, IncEcomSalesHeader, UpdateRetryCount);
        IncEcomSalesHeader.Modify(true);
    end;

    internal procedure UpdateSalesDocPaymentLinePostingInformation(PaymentLine: Record "NPR Magento Payment Line")
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line";
        IncEcomSalesDocImpl: Codeunit "NPR Inc Ecom Sales Doc Impl";
        IncEcomSalesDocImplV2: Codeunit "NPR Inc Ecom Sales Doc Impl V2";
    begin
        IncEcomSalesPmtLine.SetLoadFields("Document Type");
        if not IncEcomSalesPmtLine.GetBySystemId(PaymentLine."NPR Inc Ecom Sales Pmt Line Id") then
            exit;

        IncEcomSalesHeader.SetLoadFields("API Version Date");
        if not IncEcomSalesHeader.Get(IncEcomSalesPmtLine."Document Type", IncEcomSalesPmtLine."External Document No.") then
            exit;

        case IncEcomSalesHeader."API Version Date" of
            IncEcomSalesDocImplV2.GetApiVersion():
                IncEcomSalesDocImplV2.UpdateSalesDocumentPaymentLinePostingInformation(PaymentLine);
            else
                IncEcomSalesDocImpl.UpdateSalesDocumentPaymentLinePostingInformation(PaymentLine);
        end;
    end;

    internal procedure UpdateSalesDocPaymentLineCaptureInformation(PaymentLine: Record "NPR Magento Payment Line")
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line";
        IncEcomSalesDocImpl: Codeunit "NPR Inc Ecom Sales Doc Impl";
        IncEcomSalesDocImplV2: Codeunit "NPR Inc Ecom Sales Doc Impl V2";
    begin
        IncEcomSalesPmtLine.SetLoadFields("Document Type");
        if not IncEcomSalesPmtLine.GetBySystemId(PaymentLine."NPR Inc Ecom Sales Pmt Line Id") then
            exit;

        IncEcomSalesHeader.SetLoadFields("API Version Date");
        if not IncEcomSalesHeader.Get(IncEcomSalesPmtLine."Document Type", IncEcomSalesPmtLine."External Document No.") then
            exit;

        case IncEcomSalesHeader."API Version Date" of
            IncEcomSalesDocImplV2.GetApiVersion():
                IncEcomSalesDocImplV2.UpdateSalesDocumentPaymentLineCaptureInformation(PaymentLine);
            else
                IncEcomSalesDocImpl.UpdateSalesDocumentPaymentLineCaptureInformation(PaymentLine);
        end;
    end;

    local procedure HandleSalesOrderProcessJQSchedule(Schedule: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JobDescriptionLbl: Label 'Process Incoming Ecommerce Sales Orders';
    begin
        JobQueueMgt.SetJobTimeout(4, 0);
        JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 30, '');
        if JobQueueMgt.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR IncEcomSalesOrderProcJQ",
                '',
                JobDescriptionLbl,
                CreateDateTime(Today(), 070000T),
                1,
                '',
                JobQueueEntry)
        then
            if Schedule then
                JobQueueMgt.StartJobQueueEntry(JobQueueEntry)
            else
                JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
    end;

    local procedure HandleSalesReturnOrderProcessJQSchedule(Schedule: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JobDescriptionLbl: Label 'Process Incoming Ecommerce Sales Return Orders';
    begin
        JobQueueMgt.SetJobTimeout(4, 0);
        JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 30, '');
        if JobQueueMgt.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR IncEcomSalesRetOrderProcJQ",
                '',
                JobDescriptionLbl,
                CreateDateTime(Today(), 070000T),
                1,
                '',
                JobQueueEntry)
        then
            if Schedule then
                JobQueueMgt.StartJobQueueEntry(JobQueueEntry)
            else
                JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
    end;

    internal procedure HandleSalesOrderProcessJQScheduleConfirmation(Schedule: Boolean)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        DisableAutoProcSalesOrderLbl: Label 'Do you want to disable the auto processing of sales orders?';
        EnableAutoProcSalesOrderLbl: Label 'Do you want to enable the auto processing of sales orders?';
        ConfirmationText: Text;
    begin
        if Schedule then
            ConfirmationText := EnableAutoProcSalesOrderLbl
        else
            ConfirmationText := DisableAutoProcSalesOrderLbl;

        if not ConfirmManagement.GetResponseOrDefault(ConfirmationText, true) then
            exit;

        HandleSalesOrderProcessJQSchedule(Schedule);
    end;

    internal procedure HandleSalesReturnOrderProcessJQScheduleConfirmation(Schedule: Boolean)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        DisableAutoProcSalesOrderLbl: Label 'Do you want to disable the auto processing of sales return orders?';
        EnableAutoProcSalesOrderLbl: Label 'Do you want to enable the auto processing of sales return orders?';
        ConfirmationText: Text;
    begin
        if Schedule then
            ConfirmationText := EnableAutoProcSalesOrderLbl
        else
            ConfirmationText := DisableAutoProcSalesOrderLbl;

        if not ConfirmManagement.GetResponseOrDefault(ConfirmationText, true) then
            exit;

        HandleSalesReturnOrderProcessJQSchedule(Schedule);
    end;

    internal procedure SetUpdateRetryCount(UpdateRetryCount: Boolean)
    begin
        _UpdateRetryCount := UpdateRetryCount;
    end;

    internal procedure GetUpdateRetryCount() UpdateRetryCount: Boolean
    begin
        UpdateRetryCount := _UpdateRetryCount;
    end;

    internal procedure SetShowError(ShowError: Boolean)
    begin
        _ShowError := ShowError;
    end;

    internal procedure GetShowError() ShowError: Boolean
    begin
        ShowError := _ShowError;
    end;

    local procedure EmitError(ErrorText: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin
        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_ErrorText', ErrorText);
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");
        CustomDimensions.Add('NPR_CallStack', GetLastErrorCallStack());

        Session.LogMessage('NPR_API_Ecommerce_IncomingSalesDocumentProcessFailed', ErrorText, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    //The codeunit is obsolete panding and we dont' want these events to fire up
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    // local procedure AutoRefreshJobQueues()
    // var
    //     IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    // begin
    //     //the codeunit is obsolete pending
    //     exit;
    //     if not IncEcomSalesDocSetup.Get() then
    //         IncEcomSalesDocSetup.Init();
    //     HandleSalesOrderProcessJQSchedule(IncEcomSalesDocSetup."Auto Proc Sales Order");
    //     HandleSalesReturnOrderProcessJQSchedule(IncEcomSalesDocSetup."Auto Proc Sales Ret Order");
    // end;

    //The codeunit is obsolete panding and we dont' want these events to fire up
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnCheckIfIsNPRecurringJob, '', false, false)]
    // local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    // begin
    //     if Handled then
    //         exit;

    //     if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
    //        (JobQueueEntry."Object ID to Run" in
    //            [Codeunit::"NPR IncEcomSalesOrderProcJQ",
    //             Codeunit::"NPR IncEcomSalesRetOrderProcJQ"])
    //     then begin
    //         IsNpJob := true;
    //         Handled := true;
    //     end;
    // end;



    var
        _UpdateRetryCount: Boolean;
        _Success: Boolean;
        _ShowError: Boolean;
}
#endif