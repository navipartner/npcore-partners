codeunit 6060116 "NPR TM Ticket WebService Mgr"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: XmlDocument;
        FunctionName: Text[100];
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin

        Commit();
        TicketRequestManager.LockResources();

        if (Rec.LoadXmlDoc(XmlDoc)) then begin
            FunctionName := GetWebServiceFunction(Rec."Import Type");
            case FunctionName of
                'MakeTicketReservation':
                    ImportTicketReservations(XmlDoc, Rec."Entry No.", Rec."Document ID");
                'ReserveConfirmArrive':
                    ImportTicketReservationConfirmArriveDoc(XmlDoc, Rec."Entry No.", Rec."Document ID");
                'PreConfirmReservation':
                    ImportTicketPreConfirmation(XmlDoc, Rec."Entry No.", Rec."Document ID");
                'CancelReservation':
                    ImportTicketCancellation(XmlDoc, Rec."Entry No.", Rec."Document ID");
                'ConfirmReservation':
                    ImportTicketConfirmation(XmlDoc, Rec."Entry No.", Rec."Document ID");

                'SetAttributes':
                    ImportTicketAttributes(XmlDoc, Rec."Entry No.", Rec."Document ID");

                'GetTicketChangeRequest':
                    ImportTicketChangeRequest(XmlDoc, Rec."Entry No.", Rec."Document ID");
                'ConfirmTicketChangeRequest':
                    ImportTicketConfirmChangeRequest(XmlDoc, Rec."Entry No.", Rec."Document ID");
                else
                    Error(MISSING_CASE, Rec."Import Type", FunctionName);
            end;
        end;

        Commit();
    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Initialized: Boolean;
        TOKEN_INCORRECT_STATE: Label 'The token %1 can''t be changed when in the %1 state.';
        MISSING_CASE: Label 'No handler for %1 [%2].';
        MUST_BE_POSITIVE: Label 'Quantity must be positive.';

    local procedure ImportTicketReservations(Document: XmlDocument; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketWaitingListMgr: Codeunit "NPR TM Ticket WaitingList Mgr.";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Reservation: XmlElement;
        Node: XmlNode;
        TicketAdmissionNodeList: XmlNodeList;
        ReservationNodeList: XmlNodeList;
        NTicketAdmission: Integer;
        NReservation: Integer;
        Token: Text[100];
        TicketCreated: Boolean;
    begin

        TicketRequestManager.ExpireReservationRequests();

        if (not Document.GetRoot(Reservation)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(Reservation.AsXmlNode(), 'reserve_tickets', ReservationNodeList)) then
            exit;

        for NReservation := 1 to ReservationNodeList.Count() do begin
            ReservationNodeList.Get(NReservation, Node);
            Token := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Node.AsXmlElement(), 'token', false), 1, MaxStrLen(Token));
            if (Token = '') then
                Token := DocumentID;

            if (TicketRequestManager.TokenRequestExists(Token)) then
                TicketRequestManager.DeleteReservationRequest(Token, true);

            if (not NpXmlDomMgt.FindNodes(Node, 'ticket', TicketAdmissionNodeList)) then
                exit;

            for NTicketAdmission := 1 to TicketAdmissionNodeList.Count() do begin
                TicketAdmissionNodeList.Get(NTicketAdmission, Node);
                ImportTicketReservation(Node.AsXmlElement(), Token, DocumentID);
            end;
        end;

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);

        if (TicketReservationRequest.FindSet(true, false)) then begin
            TicketCreated := true;
            repeat
                CreateResponse(TicketReservationRequest, TicketReservationResponse);

                if (ValidTicketRequest(TicketReservationRequest, TicketReservationResponse)) then begin

                    if (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::WAITINGLIST) then begin
                        TicketWaitingListMgr.CreateWaitingListEntry(TicketReservationRequest, TicketReservationRequest."Notification Address");
                    end else begin
                        TicketCreated := TicketCreated and CreateTicket(TicketReservationRequest, TicketReservationResponse);
                    end;

                end else begin
                    TicketCreated := false;
                end;

            until ((TicketReservationRequest.Next() = 0));
        end;

        if (not TicketCreated) then
            TicketRequestManager.DeleteReservationRequest(Token, false);
    end;

    local procedure ImportTicketReservation(Element: XmlElement; Token: Text[100]; DocumentID: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.Init();
        InsertTicketReservation(Element, Token, TicketReservationRequest);

        exit(true);
    end;

    local procedure ImportTicketPreConfirmation(Document: XmlDocument; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        Reservation: XmlElement;
        ReservationNodeList: XmlNodeList;
        Node: XmlNode;
        NReservation: Integer;
        Token: Text[100];
    begin

        if (not Document.GetRoot(Reservation)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(Reservation.AsXmlNode(), 'ticket_tokens', ReservationNodeList)) then
            exit;

        for NReservation := 1 to ReservationNodeList.Count() do begin
            ReservationNodeList.Get(NReservation, Node);
            Reservation := Node.AsXmlElement();

            Token := NpXmlDomMgt.GetXmlText(Reservation, 'ticket_token', MaxStrLen(Token), true);
            PreConfirmReservationRequest(Token);
        end;
    end;


    local procedure PreConfirmReservationRequest(Token: Text[100])
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketCreated: Boolean;
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::REGISTERED);

        if (TicketReservationRequest.FindSet(true, false)) then begin
            TicketReservationRequest.ModifyAll("Expires Date Time", CurrentDateTime() + 1500 * 1000);
            exit;
        end;

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::EXPIRED);
        if (TicketReservationRequest.FindSet()) then begin
            TicketCreated := true;
            repeat
                CreateResponse(TicketReservationRequest, TicketReservationResponse);

                if (ValidTicketRequest(TicketReservationRequest, TicketReservationResponse)) then begin
                    TicketCreated := TicketCreated and CreateTicket(TicketReservationRequest, TicketReservationResponse);

                end else begin
                    TicketCreated := false;
                end;
            until (TicketReservationRequest.Next() = 0);

            if (not TicketCreated) then
                TicketRequestManager.DeleteReservationRequest(Token, false);

            exit;
        end;

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            CreateResponse(TicketReservationRequest, TicketReservationResponse);
            TicketReservationResponse."Response Message" := StrSubstNo(TOKEN_INCORRECT_STATE, Token, TicketReservationRequest."Request Status");
            TicketReservationResponse.Status := false;
            TicketReservationResponse.Modify();
        end;
    end;

    local procedure ImportTicketConfirmation(Document: XmlDocument; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Reservation: XmlElement;
        ReservationNodeList: XmlNodeList;
        Node: XmlNode;
        NReservation: Integer;
        Token: Text[100];
        ResponseMessage: Text;
    begin

        if (not Document.GetRoot(Reservation)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(Reservation.AsXmlNode(), 'ticket_tokens', ReservationNodeList)) then
            exit;

        for NReservation := 1 to ReservationNodeList.Count() do begin
            ReservationNodeList.Get(NReservation, Node);
            Reservation := Node.AsXmlElement();

            Token := NpXmlDomMgt.GetXmlText(Reservation, 'ticket_token', MaxStrLen(Token), true);
            TicketRequestManager.SetReservationRequestExtraInfo(Token,
              NpXmlDomMgt.GetXmlText(Reservation, 'send_notification_to', 80, false),
              NpXmlDomMgt.GetXmlText(Reservation, 'external_order_no', 80, false));

            // Response is updated with a soft fail message if confirm fails.
            TicketRequestManager.ConfirmReservationRequest(Token, ResponseMessage);

        end;
    end;

    local procedure ImportTicketCancellation(Document: XmlDocument; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Reservation: XmlElement;
        ReservationNodeList: XmlNodeList;
        Node: XmlNode;
        NReservation: Integer;
        Token: Text[100];
    begin

        if (not Document.GetRoot(Reservation)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(Reservation.AsXmlNode(), 'ticket_tokens', ReservationNodeList)) then
            exit;

        for NReservation := 1 to ReservationNodeList.Count() do begin
            ReservationNodeList.Get(NReservation, Node);
            Reservation := Node.AsXmlElement();

            Token := NpXmlDomMgt.GetXmlText(Reservation, 'ticket_token', MaxStrLen(Token), true);
            TicketRequestManager.DeleteReservationTokenRequest(Token);
        end;

    end;

    local procedure ImportTicketReservationConfirmArriveDoc(Document: XmlDocument; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationResponse2: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        TicketAttemptCreate: Codeunit "NPR Ticket Attempt Create";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketCreated: Boolean;

        NTicket: Integer;
        ResponseMessage: Text;
        ReusedToken: Text;
        Token: Text[100];

        TicketRequestElement: XmlElement;
        TicketNode: XmlNode;
        TicketNodeList: XmlNodeList;
    begin

        TicketRequestManager.ExpireReservationRequests();

        if (not Document.GetRoot(TicketRequestElement)) then
            exit;

        Token := DocumentID;

        if (TicketRequestManager.TokenRequestExists(Token)) then
            TicketRequestManager.DeleteReservationRequest(Token, true);

        if (not NpXmlDomMgt.FindNodes(TicketRequestElement.AsXmlNode(), 'ticket', TicketNodeList)) then
            exit;

        for NTicket := 1 to TicketNodeList.Count() do begin
            TicketNodeList.Get(NTicket, TicketNode);
            InsertTemporaryTicketReservation(TicketNode.AsXmlElement(), Token, TmpTicketReservationRequest);
        end;

        TmpTicketReservationRequest.Reset();
        if (TmpTicketReservationRequest.IsEmpty()) then
            Error('Houston, we have a problem! 6060116.CreateTicketRequest() said ok, but token %1 was not found.', Token);

        // pre-check member guest
        MemberTicketManager.PreValidateMemberGuestTicketRequest(TmpTicketReservationRequest, true);

        Commit();
        if (TicketAttemptCreate.AttemptValidateRequestForTicketReuse(TmpTicketReservationRequest, ReusedToken, ResponseMessage)) then begin
            // duplicate the previous response so SOAP Service gets a valid response
            TicketReservationResponse.SetFilter("Session Token ID", '=%1', ReusedToken);
            if (TicketReservationResponse.FindSet()) then begin
                repeat
                    TicketReservationResponse2.TransferFields(TicketReservationResponse, false);
                    TicketReservationResponse2."Entry No." := 0;
                    TicketReservationResponse2."Session Token ID" := Token;
                    TicketReservationResponse2.Insert();

                until (TicketReservationResponse.Next() = 0);

            end;
            exit;
        end;

        // Make new tickets
        TmpTicketReservationRequest.Reset();
        TmpTicketReservationRequest.FindSet();
        repeat
            TicketReservationRequest.TransferFields(TmpTicketReservationRequest, false);
            TicketReservationRequest."Entry No." := 0;
            TicketReservationRequest.Insert();
        until (TmpTicketReservationRequest.Next() = 0);

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet(true, false)) then begin
            TicketCreated := true;
            repeat
                CreateResponse(TicketReservationRequest, TicketReservationResponse);

                if (ValidTicketRequest(TicketReservationRequest, TicketReservationResponse)) then begin
                    TicketCreated := TicketCreated and CreateTicket(TicketReservationRequest, TicketReservationResponse);

                end else begin
                    TicketCreated := false;
                end;

            until ((TicketReservationRequest.Next() = 0));
        end;

        TicketRequestManager.ConfirmReservationRequestWithValidate(Token);
        TicketRequestManager.RegisterArrivalRequest(Token);
    end;

    local procedure ImportTicketAttributes(Document: XmlDocument; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        Token: Text[50];
        AdmissionCode: Code[20];
        AttributeCode: Code[20];
        AttributeValue: Text[250];
        ReservationAttributes: XmlElement;
        AttributesNode: XmlNode;
        AttributeNodeList: XmlNodeList;
        AttributeNode: XmlNode;
        NAttribute: Integer;
    begin

        if (not Document.GetRoot(ReservationAttributes)) then
            exit;

        if (not NpXmlDomMgt.FindNode(ReservationAttributes.AsXmlNode(), 'setattributes', AttributesNode)) then
            exit;

        Token := CopyStr(NpXmlDomMgt.GetXmlAttributeText(AttributesNode, 'token', true), 1, MaxStrLen(Token));

        if (not NpXmlDomMgt.FindNodes(ReservationAttributes.AsXmlNode(), 'attribute', AttributeNodeList)) then
            exit;

        // Pass one - blank Admission Code
        for NAttribute := 1 to AttributeNodeList.Count() do begin
            AttributeNodeList.Get(NAttribute, AttributeNode);

            AdmissionCode := 'not_blank';
            AdmissionCode := CopyStr(NpXmlDomMgt.GetXmlAttributeText(AttributeNode, 'admission_code', false), 1, MaxStrLen(AdmissionCode));
            AttributeCode := CopyStr(NpXmlDomMgt.GetXmlAttributeText(AttributeNode, 'attribute_code', true), 1, MaxStrLen(AttributeCode));
            AttributeValue := CopyStr(NpXmlDomMgt.GetXmlAttributeText(AttributeNode, 'attribute_value', false), 1, MaxStrLen(AttributeValue));

            if (AdmissionCode = '') then
                ApplyAttributes(Token, '', AttributeCode, AttributeValue);

        end;

        // Pass two - specific Admission Code
        for NAttribute := 1 to AttributeNodeList.Count() do begin
            AttributeNodeList.Get(NAttribute, AttributeNode);

            AdmissionCode := '';
            AdmissionCode := CopyStr(NpXmlDomMgt.GetXmlAttributeText(AttributeNode, 'admission_code', false), 1, MaxStrLen(AdmissionCode));
            AttributeCode := CopyStr(NpXmlDomMgt.GetXmlAttributeText(AttributeNode, 'attribute_code', true), 1, MaxStrLen(AttributeCode));
            AttributeValue := CopyStr(NpXmlDomMgt.GetXmlAttributeText(AttributeNode, 'attribute_value', false), 1, MaxStrLen(AttributeValue));

            if (AdmissionCode <> '') then
                ApplyAttributes(Token, AdmissionCode, AttributeCode, AttributeValue);
        end;

    end;

    local procedure ImportTicketChangeRequest(Document: XmlDocument; RequestEntryNo: Integer; DocumentID: Text[100]);
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Element: XmlElement;
        Node: XmlNode;
        TicketNumber: Code[30];
        PinCode: Code[10];
        ResponseMessage: Text;
    begin

        TicketRequestManager.ExpireReservationRequests();

        if (not Document.GetRoot(Element)) then
            exit;

        if (not NpXmlDomMgt.FindNode(Element.AsXmlNode(), 'ChangeReservation', Node)) then
            exit;

        TicketNumber := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'Request/TicketNumber', MaxStrLen(TicketNumber), true);
        PinCode := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'Request/PinCode', MaxStrLen(PinCode), true);

        if (not TicketRequestManager.CreateChangeRequest(TicketNumber, PinCode, DocumentID, ResponseMessage)) then
            Error(ResponseMessage);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', DocumentID);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindFirst();
        CreateResponse(TicketReservationRequest, TicketReservationResponse);

    end;

    local procedure ImportTicketConfirmChangeRequest(Document: XmlDocument; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketChangeRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Element: XmlElement;
        Node: XmlNode;
        AdmissionNodeList: XmlNodeList;
        AdmissionNode: XmlNode;
        NToken: Integer;
        ChangeRequestToken: Text[100];
        AdmissionCode: Code[20];
        ExtScheduleEntryOld: Integer;
        ExtScheduleEntryNew: Integer;
        WrongEntry: Label 'Schedule Entry %1 does not correspond to admission code %2.';
        InvalidEntry: Label 'Invalid schedule entry %1.';
        AlreadyConfirmed: Label 'Change request %1 has already been confirmed.';
        InvalidToken: Label 'A request for %1 and schedule entry %2 was not found for token %3';
    begin

        TicketRequestManager.ExpireReservationRequests();

        if (not Document.GetRoot(Element)) then
            exit;

        if (not NpXmlDomMgt.FindNode(Element.AsXmlNode(), 'ConfirmChangeReservation', Node)) then
            exit;

        ChangeRequestToken := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'Request/ChangeRequestToken', MaxStrLen(ChangeRequestToken), true);
        if (not TicketRequestManager.TokenRequestExists(ChangeRequestToken)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(Node, 'Request/Admissions/Admission', AdmissionNodeList)) then
            exit;

        FOR NToken := 1 TO AdmissionNodeList.Count() do begin
            AdmissionNodeList.Get(NToken, AdmissionNode);

            AdmissionCode := CopyStr(NpXmlDomMgt.GetXmlAttributeText(AdmissionNode, 'Code', true), 1, MaxStrLen(AdmissionCode));
            if (not Evaluate(ExtScheduleEntryOld, CopyStr(NpXmlDomMgt.GetXmlAttributeText(AdmissionNode, 'OldScheduleEntryNo', true), 1, 10))) then
                ExtScheduleEntryOld := 0;

            if (not Evaluate(ExtScheduleEntryNew, CopyStr(NpXmlDomMgt.GetXmlAttributeText(AdmissionNode, 'NewScheduleEntryNo', true), 1, 10))) then
                ExtScheduleEntryNew := 0;

            AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtScheduleEntryOld);
            if (not AdmissionScheduleEntry.FindFirst()) then
                Error(InvalidEntry, ExtScheduleEntryOld);

            if (AdmissionCode <> AdmissionScheduleEntry."Admission Code") then
                Error(WrongEntry, ExtScheduleEntryOld, AdmissionCode);

            AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtScheduleEntryNew);
            if (not AdmissionScheduleEntry.FindFirst()) then
                Error(InvalidEntry, ExtScheduleEntryNew);

            if (AdmissionCode <> AdmissionScheduleEntry."Admission Code") then
                Error(WrongEntry, ExtScheduleEntryNew, AdmissionCode);

            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', ChangeRequestToken);
            TicketReservationRequest.SetFilter("Admission Code", '=%1', AdmissionCode);
            TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '=%1', ExtScheduleEntryOld);
            if (TicketReservationRequest.FindFirst()) then
                if (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CONFIRMED) then
                    Error(AlreadyConfirmed, ChangeRequestToken);

            TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::REGISTERED);
            if (not TicketReservationRequest.FindFirst()) then
                Error(InvalidToken, AdmissionCode, ExtScheduleEntryOld, ChangeRequestToken);

            TicketReservationRequest."External Adm. Sch. Entry No." := ExtScheduleEntryNew;
            TicketReservationRequest.Modify();

        end;

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', DocumentID);
        TicketReservationRequest.FindFirst();

        // Shift admission from old schedule entry to new
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Superseeds Entry No.");
        if (Ticket.FindSet()) then begin
            repeat
                TicketChangeRequest.SetFilter("Session Token ID", '=%1', DocumentID);
                TicketChangeRequest.FindSet();
                repeat
                    TicketManagement.RescheduleTicketAdmission(Ticket."No.", TicketChangeRequest."External Adm. Sch. Entry No.", true, TicketChangeRequest."Request Status Date Time");
                until (TicketChangeRequest.NEXT() = 0);
            until (Ticket.NEXT() = 0);

            // Relink tickets to this request
            Ticket.ModifyALL("Ticket Reservation Entry No.", TicketReservationRequest."Entry No.", false);
        end;

        TicketRequestManager.ConfirmChangeRequest(DocumentID);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', DocumentID);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindFirst();

        if (CreateResponse(TicketReservationRequest, TicketReservationResponse)) then begin
            TicketReservationResponse.Confirmed := true;
            TicketReservationResponse.Modify();
        end;
    end;

    // ******************* Database Operations ()

    local procedure CreateResponse(var TicketReservationRequest: Record "NPR TM Ticket Reservation Req."; var TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp."): Boolean
    var
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
    begin

        // One response per external line ref
        TicketReservationRequest2.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest2.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
        if (not TicketReservationRequest2.FindFirst()) then
            exit(false);

        TicketReservationResponse.Reset();
        TicketReservationResponse.SetCurrentKey("Request Entry No.");
        TicketReservationResponse.SetFilter("Request Entry No.", '=%1', TicketReservationRequest2."Entry No.");
        if (not TicketReservationResponse.FindFirst()) then begin
            TicketReservationResponse.Init();
            TicketReservationResponse."Entry No." := 0;
            TicketReservationResponse."Request Entry No." := TicketReservationRequest2."Entry No.";
            TicketReservationResponse."Session Token ID" := TicketReservationRequest."Session Token ID";
            TicketReservationResponse."Exires (Seconds)" := 1500;
            TicketReservationResponse.Status := true;
            TicketReservationResponse.Confirmed := false;
            TicketReservationResponse.Insert();
        end;

        exit(true);
    end;

    local procedure CreateTicket(var TicketReservationRequest: Record "NPR TM Ticket Reservation Req."; var TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp."): Boolean
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketAttemptAction: Codeunit "NPR Ticket Attempt Create";
        ResponseMessage: Text;
    begin

        TicketReservationRequest."Expires Date Time" := CurrentDateTime() + TicketReservationResponse."Exires (Seconds)" * 1000;
        TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::REGISTERED;
        TicketReservationRequest.Modify();

        // commit is required when/if IssueTicket throws an error, or the reservation and response will be rolled back as well
        Commit();

        if (not TicketAttemptAction.AttemptIssueTicketFromReservation(TicketReservationRequest, ResponseMessage)) then begin
            TicketReservationResponse."Response Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketReservationResponse."Response Message"));
            TicketRequestManager.DeleteReservationRequest(TicketReservationRequest."Session Token ID", false);
            TicketReservationResponse.Status := false;
        end else begin
            TicketReservationResponse.Status := true;
        end;

        TicketReservationResponse.Modify();
        exit(TicketReservationResponse.Status);
    end;

    local procedure ValidTicketRequest(var TicketReservationRequest: Record "NPR TM Ticket Reservation Req."; var TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp."): Boolean
    var
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        Admission: Record "NPR TM Admission";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ExternalItemType: Integer;
        InvalidAdmissionCode: Label 'Admission Code [%1] is not a valid admission code.';
        InvalidItem: Label 'External Item [%1] does not resolve to an internal item.';
        InvalidRequest: Label 'Ambiguous ticket request, multiple references for %1 line %2';
    begin

        if (TicketReservationRequest.Quantity <= 0) then begin
            TicketReservationResponse."Response Message" := StrSubstNo(MUST_BE_POSITIVE);
            TicketReservationResponse.Status := false;
        end;

        if (TicketReservationRequest."Admission Code" <> '') then begin
            if (not Admission.Get(TicketReservationRequest."Admission Code")) then begin
                TicketReservationResponse."Response Message" := StrSubstNo(InvalidAdmissionCode, TicketReservationRequest."Admission Code");
                TicketReservationResponse.Status := false;
            end;
        end;

        //if (not TicketRequestManager.TranslateBarcodeToItemVariant (TicketReservationRequest."External Item Code", ItemNo, VariantCode, ExternalItemType)) then begin
        if (not TicketRequestManager.TranslateBarcodeToItemVariant(TicketReservationRequest."External Item Code", TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", ExternalItemType)) then begin

            TicketReservationResponse."Response Message" := StrSubstNo(InvalidItem, TicketReservationRequest."External Item Code");
            TicketReservationResponse.Status := false;
        end;

        TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest2.SetFilter("Entry No.", '<>%1', TicketReservationRequest."Entry No.");
        TicketReservationRequest2.SetFilter("External Item Code", '=%1', TicketReservationRequest."External Item Code");
        TicketReservationRequest2.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
        TicketReservationRequest2.SetFilter("Admission Code", '=%1|=%2', '', TicketReservationRequest."Admission Code");

        if (not TicketReservationRequest2.IsEmpty()) then begin
            TicketReservationResponse."Response Message" := StrSubstNo(InvalidRequest,
              TicketReservationRequest."External Item Code", TicketReservationRequest."Ext. Line Reference No.");
            TicketReservationResponse.Status := false;
        end;

        TicketReservationResponse.Modify();
        exit(TicketReservationResponse.Status);
    end;

    local procedure InsertTicketReservation(Element: XmlElement; Token: Text[100]; var TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ExternalItemType: Integer;
        WaitingListOptInAddress: Text[200];
    begin

        Initialize;

        Clear(TicketReservationRequest);
        TicketReservationRequest."Session Token ID" := Token;
        TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::WIP;
        TicketReservationRequest."Created Date Time" := CurrentDateTime();

        TicketReservationRequest."External Item Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'external_id', true), 1, MaxStrLen(TicketReservationRequest."External Item Code"));

        TicketRequestManager.TranslateBarcodeToItemVariant(TicketReservationRequest."External Item Code", TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", ExternalItemType);

        Evaluate(TicketReservationRequest.Quantity, NpXmlDomMgt.GetXmlAttributeText(Element, 'qty', true));
        Evaluate(TicketReservationRequest."Ext. Line Reference No.", NpXmlDomMgt.GetXmlAttributeText(Element, 'line_no', true));
        TicketReservationRequest."External Member No." := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'member_number', false), 1, MaxStrLen(TicketReservationRequest."External Member No."));
        TicketReservationRequest."Admission Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'admission_code', false), 1, MaxStrLen(TicketReservationRequest."Admission Code"));

        Evaluate(TicketReservationRequest."External Adm. Sch. Entry No.", NpXmlDomMgt.GetXmlAttributeText(Element, 'admission_schedule_entry', false));

        TicketReservationRequest."Waiting List Reference Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'waitinglist_reference_code', false), 1, MaxStrLen(TicketReservationRequest."Waiting List Reference Code"));
        WaitingListOptInAddress := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'waitinglist_opt-in_address', false), 1, MaxStrLen(WaitingListOptInAddress));
        if (WaitingListOptInAddress <> '') then begin
            TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::WAITINGLIST;
            TicketReservationRequest."Notification Address" := WaitingListOptInAddress;
        end;

        TicketReservationRequest.Insert();
    end;

    local procedure InsertTemporaryTicketReservation(TicketElement: XmlElement; Token: Text[100]; var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary)
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ExternalItemType: Integer;
    begin

        Initialize;

        TmpTicketReservationRequest.Init();
        TmpTicketReservationRequest."Entry No." := TmpTicketReservationRequest.Count() + 1;
        TmpTicketReservationRequest."Session Token ID" := Token;
        TmpTicketReservationRequest."Request Status" := TmpTicketReservationRequest."Request Status"::WIP;
        TmpTicketReservationRequest."Created Date Time" := CurrentDateTime();

        TmpTicketReservationRequest."External Item Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(TicketElement, 'external_id', true), 1, MaxStrLen(TmpTicketReservationRequest."External Item Code"));

        TicketRequestManager.TranslateBarcodeToItemVariant(TmpTicketReservationRequest."External Item Code", TmpTicketReservationRequest."Item No.", TmpTicketReservationRequest."Variant Code", ExternalItemType);

        Evaluate(TmpTicketReservationRequest.Quantity, NpXmlDomMgt.GetXmlAttributeText(TicketElement, 'qty', true));
        Evaluate(TmpTicketReservationRequest."Ext. Line Reference No.", NpXmlDomMgt.GetXmlAttributeText(TicketElement, 'line_no', true));
        TmpTicketReservationRequest."External Member No." := CopyStr(NpXmlDomMgt.GetXmlAttributeText(TicketElement, 'member_number', false), 1, MaxStrLen(TmpTicketReservationRequest."External Member No."));
        TmpTicketReservationRequest."Admission Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(TicketElement, 'admission_code', false), 1, MaxStrLen(TmpTicketReservationRequest."Admission Code"));

        Evaluate(TmpTicketReservationRequest."External Adm. Sch. Entry No.", NpXmlDomMgt.GetXmlAttributeText(TicketElement, 'admission_schedule_entry', false));

        TmpTicketReservationRequest.Insert();

    end;

    local procedure ApplyAttributes(Token: Text[50]; AdmissionCode: Code[20]; AttributeCode: Code[20]; AttributeValue: Text)
    var
        NPRAttribute: Record "NPR Attribute";
        NPRAttributeID: Record "NPR Attribute ID";
        Admission: Record "NPR TM Admission";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TableId: Integer;
        NPRAttributeManagement: Codeunit "NPR Attribute Management";
        InvalidAttributeCode: Label 'Attribute %1 is not valid.';
        InvalidAttribute: Label 'Attribute %1 is not defined for table with id %2.';
        InvalidAdmissionCode: Label 'The admission code %1 is not valid.';
        NotFound: Label 'No reservation request found using filter %1.';
    begin

        TableId := DATABASE::"NPR TM Ticket Reservation Req.";

        if (not NPRAttribute.Get(AttributeCode)) then
            Error(InvalidAttributeCode, AttributeCode);

        if (not NPRAttributeID.Get(TableId, AttributeCode)) then
            Error(InvalidAttribute, AttributeCode, TableId);

        if (AdmissionCode <> '') then
            if (not Admission.Get(AdmissionCode)) then
                Error(InvalidAdmissionCode, AdmissionCode);

        // update the request
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (AdmissionCode <> '') then
            TicketReservationRequest.SetFilter("Admission Code", '=%1', AdmissionCode);

        if (TicketReservationRequest.IsEmpty()) then
            Error(NotFound, TicketReservationRequest.GetFilters());

        TicketReservationRequest.FindSet(false, false);
        repeat
            NPRAttributeManagement.SetEntryAttributeValue(TableId, NPRAttributeID."Shortcut Attribute ID", TicketReservationRequest."Entry No.", AttributeValue);
        until (TicketReservationRequest.Next() = 0);
    end;

    local procedure "--Utils"()
    begin
    end;

    procedure Initialize()
    begin

        if (not Initialized) then begin
            Initialized := true;
        end;
    end;

    local procedure GetWebServiceFunction(ImportTypeCode: Code[20]): Text[100]
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetFilter(Code, '=%1', ImportTypeCode);
        if (ImportType.FindFirst()) then;

        exit(ImportType."Webservice Function");
    end;
}

