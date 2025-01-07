codeunit 6151536 "NPR POS Action SS: MemberArr.B"
{
    Access = Internal;

    internal procedure SetMemberArrival(DefaultInputValue: Text; DialogMethodType: Option; POSWorkflowType: Option; MemberCardNumber: Text[100]; AdmissionCode: Code[20]; Setup: Codeunit "NPR POS Setup") MemberCardEntryNo: Integer
    begin
        if (DefaultInputValue <> '') then
            MemberCardNumber := CopyStr(DefaultInputValue, 1, MaxStrLen(MemberCardNumber));

        exit(MemberArrival(DialogMethodType, POSWorkflowType, MemberCardNumber, AdmissionCode, Setup));
    end;

    local procedure MemberArrival(InputMethod: Option; POSWorkflowType: Option; ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; POSSetup: Codeunit "NPR POS Setup") MemberCardEntryNo: Integer
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        ThisShouldBeEmpty_SaleLinePOS: Record "NPR POS Sale Line";
        ExternalTicketNo: Text[30];
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        POSActionMemberManagement: Codeunit "NPR POS Action Member MgtWF3-B";
        MembershipEvents: Codeunit "NPR MM Membership Events";
        LogEntryNo: Integer;
        ResponseCode: Integer;
        ResponseMessage: Text;
        Token: Text[100];
        POSWorkflowMethod: Option POS,Automatic,GuestCheckIn;
        MEMBER_REQUIRED: Label 'Member identification must be specified.';
        PosUnitNo: Code[10];
        CheckInOK: Boolean;
    begin

        if (ExternalMemberCardNo = '') then
            Error(MEMBER_REQUIRED);

        PosUnitNo := POSSetup.GetPOSUnitNo();

        case POSWorkflowType of
            POSWorkflowMethod::POS:
                MemberCardEntryNo := POSActionMemberManagement.POSMemberArrival(InputMethod, ExternalMemberCardNo, '');
            POSWorkflowMethod::Automatic,
            POSWorkflowMethod::GuestCheckIn:
                begin
                    MemberCard.Get(MembershipManagement.GetCardEntryNoFromExtCardNo(ExternalMemberCardNo));
                    MemberCardEntryNo := MemberCard."Entry No.";
                    Membership.Get(MemberCard."Membership Entry No.");
                    MembershipSetup.Get(Membership."Membership Code");

                    MembershipEvents.OnBeforePOSMemberArrival(ThisShouldBeEmpty_SaleLinePOS, MembershipSetup."Community Code", MembershipSetup.Code, MemberCard."Membership Entry No.", MemberCard."Member Entry No.", MemberCard."Entry No.", ExternalMemberCardNo);

                    LogEntryNo := MemberLimitationMgr.POS_CheckLimitMemberCardArrival(ExternalMemberCardNo, AdmissionCode, 'POS', LogEntryNo, ResponseMessage, ResponseCode);
                    Commit();

                    MemberRetailIntegration.POS_ValidateMemberCardNo(true, true, InputMethod, true, ExternalMemberCardNo);
                    MemberLimitationMgr.POS_CheckLimitMemberCardArrival(ExternalMemberCardNo, AdmissionCode, 'POS', LogEntryNo, ResponseMessage, ResponseCode);
                    Commit();

                    if (ResponseCode <> 0) then
                        Error(ResponseMessage);

                    if (POSWorkflowType = POSWorkflowMethod::Automatic) then
                        CheckInOK := MemberTicketManager.AttemptMemberFastCheckIn(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", AdmissionCode, PosUnitNo, 1, '', ExternalTicketNo, ResponseMessage, ResponseCode);

                    if (POSWorkflowType = POSWorkflowMethod::GuestCheckIn) then begin
                        MemberTicketManager.PromptForMemberGuestArrival(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", AdmissionCode, PosUnitNo, Token);
                        CheckInOK := MemberTicketManager.AttemptMemberFastCheckIn(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", AdmissionCode, PosUnitNo, 1, Token, ExternalTicketNo, ResponseMessage, ResponseCode);
                    end;

                    if (not CheckInOK) then
                        MemberLimitationMgr.UpdateLogEntry(LogEntryNo, ResponseCode, ResponseMessage);

                    if (CheckInOK) then
                        MemberLimitationMgr.UpdateLogEntry(LogEntryNo, 0, ExternalTicketNo);

                    Commit();

                    if (not CheckInOK) then
                        Error(ResponseMessage);

                end;
        end;
    end;

}