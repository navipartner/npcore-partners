enum 6014485 "NPR TM Ternary"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = false;

    value(0; TERNARY_UNKNOWN)
    {
        Caption = 'Unknown';
    }
    value(1; TERNARY_TRUE)
    {
        Caption = 'True';
    }
    value(2; TERNARY_FALSE)
    {
        Caption = 'False';
    }
}