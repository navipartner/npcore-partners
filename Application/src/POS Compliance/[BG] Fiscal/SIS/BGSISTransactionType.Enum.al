enum 6014615 "NPR BG SIS Transaction Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Sale)
    {
        Caption = 'Sale';
    }
    value(2; Refund)
    {
        Caption = 'Refund';
    }
}