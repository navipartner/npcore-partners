codeunit 6151424 "Magento Pmt. Netaxept Mgt."
{
    // MAG2.24/MHA /20191108  CASE 376322 Object created - Integration with Netaxept Payment gateway


    trigger OnRun()
    begin
    end;

    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";

    local procedure "--- Subscriber"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'CancelPaymentEvent', '', false, false)]
    local procedure CancelPaymentSalesOrder(PaymentGateway: Record "Magento Payment Gateway";var PaymentLine: Record "Magento Payment Line")
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

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'CapturePaymentEvent', '', false, false)]
    local procedure CapturePaymentSalesInvoice(PaymentGateway: Record "Magento Payment Gateway";var PaymentLine: Record "Magento Payment Line")
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

        PaymentLine."Date Captured" := Today;
        PaymentLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'RefundPaymentEvent', '', false, false)]
    local procedure RefundPaymentSalesReturn(PaymentGateway: Record "Magento Payment Gateway";var PaymentLine: Record "Magento Payment Line")
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

        PaymentLine."Date Refunded" := Today;
        PaymentLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, 6151413, 'OnAfterValidateEvent', 'Capture Codeunit Id', true, true)]
    local procedure OnValidateCaptureCodeunitId(var Rec: Record "Magento Payment Gateway")
    begin
        if Rec."Capture Codeunit Id" <> CurrCodeunitId() then
          exit;

        SetApiInfo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151413, 'OnAfterValidateEvent', 'Refund Codeunit Id', true, true)]
    local procedure OnValidateRefundCodeunitId(var Rec: Record "Magento Payment Gateway")
    begin
        if Rec."Refund Codeunit Id" <> CurrCodeunitId() then
          exit;

        SetApiInfo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 6151413, 'OnAfterValidateEvent', 'Cancel Codeunit Id', true, true)]
    local procedure OnValidateCancelCodeunitId(var Rec: Record "Magento Payment Gateway")
    begin
        if Rec."Cancel Codeunit Id" <> CurrCodeunitId() then
          exit;

        SetApiInfo(Rec);
    end;

    procedure "--- Api"()
    begin
    end;

    [TryFunction]
    local procedure Cancel(PaymentLine: Record "Magento Payment Line")
    var
        PaymentGateway: Record "Magento Payment Gateway";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        Response: Text;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        InitHttpWebRequest(PaymentGateway,PaymentLine,"ServiceName.Cancel",HttpWebRequest);

        if not SendWebRequest(HttpWebRequest,HttpWebResponse) then
          Error(CopyStr('NetAxept: ' + GetLastError(),1,1024));

        Response := GetResponseText(HttpWebResponse);
        if not LoadXml(Response,XmlDoc) then
          Error(CopyStr('NetAxept: ' + Response,1,1024));

        Message(XmlDoc.InnerXml);

        if ResponseCodeIsOk(XmlDoc) then
          exit;

        if GetNetaxeptMessage(XmlDoc,Response) then
          Error(CopyStr('NetAxept: ' + Response,1,1024));

        Error(CopyStr('NetAxept: ' + XmlDoc.DocumentElement.InnerXml,1,1024));
    end;

    [TryFunction]
    local procedure Capture(PaymentLine: Record "Magento Payment Line")
    var
        PaymentGateway: Record "Magento Payment Gateway";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        Response: Text;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        InitHttpWebRequest(PaymentGateway,PaymentLine,"ServiceName.Capture",HttpWebRequest);

        if not SendWebRequest(HttpWebRequest,HttpWebResponse) then
          Error(CopyStr('NetAxept: ' + GetLastError(),1,1024));

        Response := GetResponseText(HttpWebResponse);
        if not LoadXml(Response,XmlDoc) then
          Error(CopyStr('NetAxept: ' + Response,1,1024));

        if ResponseCodeIsOk(XmlDoc) then
          exit;

        if GetNetaxeptMessage(XmlDoc,Response) then
          Error(CopyStr('NetAxept: ' + Response,1,1024));

        Error(CopyStr('NetAxept: ' + XmlDoc.DocumentElement.InnerXml,1,1024));
    end;

    [TryFunction]
    local procedure Refund(PaymentLine: Record "Magento Payment Line")
    var
        PaymentGateway: Record "Magento Payment Gateway";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        Response: Text;
    begin
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        InitHttpWebRequest(PaymentGateway,PaymentLine,"ServiceName.Refund",HttpWebRequest);

        if not SendWebRequest(HttpWebRequest,HttpWebResponse) then
          Error(CopyStr('NetAxept: ' + GetLastError(),1,1024));

        Response := GetResponseText(HttpWebResponse);
        if not LoadXml(Response,XmlDoc) then
          Error(CopyStr('NetAxept: ' + Response,1,1024));

        if ResponseCodeIsOk(XmlDoc) then
          exit;

        if GetNetaxeptMessage(XmlDoc,Response) then
          Error(CopyStr('NetAxept: ' + Response,1,1024));

        Error(CopyStr('NetAxept: ' + XmlDoc.DocumentElement.InnerXml,1,1024));
    end;

    local procedure "--- Api Response"()
    begin
    end;

    procedure GetLastError() LastError: Text
    var
        ExceptionError: Text;
    begin
        LastError := GetLastErrorText;
        if GetLastExceptionError(ExceptionError) then
          exit(ExceptionError);

        exit(LastError);
    end;

    [TryFunction]
    local procedure GetLastExceptionError(var ExceptionError: Text)
    var
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        Response: Text;
    begin
        WebException := GetLastErrorObject;
        ExceptionError := WebException.Message;

        WebException := WebException.InnerException;
        ExceptionError := WebException.Message;
    end;

    [TryFunction]
    local procedure GetNetaxeptMessage(var XmlDoc: DotNet npNetXmlDocument;var ResponseExceptionText: Text)
    begin
        ResponseExceptionText := NpXmlDomMgt.GetXmlText(XmlDoc.DocumentElement,'Message',1000,true)
    end;

    procedure GetResponseText(var HttpWebResponse: DotNet npNetHttpWebResponse) ResponseText: Text
    var
        HttpWebException: DotNet npNetWebException;
        BinaryReader: DotNet npNetBinaryReader;
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
        APIUsername: Text;
        ElementName: Text;
        Response: Text;
    begin
        Stream := HttpWebResponse.GetResponseStream;
        StreamReader := StreamReader.StreamReader(Stream);
        ResponseText := StreamReader.ReadToEnd;
        Stream.Flush;
        Stream.Close;
        Clear(Stream);

        exit(ResponseText);
    end;

    [TryFunction]
    local procedure ResponseCodeIsOk(var XmlDoc: DotNet npNetXmlDocument)
    var
        ResponseCode: Text;
    begin
        ResponseCode := LowerCase(NpXmlDomMgt.GetXmlText(XmlDoc.DocumentElement,'ResponseCode',0,true));
        if ResponseCode = 'ok' then
          exit;

        Error('');
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure SetApiInfo(var MagentoPaymentGateway: Record "Magento Payment Gateway")
    var
        MagentoSetup: Record "Magento Setup";
    begin
        if not MagentoSetup.Get then
          exit;

        if MagentoPaymentGateway."Api Url" = '' then
          MagentoPaymentGateway."Api Url" := 'https://epayment.bbs.no/REST/';
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"Magento Pmt. Netaxept Mgt.");
    end;

    local procedure DocumentExists(PaymentLine: Record "Magento Payment Line"): Boolean
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
              exit(SalesHeader.Get(PaymentLine."Document Type",PaymentLine."Document No."));
            end;
          DATABASE::"Sales Cr.Memo Header":
            begin
              exit(SalesCrMemoHeader.Get(PaymentLine."Document No."));
            end;
        end;

        exit(false);
    end;

    local procedure GetApiUrl(PaymentGateway: Record "Magento Payment Gateway";PaymentLine: Record "Magento Payment Line";Method: Text): Text
    begin
        exit(PaymentGateway."Api Url" +
             Method + '.aspx' +
             '?merchantId=' + PaymentGateway."Merchant ID" +
             '&token=' + PaymentGateway."Api Password" +
             '&transactionId=' + LowerCase(PaymentLine."No.") +
             '&transactionreconref=' + '' +
             '&transactionamount=' + DelChr(Format(PaymentLine.Amount,0,'<SIGN><INTEGER><DECIMALS,3>'),'=','.,'));
    end;

    procedure InitHttpWebRequest(PaymentGateway: Record "Magento Payment Gateway";PaymentLine: Record "Magento Payment Line";Method: Text;var HttpWebRequest: DotNet npNetHttpWebRequest)
    begin
        Clear(HttpWebRequest);
        HttpWebRequest := HttpWebRequest.Create(GetApiUrl(PaymentGateway,PaymentLine,Method));
        HttpWebRequest.Timeout := 1000 * 5;
        HttpWebRequest.Method := 'GET';
    end;

    procedure IsNetAxeptPaymentLine(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
          exit;

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
          exit(false);

        exit(PaymentGateway."Capture Codeunit Id" = CurrCodeunitId());
    end;

    [TryFunction]
    local procedure LoadXml(Content: Text;var XmlDoc: DotNet npNetXmlDocument)
    begin
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(Content);
        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
    end;

    local procedure PostedDocumentExists(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        PaymentLine2: Record "Magento Payment Line";
        SalesHeader: Record "Sales Header";
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
              SalesInvHeader.SetRange("Order No.",PaymentLine."Document No.");
              if not SalesInvHeader.FindFirst then
                exit(false);
              exit(PaymentLine2.Get(DATABASE::"Sales Invoice Header",0,SalesInvHeader."No.",PaymentLine."Line No."));
            end;
        end;

        exit(false);
    end;

    [TryFunction]
    procedure SendWebRequest(HttpWebRequest: DotNet npNetHttpWebRequest;var HttpWebResponse: DotNet npNetHttpWebResponse)
    begin
        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    procedure "--- Enum"()
    begin
    end;

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

