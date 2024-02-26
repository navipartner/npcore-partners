codeunit 6150815 "NPR POS Action: MM Member ArrB"
{
    Access = Internal;

    procedure SetMemberArrival(ShowWelcomeMessage: Boolean; DefaultInputValue: Text; DialogMethodType: Option; POSWorkflowType: Option; MemberCardNumber: Text[100]; AdmissionCode: Code[20]; Setup: Codeunit "NPR POS Setup")
    begin

        if (DefaultInputValue <> '') then
            MemberCardNumber := CopyStr(DefaultInputValue, 1, MaxStrLen(MemberCardNumber));

        MemberArrival(DialogMethodType, POSWorkflowType, MemberCardNumber, AdmissionCode, ShowWelcomeMessage, Setup);
    end;

    local procedure MemberArrival(InputMethod: Option; POSWorkflowType: Option; ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; ShowWelcomeMessage: Boolean; POSSetup: Codeunit "NPR POS Setup")
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
        //ExternalItemNo: Code[50];
        LogEntryNo: Integer;
        ResponseCode: Integer;
        ResponseMessage: Text;
        Token: Text[100];
        DialogMethod: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT;
        POSWorkflowMethod: Option POS,Automatic,GuestCheckin;
        MEMBER_REQUIRED: Label 'Member identification must be specified.';
        PosUnitNo: Code[10];
    begin

        if (InputMethod = DialogMethod::NO_PROMPT) and (ExternalMemberCardNo = '') then
            if (not SelectMemberCardUI(ExternalMemberCardNo)) then
                Error(MEMBER_REQUIRED);

        PosUnitNo := POSSetup.GetPOSUnitNo();

        case POSWorkflowType of
            POSWorkflowMethod::POS:
                POSActionMemberManagement.POSMemberArrival(InputMethod, ExternalMemberCardNo);
            POSWorkflowMethod::Automatic,
            POSWorkflowMethod::GuestCheckin:
                begin
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

                    //ExternalItemNo := MemberRetailIntegration.POS_GetExternalTicketItemForMembership(MemberCard."Membership Entry No.");

                    if (POSWorkflowType = POSWorkflowMethod::Automatic) then
                        MemberTicketManager.MemberFastCheckIn(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", AdmissionCode, PosUnitNo, 1, '', ExternalTicketNo, ShowWelcomeMessage);

                    if (POSWorkflowType = POSWorkflowMethod::GuestCheckin) then begin
                        MemberTicketManager.PromptForMemberGuestArrival(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", AdmissionCode, PosUnitNo, Token);
                        MemberTicketManager.MemberFastCheckIn(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", AdmissionCode, PosUnitNo, 1, Token, ExternalTicketNo, ShowWelcomeMessage);
                    end;

                    MemberLimitationMgr.UpdateLogEntry(LogEntryNo, 0, ExternalTicketNo);
                    Commit();

                end;
        end;
    end;

    local procedure SelectMemberCardUI(var ExtMemberCardNo: Text[100]): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
    begin

        if (ACTION::LookupOK <> PAGE.RunModal(0, MemberCard)) then
            exit(false);

        ExtMemberCardNo := MemberCard."External Card No.";
        exit(ExtMemberCardNo <> '');
    end;

}