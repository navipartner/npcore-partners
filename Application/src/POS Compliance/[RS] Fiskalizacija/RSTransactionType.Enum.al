enum 6014523 "NPR RS Transaction Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; SALE)
    {
        Caption = 'Sale';
    }
    value(1; REFUND)
    {
        Caption = 'Refund';
    }
}