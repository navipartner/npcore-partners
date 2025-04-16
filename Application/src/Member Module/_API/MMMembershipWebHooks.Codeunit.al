codeunit 6248397 "NPR MM MembershipWebHooks"
{
    Access = Internal;
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)

    internal procedure TriggerMembershipEntryWebhookCall(MembershipId: Guid; MembershipEntryId: Guid)
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Translation: Codeunit "NPR MembershipApiTranslation";
    begin

        MembershipEntry.SetLoadFields(MembershipEntry.SystemId, MembershipEntry."Context");
        if (not MembershipEntry.GetBySystemId(MembershipEntryId)) then
            exit;

        case MembershipEntry.Context of
            MembershipEntry.Context::NEW:
                OnMembershipCreated(MembershipId, MembershipEntryId);

            MembershipEntry.Context::RENEW:
                OnMembershipRenewedStaged(MembershipId, MembershipEntryId, Translation.MembershipEntryContextToText(MembershipEntry.Context));

            MembershipEntry.Context::UPGRADE:
                OnMembershipUpgradeStaged(MembershipId, MembershipEntryId, Translation.MembershipEntryContextToText(MembershipEntry.Context));

            MembershipEntry.Context::EXTEND:
                OnMembershipExtendStaged(MembershipId, MembershipEntryId, Translation.MembershipEntryContextToText(MembershipEntry.Context));

            MembershipEntry.Context::CANCEL:
                OnMembershipPeriodCancel(MembershipId, MembershipEntryId, Translation.MembershipEntryContextToText(MembershipEntry.Context));

            MembershipEntry.Context::REGRET:
                OnMembershipPeriodRegret(MembershipId, MembershipEntryId, Translation.MembershipEntryContextToText(MembershipEntry.Context));

            MembershipEntry.Context::AUTORENEW:
                OnMembershipAutoRenewedStaged(MembershipId, MembershipEntryId, Translation.MembershipEntryContextToText(MembershipEntry.Context));
        end;
    end;

    internal procedure TriggerMembershipActivatedWebhookCall(MembershipId: Guid; MembershipEntryId: Guid)
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin

        MembershipEntry.SetLoadFields(MembershipEntry.SystemId, MembershipEntry."Context");
        if (not MembershipEntry.GetBySystemId(MembershipEntryId)) then
            exit;

        OnMembershipActivated(MembershipId, MembershipEntryId);
    end;

    internal procedure TriggerMemberAddedWebhookCall(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberId: Guid)
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        Translation: Codeunit "NPR MembershipApiTranslation";
    begin
        Membership.SetLoadFields(Membership.SystemId);
        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        MembershipRole.SetLoadFields(MembershipRole."Member Role");
        if (not (MembershipRole.Get(MembershipEntryNo, MemberEntryNo))) then
            exit;

        OnMembershipMemberAdded(Membership.SystemId, MemberId, Translation.MemberRoleToText(MembershipRole."Member Role"));

    end;

    [ExternalBusinessEvent('membership_created', 'Membership Created', 'Triggered when a membership has been created', EventCategory::"NPR Membership", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR MM MembershipWebHooks", 'X')]
    local procedure OnMembershipCreated(membershipId: Guid; entryId: Guid)
    begin
    end;

    [ExternalBusinessEvent('membershipMember_added', 'Membership Member Added', 'Triggered when a member is added to a membership', EventCategory::"NPR Membership", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR MM MembershipWebHooks", 'X')]
    local procedure OnMembershipMemberAdded(membershipId: Guid; memberId: Guid; memberRole: Text[50])
    begin
    end;

    [ExternalBusinessEvent('membershipPeriodRenew_staged', 'Membership Renew Event Staged', 'Triggered when a renewal period is created for the membership', EventCategory::"NPR Membership", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR MM MembershipWebHooks", 'X')]
    local procedure OnMembershipRenewedStaged(membershipId: Guid; entryId: Guid; lifecycleAction: Text[50])
    begin
    end;

    [ExternalBusinessEvent('membershipPeriodAutoRenew_staged', 'Membership AutoRenew Event Staged', 'Triggered when a auto renewal period is created for the membership', EventCategory::"NPR Membership", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR MM MembershipWebHooks", 'X')]
    local procedure OnMembershipAutoRenewedStaged(membershipId: Guid; entryId: Guid; lifecycleAction: Text[50])
    begin
    end;

    [ExternalBusinessEvent('membershipPeriodUpgrade_staged', 'Membership Upgrade Event Staged', 'Triggered when a cancel period is created for the membership', EventCategory::"NPR Membership", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR MM MembershipWebHooks", 'X')]
    local procedure OnMembershipUpgradeStaged(membershipId: Guid; entryId: Guid; lifecycleAction: Text[50])
    begin
    end;

    [ExternalBusinessEvent('membershipPeriodExtend_staged', 'Membership Extend Event Staged', 'Triggered when a extend period is created for the membership', EventCategory::"NPR Membership", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR MM MembershipWebHooks", 'X')]
    local procedure OnMembershipExtendStaged(membershipId: Guid; entryId: Guid; lifecycleAction: Text[50])
    begin
    end;

    [ExternalBusinessEvent('membershipPeriod_cancel', 'Membership period is terminated early', 'Triggered when a period is terminated before the initial valid until date', EventCategory::"NPR Membership", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR MM MembershipWebHooks", 'X')]
    local procedure OnMembershipPeriodCancel(membershipId: Guid; entryId: Guid; lifecycleAction: Text[50])
    begin
    end;

    [ExternalBusinessEvent('membershipPeriod_regret', 'Membership period is regretted', 'Triggered when a period is regretted (soft delete of period)', EventCategory::"NPR Membership", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR MM MembershipWebHooks", 'X')]
    local procedure OnMembershipPeriodRegret(membershipId: Guid; entryId: Guid; lifecycleAction: Text[50])
    begin
    end;

    [ExternalBusinessEvent('membershipPeriod_activated', 'Membership Activated', 'Triggered when a membership has been activated', EventCategory::"NPR Membership", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR MM MembershipWebHooks", 'X')]
    local procedure OnMembershipActivated(membershipId: Guid; entryId: Guid)
    begin
    end;

#else
    internal procedure TriggerMembershipActivatedWebhookCall(MembershipId: Guid; MembershipEntryId: Guid)
    begin
        // This is a placeholder to ensure compatibility with older versions.
    end;

    internal procedure TriggerMembershipEntryWebhookCall(MembershipId: Guid; MembershipEntryId: Guid)
    begin
        // This is a placeholder to ensure compatibility with older versions.
    end;

    internal procedure TriggerMemberAddedWebhookCall(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberId: Guid)
    begin
        // This is a placeholder to ensure compatibility with older versions.
    end;
#endif
}