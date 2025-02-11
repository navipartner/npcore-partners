codeunit 6184937 "NPR ES Fiskaly Communication"
{
    Access = Internal;

    var
        ESSecretMgt: Codeunit "NPR ES Secret Mgt.";

    #region JWT Token
    local procedure GetJWT(ESOrganization: Record "NPR ES Organization"): Text
    var
        ESFiskalyJWT: Codeunit "NPR ES Fiskaly JWT";
        JWTResponseJson: JsonToken;
        AccessToken: Text;
        RefreshToken: Text;
    begin
        ESOrganization.TestField(SystemId);
        if ESFiskalyJWT.GetToken(ESOrganization.SystemId, AccessToken, RefreshToken) then
            exit(AccessToken);

        JWTResponseJson := RetrieveAccessToken(ESOrganization, RefreshToken);
        ESFiskalyJWT.SetToken(ESOrganization.SystemId, JWTResponseJson, AccessToken);
        exit(AccessToken);
    end;

    local procedure RetrieveAccessToken(ESOrganization: Record "NPR ES Organization"; RefreshToken: Text) JsonResponse: JsonToken
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        RequestMessage: HttpRequestMessage;
        RetrieveAccessTokenErr: Label 'Retrieve access token with Fiskaly failed.';
        RetrieveAccessTokenLbl: Label 'auth', Locked = true;
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ESFiscalizationSetup.GetWithCheck();
        CheckRetrieveAccessTokenCredentials(ESOrganization);

        Url := CreateUrl(ESFiscalizationSetup, RetrieveAccessTokenLbl);
        JsonBody := CreateJSONBodyForRetrieveAccessToken(ESOrganization, RefreshToken);
        PrepareHttpRequest(ESOrganization, false, RequestMessage, JsonBody, Url, Enum::"Http Request Type"::POST);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', RetrieveAccessTokenErr, GetLastErrorText());

        JsonResponse.ReadFrom(ResponseText);
    end;

    local procedure CheckRetrieveAccessTokenCredentials(ESOrganization: Record "NPR ES Organization")
    begin
        CheckIsAPIKeyAssigned(ESOrganization);
        CheckIsAPISecretNameAssigned(ESOrganization);
    end;

    local procedure CheckIsAPIKeyAssigned(ESOrganization: Record "NPR ES Organization")
    var
        FONParticipantIdNotAssignedErr: Label 'API Key must be assigned on %1 %2 first.', Comment = '%1 - AT Organization table caption, %2 - AT Organization Code value';
    begin
        if not ESSecretMgt.HasSecretKey(ESOrganization.GetAPIKeyName()) then
            Error(FONParticipantIdNotAssignedErr, ESOrganization.TableCaption, ESOrganization.Code);
    end;

    local procedure CheckIsAPISecretNameAssigned(ESOrganization: Record "NPR ES Organization")
    var
        FONUserIdNotAssignedErr: Label 'API Secret must be assigned to %1 %2 first.', Comment = '%1 - AT Organization table caption, %2 - AT Organization Code value';
    begin
        if not ESSecretMgt.HasSecretKey(ESOrganization.GetAPISecretName()) then
            Error(FONUserIdNotAssignedErr, ESOrganization.TableCaption, ESOrganization.Code);
    end;
    #endregion

    #region Taxpayer management
    internal procedure CreateTaxpayer(var ESOrganization: Record "NPR ES Organization")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        CreateTaxpayerErr: Label 'Create taxpayer failed.';
        CreateTaxpayerLbl: Label 'taxpayer', Locked = true;
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ESOrganization.TestField(SystemId);
        ESOrganization.TestField(Disabled, false);
        ESOrganization.CheckIsTerritoryPopulated();
        ESOrganization.CheckIsThereAnyRelatedSigner();
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, CreateTaxpayerLbl);
        JsonBody := CreateJSONBodyForCreateTaxpayer(ESOrganization);
        PrepareHttpRequest(ESOrganization, true, RequestMessage, JsonBody, Url, Enum::"Http Request Type"::PUT);

        OnBeforeSendHttpRequestForCreateTaxpayer(RequestMessage, ResponseText, ESOrganization, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', CreateTaxpayerErr, GetLastErrorText());

        PopulateOrganization(ESOrganization, ResponseText);
        Commit();
        RetrieveSoftware(ESOrganization);
    end;

    internal procedure RetrieveTaxpayer(var ESOrganization: Record "NPR ES Organization")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        RetrieveTaxpayerErr: Label 'Retrieve taxpayer failed.';
        RetrieveTaxpayerLbl: Label 'taxpayer', Locked = true;
        ResponseText: Text;
        Url: Text;
    begin
        ESOrganization.TestField(SystemId);
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, RetrieveTaxpayerLbl);
        PrepareHttpRequest(ESOrganization, true, RequestMessage, '', Url, Enum::"Http Request Type"::GET);

        OnBeforeSendHttpRequestForRetrieveTaxpayer(RequestMessage, ResponseText, ESOrganization, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', RetrieveTaxpayerErr, GetLastErrorText());

        PopulateOrganization(ESOrganization, ResponseText);
        Commit();
        RetrieveSoftware(ESOrganization);
    end;
    #endregion

    #region Signer management
    internal procedure CreateSigner(var ESSigner: Record "NPR ES Signer")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESOrganization: Record "NPR ES Organization";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        CreateSignerErr: Label 'Create signer failed.';
        CreateSignerLbl: Label 'signers/%1', Locked = true, Comment = '%1 - Signer Id value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ESSigner.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ESSigner.SystemId);
        ESSigner.TestField("ES Organization Code");
        ESSigner.TestField(State, ESSigner.State::" ");
        ESSigner.IsThereAnyOtherActiveSignerForThisOrganization();
        ESOrganization.GetWithCheck(ESSigner."ES Organization Code");
        ESOrganization.TestField(Disabled, false);
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, StrSubstNo(CreateSignerLbl, Format(ESSigner.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForCreateSigner(ESSigner);
        PrepareHttpRequest(ESOrganization, true, RequestMessage, JsonBody, Url, Enum::"Http Request Type"::PUT);

        OnBeforeSendHttpRequestForCreateSigner(RequestMessage, ResponseText, ESSigner, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', CreateSignerErr, GetLastErrorText());

        PopulateSigner(ESSigner, ResponseText);
    end;

    internal procedure UpdateSigner(var ESSigner: Record "NPR ES Signer"; NewState: Enum "NPR ES Signer State")
    var
        ESClient: Record "NPR ES Client";
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESOrganization: Record "NPR ES Organization";
        ConfirmManagement: Codeunit "Confirm Management";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        CannotUpdateToStateDueToRelatedRecordErr: Label 'You cannot set the %1 to %2, since there is at least one related %3 which %4 has to be set to %5.', Comment = '%1 - ES Signer State field caption, %2 - New State value, %3 - ES Client table caption, %4 - ES Client State field value, %5 - ES Client State DISABLED value';
        UpdateConfirmQst: Label 'Are you sure that you want to set the %1 to %2 since this it is irreversible?', Comment = '%1 - State field caption, %2 - New State value';
        UpdateSignerErr: Label 'Update signer failed.';
        UpdateSignerLbl: Label 'signers/%1', Locked = true, Comment = '%1 - Signer Id value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ESSigner.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ESSigner.SystemId);
        ESSigner.TestField("ES Organization Code");

        if NewState = NewState::DISABLED then begin
            ESSigner.TestField(State, ESSigner.State::ENABLED);
            if not ConfirmManagement.GetResponse(StrSubstNo(UpdateConfirmQst, ESSigner.FieldCaption(State), NewState), false) then
                Error('');

            ESClient.SetRange("ES Signer Code", ESSigner.Code);
            ESClient.SetFilter(State, '<>%1', ESClient.State::DISABLED);
            if not ESClient.IsEmpty() then
                Error(CannotUpdateToStateDueToRelatedRecordErr, ESSigner.FieldCaption(State), NewState, ESClient.TableCaption(), ESClient.FieldCaption(State), ESClient.State::DISABLED);
        end;

        ESOrganization.GetWithCheck(ESSigner."ES Organization Code");
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, StrSubstNo(UpdateSignerLbl, Format(ESSigner.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForUpdateSigner(ESSigner, NewState);
        PrepareHttpRequest(ESOrganization, true, RequestMessage, JsonBody, Url, Enum::"Http Request Type"::PATCH);

        OnBeforeSendHttpRequestForUpdateSigner(RequestMessage, ResponseText, ESSigner, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', UpdateSignerErr, GetLastErrorText());

        PopulateSigner(ESSigner, ResponseText);
    end;

    internal procedure RetrieveSigner(var ESSigner: Record "NPR ES Signer")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESOrganization: Record "NPR ES Organization";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        RetrieveSignerErr: Label 'Retrieve signer failed.';
        RetrieveSignerLbl: Label 'signers/%1', Locked = true, Comment = '%1 - Signer Id value';
        ResponseText: Text;
        Url: Text;
    begin
        ESSigner.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ESSigner.SystemId);
        ESSigner.TestField("ES Organization Code");
        ESSigner.IsThereAnyOtherActiveSignerForThisOrganization();
        ESOrganization.GetWithCheck(ESSigner."ES Organization Code");
        ESOrganization.TestField(Disabled, false);
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, StrSubstNo(RetrieveSignerLbl, Format(ESSigner.SystemId, 0, 4).ToLower()));
        PrepareHttpRequest(ESOrganization, true, RequestMessage, '', Url, Enum::"Http Request Type"::GET);

        OnBeforeSendHttpRequestForRetrieveSigner(RequestMessage, ResponseText, ESSigner, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', RetrieveSignerErr, GetLastErrorText());

        PopulateSigner(ESSigner, ResponseText);
    end;

    local procedure InsertSigner(var ESSigner: Record "NPR ES Signer"; ESOrganizationCode: Code[20]; SignerId: Guid)
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESOrganization: Record "NPR ES Organization";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        RetrieveSignerErr: Label 'Retrieve signer failed.';
        RetrieveSignerLbl: Label 'signers/%1', Locked = true, Comment = '%1 - Signer Id value';
        ResponseText: Text;
        Url: Text;
    begin
        CheckIsGUIDAccordingToUUIDv4Standard(SignerId);
        ESOrganization.GetWithCheck(ESOrganizationCode);
        ESOrganization.TestField(Disabled, false);
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, StrSubstNo(RetrieveSignerLbl, Format(SignerId, 0, 4).ToLower()));
        PrepareHttpRequest(ESOrganization, true, RequestMessage, '', Url, Enum::"Http Request Type"::GET);

        OnBeforeSendHttpRequestForInsertSigner(RequestMessage, ResponseText, ESSigner, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', RetrieveSignerErr, GetLastErrorText());

        InsertSigner(ESSigner, ESOrganizationCode, SignerId, ResponseText);
    end;

    internal procedure ListSigners()
    var
        ESOrganization: Record "NPR ES Organization";
        Window: Dialog;
        RetrievingDataLbl: Label 'Retrieving data from Fiskaly...';
    begin
        ESOrganization.SetRange("Taxpayer Created", true);
        ESOrganization.SetRange(Disabled, false);
        if ESOrganization.IsEmpty() then
            exit;

        Window.Open(RetrievingDataLbl);

        ESOrganization.FindSet();

        repeat
            ListSigners(ESOrganization);
        until ESOrganization.Next() = 0;

        Window.Close();
    end;

    local procedure ListSigners(ESOrganization: Record "NPR ES Organization")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        RequestMessage: HttpRequestMessage;
        ListSignersErr: Label 'List signers failed.';
        ListSignersLbl: Label 'signers', Locked = true;
        ResponseText: Text;
        Url: Text;
    begin
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, ListSignersLbl);
        PrepareHttpRequest(ESOrganization, true, RequestMessage, '', Url, Enum::"Http Request Type"::GET);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', ListSignersErr, GetLastErrorText());

        PopulateSignerForListSigners(ResponseText, ESOrganization.Code);
    end;
    #endregion

    #region Client management
    internal procedure CreateClient(var ESClient: Record "NPR ES Client")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESOrganization: Record "NPR ES Organization";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        CreateClientErr: Label 'Create signer failed.';
        CreateClientLbl: Label 'clients/%1', Locked = true, Comment = '%1 - Client Id value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ESClient.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ESClient.SystemId);
        ESClient.TestField("ES Organization Code");
        ESClient.TestField(State, ESClient.State::" ");
        ESOrganization.GetWithCheck(ESClient."ES Organization Code");
        ESOrganization.TestField(Disabled, false);
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, StrSubstNo(CreateClientLbl, Format(ESClient.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForCreateClient(ESClient);
        PrepareHttpRequest(ESOrganization, true, RequestMessage, JsonBody, Url, Enum::"Http Request Type"::PUT);

        OnBeforeSendHttpRequestForCreateClient(RequestMessage, ResponseText, ESClient, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', CreateClientErr, GetLastErrorText());

        PopulateClient(ESClient, ResponseText);
    end;

    internal procedure UpdateClient(var ESClient: Record "NPR ES Client"; NewState: Enum "NPR ES Client State")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESOrganization: Record "NPR ES Organization";
        ConfirmManagement: Codeunit "Confirm Management";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        UpdateClientErr: Label 'Update client failed.';
        UpdateClientLbl: Label 'clients/%1', Locked = true, Comment = '%1 - Client Id value';
        UpdateConfirmQst: Label 'Are you sure that you want to set the %1 to %2 since this it is irreversible?', Comment = '%1 - State field caption, %2 - New State value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ESClient.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ESClient.SystemId);
        ESClient.TestField("ES Organization Code");

        if NewState = NewState::DISABLED then begin
            ESClient.TestField(State, ESClient.State::ENABLED);
            if not ConfirmManagement.GetResponse(StrSubstNo(UpdateConfirmQst, ESClient.FieldCaption(State), NewState), false) then
                Error('');
        end;

        ESOrganization.GetWithCheck(ESClient."ES Organization Code");
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, StrSubstNo(UpdateClientLbl, Format(ESClient.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForUpdateClient(ESClient, NewState);
        PrepareHttpRequest(ESOrganization, true, RequestMessage, JsonBody, Url, Enum::"Http Request Type"::PATCH);

        OnBeforeSendHttpRequestForUpdateClient(RequestMessage, ResponseText, ESClient, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', UpdateClientErr, GetLastErrorText());

        PopulateClient(ESClient, ResponseText);
    end;

    internal procedure RetrieveClient(var ESClient: Record "NPR ES Client")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESOrganization: Record "NPR ES Organization";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        RetrieveClientErr: Label 'Retrieve client failed.';
        RetrieveClientLbl: Label 'clients/%1', Locked = true, Comment = '%1 - Client Id value';
        ResponseText: Text;
        Url: Text;
    begin
        ESClient.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ESClient.SystemId);
        ESClient.TestField("ES Organization Code");
        ESOrganization.GetWithCheck(ESClient."ES Organization Code");
        ESOrganization.TestField(Disabled, false);
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, StrSubstNo(RetrieveClientLbl, Format(ESClient.SystemId, 0, 4).ToLower()));
        PrepareHttpRequest(ESOrganization, true, RequestMessage, '', Url, Enum::"Http Request Type"::GET);

        OnBeforeSendHttpRequestForRetrieveClient(RequestMessage, ResponseText, ESClient, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', RetrieveClientErr, GetLastErrorText());

        PopulateClient(ESClient, ResponseText);
    end;

    internal procedure ListClients()
    var
        ESOrganization: Record "NPR ES Organization";
        Window: Dialog;
        RetrievingDataLbl: Label 'Retrieving data from Fiskaly...';
    begin
        ESOrganization.SetRange("Taxpayer Created", true);
        ESOrganization.SetRange(Disabled, false);
        if ESOrganization.IsEmpty() then
            exit;

        Window.Open(RetrievingDataLbl);

        ESOrganization.FindSet();

        repeat
            ListClients(ESOrganization);
        until ESOrganization.Next() = 0;

        Window.Close();
    end;

    local procedure ListClients(ESOrganization: Record "NPR ES Organization")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        RequestMessage: HttpRequestMessage;
        ListClientsErr: Label 'List clients failed.';
        ListClientsLbl: Label 'clients', Locked = true;
        ResponseText: Text;
        Url: Text;
    begin
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, ListClientsLbl);
        PrepareHttpRequest(ESOrganization, true, RequestMessage, '', Url, Enum::"Http Request Type"::GET);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', ListClientsErr, GetLastErrorText());

        PopulateClientForListClients(ResponseText, ESOrganization.Code);
    end;
    #endregion

    #region Software management
    internal procedure RetrieveSoftware(var ESOrganization: Record "NPR ES Organization")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        RetrieveSoftwareErr: Label 'Retrieve software failed.';
        RetrieveSoftwareLbl: Label 'software', Locked = true;
        ResponseText: Text;
        Url: Text;
    begin
        ESOrganization.TestField(SystemId);
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, RetrieveSoftwareLbl);
        PrepareHttpRequest(ESOrganization, true, RequestMessage, '', Url, Enum::"Http Request Type"::GET);

        OnBeforeSendHttpRequestForRetrieveSoftware(RequestMessage, ResponseText, ESOrganization, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', RetrieveSoftwareErr, GetLastErrorText());

        PopulateOrganizationForRetrieveSoftware(ESOrganization, ResponseText);
    end;
    #endregion

    #region Invoice Management
    internal procedure CreateInvoice(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info")
    var
        ESClient: Record "NPR ES Client";
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESOrganization: Record "NPR ES Organization";
        ESSigner: Record "NPR ES Signer";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        CreateInvoiceErr: Label 'Create invoice failed.';
        CreateInvoiceLbl: Label 'clients/%1/invoices/%2', Locked = true, Comment = '%1 - Client Id value, %2 - Invoice Id value';
        UseRetrieveInvoiceErr: Label '%1 %2 is already assigned on Fiskaly''s end. Therefore you should use Retrieve Invoice in order to populate missing fields.', Comment = '%1 - Invoice Number field caption, %2 - Invoice Number field value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ESPOSAuditLogAuxInfo.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ESPOSAuditLogAuxInfo.SystemId);
        ESPOSAuditLogAuxInfo.TestField("Invoice State", ESPOSAuditLogAuxInfo."Invoice State"::" ");
        if ESPOSAuditLogAuxInfo."Invoice No." <> '' then
            Error(UseRetrieveInvoiceErr, ESPOSAuditLogAuxInfo.FieldCaption("Invoice No."), ESPOSAuditLogAuxInfo."Invoice No.");

        ESPOSAuditLogAuxInfo.TestField("POS Entry No.");
        ESPOSAuditLogAuxInfo.TestField("ES Organization Code");
        ESPOSAuditLogAuxInfo.TestField("ES Signer Code");
        ESPOSAuditLogAuxInfo.TestField("ES Client Id");
        CheckIsGUIDAccordingToUUIDv4Standard(ESPOSAuditLogAuxInfo."ES Client Id");
        ESClient.GetWithCheck(ESPOSAuditLogAuxInfo."POS Unit No.");
        ESSigner.GetWithCheck(ESPOSAuditLogAuxInfo."ES Signer Code");
        ESOrganization.GetWithCheck(ESPOSAuditLogAuxInfo."ES Organization Code");
        ESOrganization.TestField(Disabled, false);
        ESFiscalizationSetup.GetWithCheck();
        ESFiscalizationSetup.TestField("Invoice Description");

        SetInvoiceFieldsOnESPOSAuditLogAuxInfo(ESPOSAuditLogAuxInfo, ESClient);

        Url := CreateUrl(ESFiscalizationSetup, StrSubstNo(CreateInvoiceLbl, Format(ESPOSAuditLogAuxInfo."ES Client Id", 0, 4).ToLower(), Format(ESPOSAuditLogAuxInfo.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForCreateInvoice(ESPOSAuditLogAuxInfo, ESFiscalizationSetup."Invoice Description");
        PrepareHttpRequest(ESOrganization, true, RequestMessage, JsonBody, Url, Enum::"Http Request Type"::PUT);

        OnBeforeSendHttpRequestForCreateInvoice(RequestMessage, ResponseText, ESPOSAuditLogAuxInfo, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', CreateInvoiceErr, GetLastErrorText());

        PopulateESPOSAuditLogAuxInfoForCreateInvoice(ESPOSAuditLogAuxInfo, ResponseText);
        if ESPOSAuditLogAuxInfo."Invoice Registration State" = ESPOSAuditLogAuxInfo."Invoice Registration State"::PENDING then begin
            Sleep(2000);
            RetrieveInvoice(ESPOSAuditLogAuxInfo);
        end;
    end;

    internal procedure RetrieveInvoice(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info")
    var
        ESClient: Record "NPR ES Client";
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESOrganization: Record "NPR ES Organization";
        ESSigner: Record "NPR ES Signer";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        RetrieveInvoiceErr: Label 'Retrieve invoice failed.';
        RetrieveInvoiceLbl: Label 'clients/%1/invoices/%2', Locked = true, Comment = '%1 - Client Id value, %2 - Invoice Id value';
        ResponseText: Text;
        Url: Text;
    begin
        ESPOSAuditLogAuxInfo.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ESPOSAuditLogAuxInfo.SystemId);
        ESPOSAuditLogAuxInfo.TestField("Invoice No.");
        ESPOSAuditLogAuxInfo.TestField("POS Entry No.");
        ESPOSAuditLogAuxInfo.TestField("ES Organization Code");
        ESPOSAuditLogAuxInfo.TestField("ES Signer Code");
        ESPOSAuditLogAuxInfo.TestField("ES Client Id");
        CheckIsGUIDAccordingToUUIDv4Standard(ESPOSAuditLogAuxInfo."ES Client Id");
        ESClient.GetWithCheck(ESPOSAuditLogAuxInfo."POS Unit No.");
        ESSigner.GetWithCheck(ESPOSAuditLogAuxInfo."ES Signer Code");
        ESOrganization.GetWithCheck(ESPOSAuditLogAuxInfo."ES Organization Code");
        ESOrganization.TestField(Disabled, false);
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, StrSubstNo(RetrieveInvoiceLbl, Format(ESPOSAuditLogAuxInfo."ES Client Id", 0, 4).ToLower(), Format(ESPOSAuditLogAuxInfo.SystemId, 0, 4).ToLower()));
        PrepareHttpRequest(ESOrganization, true, RequestMessage, '', Url, Enum::"Http Request Type"::GET);

        OnBeforeSendHttpRequestForRetrieveInvoice(RequestMessage, ResponseText, ESPOSAuditLogAuxInfo, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', RetrieveInvoiceErr, GetLastErrorText());

        PopulateESPOSAuditLogAuxInfo(ESPOSAuditLogAuxInfo, ResponseText);
    end;

    internal procedure UpdateInvoiceMetadata(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info")
    var
        ESClient: Record "NPR ES Client";
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESOrganization: Record "NPR ES Organization";
        ESSigner: Record "NPR ES Signer";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        UpdateInvoiceMetadataErr: Label 'Update invoice metadata failed.';
        UpdateInvoiceMetadataLbl: Label 'clients/%1/invoices/%2', Locked = true, Comment = '%1 - Client Id value, %2 - Invoice Id value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ESPOSAuditLogAuxInfo.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ESPOSAuditLogAuxInfo.SystemId);
        ESPOSAuditLogAuxInfo.TestField("POS Entry No.");
        ESPOSAuditLogAuxInfo.TestField("ES Organization Code");
        ESPOSAuditLogAuxInfo.TestField("ES Signer Code");
        ESPOSAuditLogAuxInfo.TestField("ES Client Id");
        CheckIsGUIDAccordingToUUIDv4Standard(ESPOSAuditLogAuxInfo."ES Client Id");
        ESClient.GetWithCheck(ESPOSAuditLogAuxInfo."POS Unit No.");
        ESSigner.GetWithCheck(ESPOSAuditLogAuxInfo."ES Signer Code");
        ESOrganization.GetWithCheck(ESPOSAuditLogAuxInfo."ES Organization Code");
        ESOrganization.TestField(Disabled, false);
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, StrSubstNo(UpdateInvoiceMetadataLbl, Format(ESPOSAuditLogAuxInfo."ES Client Id", 0, 4).ToLower(), Format(ESPOSAuditLogAuxInfo.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForUpdateInvoiceMetadata(ESPOSAuditLogAuxInfo);
        PrepareHttpRequest(ESOrganization, true, RequestMessage, JsonBody, Url, Enum::"Http Request Type"::PATCH);

        OnBeforeSendHttpRequestForUpdateInvoiceMetadata(RequestMessage, ResponseText, ESPOSAuditLogAuxInfo, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', UpdateInvoiceMetadataErr, GetLastErrorText());
    end;

    internal procedure CancelInvoice(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info")
    var
        ESClient: Record "NPR ES Client";
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESOrganization: Record "NPR ES Organization";
        ESSigner: Record "NPR ES Signer";
        ConfirmManagement: Codeunit "Confirm Management";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        CancelInvoiceErr: Label 'Cancel invoice failed.';
        CancelInvoiceLbl: Label 'clients/%1/invoices/%2', Locked = true, Comment = '%1 - Client Id value, %2 - Invoice Id value';
        CancelConfirmQst: Label 'Are you sure that you want to cancel this invoice since it is irreversible?';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ESPOSAuditLogAuxInfo.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ESPOSAuditLogAuxInfo.SystemId);
        ESPOSAuditLogAuxInfo.TestField("Invoice State", ESPOSAuditLogAuxInfo."Invoice State"::ISSUED);

        if not ConfirmManagement.GetResponse(CancelConfirmQst, false) then
            Error('');

        ESPOSAuditLogAuxInfo.TestField("POS Entry No.");
        ESPOSAuditLogAuxInfo.TestField("ES Organization Code");
        ESPOSAuditLogAuxInfo.TestField("ES Signer Code");
        ESPOSAuditLogAuxInfo.TestField("ES Client Id");
        CheckIsGUIDAccordingToUUIDv4Standard(ESPOSAuditLogAuxInfo."ES Client Id");
        ESClient.GetWithCheck(ESPOSAuditLogAuxInfo."POS Unit No.");
        ESSigner.GetWithCheck(ESPOSAuditLogAuxInfo."ES Signer Code");
        ESOrganization.GetWithCheck(ESPOSAuditLogAuxInfo."ES Organization Code");
        ESOrganization.TestField(Disabled, false);
        ESFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ESFiscalizationSetup, StrSubstNo(CancelInvoiceLbl, Format(ESPOSAuditLogAuxInfo."ES Client Id", 0, 4).ToLower(), Format(ESPOSAuditLogAuxInfo.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForCancelInvoice(ESPOSAuditLogAuxInfo);
        PrepareHttpRequest(ESOrganization, true, RequestMessage, JsonBody, Url, Enum::"Http Request Type"::PATCH);

        OnBeforeSendHttpRequestForCancelInvoice(RequestMessage, ResponseText, ESPOSAuditLogAuxInfo, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', CancelInvoiceErr, GetLastErrorText());

        PopulateESPOSAuditLogAuxInfo(ESPOSAuditLogAuxInfo, ResponseText);
        if ESPOSAuditLogAuxInfo."Invoice Registration State" = ESPOSAuditLogAuxInfo."Invoice Registration State"::PENDING then begin
            Sleep(2000);
            RetrieveInvoice(ESPOSAuditLogAuxInfo);
        end;
    end;

    local procedure SetInvoiceFieldsOnESPOSAuditLogAuxInfo(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; ESClient: Record "NPR ES Client")
    begin
        SetInvoiceTypeAndRecipientFieldsOnESPOSAuditLogAuxInfo(ESPOSAuditLogAuxInfo);
        SetInvoiceNoSeriesOnESPOSAuditLogAuxInfo(ESPOSAuditLogAuxInfo, ESClient);
        SetInvoiceNoOnESPOSAuditLogAuxInfo(ESPOSAuditLogAuxInfo);
    end;

    local procedure SetInvoiceTypeAndRecipientFieldsOnESPOSAuditLogAuxInfo(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info")
    var
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        ESPOSAuditLogAuxInfoCustomerInformation: Record "NPR ES POS Audit Log Aux. Info";
        ESInvoiceRecipient: Page "NPR ES Invoice Recipient";
        ConfirmManagement: Codeunit "Confirm Management";
        ManuallyComplete: Boolean;
        CompleteInvoiceQst: Label 'Do you want to create complete invoice?';
    begin
        if ESPOSAuditLogAuxInfo."Invoice Type" = ESPOSAuditLogAuxInfo."Invoice Type"::SIMPLIFIED then
            if ConfirmManagement.GetResponse(CompleteInvoiceQst, false) then begin
                ESPOSAuditLogAuxInfo."Invoice Type" := ESPOSAuditLogAuxInfo."Invoice Type"::COMPLETE;
                ManuallyComplete := true;
            end;

        if ESPOSAuditLogAuxInfo."Invoice Type" = ESPOSAuditLogAuxInfo."Invoice Type"::COMPLETE then
            if ManuallyComplete then begin
                POSEntry.Get(ESPOSAuditLogAuxInfo."POS Entry No.");
                if POSEntry."Customer No." <> '' then
                    if Customer.Get(POSEntry."Customer No.") then
                        ESInvoiceRecipient.SetRecipientData(Customer);

                ESInvoiceRecipient.SetManuallyComplete(ManuallyComplete);
                if ESInvoiceRecipient.RunModal() <> Action::OK then
                    if ESInvoiceRecipient.GetCreationAborted() then
                        ESPOSAuditLogAuxInfo."Invoice Type" := ESPOSAuditLogAuxInfo."Invoice Type"::SIMPLIFIED
                    else
                        ESInvoiceRecipient.ThrowMustEnterNecessaryCompleteInvoiceDataError();
            end else
                ESPOSAuditLogAuxInfoCustomerInformation.FindAuditLog(ESPOSAuditLogAuxInfo."Source Document No.");

        case true of
            (ESPOSAuditLogAuxInfo."Invoice Type" = ESPOSAuditLogAuxInfo."Invoice Type"::SIMPLIFIED) and ManuallyComplete:
                exit;
            (ESPOSAuditLogAuxInfo."Invoice Type" = ESPOSAuditLogAuxInfo."Invoice Type"::SIMPLIFIED) and not ManuallyComplete:
                begin
                    if ESPOSAuditLogAuxInfoCustomerInformation.FindAuditLog(ESPOSAuditLogAuxInfo."Source Document No.") then
                        ESPOSAuditLogAuxInfoCustomerInformation.Delete();
                    exit;
                end;
        end;

        SetInvoiceRecipientFieldsOnESPOSAuditLogAuxInfo(ESPOSAuditLogAuxInfo, ESPOSAuditLogAuxInfoCustomerInformation, ESInvoiceRecipient, ManuallyComplete);
    end;

    local procedure SetInvoiceRecipientFieldsOnESPOSAuditLogAuxInfo(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; ESPOSAuditLogAuxInfoCustomerInfo: Record "NPR ES POS Audit Log Aux. Info"; var ESInvoiceRecipient: Page "NPR ES Invoice Recipient"; ManuallyComplete: Boolean)
    var
        ESPOSAuditLogAuxInfoToRefund: Record "NPR ES POS Audit Log Aux. Info";
    begin
        case ESPOSAuditLogAuxInfo."Invoice Type" of
            ESPOSAuditLogAuxInfo."Invoice Type"::COMPLETE:
                SetCompleteInvoiceRecipientFieldsOnESPOSAuditLogAuxInfo(ESPOSAuditLogAuxInfo, ESPOSAuditLogAuxInfoCustomerInfo, ESInvoiceRecipient, ManuallyComplete);
            ESPOSAuditLogAuxInfo."Invoice Type"::CORRECTING:
                begin
                    FindESPOSAuditLogAuxInfoToRefund(ESPOSAuditLogAuxInfo."POS Entry No.", ESPOSAuditLogAuxInfoToRefund);

                    if ESPOSAuditLogAuxInfoToRefund."Invoice Type" = ESPOSAuditLogAuxInfoToRefund."Invoice Type"::COMPLETE then begin
                        ESPOSAuditLogAuxInfo."Recipient Type" := ESPOSAuditLogAuxInfoToRefund."Recipient Type";
                        ESPOSAuditLogAuxInfo."Recipient Legal Name" := ESPOSAuditLogAuxInfoToRefund."Recipient Legal Name";
                        ESPOSAuditLogAuxInfo."Recipient Address" := ESPOSAuditLogAuxInfoToRefund."Recipient Address";
                        ESPOSAuditLogAuxInfo."Recipient Post Code" := ESPOSAuditLogAuxInfoToRefund."Recipient Post Code";
                        ESPOSAuditLogAuxInfo."Recipient VAT Registration No." := ESPOSAuditLogAuxInfoToRefund."Recipient VAT Registration No.";
                        ESPOSAuditLogAuxInfo."Recipient Identification Type" := ESPOSAuditLogAuxInfoToRefund."Recipient Identification Type";
                        ESPOSAuditLogAuxInfo."Recipient Identification No." := ESPOSAuditLogAuxInfoToRefund."Recipient Identification No.";
                        ESPOSAuditLogAuxInfo."Recipient Country/Region Code" := ESPOSAuditLogAuxInfoToRefund."Recipient Country/Region Code";
                    end;
                end;
        end;
    end;

    local procedure SetCompleteInvoiceRecipientFieldsOnESPOSAuditLogAuxInfo(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; ESPOSAuditLogAuxInfoCustomerInfo: Record "NPR ES POS Audit Log Aux. Info"; var ESInvoiceRecipient: Page "NPR ES Invoice Recipient"; ManuallyComplete: Boolean)
    begin
        if ManuallyComplete then begin
            ESPOSAuditLogAuxInfo."Recipient Type" := ESInvoiceRecipient.GetRecipientType();
            ESPOSAuditLogAuxInfo."Recipient Legal Name" := ESInvoiceRecipient.GetRecipientLegalName();
            ESPOSAuditLogAuxInfo."Recipient Address" := ESInvoiceRecipient.GetRecipientAddress();
            ESPOSAuditLogAuxInfo."Recipient Post Code" := ESInvoiceRecipient.GetRecipientPostCode();

            case ESPOSAuditLogAuxInfo."Recipient Type" of
                ESPOSAuditLogAuxInfo."Recipient Type"::National:
                    ESPOSAuditLogAuxInfo."Recipient VAT Registration No." := ESInvoiceRecipient.GetRecipientVATRegistrationNo();
                ESPOSAuditLogAuxInfo."Recipient Type"::International:
                    begin
                        ESPOSAuditLogAuxInfo."Recipient Identification Type" := ESInvoiceRecipient.GetRecipientIdentificationType();
                        ESPOSAuditLogAuxInfo."Recipient Identification No." := ESInvoiceRecipient.GetRecipientIdentificationNo();
                        ESPOSAuditLogAuxInfo."Recipient Country/Region Code" := ESInvoiceRecipient.GetRecipientCountryRegionCode();
                    end;
            end;
        end else begin
            ESPOSAuditLogAuxInfo."Recipient Type" := ESPOSAuditLogAuxInfoCustomerInfo."Recipient Type";
            ESPOSAuditLogAuxInfo."Recipient Legal Name" := ESPOSAuditLogAuxInfoCustomerInfo."Recipient Legal Name";
            ESPOSAuditLogAuxInfo."Recipient Address" := ESPOSAuditLogAuxInfoCustomerInfo."Recipient Address";
            ESPOSAuditLogAuxInfo."Recipient Post Code" := ESPOSAuditLogAuxInfoCustomerInfo."POS Store Code";

            case ESPOSAuditLogAuxInfo."Recipient Type" of
                ESPOSAuditLogAuxInfo."Recipient Type"::National:
                    ESPOSAuditLogAuxInfo."Recipient VAT Registration No." := ESPOSAuditLogAuxInfoCustomerInfo."Recipient VAT Registration No.";
                ESPOSAuditLogAuxInfo."Recipient Type"::International:
                    begin
                        ESPOSAuditLogAuxInfo."Recipient Identification Type" := ESPOSAuditLogAuxInfoCustomerInfo."Recipient Identification Type";
                        ESPOSAuditLogAuxInfo."Recipient Identification No." := ESPOSAuditLogAuxInfoCustomerInfo."Recipient Identification No.";
                        ESPOSAuditLogAuxInfo."Recipient Country/Region Code" := ESPOSAuditLogAuxInfoCustomerInfo."Recipient Country/Region Code";
                    end;
            end;
        end;
    end;

    local procedure SetInvoiceNoSeriesOnESPOSAuditLogAuxInfo(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; ESClient: Record "NPR ES Client")
    begin
        case ESPOSAuditLogAuxInfo."Invoice Type" of
            ESPOSAuditLogAuxInfo."Invoice Type"::COMPLETE:
                ESPOSAuditLogAuxInfo."Invoice No. Series" := ESClient."Complete Invoice No. Series";
            ESPOSAuditLogAuxInfo."Invoice Type"::CORRECTING:
                ESPOSAuditLogAuxInfo."Invoice No. Series" := ESClient."Correction Invoice No. Series";
            else
                ESPOSAuditLogAuxInfo."Invoice No. Series" := ESClient."Invoice No. Series";
        end;
    end;

    local procedure SetInvoiceNoOnESPOSAuditLogAuxInfo(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info")
    var
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
        NoSeries: Codeunit "No. Series";
#else
        NoSeries: Codeunit NoSeriesManagement;
#endif
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
        ESPOSAuditLogAuxInfo."Invoice No." := NoSeries.PeekNextNo(ESPOSAuditLogAuxInfo."Invoice No. Series");
#else
        ESPOSAuditLogAuxInfo."Invoice No." := NoSeries.GetNextNo(ESPOSAuditLogAuxInfo."Invoice No. Series", WorkDate(), false);
#endif
    end;
    #endregion

    #region JSON Fiscal Creators
    local procedure CreateJSONBodyForRetrieveAccessToken(ESOrganization: Record "NPR ES Organization"; RefreshToken: Text) JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStartObject('content');

        if RefreshToken <> '' then
            JsonTextWriter.WriteStringProperty('refresh_token', RefreshToken)
        else begin
            JsonTextWriter.WriteStringProperty('api_key', ESSecretMgt.GetSecretKey(ESOrganization.GetAPIKeyName()));
            JsonTextWriter.WriteStringProperty('api_secret', ESSecretMgt.GetSecretKey(ESOrganization.GetAPISecretName()));
        end;

        JsonTextWriter.WriteEndObject(); // content
        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure CreateJSONBodyForCreateTaxpayer(ESOrganization: Record "NPR ES Organization") JsonBody: Text
    var
        CompanyInformation: Record "Company Information";
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        GetCompanyInformationWithCheck(CompanyInformation);

        JsonTextWriter.WriteStartObject('');

        JsonTextWriter.WriteStartObject('content');

        JsonTextWriter.WriteStartObject('issuer');
        JsonTextWriter.WriteStringProperty('legal_name', CompanyInformation.Name);
        JsonTextWriter.WriteStringProperty('tax_number', CompanyInformation."VAT Registration No.");
        JsonTextWriter.WriteEndObject(); // issuer

        JsonTextWriter.WriteStringProperty('territory', Enum::"NPR ES Taxpayer Territory".Names().Get(Enum::"NPR ES Taxpayer Territory".Ordinals().IndexOf(ESOrganization."Taxpayer Territory".AsInteger())));
        JsonTextWriter.WriteEndObject(); // content

        AddMetadataForCreateTaxpayer(ESOrganization, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure AddMetadataForCreateTaxpayer(ESOrganization: Record "NPR ES Organization"; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartObject('metadata');
        JsonTextWriter.WriteStringProperty('bc_company_name', CompanyName());
        JsonTextWriter.WriteStringProperty('bc_code', ESOrganization.Code);
        JsonTextWriter.WriteStringProperty('bc_description', ESOrganization.Description);
        JsonTextWriter.WriteEndObject();
    end;

    local procedure CreateJSONBodyForCreateSigner(ESSigner: Record "NPR ES Signer") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');

        AddMetadataForSigner(ESSigner, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure CreateJSONBodyForUpdateSigner(ESSigner: Record "NPR ES Signer"; NewState: Enum "NPR ES Signer State") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');

        JsonTextWriter.WriteStartObject('content');
        JsonTextWriter.WriteStringProperty('state', Enum::"NPR ES Signer State".Names().Get(Enum::"NPR ES Signer State".Ordinals().IndexOf(NewState.AsInteger())));
        JsonTextWriter.WriteEndObject(); // content

        AddMetadataForSigner(ESSigner, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure AddMetadataForSigner(ESSigner: Record "NPR ES Signer"; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartObject('metadata');
        JsonTextWriter.WriteStringProperty('bc_company_name', CompanyName());
        JsonTextWriter.WriteStringProperty('bc_code', ESSigner.Code);
        JsonTextWriter.WriteStringProperty('bc_description', ESSigner.Description);
        JsonTextWriter.WriteEndObject();
    end;

    local procedure CreateJSONBodyForCreateClient(ESClient: Record "NPR ES Client") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');

        AddMetadataForClient(ESClient, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure CreateJSONBodyForUpdateClient(ESClient: Record "NPR ES Client"; NewState: Enum "NPR ES Client State") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');

        JsonTextWriter.WriteStartObject('content');
        JsonTextWriter.WriteStringProperty('state', Enum::"NPR ES Client State".Names().Get(Enum::"NPR ES Client State".Ordinals().IndexOf(NewState.AsInteger())));
        JsonTextWriter.WriteEndObject(); // content

        AddMetadataForClient(ESClient, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure AddMetadataForClient(ESClient: Record "NPR ES Client"; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartObject('metadata');
        JsonTextWriter.WriteStringProperty('bc_company_name', CompanyName());
        JsonTextWriter.WriteStringProperty('bc_code', ESClient."POS Unit No.");
        JsonTextWriter.WriteStringProperty('bc_description', ESClient.Description);
        JsonTextWriter.WriteEndObject();
    end;

    local procedure CreateJSONBodyForCreateInvoice(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; InvoiceDescription: Text[250]) JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');

        JsonTextWriter.WriteStartObject('content');

        case ESPOSAuditLogAuxInfo."Invoice Type" of
            ESPOSAuditLogAuxInfo."Invoice Type"::SIMPLIFIED:
                AddSimplifiedInvoiceBodyContentForCreateInvoice(ESPOSAuditLogAuxInfo, InvoiceDescription, JsonTextWriter);
            ESPOSAuditLogAuxInfo."Invoice Type"::COMPLETE:
                AddCompleteInvoiceBodyContentForCreateInvoice(ESPOSAuditLogAuxInfo, InvoiceDescription, JsonTextWriter);
            ESPOSAuditLogAuxInfo."Invoice Type"::CORRECTING:
                AddCorrectingInvoiceBodyContentForCreateInvoice(ESPOSAuditLogAuxInfo, InvoiceDescription, JsonTextWriter);
        end;

        JsonTextWriter.WriteEndObject(); // content

        AddMetadataForInvoice(ESPOSAuditLogAuxInfo, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure AddSimplifiedInvoiceBodyContentForCreateInvoice(ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; InvoiceDescription: Text[250]; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        AddSimplifiedInvoiceBodyJSONObjectForCreateInvoice(ESPOSAuditLogAuxInfo, InvoiceDescription, JsonTextWriter);
    end;

    local procedure AddCompleteInvoiceBodyContentForCreateInvoice(ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; InvoiceDescription: Text[250]; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStringProperty('type', Enum::"NPR ES Invoice Type".Names().Get(Enum::"NPR ES Invoice Type".Ordinals().IndexOf(Enum::"NPR ES Invoice Type"::COMPLETE.AsInteger())));
        JsonTextWriter.WriteStartObject('data');
        AddSimplifiedInvoiceBodyJSONObjectForCreateInvoice(ESPOSAuditLogAuxInfo, InvoiceDescription, JsonTextWriter);
        JsonTextWriter.WriteEndObject(); // data
        AddRecipientsJSONArrayForCreateInvoice(ESPOSAuditLogAuxInfo, JsonTextWriter);
    end;

    local procedure AddCorrectingInvoiceBodyContentForCreateInvoice(ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; InvoiceDescription: Text[250]; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    var
        ESPOSAuditLogAuxInfoToRefund: Record "NPR ES POS Audit Log Aux. Info";
    begin
        JsonTextWriter.WriteStringProperty('type', Enum::"NPR ES Invoice Type".Names().Get(Enum::"NPR ES Invoice Type".Ordinals().IndexOf(Enum::"NPR ES Invoice Type"::CORRECTING.AsInteger())));

        FindESPOSAuditLogAuxInfoToRefund(ESPOSAuditLogAuxInfo."POS Entry No.", ESPOSAuditLogAuxInfoToRefund);
        JsonTextWriter.WriteStringProperty('id', Format(ESPOSAuditLogAuxInfoToRefund.SystemId, 0, 4).ToLower());

        JsonTextWriter.WriteStartObject('invoice');

        case ESPOSAuditLogAuxInfoToRefund."Invoice Type" of
            ESPOSAuditLogAuxInfoToRefund."Invoice Type"::SIMPLIFIED:
                AddSimplifiedInvoiceBodyContentForCreateInvoice(ESPOSAuditLogAuxInfo, InvoiceDescription, JsonTextWriter);
            ESPOSAuditLogAuxInfoToRefund."Invoice Type"::COMPLETE:
                AddCompleteInvoiceBodyContentForCreateInvoice(ESPOSAuditLogAuxInfo, InvoiceDescription, JsonTextWriter);
        end;

        JsonTextWriter.WriteEndObject(); // invoice

        JsonTextWriter.WriteStringProperty('method', Enum::"NPR ES Inv. Correction Method".Names().Get(Enum::"NPR ES Inv. Correction Method".Ordinals().IndexOf(Enum::"NPR ES Inv. Correction Method"::DIFFERENCES.AsInteger())));
        if ESPOSAuditLogAuxInfoToRefund."Invoice Type" = ESPOSAuditLogAuxInfoToRefund."Invoice Type"::COMPLETE then
            JsonTextWriter.WriteStringProperty('code', GetCorrectingInvoiceCode(ESPOSAuditLogAuxInfo."POS Entry No."));
    end;

    local procedure AddSimplifiedInvoiceBodyJSONObjectForCreateInvoice(ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; InvoiceDescription: Text[250]; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStringProperty('type', Enum::"NPR ES Invoice Type".Names().Get(Enum::"NPR ES Invoice Type".Ordinals().IndexOf(Enum::"NPR ES Invoice Type"::SIMPLIFIED.AsInteger())));
        JsonTextWriter.WriteStringProperty('number', ESPOSAuditLogAuxInfo."Invoice No.");
        if ESPOSAuditLogAuxInfo."Invoice Type" in [ESPOSAuditLogAuxInfo."Invoice Type"::COMPLETE, ESPOSAuditLogAuxInfo."Invoice Type"::CORRECTING] then
            JsonTextWriter.WriteStringProperty('series', ESPOSAuditLogAuxInfo."Invoice No. Series");
        JsonTextWriter.WriteStringProperty('text', InvoiceDescription);
        JsonTextWriter.WriteStringProperty('full_amount', Format(ESPOSAuditLogAuxInfo."Amount Incl. Tax", 0, '<Precision,2:2><Standard Format,2>'));

        AddItemsJSONArrayForCreateInvoice(ESPOSAuditLogAuxInfo, JsonTextWriter);
    end;

    local procedure AddItemsJSONArrayForCreateInvoice(ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    var
        Item: Record Item;
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        UnitDiscountExclVAT: Decimal;
        UnitPriceExclVAT: Decimal;
    begin
        JsonTextWriter.WriteStartArray('items');

        POSEntrySalesLine.SetRange("POS Entry No.", ESPOSAuditLogAuxInfo."POS Entry No.");
        POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
        POSEntrySalesLine.SetFilter(Quantity, '<>0');
        if POSEntrySalesLine.FindSet() then
            repeat
                JsonTextWriter.WriteStartObject('');
                JsonTextWriter.WriteStringProperty('text', POSEntrySalesLine.Description);
                JsonTextWriter.WriteStringProperty('quantity', Format(Abs(Round(POSEntrySalesLine.Quantity, 0.01)), 0, '<Precision,0:8><Standard Format,2>'));
                UnitPriceExclVAT := Abs(Round((POSEntrySalesLine."Amount Excl. VAT" + POSEntrySalesLine."Line Discount Amount Excl. VAT") / POSEntrySalesLine.Quantity, 0.01));
                if ESPOSAuditLogAuxInfo."Invoice Type" <> Enum::"NPR ES Invoice Type"::CORRECTING then
                    JsonTextWriter.WriteStringProperty('unit_amount', Format(UnitPriceExclVAT, 0, '<Precision,2:8><Standard Format,2>'))
                else
                    JsonTextWriter.WriteStringProperty('unit_amount', Format(-UnitPriceExclVAT, 0, '<Precision,2:8><Standard Format,2>'));

                JsonTextWriter.WriteStringProperty('full_amount', Format(POSEntrySalesLine."Amount Incl. VAT", 0, '<Precision,2:8><Standard Format,2>'));

                if POSEntrySalesLine."Line Discount Amount Excl. VAT" <> 0 then begin
                    UnitDiscountExclVAT := Abs(Round(POSEntrySalesLine."Line Discount Amount Excl. VAT" / POSEntrySalesLine.Quantity, 0.01));
                    if ESPOSAuditLogAuxInfo."Invoice Type" <> Enum::"NPR ES Invoice Type"::CORRECTING then
                        JsonTextWriter.WriteStringProperty('discount', Format(UnitDiscountExclVAT, 0, '<Precision,2:8><Standard Format,2>'))
                    else
                        JsonTextWriter.WriteStringProperty('discount', Format(-UnitDiscountExclVAT, 0, '<Precision,2:8><Standard Format,2>'));
                end;

                if ESPOSAuditLogAuxInfo."Recipient Type" = ESPOSAuditLogAuxInfo."Recipient Type"::International then begin
                    case POSEntrySalesLine.Type of
                        POSEntrySalesLine.Type::Item:
                            begin
                                Item.Get(POSEntrySalesLine."No.");
                                case Item.Type of
                                    Item.Type::Inventory, Item.Type::"Non-Inventory":
                                        JsonTextWriter.WriteStringProperty('concept', Enum::"NPR ES Invoice Item Concept".Names().Get(Enum::"NPR ES Invoice Item Concept".Ordinals().IndexOf(Enum::"NPR ES Invoice Item Concept"::INTERNATIONAL_GOOD.AsInteger())));
                                    Item.Type::Service:
                                        JsonTextWriter.WriteStringProperty('concept', Enum::"NPR ES Invoice Item Concept".Names().Get(Enum::"NPR ES Invoice Item Concept".Ordinals().IndexOf(Enum::"NPR ES Invoice Item Concept"::INTERNATIONAL_SERVICE.AsInteger())));
                                end;
                            end;
                        POSEntrySalesLine.Type::Voucher:
                            JsonTextWriter.WriteStringProperty('concept', Enum::"NPR ES Invoice Item Concept".Names().Get(Enum::"NPR ES Invoice Item Concept".Ordinals().IndexOf(Enum::"NPR ES Invoice Item Concept"::INTERNATIONAL_SERVICE.AsInteger())));
                    end;
                end;

                AddInvoiceSystemJSONObjectForCreateInvoice(JsonTextWriter);
                JsonTextWriter.WriteEndObject();
            until POSEntrySalesLine.Next() = 0;

        JsonTextWriter.WriteEndArray();
    end;

    local procedure AddInvoiceSystemJSONObjectForCreateInvoice(var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartObject('system');
        JsonTextWriter.WriteStringProperty('type', 'REGULAR');

        JsonTextWriter.WriteStartObject('category');
        JsonTextWriter.WriteStringProperty('type', 'VAT');
        JsonTextWriter.WriteEndObject(); // category

        JsonTextWriter.WriteEndObject(); // system
    end;

    local procedure AddRecipientsJSONArrayForCreateInvoice(ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartArray('recipients');

        JsonTextWriter.WriteStartObject('');

        JsonTextWriter.WriteStartObject('id');
        JsonTextWriter.WriteStringProperty('legal_name', ESPOSAuditLogAuxInfo."Recipient Legal Name");

        case ESPOSAuditLogAuxInfo."Recipient Type" of
            ESPOSAuditLogAuxInfo."Recipient Type"::National:
                JsonTextWriter.WriteStringProperty('tax_number', ESPOSAuditLogAuxInfo."Recipient VAT Registration No.");
            ESPOSAuditLogAuxInfo."Recipient Type"::International:
                begin
                    JsonTextWriter.WriteStringProperty('type', Enum::"NPR ES Inv. Rcpt. Id Type".Names().Get(Enum::"NPR ES Inv. Rcpt. Id Type".Ordinals().IndexOf(ESPOSAuditLogAuxInfo."Recipient Identification Type".AsInteger())));
                    JsonTextWriter.WriteStringProperty('number', ESPOSAuditLogAuxInfo."Recipient Identification No.");
                    JsonTextWriter.WriteStringProperty('country_code', ESPOSAuditLogAuxInfo."Recipient Country/Region Code");
                end;
        end;

        JsonTextWriter.WriteEndObject(); // id

        JsonTextWriter.WriteStringProperty('address_line', ESPOSAuditLogAuxInfo."Recipient Address");
        JsonTextWriter.WriteStringProperty('postal_code', ESPOSAuditLogAuxInfo."Recipient Post Code");
        JsonTextWriter.WriteEndObject();

        JsonTextWriter.WriteEndArray();
    end;

    local procedure CreateJSONBodyForUpdateInvoiceMetadata(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStartObject('content');
        JsonTextWriter.WriteEndObject(); // content

        AddMetadataForInvoice(ESPOSAuditLogAuxInfo, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure CreateJSONBodyForCancelInvoice(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');

        JsonTextWriter.WriteStartObject('content');
        JsonTextWriter.WriteStringProperty('state', Enum::"NPR ES Invoice State".Names().Get(Enum::"NPR ES Invoice State".Ordinals().IndexOf(Enum::"NPR ES Invoice State"::CANCELLED.AsInteger())));
        JsonTextWriter.WriteEndObject(); // content

        AddMetadataForInvoice(ESPOSAuditLogAuxInfo, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure AddMetadataForInvoice(ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartObject('metadata');
        JsonTextWriter.WriteStringProperty('bc_company_name', CompanyName());
        JsonTextWriter.WriteStringProperty('bc_client_code', ESPOSAuditLogAuxInfo."POS Unit No.");
        JsonTextWriter.WriteStringProperty('bc_signer_code', ESPOSAuditLogAuxInfo."ES Signer Code");
        JsonTextWriter.WriteEndObject();
    end;
    #endregion

    #region JSON Fiscal Parsers
    internal procedure PopulateOrganization(var ESOrganization: Record "NPR ES Organization"; ResponseText: Text)
    var
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('$.content.territory', PropertyValue);
        ESOrganization.Validate("Taxpayer Territory", GetTaxpayerTerritory(PropertyValue.AsValue().AsText()));

        ResponseJson.SelectToken('$.content.type', PropertyValue);
        ESOrganization."Taxpayer Type" := GetTaxpayerType(PropertyValue.AsValue().AsText());

        ESOrganization."Taxpayer Created" := true;
        ESOrganization.Modify(true);
    end;

    local procedure GetTaxpayerTerritory(Territory: Text): Enum "NPR ES Taxpayer Territory"
    begin
        if Enum::"NPR ES Taxpayer Territory".Names().Contains(Territory) then
            exit(Enum::"NPR ES Taxpayer Territory".FromInteger(Enum::"NPR ES Taxpayer Territory".Ordinals().Get(Enum::"NPR ES Taxpayer Territory".Names().IndexOf(Territory))));

        exit(Enum::"NPR ES Taxpayer Territory"::" ");
    end;

    local procedure GetTaxpayerType(Type: Text): Enum "NPR ES Taxpayer Type"
    begin
        if Enum::"NPR ES Taxpayer Type".Names().Contains(Type) then
            exit(Enum::"NPR ES Taxpayer Type".FromInteger(Enum::"NPR ES Taxpayer Type".Ordinals().Get(Enum::"NPR ES Taxpayer Type".Names().IndexOf(Type))));

        exit(Enum::"NPR ES Taxpayer Type"::" ");
    end;

    internal procedure PopulateSigner(var ESSigner: Record "NPR ES Signer"; ResponseText: Text)
    var
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('$.content.state', PropertyValue);
        ESSigner.State := GetSignerState(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('$.content.certificate.serial_number', PropertyValue);
        ESSigner."Certificate Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ESSigner."Certificate Serial Number"));

        ResponseJson.SelectToken('$.content.certificate.expires_at', PropertyValue);
        ESSigner."Certificate Expires At" := ConvertToDateTime(PropertyValue.AsValue().AsText());

        ESSigner.Modify(true);
    end;

    local procedure PopulateSignerForListSigners(ResponseText: Text; ESOrganizationCode: Code[20])
    var
        ESSigner: Record "NPR ES Signer";
        PropertyValue, ResponseJson, SignerObject, SignerObjects : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);
        if not ResponseJson.SelectToken('results', SignerObjects) then
            exit;

        if not SignerObjects.IsArray() then
            exit;

        foreach SignerObject in SignerObjects.AsArray() do begin
            InsertOrGetSigner(ESSigner, SignerObject);
            ESSigner."ES Organization Code" := ESOrganizationCode;

            SignerObject.SelectToken('$.content.state', PropertyValue);
            ESSigner.State := GetSignerState(PropertyValue.AsValue().AsText());

            SignerObject.SelectToken('$.content.certificate.serial_number', PropertyValue);
            ESSigner."Certificate Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ESSigner."Certificate Serial Number"));

            SignerObject.SelectToken('$.content.certificate.expires_at', PropertyValue);
            ESSigner."Certificate Expires At" := ConvertToDateTime(PropertyValue.AsValue().AsText());

            ESSigner.Modify(true);
        end;
    end;

    local procedure InsertOrGetSigner(var ESSigner: Record "NPR ES Signer"; var SignerObject: JsonToken)
    var
        SystemId: Guid;
        PropertyValue: JsonToken;
    begin
        SignerObject.SelectToken('$.content.id', PropertyValue);
        SystemId := PropertyValue.AsValue().AsText();
        if not ESSigner.GetBySystemId(SystemId) then begin
            ESSigner.Init();

            SignerObject.SelectToken('$.metadata.bc_code', PropertyValue);
            ESSigner.Code := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(ESSigner.Code));

            if SignerObject.SelectToken('$.metadata.bc_description', PropertyValue) then
                ESSigner.Description := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(ESSigner.Description));

            ESSigner.SystemId := SystemId;
            ESSigner.Insert(false, true);
        end;
    end;

    local procedure GetSignerState(State: Text): Enum "NPR ES Signer State"
    begin
        if Enum::"NPR ES Signer State".Names().Contains(State) then
            exit(Enum::"NPR ES Signer State".FromInteger(Enum::"NPR ES Signer State".Ordinals().Get(Enum::"NPR ES Signer State".Names().IndexOf(State))));

        exit(Enum::"NPR ES Signer State"::" ");
    end;

    internal procedure PopulateClient(var ESClient: Record "NPR ES Client"; ResponseText: Text)
    var
        ESSigner: Record "NPR ES Signer";
        SignerId: Guid;
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('$.content.state', PropertyValue);
        ESClient.State := GetClientState(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('$.content.signer.id', PropertyValue);
        SignerId := PropertyValue.AsValue().AsText();
        InsertOrGetSigner(ESSigner, ESClient."ES Organization Code", SignerId);
        ESClient."ES Signer Code" := ESSigner.Code;
        ESClient."ES Signer Id" := SignerId;

        ESClient.Modify(true);
    end;

    local procedure InsertOrGetSigner(var ESSigner: Record "NPR ES Signer"; ESOrganizationCode: Code[20]; SignerId: Guid)
    begin
        if not ESSigner.GetBySystemId(SignerId) then
            InsertSigner(ESSigner, ESOrganizationCode, SignerId);
    end;

    local procedure InsertSigner(var ESSigner: Record "NPR ES Signer"; ESOrganizationCode: Code[20]; SignerId: Guid; ResponseText: Text)
    var
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ESSigner.Init();

        ResponseJson.SelectToken('$.metadata.bc_code', PropertyValue);
        ESSigner.Code := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(ESSigner.Code));

        if ResponseJson.SelectToken('$.metadata.bc_description', PropertyValue) then
            ESSigner.Description := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(ESSigner.Description));

        ESSigner."ES Organization Code" := ESOrganizationCode;

        ResponseJson.SelectToken('$.content.state', PropertyValue);
        ESSigner.State := GetSignerState(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('$.content.certificate.serial_number', PropertyValue);
        ESSigner."Certificate Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ESSigner."Certificate Serial Number"));

        ResponseJson.SelectToken('$.content.certificate.expires_at', PropertyValue);
        ESSigner."Certificate Expires At" := ConvertToDateTime(PropertyValue.AsValue().AsText());

        ESSigner.SystemId := SignerId;
        ESSigner.Insert(false, true);
    end;

    local procedure PopulateClientForListClients(ResponseText: Text; ESOrganizationCode: Code[20])
    var
        ESClient: Record "NPR ES Client";
        ESSigner: Record "NPR ES Signer";
        SignerId: Guid;
        ClientObject, ClientObjects, PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);
        if not ResponseJson.SelectToken('results', ClientObjects) then
            exit;

        if not ClientObjects.IsArray() then
            exit;

        foreach ClientObject in ClientObjects.AsArray() do begin
            InsertOrGetClient(ESClient, ClientObject);
            ESClient."ES Organization Code" := ESOrganizationCode;

            ClientObject.SelectToken('$.content.state', PropertyValue);
            ESClient.State := GetClientState(PropertyValue.AsValue().AsText());

            ClientObject.SelectToken('$.content.signer.id', PropertyValue);
            SignerId := PropertyValue.AsValue().AsText();
            InsertOrGetSigner(ESSigner, ESClient."ES Organization Code", SignerId);
            ESClient."ES Signer Code" := ESSigner.Code;
            ESClient."ES Signer Id" := SignerId;

            ESClient.Modify(true);
        end;
    end;

    local procedure InsertOrGetClient(var ESClient: Record "NPR ES Client"; var ClientObject: JsonToken)
    var
        SystemId: Guid;
        PropertyValue: JsonToken;
    begin
        ClientObject.SelectToken('$.content.id', PropertyValue);
        SystemId := PropertyValue.AsValue().AsText();
        if not ESClient.GetBySystemId(SystemId) then begin
            ESClient.Init();

            ClientObject.SelectToken('$.metadata.bc_code', PropertyValue);
            ESClient."POS Unit No." := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(ESClient."POS Unit No."));

            if ClientObject.SelectToken('$.metadata.bc_description', PropertyValue) then
                ESClient.Description := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(ESClient.Description));

            ESClient.SystemId := SystemId;
            ESClient.Insert(false, true);
        end;
    end;

    local procedure GetClientState(State: Text): Enum "NPR ES Client State"
    begin
        if Enum::"NPR ES Client State".Names().Contains(State) then
            exit(Enum::"NPR ES Client State".FromInteger(Enum::"NPR ES Client State".Ordinals().Get(Enum::"NPR ES Client State".Names().IndexOf(State))));

        exit(Enum::"NPR ES Client State"::" ");
    end;

    local procedure PopulateOrganizationForRetrieveSoftware(var ESOrganization: Record "NPR ES Organization"; ResponseText: Text)
    var
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('$.content.company.legal_name', PropertyValue);
        ESOrganization."Company Legal Name" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ESOrganization."Company Legal Name"));

        ResponseJson.SelectToken('$.content.company.tax_number', PropertyValue);
        ESOrganization."Company Tax Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ESOrganization."Company Tax Number"));

        ResponseJson.SelectToken('$.content.name', PropertyValue);
        ESOrganization."Software Name" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ESOrganization."Software Name"));

        ResponseJson.SelectToken('$.content.license', PropertyValue);
        ESOrganization."Software License" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ESOrganization."Software License"));

        ResponseJson.SelectToken('$.content.version', PropertyValue);
        ESOrganization."Software Version" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ESOrganization."Software Version"));

        ESOrganization.Modify(true);
    end;

    internal procedure PopulateESPOSAuditLogAuxInfoForCreateInvoice(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; ResponseText: Text)
    begin
        PopulateInvoiceNoOnESPOSAuditLogAuxInfoForCreateInvoice(ESPOSAuditLogAuxInfo);
        PopulateESPOSAuditLogAuxInfo(ESPOSAuditLogAuxInfo, ResponseText);
    end;

    internal procedure PopulateInvoiceNoOnESPOSAuditLogAuxInfoForCreateInvoice(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info")
    var
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
        NoSeries: Codeunit "No. Series";
#else
        NoSeries: Codeunit NoSeriesManagement;
#endif
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
        ESPOSAuditLogAuxInfo."Invoice No." := NoSeries.GetNextNo(ESPOSAuditLogAuxInfo."Invoice No. Series");
#else
        ESPOSAuditLogAuxInfo."Invoice No." := NoSeries.GetNextNo(ESPOSAuditLogAuxInfo."Invoice No. Series", WorkDate(), true);
#endif
        ESPOSAuditLogAuxInfo.Modify(true);

        // This commit is necessary in order to have invoice number on our end and Fiskaly's end in sync in case we get some error during parsing response which should roll back the number series value.
        // Otherwise we will not be able to create new invoices due to receiving error that invoice number is already assigned on Fiskaly's end.
        Commit();
    end;

    internal procedure PopulateESPOSAuditLogAuxInfo(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; ResponseText: Text)
    var
        ESSigner: Record "NPR ES Signer";
        PropertyValue, ResponseJson : JsonToken;
        InvoiceValidationDescription: Text;
        InvoiceValidationStatus: Text;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('$.content.signer.id', PropertyValue);
        ESPOSAuditLogAuxInfo."ES Signer Id" := PropertyValue.AsValue().AsText();

        ESSigner.GetBySystemId(PropertyValue.AsValue().AsText());
        ESPOSAuditLogAuxInfo."ES Signer Code" := ESSigner.Code;
        ESPOSAuditLogAuxInfo."ES Organization Code" := ESSigner."ES Organization Code";

        ResponseJson.SelectToken('$.content.client.id', PropertyValue);
        ESPOSAuditLogAuxInfo."ES Client Id" := PropertyValue.AsValue().AsText();

        ResponseJson.SelectToken('$.content.state', PropertyValue);
        ESPOSAuditLogAuxInfo."Invoice State" := GetInvoiceState(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('$.content.issued_at', PropertyValue);
        ESPOSAuditLogAuxInfo."Issued At" := ConvertToDateTime(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('$.content.compliance.code.image.data', PropertyValue);
        ESPOSAuditLogAuxInfo.SetQRCode(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('$.content.compliance.url', PropertyValue);
        ESPOSAuditLogAuxInfo."Validation URL" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ESPOSAuditLogAuxInfo."Validation URL"));

        ResponseJson.SelectToken('$.content.transmission.registration', PropertyValue);
        ESPOSAuditLogAuxInfo."Invoice Registration State" := GetInvoiceRegistrationState(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('$.content.transmission.cancellation', PropertyValue);
        ESPOSAuditLogAuxInfo."Invoice Cancellation State" := GetInvoiceCancellationState(PropertyValue.AsValue().AsText());

        GetInvoiceValidationFields(ResponseJson, InvoiceValidationStatus, InvoiceValidationDescription);
        ESPOSAuditLogAuxInfo."Invoice Validation Status" := CopyStr(InvoiceValidationStatus, 1, MaxStrLen(ESPOSAuditLogAuxInfo."Invoice Validation Status"));
        ESPOSAuditLogAuxInfo."Invoice Validation Description" := CopyStr(InvoiceValidationDescription, 1, MaxStrLen(ESPOSAuditLogAuxInfo."Invoice Validation Description"));

        ESPOSAuditLogAuxInfo.Modify(true);
    end;

    local procedure GetInvoiceState(InvoiceState: Text): Enum "NPR ES Invoice State"
    begin
        if Enum::"NPR ES Invoice State".Names().Contains(InvoiceState) then
            exit(Enum::"NPR ES Invoice State".FromInteger(Enum::"NPR ES Invoice State".Ordinals().Get(Enum::"NPR ES Invoice State".Names().IndexOf(InvoiceState))));

        exit(Enum::"NPR ES Invoice State"::" ");
    end;

    local procedure GetInvoiceRegistrationState(InvoiceRegistrationState: Text): Enum "NPR ES Inv. Registration State"
    begin
        if Enum::"NPR ES Inv. Registration State".Names().Contains(InvoiceRegistrationState) then
            exit(Enum::"NPR ES Inv. Registration State".FromInteger(Enum::"NPR ES Inv. Registration State".Ordinals().Get(Enum::"NPR ES Inv. Registration State".Names().IndexOf(InvoiceRegistrationState))));

        exit(Enum::"NPR ES Inv. Registration State"::" ");
    end;

    local procedure GetInvoiceCancellationState(InvoiceCancellationState: Text): Enum "NPR ES Inv. Cancellation State"
    begin
        if Enum::"NPR ES Inv. Cancellation State".Names().Contains(InvoiceCancellationState) then
            exit(Enum::"NPR ES Inv. Cancellation State".FromInteger(Enum::"NPR ES Inv. Cancellation State".Ordinals().Get(Enum::"NPR ES Inv. Cancellation State".Names().IndexOf(InvoiceCancellationState))));

        exit(Enum::"NPR ES Inv. Cancellation State"::" ");
    end;

    local procedure GetInvoiceValidationFields(var InvoiceObject: JsonToken; var ValidationStatus: Text; var ValidationDescription: Text)
    var
        PropertyValue: JsonToken;
        ValidationObject: JsonToken;
        ValidationObjects: JsonToken;
    begin
        if not InvoiceObject.SelectToken('$.content.validations', ValidationObjects) then
            exit;

        if not ValidationObjects.IsArray() then
            exit;

        foreach ValidationObject in ValidationObjects.AsArray() do begin
            ValidationObject.SelectToken('code', PropertyValue);
            ValidationStatus += PropertyValue.AsValue().AsText() + '; ';

            ValidationObject.SelectToken('description', PropertyValue);
            ValidationDescription += PropertyValue.AsValue().AsText() + '; ';
        end;

        ValidationStatus := ValidationStatus.TrimEnd('; ');
        ValidationDescription := ValidationDescription.TrimEnd('; ');
    end;
    #endregion

    #region Http Requests - Misc
    local procedure CreateUrl(ESFiscalizationSetup: Record "NPR ES Fiscalization Setup"; Method: Text) Url: Text
    var
        BaseUrl: Text;
    begin
        if ESFiscalizationSetup.Live then
            BaseUrl := ESFiscalizationSetup."Live Fiskaly API URL"
        else
            BaseUrl := ESFiscalizationSetup."Test Fiskaly API URL";

        Url := BaseUrl.TrimEnd('/') + '/' + Method;
    end;

    local procedure PrepareHttpRequest(ESOrganization: Record "NPR ES Organization"; SetAuthorization: Boolean; var RequestMessage: HttpRequestMessage; JsonBody: Text; Url: Text; HttpRequestType: Enum "Http Request Type")
    var
        IsHandled: Boolean;
        RequestContent: HttpContent;
        RequestHeaders: HttpHeaders;
        BearerTokenLbl: Label 'Bearer %1', Locked = true, Comment = '%1 - JWT value';
    begin
        if JsonBody <> '' then begin
            SetRequestContent(RequestContent, RequestHeaders, JsonBody);
            RequestMessage.Content(RequestContent);
        end;

        RequestMessage.SetRequestUri(Url);
        RequestMessage.Method(Format(HttpRequestType));
        RequestMessage.GetHeaders(RequestHeaders);

        if not SetAuthorization then
            exit;

        OnBeforeSetAuthorizationOnPrepareHttpRequest(RequestHeaders, IsHandled);
        if IsHandled then
            exit;

        RequestHeaders.Add('Authorization', StrSubstNo(BearerTokenLbl, GetJWT(ESOrganization)));
    end;

    local procedure SetRequestContent(var RequestContent: HttpContent; var RequestHeaders: HttpHeaders; JsonBody: Text)
    begin
        if JsonBody = '' then
            exit;

        RequestContent.WriteFrom(JsonBody);

        RequestContent.GetHeaders(RequestHeaders);
        SetRequestHeader(RequestHeaders, 'Content-Type', 'application/json');
    end;

    local procedure SetRequestHeader(var RequestHeaders: HttpHeaders; HeaderName: Text; HeaderValue: Text)
    begin
        if RequestHeaders.Contains(HeaderName) then
            RequestHeaders.Remove(HeaderName);

        RequestHeaders.Add(HeaderName, HeaderValue);
    end;

    [TryFunction]
    local procedure SendHttpRequest(RequestMessage: HttpRequestMessage; var ResponseText: Text)
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
    begin
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content.ReadAs(ResponseText);
        if not ResponseMessage.IsSuccessStatusCode() then
            Error(ResponseText);
    end;
    #endregion

    #region Procedures/Helper Functions
    local procedure FindESPOSAuditLogAuxInfoToRefund(POSEntryNo: Integer; var ESPOSAuditLogAuxInfoToRefund: Record "NPR ES POS Audit Log Aux. Info")
    var
        OriginalPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntryNo);
        POSEntrySalesLine.FindFirst();

        OriginalPOSEntrySalesLine.GetBySystemId(POSEntrySalesLine."Orig.POS Entry S.Line SystemId");
        ESPOSAuditLogAuxInfoToRefund.FindAuditLog(OriginalPOSEntrySalesLine."POS Entry No.");
    end;

    local procedure GetCorrectingInvoiceCode(POSEntryNo: Integer): Text
    var
        ESReturnReasonMapping: Record "NPR ES Return Reason Mapping";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntryNo);
        POSEntrySalesLine.SetFilter("Return Reason Code", '<>%1', '');
        POSEntrySalesLine.FindFirst();

        ESReturnReasonMapping.Get(POSEntrySalesLine."Return Reason Code");
        ESReturnReasonMapping.CheckIsESReturnReasonPopulated();
        exit(Enum::"NPR ES Return Reason".Names().Get(Enum::"NPR ES Return Reason".Ordinals().IndexOf(ESReturnReasonMapping."ES Return Reason".AsInteger())));
    end;

    local procedure GetCompanyInformationWithCheck(var CompanyInformation: Record "Company Information")
    var
        VATRegistrationNoLenghtErr: Label '%1 cannot be longer than 9 characters.', Comment = '%1 - VAT Registration No. field caption';
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField(Name);
        CompanyInformation.TestField("VAT Registration No.");
        if StrLen(CompanyInformation."VAT Registration No.") > 9 then
            Error(VATRegistrationNoLenghtErr, CompanyInformation.FieldCaption("VAT Registration No."));
    end;

    local procedure ConvertToDateTime(DateTimeAsText: Text): DateTime
    var
        Date: Date;
        Day: Integer;
        Month: Integer;
        Year: Integer;
        DateSplit: List of [Text];
        DateTimeSplit: List of [Text];
        DateAsText: Text;
        TimeAsText: Text;
        Time: Time;
    begin
        // according to documentation string for datetime is in format DD-MM-YYYY hh:mm:ss
        DateTimeSplit := DateTimeAsText.Split(' ');

        DateAsText := DateTimeSplit.Get(1);
        DateSplit := DateAsText.Split('-');
        Evaluate(Day, DateSplit.Get(1));
        Evaluate(Month, DateSplit.Get(2));
        Evaluate(Year, DateSplit.Get(3));
        Date := DMY2Date(Day, Month, Year);

        TimeAsText := DateTimeSplit.Get(2);
        Evaluate(Time, TimeAsText);
        exit(CreateDateTime(Date, Time));
    end;

    local procedure CheckIsGUIDAccordingToUUIDv4Standard(GUIDToCheck: Guid)
    var
#IF BC17
        RegEx: Codeunit DotNet_Regex;
#ELSE
        Regex: Codeunit Regex;
#ENDIF
        UUIDv4StandardErr: Label 'GUID %1 is not according to UUIDv4 standard pattern.', Comment = '%1 - GUID value';
        UUIDv4StandardPatternLbl: Label '[a-f0-9]{8}-?[a-f0-9]{4}-?4[a-f0-9]{3}-?[89ab][a-f0-9]{3}-?[a-f0-9]{12}', Locked = true;
        GUIDToCheckAsText: Text;
    begin
        GUIDToCheckAsText := Format(GUIDToCheck, 0, 4).ToLower();
        if not Regex.IsMatch(GUIDToCheckAsText, UUIDv4StandardPatternLbl) then
            Error(UUIDv4StandardErr, GUIDToCheck);
    end;
    #endregion

    #region Event Publishers
    #endregion

    #region Automation Test Mockup Helpers
    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetAuthorizationOnPrepareHttpRequest(var RequestHeaders: HttpHeaders; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForCreateTaxpayer(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESOrganization: Record "NPR ES Organization"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForRetrieveTaxpayer(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESOrganization: Record "NPR ES Organization"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForCreateSigner(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESSigner: Record "NPR ES Signer"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForUpdateSigner(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESSigner: Record "NPR ES Signer"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForRetrieveSigner(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESSigner: Record "NPR ES Signer"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForInsertSigner(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESSigner: Record "NPR ES Signer"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForCreateClient(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESClient: Record "NPR ES Client"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForUpdateClient(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESClient: Record "NPR ES Client"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForRetrieveClient(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESClient: Record "NPR ES Client"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForRetrieveSoftware(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESOrganization: Record "NPR ES Organization"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForCreateInvoice(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForRetrieveInvoice(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForUpdateInvoiceMetadata(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForCancelInvoice(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
    end;
    #endregion
}
