enum 6014667 "NPR AT Cash Register State"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; CREATED)
    {
        Caption = 'CREATED';
    }
    value(2; REGISTERED)
    {
        Caption = 'REGISTERED';
    }
    value(3; INITIALIZED)
    {
        Caption = 'INITIALIZED';
    }
    value(4; DECOMMISSIONED)
    {
        Caption = 'DECOMMISSIONED';
    }
    value(5; OUTAGE)
    {
        Caption = 'OUTAGE';
    }
    value(6; DEFECTIVE)
    {
        Caption = 'DEFECTIVE';
    }
}
