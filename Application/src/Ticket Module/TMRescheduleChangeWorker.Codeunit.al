codeunit 6151264 "NPR TM Resched. Change Worker"
{
    Access = Internal;

    var
#pragma warning disable AA0073
        _TempRequest: Record "NPR TM Reschedule Line Buffer" temporary;
        _TempResult: Record "NPR TM Reschedule Line Buffer" temporary;
#pragma warning restore AA0073
        _ReservationToken: Text[100];
        _PinCode: Text;
        _Outcome: Enum "NPR TM Resched. Change Outcome";
        _FailedRequestEntryNo: Integer;
        _Refusal: Enum "NPR TM Reschedule Refusal";
        _ChangeTokens: List of [Text[100]];
        _ChangeToken: Text[100];
        _ResponseBody: JsonObject;
        _PublishOnly: Boolean;

    trigger OnRun()
    var
        TicketReschedule: Codeunit "NPR TM Ticket Reschedule";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        RescheduleAgent: Codeunit "NPR TicketingRescheduleAgent";
    begin
        if (_PublishOnly) then begin
            TicketRequestManager.PublishChangeRequestConfirmed(_ChangeToken);
            exit;
        end;
        _Outcome := TicketReschedule.ChangeReservation(_ReservationToken, _PinCode, _TempRequest, _TempResult, _FailedRequestEntryNo, _Refusal, _ChangeTokens);
        // A successful Run commits the change, so the response is built before that, where an error still rolls the change back.
        if (_Outcome = _Outcome::CHANGED) then
            _ResponseBody := RescheduleAgent.BuildChangeResponse(_TempResult);
    end;

    internal procedure SetChangeRequest(ReservationToken: Text[100]; PinCode: Text; var TempRequest: Record "NPR TM Reschedule Line Buffer" temporary)
    begin
        _ReservationToken := ReservationToken;
        _PinCode := PinCode;
        _TempRequest.Copy(TempRequest, true);
        _TempResult.Reset();
        _TempResult.DeleteAll();
        _Outcome := _Outcome::NOT_FOUND;
        _FailedRequestEntryNo := 0;
        _Refusal := _Refusal::NONE;
        Clear(_ChangeTokens);
        Clear(_ResponseBody);
        _PublishOnly := false;
    end;

    internal procedure SetPublishRequest(ChangeToken: Text[100])
    begin
        _ChangeToken := ChangeToken;
        _PublishOnly := true;
    end;

    internal procedure GetChangeResult(var ResponseBody: JsonObject; var ChangeTokens: List of [Text[100]]; var FailedRequestEntryNo: Integer; var Refusal: Enum "NPR TM Reschedule Refusal"): Enum "NPR TM Resched. Change Outcome"
    begin
        ResponseBody := _ResponseBody;
        ChangeTokens := _ChangeTokens;
        FailedRequestEntryNo := _FailedRequestEntryNo;
        Refusal := _Refusal;
        exit(_Outcome);
    end;
}
