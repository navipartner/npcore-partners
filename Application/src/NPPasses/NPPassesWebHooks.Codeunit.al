codeunit 6151529 "NPR NP Passes WebHooks" implements "NPR INPPasses Notifier"
{
    Access = Internal;

    procedure NotifyPassUpdated(SerialNumber: Text[36])
    begin
        OnPassUpdated(SerialNumber);
    end;

    // Parameter names are the payload keys. np-passes takes the design from the card's membership.passDesignHandle.
    [ExternalBusinessEvent('nppass_updated', 'NP Pass Updated', 'Triggered when the data or the design of a wallet pass has changed and np-passes should refresh the pass on registered devices.', EventCategory::"NPR NP Passes", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR NP Passes WebHooks", 'X')]
    local procedure OnPassUpdated(serialNumber: Text[36])
    begin
    end;
}
