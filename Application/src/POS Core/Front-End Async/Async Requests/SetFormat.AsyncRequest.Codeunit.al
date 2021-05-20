codeunit 6150783 "NPR Front-End: SetFormat" implements "NPR Front-End Async Request"
{
    var
        _json: JsonObject;
        _content: JsonObject;
        _ready: Boolean;

        LabelNumberDecimalSeparator: Label 'NumberDecimalSeparator', Locked = true;
        LabelNumberGroupSeparator: Label 'NumberGroupSeparator', Locked = true;
        LabelNumberDecimalDigits: Label 'NumberDecimalDigits', Locked = true;
        LabelCurrencySymbol: Label 'CurrencySymbol', Locked = true;
        LabelDateSeparator: Label 'DateSeparator', Locked = true;
        LabelShortDatePattern: Label 'ShortDatePattern', Locked = true;
        LabelDayNames: Label 'DayNames', Locked = true;

    procedure Initialize(ViewProfile: Record "NPR POS View Profile");
    var
        NumberFormat: JsonObject;
        DateFormat: JsonObject;
        Token: JsonToken;
    begin
        _ready := false;
        _json := ViewProfile.GetLocalFormats();

        _json.Get('NumberFormat', Token);
        NumberFormat := Token.AsObject();

        _json.Get('DateFormat', Token);
        DateFormat := Token.AsObject();

        if ViewProfile."Client Decimal Separator" <> '' then begin
            NumberFormat.Remove(LabelNumberDecimalSeparator);
            NumberFormat.Add(LabelNumberDecimalSeparator, ViewProfile."Client Decimal Separator");
        end;
        if ViewProfile."Client Thousands Separator" <> '' then begin
            NumberFormat.Remove(LabelNumberGroupSeparator);
            NumberFormat.Add(LabelNumberGroupSeparator, ViewProfile."Client Thousands Separator");
        end;
        if ViewProfile."Client Number Decimal Digits" > 0 then begin
            NumberFormat.Remove(LabelNumberDecimalDigits);
            NumberFormat.Add(LabelNumberDecimalDigits, ViewProfile."Client Number Decimal Digits");
        end;
        if ViewProfile."Client Currency Symbol" <> '' then begin
            NumberFormat.Remove(LabelCurrencySymbol);
            NumberFormat.Add(LabelCurrencySymbol, ViewProfile."Client Currency Symbol");
        end;
        if ViewProfile."Client Date Separator" <> '' then begin
            DateFormat.Remove(LabelDateSeparator);
            DateFormat.Add(LabelDateSeparator, ViewProfile."Client Date Separator");
        end;
        if ViewProfile."Client Short Date Pattern" <> '' then begin
            DateFormat.Remove(LabelShortDatePattern);
            DateFormat.Add(LabelShortDatePattern, ViewProfile."Client Short Date Pattern");
        end;
        if ViewProfile."Client Day Names" <> '' then begin
            DateFormat.Remove(LabelDayNames);
            DateFormat.Add(LabelDayNames, ViewProfile."Client Day Names");
        end;

        _ready := true;
    end;

    procedure Ready(): Boolean;
    begin
        exit(_ready);
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json := _json.Clone().AsObject();
        Json.Add('Method', 'SetFormat');
        Json.Add('Content', _content);
        exit(Json);
    end;

    procedure GetContent(): JsonObject;
    begin
        exit(_content);
    end;
}
