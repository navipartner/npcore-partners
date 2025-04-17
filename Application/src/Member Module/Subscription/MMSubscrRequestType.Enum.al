enum 6059805 "NPR MM Subscr. Request Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    Caption = 'Subscription Request Type';

    value(0; " ") { Caption = ''; }
    value(10; "Renew") { Caption = 'Renew'; }
    value(20; "Regret") { Caption = 'Regret'; }
    value(30; "Payment Method Collection") { Caption = 'Payment Method Collection'; }
}