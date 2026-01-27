codeunit 6184592 "NPR EFT Adyen CardAcquire Req"
{
    Access = Internal;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"): Text
    var
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        AmountInput: Decimal;
    begin
        if (
            (EFTTransactionRequest."Auxiliary Operation ID" = "NPR EFT Adyen Aux Operation"::ACQUIRE_CARD.AsInteger()) and
            (EFTTransactionRequest."Initiated from Entry No." > 0)
        ) then begin
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
            AmountInput := OriginalEFTTransactionRequest."Amount Input";
        end;
        exit(GetRequestJson(EFTTransactionRequest, EFTSetup, AmountInput));
    end;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"; AmountInput: Decimal): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        JsonText: Text;
    begin
        Json.WriteStartObject('');
        Json.WriteStartObject('SaleToPOIRequest');
        Json.WriteStartObject('MessageHeader');
        Json.WriteStringProperty('MessageType', 'Request');
        Json.WriteStringProperty('MessageCategory', 'CardAcquisition');
        Json.WriteStringProperty('MessageClass', 'Service');
        Json.WriteStringProperty('ServiceID', EFTTransactionRequest."Reference Number Input");
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteStringProperty('POIID', EFTTransactionRequest."Hardware ID");
        Json.WriteStringProperty('ProtocolVersion', EFTTransactionRequest."Integration Version Code");
        Json.WriteEndObject(); // MessageHeader
        Json.WriteStartObject('CardAcquisitionRequest');
        Json.WriteStartObject('SaleData');
        Json.WriteStartObject('SaleTransactionID');
        Json.WriteStringProperty('TimeStamp', Format(CurrentDateTime(), 0, 9));
        Json.WriteStringProperty('TransactionID', EFTTransactionRequest."Sales Ticket No.");
        Json.WriteEndObject(); // SaleTransactionID
        Json.WriteEndObject(); // SaleData
        Json.WriteStartObject('CardAcquisitionTransaction');
        if (
            (EFTTransactionRequest."Auxiliary Operation ID" = "NPR EFT Adyen Aux Operation"::ACQUIRE_CARD.AsInteger()) and
            (EFTTransactionRequest."Initiated from Entry No." > 0)
        ) then begin
            Json.WriteStringProperty('TotalAmount', Format(AmountInput, 0, '<Precision,2:3><Standard Format,9>'));
        end;
        Json.WriteEndObject(); // CardAcquisitionTransaction
        Json.WriteEndObject(); // CardAcquisitionRequest
        Json.WriteEndObject(); // SaleToPOIRequest
        Json.WriteEndObject(); // Root

        JsonText := EFTAdyenIntegration.RewriteAmountFromStringToNumberWithoutRounding(Json.GetJSonAsText(), 'TotalAmount');

        exit(JsonText);
    end;
}