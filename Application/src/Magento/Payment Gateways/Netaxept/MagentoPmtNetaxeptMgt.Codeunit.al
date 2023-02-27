codeunit 6151424 "NPR Magento Pmt. Netaxept Mgt." implements "NPR IPaymentGateway"
{
    Access = Internal;

    #region Payment Integration
    local procedure CancelInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        PGNetaxept: Record "NPR PG Netaxept Setup";
        HttpClientVar: HttpClient;
        HttpWebResponse: HttpResponseMessage;
    begin
        PGNetaxept.Get(Request."Payment Gateway Code");

        HttpClientVar.Timeout := 5000;
        if not HttpClientVar.Get(GetApiUrl(PGNetaxept, Request, 'annul'), HttpWebResponse) then
            Error(CopyStr('NetAxept: ' + GetLastErrorText, 1, 1024));

        RequestProcessing(HttpWebResponse, Response);
        Response."Response Success" := true;
    end;

    local procedure CaptureInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        PGNetaxept: Record "NPR PG Netaxept Setup";
        HttpClientVar: HttpClient;
        HttpWebResponse: HttpResponseMessage;
    begin
        PGNetaxept.Get(Request."Payment Gateway Code");

        HttpClientVar.Timeout := 5000;
        if not HttpClientVar.Get(GetApiUrl(PGNetaxept, Request, 'capture'), HttpWebResponse) then
            Error(CopyStr('NetAxept: ' + GetLastErrorText, 1, 1024));

        RequestProcessing(HttpWebResponse, Response);
        Response."Response Success" := true;
    end;

    local procedure RefundInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        PGNetaxept: Record "NPR PG Netaxept Setup";
        HttpClientVar: HttpClient;
        HttpWebResponse: HttpResponseMessage;
    begin
        PGNetaxept.Get(Request."Payment Gateway Code");

        HttpClientVar.Timeout := 5000;
        if not HttpClientVar.Get(GetApiUrl(PGNetaxept, Request, 'credit'), HttpWebResponse) then
            Error(CopyStr('NetAxept: ' + GetLastErrorText, 1, 1024));

        RequestProcessing(HttpWebResponse, Response);
        Response."Response Success" := true;
    end;
    #endregion

    #region aux
    local procedure RequestProcessing(HttpWebResponse: HttpResponseMessage; var Response: Record "NPR PG Payment Response")
    var
        XmlDomMng: Codeunit "XML DOM Management";
        XmlDoc: XmlDocument;
        ResponseTxt: Text;
    begin
        HttpWebResponse.Content.ReadAs(ResponseTxt);
        Response.AddResponse(ResponseTxt);

        if not XmlDocument.ReadFrom(XmlDomMng.RemoveNamespaces(ResponseTxt), XmlDoc) then
            Error(CopyStr('NetAxept: ' + ResponseTxt, 1, 1024));

        if not HttpWebResponse.IsSuccessStatusCode then
            Error('NetAxept: %1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, ResponseTxt);
    end;

    local procedure GetApiUrl(PGNetaxept: Record "NPR PG Netaxept Setup"; Request: Record "NPR PG Payment Request"; Method: Text): Text
    var
        BaseUrl: Text;
    begin
        case PGNetaxept.Environment of
            PGNetaxept.Environment::Test:
                BaseUrl := 'https://epayment-test.bbs.no/REST/';
            PGNetaxept.Environment::Production:
                BaseUrl := 'https://epayment.bbs.no/REST/';
        end;

        exit(BaseUrl +
             Method + '.aspx' +
             '?merchantId=' + PGNetaxept."Merchant ID" +
             '&token=' + PGNetaxept.GetApiAccessToken() +
             '&transactionId=' + LowerCase(Request."Transaction ID") +
             '&transactionreconref=' + '' +
             '&transactionamount=' + DelChr(Format(Request."Request Amount", 0, '<SIGN><INTEGER><DECIMALS,3>'), '=', '.,'));
    end;
    #endregion

    #region Interface implementation
    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
        CaptureInternal(Request, Response);
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
        RefundInternal(Request, Response);
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    begin
        CancelInternal(Request, Response);
    end;

    procedure RunSetupCard(PaymentGatewayCode: Code[10]);
    var
        PGNetaxeptSetup: Record "NPR PG Netaxept Setup";
    begin
        if (not PGNetaxeptSetup.Get(PaymentGatewayCode)) then begin
            PGNetaxeptSetup.Init();
            PGNetaxeptSetup.Code := PaymentGatewayCode;
            PGNetaxeptSetup.Insert(true);
            Commit();
        end;

        Page.Run(Page::"NPR PG Netaxept Setup Card", PGNetaxeptSetup);
    end;
    #endregion
}
