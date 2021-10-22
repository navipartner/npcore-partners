codeunit 6014688 "NPR TM Retention Ticket Data"
{
    var
        _Window: Dialog;
        _EndDateTime: DateTime;

    trigger OnRun()
    begin
        Main();
    end;

    procedure MainWithConfirm()
    var
        ConfirmTicketDelete: Label 'This job will remove obsolete tickets and schedules older than %1. Do you want to continue?';
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

        DeleteTickets(BatchSize);
        DeleteAdmissionSchedules(BatchSize);

        if (GuiAllowed) then
            _Window.Close();
    end;

    internal procedure DeleteTickets(BatchSize: Integer)
    var
        //TempTicketsToDelete: Record "NPR TM Ticket" temporary;
        TicketList: List of [Code[20]];
        TicketNo: Code[20];
        ResumeFromEntry: Integer;
        DeleteTicketLbl: Label 'Deleting...', MaxLength = 30;
        DeleteCounter: Integer;
    begin

        ResumeFromEntry := 0;
        while (true) do begin
            Clear(TicketList);
            ResumeFromEntry := SelectTicketsToDelete(BatchSize, ResumeFromEntry, TicketList);

            DeleteCounter := TicketList.Count();
            if (DeleteCounter = 0) then
                exit;

            if (GuiAllowed()) then
                _Window.Update(1, DeleteTicketLbl);

            DeleteCounter := TicketList.Count();
            foreach TicketNo in TicketList do begin
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

    internal procedure DeleteAdmissionSchedules(BatchSize: Integer);
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        AdmissionScheduleEntry2: Record "NPR TM Admis. Schedule Entry";
        DeleteCount: Integer;
        ProcessCount: Integer;
        SelectScheduleLbl: Label 'Selecting Schedules (%1)', MaxLength = 25;
    begin
        if (BatchSize <= 0) then
            exit;

        AdmissionScheduleEntry.SetFilter("Admission Start Date", '<=%1', GetCutoffDate());
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmissionScheduleEntry.SetAutoCalcFields("Open Reservations", "Open Admitted", Departed, "Initial Entry");
        AdmissionScheduleEntry.SetLoadFields("Open Reservations", "Open Admitted", Departed, "Initial Entry", "External Schedule Entry No.");
        if (not AdmissionScheduleEntry.FindSet()) then
            exit;

        if (GuiAllowed()) then begin
            _Window.Update(1, StrSubstNo(SelectScheduleLbl, Round(AdmissionScheduleEntry.Count() / BatchSize, 1, '>')));
            _Window.Update(2, BatchSize);
        end;

        DeleteCount := BatchSize;
        while (DeleteCount = BatchSize) do begin

            DeleteCount := 0;
            repeat
                if ((AdmissionScheduleEntry."Initial Entry" = 0) and (AdmissionScheduleEntry."Open Reservations" = 0) and (AdmissionScheduleEntry."Open Admitted" = 0) and (AdmissionScheduleEntry.Departed = 0)) then begin
                    AdmissionScheduleEntry2.SetFilter("External Schedule Entry No.", '=%1', AdmissionScheduleEntry."External Schedule Entry No.");
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

    local procedure SelectTicketsToDelete(BatchSize: Integer; EntryNo: Integer; var TicketsToDelete: List of [Code[20]]): Integer
    var
        TicketCutOffDate: Date;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        CouldBeDeleted: Boolean;
        CurrentCount: Integer;
        SelectTicketLbl: Label 'Selecting Tickets (%1)', MaxLength = 25;
    begin

        TicketCutOffDate := GetCutoffDate();
        Ticket.SetLoadFields("Valid To Date", Blocked);

        while (TicketsToDelete.Count() = 0) do begin

            TicketAccessEntry.SetFilter("Entry No.", '>%1', EntryNo);
            TicketAccessEntry.SetLoadFields("Ticket No.", "Access Date");
            if (not TicketAccessEntry.FindSet()) then
                exit(EntryNo);

            if (GuiAllowed()) then
                _Window.Update(1, StrSubstNo(SelectTicketLbl, Round(TicketAccessEntry.Count() / BatchSize, 1, '>')));

            CouldBeDeleted := false;
            CurrentCount := 0;
            CouldBeDeleted := Ticket.Get(TicketAccessEntry."Ticket No.");
            CouldBeDeleted := CouldBeDeleted and (Ticket."Valid To Date" < TicketCutOffDate);
            repeat
                if (TicketAccessEntry."Ticket No." <> Ticket."No.") then begin
                    if (CouldBeDeleted) then
                        if (not TicketsToDelete.Contains(Ticket."No.")) then
                            TicketsToDelete.Add(Ticket."No.");

                    CurrentCount += 1;
                    if (GuiAllowed()) then
                        if (CurrentCount mod 10 = 0) then
                            _Window.Update(2, BatchSize - CurrentCount);

                    CouldBeDeleted := Ticket.Get(TicketAccessEntry."Ticket No.");
                    CouldBeDeleted := CouldBeDeleted and (Ticket."Valid To Date" < TicketCutOffDate);
                end;
                CouldBeDeleted := CouldBeDeleted and ((TicketAccessEntry."Access Date" <> 0D) or (Ticket.Blocked));
                EntryNo := TicketAccessEntry."Entry No.";

            until ((TicketAccessEntry.Next() = 0) or (CurrentCount >= BatchSize));

        end;

        exit(EntryNo);
    end;

    local procedure DeleteOneTicket(TicketNo: Code[20])
    var
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
    begin

        Ticket.Get(TicketNo);

        DeleteTicketRequest(Ticket."Ticket Reservation Entry No.");

        DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetTicketAccessEntry.DeleteAll();

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.DeleteAll();

        Ticket.Delete();
    end;

    local procedure DeleteTicketRequest(TicketRequestEntryNo: Integer)
    var
        TicketResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        if (TicketRequestEntryNo = 0) then
            exit;

        if (not TicketRequest.Get(TicketRequestEntryNo)) then
            exit;

        if (TicketRequest.Quantity > 1) then begin
            TicketRequest.Reset();
            TicketRequest.SetFilter("Session Token ID", '=%1', TicketRequest."Session Token ID");
            TicketRequest.SetFilter("Ext. Line Reference No.", '=%1', TicketRequest."Ext. Line Reference No.");
            TicketRequest.ModifyAll(Quantity, TicketRequest.Quantity - 1);
            exit;
        end;

        if (TicketRequest."Superseeds Entry No." <> 0) then
            DeleteTicketRequest(TicketRequest."Superseeds Entry No.");

        TicketResponse.SetFilter("Request Entry No.", '=%1', TicketRequest."Entry No.");
        TicketResponse.DeleteAll();

        TicketRequest.Reset();
        TicketRequest.SetFilter("Session Token ID", '=%1', TicketRequest."Session Token ID");
        TicketRequest.SetFilter("Ext. Line Reference No.", '=%1', TicketRequest."Ext. Line Reference No.");
        TicketRequest.DeleteAll();
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
        JobQueueDescrLbl: Label 'Remove obsolete tickets and schedules', MaxLength = 250;
    begin
        Evaluate(NextRunDateFormula, '<1D>');

        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            CurrCodeunitId(),
            '',
            JobQueueDescrLbl,
            JobQueueMgt.NowWithDelayInSeconds(300),
            020000T,
            030000T,
            NextRunDateFormula,
            '',
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
            exit(CreateDateTime(DMY2Date(12, 31, 9999), 0T));

        exit(CurrentDateTime() + TicketSetup."Duration Retire Tickets (Min.)" * 60 * 1000);
    end;

}