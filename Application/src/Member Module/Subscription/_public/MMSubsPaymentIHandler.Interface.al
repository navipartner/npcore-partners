interface "NPR MM Subs Payment IHandler"
{
    procedure ProcessPaymentRequest(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean; Manual: Boolean) Success: Boolean
    procedure RunSetupCard(SubscriptionPaymentGateway: Code[10])
    procedure DeleteSetupCard(SubscriptionPaymentGateway: Code[10])
    procedure GetPaymentPostingAccount(var AccountType: Enum "Gen. Journal Account Type"; var AccountNo: Code[20])
    procedure EnableIntegration(var SubsPaymentGateway: Record "NPR MM Subs. Payment Gateway")
    procedure DisableIntegration(var SubsPaymentGateway: Record "NPR MM Subs. Payment Gateway")
}