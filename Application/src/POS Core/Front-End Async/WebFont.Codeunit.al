codeunit 6150759 "NPR Web Font" implements "NPR Font Definition"
{
    Access = Internal;
    var
        _code: Text;
        _name: Text;
        _fontFace: Text;
        _prefix: Text;
        _woff: Text;
        _css: Text;

    procedure Code(): Text
    begin
        exit(_code);
    end;

    procedure Name(): Text
    begin
        exit(_name);
    end;

    procedure FontFace(): Text
    begin
        exit(_fontFace);
    end;

    procedure Prefix(): Text
    begin
        exit(_prefix);
    end;

    procedure GetCssStream(var CssStream: OutStream)
    begin
        CssStream.WriteText(_css);
    end;

    procedure GetWoffStream(var WoffStream: OutStream)
    var
        Base64: Codeunit "Base64 Convert";
    begin
        Base64.FromBase64(_woff.Substring(51), WoffStream);
    end;


    procedure Initialize(Code: Text; Name: Text; FontFace: Text; Prefix: Text; CssStream: InStream; WoffStream: InStream)
    var
        Base64: Codeunit "Base64 Convert";
        NpRegex: Codeunit "NPR RegEx";
    begin
        _code := Code;
        _name := Name;
        _fontFace := FontFace;
        _prefix := Prefix;
        _woff := 'data:application/x-font-woff;charset=utf-8;base64,' + Base64.ToBase64(WoffStream);

        CssStream.ReadText(_css);
        _css := NpRegex.Replace(_css, '[a-zA-Z]+#', '#');
        _css := NpRegex.Replace(_css, '[\n\r]+\s*', '');
        _css := NpRegex.Replace(_css, '\s+', ' ');
        _css := NpRegex.Replace(_css, '\s?([:,;{}])\s?', '$1');
        _css := _css.Replace(';}', '}');
        _css := NpRegex.Replace(_css, '([\s:]0)(px|pt|%|em)', '$1');
        _css := NpRegex.Replace(_css, '/\*[\d\D]*?\*/', '');
    end;

    local procedure GetValue(Json: JsonObject; TokenName: Text): JsonValue
    var
        Token: JsonToken;
    begin
        Json.Get(TokenName, Token);
        exit(Token.AsValue());
    end;

    procedure Initialize(JsonStream: InStream)
    var
        Json: JsonObject;
    begin
        Json.ReadFrom(JsonStream);
        _code := GetValue(Json, 'Code').AsText();
        _name := GetValue(Json, 'Name').AsText();
        _fontFace := GetValue(Json, 'FontFace').AsText();
        _prefix := GetValue(Json, 'Prefix').AsText();
        _css := GetValue(Json, 'Css').AsText();
        _woff := GetValue(Json, 'Woff').AsText();
    end;

    procedure GetJson() Json: JsonObject;
    begin
        Json.Add('Code', _code);
        Json.Add('Name', _name);
        Json.Add('FontFace', _fontFace);
        Json.Add('Prefix', _prefix);
        Json.Add('Woff', _woff);
        Json.Add('Css', _css);
    end;
}
