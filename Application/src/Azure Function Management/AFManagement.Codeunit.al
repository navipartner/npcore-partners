codeunit 6151570 "NPR AF Management"
{
    procedure CallRESTWebService(var Parameters: Dictionary of [Text, Text]; HttpCont: HttpContent; var HttpResponseMsg: HttpResponseMessage): Boolean
    var
        HttpClnt: HttpClient;
        HttpHdr: HttpHeaders;

        HttpReqestMsg: HttpRequestMessage;
        OutputContent: Text;
        Base64Convert: Codeunit "Base64 Convert";
        Base64UserPass: Text;
        User: Text;
        Pass: Text;
    begin
        HttpClnt.DefaultRequestHeaders.Clear();

        HttpCont.ReadAs(OutputContent);
        if OutputContent <> '' then
            HttpReqestMsg.Content := HttpCont;

        if Parameters.ContainsKey('baseurl') then begin
            Parameters.Get('baseurl', OutputContent);
            HttpReqestMsg.SetRequestUri(OutputContent);
        end;

        if Parameters.ContainsKey('restmethod') then begin
            Parameters.Get('restmethod', OutputContent);
            HttpReqestMsg.Method(OutputContent);
        end;

        if Parameters.ContainsKey('path') then begin
            Parameters.Get('path', OutputContent);
            HttpReqestMsg.SetRequestUri(OutputContent);
        end;

        HttpReqestMsg.GetHeaders(HttpHdr);
        HttpHdr.Clear();

        if Parameters.ContainsKey('accept') then begin
            Parameters.Get('accept', OutputContent);
            HttpHdr.Add('Accept', OutputContent)
        end;
        if Parameters.ContainsKey('username') then begin
            Parameters.Get('username', User);
            if Parameters.ContainsKey('password') then
                Parameters.Get('password', Pass);
            Base64UserPass := Base64Convert.ToBase64(User + ':' + Pass);
            HttpHdr.Add('Authorization', 'Basic ' + Base64UserPass);
        end;

        if HttpClnt.Send(HttpReqestMsg, HttpResponseMsg) then;

        exit(HttpResponseMsg.IsSuccessStatusCode);
    end;
}

