enum 6014583 "NPR CRO POS Payment Method"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
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