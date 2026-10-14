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
        if (TicketReservationRequest.IsEmpty()) then
            exit(false);
        TicketReservationRequest.SetFilter("Request Status", '<>%1', TicketReservationRequest."Request Status"::CONFIRMED);
        exit(TicketReservationRequest.IsEmpty());
    end;

    internal procedure LoadCurrentLines(OriginalToken: Text[100]; var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary)
    var
        PrimaryRow: Record "NPR TM Ticket Reservation Req.";
        CurrentRow: Record "NPR TM Ticket Reservation Req.";
        SiblingRow: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        Admission: Record "NPR TM Admission";
        AdmissionCodes: Dictionary of [Code[20], Boolean];
        ItemVariants: Dictionary of [Text, Boolean];
        Ambiguous: Boolean;
        NextEntryNo: Integer;
    begin
        TempLineBuffer.Reset();
        TempLineBuffer.DeleteAll();

        // Reset() restores the default isolation and the full field load, so isolation and SetLoadFields always follow it.
        PrimaryRow.Reset();
        PrimaryRow.ReadIsolation := IsolationLevel::ReadCommitted;
        PrimaryRow.SetLoadFields("Entry No.", SystemId, "Session Token ID", "Ext. Line Reference No.", "Superseeds Entry No.", "Item No.", "Variant Code", Quantity);
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

            Ticket.ReadIsolation := IsolationLevel::ReadCommitted;
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetLoadFields("Valid From Date", "Valid To Date");
            Ticket.SetRange("Ticket Reservation Entry No.", CurrentRow."Entry No.");
            if (not Ticket.FindFirst()) then
                Error(IntegrityErr, OriginalToken, StrSubstNo(NoTicketsLbl, CurrentRow."Entry No."));

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
        until (PrimaryRow.Next() = 0);
    end;

    // The current row is the row the line's tickets point to, among the original primary row and its CONFIRMED descendants at any depth.
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
        ChainRow.SetRange("Request Status", ChainRow."Request Status"::CONFIRMED);
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
        ChainRow.SetLoadFields("Entry No.", SystemId, "Session Token ID", "Ext. Line Reference No.", "Superseeds Entry No.", "Item No.", "Variant Code", Quantity);
        ChainRow.Get(OwnerEntryNo);
        CurrentRow := ChainRow;
    end;

    // Reads the slot the way CreateChangeRequest reads it for a new change request.
    local procedure GetCurrentSlot(TicketNo: Code[20]; AdmissionCode: Code[20]; OriginalToken: Text[100]) CurrentSlot: Integer
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        TicketAccessEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        TicketAccessEntry.SetCurrentKey("Ticket No.", "Admission Code");
        TicketAccessEntry.SetLoadFields("Entry No.");
        TicketAccessEntry.SetRange("Ticket No.", TicketNo);
        TicketAccessEntry.SetRange("Admission Code", AdmissionCode);
        if (TicketAccessEntry.FindFirst()) then begin
            CurrentSlot := 0;
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.ReadIsolation := IsolationLevel::ReadCommitted;
            DetTicketAccessEntry.SetLoadFields("External Adm. Sch. Entry No.");
            DetTicketAccessEntry.SetRange("Ticket Access Entry No.", TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
            DetTicketAccessEntry.SetRange(Type, DetTicketAccessEntry.Type::INITIAL_ENTRY);
            if (DetTicketAccessEntry.FindLast()) then
                CurrentSlot := DetTicketAccessEntry."External Adm. Sch. Entry No.";
            DetTicketAccessEntry.SetRange(Type, DetTicketAccessEntry.Type::RESERVATION);
            if (DetTicketAccessEntry.FindLast()) then
                CurrentSlot := DetTicketAccessEntry."External Adm. Sch. Entry No.";
        end;
        if (CurrentSlot = 0) then
            Error(IntegrityErr, OriginalToken, StrSubstNo(NoCurrentSlotLbl, TicketNo, AdmissionCode));
    end;

    internal procedure EvaluateEligibility(var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary)
    var
        Ticket: Record "NPR TM Ticket";
        LineReason: Enum "NPR TM Reschedule Refusal";
        TicketReason: Enum "NPR TM Reschedule Refusal";
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
        Admission: Record "NPR TM Admission";
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

        if (not TicketBOM.Get(TempLineBuffer.ItemNo, TempLineBuffer.VariantCode, TempLineBuffer.AdmissionCode)) then
            TicketBOM.Init();
        if (not Admission.Get(TempLineBuffer.AdmissionCode)) then
            Admission.Init();
        // The ticket base calendar is read only when a code exists; most tenants have none (the worker in TM 4176 exits the same way, this saves the call).
        HasTicketCalendar := ((TicketBOM."Ticket Base Calendar Code" <> '') or (Admission."Ticket Base Calendar Code" <> ''));

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

        // An unresolved current slot leaves Entry No. 0, which no group counts.
        CurrentScheduleEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        CurrentScheduleEntry.SetCurrentKey("External Schedule Entry No.");
        CurrentScheduleEntry.SetLoadFields("Admission Code", "Schedule Code", "Admission Start Date");
        CurrentScheduleEntry.SetRange("External Schedule Entry No.", TempLineBuffer.CurrentExtScheduleEntryNo);
        CurrentScheduleEntry.SetRange(Cancelled, false);
        if (not CurrentScheduleEntry.FindLast()) then
            Clear(CurrentScheduleEntry);

        repeat
            if (SlotQualifies(ScheduleEntry, TempLineBuffer, CurrentScheduleEntry, TicketBOM, HasTicketCalendar, ReferenceDate, ReferenceTime, NonWorkingByDate, PendingDeltas, GroupUsageCache, Remaining, BlockReason)) then begin
                TempSlot := ScheduleEntry;
                TempSlot.Insert();
                if (Remaining >= 0) then
                    RemainingByEntryNo.Add(ScheduleEntry."Entry No.", Remaining);
            end;
        until (ScheduleEntry.Next() = 0);
    end;

    local procedure SlotQualifies(var ScheduleEntry: Record "NPR TM Admis. Schedule Entry"; var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary; CurrentScheduleEntry: Record "NPR TM Admis. Schedule Entry"; TicketBOM: Record "NPR TM Ticket Admission BOM"; HasTicketCalendar: Boolean; ReferenceDate: Date; ReferenceTime: Time; var NonWorkingByDate: Dictionary of [Date, Boolean]; PendingDeltas: Dictionary of [Integer, Integer]; var GroupUsageCache: Dictionary of [Text, Integer]; var Remaining: Integer; var BlockReason: Enum "NPR TM Sch. Block Sales Reason"): Boolean
    var
        NonWorking: Boolean;
        CalendarText: Text;
        Bounded: Boolean;
    begin
        Remaining := -1;

        // The current slot and the dates before the reference date are already excluded by the filters of GetSlots.
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

        if (not _TicketManagement.IsWithinScheduleSalesWindow(ScheduleEntry, TicketBOM, ReferenceDate, ReferenceTime, BlockReason)) then
            exit(false);

        Bounded := _TicketManagement.CalculateRemainingCapacityForMove(TempLineBuffer.ItemNo, TempLineBuffer.VariantCode, ScheduleEntry, CurrentScheduleEntry, TempLineBuffer.Quantity, PendingDeltas, GroupUsageCache, Remaining);
        if (not Bounded) then begin
            Remaining := -1;
            exit(true);
        end;
        exit(Remaining >= TempLineBuffer.Quantity);
    end;

    internal procedure GetReferenceDateTime(AdmissionCode: Code[20]): DateTime
    begin
        exit(_TimeHelper.GetLocalTimeAtAdmission(AdmissionCode));
    end;
}
