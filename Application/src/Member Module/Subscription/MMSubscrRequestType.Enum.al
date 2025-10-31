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
    value(21; "Partial Regret") { Caption = 'Partial Regret'; }
    value(30; "Payment Method Collection") { Caption = 'Payment Method Collection'; }
    value(40; "Terminate") { Caption = 'Terminate'; }
    value(50; "Enable") { Caption = 'Enable'; }
    value(60; "Disable") { Caption = 'Disable'; }
}