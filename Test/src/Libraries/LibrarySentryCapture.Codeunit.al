#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
/// <summary>Captures Sentry payloads in memory so tests can assert on them without sending anything to telemetry.</summary>
codeunit 85494 "NPR Library - Sentry Capture"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _Payloads: List of [Text];

    /// <summary>Binds before flushing the open scope, so a scope left over from earlier code is captured and discarded instead of sent.</summary>
    procedure Start()
    var
        Sentry: Codeunit "NPR Sentry";
    begin
        BindSubscription(this);
        Sentry.FinalizeScope();
        Clear(_Payloads);
    end;

    procedure Stop()
    begin
        UnbindSubscription(this);
    end;

    procedure Contains(Needle: Text): Boolean
    var
        Payload: Text;
    begin
        foreach Payload in _Payloads do
            if Payload.Contains(Needle) then
                exit(true);
        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Sentry Transaction", 'OnBeforeSendSentryPayload', '', false, false)]
    local procedure CapturePayload(PayloadJson: Text; var Handled: Boolean)
    begin
        _Payloads.Add(PayloadJson);
        Handled := true;
    end;
}
#endif
