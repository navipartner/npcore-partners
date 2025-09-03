codeunit 6150815 "NPR POS Action: MM Member ArrB"
{
    Access = Internal;

    internal procedure MemberArrival(DefaultInputValue: Text; DialogMethodType: Option; POSWorkflowType: Option; MemberCardNumber: Text[100]; AdmissionCode: Code[20]; Setup: Codeunit "NPR POS Setup"; ForeignCommunityCode: Code[20]) MemberCardEntryNo: Integer
    begin

        if (DefaultInputValue <> '') then
            MemberCardNumber := CopyStr(DefaultInputValue, 1, MaxStrLen(MemberCardNumber));

        exit(DoMemberArrival(DialogMethodType, POSWorkflowType, MemberCardNumber, AdmissionCode, Setup, ForeignCommunityCode));
    end;

    local procedure DoMemberArrival(InputMethod: Option; POSWorkflowType: Option; ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; POSSetup: Codeunit "NPR POS Setup"; ForeignCommunityCode: Code[20]) MemberCardEntryNo: Integer
    var
        MemberCardOut: Record "NPR MM Member Card";
        MembershipOut: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        ThisShouldBeEmpty_SaleLinePOS: Record "NPR POS Sale Line";
        ExternalTicketNo: Text[30];
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        POSActionMemberManagement: Codeunit "NPR POS Action Member MgtWF3-B";
        MembershipEvents: Codeunit "NPR MM Membership Events";
        LogEntryNo: Integer;
        ResponseCode: Integer;
        ResponseMessage: Text;
        Token: Text[100];
        POSWorkflowMethod: Option POS,Automatic,GuestCheckIn;
        PosUnitNo: Code[10];
        CheckInOK: Boolean;
    begin
        if (POSWorkflowType = POSWorkflowMethod::POS) then begin
            MemberCardEntryNo := POSActionMemberManagement.POSMemberArrival(InputMethod, ExternalMemberCardNo, ForeignCommunityCode);
            exit;
        end;

        // Guest and Automatic CheckIn
        PosUnitNo := POSSetup.GetPOSUnitNo();

        POSActionMemberManagement.GetMembershipFromCardNumberWithUI(InputMethod, ExternalMemberCardNo, MembershipOut, MemberCardOut, true, ForeignCommunityCode);

        MemberCardEntryNo := MemberCardOut."Entry No.";
        MembershipOut.Get(MemberCardOut."Membership Entry No.");
        MembershipSetup.Get(MembershipOut."Membership Code");

        MembershipEvents.OnBeforePOSMemberArrival(ThisShouldBeEmpty_SaleLinePOS, MembershipSetup."Community Code", MembershipSetup.Code, MemberCardOut."Membership Entry No.", MemberCardOut."Member Entry No.", MemberCardOut."Entry No.", ExternalMemberCardNo);

        LogEntryNo := MemberLimitationMgr.POS_CheckLimitMemberCardArrival(ExternalMemberCardNo, AdmissionCode, 'POS', LogEntryNo, ResponseMessage, ResponseCode);
        Commit();

        if (ResponseCode <> 0) then
            Error(ResponseMessage);


        if (POSWorkflowType = POSWorkflowMethod::Automatic) then
            CheckInOK := MemberTicketManager.AttemptMemberFastCheckIn(MemberCardOut."Membership Entry No.", MemberCardOut."Member Entry No.", AdmissionCode, PosUnitNo, 1, '', ExternalTicketNo, ResponseMessage, ResponseCode);

        if (POSWorkflowType = POSWorkflowMethod::GuestCheckIn) then begin
            MemberTicketManager.PromptForMemberGuestArrival(MemberCardOut."Membership Entry No.", MemberCardOut."Member Entry No.", AdmissionCode, PosUnitNo, Token);
            CheckInOK := MemberTicketManager.AttemptMemberFastCheckIn(MemberCardOut."Membership Entry No.", MemberCardOut."Member Entry No.", AdmissionCode, PosUnitNo, 1, Token, ExternalTicketNo, ResponseMessage, ResponseCode);
        end;

        if (not CheckInOK) then
            MemberLimitationMgr.UpdateLogEntry(LogEntryNo, ResponseCode, ResponseMessage);

        if (CheckInOK) then
            MemberLimitationMgr.UpdateLogEntry(LogEntryNo, 0, ExternalTicketNo);

        Commit();

        if (not CheckInOK) then
            Error(ResponseMessage);
    end;

    internal procedure AddToastMemberScannedData(MembershipEntryNo: Integer; MemberEntryNo: Integer; Context: Option ARRIVAL,LOYALTY; var Response: JsonObject)
    begin
        AddToastMemberScannedData(MembershipEntryNo, MemberEntryNo, 0, Context, Response);
    end;

    internal procedure AddToastMemberScannedData(MemberCardEntryNo: Integer; Context: Option ARRIVAL,LOYALTY; var Response: JsonObject)
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        if (not MemberCard.Get(MemberCardEntryNo)) then
            exit;

        AddToastMemberScannedData(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", MemberCard."Entry No.", Context, Response);
    end;


    local procedure AddToastMemberScannedData(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer; Context: Option ARRIVAL,LOYALTY; var Response: JsonObject)
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";

        MembershipSetup: Record "NPR MM Membership Setup";
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipEvents: Codeunit "NPR MM Membership Events";
        Valid: Boolean;
        ValidUntilDate: Date;
        MemberScanned: JsonObject;
    begin
        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        if (MembershipSetup."Confirm Member On Card Scan") then
            exit;

        if (not Member.Get(MemberEntryNo)) then
            exit;

        if (Context = Context::LOYALTY) then
            exit; // Exit for not - message content is not adopted for loyalty. (Valid arrival instead of redeemable points)

        Valid := MemberManagement.GetMembershipMaxValidUntilDate(MembershipEntryNo, ValidUntilDate);
        Valid := Valid and (ValidUntilDate >= Today());
        MemberScanned.Add('Valid', Valid);
        MemberScanned.Add('Name', Member."Display Name");
        MemberScanned.Add('ExpiryDate', ValidUntilDate);
        MemberScanned.Add('ImageDataUrl', GetMemberImageDataUrl(MemberEntryNo));
        MemberScanned.Add('MembershipCode', Membership."Membership Code");
        MemberScanned.Add('MembershipCodeCaption', Membership.FieldCaption("Membership Code"));
        MemberScanned.Add('MembershipCodeDescription', MembershipSetup."Description");

        if (MemberCardEntryNo > 0) then
            if (MemberCard.Get(MemberCardEntryNo)) then
                MemberScanned.Add('CardNumber', MemberCard."External Card No.")
            else
                MemberScanned.Add('CardNumber', '');

        MembershipEvents.OnAddMemberScannedToastData(MembershipEntryNo, MemberEntryNo, MemberScanned);
        Response.Add('MemberScanned', MemberScanned);
    end;


    local procedure GetMemberImageDataUrl(MemberEntryNo: Integer): Text
    var
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberImageBase64: Text;
        DataUrl: Label 'data:image/jpeg;base64,%1', locked = true;
    begin
        if (MemberManagement.GetMemberImage(MemberEntryNo, MemberImageBase64)) then
            exit(StrSubstNo(DataUrl, MemberImageBase64));

        exit(NoPictureAvailableImage());
    end;

    local procedure NoPictureAvailableImage(): Text
    var
        DataUrl: Label 'data:image/svg+xml,%1', locked = true;
        NoPictureAvailable: Label '<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-camera-off"><line x1="1" y1="1" x2="23" y2="23"></line><path d="M21 21H3a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2z"></path><path d="M12 17a5 5 0 0 0 0-10c-1.38 0-2.63.56-3.54 1.46"></path><path d="M8.12 8.12a5 5 0 0 0 7.76 7.76"></path></svg>', Locked = true;
    begin
        exit(StrSubstNo(DataUrl, NoPictureAvailable));
    end;

}