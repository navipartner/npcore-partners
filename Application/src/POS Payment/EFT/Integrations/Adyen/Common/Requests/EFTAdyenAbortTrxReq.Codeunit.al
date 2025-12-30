codeunit 6184595 "NPR EFT Adyen AbortTrx Req"
{
    Access = Internal;

    procedure GetRequestJson(ProcessedEntryNo: Integer; ReferenceNumberInput: Text[50]; RegisterNo: Code[10]; HardwareID: Text[250]; IntegrationVersionCode: Code[10]; ProcessingType: Text; AuxiliaryOperationID: Integer): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
    begin
        Json.WriteStartObject('');
        Json.WriteStartObject('SaleToPOIRequest');
        Json.WriteStartObject('AbortRequest');
        Json.WriteStringProperty('AbortReason', 'MerchantAbort');
        Json.WriteStartObject('MessageReference');
        Json.WriteStringProperty('ServiceID', Format(ProcessedEntryNo));
        Json.WriteStringProperty('MessageCategory', GetMessageCategory(ProcessingType, AuxiliaryOperationID));
        Json.WriteStringProperty('SaleID', RegisterNo);
        Json.WriteEndObject(); // MessageReference
        Json.WriteEndObject(); // AbortRequest
        Json.WriteStartObject('MessageHeader');
        Json.WriteStringProperty('MessageType', 'Request');
        Json.WriteStringProperty('MessageCategory', 'Abort');
        Json.WriteStringProperty('MessageClass', 'Service');
        Json.WriteStringProperty('ServiceID', ReferenceNumberInput);
        Json.WriteStringProperty('SaleID', RegisterNo);
        Json.WriteStringProperty('POIID', HardwareID);
        Json.WriteStringProperty('ProtocolVersion', IntegrationVersionCode);
        Json.WriteEndObject(); // MessageHeader
        Json.WriteEndObject(); // SaleToPOIRequest
        Json.WriteEndObject(); // Root

        exit(Json.GetJSonAsText());
    end;

    local procedure GetMessageCategory(ProcessingType: Text; AuxiliaryOperationID: Integer): Text
    begin
        if ProcessingType = 'Payment' then
            exit(ProcessingType);

        case AuxiliaryOperationID of
            "NPR EFT Adyen Aux Operation"::SUBSCRIPTION_CONFIRM.AsInteger(),
            "NPR EFT Adyen Aux Operation"::ACQUIRE_SIGNATURE.AsInteger(),
            "NPR EFT Adyen Aux Operation"::ACQUIRE_PHONE_NO.AsInteger(),
            "NPR EFT Adyen Aux Operation"::ACQUIRE_EMAIL.AsInteger():
                exit('Input');
            else
                exit('CardAcquisition');
        end;
    end;
}