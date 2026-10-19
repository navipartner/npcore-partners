/// <summary>
/// Entity-agnostic entry point for NP Passes: landing links and pass-update signals. Entity modules call it through their own adapter.
/// </summary>
codeunit 6151533 "NPR NP Passes Facade"
{
    Access = Internal;

    var
        _Impl: Codeunit "NPR NP Passes Impl";

    internal procedure IsConfigured(): Boolean
    begin
        exit(_Impl.IsConfigured());
    end;

    internal procedure HasSigningSecret(): Boolean
    begin
        exit(_Impl.HasSigningSecret());
    end;

    /// <summary>
    /// {Base URL}/l/{LayoutHandle}/{serial}?signature={hmac}; np-passes creates the pass when the link is opened. Empty when not configured.
    /// </summary>
    internal procedure BuildLandingLink(LayoutHandle: Text[40]; SerialNumber: Guid): Text
    begin
        exit(_Impl.BuildLandingLink(LayoutHandle, SerialNumber));
    end;

    /// <summary>
    /// The serial number np-passes knows an entity by: its SystemId, lowercase, without braces and dashes.
    /// </summary>
    internal procedure FormatSerialNumber(Id: Guid): Text[36]
    begin
        exit(_Impl.FormatSerialNumber(Id));
    end;

    /// <summary>
    /// Signals np-passes to refresh the pass (re-fetch data and design handle from the card, push devices).
    /// Returns true if the event was raised, false if NP Passes is not configured or the serial number is empty.
    /// </summary>
    internal procedure NotifyPassUpdated(SerialNumber: Guid): Boolean
    begin
        exit(_Impl.NotifyPassUpdated(SerialNumber));
    end;

    internal procedure SetNotifier(Notifier: Interface "NPR INPPasses Notifier")
    begin
        _Impl.SetNotifier(Notifier);
    end;

    internal procedure ClearNotifier()
    begin
        _Impl.ClearNotifier();
    end;
}
