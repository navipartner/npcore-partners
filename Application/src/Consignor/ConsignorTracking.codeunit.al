codeunit 6150800 "NPR Consignor Tracking"
{
    Permissions = tabledata "Sales Shipment Header" = RM;
    Access = Internal;

    var
        PackageProviderSetup: Record "NPR Shipping Provider Setup";

    trigger OnRun()
    var
        BearerToken: Text;
        TrackingCode: Text;
        Fromdate: Date;
        StartDateTime: DateTime;
        Timeout: Duration;
        PostedSalesShipment: Record "Sales Shipment Header";
    begin
        if not InitPackageProvider() then
            exit;

        StartDateTime := CurrentDateTime;
        Fromdate := CalcDate('<-CY>', Today);

        PostedSalesShipment.SetFilter("Posting Date", '%1..%2', Fromdate, Today);
        PostedSalesShipment.SetFilter("Package Tracking No.", '%1', '');
        PostedSalesShipment.SetFilter("Shipping Agent Code", '<>%1', '');
        PostedSalesShipment.SetFilter("Shipping Agent Service Code", '<>%1', '');
        if PostedSalesShipment.FindSet() then
            repeat
                if (CurrentDateTime - StartDateTime) > Timeout then begin
                    StartDateTime := CurrentDateTime;
                    BearerToken := GetToken(Timeout);
                    if BearerToken = '' then
                        exit;
                end;
                TrackingCode := GetPackagetrackingCode(PostedSalesShipment, BearerToken);
                if TrackingCode <> '' then begin
                    PostedSalesShipment."Package Tracking No." := CopyStr(TrackingCode, 1, MaxStrLen(PostedSalesShipment."Package Tracking No."));
                    PostedSalesShipment.Modify();
                end;
            until PostedSalesShipment.Next() = 0;
    end;

    local procedure GetPackagetrackingCode(PostedSalesShipment: Record "Sales Shipment Header"; BearerToken: Text): Text
    var
        uuid: Text;
    begin
        uuid := GetShipmentByOrderNo(PostedSalesShipment, BearerToken);
        if uuid <> '' then
            exit(CopyStr(GetPackageNo(uuid, BearerToken), 1, MaxStrLen(PostedSalesShipment."Package Tracking No.")));
    end;

    var
    local procedure GetToken(var Timeout: Duration): Text
    var
        TypeHelper: Codeunit "Type Helper";
        BaseUrl: Text;
        RequestBody: Text;
        LocScope: Text;
        JsonResult: JsonToken;
        Expiresin: Integer;
        ClientID: Text;
        ClientSecret: Text;

    begin
        BaseUrl := 'https://www.consignorportal.com/idsrv/connect/token';
        LocScope := 'client_credentials';
        ClientID := PackageProviderSetup."Api User";
        ClientSecret := PackageProviderSetup."Api Key";

        RequestBody := StrSubstNo('grant_type=%3&client_id=%1&client_secret=%2',
                        TypeHelper.UrlEncode(ClientID),
                        TypeHelper.UrlEncode(ClientSecret),
                        TypeHelper.UrlEncode(LocScope));

        if ExecuteCall('POST', JsonResult, BaseUrl, RequestBody, '') then begin
            if Evaluate(Expiresin, GetJsonText(JsonResult, 'expires_in', 0)) then
                Timeout := Expiresin * (1000 - 100);
            exit(GetJsonText(JsonResult, 'access_token', 0));
        end;
    end;

    local procedure GetShipmentByOrderNo(SalesShipmentHdr: Record "Sales Shipment Header"; BearerToken: Text): Text
    var
        BaseURL: Text;
        RequestBody: Text;
        JsonResult: JsonToken;
        JArray: JsonArray;
        Startdate: Text;
        Enddate: Text;
    begin
        BaseURL := GetBaseUrl() + 'ShipmentIdentifiers/ByOrderNumber';

        Startdate := Format(Date2DMY(SalesShipmentHdr."Posting Date", 3)) + Format(SalesShipmentHdr."Posting Date", 6, '-<Month,2>-<Day,2>');
        Enddate := Format(Date2DMY(SalesShipmentHdr."Posting Date", 3)) + Format(CalcDate('<+14D>', SalesShipmentHdr."Posting Date"), 6, '-<Month,2>-<Day,2>');

        RequestBody := '{';
        RequestBody += '"query":' + '"' + SalesShipmentHdr."Order No." + '" ,';
        RequestBody += '"startDate":' + '"' + Startdate + '",';
        RequestBody += '"endDate":' + '"' + Enddate + '",';
        RequestBody += '"pageSize": 20,';
        RequestBody += '"pageIndex": 0,';
        RequestBody += '"installationTags": [],';
        RequestBody += '"actorTags": [],';
        RequestBody += '"carrierTags": []';
        RequestBody += '}';

        if ExecuteCall('POST', JsonResult, BaseURL, RequestBody, BearerToken) then begin

            if not JsonResult.IsArray then
                exit;
            JArray := JsonResult.AsArray();
            if JArray.Count > 0 then
                JArray.Get(0, JsonResult);
            exit(GetJsonText(JsonResult, 'uuid', 0));
        end;
    end;

    local procedure GetPackageNo(uuid: Text; BearerToken: Text): Text
    var
        BaseURL: Text;
        RequestBody: Text;
        JsonResult: JsonToken;
        JArray: JsonArray;
        trackingUrlsToken: JsonToken;

    begin
        BaseURL := GetBaseUrl() + 'Shipments/' + uuid + '/additional-information';
        if ExecuteCall('GET', JsonResult, BaseURL, RequestBody, BearerToken) then begin

            JsonResult.SelectToken('trackingUrls', trackingUrlsToken);

            if not trackingUrlsToken.IsArray then
                exit;

            JArray := trackingUrlsToken.AsArray();
            if JArray.Count > 0 then
                JArray.Get(0, trackingUrlsToken);
            exit(GetJsonText(trackingUrlsToken, 'text', 0));
        end;
    end;

    local procedure GetBaseUrl(): Text

    begin
        exit('https://customer-api.consignorportal.com/ApiGateway/ShipmentData/Operational/');
    end;

    local procedure ExecuteCall(Method: Code[10]; JsonResult: JsonToken; BaseUrl: Text; RequestBody: Text; BearerToken: Text): Boolean;
    var
        Request: HttpRequestMessage;
        Client: HttpClient;
        Header: HttpHeaders;
        Response: HttpResponseMessage;
        Content: HttpContent;
        result: Text;
        ContentHeader: HttpHeaders;
    begin
        Request.Method(Method);
        Request.SetRequestUri(BaseUrl);
        Content.WriteFrom(RequestBody);
        if Method = 'POST' then begin
            if BearerToken = '' then begin
                Content.GetHeaders(Header);
                Header.Remove('Content-Type');
                Header.Add('Content-Type', 'application/x-www-form-urlencoded');
                Request.Content(Content);
            end else begin
                Request.GetHeaders(Header);
                Header.Remove('Authorization');
                Header.Add('Authorization', 'Bearer ' + BearerToken);
                Content.GetHeaders(ContentHeader);
                ContentHeader.Remove('Content-Type');
                ContentHeader.Add('Content-Type', 'application/json');
                Request.Content(Content);
            end;
        end else
            if Method = 'GET' then begin
                Request.GetHeaders(Header);
                Header.Remove('Authorization');
                Header.Add('Authorization', 'Bearer ' + BearerToken);
            end;

        if not Client.Send(Request, Response) then
            exit(false);
        if not Response.IsSuccessStatusCode() then
            exit(false);

        Response.Content.ReadAs(result);
        JsonResult.ReadFrom(result);
        exit(true);

    end;

    local procedure InitPackageProvider(): Boolean;
    begin
        if not PackageProviderSetup.Get() then
            exit(false);

        if not PackageProviderSetup."Enable Shipping" then
            exit(false);

        if PackageProviderSetup."Shipping Provider" <> PackageProviderSetup."Shipping Provider"::Consignor then
            exit(false);

        if (PackageProviderSetup."Api User" = '') or (PackageProviderSetup."Api Key" = '') then
            exit(false);

        exit(true);
    end;

    local procedure GetJsonText(JToken: JsonToken; Path: Text; MaxLen: Integer) Value: Text
    var
        Token2: JsonToken;
        Jvalue: JsonValue;
    begin

        if not JToken.SelectToken(Path, Token2) then
            exit('');
        Jvalue := Token2.AsValue();
        if Jvalue.IsNull then
            exit('');

        Value := Jvalue.AsText();

        if MaxLen > 0 then
            Value := CopyStr(Value, 1, MaxLen);

        exit(Value)
    end;
}