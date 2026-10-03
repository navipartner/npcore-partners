/// <summary>
/// Anonymizes the ticket holder: the notification address becomes an undeliverable pseudonym and the
/// holder name is cleared, on the reservation and on everything derived from it.
/// </summary>
codeunit 6151233 "NPR TM Anonymize"
{
    Access = Internal;

    var
        _AnonymizedDomain: Label 'anonymized.invalid', Locked = true;
        _AnonymizedAddress: Text[100];
        _PreAssignedTicketNo: Text[30];
        _ScopeAddress: Text[100];
        _LineReferenceNo: Integer;
        _PendingTokens: List of [Text[100]];
        _ClearedTokens: List of [Text[100]];
        _TicketNumbers: Dictionary of [Code[20], Boolean];
        _ClearedTicketNumbers: Dictionary of [Code[20], Boolean];

    #region Resolving a holder
    internal procedure Anonymize(Token: Text[100]; var AffectedTickets: List of [Code[20]]): Text[100]
    begin
        exit(AnonymizeWorker(Token, '', '', 0, AffectedTickets));
    end;

    internal procedure AnonymizeRequest(TicketReservationRequest: Record "NPR TM Ticket Reservation Req."; var AffectedTickets: List of [Code[20]]): Text[100]
    var
        ScopeRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        ScopeRequest := TicketReservationRequest;
        ResolveScopeRequest(ScopeRequest);

        if (ScopeRequest.PreAssignedTicketNumber = '') then
            exit(AnonymizeWorker(ScopeRequest."Session Token ID", '', '', ScopeRequest."Ext. Line Reference No.", AffectedTickets));

        exit(AnonymizeWorker(
            ScopeRequest."Session Token ID",
            ScopeRequest.PreAssignedTicketNumber,
            ScopeRequest."Notification Address",
            0,
            AffectedTickets));
    end;

    /// <summary>
    /// A revoke row carries no holder of its own, so locate the origin request.
    /// </summary>
    local procedure ResolveScopeRequest(var ScopeRequest: Record "NPR TM Ticket Reservation Req.")
    var
        LinkedRequest: Record "NPR TM Ticket Reservation Req.";
        VisitedEntryNos: List of [Integer];
        Resolved: Boolean;
    begin
        while ((ScopeRequest.PreAssignedTicketNumber = '') and (not VisitedEntryNos.Contains(ScopeRequest."Entry No."))) do begin
            VisitedEntryNos.Add(ScopeRequest."Entry No.");

            Resolved := false;
            if (ScopeRequest."External Ticket Number" <> '') then
                Resolved := GetRequestOfTicket(ScopeRequest."External Ticket Number", LinkedRequest);

            if (not Resolved) then
                if (ScopeRequest."Superseeds Entry No." > 0) then
                    Resolved := LinkedRequest.Get(ScopeRequest."Superseeds Entry No.");

            if (not Resolved) then
                exit;

            ScopeRequest := LinkedRequest;
        end;
    end;

    /// <summary>
    /// The scope a clear started from this row would cover, so a caller clearing a selection can make one
    /// pass per holder.
    /// </summary>
    internal procedure GetHolderKey(TicketReservationRequest: Record "NPR TM Ticket Reservation Req.") HolderKey: Text
    var
        ScopeRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        ScopeRequest := TicketReservationRequest;
        ResolveScopeRequest(ScopeRequest);

        HolderKey := ScopeRequest."Session Token ID";
        if (ScopeRequest.PreAssignedTicketNumber = '') then
            exit(HolderKey + '|line:' + Format(ScopeRequest."Ext. Line Reference No."));

        // An address can be a phone number and a ticket number can be digits, so the two are labelled.
        if (ScopeRequest."Notification Address" <> '') then
            exit(HolderKey + '|address:' + LowerCase(ScopeRequest."Notification Address"));

        exit(HolderKey + '|ticket:' + ScopeRequest.PreAssignedTicketNumber);
    end;

    local procedure GetRequestOfTicket(ExternalTicketNo: Text[30]; var TicketReservationRequest: Record "NPR TM Ticket Reservation Req."): Boolean
    var
        Ticket: Record "NPR TM Ticket";
    begin
        Ticket.SetCurrentKey("External Ticket No.");
        Ticket.SetLoadFields("Ticket Reservation Entry No.");
        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNo);
        if (not Ticket.FindFirst()) then
            exit(false);

        exit(TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No."));
    end;

    internal procedure AnonymizeByExternalTicketNo(ExternalTicketNo: Code[30]; var AffectedTickets: List of [Code[20]]): Text[100]
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        Clear(AffectedTickets);
        if (ExternalTicketNo = '') then
            exit('');

        Ticket.SetCurrentKey("External Ticket No.");
        Ticket.SetLoadFields("Ticket Reservation Entry No.");
        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNo);
        if (not Ticket.FindFirst()) then
            exit('');

        if (not TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
            exit('');

        exit(AnonymizeRequest(TicketReservationRequest, AffectedTickets));
    end;

    #endregion

    #region Clearing a holder
    internal procedure GetAnonymizedAddress(Prefix: Text[100]) AnonymizedAddress: Text[100]
    var
        Domain: Text;
    begin
        Domain := '@' + _AnonymizedDomain;
        exit(CopyStr(CopyStr(LowerCase(Prefix), 1, MaxStrLen(AnonymizedAddress) - StrLen(Domain)) + Domain, 1, MaxStrLen(AnonymizedAddress)));
    end;

    local procedure AnonymizeWorker(Token: Text[100]; PreAssignedTicketNo: Text[30]; ScopeAddress: Text[100]; LineReferenceNo: Integer; var AffectedTickets: List of [Code[20]]): Text[100]
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        CurrentToken: Text[100];
        AffectedTicketNo: Code[20];
    begin
        Clear(AffectedTickets);
        if (Token = '') then
            exit('');

        _PreAssignedTicketNo := PreAssignedTicketNo;
        _ScopeAddress := ScopeAddress;
        _LineReferenceNo := LineReferenceNo;

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        ApplyRequestScope(TicketReservationRequest);
        if (TicketReservationRequest.IsEmpty()) then
            exit('');

        Clear(_PendingTokens);
        Clear(_ClearedTokens);
        Clear(_TicketNumbers);
        Clear(_ClearedTicketNumbers);

        _AnonymizedAddress := GetAnonymizedAddress(Token);
        _PendingTokens.Add(Token);

        while (_PendingTokens.Count() > 0) do begin
            CurrentToken := _PendingTokens.Get(1);
            _PendingTokens.RemoveAt(1);
            if (not _ClearedTokens.Contains(CurrentToken)) then begin
                _ClearedTokens.Add(CurrentToken);
                ClearReservationRequests(CurrentToken);
            end;
        end;

        ClearNotificationEntries();
        ClearParticipantWorksheet();
        ClearWaitingList();
        ClearImportArchive();

        foreach AffectedTicketNo in _ClearedTicketNumbers.Keys() do
            AffectedTickets.Add(AffectedTicketNo);

        exit(_AnonymizedAddress);
    end;

    local procedure IsScoped(): Boolean
    begin
        exit((_PreAssignedTicketNo <> '') or (_LineReferenceNo <> 0));
    end;

    local procedure ApplyRequestScope(var TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    begin
        // A reservation line carries its own holder, so a clear started from one ticket stops at that line.
        if (_LineReferenceNo <> 0) then
            TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', _LineReferenceNo);

        if (_PreAssignedTicketNo = '') then
            exit;

        if (_ScopeAddress <> '') then
            TicketReservationRequest.SetFilter("Notification Address", '=%1', _ScopeAddress)
        else
            TicketReservationRequest.SetFilter(PreAssignedTicketNumber, '=%1', _PreAssignedTicketNo);
    end;

    local procedure ClearReservationRequests(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        HasChanges: Boolean;
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        ApplyRequestScope(TicketReservationRequest);
        if (not TicketReservationRequest.FindSet(true)) then
            exit;

        repeat
            HasChanges := false;

            if (not (TicketReservationRequest."Notification Address" in ['', _AnonymizedAddress])) then begin
                TicketReservationRequest."Notification Address" := _AnonymizedAddress;
                TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::EMAIL;
                HasChanges := true;
            end;

            if (TicketReservationRequest.TicketHolderName <> '') then begin
                TicketReservationRequest.TicketHolderName := '';
                HasChanges := true;
            end;

            if (HasChanges) then
                TicketReservationRequest.Modify();

            CollectTickets(TicketReservationRequest."Entry No.", HasChanges);
            CollectSupersedeChain(TicketReservationRequest);

        until (TicketReservationRequest.Next() = 0);
    end;

    // The later passes run over every ticket in scope, while the caller is told which holders this run cleared.
    local procedure CollectTickets(RequestEntryNo: Integer; HolderCleared: Boolean)
    var
        Ticket: Record "NPR TM Ticket";
    begin
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetLoadFields("No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', RequestEntryNo);
        if (not Ticket.FindSet()) then
            exit;

        repeat
            _TicketNumbers.Set(Ticket."No.", true);
            if (HolderCleared) then
                _ClearedTicketNumbers.Set(Ticket."No.", true);
        until (Ticket.Next() = 0);
    end;

    // A ticket change copies the whole request row - holder included - onto a new reservation token.
    // Only a change link stays with the same holder: one revoke covers the tickets of many.
    local procedure CollectSupersedeChain(TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        LinkedRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        if (TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::CHANGE) then
            if (TicketReservationRequest."Superseeds Entry No." > 0) then
                if (LinkedRequest.Get(TicketReservationRequest."Superseeds Entry No.")) then
                    QueueToken(LinkedRequest."Session Token ID");

        LinkedRequest.Reset();
        LinkedRequest.SetCurrentKey("Superseeds Entry No.");
        LinkedRequest.SetLoadFields("Session Token ID");
        LinkedRequest.SetFilter("Superseeds Entry No.", '=%1', TicketReservationRequest."Entry No.");
        LinkedRequest.SetFilter("Entry Type", '=%1', LinkedRequest."Entry Type"::CHANGE);
        if (not LinkedRequest.FindSet()) then
            exit;

        repeat
            QueueToken(LinkedRequest."Session Token ID");
        until (LinkedRequest.Next() = 0);
    end;

    local procedure QueueToken(Token: Text[100])
    begin
        if (Token = '') then
            exit;
        if (_ClearedTokens.Contains(Token)) then
            exit;
        if (_PendingTokens.Contains(Token)) then
            exit;

        _PendingTokens.Add(Token);
    end;

    local procedure ClearNotificationEntries()
    var
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
        Token: Text[100];
        TicketNo: Code[20];
    begin
        // In a scoped clear a token sweep would reach the notifications of every other holder in the batch.
        if (not IsScoped()) then
            foreach Token in _ClearedTokens do begin
                TicketNotificationEntry.Reset();
                TicketNotificationEntry.SetCurrentKey("Ticket Token");
                TicketNotificationEntry.SetFilter("Ticket Token", '=%1', Token);
                ClearNotificationEntrySet(TicketNotificationEntry);
            end;

        // Stakeholder notifications are never stamped with a reservation token.
        foreach TicketNo in _TicketNumbers.Keys() do begin
            TicketNotificationEntry.Reset();
            TicketNotificationEntry.SetCurrentKey("Ticket No.", "Notification Send Status");
            TicketNotificationEntry.SetFilter("Ticket No.", '=%1', TicketNo);
            ClearNotificationEntrySet(TicketNotificationEntry);
        end;
    end;

    // The send status is part of the key being walked, so the row moves if it is updated in place.
    local procedure ClearNotificationEntrySet(var TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry")
    var
        NotificationEntryUpdate: Record "NPR TM Ticket Notif. Entry";
        HasChanges: Boolean;
    begin
        if (not TicketNotificationEntry.FindSet()) then
            exit;

        repeat
            if (NotificationEntryUpdate.Get(TicketNotificationEntry."Entry No.")) then begin
                HasChanges := false;

                // A stakeholder notification is the only one addressed to someone other than the holder.
                if (NotificationEntryUpdate."Notification Trigger" <> NotificationEntryUpdate."Notification Trigger"::STAKEHOLDER) then
                    if (not (NotificationEntryUpdate."Notification Address" in ['', _AnonymizedAddress])) then begin
                        NotificationEntryUpdate."Notification Address" := _AnonymizedAddress;
                        NotificationEntryUpdate."Notification Method" := NotificationEntryUpdate."Notification Method"::EMAIL;
                        NotificationEntryUpdate."Failed With Message" := '';
                        if (NotificationEntryUpdate."Notification Send Status" = NotificationEntryUpdate."Notification Send Status"::PENDING) then
                            NotificationEntryUpdate."Notification Send Status" := NotificationEntryUpdate."Notification Send Status"::CANCELED;
                        HasChanges := true;
                    end;

                if (not (NotificationEntryUpdate."Ticket Holder E-Mail" in ['', _AnonymizedAddress])) then begin
                    NotificationEntryUpdate."Ticket Holder E-Mail" := _AnonymizedAddress;
                    HasChanges := true;
                end;

                if (NotificationEntryUpdate."Ticket Holder Name" <> '') then begin
                    NotificationEntryUpdate."Ticket Holder Name" := '';
                    HasChanges := true;
                end;

                if (HasChanges) then
                    NotificationEntryUpdate.Modify();
            end;
        until (TicketNotificationEntry.Next() = 0);
    end;

    // A worksheet row exists only to drive a send, and an operator rebuilding the list already wipes these
    // wholesale.
    local procedure ClearParticipantWorksheet()
    var
        TicketParticipantWks: Record "NPR TM Ticket Particpt. Wks.";
        TicketNo: Code[20];
    begin
        foreach TicketNo in _TicketNumbers.Keys() do begin
            TicketParticipantWks.Reset();
            TicketParticipantWks.SetCurrentKey("Ticket No.");
            TicketParticipantWks.SetFilter("Ticket No.", '=%1', TicketNo);
            TicketParticipantWks.DeleteAll();
        end;
    end;

    local procedure ClearWaitingList()
    var
        TicketWaitingList: Record "NPR TM Ticket Wait. List";
        ReservationToken: Text[100];
    begin
        // A waiting list entry is held against the reservation, not against one of its tickets.
        if (IsScoped()) then
            exit;

        // An entry exists to notify someone when capacity frees, which a cleared holder can no longer be.
        foreach ReservationToken in _ClearedTokens do begin
            TicketWaitingList.Reset();
            TicketWaitingList.SetCurrentKey(Token);
            TicketWaitingList.SetFilter(Token, '=%1', ReservationToken);
            TicketWaitingList.DeleteAll(true);
        end;
    end;

    local procedure ClearImportArchive()
    var
        ImportTicketHeader: Record "NPR TM ImportTicketHeader";
        ReservationToken: Text[100];
        HeaderInScope: Boolean;
    begin
        foreach ReservationToken in _ClearedTokens do begin
            ImportTicketHeader.Reset();
            ImportTicketHeader.SetCurrentKey(TicketRequestToken);
            ImportTicketHeader.SetFilter(TicketRequestToken, '=%1', ReservationToken);
            if (ImportTicketHeader.FindSet(true)) then
                repeat
                    HeaderInScope := IsImportHeaderInScope(ImportTicketHeader);
                    if (HeaderInScope) then
                        ClearImportHeader(ImportTicketHeader);
                    ClearImportLines(ImportTicketHeader.OrderId, ImportTicketHeader.JobId, HeaderInScope);
                until (ImportTicketHeader.Next() = 0);
        end;
    end;

    local procedure ClearImportHeader(var ImportTicketHeader: Record "NPR TM ImportTicketHeader")
    var
        HasChanges: Boolean;
    begin
        if (not (ImportTicketHeader.TicketHolderEMail in ['', _AnonymizedAddress])) then begin
            ImportTicketHeader.TicketHolderEMail := _AnonymizedAddress;
            HasChanges := true;
        end;

        if (ImportTicketHeader.TicketHolderName <> '') then begin
            ImportTicketHeader.TicketHolderName := '';
            HasChanges := true;
        end;

        if (HasChanges) then
            ImportTicketHeader.Modify();
    end;

    local procedure ClearImportLines(OrderIdParam: Code[20]; JobIdParam: Code[40]; HeaderInScope: Boolean)
    var
        ImportTicketLine: Record "NPR TM ImportTicketLine";
        HasChanges: Boolean;
    begin
        ImportTicketLine.SetFilter(OrderId, '=%1', OrderIdParam);
        ImportTicketLine.SetFilter(JobId, '=%1', JobIdParam);
        if (IsScoped() and (_ScopeAddress = '')) then
            ImportTicketLine.SetFilter(PreAssignedTicketNumber, '=%1', _PreAssignedTicketNo);
        if (not ImportTicketLine.FindSet(true)) then
            exit;

        repeat
            if (IsImportLineInScope(ImportTicketLine, HeaderInScope)) then begin
                HasChanges := false;

                if (not (ImportTicketLine.TicketHolderEMail in ['', _AnonymizedAddress])) then begin
                    ImportTicketLine.TicketHolderEMail := _AnonymizedAddress;
                    HasChanges := true;
                end;

                if (ImportTicketLine.TicketHolderName <> '') then begin
                    ImportTicketLine.TicketHolderName := '';
                    HasChanges := true;
                end;

                if (HasChanges) then
                    ImportTicketLine.Modify();
            end;
        until (ImportTicketLine.Next() = 0);
    end;

    // The header carries the buyer of the order, not the holder of any one ticket.
    local procedure IsImportHeaderInScope(ImportTicketHeader: Record "NPR TM ImportTicketHeader"): Boolean
    begin
        if (not IsScoped()) then
            exit(true);

        if (_ScopeAddress = '') then
            exit(false);

        exit(LowerCase(ImportTicketHeader.TicketHolderEMail) = LowerCase(_ScopeAddress));
    end;

    // The import row keeps the address as it arrived while the request keeps it normalized.
    local procedure IsImportLineInScope(ImportTicketLine: Record "NPR TM ImportTicketLine"; HeaderInScope: Boolean): Boolean
    begin
        if (not IsScoped()) then
            exit(true);

        if (_ScopeAddress = '') then
            exit(ImportTicketLine.PreAssignedTicketNumber = _PreAssignedTicketNo);

        // A line without an e-mail of its own had the header's filled into its reservation at import.
        if (ImportTicketLine.TicketHolderEMail = '') then
            exit(HeaderInScope);

        exit(LowerCase(ImportTicketLine.TicketHolderEMail) = LowerCase(_ScopeAddress));
    end;
    #endregion
}
