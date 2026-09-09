#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248656 "NPR EcomSaleDocCaptureProcess"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Header";
    trigger OnRun()
    var
        EcomTryCapture: Codeunit "NPR Ecom Try Capture";
        Sentry: Codeunit "NPR Sentry";
        SentrySpan: Codeunit "NPR Sentry Span";
        OwnsTransaction: Boolean;
    begin
        ClearLastError();
        Commit();
        OwnsTransaction := not Sentry.HasActiveTransaction();
        if OwnsTransaction then begin
            Sentry.InitScopeAndTransaction('E-com Sales Document Capture Process', 'bc.e-com.capture.process');
            Sentry.AddTransactionTag('e-com.externalNo', Rec."External No.");
        end;
        Sentry.StartSpan(SentrySpan, 'bc.e-com.capture.process');
        Clear(EcomTryCapture);
        _Success := EcomTryCapture.Run(Rec);

        if _Success then
            EcomTryCapture.GetResponse(_Success, _ErrorText);

        if not _Success then
            Sentry.AddLastErrorIfProgrammingBug();

        HandleResponse(_Success, _ErrorText, _UpdateRetryCount, Rec);
        Commit();
        SentrySpan.Finish();
        if OwnsTransaction then
            Sentry.FinalizeScope();
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
        end else
            EcomLineCaptureProcess.SetSalesDocCaptureProcessingStatusProcessed(EcomSalesHeader);

        UpdateTicketReservationExpiryTimeAfterCapture(EcomSalesHeader);
    end;

    local procedure UpdateTicketReservationExpiryTimeAfterCapture(var EcommSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
    begin
        if EcommSalesHeader."Ticket Reservation Token" = '' then
            exit;

        EcomCreateTicketImpl.UpdateExpiryTimeBasedOnCapturedStatus(EcommSalesHeader);
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