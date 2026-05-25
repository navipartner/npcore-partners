#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6150946 "NPR Create Ecom OC Notif"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Header";

    // Thin wrapper so the API agent can call OC creation via Codeunit.Run, isolating
    // OC failures from the parent transaction. If OC creation throws (rare: lock timeout,
    // DB constraint), only the OC writes are rolled back; the just-committed ecom doc
    // is unaffected and the API still returns OK to the client.
    trigger OnRun()
    var
        DigitalOrderNotifMgt: Codeunit "NPR Digital Order Notif. Mgt.";
    begin
        DigitalOrderNotifMgt.TryCreateEcomOrderConfirmationNotification(Rec);
    end;
}
#endif
