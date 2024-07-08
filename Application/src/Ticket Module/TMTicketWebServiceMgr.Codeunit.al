﻿codeunit 6060116 "NPR TM Ticket WebService Mgr" implements "NPR Nc Import List IProcess"
{
    Access = Internal;
    TableNo = "NPR Nc Import Entry";
    trigger OnRun()
    begin

    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        TOKEN_INCORRECT_STATE: Label 'The token %1 can''t be changed when in the %2 state.';
        MISSING_CASE: Label 'No handler for %1 [%2].';
        MUST_BE_POSITIVE: Label 'Quantity must be positive.';
        INVALID_ITEM_REFERENCE: Label 'Reference %1 does not resolve to neither an item reference nor an item number.';

    internal procedure RunProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        XmlDoc: XmlDocument;
        FunctionName: Text[100];
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        Commit();

        if (ImportEntry.LoadXmlDoc(XmlDoc)) then begin
            FunctionName := GetWebServiceFunction(ImportEntry."Import Type");
            TicketRequestManager.LockResources(FunctionName);
            case FunctionName of
                'MakeTicketReservation':
                    ImportTicketReservations(XmlDoc, ImportEntry."Document ID");
                'ReserveConfirmArrive':
                    ImportTicketReservationConfirmArriveDoc(XmlDoc, ImportEntry."Document ID");
                'PreConfirmReservation':
                    ImportTicketPreConfirmation(XmlDoc);
                'CancelReservation':
                    ImportTicketCancellation(XmlDoc);
                'ConfirmReservation':
                    ImportTicketConfirmation(XmlDoc);

                'SetAttributes':
                    ImportTicketAttributes(XmlDoc);

                'GetTicketChangeRequest':
                    ImportTicketChangeRequest(XmlDoc, ImportEntry."Document ID");
                'ConfirmTicketChangeRequest':
                    ImportTicketConfirmChangeRequest(XmlDoc, ImportEntry."Document ID");

                'RevokeTicketRequest':
                    ImportTicketRevokeRequest(XmlDoc, ImportEntry."Document ID");
                'ConfirmRevokeRequest':
                    ImportTicketConfirmRevokeRequest(XmlDoc);

                else
                    Error(MISSING_CASE, ImportEntry."Import Type", FunctionName);
            end;
        end;

        Commit();
        ClearLastError();
    end;

    local procedure ImportTicketReservations(Document: XmlDocument; DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Reservation: XmlElement;
        Node: XmlNode;
        TicketAdmissionNodeList: XmlNodeList;
        ReservationNodeList: XmlNodeList;
        NTicketAdmission: Integer;
        NReservation: Integer;
        Token: Text[100];
        Lines: List of [Integer];
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
                ImportTicketReservation(Node.AsXmlElement(), Token, Lines);
            end;
        end;

        FinalizeTicketReservation(Token, Lines);
    end;

    internal procedure FinalizeTicketReservation(Token: Text[100]; Lines: List of [Integer])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketWaitingListMgr: Codeunit "NPR TM Ticket WaitingList Mgr.";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketCreated: Boolean;
        Line: Integer;
    begin

        //Import remaining BOM lines per line no
        foreach Line in Lines do
            AddRemainingReservationRequestEntries(Token, Line);

        TicketRequestManager.AssignPrimaryReservationEntry(Token);
        TicketRequestManager.AssignListPrice(Token);

        // Process each line
        foreach Line in Lines do begin
            TicketReservationRequest.SetCurrentKey("Session Token ID", "Admission Inclusion");
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationRequest.SetRange("Ext. Line Reference No.", Line);

            if (TicketReservationRequest.FindSet(true)) then begin
                TicketCreated := false;
                repeat
                    if TicketReservationRequest."Admission Inclusion" = TicketReservationRequest."Admission Inclusion"::NOT_SELECTED then begin
                        TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::REGISTERED;
                        TicketReservationRequest.Modify();
                    end else begin

                        CreateResponse(TicketReservationRequest, TicketReservationResponse);
                        if (ValidTicketRequest(TicketReservationRequest, TicketReservationResponse)) then begin

                            if (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::WAITINGLIST) then begin
                                TicketWaitingListMgr.CreateWaitingListEntry(TicketReservationRequest, TicketReservationRequest."Notification Address");
                            end else begin
                                TicketCreated := CreateTicket(TicketReservationRequest, TicketReservationResponse);
                            end;
                        end;
                    end;

                until ((TicketReservationRequest.Next() = 0));
            end;
        end;

        if (not TicketCreated) then
            TicketRequestManager.DeleteReservationRequest(Token, false);
    end;

    local procedure ImportTicketReservation(Element: XmlElement; Token: Text[100]; var Lines: List of [Integer]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.Init();
        InsertTicketReservation(Element, Token, TicketReservationRequest);
        if (not Lines.Contains(TicketReservationRequest."Ext. Line Reference No.")) then
            Lines.add(TicketReservationRequest."Ext. Line Reference No.");
        exit(true);
    end;

    local procedure ImportTicketPreConfirmation(Document: XmlDocument)
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

            Token := GetXmlText100(Reservation, 'ticket_token', MaxStrLen(Token), true);
            PreConfirmReservationRequest(Token);
        end;
    end;

    internal procedure PreConfirmReservationRequest(Token: Text[100])
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketCreated: Boolean;
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::REGISTERED);

        if (TicketReservationRequest.FindSet(true)) then begin
            TicketReservationRequest.ModifyAll("Expires Date Time", TicketRequestManager.CalculateNewExpireTime());
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

    local procedure ImportTicketConfirmation(Document: XmlDocument)
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Reservation: XmlElement;
        ReservationNodeList: XmlNodeList;
        Node: XmlNode;
        NReservation: Integer;
        Token: Text[100];
        ResponseMessage: Text;
        ALREADY_CONFIRMED: Label 'Token %1 has already been confirmed.';
    begin

        if (not Document.GetRoot(Reservation)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(Reservation.AsXmlNode(), 'ticket_tokens', ReservationNodeList)) then
            exit;

        for NReservation := 1 to ReservationNodeList.Count() do begin
            ReservationNodeList.Get(NReservation, Node);
            Reservation := Node.AsXmlElement();

            Token := GetXmlText100(Reservation, 'ticket_token', MaxStrLen(Token), true);

            TicketReservationResponse.SetCurrentKey("Session Token ID");
            TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
            if (TicketReservationResponse.FindFirst()) then
                if (TicketReservationResponse.Confirmed) then
                    Error(ALREADY_CONFIRMED, Token);

            TicketRequestManager.SetReservationRequestExtraInfo(Token,
                GetXmlText80(Reservation, 'send_notification_to', 80, false),
                GetXmlText20(Reservation, 'external_order_no', 20, false),
                GetXmlText100(Reservation, 'ticket_holder_name', 100, false));

            // Response is updated with a soft fail message if confirm fails.
            TicketRequestManager.ConfirmReservationRequest(Token, ResponseMessage);
        end;
    end;

    local procedure ImportTicketCancellation(Document: XmlDocument)
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

            Token := GetXmlText100(Reservation, 'ticket_token', MaxStrLen(Token), true);
            TicketRequestManager.DeleteReservationTokenRequest(Token);
        end;

    end;

    local procedure ImportTicketReservationConfirmArriveDoc(Document: XmlDocument; DocumentID: Text[100])
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationResponse2: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TempTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        TicketAttemptCreate: Codeunit "NPR Ticket Attempt Create";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketCreated: Boolean;

        NTicket: Integer;
        ResponseMessage: Text;
        ReusedToken: Text[100];
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
            InsertTemporaryTicketReservation(TicketNode.AsXmlElement(), Token, TempTicketReservationRequest);
        end;

        TempTicketReservationRequest.Reset();
        if (TempTicketReservationRequest.IsEmpty()) then
            Error('Houston, we have a problem! 6060116.CreateTicketRequest() said ok, but token %1 was not found.', Token);

        // pre-check member guest
        MemberTicketManager.PreValidateMemberGuestTicketRequest(TempTicketReservationRequest, true);

        Commit();
        if (TicketAttemptCreate.AttemptValidateRequestForTicketReuse(TempTicketReservationRequest, ReusedToken, ResponseMessage)) then begin
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
        TempTicketReservationRequest.Reset();
        TempTicketReservationRequest.FindSet();
        repeat
            TicketReservationRequest.TransferFields(TempTicketReservationRequest, false);
            TicketReservationRequest."Entry No." := 0;
            TicketReservationRequest.Insert();
        until (TempTicketReservationRequest.Next() = 0);

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet(true)) then begin
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
        TicketRequestManager.RegisterArrivalRequest(Token, '');
    end;

    local procedure ImportTicketAttributes(Document: XmlDocument)
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

    local procedure ImportTicketChangeRequest(Document: XmlDocument; DocumentID: Text[100]);
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

        TicketNumber := GetXmlText30(Node.AsXmlElement(), 'Request/TicketNumber', MaxStrLen(TicketNumber), true);
        PinCode := GetXmlText10(Node.AsXmlElement(), 'Request/PinCode', MaxStrLen(PinCode), true);

        if (not TicketRequestManager.CreateChangeRequest(TicketNumber, PinCode, DocumentID, ResponseMessage)) then
            Error(ResponseMessage);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', DocumentID);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindFirst();
        CreateResponse(TicketReservationRequest, TicketReservationResponse);

    end;

    local procedure ImportTicketConfirmChangeRequest(Document: XmlDocument; DocumentID: Text[100])
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
        InvalidToken: Label 'A request for %1 and schedule entry %2 was not found for token %3.';
        InvalidChangeRequestToken: Label 'Invalid token %1.';
    begin
        TicketRequestManager.ExpireReservationRequests();

        if (not Document.GetRoot(Element)) then
            exit;

        if (not NpXmlDomMgt.FindNode(Element.AsXmlNode(), 'ConfirmChangeReservation', Node)) then
            exit;

        ChangeRequestToken := GetXmlText100(Node.AsXmlElement(), 'Request/ChangeRequestToken', MaxStrLen(ChangeRequestToken), true);
        if (not TicketRequestManager.TokenRequestExists(ChangeRequestToken)) then
            Error(InvalidChangeRequestToken, ChangeRequestToken);

        if (not NpXmlDomMgt.FindNodes(Node, 'Request/Admissions/Admission', AdmissionNodeList)) then
            exit;

        for NToken := 1 TO AdmissionNodeList.Count() do begin
            AdmissionNodeList.Get(NToken, AdmissionNode);

            AdmissionCode := CopyStr(NpXmlDomMgt.GetXmlAttributeText(AdmissionNode, 'Code', true), 1, MaxStrLen(AdmissionCode));
            if (not Evaluate(ExtScheduleEntryOld, CopyStr(NpXmlDomMgt.GetXmlAttributeText(AdmissionNode, 'OldScheduleEntryNo', true), 1, 10))) then
                ExtScheduleEntryOld := 0;

            if (not Evaluate(ExtScheduleEntryNew, CopyStr(NpXmlDomMgt.GetXmlAttributeText(AdmissionNode, 'NewScheduleEntryNo', true), 1, 10))) then
                ExtScheduleEntryNew := 0;

            AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtScheduleEntryOld);
            if (not AdmissionScheduleEntry.FindFirst()) then
                if ExtScheduleEntryOld <> -1 then
                    Error(InvalidEntry, ExtScheduleEntryOld)
                else
                    CreateAdmissionEntry(ChangeRequestToken, AdmissionCode, ExtScheduleEntryNew, AdmissionScheduleEntry);


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
            if ExtScheduleEntryOld <> -1 then
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
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindFirst();

        // Shift admission from old schedule entry to new
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Superseeds Entry No.");
        if (Ticket.FindSet()) then begin
            repeat
                TicketChangeRequest.SetFilter("Session Token ID", '=%1', DocumentID);
                TicketChangeRequest.SetFilter(Quantity, '>0');
                TicketChangeRequest.FindSet();
                repeat
                    TicketManagement.RescheduleTicketAdmission(Ticket."No.", TicketChangeRequest."External Adm. Sch. Entry No.", true, TicketChangeRequest."Request Status Date Time");
                until (TicketChangeRequest.Next() = 0);
            until (Ticket.Next() = 0);

            // Relink tickets to this request
            Ticket.ModifyALL("Ticket Reservation Entry No.", TicketReservationRequest."Entry No.", false);
        end;

        TicketRequestManager.ConfirmChangeRequest(DocumentID);

        if (CreateResponse(TicketReservationRequest, TicketReservationResponse)) then begin
            TicketReservationResponse.Confirmed := true;
            TicketReservationResponse.Modify();
        end;
    end;

    local procedure ImportTicketRevokeRequest(Document: XmlDocument; DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketManager: Codeunit "NPR TM Ticket Management";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Item: Record "Item";
        Element: XmlElement;
        Node: XmlNode;
        TicketNumber: Code[30];
        PinCode: Code[10];
        TicketAccessEntryNo: Integer;
        Amount: Decimal;
        RevokeQty: Integer;
    begin

        TicketRequestManager.ExpireReservationRequests();

        if (not Document.GetRoot(Element)) then
            exit;

        if (not NpXmlDomMgt.FindNode(Element.AsXmlNode(), 'RevokeTicketRequest', Node)) then
            exit;

        TicketNumber := GetXmlText30(Node.AsXmlElement(), 'Request/TicketNumber', MaxStrLen(TicketNumber), true);
        PinCode := GetXmlText10(Node.AsXmlElement(), 'Request/PinCode', MaxStrLen(PinCode), true);

        TicketManager.ValidateTicketReference("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, TicketNumber, '', TicketAccessEntryNo);
        TicketAccessEntry.Get(TicketAccessEntryNo);
        Ticket.Get(TicketAccessEntry."Ticket No.");

        Item.Get(Ticket."Item No.");
        Amount := Item."Unit Price";

        TicketRequestManager.WS_CreateRevokeRequest(DocumentID, Ticket."No.", PinCode, Amount, RevokeQty);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', DocumentID);
        TicketReservationRequest.FindFirst();

        CreateResponse(TicketReservationRequest, TicketReservationResponse);
    end;

    local procedure ImportTicketConfirmRevokeRequest(Document: XmlDocument)
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        NodeList: XmlNodeList;
        Node: XmlNode;
        Element: XmlElement;
        i: Integer;
        Token: Text[100];
    begin

        TicketRequestManager.ExpireReservationRequests();

        if (not Document.GetRoot(Element)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(Element.AsXmlNode(), 'ticket_tokens', NodeList)) then
            exit;

        for i := 1 to NodeList.Count() do begin
            NodeList.Get(i, Node);
            Element := Node.AsXmlElement();

            Token := GetXmlText100(Element, 'ticket_token', MaxStrLen(Token), false);

            TicketRequestManager.SetReservationRequestExtraInfo(Token,
              GetXmlText80(Element, 'send_notification_to', 80, false),
              GetXmlText20(Element, 'external_order_no', 20, false),
              GetXmlText100(Element, 'ticket_holder_name', 100, false));

            // Response is updated with a soft fail message if confirm fails.
            TicketRequestManager.RevokeReservationTokenRequest(Token, false);

            TicketReservationResponse.SetCurrentKey("Session Token ID");
            TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationResponse.ModifyAll(Confirmed, true);
            TicketReservationResponse.ModifyAll(Canceled, true);

        end;

    end;

    // ******************* Database Operations ()

    local procedure CreateResponse(var TicketReservationRequest: Record "NPR TM Ticket Reservation Req."; var TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp."): Boolean
    var
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin

        // One response per Ext. Line Reference No.
        // Primary Request Line links Ticket to Request and Response

        TicketReservationRequest2.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest2.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
        TicketReservationRequest2.SetFilter("Admission Inclusion", '=%1', TicketReservationRequest."Admission Inclusion"::REQUIRED);
        if (not TicketReservationRequest2.FindFirst()) then
            exit(false);

        TicketReservationResponse.Reset();
        TicketReservationResponse.SetCurrentKey("Request Entry No.");
        TicketReservationResponse.SetFilter("Request Entry No.", '=%1', TicketReservationRequest2."Entry No.");
        if (TicketReservationResponse.FindFirst()) then begin
            // unconfirmed change request entry can be reused in order to invalidate the previous token.
            if (TicketReservationResponse."Session Token ID" <> TicketReservationRequest."Session Token ID") then begin
                TicketReservationResponse."Session Token ID" := TicketReservationRequest."Session Token ID";
                TicketReservationResponse."Exires (Seconds)" := TicketRequestManager.GetExpirySeconds();
                TicketReservationResponse.Status := true;
                TicketReservationResponse.Confirmed := false;
                TicketReservationResponse.Modify();
            end;
        end;

        TicketReservationResponse.Reset();
        TicketReservationResponse.SetCurrentKey("Session Token ID", "Exires (Seconds)");
        TicketReservationResponse.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationResponse.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
        if (not TicketReservationResponse.FindFirst()) then begin
            TicketReservationResponse.Init();
            TicketReservationResponse."Entry No." := 0;
            TicketReservationResponse."Request Entry No." := TicketReservationRequest2."Entry No.";
            TicketReservationResponse."Session Token ID" := TicketReservationRequest."Session Token ID";
            TicketReservationResponse."Ext. Line Reference No." := TicketReservationRequest."Ext. Line Reference No.";
            TicketReservationResponse."Exires (Seconds)" := TicketRequestManager.GetExpirySeconds();
            TicketReservationResponse.Status := true;
            TicketReservationResponse.Confirmed := false;
            TicketReservationResponse.Insert();
        end else begin
            if (TicketReservationRequest."Primary Request Line") and (TicketReservationResponse."Request Entry No." <> TicketReservationRequest."Entry No.") then begin
                TicketReservationResponse."Request Entry No." := TicketReservationRequest."Entry No.";
                TicketReservationResponse.Modify();
            end;
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

        if (not TicketRequestManager.TranslateBarcodeToItemVariant(TicketReservationRequest."External Item Code", TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", ExternalItemType)) then begin
            TicketReservationResponse."Response Message" := StrSubstNo(InvalidItem, TicketReservationRequest."External Item Code");
            TicketReservationResponse.Status := false;
        end;

        TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest2.SetFilter("Entry No.", '<>%1', TicketReservationRequest."Entry No.");
        TicketReservationRequest2.SetFilter("External Item Code", '=%1', TicketReservationRequest."External Item Code");
        TicketReservationRequest2.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
        TicketReservationRequest2.SetFilter("Admission Code", '=%1|=%2', '', TicketReservationRequest."Admission Code");
        TicketReservationRequest2.SetFilter("Admission Created", '=%1', TicketReservationRequest."Admission Created");

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
        TMTicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketManager: Codeunit "NPR TM Ticket Management";
        ExternalItemType: Integer;
        WaitingListOptInAddress: Text[100];
    begin

        Clear(TicketReservationRequest);
        TicketReservationRequest."Session Token ID" := Token;
        TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::WIP;
        TicketReservationRequest."Created Date Time" := CurrentDateTime();

        TicketReservationRequest."External Item Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'external_id', true), 1, MaxStrLen(TicketReservationRequest."External Item Code"));

        if (not TicketRequestManager.TranslateBarcodeToItemVariant(TicketReservationRequest."External Item Code", TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", ExternalItemType)) then
            Error(INVALID_ITEM_REFERENCE, TicketReservationRequest."External Item Code");

        Evaluate(TicketReservationRequest.Quantity, NpXmlDomMgt.GetXmlAttributeText(Element, 'qty', true));
        Evaluate(TicketReservationRequest."Ext. Line Reference No.", NpXmlDomMgt.GetXmlAttributeText(Element, 'line_no', true));
        TicketReservationRequest."External Member No." := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'member_number', false), 1, MaxStrLen(TicketReservationRequest."External Member No."));
        TicketReservationRequest."Admission Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'admission_code', false), 1, MaxStrLen(TicketReservationRequest."Admission Code"));

        if (TicketReservationRequest."Admission Code" = '') then
            TicketReservationRequest."Admission Code" := TicketManager.GetDefaultAdmissionCode(TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code");

        TMTicketAdmissionBOM.Get(TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", TicketReservationRequest."Admission Code");
        TicketReservationRequest.Default := TMTicketAdmissionBOM.Default;

        if (TMTicketAdmissionBOM."Admission Inclusion" <> TMTicketAdmissionBOM."Admission Inclusion"::REQUIRED) then
            TicketReservationRequest."Admission Inclusion" := TicketReservationRequest."Admission Inclusion"::SELECTED;

        if ((TicketReservationRequest."Admission Inclusion" = TicketReservationRequest."Admission Inclusion"::SELECTED) and (TicketReservationRequest.Quantity = 0)) then
            TicketReservationRequest."Admission Inclusion" := TicketReservationRequest."Admission Inclusion"::NOT_SELECTED;

        Evaluate(TicketReservationRequest."External Adm. Sch. Entry No.", NpXmlDomMgt.GetXmlAttributeText(Element, 'admission_schedule_entry', false));

        TicketReservationRequest."Waiting List Reference Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'waitinglist_reference_code', false), 1, MaxStrLen(TicketReservationRequest."Waiting List Reference Code"));
        WaitingListOptInAddress := CopyStr(NpXmlDomMgt.GetXmlAttributeText(Element, 'waitinglist_opt-in_address', false), 1, MaxStrLen(WaitingListOptInAddress));
        if (WaitingListOptInAddress <> '') then begin
            TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::WAITINGLIST;
            TicketReservationRequest."Notification Address" := WaitingListOptInAddress;
        end;

        TicketReservationRequest.UnitAmount := Abs(GetDecimalAmount(Element, 'unit_amount'));
        TicketReservationRequest.UnitAmountInclVat := Abs(GetDecimalAmount(Element, 'unit_amount_incl_vat'));
        TicketReservationRequest.Amount := Abs(GetDecimalAmount(Element, 'amount'));
        TicketReservationRequest.AmountInclVat := Abs(GetDecimalAmount(Element, 'amount_incl_vat'));
        if (TicketReservationRequest.UnitAmount + TicketReservationRequest.UnitAmountInclVat + TicketReservationRequest.Amount + TicketReservationRequest.AmountInclVat > 0) then
            TicketReservationRequest.AmountSource := TicketReservationRequest.AmountSource::API;

        TicketReservationRequest.Insert();
    end;

    local procedure InsertTemporaryTicketReservation(TicketElement: XmlElement; Token: Text[100]; var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary)
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ExternalItemType: Integer;
    begin

        if (not TicketSetup.Get()) then
            TicketSetup.Init();

        if (TicketSetup."Authorization Code Scheme" = '') then
            TicketSetup."Authorization Code Scheme" := '[N*4]-[N*4]';

        TmpTicketReservationRequest.Init();
        TmpTicketReservationRequest."Entry No." := TmpTicketReservationRequest.Count() + 1;
        TmpTicketReservationRequest."Session Token ID" := Token;
        TmpTicketReservationRequest."Request Status" := TmpTicketReservationRequest."Request Status"::WIP;
        TmpTicketReservationRequest."Created Date Time" := CurrentDateTime();

        // NOTE!
        TmpTicketReservationRequest."Primary Request Line" := true;
        TmpTicketReservationRequest."Authorization Code" := CopyStr(TicketManagement.GenerateNumberPattern(TicketSetup."Authorization Code Scheme", '-'), 1, MaxStrLen(TmpTicketReservationRequest."Authorization Code"));

        TmpTicketReservationRequest."External Item Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(TicketElement, 'external_id', true), 1, MaxStrLen(TmpTicketReservationRequest."External Item Code"));

        if (not TicketRequestManager.TranslateBarcodeToItemVariant(TmpTicketReservationRequest."External Item Code", TmpTicketReservationRequest."Item No.", TmpTicketReservationRequest."Variant Code", ExternalItemType)) then
            Error(INVALID_ITEM_REFERENCE, TmpTicketReservationRequest."External Item Code");

        Evaluate(TmpTicketReservationRequest.Quantity, NpXmlDomMgt.GetXmlAttributeText(TicketElement, 'qty', true));
        Evaluate(TmpTicketReservationRequest."Ext. Line Reference No.", NpXmlDomMgt.GetXmlAttributeText(TicketElement, 'line_no', true));
        TmpTicketReservationRequest."External Member No." := CopyStr(NpXmlDomMgt.GetXmlAttributeText(TicketElement, 'member_number', false), 1, MaxStrLen(TmpTicketReservationRequest."External Member No."));
        TmpTicketReservationRequest."Admission Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(TicketElement, 'admission_code', false), 1, MaxStrLen(TmpTicketReservationRequest."Admission Code"));

        Evaluate(TmpTicketReservationRequest."External Adm. Sch. Entry No.", NpXmlDomMgt.GetXmlAttributeText(TicketElement, 'admission_schedule_entry', false));

        TmpTicketReservationRequest.Insert();

    end;

    local procedure ApplyAttributes(Token: Text[50]; AdmissionCode: Code[20]; AttributeCode: Code[20]; AttributeValue: Text[250])
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

        TicketReservationRequest.FindSet(false);
        repeat
            NPRAttributeManagement.SetEntryAttributeValue(TableId, NPRAttributeID."Shortcut Attribute ID", TicketReservationRequest."Entry No.", AttributeValue);
        until (TicketReservationRequest.Next() = 0);
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

    internal procedure InitTMTicketWebService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        if (not WebService.ReadPermission) then
            exit;

        if (not WebService.WritePermission) then
            exit;

        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR TM Ticket WebService", 'ticket_services', true);
    end;

#pragma warning disable AA0139
    local procedure GetXmlText10(Element: XmlElement; NodePath: Text; MaxLength: Integer; Required: Boolean): Text[10]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, MaxLength, Required));
    end;

    local procedure GetXmlText20(Element: XmlElement; NodePath: Text; MaxLength: Integer; Required: Boolean): Text[20]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, MaxLength, Required));
    end;

    local procedure GetXmlText30(Element: XmlElement; NodePath: Text; MaxLength: Integer; Required: Boolean): Text[30]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, MaxLength, Required));
    end;

    local procedure GetXmlText80(Element: XmlElement; NodePath: Text; MaxLength: Integer; Required: Boolean): Text[80]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, MaxLength, Required));
    end;

    local procedure GetXmlText100(Element: XmlElement; NodePath: Text; MaxLength: Integer; Required: Boolean): Text[100]
    begin
        exit(NpXmlDomMgt.GetXmlText(Element, NodePath, MaxLength, Required));
    end;

    local procedure CreateAdmissionEntry(ChangeRequestToken: Text[100]; AdmissionCode: Code[20]; ExtScheduleEntryNew: Integer; var AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry")
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        Ternary: Enum "NPR TM Ternary";
    begin
        TicketReservationRequest.SetRange(Default, true);
        TicketReservationRequest.SetRange("Session Token ID", ChangeRequestToken);
        if not TicketReservationRequest.FindFirst() then
            exit;
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Superseeds Entry No.");
        if Ticket.FindFirst() then
            if AdmissionScheduleEntry.Get(ExtScheduleEntryNew) then begin
                TicketManagement.CreateAdmissionAccessEntry(Ticket, 1, AdmissionCode, AdmissionScheduleEntry, Ternary);
                TicketReservationRequest.SetRange(Default);
                TicketReservationRequest.SetRange("Admission Code", AdmissionCode);
                if TicketReservationRequest.FindFirst() then begin
                    TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::REGISTERED;
                    TicketReservationRequest.Modify();
                end;
            end;
    end;

    local procedure AddRemainingReservationRequestEntries(Token: Text[100]; Line: Integer)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        TMTicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TMTicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetRange("Ext. Line Reference No.", Line);
        if (TicketReservationRequest.FindFirst()) then begin
            TMTicketAdmissionBOM.SetFilter("Item No.", '=%1', TicketReservationRequest."Item No.");
            TMTicketAdmissionBOM.SetFilter("Variant Code", '=%1', TicketReservationRequest."Variant Code");
            TMTicketAdmissionBOM.FindSet();
            repeat
                TicketReservationRequest2.SetFilter("Session Token ID", '=%1', Token);
                TicketReservationRequest2.SetRange("Admission Code", TMTicketAdmissionBOM."Admission Code");
                TicketReservationRequest2.SetRange("Ext. Line Reference No.", Line);
                if TicketReservationRequest2.IsEmpty() then
                    TMTicketRequestManager.POS_AppendToReservationRequest(Token, TicketReservationRequest."Receipt No.", TicketReservationRequest."Line No.", TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", TMTicketAdmissionBOM."Admission Code", TicketReservationRequest.Quantity, 0, TicketReservationRequest."External Member No.", TicketReservationRequest."Ext. Line Reference No.");
            until (TMTicketAdmissionBOM.Next() = 0);
        end;
    end;

    local procedure GetDecimalAmount(Element: XmlElement; AttributeKey: Text) Amount: Decimal
    var
        DecimalText: Text;
    begin
        DecimalText := NpXmlDomMgt.GetXmlAttributeText(Element, AttributeKey, false);
        if (DecimalText = '') then
            exit(0.0);

        Evaluate(Amount, DecimalText, 9);
    end;
#pragma warning restore

}


