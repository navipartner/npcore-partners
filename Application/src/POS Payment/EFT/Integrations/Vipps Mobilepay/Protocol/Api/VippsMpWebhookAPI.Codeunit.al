codeunit 6184723 "NPR Vipps Mp Webhook API"
{
    Access = Internal;

    [TryFunction]
    internal procedure GetAllRegisteredWebhooks(VippsMpStore: Record "NPR Vipps Mp Store"; JsonResponse: JsonObject)
    var
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        Http: HttpClient;
        HttpResponse: HttpResponseMessage;
        HttpResponseTxt: Text;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True);
        Http.Get('/webhooks/v1/webhooks', HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        JsonResponse.ReadFrom(HttpResponseTxt);
        if (not HttpResponse.IsSuccessStatusCode()) then begin
            VippsMpResponseHandler.HttpErrorResponseMessage(JsonResponse, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

    [TryFunction]
    internal procedure RegisterWebhook(Url: Text; WebhookEvents: List of [Enum "NPR Vipps Mp WebhookEvents"]; VippsMpStore: Record "NPR Vipps Mp Store"; var JsonResponse: JsonObject)
    var
        VippsMpWebhookEvents: Enum "NPR Vipps Mp WebhookEvents";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        Json: JsonObject;
        JsonArr: JsonArray;
        Request: Text;
        HttpResponseTxt: Text;
        Http: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        Uri: Codeunit Uri;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True);
        Uri.Init(Url);
        Json.Add('url', Uri.GetAbsoluteUri());
        foreach VippsMpWebhookEvents in WebhookEvents do begin
            JsonArr.Add(VippsMpUtil.EventNameValue(VippsMpWebhookEvents));
        end;
        Json.Add('events', JsonArr);
        Json.WriteTo(Request);
        Content.WriteFrom(Request);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        Http.Post('/webhooks/v1/webhooks', Content, HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        JsonResponse.ReadFrom(HttpResponseTxt);
        if (not HttpResponse.IsSuccessStatusCode()) then begin
            VippsMpResponseHandler.HttpErrorResponseMessage(JsonResponse, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

    [TryFunction]
    internal procedure DeleteWebhook(Id: Text; VippsMpStore: Record "NPR Vipps Mp Store")
    var
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        Http: HttpClient;
        HttpResponse: HttpResponseMessage;
        HttpResponseTxt: Text;
        JsonResponse: JsonObject;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True);
        Http.Delete(StrSubstNo('/webhooks/v1/webhooks/%1', Id), HttpResponse);
        if (not HttpResponse.IsSuccessStatusCode()) then begin
            HttpResponse.Content.ReadAs(HttpResponseTxt);
            JsonResponse.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(JsonResponse, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

}