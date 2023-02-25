codeunit 6150799 "NPR HL HeyLoyalty WS Mgt."
{
    Access = Internal;

    var
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        HLMemberMgt: Codeunit "NPR HL Member Mgt.";

    procedure UnsubscribeMember(HeyLoyaltyId: Text)
    var
        HLMember: Record "NPR HL HeyLoyalty Member";
        HLIntegrationEvents: Codeunit "NPR HL Integration Events";
        HLMemberJToken: JsonToken;
        MemberDataRetrievedFromHL: Boolean;
    begin
        if HeyLoyaltyId = '' then
            exit;
        MemberDataRetrievedFromHL := HLIntegrationMgt.InvokeGetHLMemberByID(HeyLoyaltyId, HLMemberJToken);
        if not GetHLMemberByHeyLoyaltyID(HeyLoyaltyId, HLMember) then begin
            if not MemberDataRetrievedFromHL then
                exit;
            HLMember."E-Mail Address" := HLMemberMgt.GetEmailFromResponse(HLMemberJToken, false, '');
            if HLMember."E-Mail Address" = '' then
                exit;
            if not GetHLMemberByEmailAddress(HLMember) then
                exit;
            if (HLMember."HeyLoyalty Id" <> HeyLoyaltyId) and (HLMember."HeyLoyalty Id" <> '') then
                exit;
        end;
        if HLMember."Unsubscribed at" = 0DT then
            HLMember."Unsubscribed at" := CurrentDateTime();
        HLMemberMgt.UpdateHLMemberWithDataFromHeyLoyalty(HLMember, HLMemberJToken, true);
        HLIntegrationEvents.OnUnsubscribeMember(HLMember, HLMemberJToken);
    end;

    procedure UpsertMember(HeyLoyaltyId: Text)
    var
        HLMember: Record "NPR HL HeyLoyalty Member";
        HLMemberJToken: JsonToken;
    begin
        if HeyLoyaltyId = '' then
            exit;
        HLMemberMgt.CheckHeyLoyaltyIdMaxLength(HeyLoyaltyId);
        if not HLIntegrationMgt.InvokeGetHLMemberByID(HeyLoyaltyId, HLMemberJToken) then
            exit;

        if not GetHLMemberByHeyLoyaltyID(HeyLoyaltyId, HLMember) then begin
            HLMember."E-Mail Address" := HLMemberMgt.GetEmailFromResponse(HLMemberJToken, false, '');
            if HLMember."E-Mail Address" = '' then
                exit;
            if not GetHLMemberByEmailAddress(HLMember) then begin
                HLMember.Init();
                HLMember."Entry No." := 0;
                HLMember."HeyLoyalty Id" := CopyStr(HeyLoyaltyId, 1, MaxStrLen(HLMember."HeyLoyalty Id"));
                HLMember.Insert(true);
            end else
                if (HLMember."HeyLoyalty Id" <> HeyLoyaltyId) and (HLMember."HeyLoyalty Id" <> '') then
                    if HLMemberMgt.GetUnsubscribedAtFromResponse(HLMemberJToken, 0DT) <> 0DT then
                        exit;
        end;
        HLMember."Unsubscribed at" := 0DT;
        HLMemberMgt.UpdateHLMemberWithDataFromHeyLoyalty(HLMember, HLMemberJToken, false);
    end;

    procedure GetHLMemberByHeyLoyaltyID(HeyLoyaltyId: Text; var HLMember: Record "NPR HL HeyLoyalty Member"): Boolean
    begin
        Clear(HLMember);
        HLMember.SetCurrentKey("HeyLoyalty Id");
        HLMember.SetRange("HeyLoyalty Id", CopyStr(HeyLoyaltyId, 1, MaxStrLen(HLMember."HeyLoyalty Id")));
        exit(HLMember.FindLast());
    end;

    procedure GetHLMemberByEmailAddress(var HLMember: Record "NPR HL HeyLoyalty Member"): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
        HLMember2: Record "NPR HL HeyLoyalty Member";
        Member: Record "NPR MM Member";
        MemberMgt: Codeunit "NPR HL Member Mgt.";
    begin
        if HLMember."E-Mail Address" = '' then
            exit(false);
        HLMember2 := HLMember;
        Clear(HLMember);
        HLMember.SetCurrentKey("E-Mail Address");
        HLMember.SetRange("E-Mail Address", HLMember2."E-Mail Address");
        if HLMember.IsEmpty() then
            HLMember.SetFilter("E-Mail Address", '@' + ConvertStr(HLMember2."E-Mail Address", '@', '?'));
        if HLMember.FindLast() then
            exit(true);

        if not GetMemberByEmailAddress(HLMember2."E-Mail Address", Member) then
            exit(false);
        MemberMgt.FindMembershipRole(Member, MembershipRole);

        HLMember.Reset();
        if not HLMemberMgt.GetHLMember(Member, MembershipRole, HLMember, "NPR HL Auto Create HL Member"::Never) then
            HLMemberMgt.UpdateHLMember(Member, MembershipRole, HLMember);
        exit(true);
    end;

    procedure GetMemberByEmailAddress(EmailAddress: Text[80]; var Member: Record "NPR MM Member"): Boolean
    begin
        Member.Reset();
        Member.SetRange("E-Mail Address", EmailAddress);
        if Member.IsEmpty() then
            Member.SetFilter("E-Mail Address", '@' + ConvertStr(EmailAddress, '@', '?'));
        exit(Member.FindLast());
    end;
}