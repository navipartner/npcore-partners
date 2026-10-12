codeunit 85524 "NPR Test Nested PayReq Modify"
{
    // Manually bound after-modify subscriber that modifies the same subscription payment request once more while the outer
    // modify's after-event is still running, the way another app's subscriber might. Used to prove the status propagation
    // of the outer modify survives a nested before and after pair on the same row.
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _Nested: Boolean;

    [EventSubscriber(ObjectType::Table, Database::"NPR MM Subscr. Payment Request", OnAfterModifyEvent, '', false, false)]
    local procedure ModifyTheSameRowAgain(var Rec: Record "NPR MM Subscr. Payment Request")
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        if Rec.IsTemporary() or _Nested then
            exit;
        _Nested := true;
        SubscrPaymentRequest.Get(Rec."Entry No.");
        SubscrPaymentRequest.Amount += 1;
        SubscrPaymentRequest.Modify(true);
    end;

    procedure NestedModifyRan(): Boolean
    begin
        exit(_Nested);
    end;
}
