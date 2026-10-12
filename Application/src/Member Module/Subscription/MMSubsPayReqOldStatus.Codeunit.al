codeunit 6151312 "NPR MM Subs PayReq Old Status"
{
    // Carries the on-disk status of a payment request from OnBeforeModifyEvent to OnAfterModifyEvent without touching xRec.
    // One stack per entry, so a nested modify of the same row takes its own status, not the outer one's.
    Access = Internal;
    SingleInstance = true;

    var
        _OldStatusesByEntryNo: Dictionary of [BigInteger, List of [Integer]];

    internal procedure Remember(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        CurrentSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        OldStatuses: List of [Integer];
    begin
        CurrentSubscrPaymentRequest.ReadIsolation := IsolationLevel::ReadCommitted;
        CurrentSubscrPaymentRequest.SetLoadFields(Status);
        if not CurrentSubscrPaymentRequest.Get(SubscrPaymentRequest."Entry No.") then
            exit;
        if not _OldStatusesByEntryNo.Get(SubscrPaymentRequest."Entry No.", OldStatuses) then begin
            _OldStatusesByEntryNo.Add(SubscrPaymentRequest."Entry No.", OldStatuses);
            _OldStatusesByEntryNo.Get(SubscrPaymentRequest."Entry No.", OldStatuses);
        end;
        OldStatuses.Add(CurrentSubscrPaymentRequest.Status.AsInteger());
    end;

    /// <summary>Hands out the status remembered most recently for the entry and forgets it. False when nothing was remembered.</summary>
    internal procedure Take(EntryNo: BigInteger; var OldStatus: Enum "NPR MM Payment Request Status"): Boolean
    var
        OldStatuses: List of [Integer];
        OldStatusValue: Integer;
    begin
        if not _OldStatusesByEntryNo.Get(EntryNo, OldStatuses) then
            exit(false);
        if OldStatuses.Count() = 0 then
            exit(false);
        OldStatusValue := OldStatuses.Get(OldStatuses.Count());
        OldStatuses.RemoveAt(OldStatuses.Count());
        if OldStatuses.Count() = 0 then
            _OldStatusesByEntryNo.Remove(EntryNo);
        OldStatus := Enum::"NPR MM Payment Request Status".FromInteger(OldStatusValue);
        exit(true);
    end;
}
