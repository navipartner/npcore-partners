codeunit 6248736 "NPR Cust. Act. Refresh Runner"
{
    Access = Internal;

    // Per-customer isolation wrapper for the batch in "NPR Cust. Activity Refresh".OnRun. The Job Queue runs
    // that OnRun via a guarded Codeunit.Run, where AL forbids a nested [TryFunction] from writing to the
    // database. Running each customer's refresh through this codeunit's guarded Run isolates a failure to that
    // customer inside a real transaction boundary that permits the write. The caller Commits pending writes
    // before invoking Run and after it returns (see "NPR Cust. Activity Refresh".OnRun).

    trigger OnRun()
    var
        ActivityRefresh: Codeunit "NPR Cust. Activity Refresh";
        Customer: Record Customer;
    begin
        if not Customer.Get(_CustomerNo) then
            exit;
        ActivityRefresh.RefreshSingleCustomer(Customer);
    end;

    var
        _CustomerNo: Code[20];

    procedure SetCustomer(CustomerNo: Code[20])
    begin
        _CustomerNo := CustomerNo;
    end;
}
