codeunit 6151172 "NPR Spfy Legacy Return Proc JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ProcessQueue(Rec);
    end;

    var
        _SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        _ReportedToSentry: List of [Text];
        _MaxRunDuration: Duration;
        _ClaimStaleBefore: DateTime;

    internal procedure ProcessQueue(JobQueueEntry: Record "Job Queue Entry")
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StartedAt: DateTime;
    begin
        // The Ecommerce engine owns returns while its feature is on; a job entry recreated in a refresh race must not import.
        if ShopifyEcommOrderExp.IsFeatureEnabled() then
            exit;
        StartedAt := CurrentDateTime();
        _MaxRunDuration := 15 * 60 * 1000;
        _ClaimStaleBefore := StaleBefore(JobQueueEntry);
        QueueRow.SetCurrentKey(Status);
        QueueRow.SetRange(Status, QueueRow.Status::New);
        ProcessRows(QueueRow, StartedAt, 0, 0DT);
        QueueRow.SetRange(Status, QueueRow.Status::Error);
        ProcessRows(QueueRow, StartedAt, MaxRetryCount(), 0DT);
        QueueRow.SetRange(Status, QueueRow.Status::Processing);
        ProcessRows(QueueRow, StartedAt, 0, _ClaimStaleBefore);
        // A waiting row is looked at on every run and never counted. It calls Shopify only when BC alone cannot tell whether the wait is over: a pending refund transaction, an order not in BC yet, or an order without an invoice whose Sales Order has nothing to post, which waits only if Shopify shipped it.
        QueueRow.SetRange(Status, QueueRow.Status::Waiting);
        ProcessRows(QueueRow, StartedAt, 0, 0DT);
    end;

    local procedure ProcessRows(var QueueRowFilter: Record "NPR Spfy NC Return Queue"; StartedAt: DateTime; RetryCountLimit: Integer; StaleBeforeParam: DateTime)
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        TempQueueRow: Record "NPR Spfy NC Return Queue" temporary;
    begin
        if CurrentDateTime() - StartedAt > _MaxRunDuration then
            exit;
        // Snapshot first: ProcessRow changes Status, the filtered field.
        if QueueRowFilter.FindSet() then
            repeat
                TempQueueRow := QueueRowFilter;
                TempQueueRow.Insert();
            until QueueRowFilter.Next() = 0;
        if not TempQueueRow.FindSet() then
            exit;
        repeat
            if CurrentDateTime() - StartedAt > _MaxRunDuration then
                exit;
            if QueueRow.Get(TempQueueRow."Entry No.") then
                if _SpfyLegacyReturnMgt.MarkImportedIfCreditMemoPosted(QueueRow) then
                    Commit()
                else
                    if QueueRow."Processed At" < StartedAt then
                        if (RetryCountLimit = 0) or (QueueRow."Retry Count" < RetryCountLimit) then
                            if (StaleBeforeParam = 0DT) or (QueueRow."Processed At" < StaleBeforeParam) then
                                // Rows of a store whose return import was switched off wait at their status until it is switched on again.
                                if not _SpfyLegacyReturnMgt.ReturnsSwitchedOff(QueueRow."Shopify Store Code") then begin
                                    // The setup lock comes before any row lock, in every path, so a page action and the job cannot wait on each other.
                                    if _SpfyLegacyReturnMgt.FeatureSwitchedOn() then
                                        exit;
                                    if StaleBeforeParam = 0DT then begin
                                        if ProcessRow(QueueRow) then;
                                    end else
                                        if CountLostAttempt(QueueRow) then
                                            if ProcessRow(QueueRow) then;
                                    Commit();
                                end;
        until TempQueueRow.Next() = 0;
    end;

    /// <summary>
    /// The job's own stale rule, so the claim and the pass that selected the row agree; a page action has no job entry and uses the registered interval.
    /// </summary>
    local procedure IsHeldByAnotherSession(QueueRow: Record "NPR Spfy NC Return Queue"): Boolean
    begin
        if _ClaimStaleBefore = 0DT then
            exit(_SpfyLegacyReturnMgt.IsBeingProcessed(QueueRow));
        exit((QueueRow.Status = QueueRow.Status::Processing) and (QueueRow."Processed At" >= _ClaimStaleBefore));
    end;

    /// <summary>
    /// A stale Processing row counts as a lost attempt; at the retry limit the row ends at Error instead of being picked up forever.
    /// </summary>
    local procedure CountLostAttempt(var QueueRow: Record "NPR Spfy NC Return Queue"): Boolean
    var
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        AttemptLostErr: Label 'The last attempt to import Shopify %1 did not finish and its session was lost. The retry limit of %2 is reached, so it is not attempted again.', Comment = '%1 = Shopify document caption, %2 = retry limit';
    begin
        // Re-read under a lock: a page action may have claimed the row since the snapshot, and a blind Modify would collide with it.
        QueueRow.LockTable();
        if not QueueRow.Get(QueueRow."Entry No.") then
            exit(false);
        if (QueueRow.Status <> QueueRow.Status::Processing) or (QueueRow."Processed At" >= _ClaimStaleBefore) then
            exit(false);
        QueueRow."Retry Count" += 1;
        if QueueRow."Retry Count" < MaxRetryCount() then begin
            QueueRow.Modify();
            exit(true);
        end;
        QueueRow.Validate(Status, QueueRow.Status::Error);
        QueueRow."Last Error" := CopyStr(StrSubstNo(AttemptLostErr, SpfyLegacyReturnAPI.DocumentCaption(QueueRow."Source Doc. Type", QueueRow."Source Doc. Name", QueueRow."Source Doc. ID"), MaxRetryCount()), 1, MaxStrLen(QueueRow."Last Error"));
        QueueRow."Processed At" := CurrentDateTime();
        QueueRow.Modify();
        exit(false);
    end;

    /// <summary>
    /// Claims and imports the row; false when the feature was switched on or the row could not be claimed, so a page action can say so.
    /// </summary>
    internal procedure ProcessRow(var QueueRow: Record "NPR Spfy NC Return Queue"): Boolean
    var
        ErrorText: Text;
        Succeeded: Boolean;
        Posted: Boolean;
    begin
        // The feature may have been switched on during a run; read under the switch's lock, so a claim and the switch never both pass.
        if _SpfyLegacyReturnMgt.FeatureSwitchedOn() then
            exit(false);
        // Claim under a lock: a page action and the job may both have passed their guard, or the row may be gone.
        // Get, not Find: the page hands over its filtered record, and Find would honour a filter the claim moves the row out of.
        QueueRow.LockTable();
        if not QueueRow.Get(QueueRow."Entry No.") then
            exit(false);
        if QueueRow.Status in [QueueRow.Status::Dismissed, QueueRow.Status::Imported, QueueRow.Status::"Nothing to Credit"] then
            exit(false);
        if IsHeldByAnotherSession(QueueRow) then
            exit(false);
        QueueRow.Validate(Status, QueueRow.Status::Processing);
        QueueRow."Processed At" := CurrentDateTime();
        QueueRow.Modify();
        Commit();

        ClearLastError();
        Succeeded := Codeunit.Run(Codeunit::"NPR Spfy Legacy Return Import", QueueRow);
        if not Succeeded then
            ErrorText := GetLastErrorText();
        if not QueueRow.Get(QueueRow."Entry No.") then
            exit(true);
        // An error raised after Sales-Post committed still leaves a posted, settled credit memo; a bug behind it is still reported.
        Posted := _SpfyLegacyReturnMgt.IsCreditMemoPosted(QueueRow);
        if Succeeded and (QueueRow.Status in [QueueRow.Status::Waiting, QueueRow.Status::"Nothing to Credit"]) then begin
            QueueRow."Retry Count" := 0;
            QueueRow."Last Error" := '';
        end else
            if Succeeded or Posted then begin
                if not Succeeded then
                    EmitSentryError(QueueRow);
                if Posted then
                    QueueRow.Validate(Status, QueueRow.Status::Imported)
                else
                    QueueRow.Validate(Status, QueueRow.Status::"Draft Created");
                QueueRow."Last Error" := '';
                // A successful attempt gives a draft posted later by hand a full retry budget again.
                QueueRow."Retry Count" := 0;
            end else begin
                QueueRow.Validate(Status, QueueRow.Status::Error);
                QueueRow."Retry Count" += 1;
                QueueRow."Last Error" := CopyStr(ErrorText, 1, MaxStrLen(QueueRow."Last Error"));
                if QueueRow."Retry Count" >= MaxRetryCount() then
                    EmitSentryError(QueueRow);
            end;
        QueueRow."Processed At" := CurrentDateTime();
        QueueRow.Modify();
        exit(true);
    end;

    local procedure MaxRetryCount(): Integer
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        if not SpfyIntegrationSetup.Get() then
            exit(5);
        if SpfyIntegrationSetup."Max Doc Process Retry Count" <= 0 then
            exit(5);
        exit(SpfyIntegrationSetup."Max Doc Process Retry Count");
    end;

    local procedure StaleBefore(JobQueueEntry: Record "Job Queue Entry"): DateTime
    begin
        exit(_SpfyLegacyReturnMgt.StaleBefore(JobQueueEntry."No. of Minutes between Runs"));
    end;

    local procedure EmitSentryError(QueueRow: Record "NPR Spfy NC Return Queue")
    var
        TransactionNameLbl: Label 'Shopify legacy return import failed: %1', Comment = '%1 = Shopify store code', Locked = true;
        ReportKey: Text;
    begin
        // One report per store and error site per run; the error text names the return and cannot be the key.
        ReportKey := QueueRow."Shopify Store Code" + '|' + CopyStr(GetLastErrorCallStack(), 1, 250);
        if ReportKey.EndsWith('|') then
            ReportKey += CopyStr(QueueRow."Last Error", 1, 250);
        if _ReportedToSentry.Contains(ReportKey) then
            exit;
        // The key is recorded only after a report, so a harmless failure at the same site never hides a later bug.
        if _SpfyLegacyReturnMgt.ReportProgrammingBugToSentry(QueueRow."Shopify Store Code", QueueRow."Source Doc. ID", StrSubstNo(TransactionNameLbl, QueueRow."Shopify Store Code"), 'bc.shopify.legacyreturn.process.error') then
            _ReportedToSentry.Add(ReportKey);
    end;
}
