codeunit 6014405 "NPR Magento Pmt. Bambora Mgt."
{
    Access = Internal;

    var
        _BaseUrlTok: Label 'https://transaction-v1.api-eu.bambora.com', Locked = true;
        _OperationType: Option Capture,Refund,Cancel;
        _CalingApiErr: Label 'An error happened while calling the API.\Status code: %1 - %2\Response: %3', Comment = '%1 = HTTP status code, %2 = Reason Phrase, %3 = Response body';

    #region Capture
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'CapturePaymentEvent', '', false, false)]
    local procedure CapturePayment(var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if (not IsBamboraPaymentLine(PaymentLine, _OperationType::Capture)) then
            exit;

        if (PaymentLine."Document Table No." <> Database::"Sales Invoice Header") then
            exit;

        PaymentLine.TestField("Date Captured", 0D);

        Capture(PaymentLine);

        PaymentLine."Date Captured" := Today();
        PaymentLine.Modify(true);
        Commit();
    end;

    local procedure Capture(PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        Client: HttpClient;
        Request: Text;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        ResponseTxt: Text;
        Success: Boolean;
    begin
        PaymentLine.TestField("No.");

        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        GetHttpClient(PaymentGateway, Client);

        Request := '{' + '"amount":' + Format(GetBamboraAmount(PaymentLine), 0, 9) + '}';
        Content.WriteFrom(Request);

        Content.GetHeaders(ContentHeaders);
        SetHeader(ContentHeaders, 'Content-Type', 'application/json');

        Success := Client.Post(StrSubstNo('/transactions/%1/capture', PaymentLine."No."), Content, Response);
        Response.Content.ReadAs(ResponseTxt);

        if (not (Success and Response.IsSuccessStatusCode())) then
            Error(_CalingApiErr, Response.HttpStatusCode(), Response.ReasonPhrase(), ResponseTxt);
    end;
    #endregion

    #region Refund
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'RefundPaymentEvent', '', false, false)]
    local procedure RefundPayment(var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if (not IsBamboraPaymentLine(PaymentLine, _OperationType::Refund)) then
            exit;

        if (PaymentLine."Document Table No." <> Database::"Sales Cr.Memo Header") then
            exit;

        PaymentLine.TestField("Date Refunded", 0D);

        Refund(PaymentLine);

        PaymentLine."Date Refunded" := Today();
        PaymentLine.Modify(true);
        Commit();
    end;

    local procedure Refund(PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        Client: HttpClient;
        Request: Text;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        ResponseTxt: Text;
        Success: Boolean;
    begin
        PaymentLine.TestField("No.");

        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        GetHttpClient(PaymentGateway, Client);

        Request := '{' + '"amount":' + Format(GetBamboraAmount(PaymentLine), 0, 9) + '}';
        Content.WriteFrom(Request);

        Content.GetHeaders(ContentHeaders);
        SetHeader(ContentHeaders, 'Content-Type', 'application/json');

        Success := Client.Post(StrSubstNo('/transactions/%1/credit', PaymentLine."No."), Content, Response);
        Response.Content.ReadAs(ResponseTxt);

        if (not (Success and Response.IsSuccessStatusCode())) then
            Error(_CalingApiErr, Response.HttpStatusCode(), Response.ReasonPhrase(), ResponseTxt);
    end;
    #endregion

    #region Cancel
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'CancelPaymentEvent', '', false, false)]
    local procedure CancelPayment(var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if (not IsBamboraPaymentLine(PaymentLine, _OperationType::Cancel)) then
            exit;

        if (PaymentLine."Document Table No." <> Database::"Sales Header") then
            exit;

        PaymentLine.TestField("Date Captured", 0D);
        PaymentLine.TestField("Date Refunded", 0D);

        Cancel(PaymentLine);

        PaymentLine."Date Refunded" := Today();
        PaymentLine.Modify(true);
        Commit();
    end;

    local procedure Cancel(PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        Client: HttpClient;
        Request: Text;
        Content: HttpContent;
        Response: HttpResponseMessage;
        ResponseTxt: Text;
        Success: Boolean;
    begin
        PaymentLine.TestField("No.");

        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        GetHttpClient(PaymentGateway, Client);

        Request := ''; // cancel operation takes an empty body
        Content.WriteFrom(Request);

        Success := Client.Post(StrSubstNo('/transactions/%1/delete', PaymentLine."No."), Content, Response);
        Response.Content.ReadAs(ResponseTxt);

        if (not (Success and Response.IsSuccessStatusCode())) then
            Error(_CalingApiErr, Response.HttpStatusCode(), Response.ReasonPhrase(), ResponseTxt);
    end;
    #endregion

    #region Aux
    local procedure GetBamboraAmount(PaymentLine: Record "NPR Magento Payment Line"): Integer
    begin
        exit(Round(PaymentLine.Amount, 0.01) * 100);
    end;

    [NonDebuggable]
    local procedure GetHttpClient(PaymentGateway: Record "NPR Magento Payment Gateway"; var Client: HttpClient)
    var
        AccessTokenNotSetErr: Label 'The access token is not set on Payment Gateway %1. Set this in the "%2" field', Comment = '%1 = payment gateway code, %2 = Api Username field caption';
        ApiAuthTokenNotSetErr: Label 'The secret authentication token is not set on Payment Gateway %1. Set this in the "%2" field', Comment = '%1 = payment gateway code, %2 = Api Password field caption';
        Username: Text;
        SecretToken: Text;
        AuthToken: Text;
        Headers: HttpHeaders;
        Convert: Codeunit "Base64 Convert";
    begin
        if (PaymentGateway."Api Username" = '') then
            Error(AccessTokenNotSetErr, PaymentGateway.Code, PaymentGateway.FieldCaption("Api Username"));

        PaymentGateway.TestField("Merchant ID");

        if (not PaymentGateway.HasApiPassword()) then
            Error(ApiAuthTokenNotSetErr, PaymentGateway.Code, PaymentGateway.FieldCaption("Api Password Key"));

        SecretToken := PaymentGateway.GetApiPassword();

        if (SecretToken = '') then
            Error(ApiAuthTokenNotSetErr, PaymentGateway.Code, PaymentGateway.FieldCaption("Api Password Key"));

        Clear(Client);

        Username := PaymentGateway."Api Username" + '@' + PaymentGateway."Merchant ID";
        AuthToken := Convert.ToBase64(Username + ':' + SecretToken);

        Client.SetBaseAddress(_BaseUrlTok);
        Headers := Client.DefaultRequestHeaders();
        SetHeader(Headers, 'Authorization', 'Basic ' + AuthToken);
        SetHeader(Headers, 'Accept', 'application/json');
    end;

    local procedure SetHeader(var Headers: HttpHeaders; Name: Text; Val: Text)
    begin
        if (Headers.Contains(Name)) then
            Headers.Remove(Name);
        Headers.Add(Name, Val);
    end;

    local procedure IsBamboraPaymentLine(PaymentLine: Record "NPR Magento Payment Line"; OperationType: Option Capture,Refund,Cancel): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if (PaymentLine."Payment Gateway Code" = '') then
            exit(false);

        if (not PaymentGateway.Get(PaymentLine."Payment Gateway Code")) then
            exit(false);

        case OperationType of
            OperationType::Capture:
                exit(PaymentGateway."Capture Codeunit Id" = CurrCodeunitId());
            OperationType::Refund:
                exit(PaymentGateway."Refund Codeunit Id" = CurrCodeunitId());
            OperationType::Cancel:
                exit(PaymentGateway."Cancel Codeunit Id" = CurrCodeunitId());
            else
                exit(false);
        end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Magento Pmt. Bambora Mgt.");
    end;
    #endregion
}