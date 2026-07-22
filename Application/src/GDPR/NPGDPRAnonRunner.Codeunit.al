codeunit 6248737 "NPR NP GDPR Anon. Runner"
{
    Access = Internal;

    // Per-customer isolation wrapper for the anonymization batch in "NPR NP GDPR Management".
    // The Job Queue runs that codeunit's OnRun via a guarded Codeunit.Run. In that context AL (a) forbids a
    // nested [TryFunction] from writing to the database and (b) requires no uncommitted writes when a further
    // guarded Codeunit.Run is invoked. Running each customer through this codeunit's guarded Run isolates
    // failures - a bad customer rolls back on its own and the batch continues - inside a real transaction
    // boundary that permits the writes. The caller must Commit pending writes before invoking Run and after
    // it returns (see the batch loop in "NPR NP GDPR Management".OnRun).

    trigger OnRun()
    var
        GDPRMgt: Codeunit "NPR NP GDPR Management";
    begin
        _WasAnonymized := false;
        _Reason := '';
        _WasAnonymized := GDPRMgt.AnonymizeSingle(_CustomerNo, _CheckPeriod, _Reason);
    end;

    var
        _CustomerNo: Code[20];
        _CheckPeriod: Boolean;
        _WasAnonymized: Boolean;
        _Reason: Text;

    procedure SetCustomer(CustomerNo: Code[20])
    begin
        _CustomerNo := CustomerNo;
    end;

    procedure SetCheckPeriod(CheckPeriod: Boolean)
    begin
        _CheckPeriod := CheckPeriod;
    end;

    procedure WasAnonymized(): Boolean
    begin
        exit(_WasAnonymized);
    end;

    procedure GetReason(): Text
    begin
        exit(_Reason);
    end;
}
