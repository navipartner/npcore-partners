
codeunit 6184596 "NPR EFT Adyen AbortAcquire Req"
{
    Access = Internal;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        ABORT_ACQUIRE_SWIPE_HEADER: Label 'Card Scanned';
        ABORT_ACQUIRE_SWIPE_LINE: Label 'Please Remove Card';
    begin
        Json.WriteStartObject('');
        Json.WriteStartObject('SaleToPOIRequest');
        Json.WriteStartObject('MessageHeader');
        Json.WriteStringProperty('MessageType', 'Request');
        Json.WriteStringProperty('MessageCategory', 'EnableService');
        Json.WriteStringProperty('MessageClass', 'Service');
        Json.WriteStringProperty('ServiceID', EFTTransactionRequest."Reference Number Input");
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteStringProperty('POIID', EFTTransactionRequest."Hardware ID");
        Json.WriteStringProperty('ProtocolVersion', EFTTransactionRequest."Integration Version Code");
        Json.WriteEndObject(); // MessageHeader
        Json.WriteStartObject('EnableServiceRequest');
        Json.WriteStringProperty('TransactionAction', 'AbortTransaction');
        if EFTTransactionRequest."Processed Entry No." <> 0 then begin
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
            if OriginalEFTTransactionRequest."Auxiliary Operation ID" in ["NPR EFT Adyen Aux Operation"::DETECT_SHOPPER.AsInteger(), "NPR EFT Adyen Aux Operation"::CLEAR_SHOPPER.AsInteger()] then begin
                Json.WriteStartObject('DisplayOutput');
                Json.WriteStringProperty('Device', 'CustomerDisplay');
                Json.WriteStringProperty('InfoQualify', 'Display');
                Json.WriteStartObject('OutputContent');
                Json.WriteStartObject('PredefinedContent');
                Json.WriteStringProperty('ReferenceID', 'CustomAnimated');
                Json.WriteEndObject(); // PredefinedContent
                Json.WriteStringProperty('OutputFormat', 'Text');
                Json.WriteStartArray('OutputText');
                Json.WriteStartObject('');
                Json.WriteStringProperty('Text', ABORT_ACQUIRE_SWIPE_HEADER);
                Json.WriteEndObject();
                Json.WriteStartObject('');
                Json.WriteStringProperty('Text', ABORT_ACQUIRE_SWIPE_LINE);
                Json.WriteEndObject();
                Json.WriteEndArray(); // OutputText
                Json.WriteEndObject(); // OutputContent
                Json.WriteEndObject(); // DisplayOutput
            end;
        end;
        Json.WriteEndObject(); // EnableServiceRequest
        Json.WriteEndObject(); // SaleToPOIRequest
        Json.WriteEndObject(); // root

        exit(Json.GetJSonAsText());
    end;
}