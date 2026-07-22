codeunit 85273 "NPR GDPR Anon Fault Inject"
{
    // Manual-instance test double: bound only inside the customer-path atomicity test to force a mid-wipe
    // failure. It subscribes to OnAfterDoAnonymization (raised inside DoAnonymization AFTER AnonymizeCustomer
    // has wiped the records but BEFORE the success log entry is written), so the guarded Run must roll the
    // whole wipe back.
    EventSubscriberInstance = Manual;

    var
        InjectedFailureErr: Label 'Injected anonymization failure for testing.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NP GDPR Management", 'OnAfterDoAnonymization', '', false, false)]
    local procedure ForceErrorOnAfterDoAnonymization(CustNo: Code[20])
    begin
        Error(InjectedFailureErr);
    end;
}
