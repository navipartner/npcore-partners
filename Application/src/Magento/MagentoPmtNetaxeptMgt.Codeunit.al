codeunit 6151424 "NPR Magento Pmt. Netaxept Mgt."
{


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'CancelPaymentEvent', '', false, false)]
    local procedure CancelPaymentSalesOrder(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsNetAxeptPaymentLine(PaymentLine) then
            exit;
        if PaymentLine."Document Table No." <> DATABASE::"Sales Header" then
            exit;
        if PaymentLine."Document Type" <> PaymentLine."Document Type"::Order then
            exit;
        if PostedDocumentExists(PaymentLine) then
            exit;

        if not Cancel(PaymentLine) then
            Message(GetLastErrorText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'CapturePaymentEvent', '', false, false)]
    local procedure CapturePaymentSalesInvoice(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsNetAxeptPaymentLine(PaymentLine) then
            exit;
        if PaymentLine."Document Table No." <> DATABASE::"Sales Invoice Header" then
            exit;
        if not DocumentExists(PaymentLine) then
            exit;

        if not Capture(PaymentLine) then begin
            Message(GetLastErrorText);
            exit;
        end;

        PaymentLine."Date Captured" := Today();
        PaymentLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'RefundPaymentEvent', '', false, false)]
    local procedure RefundPaymentSalesReturn(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsNetAxeptPaymentLine(PaymentLine) then
            exit;
        if PaymentLine."Document Table No." <> DATABASE::"Sales Cr.Memo Header" then
            exit;
        if not DocumentExists(PaymentLine) then
            exit;

        if not Refund(PaymentLine) then begin
            Message(GetLastErrorText);
            exit;
        end;

        PaymentLine."Date Refunded" := Today();
        PaymentLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Gateway", 'OnAfterValidateEvent', 'Capture Codeunit Id', true, true)]
    local procedure OnValidateCaptureCodeunitId(var Rec: Record "NPR Magento Payment Gateway")
    begin
        if Rec."Capture Codeunit Id" <> CurrCodeunitId() then
            exit;

        SetApiInfo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Gateway", 'OnAfterValidateEvent', 'Refund Codeunit Id', true, true)]
    local procedure OnValidateRefundCodeunitId(var Rec: Record "NPR Magento Payment Gateway")
    begin
        if Rec."Refund Codeunit Id" <> CurrCodeunitId() then
            exit;

        SetApiInfo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Gateway", 'OnAfterValidateEvent', 'Cancel Codeunit Id', true, true)]
    local procedure OnValidateCancelCodeunitId(var Rec: Record "NPR Magento Payment Gateway")
    begin
        if Rec."Cancel Codeunit Id" <> CurrCodeunitId() then
            exit;

        SetApiInfo(Rec);
    end;

    #region Api

    [TryFunction]
    local procedure Cancel(PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        HttpClientVar: HttpClient;
        HttpWebResponse: HttpResponseMessage;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");

        HttpClientVar.Timeout := 5000;
        if not HttpClientVar.Get(GetApiUrl(PaymentGateway, PaymentLine, "ServiceName.Cancel"()), HttpWebResponse) then
            Error(CopyStr('NetAxept: ' + GetLastErrorText, 1, 1024));

        RequestProcessing(HttpWebResponse);
    end;

    [TryFunction]
    local procedure Capture(PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        HttpClientVar: HttpClient;
        HttpWebResponse: HttpResponseMessage;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");

        HttpClientVar.Timeout := 5000;
        if not HttpClientVar.Get(GetApiUrl(PaymentGateway, PaymentLine, "ServiceName.Capture"()), HttpWebResponse) then
            Error(CopyStr('NetAxept: ' + GetLastErrorText, 1, 1024));

        RequestProcessing(HttpWebResponse);
    end;

    [TryFunction]
    local procedure Refund(PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        HttpClientVar: HttpClient;
        HttpWebResponse: HttpResponseMessage;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");

        HttpClientVar.Timeout := 5000;
        if not HttpClientVar.Get(GetApiUrl(PaymentGateway, PaymentLine, "ServiceName.Refund"()), HttpWebResponse) then
            Error(CopyStr('NetAxept: ' + GetLastErrorText, 1, 1024));

        RequestProcessing(HttpWebResponse);
    end;

    local procedure RequestProcessing(HttpWebResponse: HttpResponseMessage)
    var
        XmlDomMng: Codeunit "XML DOM Management";
        XmlDoc: XmlDocument;
        Response: Text;
    begin
        Clear(XmlDoc);
        HttpWebResponse.Content.ReadAs(Response);
        if not XmlDocument.ReadFrom(XmlDomMng.RemoveNamespaces(Response), XmlDoc) then
            Error(CopyStr('NetAxept: ' + Response, 1, 1024));

        Message(Response);

        if not HttpWebResponse.IsSuccessStatusCode then
            Error(StrSubstNo('NetAxept: %1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response));
    end;

    #endregion

    #region Aux

    local procedure SetApiInfo(var MagentoPaymentGateway: Record "NPR Magento Payment Gateway")
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not MagentoSetup.Get() then
            exit;

        if MagentoPaymentGateway."Api Url" = '' then
            MagentoPaymentGateway."Api Url" := 'https://epayment.bbs.no/REST/';
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Magento Pmt. Netaxept Mgt.");
    end;

    local procedure DocumentExists(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        case PaymentLine."Document Table No." of
            DATABASE::"Sales Invoice Header":
                begin
                    exit(SalesInvoiceHeader.Get(PaymentLine."Document No."));
                end;
            DATABASE::"Sales Header":
                begin
                    exit(SalesHeader.Get(PaymentLine."Document Type", PaymentLine."Document No."));
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    exit(SalesCrMemoHeader.Get(PaymentLine."Document No."));
                end;
        end;

        exit(false);
    end;

    local procedure GetApiUrl(PaymentGateway: Record "NPR Magento Payment Gateway"; PaymentLine: Record "NPR Magento Payment Line"; Method: Text): Text
    begin
        exit(PaymentGateway."Api Url" +
             Method + '.aspx' +
             '?merchantId=' + PaymentGateway."Merchant ID" +
             '&token=' + PaymentGateway.GetApiPassword() +
             '&transactionId=' + LowerCase(PaymentLine."No.") +
             '&transactionreconref=' + '' +
             '&transactionamount=' + DelChr(Format(PaymentLine.Amount, 0, '<SIGN><INTEGER><DECIMALS,3>'), '=', '.,'));
    end;

    procedure IsNetAxeptPaymentLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit;

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit(false);

        exit(PaymentGateway."Capture Codeunit Id" = CurrCodeunitId());
    end;

    local procedure PostedDocumentExists(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PaymentLine2: Record "NPR Magento Payment Line";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        case PaymentLine."Document Table No." of
            DATABASE::"Sales Invoice Header":
                begin
                    exit(SalesInvHeader.Get(PaymentLine."Document No."));
                end;
            DATABASE::"Sales Header":
                begin
                    if PaymentLine."Document Type" <> PaymentLine."Document Type"::Order then
                        exit(false);
                    SalesInvHeader.SetRange("Order No.", PaymentLine."Document No.");
                    if not SalesInvHeader.FindFirst() then
                        exit(false);
                    exit(PaymentLine2.Get(DATABASE::"Sales Invoice Header", 0, SalesInvHeader."No.", PaymentLine."Line No."));
                end;
        end;

        exit(false);
    end;

    #endregion

    local procedure "ServiceName.Cancel"(): Text
    begin
        exit('annul');
    end;

    local procedure "ServiceName.Capture"(): Text
    begin
        exit('capture');
    end;

    local procedure "ServiceName.Refund"(): Text
    begin
        exit('credit');
    end;
}