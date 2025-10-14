codeunit 6248592 "NPR EFT Adyen Task Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeEFTAdyenSubsConfirmationDialogTextSet(var ConfirmationDialogText: Text; SubscriptionAmountIncludingVAT: Decimal; CurrencyCode: Code[10])
    begin
    end;
}