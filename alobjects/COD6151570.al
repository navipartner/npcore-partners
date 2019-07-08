codeunit 6151570 "AF Management"
{
    // NPR5.36/CLVA/20170710 CASE 269792 AF Management


    trigger OnRun()
    begin
    end;

    procedure CallRESTWebService(var Parameters: DotNet Dictionary_Of_T_U;var HttpResponseMessage: DotNet HttpResponseMessage): Boolean
    var
        HttpContent: DotNet HttpContent;
        HttpClient: DotNet HttpClient;
        AuthHeaderValue: DotNet AuthenticationHeaderValue;
        EntityTagHeaderValue: DotNet EntityTagHeaderValue;
        Uri: DotNet Uri;
        Bytes: DotNet Array;
        Encoding: DotNet Encoding;
        Convert: DotNet Convert;
        HttpRequestMessage: DotNet HttpRequestMessage;
        HttpMethod: DotNet HttpMethod;
    begin
        HttpClient := HttpClient.HttpClient();
        HttpClient.BaseAddress := Uri.Uri(Format(Parameters.Item('baseurl')));

        HttpRequestMessage :=
          HttpRequestMessage.HttpRequestMessage(HttpMethod.HttpMethod(UpperCase(Format(Parameters.Item('restmethod')))),
                                                Format(Parameters.Item('path')));;

        if Parameters.ContainsKey('accept') then
          HttpRequestMessage.Headers.Add('Accept',Format(Parameters.Item('accept')));

        if Parameters.ContainsKey('username') then begin
          if Parameters.ContainsKey('password') then
            Bytes := Encoding.ASCII.GetBytes(StrSubstNo('%1:%2',Format(Parameters.Item('username')),Format(Parameters.Item('password'))))
          else
            Bytes := Encoding.ASCII.GetBytes(StrSubstNo('%1:%2',Format(Parameters.Item('username')),''));
          AuthHeaderValue := AuthHeaderValue.AuthenticationHeaderValue('Basic',Convert.ToBase64String(Bytes));
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

