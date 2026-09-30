codeunit 6151219 "NPR Change Tracker Mgt"
{
    Access = Internal;

    procedure RegisterTable(IntegrationType: Enum "NPR Integration Type"; TableNo: Integer)
    begin
        RegisterTable(IntegrationType, TableNo, 0);
    end;

    procedure RegisterTable(IntegrationType: Enum "NPR Integration Type"; TableNo: Integer; ProcessingOrder: Integer)
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        if ChangeTracker.Get(IntegrationType, TableNo) then begin
            if ChangeTracker."Processing Order" <> ProcessingOrder then begin
                ChangeTracker."Processing Order" := ProcessingOrder;
                ChangeTracker.Modify(true);
            end;
            exit;
        end;
        EnsureTracker(IntegrationType, TableNo, ChangeTracker);
        ChangeTracker."Processing Order" := ProcessingOrder;
        // Seed at the boundary, not the table max: everything at or below it is committed, and no row of this
        // table lies between its own max and the boundary, so both scan the same rows - without a source read.
        SeedToCurrentMax(ChangeTracker, CommittedBoundary());
    end;

    procedure EnsureTracker(IntegrationType: Enum "NPR Integration Type"; TableNo: Integer; var ChangeTracker: Record "NPR Change Tracker")
    begin
        if ChangeTracker.Get(IntegrationType, TableNo) then
            exit;
        ChangeTracker.Init();
        ChangeTracker."Integration Type" := IntegrationType;
        ChangeTracker."Table No." := TableNo;
        ChangeTracker.Insert(true);
    end;

    procedure AdvanceMark(var ChangeTracker: Record "NPR Change Tracker"; NewMaxRowVersion: BigInteger): Boolean
    var
        FreshTracker: Record "NPR Change Tracker";
    begin
        // Re-Get under UpdLock: the caller's in-memory row goes stale once its per-row Commit released the lock.
        FreshTracker.ReadIsolation(IsolationLevel::UpdLock);
        if not FreshTracker.Get(ChangeTracker."Integration Type", ChangeTracker."Table No.") then
            exit(false);
        // A concurrent lowering (reset/re-sync) must win: advancing past it would discard the forced re-scan.
        // FreshTracker is deliberately not copied back — the caller's stale high mark keeps repeat calls false.
        if FreshTracker."Last Row Version" < ChangeTracker."Last Row Version" then
            exit(false);
        if NewMaxRowVersion > FreshTracker."Last Row Version" then begin
            FreshTracker."Last Row Version" := NewMaxRowVersion;
            FreshTracker.Modify(true);
        end;
        ChangeTracker := FreshTracker;
        exit(true);
    end;

    procedure RecordRowFailure(var ChangeTracker: Record "NPR Change Tracker"; FailingRowVersion: BigInteger; var Lowered: Boolean): Integer
    var
        FreshTracker: Record "NPR Change Tracker";
    begin
        Lowered := false;
        FreshTracker.ReadIsolation(IsolationLevel::UpdLock);
        if not FreshTracker.Get(ChangeTracker."Integration Type", ChangeTracker."Table No.") then
            exit(0);
        // A concurrent lowering (reset/re-sync) wins: recording a strike would cement state the re-sync just cleared.
        // The lowered tracker is deliberately not copied back (same contract as AdvanceMark).
        if FreshTracker."Last Row Version" < ChangeTracker."Last Row Version" then begin
            Lowered := true;
            exit(0);
        end;
        // A modified poison row gets a new rowversion -> the streak restarts (the row changed, it may dispatch now).
        if FreshTracker."Failing Row Version" = FailingRowVersion then
            FreshTracker."Consecutive Failures" += 1
        else begin
            FreshTracker."Failing Row Version" := FailingRowVersion;
            FreshTracker."Consecutive Failures" := 1;
        end;
        FreshTracker.Modify(true);
        ChangeTracker := FreshTracker;
        exit(FreshTracker."Consecutive Failures");
    end;

    procedure ClearRowFailure(var ChangeTracker: Record "NPR Change Tracker")
    var
        FreshTracker: Record "NPR Change Tracker";
    begin
        FreshTracker.ReadIsolation(IsolationLevel::UpdLock);
        if not FreshTracker.Get(ChangeTracker."Integration Type", ChangeTracker."Table No.") then
            exit;
        if (FreshTracker."Failing Row Version" <> 0) or (FreshTracker."Consecutive Failures" <> 0) then begin
            FreshTracker."Failing Row Version" := 0;
            FreshTracker."Consecutive Failures" := 0;
            FreshTracker.Modify(true);
        end;
        ChangeTracker := FreshTracker;
    end;

    procedure QuarantineRow(var ChangeTracker: Record "NPR Change Tracker"; RowVersion: BigInteger; QuarRecordId: RecordId; EntitySystemId: Guid; ErrorText: Text): Boolean
    var
        ChangeQuarantine: Record "NPR Change Quarantine";
        FreshTracker: Record "NPR Change Tracker";
    begin
        // Check the mark under lock BEFORE inserting: when a re-sync lowered it concurrently, the whole quarantine
        // aborts. Insert, advance and failure cleanup share one transaction and one Modify - together or not at all.
        FreshTracker.ReadIsolation(IsolationLevel::UpdLock);
        if not FreshTracker.Get(ChangeTracker."Integration Type", ChangeTracker."Table No.") then
            exit(false);
        if FreshTracker."Last Row Version" < ChangeTracker."Last Row Version" then
            exit(false);
        ChangeQuarantine.Init();
        ChangeQuarantine."Integration Type" := ChangeTracker."Integration Type";
        ChangeQuarantine."Table No." := ChangeTracker."Table No.";
        ChangeQuarantine."Row Version" := RowVersion;
        ChangeQuarantine."Record ID" := QuarRecordId;
        ChangeQuarantine."Entity System Id" := EntitySystemId;
        ChangeQuarantine."Error Text" := CopyStr(ErrorText, 1, MaxStrLen(ChangeQuarantine."Error Text"));
        ChangeQuarantine."Quarantined At" := CurrentDateTime();
        ChangeQuarantine.Insert(true);
        if RowVersion > FreshTracker."Last Row Version" then
            FreshTracker."Last Row Version" := RowVersion;
        FreshTracker."Failing Row Version" := 0;
        FreshTracker."Consecutive Failures" := 0;
        FreshTracker.Modify(true);
        ChangeTracker := FreshTracker;
        exit(true);
    end;

    procedure SeedToCurrentMax(var ChangeTracker: Record "NPR Change Tracker"; CurrentMaxRowVersionParam: BigInteger)
    begin
        ChangeTracker."Last Row Version" := CurrentMaxRowVersionParam;
        ChangeTracker.Modify(true);
    end;

    internal procedure FastForwardToCommittedMax(var ChangeTracker: Record "NPR Change Tracker"): Boolean
    var
        FreshTracker: Record "NPR Change Tracker";
        NewMark: BigInteger;
    begin
        // Raise-only against the persisted mark, under lock: the UI promises a raise, never a lowering.
        FreshTracker.ReadIsolation(IsolationLevel::UpdLock);
        if not FreshTracker.Get(ChangeTracker."Integration Type", ChangeTracker."Table No.") then
            exit(false);
        // Same boundary reasoning as the seed in RegisterTable, and no source-table read under the tracker lock.
        NewMark := CommittedBoundary();
        if NewMark <= FreshTracker."Last Row Version" then begin
            ChangeTracker := FreshTracker;
            exit(false);
        end;
        FreshTracker."Last Row Version" := NewMark;
        FreshTracker.Modify(true);
        ChangeTracker := FreshTracker;
        exit(true);
    end;

    internal procedure CommittedBoundary(): BigInteger
    var
        Boundary: BigInteger;
        Handled: Boolean;
    begin
        // Test seam: TestIsolation holds one open transaction across Commit(), which pins MinimumActiveRowVersion
        // below every test fixture. Production has no subscriber and always takes the real read below.
        OnGetCommittedBoundaryOverride(Boundary, Handled);
        if Handled then
            exit(Boundary);
        // Highest rowversion guaranteed committed: rows of every still-open transaction lie above it (DB-wide counter).
        exit(Database.MinimumActiveRowVersion() - 1);
    end;

    [InternalEvent(false)]
    local procedure OnGetCommittedBoundaryOverride(var Boundary: BigInteger; var Handled: Boolean)
    begin
    end;

    procedure ReseedAllMarksToCurrentMax(IntegrationType: Enum "NPR Integration Type")
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        ChangeTracker.SetRange("Integration Type", IntegrationType);
        if ChangeTracker.FindSet() then
            repeat
                SeedToCurrentMax(ChangeTracker, CommittedBoundary());
            until ChangeTracker.Next() = 0;
    end;

    procedure ResetTracking(IntegrationType: Enum "NPR Integration Type"; TableNo: Integer)
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        if not ChangeTracker.Get(IntegrationType, TableNo) then
            exit;
        ChangeTracker."Last Row Version" := 0;
        ChangeTracker.Modify(true);
    end;

    procedure CurrentMaxRowVersion(TableNo: Integer): BigInteger
    var
        RecRef: RecordRef;
        RowVersionFRef: FieldRef;
    begin
        RecRef.Open(TableNo);
        RecRef.ReadIsolation(IsolationLevel::ReadCommitted);
        RowVersionFRef := RowVersionFieldRef(RecRef);
        SelectRowVersionKey(RecRef, RowVersionFRef);
        if RecRef.FindLast() then
            exit(RowVersionFRef.Value());
        exit(0);
    end;

    internal procedure UncommittedMaxRowVersion(TableNo: Integer): BigInteger
    var
        RecRef: RecordRef;
        RowVersionFRef: FieldRef;
    begin
        // Telemetry probe only: a committed read cannot SEE the pinning row, which is the work this probe asks about.
        RecRef.Open(TableNo);
        RecRef.ReadIsolation(IsolationLevel::ReadUncommitted);
        RowVersionFRef := RowVersionFieldRef(RecRef);
        SelectRowVersionKey(RecRef, RowVersionFRef);
        if RecRef.FindLast() then
            exit(RowVersionFRef.Value());
        exit(0);
    end;

    internal procedure SetFilterOnRowVersion(var RecRef: RecordRef; Mark: BigInteger; UpperBound: BigInteger)
    var
        RowVersionFRef: FieldRef;
    begin
        RowVersionFRef := RowVersionFieldRef(RecRef);
        SelectRowVersionKey(RecRef, RowVersionFRef);
        // Explicit AND range (Mark, UpperBound]: rows of still-open transactions lie above the frozen upper
        // bound and stay invisible to the scan AND to the mark, so they are next cycle's work.
        RowVersionFRef.SetFilter('>%1&<=%2', Mark, UpperBound);
    end;

    internal procedure RowVersionOf(var RecRef: RecordRef): BigInteger
    begin
        exit(RowVersionFieldRef(RecRef).Value());
    end;

    internal procedure RowVersionFieldNo(var RecRef: RecordRef): Integer
    begin
        exit(RowVersionFieldRef(RecRef).Number());
    end;

    internal procedure SystemIdOf(var RecRef: RecordRef): Guid
    begin
        exit(RecRef.Field(RecRef.SystemIdNo()).Value());
    end;

    local procedure RowVersionFieldRef(var RecRef: RecordRef): FieldRef
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        RowVersionFRef: FieldRef;
        FieldNotFoundErr: Label 'SystemRowVersion (timestamp) field not found on table %1. This is a programming bug.', Comment = '%1 = table no.';
    begin
        // SystemRowVersion is the SQL 'timestamp' field; no RecordRef accessor, must find by name.
        if not DataTypeMgmt.FindFieldByName(RecRef, RowVersionFRef, 'timestamp') then
            Error(FieldNotFoundErr, RecRef.Number());
        exit(RowVersionFRef);
    end;

    local procedure SelectRowVersionKey(var RecRef: RecordRef; RowVersionFRef: FieldRef)
    var
        KRef: KeyRef;
        FRef: FieldRef;
        NoRowVersionKeyErr: Label 'No single-field SystemRowVersion key on table %1. The rowversion poll requires a single-field SystemRowVersion key; without it the scan would silently fall back to another key (wrong order / full scan). This is a programming bug.', Comment = '%1 = table no.';
        i: Integer;
    begin
        for i := 1 to RecRef.KeyCount() do begin
            KRef := RecRef.KeyIndex(i);
            if KRef.Active() and (KRef.FieldCount() = 1) then begin
                FRef := KRef.FieldIndex(1);
                if FRef.Name() = RowVersionFRef.Name() then begin
                    RecRef.CurrentKeyIndex(i);
                    exit;
                end;
            end;
        end;
        Error(NoRowVersionKeyErr, RecRef.Number());
    end;
}
