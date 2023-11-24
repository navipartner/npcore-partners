codeunit 6184595 "NPR EFT Adyen AbortTrx Req"
{
    Access = Internal;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
    begin
        Json.WriteStartObject('');
        Json.WriteStartObject('SaleToPOIRequest');
        Json.WriteStartObject('AbortRequest');
        Json.WriteStringProperty('AbortReason', 'MerchantAbort');
        Json.WriteStartObject('MessageReference');
        Json.WriteStringProperty('ServiceID', EFTTransactionRequest."Processed Entry No.");
        Json.WriteStringProperty('MessageCategory', GetMessageCategory(EFTTransactionRequest));
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteEndObject(); // MessageReference
        Json.WriteEndObject(); // AbortRequest
        Json.WriteStartObject('MessageHeader');
        Json.WriteStringProperty('MessageType', 'Request');
        Json.WriteStringProperty('MessageCategory', 'Abort');
        Json.WriteStringProperty('MessageClass', 'Service');
        Json.WriteStringProperty('ServiceID', EFTTransactionRequest."Reference Number Input");
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteStringProperty('POIID', EFTTransactionRequest."Hardware ID");
        Json.WriteStringProperty('ProtocolVersion', EFTTransactionRequest."Integration Version Code");
        Json.WriteEndObject(); // MessageHeader
        Json.WriteEndObject(); // SaleToPOIRequest
        Json.WriteEndObject(); // Root

        exit(Json.GetJSonAsText());
    end;

    local procedure GetMessageCategory(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    begin
        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT,
            EFTTransactionRequest."Processing Type"::REFUND:
                exit('Payment');
            else
                exit('CardAcquisition');
        end;
    end;
}