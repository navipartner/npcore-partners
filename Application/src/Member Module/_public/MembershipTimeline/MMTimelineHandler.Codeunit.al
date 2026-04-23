codeunit 6151092 "NPR MMTimelineHandler"
{
    Access = Internal;
    internal procedure GetTimelineEvents(MembershipEntryNo: Integer; var TimelineEvents: Record "NPR MMTimelineEventBuffer")
    var
        EventTypeInterface: Interface "NPR MMTimelineTypeInterface";
        TimelineEvent: Record "NPR MMTimelineEventBuffer";
        TimeLineEventType: Enum "NPR MMTimelineEventType";
        EventTypes: List of [Integer];
        EventType: Integer;
        InsertEvents: Boolean;
        EventCounter: Integer;
    begin

        GetAllCoreTimelineEventsWorker(MembershipEntryNo, TimelineEvents);

        TimelineEvents.Reset();
        EventCounter := TimelineEvents.Count();

        // Ask each event type to collect events for the type it represents. 
        // The events are inserted into the timeline buffer with basic information like event type, date time, and source system id filled in. 
        // Title and details are left blank for now and will be filled in the DescribeEvent call later. 
        // PTE can do the full insert / describe in the CollectEvent call if they want to, 
        // but this pattern allows for better separation of concerns where;  
        // - CollectEvent is responsible for collecting events of a certain type and 
        // - DescribeEvent is responsible for describing how those events should look on the timeline.
        EventTypes := "NPR MMTimelineEventType".Ordinals();
        foreach EventType in EventTypes do begin
            TimeLineEventType := Enum::"NPR MMTimelineEventType".FromInteger(EventType);

            EventTypeInterface := TimeLineEventType; // interface implemented by enum value

            TimelineEvent.Reset();
            TimelineEvent.DeleteAll();
            Clear(TimelineEvent);

            InsertEvents := false;
            TimelineEvent.EventType := TimeLineEventType;
            EventTypeInterface.CollectEvents(MembershipEntryNo, TimelineEvent, InsertEvents);

            if (InsertEvents) then begin
                TimelineEvent.Reset();
                TimelineEvent.SetFilter(EventType, '=%1', TimeLineEventType);
                if (TimelineEvent.FindSet()) then begin
                    repeat
                        EventCounter := EventCounter + 1;
                        TimelineEvents.TransferFields(TimelineEvent, false);
                        TimelineEvents.EntryNo := EventCounter;
                        TimelineEvents.SystemId := TimelineEvent.SystemId;
                        TimelineEvents.Insert();
                    until TimelineEvent.Next() = 0;
                end;
            end;
        end;

        // Core uses the DescribeEvent method to describe collected events so that they have title and details for the UI.
        TimelineEvents.Reset();
        if (TimelineEvents.FindSet()) then
            repeat
                EventTypeInterface := TimelineEvents.EventType;

                TimelineEvent.TransferFields(TimelineEvents, true);
                EventTypeInterface.DescribeEvent(TimelineEvent);

                TimelineEvents.Title := TimelineEvent.Title;
                TimelineEvents.Details := TimelineEvent.Details;
                if (not TimelineEvents.Modify()) then;

            until (TimelineEvents.Next() = 0);

    end;


    local procedure GetAllCoreTimelineEventsWorker(MembershipEntryNo: Integer; var TimelineEvents: Record "NPR MMTimelineEventBuffer")
    var
        Membership: Record "NPR MM Membership";
    begin
        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        CollectedMembershipEvents(MembershipEntryNo, TimelineEvents);
        CollectedMemberEvents(MembershipEntryNo, TimelineEvents);
        CollectedMemberCardEvents(MembershipEntryNo, TimelineEvents);

    end;

    local procedure GetUserName(UserId: Guid): Text[100]
    var
        User: Record User;
    begin
        if (User.Get(UserId)) then begin
            if (User."Full Name" <> '') then
                exit(User."Full Name");
            exit(User."User Name");
        end;

        exit('--');
    end;

    local procedure GetUserName(UserName: Code[50]): Text[100]
    var
        User: Record User;
    begin
        User.SetRange("User Name", UserName);
        if (User.FindFirst()) then
            exit(GetUserName(User."User Security ID"));

        exit('--');
    end;

    local procedure CollectedMembershipEvents(MembershipEntryNo: Integer; var TimelineEvents: Record "NPR MMTimelineEventBuffer")
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        SkipInsert: Boolean;
    begin
        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        TimelineEvents.EntryNo := 1;
        TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBERSHIP_ISSUED;
        TimelineEvents.EventDateTime := Membership.SystemCreatedAt;
        TimelineEvents.SourceTableId := Database::"NPR MM Membership";
        TimelineEvents.SourceSystemId := Membership.SystemId;
        TimelineEvents.EventCreatedBy := GetUserName(Membership.SystemCreatedBy);
        TimelineEvents.Insert();

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        if MembershipEntry.FindSet() then
            repeat
                SkipInsert := false;
                TimelineEvents.EntryNo := TimelineEvents.EntryNo + 1;
                TimelineEvents.EventDateTime := MembershipEntry.SystemCreatedAt;
                TimelineEvents.SourceTableId := Database::"NPR MM Membership Entry";
                TimelineEvents.SourceSystemId := MembershipEntry.SystemId;
                TimelineEvents.EventCreatedBy := GetUserName(MembershipEntry.SystemCreatedBy);

                case MembershipEntry."Original Context" of
                    MembershipEntry."Original Context"::New:
                        TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBERSHIP_ACTIVATED;

                    MembershipEntry."Original Context"::RENEW:
                        TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBERSHIP_RENEWED;

                    MembershipEntry."Original Context"::UPGRADE:
                        TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBERSHIP_UPGRADE;

                    MembershipEntry."Original Context"::EXTEND:
                        TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBERSHIP_EXTEND;

                    MembershipEntry."Original Context"::CANCEL:
                        TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBERSHIP_CANCEL;

                    MembershipEntry."Original Context"::AUTORENEW:
                        TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBERSHIP_AUTORENEW;

                    MembershipEntry."Original Context"::FOREIGN:
                        TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBERSHIP_FOREIGN;

                    else
                        SkipInsert := true;
                end;

                if (not SkipInsert) then
                    TimelineEvents.Insert();

                if (Format(MembershipEntry."Duration Dateformula") <> '') and (MembershipEntry."Valid From Date" <> 0D) then begin
                    if (MembershipEntry."Valid Until Date" <> CalcDate(MembershipEntry."Duration Dateformula", MembershipEntry."Valid From Date")) then begin
                        TimelineEvents.EntryNo := TimelineEvents.EntryNo + 1;
                        TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBERSHIP_CANCEL;
                        TimelineEvents.EventDateTime := MembershipEntry.SystemModifiedAt;
                        TimelineEvents.Insert();
                    end;
                end;

                if (MembershipEntry.Context <> MembershipEntry."Original Context") then begin
                    TimelineEvents.EntryNo := TimelineEvents.EntryNo + 1;
                    TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBERSHIP_REGRET;
                    TimelineEvents.EventDateTime := MembershipEntry.SystemModifiedAt + 100; // add 100 ms to ensure regret event shows after cancel event in case of regret on cancellation
                    TimelineEvents.Insert();
                end;

            until MembershipEntry.Next() = 0;

    end;

    local procedure CollectedMemberEvents(MembershipEntryNo: Integer; var TimelineEvents: Record "NPR MMTimelineEventBuffer")
    var
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        MemberImage: Record "NPR CloudflareMediaLink";
    begin
        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if MembershipRole.FindSet() then
            repeat
                if (Member.Get(MembershipRole."Member Entry No.")) then begin
                    TimelineEvents.EntryNo := TimelineEvents.EntryNo + 1;
                    TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBER_ADDED;
                    TimelineEvents.EventDateTime := Member.SystemCreatedAt + 100; // add 100 ms to ensure member added event shows after membership issued event
                    TimelineEvents.SourceTableId := Database::"NPR MM Member";
                    TimelineEvents.SourceSystemId := Member.SystemId;
                    TimelineEvents.EventCreatedBy := GetUserName(Member.SystemCreatedBy);
                    TimelineEvents.Insert();

                    TimelineEvents.EntryNo := TimelineEvents.EntryNo + 1;
                    TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBER_LAST_UPDATED;
                    TimelineEvents.EventDateTime := Member.SystemModifiedAt + 100; // add 100 ms to ensure member added event shows after membership issued event;
                    TimelineEvents.SourceTableId := Database::"NPR MM Member";
                    TimelineEvents.SourceSystemId := Member.SystemId;
                    TimelineEvents.EventCreatedBy := GetUserName(Member.SystemModifiedBy);
                    TimelineEvents.Insert();

                    if (Member.Blocked) then begin
                        TimelineEvents.EntryNo := TimelineEvents.EntryNo + 1;
                        TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBER_LAST_BLOCKED;
                        TimelineEvents.EventDateTime := Member."Blocked At";
                        TimelineEvents.SourceTableId := Database::"NPR MM Member";
                        TimelineEvents.SourceSystemId := Member.SystemId;
                        TimelineEvents.EventCreatedBy := GetUserName(Member."Blocked By");
                        TimelineEvents.Insert();
                    end;

                    MemberImage.SetFilter(TableNumber, '=%1', Database::"NPR MM Member");
                    MemberImage.SetFilter(RecordId, '=%1', Member.SystemId);
                    if (MemberImage.FindFirst()) then begin
                        TimelineEvents.EntryNo := TimelineEvents.EntryNo + 1;
                        TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBER_IMAGE_ADDED;
                        TimelineEvents.EventDateTime := MemberImage.SystemCreatedAt;
                        TimelineEvents.SourceTableId := Database::"NPR CloudflareMediaLink";
                        TimelineEvents.SourceSystemId := MemberImage.SystemId;
                        TimelineEvents.EventCreatedBy := GetUserName(MemberImage.SystemCreatedBy);
                        TimelineEvents.Insert();

                        if (MemberImage.SystemModifiedAt <> MemberImage.SystemCreatedAt) then begin
                            TimelineEvents.EntryNo := TimelineEvents.EntryNo + 1;
                            TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBER_IMAGE_LAST_UPDATED;
                            TimelineEvents.EventDateTime := MemberImage.SystemModifiedAt;
                            TimelineEvents.SourceTableId := Database::"NPR CloudflareMediaLink";
                            TimelineEvents.SourceSystemId := MemberImage.SystemId;
                            TimelineEvents.EventCreatedBy := GetUserName(MemberImage.SystemModifiedBy);
                            TimelineEvents.Insert();
                        end;
                    end;
                end;
            until MembershipRole.Next() = 0;
    end;

    local procedure CollectedMemberCardEvents(MembershipEntryNo: Integer; var TimelineEvents: Record "NPR MMTimelineEventBuffer")
    var
        MemberCard: Record "NPR MM Member Card";
    begin
        MemberCard.SetCurrentKey("Membership Entry No.");
        MemberCard.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if MemberCard.FindSet() then
            repeat
                TimelineEvents.EntryNo := TimelineEvents.EntryNo + 1;
                TimelineEvents.EventType := "NPR MMTimelineEventType"::MEMBER_CARD_ADDED;
                TimelineEvents.EventDateTime := MemberCard.SystemCreatedAt;
                TimelineEvents.SourceTableId := Database::"NPR MM Member Card";
                TimelineEvents.SourceSystemId := MemberCard.SystemId;
                TimelineEvents.EventCreatedBy := GetUserName(MemberCard.SystemCreatedBy);
                TimelineEvents.Insert();
            until MemberCard.Next() = 0;
    end;

}