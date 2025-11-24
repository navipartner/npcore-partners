#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248656 "NPR EcomSaleDocCaptureProcess"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Header";
    trigger OnRun()
    var
        EcomTryCapture: Codeunit "NPR Ecom Try Capture";
    begin
        Commit();
        Clear(EcomTryCapture);
        _Success := EcomTryCapture.Run(Rec);

        if _Success then
            EcomTryCapture.GetResponse(_Success, _ErrorText);

        HandleResponse(_Success, _ErrorText, _UpdateRetryCount, Rec);
        Commit();
        if (not _Success) and _ShowError then
            Error(Rec."Last Capture Error Message");
    end;

    local procedure HandleResponse(Success: Boolean; ErrorText: Text; UpdateRetryCount: Boolean; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomLineCaptureProcess: Codeunit "NPR EcomLineCaptureProcess";
        UpdateErrorStatus: Boolean;
        FullAmtCaptured: Boolean;
        LastErrorText: Text;
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        EcomSalesHeader.ReadIsolation := EcomSalesHeader.ReadIsolation::UpdLock;
        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
        if UpdateRetryCount then
            EcomSalesHeader."Capture Retry Count" += 1;

        if not Success then begin
            LastErrorText := ErrorText;
            if LastErrorText = '' then
                LastErrorText := GetLastErrorText();
            UpdateErrorStatus := EcomSalesHeader."Capture Retry Count" >= IncEcomSalesDocSetup."Max Capture Retry Count";
            EcomLineCaptureProcess.UpdateEcomSalesLineCaptureStatusProcessed(EcomSalesHeader, FullAmtCaptured);
            EcomLineCaptureProcess.SetSalesDocCaptureProcessingStatusError(EcomSalesHeader, CopyStr(LastErrorText, 1, MaxStrLen(EcomSalesHeader."Last Capture Error Message")), UpdateErrorStatus);
            EmitError(LastErrorText);
        end else
            EcomLineCaptureProcess.SetSalesDocCaptureProcessingStatusProcessed(EcomSalesHeader);
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

        Session.LogMessage('NPR_API_Ecommerce_IncomingSalesDocumentLineCaptureProcessFailed', ErrorText, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    internal procedure SetShowError(ShowError: Boolean)
    begin
        _ShowError := ShowError;
    end;

    internal procedure SetUpdateRetryCount(UpdateRetryCount: Boolean)
    begin
        _UpdateRetryCount := UpdateRetryCount;
    end;

    internal procedure GetUpdateRetryCount() UpdateRetryCount: Boolean
    begin
        UpdateRetryCount := _UpdateRetryCount;
    end;

    var
        _Success: Boolean;
        _ShowError: Boolean;
        _UpdateRetryCount: Boolean;
        _ErrorText: Text;
}
#endif