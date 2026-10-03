codeunit 85509 "NPR Spfy LR Fail After Post"
{
    // Raises an error after Sales-Post has committed a credit memo, for tests of what follows such a failure.
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        FailAfterPostErr: Label 'Simulated failure after the credit memo was committed. This is a programming bug.', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure FailAfterCreditMemoPosted(SalesCrMemoHdrNo: Code[20])
    begin
        if SalesCrMemoHdrNo <> '' then
            Error(FailAfterPostErr);
    end;
}
