codeunit 85485 "NPR Spfy RowVer Boundary Seam"
{
    // Test-only override for the committed-boundary read: TestIsolation = Codeunit holds one open SQL
    // transaction across Commit(), which pins Database.MinimumActiveRowVersion() below every test fixture,
    // so tests supply the boundary through the OnGetCommittedBoundaryOverride event instead.
    //
    // Manually bound and NOT SingleInstance, on purpose: the subscriber executes only in a session that
    // bound an instance, and the binding dies with the owning test codeunit's instance. A session that
    // never binds (production, or interactive work on a sandbox with this app installed) always gets the
    // real MinimumActiveRowVersion path, with no cleanup step anywhere. Each RowVer test codeunit owns one
    // instance plus a bound-flag and hands both to SpfyRowVerTestLib.ResetState(var, var); the lib must
    // never store the instance (a SingleInstance holder would make the binding session-long again).
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _FixedBoundary: BigInteger;
        _BoundaryReads: Integer;
        // First value = the unarmed default: Real leaves the event unhandled (production behaviour).
        _BoundaryMode: Option Real,LastAllocated,Fixed;

    // Arm AFTER fixture setup: a Fixed boundary below the table max makes RegisterTable seed the mark at the
    // boundary, and every later poll then exits pinned.
    procedure SetFixedBoundary(Boundary: BigInteger)
    begin
        _BoundaryMode := _BoundaryMode::Fixed;
        _FixedBoundary := Boundary;
    end;

    procedure UseLastAllocatedBoundary()
    begin
        _BoundaryMode := _BoundaryMode::LastAllocated;
        _FixedBoundary := 0;
    end;

    procedure UseRealBoundary()
    begin
        _BoundaryMode := _BoundaryMode::Real;
        _FixedBoundary := 0;
    end;

    procedure ResetBoundaryReadCount()
    begin
        _BoundaryReads := 0;
    end;

    procedure BoundaryReadCount(): Integer
    begin
        exit(_BoundaryReads);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Change Tracker Mgt", 'OnGetCommittedBoundaryOverride', '', true, false)]
    local procedure OverrideCommittedBoundary(var Boundary: BigInteger; var Handled: Boolean)
    begin
        _BoundaryReads += 1;
        case _BoundaryMode of
            _BoundaryMode::LastAllocated:
                begin
                    // @@DBTS: the last allocated rowversion, INCLUDING this session's own open-transaction rows -
                    // reproduces the pre-boundary scan semantics for the flow tests.
                    Boundary := Database.LastUsedRowVersion();
                    Handled := true;
                end;
            _BoundaryMode::Fixed:
                begin
                    Boundary := _FixedBoundary;
                    Handled := true;
                end;
            _BoundaryMode::Real:
                ;
        end;
    end;
}
