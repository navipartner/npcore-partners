codeunit 6150966 "NPR Sentry Metadata"
{
    Access = Internal;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', true, true)]
    local procedure OnCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        Json: Codeunit "Json Text Reader/Writer";
        Response: JsonObject;
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        if Method <> 'getSentryMetadata' then
            exit;
        Handled := true;

        Json.WriteStartObject('');
        Json.WriteStringProperty('sentryKey', AzureKeyVaultMgt.GetAzureKeyVaultSecret('SentryIODragonglass'));
        Json.WriteStringProperty('sessionRecordAll', SessionRecordingEnabled());
        WriteMetadataJson(Json);
        Json.WriteEndObject();
        Response.ReadFrom(Json.GetJSonAsText());

        Frontend.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    internal procedure WriteMetadataJson(Json: Codeunit "Json Text Reader/Writer")
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        CompanyInformation: Record "Company Information";
        InstalledApp: Record "NAV App Installed App";
        EnvironmentInformation: Codeunit "Environment Information";
        TenantInformation: Codeunit "Tenant Information";
        ActiveSession: Record "Active Session";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        CompanyInformation.Get();

        Json.WriteStringProperty('userId', Format(UserSecurityId(), 0, 4).ToLower());
        Json.WriteStringProperty('tenantId', TenantInformation.GetTenantId());
        Json.WriteStringProperty('tenantDisplayName', TenantInformation.GetTenantDisplayName());
        Json.WriteStringProperty('user', UserId);
        Json.WriteStringProperty('POSUnit', POSUnit."No.");
        Json.WriteStringProperty('POSStore', POSUnit."POS Store Code");
        Json.WriteStringProperty('VATNumber', CompanyInformation."VAT Registration No.");
        if InstalledApp.Get('992c2309-cca4-43cb-9e41-911f482ec088') then begin
            Json.WriteStringProperty('retailAppVersion', StrSubstNo('%1.%2.%3.%4', InstalledApp."Version Major", InstalledApp."Version Minor", InstalledApp."Version Revision", InstalledApp."Version Build"));
        end;
        if InstalledApp.Get('437dbf0e-84ff-417a-965d-ed2bb9650972') then begin
            Json.WriteStringProperty('baseAppVersion', StrSubstNo('%1.%2.%3.%4', InstalledApp."Version Major", InstalledApp."Version Minor", InstalledApp."Version Revision", InstalledApp."Version Build"));
        end;
        Json.WriteStringProperty('companyName', CompanyName());
        case true of
            EnvironmentInformation.IsSandbox():
                Json.WriteStringProperty('environment', 'Sandbox');
            EnvironmentInformation.IsSaaS():
                Json.WriteStringProperty('environment', 'SaaS');
            else
                Json.WriteStringProperty('environment', 'OnPrem');
        end;
        Json.WriteStringProperty('serviceInstanceId', ServiceInstanceId());
        Json.WriteStringProperty('sessionId', SessionId());
        Json.WriteStringProperty('clientType', Format(CurrentClientType()));
        if ActiveSession.Get(ServiceInstanceId(), SessionId()) then begin
            Json.WriteStringProperty('sessionUniqueId', Format(ActiveSession."Session Unique ID", 0, 4).ToLower());
            Json.WriteStringProperty('serverInstanceName', ActiveSession."Server Instance Name");
        end;
        Json.WriteStringProperty('POSType', Format(POSUnit."POS Type"));
    end;

    local procedure SessionRecordingEnabled(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        NavipartnerManaged: Boolean;
    begin
        if EnvironmentInformation.IsSaaS() then begin
            if CheckIfNavipartnerManagedSaaSTenant(NavipartnerManaged) then begin
                exit(NavipartnerManaged);
            end else begin
                exit(false);
            end;
        end;

        exit(true); //onprem
    end;

    [TryFunction]
    local procedure CheckIfNavipartnerManagedSaaSTenant(var IsNaviPartnerManaged: Boolean)
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        Http: HttpClient;
        HttpResponse: HttpResponseMessage;
        Response: Text;
        JSON: JsonObject;
        JToken: JsonToken;
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        Http.Get('https://api.navipartner.dk/customer-mgt/v1/get?subscription-key=' + AzureKeyVaultMgt.GetAzureKeyVaultSecret('CustomerMgtAzureAPI') + '&tenantId=' + AzureADTenant.GetAadTenantId(), HttpResponse);
        HttpResponse.Content.ReadAs(Response);
        JSON.ReadFrom(Response);
        JSON.Get('isNpCustomer', JToken);
        IsNaviPartnerManaged := JToken.AsValue().AsBoolean();
    end;
}