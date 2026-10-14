/// <summary>
/// Subscribes to the confirm event of a change request. It records the token of every call and, at its first call, how many watched tickets
/// already stand on their target slot and how many watched lines already have a CONFIRMED change row, and it can
/// refuse a given call, so a test can see what the change completed before its first confirm event and what an
/// error in a later one leaves behind.
/// </summary>
codeunit 85513 "NPR TM Change Confirm Sub"
{
    EventSubscriberInstance = Manual;

    var
        _WatchedTicketNumbers: List of [Text];
        _WatchedAdmissionCodes: List of [Code[20]];
        _WatchedSlotNos: List of [Integer];
        _WatchedRowEntryNos: List of [Integer];
        _ThrowOnCall: Integer;
        _CallCount: Integer;
        _Tokens: List of [Text];
        _TicketsOnTargetAtFirstCall: Integer;
        _ConfirmedChangeRowsAtFirstCall: Integer;
        RefusalTxt: Label 'The test subscriber refuses the confirm event %1.', Locked = true;

    procedure ThrowOnCall(CallNo: Integer)
    begin
        _ThrowOnCall := CallNo;
    end;

    procedure WatchTicket(TicketNumber: Text; AdmissionCode: Code[20]; TargetSlotNo: Integer)
    begin
        _WatchedTicketNumbers.Add(TicketNumber);
        _WatchedAdmissionCodes.Add(AdmissionCode);
        _WatchedSlotNos.Add(TargetSlotNo);
    end;

    procedure WatchLineRow(EntryNo: Integer)
    begin
        _WatchedRowEntryNos.Add(EntryNo);
    end;

    procedure CallCount(): Integer
    begin
        exit(_CallCount);
    end;

    procedure TokenOfCall(CallNo: Integer): Text
    begin
        exit(_Tokens.Get(CallNo));
    end;

    procedure TicketsOnTargetAtFirstCall(): Integer
    begin
        exit(_TicketsOnTargetAtFirstCall);
    end;

    procedure ConfirmedChangeRowsAtFirstCall(): Integer
    begin
        exit(_ConfirmedChangeRowsAtFirstCall);
    end;

    procedure RefusalText(CallNo: Integer): Text
    begin
        exit(StrSubstNo(RefusalTxt, CallNo));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR TM Ticket Request Manager", 'OnAfterConfirmTicketChangeRequestPublisher', '', false, false)]
    local procedure OnAfterConfirmTicketChangeRequest(Token: Text[100])
    begin
        _CallCount += 1;
        _Tokens.Add(Token);
        if (_CallCount = 1) then
            RecordFirstCall();
        if (_CallCount = _ThrowOnCall) then
            Error(RefusalTxt, _CallCount);
    end;

    local procedure RecordFirstCall()
    var
        ChangeRow: Record "NPR TM Ticket Reservation Req.";
        LibraryTMReschedule: Codeunit "NPR Library - TM Reschedule";
        Index: Integer;
        EntryNo: Integer;
    begin
        for Index := 1 to _WatchedTicketNumbers.Count() do
            if (LibraryTMReschedule.CurrentSlotOfTicket(_WatchedTicketNumbers.Get(Index), _WatchedAdmissionCodes.Get(Index)) = _WatchedSlotNos.Get(Index)) then
                _TicketsOnTargetAtFirstCall += 1;

        ChangeRow.SetCurrentKey("Superseeds Entry No.");
        ChangeRow.SetFilter("Entry Type", '=%1', ChangeRow."Entry Type"::CHANGE);
        ChangeRow.SetFilter("Request Status", '=%1', ChangeRow."Request Status"::CONFIRMED);
        foreach EntryNo in _WatchedRowEntryNos do begin
            ChangeRow.SetFilter("Superseeds Entry No.", '=%1', EntryNo);
            _ConfirmedChangeRowsAtFirstCall += ChangeRow.Count();
        end;
    end;
}
