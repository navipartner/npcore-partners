/// <summary>
/// Emits the "pass updated" signal to np-passes. Default implementation raises the nppass_updated business event; tests inject a recorder.
/// </summary>
interface "NPR INPPasses Notifier"
{
    Access = Internal;

    procedure NotifyPassUpdated(SerialNumber: Text[36]);
}
