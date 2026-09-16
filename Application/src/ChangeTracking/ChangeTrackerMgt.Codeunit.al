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
        SeedToCurrentMax(ChangeTracker, CurrentMaxRowVersion(TableNo));
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

    procedure RecordRowFailure(var ChangeTracker: Record "NPR Change Tracker"; FailingRowVersion: BigInteger): Integer
    var
        FreshTracker: Record "NPR Change Tracker";
    begin
        FreshTracker.ReadIsolation(IsolationLevel::UpdLock);
        if not FreshTracker.Get(ChangeTracker."Integration Type", ChangeTracker."Table No.") then
            exit(0);
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

    procedure QuarantineRow(var ChangeTracker: Record "NPR Change Tracker"; RowVersion: BigInteger; QuarRecordId: RecordId; EntitySystemId: Guid; ErrorText: Text)
    var
        ChangeQuarantine: Record "NPR Change Quarantine";
    begin
        ChangeQuarantine.Init();
        ChangeQuarantine."Integration Type" := ChangeTracker."Integration Type";
        ChangeQuarantine."Table No." := ChangeTracker."Table No.";
        ChangeQuarantine."Row Version" := RowVersion;
        ChangeQuarantine."Record ID" := QuarRecordId;
        ChangeQuarantine."Entity System Id" := EntitySystemId;
        ChangeQuarantine."Error Text" := CopyStr(ErrorText, 1, MaxStrLen(ChangeQuarantine."Error Text"));
        ChangeQuarantine."Quarantined At" := CurrentDateTime();
        ChangeQuarantine.Insert(true);
        // Advance past the quarantined row (discarded return intentional; a re-sync racing this narrow window can lose its reset here - accepted).
        if AdvanceMark(ChangeTracker, RowVersion) then;
        ClearRowFailure(ChangeTracker);
    end;

    procedure SeedToCurrentMax(var ChangeTracker: Record "NPR Change Tracker"; CurrentMaxRowVersionParam: BigInteger)
    begin
        ChangeTracker."Last Row Version" := CurrentMaxRowVersionParam;
        ChangeTracker.Modify(true);
    end;

    procedure ReseedAllMarksToCurrentMax(IntegrationType: Enum "NPR Integration Type")
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        ChangeTracker.SetRange("Integration Type", IntegrationType);
        if ChangeTracker.FindSet() then
            repeat
                SeedToCurrentMax(ChangeTracker, CurrentMaxRowVersion(ChangeTracker."Table No."));
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

    internal procedure SetFilterOnRowVersion(var RecRef: RecordRef; Mark: BigInteger)
    var
        RowVersionFRef: FieldRef;
    begin
        RowVersionFRef := RowVersionFieldRef(RecRef);
        SelectRowVersionKey(RecRef, RowVersionFRef);
        RowVersionFRef.SetFilter('>%1', Mark);
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
