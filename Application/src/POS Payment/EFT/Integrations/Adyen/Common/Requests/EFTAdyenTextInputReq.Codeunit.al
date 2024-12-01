codeunit 6185074 "NPR EFT Adyen Text Input Req"
{
    Access = Internal;

    var
        Title: Text;
        DefaultInput: Text;
        MaskChararctersFlag: Boolean;

    procedure GetRequestJson(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EFTSetup: Record "NPR EFT Setup"): Text
    var
        Json: Codeunit "Json Text Reader/Writer";
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
        Json.WriteStringProperty('ReferenceID', 'GetText');
        Json.WriteEndObject(); // PredefinedContent        
        Json.WriteStartArray('OutputText');
        Json.WriteStartObject('');
        Json.WriteStringProperty('Text', Title);
        Json.WriteEndObject();
        Json.WriteEndArray(); // OutputText
        Json.WriteEndObject(); // DisplayOutput
        Json.WriteEndObject(); // OutputContent
        Json.WriteStartObject('InputData');
        Json.WriteStringProperty('Device', 'CustomerInput');
        Json.WriteStringProperty('InfoQualify', 'Input');
        Json.WriteStringProperty('InputCommand', 'TextString');
        Json.WriteRawProperty('MaxInputTime', 120);
        Json.WriteStringProperty('DefaultInputString', DefaultInput);
        Json.WriteBooleanProperty('MaskCharactersFlag', MaskChararctersFlag);

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

    procedure SetDefaultInput(ParamDefaultInput: Text)
    begin
        DefaultInput := ParamDefaultInput;
    end;

    procedure SetMaskChararctersFlag(ParamMaskChararctersFlag: Boolean)
    begin
        MaskChararctersFlag := ParamMaskChararctersFlag;
    end;

}