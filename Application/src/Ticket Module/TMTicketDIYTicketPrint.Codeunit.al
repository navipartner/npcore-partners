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

    procedure CheckPublishTicketUrl(TicketNo: Code[20]): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
    begin

        if (not Ticket.Get(TicketNo)) then
            exit(false);

        TicketBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBOM.SetFilter("Publish Ticket URL", '>=%1', TicketBOM."Publish Ticket URL"::PUBLISH);
        exit(not TicketBOM.IsEmpty());
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
        exit(not TicketBOM.IsEmpty());

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
        TicketRequestXml: XmlDocument;
        ServiceResponse: XmlDocument;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        ErrorCode: Code[10];
        ErrorText: Text;
        FailReasonLbl: Label 'TicketServer: [%1] %2';
    begin

        TicketReservationRequest.Get(EntryNo);
        if (TicketReservationRequest."DIY Print Order Requested") then
            exit(true);

        if (not CreateTicketPrintOrderXml(TicketRequestXml, TicketReservationRequest."Session Token ID", MarkTicketAsPrinted, FailReasonText)) then begin
            //FailReasonText := GetLastErrorText();
            exit(false);
        end;


        if (WebServiceApi(TicketRequestXml, ServiceResponse)) then begin
            FailReasonText := '';
            TicketReservationRequest."DIY Print Order At" := CurrentDateTime;
            TicketReservationRequest."DIY Print Order Requested" := true;
            TicketReservationRequest.Modify();
            exit(true);
        end;

#if DEBUG_TICKET
        message(GetLastErrorText());
