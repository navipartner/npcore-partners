enum 6059820 "NPR MM Subs Pmt Gateway Status"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    Caption = 'Subscriptions Payment Gateway Status';

    value(0; Disabled) { }
    value(10; Enabled) { }
}
