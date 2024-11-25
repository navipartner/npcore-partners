enum 6059801 "NPR MM Subscription PSP"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    Caption = 'Subscription PSP';

    value(1; Adyen)
    {
        Caption = 'Adyen';
    }
}