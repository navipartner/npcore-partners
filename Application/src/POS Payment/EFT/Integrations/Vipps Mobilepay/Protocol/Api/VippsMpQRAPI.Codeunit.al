codeunit 6184715 "NPR Vipps Mp QR API"
{
    Access = Internal;

    [TryFunction]
    internal procedure GetMerchantCallBackQrInfo(VippsMpStore: Record "NPR Vipps Mp Store"; MerchantQrId: Text; var JsonResponse: JsonObject)
    begin
        GetMerchantCallBackQRById(VippsMpStore, MerchantQrId, JsonResponse);
    end;

    [TryFunction]
    internal procedure GetAllMerchantCallBackQrInfo(VippsMpStore: Record "NPR Vipps Mp Store"; var JsonResponse: JsonArray)
    begin
        GetAllMerchantCallBackQRs(VippsMpStore, JsonResponse);
    end;

    [TryFunction]
    local procedure GetAllMerchantCallBackQRs(VippsMpStore: Record "NPR Vipps Mp Store"; var JsonResponse: JsonArray)
    var
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        Http: HttpClient;
        HttpResponse: HttpResponseMessage;
        HttpResponseTxt: Text;
        QueryString: Text;
        Response: JsonObject;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True);
        QueryString := 'QrImageFormat=PNG&QrImageSize=500';
        Http.Get(StrSubstNo('/qr/v1/merchant-callback?%1', QueryString), HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        if (HttpResponse.IsSuccessStatusCode()) then begin
            JsonResponse.ReadFrom(HttpResponseTxt);
        end else begin
            Response.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(Response, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

    [TryFunction]
    local procedure GetMerchantCallBackQRById(VippsMpStore: Record "NPR Vipps Mp Store"; MerchantQrId: Text; var JsonResponse: JsonObject)
    var
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        Http: HttpClient;
        HttpResponse: HttpResponseMessage;
        HttpResponseTxt: Text;
        QueryString: Text;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True);
        QueryString := 'QrImageFormat=PNG&QrImageSize=500';
        Http.Get(StrSubstNo('/qr/v1/merchant-callback/%1?%2', MerchantQrId, QueryString), HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        if (HttpResponse.IsSuccessStatusCode()) then begin
            JsonResponse.ReadFrom(HttpResponseTxt);
        end else begin
            JsonResponse.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(JsonResponse, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

    [TryFunction]
    internal procedure CreateOrUpdateCallbackQr(VippsMpStore: Record "NPR Vipps Mp Store"; MerchantQrId: Text; LocationDescription: Text)
    var
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        Http: HttpClient;
        HttpContent: HttpContent;
        HttpResponse: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        RequestJson: Text;
        HttpResponseTxt: Text;
        Request: JsonObject;
        JsonResponse: JsonObject;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True);
        Request.Add('locationDescription', LocationDescription);
        Request.writeTo(RequestJson);
        HttpContent.WriteFrom(RequestJson);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        Http.Put(StrSubstNo('/qr/v1/merchant-callback/%1', MerchantQrId), HttpContent, HttpResponse);
        if (not HttpResponse.IsSuccessStatusCode()) then begin
            JsonResponse.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(JsonResponse, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

    [TryFunction]
    internal procedure DeleteCallbackQr(VippsMpStore: Record "NPR Vipps Mp Store"; MerchantQrId: Text)
    var
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        Http: HttpClient;
        HttpResponse: HttpResponseMessage;
        JsonResponse: JsonObject;
        HttpResponseTxt: Text;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True);
        Http.Delete(StrSubstNo('/qr/v1/merchant-callback/%1', MerchantQrId), HttpResponse);
        if (not HttpResponse.IsSuccessStatusCode()) then begin
            JsonResponse.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(JsonResponse, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

    [TryFunction]
    internal procedure CreateORUpdateMobilepayQr(VippsMpStore: Record "NPR Vipps Mp Store"; BeaconId: Text; LocationDescription: Text)
    var
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        Http: HttpClient;
        HttpResponse: HttpResponseMessage;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestJson: Text;
        HttpResponseTxt: Text;
        Request: JsonObject;
        JsonResponse: JsonObject;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True);
        Request.Add('locationDescription', LocationDescription);
        Request.writeTo(RequestJson);
        HttpContent.WriteFrom(RequestJson);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        Http.Put(StrSubstNo('/qr/v1/merchant-callback/mobilepay/%1', BeaconId), HttpContent, HttpResponse);
        if (not HttpResponse.IsSuccessStatusCode()) then begin
            JsonResponse.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(JsonResponse, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;
}