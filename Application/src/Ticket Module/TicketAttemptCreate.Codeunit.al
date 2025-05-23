﻿codeunit 6014491 "NPR Ticket Attempt Create"
{
    Access = Internal;
    SingleInstance = true;

    trigger OnRun()
    begin
        case _AttemptFunction of
            _AttemptFunction::REUSE:
                DoRevalidateRequestForTicketReuse(TempTicketReservationRequest, _ReusedTokenId);

            _AttemptFunction::VALIDATE_ARRIVAL:
                DoValidateTicketForArrival(_TicketIdentifierType, _TicketIdentifier, _AdmissionCode, _AdmissionScheduleEntryNo, _PosUnitNo, _ScannerStationId);

            _AttemptFunction::ISSUE_FROM_TOKEN:
                DoIssueTicketFromReservationToken(_Token);

            _AttemptFunction::ISSUE_FROM_RESERVATION:
                DoIssueTicketFromReservation(_TicketReservationRequest);

            _AttemptFunction::CHANGE_RESERVED_QTY:
                DoChangeConfirmedTicketQuantity(_TicketNo, _AdmissionCode, _NewTicketQuantity);

            else
                Error('No handler for %1.', _AttemptFunction);
        end;
    end;

    var
        _TicketAttemptCreate: Codeunit "NPR Ticket Attempt Create";
        TempTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
        _TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        _ReusedTokenId: Text[100];
        _TicketNo: Code[20];
        _TicketIdentifierType: Enum "NPR TM TicketIdentifierType";
        _TicketIdentifier: Text[50];
        _AdmissionCode: Code[20];
        _AdmissionScheduleEntryNo: Integer;
        _NewTicketQuantity: Integer;
        _Token: Text[100];
        _PosUnitNo: Code[10];
        _ScannerStationId: Code[10];

        _AttemptFunction: Option NA,REUSE,VALIDATE_ARRIVAL,ISSUE_FROM_TOKEN,ISSUE_FROM_RESERVATION,CHANGE_RESERVED_QTY;

    #region External Functions

    local procedure InvokeAttemptAction(var ResponseMessage: Text): Boolean
    var
        IsSuccess: Boolean;
    begin

        Commit();
        ClearLastError();

        IsSuccess := _TicketAttemptCreate.Run();
        if (not IsSuccess) then
            ResponseMessage := GetLastErrorText();

        if (_AttemptFunction = _AttemptFunction::REUSE) then
            _ReusedTokenId := _TicketAttemptCreate.GetReusedTokenId();

        Commit();
        exit(IsSuccess);
    end;

    procedure AttemptValidateRequestForTicketReuse(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary; var ReusedTokenId: Text[100]; var ResponseMessage: Text): Boolean
    var
        Successful: Boolean;
    begin

        TempTicketReservationRequest.Copy(TmpTicketReservationRequest, true);
        _AttemptFunction := _AttemptFunction::REUSE;

        Successful := InvokeAttemptAction(ResponseMessage);
        if (Successful) then
            ReusedTokenId := _ReusedTokenId;

        exit(Successful);
    end;

    procedure AttemptValidateTicketForArrival(TicketIdentifierType: Enum "NPR TM TicketIdentifierType"; TicketIdentifier: Text[50]; AdmissionCode: Code[20]; AdmissionScheduleEntryNo: Integer; PosUnitNo: Code[10]; ScannerStationId: Code[10]; var ResponseMessage: Text): Boolean
    begin

        _AttemptFunction := _AttemptFunction::VALIDATE_ARRIVAL;

        _TicketIdentifierType := TicketIdentifierType;
        _TicketIdentifier := TicketIdentifier;
        _AdmissionCode := AdmissionCode;
        _AdmissionScheduleEntryNo := AdmissionScheduleEntryNo;
        _PosUnitNo := PosUnitNo;
        _ScannerStationId := ScannerStationId;
        ResponseMessage := '';

        exit(InvokeAttemptAction(ResponseMessage));
    end;

    procedure AttemptIssueTicketFromReservationToken(Token: Text[100]; var ResponseMessage: Text): Boolean
    begin

        _AttemptFunction := _AttemptFunction::ISSUE_FROM_TOKEN;
        _Token := Token;

        exit(InvokeAttemptAction(ResponseMessage));
    end;

    procedure AttemptIssueTicketFromReservation(var TicketReservationRequest: Record "NPR TM Ticket Reservation Req."; var ResponseMessage: Text): Boolean
    begin

        _AttemptFunction := _AttemptFunction::ISSUE_FROM_RESERVATION;
        _TicketReservationRequest := TicketReservationRequest;

        exit(InvokeAttemptAction(ResponseMessage));
    end;

    procedure AttemptChangeConfirmedTicketQuantity(TicketNo: Code[20]; AdmissionCode: Code[20]; NewTicketQuantity: Integer; var ResponseMessage: Text): Boolean
    begin

        _AttemptFunction := _AttemptFunction::CHANGE_RESERVED_QTY;

        _TicketNo := TicketNo;
        _AdmissionCode := AdmissionCode;
        _NewTicketQuantity := NewTicketQuantity;

        exit(InvokeAttemptAction(ResponseMessage));
    end;
    #endregion

    #region Internal Worker Functions
    local procedure DoRevalidateRequestForTicketReuse(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary; var ReusedTokenId: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        IsRepeatedEntry: Boolean;
    begin

        // Pre-check if member has tickets for today with same item numbers and qty. If so try to reuse those tickets.
        IsRepeatedEntry := true;

        TmpTicketReservationRequest.Reset();
        TmpTicketReservationRequest.FindSet();

        repeat

            TicketReservationRequest.SetFilter("Item No.", '=%1', TmpTicketReservationRequest."Item No.");
            TicketReservationRequest.SetFilter("Variant Code", '=%1', TmpTicketReservationRequest."Variant Code");

            TicketReservationRequest.SetFilter("External Member No.", '=%1', TmpTicketReservationRequest."External Member No.");
            TicketReservationRequest.SetFilter("Created Date Time", '%1..%2', CreateDateTime(Today, 0T), CreateDateTime(Today, 235959T));
            TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);
            TicketReservationRequest.SetFilter(Quantity, '=%1', TmpTicketReservationRequest.Quantity);

            IsRepeatedEntry := (IsRepeatedEntry and (TmpTicketReservationRequest."External Member No." <> ''));
            IsRepeatedEntry := (IsRepeatedEntry and TicketReservationRequest.FindLast());
            if (IsRepeatedEntry) then
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");

        until (TmpTicketReservationRequest.Next() = 0);

        if (IsRepeatedEntry) then begin

            TicketReservationRequest.Reset();
            TicketReservationRequest.SetCurrentKey("Session Token ID");
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
            if (TicketReservationRequest.FindSet()) then begin

                repeat
                    Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                    if (Ticket.FindSet()) then begin
                        repeat
                            TicketManagement.RegisterArrivalScanTicket("NPR TM TicketIdentifierType"::INTERNAL_TICKET_NO, Ticket."No.", '', 0, '', '', false);
                        until (Ticket.Next() = 0);
                    end;
                until (TicketReservationRequest.Next() = 0);

                ReusedTokenId := TicketReservationRequest."Session Token ID";
                exit; // Arrival was successfully registered on tickets previously created - we are done

            end;
        end;

        Error('Member does not have a previous ticket request that matches the current request. Ticket reuse is not possible.');

    end;

    local procedure DoValidateTicketForArrival(TicketIdentifierType: Enum "NPR TM TicketIdentifierType"; TicketIdentifier: Text[50]; AdmissionCode: Code[20]; AdmissionScheduleEntryNo: Integer; PosUnitNo: Code[10]; ScannerStationId: Code[10])
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        TicketManagement.RegisterArrivalScanTicket(TicketIdentifierType, TicketIdentifier, AdmissionCode, AdmissionScheduleEntryNo, PosUnitNo, ScannerStationId, false);
    end;

    local procedure DoIssueTicketFromReservationToken(Token: Text[100])
    var
        TicketRequest: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketRequest.DoIssueTicketFromReservationToken(Token);
    end;

    local procedure DoIssueTicketFromReservation(TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        TicketRequest: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketRequest.IssueTicketFromReservation(TicketReservationRequest);
    end;

    local procedure DoChangeConfirmedTicketQuantity(TicketNo: Code[20]; AdmissionCode: Code[20]; NewTicketQuantity: Integer)
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        TicketManagement.ChangeConfirmedTicketQuantity(TicketNo, AdmissionCode, NewTicketQuantity);
    end;

    #endregion

    internal procedure GetReusedTokenId(): Text[100]
    begin
        exit(_ReusedTokenId);
    end;
}
