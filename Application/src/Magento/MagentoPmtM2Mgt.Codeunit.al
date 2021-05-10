codeunit 6151423 "NPR Magento Pmt. M2 Mgt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'CapturePaymentEvent', '', true, true)]
    local procedure OnCapturePayment(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsM2PaymentLine(PaymentLine) then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Invoice Header"]) then
            exit;

        Capture(PaymentLine);

        PaymentLine."Date Captured" := Today();
        PaymentLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'CancelPaymentEvent', '', true, true)]
    local procedure OnCancelPayment(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsM2PaymentLine(PaymentLine) then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Invoice Header"]) then
            exit;

        Cancel(PaymentLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'RefundPaymentEvent', '', true, true)]
    local procedure OnRefundPayment(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        if not IsM2RefundLine(PaymentLine) then
            exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Cr.Memo Header"]) then
            exit;

        Refund(PaymentLine);

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

    #region Payment Integration

    local procedure Capture(PaymentLine: Record "NPR Magento Payment Line")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        JToken: JsonToken;
        HttpWebRequest: HttpRequestMessage;
        Url: Text;
        Request: Text;
        OrderId: Text;
        Response: Text;
        ResponseJson: Text;
        ItemArray: Text;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        PaymentGateway.TestField("Api Url");
        Url := PaymentGateway."Api Url" + '/invoice';

        case PaymentLine."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    SalesHeader.Get(PaymentLine."Document Type", PaymentLine."Document No.");
                    OrderId := SalesHeader."NPR External Order No.";

                    SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
                    if SalesLine.FindSet() then begin
                        ItemArray :=
                          '{' +
                            '"order_item_sku": "' + ItemNo2Sku(SalesLine."No.", SalesLine."Variant Code") + '",' +
                            '"qty": ' + Format(SalesLine."Outstanding Quantity", 0, 9) +
                          '}';

                        while SalesLine.Next() <> 0 do begin
                            ItemArray +=
                              ',{' +
                                '"order_item_sku": "' + ItemNo2Sku(SalesLine."No.", SalesLine."Variant Code") + '",' +
                                '"qty": ' + Format(SalesLine."Outstanding Quantity", 0, 9) +
                              '}';
                        end;
                    end;
                end;
            DATABASE::"Sales Invoice Header":
                begin
                    SalesInvHeader.Get(PaymentLine."Document No.");
                    OrderId := SalesInvHeader."NPR External Order No.";

                    SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
                    SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
                    SalesInvLine.SetFilter(Quantity, '>%1', 0);
                    if SalesInvLine.FindSet() then begin
                        ItemArray :=
                          '{' +
                            '"order_item_sku": "' + ItemNo2Sku(SalesInvLine."No.", SalesInvLine."Variant Code") + '",' +
                            '"qty": ' + Format(SalesInvLine.Quantity, 0, 9) +
                          '}';

                        while SalesInvLine.Next() <> 0 do begin
                            ItemArray +=
                              ',{' +
                                '"order_item_sku": "' + ItemNo2Sku(SalesInvLine."No.", SalesInvLine."Variant Code") + '",' +
                                '"qty": ' + Format(SalesInvLine.Quantity, 0, 9) +
                              '}';
                        end;
                    end;
                end;
        end;

        Request :=
          '{' +
            '"invoice": {' +
              '"externalId": "' + PaymentLine."Document No." + '",' +
              '"orderId": "' + OrderId + '",' +
              '"capture": true,' +
              '"items": [' +
                ItemArray +
              '],' +
              '"notify": false,' +
              '"appendComment": false' +
            '}' +
          '}';

        InitWebRequest(Url, PaymentGateway.GetApiPassword(), HttpWebRequest, Request);

        ResponseJson := SendWebRequest(HttpWebRequest);
        if not JToken.ReadFrom(ResponseJson) then
            Error(ResponseJson);

        Response := GetJsonText(JToken, 'messages.success', 0);
        if Response <> '' then
            exit;

        Error('%1', JToken);
    end;

    local procedure Cancel(PaymentLine: Record "NPR Magento Payment Line")
    var
        MagentoOrderStatus: Record "NPR Magento Order Status";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        JToken: JsonToken;
        HttpWebRequest: HttpRequestMessage;
        Url: Text;
        Request: Text;
        Response: Text;
        ResponseJson: Text;
    begin
        if PaymentLine."Document Table No." <> DATABASE::"Sales Header" then
            exit;

        if not MagentoOrderStatus.Get(PaymentLine."Document No.") then
            exit;
        if MagentoOrderStatus."External Order No." = '' then
            exit;

        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        PaymentGateway.TestField("Api Url");
        Url := PaymentGateway."Api Url" + '/cancelorder';

        Request :=
          '{' +
            '"cancel": {' +
              '"orderId": "' + MagentoOrderStatus."External Order No." + '"' +
            '}' +
          '}';

        InitWebRequest(Url, PaymentGateway.GetApiPassword(), HttpWebRequest, Request);

        ResponseJson := SendWebRequest(HttpWebRequest);
        if not JToken.ReadFrom(ResponseJson) then
            Error(ResponseJson);

        Response := GetJsonText(JToken, 'messages.success', 0);
        if Response <> '' then
            exit;

        Error('%1', JToken);
    end;

    local procedure Refund(PaymentLine: Record "NPR Magento Payment Line")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        JToken: JsonToken;
        HttpWebRequest: HttpRequestMessage;
        Url: Text;
        Request: Text;
        OrderId: Text;
        Response: Text;
        ResponseJson: Text;
        ItemArray: Text;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        PaymentGateway.TestField("Api Url");
        Url := PaymentGateway."Api Url" + '/refundorder';

        case PaymentLine."Document Table No." of
            DATABASE::"Sales Header":
                begin
                    SalesHeader.Get(PaymentLine."Document Type", PaymentLine."Document No.");
                    OrderId := SalesHeader."NPR External Order No.";

                    SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                    SalesLine.SetRange("Document No.", SalesHeader."No.");
                    SalesLine.SetRange(Type, SalesLine.Type::Item);
                    SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
                    if SalesLine.FindSet() then begin
                        ItemArray :=
                          '{' +
                            '"order_item_sku": "' + ItemNo2Sku(SalesLine."No.", SalesLine."Variant Code") + '",' +
                            '"qty": ' + Format(SalesLine."Outstanding Quantity", 0, 9) +
                          '}';

                        while SalesLine.Next() <> 0 do begin
                            ItemArray +=
                              ',{' +
                                '"order_item_sku": "' + ItemNo2Sku(SalesLine."No.", SalesLine."Variant Code") + '",' +
                                '"qty": ' + Format(SalesLine."Outstanding Quantity", 0, 9) +
                              '}';
                        end;
                    end;
                end;
            DATABASE::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader.Get(PaymentLine."Document No.");
                    OrderId := SalesCrMemoHeader."NPR External Order No.";

                    SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
                    SalesCrMemoLine.SetFilter(Quantity, '>%1', 0);
                    if SalesCrMemoLine.FindSet() then begin
                        ItemArray :=
                          '{' +
                            '"order_item_sku": "' + ItemNo2Sku(SalesCrMemoLine."No.", SalesCrMemoLine."Variant Code") + '",' +
                            '"qty": ' + Format(SalesCrMemoLine.Quantity, 0, 9) +
                          '}';

                        while SalesCrMemoLine.Next() <> 0 do begin
                            ItemArray +=
                              ',{' +
                                '"order_item_sku": "' + ItemNo2Sku(SalesCrMemoLine."No.", SalesCrMemoLine."Variant Code") + '",' +
                                '"qty": ' + Format(SalesCrMemoLine.Quantity, 0, 9) +
                              '}';
                        end;
                    end;
                end;
        end;

        Request :=
          '{' +
            '"refund": {' +
              '"orderId": "' + OrderId + '",' +
              '"items": [' +
                ItemArray +
              '],' +
              '"isOnline": true,' +
              '"notify": false,' +
              '"appendComment": false,' +
              '"arguments": {' +
              '  "shipping_amount": 0,' +
              '  "adjustment_positive": 0,' +
              '  "adjustment_negative": 0' +
              '}' +
            '}' +
          '}';

        InitWebRequest(Url, PaymentGateway.GetApiPassword(), HttpWebRequest, Request);

        ResponseJson := SendWebRequest(HttpWebRequest);
        if not JToken.ReadFrom(ResponseJson) then
            Error(ResponseJson);

        Response := GetJsonText(JToken, 'messages.success', 0);
        if Response <> '' then
            exit;

        Error('%1', JToken);
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
            MagentoPaymentGateway."Api Url" := CopyStr(MagentoSetup."Api Url" + 'paymentprocessor', 1, MaxStrLen(MagentoPaymentGateway."Api Url"));
        if MagentoPaymentGateway.GetApiPassword() = '' then
            MagentoPaymentGateway.SetApiPassword(MagentoSetup."Api Authorization");
    end;

    local procedure InitWebRequest(Url: Text; Authorization: Text; var HttpWebRequest: HttpRequestMessage; RequestBody: Text)
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

        Headers.Add('Content-Type', 'naviconnect/json');
        Headers.Add('Accept', 'application/json');
        HeadersReq.Add('Authorization', 'bearer ' + Authorization);

        HttpWebRequest.Content(Content);
        HttpWebRequest.SetRequestUri(Url);
        HttpWebRequest.Method := 'POST';
    end;

    local procedure SendWebRequest(HttpWebRequest: HttpRequestMessage): Text
    var
        Client: HttpClient;
        HttpWebResponse: HttpResponseMessage;
        Response: Text;
    begin
        Client.Timeout(300000);
        Client.Send(HttpWebRequest, HttpWebResponse);

        HttpWebResponse.Content.ReadAs(Response);

        if not HttpWebResponse.IsSuccessStatusCode then
            Error(StrSubstNo('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response));
        exit(Response);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Magento Pmt. M2 Mgt.");
    end;

    procedure IsM2PaymentLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit(false);

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit(false);

        exit(PaymentGateway."Capture Codeunit Id" = CurrCodeunitId());
    end;

    procedure IsM2RefundLine(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit(false);

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit(false);

        exit(PaymentGateway."Refund Codeunit Id" = CurrCodeunitId());
    end;

    local procedure GetJsonText(JToken: JsonToken; JPath: Text; MaxLen: Integer) Value: Text
    var
        JToken2: JsonToken;
    begin
        if not JToken.SelectToken('$..' + JPath, JToken2) then
            exit('');

        Value := Format(JToken2);
        if MaxLen > 0 then
            Value := CopyStr(Value, 1, MaxLen);
        exit(Value);
    end;

    local procedure ItemNo2Sku(ItemNo: Text; VariantCode: Code[10]) Sku: Text
    begin
        Sku := ItemNo;
        if VariantCode <> '' then
            Sku += '_' + VariantCode;

        exit(Sku);
    end;

    #endregion
}