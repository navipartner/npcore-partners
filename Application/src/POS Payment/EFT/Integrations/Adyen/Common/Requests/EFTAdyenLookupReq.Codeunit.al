codeunit 6184597 "NPR EFT Adyen Lookup Req"
{
    Access = Internal;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
    begin
        // We do two forms of lookup :
        // 1) an automatic lookup at the end of a purchase/refund/void if result is inconclusive i.e. timeout or http disconnect.
        // This one re-uses the trx request record and will not create a dedicated lookup record.
        // 2) a manual lookup. This one creates a dedicated trx request record on click.

        if EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::LOOK_UP then begin
            // Scenario 1)            
            EFTTransactionRequest."Reference Number Input" += 'r'; //Is not actually inserted in DB but will make the auto look retry unique to adyen.
        end;


        Json.WriteStartObject('');
        Json.WriteStartObject('SaleToPOIRequest');
        Json.WriteStartObject('MessageHeader');
        Json.WriteStringProperty('ProtocolVersion', EFTTransactionRequest."Integration Version Code");
        Json.WriteStringProperty('MessageClass', 'Service');
        Json.WriteStringProperty('MessageCategory', 'TransactionStatus');
        Json.WriteStringProperty('MessageType', 'Request');
        Json.WriteStringProperty('ServiceID', EFTTransactionRequest."Reference Number Input");
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteStringProperty('POIID', EFTTransactionRequest."Hardware ID");
        Json.WriteEndObject(); // MessageHeader
        Json.WriteStartObject('TransactionStatusRequest');
        Json.WriteStartArray('DocumentQualifier');
        Json.WriteValue('CashierReceipt');
        Json.WriteValue('CustomerReceipt');
        Json.WriteEndArray(); // DocumentQualifier
        Json.WriteBooleanProperty('ReceiptReprintFlag', true);
        Json.WriteStartObject('MessageReference');
        if OriginalEFTTransactionRequest."Processing Type" in
           [OriginalEFTTransactionRequest."Processing Type"::PAYMENT,
            OriginalEFTTransactionRequest."Processing Type"::REFUND] then begin
            Json.WriteStringProperty('MessageCategory', 'Payment')
        end else begin
            Json.WriteStringProperty('MessageCategory', 'Reversal');
        end;
        Json.WriteStringProperty('SaleID', OriginalEFTTransactionRequest."Register No.");
        Json.WriteStringProperty('ServiceID', OriginalEFTTransactionRequest."Reference Number Input");
        Json.WriteEndObject(); // MessageReference
        Json.WriteEndObject(); // TransactionStatusRequest
        Json.WriteEndObject(); // SaleToPOIRequest
        Json.WriteEndObject(); // root

        exit(Json.GetJSonAsText());
    end;
}