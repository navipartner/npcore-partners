#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248649 "NPR EcomLineCaptureProcess"
{
    Access = Internal;
    TableNo = "NPR Magento Payment Line";

    trigger OnRun()
    var
        EcomSalesLineTryProcess: Codeunit "NPR EcomLineCaptureTryProcess";
    begin
        Commit();

        Clear(EcomSalesLineTryProcess);
        _Success := EcomSalesLineTryProcess.Run(Rec);
        if not _Success then
            _LastErrorText := GetLastErrorText;

        if not _SkipHandleResponse then
            HandleResponse(_Success, Rec, _UpdateRetryCount);
        Commit();
        if (not _Success) and _ShowError and not _SkipHandleResponse then
            Error(GetLastErrorText);
    end;

    local procedure HandleResponse(Success: Boolean; var PaymentLine: Record "NPR Magento Payment Line"; UpdateRetryCount: Boolean)
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomVirtualItemEvents: Codeunit "NPR EcomVirtualItemEvents";
        UpdateErrorStatus: Boolean;
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        EcomSalesHeader.GetBySystemId(PaymentLine."NPR Inc Ecom Sale Id");
        if UpdateRetryCount then
            EcomSalesHeader."Capture Retry Count" += 1;

        if not Success then begin
            UpdateErrorStatus := EcomSalesHeader."Capture Retry Count" >= IncEcomSalesDocSetup."Max Capture Retry Count";
            SetSalesDocCaptureProcessingStatusError(EcomSalesHeader, CopyStr(GetLastErrorText(), 1, MaxStrLen(EcomSalesHeader."Last Capture Error Message")), UpdateErrorStatus);
            EmitError(GetLastErrorText());
        end else
            SetSalesDocCaptureProcessingStatusProcessed(EcomSalesHeader);

        EcomVirtualItemEvents.OnHandleCaptureLineResponseBeforeModifyRecord(Success, EcomSalesHeader, PaymentLine, UpdateRetryCount);
        EcomSalesHeader.Modify(true);
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

    internal procedure SetSalesDocCaptureProcessingStatusError(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ErrorMessage: Text[500]; UpdateStatus: Boolean)
    var
        EcomVirtualItemEvents: Codeunit "NPR EcomVirtualItemEvents";
    begin
        EcomSalesHeader."Last Capture Error Message" := ErrorMessage;

        if UpdateStatus then
            EcomSalesHeader."Capture Processing Status" := EcomSalesHeader."Capture Processing Status"::Error;

        EcomVirtualItemEvents.OnSetSalesDocCaptureProcessingStatusErrorBeforeModify(EcomSalesHeader, ErrorMessage, UpdateStatus);
        EcomSalesHeader.Modify(true);
    end;

    internal procedure SetSalesDocCaptureProcessingStatusProcessed(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        FullAmtCaptured: Boolean;
    begin
        UpdateEcomSalesLineCaptureStatusProcessed(EcomSalesHeader, FullAmtCaptured);
        UpdateEcomSalesHeaderInformationProcessed(EcomSalesHeader, FullAmtCaptured);
    end;

    local procedure UpdateEcomSalesHeaderInformationProcessed(var EcomSalesHeader: Record "NPR Ecom Sales Header"; FullAmtCaptured: Boolean)
    var
        EcomVirtualItemEvents: Codeunit "NPR EcomVirtualItemEvents";
    begin
        if FullAmtCaptured then
            EcomSalesHeader."Capture Processing Status" := EcomSalesHeader."Capture Processing Status"::Processed
        else
            EcomSalesHeader."Capture Processing Status" := EcomSalesHeader."Capture Processing Status"::"Partially Processed";

        EcomSalesHeader."Last Capture Error Message" := '';
        EcomVirtualItemEvents.OnSetSalesDocCaptureProcessingStatusProcessedBeforeModify(EcomSalesHeader);
        EcomSalesHeader.Modify(true);
    end;

    internal procedure UpdateEcomSalesLineCaptureStatusProcessed(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var FullAmtCaptured: Boolean)
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        CapturedPaymentLine: Record "NPR Magento Payment Line";
        EcomVirtualItemEvents: Codeunit "NPR EcomVirtualItemEvents";
        CapturedPaymentAmount: Decimal;
        CapturedSalesAmount: Decimal;
        SalesAmount: Decimal;
    begin
        CapturedPaymentLine.Reset();
        CapturedPaymentLine.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        CapturedPaymentLine.SetFilter("Date Captured", '<>%1', 0D);
        CapturedPaymentLine.CalcSums(Amount);
        CapturedPaymentAmount := CapturedPaymentLine.Amount;

        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetFilter(Type, '%1', EcomSalesLine.Type::Voucher);
        EcomSalesLine.SetFilter("Unit Price", '<>0');
        EcomSalesLine.SetFilter(Quantity, '<>0');
        EcomSalesLine.SetRange(Captured, true);
        EcomSalesLine.SetLoadFields("Line Amount", "VAT %");
        if EcomSalesLine.FindSet() then
            repeat
                if not EcomSalesHeader."Price Excl. VAT" then
                    CapturedSalesAmount += EcomSalesLine."Line Amount" * (1 + (EcomSalesLine."VAT %" / 100))
                else
                    CapturedSalesAmount += EcomSalesLine."Line Amount";
            until (EcomSalesLine.Next() = 0);

        CapturedPaymentAmount -= CapturedSalesAmount;
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetFilter(Type, '%1', EcomSalesLine.Type::Voucher);
        EcomSalesLine.SetFilter("Unit Price", '<>0');
        EcomSalesLine.SetFilter(Quantity, '<>0');
        EcomSalesLine.SetRange(Captured, false);
        EcomSalesLine.ReadIsolation := EcomSalesLine.ReadIsolation::UpdLock;
        if EcomSalesLine.FindSet() then
            repeat
                if not EcomSalesHeader."Price Excl. VAT" then
                    SalesAmount := EcomSalesLine."Line Amount" * (1 + (EcomSalesLine."VAT %" / 100))
                else
                    SalesAmount := EcomSalesLine."Line Amount";
                CapturedPaymentAmount -= SalesAmount;
                if CapturedPaymentAmount >= 0 then begin
                    EcomSalesLine.Captured := true;
                    EcomVirtualItemEvents.OnUpdateEcomSalesLineCaptureStatusProcessedBeforeModify(EcomSalesHeader, CapturedPaymentAmount, EcomSalesLine);
                    EcomSalesLine.Modify();
                end;
            until (EcomSalesLine.Next() = 0) or (CapturedPaymentAmount <= 0);

        FullAmtCaptured := CapturedPaymentAmount >= 0;
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

    internal procedure SetSkipHandleResponse(SkipHandleResponse: Boolean)
    begin
        _SkipHandleResponse := SkipHandleResponse;

    end;

    internal procedure GetSkipHandleResponse() SkipHandleResponse: Boolean
    begin
        SkipHandleResponse := _SkipHandleResponse;
    end;



    internal procedure GetResponse(var Success: Boolean; var LastErrorText: Text);
    begin
        Success := _Success;
        LastErrorText := _LastErrorText;
    end;


    var

        _Success: Boolean;
        _ShowError: Boolean;
        _UpdateRetryCount: Boolean;
        _SkipHandleResponse: Boolean;
        _LastErrorText: Text;

}
#endif