codeunit 6150767 "NPR Front-End: ConfSMPasswords" implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _method: Text;
        _commaDelimitedPasswords: Text;

    procedure Initialize(Method: Text; CommaDelimitedPasswords: Text)
    begin
        _method := Method;
        _commaDelimitedPasswords := CommaDelimitedPasswords;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'ConfigureSecureMethodsClientPasswords');
        Json.Add('Content', _content);

        _content.Add('method', _method);
        _content.Add('passwords', _commaDelimitedPasswords);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}
