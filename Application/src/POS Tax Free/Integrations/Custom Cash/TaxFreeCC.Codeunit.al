codeunit 6014661 "NPR Tax Free CC" implements "NPR Tax Free Handler Interface"
{
    // TEST: 5A@d3[wsDK[c97b
    // PROD: Rbdx8hhwTvsHENprTCcq
    // Login: Navipartner
    // Kode: Navipartner1234
    // ShopID: 11
    var
        TaxFreeCCPrint: Codeunit "NPR Tax Free CC Print";
        Handeled: Boolean;
        Error_NotSupported: Label 'Operation is not supported by tax free handler %1';
        Error_PrintFail: Label 'Printing of tax free voucher %1 failed with error "%2".\NOTE: The voucher is correctly issued and active. Please attempt using ''Reprint Last'' or reissuing the voucher if the print error persists.';


    procedure OnIsActiveSaleEligible(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean)
    begin
        Eligible := IsActiveSaleEligible(SalesTicketNo, TaxFreeRequest);
    end;


    procedure OnIsStoredSaleEligible(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean)
    begin
        Eligible := IsStoredSaleEligible(SalesTicketNo, TaxFreeRequest);
    end;

    procedure OnIsValidTerminalIIN(var TaxFreeRequest: Record "NPR Tax Free Request"; MaskedCardNo: Text; var IsForeignIIN: Boolean)
    begin
        IsForeignIIN := false;
        Error(Error_NotSupported, TaxFreeRequest."Handler ID Enum");
    end;

    procedure OnLookupHandlerParameter(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var Handled: Boolean; var tmpHandlerParameters: Record "NPR Tax Free Handler Param." temporary)
    begin
        Handled := false;
        Error(Error_NotSupported, TaxFreeUnit."Handler ID Enum");
    end;

    procedure OnSetUnitParameters(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var Handled: Boolean)
    var
        TaxFreeCCParam: Record "NPR Tax Free CC Param.";
    begin
        Handled := true;

        if not TaxFreeCCParam.Get(TaxFreeUnit."POS Unit No.") then begin
            TaxFreeCCParam.Init();
            TaxFreeCCParam."Tax Free POS Unit Code" := TaxFreeUnit."POS Unit No.";
            TaxFreeCCParam.Insert();
            Commit();
        end;

        Page.RunModal(0, TaxFreeCCParam);
    end;

    procedure OnUnitAutoConfigure(var TaxFreeRequest: Record "NPR Tax Free Request"; Silent: Boolean)
    begin
        Error(Error_NotSupported, TaxFreeRequest."Handler ID Enum");
    end;

    procedure OnUnitTestConnection(var TaxFreeRequest: Record "NPR Tax Free Request")
    begin
        Error(Error_NotSupported, TaxFreeRequest."Handler ID Enum");
    end;

    procedure OnVoucherConsolidate(var TaxFreeRequest: Record "NPR Tax Free Request"; var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary)
    begin
        Error(Error_NotSupported, TaxFreeRequest."Handler ID Enum");
    end;

    procedure OnVoucherIssueFromPOSSale(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesReceiptNo: Code[20]; var SkipRecordHandling: Boolean)
    begin
        SkipRecordHandling := false;
        IssueVoucher(TaxFreeRequest, SalesReceiptNo)
    end;

    procedure OnVoucherLookup(var TaxFreeRequest: Record "NPR Tax Free Request"; VoucherNo: Text)
    begin
        Error(Error_NotSupported, TaxFreeRequest."Handler ID Enum");
    end;

    procedure OnVoucherPrint(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; IsRecentVoucher: Boolean)
    begin
        ClearLastError();
        Clear(TaxFreeCCPrint);
        TaxFreeCCPrint.SetExternalVoucherNo(TaxFreeVoucher."External Voucher No.");
        if not TaxFreeCCPrint.Run(TaxFreeRequest) then
            Error(Error_PrintFail, TaxFreeVoucher."External Voucher No.", GetLastErrorText);
    end;

    procedure OnVoucherReissue(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher")
    begin
        Error(Error_NotSupported, TaxFreeRequest."Handler ID Enum");
    end;

    procedure OnVoucherVoid(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher")
    begin
        Error(Error_NotSupported, TaxFreeRequest."Handler ID Enum");
    end;

    local procedure IssueVoucher(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesReceiptNo: Code[20])
    begin
        OnBeforeIssueVoucher(TaxFreeRequest, SalesReceiptNo, Handeled);
        if Handeled then
            exit;

        CreateRequest(TaxFreeRequest, SalesReceiptNo);
        SendRequest(TaxFreeRequest);
        ParseIssueVoucher(TaxFreeRequest);
    end;

    local procedure ParseIssueVoucher(var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        InStr: InStream;
        JsonResponse: Text;
        JsonTok: JsonToken;
        JsonObj: JsonObject;
        JsonTokValue: JsonToken;
    begin
        TaxFreeRequest.Response.CreateInStream(InStr, TEXTENCODING::UTF8);
        InStr.Read(JsonResponse);

        JsonTok.ReadFrom(JsonResponse);
        JsonObj := JsonTok.AsObject();
        JsonObj.Get('status', JsonTokValue);
        if JsonTokValue.AsValue().AsText() = 'error' then begin
            JsonObj.Get('message', JsonTokValue);
            Error(JsonTokValue.AsValue().AsText());
        end;
        JsonObj.Get('receipt', JsonTokValue);

        JsonObj := JsonTokValue.AsObject();

        JsonObj.Get('number', JsonTokValue);

        TaxFreeRequest."External Voucher No." := JsonTokValue.AsValue().AsText();
        TaxFreeRequest."External Voucher Barcode" := JsonTokValue.AsValue().AsText();

        JsonObj.Get('purchaseAmount', JsonTokValue);
        TaxFreeRequest."Total Amount Incl. VAT" := JsonTokValue.AsValue().AsDecimal();

        JsonObj.Get('refundAmount', JsonTokValue);
        TaxFreeRequest."Refund Amount" := JsonTokValue.AsValue().AsDecimal();

        GetPrintJson(TaxFreeRequest, TaxFreeRequest."External Voucher No.");

        TaxFreeRequest."Print Type" := TaxFreeRequest."Print Type"::Thermal;

        TaxFreeRequest.Success := true;
        TaxFreeRequest."Date End" := Today;
        TaxFreeRequest."Time End" := Time;
    end;

    local procedure SendRequest(var TaxFreeRequest: Record "NPR Tax Free Request")
    var
        InStr: InStream;
        OutStr: OutStream;
        JsonRequest: Text;
        HttpClnt: HttpClient;
        HttpReqMessage: HttpRequestMessage;
        HttpRespMessage: HttpResponseMessage;
        HttpReqHdr: HttpHeaders;
        HttpHdr: HttpHeaders;
        HttpCont: HttpContent;
        TaxFreeCCParam: Record "NPR Tax Free CC Param.";
    begin
        TaxFreeCCParam.Get(TaxFreeRequest."POS Unit No.");
        TaxFreeRequest.Request.CreateInStream(InStr, TEXTENCODING::UTF8);
        InStr.Read(JsonRequest);

        HttpClnt.DefaultRequestHeaders.Clear();

        if TaxFreeRequest.Mode = TaxFreeRequest.Mode::PROD then
            HttpReqMessage.SetRequestUri(ServicePROD())
        else
            HttpReqMessage.SetRequestUri(ServiceTEST());

        if TaxFreeRequest."Timeout (ms)" > 0 then
            HttpClnt.Timeout := TaxFreeRequest."Timeout (ms)"
        else
            HttpClnt.Timeout := 10000;

        HttpCont.WriteFrom(JsonRequest);
        HttpCont.GetHeaders(HttpHdr);

        HttpHdr.Clear();
        HttpHdr.Add('Content-Type', 'application/json');

        HttpReqMessage.GetHeaders(HttpReqHdr);
        HttpReqHdr.Clear();
        HttpReqHdr.Add('X-AUTH-TOKEN', TaxFreeCCParam.GetXAuth());
        HttpReqHdr.Add('Authorization', 'Basic ' + GetBasicAuthInfo(TaxFreeCCParam."Shop User Name", TaxFreeCCParam.GetPassword()));

        HttpReqMessage.Method('POST');
        HttpReqMessage.Content := HttpCont;

        if not HttpClnt.Send(HttpReqMessage, HttpRespMessage) then
            error('%1 - %2', HttpRespMessage.HttpStatusCode, HttpRespMessage.ReasonPhrase);

        TaxFreeRequest.Response.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        HttpRespMessage.Content.ReadAs(JsonRequest);
        OutStr.Write(JsonRequest);
    end;

    local procedure ServicePROD(): Text
    begin

        exit('https://customcash.com/api/POS/receipts');
    end;

    local procedure ServiceTEST(): Text
    begin
        exit('https://test.customcash.com/api/POS/receipts');
    end;

    local procedure CreateRequest(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesReceiptNo: Code[20])
    var
        RequestJson: JsonObject;
        TaxFreeCCParam: Record "NPR Tax Free CC Param.";
        PosSalesLine: Record "NPR POS Entry Sales Line";
        PosEntry: Record "NPR POS Entry";
        OutStr: OutStream;
        JsonRequest: Text;
        GLSetup: Record "General Ledger Setup";
        MultipleVATPctErr: Label 'You cannot issue voucher with different VAT %.';
    begin
        TaxFreeCCParam.Get(TaxFreeRequest."POS Unit No.");

        CheckParams(TaxFreeCCParam);

        RequestJson.Add('externalShopId', TaxFreeCCParam."Shop ID");
        RequestJson.Add('externalFormNumber', SalesReceiptNo);


        PosSalesLine.Reset();
        Clear(PosSalesLine);
        PosSalesLine.SetRange("Document No.", SalesReceiptNo);
        PosSalesLine.SetRange(Type, PosSalesLine.Type::Item);
        PosSalesLine.SetFilter(Quantity, '>0');
        PosSalesLine.FindFirst();

        PosSalesLine.SetFilter("VAT %", '<>%1', PosSalesLine."VAT %");
        if not PosSalesLine.IsEmpty then
            Error(MultipleVATPctErr);

        PosSalesLine.SetRange("VAT %");

        PosSalesLine.CalcSums("Amount Incl. VAT");
        RequestJson.Add('amount', PosSalesLine."Amount Incl. VAT");

        PosEntry.Get(PosSalesLine."POS Entry No.");
        if PosEntry."Currency Code" = '' then begin
            GLSetup.Get();
            GLSetup.TestField("LCY Code");
            RequestJson.Add('currency', GLSetup."LCY Code");
        end else
            RequestJson.Add('currency', PosEntry."Currency Code");

        RequestJson.Add('purchasedAt', FormatDateTime(CreateDateTime(PosEntry."Entry Date", PosEntry."Ending Time")));
        RequestJson.Add('vatPercentage', Format(PosSalesLine."VAT %", 0, 9));
        TaxFreeRequest.Request.CreateOutStream(OutStr);

        RequestJson.WriteTo(JsonRequest);

        OutStr.Write(JsonRequest);
    end;

    local procedure FormatDateTime(DateTime: DateTime): Text
    var
        DotNet_DateTimeOffset: Codeunit DotNet_DateTimeOffset;
        OffSet: Integer;
    begin
        OffSet := DotNet_DateTimeOffset.GetOffset() / 1000 / 60 / 60;
        exit(Format(DotNet_DateTimeOffset.ConvertToUtcDateTime(DateTime), 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>' + '+' + Format(OffSet) + ':00'))
    end;

    local procedure CheckParams(TaxFreeCCParam: Record "NPR Tax Free CC Param.")
    begin
        TaxFreeCCParam.TestField("Shop User Name");
        TaxFreeCCParam.TestField("X Auth Token");
        TaxFreeCCParam.TestField("Shop Password");
        TaxFreeCCParam.TestField("Shop ID");
    end;

    [NonDebuggable]
    local procedure GetBasicAuthInfo(Username: Text; Password: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        SubMsg: Label '%1:%2', Locked = true;
    begin
        exit(Base64Convert.ToBase64(StrSubstNo(SubMsg, Username, Password)))
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIssueVoucher(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesReceiptNo: Code[20]; var Handeled: Boolean)
    begin
    end;
    #region Eligible check
    local procedure IsActiveSaleEligible(SalesTicketNo: Text; TaxFreeRequest: Record "NPR Tax Free Request"): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TaxFreeCCParam: Record "NPR Tax Free CC Param.";
    begin
        SaleLinePOS.SetRange("Sales Ticket No.", SalesTicketNo);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetFilter(Quantity, '>0');
        SaleLinePOS.SetFilter("VAT %", '>0');

        if SaleLinePOS.IsEmpty() then
            exit(false);

        SaleLinePOS.CalcSums("Amount Including VAT");

        TaxFreeCCParam.Get(TaxFreeRequest."POS Unit No.");
        if (TaxFreeCCParam."Minimal Amount" <> 0) and (TaxFreeCCParam."Maximal Amount" <> 0) then
            exit(SaleLinePOS."Amount Including VAT" in [TaxFreeCCParam."Minimal Amount" .. TaxFreeCCParam."Maximal Amount"]);

        if (TaxFreeCCParam."Minimal Amount" <> 0) then
            exit(SaleLinePOS."Amount Including VAT" >= TaxFreeCCParam."Minimal Amount");

        if (TaxFreeCCParam."Maximal Amount" <> 0) then
            exit(SaleLinePOS."Amount Including VAT" <= TaxFreeCCParam."Maximal Amount");

        exit(true)
    end;

    local procedure IsStoredSaleEligible(SalesTicketNo: Text; TaxFreeRequest: Record "NPR Tax Free Request"): Boolean
    var
        TaxFreeCCParam: Record "NPR Tax Free CC Param.";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
    begin
        POSSalesLine.SetCurrentKey("Document No.", "Line No.");
        POSSalesLine.SetRange("Document No.", SalesTicketNo);
        POSSalesLine.SetRange(Type, POSSalesLine.Type::Item);
        POSSalesLine.SetFilter(Quantity, '>0');
        POSSalesLine.SetFilter("VAT %", '>0');

        if not POSSalesLine.FindFirst() then
            exit(false);

        POSSalesLine.CalcSums("Amount Incl. VAT (LCY)");

        POSEntry.Get(POSSalesLine."POS Entry No.");

        if POSEntry."Entry Type" <> POSEntry."Entry Type"::"Direct Sale" then
            exit;

        TaxFreeCCParam.Get(TaxFreeRequest."POS Unit No.");

        if (TaxFreeCCParam."Minimal Amount" <> 0) and (TaxFreeCCParam."Maximal Amount" <> 0) then
            exit(POSSalesLine."Amount Incl. VAT (LCY)" in [TaxFreeCCParam."Minimal Amount" .. TaxFreeCCParam."Maximal Amount"]);

        if (TaxFreeCCParam."Minimal Amount" <> 0) then
            exit(POSSalesLine."Amount Incl. VAT (LCY)" >= TaxFreeCCParam."Minimal Amount");

        if (TaxFreeCCParam."Maximal Amount" <> 0) then
            exit(POSSalesLine."Amount Incl. VAT (LCY)" <= TaxFreeCCParam."Maximal Amount");

        exit(true)
    end;
    #endregion
    procedure GetPrintJson(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucherNo: Text)
    var
        OutStr: OutStream;
        JsonRequest: Text;
        HttpClnt: HttpClient;
        HttpReqMessage: HttpRequestMessage;
        HttpRespMessage: HttpResponseMessage;
        HttpReqHdr: HttpHeaders;
        HttpHdr: HttpHeaders;
        HttpCont: HttpContent;
        AddToLink: Text;
        TaxFreeCCParam: Record "NPR Tax Free CC Param.";
    begin
        TaxFreeRequest.CalcFields(Print);
        if TaxFreeRequest.Print.HasValue then
            exit;

        TaxFreeCCParam.Get(TaxFreeRequest."POS Unit No.");

        AddToLink := '/' + TaxFreeVoucherNo + '/json/print';

        if TaxFreeRequest.Mode = TaxFreeRequest.Mode::PROD then
            HttpReqMessage.SetRequestUri(ServicePROD() + AddToLink)
        else
            HttpReqMessage.SetRequestUri(ServiceTEST() + AddToLink);

        if TaxFreeRequest."Timeout (ms)" > 0 then
            HttpClnt.Timeout := TaxFreeRequest."Timeout (ms)"
        else
            HttpClnt.Timeout := 10000;

        HttpCont.GetHeaders(HttpHdr);

        HttpHdr.Clear();
        HttpHdr.Add('Content-Type', 'application/json');

        HttpReqMessage.GetHeaders(HttpReqHdr);
        HttpReqHdr.Clear();
        HttpReqHdr.Add('X-AUTH-TOKEN', TaxFreeCCParam.GetXAuth());
        HttpReqHdr.Add('Authorization', 'Basic ' + GetBasicAuthInfo(TaxFreeCCParam."Shop User Name", TaxFreeCCParam.GetPassword()));
        HttpReqMessage.Method('GET');

        if not HttpClnt.Send(HttpReqMessage, HttpRespMessage) then
            error('%1 - %2', HttpRespMessage.HttpStatusCode, HttpRespMessage.ReasonPhrase);

        TaxFreeRequest.Print.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        HttpRespMessage.Content.ReadAs(JsonRequest);
        OutStr.Write(JsonRequest);
    end;

}
