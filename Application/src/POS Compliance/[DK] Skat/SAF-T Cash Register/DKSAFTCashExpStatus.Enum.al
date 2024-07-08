enum 6014591 "NPR DK SAF-T Cash Exp. Status"
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