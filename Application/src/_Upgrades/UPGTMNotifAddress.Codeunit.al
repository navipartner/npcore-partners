codeunit 6151099 "NPR UPG TM Notif Address"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        _UpgradeTag: Codeunit "Upgrade Tag";
        _UpgradeTagDef: Codeunit "NPR Upgrade Tag Definitions";
        _UpgradeStep: Text;
        _LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";

    trigger OnUpgradePerCompany()
    begin
        LowercaseEmailNotifAddress();
    end;

    // Backfill existing NPR TM Ticket Reservation Req. rows so the Notification Address column carries
    // lowercase emails. Pairs with the runtime normalization helper added on the table and the writer
    // changes that now route through it. Phones (no '@') are untouched. Re-runs are idempotent because
    // already-lowercased rows compare equal to their normalized form and skip the Modify.
    local procedure LowercaseEmailNotifAddress()
    var
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Normalized: Text[100];
        BatchSize: Integer;
        ProcessedInBatch: Integer;
        LastEntryNo: Integer;
    begin
        _UpgradeStep := 'LowercaseEmailNotifAddress';
        if HasUpgradeTag() then
            exit;

        BatchSize := 1000;
        LastEntryNo := 0;

        // Iterate over the PK in batches of BatchSize, committing between batches so a single
        // long-running transaction does not block other users or hit SaaS transaction limits.
        repeat
            ProcessedInBatch := 0;
            ReservationRequest.Reset();
            ReservationRequest.SetCurrentKey("Entry No.");
            ReservationRequest.SetFilter("Entry No.", '>%1', LastEntryNo);
            ReservationRequest.SetFilter("Notification Address", '*@*');
            if ReservationRequest.FindSet(true) then begin
                repeat
                    Normalized := ReservationRequest.NormalizeNotificationAddress(ReservationRequest."Notification Address");
                    if Normalized <> ReservationRequest."Notification Address" then begin
                        ReservationRequest."Notification Address" := Normalized;
                        ReservationRequest.Modify(false);
                    end;
                    LastEntryNo := ReservationRequest."Entry No.";
                    ProcessedInBatch += 1;
                until (ReservationRequest.Next() = 0) or (ProcessedInBatch >= BatchSize);
                Commit();
            end;
        until ProcessedInBatch < BatchSize;

        SetUpgradeTag();
    end;

    local procedure HasUpgradeTag(): Boolean
    begin
        if (_UpgradeTag.HasUpgradeTag(_UpgradeTagDef.GetUpgradeTag(Codeunit::"NPR UPG TM Notif Address", _UpgradeStep))) then
            exit(true);
        _LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG TM Notif Address', _UpgradeStep);
        exit(false);
    end;

    local procedure SetUpgradeTag()
    begin
        _UpgradeTag.SetUpgradeTag(_UpgradeTagDef.GetUpgradeTag(Codeunit::"NPR UPG TM Notif Address", _UpgradeStep));
        _LogMessageStopwatch.LogFinish();
    end;
}