#endif

        // Examine fault code - might have been produced already
        if (WebExceptionResponse(ServiceResponse, ErrorCode, ErrorText)) then begin
            FailReasonText := StrSubstNo(FailReasonLbl, ErrorCode, ErrorText);

            if ((StrPos(ErrorText, 'Bad Request: Ticket ') > 0) and (StrPos(ErrorText, ' already exists.') > 0)) then begin
                TicketReservationRequest."DIY Print Order At" := CurrentDateTime;
                TicketReservationRequest."DIY Print Order Requested" := true;
                TicketReservationRequest.Modify();
                exit(true);
            end;
        end;

        FailReasonText := ErrorText;
        exit(false);
    end;

    procedure ViewOnlineTicketOrder(RequestEntryNo: Integer)
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        FailReason: Text;
        TicketOrderLbl: Label '%1%2', Locked = true;
    begin

        TicketReservationRequest.Get(RequestEntryNo);

        TicketSetup.Get();
        TicketSetup.TestField("Print Server Order URL");

        if (not GenerateTicketPrint(RequestEntryNo, true, FailReason)) then
            Error(FailReason);

        HyperLink(StrSubstNo(TicketOrderLbl, TicketSetup."Print Server Order URL", TicketReservationRequest."Session Token ID"));
    end;

    procedure ViewOnlineSingleTicket(TicketNo: Code[20])
    var
        Ticket: Record "NPR TM Ticket";
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        FailReason: Text;
        HpyperLinkLbl: Label '%1%2', Locked = true;
        HpyperLink2Lbl: Label '%1%2-%3', Locked = true;
    begin

        Ticket.Get(TicketNo);

        TicketSetup.Get();
        TicketSetup.TestField("Print Server Ticket URL");

        if (not GenerateTicketPrint(Ticket."Ticket Reservation Entry No.", true, FailReason)) then
            Error(FailReason);

        HyperLink(StrSubstNo(HpyperLinkLbl, TicketSetup."Print Server Ticket URL", Ticket."External Ticket No."));
        TicketReservationRequest.GET(Ticket."Ticket Reservation Entry No.");
        case TicketReservationRequest."Entry Type" of
            TicketReservationRequest."Entry Type"::PRIMARY:
                HYPERLINK(STRSUBSTNO(HpyperLinkLbl, TicketSetup."Print Server Ticket URL", Ticket."External Ticket No."));
            TicketReservationRequest."Entry Type"::CHANGE:
                HYPERLINK(STRSUBSTNO(HpyperLink2Lbl, TicketSetup."Print Server Ticket URL", Ticket."External Ticket No.", Ticket."Ticket Reservation Entry No."));
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

    [TryFunction]
    local procedure WebServiceApi(XmlIn: XmlDocument; var XmlOut: XmlDocument)
    var

        TicketSetup: Record "NPR TM Ticket Setup";

        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Base64Convert: Codeunit "Base64 Convert";
        RequestText: Text;
        ResponseText: Text;
        Username: Text;
        Password: Text;
        B64Credential: Text;
        Url: Text;
        RequestMethodTok: Label 'POST', Locked = true;
        UserAgentTok: Label 'User-Agent', Locked = true;
        UserAgentTxt: Label 'NP Dynamics Retail / Dynamics 365 Business Central', Locked = true;
        ContentTypeTok: Label 'Content-Type', Locked = true;
        ContentTypeTxt: Label 'navision/xml', Locked = true;
        AuthorizationTok: Label 'Authorization', Locked = true;
        UnexpectedResponseCodeErr: Label 'Ticket service did not return with a HTTP 200 return code (return code was: %1)';
        InvalidXmlErr: Label 'Ticket server did not respond with a valid XML document: (response was %1)';
        XmlErrorTxt: Label '<response><error><code>%1</code><message>%2 - %3</message></error></response>', Locked = true;
        AuthLbl: Label '%1:%2', Locked = true;
        BasicLbl: Label 'Basic %1', Locked = true;
    begin

        if (not TicketSetup.Get()) then
            exit(false);

        Url := TicketSetup."Print Server Generator URL";
        UserName := TicketSetup."Print Server Gen. Username";
        Password := TicketSetup."Print Server Gen. Password";
        B64Credential := Base64Convert.ToBase64(StrSubstNo(AuthLbl, UserName, Password));

        XmlIn.WriteTo(RequestText);
        Content.WriteFrom(RequestText);
        Content.GetHeaders(ContentHeaders);
        if (ContentHeaders.Contains(ContentTypeTok)) then
            ContentHeaders.Remove(ContentTypeTok);
        ContentHeaders.Add(ContentTypeTok, ContentTypeTxt);

        Request.Method := RequestMethodTok;
        Request.SetRequestUri(Url);
        Request.Content(Content);

        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Clear();
        RequestHeaders.Add(UserAgentTok, UserAgentTxt);
        RequestHeaders.Add(AuthorizationTok, StrSubstNo(BasicLbl, B64Credential));

        Client.Timeout := 10000;
        if (TicketSetup."Timeout (ms)" > 0) then
            Client.Timeout := TicketSetup."Timeout (ms)";

        if (Client.Send(Request, Response)) then begin

            case Response.HttpStatusCode() of
                200:
                    begin
                        Response.Content.ReadAs(ResponseText);
                        if (not XmlDocument.ReadFrom(ResponseText, XmlOut)) then
                            Error(InvalidXmlErr, ResponseText);
                        exit;
                    end;
                403:
                    begin
                        // Depending on message in 403 response, it could indicate already created -> success
                        Response.Content.ReadAs(ResponseText);
                        if (not XmlDocument.ReadFrom(ResponseText, XmlOut)) then
                            Error(InvalidXmlErr, ResponseText);
                        Error(UnexpectedResponseCodeErr, Response.HttpStatusCode)
                    end;
                else begin
                        if (not Response.Content.ReadAs(ResponseText)) then
                            ResponseText := StrSubstNo(XmlErrorTxt, Response.HttpStatusCode(), RequestText, Url);
                    end;
            end
        end else
            ResponseText := StrSubstNo(XmlErrorTxt, '990', GetLastErrorText(), Url);

        if (not XmlDocument.ReadFrom(ResponseText, XmlOut)) then
            Error(InvalidXmlErr, ResponseText);

        Error(ResponseText);
    end;

    local procedure CreateTicketPrintOrderXml(var XmlDoc: XmlDocument; Token: Text[100]; MarkTicketAsPrinted: Boolean; var FailureReason: Text): Boolean
    var
        XmlString: Text;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        TicketTicketServerRequest: XMLport "NPR TM Ticket Server Req.";
        InStr: InStream;
        TicketRequestMessageFailure: Label 'XML generation failed for token %1';
    begin
        TempBlob.CreateOutStream(OutStr, TEXTENCODING::UTF8);

        if (not TicketTicketServerRequest.SetRequestEntryNo(Token, MarkTicketAsPrinted, FailureReason)) then
            exit(false);

        TicketTicketServerRequest.SetDestination(OutStr);
        TicketTicketServerRequest.Export();

        if (not TempBlob.HasValue()) then
            Error(TicketRequestMessageFailure, Token);

        TempBlob.CreateInStream(InStr, TEXTENCODING::UTF8);
        InStr.Read(XmlString);

        Clear(XmlDoc);

        XmlDocument.ReadFrom(XmlString, XmlDoc);

#if DEBUG_TICKET
        Message(XmlString);
#endif

        exit(true);
    end;

    local procedure WebExceptionResponse(var XmlDoc: XmlDocument; var ErrorCode: Code[10]; var ErrorText: Text): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlRoot: XmlElement;
        CodePath: Label '//response/error/code', Locked = true;
        MessagePath: Label '//response/error/message', Locked = true;
    begin

        if (not XmlDoc.GetRoot(XmlRoot)) then begin
            ErrorCode := '998';
            ErrorText := GetLastErrorText();
            exit(false);
        end;

        ErrorCode := CopyStr(NpXmlDomMgt.GetXmlText(XmlRoot, CodePath, 10, false), 1, MaxStrLen(ErrorCode));
        if (ErrorCode = '') then
            ErrorCode := '999';

        ErrorText := NpXmlDomMgt.GetXmlText(XmlRoot, MessagePath, 0, false);
        if (ErrorText = '') then
            ErrorText := GetLastErrorText();

        exit(true);
    end;

}

