enum 6014589 "NPR SAF-T Cash Export Status"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; "Not Started")
    {
        Caption = 'Not Started';
    }
    value(1; "In Progress")
    {
        Caption = 'In Progress';
    }
    value(2; Failed)
    {
        Caption = 'Failed';
    }
    value(3; Completed)
    {
        Caption = 'Completed';
    }
}