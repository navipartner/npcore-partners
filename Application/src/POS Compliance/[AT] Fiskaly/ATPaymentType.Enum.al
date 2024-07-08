enum 6014676 "NPR AT Payment Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; CASH)
    {
        Caption = 'CASH';
    }
    value(2; NON_CASH)
    {
        Caption = 'NON_CASH';
    }
}
