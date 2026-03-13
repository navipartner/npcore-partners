#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
codeunit 6151096 "NPR MM WebhookChangeDetect"
{
    Access = Internal;

    local procedure HasMemberWatchedFieldChanged(BeforeMember: Record "NPR MM Member"; AfterMember: Record "NPR MM Member"): Boolean
    begin
        exit(
            (BeforeMember."External Member No." <> AfterMember."External Member No.") or
            (BeforeMember."First Name" <> AfterMember."First Name") or
            (BeforeMember."Middle Name" <> AfterMember."Middle Name") or
            (BeforeMember."Last Name" <> AfterMember."Last Name") or
            (BeforeMember.Address <> AfterMember.Address) or
            (BeforeMember."Post Code Code" <> AfterMember."Post Code Code") or
            (BeforeMember.City <> AfterMember.City) or
            (BeforeMember.Country <> AfterMember.Country) or
            (BeforeMember."E-Mail Address" <> AfterMember."E-Mail Address") or
            (BeforeMember."Phone No." <> AfterMember."Phone No.") or
            (BeforeMember.Gender <> AfterMember.Gender) or
            (BeforeMember.Birthday <> AfterMember.Birthday) or
            (BeforeMember."E-Mail News Letter" <> AfterMember."E-Mail News Letter") or
            (BeforeMember.Blocked <> AfterMember.Blocked)
        );
    end;

    local procedure HasMembershipWatchedFieldChanged(BeforeMembership: Record "NPR MM Membership"; AfterMembership: Record "NPR MM Membership"): Boolean
    begin
        exit(
            (BeforeMembership."External Membership No." <> AfterMembership."External Membership No.") or
            (BeforeMembership.Description <> AfterMembership.Description) or
            (BeforeMembership."Community Code" <> AfterMembership."Community Code") or
            (BeforeMembership."Membership Code" <> AfterMembership."Membership Code") or
            (BeforeMembership."Customer No." <> AfterMembership."Customer No.") or
            (BeforeMembership.Blocked <> AfterMembership.Blocked) or
            (BeforeMembership."Auto-Renew" <> AfterMembership."Auto-Renew")
        );
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Member", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterMemberModify(var Rec: Record "NPR MM Member"; var xRec: Record "NPR MM Member")
    var
        MembershipWebhooks: Codeunit "NPR MM MembershipWebHooks";
    begin
        if (Rec.IsTemporary()) then
            exit;

        if not HasMemberWatchedFieldChanged(xRec, Rec) then
            exit;

        MembershipWebhooks.OnMemberDetailsUpdated(Rec.SystemId);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Membership", OnAfterModifyEvent, '', false, false)]
    local procedure OnAfterMembershipModify(var Rec: Record "NPR MM Membership"; var xRec: Record "NPR MM Membership")
    var
        MembershipWebhooks: Codeunit "NPR MM MembershipWebHooks";
    begin
        if (Rec.IsTemporary()) then
            exit;

        if not HasMembershipWatchedFieldChanged(xRec, Rec) then
            exit;

        MembershipWebhooks.OnMembershipDetailsUpdated(Rec.SystemId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Attribute Management", OnAfterClientAttributeNewValue, '', false, false)]
    local procedure OnAfterAttributeChanged(NPRAttributeKey: Record "NPR Attribute Key"; NPRAttributeValueSet: Record "NPR Attribute Value Set")
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipWebhooks: Codeunit "NPR MM MembershipWebHooks";
        EntryNo: Integer;
    begin
        if not Evaluate(EntryNo, NPRAttributeKey."MDR Code PK") then
            exit;

        case NPRAttributeKey."Table ID" of
            Database::"NPR MM Member":
                begin
                    if (not Member.Get(EntryNo)) then
                        exit;
                    MembershipWebhooks.OnMemberDetailsUpdated(Member.SystemId);
                end;
            Database::"NPR MM Membership":
                begin
                    if (not Membership.Get(EntryNo)) then
                        exit;
                    MembershipWebhooks.OnMembershipDetailsUpdated(Membership.SystemId);
                end;
        end;
    end;
}
#endif
