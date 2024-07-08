enum 6014680 "NPR AT Receipt Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; NORMAL)
    {
        Caption = 'NORMAL';
    }
    value(2; CANCELLATION)
    {
        Caption = 'CANCELLATION';
    }
    value(3; TRAINING)
    {
        Caption = 'TRAINING';
    }
    value(4; INITIALIZATION)
    {
        Caption = 'INITIALIZATION';
    }
    value(5; DECOMMISSION)
    {
        Caption = 'DECOMMISSION';
    }
    value(6; MONTHLY_CLOSE)
    {
        Caption = 'MONTHLY_CLOSE';
    }
    value(7; YEARLY_CLOSE)
    {
        Caption = 'YEARLY_CLOSE';
    }
    value(8; SIGNATURE_CREATION_UNIT_FAULT_CLEARANCE)
    {
        Caption = 'SIGNATURE_CREATION_UNIT_FAULT_CLEARANCE';
    }
}
