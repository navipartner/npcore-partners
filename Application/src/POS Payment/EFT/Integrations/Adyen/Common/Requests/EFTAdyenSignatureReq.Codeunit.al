codeunit 6248386 "NPR EFT Adyen Signature Req."
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
        Json.WriteStringProperty('ReferenceID', 'GetSignature');
        Json.WriteEndObject(); // PredefinedContent
        Json.WriteStartArray('OutputText');
        Json.WriteStartObject('');
        Json.WriteStringProperty('Text', 'Please sign');
        Json.WriteEndObject();
        Json.WriteStartObject('');
        Json.WriteStringProperty('Text', '');
        Json.WriteEndObject();
        Json.WriteEndArray(); // OutputText
        Json.WriteEndObject(); // OutputContent
        Json.WriteEndObject(); // DisplayOutput
        Json.WriteStartObject('InputData');
        Json.WriteStringProperty('Device', 'CustomerInput');
        Json.WriteStringProperty('InfoQualify', 'Input');
        Json.WriteStringProperty('InputCommand', 'GetConfirmation');
        Json.WriteRawProperty('MaxInputTime', 30);
        Json.WriteEndObject(); // InputData
        Json.WriteEndObject(); // InputRequest
        Json.WriteEndObject(); // SaleToPOIRequest
        Json.WriteEndObject(); // root

        exit(Json.GetJSonAsText());
    end;
}
