codeunit 6151215 "NPR Spfy Deletion Log Mgt"
{
    Access = Internal;

    var
        CancelledByReactivationTxt: Label 'Cancelled: the entity was reactivated in Business Central before the delete was sent to Shopify.';

    procedure LogDelete(EntityTableNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; CustomerNo: Code[20]; RecordIdParam: RecordId; SystemId: Guid; StoreCode: Code[20]; ShopifyIdType: Enum "NPR Spfy ID Type"; ShopifyId: Text[30])
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
    begin
        if ShopifyId = '' then
            exit;

        DeletionLog.SetCurrentKey("Table No.", "Shopify ID Type", "Shopify ID", "Shopify Store Code", Status);
        DeletionLog.SetRange("Table No.", EntityTableNo);
        DeletionLog.SetRange("Shopify ID Type", ShopifyIdType);
        DeletionLog.SetRange("Shopify ID", ShopifyId);
        DeletionLog.SetRange("Shopify Store Code", StoreCode);
        DeletionLog.SetRange(Status, DeletionLog.Status::Pending);
        if not DeletionLog.IsEmpty() then
            exit;

        DeletionLog.Init();
        DeletionLog."Table No." := EntityTableNo;
        DeletionLog."Item No." := ItemNo;
        DeletionLog."Variant Code" := VariantCode;
        DeletionLog."Customer No." := CustomerNo;
        DeletionLog."Record ID" := RecordIdParam;
        DeletionLog."Entity System Id" := SystemId;
        DeletionLog."Shopify Store Code" := StoreCode;
        DeletionLog."Shopify ID Type" := ShopifyIdType;
        DeletionLog."Shopify ID" := ShopifyId;
        DeletionLog.Status := DeletionLog.Status::Pending;
        DeletionLog.Insert(true);
    end;

    // Cancels by entity identity: the id the intent was captured with may already be cleared or reassigned.
    procedure CancelDeleteForEntity(EntityTableNo: Integer; StoreCode: Code[20]; EntitySystemId: Guid)
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
    begin
        if IsNullGuid(EntitySystemId) then
            exit;

        DeletionLog.SetCurrentKey("Table No.", "Entity System Id", "Shopify Store Code", Status);
        DeletionLog.SetRange("Table No.", EntityTableNo);
        DeletionLog.SetRange("Entity System Id", EntitySystemId);
        DeletionLog.SetRange("Shopify Store Code", StoreCode);
        DeletionLog.SetFilter(Status, '%1|%2|%3', DeletionLog.Status::Pending, DeletionLog.Status::Processed, DeletionLog.Status::Quarantined);
        DeletionLog.ReadIsolation := IsolationLevel::UpdLock;
        if not DeletionLog.FindSet(true) then
            exit;
        repeat
            CancelRow(DeletionLog);
        until DeletionLog.Next() = 0;
    end;

    // Same predicate as HasOutstandingDelete, keyed by entity: everything CancelDeleteForEntity would actually cancel.
    procedure HasOutstandingDeleteForEntity(EntityTableNo: Integer; StoreCode: Code[20]; EntitySystemId: Guid): Boolean
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        NcTask: Record "NPR Nc Task";
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
    begin
        if IsNullGuid(EntitySystemId) then
            exit(false);

        DeletionLog.SetCurrentKey("Table No.", "Entity System Id", "Shopify Store Code", Status);
        DeletionLog.SetRange("Table No.", EntityTableNo);
        DeletionLog.SetRange("Entity System Id", EntitySystemId);
        DeletionLog.SetRange("Shopify Store Code", StoreCode);
        DeletionLog.SetRange(Status, DeletionLog.Status::Pending);
        if not DeletionLog.IsEmpty() then
            exit(true);
        DeletionLog.SetRange(Status, DeletionLog.Status::Quarantined);
        if not DeletionLog.IsEmpty() then
            exit(true);
        DeletionLog.SetRange(Status, DeletionLog.Status::Processed);
        DeletionLog.SetLoadFields("NC Task Entry No.", "Spfy Task Entry No.");
        NcTask.SetLoadFields(Processed);
        if DeletionLog.FindSet() then
            repeat
                if DeletionLog."NC Task Entry No." <> 0 then begin
                    if NcTask.Get(DeletionLog."NC Task Entry No.") then
                        if not NcTask.Processed then
                            exit(true);
                end else
                    if DeletionLog."Spfy Task Entry No." <> 0 then
                        if SpfyTaskQueue.TaskIsUnprocessed(DeletionLog."Spfy Task Entry No.") then
                            exit(true);
            until DeletionLog.Next() = 0;
        exit(false);
    end;

    local procedure CancelRow(var DeletionLog: Record "NPR Spfy Deletion Log")
    begin
        case DeletionLog.Status of
            DeletionLog.Status::Pending, DeletionLog.Status::Quarantined:
                begin
                    DeletionLog.Status := DeletionLog.Status::Cancelled;
                    DeletionLog.Modify(true);
                end;
            DeletionLog.Status::Processed:
                if CancelOutstandingTask(DeletionLog) then begin
                    DeletionLog.Status := DeletionLog.Status::Cancelled;
                    DeletionLog.Modify(true);
                end;
        end;
    end;

    // True while a delete intent still needs sending: Pending or Quarantined, or Processed with a task that has not run yet.
    procedure HasOutstandingDelete(EntityTableNo: Integer; StoreCode: Code[20]; ShopifyIdType: Enum "NPR Spfy ID Type"; ShopifyId: Text[30]): Boolean
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        NcTask: Record "NPR Nc Task";
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
    begin
        if ShopifyId = '' then
            exit(false);
        DeletionLog.SetCurrentKey("Table No.", "Shopify ID Type", "Shopify ID", "Shopify Store Code", Status);
        DeletionLog.SetRange("Table No.", EntityTableNo);
        DeletionLog.SetRange("Shopify ID Type", ShopifyIdType);
        DeletionLog.SetRange("Shopify ID", ShopifyId);
        DeletionLog.SetRange("Shopify Store Code", StoreCode);
        DeletionLog.SetRange(Status, DeletionLog.Status::Pending);
        if not DeletionLog.IsEmpty() then
            exit(true);
        DeletionLog.SetRange(Status, DeletionLog.Status::Quarantined);
        if not DeletionLog.IsEmpty() then
            exit(true);
        DeletionLog.SetRange(Status, DeletionLog.Status::Processed);
        DeletionLog.SetLoadFields("NC Task Entry No.", "Spfy Task Entry No.");
        NcTask.SetLoadFields(Processed);
        if DeletionLog.FindSet() then
            repeat
                if DeletionLog."NC Task Entry No." <> 0 then begin
                    if NcTask.Get(DeletionLog."NC Task Entry No.") then
                        if not NcTask.Processed then
                            exit(true);
                end else
                    if DeletionLog."Spfy Task Entry No." <> 0 then
                        if SpfyTaskQueue.TaskIsUnprocessed(DeletionLog."Spfy Task Entry No.") then
                            exit(true);
            until DeletionLog.Next() = 0;
        exit(false);
    end;

    procedure MarkProcessed(EntryNo: BigInteger; TaskEntryNo: BigInteger)
    begin
        MarkProcessed(EntryNo, TaskEntryNo, "NPR Spfy Task Dest Queue"::"Nc Task");
    end;

    procedure MarkProcessed(EntryNo: BigInteger; TaskEntryNo: BigInteger; TaskQueue: Enum "NPR Spfy Task Dest Queue")
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
    begin
        if not DeletionLog.Get(EntryNo) then
            exit;
        if DeletionLog.Status <> DeletionLog.Status::Pending then
            exit;
        DeletionLog.Status := DeletionLog.Status::Processed;
        // Exactly one of the two entry-no fields is ever set: it is the queue discriminator the cancel path follows.
        case TaskQueue of
            "NPR Spfy Task Dest Queue"::"Nc Task":
                DeletionLog."NC Task Entry No." := TaskEntryNo;
            "NPR Spfy Task Dest Queue"::"Spfy Task":
                DeletionLog."Spfy Task Entry No." := TaskEntryNo;
        end;
        DeletionLog.Modify(true);
    end;

    // These three lock the deletion log BEFORE the task, matching CancelDelete; their row helpers stay local to enforce it.
    procedure CloseTaskAndCancelDelete(SpfyTaskEntryNo: BigInteger; CancellationReasonTxt: Text): Boolean
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        HasLockedRows: Boolean;
    begin
        HasLockedRows := LockDeleteRowsInStatus(SpfyTaskEntryNo, true, DeletionLog);
        if not SpfyTaskQueue.CancelUnsentTask(SpfyTaskEntryNo, CancellationReasonTxt) then
            exit(false);
        if HasLockedRows then
            CancelDeleteForClosedTask(DeletionLog);
        exit(true);
    end;

    procedure ReopenTaskAndRestoreDelete(var SpfyTask: Record "NPR Spfy Task"): Boolean
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        HasLockedRows: Boolean;
    begin
        HasLockedRows := LockDeleteRowsInStatus(SpfyTask."Entry No.", false, DeletionLog);
        if not SpfyTaskQueue.Resend(SpfyTask) then
            exit(false);
        if HasLockedRows then
            RestoreDeleteForReopenedTask(DeletionLog);
        exit(true);
    end;

    procedure DeleteTaskAndCancelDelete(SpfyTaskEntryNo: BigInteger): Boolean
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyTask: Record "NPR Spfy Task";
        HasLockedRows: Boolean;
    begin
        HasLockedRows := LockDeleteRowsInStatus(SpfyTaskEntryNo, true, DeletionLog);
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTaskEntryNo) then
            exit(false);
        if SpfyTask.State = SpfyTask.State::"In Flight" then
            exit(false);

        // The entry number is unrecoverable after the delete, so an unsent delete intent has to be cancelled first.
        if HasLockedRows and (SpfyTask.Type = SpfyTask.Type::Delete) and (SpfyTask.State <> SpfyTask.State::Completed) then
            CancelDeleteForClosedTask(DeletionLog);
        SpfyTask.Delete(true);
        exit(true);
    end;

    local procedure LockDeleteRowsInStatus(SpfyTaskEntryNo: BigInteger; ProcessedRows: Boolean; var DeletionLog: Record "NPR Spfy Deletion Log"): Boolean
    begin
        if SpfyTaskEntryNo = 0 then
            exit(false);
        DeletionLog.SetRange("Spfy Task Entry No.", SpfyTaskEntryNo);
        if ProcessedRows then
            DeletionLog.SetRange(Status, DeletionLog.Status::Processed)
        else
            DeletionLog.SetRange(Status, DeletionLog.Status::Cancelled);
        DeletionLog.ReadIsolation := IsolationLevel::UpdLock;
        exit(DeletionLog.FindSet(true));
    end;

    // Abandoning the task unsent kills the intent with it; a retention purge of a sent task must NOT route here.
    local procedure CancelDeleteForClosedTask(var DeletionLog: Record "NPR Spfy Deletion Log")
    begin
        repeat
            DeletionLog.Status := DeletionLog.Status::Cancelled;
            DeletionLog.Modify(true);
        until DeletionLog.Next() = 0;
    end;

    // Reopening puts the intent back in play. Processed, not Pending: Pending would have the drain build a second task.
    local procedure RestoreDeleteForReopenedTask(var DeletionLog: Record "NPR Spfy Deletion Log")
    begin
        repeat
            DeletionLog.Status := DeletionLog.Status::Processed;
            DeletionLog.Modify(true);
        until DeletionLog.Next() = 0;
    end;

    procedure RecordDrainFailure(EntryNo: BigInteger; ErrorText: Text; CallStack: Text)
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        Sentry: Codeunit "NPR Sentry";
        QuarantinedDeleteLbl: Label 'Shopify deletion log entry %1 was quarantined after %2 consecutive dispatch failures; the remote delete will not be sent until the entry is requeued from the Shopify Deletion Log page. Table %3, Shopify ID %4, store %5. Last error: %6 This is a programming bug.', Locked = true;
    begin
        DeletionLog.ReadIsolation(IsolationLevel::UpdLock);
        if not DeletionLog.Get(EntryNo) then
            exit;
        if DeletionLog.Status <> DeletionLog.Status::Pending then
            exit;
        DeletionLog."Dispatch Failure Count" += 1;
        if DeletionLog."Dispatch Failure Count" >= SpfyChangeTrackerMgt.QuarantineThreshold() then begin
            DeletionLog.Status := DeletionLog.Status::Quarantined;
            Sentry.InitScopeAndTransaction('Shopify delete quarantine', 'bc.spfy.change_detection.delete_quarantine');
            Sentry.AddError(StrSubstNo(QuarantinedDeleteLbl, DeletionLog."Entry No.", SpfyChangeTrackerMgt.QuarantineThreshold(), DeletionLog."Table No.", DeletionLog."Shopify ID", DeletionLog."Shopify Store Code", ErrorText), CallStack);
            Sentry.FinalizeScope();
        end;
        DeletionLog.Modify(true);
    end;

    procedure ClearDrainFailure(EntryNo: BigInteger)
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
    begin
        DeletionLog.ReadIsolation(IsolationLevel::UpdLock);
        if not DeletionLog.Get(EntryNo) then
            exit;
        if DeletionLog.Status <> DeletionLog.Status::Pending then
            exit;
        if DeletionLog."Dispatch Failure Count" = 0 then
            exit;
        DeletionLog."Dispatch Failure Count" := 0;
        DeletionLog.Modify(true);
    end;

    procedure Requeue(var DeletionLog: Record "NPR Spfy Deletion Log"): Boolean
    begin
        DeletionLog.ReadIsolation(IsolationLevel::UpdLock);
        if not DeletionLog.Get(DeletionLog."Entry No.") then
            exit(false);
        if DeletionLog.Status <> DeletionLog.Status::Quarantined then
            exit(false);

        DeletionLog.Status := DeletionLog.Status::Pending;
        DeletionLog."Dispatch Failure Count" := 0;
        DeletionLog.Modify(true);
        exit(true);
    end;

    local procedure CancelOutstandingTask(DeletionLog: Record "NPR Spfy Deletion Log"): Boolean
    var
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
    begin
        if DeletionLog."NC Task Entry No." <> 0 then
            exit(CancelOutstandingNcTask(DeletionLog."NC Task Entry No."));
        if DeletionLog."Spfy Task Entry No." <> 0 then
            exit(SpfyTaskQueue.CancelUnsentTask(DeletionLog."Spfy Task Entry No.", CancelledByReactivationTxt));
        exit(false);
    end;

    local procedure CancelOutstandingNcTask(NcTaskEntryNo: BigInteger): Boolean
    var
        NcTask: Record "NPR Nc Task";
        OutStr: OutStream;
    begin
        if NcTaskEntryNo = 0 then
            exit(false);
        if not NcTask.Get(NcTaskEntryNo) then
            exit(false);
        if NcTask.Processed then
            exit(false);

        NcTask.Processed := true;
        NcTask."Process Error" := false;
        NcTask."Last Processing Started at" := 0DT;
        NcTask."Last Processing Completed at" := CurrentDateTime();
        NcTask."Last Processing Duration" := 0;
        NcTask.Response.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(CancelledByReactivationTxt);
        NcTask.Modify();
        exit(true);
    end;
}
