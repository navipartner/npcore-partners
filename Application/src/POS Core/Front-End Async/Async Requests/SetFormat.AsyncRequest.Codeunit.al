codeunit 6150783 "NPR Front-End: SetFormat" implements "NPR Front-End Async Request"
{
    var
        _json: JsonObject;
        _content: JsonObject;
        _ready: Boolean;

        LabelNumberDecimalSeparator: Label 'NumberDecimalSeparator', Locked = true;
        LabelNumberGroupSeparator: Label 'NumberGroupSeparator', Locked = true;
        LabelDateSeparator: Label 'DateSeparator', Locked = true;

    procedure Initialize(ViewProfile: Record "NPR POS View Profile");
    var
        NumberFormat: JsonObject;
        DateFormat: JsonObject;
        Token: JsonToken;
    begin
        _ready := false;
        _json := ViewProfile.GetLocaleFormats();

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

        if ViewProfile."Client Date Separator" <> '' then begin
            DateFormat.Remove(LabelDateSeparator);
            Dateformat.Add(LabelDateSeparator, ViewProfile."Client Date Separator");
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
