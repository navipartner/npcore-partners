enum 6014666 "NPR AT SCU State"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; PENDING)
    {
        Caption = 'PENDING';
    }
    value(2; CREATED)
    {
        Caption = 'CREATED';
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
