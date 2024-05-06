codeunit 6184699 "NPR Vipps Mp ePayment API"
{
    Access = Internal;

    [TryFunction]
    internal procedure CreatePayment_StaticQRFlow(EftTransactionRequest: Record "NPR EFT Transaction Request"; WebhookCustomerToken: Text; var Response: JsonObject)
    var
        Request: JsonObject;
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpStore: Record "NPR Vipps Mp Store";
        LblPurchaseDesc: Label 'Purchase at POS %1';
    begin
        Request.Add('amount', AmountJson(EftTransactionRequest."Amount Input", EftTransactionRequest."Currency Code"));
        Request.Add('paymentMethod', PaymentMethodJson('WALLET'));
        Request.Add('customer', CustomerTokenJson(WebhookCustomerToken));
        Request.Add('customerInteraction', CustomerInteraction(true));
        Request.Add('reference', EftTransactionRequest."Reference Number Input");
        Request.Add('userFlow', 'PUSH_MESSAGE');
        Request.Add('paymentDescription', StrSubstNo(LblPurchaseDesc, EftTransactionRequest."Register No."));
        VippsMpUnitSetup.Get(EftTransactionRequest."Register No.");
        VippsMpStore.Get(VippsMpUnitSetup."Merchant Serial Number");
        CreatePayment(VippsMpStore, EftTransactionRequest."Reference Number Input", Request, Response);
    end;

    [TryFunction]
    internal procedure CapturePayment(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Response: JsonObject)
    var
        Request: JsonObject;
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpStore: Record "NPR Vipps Mp Store";
    begin
        Request.Add('modificationAmount', AmountJson(EftTransactionRequest."Amount Input", EftTransactionRequest."Currency Code"));
        VippsMpUnitSetup.Get(EftTransactionRequest."Register No.");
        VippsMpStore.Get(VippsMpUnitSetup."Merchant Serial Number");
        CapturePayment(VippsMpStore, EftTransactionRequest."Reference Number Input", EftTransactionRequest."Reference Number Input", Request, Response);
    end;

    [TryFunction]
    internal procedure RefundPayment(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Response: JsonObject)
    var
        Request: JsonObject;
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpStore: Record "NPR Vipps Mp Store";
    begin
        Request.Add('modificationAmount', AmountJson(EftTransactionRequest."Amount Input" * -1, EftTransactionRequest."Currency Code"));
        VippsMpUnitSetup.Get(EftTransactionRequest."Register No.");
        VippsMpStore.Get(VippsMpUnitSetup."Merchant Serial Number");
        RefundPayment(VippsMpStore, EftTransactionRequest."Reference Number Input", EftTransactionRequest."Reference Number Input", Request, Response);
    end;

    [TryFunction]
    internal procedure CancelPayment(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Response: JsonObject)
    var
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpStore: Record "NPR Vipps Mp Store";
    begin
        VippsMpUnitSetup.Get(EftTransactionRequest."Register No.");
        VippsMpStore.Get(VippsMpUnitSetup."Merchant Serial Number");
        CancelPayment(VippsMpStore, EftTransactionRequest."Reference Number Input", EftTransactionRequest."Reference Number Input", Response);
    end;

    [TryFunction]
    internal procedure GetPayment(EftTransactionRequest: Record "NPR EFT Transaction Request"; var Response: JsonObject)
    var
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpStore: Record "NPR Vipps Mp Store";
    begin
        VippsMpUnitSetup.Get(EftTransactionRequest."Register No.");
        VippsMpStore.Get(VippsMpUnitSetup."Merchant Serial Number");
        GetPayment(VippsMpStore, EftTransactionRequest."Reference Number Input", Response);
    end;

    #region API Functions
    [TryFunction]
    local procedure GetPayment(VippsMpStore: Record "NPR Vipps Mp Store"; PaymentReference: Text[50]; var Response: JsonObject)
    var
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        Http: HttpClient;
        HttpResponse: HttpResponseMessage;
        HttpResponseTxt: Text;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True);
        Http.Get(StrSubstNo('epayment/v1/payments/%1', PaymentReference), HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        if (HttpResponse.IsSuccessStatusCode()) then begin
            Response.ReadFrom(HttpResponseTxt);
        end else begin
            Response.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(Response, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

    [TryFunction]
    local procedure CreatePayment(VippsMpStore: Record "NPR Vipps Mp Store"; IdempotencyKey: Text[50]; JsonBody: JsonObject; var Response: JsonObject)
    var
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        Http: HttpClient;
        HttpContent: HttpContent;
        HttpResponse: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        HttpResponseTxt: Text;
        RequestJsonTxt: Text;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True, IdempotencyKey);
        JsonBody.WriteTo(RequestJsonTxt);
        HttpContent.WriteFrom(RequestJsonTxt);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        Http.Post('epayment/v1/payments', HttpContent, HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        if (HttpResponse.IsSuccessStatusCode()) then begin
            Response.ReadFrom(HttpResponseTxt);
        end else begin
            Response.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(Response, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

    [TryFunction]
    local procedure CapturePayment(VippsMpStore: Record "NPR Vipps Mp Store"; PaymentReference: Text[50]; IdempotencyKey: Text[50]; JsonBody: JsonObject; var Response: JsonObject)
    var
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        Http: HttpClient;
        HttpContent: HttpContent;
        HttpResponse: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        HttpResponseTxt: Text;
        RequestJsonTxt: Text;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True, IdempotencyKey);
        JsonBody.WriteTo(RequestJsonTxt);
        HttpContent.WriteFrom(RequestJsonTxt);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        Http.Post(StrSubstNo('epayment/v1/payments/%1/capture', PaymentReference), HttpContent, HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        if (HttpResponse.IsSuccessStatusCode()) then begin
            Response.ReadFrom(HttpResponseTxt);
        end else begin
            Response.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(Response, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

    [TryFunction]
    local procedure CancelPayment(VippsMpStore: Record "NPR Vipps Mp Store"; PaymentReference: Text[50]; IdempotencyKey: Text[50]; var Response: JsonObject)
    var
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        Http: HttpClient;
        HttpContent: HttpContent;
        ContentHeaders: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        HttpResponseTxt: Text;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True, IdempotencyKey);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        Http.Post(StrSubstNo('epayment/v1/payments/%1/cancel', PaymentReference), HttpContent, HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        if (HttpResponse.IsSuccessStatusCode()) then begin
            Response.ReadFrom(HttpResponseTxt);
        end else begin
            Response.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(Response, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

    [TryFunction]
    local procedure RefundPayment(VippsMpStore: Record "NPR Vipps Mp Store"; PaymentReference: Text[50]; IdempotencyKey: Text[50]; JsonBody: JsonObject; var Response: JsonObject)
    var
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
        Http: HttpClient;
        HttpContent: HttpContent;
        HttpResponse: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        HttpResponseTxt: Text;
        RequestJsonTxt: Text;
    begin
        VippsMpUtil.InitHttpClient(Http, VippsMpStore, True, IdempotencyKey);
        JsonBody.WriteTo(RequestJsonTxt);
        HttpContent.WriteFrom(RequestJsonTxt);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        Http.Post(StrSubstNo('epayment/v1/payments/%1/refund', PaymentReference), HttpContent, HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseTxt);
        if (HttpResponse.IsSuccessStatusCode()) then begin
            Response.ReadFrom(HttpResponseTxt);
        end else begin
            Response.ReadFrom(HttpResponseTxt);
            VippsMpResponseHandler.HttpErrorResponseMessage(Response, HttpResponseTxt);
            Error(HttpResponseTxt);
        end;
    end;

    #endregion

    #region  JsonPaymentFunctions

    local procedure AmountJson(OrgAmount: Decimal; Currency: Text) Json: JsonObject
    var
        Int: Integer;
        NewAmount: Decimal;
    begin
        //Move decimalpoints to integer part.
        NewAmount := OrgAmount * 100;
        //create integer
        Evaluate(Int, Format(NewAmount).Replace(',', '').Replace('.', ''));
        Json.Add('value', Int);
        Json.Add('currency', Currency);
    end;

    local procedure CustomerTokenJson(Token: Text) Json: JsonObject
    begin
        Json.Add('customerToken', Token);
    end;

    local procedure CustomerInteraction(CustomerPresent: Boolean): Text
    begin
        if (CustomerPresent) then
            exit('CUSTOMER_PRESENT');
        exit('CUSTOMER_NOT_PRESENT');
    end;

    local procedure PaymentMethodJson(PayType: Text) Json: JsonObject
    begin
        Json.Add('type', PayType);
    end;

    #endregion
}