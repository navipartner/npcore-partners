enum 6014619 "NPR CRO Payment Method"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

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