codeunit 6151493 "NPR Raptor API"
{
    Access = Internal;
    trigger OnRun()
    begin
    end;

    procedure SendRaptorRequest(BaseUrl: Text; Path: Text; var ErrorMsg: Text) Result: Text
    var
        Parameters: Dictionary of [Text, Text];
        RequestStatus: Boolean;
    begin
        Parameters.Add('baseurl', BaseUrl);
        Parameters.Add('restmethod', 'GET');
        Parameters.Add('path', Path);

        RequestStatus := CallRaptorAPI(Parameters, Result);

        if not RequestStatus then begin
            ErrorMsg := Result;
            Result := '';
        end;
    end;

    procedure CallRaptorAPI(var Parameters: Dictionary of [Text, Text]; var ResponseMsgTxt: Text): Boolean
    var
        Base64Convert: Codeunit "Base64 Convert";
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        AuthText: Text;
        UriLbl: Label '%1%2', Locked = true;
        AuthLbl: Label '%1:%2', Locked = true;
        BasicLbl: Label 'Basic %1', Locked = true;
    begin
        RequestMsg.Method := Format(Parameters.get('restmethod'));
        if Parameters.ContainsKey('path') then
            RequestMsg.SetRequestUri(strsubstno(UriLbl, Parameters.get('baseurl'), Parameters.Get('path')))
        else
            RequestMsg.SetRequestUri(Parameters.get('baseurl'));

        RequestMsg.GetHeaders(Headers);
        Headers.Add('User-Agent', 'Dynamics 365');

        if Parameters.ContainsKey('accept') then
            Headers.Add('Accept', Parameters.Get('accept'));

        if Parameters.ContainsKey('username') then begin
            if Parameters.ContainsKey('password') then
                AuthText := StrSubstNo(AuthLbl, Parameters.Get('username'), Parameters.Get('password'))
            else
                AuthText := StrSubstNo(AuthLbl, Parameters.Get('username'), '');
            Headers.Add('Authorization', StrSubstNo(BasicLbl, Base64Convert.ToBase64(AuthText)));
        end;

        if Parameters.ContainsKey('etag') then
            Headers.Add('If-Match', Parameters.Get('etag'));

        if Parameters.ContainsKey('httpcontent') then begin
            Content.WriteFrom(Parameters.Get('httpcontent'));
            if Parameters.ContainsKey('contenttype') then begin
                Content.GetHeaders(Headers);
                if Headers.Contains('Content-Type') then
                    Headers.Remove('Content-Type');
                Headers.Add('Content-Type', Parameters.Get('contenttype'));
            end;
            RequestMsg.Content := Content;
        end;

        Client.Send(RequestMsg, ResponseMsg);

        Content := ResponseMsg.Content;
        Content.ReadAs(ResponseMsgTxt);

        EXIT(ResponseMsg.IsSuccessStatusCode);
    end;
}
