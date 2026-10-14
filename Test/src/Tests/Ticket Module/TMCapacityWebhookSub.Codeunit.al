codeunit 85459 "NPR TM Capacity WebhookSub"
{
    EventSubscriberInstance = Manual;

    var
        _LastExternalEntryNo: Integer;
        _LastRemainingCapacity: Integer;
        _LastCapacityAsOf: DateTime;
        _EventCount: Integer;
        _ExternalEntryNos: List of [Integer];
        _RemainingCapacities: List of [Integer];

    procedure Reset()
    begin
        _EventCount := 0;
        _LastExternalEntryNo := 0;
        _LastRemainingCapacity := 0;
        _LastCapacityAsOf := 0DT;
        Clear(_ExternalEntryNos);
        Clear(_RemainingCapacities);
    end;

    procedure EventCount(): Integer
    begin
        exit(_EventCount);
    end;

    procedure LastExternalEntryNo(): Integer
    begin
        exit(_LastExternalEntryNo);
    end;

    procedure LastRemainingCapacity(): Integer
    begin
        exit(_LastRemainingCapacity);
    end;

    procedure LastCapacityAsOf(): DateTime
    begin
        exit(_LastCapacityAsOf);
    end;

    procedure EventCountFor(ExternalEntryNo: Integer) Events: Integer
    var
        EntryNo: Integer;
    begin
        foreach EntryNo in _ExternalEntryNos do
            if (EntryNo = ExternalEntryNo) then
                Events += 1;
    end;

    // The remaining capacity of the last event for the slot, -1 when the slot had no event.
    procedure RemainingCapacityFor(ExternalEntryNo: Integer) RemainingCapacity: Integer
    var
        Index: Integer;
    begin
        RemainingCapacity := -1;
        for Index := 1 to _ExternalEntryNos.Count() do
            if (_ExternalEntryNos.Get(Index) = ExternalEntryNo) then
                RemainingCapacity := _RemainingCapacities.Get(Index);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR TM Ticket Webhooks", OnAfterCapacityChanged, '', false, false)]
    local procedure OnAfterCapacityChanged(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; RemainingCapacity: Integer; CapacityAsOf: DateTime)
    begin
        _EventCount += 1;
        _LastExternalEntryNo := AdmissionScheduleEntry."External Schedule Entry No.";
        _LastRemainingCapacity := RemainingCapacity;
        _LastCapacityAsOf := CapacityAsOf;
        _ExternalEntryNos.Add(AdmissionScheduleEntry."External Schedule Entry No.");
        _RemainingCapacities.Add(RemainingCapacity);
    end;
}
