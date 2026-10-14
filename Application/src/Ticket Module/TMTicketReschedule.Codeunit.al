codeunit 6151260 "NPR TM Ticket Reschedule"
{
    Access = Internal;

    var
        _TicketManagement: Codeunit "NPR TM Ticket Management";
        _TimeHelper: Codeunit "NPR TM TimeHelper";
        IntegrityErr: Label 'Ticket reschedule integrity failure for token %1: %2 This is a programming bug', Locked = true;
        TicketsOnTwoRowsLbl: Label 'the tickets of the line of request row %1 point to request rows %2 and %3 of its change chain.', Locked = true;
        ChainTooLongLbl: Label 'the supersede chain from request row %1 exceeds %2 steps.', Locked = true;
        ChangeChainTooLongLbl: Label 'the change chain from request row %1 holds more than %2 rows.', Locked = true;
        NoAdmissionRowsLbl: Label 'Houston, - we have a problem with ticket request table integrity (no REQUIRED or SELECTED row for request row %1).', Locked = true;
        NoTicketsLbl: Label 'no ticket points at request row %1.', Locked = true;
        NotResolvableLbl: Label 'ticket %1 has no reschedule policy for admission %2.', Locked = true;
        NoCurrentSlotLbl: Label 'ticket %1 has no admission entry with a slot for admission %2.', Locked = true;
        NoPrimaryRowsLbl: Label 'no primary request row exists.', Locked = true;
        CreateChangeFailedLbl: Label 'step one refused request row %1: %2', Locked = true;
        NoPrimaryChangeRowLbl: Label 'change token %1 has no primary request row.', Locked = true;

    internal procedure ResolveIdentity(TicketNumber: Code[30]; ReservationToken: Text[100]; PinCode: Text; var OriginalToken: Text[100]): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        OriginalToken := '';
        if ((PinCode = '') or (StrLen(PinCode) > MaxStrLen(TicketReservationRequest."Authorization Code"))) then
            exit(false);

        TicketReservationRequest.ReadIsolation := IsolationLevel::ReadCommitted;
        if (TicketNumber <> '') then begin
            Ticket.ReadIsolation := IsolationLevel::ReadCommitted;
            Ticket.SetCurrentKey("External Ticket No.");
            Ticket.SetLoadFields("Ticket Reservation Entry No.");
            Ticket.SetRange("External Ticket No.", TicketNumber);
            Ticket.SetRange(Blocked, false);
            if (not Ticket.FindFirst()) then
                exit(false);
            if (not TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
                exit(false);
        end else begin
            if (ReservationToken = '') then
                exit(false);
            TicketReservationRequest.SetCurrentKey("Session Token ID", "Ext. Line Reference No.", "Admission Inclusion");
            TicketReservationRequest.SetRange("Session Token ID", ReservationToken);
            if (not TicketReservationRequest.FindFirst()) then
                exit(false);
        end;

        if (TicketReservationRequest."Authorization Code" <> UpperCase(PinCode)) then
            exit(false);

        OriginalToken := RootToken(TicketReservationRequest);
        exit(true);
    end;

    local procedure RootToken(TicketReservationRequest: Record "NPR TM Ticket Reservation Req."): Text[100]
    var
        Steps: Integer;
    begin
        while (TicketReservationRequest."Superseeds Entry No." <> 0) do begin
            Steps += 1;
            if (Steps > MaxChainLength()) then
                Error(IntegrityErr, TicketReservationRequest."Session Token ID", StrSubstNo(ChainTooLongLbl, TicketReservationRequest."Entry No.", MaxChainLength()));
            TicketReservationRequest.Get(TicketReservationRequest."Superseeds Entry No.");
        end;
        exit(TicketReservationRequest."Session Token ID");
    end;

    local procedure MaxChainLength(): Integer
    begin
        exit(1000);
    end;

    internal procedure IsOriginalRequestConfirmed(OriginalToken: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.ReadIsolation := IsolationLevel::ReadCommitted;
        TicketReservationRequest.SetRange("Session Token ID", OriginalToken);
        TicketReservationRequest.SetRange("Primary Request Line", true);
        TicketReservationRequest.SetRange("Request Status", TicketReservationRequest."Request Status"::CONFIRMED);
        exit(not TicketReservationRequest.IsEmpty());
    end;

    internal procedure LoadCurrentLines(OriginalToken: Text[100]; var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary)
    var
        PrimaryRow: Record "NPR TM Ticket Reservation Req.";
        CurrentRow: Record "NPR TM Ticket Reservation Req.";
        SiblingRow: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        Ambiguous: Boolean;
        NextEntryNo: Integer;
    begin
        TempLineBuffer.Reset();
        TempLineBuffer.DeleteAll();

        // Reset() restores the default isolation and the full field load, so isolation and SetLoadFields always follow it.
        PrimaryRow.Reset();
        PrimaryRow.ReadIsolation := IsolationLevel::ReadCommitted;
        PrimaryRow.SetLoadFields("Entry No.", SystemId, "Session Token ID", "Ext. Line Reference No.", "Superseeds Entry No.", "Item No.", "Variant Code", Quantity, "Request Status");
        PrimaryRow.SetCurrentKey("Session Token ID", "Ext. Line Reference No.", "Admission Inclusion");
        PrimaryRow.SetRange("Session Token ID", OriginalToken);
        PrimaryRow.SetRange("Primary Request Line", true);
        if (not PrimaryRow.FindSet()) then
            Error(IntegrityErr, OriginalToken, NoPrimaryRowsLbl);

        repeat
            CurrentRow := PrimaryRow;
            WalkToCurrentRow(CurrentRow);

            SiblingRow.Reset();
            SiblingRow.ReadIsolation := IsolationLevel::ReadCommitted;
            SiblingRow.SetLoadFields("Admission Code", "Admission Description", "External Adm. Sch. Entry No.", "Item No.", "Variant Code");
            SiblingRow.SetCurrentKey("Session Token ID", "Ext. Line Reference No.", "Admission Inclusion");
            SiblingRow.SetRange("Session Token ID", CurrentRow."Session Token ID");
            SiblingRow.SetRange("Ext. Line Reference No.", CurrentRow."Ext. Line Reference No.");
            SiblingRow.SetFilter("Admission Inclusion", '%1|%2', SiblingRow."Admission Inclusion"::REQUIRED, SiblingRow."Admission Inclusion"::SELECTED);
            if (not SiblingRow.FindSet()) then
                Error(IntegrityErr, OriginalToken, StrSubstNo(NoAdmissionRowsLbl, CurrentRow."Entry No."));

            Ambiguous := IsLineAmbiguous(SiblingRow);

            Ticket.ReadIsolation := IsolationLevel::ReadCommitted;
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetLoadFields("Valid From Date", "Valid To Date");
            Ticket.SetRange("Ticket Reservation Entry No.", CurrentRow."Entry No.");
            if (not Ticket.FindFirst()) then begin
                // A waiting-list line of the legacy XML web service holds no ticket and has nothing to move.
                if (CurrentRow."Request Status" <> CurrentRow."Request Status"::CONFIRMED) then
                    continue;
                Error(IntegrityErr, OriginalToken, StrSubstNo(NoTicketsLbl, CurrentRow."Entry No."));
            end;

            AddLineAdmissions(OriginalToken, CurrentRow, SiblingRow, Ticket, Ambiguous, NextEntryNo, TempLineBuffer);
        until (PrimaryRow.Next() = 0);
    end;

    local procedure IsLineAmbiguous(var SiblingRow: Record "NPR TM Ticket Reservation Req.") Ambiguous: Boolean
    var
        AdmissionCodes: Dictionary of [Code[20], Boolean];
        ItemVariants: Dictionary of [Text, Boolean];
    begin
        Clear(AdmissionCodes);
        Clear(ItemVariants);
        Ambiguous := false;
        repeat
            if (AdmissionCodes.ContainsKey(SiblingRow."Admission Code")) then
                Ambiguous := true
            else
                AdmissionCodes.Add(SiblingRow."Admission Code", true);
            if (not ItemVariants.ContainsKey(StrSubstNo('%1|%2', SiblingRow."Item No.", SiblingRow."Variant Code"))) then
                ItemVariants.Add(StrSubstNo('%1|%2', SiblingRow."Item No.", SiblingRow."Variant Code"), true);
        until (SiblingRow.Next() = 0);
        if (ItemVariants.Count() > 1) then
            Ambiguous := true;
    end;

    local procedure AddLineAdmissions(OriginalToken: Text[100]; var CurrentRow: Record "NPR TM Ticket Reservation Req."; var SiblingRow: Record "NPR TM Ticket Reservation Req."; var Ticket: Record "NPR TM Ticket"; Ambiguous: Boolean; var NextEntryNo: Integer; var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary)
    var
        Admission: Record "NPR TM Admission";
        AdmissionCodes: Dictionary of [Code[20], Boolean];
    begin
        Clear(AdmissionCodes);
        SiblingRow.FindSet();
        repeat
            // An admission without a schedule entry (Default Schedule = NONE, request row slot 0) has nothing to move and is not reported.
            if ((SiblingRow."External Adm. Sch. Entry No." <> 0) and (not AdmissionCodes.ContainsKey(SiblingRow."Admission Code"))) then begin
                AdmissionCodes.Add(SiblingRow."Admission Code", true);
                NextEntryNo += 1;
                TempLineBuffer.Init();
                TempLineBuffer.EntryNo := NextEntryNo;
                TempLineBuffer.OriginalToken := OriginalToken;
                TempLineBuffer.CurrentToken := CurrentRow."Session Token ID";
                TempLineBuffer.LineReferenceNo := CurrentRow."Ext. Line Reference No.";
                TempLineBuffer.CurrentPrimaryEntryNo := CurrentRow."Entry No.";
                TempLineBuffer.CurrentPrimarySystemId := CurrentRow.SystemId;
                TempLineBuffer.ItemNo := CurrentRow."Item No.";
                TempLineBuffer.VariantCode := CurrentRow."Variant Code";
                TempLineBuffer.Quantity := CurrentRow.Quantity;
                TempLineBuffer.ValidFromDate := Ticket."Valid From Date";
                TempLineBuffer.ValidToDate := Ticket."Valid To Date";
                TempLineBuffer.AdmissionCode := SiblingRow."Admission Code";
                if (Admission.Get(SiblingRow."Admission Code")) then
                    TempLineBuffer.AdmissionDescription := Admission.Description
                else
                    TempLineBuffer.AdmissionDescription := SiblingRow."Admission Description";
                // An ambiguous line's first ticket may hold no access entry for this admission (rows of different items), and the line never moves.
                if (Ambiguous) then
                    TempLineBuffer.CurrentExtScheduleEntryNo := SiblingRow."External Adm. Sch. Entry No."
                else
                    TempLineBuffer.CurrentExtScheduleEntryNo := GetCurrentSlot(Ticket."No.", SiblingRow."Admission Code", OriginalToken);
                TempLineBuffer.Ambiguous := Ambiguous;
                TempLineBuffer.Insert();
            end;
        until (SiblingRow.Next() = 0);
    end;

    // The current row is the row the line's tickets point to, among the original primary row and its CONFIRMED or CANCELED change descendants at any depth.
    local procedure WalkToCurrentRow(var CurrentRow: Record "NPR TM Ticket Reservation Req.")
    var
        ChainRow: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        ChainEntryNos: List of [Integer];
        EntryNo: Integer;
        OwnerEntryNo: Integer;
        Index: Integer;
    begin
        ChainEntryNos.Add(CurrentRow."Entry No.");
        Ticket.ReadIsolation := IsolationLevel::ReadCommitted;
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        ChainRow.ReadIsolation := IsolationLevel::ReadCommitted;
        ChainRow.SetLoadFields("Entry No.");
        ChainRow.SetCurrentKey("Superseeds Entry No.");
        ChainRow.SetRange("Entry Type", ChainRow."Entry Type"::CHANGE);
        ChainRow.SetFilter("Request Status", '%1|%2', ChainRow."Request Status"::CONFIRMED, ChainRow."Request Status"::CANCELED);
        while (Index < ChainEntryNos.Count()) do begin
            Index += 1;
            if (Index > MaxChainLength()) then
                Error(IntegrityErr, CurrentRow."Session Token ID", StrSubstNo(ChangeChainTooLongLbl, CurrentRow."Entry No.", MaxChainLength()));
            EntryNo := ChainEntryNos.Get(Index);

            Ticket.SetRange("Ticket Reservation Entry No.", EntryNo);
            if (not Ticket.IsEmpty()) then begin
                if (OwnerEntryNo <> 0) then
                    Error(IntegrityErr, CurrentRow."Session Token ID", StrSubstNo(TicketsOnTwoRowsLbl, CurrentRow."Entry No.", OwnerEntryNo, EntryNo));
                OwnerEntryNo := EntryNo;
            end;

            ChainRow.SetRange("Superseeds Entry No.", EntryNo);
            if (ChainRow.FindSet()) then
                repeat
                    ChainEntryNos.Add(ChainRow."Entry No.");
                until (ChainRow.Next() = 0);
        end;

        if ((OwnerEntryNo = 0) or (OwnerEntryNo = CurrentRow."Entry No.")) then
            exit;
        ChainRow.Reset();
        ChainRow.ReadIsolation := IsolationLevel::ReadCommitted;
        ChainRow.SetLoadFields("Entry No.", SystemId, "Session Token ID", "Ext. Line Reference No.", "Superseeds Entry No.", "Item No.", "Variant Code", Quantity, "Request Status");
        ChainRow.Get(OwnerEntryNo);
        CurrentRow := ChainRow;
    end;

    // Reads the slot the way CreateChangeRequest reads it for a new change request.
    local procedure GetCurrentSlot(TicketNo: Code[20]; AdmissionCode: Code[20]; OriginalToken: Text[100]) CurrentSlot: Integer
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketAccessEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        TicketAccessEntry.SetCurrentKey("Ticket No.", "Admission Code");
        TicketAccessEntry.SetLoadFields("Entry No.");
        TicketAccessEntry.SetRange("Ticket No.", TicketNo);
        TicketAccessEntry.SetRange("Admission Code", AdmissionCode);
        if (TicketAccessEntry.FindFirst()) then begin
            CurrentSlot := 0;
            TicketRequestManager.ReadCurrentSlot(TicketAccessEntry."Entry No.", IsolationLevel::ReadCommitted, CurrentSlot);
        end;
        if (CurrentSlot = 0) then
            Error(IntegrityErr, OriginalToken, StrSubstNo(NoCurrentSlotLbl, TicketNo, AdmissionCode));
    end;

    internal procedure EvaluateEligibility(var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary)
    var
        Ticket: Record "NPR TM Ticket";
        LineReason: Enum "NPR TM Reschedule Refusal";
        TicketReason: Enum "NPR TM Reschedule Refusal";
        ChangeableByEntryNo: Dictionary of [Integer, Boolean];
        ReferenceDateTime: DateTime;
    begin
        TempLineBuffer.Reset();
        if (not TempLineBuffer.FindSet()) then
            exit;
        repeat
            if (TempLineBuffer.Ambiguous) then begin
                LineReason := LineReason::LINE_AMBIGUOUS;
            end else begin
                LineReason := LineReason::NONE;
                ReferenceDateTime := GetReferenceDateTime(TempLineBuffer.AdmissionCode);
                Ticket.ReadIsolation := IsolationLevel::ReadCommitted;
                Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                Ticket.SetLoadFields("External Ticket No.");
                Ticket.SetRange("Ticket Reservation Entry No.", TempLineBuffer.CurrentPrimaryEntryNo);
                if (not Ticket.FindSet()) then
                    Error(IntegrityErr, TempLineBuffer.OriginalToken, StrSubstNo(NoTicketsLbl, TempLineBuffer.CurrentPrimaryEntryNo));
                repeat
                    TicketReason := _TicketManagement.GetRescheduleRefusal(Ticket."External Ticket No.", TempLineBuffer.CurrentExtScheduleEntryNo, ReferenceDateTime);
                    if (TicketReason = TicketReason::NOT_RESOLVABLE) then
                        Error(IntegrityErr, TempLineBuffer.OriginalToken, StrSubstNo(NotResolvableLbl, Ticket."External Ticket No.", TempLineBuffer.AdmissionCode));
                    if ((TicketReason <> TicketReason::NONE) and ((LineReason = LineReason::NONE) or (TicketReason.AsInteger() < LineReason.AsInteger()))) then
                        LineReason := TicketReason;
                until (Ticket.Next() = 0);
                // Ranked last (S4): only an admission that no earlier rule refuses reports it.
                if (LineReason = LineReason::NONE) then
                    if (not IsLineChangeable(TempLineBuffer, ChangeableByEntryNo)) then
                        LineReason := LineReason::LINE_NOT_CHANGEABLE;
            end;
            TempLineBuffer.RefusalReason := LineReason;
            TempLineBuffer.RescheduleAllowed := (LineReason = LineReason::NONE);
            TempLineBuffer.Modify();
        until (TempLineBuffer.Next() = 0);
    end;

    internal procedure AnyAdmissionCanMove(var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary): Boolean
    begin
        TempLineBuffer.Reset();
        TempLineBuffer.SetRange(RescheduleAllowed, true);
        exit(not TempLineBuffer.IsEmpty());
    end;

    internal procedure GetSlots(var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary; FromDate: Date; ToDate: Date; var TempSlot: Record "NPR TM Admis. Schedule Entry" temporary; var RemainingByEntryNo: Dictionary of [Integer, Integer])
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        CurrentScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        NonWorkingByDate: Dictionary of [Date, Boolean];
        PendingDeltas: Dictionary of [Integer, Integer];
        GroupUsageCache: Dictionary of [Text, Integer];
        BlockReason: Enum "NPR TM Sch. Block Sales Reason";
        ReferenceDateTime: DateTime;
        ReferenceDate: Date;
        ReferenceTime: Time;
        WindowFrom: Date;
        WindowTo: Date;
        Remaining: Integer;
        Places: Integer;
        HasTicketCalendar: Boolean;
    begin
        TempSlot.Reset();
        TempSlot.DeleteAll();
        Clear(RemainingByEntryNo);

        if (not TempLineBuffer.RescheduleAllowed) then
            exit;

        ReferenceDateTime := GetReferenceDateTime(TempLineBuffer.AdmissionCode);
        ReferenceDate := DT2Date(ReferenceDateTime);
        ReferenceTime := DT2Time(ReferenceDateTime);

        // The window is clamped to the validity and to the reference date before the query (filters before iteration).
        WindowFrom := FromDate;
        if (TempLineBuffer.ValidFromDate > WindowFrom) then
            WindowFrom := TempLineBuffer.ValidFromDate;
        if (ReferenceDate > WindowFrom) then
            WindowFrom := ReferenceDate;
        WindowTo := ToDate;
        if ((TempLineBuffer.ValidToDate <> 0D) and (TempLineBuffer.ValidToDate < WindowTo)) then
            WindowTo := TempLineBuffer.ValidToDate;
        if (WindowFrom > WindowTo) then
            exit;

        GetTicketBomAndCalendarFlag(TempLineBuffer, TicketBOM, HasTicketCalendar);

        ScheduleEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        ScheduleEntry.SetRange("Admission Code", TempLineBuffer.AdmissionCode);
        ScheduleEntry.SetRange("Admission Start Date", WindowFrom, WindowTo);
        ScheduleEntry.SetFilter("External Schedule Entry No.", '<>%1', TempLineBuffer.CurrentExtScheduleEntryNo);
        ScheduleEntry.SetRange(Cancelled, false);
        ScheduleEntry.SetRange("Visibility On Web", ScheduleEntry."Visibility On Web"::VISIBLE);
        ScheduleEntry.SetRange("Admission Is", ScheduleEntry."Admission Is"::OPEN);
        ScheduleEntry.SetRange("Allocation By", ScheduleEntry."Allocation By"::CAPACITY);
        if (not ScheduleEntry.FindSet()) then
            exit;

        GetCurrentScheduleEntry(TempLineBuffer.CurrentExtScheduleEntryNo, CurrentScheduleEntry);
        Places := LinePlaces(TempLineBuffer);

        repeat
            if (SlotQualifies(ScheduleEntry, TempLineBuffer, CurrentScheduleEntry, TicketBOM, HasTicketCalendar, ReferenceDate, ReferenceTime, NonWorkingByDate, PendingDeltas, GroupUsageCache, Places, Remaining, BlockReason)) then begin
                TempSlot := ScheduleEntry;
                TempSlot.Insert();
                if (Remaining >= 0) then
                    RemainingByEntryNo.Add(ScheduleEntry."Entry No.", Remaining);
            end;
        until (ScheduleEntry.Next() = 0);
    end;

    local procedure SlotQualifies(var ScheduleEntry: Record "NPR TM Admis. Schedule Entry"; var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary; CurrentScheduleEntry: Record "NPR TM Admis. Schedule Entry"; TicketBOM: Record "NPR TM Ticket Admission BOM"; HasTicketCalendar: Boolean; ReferenceDate: Date; ReferenceTime: Time; var NonWorkingByDate: Dictionary of [Date, Boolean]; PendingDeltas: Dictionary of [Integer, Integer]; var GroupUsageCache: Dictionary of [Text, Integer]; Places: Integer; var Remaining: Integer; var BlockReason: Enum "NPR TM Sch. Block Sales Reason"): Boolean
    var
        Bounded: Boolean;
    begin
        Remaining := -1;

        if (not SlotPassesRules(ScheduleEntry, TempLineBuffer, TicketBOM, HasTicketCalendar, ReferenceDate, ReferenceTime, NonWorkingByDate, BlockReason)) then
            exit(false);

        Bounded := _TicketManagement.CalculateRemainingCapacityForMove(TempLineBuffer.ItemNo, TempLineBuffer.VariantCode, ScheduleEntry, CurrentScheduleEntry, Places, PendingDeltas, GroupUsageCache, Remaining);
        if (not Bounded) then begin
            Remaining := -1;
            exit(true);
        end;
        exit(Remaining >= Places);
    end;

    // Per ticket of the line, the quantity of the initial entry that RescheduleTicketAdmission moves for the admission.
    local procedure LinePlaces(var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary) Places: Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        Ticket.ReadIsolation := IsolationLevel::ReadCommitted;
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetLoadFields("No.");
        Ticket.SetRange("Ticket Reservation Entry No.", TempLineBuffer.CurrentPrimaryEntryNo);
        if (not Ticket.FindSet()) then
            exit(0);

        TicketAccessEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        TicketAccessEntry.SetCurrentKey("Ticket No.", "Admission Code");
        TicketAccessEntry.SetLoadFields("Entry No.");
        TicketAccessEntry.SetRange("Admission Code", TempLineBuffer.AdmissionCode);
        DetTicketAccessEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        DetTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type, Open, "Posting Date");
        DetTicketAccessEntry.SetLoadFields(Quantity);
        DetTicketAccessEntry.SetRange(Type, DetTicketAccessEntry.Type::INITIAL_ENTRY);
        DetTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
        repeat
            TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
            if (TicketAccessEntry.FindFirst()) then begin
                DetTicketAccessEntry.SetRange("Ticket Access Entry No.", TicketAccessEntry."Entry No.");
                if (DetTicketAccessEntry.FindLast()) then
                    Places += DetTicketAccessEntry.Quantity;
            end;
        until (Ticket.Next() = 0);
    end;

    local procedure GetTicketBomAndCalendarFlag(var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary; var TicketBOM: Record "NPR TM Ticket Admission BOM"; var HasTicketCalendar: Boolean)
    var
        Admission: Record "NPR TM Admission";
    begin
        if (not TicketBOM.Get(TempLineBuffer.ItemNo, TempLineBuffer.VariantCode, TempLineBuffer.AdmissionCode)) then
            TicketBOM.Init();
        if (not Admission.Get(TempLineBuffer.AdmissionCode)) then
            Admission.Init();
        // The ticket base calendar is read only when a code exists; most tenants have none (CheckTicketBaseCalendarWorker exits the same way).
        HasTicketCalendar := ((TicketBOM."Ticket Base Calendar Code" <> '') or (Admission."Ticket Base Calendar Code" <> ''));
    end;

    // An unresolved current slot leaves Entry No. 0, which no group counts.
    local procedure GetCurrentScheduleEntry(CurrentExtScheduleEntryNo: Integer; var CurrentScheduleEntry: Record "NPR TM Admis. Schedule Entry")
    begin
        Clear(CurrentScheduleEntry);
        CurrentScheduleEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        CurrentScheduleEntry.SetCurrentKey("External Schedule Entry No.");
        CurrentScheduleEntry.SetLoadFields("Admission Code", "Schedule Code", "Admission Start Date");
        CurrentScheduleEntry.SetRange("External Schedule Entry No.", CurrentExtScheduleEntryNo);
        CurrentScheduleEntry.SetRange(Cancelled, false);
        if (not CurrentScheduleEntry.FindLast()) then
            Clear(CurrentScheduleEntry);
    end;

    local procedure SlotPassesRules(var ScheduleEntry: Record "NPR TM Admis. Schedule Entry"; var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary; TicketBOM: Record "NPR TM Ticket Admission BOM"; HasTicketCalendar: Boolean; ReferenceDate: Date; ReferenceTime: Time; var NonWorkingByDate: Dictionary of [Date, Boolean]; var BlockReason: Enum "NPR TM Sch. Block Sales Reason"): Boolean
    var
        NonWorking: Boolean;
        CalendarText: Text;
    begin
        if ((ScheduleEntry."Admission Start Date" = ReferenceDate) and (ScheduleEntry."Admission Start Time" <= ReferenceTime)) then
            exit(false);

        if (HasTicketCalendar) then begin
            if (not NonWorkingByDate.ContainsKey(ScheduleEntry."Admission Start Date")) then begin
                _TicketManagement.CheckTicketBaseCalendar(TempLineBuffer.AdmissionCode, TempLineBuffer.ItemNo, TempLineBuffer.VariantCode, ScheduleEntry."Admission Start Date", NonWorking, CalendarText);
                NonWorkingByDate.Add(ScheduleEntry."Admission Start Date", NonWorking);
            end;
            if (NonWorkingByDate.Get(ScheduleEntry."Admission Start Date")) then
                exit(false);
        end;

        exit(_TicketManagement.IsWithinScheduleSalesWindow(ScheduleEntry, TicketBOM, ReferenceDate, ReferenceTime, BlockReason));
    end;

    local procedure FindRequestedSlot(var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary; ExtScheduleEntryNo: Integer; var ScheduleEntry: Record "NPR TM Admis. Schedule Entry"): Boolean
    var
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        NonWorkingByDate: Dictionary of [Date, Boolean];
        BlockReason: Enum "NPR TM Sch. Block Sales Reason";
        ReferenceDateTime: DateTime;
        ReferenceDate: Date;
        HasTicketCalendar: Boolean;
    begin
        ReferenceDateTime := GetReferenceDateTime(TempLineBuffer.AdmissionCode);
        ReferenceDate := DT2Date(ReferenceDateTime);

        ScheduleEntry.Reset();
        ScheduleEntry.ReadIsolation := IsolationLevel::UpdLock; // Lock this slot until the transaction ends, so another reschedule locking the same slot waits before checking capacity.
        ScheduleEntry.SetCurrentKey("External Schedule Entry No.");
        ScheduleEntry.SetRange("External Schedule Entry No.", ExtScheduleEntryNo);
        ScheduleEntry.SetRange(Cancelled, false);
        if (not ScheduleEntry.FindFirst()) then
            exit(false);
        ScheduleEntry.ReadIsolation := IsolationLevel::ReadCommitted; // Keep the slot lock until the transaction ends, but avoid update locks on detail entries in later capacity CalcFields.

        if (ScheduleEntry."Admission Code" <> TempLineBuffer.AdmissionCode) then
            exit(false);
        if (ScheduleEntry."Visibility On Web" <> ScheduleEntry."Visibility On Web"::VISIBLE) then
            exit(false);
        if (ScheduleEntry."Admission Is" <> ScheduleEntry."Admission Is"::OPEN) then
            exit(false);
        if (ScheduleEntry."Allocation By" <> ScheduleEntry."Allocation By"::CAPACITY) then
            exit(false);
        if ((ScheduleEntry."Admission Start Date" < ReferenceDate) or (ScheduleEntry."Admission Start Date" < TempLineBuffer.ValidFromDate)) then
            exit(false);
        if ((TempLineBuffer.ValidToDate <> 0D) and (ScheduleEntry."Admission Start Date" > TempLineBuffer.ValidToDate)) then
            exit(false);

        GetTicketBomAndCalendarFlag(TempLineBuffer, TicketBOM, HasTicketCalendar);
        exit(SlotPassesRules(ScheduleEntry, TempLineBuffer, TicketBOM, HasTicketCalendar, ReferenceDate, DT2Time(ReferenceDateTime), NonWorkingByDate, BlockReason));
    end;

    local procedure ValidateChangeRequest(var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary; var TempRequest: Record "NPR TM Reschedule Line Buffer" temporary; var FailedRequestEntryNo: Integer; var Refusal: Enum "NPR TM Reschedule Refusal"): Enum "NPR TM Resched. Change Outcome"
    var
        NewScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        CurrentScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Outcome: Enum "NPR TM Resched. Change Outcome";
        PendingDeltas: Dictionary of [Integer, Integer];
        GroupUsageCache: Dictionary of [Text, Integer];
        LineIndex: Integer;
        Remaining: Integer;
        Places: Integer;
        ChangesSomething: Boolean;
    begin
        LineIndex := 1;
        TempRequest.Reset();
        TempRequest.SetRange(LineReferenceNo, LineIndex);
        while (TempRequest.FindSet()) do begin
            FailedRequestEntryNo := TempRequest.EntryNo;
            TempLineBuffer.Reset();
            TempLineBuffer.SetRange(CurrentPrimarySystemId, TempRequest.CurrentPrimarySystemId);
            if (not TempLineBuffer.FindFirst()) then
                exit(Outcome::INVALID_REFERENCE);
            if (TempLineBuffer.Ambiguous) then
                exit(Outcome::INVALID_REFERENCE);

            ChangesSomething := false;
            repeat
                TempLineBuffer.SetRange(AdmissionCode, TempRequest.AdmissionCode);
                if (not TempLineBuffer.FindFirst()) then begin
                    FailedRequestEntryNo := TempRequest.EntryNo;
                    exit(Outcome::INVALID_REFERENCE);
                end;
                if (TempRequest.RequestedExtScheduleEntryNo <> TempLineBuffer.CurrentExtScheduleEntryNo) then
                    ChangesSomething := true;
            until (TempRequest.Next() = 0);
            if (not ChangesSomething) then
                exit(Outcome::INVALID_INPUT);

            TempRequest.FindSet();
            repeat
                TempLineBuffer.SetRange(AdmissionCode, TempRequest.AdmissionCode);
                TempLineBuffer.FindFirst();
                if (TempRequest.RequestedExtScheduleEntryNo <> TempLineBuffer.CurrentExtScheduleEntryNo) then begin
                    FailedRequestEntryNo := TempRequest.EntryNo;
                    if (not TempLineBuffer.RescheduleAllowed) then begin
                        Refusal := TempLineBuffer.RefusalReason;
                        exit(Outcome::NOT_ALLOWED);
                    end;
                    if (not FindRequestedSlot(TempLineBuffer, TempRequest.RequestedExtScheduleEntryNo, NewScheduleEntry)) then
                        exit(Outcome::INVALID_REFERENCE);
                    GetCurrentScheduleEntry(TempLineBuffer.CurrentExtScheduleEntryNo, CurrentScheduleEntry);
                    Places := LinePlaces(TempLineBuffer);
                    if (_TicketManagement.CalculateRemainingCapacityForMove(TempLineBuffer.ItemNo, TempLineBuffer.VariantCode, NewScheduleEntry, CurrentScheduleEntry, Places, PendingDeltas, GroupUsageCache, Remaining)) then
                        if (Remaining < Places) then
                            exit(Outcome::CAPACITY_EXCEEDED);
                    AddPendingDelta(PendingDeltas, NewScheduleEntry."Entry No.", Places);
                    if (CurrentScheduleEntry."Entry No." <> 0) then
                        AddPendingDelta(PendingDeltas, CurrentScheduleEntry."Entry No.", -Places);
                    TempLineBuffer.RequestedExtScheduleEntryNo := TempRequest.RequestedExtScheduleEntryNo;
                    TempLineBuffer.Modify();
                end;
            until (TempRequest.Next() = 0);

            LineIndex += 1;
            TempRequest.SetRange(LineReferenceNo, LineIndex);
        end;
        FailedRequestEntryNo := 0;
        exit(Outcome::CHANGED);
    end;

    // CreateChangeRequest throws on a missing admission or BOM line and on a slot without a non-cancelled schedule entry; this checks the same first.
    local procedure StepOneCanCopyLine(CurrentEntryNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Slot: Integer;
        HasDefault: Boolean;
    begin
        Ticket.ReadIsolation := IsolationLevel::ReadCommitted;
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetLoadFields("No.");
        Ticket.SetRange("Ticket Reservation Entry No.", CurrentEntryNo);
        if (not Ticket.FindFirst()) then
            exit(false);

        TicketAccessEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        TicketAccessEntry.SetCurrentKey("Ticket No.", "Admission Code");
        TicketAccessEntry.SetLoadFields("Entry No.", "Admission Code");
        TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        if (not TicketAccessEntry.FindSet()) then
            exit(false);
        repeat
            if (not Admission.Get(TicketAccessEntry."Admission Code")) then
                exit(false);
            if (not TicketBom.Get(ItemNo, VariantCode, TicketAccessEntry."Admission Code")) then
                exit(false);
            if (TicketBom.Default) then
                HasDefault := true;

            // The same read as step one: the last initial entry, then the last reservation entry, both with Quantity > 0.
            Slot := 0;
            TicketRequestManager.ReadCurrentSlot(TicketAccessEntry."Entry No.", IsolationLevel::ReadCommitted, Slot);

            ScheduleEntry.Reset();
            ScheduleEntry.ReadIsolation := IsolationLevel::ReadCommitted;
            ScheduleEntry.SetCurrentKey("External Schedule Entry No.");
            ScheduleEntry.SetRange("External Schedule Entry No.", Slot);
            ScheduleEntry.SetRange(Cancelled, false);
            if (ScheduleEntry.IsEmpty()) then
                exit(false);
        until (TicketAccessEntry.Next() = 0);
        // CreateChangeRequest flags CHANGE rows primary from the BOM's Default; without one the tickets have no row to relink to.
        exit(HasDefault);
    end;

    local procedure AddPendingDelta(var PendingDeltas: Dictionary of [Integer, Integer]; ScheduleEntryNo: Integer; Places: Integer)
    begin
        if (PendingDeltas.ContainsKey(ScheduleEntryNo)) then
            PendingDeltas.Set(ScheduleEntryNo, PendingDeltas.Get(ScheduleEntryNo) + Places)
        else
            PendingDeltas.Add(ScheduleEntryNo, Places);
    end;

    local procedure IsLineChangeable(var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary; var ChangeableByEntryNo: Dictionary of [Integer, Boolean]) Changeable: Boolean
    var
        CurrentRow: Record "NPR TM Ticket Reservation Req.";
        ChildRow: Record "NPR TM Ticket Reservation Req.";
    begin
        if (ChangeableByEntryNo.Get(TempLineBuffer.CurrentPrimaryEntryNo, Changeable)) then
            exit(Changeable);
        CurrentRow.ReadIsolation := IsolationLevel::ReadCommitted;
        CurrentRow.SetLoadFields("Request Status");
        CurrentRow.Get(TempLineBuffer.CurrentPrimaryEntryNo);
        if (CurrentRow."Request Status" <> CurrentRow."Request Status"::CONFIRMED) then
            Changeable := false
        else begin
            // A REVOKE child (refund in progress or completed) would be walked into and copied by CreateChangeRequest (Is Superseeded counts any child).
            ChildRow.ReadIsolation := IsolationLevel::ReadCommitted;
            ChildRow.SetCurrentKey("Superseeds Entry No.");
            ChildRow.SetRange("Superseeds Entry No.", TempLineBuffer.CurrentPrimaryEntryNo);
            ChildRow.SetRange("Entry Type", ChildRow."Entry Type"::REVOKE);
            if (not ChildRow.IsEmpty()) then
                Changeable := false
            else
                Changeable := StepOneCanCopyLine(TempLineBuffer.CurrentPrimaryEntryNo, TempLineBuffer.ItemNo, TempLineBuffer.VariantCode);
        end;
        ChangeableByEntryNo.Add(TempLineBuffer.CurrentPrimaryEntryNo, Changeable);
    end;

    internal procedure GetReferenceDateTime(AdmissionCode: Code[20]): DateTime
    begin
        exit(_TimeHelper.GetLocalTimeAtAdmission(AdmissionCode));
    end;

    internal procedure ChangeReservation(ReservationToken: Text[100]; PinCode: Text; var TempRequest: Record "NPR TM Reschedule Line Buffer" temporary; var TempResult: Record "NPR TM Reschedule Line Buffer" temporary; var FailedRequestEntryNo: Integer; var Refusal: Enum "NPR TM Reschedule Refusal"; var ChangeTokens: List of [Text[100]]): Enum "NPR TM Resched. Change Outcome"
    var
        TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary;
        RequestMutex: Record "NPR TM TicketRequestMutex";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Outcome: Enum "NPR TM Resched. Change Outcome";
        OriginalToken: Text[100];
    begin
        TempResult.Reset();
        TempResult.DeleteAll();
        FailedRequestEntryNo := 0;
        Refusal := Refusal::NONE;
        Clear(ChangeTokens);

        if (not ResolveIdentity('', ReservationToken, PinCode, OriginalToken)) then
            exit(Outcome::NOT_FOUND);
        if (not IsOriginalRequestConfirmed(OriginalToken)) then
            exit(Outcome::NOT_FOUND);

        if (RequestMutex.IsLocked(OriginalToken)) then
            exit(Outcome::BUSY);
        if (not RequestMutex.Acquire(OriginalToken, SessionId())) then
            exit(Outcome::BUSY);

        LoadCurrentLines(OriginalToken, TempLineBuffer);
        EvaluateEligibility(TempLineBuffer);
        Outcome := ValidateChangeRequest(TempLineBuffer, TempRequest, FailedRequestEntryNo, Refusal);
        if (Outcome = Outcome::CHANGED) then begin
            ApplyChange(OriginalToken, TempLineBuffer, TempRequest, TempResult, ChangeTokens, FailedRequestEntryNo);
            TicketRequestManager.MarkChangeRequestsConfirmed(ChangeTokens);
            CapacityWebHook.EmitTouchedEntries();
        end;
        RequestMutex.Release(OriginalToken);
        exit(Outcome);
    end;

    local procedure ApplyChange(OriginalToken: Text[100]; var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary; var TempRequest: Record "NPR TM Reschedule Line Buffer" temporary; var TempResult: Record "NPR TM Reschedule Line Buffer" temporary; var ChangeTokens: List of [Text[100]]; var FailedRequestEntryNo: Integer)
    var
        CurrentRow: Record "NPR TM Ticket Reservation Req.";
        ChangeRow: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        NewToken: Text[100];
        ResponseMessage: Text;
        LineIndex: Integer;
        NextResultEntryNo: Integer;
    begin
        LineIndex := 1;
        TempRequest.Reset();
        TempRequest.SetRange(LineReferenceNo, LineIndex);
        while (TempRequest.FindSet()) do begin
            TempLineBuffer.Reset();
            TempLineBuffer.SetRange(CurrentPrimarySystemId, TempRequest.CurrentPrimarySystemId);
            TempLineBuffer.FindFirst();
            CurrentRow.Get(TempLineBuffer.CurrentPrimaryEntryNo);

            Ticket.Reset();
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetRange("Ticket Reservation Entry No.", CurrentRow."Entry No.");
            Ticket.FindFirst();

            NewToken := TicketRequestManager.GetNewToken();
            if (not TicketRequestManager.CreateChangeRequest(Ticket."External Ticket No.", CurrentRow."Authorization Code", NewToken, ResponseMessage)) then
                Error(IntegrityErr, OriginalToken, StrSubstNo(CreateChangeFailedLbl, CurrentRow."Entry No.", ResponseMessage));

            WriteChangeRowSlots(OriginalToken, NewToken, TempLineBuffer, ChangeRow, Ticket);
            MoveRequestedAdmissions(TempLineBuffer, TempRequest, Ticket, FailedRequestEntryNo);
            FindPrimaryChangeRow(OriginalToken, NewToken, CurrentRow, ChangeRow);
            Ticket.ModifyAll("Ticket Reservation Entry No.", ChangeRow."Entry No.", false);
            AddChangeResults(NewToken, TempLineBuffer, ChangeRow, TempResult, NextResultEntryNo);

            ChangeTokens.Add(NewToken);
            LineIndex += 1;
            TempRequest.Reset();
            TempRequest.SetRange(LineReferenceNo, LineIndex);
        end;
        FailedRequestEntryNo := 0;
    end;

    // A reused REGISTERED change request still holds the slots of its abandoned attempt, so unmoved admissions get their current slot too, buffered for the response.
    local procedure WriteChangeRowSlots(OriginalToken: Text[100]; NewToken: Text[100]; var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary; var ChangeRow: Record "NPR TM Ticket Reservation Req."; var Ticket: Record "NPR TM Ticket")
    begin
        if (TempLineBuffer.FindSet()) then
            repeat
                ChangeRow.Reset();
                ChangeRow.SetCurrentKey("Session Token ID", "Ext. Line Reference No.", "Admission Inclusion");
                ChangeRow.SetRange("Session Token ID", NewToken);
                ChangeRow.SetRange("Admission Code", TempLineBuffer.AdmissionCode);
                if (TempLineBuffer.RequestedExtScheduleEntryNo = 0) then begin
                    TempLineBuffer.CurrentExtScheduleEntryNo := GetCurrentSlot(Ticket."No.", TempLineBuffer.AdmissionCode, OriginalToken);
                    TempLineBuffer.Modify();
                end;
                if (TempLineBuffer.RequestedExtScheduleEntryNo <> 0) then
                    ChangeRow.ModifyAll("External Adm. Sch. Entry No.", TempLineBuffer.RequestedExtScheduleEntryNo, false)
                else
                    ChangeRow.ModifyAll("External Adm. Sch. Entry No.", TempLineBuffer.CurrentExtScheduleEntryNo, false);
            until (TempLineBuffer.Next() = 0);
    end;

    local procedure MoveRequestedAdmissions(var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary; var TempRequest: Record "NPR TM Reschedule Line Buffer" temporary; var Ticket: Record "NPR TM Ticket"; var FailedRequestEntryNo: Integer)
    var
        ReferenceDateTime: DateTime;
    begin
        repeat
            TempLineBuffer.SetRange(AdmissionCode, TempRequest.AdmissionCode);
            TempLineBuffer.FindFirst();
            if (TempLineBuffer.RequestedExtScheduleEntryNo <> 0) then begin
                // Survives a thrown move error (a variable, not a row), so the handler can name the move that failed.
                FailedRequestEntryNo := TempRequest.EntryNo;
                ReferenceDateTime := GetReferenceDateTime(TempLineBuffer.AdmissionCode);
                Ticket.FindSet();
                repeat
                    _TicketManagement.RescheduleTicketAdmission(Ticket."No.", TempLineBuffer.RequestedExtScheduleEntryNo, true, ReferenceDateTime);
                until (Ticket.Next() = 0);
            end;
        until (TempRequest.Next() = 0);
        TempLineBuffer.SetRange(AdmissionCode);
    end;

    // The CHANGE row of the current primary row's admission wins when the item has two Default BOM lines; the first primary row otherwise, as the back-office page takes it.
    local procedure FindPrimaryChangeRow(OriginalToken: Text[100]; NewToken: Text[100]; var CurrentRow: Record "NPR TM Ticket Reservation Req."; var ChangeRow: Record "NPR TM Ticket Reservation Req.")
    begin
        ChangeRow.Reset();
        ChangeRow.SetCurrentKey("Session Token ID", "Ext. Line Reference No.", "Admission Inclusion");
        ChangeRow.SetRange("Session Token ID", NewToken);
        ChangeRow.SetRange("Primary Request Line", true);
        ChangeRow.SetRange("Admission Code", CurrentRow."Admission Code");
        if (not ChangeRow.FindFirst()) then begin
            ChangeRow.SetRange("Admission Code");
            if (not ChangeRow.FindFirst()) then
                Error(IntegrityErr, OriginalToken, StrSubstNo(NoPrimaryChangeRowLbl, NewToken));
        end;
    end;

    local procedure AddChangeResults(NewToken: Text[100]; var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary; ChangeRow: Record "NPR TM Ticket Reservation Req."; var TempResult: Record "NPR TM Reschedule Line Buffer" temporary; var NextResultEntryNo: Integer)
    begin
        TempLineBuffer.FindSet();
        repeat
            NextResultEntryNo += 1;
            TempResult := TempLineBuffer;
            TempResult.EntryNo := NextResultEntryNo;
            TempResult.CurrentToken := NewToken;
            TempResult.CurrentPrimaryEntryNo := ChangeRow."Entry No.";
            TempResult.CurrentPrimarySystemId := ChangeRow.SystemId;
            if (TempLineBuffer.RequestedExtScheduleEntryNo <> 0) then
                TempResult.CurrentExtScheduleEntryNo := TempLineBuffer.RequestedExtScheduleEntryNo;
            TempResult.Insert();
        until (TempLineBuffer.Next() = 0);
    end;
}
