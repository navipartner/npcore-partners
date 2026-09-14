#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 85446 "NPR Library - Subs Terminate"
{
    // Requests a subscription termination through Codeunit.Run rather than a [TryFunction], so a test can trap the
    // refusal without tripping the test runner.
    //
    // A termination inserts a request row, and the runner refuses a write inside a TryFunction while RunTests is on
    // the stack, even though the same code is free to write when it runs online. Trapping the call therefore has to
    // go through Run. The error text stays available through GetLastErrorText either way.
    TableNo = "NPR MM Membership";

    var
        _RequestedDate: Date;

    trigger OnRun()
    var
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
    begin
        SubscriptionMgt.RequestSubscriptionTermination(Rec, _RequestedDate, Enum::"NPR MM Subs Termination Reason"::CUSTOMER_INITIATED, false, '', 0);
    end;

    /// <summary>
    /// The date to request the termination for. Set it before calling Run.
    /// </summary>
    procedure SetRequestedDate(RequestedDate: Date)
    begin
        _RequestedDate := RequestedDate;
    end;
}
#endif
