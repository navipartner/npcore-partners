codeunit 6184721 "NPR Vipps Mp Mgt. API"
{
    Access = Internal;

    var
        _SandboxErrorLbl: Label 'This API Does not work in Sandbox mode.';

    [TryFunction]
    internal procedure GetMerchantMsn("Vipps Mp Store": Record "NPR Vipps Mp Store"; Scheme: Text; "Business Id": Text; var JsonResponse: JsonObject)
    var
        Http: HttpClient;
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
    begin
        if ("Vipps Mp Store".Sandbox) then Error(_SandboxErrorLbl);
        VippsMpUtil.InitHttpClient(Http, "Vipps Mp Store", True);
        GetMerchant(Http, Scheme, "Business Id", JsonResponse);
    end;

    [TryFunction]
    [NonDebuggable]
    internal procedure GetMerchantPartner(Scheme: Text; "Business Id": Text; var JsonResponse: JsonObject)
    var
        Http: HttpClient;
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
    begin
        VippsMpUtil.InitPartnerHttpClient(Http, '');
        GetMerchant(Http, Scheme, "Business Id", JsonResponse);
    end;

    [TryFunction]
    local procedure GetMerchant(var Http: HttpClient; Scheme: Text; "Business Id": Text; var JsonResponse: JsonObject)
    var
        HttpResponse: HttpResponseMessage;
        HttpResponseTxt: Text;
    begin
        Http.Get(StrSubstNo('management/v1/merchants/%1/%2', Scheme, "Business Id"), HttpResponse);
        if (not HttpResponse.IsSuccessStatusCode()) then
            Error('GetSalesUnits failed with: %1 - %2', HttpResponse.HttpStatusCode(), HttpResponse.ReasonPhrase());
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        JsonResponse.ReadFrom(HttpResponseTxt);
    end;

    [TryFunction]
    internal procedure GetSalesUnitsMsn("Vipps Mp Store": Record "NPR Vipps Mp Store"; Scheme: Text; "Business Id": Text; var JsonResponse: JsonArray)
    var
        Http: HttpClient;
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
    begin
        if ("Vipps Mp Store".Sandbox) then Error(_SandboxErrorLbl);
        VippsMpUtil.InitHttpClient(Http, "Vipps Mp Store", True);
        GetSalesUnits(Http, Scheme, "Business Id", JsonResponse);
    end;

    [TryFunction]
    internal procedure GetSalesUnitsPartner(Scheme: Text; "Business Id": Text; var JsonResponse: JsonArray)
    var
        Http: HttpClient;
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
    begin
        VippsMpUtil.InitPartnerHttpClient(Http, '');
        GetSalesUnits(Http, Scheme, "Business Id", JsonResponse);
    end;

    [TryFunction]
    local procedure GetSalesUnits(var Http: HttpClient; Scheme: Text; "Business Id": Text; var JsonResponse: JsonArray)
    var
        HttpResponse: HttpResponseMessage;
        HttpResponseTxt: Text;
        JsonResp: JsonObject;
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
    begin
        Http.Get(StrSubstNo('management/v1/merchants/%1/%2/sales-units', Scheme, "Business Id"), HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        if (HttpResponse.IsSuccessStatusCode()) then begin
            JsonResponse.ReadFrom(HttpResponseTxt);
        end else begin
            JsonResp.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(JsonResp, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;


    [TryFunction]
    internal procedure GetSalesUnitDetailsMsn("Vipps Mp Store": Record "NPR Vipps Mp Store"; var JsonResponse: JsonObject)
    var
        Http: HttpClient;
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
    begin
        if ("Vipps Mp Store".Sandbox) then Error(_SandboxErrorLbl);
        VippsMpUtil.InitHttpClient(Http, "Vipps Mp Store", True);
        GetSalesUnitDetails(Http, "Vipps Mp Store"."Merchant Serial Number", JsonResponse);
    end;

    [TryFunction]
    internal procedure GetSalesUnitDetailsPartner(Msn: Text; var JsonResponse: JsonObject)
    var
        Http: HttpClient;
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
    begin
        VippsMpUtil.InitPartnerHttpClient(Http, Msn);
        GetSalesUnitDetails(Http, Msn, JsonResponse);
    end;

    [TryFunction]
    local procedure GetSalesUnitDetails(var Http: HttpClient; Msn: Text; var JsonResponse: JsonObject)
    var
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        HttpResponse: HttpResponseMessage;
        HttpResponseTxt: Text;
        JsonResp: JsonObject;
    begin
        Http.Get(StrSubstNo('management/v1/sales-units/%1', Msn), HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        if (HttpResponse.IsSuccessStatusCode()) then begin
            JsonResponse.ReadFrom(HttpResponseTxt);
        end else begin
            JsonResp.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(JsonResp, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;
}