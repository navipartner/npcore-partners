#pragma warning disable AA0073
codeunit 6184696 "NPR TM ImportTicketWorker"
{
    Access = Internal;

    trigger OnRun()
    begin
        Import();
    end;

    var
        _TempTicketImport: Record "NPR TM ImportTicketHeader" temporary;
        _TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary;

    internal procedure SetImportBuffer(var TempTicketImport: Record "NPR TM ImportTicketHeader" temporary; var TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary)
    begin
        if (not TempTicketImport.IsTemporary) then
            Error('Record must be a temporary record. This is a programming bug and not a user error.');

        if (not TempTicketImportLine.IsTemporary) then
            Error('Record must be a temporary record. This is a programming bug and not a user error.');

        _TempTicketImport.Copy(TempTicketImport, true);
        _TempTicketImportLine.Copy(TempTicketImportLine, true);
    end;


    internal procedure Import();
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Token: Text[100];
        TokenLine: Integer;
        AuthorizationCode: Code[10];
        ResponseMessage: Text;
        RequestSuccess: Boolean;
    begin
        if (not TicketSetup.Get()) then
            TicketSetup.Init();

        if (TicketSetup."Authorization Code Scheme" = '') then
            TicketSetup."Authorization Code Scheme" := '[N*4]-[N*4]';

        _TempTicketImport.Reset();
        if (not _TempTicketImport.FindSet()) then
            Error('Import buffer is empty.');

        repeat
            _TempTicketImportLine.SetFilter(OrderId, '=%1', _TempTicketImport.OrderId);
            if (not _TempTicketImportLine.FindSet()) then
                Error('Order %1 has no lines.', _TempTicketImport.OrderId);

            Token := CreateDocumentId();
            TokenLine := 1;

            Archive(Token, _TempTicketImport);
            AuthorizationCode := CopyStr(TicketManagement.GenerateNumberPattern(TicketSetup."Authorization Code Scheme", '-'), 1, MaxStrLen(AuthorizationCode));
            repeat
                Archive(Token, TokenLine, _TempTicketImportLine);
                CreateTicketRequest(_TempTicketImportLine, AuthorizationCode);
                TokenLine += 1;
            until (_TempTicketImportLine.Next() = 0);

        until (_TempTicketImport.Next() = 0);

        _TempTicketImport.FindSet();
        repeat
            RequestSuccess := ConfirmTicketRequest(_TempTicketImport.TicketRequestToken, _TempTicketImport, ResponseMessage);
        until (_TempTicketImport.Next() = 0) or (not RequestSuccess);

        if (not RequestSuccess) then
            Error(ResponseMessage);

    end;

    internal procedure CleanUpFailedImport(JobId: Code[40])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketImport: Record "NPR TM ImportTicketHeader";
        TicketImportLine: Record "NPR TM ImportTicketLine";
    begin
        _TempTicketImport.Reset();
        if (not _TempTicketImport.FindSet()) then
            Error('Import buffer is empty.');

        repeat
            if (TicketImport.Get(_TempTicketImport.OrderId, JobId)) then begin
                TicketRequestManager.DeleteReservationRequest(TicketImport.TicketRequestToken, true);
                TicketImportLine.SetFilter(OrderId, '=%1', TicketImport.OrderId);
                TicketImportLine.SetFilter(JobId, '=%1', TicketImport.JobId);
                TicketImportLine.DeleteAll();
                TicketImport.Delete();
            end;
        until (_TempTicketImport.Next() = 0);
    end;


#pragma warning disable AA0139
    local procedure CreateDocumentId(): Text[50]
    begin
        exit('IMP' + UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;
#pragma warning restore

    [CommitBehavior(CommitBehavior::Error)]
    local procedure ConfirmTicketRequest(Token: Text[100]; TempTicketImport: Record "NPR TM ImportTicketHeader" temporary; var ErrorMessage: Text) Success: Boolean
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketRequestManager.SetReservationRequestExtraInfo(TempTicketImport.TicketRequestToken, TempTicketImport.TicketHolderEMail, TempTicketImport.PaymentReference, TempTicketImport.TicketHolderName);
        Success := TicketRequestManager.ConfirmReservationRequest(Token, ErrorMessage);
    end;

    local procedure CreateTicketRequest(TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary; AuthorizationCode: Code[10])
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResolvingTable: Integer;
        INVALID_ITEM_REFERENCE: Label 'Reference %1 does not resolve to neither an item reference nor an item number.';
    begin
        TicketRequest.Init();

        TicketRequest."Session Token ID" := TempTicketImportLine.TicketRequestToken;
        TicketRequest."Request Status" := TicketRequest."Request Status"::WIP;
        TicketRequest."Request Status Date Time" := CurrentDateTime;
        TicketRequest."Created Date Time" := CurrentDateTime();
        TicketRequest."Ext. Line Reference No." := TempTicketImportLine.TicketRequestTokenLine;
        TicketRequest."Primary Request Line" := true;
        TicketRequest."Authorization Code" := AuthorizationCode;

        TicketRequest."External Item Code" := TempTicketImportLine.ItemReferenceNumber;
        TicketRequest."External Order No." := TempTicketImportLine.OrderId;
        TicketRequest.PreAssignedTicketNumber := TempTicketImportLine.PreAssignedTicketNumber;
        TicketRequest.Quantity := 1;
        TicketRequest."External Member No." := TempTicketImportLine.MemberNumber;
        TicketRequest."Notification Address" := TempTicketImportLine.TicketHolderEMail;

        if (not TicketRequestManager.TranslateBarcodeToItemVariant(TicketRequest."External Item Code", TicketRequest."Item No.", TicketRequest."Variant Code", ResolvingTable)) then
            Error(INVALID_ITEM_REFERENCE, TicketRequest."External Item Code");

        TicketBOM.SetFilter("Item No.", '=%1', TicketRequest."Item No.");
        TicketBOM.SetFilter("Variant Code", '=%1', TicketRequest."Variant Code");
        TicketBOM.SetFilter(Default, '=%1', true);
        TicketBOM.FindFirst(); // Must fail when no admission is marked default.

        TicketRequest."Admission Code" := TicketBOM."Admission Code";
        Admission.Get(TicketBOM."Admission Code");

        TicketRequest.Default := TicketBOM.Default;
        TicketRequest."Admission Inclusion" := TicketBOM."Admission Inclusion";
        if (TicketBOM."Admission Inclusion" <> TicketBOM."Admission Inclusion"::REQUIRED) then
            TicketRequest."Admission Inclusion" := TicketBOM."Admission Inclusion"::SELECTED;

        if ((TicketRequest."Admission Inclusion" = TicketBOM."Admission Inclusion"::SELECTED) and (TicketRequest.Quantity = 0)) then
            TicketRequest."Admission Inclusion" := TicketBOM."Admission Inclusion"::NOT_SELECTED;

        TicketRequest."Admission Description" := Admission.Description;
        TicketRequest."External Adm. Sch. Entry No." := GetAdmissionTimeSlot(TicketRequest."Admission Code", Admission."Default Schedule", TempTicketImportLine.ExpectedVisitDate, TempTicketImportLine.ExpectedVisitTime);
        TicketRequest."Scheduled Time Description" := StrSubstNo('%1 - %2', TempTicketImportLine.ExpectedVisitDate, TempTicketImportLine.ExpectedVisitTime);
        TicketRequest.Insert();

        TicketRequestManager.IssueTicketFromReservation(TicketRequest);

    end;

    local procedure Archive(Token: Text[100]; TokenLine: Integer; var TempTicketImportLine: Record "NPR TM ImportTicketLine" temporary)
    var
        TicketImportLine: Record "NPR TM ImportTicketLine";
    begin
        TempTicketImportLine.TicketRequestToken := Token;
        TempTicketImportLine.TicketRequestTokenLine := TokenLine;
        TempTicketImportLine.Modify();

        TicketImportLine.TransferFields(TempTicketImportLine, true);
        TicketImportLine.Insert();
    end;

    local procedure Archive(Token: Text[100]; var TempTicketImport: Record "NPR TM ImportTicketHeader" temporary)
    var
        TicketImport: Record "NPR TM ImportTicketHeader";
    begin
        TempTicketImport.TicketRequestToken := Token;
        TempTicketImport.Modify();

        TicketImport.TransferFields(TempTicketImport, true);
        TicketImport.Insert();
    end;

    local procedure GetAdmissionTimeSlot(AdmissionCode: Code[20]; DefaultSchedule: Option; ExpectedVisitDate: Date; ExpectedVisitTime: Time): Integer
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        NoTimeSlot: Label 'Admission Code %1 has no available time slots for expected visit date %2.';
        TimeDifference, MinTimeDifference : Integer;
        EntryNo: Integer;
    begin
        ScheduleEntry.Reset();
        ScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
        ScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleEntry.SetFilter("Admission Start Date", '=%1', ExpectedVisitDate);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (ScheduleEntry.FindSet()) then begin
            repeat
                case true of
                    ExpectedVisitTime <= ScheduleEntry."Admission Start Time":
                        TimeDifference := ScheduleEntry."Admission Start Time" - ExpectedVisitTime;
                    ExpectedVisitTime <= ScheduleEntry."Admission End Time":
                        TimeDifference := 0;
                    else
                        TimeDifference := ExpectedVisitTime - ScheduleEntry."Admission Start Time";
                end;

                if ((EntryNo = 0) or (TimeDifference < MinTimeDifference)) then begin
                    EntryNo := ScheduleEntry."Entry No.";
                    MinTimeDifference := TimeDifference;
                end;

            until (ScheduleEntry.Next() = 0);
        end;

        if (EntryNo = 0) then
            if (DefaultSchedule in [Admission."Default Schedule"::TODAY, Admission."Default Schedule"::SCHEDULE_ENTRY]) then
                Error(NoTimeSlot, AdmissionCode, ExpectedVisitDate); // blow up if expected visit date does not have a valid time slot for that entire date

        ScheduleEntry.Get(EntryNo);
        exit(ScheduleEntry."External Schedule Entry No.");
    end;

}