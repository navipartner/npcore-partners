codeunit 6151570 "NPR AF Management"
{
    [Obsolete('Use native Business Central objects')]
    procedure CallRESTWebService(var Parameters: DotNet NPRNetDictionary_Of_T_U; var HttpResponseMessage: DotNet NPRNetHttpResponseMessage): Boolean
    var
        HttpContent: DotNet NPRNetHttpContent;
        HttpClient: DotNet NPRNetHttpClient;
        AuthHeaderValue: DotNet NPRNetAuthenticationHeaderValue;
        EntityTagHeaderValue: DotNet NPRNetEntityTagHeaderValue;
        Uri: DotNet NPRNetUri;
        Bytes: DotNet NPRNetArray;
        Encoding: DotNet NPRNetEncoding;
        Convert: DotNet NPRNetConvert;
        HttpRequestMessage: DotNet NPRNetHttpRequestMessage;
        HttpMethod: DotNet NPRNetHttpMethod;
    begin
        HttpClient := HttpClient.HttpClient();
        HttpClient.BaseAddress := Uri.Uri(Format(Parameters.Item('baseurl')));

        HttpRequestMessage :=
          HttpRequestMessage.HttpRequestMessage(HttpMethod.HttpMethod(UpperCase(Format(Parameters.Item('restmethod')))),
                                                Format(Parameters.Item('path')));
        ;

        if Parameters.ContainsKey('accept') then
            HttpRequestMessage.Headers.Add('Accept', Format(Parameters.Item('accept')));

        if Parameters.ContainsKey('username') then begin
            if Parameters.ContainsKey('password') then
                Bytes := Encoding.ASCII.GetBytes(StrSubstNo('%1:%2', Format(Parameters.Item('username')), Format(Parameters.Item('password'))))
            else
                Bytes := Encoding.ASCII.GetBytes(StrSubstNo('%1:%2', Format(Parameters.Item('username')), ''));
            AuthHeaderValue := AuthHeaderValue.AuthenticationHeaderValue('Basic', Convert.ToBase64String(Bytes));
            HttpRequestMessage.Headers.Authorization := AuthHeaderValue;
        end;

        if Parameters.ContainsKey('etag') then
            HttpRequestMessage.Headers.IfMatch.Add(Parameters.Item('etag'));

        if Parameters.ContainsKey('httpcontent') then
            HttpRequestMessage.Content := Parameters.Item('httpcontent');

        HttpResponseMessage := HttpClient.SendAsync(HttpRequestMessage).Result;
        exit(HttpResponseMessage.IsSuccessStatusCode);
    end;

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

