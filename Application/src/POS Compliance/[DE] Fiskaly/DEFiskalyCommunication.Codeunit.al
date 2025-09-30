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
        DETSSClient: Record "NPR DE POS Unit Aux. Info";
        DETSS: Record "NPR DE TSS";
    begin
        DeAuditAux.TestField("Transaction ID");
        DeAuditAux.TestField("Client ID");
        DETSSClient.GetBySystemId(DeAuditAux."Client ID");
        DETSSClient.TestField("Fiskaly Client Created at");

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
        IsHandled: Boolean;
        ResponseJson: JsonToken;
        TrxUploadErr: Label 'Error while trying to send a transaction to Fiskaly.\%1';
        Url: Text;
    begin
        ConnectionParameters.GetSetup(DeAuditAux);
        Url := StrSubstNo('/tss/%1/tx/%2?tx_revision=%3', Format(DeAuditAux."TSS ID", 0, 4), Format(DeAuditAux."Transaction ID", 0, 4), DeAuditAux."Latest Revision" + 1);

        OnBeforeSendHttpRequestForSendTransaction(DeAuditAux, RequestBody, ResponseJson, ConnectionParameters, IsHandled);
        if IsHandled then
            exit;

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::PUT, Url) then
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
        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::GET, Url) then
            Error(TxGetErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
    end;
    #endregion

    #region manage Technical Security Systems (TSS)
    procedure CreateTSS(var DETSS: Record "NPR DE TSS"; ConnectionParameters: Record "NPR DE Audit Setup")
    var
        IsHandled: Boolean;
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

        OnBeforeSendHttpRequestForCreateTSS(DETSS, RequestBody, ResponseJson, ConnectionParameters, IsHandled);
        if IsHandled then
            exit;

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::PUT, StrSubstNo('/tss/%1', Format(DETSS.SystemId, 0, 4))) then
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
        IsHandled: Boolean;
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

        OnBeforeSendHttpRequestForUpdateAdminPin(DETSS, DESecretMgt, NewAdminPIN, IsHandled);
        if IsHandled then
            exit;

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::PATCH, StrSubstNo('/tss/%1/admin', Format(DETSS.SystemId, 0, 4))) then
            Error(TSSUpdateErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        DESecretMgt.SetSecretKey(DETSS.AdminPINSecretLbl(), NewAdminPIN);
        Commit();
    end;

    procedure TSS_AuthenticateAdmin(DETSS: Record "NPR DE TSS"; ConnectionParameters: Record "NPR DE Audit Setup")
    var
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TSSAdminAuthErr: Label 'Error while trying to authenticate admin of a Technical Security System (TSS) at Fiskaly.\%1';
    begin
        DETSS.TestField(SystemId);
        DETSS.TestField("Fiskaly TSS Created at");

        RequestBody.Add('admin_pin', DESecretMgt.GetSecretKey(DETSS.AdminPINSecretLbl()));

        OnBeforeSendHttpRequestForAuthenticateAdmin(IsHandled);
        if IsHandled then
            exit;

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::POST, StrSubstNo('/tss/%1/admin/auth', Format(DETSS.SystemId, 0, 4))) then
            Error(TSSAdminAuthErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
    end;

    procedure TSS_LogoutAdmin(DETSS: Record "NPR DE TSS"; ConnectionParameters: Record "NPR DE Audit Setup")
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
    begin
        DETSS.TestField(SystemId);
        DETSS.TestField("Fiskaly TSS Created at");

        SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::POST, StrSubstNo('/tss/%1/admin/logout', Format(DETSS.SystemId, 0, 4)));
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
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TSSUpdateErr: Label 'Error while trying to update a Technical Security System (TSS) at Fiskaly.\%1';
    begin
        DETSS.TestField(SystemId);
        DETSS.TestField("Fiskaly TSS Created at");

        RequestBody.Add('state', Enum::"NPR DE TSS State".Names().Get(Enum::"NPR DE TSS State".Ordinals().IndexOf(NewState.AsInteger())));

        OnBeforeSendHttpRequestForUpdateTSS_State(DETSS, NewState, RequestBody, ResponseJson, UpdateBCInfo, ConnectionParameters, IsHandled);
        if IsHandled then
            exit;

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::PATCH, StrSubstNo('/tss/%1', Format(DETSS.SystemId, 0, 4))) then
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
        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::GET, '/tss') then
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

    internal procedure UpdateDeTssWithDataFromFiskaly(var DETSS: Record "NPR DE TSS"; ResponseJson: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup")
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
    procedure CreateClient(var DETSSClient: Record "NPR DE POS Unit Aux. Info")
    var
        ConnectionParameters: Record "NPR DE Audit Setup";
        DETSS: Record "NPR DE TSS";
        ConfirmManagement: Codeunit "Confirm Management";
        IsHandled: Boolean;
        RequestBody: JsonObject;
        RequestMetadata: JsonObject;
        ResponseJson: JsonToken;
        ClientCreateErr: Label 'Error while trying to create a new Client at Fiskaly.\%1';
        TSSNotSyncedQst: Label 'It looks that assigned TSS hasn''t been created at Fiskaly yet. If you continue, it will be created automatically.\Are you sure you want to continue?';
    begin
        DETSSClient.TestField(SystemId);
        DETSSClient.TestField("Fiskaly Client Created at", 0DT);
        DETSSClient.TestField("Serial Number");
        DETSSClient.TestField("TSS Code");
        DETSS.Get(DETSSClient."TSS Code");
        ConnectionParameters.GetSetup(DETSS);
        if DETSS."Fiskaly TSS Created at" = 0DT then begin
            if not ConfirmManagement.GetResponse(TSSNotSyncedQst, false) then
                exit;
            CreateTSS(DETSS, ConnectionParameters);
            Commit();
        end;

        CheckAdminPINAssigned(DETSS);
        TSS_AuthenticateAdmin(DETSS, ConnectionParameters);

        RequestBody.Add('serial_number', DETSSClient."Serial Number");
        RequestMetadata.Add('company', CompanyName);
        RequestMetadata.Add('pos_unit_no', DETSSClient."POS Unit No.");
        RequestMetadata.Add('tss_bc_code', DETSS."Code");
        RequestBody.Add('metadata', RequestMetadata);

        OnBeforeSendHttpRequestForCreateClient(DETSSClient, DETSS, RequestBody, ResponseJson, ConnectionParameters, IsHandled);
        if IsHandled then
            exit;

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::PUT, StrSubstNo('/tss/%1/client/%2', Format(DETSS.SystemId, 0, 4), Format(DETSSClient.SystemId, 0, 4))) then
            Error(ClientCreateErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
        UpdateDeTssClientWithDataFromFiskaly(DETSSClient, ResponseJson);

        TSS_LogoutAdmin(DETSS, ConnectionParameters);
    end;

    procedure UpdateTSSClient_State(var DETSSClient: Record "NPR DE POS Unit Aux. Info"; NewState: Enum "NPR DE TSS Client State")
    var
        ConnectionParameters: Record "NPR DE Audit Setup";
        DETSSClient2: Record "NPR DE POS Unit Aux. Info";
        DETSS: Record "NPR DE TSS";
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        ClientUpdateErr: Label 'Error while trying to update a Fiskaly client.\%1';
    begin
        DETSSClient.TestField(SystemId);
        DETSSClient.TestField("Fiskaly Client Created at");
        DETSSClient.TestField("TSS Code");
        DETSS.Get(DETSSClient."TSS Code");
        CheckAdminPINAssigned(DETSS);
        ConnectionParameters.GetSetup(DETSS);
        TSS_AuthenticateAdmin(DETSS, ConnectionParameters);

        RequestBody.Add('state', Enum::"NPR DE TSS Client State".Names().Get(Enum::"NPR DE TSS Client State".Ordinals().IndexOf(NewState.AsInteger())));

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::PATCH, StrSubstNo('/tss/%1/client/%2', Format(DETSS.SystemId, 0, 4), Format(DETSSClient.SystemId, 0, 4))) then
            Error(ClientUpdateErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
        UpdateDeTssClientWithDataFromFiskaly(DETSSClient, ResponseJson);
        if DETSSClient.IsTemporary() then
            if DETSSClient2.Get(DETSSClient."POS Unit No.") then
                UpdateDeTssClientWithDataFromFiskaly(DETSSClient2, ResponseJson);

        TSS_LogoutAdmin(DETSS, ConnectionParameters);
    end;

    procedure ShowTSSClientListAtFiskaly(DETSS: Record "NPR DE TSS")
    var
        TempDETSSClient: Record "NPR DE POS Unit Aux. Info" temporary;
        NoClientsFoundErr: Label 'No registered clients found at Fiskaly for TSS %1.', Comment = '%1 - TSS Code';
    begin
        GetTSSClientList(DETSS, TempDETSSClient);
        if TempDETSSClient.IsEmpty() then
            Error(NoClientsFoundErr, DETSS.Code);
        Page.RunModal(Page::"NPR DE POS Unit Aux. Info List", TempDETSSClient);
    end;

    procedure GetTSSClientList(DETSS: Record "NPR DE TSS"; var DETSSClient: Record "NPR DE POS Unit Aux. Info")
    var
        ConnectionParameters: Record "NPR DE Audit Setup";
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TSSClientListAccessErr: Label 'Error while retrieving list of clients from Fiskaly.\%1';
    begin
        ConnectionParameters.GetSetup(DETSS);

        OnBeforeSendHttpRequestForGetTSSClientList(ResponseJson, DETSS, DETSSClient, IsHandled);
        if IsHandled then
            exit;

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::GET, StrSubstNo('/tss/%1/client', Format(DETSS.SystemId, 0, 4))) then
            Error(TSSClientListAccessErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
        UpdateDeTssClientFromFiskaly(DETSSClient, ResponseJson);
    end;

    internal procedure UpdateDeTssClientFromFiskaly(var DETSSClient: Record "NPR DE POS Unit Aux. Info"; ResponseJson: JsonToken)
    var
        DETSSClient2: Record "NPR DE POS Unit Aux. Info";
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
            if DETSSClient2.GetBySystemId(JToken.AsValue().AsText()) then begin
                DETSSClient := DETSSClient2;
                if DETSSClient.IsTemporary() then
                    DETSSClient.Insert(false, true);
            end else begin
                DETSSClient."POS Unit No." := '_UKN000001';
                while DETSSClient.Find() do
                    DETSSClient."POS Unit No." := IncStr(DETSSClient."POS Unit No.");
                DETSSClient.SystemId := JToken.AsValue().AsText();
                DETSSClient.Insert(false, true);
            end;
            UpdateDeTssClientWithDataFromFiskaly(DETSSClient, TssClient);
        end;
    end;

    internal procedure UpdateDeTssClientWithDataFromFiskaly(var DETSSClient: Record "NPR DE POS Unit Aux. Info"; ResponseJson: JsonToken)
    var
        DETSS: Record "NPR DE TSS";
        TypeHelper: Codeunit "Type Helper";
        JToken: JsonToken;
        State: Text;
    begin
        ResponseJson.SelectToken('time_creation', JToken);
        DETSSClient."Fiskaly Client Created at" := TypeHelper.EvaluateUnixTimestamp(JToken.AsValue().AsBigInteger());

        ResponseJson.SelectToken('tss_id', JToken);
        FindOrCreateNewDeTss(DETSS, JToken.AsValue().AsText(), not DETSSClient.IsTemporary());
        DETSSClient."TSS Code" := DETSS."Code";

        ResponseJson.SelectToken('serial_number', JToken);
        DETSSClient."Serial Number" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(DETSSClient."Serial Number"));

        ResponseJson.SelectToken('state', JToken);
        State := JToken.AsValue().AsText();
        if not Enum::"NPR DE TSS Client State".Names().Contains(State) then
            DETSSClient."Fiskaly Client State" := DETSSClient."Fiskaly Client State"::Unknown
        else
            DETSSClient."Fiskaly Client State" :=
                Enum::"NPR DE TSS Client State".FromInteger(Enum::"NPR DE TSS Client State".Ordinals().Get(Enum::"NPR DE TSS Client State".Names().IndexOf(State)));
        DETSSClient.Modify();
        if not DETSSClient.IsTemporary() then
            Commit();
    end;
    #endregion

    #region DSFINVK Cash Register management
    internal procedure UpsertCashRegister(var DETSSClient: Record "NPR DE POS Unit Aux. Info")
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DETSS: Record "NPR DE TSS";
        RequestJson: JsonObject;
        ResponseJson: JsonToken;
    begin
        CheckFieldValuesForUpsertCashRegister(DETSSClient);
        DETSS.Get(DETSSClient."TSS Code");
        DETSS.TestField("Fiskaly TSS Created at");
        DETSS.TestField(SystemId);
        ConnectionParameterSet.GetSetup(DETSS);

        RequestJson := CreateJSONBodyForUpsertCashRegister(DETSS, DETSSClient);

        if not SendRequest_DSFinV_K(RequestJson, ResponseJson, ConnectionParameterSet, Enum::"Http Request Type"::PUT, StrSubstNo('/cash_registers/%1', Format(DETSSClient.SystemId, 0, 4))) then
            Error(GetLastErrorText());

        DETSSClient."Cash Register Created" := true;
        DETSSClient.Modify(true);
    end;

    local procedure CheckFieldValuesForUpsertCashRegister(var DETSSClient: Record "NPR DE POS Unit Aux. Info")
    begin
        DETSSClient.TestField(SystemId);
        DETSSClient.TestField("TSS Code");
        DETSSClient.TestField("Cash Register Brand");
        DETSSClient.TestField("Cash Register Model");
    end;

    local procedure CreateJSONBodyForUpsertCashRegister(DETSS: Record "NPR DE TSS"; DETSSClient: Record "NPR DE POS Unit Aux. Info") RequestJson: JsonObject
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CashRegisterTypeJson: JsonObject;
        SoftwareJson: JsonObject;
    begin
        GeneralLedgerSetup.Get();
        CashRegisterTypeJson.Add('type', 'MASTER');
        CashRegisterTypeJson.Add('tss_id', Format(DETSS.SystemId, 0, 4));
        SoftwareJson.Add('brand', 'NP Retail');
        RequestJson.Add('cash_register_type', CashRegisterTypeJson);
        RequestJson.Add('software', SoftwareJson);
        RequestJson.Add('brand', DETSSClient."Cash Register Brand");
        RequestJson.Add('model', DETSSClient."Cash Register Model");
        RequestJson.Add('base_currency_code', GeneralLedgerSetup."LCY Code");
    end;
    #endregion

    #region Taxpayer management
    internal procedure UpsertTaxpayer(var ConnectionParameterSet: Record "NPR DE Audit Setup")
    var
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        UpsertTaxpayerErr: Label 'Error while trying to create / update the Taxpayer at Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        CheckFieldValuesForUpsertTaxpayer(ConnectionParameterSet);

        RequestBody.ReadFrom(CreateJSONBodyForUpsertTaxpayer(ConnectionParameterSet));

        OnBeforeSendHttpRequestForUpsertTaxpayer(ConnectionParameterSet, RequestBody, ResponseJson, IsHandled);
        if IsHandled then
            exit;

        UrlFunction := '/taxpayer';
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::PUT, UrlFunction) then
            Error(UpsertTaxpayerErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        ResponseJson.ReadFrom(ResponseText);
        PopulateConnectionParameterSetForTaxpayer(ConnectionParameterSet, ResponseJson);
    end;

    internal procedure RetrieveTaxpayer(var ConnectionParameterSet: Record "NPR DE Audit Setup")
    var
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        RetrieveTaxpayerErr: Label 'Error while trying to retrieve the Taxpayer from Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        OnBeforeSendHttpRequestForRetrieveTaxpayer(ConnectionParameterSet, ResponseJson, IsHandled);
        if IsHandled then
            exit;

        UrlFunction := '/taxpayer';
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(RetrieveTaxpayerErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        ResponseJson.ReadFrom(ResponseText);
        PopulateConnectionParameterSetForTaxpayer(ConnectionParameterSet, ResponseJson);
    end;

    local procedure CheckFieldValuesForUpsertTaxpayer(ConnectionParameterSet: Record "NPR DE Audit Setup")
    begin
        ConnectionParameterSet.TestField(SystemId);
        ConnectionParameterSet.TestField("Primary Key");
        ConnectionParameterSet.TestField("Taxpayer Registration No.");
        ConnectionParameterSet.TestField("Taxpayer Tax Office Number");
        ConnectionParameterSet.CheckIsPersonTypePopulated();
        ConnectionParameterSet.TestField("Taxpayer Street");
        ConnectionParameterSet.TestField("Taxpayer House Number");
        ConnectionParameterSet.TestField("Taxpayer Town");
        ConnectionParameterSet.TestField("Taxpayer ZIP Code");
        if ConnectionParameterSet."Taxpayer International Address" then
            ConnectionParameterSet.TestField("Taxpayer Country/Region Code");

        case ConnectionParameterSet."Taxpayer Person Type" of
            ConnectionParameterSet."Taxpayer Person Type"::legal:
                begin
                    ConnectionParameterSet.TestField("Taxpayer Company Name");
                    ConnectionParameterSet.CheckIsLegalFormPopulated();
                end;
            ConnectionParameterSet."Taxpayer Person Type"::natural:
                begin
                    ConnectionParameterSet.TestField("Taxpayer Birthdate");
                    ConnectionParameterSet.TestField("Taxpayer First Name");
                    ConnectionParameterSet.TestField("Taxpayer Last Name");
                    ConnectionParameterSet.TestField("Taxpayer Identification No.");
                    ConnectionParameterSet.CheckIsSalutationPopulated();
                end;
        end;
    end;

    local procedure CreateJSONBodyForUpsertTaxpayer(ConnectionParameterSet: Record "NPR DE Audit Setup") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
        BirthdateFormatted: Text;
    begin
        JsonTextWriter.WriteStartObject('');

        JsonTextWriter.WriteStringProperty('tax_number', ConnectionParameterSet."Taxpayer Registration No.");
        JsonTextWriter.WriteStringProperty('tax_office_number', ConnectionParameterSet."Taxpayer Tax Office Number");

        JsonTextWriter.WriteStartObject('general_information');
        JsonTextWriter.WriteStringProperty('person', Enum::"NPR DE Taxpayer Person Type".Names().Get(Enum::"NPR DE Taxpayer Person Type".Ordinals().IndexOf(ConnectionParameterSet."Taxpayer Person Type".AsInteger())));

        JsonTextWriter.WriteStartObject('information');

        case ConnectionParameterSet."Taxpayer Person Type" of
            ConnectionParameterSet."Taxpayer Person Type"::legal:
                begin
                    JsonTextWriter.WriteStringProperty('company_name', ConnectionParameterSet."Taxpayer Company Name");
                    JsonTextWriter.WriteStringProperty('legal_form', Enum::"NPR DE Taxpayer Legal Form".Names().Get(Enum::"NPR DE Taxpayer Legal Form".Ordinals().IndexOf(ConnectionParameterSet."Taxpayer Legal Form".AsInteger())));
                end;
            ConnectionParameterSet."Taxpayer Person Type"::natural:
                begin
                    BirthdateFormatted := Format(ConnectionParameterSet."Taxpayer Birthdate", 0, '<Day,2>.<Month,2>.<Year4>');
                    JsonTextWriter.WriteStringProperty('birthdate', BirthdateFormatted);
                    JsonTextWriter.WriteStringProperty('first_name', ConnectionParameterSet."Taxpayer First Name");
                    JsonTextWriter.WriteStringProperty('identification_number', ConnectionParameterSet."Taxpayer Identification No.");
                    JsonTextWriter.WriteStringProperty('last_name', ConnectionParameterSet."Taxpayer Last Name");
                    if ConnectionParameterSet."Taxpayer Name Prefix" <> '' then
                        JsonTextWriter.WriteStringProperty('prefix', ConnectionParameterSet."Taxpayer Name Prefix");

                    JsonTextWriter.WriteStringProperty('salutation', Enum::"NPR DE Taxpayer Salutation".Names().Get(Enum::"NPR DE Taxpayer Salutation".Ordinals().IndexOf(ConnectionParameterSet."Taxpayer Salutation".AsInteger())));
                    if ConnectionParameterSet."Taxpayer Name Suffix" <> '' then
                        JsonTextWriter.WriteStringProperty('suffix', ConnectionParameterSet."Taxpayer Name Suffix");

                    if ConnectionParameterSet."Taxpayer Title" <> '' then
                        JsonTextWriter.WriteStringProperty('title', ConnectionParameterSet."Taxpayer Title");
                end;
        end;

        if ConnectionParameterSet."Taxpayer Web Address" <> '' then
            JsonTextWriter.WriteStringProperty('web_address', ConnectionParameterSet."Taxpayer Web Address");
        JsonTextWriter.WriteEndObject(); // information

        JsonTextWriter.WriteStartObject('address');
        JsonTextWriter.WriteStartObject('post_address');
        JsonTextWriter.WriteStringProperty('street', ConnectionParameterSet."Taxpayer Street");
        JsonTextWriter.WriteStringProperty('house_number', ConnectionParameterSet."Taxpayer House Number");
        JsonTextWriter.WriteStringProperty('town', ConnectionParameterSet."Taxpayer Town");
        JsonTextWriter.WriteStringProperty('zip_code', ConnectionParameterSet."Taxpayer ZIP Code");
        if ConnectionParameterSet."Taxpayer House Number Suffix" <> '' then
            JsonTextWriter.WriteStringProperty('house_number_suffix', ConnectionParameterSet."Taxpayer House Number Suffix");

        if ConnectionParameterSet."Taxpayer Additional Address" <> '' then
            JsonTextWriter.WriteStringProperty('address_additional', ConnectionParameterSet."Taxpayer Additional Address");

        if ConnectionParameterSet."Taxpayer International Address" then
            JsonTextWriter.WriteStringProperty('country', ConnectionParameterSet."Taxpayer Country/Region Code");

        JsonTextWriter.WriteEndObject(); // post_address
        JsonTextWriter.WriteEndObject(); // address
        JsonTextWriter.WriteEndObject(); // general_information

        AddMetadataForUpsertTaxpayer(ConnectionParameterSet, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure AddMetadataForUpsertTaxpayer(ConnectionParameterSet: Record "NPR DE Audit Setup"; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartObject('metadata');
        JsonTextWriter.WriteStringProperty('bc_company_name', CompanyName());
        JsonTextWriter.WriteStringProperty('bc_code', ConnectionParameterSet."Primary Key");
        JsonTextWriter.WriteStringProperty('bc_description', ConnectionParameterSet.Description);
        JsonTextWriter.WriteEndObject();
    end;

    internal procedure PopulateConnectionParameterSetForTaxpayer(var ConnectionParameterSet: Record "NPR DE Audit Setup"; ResponseJson: JsonToken)
    var
        PropertyValue: JsonToken;
    begin
        if ResponseJson.SelectToken('vat_number', PropertyValue) then
            ConnectionParameterSet."Taxpayer VAT Registration No." := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer VAT Registration No."));

        ResponseJson.SelectToken('tax_number', PropertyValue);
        ConnectionParameterSet."Taxpayer Registration No." := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Registration No."));

        ResponseJson.SelectToken('tax_office_number', PropertyValue);
        ConnectionParameterSet."Taxpayer Tax Office Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Tax Office Number"));

        ResponseJson.SelectToken('$.general_information.person', PropertyValue);
        ConnectionParameterSet."Taxpayer Person Type" := GetTaxpayerPersonType(PropertyValue.AsValue().AsText());

        case ConnectionParameterSet."Taxpayer Person Type" of
            ConnectionParameterSet."Taxpayer Person Type"::legal:
                begin
                    ResponseJson.SelectToken('$.general_information.information.company_name', PropertyValue);
                    ConnectionParameterSet."Taxpayer Company Name" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Company Name"));

                    ResponseJson.SelectToken('$.general_information.information.legal_form', PropertyValue);
                    ConnectionParameterSet."Taxpayer Legal Form" := GetTaxpayerLegalForm(PropertyValue.AsValue().AsText());
                end;
            ConnectionParameterSet."Taxpayer Person Type"::natural:
                begin
                    ResponseJson.SelectToken('$.general_information.information.first_name', PropertyValue);
                    ConnectionParameterSet."Taxpayer First Name" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer First Name"));

                    ResponseJson.SelectToken('$.general_information.information.last_name', PropertyValue);
                    ConnectionParameterSet."Taxpayer Last Name" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Last Name"));

                    ResponseJson.SelectToken('$.general_information.information.birthdate', PropertyValue);
                    ConnectionParameterSet."Taxpayer Birthdate" := ConvertToDate(PropertyValue.AsValue().AsText());

                    ResponseJson.SelectToken('$.general_information.information.identification_number', PropertyValue);
                    ConnectionParameterSet."Taxpayer Identification No." := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Identification No."));

                    ResponseJson.SelectToken('$.general_information.information.prefix', PropertyValue);
                    ConnectionParameterSet."Taxpayer Name Prefix" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Name Prefix"));

                    ResponseJson.SelectToken('$.general_information.information.salutation', PropertyValue);
                    ConnectionParameterSet."Taxpayer Salutation" := GetTaxpayerSalutation(PropertyValue.AsValue().AsText());

                    ResponseJson.SelectToken('$.general_information.information.suffix', PropertyValue);
                    ConnectionParameterSet."Taxpayer Name Suffix" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Name Suffix"));

                    ResponseJson.SelectToken('$.general_information.information.title', PropertyValue);
                    ConnectionParameterSet."Taxpayer Title" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Title"));
                end;
        end;

        Clear(ConnectionParameterSet."Taxpayer Web Address");
        if ResponseJson.SelectToken('$.general_information.information.web_address', PropertyValue) then
            ConnectionParameterSet."Taxpayer Web Address" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Web Address"));

        ResponseJson.SelectToken('$.general_information.address.post_address.street', PropertyValue);
        ConnectionParameterSet."Taxpayer Street" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Street"));

        ResponseJson.SelectToken('$.general_information.address.post_address.house_number', PropertyValue);
        ConnectionParameterSet."Taxpayer House Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer House Number"));

        Clear(ConnectionParameterSet."Taxpayer House Number Suffix");
        if ResponseJson.SelectToken('$.general_information.address.post_address.house_number_suffix', PropertyValue) then
            ConnectionParameterSet."Taxpayer House Number Suffix" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer House Number Suffix"));

        ResponseJson.SelectToken('$.general_information.address.post_address.town', PropertyValue);
        ConnectionParameterSet."Taxpayer Town" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Town"));

        ResponseJson.SelectToken('$.general_information.address.post_address.zip_code', PropertyValue);
        ConnectionParameterSet."Taxpayer ZIP Code" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer ZIP Code"));

        Clear(ConnectionParameterSet."Taxpayer Additional Address");
        if ResponseJson.SelectToken('$.general_information.address.post_address.address_additional', PropertyValue) then
            ConnectionParameterSet."Taxpayer Additional Address" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Additional Address"));

        Clear(ConnectionParameterSet."Taxpayer International Address");
        Clear(ConnectionParameterSet."Taxpayer Country/Region Code");
        if ResponseJson.SelectToken('$.general_information.address.post_address.country', PropertyValue) then begin
            ConnectionParameterSet."Taxpayer International Address" := true;
            ConnectionParameterSet."Taxpayer Country/Region Code" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ConnectionParameterSet."Taxpayer Country/Region Code"));
        end;

        ConnectionParameterSet."Taxpayer Created" := true;
        ConnectionParameterSet.Modify(true);
    end;

    local procedure GetTaxpayerPersonType(PersonType: Text): Enum "NPR DE Taxpayer Person Type"
    begin
        if Enum::"NPR DE Taxpayer Person Type".Names().Contains(PersonType) then
            exit(Enum::"NPR DE Taxpayer Person Type".FromInteger(Enum::"NPR DE Taxpayer Person Type".Ordinals().Get(Enum::"NPR DE Taxpayer Person Type".Names().IndexOf(PersonType))));

        exit(Enum::"NPR DE Taxpayer Person Type"::" ");
    end;

    local procedure GetTaxpayerLegalForm(LegalForm: Text): Enum "NPR DE Taxpayer Legal Form"
    begin
        if Enum::"NPR DE Taxpayer Legal Form".Names().Contains(LegalForm) then
            exit(Enum::"NPR DE Taxpayer Legal Form".FromInteger(Enum::"NPR DE Taxpayer Legal Form".Ordinals().Get(Enum::"NPR DE Taxpayer Legal Form".Names().IndexOf(LegalForm))));

        exit(Enum::"NPR DE Taxpayer Legal Form"::" ");
    end;

    local procedure GetTaxpayerSalutation(Salutation: Text): Enum "NPR DE Taxpayer Salutation"
    begin
        if Enum::"NPR DE Taxpayer Salutation".Names().Contains(Salutation) then
            exit(Enum::"NPR DE Taxpayer Salutation".FromInteger(Enum::"NPR DE Taxpayer Salutation".Ordinals().Get(Enum::"NPR DE Taxpayer Salutation".Names().IndexOf(Salutation))));

        exit(Enum::"NPR DE Taxpayer Salutation"::" ");
    end;
    #endregion

    #region Establishment management
    internal procedure UpsertEstablishment(var DEEstablishment: Record "NPR DE Establishment"; Decommission: Boolean)
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        UpsertEstablishmentErr: Label 'Error while trying to create / update the Establishment at Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        CheckFieldValuesForUpsertEstablishment(DEEstablishment);
        ConnectionParameterSet.GetWithCheck(DEEstablishment."Connection Parameter Set Code");

        RequestBody.ReadFrom(CreateJSONBodyForUpsertEstablishment(DEEstablishment, Decommission));

        OnBeforeSendHttpRequestForUpsertEstablishment(DEEstablishment, RequestBody, ResponseJson, IsHandled);
        if IsHandled then
            exit;

        UrlFunction := StrSubstNo('/establishment/%1', Format(DEEstablishment.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::PUT, UrlFunction) then
            Error(UpsertEstablishmentErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        ResponseJson.ReadFrom(ResponseText);
        PopulateEstablishment(DEEstablishment, ResponseJson);
    end;

    internal procedure DecommissionEstablishment(var DEEstablishment: Record "NPR DE Establishment")
    var
        DETSSClient: Record "NPR DE POS Unit Aux. Info";
        ConfirmManagement: Codeunit "Confirm Management";
        CannotDecomissionDueToRelatedRecordErr: Label 'You cannot decommission this %1, since there is at least one related %2 has to be decommissioned first.', Comment = '%1 - DE Establishment table caption, %2 - DE POS Unit Aux. Info table caption';
        DecommissionConfirmQst: Label 'Are you sure that you want to decommission this %1, since this it is irreversible?', Comment = '%1 - DE Establishment table caption';
    begin
        // decommisioning is special version of upsert when decommissioning date is set
        if not ConfirmManagement.GetResponse(StrSubstNo(DecommissionConfirmQst, DEEstablishment.TableCaption()), false) then
            Error('');

        DEEstablishment.TestField(Decommissioned, false);
        DEEstablishment.TestField("Decommissioning Date");

        DETSSClient.SetRange("POS Store Code", DEEstablishment."POS Store Code");
        DETSSClient.SetRange("Additional Data Created", true);
        DETSSClient.SetRange("Additional Data Decommissioned", false);
        if not DETSSClient.IsEmpty() then
            Error(CannotDecomissionDueToRelatedRecordErr, DEEstablishment.TableCaption(), DETSSClient.TableCaption());

        UpsertEstablishment(DEEstablishment, true);
    end;

    internal procedure RetrieveEstablishment(var DEEstablishment: Record "NPR DE Establishment")
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        RetrieveEstablishmentErr: Label 'Error while trying to retrieve the Establishment from Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        CheckFieldValuesForRetrieveEstablishment(DEEstablishment);
        ConnectionParameterSet.GetWithCheck(DEEstablishment."Connection Parameter Set Code");

        OnBeforeSendHttpRequestForRetrieveEstablishment(DEEstablishment, ResponseJson, IsHandled);
        if IsHandled then
            exit;

        UrlFunction := StrSubstNo('/establishment/%1', Format(DEEstablishment.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(RetrieveEstablishmentErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        ResponseJson.ReadFrom(ResponseText);
        PopulateEstablishment(DEEstablishment, ResponseJson);
    end;

    local procedure CheckFieldValuesForUpsertEstablishment(DEEstablishment: Record "NPR DE Establishment")
    begin
        DEEstablishment.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(DEEstablishment.SystemId);
        DEEstablishment.TestField("Connection Parameter Set Code");
        DEEstablishment.TestField(Street);
        DEEstablishment.TestField("House Number");
        DEEstablishment.TestField(Town);
        DEEstablishment.TestField("ZIP Code");
    end;

    local procedure CheckFieldValuesForRetrieveEstablishment(DEEstablishment: Record "NPR DE Establishment")
    begin
        DEEstablishment.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(DEEstablishment.SystemId);
        DEEstablishment.TestField("Connection Parameter Set Code");
    end;

    local procedure CreateJSONBodyForUpsertEstablishment(DEEstablishment: Record "NPR DE Establishment"; Decommission: Boolean) JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
        DecommissioningDateFormatted: Text;
    begin
        JsonTextWriter.WriteStartObject('');

        JsonTextWriter.WriteStartObject('address');
        JsonTextWriter.WriteStringProperty('street', DEEstablishment.Street);
        JsonTextWriter.WriteStringProperty('house_number', DEEstablishment."House Number");
        JsonTextWriter.WriteStringProperty('town', DEEstablishment.Town);
        JsonTextWriter.WriteStringProperty('zip_code', DEEstablishment."ZIP Code");
        if DEEstablishment."House Number Suffix" <> '' then
            JsonTextWriter.WriteStringProperty('house_number_suffix', DEEstablishment."House Number Suffix");

        if DEEstablishment."Additional Address" <> '' then
            JsonTextWriter.WriteStringProperty('address_additional', DEEstablishment."Additional Address");

        JsonTextWriter.WriteEndObject(); // address

        if Decommission or DEEstablishment.Decommissioned then
            if DEEstablishment."Decommissioning Date" <> 0D then begin
                DecommissioningDateFormatted := Format(DEEstablishment."Decommissioning Date", 0, '<Day,2>.<Month,2>.<Year4>');
                JsonTextWriter.WriteStringProperty('decommissioning_date', DecommissioningDateFormatted);
            end;

        if DEEstablishment.Designation <> '' then
            JsonTextWriter.WriteStringProperty('designation', DEEstablishment.Designation);

        if DEEstablishment.Remarks <> '' then
            JsonTextWriter.WriteStringProperty('remarks', DEEstablishment.Remarks);

        AddMetadataForUpsertEstablishment(DEEstablishment, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure AddMetadataForUpsertEstablishment(DEEstablishment: Record "NPR DE Establishment"; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartObject('metadata');
        JsonTextWriter.WriteStringProperty('bc_company_name', CompanyName());
        JsonTextWriter.WriteStringProperty('bc_code', DEEstablishment."POS Store Code");
        JsonTextWriter.WriteStringProperty('bc_description', DEEstablishment.Description);
        JsonTextWriter.WriteEndObject();
    end;

    internal procedure RetrieveEstablishments()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        Window: Dialog;
        RetrievingDataLbl: Label 'Retrieving data from Fiskaly...';
    begin
        ConnectionParameterSet.SetRange("Taxpayer Created", true);
        if ConnectionParameterSet.IsEmpty() then
            exit;

        Window.Open(RetrievingDataLbl);

        ConnectionParameterSet.FindSet();

        repeat
            RetrieveEstablishments(ConnectionParameterSet);
        until ConnectionParameterSet.Next() = 0;

        Window.Close();
    end;

    local procedure RetrieveEstablishments(ConnectionParameterSet: Record "NPR DE Audit Setup")
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        RetrieveEstablishmentsErr: Label 'Error while trying to retrieve Establishments from Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        UrlFunction := '/establishment';
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(RetrieveEstablishmentsErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        ResponseJson.ReadFrom(ResponseText);
        PopulateEstablishmentsForRetrieveEstablishments(ResponseJson, ConnectionParameterSet."Primary Key");
    end;

    local procedure PopulateEstablishmentsForRetrieveEstablishments(ResponseJson: JsonToken; ConnectionParameterSetCode: Code[10])
    var
        DEEstablishment: Record "NPR DE Establishment";
        EstablishmentObject, EstablishmentObjects : JsonToken;
    begin
        if not ResponseJson.SelectToken('results', EstablishmentObjects) then
            exit;

        if not EstablishmentObjects.IsArray() then
            exit;

        foreach EstablishmentObject in EstablishmentObjects.AsArray() do begin
            InsertOrGetEstablishment(DEEstablishment, EstablishmentObject);
            DEEstablishment."Connection Parameter Set Code" := ConnectionParameterSetCode;
            PopulateEstablishment(DEEstablishment, EstablishmentObject);
        end;
    end;

    local procedure InsertOrGetEstablishment(var DEEstablishment: Record "NPR DE Establishment"; var EstablishmentObject: JsonToken)
    var
        EstablishmentId: Guid;
        PropertyValue: JsonToken;
    begin
        EstablishmentObject.SelectToken('id', PropertyValue);
        EstablishmentId := PropertyValue.AsValue().AsText();
        if not DEEstablishment.GetBySystemId(EstablishmentId) then begin
            DEEstablishment.Init();

            EstablishmentObject.SelectToken('$.metadata.bc_code', PropertyValue);
            DEEstablishment."POS Store Code" := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(DEEstablishment."POS Store Code"));

            EstablishmentObject.SelectToken('$.metadata.bc_description', PropertyValue);
            DEEstablishment.Description := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(DEEstablishment.Description));

            DEEstablishment.SystemId := EstablishmentId;
            DEEstablishment.Insert(false, true);
        end;
    end;

    internal procedure PopulateEstablishment(var DEEstablishment: Record "NPR DE Establishment"; ResponseJson: JsonToken)
    var
        PropertyValue: JsonToken;
    begin
        ResponseJson.SelectToken('$.address.street', PropertyValue);
        DEEstablishment.Street := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DEEstablishment.Street));

        ResponseJson.SelectToken('$.address.house_number', PropertyValue);
        DEEstablishment."House Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DEEstablishment."House Number"));

        Clear(DEEstablishment."House Number Suffix");
        if ResponseJson.SelectToken('$.address.house_number_suffix', PropertyValue) then
            DEEstablishment."House Number Suffix" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DEEstablishment."House Number Suffix"));

        ResponseJson.SelectToken('$.address.town', PropertyValue);
        DEEstablishment.Town := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DEEstablishment.Town));

        ResponseJson.SelectToken('$.address.zip_code', PropertyValue);
        DEEstablishment."ZIP Code" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DEEstablishment."ZIP Code"));

        Clear(DEEstablishment."Additional Address");
        if ResponseJson.SelectToken('$.address.address_additional', PropertyValue) then
            DEEstablishment."Additional Address" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DEEstablishment."Additional Address"));

        Clear(DEEstablishment."Decommissioning Date");
        Clear(DEEstablishment.Decommissioned);
        if ResponseJson.SelectToken('decommissioning_date', PropertyValue) then begin
            DEEstablishment."Decommissioning Date" := ConvertToDate(PropertyValue.AsValue().AsText());
            DEEstablishment.Decommissioned := DEEstablishment."Decommissioning Date" <> 0D;
        end;

        Clear(DEEstablishment.Designation);
        if ResponseJson.SelectToken('designation', PropertyValue) then
            DEEstablishment.Designation := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DEEstablishment.Designation));

        Clear(DEEstablishment.Remarks);
        if ResponseJson.SelectToken('remarks', PropertyValue) then
            DEEstablishment.Remarks := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DEEstablishment.Remarks));

        DEEstablishment.Created := true;
        DEEstablishment.Modify(true);
    end;
    #endregion

    #region client additional data management
    internal procedure UpsertClientAdditionalData(var DETSSClient: Record "NPR DE POS Unit Aux. Info"; Decommission: Boolean)
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DETSS: Record "NPR DE TSS";
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        UpsertClientAdditionalDataErr: Label 'Error while trying to create / update the Client additional data at Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        CheckFieldValuesForUpsertClientAdditionalData(DETSSClient);
        DETSS.Get(DETSSClient."TSS Code");
        ConnectionParameterSet.GetWithCheck(DETSS."Connection Parameter Set Code");

        RequestBody.ReadFrom(CreateJSONBodyForUpsertClientAdditionalData(DETSSClient, Decommission));

        OnBeforeSendHttpRequestForUpsertClientAdditionalData(DETSSClient, RequestBody, ResponseJson, IsHandled);
        if IsHandled then
            exit;

        UrlFunction := StrSubstNo('/sign-de-v2/tss/%1/client/%2/additional_data', Format(DETSS.SystemId, 0, 4).ToLower(), Format(DETSSClient.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::PUT, UrlFunction) then
            Error(UpsertClientAdditionalDataErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        ResponseJson.ReadFrom(ResponseText);
        PopulateClientAdditionalData(DETSSClient, ResponseJson);
    end;

    internal procedure DecommissionClientAdditionalData(var DETSSClient: Record "NPR DE POS Unit Aux. Info")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        DecommissionConfirmQst: Label 'Are you sure that you want to decommission this %1, since this it is irreversible?', Comment = '%1 - DE POS Unit Aux. Info table caption';
    begin
        // decommisioning is special version of upsert when decommissioning date is set
        if not ConfirmManagement.GetResponse(StrSubstNo(DecommissionConfirmQst, DETSSClient.TableCaption()), false) then
            Error('');

        DETSSClient.TestField("Additional Data Decommissioned", false);
        DETSSClient.TestField("Decommissioning Date");

        UpsertClientAdditionalData(DETSSClient, true);
    end;

    internal procedure RetrieveClientAdditionalData(var DETSSClient: Record "NPR DE POS Unit Aux. Info")
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DETSS: Record "NPR DE TSS";
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        RetrieveClientAdditionalDataErr: Label 'Error while trying to retrieve the Client''s additional data from Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        CheckFieldValuesForRetrieveClientAdditionalData(DETSSClient);
        DETSS.Get(DETSSClient."TSS Code");
        ConnectionParameterSet.GetWithCheck(DETSS."Connection Parameter Set Code");

        OnBeforeSendHttpRequestForRetrieveClientAdditionalData(DETSSClient, ResponseJson, IsHandled);
        if IsHandled then
            exit;

        UrlFunction := StrSubstNo('/sign-de-v2/tss/%1/client/%2/additional_data', Format(DETSS.SystemId, 0, 4).ToLower(), Format(DETSSClient.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(RetrieveClientAdditionalDataErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        ResponseJson.ReadFrom(ResponseText);
        PopulateClientAdditionalData(DETSSClient, ResponseJson);
    end;

    local procedure CheckFieldValuesForUpsertClientAdditionalData(DETSSClient: Record "NPR DE POS Unit Aux. Info")
    begin
        DETSSClient.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(DETSSClient.SystemId);
        DETSSClient.TestField("Fiskaly Client Created at");
        DETSSClient.TestField("TSS Code");
        DETSSClient.TestField("Acquisition Date");
        DETSSClient.TestField("Commissioning Date");
        DETSSClient.TestField("Cash Register Brand");
        DETSSClient.TestField("Cash Register Model");
        DETSSClient.TestField(Software);
        DETSSClient.CheckIsClientTypePopulated();
    end;

    local procedure CheckFieldValuesForRetrieveClientAdditionalData(DETSSClient: Record "NPR DE POS Unit Aux. Info")
    begin
        DETSSClient.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(DETSSClient.SystemId);
        DETSSClient.TestField("Fiskaly Client Created at");
        DETSSClient.TestField("TSS Code");
    end;

    local procedure CreateJSONBodyForUpsertClientAdditionalData(DETSSClient: Record "NPR DE POS Unit Aux. Info"; Decommission: Boolean) JsonBody: Text
    var
        DEEstablishment: Record "NPR DE Establishment";
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
        AcquisitionDateFormatted, CommissioningDateFormatted, DecommissioningDateFormatted : Text;
    begin
        JsonTextWriter.WriteStartObject('');

        AcquisitionDateFormatted := Format(DETSSClient."Acquisition Date", 0, '<Day,2>.<Month,2>.<Year4>');
        JsonTextWriter.WriteStringProperty('date_acquisition', AcquisitionDateFormatted);

        CommissioningDateFormatted := Format(DETSSClient."Commissioning Date", 0, '<Day,2>.<Month,2>.<Year4>');
        JsonTextWriter.WriteStringProperty('date_commissioning', CommissioningDateFormatted);

        if Decommission or DETSSClient."Additional Data Decommissioned" then begin
            if DETSSClient."Decommissioning Date" <> 0D then begin
                DecommissioningDateFormatted := Format(DETSSClient."Decommissioning Date", 0, '<Day,2>.<Month,2>.<Year4>');
                JsonTextWriter.WriteStringProperty('date_decommissioning', DecommissioningDateFormatted);
            end;

            if DETSSClient."Decommissioning Reason" <> '' then
                JsonTextWriter.WriteStringProperty('decommissioning_reason', DETSSClient."Decommissioning Reason");
        end;

        if DETSSClient."POS Store Code" <> '' then begin
            DEEstablishment.GetWithCheck(DETSSClient."POS Store Code");
            JsonTextWriter.WriteStringProperty('establishment_id', Format(DEEstablishment.SystemId, 0, 4).ToLower());
        end;

        JsonTextWriter.WriteStringProperty('manufacturer', DETSSClient."Cash Register Brand");

        JsonTextWriter.WriteStringProperty('model', DETSSClient."Cash Register Model");

        if DETSSClient.Remarks <> '' then
            JsonTextWriter.WriteStringProperty('remarks', DETSSClient.Remarks);

        JsonTextWriter.WriteStringProperty('software', DETSSClient.Software);

        if DETSSClient."Software Version" <> '' then
            JsonTextWriter.WriteStringProperty('software_version', DETSSClient."Software Version");

        JsonTextWriter.WriteStringProperty('type', Enum::"NPR DE Client Type".Names().Get(Enum::"NPR DE Client Type".Ordinals().IndexOf(DETSSClient."Client Type".AsInteger())));

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    internal procedure PopulateClientAdditionalData(var DETSSClient: Record "NPR DE POS Unit Aux. Info"; ResponseJson: JsonToken)
    var
        PropertyValue: JsonToken;
    begin
        ResponseJson.SelectToken('date_acquisition', PropertyValue);
        DETSSClient."Acquisition Date" := ConvertToDate(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('date_commissioning', PropertyValue);
        DETSSClient."Commissioning Date" := ConvertToDate(PropertyValue.AsValue().AsText());

        Clear(DETSSClient."Decommissioning Date");
        Clear(DETSSClient."Additional Data Decommissioned");
        if ResponseJson.SelectToken('date_decommissioning', PropertyValue) then begin
            DETSSClient."Decommissioning Date" := ConvertToDate(PropertyValue.AsValue().AsText());
            DETSSClient."Additional Data Decommissioned" := DETSSClient."Decommissioning Date" <> 0D;
        end;

        Clear(DETSSClient."Decommissioning Reason");
        if ResponseJson.SelectToken('decommissioning_reason', PropertyValue) then
            DETSSClient."Decommissioning Reason" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DETSSClient."Decommissioning Reason"));

        Clear(DETSSClient."Establishment Id");
        if ResponseJson.SelectToken('establishment_id', PropertyValue) then
            DETSSClient."Establishment Id" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DETSSClient."Establishment Id"));

        ResponseJson.SelectToken('manufacturer', PropertyValue);
        DETSSClient."Cash Register Brand" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DETSSClient."Cash Register Brand"));

        ResponseJson.SelectToken('model', PropertyValue);
        DETSSClient."Cash Register Model" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DETSSClient."Cash Register Model"));

        Clear(DETSSClient.Remarks);
        if ResponseJson.SelectToken('remarks', PropertyValue) then
            DETSSClient.Remarks := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DETSSClient.Remarks));

        ResponseJson.SelectToken('software', PropertyValue);
        DETSSClient.Software := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DETSSClient.Software));

        Clear(DETSSClient."Software Version");
        if ResponseJson.SelectToken('software_version', PropertyValue) then
            DETSSClient."Software Version" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DETSSClient."Software Version"));

        ResponseJson.SelectToken('type', PropertyValue);
        DETSSClient."Client Type" := GetClientType(PropertyValue.AsValue().AsText());

        DETSSClient."Additional Data Created" := true;
        DETSSClient.Modify(true);
    end;

    local procedure GetClientType(ClientType: Text): Enum "NPR DE Client Type"
    begin
        if Enum::"NPR DE Client Type".Names().Contains(ClientType) then
            exit(Enum::"NPR DE Client Type".FromInteger(Enum::"NPR DE Client Type".Ordinals().Get(Enum::"NPR DE Client Type".Names().IndexOf(ClientType))));

        exit(Enum::"NPR DE Client Type"::" ");
    end;
    #endregion

    #region Submission & Transmission management
    internal procedure CreateSubmission(POSStoreCode: Code[10])
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        DESubmission: Record "NPR DE Submission";
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        CreateSubmissionErr: Label 'Error while trying to create the Submission at Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        if POSStoreCode = '' then
            if not SelectEstablishmentForCreateSubmission(POSStoreCode) then
                exit;

        DEEstablishment.GetWithCheck(POSStoreCode);
        ConnectionParameterSet.GetWithCheck(DEEstablishment."Connection Parameter Set Code");
        InsertSubmission(DESubmission, DEEstablishment);
        CheckFieldValuesForCreateSubmission(DESubmission);

        RequestBody.ReadFrom(CreateJSONBodyForCreateSubmission(DESubmission));

        OnBeforeSendHttpRequestForCreateSubmission(DESubmission, RequestBody, ResponseJson, IsHandled);
        if IsHandled then
            exit;

        UrlFunction := StrSubstNo('/submission/%1', Format(DESubmission.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::PUT, UrlFunction) then
            Error(CreateSubmissionErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        ResponseJson.ReadFrom(ResponseText);
        PopulateSubmission(DESubmission, ResponseJson);
    end;

    internal procedure RetrieveSubmission(DESubmission: Record "NPR DE Submission")
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        CreateSubmissionErr: Label 'Error while trying to retrieve the Submission from Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        DEEstablishment.GetWithCheck(DESubmission."POS Store Code");
        ConnectionParameterSet.GetWithCheck(DEEstablishment."Connection Parameter Set Code");
        CheckGeneralFieldValuesOfSubmission(DESubmission);

        OnBeforeSendHttpRequestForRetrieveSubmission(DESubmission, ResponseJson, IsHandled);
        if IsHandled then
            exit;

        UrlFunction := StrSubstNo('/submission/%1', Format(DESubmission.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(CreateSubmissionErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        ResponseJson.ReadFrom(ResponseText);
        PopulateSubmission(DESubmission, ResponseJson);
    end;

    internal procedure DownloadSubmissionXMLFile(DESubmission: Record "NPR DE Submission")
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        RequestBody: JsonObject;
        DownloadSubmissionXMLFileErr: Label 'Error while trying to download XML file of Submission from Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        DEEstablishment.GetWithCheck(DESubmission."POS Store Code");
        ConnectionParameterSet.GetWithCheck(DEEstablishment."Connection Parameter Set Code");
        CheckGeneralFieldValuesOfSubmission(DESubmission);

        UrlFunction := StrSubstNo('/submission/%1/file', Format(DESubmission.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(DownloadSubmissionXMLFileErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        DownloadSubmissionXMLFile(DESubmission, ResponseText);
    end;

    internal procedure DownloadERiCSubmissionValidationPreviewPDFFile(DESubmission: Record "NPR DE Submission")
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        ResponseInStream: InStream;
        RequestBody: JsonObject;
        DownloadERiCSubmissionValidationPreviewPDFFileErr: Label 'Error while trying to download ERiC validation preview PDF file of Submission from Fiskaly.\%1', Comment = '%1 - error message placeholder';
        UrlFunction: Text;
    begin
        DEEstablishment.GetWithCheck(DESubmission."POS Store Code");
        ConnectionParameterSet.GetWithCheck(DEEstablishment."Connection Parameter Set Code");
        CheckFieldValuesForDownloadERiCSubmissionValidationPreviewPDFFile(DESubmission);

        UrlFunction := StrSubstNo('/submission/%1/validation/pdf', Format(DESubmission.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseInStream, ConnectionParameterSet, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(DownloadERiCSubmissionValidationPreviewPDFFileErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        DownloadERiCSubmissionValidationPreviewPDFFile(DESubmission, ResponseInStream);
        Sleep(2000);
        RetrieveSubmission(DESubmission);
    end;

    internal procedure DownloadERiCSubmissionValidationXMLFile(DESubmission: Record "NPR DE Submission")
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        RequestBody: JsonObject;
        DownloadERiCSubmissionValidationXMLFileErr: Label 'Error while trying to download ERiC validation XML file of Submission from Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        DEEstablishment.GetWithCheck(DESubmission."POS Store Code");
        ConnectionParameterSet.GetWithCheck(DEEstablishment."Connection Parameter Set Code");
        CheckFieldValuesForDownloadERiCSubmissionValidationXMLFile(DESubmission);

        UrlFunction := StrSubstNo('/submission/%1/validation/xml', Format(DESubmission.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(DownloadERiCSubmissionValidationXMLFileErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        DownloadERiCSubmissionValidationXMLFile(DESubmission, ResponseText);
    end;

    internal procedure TriggerSubmissionTransmission(DESubmission: Record "NPR DE Submission")
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        TriggerSubmissionTransmissionErr: Label 'Error while trying to trigger the transmission of submission at Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        DEEstablishment.GetWithCheck(DESubmission."POS Store Code");
        ConnectionParameterSet.GetWithCheck(DEEstablishment."Connection Parameter Set Code");
        CheckFieldValuesForTriggerSubmissionTransmission(DESubmission);

        RequestBody.ReadFrom(CreateJSONBodyForTriggerSubmissionTransmission());

        OnBeforeSendHttpRequestForTriggerSubmissionTransmission(DESubmission, RequestBody, ResponseJson, IsHandled);
        if IsHandled then
            exit;

        UrlFunction := StrSubstNo('/submission/%1/transmission', Format(DESubmission.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::PUT, UrlFunction) then
            Error(TriggerSubmissionTransmissionErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        ResponseJson.ReadFrom(ResponseText);
        PopulateSubmission(DESubmission, ResponseJson);
    end;

    internal procedure CancelSubmissionTransmission(DESubmission: Record "NPR DE Submission")
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        IsHandled: Boolean;
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        CancelSubmissionTransmissionErr: Label 'Error while trying to cancel the transmission of submission at Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        DEEstablishment.GetWithCheck(DESubmission."POS Store Code");
        ConnectionParameterSet.GetWithCheck(DEEstablishment."Connection Parameter Set Code");
        CheckFieldValuesForCancelSubmissionTransmission(DESubmission);

        OnBeforeSendHttpRequestForCancelSubmissionTransmission(DESubmission, RequestBody, ResponseJson, IsHandled);
        if IsHandled then
            exit;

        UrlFunction := StrSubstNo('/submission/%1/transmission', Format(DESubmission.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::DELETE, UrlFunction) then
            Error(CancelSubmissionTransmissionErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        ResponseJson.ReadFrom(ResponseText);
        PopulateSubmission(DESubmission, ResponseJson);
    end;

    internal procedure DownloadERiCSubmissionTransmissionPDFFile(DESubmission: Record "NPR DE Submission")
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        ResponseInStream: InStream;
        RequestBody: JsonObject;
        DownloadERiCSubmissionTransmissionPDFFileErr: Label 'Error while trying to download ERiC transmission PDF file of Submission from Fiskaly.\%1', Comment = '%1 - error message placeholder';
        UrlFunction: Text;
    begin
        DEEstablishment.GetWithCheck(DESubmission."POS Store Code");
        ConnectionParameterSet.GetWithCheck(DEEstablishment."Connection Parameter Set Code");
        CheckFieldValuesForDownloadERiCSubmissionTransmissionPDFFile(DESubmission);

        UrlFunction := StrSubstNo('/submission/%1/transmission/pdf', Format(DESubmission.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseInStream, ConnectionParameterSet, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(DownloadERiCSubmissionTransmissionPDFFileErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        DownloadERiCSubmissionTransmissionPDFFile(DESubmission, ResponseInStream);
        Sleep(2000);
        RetrieveSubmission(DESubmission);
    end;

    internal procedure DownloadERiCELSTERSubmissionTransmissionXMLFile(DESubmission: Record "NPR DE Submission")
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        DEEstablishment: Record "NPR DE Establishment";
        RequestBody: JsonObject;
        DownloadERiCELSTERSubmissionTransmissionXMLFileErr: Label 'Error while trying to download ERiC/ELSTER transmission XML file of Submission from Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        DEEstablishment.GetWithCheck(DESubmission."POS Store Code");
        ConnectionParameterSet.GetWithCheck(DEEstablishment."Connection Parameter Set Code");
        CheckFieldValuesForDownloadERiCELSTERSubmissionTransmissionXMLFile(DESubmission);

        UrlFunction := StrSubstNo('/submission/%1/transmission/xml', Format(DESubmission.SystemId, 0, 4).ToLower());
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(DownloadERiCELSTERSubmissionTransmissionXMLFileErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        DownloadERiCELSTERSubmissionTransmissionXMLFile(DESubmission, ResponseText);
    end;

    local procedure SelectEstablishmentForCreateSubmission(var POSStoreCode: Code[10]): Boolean
    var
        DEEstablishment: Record "NPR DE Establishment";
    begin
        DEEstablishment.SetRange(Created, true);
        if Page.RunModal(0, DEEstablishment) <> Action::LookupOK then
            exit(false);

        POSStoreCode := DEEstablishment."POS Store Code";
        exit(true);
    end;

    local procedure CheckFieldValuesForCreateSubmission(DESubmission: Record "NPR DE Submission")
    begin
        CheckGeneralFieldValuesOfSubmission(DESubmission);
        DESubmission.TestField("Establishment Id");
        CheckIsGUIDAccordingToUUIDv4Standard(DESubmission."Establishment Id");
    end;

    local procedure CheckGeneralFieldValuesOfSubmission(DESubmission: Record "NPR DE Submission")
    begin
        DESubmission.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(DESubmission.SystemId);
    end;

    local procedure CheckFieldValuesForDownloadERiCSubmissionValidationXMLFile(DESubmission: Record "NPR DE Submission")
    var
        SubmissionStateErr: Label '%1 of %2 has to be %3 or %4 in order to be able to use this action.', Comment = '%1 - DE Submission State field caption, %2 - DE Submission table caption, %3 - DE Submission State INTERNAL_VALIDATION_FAILED value, %4 - DE Submission State EXTERNAL_VALIDATION_FAILED value';
    begin
        CheckGeneralFieldValuesOfSubmission(DESubmission);
        if not (DESubmission.State in [DESubmission.State::INTERNAL_VALIDATION_FAILED, DESubmission.State::EXTERNAL_VALIDATION_FAILED]) then
            Error(SubmissionStateErr, DESubmission.FieldCaption(State), DESubmission.TableCaption(), DESubmission.State::INTERNAL_VALIDATION_FAILED, DESubmission.State::EXTERNAL_VALIDATION_FAILED);
    end;

    local procedure CheckFieldValuesForDownloadERiCSubmissionValidationPreviewPDFFile(DESubmission: Record "NPR DE Submission")
    var
        SubmissionStateErr: Label '%1 of %2 has to be %3 in order to be able to use this action.', Comment = '%1 - DE Submission State field caption, %2 - DE Submission table caption, %3 - DE Submission State VALIDATION_SUCCEEDED value';
    begin
        CheckGeneralFieldValuesOfSubmission(DESubmission);
        if DESubmission.State <> DESubmission.State::VALIDATION_SUCCEEDED then
            Error(SubmissionStateErr, DESubmission.FieldCaption(State), DESubmission.TableCaption(), DESubmission.State::VALIDATION_SUCCEEDED);
    end;

    local procedure CheckFieldValuesForTriggerSubmissionTransmission(DESubmission: Record "NPR DE Submission")
    var
        SubmissionStateErr: Label '%1 of %2 has to be %3 in order to be able to use this action.', Comment = '%1 - DE Submission State field caption, %2 - DE Submission table caption, %3 - DE Submission State READY_FOR_TRANSMISSION value';
    begin
        CheckGeneralFieldValuesOfSubmission(DESubmission);
        if DESubmission.State <> DESubmission.State::READY_FOR_TRANSMISSION then
            Error(SubmissionStateErr, DESubmission.FieldCaption(State), DESubmission.TableCaption(), DESubmission.State::READY_FOR_TRANSMISSION);
    end;

    local procedure CheckFieldValuesForCancelSubmissionTransmission(DESubmission: Record "NPR DE Submission")
    var
        SubmissionStateErr: Label '%1 of %2 has to be %3 in order to be able to use this action.', Comment = '%1 - DE Submission State field caption, %2 - DE Submission table caption, %3 - DE Submission State TRANSMISSION_PENDING value';
    begin
        CheckGeneralFieldValuesOfSubmission(DESubmission);
        if DESubmission.State <> DESubmission.State::TRANSMISSION_PENDING then
            Error(SubmissionStateErr, DESubmission.FieldCaption(State), DESubmission.TableCaption(), DESubmission.State::TRANSMISSION_PENDING);
    end;

    local procedure CheckFieldValuesForDownloadERiCSubmissionTransmissionPDFFile(DESubmission: Record "NPR DE Submission")
    var
        SubmissionStateErr: Label '%1 of %2 has to be %3 in order to be able to use this action.', Comment = '%1 - DE Submission State field caption, %2 - DE Submission table caption, %3 - DE Submission State TRANSMISSION_SUCCEEDED value';
    begin
        CheckGeneralFieldValuesOfSubmission(DESubmission);
        if DESubmission.State <> DESubmission.State::TRANSMISSION_SUCCEEDED then
            Error(SubmissionStateErr, DESubmission.FieldCaption(State), DESubmission.TableCaption(), DESubmission.State::TRANSMISSION_SUCCEEDED);
    end;

    local procedure CheckFieldValuesForDownloadERiCELSTERSubmissionTransmissionXMLFile(DESubmission: Record "NPR DE Submission")
    var
        SubmissionStateErr: Label '%1 of %2 has to be %3 in order to be able to use this action.', Comment = '%1 - DE Submission State field caption, %2 - DE Submission table caption, %3 - DE Submission State TRANSMISSION_FAILED value';
    begin
        CheckGeneralFieldValuesOfSubmission(DESubmission);
        if DESubmission.State <> DESubmission.State::TRANSMISSION_FAILED then
            Error(SubmissionStateErr, DESubmission.FieldCaption(State), DESubmission.TableCaption(), DESubmission.State::TRANSMISSION_FAILED);
    end;

    local procedure InsertSubmission(var DESubmission: Record "NPR DE Submission"; DEEstablishment: Record "NPR DE Establishment")
    begin
        DESubmission.Init();
        DESubmission."Entry No." := DESubmission.GetLastEntryNo() + 1;
        DESubmission."POS Store Code" := DEEstablishment."POS Store Code";
        DESubmission."Establishment Id" := DEEstablishment.SystemId;
        DESubmission.Insert(true);
    end;

    local procedure CreateJSONBodyForCreateSubmission(DESubmission: Record "NPR DE Submission") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');

        JsonTextWriter.WriteStringProperty('establishment_id', Format(DESubmission."Establishment Id", 0, 4).ToLower());

        AddMetadataForCreateSubmission(DESubmission, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure CreateJSONBodyForTriggerSubmissionTransmission() JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');

        JsonTextWriter.WriteBooleanProperty('legal_consent', true);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure AddMetadataForCreateSubmission(DESubmission: Record "NPR DE Submission"; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartObject('metadata');
        JsonTextWriter.WriteStringProperty('bc_company_name', CompanyName());
        JsonTextWriter.WriteStringProperty('bc_entry_no', DESubmission."Entry No.");
        JsonTextWriter.WriteStringProperty('bc_pos_store_code', DESubmission."POS Store Code");
        JsonTextWriter.WriteEndObject();
    end;

    internal procedure RetrieveSubmissions()
    var
        ConnectionParameterSet: Record "NPR DE Audit Setup";
        Window: Dialog;
        RetrievingDataLbl: Label 'Retrieving data from Fiskaly...';
    begin
        ConnectionParameterSet.SetRange("Taxpayer Created", true);
        if ConnectionParameterSet.IsEmpty() then
            exit;

        Window.Open(RetrievingDataLbl);

        ConnectionParameterSet.FindSet();

        repeat
            RetrieveSubmissions(ConnectionParameterSet);
        until ConnectionParameterSet.Next() = 0;

        Window.Close();
    end;

    local procedure RetrieveSubmissions(ConnectionParameterSet: Record "NPR DE Audit Setup")
    var
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        RetrieveEstablishmentsErr: Label 'Error while trying to retrieve Submissions from Fiskaly.\%1', Comment = '%1 - error message placeholder';
        ResponseText: Text;
        UrlFunction: Text;
    begin
        UrlFunction := '/submission';
        if not SendRequest_SIGNDE_Submission(RequestBody, ResponseText, ConnectionParameterSet, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(RetrieveEstablishmentsErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));

        ResponseJson.ReadFrom(ResponseText);
        PopulateSubmissionsForRetrieveSubmissions(ResponseJson);
    end;

    local procedure PopulateSubmissionsForRetrieveSubmissions(ResponseJson: JsonToken)
    var
        DESubmission: Record "NPR DE Submission";
        SubmissionObject, SubmissionObjects : JsonToken;
    begin
        if not ResponseJson.SelectToken('results', SubmissionObjects) then
            exit;

        if not SubmissionObjects.IsArray() then
            exit;

        foreach SubmissionObject in SubmissionObjects.AsArray() do begin
            InsertOrGetSubmission(DESubmission, SubmissionObject);
            PopulateSubmission(DESubmission, SubmissionObject);
        end;
    end;

    local procedure InsertOrGetSubmission(var DESubmission: Record "NPR DE Submission"; var SubmissionObject: JsonToken)
    var
        DESubmission2: Record "NPR DE Submission";
        SubmissionId: Guid;
        EntryNo: Integer;
        PropertyValue: JsonToken;
    begin
        SubmissionObject.SelectToken('id', PropertyValue);
        SubmissionId := PropertyValue.AsValue().AsText();
        if not DESubmission.GetBySystemId(SubmissionId) then begin
            DESubmission.Init();

            SubmissionObject.SelectToken('$.metadata.bc_entry_no', PropertyValue);
            EntryNo := PropertyValue.AsValue().AsInteger();
            if not DESubmission2.Get(EntryNo) then
                DESubmission."Entry No." := EntryNo
            else
                DESubmission."Entry No." := DESubmission.GetLastEntryNo() + 1;

            DESubmission.SystemId := SubmissionId;
            DESubmission.Insert(false, true);
        end;
    end;

    internal procedure PopulateSubmission(var DESubmission: Record "NPR DE Submission"; ResponseJson: JsonToken)
    var
        PropertyValue: JsonToken;
    begin
        ResponseJson.SelectToken('$.metadata.bc_pos_store_code', PropertyValue);
        DESubmission."POS Store Code" := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(DESubmission."POS Store Code"));

        ResponseJson.SelectToken('establishment_id', PropertyValue);
        DESubmission."Establishment Id" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DESubmission."Establishment Id"));

        ResponseJson.SelectToken('state', PropertyValue);
        DESubmission.State := GetSubmissionState(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('time_created', PropertyValue);
        DESubmission."Created At" := ConvertToDateTime(PropertyValue.AsValue().AsText());

        Clear(DESubmission."Generated At");
        if ResponseJson.SelectToken('time_generated', PropertyValue) then
            DESubmission."Generated At" := ConvertToDateTime(PropertyValue.AsValue().AsText());

        Clear(DESubmission."Transmitted At");
        if ResponseJson.SelectToken('time_transmitted', PropertyValue) then
            DESubmission."Transmitted At" := ConvertToDateTime(PropertyValue.AsValue().AsText());

        Clear(DESubmission."Errored At");
        if ResponseJson.SelectToken('time_error', PropertyValue) then
            DESubmission."Errored At" := ConvertToDateTime(PropertyValue.AsValue().AsText());

        Clear(DESubmission.Error);
        if ResponseJson.SelectToken('error_description', PropertyValue) then
            DESubmission.Error := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DESubmission.Error));

        DESubmission.Modify(true);
    end;

    local procedure GetSubmissionState(SubmissionState: Text): Enum "NPR DE Submission State"
    begin
        if Enum::"NPR DE Submission State".Names().Contains(SubmissionState) then
            exit(Enum::"NPR DE Submission State".FromInteger(Enum::"NPR DE Submission State".Ordinals().Get(Enum::"NPR DE Submission State".Names().IndexOf(SubmissionState))));

        exit(Enum::"NPR DE Submission State"::" ");
    end;

    local procedure DownloadSubmissionXMLFile(DESubmission: Record "NPR DE Submission"; ResponseText: Text)
    var
        FilenameLbl: Label '%1.xml', Locked = true;
    begin
        DownloadXMLFile(StrSubstNo(FilenameLbl, Format(DESubmission.SystemId, 0, 4).ToLower()), ResponseText);
    end;

    local procedure DownloadERiCSubmissionValidationPreviewPDFFile(DESubmission: Record "NPR DE Submission"; ResponseInStream: InStream)
    var
        FilenameLbl: Label 'ERiC-Validation-%1.pdf', Locked = true;
        Filename: Text;
    begin
        Filename := StrSubstNo(FilenameLbl, Format(DESubmission.SystemId, 0, 4).ToLower());
        DownloadFromStream(ResponseInStream, '', '', '', Filename);
    end;

    local procedure DownloadERiCSubmissionValidationXMLFile(DESubmission: Record "NPR DE Submission"; ResponseText: Text)
    var
        FilenameLbl: Label 'ERiC-Validation-%1.xml', Locked = true;
    begin
        DownloadXMLFile(StrSubstNo(FilenameLbl, Format(DESubmission.SystemId, 0, 4).ToLower()), ResponseText);
    end;

    local procedure DownloadERiCSubmissionTransmissionPDFFile(DESubmission: Record "NPR DE Submission"; ResponseInStream: InStream)
    var
        FilenameLbl: Label 'ERiC-Transmission-%1.pdf', Locked = true;
        Filename: Text;
    begin
        Filename := StrSubstNo(FilenameLbl, Format(DESubmission.SystemId, 0, 4).ToLower());
        DownloadFromStream(ResponseInStream, '', '', '', Filename);
    end;

    local procedure DownloadERiCELSTERSubmissionTransmissionXMLFile(DESubmission: Record "NPR DE Submission"; ResponseText: Text)
    var
        FilenameLbl: Label 'ERiC-ELSTER-Transmission-%1.xml', Locked = true;
    begin
        DownloadXMLFile(StrSubstNo(FilenameLbl, Format(DESubmission.SystemId, 0, 4).ToLower()), ResponseText);
    end;

    local procedure DownloadXMLFile(Filename: Text; ResponseText: Text)
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ResponseText);
        FileManagement.BLOBExport(TempBlob, Filename, true);
    end;
    #endregion

    #region Data Export management
    internal procedure TriggerExport(var DEDataExport: Record "NPR DE Data Export")
    var
        DETSS: Record "NPR DE TSS";
        ConnectionParameters: Record "NPR DE Audit Setup";
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        UrlFunction: Text;
        TSSExportTriggerErr: Label 'Error while trying to trigger a data export at Fiskaly.\%1';
    begin
        CheckFieldValuesForTriggerExport(DEDataExport);
        DETSS.Get(DEDataExport."TSS Code");
        ConnectionParameters.Get(DETSS."Connection Parameter Set Code");

        RequestBody := CreateJSONBodyForTriggerExport(DEDataExport);
        UrlFunction := StrSubstNo('/tss/%1/export/%2', Format(DETSS.SystemId, 0, 4), Format(DEDataExport.SystemId, 0, 4));

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::PUT, UrlFunction) then
            Error(TSSExportTriggerErr, GetLastErrorText());

        PopulateDataExport(DEDataExport, ResponseJson);
    end;

    internal procedure RetrieveExport(var DEDataExport: Record "NPR DE Data Export")
    var
        DETSS: Record "NPR DE TSS";
        ConnectionParameters: Record "NPR DE Audit Setup";
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        UrlFunction: Text;
        TSSExportRetrieveErr: Label 'Error while trying to retrieve a data export from Fiskaly.\%1';
    begin
        CheckGeneralFieldValuesOfDataExport(DEDataExport);
        DETSS.Get(DEDataExport."TSS Code");
        ConnectionParameters.Get(DETSS."Connection Parameter Set Code");

        UrlFunction := StrSubstNo('/tss/%1/export/%2', Format(DETSS.SystemId, 0, 4), Format(DEDataExport.SystemId, 0, 4));

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(TSSExportRetrieveErr, GetLastErrorText());

        PopulateDataExport(DEDataExport, ResponseJson);
    end;

    internal procedure CancelExport(var DEDataExport: Record "NPR DE Data Export")
    var
        DETSS: Record "NPR DE TSS";
        ConnectionParameters: Record "NPR DE Audit Setup";
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        UrlFunction: Text;
        TSSExportCancelErr: Label 'Error while trying to cancel a data export at Fiskaly.\%1';
        ExportCancelConfirmQst: Label 'Are you sure you want to cancel this data export? This action cannot be undone if the export is in PENDING or WORKING state.';
    begin
        CheckFieldValuesForCancelExport(DEDataExport);
        if not Confirm(ExportCancelConfirmQst) then
            exit;

        DETSS.Get(DEDataExport."TSS Code");
        ConnectionParameters.Get(DETSS."Connection Parameter Set Code");

        UrlFunction := StrSubstNo('/tss/%1/export/%2', Format(DETSS.SystemId, 0, 4), Format(DEDataExport.SystemId, 0, 4));

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::DELETE, UrlFunction) then
            Error(TSSExportCancelErr, GetLastErrorText());

        PopulateDataExport(DEDataExport, ResponseJson);
    end;

    internal procedure DownloadExportTARFile(DEDataExport: Record "NPR DE Data Export")
    var
        DETSS: Record "NPR DE TSS";
        ConnectionParameters: Record "NPR DE Audit Setup";
        Client: HttpClient;
        Headers: HttpHeaders;
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        ResponseInStream: InStream;
        UrlFunction: Text;
        TSSExportDownloadErr: Label 'Error while trying to download TAR file from Fiskaly.\%1';
    begin
        CheckFieldValuesForDownloadExportTARFile(DEDataExport);
        DETSS.Get(DEDataExport."TSS Code");
        ConnectionParameters.Get(DETSS."Connection Parameter Set Code");

        CheckHttpClientRequestsAllowed();
        UrlFunction := StrSubstNo('/tss/%1/export/%2/file', Format(DETSS.SystemId, 0, 4), Format(DEDataExport.SystemId, 0, 4));

        ConnectionParameters.TestField("Api URL");
        HttpWebRequest.SetRequestUri(ConnectionParameters."Api URL" + UrlFunction);
        SetHttpHeaders(Enum::"Http Request Type"::GET, HttpWebRequest, Headers);
        Headers.Add('Authorization', StrSubstNo(BearerTokenLbl, Get_signDE_V2_JwtToken(ConnectionParameters)));

        Client.Send(HttpWebRequest, HttpWebResponse);

        if not HttpWebResponse.IsSuccessStatusCode then begin
            HttpWebResponse.Content.ReadAs(ResponseInStream);
            Error(TSSExportDownloadErr, Format(HttpWebResponse.HttpStatusCode) + ' ' + HttpWebResponse.ReasonPhrase);
        end;

        HttpWebResponse.Content.ReadAs(ResponseInStream);
        DownloadExportTARFile(DEDataExport, ResponseInStream);
    end;

    internal procedure ListExports(TSSCode: Code[10])
    var
        DETSS: Record "NPR DE TSS";
        ConnectionParameters: Record "NPR DE Audit Setup";
        RequestBody: JsonObject;
        ResponseJson: JsonToken;
        UrlFunction: Text;
        TSSExportListErr: Label 'Error while trying to retrieve list of data exports from Fiskaly.\%1';
    begin
        if TSSCode <> '' then begin
            DETSS.Get(TSSCode);
            DETSS.TestField("Connection Parameter Set Code");
            ConnectionParameters.Get(DETSS."Connection Parameter Set Code");
            UrlFunction := StrSubstNo('/tss/%1/export', Format(DETSS.SystemId, 0, 4));
        end else begin
            ConnectionParameters.FindFirst();
            UrlFunction := '/export';
        end;

        if not SendRequest_signDE_V2(RequestBody, ResponseJson, ConnectionParameters, Enum::"Http Request Type"::GET, UrlFunction) then
            Error(TSSExportListErr, GetLastErrorText());

        PopulateDataExportsForListExports(ResponseJson, TSSCode);
    end;

    local procedure CheckFieldValuesForTriggerExport(DEDataExport: Record "NPR DE Data Export")
    var
        DETSS: Record "NPR DE TSS";
    begin
        CheckGeneralFieldValuesOfDataExport(DEDataExport);
        DETSS.Get(DEDataExport."TSS Code");
        CheckIsGUIDAccordingToUUIDv4Standard(DETSS.SystemId);
    end;

    local procedure CheckFieldValuesForCancelExport(DEDataExport: Record "NPR DE Data Export")
    var
        ExportStateErr: Label '%1 of %2 has to be %3 or %4 in order to be able to cancel the export.', Comment = '%1 - DE Data Export State field caption, %2 - DE Data Export table caption, %3 - DE Export State PENDING value, %4 - DE Export State WORKING value';
    begin
        CheckGeneralFieldValuesOfDataExport(DEDataExport);
        if not (DEDataExport.State in [DEDataExport.State::PENDING, DEDataExport.State::WORKING]) then
            Error(ExportStateErr, DEDataExport.FieldCaption(State), DEDataExport.TableCaption(), DEDataExport.State::PENDING, DEDataExport.State::WORKING);
    end;

    local procedure CheckFieldValuesForDownloadExportTARFile(DEDataExport: Record "NPR DE Data Export")
    var
        ExportStateErr: Label '%1 of %2 has to be %3 in order to be able to download the TAR file.', Comment = '%1 - DE Data Export State field caption, %2 - DE Data Export table caption, %3 - DE Export State COMPLETED value';
    begin
        CheckGeneralFieldValuesOfDataExport(DEDataExport);
        if DEDataExport.State <> DEDataExport.State::COMPLETED then
            Error(ExportStateErr, DEDataExport.FieldCaption(State), DEDataExport.TableCaption(), DEDataExport.State::COMPLETED);
    end;

    local procedure CheckGeneralFieldValuesOfDataExport(DEDataExport: Record "NPR DE Data Export")
    begin
        DEDataExport.TestField("TSS Code");
        CheckIsGUIDAccordingToUUIDv4Standard(DEDataExport.SystemId);
    end;

    local procedure CreateJSONBodyForTriggerExport(DEDataExport: Record "NPR DE Data Export") RequestJson: JsonObject
    begin
        // Add query parameters as per API documentation
        if DEDataExport."Client Id" <> '' then
            RequestJson.Add('client_id', DEDataExport."Client Id");
        if DEDataExport."Transaction Number" <> '' then
            RequestJson.Add('transaction_number', DEDataExport."Transaction Number");
        if DEDataExport."Start Transaction Number" <> '' then
            RequestJson.Add('start_transaction_number', DEDataExport."Start Transaction Number");
        if DEDataExport."End Transaction Number" <> '' then
            RequestJson.Add('end_transaction_number', DEDataExport."End Transaction Number");
        if DEDataExport."Start Date" <> 0 then
            RequestJson.Add('start_date', DEDataExport."Start Date");
        if DEDataExport."End Date" <> 0 then
            RequestJson.Add('end_date', DEDataExport."End Date");
        if DEDataExport."Maximum Number Records" <> 0 then
            RequestJson.Add('maximum_number_records', DEDataExport."Maximum Number Records")
        else
            RequestJson.Add('maximum_number_records', '1000000'); // Default value
        if DEDataExport."Start Signature Counter" <> '' then
            RequestJson.Add('start_signature_counter', DEDataExport."Start Signature Counter");
        if DEDataExport."End Signature Counter" <> '' then
            RequestJson.Add('end_signature_counter', DEDataExport."End Signature Counter");
    end;

    local procedure PopulateDataExportsForListExports(ResponseJson: JsonToken; TSSCode: Code[10])
    var
        DEDataExport: Record "NPR DE Data Export";
        ExportObject, ExportObjects : JsonToken;
        PropertyValue: JsonToken;
    begin
        DEDataExport.DeleteAll();
        if ResponseJson.SelectToken('data', ExportObjects) then begin
            foreach ExportObject in ExportObjects.AsArray() do begin
                if ExportObject.SelectToken('_id', PropertyValue) then begin
                    if not DEDataExport.GetBySystemId(PropertyValue.AsValue().AsText()) then begin
                        DEDataExport.Init();
                        DEDataExport.SystemId := PropertyValue.AsValue().AsText();
                        DEDataExport."TSS Code" := TSSCode;
                        if ExportObject.SelectToken('tss_id', PropertyValue) then
                            DEDataExport.Validate("TSS ID", PropertyValue.AsValue().AsText());
                        DEDataExport.Insert(true);
                    end;
                    PopulateDataExport(DEDataExport, ExportObject);
                end;
            end;
        end;
    end;

    internal procedure PopulateDataExport(var DEDataExport: Record "NPR DE Data Export"; ResponseJson: JsonToken)
    var
        PropertyValue: JsonToken;
    begin
        if ResponseJson.SelectToken('state', PropertyValue) then
            DEDataExport.State := GetExportState(PropertyValue.AsValue().AsText());
        if ResponseJson.SelectToken('exception', PropertyValue) then
            DEDataExport.Exception := GetExportException(PropertyValue.AsValue().AsText());
        if ResponseJson.SelectToken('time_request', PropertyValue) then
            DEDataExport."Time Request" := PropertyValue.AsValue().AsBigInteger();
        if ResponseJson.SelectToken('time_start', PropertyValue) then
            DEDataExport."Time Start" := PropertyValue.AsValue().AsBigInteger();
        if ResponseJson.SelectToken('time_end', PropertyValue) then
            DEDataExport."Time End" := PropertyValue.AsValue().AsBigInteger();
        if ResponseJson.SelectToken('time_expiration', PropertyValue) then
            DEDataExport."Time Expiration" := PropertyValue.AsValue().AsBigInteger();
        if ResponseJson.SelectToken('time_error', PropertyValue) then
            DEDataExport."Time Error" := PropertyValue.AsValue().AsBigInteger();
        if ResponseJson.SelectToken('estimated_time_of_completion', PropertyValue) then
            DEDataExport."Estimated Time Of Completion" := PropertyValue.AsValue().AsBigInteger();
        if ResponseJson.SelectToken('tss_id', PropertyValue) then
            DEDataExport.Validate("TSS ID", PropertyValue.AsValue().AsText());
        if ResponseJson.SelectToken('_env', PropertyValue) then
            DEDataExport.Environment := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DEDataExport.Environment));
        if ResponseJson.SelectToken('_version', PropertyValue) then
            DEDataExport.Version := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(DEDataExport.Version));

        DEDataExport.Modify(true);
    end;

    local procedure GetExportState(ExportState: Text): Enum "NPR DE Export State"
    begin
        case ExportState of
            'CANCELLED':
                exit(Enum::"NPR DE Export State"::CANCELLED);
            'PENDING':
                exit(Enum::"NPR DE Export State"::PENDING);
            'WORKING':
                exit(Enum::"NPR DE Export State"::WORKING);
            'COMPLETED':
                exit(Enum::"NPR DE Export State"::COMPLETED);
            'ERROR':
                exit(Enum::"NPR DE Export State"::ERROR);
        end;

        exit(Enum::"NPR DE Export State"::" ");
    end;

    local procedure GetExportException(ExportException: Text): Enum "NPR DE Export Exception"
    begin
        case ExportException of
            'E_UNEXPECTED':
                exit(Enum::"NPR DE Export Exception"::E_UNEXPECTED);
            'E_ID_NOT_FOUND':
                exit(Enum::"NPR DE Export Exception"::E_ID_NOT_FOUND);
            'E_BAD_REQUEST':
                exit(Enum::"NPR DE Export Exception"::E_BAD_REQUEST);
            'E_INTERNAL':
                exit(Enum::"NPR DE Export Exception"::E_INTERNAL);
            'E_TRANSACTION_ID_NOT_FOUND':
                exit(Enum::"NPR DE Export Exception"::E_TRANSACTION_ID_NOT_FOUND);
            'E_NO_DATA_AVAILABLE':
                exit(Enum::"NPR DE Export Exception"::E_NO_DATA_AVAILABLE);
            'E_TOO_MANY_RECORDS':
                exit(Enum::"NPR DE Export Exception"::E_TOO_MANY_RECORDS);
            'E_ALREADY_PROCESSING':
                exit(Enum::"NPR DE Export Exception"::E_ALREADY_PROCESSING);
            'E_LOGS_NOT_DELETED':
                exit(Enum::"NPR DE Export Exception"::E_LOGS_NOT_DELETED);
            'E_EXPORT_PROCESSING_TIMEOUT':
                exit(Enum::"NPR DE Export Exception"::E_EXPORT_PROCESSING_TIMEOUT);
        end;

        exit(Enum::"NPR DE Export Exception"::" ");
    end;

    local procedure DownloadExportTARFile(DEDataExport: Record "NPR DE Data Export"; ResponseInStream: InStream)
    var
        FilenameLbl: Label 'Export-%1.tar', Locked = true;
        Filename: Text;
    begin
        Filename := StrSubstNo(FilenameLbl, Format(DEDataExport.SystemId, 0, 4).ToLower());
        DownloadFromStream(ResponseInStream, '', '', '', Filename);
    end;
    #endregion

    #region V2 (signDE) API request handling
    internal procedure SendRequest_signDE_V2(RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup"; HttpRequestType: Enum "Http Request Type"; UrlFunction: Text): Boolean
    begin
        exit(SendRequest_signDE_V2(RequestBodyJsonIn, ResponseJsonOut, ConnectionParameters, HttpRequestType, UrlFunction, false));
    end;

    [TryFunction]
    local procedure SendRequest_signDE_V2(RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup"; HttpRequestType: Enum "Http Request Type"; UrlFunction: Text; IsAuthenticationTokenRefreshRequest: Boolean)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        ResponseTxt: Text;
    begin
        Clear(ResponseJsonOut);
        CheckHttpClientRequestsAllowed();

        if HttpRequestType <> Enum::"Http Request Type"::GET then
            AddRequestBodyAndHeadersToRequest(RequestBodyJsonIn, HttpWebRequest, Headers);

        ConnectionParameters.TestField("Api URL");
        HttpWebRequest.SetRequestUri(ConnectionParameters."Api URL" + UrlFunction);
        SetHttpHeaders(HttpRequestType, HttpWebRequest, Headers);

        if not IsAuthenticationTokenRefreshRequest then
            Headers.Add('Authorization', StrSubstNo(BearerTokenLbl, Get_signDE_V2_JwtToken(ConnectionParameters)));

        Client.Send(HttpWebRequest, HttpWebResponse);
        if not HttpWebResponse.Content.ReadAs(ResponseTxt) then
            ResponseTxt := '';

        if not HttpWebResponse.IsSuccessStatusCode then
            Error(UnsuccessfullResponseErr, HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, ResponseTxt);

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
        exit(SendRequest_signDE_V2(RefreshTokenJson, JWTResponseJson, ConnectionParameters, Enum::"Http Request Type"::POST, '/auth', true));
    end;
    #endregion

    #region DSFinV-K API request handling
    internal procedure SendRequest_DSFinV_K(RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup"; HttpRequestType: Enum "Http Request Type"; UrlFunction: Text): Boolean
    begin
        exit(SendRequest_DSFinV_K(RequestBodyJsonIn, ResponseJsonOut, ConnectionParameters, HttpRequestType, UrlFunction, false));
    end;

    [TryFunction]
    local procedure SendRequest_DSFinV_K(RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup"; HttpRequestType: Enum "Http Request Type"; UrlFunction: Text; IsAuthenticationTokenRefreshRequest: Boolean)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        ResponseTxt: Text;
    begin
        Clear(ResponseJsonOut);
        CheckHttpClientRequestsAllowed();

        if HttpRequestType <> Enum::"Http Request Type"::GET then
            AddRequestBodyAndHeadersToRequest(RequestBodyJsonIn, HttpWebRequest, Headers);

        ConnectionParameters.TestField("DSFINVK Api URL");
        HttpWebRequest.SetRequestUri(ConnectionParameters."DSFINVK Api URL" + UrlFunction);
        SetHttpHeaders(HttpRequestType, HttpWebRequest, Headers);

        if not IsAuthenticationTokenRefreshRequest then
            Headers.Add('Authorization', StrSubstNo(BearerTokenLbl, Get_DSFinV_K_JwtToken(ConnectionParameters)));

        Client.Send(HttpWebRequest, HttpWebResponse);
        if not HttpWebResponse.Content.ReadAs(ResponseTxt) then
            ResponseTxt := '';

        if not HttpWebResponse.IsSuccessStatusCode then
            Error(UnsuccessfullResponseErr, HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, ResponseTxt);

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
        exit(SendRequest_DSFinV_K(RefreshTokenJson, JWTResponseJson, ConnectionParameters, Enum::"Http Request Type"::POST, '/auth', true));
    end;
    #endregion

    #region SIGN DE x Sumbission API request handling
    internal procedure SendRequest_SIGNDE_Submission(RequestBodyJsonIn: JsonObject; var ResponseText: Text; ConnectionParameterSet: Record "NPR DE Audit Setup"; HttpRequestType: Enum "Http Request Type"; UrlFunction: Text): Boolean
    begin
        exit(SendRequest_SIGNDE_Submission(RequestBodyJsonIn, ResponseText, ConnectionParameterSet, HttpRequestType, UrlFunction, false));
    end;

    local procedure SendRequest_SIGNDE_Submission(RequestBodyJsonIn: JsonObject; var ResponseInStream: InStream; ConnectionParameterSet: Record "NPR DE Audit Setup"; HttpRequestType: Enum "Http Request Type"; UrlFunction: Text): Boolean
    begin
        exit(SendRequest_SIGNDE_Submission(RequestBodyJsonIn, ResponseInStream, ConnectionParameterSet, HttpRequestType, UrlFunction, false));
    end;

    [TryFunction]
    local procedure SendRequest_SIGNDE_Submission(RequestBodyJsonIn: JsonObject; var ResponseText: Text; ConnectionParameterSet: Record "NPR DE Audit Setup"; HttpRequestType: Enum "Http Request Type"; UrlFunction: Text; IsAuthenticationTokenRefreshRequest: Boolean)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
    begin
        Clear(ResponseText);
        CheckHttpClientRequestsAllowed();

        if HttpRequestType <> Enum::"Http Request Type"::GET then
            AddRequestBodyAndHeadersToRequest(RequestBodyJsonIn, HttpWebRequest, Headers);

        ConnectionParameterSet.TestField("Submission Api URL");
        HttpWebRequest.SetRequestUri(ConnectionParameterSet."Submission Api URL" + UrlFunction);
        SetHttpHeaders(HttpRequestType, HttpWebRequest, Headers);

        if not IsAuthenticationTokenRefreshRequest then
            Headers.Add('Authorization', StrSubstNo(BearerTokenLbl, Get_SIGNDE_Submission_JwtToken(ConnectionParameterSet)));

        Client.Send(HttpWebRequest, HttpWebResponse);
        if not HttpWebResponse.Content.ReadAs(ResponseText) then
            ResponseText := '';

        if not HttpWebResponse.IsSuccessStatusCode then
            Error(UnsuccessfullResponseErr, HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, ResponseText);
    end;

    [TryFunction]
    local procedure SendRequest_SIGNDE_Submission(RequestBodyJsonIn: JsonObject; var ResponseInStream: InStream; ConnectionParameterSet: Record "NPR DE Audit Setup"; HttpRequestType: Enum "Http Request Type"; UrlFunction: Text; IsAuthenticationTokenRefreshRequest: Boolean)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        ResponseText: Text;
    begin
        Clear(ResponseInStream);
        CheckHttpClientRequestsAllowed();

        if HttpRequestType <> Enum::"Http Request Type"::GET then
            AddRequestBodyAndHeadersToRequest(RequestBodyJsonIn, HttpWebRequest, Headers);

        ConnectionParameterSet.TestField("Submission Api URL");
        HttpWebRequest.SetRequestUri(ConnectionParameterSet."Submission Api URL" + UrlFunction);
        SetHttpHeaders(HttpRequestType, HttpWebRequest, Headers);

        if not IsAuthenticationTokenRefreshRequest then
            Headers.Add('Authorization', StrSubstNo(BearerTokenLbl, Get_SIGNDE_Submission_JwtToken(ConnectionParameterSet)));

        Client.Send(HttpWebRequest, HttpWebResponse);
        if not HttpWebResponse.Content.ReadAs(ResponseInStream) then
            Clear(ResponseInStream);

        ResponseInStream.ReadText(ResponseText);

        if not HttpWebResponse.IsSuccessStatusCode then
            Error(UnsuccessfullResponseErr, HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, ResponseText);
    end;

    local procedure Get_SIGNDE_Submission_JwtToken(ConnectionParameters: Record "NPR DE Audit Setup"): Text
    var
        FiskalyJWT: Codeunit "NPR FiskalyJWT";
        RefreshTokenJson: JsonObject;
        JWTResponseJson: JsonToken;
        AccessTokenRefreshErr: Label 'Error while trying to get authentication token from the server.\%1', Comment = '%1 - Last Error Text';
        AccessToken: Text;
        JWTResponseText: Text;
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
        if Refresh_SIGNDE_Submission_JwtToken(RefreshTokenJson, JWTResponseText, ConnectionParameters) then begin
            JWTResponseJson.ReadFrom(JWTResponseText);
            FiskalyJWT.SetJWT(ConnectionParameters.SystemId, JWTResponseJson, AccessToken);
            exit(AccessToken);
        end else
            Error(AccessTokenRefreshErr, StrSubstNo(ErrorDetailsTxt, GetLastErrorText()));
    end;

    local procedure Refresh_SIGNDE_Submission_JwtToken(RefreshTokenJson: JsonObject; var JWTResponseText: Text; ConnectionParameterSet: Record "NPR DE Audit Setup"): Boolean
    begin
        exit(SendRequest_SIGNDE_Submission(RefreshTokenJson, JWTResponseText, ConnectionParameterSet, Enum::"Http Request Type"::POST, '/auth', true));
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

    local procedure SetHttpHeaders(HttpRequestType: Enum "Http Request Type"; var HttpWebRequest: HttpRequestMessage; var Headers: HttpHeaders)
    begin
        HttpWebRequest.Method(Format(HttpRequestType));
        HttpWebRequest.GetHeaders(Headers);
        Headers.Add('Accept', 'application/json');
        Headers.Add('User-Agent', 'Dynamics 365');
    end;
    #endregion

    #region Procedures/Helper Functions
    local procedure ConvertToDate(DateAsText: Text): Date
    var
        Date: Date;
        Day: Integer;
        Month: Integer;
        Year: Integer;
        DateSplit: List of [Text];
    begin
        // according to documentation string for date is in format DD.MM.YYYY
        DateSplit := DateAsText.Split('.');
        Evaluate(Day, DateSplit.Get(1));
        Evaluate(Month, DateSplit.Get(2));
        Evaluate(Year, DateSplit.Get(3));
        Date := DMY2Date(Day, Month, Year);
        exit(Date);
    end;

    local procedure ConvertToDateTime(DateTimeAsText: Text): DateTime
    var
        DateTime: DateTime;
    begin
        Evaluate(DateTime, DateTimeAsText, 9);
        exit(DateTime);
    end;

    internal procedure CheckIsValueAccordingToAllowedPattern(Value: Text; Pattern: Text)
    var
        ValueErr: Label '%1 is not according to pattern %2.', Comment = '%1 - value to check %2 - allowed pattern value';
    begin
        if not IsValueAccordingToAllowedPattern(Value, Pattern) then
            Error(ValueErr, Value, Pattern);
    end;

    internal procedure IsValueAccordingToAllowedPattern(Value: Text; Pattern: Text): Boolean
    var
#IF BC17
        RegEx: Codeunit DotNet_Regex;
#ELSE
        Regex: Codeunit Regex;
#ENDIF
    begin
        exit(RegEx.IsMatch(Value, Pattern));
    end;

    local procedure CheckIsGUIDAccordingToUUIDv4Standard(GUIDToCheck: Guid)
    var
#IF BC17
        RegEx: Codeunit DotNet_Regex;
#ELSE
        Regex: Codeunit Regex;
#ENDIF
        UUIDv4StandardErr: Label 'GUID %1 is not according to UUIDv4 standard pattern.', Comment = '%1 - GUID value';
        UUIDv4StandardPatternLbl: Label '^[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}$', Locked = true;
        GUIDToCheckAsText: Text;
    begin
        GUIDToCheckAsText := Format(GUIDToCheck, 0, 4).ToLower();
        if not Regex.IsMatch(GUIDToCheckAsText, UUIDv4StandardPatternLbl) then
            Error(UUIDv4StandardErr, GUIDToCheck);
    end;
    #endregion

    #region DE Fiskaly Communication Test Event Publishers

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForCreateTSS(var DETSS: Record "NPR DE TSS"; RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; DEAuditSetup: Record "NPR DE Audit Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendHttpRequestForAuthenticateAdmin(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForUpdateTSS_State(var DETSS: Record "NPR DE TSS"; NewState: Enum "NPR DE TSS State"; RequestBody: JsonObject; ResponseJson: JsonToken; UpdateBCInfo: Boolean; DEAuditSetup: Record "NPR DE Audit Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForUpdateAdminPin(var DETSS: Record "NPR DE TSS"; DESecretMgt: Codeunit "NPR DE Secret Mgt."; NewAdminPIN: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForCreateClient(var DEPOSUnitAuxInfo: Record "NPR DE POS Unit Aux. Info"; DETSS: Record "NPR DE TSS"; RequestBody: JsonObject; ResponseJson: JsonToken; DEAuditSetup: Record "NPR DE Audit Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForSendTransaction(var DeAuditAux: Record "NPR DE POS Audit Log Aux. Info"; RequestBody: JsonObject; ResponseJson: JsonToken; ConnectionParameters: Record "NPR DE Audit Setup"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForGetTSSClientList(ResponseJson: JsonToken; DETSS: Record "NPR DE TSS"; var PosUnitAuxDE: Record "NPR DE POS Unit Aux. Info"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForUpsertTaxpayer(var ConnectionParameterSet: Record "NPR DE Audit Setup"; RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForRetrieveTaxpayer(var ConnectionParameterSet: Record "NPR DE Audit Setup"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForUpsertEstablishment(var DEEstablishment: Record "NPR DE Establishment"; RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForRetrieveEstablishment(var DEEstablishment: Record "NPR DE Establishment"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForUpsertClientAdditionalData(var DETSSClient: Record "NPR DE POS Unit Aux. Info"; RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForRetrieveClientAdditionalData(var DETSSClient: Record "NPR DE POS Unit Aux. Info"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForCreateSubmission(var DESubmission: Record "NPR DE Submission"; RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForRetrieveSubmission(var DESubmission: Record "NPR DE Submission"; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForTriggerSubmissionTransmission(var DESubmission: Record "NPR DE Submission"; RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForCancelSubmissionTransmission(var DESubmission: Record "NPR DE Submission"; RequestBodyJsonIn: JsonObject; var ResponseJsonOut: JsonToken; var IsHandled: Boolean)
    begin
    end;
    #endregion DE Fiskaly Communication Test Event Publishers

    var
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";
        BearerTokenLbl: Label 'Bearer %1', Comment = '%1 - JWT Token Value', Locked = true;
        ErrorDetailsTxt: Label 'Error details:\%1', Comment = '%1 - details of the error returned by the server';
        UnsuccessfullResponseErr: Label '%1: %2\%3', Comment = '%1 - Http Status Code, %2 - Reason Code, %3 - Http Response Text', Locked = true;
}