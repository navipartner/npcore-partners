codeunit 6014662 "NPR Tax Free CC Print"
{
    Access = Internal;
    TableNo = "NPR Tax Free Request";
    trigger OnRun()
    begin
        TaxFreeCC.GetPrintJson(Rec, ExternalVoucherNo);
        case Rec."Print Type" of
            Rec."Print Type"::Thermal:
                PrintThermal(Rec);
        end;
    end;

    procedure SetExternalVoucherNo(VoucherNo: Text[50])
    begin
        ExternalVoucherNo := VoucherNo
    end;

    local procedure ParsePrinter()
    var
        Index: Integer;
        ValDict: Dictionary of [Text, Text];
        JsonKey: Text;
        JsonVal: Text;
        StyleLab: Label 'style', Locked = true;
        ContentLab: Label 'content', Locked = true;
        LinkLab: Label 'link', Locked = true;
        RecNumLab: Label 'receiptNumber', Locked = true;
        KeyErr: Label 'Key %1 not supported', Comment = '%1 - Key';
        Printer: Codeunit "NPR RP Line Print Mgt.";
        Font: Text;
        Center: Boolean;
        Bold: Boolean;
        ContenText: Text;
        RecNumText: Text;
        LinkText: Text;
        QRData: Label 'www.customcash.com/download', Locked = true;
    begin
        for Index := 1 to ObjectCounter do begin
            if ParsedJsonObject.Get(Index, ValDict) then begin
                ClearPrinterVar(Font, Center, Bold, ContenText, LinkText, RecNumText);
                foreach JsonKey in ValDict.Keys do begin
                    if ValDict.Get(JsonKey, JsonVal) then begin
                        case JsonKey of
                            StyleLab:
                                ParseStyle(JsonVal, Font, Center, Bold);
                            ContentLab:
                                ContenText := JsonVal;
                            LinkLab:
                                LinkText := JsonVal;
                            RecNumLab:
                                RecNumText := JsonVal;
                            else
                                Error(KeyErr, JsonKey);
                        end;
                    end;
                end;
            end;
            if Index = 2 then begin
                Printer.SetFont('Logo');
                Printer.AddLine('TAXFREE');
            end;

            if (LinkText <> '') and (RecNumText <> '') and (ContenText = 'QR LOGO') then begin
                ContenText := '{"client_cone:null;receipt_number":"' + RecNumText + '"}';
                Printer.AddBarcode('QR', ContenText, 2);
            end else begin
                if StrPos(ContenText, 'data:image') <> 0 then begin
                    Printer.AddBarcode('QR', QRData, 2);
                end else begin
                    if Font = '' then
                        Font := 'A11';
                    Printer.SetFont(Font);
                    Printer.SetBold(Bold);
                    if ContenText = '' then
                        ContenText := ' ';
                    while (ContenText <> '') do begin
                        if Center then
                            Printer.AddTextField(2, 1, CopyStr(ContenText, 1, 42))
                        else
                            Printer.AddTextField(1, 0, CopyStr(ContenText, 1, 42));
                        ContenText := CopyStr(ContenText, 43);
                        Printer.NewLine();
                    end;
                end;
            end;
        end;
        Printer.SetFont('Control');
        Printer.AddLine('P');
        Printer.ProcessBufferForCodeunit(CODEUNIT::"NPR Tax Free Receipt", '');
    end;

    local procedure ClearPrinterVar(var Font: Text; var Center: Boolean; var Bold: Boolean; var ContenText: Text; var LinkText: Text; var RecNumText: Text)
    begin
        Font := '';
        Center := false;
        Bold := false;
        ContenText := '';
        LinkText := '';
        RecNumText := '';
    end;

    local procedure ParseStyle(StyleValue: Text; var Font: Text; var Center: Boolean; var Bold: Boolean)
    var
        StylePart: Text;
    begin
        while StrPos(StyleValue, ';') <> 0 do begin
            StylePart := CopyStr(StyleValue, 1, StrPos(StyleValue, ';'));
            StyleValue := CopyStr(StyleValue, StrPos(StyleValue, ';') + 1);
            ParseStyleTag(StyleValue, Font, Center, Bold);
        end;
        ParseStyleTag(StyleValue, Font, Center, Bold);
    end;

    local procedure ParseStyleTag(StyleValue: Text; var Font: Text; var Center: Boolean; var Bold: Boolean)
    var
        StyleFSLab: Label 'font-size', Locked = true;
        StyleTALab: Label 'text-align', Locked = true;
        StyleBCLab: Label 'background-color', Locked = true;
        StyleCLab: Label 'color', Locked = true;
        StyleFLab: Label 'float', Locked = true;
        StyleFStLab: Label 'font-stretch', Locked = true;
        StyleTagErr: Label 'Style value %1 is not supported.', Comment = '%1 - Tag';
        ValueVar: Text;
        Number: Decimal;
    begin
        if StrPos(StyleValue, StyleFSLab) <> 0 then begin
            ValueVar := CopyStr(StyleValue, StrPos(StyleValue, ':') + 1);
            ValueVar := CopyStr(ValueVar, 1, StrPos(ValueVar, 'px') - 1);
            Evaluate(Number, ValueVar);
            if Number > 30 then
                Font := 'A30'
            else
                if Number < 10 then
                    Font := 'A10'
                else
                    Font := 'A' + Format(Number);
            exit;
        end;
        if StrPos(StyleValue, StyleTALab) <> 0 then begin
            case true of
                StrPos(StyleValue, 'center') <> 0:
                    Center := true;
            end;
            exit;
        end;

        if StrPos(StyleValue, StyleBCLab) <> 0 then begin
            Bold := true;
            exit;
        end;
        if StrPos(StyleValue, StyleCLab) <> 0 then
            exit;
        if StrPos(StyleValue, StyleFLab) <> 0 then
            exit;
        if StrPos(StyleValue, StyleFStLab) <> 0 then
            exit;
        Error(StyleTagErr, StyleValue);
    end;

    local procedure PrintThermal(var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        InStr: InStream;
        JsonResponse: Text;
        JsonTok: JsonToken;
        JsonObj: JsonObject;
        JsonTokValue: JsonToken;
    begin
        if not TaxFreeRequest.Print.HasValue then
            exit;
        TaxFreeRequest.Print.CreateInStream(InStr, TEXTENCODING::UTF8);
        InStr.Read(JsonResponse);

        JsonTok.ReadFrom(JsonResponse);
        JsonObj := JsonTok.AsObject();
        JsonObj.Get('status', JsonTokValue);
        if JsonTokValue.AsValue().AsText() = 'error' then begin
            JsonObj.Get('message', JsonTokValue);
            Error(JsonTokValue.AsValue().AsText());
        end;
        JsonObj.Get('data', JsonTokValue);
        ParseJson(JsonTokValue);
        ParsePrinter();
    end;

    local procedure ParseJson(JsonTokPar: JsonToken)
    begin
        case true of
            JsonTokPar.IsArray:
                ParseJArray(JsonTokPar);
            JsonTokPar.IsObject:
                ParseJObject(JsonTokPar);
        end;
    end;

    local procedure ParseJArray(JsonTokPar: JsonToken)
    var
        JsonArr: JsonArray;
        JsonTokValue: JsonToken;
    begin
        if not JsonTokPar.IsArray then
            exit;
        JsonArr := JsonTokPar.AsArray();
        foreach JsonTokValue in JsonArr do
            ParseJson(JsonTokValue);
    end;

    local procedure ParseJObject(JsonTokPar: JsonToken)
    var
        JsonObj: JsonObject;
        JsonTokValue: JsonToken;
        JsonKeys: List of [Text];
        JsonKey: Text;
        ValDict: Dictionary of [Text, Text];
    begin
        if not JsonTokPar.IsObject then
            exit;
        JsonObj := JsonTokPar.AsObject();
        JsonKeys := JsonObj.Keys;
        ObjectCounter += 1;
        foreach JsonKey in JsonKeys do begin
            JsonObj.Get(JsonKey, JsonTokValue);

            if JsonTokValue.IsValue then begin
                if ParsedJsonObject.Get(ObjectCounter, ValDict) then begin
                    ParseJValue(JsonTokValue, JsonKey, ValDict);
                    ParsedJsonObject.Set(ObjectCounter, ValDict);
                end else begin
                    ParseJValue(JsonTokValue, JsonKey, ValDict);
                    ParsedJsonObject.Add(ObjectCounter, ValDict);
                end;
            end else
                ParseJson(JsonTokValue);
        end;

    end;

    local procedure ParseJValue(JsonTokPar: JsonToken; JsonKey: Text; var ValDict: Dictionary of [Text, Text])
    var
        JsonVal: JsonValue;
    begin
        if not JsonTokPar.IsValue then
            exit;
        JsonVal := JsonTokPar.AsValue();
        ValDict.Add(JsonKey, JsonVal.AsText());
    end;

    var
        TaxFreeCC: Codeunit "NPR Tax Free CC";
        ParsedJsonObject: Dictionary of [Integer, Dictionary of [Text, Text]];
        ObjectCounter: Integer;
        ExternalVoucherNo: Text[50];
}
