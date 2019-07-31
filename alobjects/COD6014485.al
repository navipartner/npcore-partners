codeunit 6014485 "PBS Gift Voucher Functions"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPRx.xx/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 230373 NP Retail 2016
    // NPR5.36/TJ  /20170914 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.38/MHA /20180105  CASE 301053 Reworked GetBalance() to use dotnet instead of automation
    // #361164/MHA /20190705  CASE 361164 Updated Exception Message parsing in GetBalance()

    var
        PaymentTypePOS: Record "Payment Type POS";

    procedure GetBalance(Card: Code[19]; var ExpiryDate: Text[30]) Balance: Integer
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
        HttpWebRequest.Headers.Add('SOAPAction', 'http://tempuri.org/BalanceInquiry');
        if not NpXmlDomMgt.SendWebRequest(XmlDoc, HttpWebRequest, HttpWebResponse, WebException) then begin
            //-#361164 [361164]
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
            //+#361164 [361164]
            Error(CopyStr(ErrorMessage, 1, 1000));
        end;

        Response := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        ;
        if not NpXmlDomMgt.TryLoadXml(Response, XmlDoc) then
            Error(CopyStr(Response, 1, 1000));

        XmlElement := XmlDoc.DocumentElement;
        if NpXmlDomMgt.FindNode(XmlElement, 'Balance', XmlElement2) then
            Evaluate(Balance, XmlElement2.InnerText);
        if NpXmlDomMgt.FindNode(XmlElement, 'ExpiryDate', XmlElement2) then
            ExpiryDate := XmlElement2.InnerText;

        exit(Balance)
        //+NPR5.38 [301053]
    end;
}

