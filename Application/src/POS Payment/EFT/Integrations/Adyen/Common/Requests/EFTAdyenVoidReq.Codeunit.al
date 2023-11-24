codeunit 6184594 "NPR EFT Adyen Void Req"
{
    Access = Internal;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        LookupEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        Json.WriteStartObject('');
        Json.WriteStartObject('SaleToPOIRequest');
        Json.WriteStartObject('MessageHeader');
        Json.WriteStringProperty('MessageClass', 'Service');
        Json.WriteStringProperty('MessageType', 'Request');
        Json.WriteStringProperty('ProtocolVersion', EFTTransactionRequest."Integration Version Code");
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteStringProperty('POIID', EFTTransactionRequest."Hardware ID");
        Json.WriteStringProperty('ServiceID', EFTTransactionRequest."Reference Number Input");
        Json.WriteStringProperty('MessageCategory', 'Reversal');
        Json.WriteEndObject(); // MessageHeader
        Json.WriteStartObject('ReversalRequest');
        Json.WriteStartObject('OriginalPOITransaction');
        Json.WriteStartObject('POITransactionID');
        Json.WriteStringProperty('TimeStamp', Format(EFTTransactionRequest.Started, 0, 9));

        OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
        if OriginalEFTTransactionRequest.Recovered then begin
            LookupEFTTransactionRequest.Get(OriginalEFTTransactionRequest."Recovered by Entry No.");
            Json.WriteStringProperty('TransactionID', LookupEFTTransactionRequest."Reference Number Output");
        end else begin
            Json.WriteStringProperty('TransactionID', OriginalEFTTransactionRequest."Reference Number Output");
        end;

        Json.WriteEndObject(); // POITransactionID
        Json.WriteEndObject(); // OriginalPOITransaction
        Json.WriteStringProperty('ReversalReason', 'MerchantCancel');
        Json.WriteEndObject(); // ReversalRequest
        Json.WriteEndObject(); // SaleToPOIRequest
        Json.WriteEndObject(); // root

        exit(Json.GetJSonAsText());
    end;
}