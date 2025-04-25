codeunit 6150742 "NPR Adyen Acq Phone No Req."
{
    Access = Internal;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
    begin
        Json.WriteStartObject('');
        Json.WriteStartObject('SaleToPOIRequest');
        Json.WriteStartObject('MessageHeader');
        Json.WriteStringProperty('ProtocolVersion', EFTTransactionRequest."Integration Version Code");
        Json.WriteStringProperty('MessageClass', 'Device');
        Json.WriteStringProperty('MessageCategory', 'Input');
        Json.WriteStringProperty('MessageType', 'Request');
        Json.WriteStringProperty('ServiceID', CopyStr(EFTTransactionRequest."Reference Number Input", 1, 10));
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteStringProperty('POIID', EFTTransactionRequest."Hardware ID");
        Json.WriteEndObject(); // MessageHeader
        Json.WriteStartObject('InputRequest');
        Json.WriteStartObject('DisplayOutput');
        Json.WriteStringProperty('Device', 'CustomerDisplay');
        Json.WriteStringProperty('InfoQualify', 'Display');
        Json.WriteStartObject('OutputContent');
        Json.WriteStringProperty('OutputFormat', 'Text');
        Json.WriteStartObject('PredefinedContent');
        Json.WriteStringProperty('ReferenceID', 'GetPhoneNumber');
        Json.WriteEndObject(); // PredefinedContent
        Json.WriteStartArray('OutputText');
        Json.WriteStartObject('');
        Json.WriteStringProperty('Text', 'Enter your phone number:');
        Json.WriteEndObject();
        Json.WriteEndArray(); // OutputText
        Json.WriteEndObject(); // OutputContent
        Json.WriteEndObject(); // DisplayOutput
        Json.WriteStartObject('InputData');
        Json.WriteStringProperty('Device', 'CustomerInput');
        Json.WriteStringProperty('InfoQualify', 'Input');
        Json.WriteStringProperty('InputCommand', 'DigitString');
        Json.WriteRawProperty('MaxInputTime', 40);
        Json.WriteStringProperty('DefaultInputString', '0123456789');
        Json.WriteBooleanProperty('MaskCharactersFlag', true);
        Json.WriteEndObject(); // InputData
        Json.WriteEndObject(); // InputRequest
        Json.WriteEndObject(); // SaleToPOIRequest
        Json.WriteEndObject(); // root

        exit(Json.GetJSonAsText());
    end;
}
