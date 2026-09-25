/// <summary>
/// Every ticket module webhook is declared here, so there is one place to look for them. The logic that
/// decides when to raise one lives elsewhere - for capacity, in codeunit "NPR TM CapacityWebHook".
/// </summary>
codeunit 6151549 "NPR TM Ticket Webhooks"
{
    Access = Internal;

    [ExternalBusinessEvent('timeslot_capacity_changed', 'Time Slot Capacity Changed', 'Raised for time slots on admissions whose capacity control is Sales; other controls count admissions rather than sales and are not reported. Triggered at most once per request, for each such slot whose capacity changed and whose remaining capacity is at or below the notify quantity configured on the admission schedule line. Also raised for the single change that takes a slot back above that quantity, so a consumer always learns when capacity is released. The count is read without locking and can include sales that are still in flight, so treat it as a signal to refresh rather than a figure to sell against - capacity is enforced at issuance, not here. capacityAsOf is when the count was taken - earlier than the event timestamp by however long the rest of the transaction ran. A redelivery repeats it, so it identifies duplicates; where two events for one slot differ, the later one is the fresher count, and equal values mean neither is known to be.', EventCategory::"NPR Ticketing", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR TM Ticket Webhooks", 'X')]
    procedure CapacityChanged(scheduleNumber: Integer; admissionCode: Code[20]; scheduleCode: Code[20]; startDate: Date; startTime: Time; capacityControl: Text[20]; maxCapacity: Integer; remainingCapacity: Integer; capacityAsOf: DateTime)
    begin
    end;

    /// <summary>
    /// Subscribers run mid-sale, before the transaction that raised this is committed, so one that commits has
    /// misunderstood what it is subscribing to.
    /// </summary>
    internal procedure NotifyCapacityChanged(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; RemainingCapacity: Integer; CapacityAsOf: DateTime)
    var
        Sentry: Codeunit "NPR Sentry";
    begin
        ClearLastError();
        if (not TryCapacityChanged(AdmissionScheduleEntry, RemainingCapacity, CapacityAsOf)) then
            Sentry.AddLastErrorIfProgrammingBug();
    end;

    [TryFunction]
    local procedure TryCapacityChanged(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; RemainingCapacity: Integer; CapacityAsOf: DateTime)
    begin
        OnAfterCapacityChanged(AdmissionScheduleEntry, RemainingCapacity, CapacityAsOf);
    end;

    /// <summary>
    /// Raised alongside the external business event, which AL cannot subscribe to, so that tests can assert it.
    /// </summary>
    [CommitBehavior(CommitBehavior::Error)]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterCapacityChanged(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; RemainingCapacity: Integer; CapacityAsOf: DateTime)
    begin
    end;
}
