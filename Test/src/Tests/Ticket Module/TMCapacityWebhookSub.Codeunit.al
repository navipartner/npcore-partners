codeunit 85459 "NPR TM Capacity WebhookSub"
{
    EventSubscriberInstance = Manual;

    var
        _LastExternalEntryNo: Integer;
        _LastRemainingCapacity: Integer;
        _LastCapacityAsOf: DateTime;
        _EventCount: Integer;

    procedure Reset()
    begin
        _EventCount := 0;
        _LastExternalEntryNo := 0;
        _LastRemainingCapacity := 0;
        _LastCapacityAsOf := 0DT;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR TM Ticket Webhooks", OnAfterCapacityChanged, '', false, false)]
    local procedure OnAfterCapacityChanged(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; RemainingCapacity: Integer; CapacityAsOf: DateTime)
    begin
        _EventCount += 1;
        _LastExternalEntryNo := AdmissionScheduleEntry."External Schedule Entry No.";
        _LastRemainingCapacity := RemainingCapacity;
        _LastCapacityAsOf := CapacityAsOf;
    end;
}
