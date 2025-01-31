enum 6059852 "NPR MM SubsAdyenRecProcModel"
{
    Extensible = false;
#if not BC17
    Access = internal;
#endif
    value(0; UnscheduledCardOnFile)
    {
        Caption = 'UnscheduledCardOnFile';
    }
    value(1; CardOnFile)
    {
        Caption = 'CardOnFile';
    }
    value(2; Subscription)
    {
        Caption = 'Subscription';
    }

}
