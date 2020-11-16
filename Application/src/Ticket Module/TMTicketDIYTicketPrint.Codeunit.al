codeunit 6060113 "NPR TM Ticket DIY Ticket Print"
{
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

    var
        GEN_NOT_ISSUE: Label 'There was a problem creating the notification entry.';

    /// <summary>
    /// 
    /// </summary>
    /// <param name="TicketNo"></param>
    /// <returns></returns>
    procedure CheckPublishTicketUrl(TicketNo: Code[20]): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
    begin

        if (not Ticket.Get(TicketNo)) then
            exit(false);

        TicketBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBOM.SetFilter("Publish Ticket URL", '>=%1', TicketBOM."Publish Ticket URL"::PUBLISH);
        exit(not TicketBOM.IsEmpty);
    end;

    procedure PublishTicketUrl(TicketNo: Code[20]; var ResponseMessage: Text): Boolean
    var
        Ticket: Record "NPR TM Ticket";
    begin

        if (not Ticket.Get(TicketNo)) then
            exit(false);

        exit(GenerateTicketPrint(Ticket."Ticket Reservation Entry No.", true, ResponseMessage));

    end;

    procedure CheckSendTicketUrl(TicketNo: Code[20]): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
    begin

        if (not Ticket.Get(TicketNo)) then
            exit(false);

        TicketBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBOM.SetFilter("Publish Ticket URL", '=%1', TicketBOM."Publish Ticket URL"::SEND);
        exit(not TicketBOM.IsEmpty);

    end;

    procedure SendTicketUrl(TicketNo: Code[20]; var ResponseMessage: Text): Boolean
    var
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
        EntryNo: Integer;
    begin

        EntryNo := NotifyParticipant.CreateDiyPrintNotification(TicketNo);
        if (EntryNo = 0) then begin
            ResponseMessage := GEN_NOT_ISSUE;
            exit(false);
        end;

        TicketNotificationEntry.SetFilter("Entry No.", '=%1', EntryNo);
        NotifyParticipant.SendGeneralNotification(TicketNotificationEntry);

        if (TicketNotificationEntry.Get(EntryNo)) then;
        ResponseMessage := TicketNotificationEntry."Failed With Message";
        exit(ResponseMessage = '');
    end;

    procedure GenerateTicketPrint(EntryNo: Integer; MarkTicketAsPrinted: Boolean; var FailReasonText: Text): Boolean
    var
        TicketRequestXml: DotNet "NPRNetXmlDocument";
        ServiceResponse: DotNet "NPRNetXmlDocument";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        ErrorCode: Code[10];
        ErrorText: Text;
    begin

        TicketReservationRequest.Get(EntryNo);
        if (TicketReservationRequest."DIY Print Order Requested") then
            exit(true);

        if (not CreatTicketPrintOrderXml(TicketRequestXml, TicketReservationRequest."Session Token ID", MarkTicketAsPrinted, FailReasonText)) then
            exit(false);

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
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
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
        Ticket: Record "NPR TM Ticket";
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        FailReason: Text;
    begin

        Ticket.Get(TicketNo);

        TicketSetup.Get();
        TicketSetup.TestField("Print Server Ticket URL");

        if (not GenerateTicketPrint(Ticket."Ticket Reservation Entry No.", true, FailReason)) then
            Error(FailReason);

        HyperLink(StrSubstNo('%1%2', TicketSetup."Print Server Ticket URL", Ticket."External Ticket No."));
        TicketReservationRequest.GET(Ticket."Ticket Reservation Entry No.");
        case TicketReservationRequest."Entry Type" of
            TicketReservationRequest."Entry Type"::PRIMARY:
                HYPERLINK(STRSUBSTNO('%1%2', TicketSetup."Print Server Ticket URL", Ticket."External Ticket No."));
            TicketReservationRequest."Entry Type"::CHANGE:
                HYPERLINK(STRSUBSTNO('%1%2-%3', TicketSetup."Print Server Ticket URL", Ticket."External Ticket No.", Ticket."Ticket Reservation Entry No."));
        end;
    end;

    procedure ValidateSetup(): Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        if (not TicketSetup.Get()) then
            exit(false);

        if ((TicketSetup."Print Server Generator URL" = '') or
            (TicketSetup."Print Server Gen. Username" = '') or
            (TicketSetup."Print Server Gen. Password" = '')) then
            exit(false);

        exit(true);
    end;

    local procedure WebServiceApi(var ReasonText: Text; var XmlDocIn: DotNet "NPRNetXmlDocument"; var XmlDocOut: DotNet "NPRNetXmlDocument"): Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Credential: DotNet NPRNetNetworkCredential;
        Convert: DotNet NPRNetConvert;
        B64Credential: Text[200];
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        WebException: DotNet NPRNetWebException;
        WebInnerException: DotNet NPRNetWebException;
        Url: Text;
        ErrorMessage: Text;
        ResponseText: Text;
        Exception: DotNet NPRNetException;
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

        HttpWebRequest.Timeout := 10000;
        if (TicketSetup."Timeout (ms)" > 0) then
            HttpWebRequest.Timeout := TicketSetup."Timeout (ms)";

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
    local procedure TrySendWebRequest(var XmlDoc: DotNet "NPRNetXmlDocument"; HttpWebRequest: DotNet NPRNetHttpWebRequest; var HttpWebResponse: DotNet NPRNetHttpWebResponse)
    var
        MemoryStream: DotNet NPRNetMemoryStream;
    begin

        MemoryStream := HttpWebRequest.GetRequestStream;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    [TryFunction]
    local procedure TryReadResponseText(var HttpWebResponse: DotNet NPRNetHttpWebResponse; var ResponseText: Text)
    var
        Stream: DotNet NPRNetStream;
        StreamReader: DotNet NPRNetStreamReader;
    begin

        StreamReader := StreamReader.StreamReader(HttpWebResponse.GetResponseStream());
        ResponseText := StreamReader.ReadToEnd;
        StreamReader.Close;
        Clear(StreamReader);
    end;

    [TryFunction]
    local procedure TryReadExceptionResponseText(var WebException: DotNet NPRNetWebException; var StatusCode: Code[10]; var StatusDescription: Text; var ResponseXml: Text)
    var
        Stream: DotNet NPRNetStream;
        StreamReader: DotNet NPRNetStreamReader;
        WebResponse: DotNet NPRNetWebResponse;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        WebExceptionStatus: DotNet NPRNetWebExceptionStatus;
        SystemConvert: DotNet NPRNetConvert;
        StatusCodeInt: Integer;
        DotNetType: DotNet NPRNetType;
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
                exit;
        end;

        StreamReader := StreamReader.StreamReader(WebException.Response().GetResponseStream());
        ResponseXml := StreamReader.ReadToEnd;
        StreamReader.Close;
        Clear(StreamReader);
    end;

    local procedure ToBase64(StringToEncode: Text) B64String: Text
    var
        TempBlob: Codeunit "Temp Blob";
        BinaryReader: DotNet NPRNetBinaryReader;
        MemoryStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
        InStr: InStream;
        Outstr: OutStream;
    begin

        Clear(TempBlob);
        TempBlob.CreateOutStream(Outstr);
        Outstr.WriteText(StringToEncode);

        TempBlob.CreateInStream(InStr);
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

    local procedure CreatTicketPrintOrderXml(var XmlDoc: DotNet "NPRNetXmlDocument"; var Token: Text[100]; MarkTicketAsPrinted: Boolean; var FailureReason: Text): Boolean
    var
        XmlText: Text;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        TicketTicketServerRequest: XMLport "NPR TM Ticket Server Req.";
        InStr: InStream;
    begin
        TempBlob.CreateOutStream(OutStr, TEXTENCODING::UTF8);

        if (not TicketTicketServerRequest.SetRequestEntryNo(Token, MarkTicketAsPrinted, FailureReason)) then
            exit(false);

        TicketTicketServerRequest.SetDestination(OutStr);
        TicketTicketServerRequest.Export;

        if (not TempBlob.HasValue()) then
            Error('XML generation failed for token %1', Token);

        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF8);
        InStr.Read(XmlText);

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(XmlText);

        if (UserId = 'TSA') then Message(CopyStr(XmlText, 1, 1024));

        exit(true);
    end;

    local procedure WebExceptionResponse(var XmlDoc: DotNet "NPRNetXmlDocument"; var ErrorCode: Code[10]; var ErrorText: Text): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
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

