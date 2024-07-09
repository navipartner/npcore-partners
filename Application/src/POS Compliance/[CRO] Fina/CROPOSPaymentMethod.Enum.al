enum 6014583 "NPR CRO POS Payment Method"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-11-28';
    ObsoleteReason = 'Not used anymore.';

    value(0; Other)
    {
        Caption = 'Ostalo', Locked = true;
    }
    value(1; Cash)
    {
        Caption = 'Gotovina', Locked = true;
    }
    value(2; Card)
    {
        Caption = 'Kartica', Locked = true;
    }
    value(3; Check)
    {
        Caption = 'Ček', Locked = true;
    }
}