interface "NPR MM Subscr.Payment IHandler"
{
#if not BC17
    ObsoleteState = Pending;
    ObsoleteTag = '2025-01-31';
    ObsoleteReason = 'Use NPR MM Subs Payment IHandler instead';
#endif
    procedure ProcessPaymentRequest(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    procedure RunSetupCard(SubscriptionPaymentGateway: Code[10])
    procedure DeleteSetupCard(SubscriptionPaymentGateway: Code[10])
    procedure GetPaymentPostingAccount(var AccountType: Enum "Gen. Journal Account Type"; var AccountNo: Code[20])
}