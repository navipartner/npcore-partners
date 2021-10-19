codeunit 6014625 "NPR TM Retention Ticket Data"
{
    var
        _Window: Dialog;

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

    internal procedure GetCutoffDate(): Date
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        CutoffDate: Date;
        InvalidDateFormulaCalculation: Label 'The calculated cutoff date %1 for deleting retired tickets is not valid, it must be in the past.';
    begin
        TicketSetup.Get();
        if (Format(TicketSetup."Retire Used Tickets After") = '') then
            if (Evaluate(TicketSetup."Retire Used Tickets After", '<2Y>', 9)) then
                TicketSetup.Modify();

        TicketSetup.TestField("Retire Used Tickets After");

        CutoffDate := Today() - Abs((Today() - CalcDate(TicketSetup."Retire Used Tickets After", Today())));
        if (CutoffDate >= Today()) then
            Error(InvalidDateFormulaCalculation, CutoffDate);

        exit(CutoffDate);
    end;

    procedure Main()
    var
        BatchSize: Integer;
        WindowText: Label '#1############################ #2#######';
    begin
        if (GuiAllowed) then
            _Window.Open(WindowText);

        BatchSize := 1000;
        DeleteTickets(BatchSize);
        DeleteAdmissionSchedules(BatchSize);

        if (GuiAllowed) then
            _Window.Close();
    end;

    internal procedure DeleteTickets(BatchSize: Integer)
    var
        TempTicketsToDelete: Record "NPR TM Ticket" temporary;
        ResumeFromEntry: Integer;
        DeleteTicketLbl: Label 'Deleting...', MaxLength = 30;
    begin

        ResumeFromEntry := 0;
        while (true) do begin

            ResumeFromEntry := SelectTicketsToDelete(BatchSize, ResumeFromEntry, TempTicketsToDelete);

            TempTicketsToDelete.Reset();
            if (TempTicketsToDelete.IsEmpty()) then
                exit;

            if (GuiAllowed()) then
                _Window.Update(1, DeleteTicketLbl);

            TempTicketsToDelete.FindSet();
            repeat
                DeleteOneTicket(TempTicketsToDelete."No.");
            until (TempTicketsToDelete.Next() = 0);
            Commit();

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

            until (AdmissionScheduleEntry.Next() = 0) or (DeleteCount >= BatchSize);
            Commit();
        end;
    end;

    local procedure SelectTicketsToDelete(BatchSize: Integer; EntryNo: Integer; var TempTicketsToDelete: Record "NPR TM Ticket" temporary): Integer
    var
        TicketCutOffDate: Date;
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        CouldBeDeleted: Boolean;
        CurrentCount: Integer;
        SelectTicketLbl: Label 'Selecting Tickets (%1)', MaxLength = 25;
    begin
        TempTicketsToDelete.Reset();
        TempTicketsToDelete.DeleteAll();

        TicketCutOffDate := GetCutoffDate();
        Ticket.SetLoadFields("Valid To Date");

        while (TempTicketsToDelete.Count() = 0) do begin

            TicketAccessEntry.SetFilter("Entry No.", '>%1', EntryNo);
            TicketAccessEntry.SetLoadFields("Ticket No.", "Access Date");
            if (not TicketAccessEntry.FindSet()) then
                exit(EntryNo);

            if (GuiAllowed()) then
                _Window.Update(1, StrSubstNo(SelectTicketLbl, Round(TicketAccessEntry.Count() / BatchSize, 1, '>')));

            CouldBeDeleted := false;
            CurrentCount := 0;
            repeat
                if (TicketAccessEntry."Ticket No." <> Ticket."No.") then begin
                    if (CouldBeDeleted) then begin
                        TempTicketsToDelete.TransferFields(Ticket, true);
                        TempTicketsToDelete.Insert();
                    end;

                    CurrentCount += 1;
                    if (GuiAllowed()) then
                        if (CurrentCount mod 10 = 0) then
                            _Window.Update(2, BatchSize - CurrentCount);

                    Ticket.Get(TicketAccessEntry."Ticket No.");
                    CouldBeDeleted := (Ticket."Valid To Date" <= TicketCutOffDate);
                end;
                CouldBeDeleted := CouldBeDeleted and (TicketAccessEntry."Access Date" <> 0D);
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

        TicketRequest.Get(TicketRequestEntryNo);

        if (TicketRequest.Quantity > 1) then begin
            TicketRequest.Quantity -= 1;
            TicketRequest.Modify();
            exit;
        end;

        if (TicketRequest."Superseeds Entry No." <> 0) then
            DeleteTicketRequest(TicketRequest."Superseeds Entry No.");

        TicketResponse.SetFilter("Request Entry No.", '=%1', TicketRequest."Entry No.");
        TicketResponse.DeleteAll();

        TicketRequest.Reset();
        TicketRequest.SetFilter("Session Token ID", '=%1', TicketRequest."Session Token ID");
        TicketRequest.DeleteAll();
    end;

}