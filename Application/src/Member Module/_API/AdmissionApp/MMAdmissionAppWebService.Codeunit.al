codeunit 6184894 "NPR MMAdmissionAppWebService"
{
    procedure RegisterArrival(BarCode: Code[100]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var MessageText: Text) Success: Boolean
    var
        AttemptTicket: Codeunit "NPR Ticket Attempt Create";
        MemberCard: Record "NPR MM Member Card";
        Ticket: Record "NPR TM Ticket";
    begin

        if (BarCode = '') then begin
            MessageText := 'Barcode is required';
            exit(false);
        end;

        MemberCard.SetCurrentKey("External Card No.");
        MemberCard.SetFilter("External Card No.", '=%1', CopyStr(BarCode, 1, MaxStrLen(MemberCard."External Card No.")));
        if (not MemberCard.IsEmpty()) then
            exit(ValidateMemberAndRegisterArrival(BarCode, AdmissionCode, ScannerStationId, MessageText) = 0);

        Ticket.SetCurrentKey("External Ticket No.");
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(BarCode, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (not Ticket.IsEmpty()) then
            exit(AttemptTicket.AttemptValidateTicketForArrival("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, CopyStr(BarCode, 1, MaxStrLen(Ticket."External Ticket No.")), AdmissionCode, -1, '', ScannerStationId, MessageText));

        MessageText := 'Invalid barcode';
        exit(false);

    end;

    local procedure ValidateMemberAndRegisterArrival(ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ResponseMessage: Text) ResponseCode: Integer
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        AttemptArrival: Codeunit "NPR MM Attempt Member Arrival";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MembershipMgr: Codeunit "NPR MM MembershipMgtInternal";
        LimitLogEntry: Integer;
        MembershipEntryNo: Integer;
        MembershipNotActiveLbl: Label 'Membership is not active for today (%1).';
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today(), ResponseMessage);
        if (MembershipEntryNo = 0) then
            exit(-1);

        if (not Membership.Get(MembershipEntryNo)) then
            exit(-1);

        if (not MembershipMgr.IsMembershipActive(MembershipEntryNo, WorkDate(), true)) then begin
            ResponseMessage := StrSubstNo(MembershipNotActiveLbl, Format(WorkDate(), 0, 9));
            MemberLimitationMgr.LogMemberCardArrival(ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, -1);
            exit(-1);
        end;

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit(-1);

        if (not Member.Get(MembershipMgr.GetMemberFromExtCardNo(ExternalMemberCardNo, Today(), ResponseMessage))) then
            exit(-1);

        ResponseCode := 0;
        ResponseMessage := '';

        LimitLogEntry := 0;
        MemberLimitationMgr.WS_CheckLimitMemberCardArrival(ExternalMemberCardNo, AdmissionCode, ScannerStationId, LimitLogEntry, ResponseMessage, ResponseCode);
        if (ResponseCode <> 0) then
            exit(ResponseCode);

        Commit();

        AttemptArrival.AttemptMemberArrival(MembershipSetup."Ticket Item Barcode", AdmissionCode, '', ScannerStationId, Member, MembershipEntryNo);
        if (AttemptArrival.Run()) then;
        ResponseCode := AttemptArrival.GetAttemptMemberArrivalResponse(ResponseMessage);

        MemberLimitationMgr.UpdateLogEntry(LimitLogEntry, ResponseCode, ResponseMessage);

        Commit();
        exit(ResponseCode);

    end;

}