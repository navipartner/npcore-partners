codeunit 6014485 "PBS Gift Voucher Functions"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPRx.xx/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 230373 NP Retail 2016
    // NPR5.36/TJ  /20170914 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.38/MHA /20180105  CASE 301053 Reworked GetBalance() to use dotnet instead of automation
    // NPR5.51/MHA /20190705  CASE 361164 Updated Exception Message parsing in GetBalance()


    trigger OnRun()
    begin
        //Betalingsvalg.GET('PBS');
        //MESSAGE(FORMAT(getBalance('9208607571000000023',ExpireDate)))
        GetBalanceFromCardNo;
    end;

    var
        PaymentTypePOS: Record "Payment Type POS";
        EnvironmentMgt: Codeunit "NPR Environment Mgt.";

    procedure IsGiftVoucher(PAN: Code[30]) IsGiftV: Boolean
    var
        PaymentTypePrefix: Record "Payment Type - Prefix";
        "Filter": Code[30];
        Len: Integer;
    begin
        Filter := PAN;
        Len := StrLen(Filter);
        while Len > 0 do begin
          PaymentTypePrefix.SetRange(PaymentTypePrefix.Prefix,Filter);
          if PaymentTypePrefix.Find('-') then
            repeat
              PaymentTypePOS.Reset;
              PaymentTypePOS.SetCurrentKey("No.","Via Terminal");
              PaymentTypePOS.SetRange("No.",PaymentTypePrefix."Payment Type");
              PaymentTypePOS.SetRange("Via Terminal",true);
              if PaymentTypePOS.Find('-') and PaymentTypePOS."PBS Gift Voucher" then begin
                exit(PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::"Gift Voucher");
              end;
            until (PaymentTypePrefix.Next = 0);
          Len := Len - 1;
          Filter := CopyStr(Filter,1,Len);
        end;
        exit(false);
    end;

    procedure InitiateBarcodeTransfer(Amount: Decimal;Path: Text[250];Description: Text[100];Cvm: Integer;OnOffline: Integer;Barcode: Text[19])
    var
        File: File;
    begin
        //InitiateBarcodeTransfer
        File.TextMode(true);
        File.WriteMode(true);
        if Exists(Path + 'PPBarcode.txt') then begin
          File.Open(Path + 'PPBarcode.txt');
          File.Seek(File.Len);
        end else
          File.Create(Path+'PPBarcode.txt');

        if Amount = 0 then  //Ved �bne lukke
          File.Write('NULL')
        else
          File.Write(Format(Round(Amount * 100,1),0,1) + ',' +
                Format(Time,0,'<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>') + ',' +   //Timestamp version
                Description + ',' + Format(Cvm) + ',' + Format(OnOffline) + ',' + Barcode);
        File.Close;
    end;

    procedure PerformGiftVoucherTransfer(var SaleLinePOS: Record "Sale Line POS";Barcode: Text[19])
    begin
        case SaleLinePOS."Sale Type" of
          SaleLinePOS."Sale Type"::Payment :
            begin
              PerformPositiveTransfer(SaleLinePOS,Barcode);
            end;
          SaleLinePOS."Sale Type"::Sale:
            begin
              PerformNegativeTransfer(SaleLinePOS);
            end;
        end;
    end;

    procedure PerformPositiveTransfer(var SaleLinePOS: Record "Sale Line POS";Barcode: Text[19])
    var
        CallTerminalIntegration: Codeunit "Call Terminal Integration";
    begin
        CallTerminalIntegration.SetBarcode(Barcode);
        CallTerminalIntegration.Run(SaleLinePOS);
    end;

    procedure PerformNegativeTransfer(var SaleLinePOS: Record "Sale Line POS")
    begin
        Error('NOT Implemented');
    end;

    procedure GetBalance(Card: Code[19];var ExpiryDate: Text[30]) Balance: Integer
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        WebException: DotNet npNetWebException;
        ErrorMessage: Text;
        LastErrorMessage: Text;
        Response: Text;
    begin
        if PaymentTypePOS."PBS Customer ID" = '' then
          exit(0);

        //-NPR5.38 [301053]
        // IF NOT ISCLEAR(http) THEN
        //  CLEAR(http);
        // IF NOT ISCLEAR(XMLReader) THEN
        //  CLEAR(XMLReader);
        // CREATE(http,TRUE,TRUE);
        // CREATE(XMLReader,TRUE,TRUE);
        // FilePath := EnvironmentMgt.ClientEnvironment('userprofile') + '\CardRequest.xml';
        // IF EXISTS(FilePath) THEN
        //  ERASE(FilePath);
        // File.CREATE(FilePath);
        // File.OPEN(FilePath);
        // File.CREATEOUTSTREAM(Ostream);
        // Ostream.WRITETEXT(header);
        // Ostream.WRITETEXT('<Sender>' + PaymentTypePOS."PBS Customer ID" + '</Sender>');
        // Ostream.WRITETEXT('<CardNr>' + Card + '</CardNr>');
        // Ostream.WRITETEXT(footer);
        // File.CLOSE;
        //
        // XMLReader.load(FilePath);
        // http.open('POST','https://gavekort.pbs.dk/atsws/ATSWS001.asmx');
        // http.setRequestHeader('Content-Type','text/xml');
        // http.setRequestHeader('SOAPAction','http://tempuri.org/BalanceInquiry');
        // http.send(XMLReader);
        //
        // XmlBuffer := http.responseXML;
        //
        // IF XMLReader.load(XmlBuffer) THEN BEGIN
        //  Nodelist := XMLReader.getElementsByTagName('soap:Envelope');
        //  Node := Nodelist.item(0);
        //  WHILE(Node.firstChild.hasChildNodes) DO
        //    Node := Node.firstChild;
        //  WHILE(NOT ISCLEAR(Node)) DO BEGIN
        //    CASE Node.nodeName OF
        //     'Balance':
        //       EVALUATE(Balance,Node.text);
        //     'CardStatus':
        //       EVALUATE(Status,Node.text);
        //     'ExpiryDate':
        //       ExpiryDate := Node.text;
        //    END;
        //    Node := Node.nextSibling;
        //  END;
        //  IF NOT ISCLEAR(Node) THEN
        //    EVALUATE(Balance,Node.text);
        // END;
        // XMLReader.save(EnvironmentMgt.ClientEnvironment('userprofile') + '\CardResponse.xml');
        // CLEAR(XMLReader);
        // EXIT(Balance)
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<?xml version="1.0" encoding="utf-8"?>' +
          '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
          '  <soap:Body>' +
          '    <BalanceInquiry xmlns="http://tempuri.org/">' +
          '      <Sender>' + PaymentTypePOS."PBS Customer ID" + '</Sender>' +
          '      <CardNr>' + Card + '</CardNr>' +
          '    </BalanceInquiry>' +
          '  </soap:Body>' +
          '</soap:Envelope>');

        HttpWebRequest := HttpWebRequest.Create('https://gavekort.pbs.dk/atsws/ATSWS001.asmx');
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType('text/xml');
        HttpWebRequest.Headers.Add('SOAPAction','http://tempuri.org/BalanceInquiry');
        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          //-NPR5.51 [361164]
          ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          //+NPR5.51 [361164]
          Error(CopyStr(ErrorMessage,1,1000));
        end;

        Response := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);;
        if not NpXmlDomMgt.TryLoadXml(Response,XmlDoc) then
          Error(CopyStr(Response,1,1000));

        XmlElement := XmlDoc.DocumentElement;
        if NpXmlDomMgt.FindNode(XmlElement,'Balance',XmlElement2) then
          Evaluate(Balance,XmlElement2.InnerText);
        if NpXmlDomMgt.FindNode(XmlElement,'ExpiryDate',XmlElement2) then
          ExpiryDate := XmlElement2.InnerText;

        exit(Balance)
        //+NPR5.38 [301053]
    end;

    procedure GetBalanceFromCardNo()
    var
        TxtInput: Label 'Type cardnumber';
        POSEventMarshaller: Codeunit "POS Event Marshaller";
        CardNo: Text[30];
        ExpireDate: Text[30];
        TxtReturn: Label 'Balance is : %1';
    begin
        CardNo := POSEventMarshaller.SearchBox(TxtInput,'',MaxStrLen(CardNo));

        if CopyStr(CardNo,1,4) = '6075' then
          CardNo := '9208' +  CopyStr(CardNo,1,15);
        if IsGiftVoucher(CardNo) then begin
          Message(StrSubstNo(TxtReturn,GetBalance(CardNo,ExpireDate) / 100));
        end;
    end;

    procedure GetMSC(Path: Text[250]) CardNo: Code[19]
    var
        File: File;
        Track1: Text[50];
        Track2: Text[50];
        Track3: Text[50];
        TrackNo: Integer;
    begin
        File.TextMode(true);
        File.WriteMode(false);
        if File.Open(Path + 'MSC.txt') then begin
          for TrackNo := 1 to 3 do begin
            case TrackNo of
              1:
                File.Read(Track1);
              2:
                File.Read(Track2);
              3:
                File.Read(Track3);
            end;
          end;
          File.Close;
          if Erase(Path + 'MSC.txt') then;
        end else
          exit('');

        CardNo := CopyStr(Track2,6,15) + CopyStr(Track2,35,4);
    end;

    procedure AddGiftVoucherInfo(SaleLinePOS: Record "Sale Line POS";Date2: Text[30];BalanceAmount: Decimal)
    var
        CreditCardTransaction: Record "Credit Card Transaction";
        EntryNo: Integer;
        SalePOS: Record "Sale POS";
    begin
        exit;

        SalePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.");

        CreditCardTransaction.SetRange(CreditCardTransaction."Register No.",SaleLinePOS."Register No.");
        CreditCardTransaction.SetRange(CreditCardTransaction."Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        if CreditCardTransaction.Find('+') then begin
          CreditCardTransaction."Entry No." += 2;
          CreditCardTransaction.Modify;
          EntryNo := CreditCardTransaction."Entry No." - 2;
        end;

        with CreditCardTransaction do begin
          LockTable;
          Init;
          "Entry No." := EntryNo;
          Date := Today;
          Type := 0;
          "Transaction Time" := Time;
          Text := 'Expiration Date:%1' + Date2;
          "Register No." := SaleLinePOS."Register No.";
          "Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
          "Line No." := SaleLinePOS."Line No.";
          "Salesperson Code" := SalePOS."Salesperson Code";
          EntryNo += 1;
          Insert;

          Init;
          "Entry No." := EntryNo;
          Date := Today;
          Type := 0;
          "Transaction Time" := Time;
          Text := 'Saldo : ' + Format(BalanceAmount);
          "Register No." := SaleLinePOS."Register No.";
          "Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
          "Line No." := SaleLinePOS."Line No.";
          "Salesperson Code" := SalePOS."Salesperson Code";
          EntryNo += 1;
          Insert;
        end;
    end;
}

