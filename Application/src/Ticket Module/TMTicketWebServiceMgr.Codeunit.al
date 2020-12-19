codeunit 6060116 "NPR TM Ticket WebService Mgr"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet "NPRNetXmlDocument";
        ImportType: Record "NPR Nc Import Type";
        FunctionName: Text[100];
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin

        Commit();
        TicketRequestManager.LockResources();

        if (LoadXmlDoc(XmlDoc)) then begin
            FunctionName := GetWebserviceFunction("Import Type");
            case FunctionName of
                'MakeTicketReservation':
                    ImportTicketReservations(XmlDoc, "Entry No.", "Document ID");
                'ReserveConfirmArrive':
                    ImportTicketReservationConfirmArriveDoc(XmlDoc, "Entry No.", "Document ID");
                'PreConfirmReservation':
                    ImportTicketPreConfirmation(XmlDoc, "Entry No.", "Document ID");
                'CancelReservation':
                    ImportTicketCancelation(XmlDoc, "Entry No.", "Document ID");
                'ConfirmReservation':
                    ImportTicketConfirmation(XmlDoc, "Entry No.", "Document ID");

                'SetAttributes':
                    ImportTicketAttributes(XmlDoc, "Entry No.", "Document ID");

                'GetTicketChangeRequest':
                    ImportTicketChangeRequest(XmlDoc, "Entry No.", "Document ID");
                'ConfirmTicketChangeRequest':
                    ImportTicketConfirmChangeRequest(XmlDoc, "Entry No.", "Document ID");
                else
                    Error(MISSING_CASE, "Import Type", FunctionName);
            end;
        end;

        Commit();
    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Initialized: Boolean;
        ITEM_NOT_FOUND: Label 'The sales item specified in external_id %1, was not found.';
        CHANGE_NOT_ALLOWED: Label 'Confirmed tickets can''t be changed.';
        TOKEN_NOT_FOUND: Label 'The token %1 was not found, or has incorrect state.';
        TOKEN_EXPIRED: Label 'The token %1 has expired. Use PreConfirm to re-reserve tickets.';
        TOKEN_INCORRECT_STATE: Label 'The token %1 can''t be changed when in the %1 state.';
        MISSING_CASE: Label 'No handler for %1 [%2].';
        XML_NODE: Label '%1 not found (this is a programming error.)';
        MUST_BE_POSITIVE: Label 'Quantity must be positive.';

    local procedure ImportTicketReservations(XmlDoc: DotNet "NPRNetXmlDocument"; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketWaitingListMgr: Codeunit "NPR TM Ticket WaitingList Mgr.";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        XmlElement: DotNet NPRNetXmlElement;
        XmlTokenElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        XmlTokenNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
        Token_i: Integer;
        Token: Text[50];
        TicketCreated: Boolean;
    begin

        TicketRequestManager.ExpireReservationRequests();

        if (IsNull(XmlDoc)) then
            exit;
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(XmlElement, 'reserve_tickets', XmlTokenNodeList)) then
            exit;

        for Token_i := 0 to XmlTokenNodeList.Count - 1 do begin
            XmlTokenElement := XmlTokenNodeList.ItemOf(Token_i);
            Token := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlTokenElement, 'token', false), 1, MaxStrLen(Token));
            if (Token = '') then
                Token := DocumentID;

            if (TicketRequestManager.TokenRequestExists(Token)) then
                TicketRequestManager.DeleteReservationRequest(Token, true);

            if (not NpXmlDomMgt.FindNodes(XmlTokenElement, 'ticket', XmlNodeList)) then
                exit;

            for i := 0 to XmlNodeList.Count - 1 do begin
                XmlElement := XmlNodeList.ItemOf(i);
                ImportTicketReservation(XmlElement, Token, DocumentID);
            end;
        end;

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);

        if (TicketReservationRequest.FindSet(true, false)) then begin
            TicketCreated := true;
            repeat
                CreateResponse(TicketReservationRequest, TicketReservationResponse);

                if (ValidTicketRequest(TicketReservationRequest, TicketReservationResponse)) then begin

                    //TicketCreated := TicketCreated and CreateTicket (TicketReservationRequest, TicketReservationResponse);
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

    local procedure ImportTicketReservation(XmlElement: DotNet NPRNetXmlElement; Token: Text[100]; DocumentID: Text[100]) Imported: Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
    begin

        if (IsNull(XmlElement)) then
            exit(false);

        TicketReservationRequest.Init();
        InsertTicketReservation(XmlElement, Token, TicketReservationRequest);

        exit(true);
    end;

    local procedure ImportTicketPreConfirmation(XmlDoc: DotNet "NPRNetXmlDocument"; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        XmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
        Token: Text[100];
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketCreated: Boolean;
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin

        if (IsNull(XmlDoc)) then
            exit;
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(XmlElement, 'ticket_tokens', XmlNodeList)) then
            exit;

        Token := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'ticket_token', false), 1, MaxStrLen(Token));
        if (Token = '') then
            Token := DocumentID;

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

    local procedure ImportTicketConfirmation(XmlDoc: DotNet "NPRNetXmlDocument"; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        XmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
        Token: Text[100];
        ResponseMessage: Text;
    begin

        if (IsNull(XmlDoc)) then
            exit;
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(XmlElement, 'ticket_tokens', XmlNodeList)) then
            exit;

        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);

            Token := NpXmlDomMgt.GetXmlText(XmlElement, 'ticket_token', MaxStrLen(Token), false);

            TicketRequestManager.SetReservationRequestExtraInfo(Token,
              NpXmlDomMgt.GetXmlText(XmlElement, 'send_notification_to', 80, false),
              NpXmlDomMgt.GetXmlText(XmlElement, 'external_order_no', 80, false));

            // Response is updated with a soft fail message if confirm fails.
            TicketRequestManager.ConfirmReservationRequest(Token, ResponseMessage);

        end;
    end;

    local procedure ImportTicketCancelation(XmlDoc: DotNet "NPRNetXmlDocument"; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        XmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
        Token: Text[100];
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
    begin

        if (IsNull(XmlDoc)) then
            exit;
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(XmlElement, 'ticket_tokens', XmlNodeList)) then
            exit;

        Token := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'ticket_token', false), 1, MaxStrLen(Token));
        if (Token = '') then
            Token := DocumentID;

        TicketRequestManager.DeleteReservationTokenRequest(Token);

        //XCOMMIT;
    end;

    local procedure ImportTicketReservationConfirmArriveDoc(XmlDoc: DotNet "NPRNetXmlDocument"; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationResponse2: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        TicketAttempCreate: Codeunit "NPR Ticket Attempt Create";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketCreated: Boolean;
        XmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
        ResponseMessage: Text;
        ReusedToken: Text;
        Token: Text[50];
    begin

        TicketRequestManager.ExpireReservationRequests();

        if (IsNull(XmlDoc)) then
            exit;
        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(XmlElement, 'ticket_tokens', XmlNodeList)) then
            exit;

        Token := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'ticket_token', false), 1, MaxStrLen(Token));
        if (Token = '') then
            Token := DocumentID;

        if (TicketRequestManager.TokenRequestExists(Token)) then
            TicketRequestManager.DeleteReservationRequest(Token, true);

        if (not NpXmlDomMgt.FindNodes(XmlElement, 'ticket', XmlNodeList)) then
            exit;

        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);
            InsertTemporaryTicketReservation(XmlElement, Token, TmpTicketReservationRequest);
        end;

        TmpTicketReservationRequest.Reset();
        if (TmpTicketReservationRequest.IsEmpty()) then
            Error('Houston, we have a problem! 6060116.CreateTicketRequest() said ok, but token %1 was not found.', Token);

        // precheck member guest
        MemberTicketManager.PreValidateMemberGuestTicketRequest(TmpTicketReservationRequest, true);

        Commit();
        if (TicketAttempCreate.AttemptValidateRequestForTicketReuse(TmpTicketReservationRequest, ReusedToken, ResponseMessage)) then begin
            // duplicate the previous response so SOAP Service gets a valid response
            TicketReservationResponse.SetFilter("Session Token ID", '=%1', ReusedToken);
            if (TicketReservationResponse.FindSet()) then begin
                repeat
                    TicketReservationResponse2.TransferFields(TicketReservationResponse, false);
                    TicketReservationResponse2."Entry No." := 0;
                    TicketReservationResponse2."Session Token ID" := Token;
                    TicketReservationResponse2.Insert();

                //until (TicketReservationRequest.NEXT () = 0);
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

    local procedure ImportTicketAttributes(XmlDoc: DotNet "NPRNetXmlDocument"; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        Token: Text[50];
        AdmissionCode: Code[20];
        AttributeCode: Code[20];
        AttributeValue: Text[250];
        XmlElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        i: Integer;
    begin

        if (IsNull(XmlDoc)) then
            exit;

        XmlElement := XmlDoc.DocumentElement;
        if (IsNull(XmlElement)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(XmlElement, 'set_attributes', XmlNodeList)) then
            exit;

        Token := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'token', false), 1, MaxStrLen(Token));
        if (Token = '') then
            Token := DocumentID;

        if (not NpXmlDomMgt.FindNodes(XmlElement, 'attribute', XmlNodeList)) then
            exit;

        // Pass one - blank Admission Code
        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);

            AdmissionCode := 'not_blank';
            AdmissionCode := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'admission_code', false), 1, MaxStrLen(AdmissionCode));
            AttributeCode := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'attribute_code', true), 1, MaxStrLen(AttributeCode));
            AttributeValue := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'attribute_value', true), 1, MaxStrLen(AttributeValue));

            if (AdmissionCode = '') then
                ApplyAttributes(Token, '', AttributeCode, AttributeValue);

        end;

        if (not NpXmlDomMgt.FindNodes(XmlElement, 'attribute', XmlNodeList)) then
            exit;
        // Pass two - specific Admission Code
        for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement := XmlNodeList.ItemOf(i);

            AdmissionCode := '';
            AdmissionCode := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'admission_code', false), 1, MaxStrLen(AdmissionCode));
            AttributeCode := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'attribute_code', true), 1, MaxStrLen(AttributeCode));
            AttributeValue := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'attribute_value', true), 1, MaxStrLen(AttributeValue));

            if (AdmissionCode <> '') then
                ApplyAttributes(Token, AdmissionCode, AttributeCode, AttributeValue);

        end;

    end;

    local procedure ImportTicketChangeRequest(XmlDoc: DotNet NPRNetXmlDocument; RequestEntryNo: Integer; DocumentID: Text[100]);
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketWaitingListMgr: Codeunit "NPR TM Ticket WaitingList Mgr.";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        XmlElement: DotNet NPRNetXmlElement;
        XmlTokenElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        XmlTokenNodeList: DotNet NPRNetXmlNodeList;
        XmlNodeChild: DotNet NPRNetXmlNode;
        i: Integer;
        Token_i: Integer;
        Token: Text[50];
        TicketCreated: Boolean;
        TicketNumber: Code[30];
        PinCode: Code[10];
        ResponseMessage: Text;
    begin

        TicketRequestManager.ExpireReservationRequests();

        if (ISNULL(XmlDoc)) then
            exit;

        XmlElement := XmlDoc.DocumentElement;
        if (ISNULL(XmlElement)) then
            exit;

        if (not NpXmlDomMgt.FindNode(XmlElement, 'ChangeReservation', XmlNodeChild)) then
            exit;

        TicketNumber := NpXmlDomMgt.GetElementText(XmlNodeChild, 'Request/TicketNumber', MaxStrLen(TicketNumber), true);
        PinCode := NpXmlDomMgt.GetElementText(XmlNodeChild, 'Request/PinCode', MaxStrLen(PinCode), true);

        if (not TicketRequestManager.CreateChangeRequest(TicketNumber, PinCode, DocumentID, ResponseMessage)) then
            Error(ResponseMessage);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', DocumentID);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindFirst();
        CreateResponse(TicketReservationRequest, TicketReservationResponse);

    end;

    local procedure ImportTicketConfirmChangeRequest(XmlDoc: DotNet NPRNetXmlDocument; RequestEntryNo: Integer; DocumentID: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketWaitingListMgr: Codeunit "NPR TM Ticket WaitingList Mgr.";
        TicketManagement: Codeunit "NPR TM Ticket Management";

        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TickeChangeRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";

        XmlElement: DotNet NPRNetXmlElement;
        XmlTokenElement: DotNet NPRNetXmlElement;
        XmlNodeList: DotNet NPRNetXmlNodeList;
        XmlTokenNodeList: DotNet NPRNetXmlNodeList;
        XmlNode: DotNet NPRNetXmlNode;

        i: Integer;
        Token_i: Integer;
        TicketCreated: Boolean;
        ChangeRequestToken: Text[100];
        AdmissionCode: Code[20];
        ExtScheduleEntryOld: Integer;
        ExtScheduleEntryNew: Integer;
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin

        TicketRequestManager.ExpireReservationRequests();

        if (ISNULL(XmlDoc)) then
            exit;
        XmlElement := XmlDoc.DocumentElement;
        if (ISNULL(XmlElement)) then
            exit;

        if (not NpXmlDomMgt.FindNode(XmlElement, 'ConfirmChangeReservation', XmlNode)) then
            exit;

        ChangeRequestToken := NpXmlDomMgt.GetElementText(XmlNode, 'Request/ChangeRequestToken', MaxStrLen(ChangeRequestToken), true);
        if (not TicketRequestManager.TokenRequestExists(ChangeRequestToken)) then
            exit;

        if (not NpXmlDomMgt.FindNodes(XmlNode, 'Request/Admissions/Admission', XmlTokenNodeList)) then
            exit;

        FOR Token_i := 0 TO XmlTokenNodeList.Count - 1 do begin
            XmlTokenElement := XmlTokenNodeList.ItemOf(Token_i);

            AdmissionCode := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlTokenElement, 'Code', true), 1, MaxStrLen(AdmissionCode));
            if (not Evaluate(ExtScheduleEntryOld, CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlTokenElement, 'OldScheduleEntryNo', true), 1, 10))) then
                ExtScheduleEntryOld := 0;

            if (not Evaluate(ExtScheduleEntryNew, CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlTokenElement, 'NewScheduleEntryNo', true), 1, 10))) then
                ExtScheduleEntryNew := 0;

            AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtScheduleEntryOld);
            if (not AdmissionScheduleEntry.FindFirst()) then
                Error('Invalid schedule entry %1.', ExtScheduleEntryOld);

            if (AdmissionCode <> AdmissionScheduleEntry."Admission Code") then
                Error('Schedule Entry %1 does not correspond to admission code %2.', ExtScheduleEntryOld, AdmissionCode);

            AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtScheduleEntryNew);
            if (not AdmissionScheduleEntry.FindFirst()) then
                Error('Invalid schedule entry %1.', ExtScheduleEntryNew);

            if (AdmissionCode <> AdmissionScheduleEntry."Admission Code") then
                Error('Schedule Entry %1 does not correspond to admission code %2.', ExtScheduleEntryNew, AdmissionCode);

            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', ChangeRequestToken);
            TicketReservationRequest.SetFilter("Admission Code", '=%1', AdmissionCode);
            TicketReservationRequest.SetFilter("External Adm. Sch. Entry No.", '=%1', ExtScheduleEntryOld);
            if (TicketReservationRequest.FindFirst()) then
                if (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CONFIRMED) then
                    Error('Change request %1 has already been confirmed.', ChangeRequestToken);

            TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::REGISTERED);
            if (not TicketReservationRequest.FindFirst()) then
                Error('A request for %1 and schedule entry %2 was not found for token %3', AdmissionCode, ExtScheduleEntryOld, ChangeRequestToken);

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
                TickeChangeRequest.SetFilter("Session Token ID", '=%1', DocumentID);
                TickeChangeRequest.FindSet();
                repeat
                    TicketManagement.RescheduleTicketAdmission(Ticket."No.", TickeChangeRequest."External Adm. Sch. Entry No.", true, TickeChangeRequest."Request Status Date Time");
                until (TickeChangeRequest.NEXT() = 0);
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
        ResponseCode: Integer;
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
    begin

        if (TicketReservationRequest.Quantity <= 0) then begin
            TicketReservationResponse."Response Message" := StrSubstNo(MUST_BE_POSITIVE);
            TicketReservationResponse.Status := false;
        end;

        if (TicketReservationRequest."Admission Code" <> '') then begin
            if (not Admission.Get(TicketReservationRequest."Admission Code")) then begin
                TicketReservationResponse."Response Message" := StrSubstNo('Admission Code [%1] is not a valid admission code.', TicketReservationRequest."Admission Code");
                TicketReservationResponse.Status := false;
            end;
        end;

        //if (not TicketRequestManager.TranslateBarcodeToItemVariant (TicketReservationRequest."External Item Code", ItemNo, VariantCode, ExternalItemType)) then begin
        if (not TicketRequestManager.TranslateBarcodeToItemVariant(TicketReservationRequest."External Item Code", TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", ExternalItemType)) then begin

            TicketReservationResponse."Response Message" := StrSubstNo('External Item [%1] does not resolve to an internal item.', TicketReservationRequest."External Item Code");
            TicketReservationResponse.Status := false;
        end;

        TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest2.SetFilter("Entry No.", '<>%1', TicketReservationRequest."Entry No.");
        TicketReservationRequest2.SetFilter("External Item Code", '=%1', TicketReservationRequest."External Item Code");
        TicketReservationRequest2.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
        TicketReservationRequest2.SetFilter("Admission Code", '=%1|=%2', '', TicketReservationRequest."Admission Code");

        if (not TicketReservationRequest2.IsEmpty()) then begin
            TicketReservationResponse."Response Message" := StrSubstNo('Ambigous ticket request, multiple references for %1 line %2',
              TicketReservationRequest."External Item Code", TicketReservationRequest."Ext. Line Reference No.");
            TicketReservationResponse.Status := false;
        end;

        TicketReservationResponse.Modify();
        exit(TicketReservationResponse.Status);
    end;

    local procedure InsertTicketReservation(XmlElement: DotNet NPRNetXmlElement; Token: Text[100]; var TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        Member: Record "NPR MM Member";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ExternalItemType: Integer;
        WaitingListOptInAddress: Text[200];
    begin

        Initialize;

        Clear(TicketReservationRequest);
        TicketReservationRequest."Session Token ID" := Token;
        TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::WIP;
        TicketReservationRequest."Created Date Time" := CurrentDateTime();

        TicketReservationRequest."External Item Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'external_id', true), 1, MaxStrLen(TicketReservationRequest."External Item Code"));

        TicketRequestManager.TranslateBarcodeToItemVariant(TicketReservationRequest."External Item Code", TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", ExternalItemType);

        Evaluate(TicketReservationRequest.Quantity, NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'qty', true));
        Evaluate(TicketReservationRequest."Ext. Line Reference No.", NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'line_no', true));
        TicketReservationRequest."External Member No." := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'member_number', false), 1, MaxStrLen(TicketReservationRequest."External Member No."));
        TicketReservationRequest."Admission Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'admission_code', false), 1, MaxStrLen(TicketReservationRequest."Admission Code"));

        Evaluate(TicketReservationRequest."External Adm. Sch. Entry No.", NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'admission_schedule_entry', false));

        TicketReservationRequest."Waiting List Reference Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'waitinglist_reference_code', false), 1, MaxStrLen(TicketReservationRequest."Waiting List Reference Code"));
        WaitingListOptInAddress := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'waitinglist_opt-in_address', false), 1, MaxStrLen(WaitingListOptInAddress));
        if (WaitingListOptInAddress <> '') then begin
            TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::WAITINGLIST;
            TicketReservationRequest."Notification Address" := WaitingListOptInAddress;
        end;

        // //xx
        // if (TicketReservationRequest."External Member No." <> '') then begin
        //  Member.SetFilter ("External Member No.", '=%1', TicketReservationRequest."External Member No.");
        //  Member.SetFilter (Blocked, '=%1', false);
        //  if (Member.FindFirst ()) then begin
        //    case Member."Notification Method" OF
        //      Member."Notification Method"::EMAIL :
        //        begin
        //          TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::EMAIL;
        //          TicketReservationRequest."Notification Address" := Member."E-Mail Address";
        //        end;
        //      Member."Notification Method"::SMS :
        //        begin
        //          TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::SMS;
        //          TicketReservationRequest."Notification Address" := Member."Phone No.";
        //        end;
        //    end;
        //  end;
        // end;
        // //xx

        TicketReservationRequest.Insert();
    end;

    local procedure InsertTemporaryTicketReservation(XmlElement: DotNet NPRNetXmlElement; Token: Text[100]; var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary)
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ExternalItemType: Integer;
    begin

        Initialize;

        with TmpTicketReservationRequest do begin
            Init();
            TmpTicketReservationRequest."Entry No." := TmpTicketReservationRequest.Count() + 1;
            "Session Token ID" := Token;
            "Request Status" := "Request Status"::WIP;
            "Created Date Time" := CurrentDateTime();

            "External Item Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'external_id', true), 1, MaxStrLen("External Item Code"));

            TicketRequestManager.TranslateBarcodeToItemVariant("External Item Code", "Item No.", "Variant Code", ExternalItemType);

            Evaluate(Quantity, NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'qty', true));
            Evaluate("Ext. Line Reference No.", NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'line_no', true));
            "External Member No." := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'member_number', false), 1, MaxStrLen("External Member No."));
            "Admission Code" := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'admission_code', false), 1, MaxStrLen("Admission Code"));

            Evaluate("External Adm. Sch. Entry No.", NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'admission_schedule_entry', false));

            Insert();
        end;

    end;

    local procedure ApplyAttributes(Token: Text[50]; AdmissionCode: Code[20]; AttributeCode: Code[20]; AttributeValue: Text)
    var
        NPRAttribute: Record "NPR Attribute";
        NPRAttributeID: Record "NPR Attribute ID";
        Admission: Record "NPR TM Admission";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TableId: Integer;
        NPRAttributeManagement: Codeunit "NPR Attribute Management";
    begin

        TableId := DATABASE::"NPR TM Ticket Reservation Req.";

        if (not NPRAttribute.Get(AttributeCode)) then
            Error('Attribute %1 is not valid.', AttributeCode);

        if (not NPRAttributeID.Get(TableId, AttributeCode)) then
            Error('Attribute %1 is not defined for table with id %2.', AttributeCode, TableId);

        if (AdmissionCode <> '') then
            if (not Admission.Get(AdmissionCode)) then
                Error('The admission code %1 is not valid.', AdmissionCode);

        // update the request
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (AdmissionCode <> '') then
            TicketReservationRequest.SetFilter("Admission Code", '=%1', AdmissionCode);

        if (TicketReservationRequest.IsEmpty()) then
            Error('No reservation request found using filter %1.', TicketReservationRequest.GetFilters());

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

    local procedure GetWebserviceFunction(ImportTypeCode: Code[20]) FunctionName: Text[100]
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetFilter(Code, '=%1', ImportTypeCode);
        if (ImportType.FindFirst()) then;

        exit(ImportType."Webservice Function");
    end;
}

