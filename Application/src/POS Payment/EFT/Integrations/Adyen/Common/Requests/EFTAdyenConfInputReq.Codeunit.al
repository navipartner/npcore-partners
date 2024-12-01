codeunit 6185058 "NPR EFT Adyen ConfInput Req"
{
    Access = Internal;

    var
        Title: Text;
        TextQst: Text;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
        AgreeLbl: Label 'Agree';
        DeclineLbl: Label 'Decline';
    begin
        Json.WriteStartObject('');
        Json.WriteStartObject('SaleToPOIRequest');
        Json.WriteStartObject('MessageHeader');
        Json.WriteStringProperty('MessageType', 'Request');
        Json.WriteStringProperty('MessageCategory', 'Input');
        Json.WriteStringProperty('MessageClass', 'Device');
        Json.WriteStringProperty('ServiceID', EFTTransactionRequest."Reference Number Input");
        Json.WriteStringProperty('SaleID', EFTTransactionRequest."Register No.");
        Json.WriteStringProperty('POIID', EFTTransactionRequest."Hardware ID");
        Json.WriteStringProperty('ProtocolVersion', EFTTransactionRequest."Integration Version Code");
        Json.WriteEndObject(); // MessageHeader
        Json.WriteStartObject('InputRequest');
        Json.WriteStartObject('DisplayOutput');
        Json.WriteStringProperty('Device', 'CustomerDisplay');
        Json.WriteStringProperty('InfoQualify', 'Display');
        Json.WriteStartObject('OutputContent');
        Json.WriteStringProperty('OutputFormat', 'Text');
        Json.WriteStartObject('PredefinedContent');
        Json.WriteStringProperty('ReferenceID', 'GetConfirmation');
        Json.WriteEndObject(); // PredefinedContent        
        Json.WriteStartArray('OutputText');
        Json.WriteStartObject('');
        Json.WriteStringProperty('Text', Title);
        Json.WriteEndObject();
        Json.WriteStartObject('');
        Json.WriteStringProperty('Text', TextQst);
        Json.WriteEndObject();
        Json.WriteStartObject('');
        Json.WriteStringProperty('Text', DeclineLbl);
        Json.WriteEndObject();
        Json.WriteStartObject('');
        Json.WriteStringProperty('Text', AgreeLbl);
        Json.WriteEndObject();
        Json.WriteEndArray(); // OutputText
        Json.WriteEndObject(); // DisplayOutput
        Json.WriteEndObject(); // OutputContent
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

    procedure SetTitle(ParamTitle: Text)
    begin
        Title := ParamTitle;
    end;

    procedure SetTextQst(ParamTextQst: Text)
    begin
        TextQst := ParamTextQst;
    end;
}