table 6014588 "NPR Replication Service Setup"
{
    Access = Internal;
    Caption = 'Replication API Setup';
    DataClassification = CustomerContent;
    Extensible = true;
    LookupPageId = "NPR Replication Setup Card";

    fields
    {
        field(1; "API Version"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(5; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }
        field(10; "Service URL"; Text[100])
        {
            Caption = 'Service Base URL';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ServiceAPI: Codeunit "NPR Replication API";
            begin
                Rec.TestField(Enabled, false);
                Rec."Service URL" := COPYSTR(ServiceAPI.VerifyServiceURL(Rec."Service URL"), 1, MaxStrLen(Rec."Service URL"));
            end;
        }
        field(15; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                ReplicationAPI: Codeunit "NPR Replication API";
                iAuth: Interface "NPR API IAuthorization";
                AuthParamsBuff: Record "NPR Auth. Param. Buffer";
                WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
            begin
                if Enabled then begin
                    Rec."Service URL" := COPYSTR(ReplicationAPI.VerifyServiceURL(Rec."Service URL"), 1, MaxStrLen(Rec."Service URL"));
                    CheckFromCompany();
                    iAuth := Rec.AuthType;

                    case Rec.AuthType of
                        Rec.AuthType::Basic:
                            WebServiceAuthHelper.GetBasicAuthorizationParamsBuff(Rec.UserName, Rec."API Password Key", AuthParamsBuff);
                        Rec.AuthType::OAuth2:
                            WebServiceAuthHelper.GetOpenAuthorizationParamsBuff(Rec."OAuth2 Setup Code", AuthParamsBuff);
                    end;

                    iAuth.CheckMandatoryValues(AuthParamsBuff);
                    if GuiAllowed Then
                        if not Confirm(EnableServiceConfirm) then
                            Error('');
                    ReplicationAPI.RegisterNcImportType(Rec."API Version");
                    ReplicationAPI.ScheduleJobQueueEntry(Rec);
                end else begin
                    ReplicationAPI.DeleteNcImportType(Rec."API Version");
                    ReplicationAPI.DeleteJobQueueEntries(Rec);
                    ReplicationAPI.DeleteJobQueueCategory();
                end;
            end;
        }
        field(20; AuthType; Enum "NPR API Auth. Type")
        {
            Caption = 'Auth. Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }

        field(25; UserName; Code[50])
        {
            Caption = 'User Name';
            DataClassification = EndUserIdentifiableInformation;
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }

        field(30; "API Password Key"; GUID)
        {
            Caption = 'API Password Key';
            DataClassification = EndUserPseudonymousIdentifiers;
        }

        field(35; "OAuth2 Setup Code"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR OAuth Setup";
            Caption = 'OAuth2.0 Setup Code';
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }

        field(40; FromCompany; Text[30])
        {
            Caption = 'From Company';
            DataClassification = CustomerContent;
            TableRelation = Company.Name;

            trigger OnLookup()
            var
                CompanyRec: Record Company;
                CompaniesPage: Page Companies;
            begin
                Rec.TestField(Enabled, false);
                CompanyRec.SetFilter(Name, '<>%1', CompanyName);
                CompaniesPage.SetTableView(CompanyRec);
                CompaniesPage.LookupMode(true);
                if CompaniesPage.RunModal() = Action::LookupOK then begin
                    CompaniesPage.GetRecord(CompanyRec);
                    Rec.Validate(FromCompany, CompanyRec.Name);
                end;
            end;

            trigger OnValidate()
            var
                UseDifferentCompanyErr: Label 'From Company must be different than current company';
            begin
                if FromCompany = CompanyName then
                    Error(UseDifferentCompanyErr);
            end;

        }
        field(41; FromCompanyID; Guid)
        {
            Caption = 'From Company ID';
            FieldClass = FlowField;
            CalcFormula = lookup(Company.Id WHERE(Name = FIELD(FromCompany)));
            Editable = False;
        }

        field(42; "External Database"; Boolean)
        {
            Caption = 'External Database';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                EmptyGUID: Guid;
            begin
                Rec.TestField(Enabled, false);
                if Rec."External Database" then begin
                    CheckBaseURLIsExternalOrInternal(true);
                    Rec.FromCompany := '';
                end Else begin
                    CheckBaseURLIsExternalOrInternal(false);
                    Rec."From Company Name - External" := '';
                    Rec."From Company ID - External" := EmptyGUID;
                end;
                Rec."From Company Tenant" := '';
            end;
        }
        field(43; "From Company Name - External"; Text[30])
        {
            Caption = 'From Company Name';
            DataClassification = CustomerContent;
            Editable = False;
        }

        field(44; "From Company ID - External"; GUID)
        {
            Caption = 'External Database';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(45; "From Company Tenant"; Text[50])
        {
            Caption = 'From Company Tenant';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }

        field(50; JobQueueStartTime; Time)
        {
            Caption = 'Job Queue Starting Time';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }

        field(51; JobQueueEndTime; Time)
        {
            Caption = 'Job Queue Ending Time';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }

        field(52; JobQueueMinutesBetweenRun; Integer)
        {
            Caption = 'Job Queue No. of Min. Between Runs';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }

        field(55; JobQueueProcessImportList; Boolean)
        {
            Caption = 'Add process_import_list param';
            DataClassification = CustomerContent;
            InitValue = true;
            trigger OnValidate()
            begin
                Rec.TestField(Enabled, false);
            end;
        }

        field(60; "Error Notify Email Address"; Text[100])
        {
            Caption = 'Error Notification Email Address';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "API Version")
        {
            Clustered = true;
        }
    }

    var
        RenameNotAllowedErr: Label 'Rename not allowed. Instead, delete and recreate record.';
        ExternalURLErr: Label 'Service Base URL must refer to an external database.', Locked = true;
        InternalURLErr: Label 'Service Base URL must refer to internal database.', Locked = true;
        EnableServiceConfirm: Label 'Are you sure you want to enable service? This action will start importing from Source Company all data created or modified with a Replication Counter greater than the one setup for each Endpoint.';

    trigger OnDelete()
    var
        ServiceEndPoint: Record "NPR Replication Endpoint";
        ReplicationAPI: Codeunit "NPR Replication API";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        ServiceEndPoint.Setrange("Service Code", Rec."API Version");
        if not ServiceEndPoint.IsEmpty() then
            ServiceEndPoint.DeleteAll(true);

        ReplicationAPI.DeleteNcImportType(Rec."API Version");
        ReplicationAPI.DeleteJobQueueEntries(Rec);
        ReplicationAPI.DeleteJobQueueCategory();

        if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
            WebServiceAuthHelper.RemoveApiPassword("API Password Key");
    end;

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr);
    end;

    procedure RegisterService(pAPIVersion: Code[20]; pServiceUrl: Text[100]; pName: Text[100]; pEnabled: Boolean; pAuthType: Enum "NPR API Auth. Type"; pTenant: Text[50])
    begin
        Rec."API Version" := pAPIVersion;
        if Rec.FIND() then
            Exit;

        Rec.Init();
        Rec."Service URL" := pServiceUrl;
        Rec.Name := pName;
        Rec.Enabled := pEnabled;
        Rec.AuthType := pAuthType;
        Rec."From Company Tenant" := pTenant;
        Rec.JobQueueStartTime := 070000T;
        Rec.JobQueueEndTime := 230000T;
        Rec.JobQueueMinutesBetweenRun := 10;
        Rec.JobQueueProcessImportList := true;

        OnRegisterServiceOnBeforeInsert();

        Rec.Insert(true);

    end;

    procedure CopyEndpointsFromAnotherVersion()
    var
        ReplicationSetupList: Page "NPR Replication Setup List";
        ReplicationSetup: Record "NPR Replication Service Setup";
        ReplicationEndpoint: Record "NPR Replication Endpoint";
        ReplicationEndpoint2: Record "NPR Replication Endpoint";
        SpecialFieldMapping: Record "NPR Rep. Special Field Mapping";
    begin
        ReplicationSetupList.LookupMode(true);
        ReplicationSetup.SetFilter("API Version", '<>%1', Rec."API Version");
        if ReplicationSetup.IsEmpty then
            exit; // nothing to copy from

        ReplicationSetupList.SetTableView(ReplicationSetup);
        if ReplicationSetupList.RunModal() = Action::LookupOK then begin
            ReplicationSetupList.GetRecord(ReplicationSetup);
            ReplicationEndpoint.SetRange("Service Code", ReplicationSetup."API Version");
            if ReplicationEndpoint.FindSet() then
                repeat
                    ReplicationEndpoint2.SetRange("Service Code", Rec."API Version");
                    ReplicationEndpoint2.SetRange("EndPoint ID", ReplicationEndpoint."EndPoint ID");
                    if ReplicationEndpoint2.IsEmpty then begin
                        ReplicationEndpoint2.Init();
                        ReplicationEndpoint2 := ReplicationEndpoint;
                        ReplicationEndpoint2."Service Code" := Rec."API Version";
                        ReplicationEndpoint2."Replication Counter" := 0;
                        ReplicationEndpoint2.Insert(true);
                        SpecialFieldMapping.CopyFromEndpointToEndpoint(ReplicationEndpoint, ReplicationEndpoint2);
                    end;
                until ReplicationEndpoint.Next() = 0;
        end;
    end;

    procedure FillExternalCompany()
    var
        TempCompany: Record Company temporary;
    begin
        Rec.TestField(Enabled, false);
        Rec.TestField("Service URL");
        if GetExternalCompany(TempCompany) then begin
            Rec.Validate("From Company Name - External", TempCompany.Name);
            Rec.Validate("From Company ID - External", TempCompany.Id);
        end;
    end;

    local procedure CheckBaseURLIsExternalOrInternal(checkExternal: Boolean)
    begin
        if Rec."Service URL" = '' then
            exit;

        if LowerCase(Rec."Service URL") = LowerCase(GetUrl(ClientType::Api).TrimEnd('/')) then begin
            if checkExternal then
                Error(ExternalURLErr);
        end else
            if not checkExternal then
                Error(InternalURLErr);
    end;

    procedure GetExternalCompany(var TempCompany: Record Company temporary): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        Client: HttpClient;
        [NonDebuggable]
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        URI: Text;
        ErrorTxt: Text;
        StatusCode: Integer;
        ResponseText: Text;
        JToken: JsonToken;
        JArray: JsonArray;
        i: Integer;
    begin
        TempCompany.Reset();
        if not TempCompany.IsEmpty then
            TempCompany.DeleteAll();

        RequestMessage.Method := 'GET';
        URI := Rec."Service URL" + '/v2.0/companies';
        AddTenantToURL(URI);

        RequestMessage.SetRequestUri(URI);
        RequestMessage.GetHeaders(Headers);

        Rec.SetRequestHeadersAuthorization(Headers);

        if not ReplicationAPI.IsSuccessfulRequest(Client.Send(RequestMessage, ResponseMessage), ResponseMessage, ErrorTxt, StatusCode) then
            Error(ErrorTxt);

        ResponseMessage.Content.ReadAs(ResponseText);
        if not JToken.ReadFrom(ResponseText) then
            Exit;

        if not JToken.SelectToken('$.value', JToken) then
            exit;

        JArray := JToken.AsArray();
        for i := 0 to JArray.Count - 1 do begin
            JArray.Get(i, JToken);
            TempCompany.Init();
            TempCompany.Name := CopyStr(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.name'), 1, MaxStrLen(TempCompany.Name));
            TempCompany.Id := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');
            TempCompany.Insert();
        end;

        if Page.RunModal(Page::Companies, TempCompany) = Action::LookupOK then begin
            exit(true);
        end;
    end;

    procedure GetCompanyId(): Text
    begin
        if not Rec."External Database" then begin
            Rec.CalcFields(FromCompanyID); // HQ company in same database
            exit(Format(Rec.FromCompanyID, 0, 4));
        end else // HQ company in another BC database
            exit(Format(Rec."From Company ID - External", 0, 4));
    end;

    procedure TestConnection()
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        Client: HttpClient;
        [NonDebuggable]
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        URI: Text;
        ErrorTxt: Text;
        StatusCode: Integer;
        ResponseText: Text;
        Response: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        Rec."Service URL" := COPYSTR(ReplicationAPI.VerifyServiceURL(Rec."Service URL"), 1, MaxStrLen(Rec."Service URL"));
        CheckFromCompany();

        RequestMessage.Method := 'GET';
        URI := Rec."Service URL" + '/v2.0/companies';
        AddTenantToURL(URI);

        RequestMessage.SetRequestUri(URI);
        RequestMessage.GetHeaders(Headers);

        Rec.SetRequestHeadersAuthorization(Headers);

        if not ReplicationAPI.IsSuccessfulRequest(Client.Send(RequestMessage, ResponseMessage), ResponseMessage, ErrorTxt, StatusCode) then
            Error(ErrorTxt);

        ResponseMessage.Content.ReadAs(ResponseText);
        Response.CreateOutStream(OutStr);
        OutStr.WriteText(ResponseText);

        if ReplicationAPI.FoundErrorInResponse(Response, StatusCode) then
            Error(ResponseText)
        else
            Message('Connection OK.');
    end;

    local procedure CheckFromCompany()
    begin
        if not Rec."External Database" then
            Rec.TestField(FromCompany)
        Else begin
            Rec.TestField("From Company Name - External");
            Rec.TestField("From Company ID - External");
        end;
    end;

    procedure AddTenantToURL(var URI: Text)
    begin
        if Rec."From Company Tenant" <> '' then begin
            if StrPos(URI, '/?') > 0 then
                URI += '&tenant=' + Rec."From Company Tenant"
            else
                URI += '/?tenant=' + "From Company Tenant";
        end;
    end;

    procedure SetRequestHeadersAuthorization(var RequestHeaders: HttpHeaders)
    var
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        iAuth: Interface "NPR API IAuthorization";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        iAuth := Rec.AuthType;
        case Rec.AuthType of
            Rec.AuthType::Basic:
                WebServiceAuthHelper.GetBasicAuthorizationParamsBuff(Rec.UserName, Rec."API Password Key", AuthParamsBuff);
            Rec.AuthType::OAuth2:
                WebServiceAuthHelper.GetOpenAuthorizationParamsBuff(Rec."OAuth2 Setup Code", AuthParamsBuff);
        end;
        iAuth.CheckMandatoryValues(AuthParamsBuff);
        iAuth.SetAuthorizationValue(RequestHeaders, AuthParamsBuff);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnRegisterServiceOnBeforeInsert()
    begin
    end;

    [IntegrationEvent(true, false)]
    procedure OnRegisterService()
    begin
    end;
}

