codeunit 6184612 "NPR EFT Adyen Contract Mgmt."
{

    //This operation is not handled via the terminal integration so it is always via webservice request, even for the local adyen integration.

    Access = Internal;

    procedure DisableRecurringContract(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTSetup: Record "NPR EFT Setup";
        Response: Text;
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        Completed: Boolean;
        StatusCode: Integer;
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Protocol";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        EFTAdyenCloudIntegrat: Codeunit "NPR EFT Adyen Cloud Integrat.";
        Request: Text;
        URL: Text;
        EFTAdyenDisableCtrctReq: Codeunit "NPR EFT Adyen DisableCtrct Req";
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        Request := EFTAdyenDisableCtrctReq.GetRequestJson(EftTransactionRequest, EFTAdyenIntegration.GetMerchantAccount(EFTSetup));
        URL := EFTAdyenCloudProtocol.GetTerminalURL(EFTTransactionRequest);
        ClearLastError();
        Completed := EFTAdyenCloudProtocol.InvokeAPI(Request, EFTAdyenCloudIntegrat.GetAPIKey(EFTSetup), URL, 1000 * 60 * 5, Response, StatusCode);

        EFTAdyenIntegration.WriteLogEntry(EftTransactionRequest, not Completed, 'Invoke', EFTAdyenCloudProtocol.GetLogBuffer());
        EFTAdyenResponseHandler.ProcessResponse(EftTransactionRequest."Entry No.", Response, Completed, false, GetLastErrorText());
    end;
}