codeunit 6014588 "NPR GCP API"
{
    // Google Cloud Print & Authorization Documentation:
    //   https://developers.google.com/cloud-print/docs/appInterfaces
    //   https://developers.google.com/identity/protocols/OAuth2InstalledApp

    trigger OnRun()
    begin
    end;

    var
        _AccessToken: Text;
        _AccessTokenTimeStamp: DateTime;
        _AccessTokenExpiresIn: Integer;
        _RefreshToken: Text;
        Error_HTTPStatus: Label 'HTTP request failed with status %1';
        Error_InvalidJSON: Label 'Invalid response JSON';
        Error_MissingTokens: Label 'Account tokens missing. Please re-register your google account.';
        Error_TooLarge: Label 'File size is above the 2MB limit';
        _RefreshTokenTimeStamp: DateTime;
        _RefreshTokenExpiresIn: Integer;

    local procedure "// Global Accessors"()
    begin
    end;

    procedure GetAccessTokenValue(): Text
    begin
        exit(_AccessToken);
    end;

    procedure GetAccessTokenTimeStamp(): DateTime
    begin
        exit(_AccessTokenTimeStamp);
    end;

    procedure GetAccessTokenExpiresIn(): Integer
    begin
        exit(_AccessTokenExpiresIn);
    end;

    procedure GetRefreshTokenValue(): Text
    begin
        exit(_RefreshToken);
    end;

    procedure GetRefreshTokenTimeStamp(): DateTime
    begin
        exit(_RefreshTokenTimeStamp);
    end;

    procedure GetRefreshTokenExpiresIn(): Integer
    begin
        exit(_RefreshTokenExpiresIn);
    end;

    procedure SetAccessTokenValue(Value: Text)
    begin
        _AccessToken := Value;
    end;

    procedure SetAccessTokenTimeStamp(Value: DateTime)
    begin
        _AccessTokenTimeStamp := Value;
    end;

    procedure SetAccessTokenExpiresIn(Value: Integer)
    begin
        _AccessTokenExpiresIn := Value;
    end;

    procedure SetRefreshTokenValue(Value: Text)
    begin
        _RefreshToken := Value;
    end;

    procedure SetRefreshTokenTimeStamp(Value: DateTime)
    begin
        _RefreshTokenTimeStamp := Value;
    end;

    procedure SetRefreshTokenExpiresIn(Value: Integer)
    begin
        _RefreshTokenExpiresIn := Value;
    end;

    local procedure "// API functions"()
    begin
    end;

    [TryFunction]
    procedure SubmitJob(PrinterID: Text; Title: Text; Ticket: Text; Content: DotNet NPRNetMemoryStream; ContentType: Text; Tag: Text; FirstAttempt: Boolean)
    var
        [SuppressDispose]
        MultipartFormDataContent: DotNet NPRNetMultipartFormDataContent;
        [SuppressDispose]
        ByteArrayContent: DotNet NPRNetByteArrayContent;
        AuthenticationHeader: DotNet NPRNetAuthenticationHeaderValue;
        HttpResponseMessage: DotNet NPRNetHttpResponseMessage;
        "Integer": DotNet NPRNetInt32;
        JObject: DotNet JObject;
        Dictionary: DotNet NPRNetDictionary_Of_T_U;
        Encoding: DotNet NPRNetEncoding;
        Success: Boolean;
    begin
        if (StrLen(_AccessToken) = 0) or (StrLen(_RefreshToken) = 0) then
            Error(Error_MissingTokens);

        if Content.Length > 2000000 then
            Error(Error_TooLarge);

        MultipartFormDataContent := MultipartFormDataContent.MultipartFormDataContent();
        MultipartFormDataContent.Add(ByteArrayContent.ByteArrayContent(Encoding.UTF8.GetBytes(PrinterID)), 'printerid');
        MultipartFormDataContent.Add(ByteArrayContent.ByteArrayContent(Encoding.UTF8.GetBytes(Title)), 'title');
        MultipartFormDataContent.Add(ByteArrayContent.ByteArrayContent(Encoding.UTF8.GetBytes(Ticket)), 'ticket');
        MultipartFormDataContent.Add(ByteArrayContent.ByteArrayContent(Content.ToArray()), 'content', 'file.pdf');
        MultipartFormDataContent.Add(ByteArrayContent.ByteArrayContent(Encoding.UTF8.GetBytes(ContentType)), 'contentType');

        AuthenticationHeader := AuthenticationHeader.AuthenticationHeaderValue('Bearer', _AccessToken);

        if not TryInvokeService(MultipartFormDataContent, 'https://www.google.com', '/cloudprint/submit', 10, AuthenticationHeader, HttpResponseMessage) then
            Error(GetLastErrorText);

        if not HttpResponseMessage.IsSuccessStatusCode then begin
            if FirstAttempt then
                if CheckForTokenExpiration(HttpResponseMessage) then begin
                    SubmitJob(PrinterID, Title, Ticket, Content, ContentType, Tag, false);
                    exit;
                end;
            Error(Error_HTTPStatus, Format(HttpResponseMessage.StatusCode));
        end;

        TryParseJSON(HttpResponseMessage, JObject);
        Evaluate(Success, Format(JObject.Property('success').Value));
        if not Success then
            Error(Format(JObject.Property('errorCode').Value) + ' - ' + Format(JObject.Property('message').Value));
    end;

    [TryFunction]
    procedure LookupPrinter(PrinterID: Text; var OutJObject: DotNet JObject; FirstAttempt: Boolean)
    var
        [SuppressDispose]
        FormUrlEncodedContent: DotNet NPRNetFormUrlEncodedContent;
        AuthenticationHeader: DotNet NPRNetAuthenticationHeaderValue;
        HttpResponseMessage: DotNet NPRNetHttpResponseMessage;
        Dictionary: DotNet NPRNetDictionary_Of_T_U;
        "Integer": DotNet NPRNetInt32;
    begin
        if (StrLen(_AccessToken) = 0) or (StrLen(_RefreshToken) = 0) then
            Error(Error_MissingTokens);

        CreateDotNetDictionary(Dictionary);
        Dictionary.Add('printerid', PrinterID);
        FormUrlEncodedContent := FormUrlEncodedContent.FormUrlEncodedContent(Dictionary);
        AuthenticationHeader := AuthenticationHeader.AuthenticationHeaderValue('Bearer', _AccessToken);

        if not TryInvokeService(FormUrlEncodedContent, 'https://www.google.com', '/cloudprint/printer', 10, AuthenticationHeader, HttpResponseMessage) then
            Error(GetLastErrorText);

        if not HttpResponseMessage.IsSuccessStatusCode then begin
            if FirstAttempt then
                if CheckForTokenExpiration(HttpResponseMessage) then begin
                    LookupPrinter(PrinterID, OutJObject, false);
                    exit;
                end;
            Error(Error_HTTPStatus, Format(HttpResponseMessage.StatusCode));
        end;

        TryParseJSON(HttpResponseMessage, OutJObject);
    end;

    [TryFunction]
    procedure GetPrinters(var OutJObject: DotNet JObject; FirstAttempt: Boolean)
    var
        [SuppressDispose]
        StringContent: DotNet NPRNetStringContent;
        AuthenticationHeader: DotNet NPRNetAuthenticationHeaderValue;
        HttpResponseMessage: DotNet NPRNetHttpResponseMessage;
    begin
        if (StrLen(_AccessToken) = 0) or (StrLen(_RefreshToken) = 0) then
            Error(Error_MissingTokens);

        StringContent := StringContent.StringContent('');
        AuthenticationHeader := AuthenticationHeader.AuthenticationHeaderValue('Bearer', _AccessToken);

        if not TryInvokeService(StringContent, 'https://www.google.com', '/cloudprint/search', 10, AuthenticationHeader, HttpResponseMessage) then
            Error(GetLastErrorText);

        if not HttpResponseMessage.IsSuccessStatusCode then begin
            if FirstAttempt then
                if CheckForTokenExpiration(HttpResponseMessage) then begin
                    GetPrinters(OutJObject, false);
                    exit;
                end;
            Error(Error_HTTPStatus, Format(HttpResponseMessage.StatusCode));
        end;

        TryParseJSON(HttpResponseMessage, OutJObject);
    end;

    [TryFunction]
    procedure AuthenticateUser(AuthCode: Text)
    var
        [SuppressDispose]
        FormUrlEncodedContent: DotNet NPRNetFormUrlEncodedContent;
        [SuppressDispose]
        AuthenticationHeader: DotNet NPRNetAuthenticationHeaderValue;
        HttpResponseMessage: DotNet NPRNetHttpResponseMessage;
        JObject: DotNet JObject;
        Dictionary: DotNet NPRNetDictionary_Of_T_U;        
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        Clear(_AccessToken);
        Clear(_RefreshToken);

        CreateDotNetDictionary(Dictionary);
        Dictionary.Add('code', AuthCode);
        Dictionary.Add('client_id', AzureKeyVaultMgt.GetSecret('GoogleCloudPrintClientId')); 
        Dictionary.Add('client_secret', AzureKeyVaultMgt.GetSecret('GoogleCloudPrintClientSecret'));
        Dictionary.Add('redirect_uri', 'urn:ietf:wg:oauth:2.0:oob');
        Dictionary.Add('grant_type', 'authorization_code');

        FormUrlEncodedContent := FormUrlEncodedContent.FormUrlEncodedContent(Dictionary);

        TryInvokeService(FormUrlEncodedContent, 'https://www.googleapis.com', '/oauth2/v4/token', 10, AuthenticationHeader, HttpResponseMessage);

        if not HttpResponseMessage.IsSuccessStatusCode then
            Error(Error_HTTPStatus, Format(HttpResponseMessage.StatusCode));

        TryParseJSON(HttpResponseMessage, JObject);
        _AccessToken := Format(JObject.Property('access_token').Value);
        Evaluate(_AccessTokenExpiresIn, Format(JObject.Property('expires_in').Value));
        _AccessTokenTimeStamp := CreateDateTime(Today, Time);
        _RefreshToken := Format(JObject.Property('refresh_token').Value);
        _RefreshTokenTimeStamp := _AccessTokenTimeStamp;

        if (StrLen(_AccessToken) = 0) or (StrLen(_RefreshToken) = 0) then
            Error(Error_InvalidJSON);
    end;

    [TryFunction]
    procedure RefreshAccessToken()
    var
        [SuppressDispose]
        FormUrlEncodedContent: DotNet NPRNetFormUrlEncodedContent;
        AuthenticationHeader: DotNet NPRNetAuthenticationHeaderValue;
        HttpResponseMessage: DotNet NPRNetHttpResponseMessage;
        JObject: DotNet JObject;
        Dictionary: DotNet NPRNetDictionary_Of_T_U;
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";        
    begin
        if StrLen(_RefreshToken) = 0 then
            Error(Error_MissingTokens);

        CreateDotNetDictionary(Dictionary);
        Dictionary.Add('client_id', AzureKeyVaultMgt.GetSecret('GoogleCloudPrintClientId'));
        Dictionary.Add('client_secret', AzureKeyVaultMgt.GetSecret('GoogleCloudPrintClientSecret'));
        Dictionary.Add('refresh_token', _RefreshToken);
        Dictionary.Add('grant_type', 'refresh_token');

        FormUrlEncodedContent := FormUrlEncodedContent.FormUrlEncodedContent(Dictionary);

        TryInvokeService(FormUrlEncodedContent, 'https://www.googleapis.com', '/oauth2/v4/token', 10, AuthenticationHeader, HttpResponseMessage);

        if not HttpResponseMessage.IsSuccessStatusCode then
            Error(Error_HTTPStatus, Format(HttpResponseMessage.StatusCode));

        TryParseJSON(HttpResponseMessage, JObject);
        _AccessToken := Format(JObject.Property('access_token').Value);
        Evaluate(_AccessTokenExpiresIn, Format(JObject.Property('expires_in').Value));
        _AccessTokenTimeStamp := CreateDateTime(Today, Time);

        if (StrLen(_AccessToken) = 0) then
            Error(Error_InvalidJSON);
    end;

    local procedure "// Aux"()
    begin
    end;

    [TryFunction]
    local procedure TryInvokeService(HttpContent: DotNet NPRNetHttpContent; BaseAddress: Text; Endpoint: Text; TimeoutSeconds: Integer; AuthenticationHeader: DotNet NPRNetAuthenticationHeaderValue; HttpResponseMessage: DotNet NPRNetHttpResponseMessage)
    var
        HttpClient: DotNet NPRNetHttpClient;
        Uri: DotNet NPRNetUri;
        TimeSpan: DotNet NPRNetTimeSpan;
    begin
        HttpClient := HttpClient.HttpClient();
        HttpClient.BaseAddress := Uri.Uri(BaseAddress);
        HttpClient.Timeout := TimeSpan.TimeSpan(0, 0, TimeoutSeconds);

        HttpClient.DefaultRequestHeaders.Clear();
        if not IsNull(AuthenticationHeader) then
            HttpClient.DefaultRequestHeaders.Authorization := AuthenticationHeader;

        HttpResponseMessage := HttpClient.PostAsync(Endpoint, HttpContent).Result();
    end;

    [TryFunction]
    local procedure TryParseJSON(HttpResponseMessage: DotNet NPRNetHttpResponseMessage; JObject: DotNet JObject)
    var
        Text: Text;
    begin
        Text := HttpResponseMessage.Content.ReadAsStringAsync().Result;
        JObject := JObject.Parse(Text);
    end;

    local procedure CreateDotNetDictionary(Dictionary: DotNet NPRNetDictionary_Of_T_U)
    var
        Type: DotNet NPRNetType;
        Activator: DotNet NPRNetActivator;
        Arr: DotNet NPRNetArray;
        String: DotNet NPRNetString;
    begin
        Arr := Arr.CreateInstance(GetDotNetType(Type), 2);
        Arr.SetValue(GetDotNetType(String), 0);
        Arr.SetValue(GetDotNetType(String), 1);

        Type := GetDotNetType(Dictionary);
        Type := Type.MakeGenericType(Arr);

        Dictionary := Activator.CreateInstance(Type);
    end;

    local procedure CheckForTokenExpiration(HttpResponseMessage: DotNet NPRNetHttpResponseMessage): Boolean
    var
        Convert: DotNet NPRNetConvert;
    begin
        //403 can mean expired access token so try renewal.
        if Convert.ToInt32(HttpResponseMessage.StatusCode) = 403 then
            exit(RefreshAccessToken);
    end;
}

