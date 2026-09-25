codeunit 6151545 "NPR TM CapacityWebHook"
{
    Access = Internal;
    SingleInstance = true;

    var
        _TouchedScheduleEntries: Dictionary of [Integer, Integer];
        _NetQuantities: Dictionary of [Integer, Decimal];
        _LastFlushedEntries: List of [Integer];

    /// <summary>
    /// Records a detail row that takes capacity. Consumes and releases accumulate into one signed net per
    /// slot, which the emit adds back to reconstruct where the slot stood before this request.
    /// </summary>
    internal procedure TouchConsumedEntry(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; ConsumedQuantity: Decimal)
    begin
        if (AdmissionScheduleEntry."External Schedule Entry No." <= 0) then
            exit;

        TouchEntry(AdmissionScheduleEntry);
        Accumulate(AdmissionScheduleEntry."External Schedule Entry No.", ConsumedQuantity);
    end;

    internal procedure TouchConsumedExternalEntry(ExternalAdmissionScheduleEntryNo: Integer; ConsumedQuantity: Decimal)
    begin
        if (not TouchExternalEntry(ExternalAdmissionScheduleEntryNo)) then
            exit;

        Accumulate(ExternalAdmissionScheduleEntryNo, ConsumedQuantity);
    end;

    internal procedure TouchReleasedExternalEntry(ExternalAdmissionScheduleEntryNo: Integer; ReleasedQuantity: Decimal)
    begin
        if (not TouchExternalEntry(ExternalAdmissionScheduleEntryNo)) then
            exit;

        Accumulate(ExternalAdmissionScheduleEntryNo, -ReleasedQuantity);
    end;

    local procedure TouchExternalEntry(ExternalAdmissionScheduleEntryNo: Integer): Boolean
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        if (ExternalAdmissionScheduleEntryNo <= 0) then
            exit(false);

        if (_TouchedScheduleEntries.ContainsKey(ExternalAdmissionScheduleEntryNo)) then
            exit(true);

        AdmissionScheduleEntry.SetCurrentKey("External Schedule Entry No.");
        AdmissionScheduleEntry.SetLoadFields("Entry No.", "External Schedule Entry No.");
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExternalAdmissionScheduleEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindFirst()) then
            exit(false);

        TouchEntry(AdmissionScheduleEntry);
        exit(true);
    end;

    /// <summary>
    /// Signed: a consume is positive, a release negative. A row that is itself negative - the reversal a
    /// reschedule or a cancellation leaves behind - therefore books the opposite direction on its own, since
    /// deleting a negative row raises the count rather than lowering it.
    /// </summary>
    local procedure Accumulate(ExternalAdmissionScheduleEntryNo: Integer; Quantity: Decimal)
    var
        QuantitySoFar: Decimal;
    begin
        if (Quantity = 0) then
            exit;

        if (_NetQuantities.Get(ExternalAdmissionScheduleEntryNo, QuantitySoFar)) then
            _NetQuantities.Set(ExternalAdmissionScheduleEntryNo, QuantitySoFar + Quantity)
        else
            _NetQuantities.Add(ExternalAdmissionScheduleEntryNo, Quantity);
    end;

    local procedure TouchEntry(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry")
    begin
        if (AdmissionScheduleEntry."External Schedule Entry No." <= 0) then
            exit;

        if (_TouchedScheduleEntries.ContainsKey(AdmissionScheduleEntry."External Schedule Entry No.")) then
            exit;

        _TouchedScheduleEntries.Add(AdmissionScheduleEntry."External Schedule Entry No.", AdmissionScheduleEntry."Entry No.");
    end;

    internal procedure GetTouchedEntries(): Dictionary of [Integer, Integer]
    begin
        exit(_TouchedScheduleEntries);
    end;

    internal procedure ClearTouchedEntries()
    begin
        Clear(_TouchedScheduleEntries);
        Clear(_NetQuantities);
    end;

    internal procedure EmitTouchedEntries()
    var
        ExternalEntryNo: Integer;
    begin
        Clear(_LastFlushedEntries);

        foreach ExternalEntryNo in _TouchedScheduleEntries.Keys() do begin
            _LastFlushedEntries.Add(ExternalEntryNo);
            EmitEntry(_TouchedScheduleEntries.Get(ExternalEntryNo), GetNetQuantity(ExternalEntryNo));
        end;

        ClearTouchedEntries();
    end;

    /// <summary>
    /// The slots the last flush handled. A flush empties the buffer, so on the paths that flush this is the
    /// only way a test can see that the operation reached the touch sites at all.
    /// </summary>
    internal procedure GetLastFlushedEntries(): List of [Integer]
    begin
        exit(_LastFlushedEntries);
    end;

    /// <summary>
    /// Deliberately not part of ClearTouchedEntries, which the flush itself calls after writing this record.
    /// A test asserting that an operation flushed must clear it first, or the previous flush's record answers
    /// for a flush that never happened.
    /// </summary>
    internal procedure ClearLastFlushedEntries()
    begin
        Clear(_LastFlushedEntries);
    end;

    local procedure GetNetQuantity(ExternalAdmissionScheduleEntryNo: Integer) Quantity: Decimal
    begin
        if (not _NetQuantities.Get(ExternalAdmissionScheduleEntryNo, Quantity)) then
            Quantity := 0;
    end;

    local procedure EmitEntry(AdmissionScheduleEntryNo: Integer; NetQuantity: Decimal)
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        AdmissionScheduleLine: Record "NPR TM Admis. Schedule Lines";
        NotifyAtRemainingQty: Integer;
        MaxCapacity: Integer;
        RemainingCapacity: Integer;
        CapacityControl: Option;
        IsWithinNotifyQty: Boolean;
        WasWithinNotifyQty: Boolean;
    begin
        if (NetQuantity = 0) then
            exit;

        if (not AdmissionScheduleEntry.Get(AdmissionScheduleEntryNo)) then
            exit;

        // The line always holds the effective value: SyncAdmissionSettings / SyncScheduleSettings push it down
        // in the ADMISSION and SCHEDULE modes, and in OVERRIDE the line is itself the source.
        if (not AdmissionScheduleLine.Get(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code")) then
            exit;

        NotifyAtRemainingQty := AdmissionScheduleLine."Notify At Remaining Qty.";
        if (NotifyAtRemainingQty <= 0) then
            exit;

        if (not TryResolveCapacity(AdmissionScheduleEntry, MaxCapacity, RemainingCapacity, CapacityControl)) then begin
            ClearLastError();
            exit;
        end;

        if (MaxCapacity <= 0) then
            exit;

        // Slots outside the notify quantity stay silent, except for the change that lifts one back out of it -
        // without that, a consumer told "3 left" never learns the capacity came back above the notify quantity.
        IsWithinNotifyQty := (RemainingCapacity <= NotifyAtRemainingQty);
        WasWithinNotifyQty := ((RemainingCapacity + NetQuantity) <= NotifyAtRemainingQty);
        if (not IsWithinNotifyQty) and (not WasWithinNotifyQty) then
            exit;

        // Stamped at the read, not at dispatch - the gap to the event's own timestamp is how stale the count is.
        EmitCapacity(AdmissionScheduleEntry, CapacityControl, MaxCapacity, RemainingCapacity, CurrentDateTime());
    end;

    [TryFunction]
    local procedure TryResolveCapacity(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; var MaxCapacity: Integer; var RemainingCapacity: Integer; var CapacityControl: Option)
    var
        Admission: Record "NPR TM Admission";
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        Clear(MaxCapacity);
        Clear(RemainingCapacity);
        Clear(CapacityControl);

        if (not TicketManagement.GetAdmissionCapacity(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", AdmissionScheduleEntry."Entry No.", MaxCapacity, CapacityControl)) then begin
            Clear(MaxCapacity);
            exit;
        end;

        if (CapacityControl <> Admission."Capacity Control"::SALES) then begin
            Clear(MaxCapacity);
            exit;
        end;

        RemainingCapacity := MaxCapacity - TicketManagement.CalculateCurrentCapacity(CapacityControl, AdmissionScheduleEntry."Entry No.");
        if (RemainingCapacity < 0) then
            RemainingCapacity := 0;
    end;

    local procedure EmitCapacity(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; CapacityControl: Option; MaxCapacity: Integer; RemainingCapacity: Integer; CapacityAsOf: DateTime)
    var
        TicketWebhooks: Codeunit "NPR TM Ticket Webhooks";
        EnumEncoder: Codeunit "NPR TicketingApiTranslations";
    begin
        TicketWebhooks.CapacityChanged(
            AdmissionScheduleEntry."External Schedule Entry No.",
            AdmissionScheduleEntry."Admission Code",
            AdmissionScheduleEntry."Schedule Code",
            AdmissionScheduleEntry."Admission Start Date",
            AdmissionScheduleEntry."Admission Start Time",
            CopyStr(EnumEncoder.EncodeCapacity(CapacityControl), 1, 20),
            MaxCapacity,
            RemainingCapacity,
            CapacityAsOf);

        TicketWebhooks.NotifyCapacityChanged(AdmissionScheduleEntry, RemainingCapacity, CapacityAsOf);
    end;
}
