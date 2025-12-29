codeunit 6184592 "NPR EFT Adyen CardAcquire Req"
{
    Access = Internal;

    procedure GetRequestJson(ReferenceNumberInput: Code[20]; RegisterNo: Code[10]; HardwareID: Text[250]; IntegrationVersionCode: Code[10]; SalesTicketNo: Code[20]; AuxiliaryOperationID: Integer; InitiatedFromEntryNo: Integer; AmountInput: Decimal): Text
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
        Json.WriteStringProperty('ServiceID', ReferenceNumberInput);
        Json.WriteStringProperty('SaleID', RegisterNo);
        Json.WriteStringProperty('POIID', HardwareID);
        Json.WriteStringProperty('ProtocolVersion', IntegrationVersionCode);
        Json.WriteEndObject(); // MessageHeader
        Json.WriteStartObject('CardAcquisitionRequest');
        Json.WriteStartObject('SaleData');
        Json.WriteStartObject('SaleTransactionID');
        Json.WriteStringProperty('TimeStamp', Format(CurrentDateTime(), 0, 9));
        Json.WriteStringProperty('TransactionID', SalesTicketNo);
        Json.WriteEndObject(); // SaleTransactionID
        Json.WriteEndObject(); // SaleData
        Json.WriteStartObject('CardAcquisitionTransaction');
        if (
            (AuxiliaryOperationID = "NPR EFT Adyen Aux Operation"::ACQUIRE_CARD.AsInteger()) and
            (InitiatedFromEntryNo > 0)
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