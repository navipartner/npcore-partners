codeunit 6151418 "Magento Pmt. Dibs Mgt."
{
    // MAG1.22/TR/20160420  CASE 238567 Dibs payment implemented
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.01/MHA/20160929 CASE 250694 Added functions CapturePaymentSalesInvoice() and IsDibsPaymentLine()


    trigger OnRun()
    begin
        //-MAG2.01 [250694]
        //CASE "Document Table No." OF
        //  DATABASE::"Sales Invoice Header": Capture(Rec);
        //  DATABASE::"Sales Cr.Memo Header": Refund(Rec);
        //  DATABASE::"Sales Header": Cancel(Rec);
        //END;
        //+MAG2.01 [250694]
    end;

    local procedure "--- Subscriber"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'CapturePaymentEvent', '', false, false)]
    local procedure CapturePaymentSalesInvoice(PaymentGateway: Record "Magento Payment Gateway";var PaymentLine: Record "Magento Payment Line")
    begin
        //-MAG2.01 [250694]
        if not IsDibsPaymentLine(PaymentLine) then
          exit;
        if PaymentLine."Document Table No." <> DATABASE::"Sales Invoice Header" then
          exit;

        Capture(PaymentLine);

        PaymentLine."Date Captured" := Today;
        PaymentLine.Modify(true);
        //+MAG2.01 [250694]
    end;

    local procedure "--- Api"()
    begin
    end;

    procedure Capture(PaymentLine: Record "Magento Payment Line")
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PaymentGateway: Record "Magento Payment Gateway";
        HttpWebRequest: DotNet HttpWebRequest;
        CaptureString: Text;
        MD5Key: Text;
    begin
        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
          exit;
        if not SalesInvoiceHeader.Get(PaymentLine."Document No.") then
          exit;

        SetupWebRequest(PaymentGateway."Api Url",HttpWebRequest,PaymentLine,"RequestMethod.Post");

        CaptureString += AppendText('merchant',PaymentGateway."Merchant ID");
        CaptureString += AppendText('orderid',SalesInvoiceHeader."External Document No.");
        CaptureString += AppendText('transact',PaymentLine."No.");
        CaptureString += AppendText('amount',ConvertToDIBSAmount(PaymentLine.Amount));
        MD5Key := CalcMD5Key(CaptureString,PaymentGateway);
        CaptureString += AppendText('md5key',MD5Key);
        CaptureString += AppendText('splitpay','true');
        CaptureString += AppendText('close','false');

        SendWebRequest(HttpWebRequest,CaptureString);
    end;

    procedure Refund(PaymentLine: Record "Magento Payment Line")
    begin
    end;

    procedure Cancel(PaymentLine: Record "Magento Payment Line")
    begin
    end;

    procedure "--- Support"()
    begin
    end;

    procedure AppendText("Key": Text;Value: Text): Text
    var
        Text000: Label '%1=%2&';
    begin
        exit(StrSubstNo(Text000,Key,Value));
    end;

    procedure CalcMD5Key(CaptureString: Text;PaymentGateway: Record "Magento Payment Gateway"): Text
    var
        Encoding: DotNet Encoding;
        MD5: DotNet MD5CryptoServiceProvider;
    begin
        MD5 := MD5.MD5CryptoServiceProvider();
        exit(MD5.ComputeHash(Encoding.UTF8.GetBytes(PaymentGateway."Api Password" + MD5.ComputeHash(Encoding.UTF8.GetBytes(PaymentGateway."Api Username" + CaptureString)).ToString())).ToString());
    end;

    local procedure CatchErrorMessage(HttpWebRequest: DotNet HttpWebRequest)
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebResponse: DotNet HttpWebResponse;
        HttpWebException: DotNet WebException;
        XmlDoc: DotNet XmlDocument;
        Text000: Label 'While trying to connect to DIBS an error appeared\%1';
        StreamReader: DotNet StreamReader;
        Stream: DotNet Stream;
    begin
        XmlDoc := XmlDoc.XmlDocument;
        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,HttpWebException) then begin
          StreamReader := StreamReader.StreamReader(HttpWebResponse.GetResponseStream);
          Error(StrSubstNo(Text000,GetErrorMessage(StreamReader.ReadToEnd)));
        end;
    end;

    local procedure ConvertToDIBSAmount(Amount: Decimal): Text
    begin
        exit(Format(Amount * 100));
    end;

    local procedure GetErrorMessage(ErrorMgs: Text) ErrorMessage: Text
    begin
        Message(ErrorMgs);
    end;

    procedure IsDibsPaymentLine(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        PaymentGateway: Record "Magento Payment Gateway";
    begin
        //-MAG2.01 [250694]
        if PaymentLine."Payment Gateway Code" = '' then
          exit;

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
          exit(false);

        exit(PaymentGateway."Capture Codeunit Id" = CODEUNIT::"Magento Pmt. Dibs Mgt.");
        //+MAG2.01 [250694]
    end;

    local procedure SetupWebRequest(ApiUrl: Text;var HttpWebRequest: DotNet HttpWebRequest;PaymentLine: Record "Magento Payment Line";RequestMethod: Code[10])
    begin
        HttpWebRequest := HttpWebRequest.Create(ApiUrl);
        HttpWebRequest.Timeout := 1000 * 60 * 5;
        HttpWebRequest.Method := RequestMethod;
        HttpWebRequest.ContentType := 'application/x-www-form-urlencoded';
    end;

    local procedure SendWebRequest(HttpWebRequest: DotNet HttpWebRequest;CaptureString: Text)
    var
        DotNetArray: DotNet Array;
    begin
        SerializeObject(CaptureString,DotNetArray);
        HttpWebRequest.GetRequestStream().Write(DotNetArray,0,DotNetArray.Length);
        CatchErrorMessage(HttpWebRequest);
    end;

    local procedure SerializeObject(CaptureString: Text;var DotNetArray: DotNet Array)
    var
        Encoding: DotNet Encoding;
        Type: DotNet Type;
    begin
        Type := Type.GetType('System.Byte',false);
        DotNetArray.CreateInstance(Type,1);
        Encoding := Encoding.UTF8;
        DotNetArray := Encoding.GetBytes(CaptureString);
    end;

    local procedure CreateMD5(ApiUsername: Text;ApiPassword: Text;CaptureString: Text;MD5Hash: Text)
    begin
    end;

    procedure "--- Enum"()
    begin
    end;

    local procedure "RequestMethod.Post"(): Text
    begin
        exit('POST');
    end;
}

