enum 6059783 "NPR ES Inv. Recipient Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; National)
    {
        Caption = 'National';
    }
    value(2; International)
    {
        Caption = 'International';
    }
}
