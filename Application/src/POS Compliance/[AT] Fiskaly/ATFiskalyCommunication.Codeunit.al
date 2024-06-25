codeunit 6184861 "NPR AT Fiskaly Communication"
{
    Access = Internal;

    var
        ATSecretMgt: Codeunit "NPR AT Secret Mgt.";
        RestMethod: Option GET,POST,DELETE,PATCH,PUT;

    #region JWT Token
    local procedure GetJWT(ATOrganization: Record "NPR AT Organization"): Text
    var
        ATFiskalyJWT: Codeunit "NPR AT Fiskaly JWT";
        JWTResponseJson: JsonToken;
        AccessToken: Text;
        RefreshToken: Text;
    begin
        ATOrganization.TestField(SystemId);
        if ATFiskalyJWT.GetToken(ATOrganization.SystemId, AccessToken, RefreshToken) then
            exit(AccessToken);

        JWTResponseJson := AuthenticateAPI(ATOrganization, RefreshToken);
        ATFiskalyJWT.SetToken(ATOrganization.SystemId, JWTResponseJson, AccessToken);
        exit(AccessToken);
    end;

    local procedure AuthenticateAPI(ATOrganization: Record "NPR AT Organization"; RefreshToken: Text) JsonResponse: JsonToken
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        RequestMessage: HttpRequestMessage;
        AuthenticateAPIErr: Label 'Authentication with Fiskaly failed.';
        AuthenticateAPILbl: Label 'auth', Locked = true;
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ATFiscalizationSetup.GetWithCheck();
        CheckAuthenticateAPICredentials(ATOrganization);

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", AuthenticateAPILbl);
        JsonBody := CreateJSONBodyForAuthenticateAPI(ATOrganization, RefreshToken);
        PrepareHttpRequest(ATOrganization, false, RequestMessage, JsonBody, Url, RestMethod::POST);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', AuthenticateAPIErr, GetLastErrorText());

        JsonResponse.ReadFrom(ResponseText);
    end;

    local procedure CheckAuthenticateAPICredentials(ATOrganization: Record "NPR AT Organization")
    begin
        CheckIsAPIKeyAssigned(ATOrganization);
        CheckIsAPISecretNameAssigned(ATOrganization);
    end;

    local procedure CheckIsAPIKeyAssigned(ATOrganization: Record "NPR AT Organization")
    var
        FONParticipantIdNotAssignedErr: Label 'API Key must be assigned on %1 %2 first.', Comment = '%1 - AT Organization table caption, %2 - AT Organization Code value';
    begin
        if not ATSecretMgt.HasSecretKey(ATOrganization.GetAPIKeyName()) then
            Error(FONParticipantIdNotAssignedErr, ATOrganization.TableCaption, ATOrganization.Code);
    end;

    local procedure CheckIsAPISecretNameAssigned(ATOrganization: Record "NPR AT Organization")
    var
        FONUserIdNotAssignedErr: Label 'API Secret must be assigned to %1 %2 first.', Comment = '%1 - AT Organization table caption, %2 - AT Organization Code value';
    begin
        if not ATSecretMgt.HasSecretKey(ATOrganization.GetAPISecretName()) then
            Error(FONUserIdNotAssignedErr, ATOrganization.TableCaption, ATOrganization.Code);
    end;
    #endregion

    #region FinanzOnline management
    internal procedure AuthenticateFON(var ATOrganization: Record "NPR AT Organization")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        AuthenticateFONErr: Label 'FinanzOnline Authentication failed.';
        AuthenticateFONLbl: Label 'fon/auth', Locked = true;
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ATOrganization.TestField(SystemId);
        ATFiscalizationSetup.GetWithCheck();
        CheckFONAuthenticationCredentials(ATFiscalizationSetup);

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", AuthenticateFONLbl);
        JsonBody := CreateJSONBodyForAuthenticateFON(ATFiscalizationSetup);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PUT);

        OnBeforeSendHttpRequestForAuthenticateFON(RequestMessage, ResponseText, ATOrganization, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', AuthenticateFONErr, GetLastErrorText());

        PopulateATOrganizationForAuthenticateFON(ATOrganization, ResponseText);
    end;

    internal procedure RetrieveFONStatus(var ATOrganization: Record "NPR AT Organization")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        RetrieveFONStatusErr: Label 'Retrieve FinanzOnline authentication status failed.';
        RetrieveFONStatusLbl: Label 'fon/auth', Locked = true;
        ResponseText: Text;
        Url: Text;
    begin
        ATOrganization.TestField(SystemId);
        ATOrganization.CheckIsFONAuthenticationStatusNotAuthenticated();
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", RetrieveFONStatusLbl);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::GET);

        OnBeforeSendHttpRequestForRetrieveFONStatus(RequestMessage, ResponseText, ATOrganization, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', RetrieveFONStatusErr, GetLastErrorText());

        PopulateATOrganizationForRetrieveFONStatus(ATOrganization, ResponseText);
    end;

    local procedure CheckFONAuthenticationCredentials(ATFiscalizationSetup: Record "NPR AT Fiscalization Setup")
    begin
        CheckIsFONParticipantIdAssigned(ATFiscalizationSetup);
        CheckIsFONUserIdAssigned(ATFiscalizationSetup);
        CheckIsFONUserPINAssigned(ATFiscalizationSetup);
    end;

    local procedure CheckIsFONParticipantIdAssigned(ATFiscalizationSetup: Record "NPR AT Fiscalization Setup")
    var
        FONParticipantIdNotAssignedErr: Label 'FinanzOnline Participant Id must be assigned on %1 first.', Comment = '%1 - AT Fiscalization Setup table caption';
    begin
        if not ATSecretMgt.HasSecretKey(ATFiscalizationSetup.GetFONParticipantId()) then
            Error(FONParticipantIdNotAssignedErr, ATFiscalizationSetup.TableCaption);
    end;

    local procedure CheckIsFONUserIdAssigned(ATFiscalizationSetup: Record "NPR AT Fiscalization Setup")
    var
        FONUserIdNotAssignedErr: Label 'FinanzOnline User Id must be assigned to %1 first.', Comment = '%1 - AT Fiscalization Setup table caption';
    begin
        if not ATSecretMgt.HasSecretKey(ATFiscalizationSetup.GetFONUserId()) then
            Error(FONUserIdNotAssignedErr, ATFiscalizationSetup.TableCaption);
    end;

    local procedure CheckIsFONUserPINAssigned(ATFiscalizationSetup: Record "NPR AT Fiscalization Setup")
    var
        FONUserPINNotAssignedErr: Label 'FinanzOnline User PIN must be assigned to %1 first.', Comment = '%1 - AT Fiscalization Setup table caption';
    begin
        if not ATSecretMgt.HasSecretKey(ATFiscalizationSetup.GetFONUserPIN()) then
            Error(FONUserPINNotAssignedErr, ATFiscalizationSetup.TableCaption);
    end;
    #endregion

    #region SCU Management
    internal procedure CreateSCU(var ATSCU: Record "NPR AT SCU")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        CreateSCUErr: Label 'Create Signature Creation Unit failed.';
        CreateSCULbl: Label 'signature-creation-unit/%1', Locked = true, Comment = '%1 - Signature Creation Unit Id value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ATSCU.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATSCU.SystemId);
        ATSCU.TestField(Description);
        ATSCU.TestField("AT Organization Code");
        ATSCU.TestField("Created At", 0DT);
        ATSCU.IsThereAnyOtherActiveSCUForThisOrganization();
        ATOrganization.GetWithCheck(ATSCU."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(CreateSCULbl, Format(ATSCU.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForCreateSCU(ATSCU);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PUT);

        OnBeforeSendHttpRequestForCreateSCU(RequestMessage, ResponseText, ATSCU, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', CreateSCUErr, GetLastErrorText());

        PopulateATSCUForCreateSCU(ATSCU, ResponseText);
    end;

    internal procedure RetrieveSCU(var ATSCU: Record "NPR AT SCU")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        RetrieveSCUErr: Label 'Retrieve Signature Creation Unit failed.';
        RetrieveSCULbl: Label 'signature-creation-unit/%1', Locked = true, Comment = '%1 - Signature Creation Unit Id value';
        ResponseText: Text;
        Url: Text;
    begin
        ATSCU.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATSCU.SystemId);
        ATSCU.TestField("AT Organization Code");
        ATSCU.IsThereAnyOtherActiveSCUForThisOrganization();
        ATOrganization.GetWithCheck(ATSCU."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(RetrieveSCULbl, Format(ATSCU.SystemId, 0, 4).ToLower()));
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::GET);

        OnBeforeSendHttpRequestForRetrieveSCU(RequestMessage, ResponseText, ATSCU, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', RetrieveSCUErr, GetLastErrorText());

        PopulateATSCUForRetrieveSCU(ATSCU, ResponseText);
    end;

    internal procedure UpdateSCU(var ATSCU: Record "NPR AT SCU"; NewState: Enum "NPR AT SCU State")
    var
        ATCashRegister: Record "NPR AT Cash Register";
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        CannotUpdateToStateDueToRelatedRecordErr: Label 'You cannot set the %1 to %2, since there is at least one related %3 which %4 has to be set to %5 or %6.', Comment = '%1 - AT SCU State field caption, %2 - New State value, %3 - AT Cash Register table caption, %4 - AT Cash Register State field value, %5 - AT Cash Register State DECOMMISSIONED value, %6 - AT Cash Register State DEFECTIVE value';
        CannotUpdateToStateErr: Label 'You cannot set the %1 to %2, since it must have %1 %3 or %4 in order to be able to do that.', Comment = '%1 - AT SCU State field caption, %2 - New State value, %3 - AT SCU State INITIALIZED value, %4 - AT SCU State OUTAGE value';
        UpdateConfirmQst: Label 'Are you sure that you want to set the %1 to %2 since this it is irreversible?', Comment = '%1 - State field caption, %2 - New State value';
        UpdateSCUErr: Label 'Update Signature Creation Unit failed.';
        UpdateSCULbl: Label 'signature-creation-unit/%1', Locked = true, Comment = '%1 - Signature Creation Unit Id value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ATSCU.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATSCU.SystemId);
        ATSCU.TestField("AT Organization Code");

        case NewState of
            NewState::INITIALIZED:
                begin
                    ATSCU.TestField("Created At");
                    ATSCU.TestField(State, ATSCU.State::CREATED);
                end;
            NewState::DECOMMISSIONED:
                begin
                    ATSCU.TestField("Initialized At");
                    if not (ATSCU.State in [ATSCU.State::INITIALIZED, ATSCU.State::OUTAGE]) then
                        Error(CannotUpdateToStateErr, ATSCU.FieldCaption(State), NewState, ATSCU.State::INITIALIZED, ATSCU.State::OUTAGE);

                    ATCashRegister.SetRange("AT SCU Code", ATSCU.Code);
                    ATCashRegister.SetFilter(State, '<>%1&<>%2', ATCashRegister.State::DECOMMISSIONED, ATCashRegister.State::DEFECTIVE);
                    if not ATCashRegister.IsEmpty() then
                        Error(CannotUpdateToStateDueToRelatedRecordErr, ATSCU.FieldCaption(State), NewState, ATCashRegister.TableCaption(), ATCashRegister.FieldCaption(State), ATCashRegister.State::DECOMMISSIONED, ATCashRegister.State::DEFECTIVE);

                    if not Confirm(StrSubstNo(UpdateConfirmQst, ATSCU.FieldCaption(State), NewState)) then
                        Error('');
                end;
        end;

        ATOrganization.GetWithCheck(ATSCU."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(UpdateSCULbl, Format(ATSCU.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForUpdateSCU(NewState);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PATCH);

        OnBeforeSendHttpRequestForUpdateSCU(RequestMessage, ResponseText, ATSCU, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', UpdateSCUErr, GetLastErrorText());

        PopulateATSCUForUpdateSCU(ATSCU, ResponseText);
    end;

    internal procedure ListSCUs()
    var
        ATOrganization: Record "NPR AT Organization";
        Window: Dialog;
        RetrievingDataLbl: Label 'Retrieving data from Fiskaly...';
    begin
        ATOrganization.SetRange("FON Authentication Status", ATOrganization."FON Authentication Status"::AUTHENTICATED);
        if ATOrganization.IsEmpty() then
            exit;

        Window.Open(RetrievingDataLbl);

        ATOrganization.FindSet();

        repeat
            ListSCUs(ATOrganization);
        until ATOrganization.Next() = 0;

        Window.Close();
    end;

    local procedure ListSCUs(ATOrganization: Record "NPR AT Organization")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        RequestMessage: HttpRequestMessage;
        ListSCUsErr: Label 'List Signature Creation Units failed.';
        ListSCUsLbl: Label 'signature-creation-unit', Locked = true;
        ResponseText: Text;
        Url: Text;
    begin
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", ListSCUsLbl);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::GET);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', ListSCUsErr, GetLastErrorText());

        PopulateATSCUForListSCUs(ResponseText, ATOrganization.Code);
    end;
    #endregion

    #region Cash Register Management
    internal procedure CreateCashRegister(var ATCashRegister: Record "NPR AT Cash Register")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        CreateCashRegisterErr: Label 'Create Cash Register failed.';
        CreateCashRegisterLbl: Label 'cash-register/%1', Locked = true, Comment = '%1 - Cash Register Id value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ATCashRegister.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATCashRegister.SystemId);
        ATCashRegister.TestField(Description);
        ATCashRegister.TestField("AT SCU Code");
        ATCashRegister.TestField("Created At", 0DT);
        ATSCU.GetWithCheck(ATCashRegister."AT SCU Code");
        ATOrganization.GetWithCheck(ATSCU."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(CreateCashRegisterLbl, Format(ATCashRegister.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForCreateCashRegister(ATCashRegister);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PUT);

        OnBeforeSendHttpRequestForCreateCashRegister(RequestMessage, ResponseText, ATCashRegister, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', CreateCashRegisterErr, GetLastErrorText());

        PopulateATCashRegisterForCreateCashRegister(ATCashRegister, ResponseText);
    end;

    internal procedure RetrieveCashRegister(var ATCashRegister: Record "NPR AT Cash Register")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        CreateCashRegisterErr: Label 'Retrieve Cash Register failed.';
        CreateCashRegisterLbl: Label 'cash-register/%1', Locked = true, Comment = '%1 - Cash Register Id value';
        ResponseText: Text;
        Url: Text;
    begin
        ATCashRegister.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATCashRegister.SystemId);
        ATCashRegister.TestField("AT SCU Code");
        ATSCU.GetWithCheck(ATCashRegister."AT SCU Code");
        ATOrganization.GetWithCheck(ATSCU."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(CreateCashRegisterLbl, Format(ATCashRegister.SystemId, 0, 4).ToLower()));
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::GET);

        OnBeforeSendHttpRequestForRetrieveCashRegister(RequestMessage, ResponseText, ATCashRegister, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', CreateCashRegisterErr, GetLastErrorText());

        PopulateATCashRegisterForRetrieveCashRegister(ATCashRegister, ResponseText);
        OnAfterRetrieveCashRegister(ATCashRegister);
    end;

    internal procedure UpdateCashRegister(var ATCashRegister: Record "NPR AT Cash Register"; NewState: Enum "NPR AT Cash Register State")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        CannotUpdateToStateErr: Label 'You cannot set the %1 to %2, since it must have %1 %3 or %4 in order to be able to do that.', Comment = '%1 - AT Cash Register State field caption, %2 - New State value, %3 - AT Cash Register State INITIALIZED value, %4 - AT Cash Register State OUTAGE value';
        UpdateCashRegisterErr: Label 'Update Cash Register failed.';
        UpdateCashRegisterLbl: Label 'cash-register/%1', Locked = true, Comment = '%1 - Cash Register Id value';
        UpdateConfirmQst: Label 'Are you sure that you want to set the %1 to %2 since this it is irreversible?', Comment = '%1 - State field caption, %2 - New State value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ATCashRegister.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATCashRegister.SystemId);
        ATCashRegister.TestField("AT SCU Code");

        case NewState of
            NewState::REGISTERED:
                begin
                    ATCashRegister.TestField("Created At");
                    ATCashRegister.TestField(State, ATCashRegister.State::CREATED);
                end;
            NewState::INITIALIZED:
                begin
                    ATCashRegister.TestField("Registered At");
                    if not (ATCashRegister.State in [ATCashRegister.State::REGISTERED, ATCashRegister.State::OUTAGE]) then
                        Error(CannotUpdateToStateErr, ATCashRegister.FieldCaption(State), NewState, ATCashRegister.State::REGISTERED, ATCashRegister.State::OUTAGE);
                end;
            NewState::DECOMMISSIONED, NewState::DEFECTIVE:
                begin
                    ATCashRegister.TestField("Initialized At");
                    if not (ATCashRegister.State in [ATCashRegister.State::INITIALIZED, ATCashRegister.State::OUTAGE]) then
                        Error(CannotUpdateToStateErr, ATCashRegister.FieldCaption(State), NewState, ATCashRegister.State::INITIALIZED, ATCashRegister.State::OUTAGE);

                    if not Confirm(StrSubstNo(UpdateConfirmQst, ATCashRegister.FieldCaption(State), NewState)) then
                        Error('');
                end;
            NewState::OUTAGE:
                begin
                    ATCashRegister.TestField("Initialized At");
                    ATCashRegister.TestField(State, ATCashRegister.State::INITIALIZED);
                end;
        end;

        ATSCU.GetWithCheck(ATCashRegister."AT SCU Code");
        ATOrganization.GetWithCheck(ATSCU."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(UpdateCashRegisterLbl, Format(ATCashRegister.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForUpdateCashRegister(NewState);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PATCH);

        OnBeforeSendHttpRequestForUpdateCashRegister(RequestMessage, ResponseText, ATCashRegister, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', UpdateCashRegisterErr, GetLastErrorText());

        PopulateATCashRegisterForUpdateCashRegister(ATCashRegister, ResponseText);
        OnAfterUpdateCashRegister(ATCashRegister);
    end;

    internal procedure ListCashRegisters()
    var
        ATOrganization: Record "NPR AT Organization";
        Window: Dialog;
        RetrievingDataLbl: Label 'Retrieving data from Fiskaly...';
    begin
        ATOrganization.SetRange("FON Authentication Status", ATOrganization."FON Authentication Status"::AUTHENTICATED);
        if ATOrganization.IsEmpty() then
            exit;

        Window.Open(RetrievingDataLbl);

        ATOrganization.FindSet();

        repeat
            ListCashRegisters(ATOrganization);
        until ATOrganization.Next() = 0;

        Window.Close();
    end;

    local procedure ListCashRegisters(ATOrganization: Record "NPR AT Organization")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        RequestMessage: HttpRequestMessage;
        ListCashRegistersErr: Label 'List Cash Registers failed.';
        ListCashRegistersLbl: Label 'cash-register', Locked = true;
        ResponseText: Text;
        Url: Text;
    begin
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", ListCashRegistersLbl);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::GET);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', ListCashRegistersErr, GetLastErrorText());

        PopulateATCashRegisterForListCashRegisters(ResponseText);
    end;
    #endregion

    #region Receipt Management
    internal procedure ValidateReceipt(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        ValidateReceiptErr: Label 'Validate Receipt failed.';
        ValidateReceiptLbl: Label 'cash-register/%1/receipt/%2/validation', Locked = true, Comment = '%1 - Cash Register Id value, %2 - Receipt Id value';
        ResponseText: Text;
        Url: Text;
    begin
        ATPOSAuditLogAuxInfo.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATPOSAuditLogAuxInfo.SystemId);
        ATPOSAuditLogAuxInfo.TestField("AT SCU Code");
        ATPOSAuditLogAuxInfo.TestField("AT Cash Register Id");
        CheckIsGUIDAccordingToUUIDv4Standard(ATPOSAuditLogAuxInfo."AT Cash Register Id");
        ATOrganization.GetWithCheck(ATPOSAuditLogAuxInfo."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(ValidateReceiptLbl, Format(ATPOSAuditLogAuxInfo."AT Cash Register Id", 0, 4).ToLower(), Format(ATPOSAuditLogAuxInfo.SystemId, 0, 4).ToLower()));
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::POST);

        OnBeforeSendHttpRequestForValidateReceipt(RequestMessage, ResponseText, ATPOSAuditLogAuxInfo, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', ValidateReceiptErr, GetLastErrorText());

        PopulateATPOSAuditLogAuxInfoForValidateReceipt(ATPOSAuditLogAuxInfo, ResponseText);
    end;

    internal procedure SignReceipt(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        SignReceiptErr: Label 'Sign Receipt failed.';
        SignReceiptLbl: Label 'cash-register/%1/receipt/%2', Locked = true, Comment = '%1 - Cash Register Id value, %2 - Receipt Id value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ATPOSAuditLogAuxInfo.TestField(Signed, false);
        ATPOSAuditLogAuxInfo.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATPOSAuditLogAuxInfo.SystemId);
        ATPOSAuditLogAuxInfo.TestField("POS Entry No.");
        ATPOSAuditLogAuxInfo.TestField("AT Organization Code");
        ATPOSAuditLogAuxInfo.TestField("AT SCU Code");
        ATPOSAuditLogAuxInfo.TestField("AT Cash Register Id");
        CheckIsGUIDAccordingToUUIDv4Standard(ATPOSAuditLogAuxInfo."AT Cash Register Id");
        ATSCU.GetWithCheck(ATPOSAuditLogAuxInfo."AT SCU Code");
        ATOrganization.GetWithCheck(ATPOSAuditLogAuxInfo."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(SignReceiptLbl, Format(ATPOSAuditLogAuxInfo."AT Cash Register Id", 0, 4).ToLower(), Format(ATPOSAuditLogAuxInfo.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForSignReceipt(ATPOSAuditLogAuxInfo);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PUT);

        OnBeforeSendHttpRequestForSignReceipt(RequestMessage, ResponseText, ATPOSAuditLogAuxInfo, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', SignReceiptErr, GetLastErrorText());

        PopulateATPOSAuditLogAuxInfoForSignReceipt(ATPOSAuditLogAuxInfo, ResponseText);
    end;

    internal procedure RetrieveReceipt(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        RequestMessage: HttpRequestMessage;
        RetrieveReceiptErr: Label 'Retrieve Receipt failed.';
        RetrieveReceiptLbl: Label 'cash-register/%1/receipt/%2', Locked = true, Comment = '%1 - Cash Register Id value, %2 - Receipt Id value';
        ResponseText: Text;
        Url: Text;
    begin
        ATPOSAuditLogAuxInfo.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATPOSAuditLogAuxInfo.SystemId);
        ATPOSAuditLogAuxInfo.TestField("AT Organization Code");
        ATPOSAuditLogAuxInfo.TestField("AT SCU Code");
        ATPOSAuditLogAuxInfo.TestField("AT Cash Register Id");
        CheckIsGUIDAccordingToUUIDv4Standard(ATPOSAuditLogAuxInfo."AT Cash Register Id");
        ATSCU.GetWithCheck(ATPOSAuditLogAuxInfo."AT SCU Code");
        ATOrganization.GetWithCheck(ATPOSAuditLogAuxInfo."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(RetrieveReceiptLbl, Format(ATPOSAuditLogAuxInfo."AT Cash Register Id", 0, 4).ToLower(), Format(ATPOSAuditLogAuxInfo.SystemId, 0, 4).ToLower()));
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::GET);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', RetrieveReceiptErr, GetLastErrorText());

        PopulateATPOSAuditLogAuxInfoForRetrieveReceipt(ATPOSAuditLogAuxInfo, ResponseText);
    end;

    internal procedure SignControlReceipt(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        IsHandled: Boolean;
        RequestMessage: HttpRequestMessage;
        SignControlReceiptErr: Label 'Sign Control Receipt failed.';
        SignControlReceiptLbl: Label 'cash-register/%1/receipt/%2', Locked = true, Comment = '%1 - Cash Register Id value, %2 - Receipt Id value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ATPOSAuditLogAuxInfo.TestField(Signed, false);
        ATPOSAuditLogAuxInfo.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATPOSAuditLogAuxInfo.SystemId);
        ATPOSAuditLogAuxInfo.TestField("Audit Entry Type", ATPOSAuditLogAuxInfo."Audit Entry Type"::"Control Transaction");
        ATPOSAuditLogAuxInfo.TestField("AT Organization Code");
        ATPOSAuditLogAuxInfo.TestField("AT SCU Code");
        ATPOSAuditLogAuxInfo.TestField("AT Cash Register Id");
        CheckIsGUIDAccordingToUUIDv4Standard(ATPOSAuditLogAuxInfo."AT Cash Register Id");
        ATSCU.GetWithCheck(ATPOSAuditLogAuxInfo."AT SCU Code");
        ATOrganization.GetWithCheck(ATPOSAuditLogAuxInfo."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(SignControlReceiptLbl, Format(ATPOSAuditLogAuxInfo."AT Cash Register Id", 0, 4).ToLower(), Format(ATPOSAuditLogAuxInfo.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForSignControlReceipt(ATPOSAuditLogAuxInfo);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PUT);

        OnBeforeSendHttpRequestForSignControlReceipt(RequestMessage, ResponseText, ATPOSAuditLogAuxInfo, IsHandled);
        if IsHandled then
            exit;

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', SignControlReceiptErr, GetLastErrorText());

        PopulateATPOSAuditLogAuxInfoForSignControlReceipt(ATPOSAuditLogAuxInfo, ResponseText);
    end;

    internal procedure ListCashRegisterReceipts(ATCashRegister: Record "NPR AT Cash Register"; ATAuditEntryType: Enum "NPR AT Audit Entry Type"; QueryParameters: Text)
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        RequestMessage: HttpRequestMessage;
        ListCashRegisterReceiptsErr: Label 'List Cash Register Receipts failed.';
        ListCashRegisterReceiptsLbl: Label 'cash-register/%1/receipt', Locked = true, Comment = '%1 - Cash Register Id value';
        ResponseText: Text;
        Url: Text;
    begin
        ATCashRegister.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATCashRegister.SystemId);
        ATCashRegister.TestField("AT SCU Code");
        ATSCU.Get(ATCashRegister."AT SCU Code");
        ATOrganization.GetWithCheck(ATSCU."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(ListCashRegisterReceiptsLbl, Format(ATCashRegister.SystemId, 0, 4).ToLower()) + QueryParameters);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::GET);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', ListCashRegisterReceiptsErr, GetLastErrorText());

        PopulateATPOSAuditLogAuxInfoForListCashRegisterReceipts(ATCashRegister, ATAuditEntryType, ResponseText);
    end;

    internal procedure GetListOtherCashRegisterControlReceiptsQueryParameters() QueryParameters: Text
    var
        QueryParameterAlreadyAdded: Boolean;
    begin
        QueryParameters += CreateQueryParameter(QueryParameterAlreadyAdded, 'receipt_types[1]', Enum::"NPR AT Receipt Type".Names().Get(Enum::"NPR AT Receipt Type".Ordinals().IndexOf(Enum::"NPR AT Receipt Type"::MONTHLY_CLOSE.AsInteger())));
        QueryParameters += CreateQueryParameter(QueryParameterAlreadyAdded, 'receipt_types[2]', Enum::"NPR AT Receipt Type".Names().Get(Enum::"NPR AT Receipt Type".Ordinals().IndexOf(Enum::"NPR AT Receipt Type"::YEARLY_CLOSE.AsInteger())));
        QueryParameters += CreateQueryParameter(QueryParameterAlreadyAdded, 'receipt_types[3]', Enum::"NPR AT Receipt Type".Names().Get(Enum::"NPR AT Receipt Type".Ordinals().IndexOf(Enum::"NPR AT Receipt Type"::SIGNATURE_CREATION_UNIT_FAULT_CLEARANCE.AsInteger())));
    end;

    internal procedure UpdateReceiptMetadata(ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        RequestMessage: HttpRequestMessage;
        UpdateReceiptMetadataErr: Label 'Update Receipt Metadata failed.';
        UpdateReceiptMetadataLbl: Label 'cash-register/%1/receipt/%2/metadata', Locked = true, Comment = '%1 - Cash Register Id value, %2 - Receipt Id value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ATPOSAuditLogAuxInfo.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATPOSAuditLogAuxInfo.SystemId);
        ATPOSAuditLogAuxInfo.TestField("AT Organization Code");
        ATPOSAuditLogAuxInfo.TestField("AT SCU Code");
        ATPOSAuditLogAuxInfo.TestField("AT Cash Register Id");
        CheckIsGUIDAccordingToUUIDv4Standard(ATPOSAuditLogAuxInfo."AT Cash Register Id");
        ATSCU.GetWithCheck(ATPOSAuditLogAuxInfo."AT SCU Code");
        ATOrganization.GetWithCheck(ATPOSAuditLogAuxInfo."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(UpdateReceiptMetadataLbl, Format(ATPOSAuditLogAuxInfo."AT Cash Register Id", 0, 4).ToLower(), Format(ATPOSAuditLogAuxInfo.SystemId, 0, 4).ToLower()));
        JsonBody := CreateJSONBodyForUpdateReceiptMetadata(ATPOSAuditLogAuxInfo);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PATCH);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', UpdateReceiptMetadataErr, GetLastErrorText());
    end;
    #endregion

    #region Export Data Management
    internal procedure ExportCashRegister(ATCashRegister: Record "NPR AT Cash Register"; QueryParameters: Text)
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        RequestMessage: HttpRequestMessage;
        ExportCashRegisterErr: Label 'Export Cash Register failed.';
        ExportCashRegisterLbl: Label 'cash-register/%1/export', Locked = true, Comment = '%1 - Cash Register Id value';
        FileNameLbl: Label '%1.json', Locked = true;
        OutStream: OutStream;
        ResponseText: Text;
        Url: Text;
    begin
        ATCashRegister.TestField(SystemId);
        CheckIsGUIDAccordingToUUIDv4Standard(ATCashRegister.SystemId);
        ATCashRegister.TestField("AT SCU Code");
        ATSCU.Get(ATCashRegister."AT SCU Code");
        ATOrganization.GetWithCheck(ATSCU."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := CreateUrl(ATFiscalizationSetup."Fiskaly API URL", StrSubstNo(ExportCashRegisterLbl, Format(ATCashRegister.SystemId, 0, 4).ToLower()) + QueryParameters);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::GET);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', ExportCashRegisterErr, GetLastErrorText());

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ResponseText);
        FileManagement.BLOBExportWithEncoding(TempBlob, StrSubstNo(FileNameLbl, Format(ATCashRegister.SystemId, 0, 4).ToLower()), true, TextEncoding::UTF8);
    end;

    internal procedure GetExportCashRegisterQueryParameters() QueryParameters: Text
    var
        ATExpCashRegFilters: Page "NPR AT Exp. Cash Reg. Filters";
        QueryParameterAlreadyAdded: Boolean;
        EndSignatureDateTime, StartSignatureDateTime : DateTime;
        EndReceiptNo, StartReceiptNo : Integer;
        EndReceiptNumberCannotBeSmallerFromStartReceiptNumberErr: Label 'End Receipt Number cannot be smaller from Start Receipt Number.';
        ReceiptNumbersCannotBeNegativeErr: Label 'Receipt numbers cannot be negative numbers.';
        StartSignatureDateTimeCannotBeBeforeEndSignatureDateTimeErr: Label 'End Signature DateTime cannot be before Start Signature DateTime.';
    begin
        if ATExpCashRegFilters.RunModal() <> Action::OK then
            Error('');

        StartReceiptNo := ATExpCashRegFilters.GetStartReceiptNo();
        EndReceiptNo := ATExpCashRegFilters.GetEndReceiptNo();
        StartSignatureDateTime := ATExpCashRegFilters.GetStartSignatureDateTime();
        EndSignatureDateTime := ATExpCashRegFilters.GetEndSignatureDateTime();

        if (StartReceiptNo < 0) or (EndReceiptNo < 0) then
            Error(ReceiptNumbersCannotBeNegativeErr);

        if (StartReceiptNo <> 0) and (EndReceiptNo <> 0) and (EndReceiptNo < StartReceiptNo) then
            Error(EndReceiptNumberCannotBeSmallerFromStartReceiptNumberErr);

        if (StartSignatureDateTime <> 0DT) and (EndSignatureDateTime <> 0DT) and (EndSignatureDateTime < StartSignatureDateTime) then
            Error(StartSignatureDateTimeCannotBeBeforeEndSignatureDateTimeErr);

        if (StartReceiptNo = 0) and (EndReceiptNo = 0) and (StartSignatureDateTime = 0DT) and (EndSignatureDateTime = 0DT) then
            exit;

        if StartReceiptNo <> 0 then
            QueryParameters += CreateQueryParameter(QueryParameterAlreadyAdded, 'start_receipt_number', Format(StartReceiptNo));

        if EndReceiptNo <> 0 then
            QueryParameters += CreateQueryParameter(QueryParameterAlreadyAdded, 'end_receipt_number', Format(EndReceiptNo));

        if StartSignatureDateTime <> 0DT then
            QueryParameters += CreateQueryParameter(QueryParameterAlreadyAdded, 'start_time_signature', Format(GetUnixTimestamp(StartSignatureDateTime)));

        if EndSignatureDateTime <> 0DT then
            QueryParameters += CreateQueryParameter(QueryParameterAlreadyAdded, 'end_time_signature', Format(GetUnixTimestamp(EndSignatureDateTime)));
    end;
    #endregion

    #region JSON Fiscal Creators
    local procedure CreateJSONBodyForAuthenticateAPI(ATOrganization: Record "NPR AT Organization"; RefreshToken: Text) JsonBody: Text
    var
        JsonTextReaderWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextReaderWriter.WriteStartObject('');

        if RefreshToken <> '' then
            JsonTextReaderWriter.WriteStringProperty('refresh_token', RefreshToken)
        else begin
            JsonTextReaderWriter.WriteStringProperty('api_key', ATSecretMgt.GetSecretKey(ATOrganization.GetAPIKeyName()));
            JsonTextReaderWriter.WriteStringProperty('api_secret', ATSecretMgt.GetSecretKey(ATOrganization.GetAPISecretName()));
        end;

        JsonTextReaderWriter.WriteEndObject();
        JsonBody := JsonTextReaderWriter.GetJSonAsText();
    end;

    local procedure CreateJSONBodyForAuthenticateFON(ATFiscalizationSetup: Record "NPR AT Fiscalization Setup") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('fon_participant_id', ATSecretMgt.GetSecretKey(ATFiscalizationSetup.GetFONParticipantId()));
        JsonTextWriter.WriteStringProperty('fon_user_id', ATSecretMgt.GetSecretKey(ATFiscalizationSetup.GetFONUserId()));
        JsonTextWriter.WriteStringProperty('fon_user_pin', ATSecretMgt.GetSecretKey(ATFiscalizationSetup.GetFONUserPIN()));
        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure CreateJSONBodyForCreateSCU(ATSCU: Record "NPR AT SCU") JsonBody: Text
    var
        CompanyInformation: Record "Company Information";
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        GetCompanyInformationWithCheck(CompanyInformation);

        JsonTextWriter.WriteStartObject('');

        JsonTextWriter.WriteStartObject('legal_entity_id');
        JsonTextWriter.WriteStringProperty('vat_id', CompanyInformation."VAT Registration No.");
        JsonTextWriter.WriteEndObject();

        if CompanyInformation.Name <> '' then
            JsonTextWriter.WriteStringProperty('legal_entity_name', CompanyInformation.Name);

        AddMetadataForCreateSCU(ATSCU, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure AddMetadataForCreateSCU(ATSCU: Record "NPR AT SCU"; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartObject('metadata');
        JsonTextWriter.WriteStringProperty('bc_company_name', CompanyName());
        JsonTextWriter.WriteStringProperty('bc_code', ATSCU.Code);
        JsonTextWriter.WriteStringProperty('bc_description', ATSCU.Description);
        JsonTextWriter.WriteEndObject();
    end;

    local procedure CreateJSONBodyForUpdateSCU(NewState: Enum "NPR AT SCU State") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('state', Enum::"NPR AT SCU State".Names().Get(Enum::"NPR AT SCU State".Ordinals().IndexOf(NewState.AsInteger())));
        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure CreateJSONBodyForCreateCashRegister(ATCashRegister: Record "NPR AT Cash Register") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('description', ATCashRegister.Description);

        AddMetadataForCreateCashRegister(ATCashRegister, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure AddMetadataForCreateCashRegister(ATCashRegister: Record "NPR AT Cash Register"; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartObject('metadata');
        JsonTextWriter.WriteStringProperty('bc_company_name', CompanyName());
        JsonTextWriter.WriteStringProperty('bc_code', ATCashRegister."POS Unit No.");
        JsonTextWriter.WriteStringProperty('bc_description', ATCashRegister.Description);
        JsonTextWriter.WriteStringProperty('bc_scu_code', ATCashRegister."AT SCU Code");
        JsonTextWriter.WriteEndObject();
    end;

    local procedure CreateJSONBodyForUpdateCashRegister(NewState: Enum "NPR AT Cash Register State") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('state', Enum::"NPR AT Cash Register State".Names().Get(Enum::"NPR AT Cash Register State".Ordinals().IndexOf(NewState.AsInteger())));
        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure CreateJSONBodyForSignReceipt(ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info") JsonBody: Text
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');

        ATFiscalizationSetup.Get();
        if ATFiscalizationSetup.Training then
            JsonTextWriter.WriteStringProperty('receipt_type', Enum::"NPR AT Receipt Type".Names().Get(Enum::"NPR AT Receipt Type".Ordinals().IndexOf(Enum::"NPR AT Receipt Type"::TRAINING.AsInteger())))
        else
            JsonTextWriter.WriteStringProperty('receipt_type', Enum::"NPR AT Receipt Type".Names().Get(Enum::"NPR AT Receipt Type".Ordinals().IndexOf(ATPOSAuditLogAuxInfo."Receipt Type".AsInteger())));

        JsonTextWriter.WriteStartObject('schema');
        JsonTextWriter.WriteStartObject('standard_v1');
        AddAmountsPerVATRateJSONArrayForSignReceipt(JsonTextWriter, ATPOSAuditLogAuxInfo."POS Entry No.");
        AddAmountsPerPaymentTypeJSONArrayForSignReceipt(JsonTextWriter, ATPOSAuditLogAuxInfo."POS Entry No.");
        AddLineItemsJSONArrayForSignReceipt(JsonTextWriter, ATPOSAuditLogAuxInfo."POS Entry No.");
        JsonTextWriter.WriteEndObject(); // standard_v1
        JsonTextWriter.WriteEndObject(); // schema

        AddMetadataForSignReceipt(ATPOSAuditLogAuxInfo, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure AddAmountsPerVATRateJSONArrayForSignReceipt(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; POSEntryNo: Integer)
    var
        ATVATPostingSetupMap: Record "NPR AT VAT Posting Setup Map";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        JsonTextWriter.WriteStartArray('amounts_per_vat_rate');

        POSEntryTaxLine.SetRange("POS Entry No.", POSEntryNo);
        if POSEntryTaxLine.FindSet() then
            repeat
                ATVATPostingSetupMap.SetRange("VAT Identifier", POSEntryTaxLine."VAT Identifier");
                ATVATPostingSetupMap.FindFirst();
                ATVATPostingSetupMap.CheckIsATVATRatePopulated();

                JsonTextWriter.WriteStartObject('');
                JsonTextWriter.WriteStringProperty('vat_rate', Enum::"NPR AT VAT Rate".Names().Get(Enum::"NPR AT VAT Rate".Ordinals().IndexOf(ATVATPostingSetupMap."AT VAT Rate".AsInteger())));
                JsonTextWriter.WriteStringProperty('amount', Format(POSEntryTaxLine."Amount Including Tax", 0, '<Precision,2:2><Standard Format,2>'));
                JsonTextWriter.WriteEndObject();
            until POSEntryTaxLine.Next() = 0;

        JsonTextWriter.WriteEndArray();
    end;

    local procedure AddAmountsPerPaymentTypeJSONArrayForSignReceipt(var JsonTextWriter: Codeunit "Json Text Reader/Writer"; POSEntryNo: Integer)
    var
        Currency: Record Currency;
        ATPOSPaymentMethodMap: Record "NPR AT POS Payment Method Map";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        JsonTextWriter.WriteStartArray('amounts_per_payment_type');

        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntryNo);
        if POSEntryPaymentLine.FindSet() then
            repeat
                ATPOSPaymentMethodMap.Get(POSEntryPaymentLine."POS Payment Method Code");
                ATPOSPaymentMethodMap.CheckIsATPaymentTypePopulated();

                JsonTextWriter.WriteStartObject('');
                JsonTextWriter.WriteStringProperty('payment_type', Enum::"NPR AT Payment Type".Names().Get(Enum::"NPR AT Payment Type".Ordinals().IndexOf(ATPOSPaymentMethodMap."AT Payment Type".AsInteger())));
                JsonTextWriter.WriteStringProperty('amount', Format(POSEntryPaymentLine.Amount, 0, '<Precision,2:26><Standard Format,2>'));

                if POSEntryPaymentLine."Currency Code" <> '' then begin
                    Currency.Get(POSEntryPaymentLine."Currency Code");
                    Currency.TestField("ISO Code");
                    JsonTextWriter.WriteStringProperty('currency_code', Currency."ISO Code");
                end;

                JsonTextWriter.WriteEndObject();
            until POSEntryPaymentLine.Next() = 0;

        JsonTextWriter.WriteEndArray();
    end;

    local procedure AddLineItemsJSONArrayForSignReceipt(var JsonTextReaderWriter: Codeunit "Json Text Reader/Writer"; POSEntryNo: Integer)
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        UnitPrice: Decimal;
    begin
        JsonTextReaderWriter.WriteStartArray('line_items');

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntryNo);
        POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
        POSEntrySalesLine.SetFilter(Quantity, '<>0');
        if POSEntrySalesLine.FindSet() then
            repeat
                JsonTextReaderWriter.WriteStartObject('');
                JsonTextReaderWriter.WriteStringProperty('quantity', Format(Round(POSEntrySalesLine.Quantity, 0.01), 0, '<Precision,0:26><Standard Format,2>'));
                JsonTextReaderWriter.WriteStringProperty('text', POSEntrySalesLine.Description);
                UnitPrice := Abs(Round(POSEntrySalesLine."Amount Incl. VAT" / POSEntrySalesLine.Quantity, 0.01));
                JsonTextReaderWriter.WriteStringProperty('price_per_unit', Format(UnitPrice, 0, '<Precision,2:5><Standard Format,2>'));
                JsonTextReaderWriter.WriteEndObject();
            until POSEntrySalesLine.Next() = 0;

        JsonTextReaderWriter.WriteEndArray();
    end;

    local procedure CreateJSONBodyForUpdateReceiptMetadata(ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('bc_company_name', CompanyName());
        JsonTextWriter.WriteStringProperty('bc_cash_register_code', ATPOSAuditLogAuxInfo."POS Unit No.");
        JsonTextWriter.WriteStringProperty('bc_scu_code', ATPOSAuditLogAuxInfo."AT SCU Code");
        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure CreateJSONBodyForSignControlReceipt(ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info") JsonBody: Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('receipt_type', Enum::"NPR AT Receipt Type".Names().Get(Enum::"NPR AT Receipt Type".Ordinals().IndexOf(ATPOSAuditLogAuxInfo."Receipt Type".AsInteger())));

        JsonTextWriter.WriteStartObject('schema');
        JsonTextWriter.WriteStartObject('standard_v1');
        AddAmountsPerVATRateJSONArrayForSignControlReceipt(JsonTextWriter);
        AddLineItemsJSONArrayForSignControlReceipt(JsonTextWriter);
        JsonTextWriter.WriteEndObject(); // standard_v1
        JsonTextWriter.WriteEndObject(); // schema

        AddMetadataForSignReceipt(ATPOSAuditLogAuxInfo, JsonTextWriter);

        JsonTextWriter.WriteEndObject();
        JsonBody := JsonTextWriter.GetJSonAsText();
    end;

    local procedure AddAmountsPerVATRateJSONArrayForSignControlReceipt(var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartArray('amounts_per_vat_rate');
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('vat_rate', Enum::"NPR AT VAT Rate".Names().Get(Enum::"NPR AT VAT Rate".Ordinals().IndexOf(Enum::"NPR AT VAT Rate"::ZERO.AsInteger())));
        JsonTextWriter.WriteStringProperty('amount', Format(0.00, 0, '<Precision,2:2><Standard Format,2>'));
        JsonTextWriter.WriteEndObject();
        JsonTextWriter.WriteEndArray();
    end;

    local procedure AddLineItemsJSONArrayForSignControlReceipt(var JsonTextReaderWriter: Codeunit "Json Text Reader/Writer")
    var
        ATAuditMgt: Codeunit "NPR AT Audit Mgt.";
    begin
        JsonTextReaderWriter.WriteStartArray('line_items');
        JsonTextReaderWriter.WriteStartObject('');
        JsonTextReaderWriter.WriteStringProperty('quantity', Format(1.00, 0, '<Precision,0:26><Standard Format,2>'));
        JsonTextReaderWriter.WriteStringProperty('text', ATAuditMgt.GetControlReceiptItemText());
        JsonTextReaderWriter.WriteStringProperty('price_per_unit', Format(0.00, 0, '<Precision,2:5><Standard Format,2>'));
        JsonTextReaderWriter.WriteEndObject();
        JsonTextReaderWriter.WriteEndArray();
    end;

    local procedure AddMetadataForSignReceipt(ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; var JsonTextWriter: Codeunit "Json Text Reader/Writer")
    begin
        JsonTextWriter.WriteStartObject('metadata');
        JsonTextWriter.WriteStringProperty('bc_company_name', CompanyName());
        JsonTextWriter.WriteStringProperty('bc_cash_register_code', ATPOSAuditLogAuxInfo."POS Unit No.");
        JsonTextWriter.WriteStringProperty('bc_scu_code', ATPOSAuditLogAuxInfo."AT SCU Code");
        JsonTextWriter.WriteEndObject();
    end;
    #endregion

    #region JSON Fiscal Parsers
    internal procedure PopulateATOrganizationForAuthenticateFON(var ATOrganization: Record "NPR AT Organization"; ResponseText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('authentication_status', PropertyValue);
        ATOrganization.Validate("FON Authentication Status", GetFONAuthenticationStatus(PropertyValue.AsValue().AsText()));

        ResponseJson.SelectToken('time_authentication', PropertyValue);
        ATOrganization."FON Authenticated At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());
        ATOrganization.Modify(true);
    end;

    internal procedure PopulateATOrganizationForRetrieveFONStatus(var ATOrganization: Record "NPR AT Organization"; ResponseText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('authentication_status', PropertyValue);
        ATOrganization.Validate("FON Authentication Status", GetFONAuthenticationStatus(PropertyValue.AsValue().AsText()));

        if ResponseJson.SelectToken('time_authentication', PropertyValue) then
            ATOrganization."FON Authenticated At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ATOrganization.Modify(true);
    end;

    local procedure GetFONAuthenticationStatus(AuthenticationStatus: Text): Enum "NPR AT FON Auth. Status"
    begin
        if Enum::"NPR AT FON Auth. Status".Names().Contains(AuthenticationStatus) then
            exit(Enum::"NPR AT FON Auth. Status".FromInteger(Enum::"NPR AT FON Auth. Status".Ordinals().Get(Enum::"NPR AT FON Auth. Status".Names().IndexOf(AuthenticationStatus))));

        exit(Enum::"NPR AT FON Auth. Status"::" ");
    end;

    internal procedure PopulateATSCUForCreateSCU(var ATSCU: Record "NPR AT SCU"; ResponseText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('state', PropertyValue);
        ATSCU.State := GetATSCUState(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('certificate_serial_number', PropertyValue);
        ATSCU."Certificate Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATSCU."Certificate Serial Number"));

        ResponseJson.SelectToken('time_pending', PropertyValue);
        ATSCU."Pending At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ResponseJson.SelectToken('time_creation', PropertyValue);
        ATSCU."Created At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());
        ATSCU.Modify(true);
    end;

    internal procedure PopulateATSCUForRetrieveSCU(var ATSCU: Record "NPR AT SCU"; ResponseText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('state', PropertyValue);
        ATSCU.State := GetATSCUState(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('certificate_serial_number', PropertyValue);
        ATSCU."Certificate Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATSCU."Certificate Serial Number"));

        ResponseJson.SelectToken('time_pending', PropertyValue);
        ATSCU."Pending At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ResponseJson.SelectToken('time_creation', PropertyValue);
        ATSCU."Created At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('time_initialization', PropertyValue) then
            ATSCU."Initialized At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('time_decommission', PropertyValue) then
            ATSCU."Decommissioned At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ATSCU.Modify(true);
    end;

    internal procedure PopulateATSCUForUpdateSCU(var ATSCU: Record "NPR AT SCU"; ResponseText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('state', PropertyValue);
        ATSCU.State := GetATSCUState(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('certificate_serial_number', PropertyValue);
        ATSCU."Certificate Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATSCU."Certificate Serial Number"));

        ResponseJson.SelectToken('time_pending', PropertyValue);
        ATSCU."Pending At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ResponseJson.SelectToken('time_creation', PropertyValue);
        ATSCU."Created At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ResponseJson.SelectToken('time_initialization', PropertyValue);
        ATSCU."Initialized At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('time_decommission', PropertyValue) then
            ATSCU."Decommissioned At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ATSCU.Modify(true);
    end;

    local procedure PopulateATSCUForListSCUs(ResponseText: Text; ATOrganizationCode: Code[20])
    var
        CompanyInformation: Record "Company Information";
        ATSCU: Record "NPR AT SCU";
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson, SCUObject, SCUObjects : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);
        if not ResponseJson.SelectToken('data', SCUObjects) then
            exit;

        if not SCUObjects.IsArray() then
            exit;

        GetCompanyInformationWithCheck(CompanyInformation);

        foreach SCUObject in SCUObjects.AsArray() do begin
            SCUObject.SelectToken('$.legal_entity_id.vat_id', PropertyValue);
            CompanyInformation.TestField("VAT Registration No.", PropertyValue.AsValue().AsText());

            InsertOrGetATSCU(ATSCU, SCUObject);
            ATSCU."AT Organization Code" := ATOrganizationCode;

            SCUObject.SelectToken('state', PropertyValue);
            ATSCU.State := GetATSCUState(PropertyValue.AsValue().AsText());

            if SCUObject.SelectToken('certificate_serial_number', PropertyValue) then
                ATSCU."Certificate Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATSCU."Certificate Serial Number"));

            SCUObject.SelectToken('time_pending', PropertyValue);
            ATSCU."Pending At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

            if SCUObject.SelectToken('time_creation', PropertyValue) then
                ATSCU."Created At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

            if SCUObject.SelectToken('time_initialization', PropertyValue) then
                ATSCU."Initialized At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

            if SCUObject.SelectToken('time_decommission', PropertyValue) then
                ATSCU."Decommissioned At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

            ATSCU.Modify(true);
        end;
    end;

    local procedure InsertOrGetATSCU(var ATSCU: Record "NPR AT SCU"; var SCUObject: JsonToken)
    var
        SystemId: Guid;
        PropertyValue: JsonToken;
    begin
        SCUObject.SelectToken('_id', PropertyValue);
        SystemId := PropertyValue.AsValue().AsText();
        if not ATSCU.GetBySystemId(SystemId) then begin
            ATSCU.Init();

            SCUObject.SelectToken('$.metadata.bc_code', PropertyValue);
            ATSCU.Code := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(ATSCU.Code));

            SCUObject.SelectToken('$.metadata.bc_description', PropertyValue);
            ATSCU.Description := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(ATSCU.Description));

            ATSCU.SystemId := SystemId;
            ATSCU.Insert(false, true);
        end;
    end;

    local procedure GetATSCUState(State: Text): Enum "NPR AT SCU State"
    begin
        if Enum::"NPR AT SCU State".Names().Contains(State) then
            exit(Enum::"NPR AT SCU State".FromInteger(Enum::"NPR AT SCU State".Ordinals().Get(Enum::"NPR AT SCU State".Names().IndexOf(State))));

        exit(Enum::"NPR AT SCU State"::" ");
    end;

    internal procedure PopulateATCashRegisterForCreateCashRegister(var ATCashRegister: Record "NPR AT Cash Register"; ResponseText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('state', PropertyValue);
        ATCashRegister.State := GetCashRegisterState(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('serial_number', PropertyValue);
        ATCashRegister."Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATCashRegister."Serial Number"));

        if ResponseJson.SelectToken('description', PropertyValue) then
            ATCashRegister.Description := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATCashRegister.Description));

        ResponseJson.SelectToken('time_creation', PropertyValue);
        ATCashRegister."Created At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());
        ATCashRegister.Modify(true);
    end;

    internal procedure PopulateATCashRegisterForRetrieveCashRegister(var ATCashRegister: Record "NPR AT Cash Register"; ResponseText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('state', PropertyValue);
        ATCashRegister.State := GetCashRegisterState(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('serial_number', PropertyValue);
        ATCashRegister."Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATCashRegister."Serial Number"));

        if ResponseJson.SelectToken('description', PropertyValue) then
            ATCashRegister.Description := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATCashRegister.Description));

        ResponseJson.SelectToken('time_creation', PropertyValue);
        ATCashRegister."Created At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('time_registration', PropertyValue) then
            ATCashRegister."Registered At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('time_initialization', PropertyValue) then
            ATCashRegister."Initialized At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('initialization_receipt_id', PropertyValue) then
            ATCashRegister."Initialization Receipt Id" := PropertyValue.AsValue().AsText();

        if ResponseJson.SelectToken('time_decommission', PropertyValue) then
            ATCashRegister."Decommissioned At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('decommission_receipt_id', PropertyValue) then
            ATCashRegister."Decommission Receipt Id" := PropertyValue.AsValue().AsText();

        Clear(ATCashRegister."Outage At");
        if ResponseJson.SelectToken('time_outage', PropertyValue) then
            ATCashRegister."Outage At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('time_defect', PropertyValue) then
            ATCashRegister."Defect At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ATCashRegister.Modify(true);
    end;

    internal procedure PopulateATCashRegisterForUpdateCashRegister(var ATCashRegister: Record "NPR AT Cash Register"; ResponseText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('state', PropertyValue);
        ATCashRegister.State := GetCashRegisterState(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('serial_number', PropertyValue);
        ATCashRegister."Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATCashRegister."Serial Number"));

        if ResponseJson.SelectToken('description', PropertyValue) then
            ATCashRegister.Description := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATCashRegister.Description));

        ResponseJson.SelectToken('time_creation', PropertyValue);
        ATCashRegister."Created At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ResponseJson.SelectToken('time_registration', PropertyValue);
        ATCashRegister."Registered At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('time_initialization', PropertyValue) then
            ATCashRegister."Initialized At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('initialization_receipt_id', PropertyValue) then
            ATCashRegister."Initialization Receipt Id" := PropertyValue.AsValue().AsText();

        if ResponseJson.SelectToken('time_decommission', PropertyValue) then
            ATCashRegister."Decommissioned At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('decommission_receipt_id', PropertyValue) then
            ATCashRegister."Decommission Receipt Id" := PropertyValue.AsValue().AsText();

        Clear(ATCashRegister."Outage At");
        if ResponseJson.SelectToken('time_outage', PropertyValue) then
            ATCashRegister."Outage At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        if ResponseJson.SelectToken('time_defect', PropertyValue) then
            ATCashRegister."Defect At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ATCashRegister.Modify(true);
    end;

    local procedure PopulateATCashRegisterForListCashRegisters(ResponseText: Text)
    var
        ATCashRegister: Record "NPR AT Cash Register";
        ATSCU: Record "NPR AT SCU";
        TypeHelper: Codeunit "Type Helper";
        CashRegisterObject, CashRegisterObjects, PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);
        if not ResponseJson.SelectToken('data', CashRegisterObjects) then
            exit;

        if not CashRegisterObjects.IsArray() then
            exit;

        foreach CashRegisterObject in CashRegisterObjects.AsArray() do begin
            InsertOrGetATCashRegister(ATCashRegister, CashRegisterObject);

            CashRegisterObject.SelectToken('$.metadata.bc_scu_code', PropertyValue);
            ATSCU.Get(PropertyValue.AsValue().AsCode());
            ATCashRegister."AT SCU Code" := CopyStr(ATSCU.Code, 1, MaxStrLen(ATCashRegister."AT SCU Code"));

            CashRegisterObject.SelectToken('state', PropertyValue);
            ATCashRegister.State := GetCashRegisterState(PropertyValue.AsValue().AsText());

            CashRegisterObject.SelectToken('serial_number', PropertyValue);
            ATCashRegister."Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATCashRegister."Serial Number"));

            if CashRegisterObject.SelectToken('description', PropertyValue) then
                ATCashRegister.Description := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATCashRegister.Description));

            CashRegisterObject.SelectToken('time_creation', PropertyValue);
            ATCashRegister."Created At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

            if CashRegisterObject.SelectToken('time_registration', PropertyValue) then
                ATCashRegister."Registered At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

            if CashRegisterObject.SelectToken('time_initialization', PropertyValue) then
                ATCashRegister."Initialized At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

            if CashRegisterObject.SelectToken('initialization_receipt_id', PropertyValue) then
                ATCashRegister."Initialization Receipt Id" := PropertyValue.AsValue().AsText();

            if CashRegisterObject.SelectToken('time_decommission', PropertyValue) then
                ATCashRegister."Decommissioned At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

            if CashRegisterObject.SelectToken('decommission_receipt_id', PropertyValue) then
                ATCashRegister."Decommission Receipt Id" := PropertyValue.AsValue().AsText();

            Clear(ATCashRegister."Outage At");
            if CashRegisterObject.SelectToken('time_outage', PropertyValue) then
                ATCashRegister."Outage At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

            if CashRegisterObject.SelectToken('time_defect', PropertyValue) then
                ATCashRegister."Defect At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

            ATCashRegister.Modify(true);
        end;
    end;

    local procedure InsertOrGetATCashRegister(var ATCashRegister: Record "NPR AT Cash Register"; var CashRegisterObject: JsonToken)
    var
        SystemId: Guid;
        PropertyValue: JsonToken;
    begin
        CashRegisterObject.SelectToken('_id', PropertyValue);
        SystemId := PropertyValue.AsValue().AsText();
        if not ATCashRegister.GetBySystemId(SystemId) then begin
            ATCashRegister.Init();

            CashRegisterObject.SelectToken('$.metadata.bc_code', PropertyValue);
            ATCashRegister."POS Unit No." := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(ATCashRegister."POS Unit No."));

            CashRegisterObject.SelectToken('$.metadata.bc_description', PropertyValue);
            ATCashRegister.Description := CopyStr(PropertyValue.AsValue().AsCode(), 1, MaxStrLen(ATCashRegister.Description));

            ATCashRegister.SystemId := SystemId;
            ATCashRegister.Insert(false, true);
        end;
    end;

    local procedure GetCashRegisterState(State: Text): Enum "NPR AT Cash Register State"
    begin
        if Enum::"NPR AT Cash Register State".Names().Contains(State) then
            exit(Enum::"NPR AT Cash Register State".FromInteger(Enum::"NPR AT Cash Register State".Ordinals().Get(Enum::"NPR AT Cash Register State".Names().IndexOf(State))));

        exit(Enum::"NPR AT Cash Register State"::" ");
    end;

    internal procedure PopulateATPOSAuditLogAuxInfoForValidateReceipt(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; ResponseText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson : JsonToken;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('validation_result', PropertyValue);
        ATPOSAuditLogAuxInfo."FON Receipt Validation Status" := GetFONReceiptValididationStatus(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('time_validation', PropertyValue);
        ATPOSAuditLogAuxInfo."Validated At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());
        ATPOSAuditLogAuxInfo.Modify(true);
    end;

    internal procedure PopulateATPOSAuditLogAuxInfoForSignReceipt(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; ResponseText: Text)
    var
        ATSCU: Record "NPR AT SCU";
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson : JsonToken;
        Hints: Text;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('signature_creation_unit_id', PropertyValue);
        ATPOSAuditLogAuxInfo."AT SCU Id" := PropertyValue.AsValue().AsText();

        ATSCU.GetBySystemId(PropertyValue.AsValue().AsText());
        ATPOSAuditLogAuxInfo."AT SCU Code" := ATSCU.Code;
        ATPOSAuditLogAuxInfo."AT Organization Code" := ATSCU."AT Organization Code";

        ResponseJson.SelectToken('cash_register_id', PropertyValue);
        ATPOSAuditLogAuxInfo."AT Cash Register Id" := PropertyValue.AsValue().AsText();

        ResponseJson.SelectToken('cash_register_serial_number', PropertyValue);
        ATPOSAuditLogAuxInfo."AT Cash Register Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATPOSAuditLogAuxInfo."AT Cash Register Serial Number"));

        ResponseJson.SelectToken('receipt_type', PropertyValue);
        ATPOSAuditLogAuxInfo."Receipt Type" := GetReceiptType(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('receipt_number', PropertyValue);
        ATPOSAuditLogAuxInfo."Receipt Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATPOSAuditLogAuxInfo."Receipt Number"));

        ResponseJson.SelectToken('signed', PropertyValue);
        ATPOSAuditLogAuxInfo.Signed := PropertyValue.AsValue().AsBoolean();

        ResponseJson.SelectToken('time_signature', PropertyValue);
        ATPOSAuditLogAuxInfo."Signed At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ResponseJson.SelectToken('qr_code_data', PropertyValue);
        ATPOSAuditLogAuxInfo.SetQRCode(PropertyValue.AsValue().AsText());

        Hints := GetReceiptHints(ResponseJson);
        ATPOSAuditLogAuxInfo.Hints := CopyStr(Hints, 1, MaxStrLen(ATPOSAuditLogAuxInfo.Hints));

        ATPOSAuditLogAuxInfo.Modify(true);
    end;

    internal procedure PopulateATPOSAuditLogAuxInfoForRetrieveReceipt(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; ResponseText: Text)
    var
        ATSCU: Record "NPR AT SCU";
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson : JsonToken;
        Hints: Text;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('signature_creation_unit_id', PropertyValue);
        ATPOSAuditLogAuxInfo."AT SCU Id" := PropertyValue.AsValue().AsText();

        ATSCU.GetBySystemId(PropertyValue.AsValue().AsText());
        ATPOSAuditLogAuxInfo."AT SCU Code" := ATSCU.Code;
        ATPOSAuditLogAuxInfo."AT Organization Code" := ATSCU."AT Organization Code";

        ResponseJson.SelectToken('cash_register_id', PropertyValue);
        ATPOSAuditLogAuxInfo."AT Cash Register Id" := PropertyValue.AsValue().AsText();

        ResponseJson.SelectToken('cash_register_serial_number', PropertyValue);
        ATPOSAuditLogAuxInfo."AT Cash Register Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATPOSAuditLogAuxInfo."AT Cash Register Serial Number"));

        ResponseJson.SelectToken('receipt_type', PropertyValue);
        ATPOSAuditLogAuxInfo."Receipt Type" := GetReceiptType(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('receipt_number', PropertyValue);
        ATPOSAuditLogAuxInfo."Receipt Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATPOSAuditLogAuxInfo."Receipt Number"));

        ResponseJson.SelectToken('signed', PropertyValue);
        ATPOSAuditLogAuxInfo.Signed := PropertyValue.AsValue().AsBoolean();

        ResponseJson.SelectToken('time_signature', PropertyValue);
        ATPOSAuditLogAuxInfo."Signed At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ResponseJson.SelectToken('qr_code_data', PropertyValue);
        ATPOSAuditLogAuxInfo.SetQRCode(PropertyValue.AsValue().AsText());

        Hints := GetReceiptHints(ResponseJson);
        ATPOSAuditLogAuxInfo.Hints := CopyStr(Hints, 1, MaxStrLen(ATPOSAuditLogAuxInfo.Hints));

        PopulateValidationFieldsOnATPOSAuditLogAuxInfo(ATPOSAuditLogAuxInfo, ResponseJson);

        ATPOSAuditLogAuxInfo.Modify(true);
    end;

    local procedure PopulateATPOSAuditLogAuxInfoForListCashRegisterReceipts(ATCashRegister: Record "NPR AT Cash Register"; ATAuditEntryType: Enum "NPR AT Audit Entry Type"; ResponseText: Text)
    var
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
        ATSCU: Record "NPR AT SCU";
        TypeHelper: Codeunit "Type Helper";
        Inserted: Boolean;
        PropertyValue, ReceiptObject, ReceiptObjects, ResponseJson : JsonToken;
        Hints: Text;
    begin
        ResponseJson.ReadFrom(ResponseText);
        if not ResponseJson.SelectToken('data', ReceiptObjects) then
            exit;

        if not ReceiptObjects.IsArray() then
            exit;

        foreach ReceiptObject in ReceiptObjects.AsArray() do begin
            Inserted := InsertOrGetATPOSAuditLogAuxInfo(ATCashRegister, ATPOSAuditLogAuxInfo, ATAuditEntryType, ReceiptObject);

            ReceiptObject.SelectToken('signature_creation_unit_id', PropertyValue);
            ATPOSAuditLogAuxInfo."AT SCU Id" := PropertyValue.AsValue().AsText();

            ATSCU.GetBySystemId(PropertyValue.AsValue().AsText());
            ATPOSAuditLogAuxInfo."AT SCU Code" := ATSCU.Code;
            ATPOSAuditLogAuxInfo."AT Organization Code" := ATSCU."AT Organization Code";

            ReceiptObject.SelectToken('cash_register_id', PropertyValue);
            ATPOSAuditLogAuxInfo."AT Cash Register Id" := PropertyValue.AsValue().AsText();

            ReceiptObject.SelectToken('cash_register_serial_number', PropertyValue);
            ATPOSAuditLogAuxInfo."AT Cash Register Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATPOSAuditLogAuxInfo."AT Cash Register Serial Number"));

            ReceiptObject.SelectToken('receipt_type', PropertyValue);
            ATPOSAuditLogAuxInfo."Receipt Type" := GetReceiptType(PropertyValue.AsValue().AsText());

            ReceiptObject.SelectToken('receipt_number', PropertyValue);
            ATPOSAuditLogAuxInfo."Receipt Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATPOSAuditLogAuxInfo."Receipt Number"));

            ReceiptObject.SelectToken('signed', PropertyValue);
            ATPOSAuditLogAuxInfo.Signed := PropertyValue.AsValue().AsBoolean();

            ReceiptObject.SelectToken('time_signature', PropertyValue);
            ATPOSAuditLogAuxInfo."Signed At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

            ReceiptObject.SelectToken('qr_code_data', PropertyValue);
            ATPOSAuditLogAuxInfo.SetQRCode(PropertyValue.AsValue().AsText());

            Hints := GetReceiptHints(ReceiptObject);
            ATPOSAuditLogAuxInfo.Hints := CopyStr(Hints, 1, MaxStrLen(ATPOSAuditLogAuxInfo.Hints));

            PopulateValidationFieldsOnATPOSAuditLogAuxInfo(ATPOSAuditLogAuxInfo, ReceiptObject);

            ATPOSAuditLogAuxInfo.Modify(true);

            if Inserted then
                UpdateReceiptMetadata(ATPOSAuditLogAuxInfo);
        end;
    end;

    local procedure InsertOrGetATPOSAuditLogAuxInfo(ATCashRegister: Record "NPR AT Cash Register"; var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; ATAuditEntryType: Enum "NPR AT Audit Entry Type"; var ReceiptObject: JsonToken) Inserted: Boolean;
    var
        POSUnit: Record "NPR POS Unit";
        SystemId: Guid;
        PropertyValue: JsonToken;
    begin
        ReceiptObject.SelectToken('_id', PropertyValue);
        SystemId := PropertyValue.AsValue().AsText();
        if ATPOSAuditLogAuxInfo.GetBySystemId(SystemId) then
            exit;

        ATPOSAuditLogAuxInfo.Init();
        ATPOSAuditLogAuxInfo."Audit Entry Type" := ATAuditEntryType;
        ATPOSAuditLogAuxInfo."Entry Date" := Today();
        POSUnit.Get(ATCashRegister."POS Unit No.");
        ATPOSAuditLogAuxInfo."POS Store Code" := POSUnit."POS Store Code";
        ATPOSAuditLogAuxInfo."POS Unit No." := ATCashRegister."POS Unit No.";
        ATPOSAuditLogAuxInfo.SystemId := SystemId;
        ATPOSAuditLogAuxInfo.Insert(false, true);
        Inserted := true;
    end;

    internal procedure PopulateATPOSAuditLogAuxInfoForSignControlReceipt(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; ResponseText: Text)
    var
        ATSCU: Record "NPR AT SCU";
        TypeHelper: Codeunit "Type Helper";
        PropertyValue, ResponseJson : JsonToken;
        Hints: Text;
    begin
        ResponseJson.ReadFrom(ResponseText);

        ResponseJson.SelectToken('signature_creation_unit_id', PropertyValue);
        ATPOSAuditLogAuxInfo."AT SCU Id" := PropertyValue.AsValue().AsText();

        ATSCU.GetBySystemId(PropertyValue.AsValue().AsText());
        ATPOSAuditLogAuxInfo."AT SCU Code" := ATSCU.Code;
        ATPOSAuditLogAuxInfo."AT Organization Code" := ATSCU."AT Organization Code";

        ResponseJson.SelectToken('cash_register_id', PropertyValue);
        ATPOSAuditLogAuxInfo."AT Cash Register Id" := PropertyValue.AsValue().AsText();

        ResponseJson.SelectToken('cash_register_serial_number', PropertyValue);
        ATPOSAuditLogAuxInfo."AT Cash Register Serial Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATPOSAuditLogAuxInfo."AT Cash Register Serial Number"));

        ResponseJson.SelectToken('receipt_type', PropertyValue);
        ATPOSAuditLogAuxInfo."Receipt Type" := GetReceiptType(PropertyValue.AsValue().AsText());

        ResponseJson.SelectToken('receipt_number', PropertyValue);
        ATPOSAuditLogAuxInfo."Receipt Number" := CopyStr(PropertyValue.AsValue().AsText(), 1, MaxStrLen(ATPOSAuditLogAuxInfo."Receipt Number"));

        ResponseJson.SelectToken('signed', PropertyValue);
        ATPOSAuditLogAuxInfo.Signed := PropertyValue.AsValue().AsBoolean();

        ResponseJson.SelectToken('time_signature', PropertyValue);
        ATPOSAuditLogAuxInfo."Signed At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());

        ResponseJson.SelectToken('qr_code_data', PropertyValue);
        ATPOSAuditLogAuxInfo.SetQRCode(PropertyValue.AsValue().AsText());

        Hints := GetReceiptHints(ResponseJson);
        ATPOSAuditLogAuxInfo.Hints := CopyStr(Hints, 1, MaxStrLen(ATPOSAuditLogAuxInfo.Hints));

        ATPOSAuditLogAuxInfo.Modify(true);
    end;

    local procedure GetFONReceiptValididationStatus(ValidationResult: Text): Enum "NPR AT FON Rcpt. Valid. Status"
    begin
        if Enum::"NPR AT FON Rcpt. Valid. Status".Names().Contains(ValidationResult) then
            exit(Enum::"NPR AT FON Rcpt. Valid. Status".FromInteger(Enum::"NPR AT FON Rcpt. Valid. Status".Ordinals().Get(Enum::"NPR AT FON Rcpt. Valid. Status".Names().IndexOf(ValidationResult))));

        exit(Enum::"NPR AT FON Rcpt. Valid. Status"::" ");
    end;

    local procedure GetReceiptType(ReceiptType: Text): Enum "NPR AT Receipt Type"
    begin
        if Enum::"NPR AT Receipt Type".Names().Contains(ReceiptType) then
            exit(Enum::"NPR AT Receipt Type".FromInteger(Enum::"NPR AT Receipt Type".Ordinals().Get(Enum::"NPR AT Receipt Type".Names().IndexOf(ReceiptType))));

        exit(Enum::"NPR AT Receipt Type"::" ");
    end;

    local procedure PopulateValidationFieldsOnATPOSAuditLogAuxInfo(var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; var ReceiptObject: JsonToken)
    var
        TypeHelper: Codeunit "Type Helper";
        FONValidationObject, FONValidationObjects, PropertyValue : JsonToken;
    begin
        if not ReceiptObject.SelectToken('fon_validations', FONValidationObjects) then
            exit;

        if not FONValidationObjects.IsArray() then
            exit;

        foreach FONValidationObject in FONValidationObjects.AsArray() do begin
            FONValidationObject.SelectToken('validation_result', PropertyValue);
            ATPOSAuditLogAuxInfo."FON Receipt Validation Status" := GetFONReceiptValididationStatus(PropertyValue.AsValue().AsText());

            FONValidationObject.SelectToken('time_validation', PropertyValue);
            ATPOSAuditLogAuxInfo."Validated At" := TypeHelper.EvaluateUnixTimestamp(PropertyValue.AsValue().AsBigInteger());
        end;
    end;

    local procedure GetReceiptHints(var ReceiptObject: JsonToken) Hints: Text
    var
        HintObject: JsonToken;
        HintObjects: JsonToken;
        Hint: Text;
    begin
        if not ReceiptObject.SelectToken('hints', HintObjects) then
            exit;

        if not HintObjects.IsArray() then
            exit;

        foreach HintObject in HintObjects.AsArray() do begin
            HintObject.WriteTo(Hint);
            Hints += Hint.Replace('"', '') + '; ';
        end;

        Hints := Hints.TrimEnd('; ');
    end;
    #endregion

    #region Http Requests - Misc
    local procedure CreateUrl(BaseUrl: Text; Method: Text) Url: Text
    begin
        if BaseUrl.EndsWith('/') then
            Url := BaseUrl + Method
        else
            Url := BaseUrl + '/' + Method;
    end;

    local procedure PrepareHttpRequest(ATOrganization: Record "NPR AT Organization"; SetAuthorization: Boolean; var RequestMessage: HttpRequestMessage; JsonBody: Text; Url: Text; RestMethodToUse: Option GET,POST,DELETE,PATCH,PUT)
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
        RequestMessage.Method(GetRestMethod(RestMethodToUse));
        RequestMessage.GetHeaders(RequestHeaders);

        if not SetAuthorization then
            exit;

        OnBeforeSetAuthorizationOnPrepareHttpRequest(RequestHeaders, IsHandled);
        if IsHandled then
            exit;

        RequestHeaders.Add('Authorization', StrSubstNo(BearerTokenLbl, GetJWT(ATOrganization)));
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

    local procedure GetRestMethod(RestMethodToCheck: Option GET,POST,DELETE,PATCH,PUT): Text
    begin
        case RestMethodToCheck of
            RestMethodToCheck::GET:
                exit('GET');
            RestMethodToCheck::POST:
                exit('POST');
            RestMethodToCheck::DELETE:
                exit('DELETE');
            RestMethodToCheck::PATCH:
                exit('PATCH');
            RestMethodToCheck::PUT:
                exit('PUT');
        end;
    end;

    local procedure CreateQueryParameter(var QueryParameterAlreadyAdded: Boolean; QueryParameterName: Text; QueryParameterValue: Text) QueryParameter: Text
    begin
        if QueryParameterAlreadyAdded then
            QueryParameter := '&'
        else
            QueryParameter := '?';

        QueryParameter += QueryParameterName + '=' + QueryParameterValue;
        QueryParameterAlreadyAdded := true;
    end;
    #endregion

    #region Procedures/Helper Functions
    local procedure GetCompanyInformationWithCheck(var CompanyInformation: Record "Company Information")
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField("VAT Registration No.");
    end;

    local procedure GetUnixTimestamp(DateTime: DateTime): Integer
    var
        DurationMs: BigInteger;
        OriginDateTime: DateTime;
        Duration: Duration;
    begin
        Evaluate(OriginDateTime, '1970-01-01T00:00:00Z', 9);
        Duration := DateTime - OriginDateTime;
        DurationMs := Duration;
        exit((DurationMs / 1000) div 1);
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
    [IntegrationEvent(false, false)]
    local procedure OnAfterRetrieveCashRegister(var ATCashRegister: Record "NPR AT Cash Register")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateCashRegister(var ATCashRegister: Record "NPR AT Cash Register")
    begin
    end;
    #endregion

    #region Automation Test Mockup Helpers
    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetAuthorizationOnPrepareHttpRequest(var RequestHeaders: HttpHeaders; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForAuthenticateFON(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ATOrganization: Record "NPR AT Organization"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForCreateSCU(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ATSCU: Record "NPR AT SCU"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForRetrieveSCU(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ATSCU: Record "NPR AT SCU"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForUpdateSCU(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ATSCU: Record "NPR AT SCU"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForRetrieveFONStatus(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ATOrganization: Record "NPR AT Organization"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForCreateCashRegister(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ATCashRegister: Record "NPR AT Cash Register"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForRetrieveCashRegister(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ATCashRegister: Record "NPR AT Cash Register"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForUpdateCashRegister(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ATCashRegister: Record "NPR AT Cash Register"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForValidateReceipt(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForSignReceipt(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSendHttpRequestForSignControlReceipt(var RequestMessage: HttpRequestMessage; var ResponseText: Text; var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info"; var IsHandled: Boolean)
    begin
    end;
    #endregion
}
