codeunit 6060109 "NPR TM OfflineTicketValidBL"
{
    Access = Internal;

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

    internal procedure ProcessImportBatch(ImportBatchNo: Integer)
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

    internal procedure ProcessEntry(EntryNo: Integer): Boolean
    var
        OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.";
        Ticket: Record "NPR TM Ticket";
        AccessEntry: Record "NPR TM Ticket Access Entry";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        InvalidEntry: Boolean;
        ScheduleEntryNo: Integer;
        ExternalEntryNo: Integer;
        AdmissionEntryNo: Integer;
        RespLbl: Label '%1 %2', Locked = true;
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

        if (OfflineTicketValidation."Admission Code" = '') then begin
            TicketAdmissionBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
            TicketAdmissionBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
            TicketAdmissionBOM.SetFilter(Default, '=%1', true);
            if (TicketAdmissionBOM.IsEmpty()) then begin
                TicketAdmissionBOM.SetFilter(Default, '=%1', false);
                if (TicketAdmissionBOM.Count() > 1) then begin
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

        repeat
            if (GetInitialEntry(Ticket."No.", AccessEntry."Admission Code", ExternalEntryNo)) then
                SetInitialTime(ExternalEntryNo, false, OfflineTicketValidation);

            if (GetReservation(Ticket."No.", AccessEntry."Admission Code", ExternalEntryNo)) then
                SetReservationTime(ExternalEntryNo, true, OfflineTicketValidation);

            if (OfflineTicketValidation."Event Date" = 0D) then begin
                OfflineTicketValidation."Event Date" := Today();
                OfflineTicketValidation."Process Response Text" := StrSubstNo(RespLbl, OfflineTicketValidation."Process Response Text", DEFAULT_DATE);
            end;

            if (OfflineTicketValidation."Event Time" = 0T) then begin
                OfflineTicketValidation."Event Time" := Time;
                OfflineTicketValidation."Process Response Text" := StrSubstNo(RespLbl, OfflineTicketValidation."Process Response Text", DEFAULT_TIME);
            end;

            ScheduleEntryNo := GetInternalScheduleEntryNo(AccessEntry."Admission Code", OfflineTicketValidation."Event Date", OfflineTicketValidation."Event Time");

            if (ScheduleEntryNo = 0) then begin
                OfflineTicketValidation."Process Status" := OfflineTicketValidation."Process Status"::INVALID;
                OfflineTicketValidation."Process Response Text" := StrSubstNo(NO_ADMISSION_FOR_TIME, OfflineTicketValidation."Event Date", OfflineTicketValidation."Event Time", AccessEntry."Admission Code");
            end else begin
                AdmissionEntryNo := RegisterArrival_Worker(AccessEntry."Entry No.", ScheduleEntryNo, OfflineTicketValidation."Event Date", OfflineTicketValidation."Event Time");
                TicketManagement.OnAfterRegisterArrival(Ticket, AccessEntry."Admission Code", AdmissionEntryNo);
            end;

        until (AccessEntry.Next() = 0);

        OfflineTicketValidation.Modify();
        exit(true);
    end;

    internal procedure AddRequestToOfflineValidation(var TicketReservationRequest: Record "NPR TM Ticket Reservation Req."): Integer
    var
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";

        Ticket: Record "NPR TM Ticket";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ImportBatchNo: Integer;
        EventStartDate: Date;
        EventStartTime: Time;
    begin
        // The link to ticket is only on the first request
        TicketReservationRequest.FindFirst();
        TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest2.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
        TicketReservationRequest2.FindFirst();

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Entry No.", '=%1', TicketReservationRequest2."Entry No.");
        TicketReservationRequest.FindFirst();

        ImportBatchNo := GetNextImportBatchNo();

        TicketReservationRequest2.SetFilter("Admission Created", '=%1', true);
        TicketReservationRequest2.FindSet();
        repeat
            // All tickets in the ticket request must relate to same schedules entry time request.
            // This will not account for different admission codes.
            EventStartDate := Today();
            EventStartTime := Time;

            if (TicketReservationRequest."External Adm. Sch. Entry No." <> 0) then begin
                AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest2."External Adm. Sch. Entry No.");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionScheduleEntry.FindLast()) then begin
                    EventStartDate := AdmissionScheduleEntry."Admission Start Date";
                    EventStartTime := AdmissionScheduleEntry."Admission Start Time";
                end;
            end;

            // The link to ticket is only on the first request
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (Ticket.FindSet()) then begin
                repeat
                    CreateAdmitRequest(
                        Ticket."External Ticket No.",
                        TicketReservationRequest2."Admission Code",
                        EventStartDate,
                        EventStartTime,
                        TicketReservationRequest2."Session Token ID",
                        ImportBatchNo);
                until (Ticket.Next() = 0);
            end;

        until (TicketReservationRequest2.Next() = 0);

        exit(ImportBatchNo);
    end;

    internal procedure AdmitTicketWithoutValidation(ExternalTicketNumber: Text[30]; AdmissionCode: Code[20]; ArrivalDate: Date; ArrivalTime: Time) ImportId: Integer
    begin
        ImportId := GetNextImportBatchNo();

        if (ArrivalDate = 0D) then
            ArrivalDate := Today();

        CreateAdmitRequest(ExternalTicketNumber, AdmissionCode, ArrivalDate, ArrivalTime, '', ImportId);
        ProcessImportBatch(ImportId);
    end;

    local procedure GetNextImportBatchNo(): Integer
    var
        TicketOfflineValidation: Record "NPR TM Offline Ticket Valid.";
    begin
        TicketOfflineValidation.SetCurrentKey("Import Reference No.");
        if (not TicketOfflineValidation.FindLast()) then
            exit(1);
        exit(TicketOfflineValidation."Import Reference No." + 1);
    end;

    local procedure CreateAdmitRequest(ExternalTicketNumber: Text[30]; AdmissionCode: Code[20]; ArrivalDate: Date; ArrivalTime: Time; ReferenceName: Text[100]; ReferenceNo: Integer);
    var
        TicketOfflineValidation: Record "NPR TM Offline Ticket Valid.";
    begin
        TicketOfflineValidation.Init();
        TicketOfflineValidation."Entry No." := 0;

        TicketOfflineValidation."Ticket Reference Type" := TicketOfflineValidation."Ticket Reference Type"::EXTERNALTICKETNO;
        TicketOfflineValidation."Ticket Reference No." := ExternalTicketNumber;
        TicketOfflineValidation."Admission Code" := AdmissionCode;
        TicketOfflineValidation."Event Type" := TicketOfflineValidation."Event Type"::ADMIT;
        TicketOfflineValidation."Event Date" := ArrivalDate;
        TicketOfflineValidation."Event Time" := ArrivalTime;
        TicketOfflineValidation."Imported At" := CurrentDateTime;
        TicketOfflineValidation."Import Reference Name" := ReferenceName;
        TicketOfflineValidation."Import Reference No." := ReferenceNo;

        TicketOfflineValidation.Insert();
    end;

    local procedure RegisterArrival_Worker(TicketAccessEntryNo: Integer; TicketAdmissionSchEntryNo: Integer; pDate: Date; pTime: Time): Integer
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        AdmittedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        StationIdLbl: Label 'Offline on %1';
        DeferRevenue: Codeunit "NPR TM RevenueDeferral";
    begin
        TicketAccessEntry.LockTable();
        TicketAccessEntry.Get(TicketAccessEntryNo);
        if (TicketAccessEntry."Access Date" = 0D) then begin
            TicketAccessEntry."Access Date" := pDate;
            TicketAccessEntry."Access Time" := pTime;
            TicketAccessEntry.Modify();

            DeferRevenue.ReadyToRecognize(TicketAccessEntryNo, pDate);
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
        AdmittedTicketAccessEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(AdmittedTicketAccessEntry."User ID"));
        AdmittedTicketAccessEntry."Scanner Station ID" := StrSubstNo(StationIdLbl, CurrentDateTime());
        AdmittedTicketAccessEntry.Insert();

        CloseReservationEntry(AdmittedTicketAccessEntry);
        exit(AdmittedTicketAccessEntry."Entry No.");
    end;

    local procedure CloseReservationEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"): Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        exit(CloseTicketAccessEntry(ClosedByAccessEntry, DetailedTicketAccessEntry.Type::RESERVATION));
    end;

    local procedure CloseTicketAccessEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"; ClosingEntryType: Option) Closed: Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
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
    end;

    internal procedure GetInternalScheduleEntryNo(AdmissionCode: Code[20]; ArrivalDate: Date; ArrivalTime: Time): Integer
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        AdmissionScheduleEntry.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ArrivalDate);
        AdmissionScheduleEntry.SetFilter("Admission End Time", '>=%1', ArrivalTime);

        if (not AdmissionScheduleEntry.FindFirst()) then begin
            AdmissionScheduleEntry.Reset();
            AdmissionScheduleEntry.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ArrivalDate);
            if (not AdmissionScheduleEntry.FindLast()) then begin
                AdmissionScheduleEntry.SetFilter("Admission Start Date", '>%1', ArrivalDate);
                if (not AdmissionScheduleEntry.FindFirst()) then
                    exit(0);
            end;
        end;

        exit(AdmissionScheduleEntry."Entry No.");
    end;



    local procedure GetReservation(TicketNo: Code[20]; AdmissionCode: Code[20]; var ExternalReservationEntryNo: Integer): Boolean
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
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
    end;

    local procedure SetReservationTime(ExternalAdmSchEntryNo: Integer; ForceUpdate: Boolean; var OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.")
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        RespLbl: Label '%1 %2', Locked = true;
    begin
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExternalAdmSchEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindLast()) then
            exit;

        if (OfflineTicketValidation."Event Date" = 0D) or (ForceUpdate) then begin
            OfflineTicketValidation."Event Date" := AdmissionScheduleEntry."Admission Start Date";
            OfflineTicketValidation."Process Response Text" := StrSubstNo(RespLbl, OfflineTicketValidation."Process Response Text", RESERVATION_DATE);
        end;

        if (OfflineTicketValidation."Event Time" = 0T) or (ForceUpdate) then begin
            OfflineTicketValidation."Event Time" := AdmissionScheduleEntry."Admission Start Time";
            OfflineTicketValidation."Process Response Text" := StrSubstNo(RespLbl, OfflineTicketValidation."Process Response Text", RESERVATION_TIME);
        end;
    end;

    local procedure GetInitialEntry(TicketNo: Code[20]; AdmissionCode: Code[20]; var ExternalAdmissionEntryNo: Integer): Boolean
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
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
    end;

    local procedure SetInitialTime(ExternalAdmSchEntryNo: Integer; ForceUpdate: Boolean; var OfflineTicketValidation: Record "NPR TM Offline Ticket Valid.")
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        RespLbl: Label '%1 %2', Locked = true;
    begin
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExternalAdmSchEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindLast()) then
            exit;

        if (OfflineTicketValidation."Event Date" = 0D) or (ForceUpdate) then begin
            OfflineTicketValidation."Event Date" := AdmissionScheduleEntry."Admission Start Date";
            OfflineTicketValidation."Process Response Text" := StrSubstNo(RespLbl, OfflineTicketValidation."Process Response Text", DEFAULT_DATE);
        end;

        if (OfflineTicketValidation."Event Time" = 0T) or (ForceUpdate) then begin
            OfflineTicketValidation."Event Time" := AdmissionScheduleEntry."Admission Start Time";
            OfflineTicketValidation."Process Response Text" := StrSubstNo(RespLbl, OfflineTicketValidation."Process Response Text", DEFAULT_TIME);
        end;
    end;

    internal procedure ImportOfflineValidationFile(ImportId: Integer)
    var

        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        FileName: Text;
        IMPORT_FILE: Label 'Import File';
        FILE_FILTER: Label 'Offline Ticket Validation Files (*.json)|*.json';
        JStream: InStream;
        JRootObject: JsonObject;
    begin

        /***
        Expected file format is:
        {
            "Admit":[{"ExternalTicketNumber":"","AdmissionCode":"","EventDate":"","EventTime":""}],
            "Depart":[{"ExternalTicketNumber":"","AdmissionCode":"","EventDate":"","EventTime":""}]
        }
        ***/
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, IMPORT_FILE, '', FILE_FILTER, 'json');
        if (FileName = '') then
            exit;

        TempBlob.CreateInStream(JStream);
        JRootObject.ReadFrom(JStream);
        CreateAdmitEvents(FileName, JRootObject, ImportId);
        CreateDepartEvents(FileName, JRootObject, ImportId);
    end;

    internal procedure CreateAdmitEvents(FileName: Text; JRootObject: JsonObject; var ImportId: Integer)
    var
        TicketOfflineValidation: Record "NPR TM Offline Ticket Valid.";
    begin
        if (ImportId = 0) then
            ImportId := GetNextImportBatchNo();
        CreateEvents(FileName, JRootObject, TicketOfflineValidation."Event Type"::ADMIT, 'Admit', ImportId);
    end;

    internal procedure CreateDepartEvents(FileName: Text; JRootObject: JsonObject; var ImportId: Integer)
    var
        TicketOfflineValidation: Record "NPR TM Offline Ticket Valid.";
    begin
        if (ImportId = 0) then
            ImportId := GetNextImportBatchNo();
        CreateEvents(FileName, JRootObject, TicketOfflineValidation."Event Type"::DEPART, 'Depart', ImportId);
    end;

    local procedure CreateEvents(FileName: Text; JRootObject: JsonObject; EventType: Option; KeyName: Text; ImportId: Integer)
    var
        JObject: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
    begin
        if (JRootObject.Get(KeyName, JToken)) then begin
            JArray := JToken.AsArray();
            foreach JToken in JArray do begin
                JObject := JToken.AsObject();
                CreateEventLine(FileName, JObject, EventType, ImportId);
            end;
        end;
    end;

    local procedure CreateEventLine(FileName: Text; var JObject: JsonObject; EventType: Option; ImportId: Integer)
    var
        TicketOfflineValidation: Record "NPR TM Offline Ticket Valid.";
    begin
        TicketOfflineValidation.Init();
        TicketOfflineValidation."Entry No." := 0;

        TicketOfflineValidation."Ticket Reference Type" := TicketOfflineValidation."Ticket Reference Type"::EXTERNALTICKETNO;
        TicketOfflineValidation."Ticket Reference No." := CopyStr(GetValue(JObject, 'ExternalTicketNumber').AsCode(), 1, MaxStrLen(TicketOfflineValidation."Ticket Reference No."));
        TicketOfflineValidation."Admission Code" := CopyStr(GetValue(JObject, 'AdmissionCode').AsCode(), 1, MaxStrLen(TicketOfflineValidation."Admission Code"));
        TicketOfflineValidation."Event Type" := EventType;
        TicketOfflineValidation."Event Date" := GetValue(JObject, 'EventDate').AsDate();
        TicketOfflineValidation."Event Time" := GetValue(JObject, 'EventTime').AsTime();
        TicketOfflineValidation."Imported At" := CurrentDateTime;
        TicketOfflineValidation."Import Reference Name" := CopyStr(FileName, 1, MaxStrLen(TicketOfflineValidation."Import Reference Name"));
        TicketOfflineValidation."Import Reference No." := ImportId;

        TicketOfflineValidation.Insert();
    end;

    local procedure GetValue(Json: JsonObject; TokenName: Text): JsonValue
    var
        Token: JsonToken;
    begin
        Json.Get(TokenName, Token);
        exit(Token.AsValue());
    end;

}


