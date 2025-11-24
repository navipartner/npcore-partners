#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248610 "NPR EcomSalesDocProcess"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Header";

    trigger OnRun()
    var
        EcomSalesDocTryProcess: Codeunit "NPR EcomSalesDocTryProcess";
    begin
        ClearLastError();
        Commit();

        Clear(EcomSalesDocTryProcess);
        _Success := EcomSalesDocTryProcess.Run(Rec);
        Rec.ReadIsolation := Rec.ReadIsolation::UpdLock;
        Rec.Get(Rec.RecordId);

        HandleResponse(_Success, Rec, _UpdateRetryCount);
        Commit();
        if (not _Success) and _ShowError then
            Error(GetLastErrorText);
    end;

    local procedure HandleResponse(Success: Boolean; var EcomSalesHeader: Record "NPR Ecom Sales Header"; UpdateRetryCount: Boolean)
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomSalesDocEvents: Codeunit "NPR Ecom Sales Doc Events";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        UpdateErrorStatus: Boolean;
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        if UpdateRetryCount then
            EcomSalesHeader."Process Retry Count" += 1;

        if not Success then begin
            UpdateErrorStatus := EcomSalesHeader."Process Retry Count" >= IncEcomSalesDocSetup."Max Doc Process Retry Count";
            EcomSalesDocUtils.SetSalesDocCreationStatusError(EcomSalesHeader, CopyStr(GetLastErrorText(), 1, MaxStrLen(EcomSalesHeader."Last Error Message")), UpdateErrorStatus, false);
            EmitError(GetLastErrorText());
        end else
            EcomSalesDocUtils.SetSalesDocCreationStatusCreated(EcomSalesHeader, false);

        EcomSalesDocEvents.OnHandleResponseBeforeModifyRecord(Success, EcomSalesHeader, UpdateRetryCount);
        EcomSalesHeader.Modify(true);
    end;

    internal procedure UpdateSalesDocPaymentLinePostingInformation(PaymentLine: Record "NPR Magento Payment Line")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        EcomSalesDocImpl: Codeunit "NPR Ecom Sales Doc Impl";
        EcomSalesDocImplV2: Codeunit "NPR Ecom Sales Doc Impl V2";
    begin
        EcomSalesPmtLine.SetLoadFields("Document Type");
        if not EcomSalesPmtLine.GetBySystemId(PaymentLine."NPR Inc Ecom Sales Pmt Line Id") then
            exit;

        EcomSalesHeader.SetLoadFields("API Version Date");
        if not EcomSalesHeader.Get(EcomSalesPmtLine."Document Entry No.") then
            exit;

        case EcomSalesHeader."API Version Date" of
            EcomSalesDocImplV2.GetApiVersion():
                EcomSalesDocImplV2.UpdateSalesDocumentPaymentLinePostingInformation(PaymentLine);
            else
                EcomSalesDocImpl.UpdateSalesDocumentPaymentLinePostingInformation(PaymentLine);
        end;
    end;

    internal procedure UpdateSalesDocPaymentLineCaptureInformation(PaymentLine: Record "NPR Magento Payment Line")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        EcomSalesDocImpl: Codeunit "NPR Ecom Sales Doc Impl";
        EcomSalesDocImplV2: Codeunit "NPR Ecom Sales Doc Impl V2";
    begin
        EcomSalesPmtLine.SetLoadFields("Document Type");
        if not EcomSalesPmtLine.GetBySystemId(PaymentLine."NPR Inc Ecom Sales Pmt Line Id") then
            exit;

        EcomSalesHeader.SetLoadFields("API Version Date");
        if not EcomSalesHeader.Get(EcomSalesPmtLine."Document Entry No.") then
            exit;

        case EcomSalesHeader."API Version Date" of
            EcomSalesDocImplV2.GetApiVersion():
                EcomSalesDocImplV2.UpdateSalesDocumentPaymentLineCaptureInformation(PaymentLine);
            else
                EcomSalesDocImpl.UpdateSalesDocumentPaymentLineCaptureInformation(PaymentLine);
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
                Codeunit::"NPR EcomSalesOrderProcJQ",
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
                Codeunit::"NPR EcomSalesRetOrderProcJQ",
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure AutoRefreshJobQueues()
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();
        HandleSalesReturnOrderProcessJQSchedule(IncEcomSalesDocSetup."Auto Proc Sales Ret Order");
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnCheckIfIsNPRecurringJob, '', false, false)]
    local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;

        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" = Codeunit::"NPR EcomSalesRetOrderProcJQ")
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;

    var
        _UpdateRetryCount: Boolean;
        _Success: Boolean;
        _ShowError: Boolean;
}
#endif