codeunit 6184598 "NPR EFT Adyen Diagnose Req"
{
    Access = Internal;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
    begin
        Json.WriteStartObject('');
        Json.WriteStartObject('SaleToPOIRequest');
        Json.WriteStartObject('MessageHeader');
        Json.WriteStringProperty('ProtocolVersion', EFTTransactionRequest."Integration Version Code");
        Json.WriteStringProperty('MessageClass', 'Service');
        Json.WriteStringProperty('MessageCategory', 'Diagnosis');
        Json.WriteStringProperty('MessageType', 'Request');
        Json.WriteStringProperty('ServiceID', EFTTransactionRequest."Reference Number Input");
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteStringProperty('POIID', EFTTransactionRequest."Hardware ID");
        Json.WriteEndObject(); // MessageHeader
        Json.WriteStartObject('DiagnosisRequest');
        Json.WriteBooleanProperty('HostDiagnosisFlag', true);
        Json.WriteEndObject(); // DiagnosisRequest
        Json.WriteEndObject(); // SaleToPOIRequest
        Json.WriteEndObject(); // root

        exit(Json.GetJSonAsText());
    end;
}