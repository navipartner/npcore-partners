enum 6059801 "NPR MM Subscription PSP" implements "NPR MM Subscr.Payment IHandler"
{
#if not BC17
    Access = Public;
    UnknownValueImplementation = "NPR MM Subscr.Payment IHandler" = "NPR MM Subscr.Pmt.: Undefined";
#endif
    Extensible = true;
    DefaultImplementation = "NPR MM Subscr.Payment IHandler" = "NPR MM Subscr.Pmt.: Undefined";
    Caption = 'Subscription PSP';

    value(1; Adyen)
    {
        Caption = 'Adyen';
        Implementation = "NPR MM Subscr.Payment IHandler" = "NPR MM Subscr.Pmt.: Adyen";
    }
}