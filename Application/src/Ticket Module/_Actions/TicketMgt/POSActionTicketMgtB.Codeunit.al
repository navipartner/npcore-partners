codeunit 6151431 "NPR POS Action - Ticket Mgt B."
{
    Access = Internal;


    var
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';
        INVALID_ADMISSION: Label 'Parameter %1 specifies an invalid value for admission code. %2 not found.';
        REVOKE_IN_PROGRESS: Label 'Ticket %1 is being processed for revoke and can''t be added at this time.';
        TICKET_NUMBER: Label 'Ticket Number';

    #region PosActions functions
    internal procedure ShowQuickStatistics(AdmissionCode: Code[20])
    var
        Admission: Record "NPR TM Admission";
        QuickStatsPage: Page "NPR TM Ticket Quick Stats";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        if (AdmissionCode <> '') then begin
            if (not Admission.Get(AdmissionCode)) then
                Error(INVALID_ADMISSION, 'Admission Code', AdmissionCode);
            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        end;

        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', Today);
        QuickStatsPage.SetFilterRecord(AdmissionScheduleEntry);
        QuickStatsPage.RunModal();
    end;

    internal procedure RegisterArrival(ExternalTicketNumber: Code[50]; AdmissionCode: Code[20]; PosUnitNo: Code[10]; WithPrint: Boolean; var ResponseText: Text)
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Ticket: Record "NPR TM Ticket";
        AdmittedCount: Integer;
        MultipleTicketsAdmittedMessage: Label '%1 tickets have been processed.';
        SingleTicketsAdmittedMessage: Label '%1 ticket has been processed.';
    begin

        if (not TicketManagement.GetTicket("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, ExternalTicketNumber, Ticket)) then begin
            TicketManagement.RegisterArrivalScanTicket("NPR TM TicketIdentifierType"::EXTERNAL_ORDER_REF, ExternalTicketNumber, AdmissionCode, -1, PosUnitNo, '', WithPrint, AdmittedCount);
            ResponseText := StrSubstNo(MultipleTicketsAdmittedMessage, AdmittedCount);
            exit;
        end;

        TicketManagement.RegisterArrivalScanTicket("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, ExternalTicketNumber, AdmissionCode, -1, PosUnitNo, '', WithPrint, AdmittedCount);
        ResponseText := StrSubstNo(SingleTicketsAdmittedMessage, AdmittedCount);
    end;

    internal procedure RevokeTicketReservation(POSSession: Codeunit "NPR POS Session"; ExternalTicketNumber: Code[50])
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketAccessEntryNo: Integer;
        Token: Text[100];
        UnitPrice: Decimal;
        RevokeQuantity: Integer;
        PosEntry: Record "NPR POS Entry";
        PosEntrySalesLine: Record "NPR POS Entry Sales Line";
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin
        if (ExternalTicketNumber = '') then
            Error(ILLEGAL_VALUE, ExternalTicketNumber, TICKET_NUMBER);

        POSSession.GetSaleLine(POSSaleLine);

        TicketManagement.ValidateTicketReference("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, ExternalTicketNumber, '', TicketAccessEntryNo);
        TicketAccessEntry.Get(TicketAccessEntryNo);
        Ticket.Get(TicketAccessEntry."Ticket No.");

        TicketReservationRequest.SetCurrentKey("External Ticket Number");
        TicketReservationRequest.SetFilter("External Ticket Number", '=%1', Ticket."External Ticket No.");
        TicketReservationRequest.SetFilter("Revoke Ticket Request", '=%1', true);
        TicketReservationRequest.SetFilter("Request Status", '<>%1', TicketReservationRequest."Request Status"::CANCELED); // in progress
        if (TicketReservationRequest.FindFirst()) then
            Error(REVOKE_IN_PROGRESS, Ticket."External Ticket No.");
        TicketReservationRequest.Reset();

        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");

        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        SaleLinePOS."No." := Ticket."Item No.";
        SaleLinePOS."Variant Code" := Ticket."Variant Code";
        SaleLinePOS.Quantity := -1;

        SaleLinePOS."Return Sale Sales Ticket No." := Ticket."Sales Receipt No.";

        POSSaleLine.InsertLine(SaleLinePOS);
        POSSaleLine.RefreshCurrent();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        UnitPrice := SaleLinePOS."Unit Price";
        if (SaleLinePOS."Price Includes VAT") then
            if (Ticket.AmountInclVat <> 0) then
                UnitPrice := Ticket.AmountInclVat;

        if (not SaleLinePOS."Price Includes VAT") then
            if (Ticket.AmountExclVat <> 0) then
                UnitPrice := Ticket.AmountExclVat;

        if (TicketReservationRequest."Receipt No." <> '') then begin
            PosEntry.SetFilter("Document No.", TicketReservationRequest."Receipt No.");
            if (PosEntry.FindFirst()) then begin
                PosEntrySalesLine.SetFilter("POS Entry No.", '=%1', PosEntry."Entry No.");
                PosEntrySalesLine.SetFilter("Line No.", '=%1', TicketReservationRequest."Line No.");
                if (PosEntrySalesLine.FindFirst()) then begin
                    if (SaleLinePOS."Price Includes VAT") then
                        UnitPrice := PosEntrySalesLine."Amount Incl. VAT" / PosEntrySalesLine.Quantity;
                    if (not SaleLinePOS."Price Includes VAT") then
                        UnitPrice := PosEntrySalesLine."Amount Excl. VAT" / PosEntrySalesLine.Quantity;
                end;
            end;
        end;

        ResponseCode := TicketRequestManager.POS_CreateRevokeRequest(Token, Ticket."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", UnitPrice, RevokeQuantity, ResponseMessage);
        if (ResponseCode <= 0) then begin
            POSSaleLine.DeleteLine();
            POSSaleLine.RefreshCurrent();
            Commit();
            Error(ResponseMessage);
        end;

        POSSaleLine.SetQuantity(-1 * Abs(RevokeQuantity));
        POSSaleLine.SetUnitPrice(UnitPrice);
        AddAdditionalExperienceRevokeLines(POSSession, Ticket, SaleLinePOS."Sales Ticket No.");

    end;

    internal procedure EditReservation(POSSession: Codeunit "NPR POS Session"; TicketReference: Code[50])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest, TicketRequest : Record "NPR TM Ticket Reservation Req.";
        Token: Text[100];
        ResponseMessage: Text;
        HaveSalesTicket: Boolean;
        RESERVATION_CONFIRMED: Label 'Reservation %1 is already confirmed and can not be changed.';
    begin
        if (TicketReference <> '') then begin
            TicketRequest.SetCurrentKey("Session Token ID");
            TicketRequest.SetFilter("Session Token ID", '=%1', TicketReference);
            if (not TicketRequest.FindFirst()) then begin
                Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(Ticket."External Ticket No.")));
                if (not Ticket.FindFirst()) then
                    Error(ILLEGAL_VALUE, TicketReference, TICKET_NUMBER);

                Ticket.TestField(Blocked, false);
                TicketRequestManager.GetTicketToken(Ticket."No.", Token);
            end else begin
                Token := TicketReference;
            end;
            HaveSalesTicket := false;

        end else begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token);
            HaveSalesTicket := true;
        end;

        if (Token <> '') then begin
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationRequest.SetFilter("Admission Inclusion", '<>%1', TicketReservationRequest."Admission Inclusion"::REQUIRED);
            if (not TicketReservationRequest.IsEmpty()) then begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                TicketReservationRequest.SetFilter("Request Status", '<>%1', TicketReservationRequest."Request Status"::REGISTERED);
                if (not TicketReservationRequest.IsEmpty()) then begin
                    AddAdditionalExperience(POSSession, TicketReference);
                    exit;
                end;
            end;

            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);
            if (not TicketReservationRequest.IsEmpty()) then
                Error(RESERVATION_CONFIRMED, Token);

            AcquireTicketAdmissionSchedule(Token, SaleLinePOS, HaveSalesTicket, ResponseMessage);
        end
    end;

    internal procedure ReconfirmReservation(POSSession: Codeunit "NPR POS Session")
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        Token: Text[100];
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token)) then begin
            if (TicketRequestManager.ReadyToConfirm(Token)) then begin
                TicketRequestManager.DeleteReservationRequest(Token, false);
                ResponseCode := TicketRequestManager.IssueTicketFromReservationToken(Token, false, ResponseMessage);
                if (ResponseCode <> 0) then
                    Error(ResponseMessage);

                AcquireTicketAdmissionSchedule(Token, SaleLinePOS, true, ResponseMessage); //-+TM1.45 [380754]
            end;
        end;
    end;

    internal procedure EditTicketHolder(POSSession: Codeunit "NPR POS Session"; TicketReference: Code[50])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRetailMgr: Codeunit "NPR TM Ticket Retail Mgt.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        Ticket: Record "NPR TM Ticket";
        Token: Text[100];
    begin
        Ticket.Init();
        if (TicketReference <> '') then begin
            TicketRequest.SetCurrentKey("Session Token ID");
            TicketRequest.SetFilter("Session Token ID", '=%1', TicketReference);
            if (not TicketRequest.FindFirst()) then begin
                Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(Ticket."External Ticket No.")));
                if (not Ticket.FindFirst()) then
                    Error(ILLEGAL_VALUE, TicketReference, TICKET_NUMBER);

                Ticket.TestField(Blocked, false);
                TicketRequestManager.GetTicketToken(Ticket."No.", Token);
            end else begin
                Token := TicketReference;
                Ticket."External Member Card No." := TicketRequest."External Member No.";
            end;
        end else begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token);
        end;

        if (Token <> '') then
            TicketRetailMgr.AcquireTicketParticipant(Token, Ticket."External Member Card No.", true);
    end;

    internal procedure ConvertToMembership(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ExternalTicketNumber: Code[50]; AdmissionCode: Code[20])
    var
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ReasonText: Text;

        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
        ItemIdentifierType: Option ItemNo,ItemCrossReference;
        Item: Record Item;
        ItemReference: Record "Item Reference";
        SaleLine: Codeunit "NPR POS Sale Line";
        LastLineNo: Integer;
    begin
        if (ExternalTicketNumber = '') then
            Error(ILLEGAL_VALUE, ExternalTicketNumber, TICKET_NUMBER);

        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(ExternalTicketNumber, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (not Ticket.FindFirst()) then
            Error(ILLEGAL_VALUE, ExternalTicketNumber, TICKET_NUMBER);

        Ticket.TestField(Blocked, false);
        TicketType.Get(Ticket."Ticket Type Code");
        TicketType.TestField("Membership Sales Item No.");

        if (not TicketManagement.CheckIfCanBeConsumed(Ticket."No.", AdmissionCode, TicketType."Membership Sales Item No.", ReasonText)) then
            Error(ReasonText);

        POSSession.GetSaleLine(SaleLine);
        LastLineNo := SaleLine.GetNextLineNo();

        POSActionInsertItemB.GetItem(Item,
                                     ItemReference,
                                     TicketType."Membership Sales Item No.",
                                     ItemIdentifierType);

        POSActionInsertItemB.AddItemLine(Item,
                                         ItemReference,
                                         ItemIdentifierType,
                                         1, //ItemQuantity,
                                         0, // UnitPrice,
                                         '', // CustomDescription,
                                         StrSubstNo('%1 / %2', ExternalTicketNumber, AdmissionCode), // CustomDescription2,
                                         '',
                                         POSSession,
                                         FrontEnd,
                                         '');

        if (LastLineNo = SaleLine.GetNextLineNo()) then
            Error('');

        if (not TicketManagement.CheckAndConsumeItem(Ticket."No.", AdmissionCode, TicketType."Membership Sales Item No.", ReasonText)) then
            Error(ReasonText);
    end;

    internal procedure RegisterDeparture(ExternalTicketNumber: Code[50]; AdmissionCode: Code[20])
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Admission: Record "NPR TM Admission";
    begin
        if (ExternalTicketNumber = '') then
            Error(ILLEGAL_VALUE, ExternalTicketNumber, TICKET_NUMBER);

        if (AdmissionCode <> '') then
            if (not Admission.Get(AdmissionCode)) then
                Error(INVALID_ADMISSION, 'Admission Code', AdmissionCode);

        TicketRequestManager.LockResources('RegisterDeparture');
        TicketManagement.ValidateTicketForDeparture("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, ExternalTicketNumber, AdmissionCode);
    end;


    internal procedure AddAdditionalExperience(POSSession: Codeunit "NPR POS Session"; TicketReference: Code[50])
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        SaleLinePOS: Record "NPR POS Sale Line";
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest, TicketRequest : Record "NPR TM Ticket Reservation Req.";
        NoExperiencesToConfigure: Label 'There are no additional experiences to configure for this ticket.';
        Token: Text[100];
        ResponseMessage: Text;
        HaveSalesTicket: Boolean;
    begin
        if (TicketReference <> '') then begin
            TicketRequest.SetCurrentKey("Session Token ID");
            TicketRequest.SetFilter("Session Token ID", '=%1', TicketReference);
            if (not TicketRequest.FindFirst()) then begin
                Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(Ticket."External Ticket No.")));
                if (not Ticket.FindFirst()) then
                    Error(ILLEGAL_VALUE, TicketReference, TICKET_NUMBER);

                Ticket.TestField(Blocked, false);
                TicketRequestManager.GetTicketToken(Ticket."No.", Token);
            end else begin
                Token := TicketReference;
            end;
            HaveSalesTicket := false;

        end else begin
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            GetRequestToken(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token);
            HaveSalesTicket := true;
        end;

        if (Token <> '') then begin
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationRequest.SetFilter("Admission Inclusion", '<>%1', TicketReservationRequest."Admission Inclusion"::REQUIRED);
            if (TicketReservationRequest.IsEmpty()) then
                Error(NoExperiencesToConfigure);

            AcquireAdditionalExperience(Ticket, POSSession, HaveSalesTicket, ResponseMessage);
        end;
    end;

    internal procedure ExchangeTicketForCoupon(POSSession: Codeunit "NPR POS Session"; ExternalTicketReference: Code[50]; CouponAlias: Code[20]; Response: JsonObject)
    var
        TicketToCoupon: Codeunit "NPR TM TicketToCoupon";
        CouponReferenceNo: Text[50];
        ExternalTicketNo: Code[30];
        ReasonCode: Integer;
        ReasonText: Text;
        CouponJson: JsonObject;
    begin
        if (ExternalTicketReference = '') then
            Error(ILLEGAL_VALUE, ExternalTicketReference, TICKET_NUMBER);

        if (StrLen(ExternalTicketReference) > 30) then // if > 30 it means it is a token (order number)
            Error(ILLEGAL_VALUE, ExternalTicketReference, TICKET_NUMBER);

        ExternalTicketNo := CopyStr(ExternalTicketReference, 1, MaxStrLen(ExternalTicketNo));
        if (not TicketToCoupon.ExchangeTicketForCoupon(ExternalTicketNo, CouponAlias, CouponReferenceNo, ReasonCode, ReasonText)) then
            Error(ReasonText);

        CouponJson.Add('reference_no', CouponReferenceNo);
        Response.Add('coupon', CouponJson);
    end;


    #endregion

    local procedure AddAdditionalExperienceRevokeLines(POSSession: Codeunit "NPR POS Session"; Ticket: Record "NPR TM Ticket"; SalesTicketNo: Code[20])
    var
        TMTicketReservationReq: Record "NPR TM Ticket Reservation Req.";

        Admission: Record "NPR TM Admission";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLine: Codeunit "NPR POS Sale Line";
    begin
        TMTicketReservationReq.Get(Ticket."Ticket Reservation Entry No.");

        TMTicketReservationReq.Reset();
        TMTicketReservationReq.SetRange("Session Token ID", TMTicketReservationReq."Session Token ID");
        TMTicketReservationReq.SetRange("Admission Inclusion", TMTicketReservationReq."Admission Inclusion"::SELECTED);

        if TMTicketReservationReq.FindSet() then
            repeat

                Admission.Get(TMTicketReservationReq."Admission Code");
                if Admission."Additional Experience Item No." <> '' then begin
                    SaleLinePOS."Sales Ticket No." := SalesTicketNo;
                    SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
                    SaleLinePOS."No." := Admission."Additional Experience Item No.";
                    SaleLinePOS.Description := Admission.Description;
                    SaleLinePOS.Quantity := -1;
                    SaleLinePOS."Unit Price" := GetOriginalPrice(TMTicketReservationReq."Receipt No.", TMTicketReservationReq."Line No.");
                    POSSession.GetSaleLine(SaleLine);
                    SaleLine.InsertLine(SaleLinePOS, false);
                end;

            until TMTicketReservationReq.Next() = 0;

    end;

    local procedure AcquireTicketAdmissionSchedule(Token: Text[100]; var SaleLinePOS: Record "NPR POS Sale Line"; HaveSalesLine: Boolean; var ResponseMessage: Text) LookupOK: Boolean
    var
        TicketRetailManagement: Codeunit "NPR TM Ticket Retail Mgt.";
    begin
        LookupOK := TicketRetailManagement.AcquireTicketAdmissionSchedule(Token, SaleLinePOS, HaveSalesLine, ResponseMessage);
        exit(LookupOK);
    end;

    local procedure AcquireAdditionalExperience(Ticket: Record "NPR TM Ticket"; POSSession: Codeunit "NPR POS Session"; HaveSalesLine: Boolean; var ResponseMessage: Text) LookupOK: Boolean
    var
        TicketRetailManagement: Codeunit "NPR TM Ticket Retail Mgt.";
    begin
        LookupOK := TicketRetailManagement.AcquireAdditionalExperiences(Ticket, POSSession, HaveSalesLine, ResponseMessage);
        exit(LookupOK);
    end;

    procedure GetRequestToken(ReceiptNo: Code[20]; LineNumber: Integer; var Token: Text[100]): Boolean
    var
        TokenLineNumber: Integer;
    begin
        exit(GetRequestToken(ReceiptNo, LineNumber, Token, TokenLineNumber));
    end;

    procedure GetRequestToken(ReceiptNo: Code[20]; LineNumber: Integer; var Token: Text[100]; var TokenLineNumber: Integer): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        Token := '';

        if (ReceiptNo = '') then
            exit(false);

        TicketReservationRequest.SetCurrentKey("Receipt No.");
        TicketReservationRequest.SetFilter("Receipt No.", '=%1', ReceiptNo);
        TicketReservationRequest.SetFilter("Line No.", '=%1', LineNumber);

        if (TicketReservationRequest.FindFirst()) then begin
            Token := TicketReservationRequest."Session Token ID";
            TokenLineNumber := TicketReservationRequest."Ext. Line Reference No.";
        end;

        exit(Token <> '');
    end;

    local procedure GetOriginalPrice(ReceiptNo: Code[20]; LineNo: Integer): Decimal
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("Document No.", ReceiptNo);
        POSEntrySalesLine.SetRange("Line No.", LineNo);
        if POSEntrySalesLine.FindFirst() then
            exit(POSEntrySalesLine."Amount Incl. VAT");
    end;

    internal procedure PickupPreConfirmedTicket(TicketReference: Code[50]; AllowPayment: Boolean; AllowUI: Boolean; AllowReprint: Boolean)
    var
        TempTicketsOut: Record "NPR TM Ticket" temporary;
    begin
        PickupPreConfirmedTicket(TicketReference, AllowPayment, AllowUI, AllowReprint, TempTicketsOut);
    end;

    internal procedure PickupPreConfirmedTicket(TicketReference: Code[50]; AllowPayment: Boolean; AllowUI: Boolean; AllowReprint: Boolean; var TempTickets: Record "NPR TM Ticket" temporary)
    var
        PickUpReservedTickets: Page "NPR TM Pick-Up Reserv. Tickets";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        PageAction: Action;
        Ticket: Record "NPR TM Ticket";
        ReservationFound: Boolean;
        TICKET_REFERENCE: Label 'Ticket Reference';
        MISSING_PAYMENT: Label 'Cannot pickup ticket. Reservation is missing payment';
        ConfirmPrintAll: Label 'Print all %1 ticket?';
        ListOfTokens: List of [Text[100]];
    begin
        if (not AllowUI) and (TicketReference = '') then
            Error('');

        ReservationFound := false;
        if (TicketReference <> '') then begin
            Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(Ticket."External Ticket No.")));
            if (Ticket.FindFirst()) then begin
                TicketReservationRequest.SetFilter("Entry No.", '=%1', Ticket."Ticket Reservation Entry No.");
                TicketReservationRequest.FindFirst();
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
                ReservationFound := TicketReservationRequest.FindFirst();
                if (ReservationFound) then
                    ListOfTokens.Add(TicketReservationRequest."Session Token ID");
            end;

            if (not ReservationFound) then begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetCurrentKey("External Order No.");
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', CopyStr(TicketReference, 1, MaxStrLen(TicketReservationRequest."Session Token ID")));
                ReservationFound := TicketReservationRequest.FindFirst();
                if (ReservationFound) then
                    ListOfTokens.Add(TicketReservationRequest."Session Token ID");
            end;

            if (not ReservationFound) then begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetCurrentKey("External Order No.");
                TicketReservationRequest.SetFilter("External Order No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(TicketReservationRequest."External Order No.")));
                ReservationFound := TicketReservationRequest.FindSet();
                if (ReservationFound) then
                    repeat
                        if (not ListOfTokens.Contains(TicketReservationRequest."Session Token ID")) then
                            ListOfTokens.Add(TicketReservationRequest."Session Token ID");
                    until (TicketReservationRequest.Next() = 0);
            end;

            if (not ReservationFound) then begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetFilter("External Member No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(TicketReservationRequest."External Member No.")));
                ReservationFound := TicketReservationRequest.FindLast();
                if (ReservationFound) then
                    ListOfTokens.Add(TicketReservationRequest."Session Token ID");
            end;
        end;

        if (not AllowUI) then begin
            if (not ReservationFound) then
                Error(ILLEGAL_VALUE, TicketReference, TICKET_REFERENCE);

            GetTickets(ListOfTokens, TempTickets);
            PrintTickets(TempTickets, AllowReprint);
            exit;
        end;

        if (AllowUI) then begin
            if (ListOfTokens.Count() = 0) then begin
                // Select token from list 
                TicketReservationRequest.Reset();
                PickUpReservedTickets.SetTableView(TicketReservationRequest);

                PickUpReservedTickets.LookupMode(true);
                PageAction := PickUpReservedTickets.RunModal();
                if (PageAction <> Action::LookupOK) then
                    exit;

                PickUpReservedTickets.GetRecord(TicketReservationRequest);
                if (not ListOfTokens.Contains(TicketReservationRequest."Session Token ID")) then
                    ListOfTokens.Add(TicketReservationRequest."Session Token ID");
            end;

            // if token is unpaid create pos sale lines to finish the reservation
            if (TicketReservationRequest."Payment Option" = TicketReservationRequest."Payment Option"::UNPAID) then begin
                if (not AllowPayment) then
                    Error(MISSING_PAYMENT);
                AddToPOS(ListOfTokens);
                exit; // Printing by end-of-sale routine
            end;

            // show list of tickets included on token
            GetTickets(ListOfTokens, TempTickets);
            if (TempTickets.Count() = 0) then
                exit;

            if (not Confirm(ConfirmPrintAll, true, TempTickets.Count())) then begin
                Page.Run(Page::"NPR TM Ticket List", TempTickets);
                exit;
            end;

            PrintTickets(TempTickets, AllowReprint);
        end;
    end;

    local procedure PrintTickets(var TempTickets: Record "NPR TM Ticket" temporary; AllowReprint: Boolean)
    var
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ReprintNotAllowed: Label 'Your order needs to be handled by customer services.';
    begin
        TempTickets.Reset();
        if (TempTickets.IsEmpty()) then
            exit;

        if (not AllowReprint) then
            TempTickets.SetFilter("Printed Date", '=%1', 0D);

        if (not TempTickets.FindSet()) then
            if (not AllowReprint) then
                Error(ReprintNotAllowed);

        repeat
            Ticket.Reset();
            Ticket.Get(TempTickets."No.");
            Ticket.SetRecFilter();
            TicketManagement.PrintTicketBatch(Ticket);
        until (TempTickets.Next() = 0);

    end;

    local procedure GetTickets(ListOfTokens: List of [Text[100]]; var TempTicketsOut: Record "NPR TM Ticket" temporary)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        Token: Text[100];
    begin
        foreach Token in ListOfTokens do begin
            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
            if (TicketReservationRequest.FindSet()) then
                repeat
                    Ticket.Reset();
                    Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                    if (Ticket.FindSet()) then
                        repeat
                            TempTicketsOut.TransferFields(Ticket, true);
                            if (not TempTicketsOut.Insert()) then;
                        until (Ticket.Next() = 0);
                until (TicketReservationRequest.Next() = 0);
        end;
    end;

    local procedure AddToPOS(ListOfTokens: List of [Text[100]])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePos: Record "NPR POS Sale Line";
        ListOfTicketSets: List of [Integer];
        Token: Text[100];
        TicketSetId: Integer;
    begin
        foreach Token in ListOfTokens do begin
            Clear(ListOfTicketSets);
            GetTicketSets(Token, ListOfTicketSets);

            foreach TicketSetId in ListOfTicketSets do begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetCurrentKey("Session Token ID");
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TicketSetId);
                TicketReservationRequest.SetFilter("Admission Inclusion", '=%1', TicketReservationRequest."Admission Inclusion"::REQUIRED);
                TicketReservationRequest.FindFirst();

                // Create POS sales lines which needs to be paid.
                POSSession.GetSaleLine(POSSaleLine);
                POSSaleLine.GetNewSaleLine(SaleLinePos);
                POSSaleLine.SetUsePresetLineNo(true);

                SaleLinePos."Line Type" := SaleLinePos."Line Type"::Item;
                SaleLinePos."No." := TicketReservationRequest."Item No.";
                SaleLinePos."Variant Code" := TicketReservationRequest."Variant Code";
                SaleLinePos.Quantity := TicketReservationRequest.Quantity;
                POSSaleLine.InsertLine(SaleLinePos);

                TicketReservationRequest.SetFilter("Admission Inclusion", '=%1', TicketReservationRequest."Admission Inclusion"::SELECTED);
                if (TicketReservationRequest.FindSet()) then begin
                    repeat
                        // Create POS sales lines for additional admissions that needs to be paid.
                        POSSession.GetSaleLine(POSSaleLine);
                        POSSaleLine.GetNewSaleLine(SaleLinePos);
                        POSSaleLine.SetUsePresetLineNo(true);

                        SaleLinePos."Line Type" := SaleLinePos."Line Type"::Item;
                        SaleLinePos."No." := TicketReservationRequest."Item No.";
                        SaleLinePos."Variant Code" := TicketReservationRequest."Variant Code";
                        SaleLinePos.Quantity := TicketReservationRequest.Quantity;
                        POSSaleLine.InsertLine(SaleLinePos);
                    until (TicketReservationRequest.Next() = 0);
                end;

                TicketReservationRequest2.SetCurrentKey("Session Token ID");
                TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
                TicketReservationRequest2.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
                TicketReservationRequest2.ModifyAll("Receipt No.", SaleLinePos."Sales Ticket No.");
                TicketReservationRequest2.ModifyAll("Line No.", SaleLinePos."Line No.");
                TicketReservationRequest2.ModifyAll("Request Status", TicketReservationRequest2."Request Status"::RESERVED);
            end;
        end;
    end;

    local procedure GetTicketSets(Token: Text[100]; TicketSet: List of [Integer])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                if (not TicketSet.Contains(TicketReservationRequest."Ext. Line Reference No.")) then
                    TicketSet.Add(TicketReservationRequest."Ext. Line Reference No.");
            until (TicketReservationRequest.Next() = 0);
        end;
    end;

    internal procedure GetTicketsFromOrderReference(OrderReference: Code[50]; var TempTickets: Record "NPR TM Ticket" temporary)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        if (not TempTickets.IsTemporary()) then
            Error('Parameter TempTickets is not declared temporary. This is a programming error.');

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("External Order No.");
        TicketReservationRequest.SetFilter("External Order No.", '=%1', CopyStr(OrderReference, 1, MaxStrLen(TicketReservationRequest."External Order No.")));
        if (TicketReservationRequest.FindSet()) then
            repeat
                Ticket.Reset();
                Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                if (Ticket.FindSet()) then
                    repeat
                        TempTickets.TransferFields(Ticket, true);
                        if TempTickets.Insert() then;
                    until (Ticket.Next() = 0);
            until (TicketReservationRequest.Next() = 0);

        if TempTickets.Count() <> 0 then
            exit;

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', CopyStr(OrderReference, 1, MaxStrLen(TicketReservationRequest."Session Token ID")));
        if (TicketReservationRequest.FindSet()) then
            repeat
                Ticket.Reset();
                Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                if (Ticket.FindSet()) then
                    repeat
                        TempTickets.TransferFields(Ticket, true);
                        if TempTickets.Insert() then;
                    until (Ticket.Next() = 0);
            until (TicketReservationRequest.Next() = 0);
    end;

}