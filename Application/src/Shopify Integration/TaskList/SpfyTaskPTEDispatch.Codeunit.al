codeunit 6151487 "NPR Spfy Task PTE Dispatch"
{
    Access = Internal;
    TableNo = "NPR Spfy Task";

    // Isolated raise: the send boundary must never raise, and a subscriber error must not abort the store's cycle.
    trigger OnRun()
    var
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
        Handled: Boolean;
    begin
        SpfyIntegrationEvents.OnBeforeDispatchShopifyTask(Rec, Handled);
        SpfyTaskRunContext.SetPTEHandled(Handled);
    end;
}
