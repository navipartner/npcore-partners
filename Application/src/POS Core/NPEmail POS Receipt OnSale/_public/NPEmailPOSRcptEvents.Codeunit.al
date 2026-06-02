#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6151115 "NPR NPEmail POSRcpt Events"
{
    Access = Public;
    /// <summary>
    /// Raised before the New Email Experience auto-receipt email is sent in
    /// "NPR NPEmail POS Receipt OnSale".SendReceiptEmailOnAfterEndSale.
    /// Subscribers may set IsHandled := true to suppress the email for a specific POS Entry.
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSendReceiptEmail(POSEntry: Record "NPR POS Entry"; var IsHandled: Boolean)
    begin
    end;
}
#endif