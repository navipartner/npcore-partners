codeunit 6150873 "NPR POS Action: NETSGift.Look."
{
    // NPR5.51/MMV /20190625 CASE 359385 Created object
    // NPR5.51/MHA /20190705  CASE 361164 Updated Exception Message parsing InvokeWebservice()
    // NPR5.53/MHA /20191212  CASE 374433 Fixed parsing of xml in OnAction()
    // NPR5.54/MMV /20200131 CASE 387965 Made InvokeWebservice function global


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Lookup of NETS giftcards via barcode scan.';
        GIFTCARD_TITLE: Label 'NETS Gift Card';
        GIFTCARD_CAPTION: Label 'Scan barcode';
        LOOKUP_PROMPT: Label 'No.: %1\Balance: %2\Expiry: %3';
        BALANCE_UNKNOWN: Label 'Gift card balance unknown';

    local procedure ActionCode(): Text
    begin
        exit('NETS_GIFTCARD_LOOKUP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do begin
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple) then begin
                RegisterWorkflowStep('ScanBarcode', 'input({title: labels.NETSGiftcardTitle, caption: labels.NETSGiftcardCaption, value: "", notBlank: true}).respond();');
                RegisterWorkflow(false);

                RegisterTextParameter('CustomerID', '');
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'NETSGiftcardCaption', GIFTCARD_CAPTION);
        Captions.AddActionCaption(ActionCode, 'NETSGiftcardTitle', GIFTCARD_TITLE);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        CardNo: Text;
        ExpiryDate: Text;
        Balance: Decimal;
        CustomerID: Text;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;
        Handled := true;

        if WorkflowStep <> 'ScanBarcode' then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        CustomerID := JSON.GetStringParameter('CustomerID', true);
        CardNo := GetInput(JSON, 'ScanBarcode');
        CardNo := DelChr(CardNo, '=', DelChr(CardNo, '=', 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'));

        if InvokeWebservice(CustomerID, CardNo, ExpiryDate, Balance) then
            Message(LOOKUP_PROMPT, CardNo, Balance, ExpiryDate)
        else
            Message(BALANCE_UNKNOWN);
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit('');

        exit(JSON.GetString('input', true));
    end;

    procedure InvokeWebservice(CustomerID: Text; CardNo: Text; var ExpiryDateOut: Text; var BalanceOut: Decimal): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        WebException: DotNet NPRNetWebException;
        ErrorMessage: Text;
        LastErrorMessage: Text;
        Response: Text;
    begin
        //Migrated from codeunit "PBS Gift Voucher Functions" but it does not look like it has proper return type handling.
        //Treating lack of "Balance" in response as error, as I don't have API docs

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<?xml version="1.0" encoding="utf-8"?>' +
          '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soap:Body>' +
              '<BalanceInquiry xmlns="http://tempuri.org/">' +
                '<Sender>' + EscapeXMLData(CustomerID) + '</Sender>' +
                '<CardNr>' + EscapeXMLData(CardNo) + '</CardNr>' +
              '</BalanceInquiry>' +
            '</soap:Body>' +
          '</soap:Envelope>');

        HttpWebRequest := HttpWebRequest.Create('https://gavekort.pbs.dk/atsws/ATSWS001.asmx');
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType('text/xml');
        HttpWebRequest.Headers.Add('SOAPAction', 'http://tempuri.org/BalanceInquiry');
        if not NpXmlDomMgt.SendWebRequest(XmlDoc, HttpWebRequest, HttpWebResponse, WebException) then begin
            //-NPR5.51 [361164]
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
            if NpXmlDomMgt.TryLoadXml(ErrorMessage, XmlDoc) then begin
                NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
                if NpXmlDomMgt.FindNode(XmlDoc.DocumentElement, '//faultstring', XmlElement) then
                    ErrorMessage := XmlElement.InnerText;
            end;
            Error(CopyStr(ErrorMessage, 1, 1000));
            //+NPR5.51 [361164]
        end;

        Response := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if not NpXmlDomMgt.TryLoadXml(Response, XmlDoc) then
            Error(Response);

        //-NPR5.53 [374433]
        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        XmlElement := XmlDoc.DocumentElement;
        if NpXmlDomMgt.FindElement(XmlElement, '//ExpiryDate', false, XmlElement2) then
            ExpiryDateOut := XmlElement2.InnerText;
        if NpXmlDomMgt.FindElement(XmlElement, '//Balance', false, XmlElement2) then begin
            Evaluate(BalanceOut, XmlElement2.InnerText, 9);
            BalanceOut /= 100;
            exit(true)
        end;
        //+NPR5.53 [374433]

        exit(false);
    end;

    local procedure EscapeXMLData(TextIn: Text): Text
    var
        String: DotNet NPRNetString;
        Response: Text;
    begin
        String := TextIn;
        String.Replace('<', '&lt;');
        String.Replace('&', '&amp;');
        Response := String;
        exit(Response);
    end;
}

