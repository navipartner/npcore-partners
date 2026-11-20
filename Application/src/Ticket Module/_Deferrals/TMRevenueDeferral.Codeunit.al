codeunit 6184739 "NPR TM RevenueDeferral"
{
    Access = Internal;

    trigger OnRun()

    begin
        ProcessBatch();
    end;

    internal procedure ProcessBatch()
    begin
        // A batch of 500 requests bounds how many rows one posting transaction keeps locked until it commits.
        ProcessBatch(500);
    end;

    internal procedure ProcessBatch(PendingDeferralBatchSize: Integer)
    var
        InvalidBatchSizeErr: Label 'Pending deferral batch size %1 must be at least 1. This is a programming bug.', Locked = true;
    begin
        if (PendingDeferralBatchSize < 1) then
            Error(InvalidBatchSizeErr, PendingDeferralBatchSize);

        ProcessStatusRegistered();
        ProcessStatusPendingDeferral(PendingDeferralBatchSize);
    end;

    internal procedure DeleteDeferralRequests(TicketAccessEntryNos: List of [Integer])
    var
        Detail: Record "NPR TM DeferRevenueReqDetail";
        InnerDetail: Record "NPR TM DeferRevenueReqDetail";
        TempDetailKeys: Record "NPR TM DeferRevenueReqDetail" temporary;
        Request: Record "NPR TM DeferRevenueRequest";
        TicketAccessEntryNo: Integer;
    begin
        if (TicketAccessEntryNos.Count() = 0) then
            exit;

        // Phase 1: collect every detail PK across the batch into the temp buffer (records stay in scope).
        Detail.SetCurrentKey(TicketAccessEntryNo);
        Detail.SetLoadFields(TokenID, ItemNo, VariantCode, AdmissionCode, EntryNo);
        foreach TicketAccessEntryNo in TicketAccessEntryNos do begin
            if (not (TicketAccessEntryNo = 0)) then begin
                Detail.SetFilter(TicketAccessEntryNo, '=%1', TicketAccessEntryNo);
                if (Detail.FindSet()) then
                    repeat
                        TempDetailKeys := Detail;
                        TempDetailKeys.Insert();
                    until (Detail.Next() = 0);
            end;
        end;

        // Phase 2: point-delete every detail row from the temp buffer.
        TempDetailKeys.Reset();
        if (TempDetailKeys.FindSet()) then
            repeat
                if (InnerDetail.Get(TempDetailKeys.TokenID, TempDetailKeys.ItemNo, TempDetailKeys.VariantCode, TempDetailKeys.AdmissionCode, TempDetailKeys.EntryNo)) then
                    InnerDetail.Delete(false);
            until (TempDetailKeys.Next() = 0);

        // Phase 3: point-delete every request row.
        foreach TicketAccessEntryNo in TicketAccessEntryNos do
            if (TicketAccessEntryNo <> 0) then
                if (Request.Get(TicketAccessEntryNo)) then
                    Request.Delete(false);
    end;

    internal procedure DeleteDeferralRequests(var FilteredRequest: Record "NPR TM DeferRevenueRequest")
    var
        TicketAccessEntryNos: List of [Integer];
    begin
        if (not FilteredRequest.HasFilter()) then
            exit;

        FilteredRequest.SetLoadFields(TicketAccessEntryNo);
        if (FilteredRequest.FindSet()) then
            repeat
                TicketAccessEntryNos.Add(FilteredRequest.TicketAccessEntryNo);
            until (FilteredRequest.Next() = 0);

        DeleteDeferralRequests(TicketAccessEntryNos);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    internal procedure ProcessOne(DeferRevenueRequest: Record "NPR TM DeferRevenueRequest")
    var
        TempRevenueRecognitionBuffer: Record "NPR TM RevenuePostingBuffer" temporary;
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        InitializeRevenueRequest(DeferRevenueRequest, DeferRevenueRequest.SalesDate);
        ProcessOneStatusRegistered(DeferRevenueRequest);
        if (ProcessOneStatusPendingDeferral(DeferRevenueRequest)) then
            AggregateDeferrals(DeferRevenueRequest, TempRevenueRecognitionBuffer);
        DeferRevenueRequest.Modify();

        // Create posting journal lines from the aggregation buffer
        CreateJournalLines(TempRevenueRecognitionBuffer, TempGenJournalLine);

        // Post Journal
        TempGenJournalLine.Reset();
        if (TempGenJournalLine.FindSet()) then
            repeat
                GenJnlPostLine.Run(TempGenJournalLine);
            until (TempGenJournalLine.Next() = 0);
    end;

    internal procedure AddAllTicketsToDeferral(TicketTypeCode: Code[20]; FromTicketIssuedDate: Date) TicketCount: Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        StatusMessage: Label 'Evaluating %1 tickets for %2 to be added to deferral: %3(%) completed.', MaxLength = 80;
        Window: Dialog;
        MaxCount: Integer;
        CurrentCount: Integer;
        HaveWindow: Boolean;
        PctComplete: Integer;
    begin
        // Get all tickets of the specified type issued after the specified date
        // and create a deferral request for each of them
        Ticket.SetFilter("Ticket Type Code", '=%1', TicketTypeCode);
        Ticket.SetFilter("Document Date", '>=%1', FromTicketIssuedDate);
        if (not Ticket.FindSet(true)) then
            exit;

        PctComplete := 0;
        MaxCount := Ticket.Count();
        if (GuiAllowed()) then begin
            if (MaxCount > 100) then begin
                Window.Open('#1#########################################################################################################################');
                HaveWindow := true;
            end;
        end;

        repeat
            TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
            if (TicketAccessEntry.FindSet()) then
                repeat
                    if (CreateDeferRevenueRequest(TicketAccessEntry."Entry No.", Ticket."Document Date")) then
                        TicketCount += 1;
                until (TicketAccessEntry.Next() = 0);

            CurrentCount += 1;
            if (CurrentCount mod 100 = 0) then begin
                PctComplete := Round(100 * CurrentCount / MaxCount, 1);
                if (HaveWindow) then
                    Window.Update(1, StrSubstNo(StatusMessage, MaxCount, TicketTypeCode, Format(PctComplete, 0, 9)));
            end;
        until (Ticket.Next() = 0);

        if (HaveWindow) then
            Window.Close();
    end;

    internal procedure CreateDeferRevenueRequest(TicketAccessEntryNo: Integer;
EventDate: Date) ValidRequest: Boolean
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        if (DeferRevenueRequest.Get(TicketAccessEntryNo)) then
            exit;

        DeferRevenueRequest.TicketAccessEntryNo := TicketAccessEntryNo;
        DeferRevenueRequest.Status := DeferRevenueRequest.Status::REGISTERED;
        ValidRequest := InitializeRevenueRequest(DeferRevenueRequest, EventDate);
        if (ValidRequest) then
            DeferRevenueRequest.Insert();
    end;

    internal procedure InitializeRevenueRequest(var DeferRevenueRequest: Record "NPR TM DeferRevenueRequest"; SalesDate: Date): Boolean
    var
        TicketType: Record "NPR TM Ticket Type";
        Ticket: Record "NPR TM Ticket";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetailedTicketEntry: Record "NPR TM Det. Ticket AccessEntry";
        ScheduledEntry: Record "NPR TM Admis. Schedule Entry";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        if (DeferRevenueRequest.Status <> DeferRevenueRequest.Status::REGISTERED) then
            exit;

        TicketAccessEntry.SetLoadFields("Ticket No.", "Admission Code");
        if (not TicketAccessEntry.Get(DeferRevenueRequest.TicketAccessEntryNo)) then
            exit;

        Ticket.SetLoadFields("No.", "Ticket Type Code", "Item No.", "Variant Code", "Ticket Reservation Entry No.", "Valid To Date");
        if (not Ticket.Get(TicketAccessEntry."Ticket No.")) then
            exit;

        TicketType.SetLoadFields("Code", "Defer Revenue", "DeferRevenueProfileCode", "Admission Registration");
        if (not TicketType.Get(Ticket."Ticket Type Code")) then
            exit;

        if ((not TicketType."Defer Revenue") or (TicketType.DeferRevenueProfileCode = '')) then
            exit;

        TicketBOM.SetLoadFields("Item No.", "Variant Code", "Admission Code", DeferRevenue);
        if (not TicketBOM.Get(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code")) then
            exit;

        if (not TicketBOM.DeferRevenue) then
            exit;

        TicketRequest.SetLoadFields("Session Token ID", "Ext. Line Reference No.");
        if (not TicketRequest.Get(Ticket."Ticket Reservation Entry No.")) then
            exit;

        DeferRevenueRequest.TicketNo := Ticket."No.";
        DeferRevenueRequest.ReservationRequestEntryNo := Ticket."Ticket Reservation Entry No.";
        DeferRevenueRequest.TokenID := TicketRequest."Session Token ID";
        DeferRevenueRequest.TokenLineNo := TicketRequest."Ext. Line Reference No.";
        DeferRevenueRequest.AdmissionCode := TicketAccessEntry."Admission Code";
        DeferRevenueRequest.ItemNo := Ticket."Item No.";
        DeferRevenueRequest.VariantCode := Ticket."Variant Code";
        DeferRevenueRequest.TicketValidUntil := Ticket."Valid To Date";
        DeferRevenueRequest.DeferRevenueProfileCode := TicketType.DeferRevenueProfileCode;
        DeferRevenueRequest.SalesDate := SalesDate;
        DeferRevenueRequest.IsGroupTicket := TicketType."Admission Registration" = TicketType."Admission Registration"::GROUP;

        DetailedTicketEntry.SetCurrentKey("Ticket Access Entry No.", Type);
        DetailedTicketEntry.SetLoadFields("External Adm. Sch. Entry No.", Quantity);
        DetailedTicketEntry.SetFilter("Ticket Access Entry No.", '=%1', DeferRevenueRequest.TicketAccessEntryNo);
        DetailedTicketEntry.SetFilter(Type, '=%1', DetailedTicketEntry.Type::RESERVATION);
        DetailedTicketEntry.SetFilter(Quantity, '>%1', 0);
        if (DetailedTicketEntry.FindFirst()) then begin
            ScheduledEntry.SetCurrentKey("External Schedule Entry No.");
            ScheduledEntry.SetFilter("External Schedule Entry No.", '=%1', DetailedTicketEntry."External Adm. Sch. Entry No.");
            ScheduledEntry.SetFilter(Cancelled, '=%1', false);
            if (ScheduledEntry.FindFirst()) then
                DeferRevenueRequest.TicketValidUntil := ScheduledEntry."Admission End Date";
        end;

        exit(true);
    end;

    internal procedure ReadyToRecognize(TicketAccessEntryNo: Integer; EventDate: Date)
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        if (not DeferRevenueRequest.Get(TicketAccessEntryNo)) then
            exit;

        if (DeferRevenueRequest.Status = DeferRevenueRequest.Status::WAITING) then
            DeferRevenueRequest.Status := DeferRevenueRequest.Status::PENDING_DEFERRAL;
        DeferRevenueRequest.AchievedDate := EventDate;
        DeferRevenueRequest.Modify();
    end;

    internal procedure AbortDeferral(TicketNo: Code[20])
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        DeferRevenueRequest.SetCurrentKey(TicketNo);
        DeferRevenueRequest.SetFilter(TicketNo, '=%1', TicketNo);
        if (DeferRevenueRequest.FindSet()) then begin
            repeat
                if (not (DeferRevenueRequest.Status in [DeferRevenueRequest.Status::DEFERRED, DeferRevenueRequest.Status::DEFERRED_FORCED])) then begin
                    DeferRevenueRequest.Status := DeferRevenueRequest.Status::DEFERRAL_ABORTED;
                    DeferRevenueRequest.Modify();
                end;
            until (DeferRevenueRequest.Next() = 0);
        end;
    end;

    local procedure ProcessStatusRegistered()
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        RunDate: Date;
    begin
        // Dress the request with all possible intermediary information 
        // Requests are locked and committed one reservation token at a time, so the batch never holds locks on the whole status range.
        RunDate := Today();

        DeferRevenueRequest.SetFilter(Status, '=%1', DeferRevenueRequest.Status::REGISTERED);
        ProcessRegisteredByToken(DeferRevenueRequest, false, RunDate);

        // A WAITING request only changes state once its ticket has expired or been admitted.
        DeferRevenueRequest.SetFilter(Status, '=%1', DeferRevenueRequest.Status::WAITING);
        ProcessRegisteredByToken(DeferRevenueRequest, true, RunDate);
    end;

    local procedure ProcessRegisteredByToken(var CandidateRequest: Record "NPR TM DeferRevenueRequest"; DueOnly: Boolean; RunDate: Date)
    var
        EntryNosByToken: Dictionary of [Text, List of [Integer]];
        TokenIDs: List of [Text];
        EntryNos: List of [Integer];
        TokenID: Text;
        TicketAccessEntryNo: Integer;
    begin
        CandidateRequest.ReadIsolation := IsolationLevel::ReadCommitted;
        CandidateRequest.SetCurrentKey(Status);
        CandidateRequest.SetLoadFields(TicketAccessEntryNo, TokenID, TicketValidUntil, AchievedDate);
        if (not CandidateRequest.FindSet()) then
            exit;

        repeat
            if ((not DueOnly) or (CandidateRequest.TicketValidUntil < RunDate) or (CandidateRequest.AchievedDate <> 0D)) then
                AddEntryNoToGroup(EntryNosByToken, TokenIDs, CandidateRequest.TokenID, CandidateRequest.TicketAccessEntryNo);
        until (CandidateRequest.Next() = 0);

        foreach TokenID in TokenIDs do begin
            EntryNosByToken.Get(TokenID, EntryNos);
            foreach TicketAccessEntryNo in EntryNos do
                ProcessRegisteredRequest(TicketAccessEntryNo);
            Commit();
        end;
    end;

    local procedure AddEntryNoToGroup(var EntryNosByGroup: Dictionary of [Text, List of [Integer]]; var GroupKeys: List of [Text]; GroupKey: Text; TicketAccessEntryNo: Integer)
    var
        EntryNos: List of [Integer];
    begin
        // A fresh list per call, written back with Set, keeps groups apart whether the list is copied or shared by reference.
        // GroupKeys keeps the groups in first-seen order, because a Dictionary has no defined order.
        if (EntryNosByGroup.ContainsKey(GroupKey)) then
            EntryNos := EntryNosByGroup.Get(GroupKey)
        else
            GroupKeys.Add(GroupKey);
        EntryNos.Add(TicketAccessEntryNo);
        EntryNosByGroup.Set(GroupKey, EntryNos);
    end;

    local procedure ProcessRegisteredRequest(TicketAccessEntryNo: Integer)
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        DeferRevenueRequest.ReadIsolation := IsolationLevel::UpdLock;
        if (not DeferRevenueRequest.Get(TicketAccessEntryNo)) then
            exit;

        // The status may have moved on since the unlocked candidate read.
        if (not (DeferRevenueRequest.Status in [DeferRevenueRequest.Status::REGISTERED, DeferRevenueRequest.Status::WAITING])) then
            exit;

        ProcessOneStatusRegistered(DeferRevenueRequest);
        DeferRevenueRequest.Modify();
    end;

    local procedure ProcessStatusPendingDeferral(BatchSize: Integer)
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        EntryNosByDocument: Dictionary of [Text, List of [Integer]];
        DocumentNos: List of [Text];
        DocumentEntryNos: List of [Integer];
        BatchEntryNos: List of [Integer];
        DocumentNo: Text;
        TicketAccessEntryNo: Integer;
    begin
        // The candidate read holds no locks. Requests are posted and committed in batches of whole source documents,
        // and a document larger than a batch is split, so a batch never locks more than BatchSize requests.
        DeferRevenueRequest.ReadIsolation := IsolationLevel::ReadCommitted;
        DeferRevenueRequest.SetCurrentKey(Status);
        DeferRevenueRequest.SetFilter(Status, '=%1', DeferRevenueRequest.Status::PENDING_DEFERRAL);
        DeferRevenueRequest.SetLoadFields(TicketAccessEntryNo, SourceDocumentNo);
        if (not DeferRevenueRequest.FindSet()) then
            exit;

        repeat
            AddEntryNoToGroup(EntryNosByDocument, DocumentNos, DeferRevenueRequest.SourceDocumentNo, DeferRevenueRequest.TicketAccessEntryNo);
        until (DeferRevenueRequest.Next() = 0);

        foreach DocumentNo in DocumentNos do begin
            EntryNosByDocument.Get(DocumentNo, DocumentEntryNos);
            if (BatchEntryNos.Count() + DocumentEntryNos.Count() > BatchSize) then
                PostAndCommitBatch(BatchEntryNos);

            foreach TicketAccessEntryNo in DocumentEntryNos do begin
                BatchEntryNos.Add(TicketAccessEntryNo);
                if (BatchEntryNos.Count() >= BatchSize) then
                    PostAndCommitBatch(BatchEntryNos);
            end;
        end;

        PostAndCommitBatch(BatchEntryNos);
    end;

    local procedure PostAndCommitBatch(var BatchEntryNos: List of [Integer])
    begin
        if (BatchEntryNos.Count() = 0) then
            exit;

        CalculateDeferralAndPost(BatchEntryNos);
        Commit();
        Clear(BatchEntryNos);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure CalculateDeferralAndPost(TicketAccessEntryNos: List of [Integer])
    var
        DeferRevenueRequestUpdate: Record "NPR TM DeferRevenueRequest";
        TempRevenueRecognitionBuffer: Record "NPR TM RevenuePostingBuffer" temporary;
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        TicketAccessEntryNo: Integer;
    begin
        // Dress the request with all possible intermediary information 
        // The requests of the batch stay locked until the caller commits the batch.
        // Refresh postings details and aggregate
        DeferRevenueRequestUpdate.ReadIsolation := IsolationLevel::UpdLock;
        foreach TicketAccessEntryNo in TicketAccessEntryNos do
            if (DeferRevenueRequestUpdate.Get(TicketAccessEntryNo)) then begin
                if (ProcessOneStatusPendingDeferral(DeferRevenueRequestUpdate)) then
                    AggregateDeferrals(DeferRevenueRequestUpdate, TempRevenueRecognitionBuffer);
                DeferRevenueRequestUpdate.Modify();
            end;

        // Create posting journal lines from the aggregation buffer
        CreateJournalLines(TempRevenueRecognitionBuffer, TempGenJournalLine);

        // Post Journal
        TempGenJournalLine.Reset();
        if (TempGenJournalLine.FindSet()) then
            repeat
                GenJnlPostLine.Run(TempGenJournalLine);
            until (TempGenJournalLine.Next() = 0);
    end;

    local procedure ProcessOneStatusRegistered(var DeferRevenueRequest: Record "NPR TM DeferRevenueRequest") Handled: Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        DeferRevenueProfile: Record "NPR TM DeferRevenueProfile";
    begin
        Handled := False;
        if (DeferRevenueRequest.Status in [DeferRevenueRequest.Status::UNRESOLVED, DeferRevenueRequest.Status::DEFERRED, DeferRevenueRequest.Status::DEFERRED_FORCED, DeferRevenueRequest.Status::IMMEDIATE, DeferRevenueRequest.Status::DEFERRAL_ABORTED]) then
            exit;

        if (not TicketReservationRequest.Get(DeferRevenueRequest.ReservationRequestEntryNo)) then
            exit;

        case (TicketReservationRequest."Payment Option") of
            TicketReservationRequest."Payment Option"::DIRECT:
                begin
                    DeferRevenueRequest.PaymentOption := DeferRevenueRequest.PaymentOption::DIRECT;
                    Handled := ResolveAsPosTransaction(DeferRevenueRequest, TicketReservationRequest);
                end;
            TicketReservationRequest."Payment Option"::PREPAID:
                begin
                    DeferRevenueRequest.PaymentOption := DeferRevenueRequest.PaymentOption::PREPAID;
                    Handled := ResolveAsDocumentTransaction(DeferRevenueRequest, TicketReservationRequest);
                end;
            TicketReservationRequest."Payment Option"::POSTPAID:
                begin
                    DeferRevenueRequest.PaymentOption := DeferRevenueRequest.PaymentOption::POSTPAID;
                    Handled := ResolveAsDocumentTransaction(DeferRevenueRequest, TicketReservationRequest);
                end;
            TicketReservationRequest."Payment Option"::UNPAID:
                begin
                    DeferRevenueRequest.PaymentOption := DeferRevenueRequest.PaymentOption::UNPAID;
                    Handled := false;
                end;
            else begin
                DeferRevenueRequest.PaymentOption := DeferRevenueRequest.PaymentOption::UNKNOWN;
                Handled := false;
            end;
        end;

        if (Handled) then begin
            DeferRevenueRequest.Status := DeferRevenueRequest.Status::WAITING;
            if (DeferRevenueRequest.AchievedDate <> 0D) then
                DeferRevenueRequest.Status := DeferRevenueRequest.Status::PENDING_DEFERRAL;

            if (DeferRevenueRequest.TicketValidUntil < Today()) then
                DeferRevenueRequest.Status := DeferRevenueRequest.Status::PENDING_DEFERRAL;

            // Crediting return for an admitted ticket is assumed to be on same day as the original admission
            if (DeferRevenueRequest.AmountToDefer <= 0) then
                DeferRevenueRequest.Status := DeferRevenueRequest.Status::IMMEDIATE;
        end;

        if (not Handled) then begin
            if (not DeferRevenueProfile.Get(DeferRevenueRequest.DeferRevenueProfileCode)) then
                DeferRevenueProfile.Init();
            DeferRevenueRequest.AttemptedRegisterCount += 1;
            if (DeferRevenueRequest.AttemptedRegisterCount >= DeferRevenueProfile.MaxAttempts) then
                DeferRevenueRequest.Status := DeferRevenueRequest.Status::UNRESOLVED;
        end;
    end;

    local procedure ProcessOneStatusPendingDeferral(var DeferRevenueRequest: Record "NPR TM DeferRevenueRequest"): Boolean
    begin
        if (DeferRevenueRequest.Status <> DeferRevenueRequest.Status::PENDING_DEFERRAL) then
            exit;

        exit(SelectAccounts(DeferRevenueRequest));
    end;

    local procedure AggregateDeferrals(var DeferRevenueRequest: Record "NPR TM DeferRevenueRequest"; var RevenueRecognitionBuffer: Record "NPR TM RevenuePostingBuffer")
    var
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NumberSeries: Codeunit "No. Series";
#ELSE
        NumberSeries: Codeunit NoSeriesManagement;
#ENDIF
        DeferRevenueProfile: Record "NPR TM DeferRevenueProfile";
        MissingNumberSeries: Label 'Ticket Deferral: %1 %2 requires %3 in %4 %5';
        SourceDocNo: Code[20];
        DeferToDate: Date;
    begin
        if (DeferRevenueRequest.Status <> DeferRevenueRequest.Status::PENDING_DEFERRAL) then
            exit;

        if (DeferRevenueRequest.AmountToDefer <= 0) then begin
            DeferRevenueRequest.Status := DeferRevenueRequest.Status::IMMEDIATE;
            exit;
        end;

        if ((DeferRevenueRequest.OriginalSalesAccount = DeferRevenueRequest.AchievedRevenueAccount) and
            (DeferRevenueRequest.SalesDate = DeferRevenueRequest.AchievedDate)) then begin
            DeferRevenueRequest.Status := DeferRevenueRequest.Status::IMMEDIATE;
            exit;
        end;

        DeferRevenueProfile.Get(DeferRevenueRequest.DeferRevenueProfileCode);
        if (DeferRevenueProfile.PostingMode <> DeferRevenueProfile.PostingMode::INLINE) then
            if (DeferRevenueProfile.NoSeries = '') then
                Error(MissingNumberSeries, DeferRevenueProfile.FieldCaption(PostingMode), DeferRevenueProfile.PostingMode, DeferRevenueProfile.FieldCaption(NoSeries), DeferRevenueProfile.TableCaption(), DeferRevenueProfile.DeferRevenueProfileCode);

        SourceDocNo := DeferRevenueRequest.SourceDocumentNo;
        if (DeferRevenueProfile.PostingMode = DeferRevenueProfile.PostingMode::COMPRESSED) then
            SourceDocNo := '';

        DeferToDate := DeferRevenueRequest.AchievedDate;
        if (DeferToDate = 0D) then
            DeferToDate := DeferRevenueRequest.TicketValidUntil;

        if (DeferToDate = 0D) then
            exit;

        if (not RevenueRecognitionBuffer.Get(
                DeferRevenueRequest.DeferRevenueProfileCode,
                DeferRevenueRequest.OriginalSalesAccount,
                DeferRevenueRequest.AchievedRevenueAccount,
                DeferRevenueRequest.DimensionSetID,
                DeferRevenueRequest.SourcePostingDate,
                DeferToDate,
                SourceDocNo)) then begin

            RevenueRecognitionBuffer.Init();
            RevenueRecognitionBuffer.DeferRevenueProfileCode := DeferRevenueRequest.DeferRevenueProfileCode;
            RevenueRecognitionBuffer.SalesAccount := DeferRevenueRequest.OriginalSalesAccount;
            RevenueRecognitionBuffer.AchievedAccount := DeferRevenueRequest.AchievedRevenueAccount;
            RevenueRecognitionBuffer.DimensionSetId := DeferRevenueRequest.DimensionSetID;
            RevenueRecognitionBuffer.SalesPostingDate := DeferRevenueRequest.SourcePostingDate;
            RevenueRecognitionBuffer.AchievedPostingDate := DeferToDate;
            RevenueRecognitionBuffer.SourceDocumentNo := SourceDocNo;
            RevenueRecognitionBuffer.Amount := 0;

            if (DeferRevenueProfile.PostingMode = DeferRevenueProfile.PostingMode::INLINE) then
                RevenueRecognitionBuffer.DocumentNo := DeferRevenueRequest.SourceDocumentNo
            else
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                RevenueRecognitionBuffer.DocumentNo := NumberSeries.GetNextNo(DeferRevenueProfile.NoSeries, Today(), false);
#ELSE
                RevenueRecognitionBuffer.DocumentNo := NumberSeries.GetNextNo(DeferRevenueProfile.NoSeries, Today(), true);
#ENDIF

            RevenueRecognitionBuffer.Insert();
        end;

        RevenueRecognitionBuffer.Amount += DeferRevenueRequest.AmountToDefer;
        RevenueRecognitionBuffer.Modify();

        DeferRevenueRequest.Status := DeferRevenueRequest.Status::DEFERRED;
        if (DeferRevenueRequest.AchievedDate = 0D) then
            DeferRevenueRequest.Status := DeferRevenueRequest.Status::DEFERRED_FORCED;

        DeferRevenueRequest.DeferralDocumentNo := RevenueRecognitionBuffer.DocumentNo;
        DeferRevenueRequest.DeferralPostingDate := DeferToDate;
        DeferRevenueRequest.DeferralDocumentDate := Today();
    end;

    local procedure ResolveAsPosTransaction(var DeferRevenueRequest: Record "NPR TM DeferRevenueRequest"; TicketReservationRequest: Record "NPR TM Ticket Reservation Req.") Handled: Boolean
    var
        RevenueDetails: Record "NPR TM DeferRevenueReqDetail";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        ValueEntry: Record "Value Entry";
        EntryCount: Integer;
        TicketCount: Integer;
        DetailsPerLine: Integer;
    begin

        // First time, we create the revenue details entries
        RevenueDetails.SetFilter(TokenID, '=%1', TicketReservationRequest."Session Token ID");
        RevenueDetails.SetFilter(ItemNo, '=%1', TicketReservationRequest."Item No.");
        RevenueDetails.SetFilter(VariantCode, '=%1', TicketReservationRequest."Variant Code");
        RevenueDetails.SetFilter(AdmissionCode, '=%1', TicketReservationRequest."Admission Code");
        if (RevenueDetails.IsEmpty()) then begin

            POSEntry.SetFilter("Document No.", '=%1', TicketReservationRequest."Receipt No.");
            if (not POSEntry.FindFirst()) then
                exit(false);

            POSEntrySalesLine.SetFilter("POS Entry No.", '=%1', POSEntry."Entry No.");
            POSEntrySalesLine.SetFilter(Type, '=%1', POSEntrySalesLine.Type::Item);
            POSEntrySalesLine.SetFilter("No.", '=%1', TicketReservationRequest."Item No.");
            POSEntrySalesLine.SetFilter("Variant Code", '=%1', TicketReservationRequest."Variant Code");
            if (not POSEntrySalesLine.FindSet()) then
                exit(false);

            repeat
                DetailsPerLine := POSEntrySalesLine.Quantity;
                if (DeferRevenueRequest.IsGroupTicket) then
                    DetailsPerLine := 1;

                for TicketCount := 1 to DetailsPerLine do begin
                    EntryCount += 1;
                    RevenueDetails.TokenID := TicketReservationRequest."Session Token ID";
                    RevenueDetails.ItemNo := TicketReservationRequest."Item No.";
                    RevenueDetails.VariantCode := TicketReservationRequest."Variant Code";
                    RevenueDetails.AdmissionCode := TicketReservationRequest."Admission Code";
                    RevenueDetails.EntryNo := EntryCount;

                    RevenueDetails.DocumentNo := POSEntrySalesLine."Document No.";
                    RevenueDetails.DocumentLineNo := POSEntrySalesLine."Line No.";

                    RevenueDetails.Insert();
                end;
            until (POSEntrySalesLine.Next() = 0);
        end;

        // Check if this ticket has been assign to a specific line number 
        RevenueDetails.SetFilter(TicketAccessEntryNo, '=%1', DeferRevenueRequest.TicketAccessEntryNo);
        if (not RevenueDetails.FindFirst()) then begin

            RevenueDetails.SetFilter(TicketAccessEntryNo, '=%1', 0);
            if (not RevenueDetails.FindFirst()) then
                exit(false);

            // Allocate to this ticket
            RevenueDetails.TicketNo := DeferRevenueRequest.TicketNo;
            RevenueDetails.TicketAccessEntryNo := DeferRevenueRequest.TicketAccessEntryNo;
            RevenueDetails.Modify();
        end;

        ValueEntry.SetFilter("Entry Type", '=%1', ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetFilter("Document No.", '=%1', TicketReservationRequest."Receipt No.");
        ValueEntry.SetFilter("Document Line No.", '=%1', TicketReservationRequest."Line No.");
        ValueEntry.SetFilter("Item Ledger Entry Type", '=%1', ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetFilter("Item No.", '=%1', TicketReservationRequest."Item No.");
        ValueEntry.SetFilter("Variant Code", '=%1', TicketReservationRequest."Variant Code");
        if (ValueEntry.FindFirst()) then begin
            Handled := AssignFromValueEntry(DeferRevenueRequest, ValueEntry);
            DeferRevenueRequest.SourceType := DeferRevenueRequest.SourceType::POS_ENTRY;
        end;
    end;

    local procedure ResolveAsDocumentTransaction(var DeferRevenueRequest: Record "NPR TM DeferRevenueRequest"; TicketReservationRequest: Record "NPR TM Ticket Reservation Req.") Handled: Boolean
    var
        RevenueDetails: Record "NPR TM DeferRevenueReqDetail";
        PostedSalesInvoice: Record "Sales Invoice Header";
        PostedSalesInvoiceLine: Record "Sales Invoice Line";
        ValueEntry: Record "Value Entry";
        EntryCount: Integer;
        TicketCount: Integer;
        DetailsPerLine: Integer;
    begin

        // First time, we create the revenue details entries
        RevenueDetails.SetFilter(TokenID, '=%1', TicketReservationRequest."Session Token ID");
        RevenueDetails.SetFilter(ItemNo, '=%1', TicketReservationRequest."Item No.");
        RevenueDetails.SetFilter(VariantCode, '=%1', TicketReservationRequest."Variant Code");
        RevenueDetails.SetFilter(AdmissionCode, '=%1', TicketReservationRequest."Admission Code");
        if (RevenueDetails.IsEmpty()) then begin

            PostedSalesInvoice.SetFilter("External Document No.", '=%1', TicketReservationRequest."External Order No.");
            if (not PostedSalesInvoice.FindFirst()) then
                exit(false);

            PostedSalesInvoiceLine.SetFilter("Document No.", '=%1', PostedSalesInvoice."No.");
            PostedSalesInvoiceLine.SetFilter(Type, '=%1', PostedSalesInvoiceLine.Type::Item);
            PostedSalesInvoiceLine.SetFilter("No.", '=%1', TicketReservationRequest."Item No.");
            PostedSalesInvoiceLine.SetFilter("Variant Code", '=%1', TicketReservationRequest."Variant Code");
            if (not PostedSalesInvoiceLine.FindSet()) then
                exit(false);

            repeat
                DetailsPerLine := PostedSalesInvoiceLine.Quantity;
                if (DeferRevenueRequest.IsGroupTicket) then
                    DetailsPerLine := 1;

                for TicketCount := 1 to DetailsPerLine do begin
                    EntryCount += 1;
                    RevenueDetails.TokenID := TicketReservationRequest."Session Token ID";
                    RevenueDetails.ItemNo := TicketReservationRequest."Item No.";
                    RevenueDetails.VariantCode := TicketReservationRequest."Variant Code";
                    RevenueDetails.AdmissionCode := TicketReservationRequest."Admission Code";
                    RevenueDetails.EntryNo := EntryCount;

                    RevenueDetails.DocumentNo := PostedSalesInvoice."No.";
                    RevenueDetails.DocumentLineNo := PostedSalesInvoiceLine."Line No.";

                    RevenueDetails.Insert();
                end;
            until (PostedSalesInvoiceLine.Next() = 0);
        end;

        // Check if this ticket has been assign to a specific line number 
        RevenueDetails.SetFilter(TicketAccessEntryNo, '=%1', DeferRevenueRequest.TicketAccessEntryNo);
        if (not RevenueDetails.FindFirst()) then begin

            RevenueDetails.SetFilter(TicketAccessEntryNo, '=%1', 0);
            if (not RevenueDetails.FindFirst()) then
                exit(false);

            // Allocate to this ticket
            RevenueDetails.TicketNo := DeferRevenueRequest.TicketNo;
            RevenueDetails.TicketAccessEntryNo := DeferRevenueRequest.TicketAccessEntryNo;
            RevenueDetails.Modify();
        end;

        ValueEntry.SetFilter("Entry Type", '=%1', ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetFilter("Document No.", '=%1', RevenueDetails.DocumentNo);
        ValueEntry.SetFilter("Document Line No.", '=%1', RevenueDetails.DocumentLineNo);
        ValueEntry.SetFilter("Item Ledger Entry Type", '=%1', ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetFilter("Item No.", '=%1', RevenueDetails.ItemNo);
        ValueEntry.SetFilter("Variant Code", '=%1', RevenueDetails.VariantCode);
        if (ValueEntry.FindFirst()) then begin
            Handled := AssignFromValueEntry(DeferRevenueRequest, ValueEntry);
            DeferRevenueRequest.SourceType := DeferRevenueRequest.SourceType::SALES_DOC;
        end;
    end;

    local procedure AssignFromValueEntry(var DeferRevenueRequest: Record "NPR TM DeferRevenueRequest"; ValueEntry: Record "Value Entry"): Boolean
    begin
        DeferRevenueRequest.SourceDocumentNo := ValueEntry."Document No.";
        DeferRevenueRequest.SourceDocumentLineNo := ValueEntry."Document Line No.";
        DeferRevenueRequest.SourcePostingDate := ValueEntry."Posting Date";
        DeferRevenueRequest.ValueEntryNo := ValueEntry."Entry No.";

        DeferRevenueRequest.DimensionSetID := ValueEntry."Dimension Set ID";
        DeferRevenueRequest.GlobalDimension1Code := ValueEntry."Global Dimension 1 Code";
        DeferRevenueRequest.GlobalDimension2Code := ValueEntry."Global Dimension 2 Code";
        DeferRevenueRequest.GenBusPostingGroup := ValueEntry."Gen. Bus. Posting Group";
        DeferRevenueRequest.GenProdPostingGroup := ValueEntry."Gen. Prod. Posting Group";

        if (ValueEntry."Item Ledger Entry Quantity" = 0) then
            exit(false);

        if (DeferRevenueRequest.IsGroupTicket) then begin
            DeferRevenueRequest.AmountToDefer := ValueEntry."Sales Amount (Actual)";
            if (ValueEntry."Item Ledger Entry Quantity" > 0) then // return sale
                DeferRevenueRequest.AmountToDefer *= -1;
        end else
            DeferRevenueRequest.AmountToDefer := -1 * ValueEntry."Sales Amount (Actual)" / ValueEntry."Item Ledger Entry Quantity";

        SelectAccounts(DeferRevenueRequest);
        exit(true);
    end;


    local procedure CreateJournalLines(var RevenueRecognitionBuffer: Record "NPR TM RevenuePostingBuffer"; var TempGenJournalLine: Record "Gen. Journal Line" temporary)
    var
        DeferProfile: Record "NPR TM DeferRevenueProfile";
        GetDimValue: Codeunit "Get Shortcut Dimension Values";
        ShortcutDimCode: array[8] of Code[20];
    begin
        RevenueRecognitionBuffer.Reset();
        if (not RevenueRecognitionBuffer.FindSet()) then
            exit;

        repeat
            DeferProfile.Get(RevenueRecognitionBuffer.DeferRevenueProfileCode);
            GetDimValue.GetShortcutDimensions(RevenueRecognitionBuffer.DimensionSetId, ShortcutDimCode);

            MakeGenJournalLine(DeferProfile.JournalTemplateName,
                RevenueRecognitionBuffer.SalesAccount,
                RevenueRecognitionBuffer.AchievedAccount,
                RevenueRecognitionBuffer.AchievedPostingDate,
                Today(),
                RevenueRecognitionBuffer.DocumentNo,
                DeferProfile.DeferralPostingDescription,
                RevenueRecognitionBuffer.Amount,
                ShortcutDimCode[1],
                ShortcutDimCode[2],
                RevenueRecognitionBuffer.DimensionSetId,
                DeferProfile.DeferralReasonCode,
                RevenueRecognitionBuffer.SourceDocumentNo,
                DeferProfile.SourceCode,
                TempGenJournalLine
                );

        until (RevenueRecognitionBuffer.Next() = 0);
    end;

    local procedure MakeGenJournalLine(JournalTemplateName: Code[10];
                                        AccountNo: Code[20];
                                        BalanceAccountNo: Code[20];
                                        PostingDate: Date;
                                        DocumentDate: Date;
                                        DocumentNo: Code[20];
                                        PostingDescription: Text;
                                        Amount: Decimal;
                                        ShortcutDim1: Code[20];
                                        ShortcutDim2: Code[20];
                                        DimSetID: Integer;
                                        ReasonCode: Code[10];
                                        ExternalDocNo: Code[35];
                                        SourceCode: Code[10];
                                        var TempGenJournalLine: Record "Gen. Journal Line" temporary
                                      )
    var
        LineNumber: Integer;
    begin
        if (not TempGenJournalLine.FindLast()) then
            TempGenJournalLine."Line No." := 10000;
        LineNumber := TempGenJournalLine."Line No." + 10000;

        TempGenJournalLine.Init();
        TempGenJournalLine."System-Created Entry" := true;
        TempGenJournalLine."Journal Template Name" := JournalTemplateName;
        TempGenJournalLine."Journal Batch Name" := '';
        TempGenJournalLine."Line No." := LineNumber;

        TempGenJournalLine.Validate("Account Type", TempGenJournalLine."Account Type"::"G/L Account");
        TempGenJournalLine.Validate("Account No.", AccountNo);

        TempGenJournalLine."Posting Date" := PostingDate;
        TempGenJournalLine."Document Date" := DocumentDate;
        TempGenJournalLine."Document No." := DocumentNo;
        TempGenJournalLine."External Document No." := ExternalDocNo;

        TempGenJournalLine.Description := CopyStr(PostingDescription, 1, MaxStrLen(TempGenJournalLine.Description));

        TempGenJournalLine.Validate(Amount, Amount);
        TempGenJournalLine."Source Currency Amount" := Amount;

        TempGenJournalLine.Validate("Bal. Account Type", TempGenJournalLine."Bal. Account Type"::"G/L Account");
        TempGenJournalLine.Validate("Bal. Account No.", BalanceAccountNo);

        // There is no VAT when revenue is deferred
        TempGenJournalLine.Validate("Gen. Posting Type", TempGenJournalLine."Gen. Posting Type"::" ");
        TempGenJournalLine.Validate("Gen. Bus. Posting Group", '');
        TempGenJournalLine.Validate("Gen. Prod. Posting Group", '');

        TempGenJournalLine.Validate("Bal. Gen. Posting Type", TempGenJournalLine."Gen. Posting Type"::" ");
        TempGenJournalLine.Validate("Bal. Gen. Bus. Posting Group", '');
        TempGenJournalLine.Validate("Bal. Gen. Prod. Posting Group", '');

        TempGenJournalLine.Validate("Shortcut Dimension 1 Code", ShortcutDim1);
        TempGenJournalLine.Validate("Shortcut Dimension 2 Code", ShortcutDim2);
        if DimSetID <> 0 then
            TempGenJournalLine.Validate("Dimension Set ID", DimSetID);
        TempGenJournalLine."Reason Code" := ReasonCode;
        TempGenJournalLine."Source Code" := SourceCode;

        TempGenJournalLine.Insert();
    end;

    local procedure SelectAccounts(var DeferRevenueRequest: Record "NPR TM DeferRevenueRequest"): Boolean
    var
        DeferRevenueProfile: Record "NPR TM DeferRevenueProfile";
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        if (not GeneralPostingSetup.Get(DeferRevenueRequest.GenBusPostingGroup, DeferRevenueRequest.GenProdPostingGroup)) then
            exit;

        if (not DeferRevenueProfile.Get(DeferRevenueRequest.DeferRevenueProfileCode)) then
            exit;

        DeferRevenueRequest.OriginalSalesAccount := GeneralPostingSetup."Sales Account";
        DeferRevenueRequest.AchievedRevenueAccount := GeneralPostingSetup.NPR_AchievedRevenueTicketAcc;
        if (DeferRevenueRequest.AchievedRevenueAccount = '') then
            DeferRevenueRequest.AchievedRevenueAccount := DeferRevenueProfile.AchievedRevenueAccount;
        DeferRevenueRequest.InterimAdjustmentAccount := DeferRevenueProfile.InterimAdjustmentAccount;

        exit((DeferRevenueRequest.AchievedRevenueAccount <> '') and (DeferRevenueRequest.OriginalSalesAccount <> ''));
    end;

}