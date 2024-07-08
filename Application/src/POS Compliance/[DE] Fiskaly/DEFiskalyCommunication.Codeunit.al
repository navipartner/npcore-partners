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
        POSUnitAux: Record "NPR DE POS Unit Aux. Info";
        DETSS: Record "NPR DE TSS";
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
        ConnectionParameters: Record "NPR DE Audit Setup";
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
        ResponseJson: JsonToken;
        TrxUploadErr: Label 'Error while trying to send a transaction to Fiskaly.\%1';
        Url: Text;
    begin
        ConnectionParameters.GetSetup(DeAuditAux);
        Url := StrSubstNo('/tss/%1/tx/%2?tx_revision=%3', Format(DeAuditAux."TSS ID", 0, 4), Format(DeAuditAux."Transaction ID", 0, 4), DeAuditAux."Latest Revision" + 1);
        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, 'PUT', Url) then
            Error(TrxUploadErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
        if not DEAuditMgt.DeAuxInfoInsertResponse(DeAuditAux, ResponseJson) then
            Error(GetLastErrorText());
    end;

    procedure GetTransaction(DeAuditAux: Record "NPR DE POS Audit Log Aux. Info"; TransactionRevision: Integer) ResponseJson: JsonToken
    var
        ConnectionParameters: Record "NPR DE Audit Setup";
        RequestBody: JsonObject;
        TxGetErr: Label 'Error while trying to get a transaction from Fiskaly.\%1';
        Url: Text;
    begin
        ConnectionParameters.GetSetup(DeAuditAux);
        Url := StrSubstNo('/tss/%1/tx/%2', Format(DeAuditAux."TSS ID", 0, 4), Format(DeAuditAux."Transaction ID", 0, 4));
        if TransactionRevision > 0 then
            Url := Url + StrSubstNo('?tx_revision=%1', TransactionRevision);
        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, 'GET', Url) then
            Error(TxGetErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
    end;
    #endregion

    #region manage Technical Security Systems (TSS)
    procedure CreateTSS(var DETSS: Record "NPR DE TSS"; ConnectionParameters: Record "NPR DE Audit Setup")
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

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, 'PUT', StrSubstNo('/tss/%1', Format(DETSS.SystemId, 0, 4))) then
            Error(TSSCreateErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        UpdateDeTssWithDataFromFiskaly(DETSS, ResponseJson, ConnectionParameters);

        if DETSS."Fiskaly TSS State".AsInteger() < DETSS."Fiskaly TSS State"::UNINITIALIZED.AsInteger() then
            UpdateTSS_State(DETSS, DETSS."Fiskaly TSS State"::UNINITIALIZED, true, ConnectionParameters);

        UpdateTSS_AdminPIN(DETSS, '', ConnectionParameters);

        if DETSS."Fiskaly TSS State".AsInteger() < DETSS."Fiskaly TSS State"::INITIALIZED.AsInteger() then begin
            TSS_AuthenticateAdmin(DETSS, ConnectionParameters);
            UpdateTSS_State(DETSS, DETSS."Fiskaly TSS State"::INITIALIZED, true, ConnectionParameters);
            TSS_LogoutAdmin(DETSS, ConnectionParameters);
        end;
    end;

    procedure UpdateTSS_AdminPIN(var DETSS: Record "NPR DE TSS"; NewAdminPIN: Text; ConnectionParameters: Record "NPR DE Audit Setup")
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

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, 'PATCH', StrSubstNo('/tss/%1/admin', Format(DETSS.SystemId, 0, 4))) then
            Error(TSSUpdateErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        DESecretMgt.SetSecretKey(DETSS.AdminPINSecretLbl(), NewAdminPIN);
        Commit();
    end;

    procedure TSS_AuthenticateAdmin(DETSS: Record "NPR DE TSS"; ConnectionParameters: Record "NPR DE Audit Setup")
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TSSAdminAuthErr: Label 'Error while trying to authenticate admin of a Technical Security System (TSS) at Fiskaly.\%1';
    begin
        DETSS.TestField(SystemId);
        DETSS.TestField("Fiskaly TSS Created at");

        RequestBody.Add('admin_pin', DESecretMgt.GetSecretKey(DETSS.AdminPINSecretLbl()));

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, 'POST', StrSubstNo('/tss/%1/admin/auth', Format(DETSS.SystemId, 0, 4))) then
            Error(TSSAdminAuthErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
    end;

    procedure TSS_LogoutAdmin(DETSS: Record "NPR DE TSS"; ConnectionParameters: Record "NPR DE Audit Setup")
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
    begin
        DETSS.TestField(SystemId);
        DETSS.TestField("Fiskaly TSS Created at");

        SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, 'POST', StrSubstNo('/tss/%1/admin/logout', Format(DETSS.SystemId, 0, 4)));
    end;

    procedure CheckAdminPINAssigned(DETSS: Record "NPR DE TSS")
    var
        AdminPinNotAssignedErr: Label 'Please assign admin PIN to Technical Security System (TSS) %1 first.', Comment = 'TSS Code';
    begin
        if not DESecretMgt.HasSecretKey(DETSS.AdminPINSecretLbl()) then
            Error(AdminPinNotAssignedErr, DETSS.Code);
    end;

    procedure UpdateTSS_State(var DETSS: Record "NPR DE TSS"; NewState: Enum "NPR DE TSS State"; UpdateBCInfo: Boolean; ConnectionParameters: Record "NPR DE Audit Setup")
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TSSUpdateErr: Label 'Error while trying to update a Technical Security System (TSS) at Fiskaly.\%1';
    begin
        DETSS.TestField(SystemId);
        DETSS.TestField("Fiskaly TSS Created at");

        RequestBody.Add('state', Enum::"NPR DE TSS State".Names().Get(Enum::"NPR DE TSS State".Ordinals().IndexOf(NewState.AsInteger())));

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, 'PATCH', StrSubstNo('/tss/%1', Format(DETSS.SystemId, 0, 4))) then
            Error(TSSUpdateErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        if UpdateBCInfo then
            UpdateDeTssWithDataFromFiskaly(DETSS, ResponseJson, ConnectionParameters);
    end;

    procedure GetTSSList()
    var
        ConnectionParameters: Record "NPR DE Audit Setup";
    begin
        if ConnectionParameters.FindSet() then
            repeat
                GetTSSList(ConnectionParameters);
            until ConnectionParameters.Next() = 0;
    end;

    procedure GetTSSList(ConnectionParameters: Record "NPR DE Audit Setup")
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TSSListAccessErr: Label 'Error while retrieving list of Technical Security Systems (TSS) from Fiskaly.\%1';
    begin
        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, 'GET', '/tss') then
            Error(TSSListAccessErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
        UpdateDeTssListFromFiskaly(ResponseJson, ConnectionParameters);
    end;

    local procedure UpdateDeTssListFromFiskaly(ResponseJson: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup")
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
            FindOrCreateNewDeTss(DETSS, JToken.AsValue().AsText(), true);
            UpdateDeTssWithDataFromFiskaly(DETSS, TssObject, ConnectionParameters);
        end;
    end;

    local procedure FindOrCreateNewDeTss(var DETSS: Record "NPR DE TSS"; TSS_Id: Guid; CreateIfDoesNotExist: Boolean)
    begin
        if DETSS.GetBySystemId(TSS_Id) then
            exit;
        if not CreateIfDoesNotExist then
            exit;
        DETSS.Code := '0001';
        while DETSS.Find() do
            DETSS.Code := IncStr(DETSS.Code);
        DETSS.Init();
        DETSS.SystemId := TSS_Id;
        DETSS.Insert(false, true);
    end;

    local procedure UpdateDeTssWithDataFromFiskaly(var DETSS: Record "NPR DE TSS"; ResponseJson: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup")
    var
        TypeHelper: Codeunit "Type Helper";
        JToken: JsonToken;
        State: Text;
        Description: Text[100];
    begin
        if DETSS."Connection Parameter Set Code" = '' then
            DETSS."Connection Parameter Set Code" := ConnectionParameters."Primary Key";

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
        ConnectionParameters: Record "NPR DE Audit Setup";
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
        ConnectionParameters.GetSetup(DETSS);
        if DETSS."Fiskaly TSS Created at" = 0DT then begin
            CreateTSS(DETSS, ConnectionParameters);
            Commit();
        end;
        CheckAdminPINAssigned(DETSS);
        TSS_AuthenticateAdmin(DETSS, ConnectionParameters);

        RequestBody.Add('serial_number', PosUnitAuxDE."Serial Number");
        RequestMetadata.Add('company', CompanyName);
        RequestMetadata.Add('pos_unit_no', PosUnitAuxDE."POS Unit No.");
        RequestMetadata.Add('tss_bc_code', DETSS."Code");
        RequestBody.Add('metadata', RequestMetadata);

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, 'PUT', StrSubstNo('/tss/%1/client/%2', Format(DETSS.SystemId, 0, 4), Format(PosUnitAuxDE.SystemId, 0, 4))) then
            Error(ClientCreateErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
        UpdateDeTssClientWithDataFromFiskaly(PosUnitAuxDE, ResponseJson);

        TSS_LogoutAdmin(DETSS, ConnectionParameters);
    end;

    procedure UpdateTSSClient_State(var PosUnitAuxDE: Record "NPR DE POS Unit Aux. Info"; NewState: Enum "NPR DE TSS Client State")
    var
        ConnectionParameters: Record "NPR DE Audit Setup";
        PosUnitAuxDE2: Record "NPR DE POS Unit Aux. Info";
        DETSS: Record "NPR DE TSS";
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        ClientUpdateErr: Label 'Error while trying to update a Fiskaly client.\%1';
    begin
        PosUnitAuxDE.TestField(SystemId);
        PosUnitAuxDE.TestField("Fiskaly Client Created at");
        PosUnitAuxDE.TestField("TSS Code");
        DETSS.Get(PosUnitAuxDE."TSS Code");
        CheckAdminPINAssigned(DETSS);
        ConnectionParameters.GetSetup(DETSS);
        TSS_AuthenticateAdmin(DETSS, ConnectionParameters);

        RequestBody.Add('state', Enum::"NPR DE TSS Client State".Names().Get(Enum::"NPR DE TSS Client State".Ordinals().IndexOf(NewState.AsInteger())));

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, 'PATCH', StrSubstNo('/tss/%1/client/%2', Format(DETSS.SystemId, 0, 4), Format(PosUnitAuxDE.SystemId, 0, 4))) then
            Error(ClientUpdateErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
        UpdateDeTssClientWithDataFromFiskaly(PosUnitAuxDE, ResponseJson);
        if PosUnitAuxDE.IsTemporary() then
            if PosUnitAuxDE2.Get(PosUnitAuxDE."POS Unit No.") then
                UpdateDeTssClientWithDataFromFiskaly(PosUnitAuxDE2, ResponseJson);

        TSS_LogoutAdmin(DETSS, ConnectionParameters);
    end;

    procedure ShowTSSClientListAtFiskaly(DETSS: Record "NPR DE TSS")
    var
        TempPosUnitAuxDE: Record "NPR DE POS Unit Aux. Info" temporary;
        NoClietsFoundErr: Label 'No registered clients found at Fiskaly for TSS %1.', Comment = '%1 - TSS Code';
    begin
        GetTSSClientList(DETSS, TempPosUnitAuxDE);
        if TempPosUnitAuxDE.IsEmpty() then
            Error(NoClietsFoundErr, DETSS.Code);
        Page.RunModal(Page::"NPR DE Fiskaly TSS Clients", TempPosUnitAuxDE);
    end;

    procedure GetTSSClientList(DETSS: Record "NPR DE TSS"; var PosUnitAuxDE: Record "NPR DE POS Unit Aux. Info")
    var
        ConnectionParameters: Record "NPR DE Audit Setup";
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TSSClientListAccessErr: Label 'Error while retrieving list of clients from Fiskaly.\%1';
    begin
        ConnectionParameters.GetSetup(DETSS);
        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, 'GET', StrSubstNo('/tss/%1/client', Format(DETSS.SystemId, 0, 4))) then
            Error(TSSClientListAccessErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
        UpdateDeTssClientFromFiskaly(PosUnitAuxDE, ResponseJson);
    end;

    local procedure UpdateDeTssClientFromFiskaly(var PosUnitAuxDE: Record "NPR DE POS Unit Aux. Info"; ResponseJson: JsonToken)
    var
        PosUnitAuxDE2: Record "NPR DE POS Unit Aux. Info";
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
            if PosUnitAuxDE2.GetBySystemId(JToken.AsValue().AsText()) then begin
                PosUnitAuxDE := PosUnitAuxDE2;
                if PosUnitAuxDE.IsTemporary() then
                    PosUnitAuxDE.Insert(false, true);
            end else begin
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
        FindOrCreateNewDeTss(DETSS, JToken.AsValue().AsText(), not PosUnitAuxDE.IsTemporary());
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
        if not PosUnitAuxDE.IsTemporary() then
            Commit();
    end;
    #endregion

    #region V2 (signDE) API request handling
    internal procedure SendRequest_signDE_V2(RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup"; RestMethod: Text; UrlFunction: Text): Boolean
    begin
        exit(SendRequest_signDE_V2(RequestBodyJsonIn, ResponseJsonOut, ConnectionParameters, RestMethod, UrlFunction, false));
    end;

    [TryFunction]
    local procedure SendRequest_signDE_V2(RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup"; RestMethod: Text; UrlFunction: Text; IsAuthenticationTokenRefreshRequest: Boolean)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        BearerToken: Label 'Bearer %1', Comment = '%1 - JWT Token Value', Locked = true;
        NotSuccessStatusCodeErr: Label '%1: %2\%3', Comment = '%1 - Http Status Code, %2 - Reason Code, %3 - Http Response Text', Locked = true;
        ResponseTxt: Text;
    begin
        Clear(ResponseJsonOut);
        CheckHttpClientRequestsAllowed();

        if UpperCase(RestMethod) <> 'GET' then
            AddRequestBodyAndHeadersToRequest(RequestBodyJsonIn, HttpWebRequest, Headers);

        ConnectionParameters.TestField("Api URL");
        HttpWebRequest.SetRequestUri(ConnectionParameters."Api URL" + UrlFunction);
        SetHttpHeaders(RestMethod, HttpWebRequest, Headers);

        if not IsAuthenticationTokenRefreshRequest then
            Headers.Add('Authorization', StrSubstNo(BearerToken, Get_signDE_V2_JwtToken(ConnectionParameters)));

        Client.Send(HttpWebRequest, HttpWebResponse);
        if not HttpWebResponse.Content.ReadAs(ResponseTxt) then
            ResponseTxt := '';

        if not HttpWebResponse.IsSuccessStatusCode then
            Error(NotSuccessStatusCodeErr, HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, ResponseTxt);

        ResponseJsonOut.ReadFrom(ResponseTxt);
    end;

    local procedure Get_signDE_V2_JwtToken(ConnectionParameters: Record "NPR DE Audit Setup"): Text
    var
        FiskalyJWT: Codeunit "NPR FiskalyJWT";
        RefreshTokenJson: JsonObject;
        JWTResponseJson: JsonToken;
        AccessTokenRefreshErr: Label 'Error while trying to get authentication token from the server.\%1', Comment = '%1 - Last Error Text';
        AccessToken: Text;
        RefreshToken: Text;
    begin
        if FiskalyJWT.GetToken(ConnectionParameters.SystemId, AccessToken, RefreshToken) then
            exit(AccessToken);

        if RefreshToken <> '' then
            RefreshTokenJson.Add('refresh_token', RefreshToken)
        else begin
            RefreshTokenJson.Add('api_key', DESecretMgt.GetSecretKey(ConnectionParameters.ApiKeyLbl()));
            RefreshTokenJson.Add('api_secret', DESecretMgt.GetSecretKey(ConnectionParameters.ApiSecretLbl()));
        end;
        ClearLastError();
        if Refresh_signDE_V2_JwtToken(RefreshTokenJson, JWTResponseJson, ConnectionParameters) then begin
            FiskalyJWT.SetJWT(ConnectionParameters.SystemId, JWTResponseJson, AccessToken);
            exit(AccessToken);
        end else
            Error(AccessTokenRefreshErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
    end;

    local procedure Refresh_signDE_V2_JwtToken(RefreshTokenJson: JsonObject; var JWTResponseJson: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup"): Boolean
    begin
        exit(SendRequest_signDE_V2(RefreshTokenJson, JWTResponseJson, ConnectionParameters, 'POST', '/auth', true));
    end;
    #endregion

    #region DSFinV-K API request handling
    internal procedure SendRequest_DSFinV_K(RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup"; RestMethod: Text; UrlFunction: Text): Boolean
    begin
        exit(SendRequest_DSFinV_K(RequestBodyJsonIn, ResponseJsonOut, ConnectionParameters, RestMethod, UrlFunction, false));
    end;

    [TryFunction]
    local procedure SendRequest_DSFinV_K(RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup"; RestMethod: Text; UrlFunction: Text; IsAuthenticationTokenRefreshRequest: Boolean)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        BearerToken: Label 'Bearer %1', Comment = '%1 - JWT Token Value', Locked = true;
        NotSuccessStatusCodeErr: Label '%1: %2\%3', Comment = '%1 - Http Status Code, %2 - Reason Code, %3 - Http Response Text', Locked = true;
        ResponseTxt: Text;
    begin
        Clear(ResponseJsonOut);
        CheckHttpClientRequestsAllowed();

        if UpperCase(RestMethod) <> 'GET' then
            AddRequestBodyAndHeadersToRequest(RequestBodyJsonIn, HttpWebRequest, Headers);

        ConnectionParameters.TestField("DSFINVK Api URL");
        HttpWebRequest.SetRequestUri(ConnectionParameters."DSFINVK Api URL" + UrlFunction);
        SetHttpHeaders(RestMethod, HttpWebRequest, Headers);

        if not IsAuthenticationTokenRefreshRequest then
            Headers.Add('Authorization', StrSubstNo(BearerToken, Get_DSFinV_K_JwtToken(ConnectionParameters)));

        Client.Send(HttpWebRequest, HttpWebResponse);
        if not HttpWebResponse.Content.ReadAs(ResponseTxt) then
            ResponseTxt := '';

        if not HttpWebResponse.IsSuccessStatusCode then
            Error(NotSuccessStatusCodeErr, HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, ResponseTxt);

        ResponseJsonOut.ReadFrom(ResponseTxt);
    end;

    local procedure Get_DSFinV_K_JwtToken(ConnectionParameters: Record "NPR DE Audit Setup"): Text
    var
        FiskalyJWT: Codeunit "NPR FiskalyJWT";
        RefreshTokenJson: JsonObject;
        JWTResponseJson: JsonToken;
        AccessTokenRefreshErr: Label 'Error while trying to get authentication token from the server.\%1', Comment = '%1 - Last Error Text';
        AccessToken: Text;
        RefreshToken: Text;
    begin
        if FiskalyJWT.GetToken(ConnectionParameters.SystemId, AccessToken, RefreshToken) then
            exit(AccessToken);

        if RefreshToken <> '' then
            RefreshTokenJson.Add('refresh_token', RefreshToken)
        else begin
            RefreshTokenJson.Add('api_key', DESecretMgt.GetSecretKey(ConnectionParameters.ApiKeyLbl()));
            RefreshTokenJson.Add('api_secret', DESecretMgt.GetSecretKey(ConnectionParameters.ApiSecretLbl()));
        end;
        ClearLastError();
        if Refresh_DSFinV_K_JwtToken(RefreshTokenJson, JWTResponseJson, ConnectionParameters) then begin
            FiskalyJWT.SetJWT(ConnectionParameters.SystemId, JWTResponseJson, AccessToken);
            exit(AccessToken);
        end else
            Error(AccessTokenRefreshErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
    end;

    local procedure Refresh_DSFinV_K_JwtToken(RefreshTokenJson: JsonObject; var JWTResponseJson: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup"): Boolean
    begin
        exit(SendRequest_DSFinV_K(RefreshTokenJson, JWTResponseJson, ConnectionParameters, 'POST', '/auth', true));
    end;
    #endregion

    #region API Request Handling
    local procedure CheckHttpClientRequestsAllowed()
    var
        NavAppSetting: Record "NAV App Setting";
        EnvironmentInfo: Codeunit "Environment Information";
        HttpRequrestsAreNotAllowedErr: Label 'Http requests are blocked by default in sandbox environments. In order to proceed, you must allow HttpClient requests for NP Retail extension.';
    begin
        if EnvironmentInfo.IsSandbox() then
            if not (NavAppSetting.Get('992c2309-cca4-43cb-9e41-911f482ec088') and NavAppSetting."Allow HttpClient Requests") then
                Error(HttpRequrestsAreNotAllowedErr);
    end;

    local procedure AddRequestBodyAndHeadersToRequest(var RequestBodyJsonIn: JsonObject; var HttpWebRequest: HttpRequestMessage; var Headers: HttpHeaders)
    var
        Content: HttpContent;
        RequestBodyTxt: Text;
    begin
        RequestBodyJsonIn.WriteTo(RequestBodyTxt);
        Content.WriteFrom(RequestBodyTxt);

        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
        HttpWebRequest.Content(Content);
    end;

    local procedure SetHttpHeaders(RestMethod: Text; var HttpWebRequest: HttpRequestMessage; var Headers: HttpHeaders)
    begin
        HttpWebRequest.Method := RestMethod;
        HttpWebRequest.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');
        Headers.Add('User-Agent', 'Dynamics 365');
    end;
    #endregion

    var
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";
        ErrorDetailsTxt: Label 'Error details:\%1', Comment = '%1 - details of the error returned by the server';
}