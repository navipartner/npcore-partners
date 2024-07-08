enum 6014518 "NPR TM CapacityLimit"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; Admission)
    {
        Caption = 'Admission';
    }
    value(1; Schedule)
    {
        Caption = 'Schedule';
    }
    value(2; Override)
    {
        Caption = 'Manual';
    }
}