codeunit 6150743 "POS Geolocation"
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
        NPRetailSetup: Record "NP Retail Setup";
        FrontEnd: Codeunit "POS Front End Management";
        GeolocationLogged: Boolean;

    local procedure "--- POS"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150700, 'OnInitializationComplete', '', false, false)]
    local procedure OnAfterInitialize(FrontEnd: Codeunit "POS Front End Management")
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

    local procedure RegisterGeoLocationScript(FrontEnd: Codeunit "POS Front End Management")
    var
        RegisterModuleRequest: DotNet npNetJsonRequest;
        ScriptString: Text;
        WebClientDependency: Record "Web Client Dependency";
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
    local procedure OnCustomMethod(Method: Text; Context: DotNet JObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        ClientDiagnosticsDataMgt: Codeunit "Client Diagnostics Data Mgt.";
        JSON: Codeunit "POS JSON Management";
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
        Parameters: DotNet npNetDictionary_Of_T_U;
        AFManagement: Codeunit "AF Management";
        AFHelperFunctions: Codeunit "AF Helper Functions";
        HttpResponseMessage: DotNet npNetHttpResponseMessage;
        Path: Text;
        JObject: DotNet JObject;
        JToken: DotNet JToken;
        JTokenWriter: DotNet npNetJTokenWriter;
        StringContent: DotNet npNetStringContent;
        TextString: Text;
        Encoding: DotNet npNetEncoding;
        ResultVar: Boolean;
        PrevRec: Text;
    begin
        //-NPR5.40 [308907]
        if IPAddress = '' then
            exit;

        JTokenWriter := JTokenWriter.JTokenWriter;
        with JTokenWriter do begin
            WriteStartObject;
            WritePropertyName('clientIp');
            WriteValue(IPAddress);
            WriteEndObject;
            JObject := Token;
        end;

        StringContent := StringContent.StringContent(JObject.ToString, Encoding.UTF8, 'application/json');

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

        if not TryParseJson(TextString, JToken) then
            exit;

        JObject := JObject.Parse(JToken.ToString());
        Latitude := GetJsonValueAsDecimal(JObject, 'lat');
        Longitude := GetJsonValueAsDecimal(JObject, 'lon');
        //+NPR5.40 [308907]
    end;

    local procedure GetJsonValueAsDecimal(JObject: DotNet JObject; PropertyName: Text) ReturnValue: Decimal
    var
        DotNetDecimal: DotNet npNetDecimal;
        CultureInfo: DotNet npNetCultureInfo;
    begin
        //-NPR5.40 [308907]
        ReturnValue := DotNetDecimal.Parse(JObject.GetValue(PropertyName).ToString, CultureInfo.InvariantCulture);
        //+NPR5.40 [308907]
    end;

    [TryFunction]
    local procedure TryParseJson(json: Text; var JToken: DotNet JToken)
    begin
        //-NPR5.40 [308907]
        JToken := JToken.Parse(json);
        //+NPR5.40 [308907]
    end;
}

