enum 6059807 "NPR MM Subscr. Auto-Renewal"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    Caption = 'Subscription Auto-Renewal';

    value(0; Never) { Caption = 'Never'; }
    value(10; "Expiry Date") { Caption = 'Expiry Date'; }
    value(20; "Next Start Date") { Caption = 'Next Start Date'; }
    value(30; "Schedule") { Caption = 'Schedule'; }
}