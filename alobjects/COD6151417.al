codeunit 6151417 "Magento Pmt. Quickpay Mgt."
{
    // MAG1.20/MHA /20150826  CASE 219645 Object created
    // MAG1.22/TR  /20151202  CASE 228134 Error handling modified
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/MHA /20160929  CASE 250694 Added functions CapturePayment() and IsQuickpayPaymentLine()
    // MAG2.03/MHA /20170406  CASE 271773 Extended Error Handling to include Inner WebException- and WebException Message
    // MAG2.06/MHA /20170801  CASE 284557 Added Refund functions RefundPaymentSalesCrMemo() and IsQuickpayRefundLine()
    // MAG2.14/MHA /20180607  CASE 317235 Added Xml Format to ConvertToQuickPayAmount()
    // MAG2.22/MHA /20190624  CASE 359514 Updated parsing of exception message in CatchErrorMessage()


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Quickpay error:\%1';

    local procedure "--- Subscriber"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'CapturePaymentEvent', '', false, false)]
    local procedure CapturePaymentSalesInvoice(PaymentGateway: Record "Magento Payment Gateway"; var PaymentLine: Record "Magento Payment Line")
    begin
        //-MAG2.01 [250694]
        if not IsQuickpayPaymentLine(PaymentLine) then
            exit;
        if PaymentLine."Document Table No." <> DATABASE::"Sales Invoice Header" then
            exit;

        Capture(PaymentLine);

        PaymentLine."Date Captured" := Today;
        PaymentLine.Modify(true);
        //+MAG2.01 [250694]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'RefundPaymentEvent', '', false, false)]
    local procedure RefundPaymentSalesCrMemo(PaymentGateway: Record "Magento Payment Gateway"; var PaymentLine: Record "Magento Payment Line")
    begin
        //-MAG2.06 [284557]
        if not IsQuickpayRefundLine(PaymentLine) then
            exit;
        if PaymentLine."Document Table No." <> DATABASE::"Sales Cr.Memo Header" then
            exit;

        Refund(PaymentLine);

        PaymentLine."Date Refunded" := Today;
        PaymentLine.Modify(true);
        //+MAG2.06 [284557]
    end;

    procedure "--- Create Request"()
    begin
    end;

    local procedure Capture(PaymentLine: Record "Magento Payment Line")
    var
        Dictionary: DotNet npNetDictionary_Of_T_U;
        DotNetArray: DotNet npNetArray;
        HttpWebRequest: DotNet npNetHttpWebRequest;
    begin
        SetupHttpWebRequest(HttpWebRequest, "RequestMethod.Post", PaymentLine, "ServiceName.Capture");
        Dictionary := Dictionary.Dictionary;
        Dictionary.Add("RequestParameter.Id", PaymentLine."No.");
        Dictionary.Add("RequestParameter.Amount", ConvertToQuickPayAmount(PaymentLine.Amount));
        SendWebRequest(Dictionary, DotNetArray, HttpWebRequest);
    end;

    local procedure Cancel(PaymentLine: Record "Magento Payment Line")
    var
        HttpWebRequest: DotNet npNetHttpWebRequest;
        Dictionary: DotNet npNetDictionary_Of_T_U;
        DotNetArray: DotNet npNetArray;
    begin
        SetupHttpWebRequest(HttpWebRequest, "RequestMethod.Post", PaymentLine, "ServiceName.Cancel");

        Dictionary := Dictionary.Dictionary;
        Dictionary.Add("RequestParameter.Id", PaymentLine."No.");
        SendWebRequest(Dictionary, DotNetArray, HttpWebRequest);
    end;

    local procedure Refund(PaymentLine: Record "Magento Payment Line")
    var
        HttpWebRequest: DotNet npNetHttpWebRequest;
        Dictionary: DotNet npNetDictionary_Of_T_U;
        DotNetArray: DotNet npNetArray;
    begin
        SetupHttpWebRequest(HttpWebRequest, "RequestMethod.Post", PaymentLine, "ServiceName.Refund");

        Dictionary := Dictionary.Dictionary;
        Dictionary.Add("RequestParameter.Id", PaymentLine."No.");
        Dictionary.Add("RequestParameter.Amount", ConvertToQuickPayAmount(PaymentLine.Amount));
        SendWebRequest(Dictionary, DotNetArray, HttpWebRequest);
    end;

    procedure "--- Aux"()
    begin
    end;

    local procedure CatchErrorMessage(HttpWebRequest: DotNet npNetHttpWebRequest)
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebResponse: DotNet npNetHttpWebResponse;
        HttpWebException: DotNet npNetWebException;
        XmlDoc: DotNet npNetXmlDocument;
        StreamReader: DotNet npNetStreamReader;
        ErrorMessage: Text;
    begin
        XmlDoc := XmlDoc.XmlDocument;
        //-MAG2.03 [271773]
        if NpXmlDomMgt.SendWebRequest(XmlDoc, HttpWebRequest, HttpWebResponse, HttpWebException) then
            exit;

        //-MAG2.22 [359514]
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(HttpWebException);
        //+MAG2.22 [359514]
        Error(StrSubstNo(Text000, CopyStr(ErrorMessage, 1, 900)));
        //+MAG2.03 [271773]
    end;

    local procedure CreateBasicAuth(ApiUsername: Text; ApiPassword: Text): Text
    var
        Convert: DotNet npNetConvert;
        Encoding: DotNet npNetEncoding;
    begin
        exit('Basic ' + Convert.ToBase64String(Encoding.UTF8.GetBytes(ApiUsername + ':' + ApiPassword)));
    end;

    local procedure ConvertToQuickPayAmount(Amount: Decimal) QuickpayAmount: Text
    begin
        //-MAG2.14 [317235]
        QuickpayAmount := DelChr(Format(Amount * 100, 0, 9), '=', '.');
        exit(QuickpayAmount);
        //+MAG2.14 [317235]
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        //-MAG2.06 [284557]
        exit(CODEUNIT::"Magento Pmt. Quickpay Mgt.");
        //+MAG2.06 [284557]
    end;

    procedure IsQuickpayPaymentLine(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "Magento Payment Gateway";
    begin
        //-MAG2.01 [250694]
        if PaymentLine."Payment Gateway Code" = '' then
            exit;

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit(false);

        //-MAG2.06 [284557]
        exit(PaymentGateway."Capture Codeunit Id" = CurrCodeunitId());
        //+MAG2.06 [284557]
        //+MAG2.01 [250694]
    end;

    procedure IsQuickpayRefundLine(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "Magento Payment Gateway";
    begin
        //-MAG2.06 [284557]
        if PaymentLine."Payment Gateway Code" = '' then
            exit;

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit(false);

        exit(PaymentGateway."Refund Codeunit Id" = CurrCodeunitId());
        //+MAG2.06 [284557]
    end;

    local procedure SendWebRequest(Dictionary: DotNet npNetDictionary_Of_T_U; DotNetArray: DotNet npNetArray; HttpWebRequest: DotNet npNetHttpWebRequest)
    begin
        SerializeObject(Dictionary, DotNetArray);
        HttpWebRequest.GetRequestStream().Write(DotNetArray, 0, DotNetArray.Length);
        CatchErrorMessage(HttpWebRequest);
    end;

    local procedure SerializeObject(Dictionary: DotNet npNetDictionary_Of_T_U; var DotNetArray: DotNet npNetArray)
    var
        Encoding: DotNet npNetEncoding;
        JavaScriptSerializer: DotNet npNetJavaScriptSerializer;
        Type: DotNet npNetType;
    begin
        JavaScriptSerializer := JavaScriptSerializer.JavaScriptSerializer;
        Type := Type.GetType('System.Byte', false);
        DotNetArray.CreateInstance(Type, 1);
        Encoding := Encoding.UTF8;
        DotNetArray := Encoding.GetBytes(JavaScriptSerializer.Serialize(Dictionary));
    end;

    local procedure SetupHttpWebRequest(var HttpWebRequest: DotNet npNetHttpWebRequest; RequestMethod: Code[10]; PaymentLine: Record "Magento Payment Line"; RequestService: Text)
    var
        PaymentGateway: Record "Magento Payment Gateway";
    begin
        if PaymentGateway.Get(PaymentLine."Payment Gateway Code") then begin
            HttpWebRequest := HttpWebRequest.Create(PaymentGateway."Api Url" + '/' + PaymentLine."No." + '/' + RequestService);
            HttpWebRequest.Timeout := 1000 * 60 * 5;
            HttpWebRequest.Headers.Add('Authorization', CreateBasicAuth('', PaymentGateway."Api Password"));
            HttpWebRequest.Headers.Add('accept-version', 'v10');
            HttpWebRequest.Method := RequestMethod;
            HttpWebRequest.ContentType := 'application/json';
        end;
    end;

    local procedure GetErrorMessage(JsonData: Text) ErrorMessage: Text
    var
        DictionaryErrors: DotNet npNetDictionary_Of_T_U;
        DictionaryKeys: DotNet npNetDictionary_Of_T_U;
        IEnumerator: DotNet npNetIEnumerator;
        IEnumerator2: DotNet npNetIEnumerator;
        JavaScriptSerializer: DotNet npNetJavaScriptSerializer;
        ListOfKeys: DotNet npNetList_Of_T;
        ListOfValues: DotNet npNetList_Of_T;
        Type: DotNet npNetType;
        Value: Text;
        NetConvHelper: Variant;
    begin
        DictionaryErrors := DictionaryErrors.Dictionary;
        Type := DictionaryErrors.GetType;
        JavaScriptSerializer := JavaScriptSerializer.JavaScriptSerializer;
        DictionaryErrors := JavaScriptSerializer.Deserialize(JsonData, Type);

        if DictionaryErrors.TryGetValue('errors', DictionaryKeys) then begin
            NetConvHelper := DictionaryKeys.Keys;
            ListOfKeys := NetConvHelper;
            IEnumerator := ListOfKeys.GetEnumerator;
            while IEnumerator.MoveNext do begin
                if DictionaryKeys.TryGetValue(IEnumerator.Current, ListOfValues) then
                    IEnumerator2 := ListOfValues.GetEnumerator;
                while IEnumerator2.MoveNext do begin
                    CreateErrorMessage(ErrorMessage, Format(IEnumerator.Current), Format(IEnumerator2.Current));
                end;
            end;
        end;
        //-MAG1.22
        if DictionaryErrors.TryGetValue('error', Value) then
            exit(Value);
        if DictionaryErrors.TryGetValue('message', Value) then
            exit(Value);
        //+MAG1.22
        exit(ErrorMessage);
    end;

    local procedure CreateErrorMessage(var ErrorMessage: Text; MainError: Text; Error: Text)
    begin
        ErrorMessage += MainError + ' : ' + Error + '\';
    end;

    procedure "--- Enum"()
    begin
    end;

    local procedure "RequestMethod.Post"(): Text
    begin
        exit('POST');
    end;

    local procedure "RequestParameter.Amount"(): Text
    begin
        exit('amount');
    end;

    local procedure "RequestParameter.Id"(): Text
    begin
        exit('id');
    end;

    local procedure "ServiceName.Cancel"(): Text
    begin
        exit('cancel');
    end;

    local procedure "ServiceName.Capture"(): Text
    begin
        exit('capture');
    end;

    local procedure "ServiceName.Refund"(): Text
    begin
        exit('refund');
    end;

    procedure "--- NC"()
    begin
    end;

    procedure IsNaviConnectPayment(var SalesHeader: Record "Sales Header"): Boolean
    var
        PaymentLine: Record "Magento Payment Line";
    begin
        PaymentLine.Reset;
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetFilter("Account No.", '<>%1', '');
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        exit(PaymentLine.FindFirst);
    end;

    procedure CaptureSalesInvHeader(SalesInvoiceHeader: Record "Sales Invoice Header"): Boolean
    var
        PaymentLine: Record "Magento Payment Line";
    begin
        if SalesInvoiceHeader."Order No." = '' then
            exit(false);

        PaymentLine.Reset;
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        PaymentLine.SetFilter("Payment Gateway Code", '<>%1', '');
        PaymentLine.SetFilter("Account No.", '<>%1', '');
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        PaymentLine.SetRange("Date Captured", 0D);
        if PaymentLine.FindSet then
            repeat
                Commit;
                Capture(PaymentLine);
                PaymentLine."Date Captured" := Today;
                PaymentLine.Modify;
                Commit;
            until PaymentLine.Next = 0;
        exit(true);
    end;
}

