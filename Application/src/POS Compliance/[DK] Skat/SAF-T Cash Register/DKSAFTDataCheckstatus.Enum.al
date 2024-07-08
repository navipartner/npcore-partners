enum 6014592 "NPR DK SAF-T Data Check status"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Failed)
    {
        Caption = 'Failed';
    }
    value(2; Passed)
    {
        Caption = 'Passed';
    }
}