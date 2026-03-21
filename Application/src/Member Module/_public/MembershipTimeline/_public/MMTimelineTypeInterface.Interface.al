interface "NPR MMTimelineTypeInterface"
{
    procedure CollectEvents(MembershipEntryNo: Integer; var TimelineEvent: Record "NPR MMTimelineEventBuffer"; var InsertEvents: Boolean);
    procedure DescribeEvent(var TimelineEvent: Record "NPR MMTimelineEventBuffer");
}