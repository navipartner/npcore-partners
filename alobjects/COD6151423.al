codeunit 6151423 "Magento Pmt. M2 Mgt."
{
    // MAG2.23/MHA /20190813  CASE 355841 Object created for Magento 2 Payment Capture/Cancel/Refund


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Quickpay error:\%1';

    local procedure "--- Subscriber"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'CapturePaymentEvent', '', true, true)]
    local procedure OnCapturePayment(PaymentGateway: Record "Magento Payment Gateway";var PaymentLine: Record "Magento Payment Line")
    begin
        if not IsM2PaymentLine(PaymentLine) then
          exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header",DATABASE::"Sales Invoice Header"]) then
          exit;

        Capture(PaymentLine);

        PaymentLine."Date Captured" := Today;
        PaymentLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'CancelPaymentEvent', '', true, true)]
    local procedure OnCancelPayment(PaymentGateway: Record "Magento Payment Gateway";var PaymentLine: Record "Magento Payment Line")
    begin
        if not IsM2PaymentLine(PaymentLine) then
          exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header",DATABASE::"Sales Invoice Header"]) then
          exit;

        Cancel(PaymentLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'RefundPaymentEvent', '', true, true)]
    local procedure OnRefundPayment(PaymentGateway: Record "Magento Payment Gateway";var PaymentLine: Record "Magento Payment Line")
    begin
        if not IsM2RefundLine(PaymentLine) then
          exit;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header",DATABASE::"Sales Cr.Memo Header"]) then
          exit;

        Refund(PaymentLine);

        PaymentLine."Date Refunded" := Today;
        PaymentLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, 6151413, 'OnAfterValidateEvent', 'Capture Codeunit Id', true, true)]
    local procedure OnValidateCaptureCodeunitId(var Rec: Record "Magento Payment Gateway")
    begin
        if Rec."Capture Codeunit Id" <> CurrCodeunitId then
          exit;

        SetApiInfo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151413, 'OnAfterValidateEvent', 'Refund Codeunit Id', true, true)]
    local procedure OnValidateRefundCodeunitId(var Rec: Record "Magento Payment Gateway")
    begin
        if Rec."Refund Codeunit Id" <> CurrCodeunitId then
          exit;

        SetApiInfo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151413, 'OnAfterValidateEvent', 'Cancel Codeunit Id', true, true)]
    local procedure OnValidateCancelCodeunitId(var Rec: Record "Magento Payment Gateway")
    begin
        if Rec."Cancel Codeunit Id" <> CurrCodeunitId then
          exit;

        SetApiInfo(Rec);
    end;

    procedure "--- Payment Integration"()
    begin
    end;

    local procedure Capture(PaymentLine: Record "Magento Payment Line")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        PaymentGateway: Record "Magento Payment Gateway";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        JToken: DotNet npNetJToken;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        Url: Text;
        Request: Text;
        OrderId: Text;
        ErrorMessage: Text;
        Response: Text;
        ResponseJson: Text;
        ItemArray: Text;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        PaymentGateway.TestField("Api Url");
        Url := PaymentGateway."Api Url" + '/invoice';
        InitWebRequest(Url,PaymentGateway."Api Password",HttpWebRequest);

        case PaymentLine."Document Table No." of
          DATABASE::"Sales Header":
            begin
              SalesHeader.Get(PaymentLine."Document Type",PaymentLine."Document No.");
              OrderId := SalesHeader."External Order No.";

              SalesLine.SetRange("Document Type",SalesHeader."Document Type");
              SalesLine.SetRange("Document No.",SalesHeader."No.");
              SalesLine.SetRange(Type,SalesLine.Type::Item);
              SalesLine.SetFilter("Outstanding Quantity",'>%1',0);
              if SalesLine.FindSet then begin
                ItemArray :=
                  '{' +
                    '"order_item_sku": "' + ItemNo2Sku(SalesLine."No.",SalesLine."Variant Code") + '",' +
                    '"qty": ' + Format(SalesLine."Outstanding Quantity",0,9) +
                  '}';

                while SalesLine.Next <> 0 do begin
                  ItemArray +=
                    ',{' +
                      '"order_item_sku": "' + ItemNo2Sku(SalesLine."No.",SalesLine."Variant Code") + '",' +
                      '"qty": ' + Format(SalesLine."Outstanding Quantity",0,9) +
                    '}';
                end;
              end;
            end;
          DATABASE::"Sales Invoice Header":
            begin
              SalesInvHeader.Get(PaymentLine."Document No.");
              OrderId := SalesInvHeader."External Order No.";

              SalesInvLine.SetRange("Document No.",SalesInvHeader."No.");
              SalesInvLine.SetRange(Type,SalesInvLine.Type::Item);
              SalesInvLine.SetFilter(Quantity,'>%1',0);
              if SalesInvLine.FindSet then begin
                ItemArray :=
                  '{' +
                    '"order_item_sku": "' + ItemNo2Sku(SalesInvLine."No.",SalesInvLine."Variant Code") + '",' +
                    '"qty": ' + Format(SalesInvLine.Quantity,0,9) +
                  '}';

                while SalesInvLine.Next <> 0 do begin
                  ItemArray +=
                    ',{' +
                      '"order_item_sku": "' + ItemNo2Sku(SalesInvLine."No.",SalesInvLine."Variant Code") + '",' +
                      '"qty": ' + Format(SalesInvLine.Quantity,0,9) +
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

        if not NpXmlDomMgt.SendWebRequestText(Request,HttpWebRequest,HttpWebResponse,WebException) then begin
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          if ParseJson(ErrorMessage,JToken) then begin
            Response := GetJsonText(JToken,'messages.error[0].message',0);
            if Response = '' then
              Response := GetJsonText(JToken,'message',0);

            if Response <> '' then
              Error(Response);
          end;
          Error(CopyStr(ErrorMessage,1,1020));
        end;

        ResponseJson := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not ParseJson(ResponseJson,JToken) then
          Error(ResponseJson);

        Response := GetJsonText(JToken,'messages.success',0);
        if Response <> '' then
          exit;

        Error('%1',JToken);
    end;

    local procedure Cancel(PaymentLine: Record "Magento Payment Line")
    var
        MagentoOrderStatus: Record "Magento Order Status";
        PaymentGateway: Record "Magento Payment Gateway";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        JToken: DotNet npNetJToken;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        Url: Text;
        Request: Text;
        ErrorMessage: Text;
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
        InitWebRequest(Url,PaymentGateway."Api Password",HttpWebRequest);

        Request :=
          '{' +
            '"cancel": {' +
              '"orderId": "' + MagentoOrderStatus."External Order No." + '"' +
            '}' +
          '}';

        if not NpXmlDomMgt.SendWebRequestText(Request,HttpWebRequest,HttpWebResponse,WebException) then begin
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          if ParseJson(ErrorMessage,JToken) then begin
            Response := GetJsonText(JToken,'messages.error[0].message',0);
            if Response = '' then
              Response := GetJsonText(JToken,'message',0);

            if Response <> '' then
              Error(Response);
          end;
          Error(CopyStr(ErrorMessage,1,1020));
        end;

        ResponseJson := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not ParseJson(ResponseJson,JToken) then
          Error(ResponseJson);

        Response := GetJsonText(JToken,'messages.success',0);
        if Response <> '' then
          exit;

        Error('%1',JToken);
    end;

    local procedure Refund(PaymentLine: Record "Magento Payment Line")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        PaymentGateway: Record "Magento Payment Gateway";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        JToken: DotNet npNetJToken;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        Url: Text;
        Request: Text;
        OrderId: Text;
        ErrorMessage: Text;
        Response: Text;
        ResponseJson: Text;
        ItemArray: Text;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        PaymentGateway.TestField("Api Url");
        Url := PaymentGateway."Api Url" + '/refundorder';
        InitWebRequest(Url,PaymentGateway."Api Password",HttpWebRequest);

        case PaymentLine."Document Table No." of
          DATABASE::"Sales Header":
            begin
              SalesHeader.Get(PaymentLine."Document Type",PaymentLine."Document No.");
              OrderId := SalesHeader."External Order No.";

              SalesLine.SetRange("Document Type",SalesHeader."Document Type");
              SalesLine.SetRange("Document No.",SalesHeader."No.");
              SalesLine.SetRange(Type,SalesLine.Type::Item);
              SalesLine.SetFilter("Outstanding Quantity",'>%1',0);
              if SalesLine.FindSet then begin
                ItemArray :=
                  '{' +
                    '"order_item_sku": "' + ItemNo2Sku(SalesLine."No.",SalesLine."Variant Code") + '",' +
                    '"qty": ' + Format(SalesLine."Outstanding Quantity",0,9) +
                  '}';

                while SalesLine.Next <> 0 do begin
                  ItemArray +=
                    ',{' +
                      '"order_item_sku": "' + ItemNo2Sku(SalesLine."No.",SalesLine."Variant Code") + '",' +
                      '"qty": ' + Format(SalesLine."Outstanding Quantity",0,9) +
                    '}';
                end;
              end;
            end;
          DATABASE::"Sales Cr.Memo Header":
            begin
              SalesCrMemoHeader.Get(PaymentLine."Document No.");
              OrderId := SalesCrMemoHeader."External Order No.";

              SalesCrMemoLine.SetRange("Document No.",SalesCrMemoHeader."No.");
              SalesCrMemoLine.SetRange(Type,SalesCrMemoLine.Type::Item);
              SalesCrMemoLine.SetFilter(Quantity,'>%1',0);
              if SalesCrMemoLine.FindSet then begin
                ItemArray :=
                  '{' +
                    '"order_item_sku": "' + ItemNo2Sku(SalesCrMemoLine."No.",SalesCrMemoLine."Variant Code") + '",' +
                    '"qty": ' + Format(SalesCrMemoLine.Quantity,0,9) +
                  '}';

                while SalesCrMemoLine.Next <> 0 do begin
                  ItemArray +=
                    ',{' +
                      '"order_item_sku": "' + ItemNo2Sku(SalesCrMemoLine."No.",SalesCrMemoLine."Variant Code") + '",' +
                      '"qty": ' + Format(SalesCrMemoLine.Quantity,0,9) +
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

        if not NpXmlDomMgt.SendWebRequestText(Request,HttpWebRequest,HttpWebResponse,WebException) then begin
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          if ParseJson(ErrorMessage,JToken) then begin
            Response := GetJsonText(JToken,'messages.error[0].message',0);
            if Response = '' then
              Response := GetJsonText(JToken,'message',0);

            if Response <> '' then
              Error(Response);
          end;
          Error(CopyStr(ErrorMessage,1,1020));
        end;

        ResponseJson := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not ParseJson(ResponseJson,JToken) then
          Error(ResponseJson);

        Response := GetJsonText(JToken,'messages.success',0);
        if Response <> '' then
          exit;

        Error('%1',JToken);
    end;

    procedure "--- Aux"()
    begin
    end;

    local procedure SetApiInfo(var MagentoPaymentGateway: Record "Magento Payment Gateway")
    var
        MagentoSetup: Record "Magento Setup";
    begin
        if not MagentoSetup.Get then
          exit;

        if MagentoPaymentGateway."Api Url" = '' then
          MagentoPaymentGateway."Api Url" := CopyStr(MagentoSetup."Api Url" + 'paymentprocessor',1,MaxStrLen(MagentoPaymentGateway."Api Url"));
        if MagentoPaymentGateway."Api Password" = '' then
          MagentoPaymentGateway."Api Password" := MagentoSetup."Api Authorization";
    end;

    local procedure InitWebRequest(Url: Text;Authorization: Text;var HttpWebRequest: DotNet npNetHttpWebRequest)
    var
        Credential: DotNet npNetNetworkCredential;
        Uri: DotNet npNetUri;
    begin
        HttpWebRequest := HttpWebRequest.Create(Uri.Uri(Url));
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'naviconnect/json';
        HttpWebRequest.Accept := 'application/json';
        HttpWebRequest.UseDefaultCredentials(false);
        HttpWebRequest.Headers.Add('Authorization',Authorization);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Magento Pmt. M2 Mgt.");
    end;

    procedure IsM2PaymentLine(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
          exit(false);

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
          exit(false);

        exit(PaymentGateway."Capture Codeunit Id" = CurrCodeunitId());
    end;

    procedure IsM2RefundLine(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
          exit(false);

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
          exit(false);

        exit(PaymentGateway."Refund Codeunit Id" = CurrCodeunitId());
    end;

    local procedure GetJsonText(JToken: DotNet npNetJToken;JPath: Text;MaxLen: Integer) Value: Text
    var
        JToken2: DotNet npNetJToken;
    begin
        JToken2 := JToken.SelectToken(JPath);
        if IsNull(JToken2) then
          exit('');

        Value := Format(JToken2);
        if MaxLen > 0 then
          Value := CopyStr(Value,1,MaxLen);
        exit(Value);
    end;

    [TryFunction]
    local procedure ParseJson(Json: Text;var JToken: DotNet npNetJToken)
    begin
        JToken := JToken.Parse(Json);
    end;

    local procedure ItemNo2Sku(ItemNo: Text;VariantCode: Code[10]) Sku: Text
    begin
        Sku := ItemNo;
        if VariantCode <> '' then
          Sku += '_' + VariantCode;

        exit(Sku);
    end;
}

