#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248750 "NPR API EFT Adyen Cloud" implements "NPR API EFT Provider"
{
    Access = Internal;

    var
        _Sentry: Codeunit "NPR Sentry";

    procedure IntegrationType(): Code[20]
    var
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        exit(EFTAdyenIntegration.CloudIntegrationType());
    end;

    procedure Flow(): Enum "NPR API EFT Flow"
    begin
        exit(Enum::"NPR API EFT Flow"::Cloud);
    end;

#pragma warning disable AA0150
    procedure ValidateSetup(EFTSetup: Record "NPR EFT Setup"; POSUnitNo: Code[10]; var ErrorMessage: Text): Boolean
#pragma warning restore
    begin
        exit(true);
    end;

#pragma warning disable AA0150
    procedure ValidateStart(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; var ErrorMessage: Text): Boolean
#pragma warning restore
    begin
        exit(true);
    end;

    procedure StartCloudPayment(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; POSSale: Record "NPR POS Sale")
    var
        EFTAdyenTrxRequest: Codeunit "NPR EFT Adyen Trx Request";
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        RequestJson: Text;
        ResponseText: Text;
        Logs: Text;
        ErrorText: Text;
        URL: Text;
        ResponseStatusCode: Integer;
    begin
        RequestJson := EFTAdyenTrxRequest.GetRequestJson(EFTTransactionRequest, EFTSetup);
        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);

        if not EFTAdyenCloudProtocol.InvokeAPI(RequestJson, GetApiKey(EFTSetup), URL, 300000, ResponseText, ResponseStatusCode) then begin
            Logs := EFTAdyenCloudProtocol.GetLogBuffer();
            ErrorText := GetLastErrorText();
            EFTAdyenResponseHandler.ProcessResponse(EFTTransactionRequest."Entry No.", ResponseText, false, true, ErrorText);
            EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, true, 'API Start (Error)', Logs);
            exit;
        end;

        Logs := EFTAdyenCloudProtocol.GetLogBuffer();
        EFTAdyenResponseHandler.ProcessResponse(EFTTransactionRequest."Entry No.", ResponseText, ResponseStatusCode in [0, 200], true, '');
        EFTAdyenIntegration.WriteLogEntry(EFTTransactionRequest, false, 'API Start (Complete)', Logs);
    end;

    procedure CancelCloudPayment(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup")
    var
        AbortEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTAdyenAbortMgmt: Codeunit "NPR EFT Adyen Abort Mgmt";
        EFTAdyenAbortTrxReq: Codeunit "NPR EFT Adyen AbortTrx Req";
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        AbortRequestJson: Text;
        AbortResponseText: Text;
        URL: Text;
        AbortResponseStatusCode: Integer;
    begin
        AbortEFTTransactionRequest.Get(EFTAdyenAbortMgmt.CreateAbortTransactionRequest(EFTTransactionRequest));
        AbortRequestJson := EFTAdyenAbortTrxReq.GetRequestJson(AbortEFTTransactionRequest, EFTTransactionRequest);
        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);

        if not EFTAdyenCloudProtocol.InvokeAPI(AbortRequestJson, GetApiKey(EFTSetup), URL, 30000, AbortResponseText, AbortResponseStatusCode) then
            _Sentry.AddLastErrorIfProgrammingBug();
    end;

    [NonDebuggable]
    local procedure GetApiKey(EFTSetup: Record "NPR EFT Setup"): Text
    var
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        EFTAdyenIntegration.GetPaymentTypeParameters(EFTSetup, EFTAdyenPaymTypeSetup);
        exit(EFTAdyenPaymTypeSetup.GetApiKey());
    end;
}
#endif
