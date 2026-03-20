codeunit 6248477 "NPR Adyen QRCode Show Req."
{
    Access = Internal;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; BarcodeValue: Text; MinimumDisplayTimeSec: Integer): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
        ScanQRCodeLbl: Label 'Scan your QR code';
        ThankYouLbl: Label 'Thank you!';
    begin
        Json.WriteStartObject('');
        Json.WriteStartObject('SaleToPOIRequest');
        Json.WriteStartObject('MessageHeader');
        Json.WriteStringProperty('ProtocolVersion', '3.0'); //Adyen Terminal API Protocol v3.0
        Json.WriteStringProperty('MessageClass', 'Device');
        Json.WriteStringProperty('MessageCategory', 'Display');
        Json.WriteStringProperty('MessageType', 'Request');
        Json.WriteStringProperty('ServiceID', CopyStr(EFTTransactionRequest."Reference Number Input", 1, 10));
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteStringProperty('POIID', EFTTransactionRequest."Hardware ID");
        Json.WriteEndObject(); // MessageHeader

        Json.WriteStartObject('DisplayRequest');
        Json.WriteStartArray('DisplayOutput');

        Json.WriteStartObject('');
        Json.WriteStringProperty('Device', 'CustomerDisplay');
        Json.WriteStringProperty('InfoQualify', 'Display');
        if MinimumDisplayTimeSec > 0 then
            Json.WriteRawProperty('MinimumDisplayTime', MinimumDisplayTimeSec);
        Json.WriteStartObject('OutputContent');
        Json.WriteStringProperty('OutputFormat', 'BarCode');
        Json.WriteStartObject('OutputBarcode');
        Json.WriteStringProperty('BarcodeType', 'QRCode');
        Json.WriteStringProperty('BarcodeValue', BarcodeValue);
        Json.WriteEndObject(); // OutputBarcode
        Json.WriteEndObject(); // OutputContent
        Json.WriteEndObject();

        Json.WriteStartObject('');
        Json.WriteStringProperty('Device', 'CustomerDisplay');
        Json.WriteStringProperty('InfoQualify', 'Display');
        Json.WriteStartObject('OutputContent');
        Json.WriteStringProperty('OutputFormat', 'Text');
        Json.WriteStartArray('OutputText');
        Json.WriteStartObject('');
        Json.WriteStringProperty('Text', ScanQRCodeLbl);
        Json.WriteEndObject();
        Json.WriteEndArray(); // OutputText
        Json.WriteEndObject(); // OutputContent
        Json.WriteEndObject();

        Json.WriteStartObject('');
        Json.WriteStringProperty('Device', 'CustomerDisplay');
        Json.WriteStringProperty('InfoQualify', 'Display');
        Json.WriteStartObject('OutputContent');
        Json.WriteStringProperty('OutputFormat', 'Text');
        Json.WriteStartArray('OutputText');
        Json.WriteStartObject('');
        Json.WriteStringProperty('Text', ThankYouLbl);
        Json.WriteEndObject();
        Json.WriteEndArray(); // OutputText
        Json.WriteEndObject(); // OutputContent
        Json.WriteEndObject();

        Json.WriteEndArray(); // DisplayOutput
        Json.WriteEndObject(); // DisplayRequest
        Json.WriteEndObject(); // SaleToPOIRequest
        Json.WriteEndObject(); // root

        exit(Json.GetJSonAsText());
    end;
}
