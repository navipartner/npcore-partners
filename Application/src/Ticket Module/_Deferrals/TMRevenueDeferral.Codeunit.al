codeunit 6184739 "NPR TM RevenueDeferral"
{
    Access = Internal;

    trigger OnRun()

    begin
        ProcessBatch();
    end;

    internal procedure ProcessBatch()
    begin
        ProcessStatusRegistered();
        ProcessStatusPendingDeferral();
    end;

    [CommitBehavior(CommitBehavior::Error)]
    internal procedure ProcessOne(DeferRevenueRequest: Record "NPR TM DeferRevenueRequest")
    var
        RevenueRecognitionBuffer: Record "NPR TM RevenuePostingBuffer";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        InitializeRevenueRequest(DeferRevenueRequest, DeferRevenueRequest.SalesDate);
        ProcessOneStatusRegistered(DeferRevenueRequest);
        if (ProcessOneStatusPendingDeferral(DeferRevenueRequest)) then
            AggregateDeferrals(DeferRevenueRequest, RevenueRecognitionBuffer);
        DeferRevenueRequest.Modify();

        // Create posting journal lines from the aggregation buffer
        CreateJournalLines(RevenueRecognitionBuffer, TempGenJournalLine);

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

        TicketType.SetLoadFields("Code", "Defer Revenue", "DeferRevenueProfileCode");
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
        DeferRevenueRequest, DeferRevenueRequestUpdate : Record "NPR TM DeferRevenueRequest";
    begin
        // Dress the request with all possible intermediary information 
        DeferRevenueRequest.SetCurrentKey(Status);
        DeferRevenueRequest.SetFilter(Status, '=%1|=%2', DeferRevenueRequest.Status::REGISTERED, DeferRevenueRequest.Status::WAITING);
        if (not DeferRevenueRequest.FindSet(true)) then
            exit;

        repeat
            DeferRevenueRequestUpdate.Get(DeferRevenueRequest.TicketAccessEntryNo);
            ProcessOneStatusRegistered(DeferRevenueRequestUpdate);
            DeferRevenueRequestUpdate.Modify();
        until (DeferRevenueRequest.Next() = 0);
        Commit();
    end;

    local procedure ProcessStatusPendingDeferral()
    begin
        CalculateDeferralAndPost();
        Commit();
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure CalculateDeferralAndPost()
    var
        DeferRevenueRequest, DeferRevenueRequestUpdate : Record "NPR TM DeferRevenueRequest";
        RevenueRecognitionBuffer: Record "NPR TM RevenuePostingBuffer";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        // Dress the request with all possible intermediary information 
        DeferRevenueRequest.SetCurrentKey(Status);
        DeferRevenueRequest.SetFilter(Status, '=%1', DeferRevenueRequest.Status::PENDING_DEFERRAL);
        if (not DeferRevenueRequest.FindSet(true)) then
            exit;

        // Refresh postings details and aggregate
        repeat
            DeferRevenueRequestUpdate.Get(DeferRevenueRequest.TicketAccessEntryNo);
            if (ProcessOneStatusPendingDeferral(DeferRevenueRequestUpdate)) then
                AggregateDeferrals(DeferRevenueRequestUpdate, RevenueRecognitionBuffer);
            DeferRevenueRequestUpdate.Modify();
        until (DeferRevenueRequest.Next() = 0);

        // Create posting journal lines from the aggregation buffer
        CreateJournalLines(RevenueRecognitionBuffer, TempGenJournalLine);

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
        if (DeferRevenueRequest.Status in [DeferRevenueRequest.Status::UNRESOLVED, DeferRevenueRequest.Status::DEFERRED, DeferRevenueRequest.Status::IMMEDIATE, DeferRevenueRequest.Status::DEFERRAL_ABORTED]) then
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
                for TicketCount := 1 to POSEntrySalesLine.Quantity do begin
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
                for TicketCount := 1 to PostedSalesInvoiceLine.Quantity do begin
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