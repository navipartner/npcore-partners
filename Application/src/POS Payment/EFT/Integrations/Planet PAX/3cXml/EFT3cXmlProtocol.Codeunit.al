codeunit 6151605 "NPR 3cXml Protocol"
{
    Access = Internal;

    internal procedure PreparePlanetPaxEftRequest(EFTReq: Record "NPR EFT Transaction Request"): Text
    var
        OldEFTReq: Record "NPR EFT Transaction Request";
        Config: Record "NPR EFT Planet PAX Config";
        PlanetPaxReq: Codeunit "NPR EFT Planet PAX Req.";
        EftOpErr: Label 'Could not process EFT Request, Processing type ''%1'' is not supported.';
        Request: Text;
        Token: Text;
    begin
        Config.Get(EFTReq."Register No.");
        case EftReq."Processing Type" of
            EftReq."Processing Type"::PAYMENT:
                begin
                    Request := PlanetPaxReq.PaymentRequest(
                        Config,
                        EftReq."Amount Input",
                        EftReq."Currency Code",
                        EftReq."Entry No.");
                    exit(Request);
                end;
            EftReq."Processing Type"::REFUND:
                begin
                    if (OldEFTReq.Get(EftReq."Processed Entry No.")) then
                        Token := OldEFTReq."External Payment Token";
                    Request := PlanetPaxReq.RefundRequest(
                        Config,
                        Abs(EftReq."Amount Input"),
                        EftReq."Currency Code",
                        EftReq."Entry No.",
                        Token);
                    exit(Request);
                end;
            EftReq."Processing Type"::LOOK_UP:
                begin
                    OldEftReq.Get(EftReq."Processed Entry No.");
                    Request := PlanetPaxReq.LookupRequest(Config, EftReq."Entry No.", OldEftReq."Entry No.");
                    exit(Request);
                end;
            EftReq."Processing Type"::VOID:
                begin
                    OldEFTReq.Get(EftReq."Processed Entry No.");
                    Token := OldEFTReq."External Payment Token";
                    if (OldEFTReq."Processing Type" = OldEFTReq."Processing Type"::PAYMENT) then begin
                        Request := PlanetPaxReq.PaymentReversalRequest(
                            Config,
                            EftReq."Entry No.",
                            OldEftReq."Entry No.",
                            OldEftReq."Result Amount",
                            OldEftReq."Currency Code",
                            Token);
                        exit(Request);
                    end;
                    if (OldEFTReq."Processing Type" = OldEFTReq."Processing Type"::REFUND) then begin
                        Request := PlanetPaxReq.RefundReversalRequest(
                            Config,
                            EftReq."Entry No.",
                            OldEftReq."Entry No.",
                            Abs(OldEftReq."Result Amount"),
                            OldEftReq."Currency Code",
                            Token);
                        exit(Request);
                    end;
                end;
        end;
        Error(EftOpErr, Format(EftReq."Processing Type"));
    end;

    [TryFunction]
    internal procedure SendRequest(Url: Text; XmlBodyRequest: Text; var Response: Text)
    var
        Api: Codeunit "NPR AF Planet Proxy";
        Http: HttpClient;
        Content: HttpContent;
        Resp: HttpResponseMessage;
        ResultXmlTxt: Text;
        ErrorLabel: Label '(%1): %2';
    begin
        Content.WriteFrom(XmlBodyRequest);
        Http.Timeout(1000 * 120); //120 Second
        Api.RunPlanetPaymentProxy(Url, Content, Resp);
        if (Resp.IsSuccessStatusCode) then begin
            Resp.Content.ReadAs(ResultXmlTxt);
            Response := ResultXmlTxt;
        end else begin
            Error(ErrorLabel, Format(Resp.HttpStatusCode()), Resp.ReasonPhrase())
        end;
    end;

    internal procedure HandleEftResponse(HttpXmlResponse: Text; var EftReq: Record "NPR EFT Transaction Request")
    var
        RespHandler: Codeunit "NPR EFT Planet PAX Response";
        OldEftReq: Record "NPR EFT Transaction Request";
    begin
        case EftReq."Processing Type" of
            EftReq."Processing Type"::PAYMENT:
                begin
                    if (not RespHandler.HandleEftPaymentResponse(HttpXmlResponse, EftReq)) then
                        Message(GetLastErrorText());
                end;
            EftReq."Processing Type"::REFUND:
                begin
                    if (not RespHandler.HandleEftRefundResponse(HttpXmlResponse, EftReq)) then
                        Message(GetLastErrorText());
                end;
            EftReq."Processing Type"::LOOK_UP:
                begin
                    OldEftReq.Get(EftReq."Processed Entry No.");
                    if (not RespHandler.HandleEftLookupResponse(HttpXmlResponse, EftReq, OldEftReq)) then
                        Message(GetLastErrorText());
                    OldEftReq.Modify();
                end;
            EftReq."Processing Type"::VOID:
                begin
                    OldEftReq.Get(EftReq."Processed Entry No.");
                    if (not RespHandler.HandleEftVoidResponse(HttpXmlResponse, EftReq, OldEftReq)) then
                        Message(GetLastErrorText());
                    OldEftReq.Modify();
                end;
        end;
        RespHandler.ParseTransactionReceipts(EftReq);
        Commit();
    end;
}