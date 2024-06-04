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

        Url := ATFiscalizationSetup."Fiskaly API URL" + AuthenticateAPILbl;
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

        Url := ATFiscalizationSetup."Fiskaly API URL" + AuthenticateFONLbl;
        JsonBody := CreateJSONBodyForAuthenticateFON(ATFiscalizationSetup);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PUT);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', AuthenticateFONErr, GetLastErrorText());

        PopulateATOrganizationForAuthenticateFON(ATOrganization, ResponseText);
    end;

    internal procedure RetrieveFONStatus(var ATOrganization: Record "NPR AT Organization")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        RequestMessage: HttpRequestMessage;
        RetrieveFONStatusErr: Label 'Retrieve FinanzOnline authentication status failed.';
        RetrieveFONStatusLbl: Label 'fon/auth', Locked = true;
        ResponseText: Text;
        Url: Text;
    begin
        ATOrganization.TestField(SystemId);
        ATOrganization.CheckIsFONAuthenticationStatusNotAuthenticated();
        ATFiscalizationSetup.GetWithCheck();

        Url := ATFiscalizationSetup."Fiskaly API URL" + RetrieveFONStatusLbl;
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::GET);

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
        RequestMessage: HttpRequestMessage;
        CreateSCUErr: Label 'Create Signature Creation Unit failed.';
        CreateSCULbl: Label 'signature-creation-unit/%1', Locked = true, Comment = '%1 - Signature Creation Unit Id value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ATSCU.TestField(SystemId);
        ATSCU.TestField(Description);
        ATSCU.TestField("AT Organization Code");
        ATSCU.TestField("Created At", 0DT);
        ATSCU.IsThereAnyOtherActiveSCUForThisOrganization();
        ATOrganization.GetWithCheck(ATSCU."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := ATFiscalizationSetup."Fiskaly API URL" + StrSubstNo(CreateSCULbl, Format(ATSCU.SystemId, 0, 4).ToLower());
        JsonBody := CreateJSONBodyForCreateSCU(ATSCU);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PUT);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', CreateSCUErr, GetLastErrorText());

        PopulateATSCUForCreateSCU(ATSCU, ResponseText);
    end;

    internal procedure RetrieveSCU(var ATSCU: Record "NPR AT SCU")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        RequestMessage: HttpRequestMessage;
        RetrieveSCUErr: Label 'Retrieve Signature Creation Unit failed.';
        RetrieveSCULbl: Label 'signature-creation-unit/%1', Locked = true, Comment = '%1 - Signature Creation Unit Id value';
        ResponseText: Text;
        Url: Text;
    begin
        ATSCU.TestField(SystemId);
        ATSCU.TestField("AT Organization Code");
        ATSCU.IsThereAnyOtherActiveSCUForThisOrganization();
        ATOrganization.GetWithCheck(ATSCU."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := ATFiscalizationSetup."Fiskaly API URL" + StrSubstNo(RetrieveSCULbl, Format(ATSCU.SystemId, 0, 4).ToLower());
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::GET);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', RetrieveSCUErr, GetLastErrorText());

        PopulateATSCUForRetrieveSCU(ATSCU, ResponseText);
    end;

    internal procedure UpdateSCU(var ATSCU: Record "NPR AT SCU"; NewState: Enum "NPR AT SCU State")
    var
        ATCashRegister: Record "NPR AT Cash Register";
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
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

        Url := ATFiscalizationSetup."Fiskaly API URL" + StrSubstNo(UpdateSCULbl, Format(ATSCU.SystemId, 0, 4).ToLower());
        JsonBody := CreateJSONBodyForUpdateSCU(NewState);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PATCH);

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

        Url := ATFiscalizationSetup."Fiskaly API URL" + ListSCUsLbl;
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
        RequestMessage: HttpRequestMessage;
        CreateCashRegisterErr: Label 'Create Cash Register failed.';
        CreateCashRegisterLbl: Label 'cash-register/%1', Locked = true, Comment = '%1 - Cash Register Id value';
        JsonBody: Text;
        ResponseText: Text;
        Url: Text;
    begin
        ATCashRegister.TestField(SystemId);
        ATCashRegister.TestField(Description);
        ATCashRegister.TestField("AT SCU Code");
        ATCashRegister.TestField("Created At", 0DT);
        ATSCU.GetWithCheck(ATCashRegister."AT SCU Code");
        ATOrganization.GetWithCheck(ATSCU."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := ATFiscalizationSetup."Fiskaly API URL" + StrSubstNo(CreateCashRegisterLbl, Format(ATCashRegister.SystemId, 0, 4).ToLower());
        JsonBody := CreateJSONBodyForCreateCashRegister(ATCashRegister);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PUT);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', CreateCashRegisterErr, GetLastErrorText());

        PopulateATCashRegisterForCreateCashRegister(ATCashRegister, ResponseText);
    end;

    internal procedure RetrieveCashRegister(var ATCashRegister: Record "NPR AT Cash Register")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATOrganization: Record "NPR AT Organization";
        ATSCU: Record "NPR AT SCU";
        RequestMessage: HttpRequestMessage;
        CreateCashRegisterErr: Label 'Retrieve Cash Register failed.';
        CreateCashRegisterLbl: Label 'cash-register/%1', Locked = true, Comment = '%1 - Cash Register Id value';
        ResponseText: Text;
        Url: Text;
    begin
        ATCashRegister.TestField(SystemId);
        ATCashRegister.TestField("AT SCU Code");
        ATSCU.GetWithCheck(ATCashRegister."AT SCU Code");
        ATOrganization.GetWithCheck(ATSCU."AT Organization Code");
        ATFiscalizationSetup.GetWithCheck();

        Url := ATFiscalizationSetup."Fiskaly API URL" + StrSubstNo(CreateCashRegisterLbl, Format(ATCashRegister.SystemId, 0, 4).ToLower());
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::GET);

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

        Url := ATFiscalizationSetup."Fiskaly API URL" + StrSubstNo(UpdateCashRegisterLbl, Format(ATCashRegister.SystemId, 0, 4).ToLower());
        JsonBody := CreateJSONBodyForUpdateCashRegister(NewState);
        PrepareHttpRequest(ATOrganization, true, RequestMessage, JsonBody, Url, RestMethod::PATCH);

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

        Url := ATFiscalizationSetup."Fiskaly API URL" + ListCashRegistersLbl;
        PrepareHttpRequest(ATOrganization, true, RequestMessage, '', Url, RestMethod::GET);

        if not SendHttpRequest(RequestMessage, ResponseText) then
            Error('%1\\%2', ListCashRegistersErr, ResponseText);

        PopulateATCashRegisterForListCashRegisters(ResponseText);
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
    #endregion

    #region JSON Fiscal Parsers
    local procedure PopulateATOrganizationForAuthenticateFON(var ATOrganization: Record "NPR AT Organization"; ResponseText: Text)
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

    local procedure PopulateATOrganizationForRetrieveFONStatus(var ATOrganization: Record "NPR AT Organization"; ResponseText: Text)
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

    local procedure PopulateATSCUForCreateSCU(var ATSCU: Record "NPR AT SCU"; ResponseText: Text)
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

    local procedure PopulateATSCUForRetrieveSCU(var ATSCU: Record "NPR AT SCU"; ResponseText: Text)
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

    local procedure PopulateATSCUForUpdateSCU(var ATSCU: Record "NPR AT SCU"; ResponseText: Text)
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

    local procedure PopulateATCashRegisterForCreateCashRegister(var ATCashRegister: Record "NPR AT Cash Register"; ResponseText: Text)
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

    local procedure PopulateATCashRegisterForRetrieveCashRegister(var ATCashRegister: Record "NPR AT Cash Register"; ResponseText: Text)
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

    local procedure PopulateATCashRegisterForUpdateCashRegister(var ATCashRegister: Record "NPR AT Cash Register"; ResponseText: Text)
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
    #endregion

    #region Http Requests - Misc
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

    local procedure PrepareHttpRequest(ATOrganization: Record "NPR AT Organization"; SetAuthorization: Boolean; var RequestMessage: HttpRequestMessage; JsonBody: Text; Url: Text; RestMethodToUse: Option GET,POST,DELETE,PATCH,PUT)
    var
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
        if SetAuthorization then
            RequestHeaders.Add('Authorization', StrSubstNo(BearerTokenLbl, GetJWT(ATOrganization)));
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
    #endregion

    #region Procedures/Helper Functions
    local procedure GetCompanyInformationWithCheck(var CompanyInformation: Record "Company Information")
    begin
        CompanyInformation.Get();
        CompanyInformation.TestField("VAT Registration No.");
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
}
