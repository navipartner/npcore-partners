codeunit 6150766 "NPR Front-End: ValSecMethPasw." implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _requestId: Integer;
        _success: Boolean;
        _authorizedBy: Text;
        _skipUI: Boolean;
        _reason: Text;

    procedure Initialize(RequestId: Integer; Success: Boolean; SkipUI: Boolean; Reason: Text; AuthorizedBy: Text)
    begin
        _requestId := RequestId;
        _success := Success;
        _skipUI := SkipUI;
        _reason := Reason;
        _authorizedBy := AuthorizedBy;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'ValidateSecureMethodPassword');
        Json.Add('Content', _content);

        _content.Add('requestId', _requestId);
        _content.Add('success', _success);
        _content.Add('authorizedBy', _authorizedBy);

        if (not _success) then begin
            _content.Add('skipUi', _skipUI);
            _content.Add('reason', _reason);
        end;
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}
