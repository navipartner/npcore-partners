codeunit 6150743 "NPR POS Geolocation"
{
    // Usage note:
    //   Geolocation is logged once per POS session.
    //   If you want geolocation to be logged only once per NAV session, make this codeunit single-instance.
    //   If you want geolocation logged once per NAV session regardless of if POS was loaded or not, then
    //   apart from making this codeunit single-instance, you should also invoke the SetGeolocationLogged(TRUE);

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        NPRetailSetup: Record "NPR NP Retail Setup";
        FrontEnd: Codeunit "NPR POS Front End Management";
        GeolocationLogged: Boolean;

    // POS
    [EventSubscriber(ObjectType::Codeunit, 6150700, 'OnInitializationComplete', '', false, false)]
    local procedure OnAfterInitialize(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        if SkipGeolocationTracking() then
            exit;

        RegisterGeoLocationScript(FrontEnd);
    end;

    procedure SkipGeolocationTracking(): Boolean
    begin
        if GeolocationLogged then
            exit(true);

        if (not NPRetailSetup.Get) or (not NPRetailSetup."Enable Client Diagnostics") then begin
            GeolocationLogged := true;
            exit(true);
        end;

        exit(false);
    end;

    local procedure RegisterGeoLocationScript(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        RegisterModuleRequest: Codeunit "NPR Front-End: Generic";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        ScriptString: Text;
        WebClientDependency: Record "NPR Web Client Dependency";
    begin
        RegisterModuleRequest.SetMethod('RegisterModule');
        RegisterModuleRequest.GetContent().Add('Name', 'GeoLocationByIP');
        ScriptString := '(function() {' +
        ' var geolocation = new n$.Event.Method("GeoLocationMethod"); ' +
        ' $.ajax({' +
        '   url: "https://api.ipstack.com/check?access_key=' + AzureKeyVaultMgt.GetSecret('IPStackApiKey') + '",' +
        '   success: function (result) {' +
        '     geolocation.raise({ result: result });' +
        '   },' +
        '   error: function (xhr, ajaxOptions, thrownError) {' +
        '     geolocation.raise({ error: xhr.responseText });' +
        '   }' +
        '});' +
        '})()';

        RegisterModuleRequest.GetContent().Add('Script', ScriptString);
        FrontEnd.InvokeFrontEndMethod(RegisterModuleRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnCustomMethod', '', false, false)]
    local procedure OnCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        ClientDiagnosticsDataMgt: Codeunit "NPR Client Diag. Data Mgt.";
        JSON: Codeunit "NPR POS JSON Management";
        ErrorText: Text;
    begin
        if Method <> 'GeoLocationMethod' then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        ErrorText := JSON.GetString('error', false);
        if ErrorText <> '' then
            exit;

        TrackGeoLocationByIP(JSON.GetString('result', true));
    end;

    procedure TrackGeoLocationByIP(IPAddress: Text)
    begin
        if SkipGeolocationTracking() then
            exit;

        GeolocationLogged := true;
        OnTrackGeoLocationByIP(IPAddress);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTrackGeoLocationByIP(IPAddress: Text)
    begin
    end;

    // Convert
    procedure IPAddress2GeoPosition(IPAddress: Text; var Latitude: Decimal; var Longitude: Decimal)
    var
        Parameters: DotNet NPRNetDictionary_Of_T_U;
        AFManagement: Codeunit "NPR AF Management";
        AFHelperFunctions: Codeunit "NPR AF Helper Functions";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        HttpResponseMessage: DotNet NPRNetHttpResponseMessage;
        Path: Text;
        JObject: JsonObject;
        StringContent: DotNet NPRNetStringContent;
        TextString: Text;
        Encoding: DotNet NPRNetEncoding;
        ResultVar: Boolean;
        PrevRec: Text;
        BaseUrl: Text;
    begin
        if IPAddress = '' then
            exit;

        JObject.Add('clientIp', IPAddress);
        JObject.WriteTo(TextString);
        StringContent := StringContent.StringContent(TextString, Encoding.UTF8, 'application/json');

        BaseUrl := AzureKeyVaultMgt.GetSecret('AFIP2GeoBaseUrl');
        Parameters := Parameters.Dictionary();

        Parameters.Add('baseurl', BaseUrl);
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('path', StrSubstNo('%1/api/GetClientGeoLocationByIPAddress?code=$2', BaseUrl, AzureKeyVaultMgt.GetSecret('AFIP2GeoKey')));
        Parameters.Add('httpcontent', StringContent);

        ResultVar := AFManagement.CallRESTWebService(Parameters, HttpResponseMessage);
        if not ResultVar then
            exit;

        TextString := HttpResponseMessage.Content.ReadAsStringAsync.Result;
        if TextString = '' then
            exit;

        if not TryParseJson(TextString, JObject) then
            exit;

        Latitude := GetJsonValueAsDecimal(JObject, 'lat');
        Longitude := GetJsonValueAsDecimal(JObject, 'lon');
    end;

    local procedure GetJsonValueAsDecimal(JObject: JsonObject; PropertyName: Text) ReturnValue: Decimal
    var
        CultureInfo: DotNet NPRNetCultureInfo;
        JToken: JsonToken;
    begin
        JObject.Get(PropertyName, JToken);
        ReturnValue := JToken.AsValue().AsDecimal();
    end;

    [TryFunction]
    local procedure TryParseJson(json: Text; var JObject: JsonObject)
    begin
        Clear(JObject);
        JObject.ReadFrom(json);
    end;
}