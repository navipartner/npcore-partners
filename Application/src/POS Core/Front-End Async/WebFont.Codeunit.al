codeunit 6150759 "NPR Web Font" implements "NPR Font Definition"
{
    var
        _code: Text;
        _name: Text;
        _fontFace: Text;
        _prefix: Text;
        _woff: Text;
        _css: Text;

    procedure Initialize(Code: Text; Name: Text; FontFace: Text; Prefix: Text; CssStream: InStream; WoffStream: InStream)
    var
        Base64: Codeunit "Base64 Convert";
        Regex: Codeunit DotNet_Regex;
    begin
        _code := Code;
        _name := Name;
        _fontFace := FontFace;
        _prefix := Prefix;
        _woff := 'data:application/x-font-woff;charset=utf-8;base64,' + Base64.ToBase64(WoffStream);

        CssStream.ReadText(_css);
        _css := Regex.Replace(_css, '[a-zA-Z]+#', '#');
        _css := Regex.Replace(_css, '[\n\r]+\s*', '');
        _css := Regex.Replace(_css, '\s+', ' ');
        _css := Regex.Replace(_css, '\s?([:,;{}])\s?', '$1');
        _css := _css.Replace(';}', '}');
        _css := Regex.Replace(_css, '([\s:]0)(px|pt|%|em)', '$1');
        _css := Regex.Replace(_css, '/\*[\d\D]*?\*/', '');
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
