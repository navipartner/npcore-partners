codeunit 6151164 "NPR UPG Member Chg Log GDPR"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Member Chg Log GDPR', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Member Chg Log GDPR")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DeleteChangeLogForAnonymizedMembers();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Member Chg Log GDPR"));

        LogMessageStopwatch.LogFinish();
    end;

    // Members anonymized - or deleted while database triggers were disabled - before the change log became part of the
    // anonymization process still hold their pre-anonymization values in "Old Value"/"New Value". Walk the log one member
    // at a time and purge the rows of members that are anonymized or no longer exist; active members keep their history.
    // Committing between batches keeps this one-time cleanup out of a single long transaction (SaaS limits).
    internal procedure DeleteChangeLogForAnonymizedMembers()
    var
        Member: Record "NPR MM Member";
        MemberChangeLog: Record "NPR MM Member Change Log";
        MemberChangeLogMgt: Codeunit "NPR MM Member Change Log Mgt";
        BatchSize: Integer;
        DeletedInBatch: Integer;
        MemberEntryNo: Integer;
    begin
        BatchSize := 1000;

        MemberChangeLog.SetCurrentKey("Member Entry No.");
        MemberChangeLog.SetLoadFields("Member Entry No.");
        while (MemberChangeLog.FindFirst()) do begin
            MemberEntryNo := MemberChangeLog."Member Entry No.";

            if ((not Member.Get(MemberEntryNo)) or (Member.Blocked and (Member."Block Reason" = Member."Block Reason"::ANONYMIZED))) then
                DeletedInBatch += MemberChangeLogMgt.DeleteMemberChangeLogForMember(MemberEntryNo);

            if (DeletedInBatch >= BatchSize) then begin
                Commit();
                DeletedInBatch := 0;
            end;

            // Skip past the member just handled so the next FindFirst lands on the next one.
            MemberChangeLog.SetFilter("Member Entry No.", '>%1', MemberEntryNo);
        end;
    end;
}
