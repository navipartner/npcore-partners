codeunit 6150753 "NPR Front-End: ReportBug" implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _errorText: Text;
        _warning: Boolean;
        _withError: Boolean;
        _isInvalidCustomMethod: Boolean;
        _invalidCustomMethodName: Text;

    procedure Initialize(InitialErrorText: Text)
    begin
        _errorText := InitialErrorText;
    end;

    procedure InitializeWarning(InitialErrorText: Text; WithError: Boolean)
    begin
        _errorText := InitialErrorText;
        _warning := true;
        _withError := true;
    end;

    procedure SetInvalidCustomMethod(InvalidCustomMethodName: Text)
    begin
        _isInvalidCustomMethod := true;
        _invalidCustomMethodName := InvalidCustomMethodName;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'ReportBug');
        Json.Add('Content', _content);
        Json.Add('ErrorText', _errorText);
        if _warning then begin
            _content.Add('warning', true);
            if (_withError) then
                _content.Add('withError', true);
        end;
        if _isInvalidCustomMethod then
            _content.Add('InvalidCustomMethod', _invalidCustomMethodName);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}
