codeunit 6151493 "NPR Raptor API"
{
    // NPR5.51/CLVA/20190710  CASE 355871 Object created
    // NPR5.53/ALPO/20191119 CASE 377727 Raptor integration enhancements


    trigger OnRun()
    begin
    end;

    procedure SendRaptorRequest(BaseUrl: Text; Path: Text; var ErrorMsg: Text) Result: Text
    var
        Parameters: DotNet NPRNetDictionary_Of_T_U;
        HttpResponseMessage: DotNet NPRNetHttpResponseMessage;
        RequestStatus: Boolean;
    begin
        Parameters := Parameters.Dictionary();
        Parameters.Add('baseurl', BaseUrl);
        Parameters.Add('restmethod', 'GET');
        Parameters.Add('path', Path);

        RequestStatus := CallRaptorAPI(Parameters, HttpResponseMessage);
        Result := HttpResponseMessage.Content.ReadAsStringAsync.Result;

        if not RequestStatus then begin
            ErrorMsg := Result;
            Result := '';
        end;
    end;

    procedure CallRaptorAPI(var Parameters: DotNet NPRNetDictionary_Of_T_U; var HttpResponseMessage: DotNet NPRNetHttpResponseMessage): Boolean
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
}

