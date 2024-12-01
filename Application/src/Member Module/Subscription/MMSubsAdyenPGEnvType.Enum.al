enum 6059819 "NPR MM Subs Adyen PG Env Type"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    Caption = 'Subscriptions Adyen Payment Gateway Environment Type';

    value(0; Test) { }
    value(10; Production) { }
}
