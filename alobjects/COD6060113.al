codeunit 6060113 "TM Ticket DIY Ticket Print"
{
    // TM1.26/TSA /20171101 CASE 276843 Initial Version
    // TM1.26/TSA /20171122  CASE 285601-01 Transport TM1.26 - 22 November 2017
    // TM1.27/TSA /20171218 CASE 300395 Added setup Timeout (ms)
    // 
    // 
    // *** TICKET SERVER setup ***
    //   http://test.ticket.navipartner.dk/import/api/rest/v1/ticket/orders
    //   web_experimentarium
    //   bf103bceddfb087198b0d032afea29db
    //   http://test.ticket.navipartner.dk/ticket/
    //   http://test.ticket.navipartner.dk/order/
    //   Danish
    // 
    //   Ticket Type Code: developer-test
    // ***
    // TM1.35/TSA/20180725  CASE 320783 Transport TM1.35 - 25 July 2018


    trigger OnRun()
    var
        FailReason: Text;
    begin
        if (not GenerateTicketPrint(25783, true, FailReason)) then
            Error(FailReason);

        Message('Ok (%1)', FailReason);
    end;

    procedure GenerateTicketPrint(EntryNo: Integer; MarkTicketAsPrinted: Boolean; var FailReasonText: Text): Boolean
    var
        TicketRequestXml: DotNet npNetXmlDocument;
        ServiceResponse: DotNet npNetXmlDocument;
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        ErrorCode: Code[10];
        ErrorText: Text;
    begin

        TicketReservationRequest.Get(EntryNo);
        if (TicketReservationRequest."DIY Print Order Requested") then
            exit(true);

        CreatTicketPrintOrderXml(TicketRequestXml, TicketReservationRequest."Session Token ID", MarkTicketAsPrinted);

        if (WebServiceApi(FailReasonText, TicketRequestXml, ServiceResponse)) then begin
            FailReasonText := '';
            TicketReservationRequest."DIY Print Order At" := CurrentDateTime;
            TicketReservationRequest."DIY Print Order Requested" := true;
            TicketReservationRequest.Modify();
            exit(true);
        end;

        // Examine fault code - might have been produced already
        if (WebExceptionResponse(ServiceResponse, ErrorCode, ErrorText)) then begin
            FailReasonText := StrSubstNo('TicketServer: [%1] %2', ErrorCode, ErrorText);

            if ((StrPos(ErrorText, 'Bad Request: Ticket ') > 0) and (StrPos(ErrorText, ' already exists.') > 0)) then begin
                TicketReservationRequest."DIY Print Order At" := CurrentDateTime;
                TicketReservationRequest."DIY Print Order Requested" := true;
                TicketReservationRequest.Modify();
                exit(true);
            end;
        end;

        exit(false);
    end;

    procedure ViewOnlineTicketOrder(RequestEntryNo: Integer)
    var
        TicketSetup: Record "TM Ticket Setup";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        FailReason: Text;
    begin

        TicketReservationRequest.Get(RequestEntryNo);

        TicketSetup.Get();
        TicketSetup.TestField("Print Server Order URL");

        if (not GenerateTicketPrint(RequestEntryNo, true, FailReason)) then
            Error(FailReason);

        HyperLink(StrSubstNo('%1%2', TicketSetup."Print Server Order URL", TicketReservationRequest."Session Token ID"));
    end;

    procedure ViewOnlineSingleTicket(TicketNo: Code[20])
    var
        Ticket: Record "TM Ticket";
        TicketSetup: Record "TM Ticket Setup";
        FailReason: Text;
    begin

        Ticket.Get(TicketNo);

        TicketSetup.Get();
        TicketSetup.TestField("Print Server Ticket URL");

        if (not GenerateTicketPrint(Ticket."Ticket Reservation Entry No.", true, FailReason)) then
            Error(FailReason);

        HyperLink(StrSubstNo('%1%2', TicketSetup."Print Server Ticket URL", Ticket."External Ticket No."));
    end;

    procedure ValidateSetup(): Boolean
    var
        TicketSetup: Record "TM Ticket Setup";
    begin

        if (not TicketSetup.Get()) then
            exit(false);

        if ((TicketSetup."Print Server Generator URL" = '') or
            (TicketSetup."Print Server Gen. Username" = '') or
            (TicketSetup."Print Server Gen. Password" = '')) then
            exit(false);

        exit(true);
    end;

    local procedure WebServiceApi(var ReasonText: Text; var XmlDocIn: DotNet npNetXmlDocument; var XmlDocOut: DotNet npNetXmlDocument): Boolean
    var
        TicketSetup: Record "TM Ticket Setup";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        Convert: DotNet npNetConvert;
        B64Credential: Text[200];
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebException: DotNet npNetWebException;
        WebInnerException: DotNet npNetWebException;
        Url: Text;
        ErrorMessage: Text;
        ResponseText: Text;
        Exception: DotNet npNetException;
        StatusCode: Code[10];
        StatusDescription: Text[50];
        "---": Integer;
        UserName: Text;
        Password: Text;
    begin

        if (not TicketSetup.Get()) then
            exit(false);

        Url := TicketSetup."Print Server Generator URL";
        UserName := TicketSetup."Print Server Gen. Username";
        Password := TicketSetup."Print Server Gen. Password";

        ReasonText := '';
        HttpWebRequest := HttpWebRequest.Create(Url);

        //-TM1.27 [300395]
        //HttpWebRequest.Timeout := 2000;
        HttpWebRequest.Timeout := 10000;
        if (TicketSetup."Timeout (ms)" > 0) then
            HttpWebRequest.Timeout := TicketSetup."Timeout (ms)";
        //+TM1.27 [300395]

        HttpWebRequest.KeepAlive(false);

        HttpWebRequest.UseDefaultCredentials(false);
        B64Credential := ToBase64(StrSubstNo('%1:%2', UserName, Password));
        HttpWebRequest.Headers.Add('Authorization', StrSubstNo('Basic %1', B64Credential));

        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'navision/xml';

        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if (TrySendWebRequest(XmlDocIn, HttpWebRequest, HttpWebResponse)) then begin
            TryReadResponseText(HttpWebResponse, ResponseText);
            XmlDocOut := XmlDocOut.XmlDocument;
            XmlDocOut.LoadXml(ResponseText);
            exit(true);
        end;

        ReasonText := StrSubstNo('Error from WebServiceApi: %1\\%2', Url, GetLastErrorText);

        Exception := GetLastErrorObject();

        if ((Format(GetDotNetType(Exception.GetBaseException()))) <> (Format(GetDotNetType(WebException)))) then
            Error(Exception.ToString());

        WebException := Exception.GetBaseException();
        TryReadExceptionResponseText(WebException, StatusCode, StatusDescription, ResponseText);

        XmlDocOut := XmlDocOut.XmlDocument;
        if (StrLen(ResponseText) > 0) then
            XmlDocOut.LoadXml(ResponseText);

        if (StrLen(ResponseText) = 0) then
            XmlDocOut.LoadXml(StrSubstNo(
              '<fault>' +
                '<code>%1</code>' +
                '<message>%2 - %3</message>' +
              '</fault>',
              StatusCode,
              StatusDescription,
              Url
              ));

        exit(false);
    end;

    [TryFunction]
    local procedure TrySendWebRequest(var XmlDoc: DotNet npNetXmlDocument; HttpWebRequest: DotNet npNetHttpWebRequest; var HttpWebResponse: DotNet npNetHttpWebResponse)
    var
        MemoryStream: DotNet npNetMemoryStream;
    begin

        MemoryStream := HttpWebRequest.GetRequestStream;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    [TryFunction]
    local procedure TryReadResponseText(var HttpWebResponse: DotNet npNetHttpWebResponse; var ResponseText: Text)
    var
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
    begin

        StreamReader := StreamReader.StreamReader(HttpWebResponse.GetResponseStream());
        ResponseText := StreamReader.ReadToEnd;
        StreamReader.Close;
        Clear(StreamReader);
    end;

    [TryFunction]
    local procedure TryReadExceptionResponseText(var WebException: DotNet npNetWebException; var StatusCode: Code[10]; var StatusDescription: Text; var ResponseXml: Text)
    var
        Stream: DotNet npNetStream;
        StreamReader: DotNet npNetStreamReader;
        WebResponse: DotNet npNetWebResponse;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        WebExceptionStatus: DotNet npNetWebExceptionStatus;
        SystemConvert: DotNet npNetConvert;
        StatusCodeInt: Integer;
        DotNetType: DotNet npNetType;
    begin

        ResponseXml := '';

        // No respone body on time out
        if (WebException.Status.Equals(WebExceptionStatus.Timeout)) then begin
            DotNetType := GetDotNetType(StatusCodeInt);
            StatusCodeInt := SystemConvert.ChangeType(WebExceptionStatus.Timeout, DotNetType);
            StatusCode := Format(StatusCodeInt);
            StatusDescription := WebExceptionStatus.Timeout.ToString();
            exit;
        end;

        // This happens for unauthorized and server side faults (4xx and 5xx)
        // The response stream in unauthorized fails in XML transformation later
        if (WebException.Status.Equals(WebExceptionStatus.ProtocolError)) then begin
            HttpWebResponse := WebException.Response();
            DotNetType := GetDotNetType(StatusCodeInt);
            StatusCodeInt := SystemConvert.ChangeType(HttpWebResponse.StatusCode, DotNetType);
            StatusCode := Format(StatusCodeInt);
            StatusDescription := HttpWebResponse.StatusDescription;
            if ((StatusCode[1] = '4') and (StatusCode <> '400')) then
                // IF (StatusCode[1] = '4') THEN // 4xx messages do not normally carry a body
                exit;
        end;

        StreamReader := StreamReader.StreamReader(WebException.Response().GetResponseStream());
        ResponseXml := StreamReader.ReadToEnd;
        StreamReader.Close;
        Clear(StreamReader);
    end;

    local procedure ToBase64(StringToEncode: Text) B64String: Text
    var
        TempBlob: Record TempBlob temporary;
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        Outstr: OutStream;
    begin

        Clear(TempBlob);
        TempBlob.Blob.CreateOutStream(Outstr);
        Outstr.WriteText(StringToEncode);

        TempBlob.Blob.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        B64String := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
    end;

    local procedure "--"()
    begin
    end;

    local procedure CreatTicketPrintOrderXml(var XmlDoc: DotNet npNetXmlDocument; var Token: Text[100]; MarkTicketAsPrinted: Boolean)
    var
        XmlText: Text;
        TempBlob: Record TempBlob temporary;
        OutStr: OutStream;
        TicketTicketServerRequest: XMLport "TM Ticket TicketServer Request";
        InsStr: InStream;
    begin

        TempBlob.Insert();
        TempBlob.Blob.CreateOutStream(OutStr, TEXTENCODING::UTF8);

        TicketTicketServerRequest.SetRequestEntryNo(Token, MarkTicketAsPrinted);
        TicketTicketServerRequest.SetDestination(OutStr);
        TicketTicketServerRequest.Export;
        TempBlob.Modify();

        TempBlob.CalcFields(Blob);
        if (not TempBlob.Blob.HasValue()) then
            Error('XML generation failed for token %1', Token);

        TempBlob.Blob.CreateInStream(InsStr, TEXTENCODING::UTF8);
        InsStr.Read(XmlText);

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlText);

        if (UserId = 'TSA') then Message(XmlText);
    end;

    local procedure WebExceptionResponse(var XmlDoc: DotNet npNetXmlDocument; var ErrorCode: Code[10]; var ErrorText: Text): Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet npNetXmlElement;
        XmlElement2: DotNet npNetXmlElement;
        ElementPath: Text;
        Parameter: Text;
        Value: Text;
        FaultSectionFound: Boolean;
    begin

        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
            ErrorCode := '998';
            ErrorText := StrSubstNo('Invalid XML in error response:', NpXmlDomMgt.PrettyPrintXml(XmlDoc.InnerXml()));
            exit(false);
        end;

        ErrorCode := NpXmlDomMgt.GetXmlText(XmlElement, '//response/error/code', 10, false);
        if (ErrorCode = '') then
            ErrorCode := '999';

        ErrorText := NpXmlDomMgt.GetXmlText(XmlElement, '//response/error/message', 1024, false);
        if (ErrorText = '') then
            ErrorText := GetLastErrorText;

        exit(true);
    end;
}

