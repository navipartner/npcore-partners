codeunit 6150743 "NPR POS Geolocation"
{
    // NPR5.40/VB  /20180227  CASE 306242 Geolocation logging through Transcendence framework.
    //                                    Usage note:
    //                                      Geolocation is logged once per POS session.
    //                                      If you want geolocation to be logged only once per NAV session, make this codeunit single-instance.
    //                                      If you want geolocation logged once per NAV session regardless of if POS was loaded or not, then
    //                                      apart from making this codeunit single-instance, you should also invoke the SetGeolocationLogged(TRUE);
    // NPR5.40/MHA /20180328  CASE 308907 Added Publisher function OnTrackGeoLocationByIP() and changed codeunit to Single instance in order to reduce Tracking
    // NPR5.42/CLVA/20180508  CASE 313575 Combined the collection of client ip address and geolocation in a single api.ipstack.com request

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        NPRetailSetup: Record "NPR NP Retail Setup";
        FrontEnd: Codeunit "NPR POS Front End Management";
        GeolocationLogged: Boolean;

    local procedure "--- POS"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150700, 'OnInitializationComplete', '', false, false)]
    local procedure OnAfterInitialize(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        //-NPR5.40 [308907]
        if SkipGeolocationTracking() then
            exit;
        //+NPR5.40 [308907]

        RegisterGeoLocationScript(FrontEnd);
    end;

    procedure SkipGeolocationTracking(): Boolean
    begin
        //-NPR5.40 [308907]
        if GeolocationLogged then
            exit(true);

        if (not NPRetailSetup.Get) or (not NPRetailSetup."Enable Client Diagnostics") then begin
            GeolocationLogged := true;
            exit(true);
        end;

        exit(false);
        //+NPR5.40 [308907]
    end;

    local procedure RegisterGeoLocationScript(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        RegisterModuleRequest: DotNet NPRNetJsonRequest;
        ScriptString: Text;
        WebClientDependency: Record "NPR Web Client Dependency";
    begin
        RegisterModuleRequest := RegisterModuleRequest.JsonRequest();
        RegisterModuleRequest.Method := 'RegisterModule';
        RegisterModuleRequest.Content.Add('Name', 'GeoLocationByIP');
        ScriptString := '(function() {' +
        ' var geolocation = new n$.Event.Method("GeoLocationMethod"); ' +
        ' $.ajax({' +
        //-NPR5.42 [313575]
        //'   url: "https://navipartnerfa.azurewebsites.net/api/GetClientIPAddress?code=eavZjqJdKVynQxzsYPnsYpBGmSm61nxavel2VGulz6R5CrAxqhi6JA==",' +
        '   url: "https://api.ipstack.com/check?access_key=b29d29cb640d98bf01c320640e432f59",' +
        //+NPR5.42 [313575]
        '   success: function (result) {' +
        '     geolocation.raise({ result: result });' +
        '   },' +
        '   error: function (xhr, ajaxOptions, thrownError) {' +
        '     geolocation.raise({ error: xhr.responseText });' +
        '   }' +
        '});' +
        '})()';

        RegisterModuleRequest.Content.Add('Script', ScriptString);
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

        //-NPR5.40 [308907]
        TrackGeoLocationByIP(JSON.GetString('result', true));
        //+NPR5.40 [308907]
    end;

    procedure TrackGeoLocationByIP(IPAddress: Text)
    begin
        //-NPR5.40 [308907]
        if SkipGeolocationTracking() then
            exit;

        GeolocationLogged := true;
        OnTrackGeoLocationByIP(IPAddress);
        //+NPR5.40 [308907]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTrackGeoLocationByIP(IPAddress: Text)
    begin
        //-NPR5.40 [308907]
        //+NPR5.40 [308907]
    end;

    local procedure "--- Convert"()
    begin
    end;

    procedure IPAddress2GeoPosition(IPAddress: Text; var Latitude: Decimal; var Longitude: Decimal)
    var
        Parameters: DotNet NPRNetDictionary_Of_T_U;
        AFManagement: Codeunit "NPR AF Management";
        AFHelperFunctions: Codeunit "NPR AF Helper Functions";
        HttpResponseMessage: DotNet NPRNetHttpResponseMessage;
        Path: Text;
        JObject: JsonObject;
        StringContent: DotNet NPRNetStringContent;
        TextString: Text;
        Encoding: DotNet NPRNetEncoding;
        ResultVar: Boolean;
        PrevRec: Text;
    begin
        //-NPR5.40 [308907]
        if IPAddress = '' then
            exit;

        JObject.Add('clientIp', IPAddress);
        JObject.WriteTo(TextString);
        StringContent := StringContent.StringContent(TextString, Encoding.UTF8, 'application/json');

        Parameters := Parameters.Dictionary();
        Parameters.Add('baseurl', 'https://navipartnerfa.azurewebsites.net');
        Parameters.Add('restmethod', 'POST');
        Parameters.Add('path', 'https://navipartnerfa.azurewebsites.net/api/GetClientGeoLocationByIPAddress?code=eavZjqJdKVynQxzsYPnsYpBGmSm61nxavel2VGulz6R5CrAxqhi6JA==');
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
        //+NPR5.40 [308907]
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

