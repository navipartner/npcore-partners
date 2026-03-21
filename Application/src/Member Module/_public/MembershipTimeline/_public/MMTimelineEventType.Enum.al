enum 6014610 "NPR MMTimelineEventType" implements "NPR MMTimelineTypeInterface"
{
    Extensible = true;

    value(0; MEMBERSHIP_ISSUED)
    {
        Caption = 'Membership Issued';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }

    value(1; MEMBERSHIP_ACTIVATED)
    {
        Caption = 'Membership Activated';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }

    value(10; MEMBERSHIP_RENEWED)
    {
        Caption = 'Membership Renewed';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }

    value(11; MEMBERSHIP_REGRET)
    {
        Caption = 'Membership Regret';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }
    value(12; MEMBERSHIP_UPGRADE)
    {
        Caption = 'Membership Upgrade';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }
    value(13; MEMBERSHIP_EXTEND)
    {
        Caption = 'Membership Extend';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }
    value(14; MEMBERSHIP_CANCEL)
    {
        Caption = 'Membership Cancel';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }
    value(15; MEMBERSHIP_AUTORENEW)
    {
        Caption = 'Membership Auto-Renew';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }
    value(16; MEMBERSHIP_FOREIGN)
    {
        Caption = 'Foreign Membership';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }

    value(100; MEMBER_ADDED)
    {
        Caption = 'Member Added';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }

    value(110; MEMBER_LAST_BLOCKED)
    {
        Caption = 'Member Last Blocked';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }

    value(120; MEMBER_LAST_UPDATED)
    {
        Caption = 'Member Last Updated';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }

    value(130; MEMBER_IMAGE_ADDED)
    {
        Caption = 'Member Image Added';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }

    value(131; MEMBER_IMAGE_LAST_UPDATED)
    {
        Caption = 'Member Image Last Updated';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }

    value(200; MEMBER_CARD_ADDED)
    {
        Caption = 'Member Card Added';
        Implementation = "NPR MMTimelineTypeInterface" = "NPR MMTimelineDescribeEvent";
    }

}