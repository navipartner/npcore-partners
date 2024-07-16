codeunit 6151422 "NPR Magento Pmt. Adyen Mgt." implements "NPR IPaymentGateway"
{
    Access = Internal;

    var
        WrongTableSuppliedErr: Label 'The table supplied (%1) is wrong. Expected table no. in (%2).', Comment = '%1 = actual table no., %2 = expected table no. or range of numbers';
        NoReferenceGivenLbl: Label 'No BC reference given';
        PayByLinkSetupGotten: Boolean;
        PayByLinkSetup: Record "NPR Pay By Link Setup";
        ShowCancelMsg: Boolean;

    #region Payment Integration
    local procedure CaptureInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        AdyenSetup: Record "NPR PG Adyen Setup";
        HttpWebRequest: HttpRequestMessage;
        JsonO: JsonObject;
        JsonT: JsonToken;
        Url: Text;
        RequestTxt: Text;
        CurrencyCode: Code[10];
        Reference: Text;
        ResponseTxt: Text;
        ResponseJson: Text;
    begin
        AdyenSetup.Get(Request."Payment Gateway Code");
        Url := AdyenSetup.GetAPIBaseUrl() + 'capture';

        case Request."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    SalesHeader.GetBySystemId(Request."Document System Id");
                    CurrencyCode := SalesHeader."Currency Code";
                    Reference := SalesHeader."No.";
                    if SalesHeader."NPR External Order No." <> '' then
                        Reference := SalesHeader."NPR External Order No.";
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    SalesInvHeader.GetBySystemId(Request."Document System Id");
                    CurrencyCode := SalesInvHeader."Currency Code";
                    Reference := SalesInvHeader."No.";
                    if SalesInvHeader."NPR External Order No." <> '' then
                        Reference := SalesInvHeader."NPR External Order No.";
                end;
            else
                Error(WrongTableSuppliedErr, Request."Document Table No.", StrSubstNo('%1, %2', Database::"Sales Header", Database::"Sales Invoice Header"));
        end;

        if CurrencyCode = '' then begin
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        RequestTxt :=
          '{' +
          '  "originalReference": "' + Request."Transaction ID" + '",' +
          '  "modificationAmount": {' +
          '    "value": ' + ConvertToAdyenPayAmount(Request."Request Amount") + ',' +
          '    "currency": "' + CurrencyCode + '"' +
          '  },' +
          '  "reference": "' + Reference + '",' +
          '  "merchantAccount": "' + AdyenSetup."Merchant Name" + '"' +
          '}';

        Request.AddBody(RequestTxt);
        InitWebRequest(Url, AdyenSetup."API Username", AdyenSetup.GetApiPassword(), HttpWebRequest, RequestTxt);

        ResponseJson := SendWebRequest(HttpWebRequest, Response);

        if (not JsonO.ReadFrom(ResponseJson)) then
            Error(ResponseJson);

        JsonO.Get('response', JsonT);
        ResponseTxt := JsonT.AsValue().AsText();
        if ResponseTxt <> '[capture-received]' then
            Error(ResponseTxt);

        Response."Response Success" := true;
    end;

    local procedure CancelInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        AdyenSetup: Record "NPR PG Adyen Setup";
        HttpWebRequest: HttpRequestMessage;
        JsonO: JsonObject;
        JsonT: JsonToken;
        Url: Text;
        RequestTxt: Text;
        Reference: Text;
        ResponseTxt: Text;
        ResponseJson: Text;
    begin
        AdyenSetup.Get(Request."Payment Gateway Code");
        Url := AdyenSetup.GetAPIBaseUrl() + 'cancel';

        if (Request."Document Table No." <> Database::"Sales Header") and (Request."Document Table No." <> Database::"Sales Invoice Header") then
            Error(WrongTableSuppliedErr, Request."Document Table No.", StrSubstNo('%1, %2', Database::"Sales Header", Database::"Sales Invoice Header"));

        Reference := Request."Request Description";
        if (Reference = '') then
            Reference := NoReferenceGivenLbl;

        RequestTxt :=
          '{' +
          '  "originalReference": "' + Request."Transaction ID" + '",' +
          '  "reference": "' + Reference + '",' +
          '  "merchantAccount": "' + AdyenSetup."Merchant Name" + '"' +
          '}';

        Request.AddBody(RequestTxt);
        InitWebRequest(Url, AdyenSetup."API Username", AdyenSetup.GetApiPassword(), HttpWebRequest, RequestTxt);

        ResponseJson := SendWebRequest(HttpWebRequest, Response);

        if not JsonO.ReadFrom(ResponseJson) then
            Error(ResponseJson);

        JsonO.Get('response', JsonT);
        ResponseTxt := JsonT.AsValue().AsText();
        if ResponseTxt <> '[cancel-received]' then
            Error(ResponseTxt);

        Response."Response Success" := true;
    end;

    local procedure RefundInternal(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        AdyenSetup: Record "NPR PG Adyen Setup";
        HttpWebRequest: HttpRequestMessage;
        JsonO: JsonObject;
        JsonT: JsonToken;
        Url: Text;
        RequestTxt: Text;
        CurrencyCode: Code[10];
        Reference: Text;
        ResponseTxt: Text;
        ResponseJson: Text;
    begin
        AdyenSetup.Get(Request."Payment Gateway Code");
        Url := AdyenSetup.GetAPIBaseUrl() + 'refund';

        case Request."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    SalesHeader.GetBySystemId(Request."Document System Id");
                    CurrencyCode := SalesHeader."Currency Code";
                    Reference := SalesHeader."No.";
                    if SalesHeader."NPR External Order No." <> '' then
                        Reference := SalesHeader."NPR External Order No.";
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader.GetBySystemId(Request."Document System Id");
                    CurrencyCode := SalesCrMemoHeader."Currency Code";
                    Reference := SalesCrMemoHeader."No.";
                    if SalesCrMemoHeader."NPR External Order No." <> '' then
                        Reference := SalesCrMemoHeader."NPR External Order No.";
                end;
            else
                Error(WrongTableSuppliedErr, Request."Document Table No.", StrSubstNo('%1, %2', Database::"Sales Header", Database::"Sales Cr.Memo Header"));
        end;

        if CurrencyCode = '' then begin
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        RequestTxt :=
          '{' +
          '  "originalReference": "' + Request."Transaction ID" + '",' +
          '  "modificationAmount": {' +
          '    "value": ' + ConvertToAdyenPayAmount(Request."Request Amount") + ',' +
          '    "currency": "' + CurrencyCode + '"' +
          '  },' +
          '  "reference": "' + Reference + '",' +
          '  "merchantAccount": "' + AdyenSetup."Merchant Name" + '"' +
          '}';

        Request.AddBody(RequestTxt);
        InitWebRequest(Url, AdyenSetup."API Username", AdyenSetup.GetApiPassword(), HttpWebRequest, RequestTxt);

        ResponseJson := SendWebRequest(HttpWebRequest, Response);

        if not JsonO.ReadFrom(ResponseJson) then
            Error(ResponseJson);

        JsonO.Get('response', JsonT);
        ResponseTxt := JsonT.AsValue().AsText();
        if ResponseTxt <> '[refund-received]' then
            Error(ResponseTxt);

        Response."Response Success" := true;
    end;

    procedure CheckIsPaid(var MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        HttpWebRequest: HttpRequestMessage;
        JsonO: JsonObject;
        JsonT: JsonToken;
        Url: Text;
        ResponseTxt: Text;
        ResponseJson: Text;
        Content: HttpContent;
        Headers: HttpHeaders;
        HeadersReq: HttpHeaders;
        Response: Record "NPR PG Payment Response";
        JsonValueToken: JsonToken;
        AdyenPGSetup: Record "NPR PG Adyen Setup";
    begin
        GetPayByLinkSetup();

        if not AdyenPGSetup.Get(PayByLinkSetup."Payment Gateaway Code") then
            exit;

        Url := AdyenPGSetup.GetAPIPayByLinkUrl() + '/' + MagentoPaymentLine."Payment ID";

        HttpWebRequest.GetHeaders(HeadersReq);
        Content.GetHeaders(Headers);

        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
        HeadersReq.Add('Authorization', CreateBasicAuth(AdyenPGSetup."API Username", AdyenPGSetup.GetApiPassword()));

        HttpWebRequest.Content(Content);
        HttpWebRequest.SetRequestUri(Url);
        HttpWebRequest.Method := 'GET';

        ResponseJson := SendWebRequest(HttpWebRequest, Response);

        if (not JsonO.ReadFrom(ResponseJson)) then
            Error(ResponseJson);

        JsonO.Get('status', JsonT);
        ResponseTxt := JsonT.AsValue().AsText();
        if ResponseTxt = 'completed' then begin
            if JsonO.Get('amount', JsonT) then
                if JsonT.IsObject() then
                    if JsonT.AsObject().Get('value', JsonValueToken) then begin
                        ResponseTxt := JsonValueToken.AsValue().AsText();
                        if ConvertFromAdyenPayAmount(ResponseTxt) = MagentoPaymentLine."Requested Amount" then begin
                            MagentoPaymentLine.Amount := MagentoPaymentLine."Requested Amount";
                            if JsonO.Get('pspReference', JsonValueToken) then begin
                                ResponseTxt := JsonValueToken.AsValue().AsText();
                                MagentoPaymentLine."Transaction ID" := CopyStr(ResponseTxt, 1, MaxStrLen(MagentoPaymentLine."Transaction ID"));
                            end;
                            MagentoPaymentLine.Modify();
                        end;
                    end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'OnAfterPostMagentoPayment', '', true, false)]
    local procedure CancelOutstandingPaymentLines(SalesInvHeader: Record "Sales Invoice Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        CancelPaymentLine: Record "NPR Magento Payment Line";
    begin
        if SalesInvHeader.IsTemporary then
            exit;

        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Quote);
        PaymentLine.SetRange("Document No.", SalesInvHeader."No.");
        if PaymentLine.IsEmpty then
            exit;

        PaymentLine.FindSet();
        repeat
            if IsAdyenPayByLinkLine(PaymentLine) then
                if CalculatePSPAmount(PaymentLine."Transaction ID") < PaymentLine."Requested Amount" then begin
                    CancelPaymentLine.Setrange("Transaction ID", PaymentLine."Transaction ID");
                    CancelPaymentLine.Setrange("Document Table No.", Database::"Sales Header");
                    if CancelPaymentLine.IsEmpty then
                        MagentoPmtMgt.CancelPaymentLine(PaymentLine);
                end;
        until PaymentLine.Next() = 0;
    end;

    local procedure CalculatePSPAmount(PSPReference: Text[250]): Decimal
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Transaction ID", PSPReference);
        PaymentLine.SetFilter("Document Table No.", '%1|%2', Database::"Sales Header", Database::"Sales Invoice Header");
        PaymentLine.CalcSums(Amount);

        exit(PaymentLine.Amount);
    end;

    procedure SendPayByLinkRequest(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response"; var MagentoPaymentLine: Record "NPR Magento Payment Line"; ExpirationDuration: Duration)
    var
        HttpWebRequest: HttpRequestMessage;
        JsonO: JsonObject;
        JRequestBody: JsonObject;
        JRequestBodyAmt: JsonObject;
        Url: Text;
        RequestTxt: Text;
        Reference: Text;
        ResponseJson: Text;
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        CurrencyCode: Code[10];
        ExpireDate: DateTime;
        ISO8601Date: Text[50];
        AdyenPGSetup: Record "NPR PG Adyen Setup";
    begin
        if not AdyenPGSetup.Get(PayByLinkSetup."Payment Gateaway Code") then
            exit;

        Url := AdyenPGSetup.GetAPIPayByLinkUrl();

        case Request."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    SalesHeader.GetBySystemId(Request."Document System Id");
                    CurrencyCode := SalesHeader."Currency Code";
                    Reference := SalesHeader."No.";
                    if SalesHeader."NPR External Order No." <> '' then
                        Reference := SalesHeader."NPR External Order No.";
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    SalesInvHeader.GetBySystemId(Request."Document System Id");
                    CurrencyCode := SalesInvHeader."Currency Code";
                    Reference := SalesInvHeader."No.";
                    if SalesInvHeader."NPR External Order No." <> '' then
                        Reference := SalesInvHeader."NPR External Order No.";
                end;
            else
                Error(WrongTableSuppliedErr, Request."Document Table No.", StrSubstNo('%1, %2', Database::"Sales Header", Database::"Sales Invoice Header"));
        end;

        if CurrencyCode = '' then begin
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        JRequestBodyAmt.Add('value', ConvertToAdyenPayAmount(Request."Request Amount"));
        JRequestBodyAmt.Add('currency', CurrencyCode);

        JRequestBody.Add('reference', Reference);
        JRequestBody.Add('amount', JRequestBodyAmt);
        JRequestBody.Add('merchantAccount', AdyenPGSetup."Merchant Name");
        JRequestBody.Add('manualCapture', true);

        if Format(ExpirationDuration) <> '' then begin
            ExpireDate := CurrentDateTime + ExpirationDuration;
            ISO8601Date := Format(ExpireDate, 0, 9);
            JRequestBody.Add('expiresAt', ISO8601Date);
        end;

        JRequestBody.WriteTo(RequestTxt);

        Request.AddBody(JRequestBody);
        InitWebRequest(Url, AdyenPGSetup."API Username", AdyenPGSetup.GetApiPassword(), HttpWebRequest, RequestTxt);

        ResponseJson := SendWebRequest(HttpWebRequest, Response);

        if not JsonO.ReadFrom(ResponseJson) then
            Error(ResponseJson);

        Response.AddResponse(ResponseJson);
        Response."Response Success" := true;
    end;

    procedure CancelAdyenPayByLink(var MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        HttpWebRequest: HttpRequestMessage;
        Response: Record "NPR PG Payment Response";
        PGInteractionsLogMgt: Codeunit "NPR PG Interactions Log Mgt.";
        Log: Record "NPR PG Interaction Log Entry";
        Request: Record "NPR PG Payment Request";
        SuccessMsg: Label 'The Pay by Link %1 has been successfully cancelled.';
    begin
        ClearLastError();

        CheckIfCanBeCanceled(MagentoPaymentLine);

        CreateCancelLinkRequest(MagentoPaymentLine, HttpWebRequest, Request);

        PGInteractionsLogMgt.LogPayByLinkCancelStart(Log, MagentoPaymentLine.SystemId);

        SendCancelLinkRequest(HttpWebRequest, Response);

        PGInteractionsLogMgt.LogOperationFinished(Log, Request, Response, Response."Response Success", GetLastErrorText());

        UpdatePaymentMagentoLine(MagentoPaymentLine, Response, true);
        if ShowCancelMsg then
            Message(SuccessMsg, MagentoPaymentLine."Pay by Link URL");
    end;

    procedure SetShowCancelMsg(NewShowCancelMsg: Boolean)
    begin
        ShowCancelMsg := NewShowCancelMsg;
    end;

    procedure ResendPayByLink(MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        PayByLinkDialog: Page "NPR Pay by Link Dialog";
        SendEmail: Boolean;
        SendSMS: Boolean;
        Email: Text[80];
        PhoneNo: Text[30];
    begin
        GetPayByLinkSetup();

        PayByLinkDialog.SetResending();
        PayByLinkDialog.SetValues(MagentoPaymentLine."Requested Amount", Email, '', false, false, PayByLinkSetup."Pay by Link Exp. Duration");
        if PayByLinkDialog.RunModal() = Action::OK then begin
            PayByLinkDialog.GetValues(MagentoPaymentLine."Requested Amount", Email, PhoneNo, SendEmail, SendSMS, PayByLinkSetup."Pay by Link Exp. Duration");
            if SendEmail then
                SendEmailNotification(Email, PayByLinkSetup."E-Mail Template", MagentoPaymentLine);

            if SendSMS then
                SendSMSFromMagentoLine(MagentoPaymentLine, PhoneNo, PayByLinkSetup."SMS Template");
        end;
    end;

    local procedure GetDocument(RecVariant: Variant; var FullAmount: Decimal; var DocumentTableNo: Integer; var DocumentNo: Code[20]; var SalesDocumentType: Enum "Sales Document Type"; var CustomerNo: Code[20])
    var
        RecRef: RecordRef;
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        UnsupportedErr: Label 'Unsupported document type';
    begin
        RecRef.GetTable(RecVariant);

        case RecRef.Number of
            Database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    SalesHeader.CalcFields("Amount Including VAT");
                    FullAmount := SalesHeader."Amount Including VAT";
                    DocumentTableNo := Database::"Sales Header";
                    DocumentNo := SalesHeader."No.";
                    SalesDocumentType := SalesHeader."Document Type";
                    CustomerNo := SalesHeader."Bill-to Customer No.";
                end;
            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvoiceHeader);
                    SalesInvoiceHeader.CalcFields("Amount Including VAT");
                    FullAmount := SalesInvoiceHeader."Amount Including VAT";
                    DocumentTableNo := Database::"Sales Invoice Header";
                    DocumentNo := SalesInvoiceHeader."No.";
                    SalesDocumentType := SalesDocumentType::Quote;
                    CustomerNo := SalesInvoiceHeader."Bill-to Customer No.";
                end;
            else
                Error(UnsupportedErr);
        end;
    end;

    procedure IssuePayByLink(RecVariant: Variant; ShowDialog: Boolean)
    var
        Request: Record "NPR PG Payment Request";
        Response: Record "NPR PG Payment Response";
        FullAmount: Decimal;
        DocumentTableNo: Integer;
        DocumentNo: Code[20];
        SalesDocumentType: Enum "Sales Document Type";
        CustomerNo: Code[20];
        AmtToPay: Decimal;
        RequestedAmt: Decimal;
        RequestedExpDate: Duration;
        PGInteractionsLogMgt: Codeunit "NPR PG Interactions Log Mgt.";
        Log: Record "NPR PG Interaction Log Entry";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        SendEmail: Boolean;
        Email: Text[80];
        SendSMS: Boolean;
        PhoneNo: Text[30];
    begin
        ClearLastError();

        GetPayByLinkSetup();

        PayByLinkSetup.TestField("Enable Pay by Link");

        RequestedExpDate := PayByLinkSetup."Pay by Link Exp. Duration";

        GetDocument(RecVariant, FullAmount, DocumentTableNo, DocumentNo, SalesDocumentType, CustomerNo);

        AmtToPay := GetAmountToPay(FullAmount, DocumentTableNo, DocumentNo, SalesDocumentType);

        GetPayByLinkParams(CustomerNo, AmtToPay, RequestedAmt, RequestedExpDate, SendEmail, Email, SendSMS, PhoneNo, ShowDialog);

        DocumentToRequest(Request, RecVariant, RequestedAmt, PayByLinkSetup."Payment Gateaway Code");

        CreateMagentoPaymentLine(Request, MagentoPaymentLine);

        PGInteractionsLogMgt.LogPayByLinkStart(Log, MagentoPaymentLine.SystemId);

        SendPayByLinkRequest(Request, Response, MagentoPaymentLine, RequestedExpDate);

        PGInteractionsLogMgt.LogOperationFinished(Log, Request, Response, Response."Response Success", GetLastErrorText());

        UpdatePaymentMagentoLine(MagentoPaymentLine, Response, false);

        if SendEmail then
            SendEmailNotification(Email, PayByLinkSetup."E-Mail Template", MagentoPaymentLine);

        if SendSMS then
            SendSMSFromMagentoLine(MagentoPaymentLine, PhoneNo, PayByLinkSetup."SMS Template");
    end;

    local procedure GetPayByLinkParams(CustomerNo: Code[20]; AmtToPay: Decimal; var RequestedAmt: Decimal; var RequestedExpDate: Duration; var SendEmail: Boolean; var Email: Text[80]; var SendSMS: Boolean; var PhoneNo: Text[30]; ShowDialog: Boolean)
    var
        PayByLinkAmountDialog: Page "NPR Pay by Link Dialog";
        Customer: Record Customer;
        AmountErr: Label 'Amount to pay is bigger than Amount of the document.';
        PayByLinkErr: Label 'Pay by Link is already issued with full amount.';
        PayByLinkAmtErr: Label 'Pay by Link with Amount %1 can''t be issued';
    begin
        if Customer.Get(CustomerNo) then begin
            Email := Customer."E-Mail";
            PhoneNo := Customer."Mobile Phone No.";
            SendEmail := Email <> '';
            SendSMS := PhoneNo <> '';
        end;

        If AmtToPay = 0 then
            Error(PayByLinkErr);

        if not ShowDialog then begin
            RequestedAmt := AmtToPay;
            exit;
        end;

        PayByLinkAmountDialog.SetValues(AmtToPay, Email, PhoneNo, SendEmail, SendSMS, RequestedExpDate);
        if PayByLinkAmountDialog.RunModal() = Action::OK then begin
            PayByLinkAmountDialog.GetValues(RequestedAmt, Email, PhoneNo, SendEmail, SendSMS, RequestedExpDate);
            If RequestedAmt > AmtToPay then
                Error(AmountErr);
            if RequestedAmt = 0 then
                Error(PayByLinkAmtErr, RequestedAmt);
        end else
            Error('');
    end;

    local procedure SendSMSFromMagentoLine(MagentoPaymentLine: Record "NPR Magento Payment Line"; PhoneNo: Text[30]; SMSTemplateCode: Code[10])
    var
        SMSTemplateHeader: Record "NPR SMS Template Header";
        SMSMessage: Text;
        SMSSetup: Record "NPR SMS Setup";
        SmsTemplateErr: Label 'Template %1 not found among SMS Templates.';
        SenderNo: Text[30];
        SMSManagement: Codeunit "NPR SMS Management";
    begin
        if SMSTemplateHeader.Get(SMSTemplateCode) then begin
            SMSMessage := SMSManagement.MakeMessage(SMSTemplateHeader, MagentoPaymentLine);
            SenderNo := SMSTemplateHeader."Alt. Sender";
            if SenderNo = '' then begin
                SMSSetup.Get();
                SenderNo := SMSSetup."Default Sender No.";
            end;
            SMSManagement.SendSMS(PhoneNo, SenderNo, SMSMessage);
        end else
            Error(SmsTemplateErr, SMSTemplateCode);

    end;

    local procedure GetAmountToPay(FullAmount: Decimal; DocumentTableNo: Integer; DocumentNo: Code[20]; SalesDocumentType: Enum "Sales Document Type") AmountToPay: Decimal;
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        PaidAmount: Decimal;
    begin
        CalculateCapturedAmount(DocumentTableNo, DocumentNo, SalesDocumentType, MagentoPaymentLine, PaidAmount);

        CalculateRequestedAmount(DocumentTableNo, DocumentNo, SalesDocumentType, MagentoPaymentLine, PaidAmount);

        if PaidAmount = 0 then
            AmountToPay := FullAmount
        else
            AmountToPay := FullAmount - PaidAmount;

        if AmountToPay < 0 then
            AmountToPay := 0;
    end;

    local procedure UpsertShopperRef(PaymentLine: Record "NPR Magento Payment Line")
    var
        SalesHeader: Record "Sales Header";
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        EFTAdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integrat.";
        PrevRec: Text;
    begin
        if not IsAdyenPaymentLine(PaymentLine) then
            exit;
        if PaymentLine."Payment Gateway Shopper Ref." = '' then
            exit;
        if PaymentLine."Document Table No." <> DATABASE::"Sales Header" then
            exit;
        if not SalesHeader.Get(PaymentLine."Document Type", PaymentLine."Document No.") then
            exit;
        if SalesHeader."Sell-to Customer No." = '' then
            exit;

        if not EFTShopperRecognition.Get(EFTAdyenCloudIntegration.IntegrationType(), PaymentLine."Payment Gateway Shopper Ref.") then begin
            EFTShopperRecognition.Init();
            EFTShopperRecognition."Integration Type" := CopyStr(EFTAdyenCloudIntegration.IntegrationType(), 1, MaxStrLen(EFTShopperRecognition."Integration Type"));
            EFTShopperRecognition."Shopper Reference" := PaymentLine."Payment Gateway Shopper Ref.";
            EFTShopperRecognition."Entity Type" := EFTShopperRecognition."Entity Type"::Customer;
            EFTShopperRecognition."Entity Key" := SalesHeader."Sell-to Customer No.";
            EFTShopperRecognition.Insert(true);
        end;

        PrevRec := Format(EFTShopperRecognition);

        EFTShopperRecognition."Entity Type" := EFTShopperRecognition."Entity Type"::Customer;
        EFTShopperRecognition."Entity Key" := SalesHeader."Sell-to Customer No.";

        if PrevRec <> Format(EFTShopperRecognition) then
            EFTShopperRecognition.Modify(true);
    end;
    #endregion

    #region insert modify
    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Line", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertPaymentLine(var Rec: Record "NPR Magento Payment Line"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if not IsAdyenPaymentLine(Rec) then
            exit;

        UpsertShopperRef(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Line", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyPaymentLine(var Rec: Record "NPR Magento Payment Line"; var xRec: Record "NPR Magento Payment Line"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;
        if not IsAdyenPaymentLine(Rec) then
            exit;

        UpsertShopperRef(Rec);
    end;
    #endregion


    #region aux
    local procedure InitWebRequest(Url: Text; Username: Text; Password: Text; var HttpWebRequest: HttpRequestMessage; RequestBody: Text)
    var
        Content: HttpContent;
        Headers: HttpHeaders;
        HeadersReq: HttpHeaders;
    begin
        HttpWebRequest.GetHeaders(HeadersReq);
        Content.GetHeaders(Headers);
        Content.WriteFrom(RequestBody);

        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
        HeadersReq.Add('Authorization', CreateBasicAuth(Username, Password));

        HttpWebRequest.Content(Content);
        HttpWebRequest.SetRequestUri(Url);
        HttpWebRequest.Method := 'POST';
    end;

    local procedure InitPatchWebRequest(Url: Text; Username: Text; Password: Text; var HttpWebRequest: HttpRequestMessage; RequestBody: Text)
    var
        Content: HttpContent;
        Headers: HttpHeaders;
        HeadersReq: HttpHeaders;
    begin
        HttpWebRequest.GetHeaders(HeadersReq);
        Content.GetHeaders(Headers);
        Content.WriteFrom(RequestBody);

        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
        HeadersReq.Add('Authorization', CreateBasicAuth(Username, Password));

        HttpWebRequest.Content(Content);
        HttpWebRequest.SetRequestUri(Url);
        HttpWebRequest.Method := 'PATCH';
    end;

    local procedure SendWebRequest(HttpWebRequest: HttpRequestMessage; var Response: Record "NPR PG Payment Response"): Text
    var
        Client: HttpClient;
        HttpWebResponse: HttpResponseMessage;
        ResponseTxt: Text;
    begin
        Client.Timeout(300000);
        Client.Send(HttpWebRequest, HttpWebResponse);

        HttpWebResponse.Content.ReadAs(ResponseTxt);
        Response.AddResponse(ResponseTxt);

        if not HttpWebResponse.IsSuccessStatusCode then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, ResponseTxt);
        exit(ResponseTxt);
    end;

    local procedure CreateBasicAuth(ApiUsername: Text; ApiPassword: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit('Basic ' + Base64Convert.ToBase64(ApiUsername + ':' + ApiPassword, TextEncoding::UTF8));
    end;

    local procedure ConvertToAdyenPayAmount(Amount: Decimal) AdyenAmount: Text
    begin
        AdyenAmount := DelChr(Format(Amount * 100, 0, 9), '=', '.');
        exit(AdyenAmount);
    end;

    procedure ConvertFromAdyenPayAmount(AdyenAmount: Text): Decimal
    var
        NormalAmount: Decimal;
    begin
        Evaluate(NormalAmount, AdyenAmount);
        NormalAmount := NormalAmount / 100;
        exit(NormalAmount);
    end;

    local procedure DocumentToRequest(var Request: Record "NPR PG Payment Request"; RecVariant: Variant; Amount: Decimal; PaymentGatewayCode: Code[10])
    var
        DocumentSystemId: Guid;
        TransactionID: Code[20];
        RecRef: RecordRef;
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        UnsupportedErr: Label 'Unsupported document type';
        DocumentTableNo: Integer;
    begin
        Request.Init();
        RecRef.GetTable(RecVariant);

        case RecRef.Number of
            Database::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);
                    TransactionID := SalesHeader."No.";
                    DocumentSystemId := SalesHeader.SystemId;
                    DocumentTableNo := DATABASE::"Sales Header";
                end;
            Database::"Sales Invoice Header":
                begin
                    RecRef.SetTable(SalesInvoiceHeader);
                    TransactionID := SalesInvoiceHeader."No.";
                    DocumentSystemId := SalesInvoiceHeader.SystemId;
                    DocumentTableNo := DATABASE::"Sales Invoice Header";
                end;
            else
                Error(UnsupportedErr);
        end;

        Request."Transaction ID" := TransactionID;
        Request."Request Amount" := Amount;
        Request."Payment Gateway Code" := PaymentGatewayCode;
        Request."Document Table No." := DocumentTableNo;
        Request."Document System Id" := DocumentSystemId;
        Request.Insert(true);
    end;

    local procedure SendEmailNotification(Email: Text[80]; EmailTempate: Code[20]; MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        RecRef: RecordRef;
        EmailManagement: Codeunit "NPR E-mail Management";
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        MailErrorMsg: Text;
        EmailSentLbl: Label 'E-mail has been successfully sent.';
    begin
        RecRef.GetTable(MagentoPaymentLine);
        RecRef.SetRecFilter();

        EmailTemplateHeader.Get(EmailTempate);
        EmailTemplateHeader.SetRecFilter();
        if EmailTemplateHeader."Report ID" > 0 then
            MailErrorMsg := EmailManagement.SendReportTemplate(EmailTemplateHeader."Report ID", RecRef, EmailTemplateHeader, Email, true)
        else
            MailErrorMsg := EmailManagement.SendEmailTemplate(RecRef, EmailTemplateHeader, Email, true);

        if MailErrorMsg = '' then
            Message(EmailSentLbl)
        else
            Error(MailErrorMsg);
    end;

    local procedure GetPayByLinkSetup()
    var
        SetupErr: Label 'Pay by Link Setup does not exist';
    begin
        if PayByLinkSetupGotten then
            exit;

        if not PayByLinkSetup.Get() then
            Error(SetupErr);

        PayByLinkSetupGotten := true;
    end;

    local procedure CreateMagentoPaymentLine(var Request: Record "NPR PG Payment Request"; var MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        LineNo: Integer;
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        GetPayByLinkSetup();

        case
            Request."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    SalesHeader.GetBySystemId(Request."Document System Id");
                    MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
                    MagentoPaymentLine.SetRange("Document Type", SalesHeader."Document Type");
                    MagentoPaymentLine.SetRange("Document No.", SalesHeader."No.");
                    if MagentoPaymentLine.FindLast() then;
                    LineNo := MagentoPaymentLine."Line No." + 10000;
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    SalesInvoiceHeader.GetBySystemId(Request."Document System Id");
                    MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
                    MagentoPaymentLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                    if MagentoPaymentLine.FindLast() then;
                    LineNo := MagentoPaymentLine."Line No." + 10000;
                end;
        end;

        MagentoPaymentLine.Init();
        MagentoPaymentLine."Document Table No." := Request."Document Table No.";
        MagentoPaymentLine."Line No." := LineNo;
        MagentoPaymentLine."Requested Amount" := Request."Request Amount";
        MagentoPaymentLine."Account Type" := PayByLinkSetup."Account Type";
        MagentoPaymentLine."Account No." := PayByLinkSetup."Account No.";
        MagentoPaymentLine."Payment Gateway Code" := PayByLinkSetup."Payment Gateaway Code";
        MagentoPaymentLine."Payment Type" := MagentoPaymentLine."Payment Type"::"Payment Method";

        case Request."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    MagentoPaymentLine."Document Type" := SalesHeader."Document Type";
                    MagentoPaymentLine."Document No." := SalesHeader."No.";

                    MagentoPaymentLine."Posting Date" := SalesHeader."Posting Date";
                    MagentoPaymentLine."External Reference No." := SalesHeader."NPR External Order No.";
                    MagentoPaymentLine.Insert(true);
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    MagentoPaymentLine."Document No." := SalesInvoiceHeader."No.";
                    MagentoPaymentLine."Posting Date" := SalesInvoiceHeader."Posting Date";
                    MagentoPaymentLine."External Reference No." := SalesInvoiceHeader."NPR External Order No.";
                    MagentoPaymentLine.Insert(true);
                end;
        end;
    end;

    local procedure UpdatePaymentMagentoLine(var MagentoPaymentLine: Record "NPR Magento Payment Line"; var Response: Record "NPR PG Payment Response" temporary; Cancelation: Boolean)
    var
        JsonO: JsonObject;
        JsonT: JsonToken;
        PaymentID: text;
        PayByLinkURL: text;
        ResponseTxt: text;
        InStr: InStream;
        ExipresAtISO8601: Text;
        ExpiresAt: DateTime;
    begin
        Response."Response Body".CreateInStream(InStr);
        InStr.ReadText(ResponseTxt);
        JsonO.ReadFrom(ResponseTxt);

        JsonO.get('expiresAt', JsonT);
        ExipresAtISO8601 := JsonT.AsValue().AsText();

        if Cancelation then
            MagentoPaymentLine."Manually Canceled Link" := true
        else begin
            JsonO.Get('url', JsonT);
            PayByLinkURL := JsonT.AsValue().AsText();
            JsonO.Get('id', JsonT);
            PaymentID := JsonT.AsValue().AsText();

            MagentoPaymentLine."Pay by Link URL" := CopyStr(PayByLinkURL, 1, MaxStrLen(MagentoPaymentLine."Pay by Link URL"));
            MagentoPaymentLine."Payment ID" := CopyStr(PaymentID, 1, MaxStrLen(MagentoPaymentLine."Payment ID"));
        end;
        if Evaluate(ExpiresAt, ExipresAtISO8601, 9) then
            MagentoPaymentLine."Expires At" := ExpiresAt;
        MagentoPaymentLine.Modify();
    end;

    local procedure CheckIfCanBeCanceled(var MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        AlreadyCancelledErr: Label 'Payment ID %1 has been already canceled.';
        ExpiredErr: Label 'It is not possible to Cancel Link %1 because it has been expired at %2.';
        PostedErr: Label 'It is not possible to Cancel Link %1 because it has been posted.';
        AuthorisedErr: Label 'It is not possible to Cancel Link %1 because it has been authorised. If you want to Cancel the payment, use Cancel Payment action ';
    begin
        if MagentoPaymentLine."Manually Canceled Link" then
            Error(AlreadyCancelledErr, MagentoPaymentLine."Payment ID");

        if MagentoPaymentLine."Expires At" < CurrentDateTime() then
            Error(ExpiredErr, MagentoPaymentLine."Pay by Link URL", MagentoPaymentLine."Expires At");

        if MagentoPaymentLine.Posted then
            Error(PostedErr, MagentoPaymentLine."Pay by Link URL");

        if MagentoPaymentLine."Date Authorized" <> 0D then
            Error(AuthorisedErr, MagentoPaymentLine."Pay by Link URL");
    end;

    local procedure CreateCancelLinkRequest(MagentoPaymentLine: Record "NPR Magento Payment Line"; var HttpWebRequest: HttpRequestMessage; var Request: Record "NPR PG Payment Request")
    var
        Url: Text;
        JRequestBody: JsonObject;
        RequestTxt: Text;
        AdyenPGSetup: Record "NPR PG Adyen Setup";
    begin
        GetPayByLinkSetup();

        if not AdyenPGSetup.Get(PayByLinkSetup."Payment Gateaway Code") then
            exit;

        Url := AdyenPGSetup.GetAPIPayByLinkUrl() + '/' + MagentoPaymentLine."Payment ID";

        JRequestBody.Add('status', 'expired');

        JRequestBody.WriteTo(RequestTxt);
        InitPatchWebRequest(Url, AdyenPGSetup."API Username", AdyenPGSetup.GetApiPassword(), HttpWebRequest, RequestTxt);

        Request.AddBody(JRequestBody);
    end;

    local procedure SendCancelLinkRequest(HttpWebRequest: HttpRequestMessage; var Response: Record "NPR PG Payment Response")
    var
        ResponseJson: Text;
        JsonO: JsonObject;
    begin
        ResponseJson := SendWebRequest(HttpWebRequest, Response);
        if not JsonO.ReadFrom(ResponseJson) then
            Error(ResponseJson);

        Response.AddResponse(ResponseJson);
        Response."Response Success" := true;
    end;

    local procedure CalculateCapturedAmount(DocumentTableNo: Integer; DocumentNo: Code[20]; SalesDocumentType: Enum "Sales Document Type"; MagentoPaymentLine: Record "NPR Magento Payment Line"; var PaidAmount: Decimal)
    var
        MagentoPaymentLineTransactionID: Record "NPR Magento Payment Line";
    begin
        MagentoPaymentLineTransactionID.Reset();
        MagentoPaymentLineTransactionID.SetRange("Document No.", DocumentNo);
        MagentoPaymentLineTransactionID.SetRange("Document Type", SalesDocumentType);
        MagentoPaymentLineTransactionID.SetRange("Document Table No.", DocumentTableNo);
        MagentoPaymentLineTransactionID.SetLoadFields("Document No.", "Document Type", "Document Table No.", "Transaction ID");
        MagentoPaymentLineTransactionID.SetCurrentKey("Transaction ID");
        MagentoPaymentLineTransactionID.SetFilter("Transaction ID", '<>%1', '');
        if MagentoPaymentLineTransactionID.FindSet() then
            repeat
                MagentoPaymentLineTransactionID.SetRange("Transaction ID", MagentoPaymentLineTransactionID."Transaction ID");
                MagentoPaymentLineTransactionID.FindLast();
                MagentoPaymentLineTransactionID.SetRange("Transaction ID");

                MagentoPaymentLine.Reset();
                MagentoPaymentLine.SetRange("Transaction ID", MagentoPaymentLineTransactionID."Transaction ID");
                MagentoPaymentLine.SetLoadFields("Transaction ID", "Document No.", "Document Table No.", "Document Type", Amount);
                if MagentoPaymentLine.FindSet() then
                    repeat
                        case MagentoPaymentLine."Document Table No." of
                            DATABASE::"Sales Header":
                                begin
                                    if MagentoPaymentLine."Document Type" in [MagentoPaymentLine."Document Type"::Order, MagentoPaymentLine."Document Type"::Invoice] then
                                        PaidAmount += MagentoPaymentLine.Amount;
                                end;
                            DATABASE::"Sales Invoice Header":
                                PaidAmount += MagentoPaymentLine.Amount;

                        end;
                    until MagentoPaymentLine.Next() = 0;
            until MagentoPaymentLineTransactionID.Next() = 0;
    end;

    local procedure CalculateRequestedAmount(DocumentTableNo: Integer; DocumentNo: Code[20]; SalesDocumentType: Enum "Sales Document Type"; MagentoPaymentLine: Record "NPR Magento Payment Line"; var PaidAmount: Decimal)
    begin
        Clear(MagentoPaymentLine);
        MagentoPaymentLine.Reset();
        MagentoPaymentLine.SetRange("Document No.", DocumentNo);
        MagentoPaymentLine.SetRange("Document Type", SalesDocumentType);
        MagentoPaymentLine.SetRange("Document Table No.", DocumentTableNo);
        MagentoPaymentLine.SetRange("Last Amount", 0);
        MagentoPaymentLine.SetRange(Amount, 0);
        MagentoPaymentLine.SetRange("Date Canceled", 0D);
        MagentoPaymentLine.SetRange("Manually Canceled Link", false);
        MagentoPaymentLine.SetFilter("Expires At", '>%1', CurrentDateTime());
        MagentoPaymentLine.SetLoadFields("Requested Amount");

        MagentoPaymentLine.CalcSums("Requested Amount");
        PaidAmount += MagentoPaymentLine."Requested Amount";
    end;

    internal procedure CheckUnproccesedWebhook(var PaymentLine: Record "NPR Magento Payment Line")
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenPayByLinkStatus: Codeunit "NPR Adyen PayByLink Status";
    begin
        AdyenWebhook.SetRange("PSP Reference", PaymentLine."Payment ID");
        AdyenWebhook.SetRange(Status, AdyenWebhook.Status::New);
        if not AdyenWebhook.FindLast() then
            exit;

        AdyenPayByLinkStatus.Run(AdyenWebhook);
        Commit();

        PaymentLine.GetBySystemId(PaymentLine.SystemId);
    end;

    procedure CancelPayByLink(var PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit;

        if not (PaymentGateway."Integration Type" = PaymentGateway."Integration Type"::Adyen) then
            exit;

        if not PayByLinkSetup.Get() then
            exit;

        if not PayByLinkSetup."Enable Pay by Link" then
            exit;

        if PaymentLine."Date Authorized" <> 0D then
            exit;

        if PaymentLine.Amount = 0 then
            if PaymentLine."Expires At" > CurrentDateTime then
                CancelAdyenPayByLink(PaymentLine);
    end;

    procedure ResetErrorPostingStatus(var PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine."Posting Error" := false;
        PaymentLine."Skip Posting" := false;
        PaymentLine."Try Posting Count" := 0;
        PaymentLine.Modify();
    end;

    procedure SetSkipPosting(var PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine."Skip Posting" := true;
        PaymentLine.Modify();
    end;

    procedure IsAdyenPaymentLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PGAdyen: Record "NPR PG Adyen Setup";
        PG: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit(false);
        if not PG.Get(PaymentLine."Payment Gateway Code") then
            exit(false);
        if not PGAdyen.Get(PaymentLine."Payment Gateway Code") then
            exit(false);

        exit(PG."Integration Type" = PG."Integration Type"::Adyen);
    end;

    procedure IsAdyenPayByLinkLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PGAdyen: Record "NPR PG Adyen Setup";
        PG: Record "NPR Magento Payment Gateway";
        PayByLink: Record "NPR Pay By Link Setup";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit(false);
        if not PG.Get(PaymentLine."Payment Gateway Code") then
            exit(false);
        if not PGAdyen.Get(PaymentLine."Payment Gateway Code") then
            exit(false);
        if PG."Integration Type" <> PG."Integration Type"::Adyen then
            exit(false);
        if not PayByLink.Get() then
            exit(false);
        if not PayByLink."Enable Pay by Link" then
            exit(false);

        exit(true);
    end;
    #endregion

    #region Interface implementation
    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        CaptureInternal(Request, Response);
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        RefundInternal(Request, Response);
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response");
    begin
        CancelInternal(Request, Response);
    end;

    procedure RunSetupCard(PaymentGatewayCode: Code[10]);
    var
        PGAdyenSetup: Record "NPR PG Adyen Setup";
    begin
        if (not PGAdyenSetup.Get(PaymentGatewayCode)) then begin
            PGAdyenSetup.Init();
            PGAdyenSetup.Code := PaymentGatewayCode;
            PGAdyenSetup.Insert(true);
            Commit();
        end;

        PGAdyenSetup.SetRecFilter();
        Page.Run(Page::"NPR PG Adyen Setup Card", PGAdyenSetup);
    end;


    #endregion
}
