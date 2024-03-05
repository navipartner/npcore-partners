codeunit 6150815 "NPR POS Action: MM Member ArrB"
{
    Access = Internal;

    procedure MemberArrival(ShowWelcomeMessage: Boolean; DefaultInputValue: Text; DialogMethodType: Option; POSWorkflowType: Option; MemberCardNumber: Text[100]; AdmissionCode: Code[20]; Setup: Codeunit "NPR POS Setup"; ForeignCommunityCode: Code[20])
    begin

        if (DefaultInputValue <> '') then
            MemberCardNumber := CopyStr(DefaultInputValue, 1, MaxStrLen(MemberCardNumber));

        DoMemberArrival(DialogMethodType, POSWorkflowType, MemberCardNumber, AdmissionCode, ShowWelcomeMessage, Setup, ForeignCommunityCode);
    end;

    local procedure DoMemberArrival(InputMethod: Option; POSWorkflowType: Option; ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; ShowWelcomeMessage: Boolean; POSSetup: Codeunit "NPR POS Setup"; ForeignCommunityCode: Code[20])
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
        PosUnitNo: Code[10];
    begin

        if (POSWorkflowType = POSWorkflowMethod::POS) then begin
            POSActionMemberManagement.POSMemberArrival(InputMethod, ExternalMemberCardNo, ForeignCommunityCode);
            exit;
        end;


        // Guest and Automatic CheckIn
        PosUnitNo := POSSetup.GetPOSUnitNo();
        POSActionMemberManagement.GetMembershipFromCardNumberWithUI(InputMethod, ExternalMemberCardNo, Membership, MemberCard, true, ForeignCommunityCode);

        LogEntryNo := MemberLimitationMgr.POS_CheckLimitMemberCardArrival(ExternalMemberCardNo, AdmissionCode, 'POS', LogEntryNo, ResponseMessage, ResponseCode);
        Commit();

        MemberRetailIntegration.POS_ValidateMemberCardNo(true, true, InputMethod, true, ExternalMemberCardNo);
        MemberLimitationMgr.POS_CheckLimitMemberCardArrival(ExternalMemberCardNo, AdmissionCode, 'POS', LogEntryNo, ResponseMessage, ResponseCode);
        Commit();

        if (ResponseCode <> 0) then
            Error(ResponseMessage);

        MemberCard.Get(MembershipManagement.GetCardEntryNoFromExtCardNo(ExternalMemberCardNo));
        Membership.Get(MemberCard."Membership Entry No.");
        MembershipSetup.Get(Membership."Membership Code");

        MembershipEvents.OnBeforePOSMemberArrival(ThisShouldBeEmpty_SaleLinePOS, MembershipSetup."Community Code", MembershipSetup.Code, MemberCard."Membership Entry No.", MemberCard."Member Entry No.", MemberCard."Entry No.", ExternalMemberCardNo);

        if (POSWorkflowType = POSWorkflowMethod::Automatic) then
            MemberTicketManager.MemberFastCheckIn(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", AdmissionCode, PosUnitNo, 1, '', ExternalTicketNo, ShowWelcomeMessage);

        if (POSWorkflowType = POSWorkflowMethod::GuestCheckIn) then begin
            MemberTicketManager.PromptForMemberGuestArrival(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", AdmissionCode, PosUnitNo, Token);
            MemberTicketManager.MemberFastCheckIn(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", AdmissionCode, PosUnitNo, 1, Token, ExternalTicketNo, ShowWelcomeMessage);
        end;

        MemberLimitationMgr.UpdateLogEntry(LogEntryNo, 0, ExternalTicketNo);
        Commit();

    end;
}