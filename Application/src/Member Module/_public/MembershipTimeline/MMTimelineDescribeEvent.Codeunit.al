codeunit 6151091 "NPR MMTimelineDescribeEvent" implements "NPR MMTimelineTypeInterface"
{
    Access = Internal;
    procedure CollectEvents(MembershipEntryNo: Integer; var TimelineEvent: Record "NPR MMTimelineEventBuffer"; var InsertEvents: Boolean)
    begin
        // The core events are collected directly in the timeline handler. 
        // This method is for non-core events.
        InsertEvents := false;
    end;

    procedure DescribeEvent(var TimelineEvent: Record "NPR MMTimelineEventBuffer")
    begin
        case TimelineEvent.EventType of
            "NPR MMTimelineEventType"::MEMBERSHIP_ISSUED,
            "NPR MMTimelineEventType"::MEMBERSHIP_ACTIVATED,
            "NPR MMTimelineEventType"::MEMBERSHIP_RENEWED,
            "NPR MMTimelineEventType"::MEMBERSHIP_REGRET,
            "NPR MMTimelineEventType"::MEMBERSHIP_UPGRADE,
            "NPR MMTimelineEventType"::MEMBERSHIP_EXTEND,
            "NPR MMTimelineEventType"::MEMBERSHIP_CANCEL,
            "NPR MMTimelineEventType"::MEMBERSHIP_AUTORENEW,
            "NPR MMTimelineEventType"::MEMBERSHIP_FOREIGN:
                DescribeMembershipEvent(TimelineEvent);

            "NPR MMTimelineEventType"::MEMBER_ADDED,
            "NPR MMTimelineEventType"::MEMBER_LAST_BLOCKED,
            "NPR MMTimelineEventType"::MEMBER_LAST_UPDATED:
                DescribeMemberEvent(TimelineEvent);

            "NPR MMTimelineEventType"::MEMBER_IMAGE_ADDED,
            "NPR MMTimelineEventType"::MEMBER_IMAGE_LAST_UPDATED:
                DescribeMemberImageEvent(TimelineEvent);

            "NPR MMTimelineEventType"::MEMBER_CARD_ADDED:
                DescribeMemberCardEvent(TimelineEvent);
        end;

    end;


    local procedure DescribeMembershipEvent(var TimelineEvent: Record "NPR MMTimelineEventBuffer")
    var
        CreatedLabel: Label 'Issued';
        RenewedLabel: Label 'Renewed';
        ActivatedLabel: Label 'Activated';
        RegretLabel: Label 'Regretted';
        UpgradeLabel: Label 'Upgraded';
        ExtendLabel: Label 'Extended';
        CancelLabel: Label 'Cancelled';
        AutoRenewLabel: Label 'Auto-Renewed';
        ForeignLabel: Label 'Foreign Membership';
        ActivatedDetailsLabel: Label 'The membership was activated on %1. The valid from date is %2 until %3.';
        CreatedDetailsLabel: Label 'The membership was issued on %1 with a valid from date %2.';
        RenewedDetailsLabel: Label 'The membership was renewed on %1. The new valid from date is %2 until %3.';
        UpgradeDetailsLabel: Label 'The membership was upgraded on %1. The valid from date was %2 until %3.';
        ExtendDetailsLabel: Label 'The membership was extended on %1. The valid from date was %2 until %3.';
        AutoRenewDetailsLabel: Label 'The membership was auto-renewed on %1. The valid from date was %2 until %3.';
        ForeignDetailsLabel: Label 'The membership was marked as foreign membership on %1. The valid from date was %2 until %3.';

        CancelDetailsLabel: Label 'The membership was cancelled on %1. New valid until date is %2.';
        RegretDetailsLabel: Label 'The membership was regretted on %1.';

        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        case TimelineEvent.EventType of
            "NPR MMTimelineEventType"::MEMBERSHIP_ISSUED:
                begin
                    Membership.GetBySystemId(TimelineEvent.SourceSystemId);
                    TimelineEvent.Title := CreatedLabel;
                    TimelineEvent.Details := StrSubstNo(CreatedDetailsLabel, Membership.SystemCreatedAt, Membership."Issued Date");
                end;
            "NPR MMTimelineEventType"::MEMBERSHIP_ACTIVATED:
                begin
                    MembershipEntry.GetBySystemId(TimelineEvent.SourceSystemId);
                    TimelineEvent.Title := ActivatedLabel;
                    TimelineEvent.Details := StrSubstNo(ActivatedDetailsLabel, MembershipEntry.SystemCreatedAt, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
                end;
            "NPR MMTimelineEventType"::MEMBERSHIP_RENEWED:
                begin
                    MembershipEntry.GetBySystemId(TimelineEvent.SourceSystemId);
                    TimelineEvent.Title := RenewedLabel;
                    TimelineEvent.Details := StrSubstNo(RenewedDetailsLabel, MembershipEntry.SystemCreatedAt, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
                end;
            "NPR MMTimelineEventType"::MEMBERSHIP_UPGRADE:
                begin
                    MembershipEntry.GetBySystemId(TimelineEvent.SourceSystemId);
                    TimelineEvent.Title := UpgradeLabel;
                    TimelineEvent.Details := StrSubstNo(UpgradeDetailsLabel, MembershipEntry.SystemCreatedAt, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
                end;
            "NPR MMTimelineEventType"::MEMBERSHIP_EXTEND:
                begin
                    MembershipEntry.GetBySystemId(TimelineEvent.SourceSystemId);
                    TimelineEvent.Title := ExtendLabel;
                    TimelineEvent.Details := StrSubstNo(ExtendDetailsLabel, MembershipEntry.SystemCreatedAt, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
                end;
            "NPR MMTimelineEventType"::MEMBERSHIP_AUTORENEW:
                begin
                    MembershipEntry.GetBySystemId(TimelineEvent.SourceSystemId);
                    TimelineEvent.Title := AutoRenewLabel;
                    TimelineEvent.Details := StrSubstNo(AutoRenewDetailsLabel, MembershipEntry.SystemCreatedAt, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
                end;
            "NPR MMTimelineEventType"::MEMBERSHIP_FOREIGN:
                begin
                    MembershipEntry.GetBySystemId(TimelineEvent.SourceSystemId);
                    TimelineEvent.Title := ForeignLabel;
                    TimelineEvent.Details := StrSubstNo(ForeignDetailsLabel, MembershipEntry.SystemCreatedAt, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
                end;
            "NPR MMTimelineEventType"::MEMBERSHIP_REGRET:
                begin
                    MembershipEntry.GetBySystemId(TimelineEvent.SourceSystemId);
                    TimelineEvent.Title := RegretLabel;
                    TimelineEvent.Details := StrSubstNo(RegretDetailsLabel, MembershipEntry.SystemCreatedAt);
                end;
            "NPR MMTimelineEventType"::MEMBERSHIP_CANCEL:
                begin
                    MembershipEntry.GetBySystemId(TimelineEvent.SourceSystemId);
                    TimelineEvent.Title := CancelLabel;
                    TimelineEvent.Details := StrSubstNo(CancelDetailsLabel, MembershipEntry.SystemCreatedAt, MembershipEntry."Valid Until Date");
                end;

        end;
    end;

    local procedure DescribeMemberEvent(var TimelineEvent: Record "NPR MMTimelineEventBuffer")
    var
        AddedLabel: Label 'Added Member';
        BlockedLabel: Label 'Blocked Member';
        UpdatedLabel: Label 'Updated Member';
        AddedDescription: Label 'The member %1 was added on %2.';
        BlockedDescription: Label 'The member %1 was blocked on %2 by %3.';
        UpdatedDescription: Label 'The member %1 was last updated on %2.';
        Member: Record "NPR MM Member";
    begin
        Member.GetBySystemId(TimelineEvent.SourceSystemId);
        case TimelineEvent.EventType of
            "NPR MMTimelineEventType"::MEMBER_ADDED:
                begin
                    TimelineEvent.Title := AddedLabel;
                    TimelineEvent.Details := StrSubstNo(AddedDescription, Member."Display Name", Member.SystemCreatedAt);
                end;
            "NPR MMTimelineEventType"::MEMBER_LAST_BLOCKED:
                begin
                    TimelineEvent.Title := BlockedLabel;
                    TimelineEvent.Details := StrSubstNo(BlockedDescription, Member."Display Name", Member."Blocked At", Member."Blocked By");
                end;
            "NPR MMTimelineEventType"::MEMBER_LAST_UPDATED:
                begin
                    TimelineEvent.Title := UpdatedLabel;
                    TimelineEvent.Details := StrSubstNo(UpdatedDescription, Member."Display Name", Member.SystemModifiedAt);
                end;
        end;
    end;

    local procedure DescribeMemberImageEvent(var TimelineEvent: Record "NPR MMTimelineEventBuffer")
    var
        AddedLabel: Label 'Added Image';
        UpdatedLabel: Label 'Updated Image';
        ImageAdded: Label 'Member image was added on %1.';
        ImageUpdated: Label 'Member image was updated on %1.';
        CloudflareMedia: Record "NPR CloudflareMediaLink";
    begin
        CloudflareMedia.GetBySystemId(TimelineEvent.SourceSystemId);
        case TimelineEvent.EventType of
            "NPR MMTimelineEventType"::MEMBER_IMAGE_ADDED:
                begin
                    TimelineEvent.Title := AddedLabel;
                    TimelineEvent.Details := StrSubstNo(ImageAdded, CloudflareMedia.SystemCreatedAt);
                end;
            "NPR MMTimelineEventType"::MEMBER_IMAGE_LAST_UPDATED:
                begin
                    TimelineEvent.Title := UpdatedLabel;
                    TimelineEvent.Details := StrSubstNo(ImageUpdated, CloudflareMedia.SystemModifiedAt);
                end;
        end;
    end;

    local procedure DescribeMemberCardEvent(var TimelineEvent: Record "NPR MMTimelineEventBuffer")
    var
        AddedLabel: Label 'Added Card';
        AddedDescription: Label 'The member card %1 was added on %2.';
        MemberCard: Record "NPR MM Member Card";
    begin
        MemberCard.GetBySystemId(TimelineEvent.SourceSystemId);
        case TimelineEvent.EventType of
            "NPR MMTimelineEventType"::MEMBER_CARD_ADDED:
                begin
                    TimelineEvent.Title := AddedLabel;
                    TimelineEvent.Details := StrSubstNo(AddedDescription, MemberCard."External Card No.", MemberCard.SystemCreatedAt);
                end;
        end;
    end;
}