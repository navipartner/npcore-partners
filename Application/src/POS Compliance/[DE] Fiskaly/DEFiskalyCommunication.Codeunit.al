codeunit 6014445 "NPR DE Fiskaly Communication"
{
    Access = Internal;

    procedure SendDocument(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info")
    var
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
    begin
        if not TrySendDocument(DeAuditAux) then
            DEAuditMgt.SetErrorMsg(DeAuditAux);
        DeAuditAux.Modify();
    end;

    #region manage Transactions
    [TryFunction]
    local procedure TrySendDocument(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info")
    var
        DETSS: Record "NPR DE TSS";
        POSUnitAux: Record "NPR DE POS Unit Aux. Info";
    begin
        DeAuditAux.TestField("Transaction ID");
        DeAuditAux.TestField("Client ID");
        POSUnitAux.GetBySystemId(DeAuditAux."Client ID");
        POSUnitAux.TestField("Fiskaly Client Created at");

        DeAuditAux.TestField("TSS Code");
        DETSS.Get(DeAuditAux."TSS Code");
        DETSS.TestField("Fiskaly TSS Created at");
        DeAuditAux.TestField("TSS ID", DETSS.SystemId);

        if DeAuditAux."Fiscalization Status" = DeAuditAux."Fiscalization Status"::"Not Fiscalized" then
            StartTransaction(DeAuditAux);

        EndTransaction(DeAuditAux);
    end;

    local procedure StartTransaction(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info")
    var
        RequestBody: JsonObject;
    begin
        RequestBody.Add('state', Enum::"NPR DE Fiskaly Trx. State".Names().Get(Enum::"NPR DE Fiskaly Trx. State".Ordinals().IndexOf(Enum::"NPR DE Fiskaly Trx. State"::ACTIVE.AsInteger())));
        RequestBody.Add('client_id', Format(DeAuditAux."Client ID", 0, 4));
        SendTransaction(DeAuditAux, RequestBody);
    end;

    local procedure EndTransaction(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info")
    var
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        RequestBody: JsonObject;
    begin
        DEAuditMgt.CreateDocumentJson(DeAuditAux, Enum::"NPR DE Fiskaly Trx. State"::FINISHED, RequestBody);
        SendTransaction(DeAuditAux, RequestBody);
    end;

    local procedure SendTransaction(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info"; RequestBody: JsonObject)
    var
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        ResponseJson: JsonToken;
        Url: Text;
        TrxUploadErr: Label 'Error while trying to send a transaction to Fiskaly.\%1';
    begin
        Url := StrSubstNo('/tss/%1/tx/%2?tx_revision=%3', Format(DeAuditAux."TSS ID", 0, 4), Format(DeAuditAux."Transaction ID", 0, 4), DeAuditAux."Latest Revision" + 1);
        if not SendRequest_signDE_V2(RequestBody, ResponseJson, 'PUT', Url, GetJwtToken()) then
            Error(TrxUploadErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
        if not DEAuditMgt.DeAuxInfoInsertResponse(DeAuditAux, ResponseJson) then
            Error(GetLastErrorText());
    end;

    procedure GetTransaction(TssId: Guid; TransactionId: Guid; TransactionRevision: Integer) ResponseJson: JsonToken
    var
        RequestBody: JsonObject;
        Url: Text;
        TxGetErr: Label 'Error while trying to get a transaction from Fiskaly.\%1';
    begin
        Url := StrSubstNo('/tss/%1/tx/%2', Format(TssId, 0, 4), Format(TransactionId, 0, 4));
        if TransactionRevision > 0 then
            Url := Url + StrSubstNo('?tx_revision=%1', TransactionRevision);
        if not SendRequest_signDE_V2(RequestBody, ResponseJson, 'GET', Url, GetJwtToken()) then
            Error(TxGetErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
    end;
    #endregion

    #region manage Technical Security Systems (TSS)
    procedure CreateTSS(var DETSS: Record "NPR DE TSS")
    var
        RequestBody: JsonObject;
        RequestMetadata: JsonObject;
        ResponseJson: JsonToken;
        TSSCreateErr: Label 'Error while trying to create a new Technical Security System (TSS) at Fiskaly.\%1';
    begin
        DETSS.TestField(SystemId);
        DETSS.TestField("Fiskaly TSS Created at", 0DT);

        RequestMetadata.Add('company', CompanyName);
        RequestMetadata.Add('bc_code', DETSS.Code);
        RequestMetadata.Add('bc_desription', DETSS.Description);
        RequestBody.Add('metadata', RequestMetadata);

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, 'PUT', StrSubstNo('/tss/%1', Format(DETSS.SystemId, 0, 4)), GetJwtToken()) then
            Error(TSSCreateErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        UpdateDeTssWithDataFromFiskaly(DETSS, ResponseJson);

        if DETSS."Fiskaly TSS State".AsInteger() < DETSS."Fiskaly TSS State"::UNINITIALIZED.AsInteger() then
            UpdateTSS_State(DETSS, DETSS."Fiskaly TSS State"::UNINITIALIZED, true);

        UpdateTSS_AdminPIN(DETSS, '');

        if DETSS."Fiskaly TSS State".AsInteger() < DETSS."Fiskaly TSS State"::INITIALIZED.AsInteger() then begin
            TSS_AuthenticateAdmin(DETSS);
            UpdateTSS_State(DETSS, DETSS."Fiskaly TSS State"::INITIALIZED, true);
            TSS_LogoutAdmin(DETSS);
        end;
    end;

    procedure UpdateTSS_AdminPIN(var DETSS: Record "NPR DE TSS"; NewAdminPIN: Text)
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TSSUpdateErr: Label 'Error while trying to set new admin PIN for a Technical Security System (TSS) at Fiskaly.\%1';
    begin
        DETSS.TestField(SystemId);
        DETSS.TestField("Fiskaly TSS Created at");

        if NewAdminPIN = '' then
            NewAdminPIN := GenerateNewRandomPIN(6);

        RequestBody.Add('admin_puk', DESecretMgt.GetSecretKey(DETSS.AdminPUKSecretLbl()));
        RequestBody.Add('new_admin_pin', NewAdminPIN);

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, 'PATCH', StrSubstNo('/tss/%1/admin', Format(DETSS.SystemId, 0, 4)), GetJwtToken()) then
            Error(TSSUpdateErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        DESecretMgt.SetSecretKey(DETSS.AdminPINSecretLbl(), NewAdminPIN);
        Commit();
    end;

    procedure TSS_AuthenticateAdmin(DETSS: Record "NPR DE TSS")
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TSSAdminAuthErr: Label 'Error while trying to authenticate admin of a Technical Security System (TSS) at Fiskaly.\%1';
    begin
        DETSS.TestField(SystemId);
        DETSS.TestField("Fiskaly TSS Created at");

        RequestBody.Add('admin_pin', DESecretMgt.GetSecretKey(DETSS.AdminPINSecretLbl()));

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, 'POST', StrSubstNo('/tss/%1/admin/auth', Format(DETSS.SystemId, 0, 4)), GetJwtToken()) then
            Error(TSSAdminAuthErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
    end;

    procedure TSS_LogoutAdmin(DETSS: Record "NPR DE TSS")
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
    begin
        DETSS.TestField(SystemId);
        DETSS.TestField("Fiskaly TSS Created at");

        SendRequest_signDE_V2(RequestBody, ResponseJson, 'POST', StrSubstNo('/tss/%1/admin/logout', Format(DETSS.SystemId, 0, 4)), GetJwtToken());
    end;

    procedure UpdateTSS_State(var DETSS: Record "NPR DE TSS"; NewState: Enum "NPR DE TSS State"; UpdateBCInfo: Boolean)
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TSSUpdateErr: Label 'Error while trying to update a Technical Security System (TSS) at Fiskaly.\%1';
    begin
        DETSS.TestField(SystemId);
        DETSS.TestField("Fiskaly TSS Created at");

        RequestBody.Add('state', Enum::"NPR DE TSS State".Names().Get(Enum::"NPR DE TSS State".Ordinals().IndexOf(NewState.AsInteger())));

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, 'PATCH', StrSubstNo('/tss/%1', Format(DETSS.SystemId, 0, 4)), GetJwtToken()) then
            Error(TSSUpdateErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        if UpdateBCInfo then
            UpdateDeTssWithDataFromFiskaly(DETSS, ResponseJson);
    end;

    procedure GetTSSList()
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TSSListAccessErr: Label 'Error while retrieving list of Technical Security Systems (TSS) from Fiskaly.\%1';
    begin
        if not SendRequest_signDE_V2(RequestBody, ResponseJson, 'GET', '/tss', GetJwtToken()) then
            Error(TSSListAccessErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
        UpdateDeTssListFromFiskaly(ResponseJson);
    end;

    local procedure UpdateDeTssListFromFiskaly(ResponseJson: JsonToken)
    var
        DETSS: Record "NPR DE TSS";
        JToken: JsonToken;
        TssObject: JsonToken;
        TssObjects: JsonToken;
    begin
        if not ResponseJson.SelectToken('data', TssObjects) then
            exit;
        if not TssObjects.IsArray() then
            exit;
        foreach TssObject in TssObjects.AsArray() do begin
            TssObject.SelectToken('_id', JToken);
            FindOrCreateNewDeTss(DETSS, JToken.AsValue().AsText());
            UpdateDeTssWithDataFromFiskaly(DETSS, TssObject);
        end;
    end;

    local procedure FindOrCreateNewDeTss(var DETSS: Record "NPR DE TSS"; TSS_Id: Guid)
    begin
        if DETSS.GetBySystemId(TSS_Id) then
            exit;
        DETSS.Code := '0001';
        while DETSS.Find() do
            DETSS.Code := IncStr(DETSS.Code);
        DETSS.Init();
        DETSS.SystemId := TSS_Id;
        DETSS.Insert(false, true);
    end;

    local procedure UpdateDeTssWithDataFromFiskaly(var DETSS: Record "NPR DE TSS"; ResponseJson: JsonToken)
    var
        TypeHelper: Codeunit "Type Helper";
        JToken: JsonToken;
        Description: Text[100];
        State: Text;
    begin
        if ResponseJson.SelectToken('time_creation', JToken) then
            DETSS."Fiskaly TSS Created at" := TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('description', JToken) then begin
            Description := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(Description));
            if (Description <> '') and (DETSS.Description <> Description) then
                DETSS.Description := Description;
        end;

        ResponseJson.SelectToken('state', JToken);
        State := JToken.AsValue().AsText();
        if not Enum::"NPR DE TSS State".Names().Contains(State) then
            DETSS."Fiskaly TSS State" := DETSS."Fiskaly TSS State"::Unknown
        else
            DETSS."Fiskaly TSS State" := Enum::"NPR DE TSS State".FromInteger(Enum::"NPR DE TSS State".Ordinals().Get(Enum::"NPR DE TSS State".Names().IndexOf(State)));
        DETSS.Modify();

        if ResponseJson.SelectToken('admin_puk', JToken) then
            DESecretMgt.SetSecretKey(DETSS.AdminPUKSecretLbl(), JToken.AsValue().AsText());
        Commit();
    end;

    procedure GenerateNewRandomPIN(Length: Integer): Text
    var
        Counter: Integer;
        Digit: Integer;
        Result: Text;
    begin
        if Length < 1 then
            Length := 1;
        Randomize();
        for Counter := 1 to Length do begin
            if Counter = 1 then
                Digit := Random(9)
            else
                Digit := Random(10) - 1;
            Result := Result + Format(Digit);
        end;
        exit(Result);
    end;
    #endregion

    #region manage TSS clients
    procedure CreateClient(var PosUnitAuxDE: Record "NPR DE POS Unit Aux. Info")
    var
        DETSS: Record "NPR DE TSS";
        RequestBody: JsonObject;
        RequestMetadata: JsonObject;
        ResponseJson: JsonToken;
        ClientCreateErr: Label 'Error while trying to create a new Client at Fiskaly.\%1';
    begin
        PosUnitAuxDE.TestField(SystemId);
        PosUnitAuxDE.TestField("Fiskaly Client Created at", 0DT);
        PosUnitAuxDE.TestField("TSS Code");
        DETSS.Get(PosUnitAuxDE."TSS Code");
        if DETSS."Fiskaly TSS Created at" = 0DT then begin
            CreateTSS(DETSS);
            Commit();
        end;
        TSS_AuthenticateAdmin(DETSS);

        RequestBody.Add('serial_number', PosUnitAuxDE."Serial Number");
        RequestMetadata.Add('company', CompanyName);
        RequestMetadata.Add('pos_unit_no', PosUnitAuxDE."POS Unit No.");
        RequestMetadata.Add('tss_bc_code', DETSS."Code");
        RequestBody.Add('metadata', RequestMetadata);

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, 'PUT', StrSubstNo('/tss/%1/client/%2', Format(DETSS.SystemId, 0, 4), Format(PosUnitAuxDE.SystemId, 0, 4)), GetJwtToken()) then
            Error(ClientCreateErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
        UpdateDeTssClientWithDataFromFiskaly(PosUnitAuxDE, ResponseJson);

        TSS_LogoutAdmin(DETSS);
    end;

    procedure GetTSSClientList(DETSS: Record "NPR DE TSS")
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TSSClientListAccessErr: Label 'Error while retrieving list of clients from Fiskaly.\%1';
    begin
        if not SendRequest_signDE_V2(RequestBody, ResponseJson, 'GET', StrSubstNo('/tss/%1/client', Format(DETSS.SystemId, 0, 4)), GetJwtToken()) then
            Error(TSSClientListAccessErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
        UpdateDeTssClientFromFiskaly(ResponseJson);
    end;

    local procedure UpdateDeTssClientFromFiskaly(ResponseJson: JsonToken)
    var
        PosUnitAuxDE: Record "NPR DE POS Unit Aux. Info";
        JToken: JsonToken;
        TssClient: JsonToken;
        TssClients: JsonToken;
    begin
        if not ResponseJson.SelectToken('data', TssClients) then
            exit;
        if not TssClients.IsArray() then
            exit;
        foreach TssClient in TssClients.AsArray() do begin
            TssClient.SelectToken('_id', JToken);
            if not PosUnitAuxDE.GetBySystemId(JToken.AsValue().AsText()) then begin
                PosUnitAuxDE."POS Unit No." := '_UKN000001';
                while PosUnitAuxDE.Find() do
                    PosUnitAuxDE."POS Unit No." := IncStr(PosUnitAuxDE."POS Unit No.");
                PosUnitAuxDE.SystemId := JToken.AsValue().AsText();
                PosUnitAuxDE.Insert(false, true);
            end;
            UpdateDeTssClientWithDataFromFiskaly(PosUnitAuxDE, TssClient);
        end;
    end;

    local procedure UpdateDeTssClientWithDataFromFiskaly(var PosUnitAuxDE: Record "NPR DE POS Unit Aux. Info"; ResponseJson: JsonToken)
    var
        DETSS: Record "NPR DE TSS";
        TypeHelper: Codeunit "Type Helper";
        JToken: JsonToken;
        State: Text;
    begin
        ResponseJson.SelectToken('time_creation', JToken);
        PosUnitAuxDE."Fiskaly Client Created at" := TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger());

        ResponseJson.SelectToken('tss_id', JToken);
        FindOrCreateNewDeTss(DETSS, JToken.AsValue().AsText());
        PosUnitAuxDE."TSS Code" := DETSS."Code";

        ResponseJson.SelectToken('serial_number', JToken);
        PosUnitAuxDE."Serial Number" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(PosUnitAuxDE."Serial Number"));

        ResponseJson.SelectToken('state', JToken);
        State := JToken.AsValue().AsText();
        if not Enum::"NPR DE TSS Client State".Names().Contains(State) then
            PosUnitAuxDE."Fiskaly Client State" := PosUnitAuxDE."Fiskaly Client State"::Unknown
        else
            PosUnitAuxDE."Fiskaly Client State" :=
                Enum::"NPR DE TSS Client State".FromInteger(Enum::"NPR DE TSS Client State".Ordinals().Get(Enum::"NPR DE TSS Client State".Names().IndexOf(State)));
        PosUnitAuxDE.Modify();
        Commit();
    end;
    #endregion

    #region V1 API request handling (obsolete)
    /*[TryFunction]
    [NonDebuggable]
    local procedure SendRequest(RequestBodyPar: JsonObject; RestMethod: text; Url: Text; ResponseJsonPar: JsonObject)
    var
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        ContextToken: JsonToken;
        RequestBodyTxt: Text;
        ResponseTxt: Text;
    begin
        CheckHttpClientRequestsAllowed();

        RequestBodyPar.WriteTo(RequestBodyTxt);
        Content.WriteFrom(RequestBodyTxt);

        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');

        HttpWebRequest.Content(Content);

        HttpWebRequest.SetRequestUri(Url);
        HttpWebRequest.Method(RestMethod);
        HttpWebRequest.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');
        Headers.Add('User-Agent', 'Dynamics 365');

        Client.Send(HttpWebRequest, HttpWebResponse);

        if not HttpWebResponse.Content.ReadAs(ResponseTxt) then
            ResponseTxt := '';

        if not HttpWebResponse.IsSuccessStatusCode then
            Error('%1: %2\%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, ResponseTxt);

        ResponseJsonPar.ReadFrom(ResponseTxt);
        CheckForErrors(ResponseJsonPar, RequestBodyTxt);
        ResponseJsonPar.SelectToken('$.result.context', ContextToken);
        LastContext := ContextToken.AsValue().AsText();
    end;

    local procedure CreateRequestBody(ParamsJson: JsonObject; MethodPar: Text) RequestBody: JsonObject
    var
        IdInt: BigInteger;
    begin
        Evaluate(IdInt, Format(CurrentDateTime, 0, '<Year><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>'));
        RequestBody.Add('jsonrpc', '2.0');
        RequestBody.Add('method', MethodPar);
        RequestBody.Add('params', ParamsJson);
        RequestBody.Add('id', IdInt);
    end;

    local procedure CheckForErrors(ResponseJsonPar: JsonObject; RequestJsonPar: Text)
    var
        ErrorToken: JsonToken;
        FiskalyCodeToken: JsonToken;
        FiskalyMessageToken: JsonToken;
        HTTPCodeToken: JsonToken;
        HTTPMessageToken: JsonToken;
        ErrorMessage: Text;
        FiskalyErrorCodeLbl: Label 'Fiskaly Error Code: ';
        FiskalyErrorMessageLbl: Label 'Fiskaly Error Message: ';
        HTTPErrorCodeLbl: Label 'HTTP Error Code: ';
        HTTPErrorMessageLbl: Label 'HTTP Error Message: ';
        RequestJsonLbl: Label 'Request Json:';
    begin
        if not ResponseJsonPar.SelectToken('error', ErrorToken) then
            exit;

        if ErrorToken.SelectToken('code', FiskalyCodeToken) then
            ErrorMessage := FiskalyErrorCodeLbl + Format(FiskalyCodeToken.AsValue().AsText());
        if ErrorToken.SelectToken('message', FiskalyMessageToken) then
            ErrorMessage += '; ' + FiskalyErrorMessageLbl + FiskalyMessageToken.AsValue().AsText();
        if ErrorToken.SelectToken('$.data.response.status', HTTPCodeToken) then
            ErrorMessage += '; ' + HTTPErrorCodeLbl + Format(HTTPCodeToken.AsValue().AsInteger());
        if ErrorToken.SelectToken('$.data.response.body', HTTPMessageToken) then
            ErrorMessage += '; ' + HTTPErrorMessageLbl + Base64Convert.FromBase64(HTTPMessageToken.AsValue().AsText());

        ErrorMessage += '\' + RequestJsonLbl + '\';
        Error('%1\%2', ErrorMessage, RequestJsonPar);
    end;*/
    #endregion

    #region V2 (signDE) API request handling
    [TryFunction]
    internal procedure SendRequest_signDE_V2(RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; RestMethod: Text; UrlFunction: Text; AccessToken: Text)
    var
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestBodyTxt: Text;
        ResponseTxt: Text;
        BearerToken: Label 'Bearer %1', Locked = true;
    begin
        CheckHttpClientRequestsAllowed();

        if UpperCase(RestMethod) <> 'GET' then begin
            RequestBodyJsonIn.WriteTo(RequestBodyTxt);
            Content.WriteFrom(RequestBodyTxt);

            Content.GetHeaders(Headers);
            if Headers.Contains('Content-Type') then
                Headers.Remove('Content-Type');
            Headers.Add('Content-Type', 'application/json');
            HttpWebRequest.Content(Content);
        end;

        DEAuditSetup.GetRecordOnce(false);
        DEAuditSetup.TestField("Api URL");
        HttpWebRequest.SetRequestUri(DEAuditSetup."Api URL" + UrlFunction);
        HttpWebRequest.Method := RestMethod;
        HttpWebRequest.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');
        Headers.Add('User-Agent', 'Dynamics 365');
        if AccessToken <> '' then
            Headers.Add('Authorization', StrSubstNo(BearerToken, AccessToken));

        Client.Send(HttpWebRequest, HttpWebResponse);
        if not HttpWebResponse.Content.ReadAs(ResponseTxt) then
            ResponseTxt := '';

        if not HttpWebResponse.IsSuccessStatusCode then
            Error('%1: %2\%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, ResponseTxt);

        ResponseJsonOut.ReadFrom(ResponseTxt);
    end;

    [TryFunction]
    procedure GetJwtToken(var AccessToken: Text)
    begin
        AccessToken := GetJwtToken();
    end;

    procedure GetJwtToken(): Text
    var
        FiskalyJWT: Codeunit "NPR FiskalyJWT";
        RefreshTokenJson: JsonObject;
        JWTResponseJson: JsonToken;
        AccessToken: Text;
        RefreshToken: Text;
        AccessTokenRefreshErr: Label 'Error while trying to get authentication token from the server.\%1';
    begin
        if FiskalyJWT.GetToken(AccessToken, RefreshToken) then
            exit(AccessToken);

        DEAuditSetup.GetRecordOnce(false);
        if RefreshToken <> '' then
            RefreshTokenJson.Add('refresh_token', RefreshToken)
        else begin
            RefreshTokenJson.Add('api_key', DESecretMgt.GetSecretKey(DEAuditSetup.ApiKeyLbl()));
            RefreshTokenJson.Add('api_secret', DESecretMgt.GetSecretKey(DEAuditSetup.ApiSecretLbl()));
        end;
        ClearLastError();
        if SendRequest_signDE_V2(RefreshTokenJson, JWTResponseJson, 'POST', '/auth', '') then begin
            FiskalyJWT.SetJWT(JWTResponseJson, AccessToken);
            exit(AccessToken);
        end else
            Error(AccessTokenRefreshErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
    end;

    local procedure CheckHttpClientRequestsAllowed()
    var
        EnvironmentInfo: Codeunit "Environment Information";
        NavAppSetting: Record "NAV App Setting";
        HttpRequrestsAreNotAllowedErr: Label 'Http requests are blocked by default in sandbox environments. In order to proceed, you must allow HttpClient requests for NP Retail extension.';
    begin
        if EnvironmentInfo.IsSandbox() then
            if not (NavAppSetting.Get('992c2309-cca4-43cb-9e41-911f482ec088') and NavAppSetting."Allow HttpClient Requests") then
                Error(HttpRequrestsAreNotAllowedErr);
    end;
    #endregion

    var
        DEAuditSetup: Record "NPR DE Audit Setup";
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";
        ErrorDetailsTxt: Label 'Error details:\%1', Comment = '%1 - details of the error returned by the server';
}