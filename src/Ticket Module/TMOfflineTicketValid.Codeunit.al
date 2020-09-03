codeunit 6060109 "NPR TM Offline Ticket Valid."
{
    // TM1.22/NPKNAV/20170612  CASE 278142 Transport T0007 - 12 June 2017
    // TM1.24/TSA /20170807 CASE 286185 Added handling default handling for emptpy fields
    // TM1.40/TSA /20190318 CASE 348952 Fixed an issue when selecting an incorrect time
    // TM1.40/TSA /20190318 CASE 348952 Fixed an issue when ticket has more than one admission object
    // TM90.1.46/TSA /20200127 CASE 376136 Close a possible reservation when registering offline admission


    trigger OnRun()
    begin
    end;

    var
        UnsupportedOption: Label 'The option %1 = %2 is not supported.';
        NotFound: Label '%1 for %2 was not found.';
        ADM_CODE_AMBIGIOUS: Label 'Offline entry does not specify an admission code, and ticket admission bom does not specify which is the default.';
        TICKET_BOM_NOT_FOUND: Label 'The Ticket Admisison BOM was not found for ticket %1.';
        DEFAULT_ADM: Label 'Default Admission Code selected.';
        DEFAULT_DATE: Label 'Default date selected.';
        DEFAULT_TIME: Label 'Default time selected.';
        NO_ADMISSION_FOR_TIME: Label '%1 %2 does not identify a valid schedule entry for %3.';
        RESERVATION_DATE: Label 'Reservation date selected.';
        RESERVATION_TIME: Label 'Reservation time selected.';

    procedure ProcessImportBatch(ImportBatchNo: Integer)
    var
        OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.";
    begin

        OfflineTicketValidation.SetCurrentKey("Import Reference No.");
        OfflineTicketValidation.SetFilter("Import Reference No.", '=%1', ImportBatchNo);

        if (OfflineTicketValidation.FindSet()) then begin
            repeat
                ProcessEntry(OfflineTicketValidation."Entry No.");
            until (OfflineTicketValidation.Next() = 0);
        end;
    end;

    procedure ProcessEntry(EntryNo: Integer): Boolean
    var
        OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.";
        Ticket: Record "NPR TM Ticket";
        AccessEntry: Record "NPR TM Ticket Access Entry";
        DetailedAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        InvalidEntry: Boolean;
        ScheduleEntryNo: Integer;
        ExternalEntryNo: Integer;
    begin

        if (not OfflineTicketValidation.Get(EntryNo)) then
            exit(false);

        if (OfflineTicketValidation."Process Status" = OfflineTicketValidation."Process Status"::VALID) then
            exit(false);

        InvalidEntry := true;

        OfflineTicketValidation."Process Status" := OfflineTicketValidation."Process Status"::VALID;
        OfflineTicketValidation."Process Response Text" := '';

        case OfflineTicketValidation."Ticket Reference Type" of
            OfflineTicketValidation."Ticket Reference Type"::EXTERNALTICKETNO:
                begin
                    Ticket.SetFilter("External Ticket No.", '=%1', OfflineTicketValidation."Ticket Reference No.");
                    InvalidEntry := (not Ticket.FindFirst());
                    if (InvalidEntry) then begin
                        OfflineTicketValidation."Process Response Text" := StrSubstNo(NotFound, Ticket.TableCaption, OfflineTicketValidation."Ticket Reference No.");
                    end;
                end;
            else
                Error(UnsupportedOption, OfflineTicketValidation.FieldCaption("Ticket Reference Type"), OfflineTicketValidation."Ticket Reference Type");
        end;

        if (InvalidEntry) then begin
            OfflineTicketValidation."Process Status" := OfflineTicketValidation."Process Status"::INVALID;
            OfflineTicketValidation.Modify();
            exit(true);
        end;

        //-TM1.24 [286185]
        if (OfflineTicketValidation."Admission Code" = '') then begin
            TicketAdmissionBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
            TicketAdmissionBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
            TicketAdmissionBOM.SetFilter(Default, '=%1', true);
            if (TicketAdmissionBOM.IsEmpty()) then begin
                TicketAdmissionBOM.SetFilter(Default, '=%1', false);
                if (TicketAdmissionBOM.Count > 1) then begin
                    OfflineTicketValidation."Process Status" := OfflineTicketValidation."Process Status"::INVALID;
                    OfflineTicketValidation."Process Response Text" := ADM_CODE_AMBIGIOUS;
                    OfflineTicketValidation.Modify();
                    exit(true);
                end;
            end;

            if (not TicketAdmissionBOM.FindFirst()) then begin
                OfflineTicketValidation."Process Status" := OfflineTicketValidation."Process Status"::INVALID;
                OfflineTicketValidation."Process Response Text" := StrSubstNo(TICKET_BOM_NOT_FOUND, Ticket."No.");
                OfflineTicketValidation.Modify();
                exit(true);
            end;

            OfflineTicketValidation."Admission Code" := TicketAdmissionBOM."Admission Code";
            OfflineTicketValidation."Process Response Text" := DEFAULT_ADM;
        end;

        AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (OfflineTicketValidation."Admission Code" <> '') then
            AccessEntry.SetFilter("Admission Code", '=%1', OfflineTicketValidation."Admission Code");

        if (OfflineTicketValidation."Admission Code" = '*') then
            AccessEntry.Reset();

        AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");

        InvalidEntry := (not AccessEntry.FindSet());
        if (InvalidEntry) then begin
            OfflineTicketValidation."Process Status" := OfflineTicketValidation."Process Status"::INVALID;
            OfflineTicketValidation."Process Response Text" := StrSubstNo(NotFound, AccessEntry.TableCaption, AccessEntry.GetFilters());
            OfflineTicketValidation.Modify();
            exit(true);
        end;


        //-TM90.1.46 [376136] - Get Reservation Time / restructured
        repeat

            if (GetInitialEntry(Ticket."No.", AccessEntry."Admission Code", ExternalEntryNo)) then
                SetInitialTime(ExternalEntryNo, false, OfflineTicketValidation);

            if (GetReservation(Ticket."No.", AccessEntry."Admission Code", ExternalEntryNo)) then
                SetReservationTime(ExternalEntryNo, true, OfflineTicketValidation);

            if (OfflineTicketValidation."Event Date" = 0D) then begin
                OfflineTicketValidation."Event Date" := Today;
                OfflineTicketValidation."Process Response Text" := StrSubstNo('%1 %2', OfflineTicketValidation."Process Response Text", DEFAULT_DATE);
            end;

            if (OfflineTicketValidation."Event Time" = 0T) then begin
                OfflineTicketValidation."Event Time" := Time;
                OfflineTicketValidation."Process Response Text" := StrSubstNo('%1 %2', OfflineTicketValidation."Process Response Text", DEFAULT_TIME);
            end;
            //+TM90.1.46 [376136]

            ScheduleEntryNo := GetInternalScheduleEntryNo(AccessEntry."Admission Code", OfflineTicketValidation."Event Date", OfflineTicketValidation."Event Time");

            if (ScheduleEntryNo = 0) then begin
                OfflineTicketValidation."Process Status" := OfflineTicketValidation."Process Status"::INVALID;
                OfflineTicketValidation."Process Response Text" := StrSubstNo(NO_ADMISSION_FOR_TIME, OfflineTicketValidation."Event Date", OfflineTicketValidation."Event Time", AccessEntry."Admission Code");
            end else begin
                RegisterArrival_Worker(AccessEntry."Entry No.", ScheduleEntryNo, OfflineTicketValidation."Event Date", OfflineTicketValidation."Event Time");
            end;

        until (AccessEntry.Next() = 0);

        OfflineTicketValidation.Modify();
        exit(true);
    end;

    procedure AddRequestToOfflineValidation(var TicketReservationRequest: Record "NPR TM Ticket Reservation Req."): Integer
    var
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        TicketOfflineValidation: Record "NPR TM Offline Ticket Valid.";
        Ticket: Record "NPR TM Ticket";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ImportBatchNo: Integer;
        EventStartDate: Date;
        EventStartTime: Time;
    begin

        // The link to ticket is only on the first request
        TicketReservationRequest.FindFirst();
        TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest2.FindFirst();

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Entry No.", '=%1', TicketReservationRequest2."Entry No.");
        TicketReservationRequest.FindFirst();


        TicketOfflineValidation.SetCurrentKey("Import Reference No.");
        if (TicketOfflineValidation.FindLast()) then;
        ImportBatchNo := TicketOfflineValidation."Import Reference No." + 1;

        //-TM1.40 [348952]
        TicketReservationRequest2.FindSet();
        repeat
            // All tickets in the ticket request must relate to same schedules entry time request.
            // This will not account for different admission codes.
            EventStartDate := Today;
            EventStartTime := Time;

            if (TicketReservationRequest."External Adm. Sch. Entry No." <> 0) then begin
                AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest2."External Adm. Sch. Entry No.");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionScheduleEntry.FindLast()) then begin
                    EventStartDate := AdmissionScheduleEntry."Admission Start Date";
                    EventStartTime := AdmissionScheduleEntry."Admission Start Time";
                end;
            end;
            //+TM1.40 [348952]

            // The link to ticket is only on the first request
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (Ticket.FindSet()) then begin

                repeat
                    TicketOfflineValidation.Init;
                    TicketOfflineValidation."Entry No." := 0;

                    TicketOfflineValidation."Ticket Reference Type" := TicketOfflineValidation."Ticket Reference Type"::EXTERNALTICKETNO;
                    TicketOfflineValidation."Ticket Reference No." := Ticket."External Ticket No.";
                    // TicketOfflineValidation."Member Reference Type" :=
                    // TicketOfflineValidation."Member Reference No."

                    //-TM1.40 [348952]
                    //TicketOfflineValidation."Admission Code" := '';
                    TicketOfflineValidation."Admission Code" := TicketReservationRequest2."Admission Code";
                    //+TM1.40 [348952]


                    TicketOfflineValidation."Event Type" := TicketOfflineValidation."Event Type"::ADMIT;

                    //-TM1.40 [348952]
                    // TicketOfflineValidation."Event Date" := TODAY;
                    // TicketOfflineValidation."Event Time" := TIME;
                    TicketOfflineValidation."Event Date" := EventStartDate;
                    TicketOfflineValidation."Event Time" := EventStartTime;
                    //+TM1.40 [348952]

                    TicketOfflineValidation."Imported At" := CurrentDateTime;
                    TicketOfflineValidation."Import Reference Name" := TicketReservationRequest."Session Token ID";
                    TicketOfflineValidation."Import Reference No." := ImportBatchNo;

                    TicketOfflineValidation.Insert();
                until (Ticket.Next() = 0);
            end;

        //-TM1.40 [348952]
        until (TicketReservationRequest2.Next() = 0);
        //+TM1.40 [348952]

        exit(ImportBatchNo);
    end;

    local procedure RegisterArrival_Worker(TicketAccessEntryNo: BigInteger; TicketAdmissionSchEntryNo: BigInteger; pDate: Date; pTime: Time)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        AdmittedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        TicketAccessEntry.LockTable();
        TicketAccessEntry.Get(TicketAccessEntryNo);
        if (TicketAccessEntry."Access Date" = 0D) then begin
            TicketAccessEntry."Access Date" := pDate;
            TicketAccessEntry."Access Time" := pTime;
            TicketAccessEntry.Modify();
        end;

        if (AdmissionScheduleEntry.Get(TicketAdmissionSchEntryNo)) then;

        AdmittedTicketAccessEntry.Init();
        AdmittedTicketAccessEntry."Ticket No." := TicketAccessEntry."Ticket No.";
        AdmittedTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";
        AdmittedTicketAccessEntry.Type := AdmittedTicketAccessEntry.Type::ADMITTED;
        AdmittedTicketAccessEntry."External Adm. Sch. Entry No." := AdmissionScheduleEntry."External Schedule Entry No.";
        AdmittedTicketAccessEntry.Quantity := TicketAccessEntry.Quantity;
        AdmittedTicketAccessEntry.Open := true;
        AdmittedTicketAccessEntry."Created Datetime" := CreateDateTime(pDate, pTime);
        AdmittedTicketAccessEntry."User ID" := UserId;
        AdmittedTicketAccessEntry."Scanner Station ID" := StrSubstNo('Offline on %1', CurrentDateTime);
        AdmittedTicketAccessEntry.Insert();

        //-TM90.1.46 [376136]
        CloseReservationEntry(AdmittedTicketAccessEntry);
        //+TM90.1.46 [376136]
    end;

    local procedure CloseReservationEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"): Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        //-TM90.1.46 [376136]
        exit(CloseTicketAccessEntry(ClosedByAccessEntry, DetailedTicketAccessEntry.Type::RESERVATION));
        //+TM90.1.46 [376136]
    end;

    local procedure CloseTicketAccessEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"; ClosingEntryType: Option) Closed: Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        //-TM90.1.46 [376136]
        DetailedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type, Open, "Posting Date");
        DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', ClosedByAccessEntry."Ticket Access Entry No.");
        DetailedTicketAccessEntry.SetFilter(Type, '=%1', ClosingEntryType);
        DetailedTicketAccessEntry.SetFilter(Open, '=%1', true);
        if (DetailedTicketAccessEntry.FindFirst()) then begin
            DetailedTicketAccessEntry."Closed By Entry No." := ClosedByAccessEntry."Entry No.";
            DetailedTicketAccessEntry.Open := false;
            DetailedTicketAccessEntry.Modify();
            Closed := true;
        end;

        if (ClosedByAccessEntry.Type = ClosedByAccessEntry.Type::DEPARTED) then
            ClosedByAccessEntry."External Adm. Sch. Entry No." := DetailedTicketAccessEntry."External Adm. Sch. Entry No.";

        if (ClosedByAccessEntry.Quantity < 0) then
            ClosedByAccessEntry."External Adm. Sch. Entry No." := DetailedTicketAccessEntry."External Adm. Sch. Entry No.";

        exit(Closed);
        //+TM90.1.46 [376136]
    end;

    procedure GetInternalScheduleEntryNo(AdmissionCode: Code[20]; ArrivalDate: Date; ArrivalTime: Time): Integer
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        AdmissionScheduleEntry.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ArrivalDate);
        AdmissionScheduleEntry.SetFilter("Admission End Time", '>=%1', ArrivalTime);

        //IF (AdmissionScheduleEntry.FINDLAST ()) THEN ;
        if (AdmissionScheduleEntry.FindFirst()) then;

        exit(AdmissionScheduleEntry."Entry No.");
    end;

    local procedure GetReservation(TicketNo: Code[20]; AdmissionCode: Code[20]; var ExternalReservationEntryNo: Integer): Boolean
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        //-TM90.1.46 [376136]
        if (AdmissionCode = '') then
            exit(false);

        if (AdmissionCode = '*') then
            exit(false);

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (not TicketAccessEntry.FindFirst()) then
            exit(false);

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
        if (not DetTicketAccessEntry.FindFirst()) then
            exit(false);

        ExternalReservationEntryNo := DetTicketAccessEntry."External Adm. Sch. Entry No.";
        exit(true);
        //+TM90.1.46 [376136]
    end;

    local procedure SetReservationTime(ExternalAdmSchEntryNo: Integer; ForceUpdate: Boolean; var OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.")
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        //-TM90.1.46 [376136]
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExternalAdmSchEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindLast()) then
            exit;

        if (OfflineTicketValidation."Event Date" = 0D) or (ForceUpdate) then begin
            OfflineTicketValidation."Event Date" := AdmissionScheduleEntry."Admission Start Date";
            OfflineTicketValidation."Process Response Text" := StrSubstNo('%1 %2', OfflineTicketValidation."Process Response Text", RESERVATION_DATE);
        end;

        if (OfflineTicketValidation."Event Time" = 0T) or (ForceUpdate) then begin
            OfflineTicketValidation."Event Time" := AdmissionScheduleEntry."Admission Start Time";
            OfflineTicketValidation."Process Response Text" := StrSubstNo('%1 %2', OfflineTicketValidation."Process Response Text", RESERVATION_TIME);
        end;

        //+TM90.1.46 [376136]
    end;

    local procedure GetInitialEntry(TicketNo: Code[20]; AdmissionCode: Code[20]; var ExternalAdmissionEntryNo: Integer): Boolean
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        //-TM90.1.46 [376136]
        if (AdmissionCode = '') then
            exit(false);

        if (AdmissionCode = '*') then
            exit(false);

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (not TicketAccessEntry.FindFirst()) then
            exit(false);

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
        if (not DetTicketAccessEntry.FindFirst()) then
            exit(false);

        ExternalAdmissionEntryNo := DetTicketAccessEntry."External Adm. Sch. Entry No.";
        exit(true);
        //+TM90.1.46 [376136]
    end;

    local procedure SetInitialTime(ExternalAdmSchEntryNo: Integer; ForceUpdate: Boolean; var OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.")
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        //-TM90.1.46 [376136]
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExternalAdmSchEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindLast()) then
            exit;

        if (OfflineTicketValidation."Event Date" = 0D) or (ForceUpdate) then begin
            OfflineTicketValidation."Event Date" := AdmissionScheduleEntry."Admission Start Date";
            OfflineTicketValidation."Process Response Text" := StrSubstNo('%1 %2', OfflineTicketValidation."Process Response Text", DEFAULT_DATE);
        end;

        if (OfflineTicketValidation."Event Time" = 0T) or (ForceUpdate) then begin
            OfflineTicketValidation."Event Time" := AdmissionScheduleEntry."Admission Start Time";
            OfflineTicketValidation."Process Response Text" := StrSubstNo('%1 %2', OfflineTicketValidation."Process Response Text", DEFAULT_TIME);
        end;

        //+TM90.1.46 [376136]
    end;
}

