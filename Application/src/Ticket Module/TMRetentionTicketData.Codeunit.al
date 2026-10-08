/// <summary>
/// Deletes obsolete ticket data. A ticket is deleted when its Valid To Date is before the cutoff (today minus the Ticket
/// Setup "Retire Used Tickets After" period, two years by default), every one of its access entries has been used or the
/// ticket is blocked, and none of its revenue deferrals is still pending. A ticket that was never fully used and is not
/// blocked is kept however old it is; the Block Unused Expired Tickets action blocks such tickets so the next run deletes
/// them. A ticket without a reservation request follows the same rule, and is also found from the ticket table because a
/// migrated one can have no access entries at all; with none, nothing on it is unused. With the ticket go its access
/// entries and their detail entries, its settled deferrals, its notification entries and participant lines, and its
/// reservation request, which goes with the last ticket that points at it, together with the requests it superseded. The
/// import archive of a reservation goes once the reservation has no requests left.
///
/// Revoke requests in status Canceled that were created before the cutoff go once their ticket and the request they
/// revoked are gone. Admission schedule entries that start before the cutoff go when no ticket entry references them.
/// Cancelled schedule entries that started more than a month ago go when a live version replaced them or no ticket entry
/// references them. Schedule entries with no admission, no dates and no external number always go.
/// </summary>
/// <remarks>
/// The time budget, "Duration Retire Tickets (Min.)" (a negative value means no limit), is checked between batches, so a
/// run ends after the limit rather than at it; every stage gets at least one batch, and the next run carries on. Each run
/// reads the access entries from the start, so data with many kept tickets makes a run slow even when it deletes little.
/// Generated ticket statistics are not touched.
/// </remarks>
codeunit 6014688 "NPR TM Retention Ticket Data"
{
    Access = Internal;

    var
        _Window: Dialog;
        _EndDateTime: DateTime;

    trigger OnRun()
    begin
        Main();
    end;

    procedure MainWithConfirm()
    var
        ConfirmTicketDelete: Label 'WARNING! This can take a long time to finish. Lists and reports that read tickets and admission schedules directly will no longer show data from before %1. Generated ticket statistics are not affected. Do you want to continue?', Comment = '%1 = the retention cutoff date';
    begin

        if (not Confirm(ConfirmTicketDelete, true, GetCutoffDate())) then
            exit;

        Main();
    end;

    procedure Main()
    var
        BatchSize: Integer;
        WindowText: Label '#1############################ #2#######';
    begin
        if (GuiAllowed) then
            _Window.Open(WindowText);

        _EndDateTime := GetEndDateTime();
        BatchSize := 1000;

        DeleteTicketsWithoutRequest(BatchSize);
        DeleteTickets(BatchSize);
        DeleteCancelledRequests(BatchSize);
        DeleteOrphanedScheduleEntries();
        DeleteAdmissionSchedules(BatchSize);
        DeleteCancelledScheduleEntries(BatchSize);

        if (GuiAllowed) then
            _Window.Close();
    end;

    internal procedure DeleteTickets(BatchSize: Integer)
    var
        TicketList: Dictionary of [Code[20], Boolean];
        TicketNo: Code[20];
        ResumeFromEntry: Integer;
        DeleteTicketLbl: Label 'Deleting...', MaxLength = 30;
        DeleteCounter: Integer;
    begin
        if (BatchSize <= 0) then
            exit;

        ResumeFromEntry := 0;
        while (true) do begin
            Clear(TicketList);
            ResumeFromEntry := SelectTicketsToDelete(BatchSize, ResumeFromEntry, TicketList);

            DeleteCounter := TicketList.Count();
            if (DeleteCounter = 0) then
                exit;

            if (GuiAllowed()) then
                _Window.Update(1, DeleteTicketLbl);

            foreach TicketNo in TicketList.Keys() do begin
                DeleteOneTicket(TicketNo);

                if (GuiAllowed()) then
                    if (DeleteCounter mod 10 = 0) then
                        _Window.Update(2, DeleteCounter);
                DeleteCounter -= 1;
            end;

            Commit();

            // Only allow X minutes of work per session
            if (CurrentDateTime() > _EndDateTime) then
                exit;
        end;

    end;

    // The ticket scan starts from access entries, and a migrated ticket without a reservation request can have none.
    internal procedure DeleteTicketsWithoutRequest(BatchSize: Integer)
    var
        Ticket: Record "NPR TM Ticket";
        DeleteCount: Integer;
        ProcessCount: Integer;
        DeleteTicketLbl: Label 'Deleting Tickets (No Request)', MaxLength = 30;
    begin
        if (BatchSize <= 0) then
            exit;

        Ticket.ReadIsolation := IsolationLevel::ReadUncommitted;
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', 0);
        Ticket.SetFilter("Valid To Date", '<%1', GetCutoffDate());
        Ticket.SetLoadFields("No.");
        if (not Ticket.FindSet()) then
            exit;

        if (GuiAllowed()) then
            _Window.Update(1, DeleteTicketLbl);

        repeat
            if (DeleteOneTicket(Ticket."No.")) then begin
                DeleteCount += 1;

                if (GuiAllowed()) then
                    if (DeleteCount mod 10 = 0) then
                        _Window.Update(2, DeleteCount);

                if (DeleteCount mod BatchSize = 0) then begin
                    Commit();
                    if (CurrentDateTime() > _EndDateTime) then
                        exit;
                end;
            end;

            // Once this transaction has deleted a ticket, the checks lock every ticket they read, including the ones they keep.
            ProcessCount += 1;
            if (ProcessCount mod BatchSize = 0) then
                Commit();
        until (Ticket.Next() = 0);
    end;

    internal procedure DeleteAdmissionSchedules(BatchSize: Integer);
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        AdmissionScheduleEntry2: Record "NPR TM Admis. Schedule Entry";
        DeleteCount: Integer;
        ProcessCount: Integer;
        CutoffDate: Date;
        SelectScheduleLbl: Label 'Selecting Schedules (%1)', MaxLength = 25;
    begin
        if (BatchSize <= 0) then
            exit;

        CutoffDate := GetCutoffDate();
        AdmissionScheduleEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
        AdmissionScheduleEntry.SetCurrentKey("Admission Start Date");
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '<%1', CutoffDate);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmissionScheduleEntry.SetLoadFields("External Schedule Entry No.");
        if (not AdmissionScheduleEntry.FindSet()) then
            exit;

        if (GuiAllowed()) then begin
            _Window.Update(1, StrSubstNo(SelectScheduleLbl, Round(AdmissionScheduleEntry.Count() / BatchSize, 1, '>')));
            _Window.Update(2, BatchSize);
        end;

        DeleteCount := BatchSize;
        while ((DeleteCount = BatchSize) or (ProcessCount mod 10000 = 0)) do begin

            DeleteCount := 0;
            repeat
                // A 0 would match every old slot that has no external number, not just this one.
                if (AdmissionScheduleEntry."External Schedule Entry No." <> 0) then
                    if (not IsScheduleEntryInUse(AdmissionScheduleEntry."External Schedule Entry No.")) then begin
                        AdmissionScheduleEntry2.SetCurrentKey("External Schedule Entry No.");
                        AdmissionScheduleEntry2.SetFilter("External Schedule Entry No.", '=%1', AdmissionScheduleEntry."External Schedule Entry No.");
                        AdmissionScheduleEntry2.SetFilter("Admission Start Date", '<%1', CutoffDate);
                        AdmissionScheduleEntry2.DeleteAll();
                        DeleteCount += 1;
                    end;

                ProcessCount += 1;
                if (GuiAllowed()) then
                    if (ProcessCount mod 10 = 0) then
                        _Window.Update(2, ProcessCount);

            until (AdmissionScheduleEntry.Next() = 0) or (DeleteCount >= BatchSize) or (ProcessCount mod 10000 = 0);
            Commit();

            // Only allow X minutes of work per session
            if (CurrentDateTime() > _EndDateTime) then
                exit;

        end;
    end;

    internal procedure DeleteCancelledScheduleEntries(BatchSize: Integer)
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleEntryDelete: Record "NPR TM Admis. Schedule Entry";
        DeleteCount: Integer;
        DeleteScheduleLbl: Label 'Deleting Cancelled Slots...', MaxLength = 30;
    begin
        if (BatchSize <= 0) then
            exit;

        AdmissionScheduleEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
        AdmissionScheduleEntry.SetCurrentKey("Admission Start Date");
        // Keep the last month of cancelled slots, as they may be used to replace a live slot that was cancelled and then re-booked.
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '<%1', CalcDate('<-1M>', Today()));
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', true);
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '<>%1', 0);
        AdmissionScheduleEntry.SetLoadFields("Entry No.", "External Schedule Entry No.");
        if (not AdmissionScheduleEntry.FindSet()) then
            exit;

        if (GuiAllowed()) then
            _Window.Update(1, DeleteScheduleLbl);

        repeat
            if (IsCancelledScheduleEntryReleasable(AdmissionScheduleEntry."External Schedule Entry No.")) then
                if (ScheduleEntryDelete.Get(AdmissionScheduleEntry."Entry No.")) then begin
                    // Without the trigger: it totals the tickets of the whole external number, which on a replaced version are its sibling's.
                    ScheduleEntryDelete.Delete();
                    DeleteCount += 1;

                    if (GuiAllowed()) then
                        if (DeleteCount mod 10 = 0) then
                            _Window.Update(2, DeleteCount);

                    if (DeleteCount mod BatchSize = 0) then begin
                        Commit();
                        if (CurrentDateTime() > _EndDateTime) then
                            exit;
                    end;
                end;
        until (AdmissionScheduleEntry.Next() = 0);
    end;

    local procedure IsCancelledScheduleEntryReleasable(ExternalScheduleEntryNo: Integer): Boolean
    var
        ActiveVersion: Record "NPR TM Admis. Schedule Entry";
    begin
        ActiveVersion.ReadIsolation := IsolationLevel::ReadUncommitted;
        ActiveVersion.SetCurrentKey("External Schedule Entry No.");
        ActiveVersion.SetFilter("External Schedule Entry No.", '=%1', ExternalScheduleEntryNo);
        ActiveVersion.SetFilter(Cancelled, '=%1', false);
        if (not ActiveVersion.IsEmpty()) then
            exit(true);

        exit(not IsScheduleEntryInUse(ExternalScheduleEntryNo));
    end;

    local procedure IsScheduleEntryInUse(ExternalScheduleEntryNo: Integer): Boolean
    var
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        DetTicketAccessEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
        DetTicketAccessEntry.SetCurrentKey("External Adm. Sch. Entry No.", Type, Open, "Posting Date");
        DetTicketAccessEntry.SetFilter("External Adm. Sch. Entry No.", '=%1', ExternalScheduleEntryNo);
        exit(not DetTicketAccessEntry.IsEmpty());
    end;

    // This special case is resulting from container creation, all fields are empty, is not caught by the other retention rules. 
    internal procedure DeleteOrphanedScheduleEntries()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        AdmissionScheduleEntry.SetCurrentKey("External Schedule Entry No.");
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', 0);
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', '');
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', 0D);
        AdmissionScheduleEntry.SetFilter("Admission End Date", '=%1', 0D);
        AdmissionScheduleEntry.DeleteAll();
    end;

    local procedure SelectTicketsToDelete(BatchSize: Integer; EntryNo: Integer; var TicketsToDelete: Dictionary of [Code[20], Boolean]): Integer
    var
        TicketCutOffDate: Date;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        CouldBeDeleted: Boolean;
        BatchFull: Boolean;
        CurrentCount: Integer;
        SelectTicketLbl: Label 'Selecting Tickets (%1)', MaxLength = 25;
    begin

        TicketCutOffDate := GetCutoffDate();
        Ticket.ReadIsolation := IsolationLevel::ReadUncommitted;
        Ticket.SetLoadFields("Valid To Date", Blocked);
        TicketAccessEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
        TicketAccessEntry.SetLoadFields("Ticket No.", "Access Date", "Entry No.");

        while (TicketsToDelete.Count() = 0) do begin

            TicketAccessEntry.SetFilter("Entry No.", '>%1', EntryNo);
            if (not TicketAccessEntry.FindSet()) then
                exit(EntryNo);

            if (GuiAllowed()) then
                _Window.Update(1, StrSubstNo(SelectTicketLbl, Round(TicketAccessEntry.Count() / BatchSize, 1, '>')));

            CurrentCount := 0;
            BatchFull := false;
            CouldBeDeleted := Ticket.Get(TicketAccessEntry."Ticket No.");
            CouldBeDeleted := CouldBeDeleted and (Ticket."Valid To Date" < TicketCutOffDate);
            repeat
                if (TicketAccessEntry."Ticket No." <> Ticket."No.") then begin
                    if (CouldBeDeleted) then
                        TicketsToDelete.Set(Ticket."No.", true);

                    CurrentCount += 1;
                    if (GuiAllowed()) then
                        if (CurrentCount mod 10 = 0) then
                            _Window.Update(2, BatchSize - CurrentCount);

                    // A batch only ends between tickets, so the next pass sees the new ticket from its first entry.
                    BatchFull := (CurrentCount >= BatchSize);
                    if (not BatchFull) then begin
                        CouldBeDeleted := Ticket.Get(TicketAccessEntry."Ticket No.");
                        CouldBeDeleted := CouldBeDeleted and (Ticket."Valid To Date" < TicketCutOffDate);
                    end;
                end;

                if (not BatchFull) then begin
                    CouldBeDeleted := CouldBeDeleted and ((TicketAccessEntry."Access Date" <> 0D) or (Ticket.Blocked));
                    EntryNo := TicketAccessEntry."Entry No.";
                end;

            until (BatchFull or (TicketAccessEntry.Next() = 0));

            if (not BatchFull) then
                if (CouldBeDeleted) then
                    TicketsToDelete.Set(Ticket."No.", true);

        end;

        exit(EntryNo);
    end;

    internal procedure DeleteOneTicket(TicketNo: Code[20]) Deleted: Boolean
    var
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
        TicketParticipantWks: Record "NPR TM Ticket Particpt. Wks.";
        Ticket: Record "NPR TM Ticket";
        RevenueDeferral: Codeunit "NPR TM RevenueDeferral";
        TicketAccessEntryNos: List of [Integer];
        TicketNotDeletedErr: Label '%1 %2 could not be deleted.', Comment = '%1 = ticket table caption, %2 = ticket number';
    begin

        Deleted := false;

        if (TicketNo = '') then
            exit;

        if (not Ticket.Get(TicketNo)) then
            exit;

        // The scan may have judged this ticket on only some of its entries, so all of them are checked before anything is deleted.
        TicketAccessEntry.SetCurrentKey("Ticket No.");
        TicketAccessEntry.SetLoadFields("Entry No.", "Access Date");
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (TicketAccessEntry.FindSet()) then
            repeat
                if ((TicketAccessEntry."Access Date" = 0D) and (not Ticket.Blocked)) then
                    exit;
                if (HasPendingDeferral(TicketAccessEntry."Entry No.")) then
                    exit;
                TicketAccessEntryNos.Add(TicketAccessEntry."Entry No.");
            until (TicketAccessEntry.Next() = 0);

        RevenueDeferral.DeleteDeferralRequests(TicketAccessEntryNos);

        DetTicketAccessEntry.SetCurrentKey("Ticket No.");
        DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetTicketAccessEntry.DeleteAll();

        TicketAccessEntry.DeleteAll();

        TicketNotificationEntry.SetCurrentKey("Ticket No.", "Notification Send Status");
        TicketNotificationEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketNotificationEntry.DeleteAll();

        TicketParticipantWks.SetCurrentKey("Ticket No.");
        TicketParticipantWks.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketParticipantWks.DeleteAll();

        DeleteTicketRequest(Ticket."Ticket Reservation Entry No.", Ticket."No.");

        Deleted := Ticket.Delete();
        if (not Deleted) then
            Error(TicketNotDeletedErr, Ticket.TableCaption(), Ticket."No.");
    end;

    // Deleting a deferral the engine will still act on would drop revenue that was never posted.
    local procedure HasPendingDeferral(TicketAccessEntryNo: Integer): Boolean
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        DeferRevenueRequest.ReadIsolation := IsolationLevel::ReadUncommitted;
        DeferRevenueRequest.SetLoadFields(Status);
        if (not DeferRevenueRequest.Get(TicketAccessEntryNo)) then
            exit(false);

        exit(not (DeferRevenueRequest.Status in [
            DeferRevenueRequest.Status::UNRESOLVED,
            DeferRevenueRequest.Status::DEFERRED,
            DeferRevenueRequest.Status::DEFERRED_FORCED,
            DeferRevenueRequest.Status::IMMEDIATE,
            DeferRevenueRequest.Status::DEFERRAL_ABORTED]));
    end;

    local procedure DeleteTicketRequest(TicketRequestEntryNo: Integer; RetiringTicketNo: Code[20])
    var
        VisitedEntryNos: List of [Integer];
    begin
        DeleteTicketRequest(TicketRequestEntryNo, RetiringTicketNo, VisitedEntryNos);
    end;

    local procedure DeleteTicketRequest(TicketRequestEntryNo: Integer; RetiringTicketNo: Code[20]; var VisitedEntryNos: List of [Integer])
    var
        TicketResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        RequestDelete: Record "NPR TM Ticket Reservation Req.";
        OtherTicket: Record "NPR TM Ticket";
    begin
        if (TicketRequestEntryNo = 0) then
            exit;

        // A corrupted supersede chain can loop back on itself.
        if (VisitedEntryNos.Contains(TicketRequestEntryNo)) then
            exit;
        VisitedEntryNos.Add(TicketRequestEntryNo);

        if (not TicketRequest.Get(TicketRequestEntryNo)) then
            exit;

        if (TicketRequest."Session Token ID" = '') then
            exit;

        RequestDelete.SetFilter("Session Token ID", '=%1', TicketRequest."Session Token ID");
        RequestDelete.SetFilter("Ext. Line Reference No.", '=%1', TicketRequest."Ext. Line Reference No.");

        // An import can repeat a line reference across its tickets, and the pre-assigned number is the per-ticket handle.
        if (TicketRequest.PreAssignedTicketNumber <> '') then
            RequestDelete.SetFilter(PreAssignedTicketNumber, '=%1', TicketRequest.PreAssignedTicketNumber);

        // A group ticket carries its request's whole quantity, so whether the request goes depends on the tickets still pointing at it, not on its quantity.
        OtherTicket.ReadIsolation := IsolationLevel::ReadUncommitted;
        OtherTicket.SetCurrentKey("Ticket Reservation Entry No.");
        OtherTicket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
        OtherTicket.SetFilter("No.", '<>%1', RetiringTicketNo);
        if (not OtherTicket.IsEmpty()) then begin
            if (TicketRequest.Quantity > 1) then
                RequestDelete.ModifyAll(Quantity, TicketRequest.Quantity - 1);
            exit;
        end;

        // The delete takes every row of the request, and the check above only covers the row this ticket points at.
        if (IsTicketRequestInUse(RequestDelete, TicketRequest."Entry No.", RetiringTicketNo)) then
            exit;

        TicketResponse.SetCurrentKey("Request Entry No.");
        TicketResponse.SetFilter("Request Entry No.", '=%1', TicketRequest."Entry No.");
        TicketResponse.DeleteAll();

        RequestDelete.DeleteAll();

        // The archive records the import of a whole reservation, so it goes with the last of its requests.
        TicketRequest.Reset();
        TicketRequest.ReadIsolation := IsolationLevel::ReadUncommitted;
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', TicketRequest."Session Token ID");
        if (TicketRequest.IsEmpty()) then
            DeleteImportArchive(TicketRequest."Session Token ID");

        DeleteTicketRequest(TicketRequest."Superseeds Entry No.", RetiringTicketNo, VisitedEntryNos);
    end;

    local procedure IsTicketRequestInUse(var TicketRequest: Record "NPR TM Ticket Reservation Req."; CheckedEntryNo: Integer; RetiringTicketNo: Code[20]): Boolean
    var
        OtherRequest: Record "NPR TM Ticket Reservation Req.";
        OtherTicket: Record "NPR TM Ticket";
    begin
        OtherTicket.ReadIsolation := IsolationLevel::ReadUncommitted;
        OtherTicket.SetCurrentKey("Ticket Reservation Entry No.");
        OtherTicket.SetFilter("No.", '<>%1', RetiringTicketNo);

        OtherRequest.CopyFilters(TicketRequest);
        OtherRequest.ReadIsolation := IsolationLevel::ReadUncommitted;
        OtherRequest.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        OtherRequest.SetLoadFields("Entry No.");
        if (OtherRequest.FindSet()) then
            repeat
                if (OtherRequest."Entry No." <> CheckedEntryNo) then begin
                    OtherTicket.SetFilter("Ticket Reservation Entry No.", '=%1', OtherRequest."Entry No.");
                    if (not OtherTicket.IsEmpty()) then
                        exit(true);
                end;
            until (OtherRequest.Next() = 0);

        exit(false);
    end;

    local procedure DeleteImportArchive(Token: Text[100])
    var
        ImportTicketHeader: Record "NPR TM ImportTicketHeader";
    begin
        ImportTicketHeader.SetCurrentKey(TicketRequestToken);
        ImportTicketHeader.SetFilter(TicketRequestToken, '=%1', Token);
        ImportTicketHeader.DeleteAll(true);
    end;

    // Retiring a ticket walks back from the request it points at and never reaches a revoke, which points back at that request, so the revoke outlives its ticket.
    internal procedure DeleteCancelledRequests(BatchSize: Integer)
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        DeleteCount: Integer;
        DeleteRequestLbl: Label 'Deleting Cancellations...', MaxLength = 30;
    begin
        if (BatchSize <= 0) then
            exit;

        TicketRequest.SetCurrentKey("Request Status", "Expires Date Time");
        TicketRequest.SetFilter("Request Status", '=%1', TicketRequest."Request Status"::CANCELED);
        TicketRequest.SetFilter("Entry Type", '=%1', TicketRequest."Entry Type"::REVOKE);
        // The expiry is rewritten through a request's life and cleared on confirmation, so only the creation time tells its age.
        TicketRequest.SetFilter("Created Date Time", '>%1&<%2', 0DT, CreateDateTime(GetCutoffDate(), 0T));
        TicketRequest.SetLoadFields("Entry No.", "External Ticket Number", "Superseeds Entry No.");
        // Once this pass has deleted a request, the scan would otherwise lock every request it reads.
        TicketRequest.ReadIsolation := IsolationLevel::ReadUncommitted;
        if (not TicketRequest.FindSet()) then
            exit;

        if (GuiAllowed()) then
            _Window.Update(1, DeleteRequestLbl);

        repeat
            if (not IsCancellationLinked(TicketRequest)) then begin
                DeleteCancellation(TicketRequest."Entry No.");
                DeleteCount += 1;

                if (GuiAllowed()) then
                    if (DeleteCount mod 10 = 0) then
                        _Window.Update(2, DeleteCount);

                if (DeleteCount mod BatchSize = 0) then begin
                    Commit();
                    if (CurrentDateTime() > _EndDateTime) then
                        exit;
                end;
            end;
        until (TicketRequest.Next() = 0);
    end;

    local procedure IsCancellationLinked(TicketRequest: Record "NPR TM Ticket Reservation Req."): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TicketByNumber: Record "NPR TM Ticket";
        SupersededRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        Ticket.ReadIsolation := IsolationLevel::ReadUncommitted;
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
        if (not Ticket.IsEmpty()) then
            exit(true);

        if (TicketRequest."External Ticket Number" <> '') then begin
            TicketByNumber.ReadIsolation := IsolationLevel::ReadUncommitted;
            TicketByNumber.SetCurrentKey("External Ticket No.");
            TicketByNumber.SetFilter("External Ticket No.", '=%1', UpperCase(TicketRequest."External Ticket Number"));
            if (not TicketByNumber.IsEmpty()) then
                exit(true);
        end;

        // A cancellation of a reservation that still exists is part of that reservation's history.
        if (TicketRequest."Superseeds Entry No." <> 0) then begin
            // The superseded request belongs to a live reservation, so this check must not lock it until the next commit.
            SupersededRequest.ReadIsolation := IsolationLevel::ReadUncommitted;
            SupersededRequest.SetLoadFields("Entry No.");
            if (SupersededRequest.Get(TicketRequest."Superseeds Entry No.")) then
                exit(true);
        end;

        exit(false);
    end;

    local procedure DeleteCancellation(EntryNo: Integer)
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketResponse: Record "NPR TM Ticket Reserv. Resp.";
    begin
        if (not TicketRequest.Get(EntryNo)) then
            exit;

        TicketResponse.SetCurrentKey("Request Entry No.");
        TicketResponse.SetFilter("Request Entry No.", '=%1', TicketRequest."Entry No.");
        TicketResponse.DeleteAll();
        TicketRequest.Delete();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR TM Retention Ticket Data");
    end;

    #region Job Queue
    procedure AddTicketDataRetentionJobQueue(var JobQueueEntry: Record "Job Queue Entry"; Silent: Boolean): Boolean
    var
        ConfirmJobCreationQst: Label 'This function will add a new periodic job (Job Queue Entry), responsible for obsolete ticket data cleanup, including unused schedule entries (if a similar job already exists, system will not add anything).\Are you sure you want to continue?';
    begin
        if not Silent then
            if not Confirm(ConfirmJobCreationQst, true) then
                exit(false);
        exit(InitTicketDataRetentionJobQueue(JobQueueEntry));
    end;

    local procedure InitTicketDataRetentionJobQueue(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NextRunDateFormula: DateFormula;
        JobQueueCategoryTok: Label 'RETENTION', Locked = true, MaxLength = 10;
        JobQueueDescrLbl: Label 'Remove obsolete tickets and schedules', MaxLength = 250;
    begin
        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueMgt.SetJobTimeout(4, 0);  //4 hours

        JobQueueMgt.SetProtected(true);
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            CurrCodeunitId(),
            '',
            JobQueueDescrLbl,
            JobQueueMgt.NowWithDelayInSeconds(300),
            020000T,
            030000T,
            NextRunDateFormula,
            JobQueueCategoryTok,
            JobQueueEntry)
        then begin
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
            exit(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR TM Ticket Setup", 'OnAfterInsertEvent', '', true, false)]
    local procedure AddTicketDataRetentionJobQueueOnTicketSetupInsert(var Rec: Record "NPR TM Ticket Setup")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if Rec.IsTemporary() then
            exit;
        AddTicketDataRetentionJobQueue(JobQueueEntry, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        if not TicketSetup.ReadPermission() then
            exit;
        if not TicketSetup.Get() then
            exit;
        AddTicketDataRetentionJobQueue(JobQueueEntry, true);
    end;
    #endregion

    internal procedure GetCutoffDate(): Date
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        CutoffDate: Date;
    begin
        TicketSetup.Get();
        if (Format(TicketSetup."Retire Used Tickets After") = '') then
            if (Evaluate(TicketSetup."Retire Used Tickets After", '<2Y>', 9)) then
                TicketSetup.Modify();

        TicketSetup.TestField("Retire Used Tickets After");
        CutoffDate := Today() - Abs((Today() - CalcDate(TicketSetup."Retire Used Tickets After", Today())));

        exit(CutoffDate);
    end;

    local procedure GetEndDateTime(): DateTime
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        TicketSetup.Get();
        if (TicketSetup."Duration Retire Tickets (Min.)" = 0) then begin
            TicketSetup."Duration Retire Tickets (Min.)" := 55;
            TicketSetup.Modify();
        end;

        if (TicketSetup."Duration Retire Tickets (Min.)" < 0) then
            exit(CreateDateTime(DMY2Date(31, 12, 9999), 0T));

        exit(CurrentDateTime() + TicketSetup."Duration Retire Tickets (Min.)" * 60 * 1000);
    end;

}
