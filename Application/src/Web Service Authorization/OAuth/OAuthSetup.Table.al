table 6014604 "NPR OAuth Setup"
{
    Access = Internal;
    Caption = 'OAuth Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(5; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(6; "AAD Tenant Id"; Text[250])
        {
            Caption = 'AAD Tenant Id';
            DataClassification = EndUserIdentifiableInformation;
        }

        field(10; "Client ID"; Guid)
        {
            Caption = 'Client ID Secret Key';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; "Client Secret"; Guid)
        {
            Caption = 'Client Secret Secret Key';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20; "Access Token"; Guid)
        {
            Caption = 'Access Token Secret Key';
            DataClassification = EndUserIdentifiableInformation;
        }

        field(25; "Get Access Token URL"; Text[250])
        {
            Caption = 'Access Token URL Path';
            DataClassification = EndUserPseudonymousIdentifiers;
        }

        field(30; Scope; Text[250])
        {
            Caption = 'Scope';
            DataClassification = EndUserPseudonymousIdentifiers;

        }
        field(35; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Rec.TestField("Get Access Token URL");
                Rec.TestField("Client ID");
                Rec.TestField("Client Secret");
            end;
        }
        field(40; "Access Token Due DateTime"; DateTime)
        {
            Caption = 'Access Token Due DateTime';
            Editable = false;
            DataClassification = SystemMetadata;
        }

        field(41; "Access Token Duration Offset"; Integer)
        {
            Caption = 'Access Token Duration Offset (seconds)';
            InitValue = 60;
            MinValue = 0;
            MaxValue = 1000;
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    var

        GetTokenErrorTxt: Label 'OAuth Token could not be retrieved.\\Error Status Code: %1;\\Description: %2';

    [NonDebuggable]
    procedure SetSecret(FieldNo: Integer; NewSecretValue: Text)
    begin
        Case FieldNo of
            Rec.FieldNo("Client ID"):
                begin
                    if IsNullGuid("Client ID") then
                        Rec."Client ID" := CreateGuid();
                    SetSecret("Client ID", NewSecretValue);
                end;

            Rec.FieldNo("Client Secret"):
                begin
                    if IsNullGuid("Client Secret") then
                        Rec."Client Secret" := CreateGuid();
                    SetSecret("Client Secret", NewSecretValue);
                end;
            Rec.FieldNo("Access Token"):
                begin
                    if IsNullGuid("Access Token") then
                        Rec."Access Token" := CreateGuid();
                    SetSecret("Access Token", NewSecretValue);
                end;
        End;
    end;

    [NonDebuggable]
    local procedure SetSecret(SecretKey: Text; NewSecretValue: Text)
    begin
        if not EncryptionEnabled() then
            IsolatedStorage.Set(SecretKey, NewSecretValue, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted(SecretKey, NewSecretValue, DataScope::Company);
    end;

    [NonDebuggable]
    procedure GetSecret(FieldNo: Integer) SecretValue: Text
    begin
        Case FieldNo of
            Rec.FieldNo("Client ID"):
                if not IsNullGuid(Rec."Client ID") then
                    if IsolatedStorage.Get("Client ID", DataScope::Company, SecretValue) then;
            Rec.FieldNo("Client Secret"):
                if not IsNullGuid(Rec."Client Secret") then
                    if IsolatedStorage.Get("Client Secret", DataScope::Company, SecretValue) then;
            Rec.FieldNo("Access Token"):
                if not IsNullGuid(Rec."Access Token") then
                    if IsolatedStorage.Get("Access Token", DataScope::Company, SecretValue) then;
        End;
    end;

    [NonDebuggable]
    procedure HasSecret(FieldNo: Integer): Boolean
    begin
        exit(GetSecret(FieldNo) <> '');
    end;

    procedure RemoveSecret(FieldNo: Integer)
    begin
        Case FieldNo of
            Rec.FieldNo("Client ID"):
                begin
                    IsolatedStorage.Delete("Client ID", DataScope::Company);
                    Clear("Client ID");
                end;
            Rec.FieldNo("Client Secret"):
                begin
                    IsolatedStorage.Delete("Client Secret", DataScope::Company);
                    Clear("Client Secret");
                end;
            Rec.FieldNo("Access Token"):
                begin
                    IsolatedStorage.Delete("Access Token", DataScope::Company);
                    Clear("Access Token");
                end;
        End;
    end;

    trigger OnDelete()
    begin
        if Rec.HasSecret(Rec.FieldNo("Client Id")) then
            Rec.RemoveSecret(Rec.FieldNo("Client ID"));
        if Rec.HasSecret(Rec.FieldNo("Client Secret")) then
            Rec.RemoveSecret(Rec.FieldNo("Client Secret"));
        if Rec.HasSecret(Rec.FieldNo("Access Token")) then
            Rec.RemoveSecret(Rec.FieldNo("Access Token"));
    end;

    procedure GetOauthToken(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        Content: HttpContent;
        APIResult: Text;
        RequestBody: Text;
        ErrorTxt: text;
        ClientId:Text;
        ClientSecret:Text;
        LocScope:Text;
    begin
        if CheckExistingTokenIsValid() then // if existing token is not expired use it
            exit(Rec.GetSecret(Rec.FieldNo("Access Token")));

        Client.SetBaseAddress(GetTokenBaseAddress());
        RequestMessage.Method('POST');
        ClientId := GetSecret(FieldNo("Client ID"));
        ClientSecret := GetSecret(FieldNo("Client Secret"));
        LocScope := GetScope();
        RequestBody := StrSubstNo('grant_type=client_credentials&client_id=%1&client_secret=%2&scope=%3',
                        TypeHelper.UrlEncode(ClientId),
                        TypeHelper.UrlEncode(ClientSecret),
                        TypeHelper.UrlEncode(LocScope));

        Content.WriteFrom(RequestBody);
        Content.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Content-Type');
        RequestHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');
        RequestMessage.Content(Content);

        if not IsSuccessfulRequest(Client.Send(RequestMessage, ResponseMessage), ResponseMessage, ErrorTxt) then
            Error(ErrorTxt);

        ResponseMessage.Content().ReadAs(APIResult);
        SaveNewToken(APIResult);
        exit(Rec.GetSecret(Rec.FieldNo("Access Token")));
    end;

    local procedure SaveNewToken(JsonResponseTxt: Text)
    var
        JsonObj: JsonObject;
        JsonTok: JsonToken;
    begin
        JsonObj.ReadFrom(JsonResponseTxt);
        if JsonObj.SelectToken('access_token', JsonTok) then
            Rec.SetSecret(FieldNo("Access Token"), JsonTok.AsValue().AsText());
        if JsonObj.SelectToken('expires_in', JsonTok) then
            Rec."Access Token Due DateTime" := CurrentDateTime + (JsonTok.AsValue().AsInteger() * 1000);

        Rec.Modify();
    end;

    local procedure CheckExistingTokenIsValid(): Boolean
    begin
        if Rec."Access Token Due DateTime" = 0DT then
            exit(false);
        Exit((Rec."Access Token Due DateTime" - Rec."Access Token Duration Offset" * 1000) > CurrentDateTime);
    end;

    local procedure GetTokenBaseAddress(): text
    begin
        Rec.TestField("Get Access Token URL");
        if StrPos(Rec."Get Access Token URL".ToLower(), '{aadtenantid}') > 0 then begin
            Rec.TestField("AAD Tenant Id");
            Exit(Rec."Get Access Token URL".ToLower().Replace('{aadtenantid}', Rec."AAD Tenant Id"));
        end;
        exit(Rec."Get Access Token URL");
    end;

    local procedure GetScope(): text
    begin
        Rec.TestField(Scope);
        if StrPos(Rec.Scope.ToLower(), '{clientid}') > 0 then begin
            Rec.TestField("Client ID");
            Exit(Rec.Scope.ToLower().Replace('{clientid}', GetSecret(FieldNo("Client ID"))));
        end;
        exit(Rec.Scope);
    end;

    procedure IsSuccessfulRequest(TransportOK: Boolean; Response: HttpResponseMessage; var ErrorTxt: Text): Boolean
    begin
        if TransportOK and Response.IsSuccessStatusCode() then
            exit(true);

        ErrorTxt := StrSubstNo(GetTokenErrorTxt, Response.HttpStatusCode, Response.ReasonPhrase);
        exit(false);
    end;
}
