codeunit 6150799 "NPR HL Member Webhook Handler"
{
    Access = Internal;
    TableNo = "NPR HL Webhook Request";

    var
        HLIntegrationEvents: Codeunit "NPR HL Integration Events";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        HLMemberMgt: Codeunit "NPR HL Member Mgt. Impl.";

    trigger OnRun()
    begin
        ProcessMemberWebhookRequest(Rec);
    end;

    procedure UnsubscribeMember(HeyLoyaltyId: Text)
    begin
        if HeyLoyaltyId = '' then
            exit;
        HLMemberMgt.CheckHeyLoyaltyIdMaxLength(HeyLoyaltyId);
        ProcessMemberUpdate(CopyStr(HeyLoyaltyId, 1, 50), true, false);
    end;

    procedure UpsertMember(HeyLoyaltyId: Text)
    begin
        if HeyLoyaltyId = '' then
            exit;
        HLMemberMgt.CheckHeyLoyaltyIdMaxLength(HeyLoyaltyId);
        ProcessMemberUpdate(CopyStr(HeyLoyaltyId, 1, 50), false, false);
    end;

    local procedure ProcessMemberWebhookRequest(var HLWebhookRequest: Record "NPR HL Webhook Request")
    var
        HLMemberJToken: JsonToken;
        Unsubscribe: Boolean;
        IntegrNotEnabledErr: Label 'HeyLoyalty Member integration is not enabled.';
#IF BC17
        InStr: InStream;
#ENDIF
    begin
        if not HLIntegrationMgt.IsEnabled("NPR HL Integration Area"::Members) then
            Error(IntegrNotEnabledErr);

        HLWebhookRequest.LockTable(true);
        HLWebhookRequest.Find();
        if HLWebhookRequest."Processing Status" in
            [HLWebhookRequest."Processing Status"::" ", HLWebhookRequest."Processing Status"::"In-Process", HLWebhookRequest."Processing Status"::Processed]
        then
            exit;
        HLWebhookRequest.SetStatusInProcess();  //has a commmit

        HLWebhookRequest.TestField("HL Member ID");
        Unsubscribe := HLWebhookRequest."HL Request Type" = 'unsubscribe';
        if not (HLIntegrationMgt.ReadWebhookPayloadEnabled() and HLWebhookRequest."HL Request Data".HasValue()) then
            ProcessMemberUpdate(HLWebhookRequest."HL Member ID", Unsubscribe, true)
        else begin
#IF BC17
            HLWebhookRequest.GetHLRequestDataStream(InStr);
            HLMemberJToken.ReadFrom(InStr);
#ELSE
            HLMemberJToken.ReadFrom(HLWebhookRequest.GetHLRequestDataStream());
#ENDIF
            ProcessMemberUpdate(HLWebhookRequest."HL Member ID", HLMemberJToken, Unsubscribe, true);
        end;
        HLWebhookRequest.SetStatusFinished();  //has a commit
    end;

    local procedure ProcessMemberUpdate(HeyLoyaltyId: Text[50]; Unsubscribe: Boolean; ErrorOnMissingData: Boolean)
    var
        HLMemberJToken: JsonToken;
    begin
        HLIntegrationMgt.InvokeGetHLMemberByID(HeyLoyaltyId, HLMemberJToken);
        ProcessMemberUpdate(HeyLoyaltyId, HLMemberJToken, Unsubscribe, ErrorOnMissingData);
    end;

    local procedure ProcessMemberUpdate(HeyLoyaltyId: Text[50]; HLMemberJToken: JsonToken; Unsubscribe: Boolean; ErrorOnMissingData: Boolean)
    var
        HLMember: Record "NPR HL HeyLoyalty Member";
    begin
        if not GetHLMemberByHeyLoyaltyID(HeyLoyaltyId, HLMember) then begin
            HLMember."E-Mail Address" := HLMemberMgt.GetEmailFromResponse(HLMemberJToken, ErrorOnMissingData and not Unsubscribe, '');
            if HLMember."E-Mail Address" = '' then
                exit;
            if not GetHLMemberByContactInfo(HLMember) then begin
                if Unsubscribe then
                    exit;
                HLMember.Init();
                HLMember."Entry No." := 0;
                HLMember."HeyLoyalty Id" := HeyLoyaltyId;
                HLMember."Created from HeyLoyalty" := true;
                HLMember.Insert(true);
            end else
                if (HLMember."HeyLoyalty Id" <> HeyLoyaltyId) and (HLMember."HeyLoyalty Id" <> '') then begin
                    if Unsubscribe then
                        exit;
                    if HLMemberMgt.GetUnsubscribedAtFromResponse(HLMemberJToken, 0DT) <> 0DT then
                        exit;
                end;
        end;

        if Unsubscribe then begin
            if HLMember."Unsubscribed at" = 0DT then
                HLMember."Unsubscribed at" := CurrentDateTime();
        end else
            HLMember."Unsubscribed at" := 0DT;
        HLMemberMgt.UpdateHLMemberWithDataFromHeyLoyalty(HLMember, HLMemberJToken, Unsubscribe);
        if Unsubscribe then
            HLIntegrationEvents.OnUnsubscribeMember(HLMember, HLMemberJToken);
    end;

    procedure GetHLMemberByHeyLoyaltyID(HeyLoyaltyId: Text[50]; var HLMember: Record "NPR HL HeyLoyalty Member"): Boolean
    begin
        Clear(HLMember);
        HLMember.SetCurrentKey("HeyLoyalty Id");
        HLMember.SetRange("HeyLoyalty Id", HeyLoyaltyId);
        exit(HLMember.FindLast());
    end;

    procedure GetHLMemberByContactInfo(var HLMember: Record "NPR HL HeyLoyalty Member"): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
        HLMember2: Record "NPR HL HeyLoyalty Member";
        Member: Record "NPR MM Member";
        MemberMgt: Codeunit "NPR HL Member Mgt. Impl.";
    begin
        case HLIntegrationMgt.RequiredContactInfo() of
            "NPR HL Required Contact Method"::Email:
                if HLMember."E-Mail Address" = '' then
                    exit(false);
            "NPR HL Required Contact Method"::Phone:
                if HLMember."Phone No." = '' then
                    exit(false);
            else
                if (HLMember."E-Mail Address" = '') and (HLMember."Phone No." = '') then
                    exit(false);
        end;

        HLMember2 := HLMember;
        Clear(HLMember);
        if HLMember2."E-Mail Address" <> '' then begin
            HLMember.SetRange("E-Mail Address", HLMember2."E-Mail Address");
            if HLMember.IsEmpty() then
                HLMember.SetFilter("E-Mail Address", '@' + ConvertStr(HLMember2."E-Mail Address", '@', '?'));
        end;
        if HLMember2."Phone No." <> '' then begin
            HLMember.SetRange("Phone No.", HLMember2."Phone No.");
            if HLMember.IsEmpty() then
                if HLMember2."E-Mail Address" <> '' then begin
                    HLMember.SetRange("Phone No.");
                    if HLMember.IsEmpty() then begin
                        HLMember.SetRange("E-Mail Address", '');
                        HLMember.SetRange("Phone No.", HLMember2."Phone No.");
                    end;
                end;
        end;
        if HLMember.FindLast() then
            exit(true);

        if not GetMemberByContactInfo(HLMember2."E-Mail Address", HLMember2."Phone No.", Member) then
            exit(false);
        MemberMgt.FindMembershipRole(Member, MembershipRole);

        HLMember.Reset();
        if not HLMemberMgt.GetHLMember(Member, MembershipRole, HLMember, "NPR HL Auto Create HL Member"::Never) then
            HLMemberMgt.UpdateHLMember(Member, MembershipRole, HLMember);
        exit(true);
    end;

    procedure GetMemberByContactInfo(EmailAddress: Text[80]; PhoneNo: Text[30]; var Member: Record "NPR MM Member"): Boolean
    begin
        Clear(Member);
        if (EmailAddress = '') and (PhoneNo = '') then
            exit(false);

        if EmailAddress <> '' then begin
            Member.SetRange("E-Mail Address", EmailAddress);
            if Member.IsEmpty() then
                Member.SetFilter("E-Mail Address", '@' + ConvertStr(EmailAddress, '@', '?'));
        end;

        if PhoneNo <> '' then begin
            Member.SetRange("Phone No.", PhoneNo);
            if Member.IsEmpty() then begin
                if EmailAddress = '' then
                    exit(false);
                Member.SetRange("Phone No.");
                if Member.IsEmpty() then begin
                    Member.SetRange("E-Mail Address", '');
                    Member.SetRange("Phone No.", PhoneNo);
                end;
            end;
        end;
        exit(Member.FindLast());
    end;
}