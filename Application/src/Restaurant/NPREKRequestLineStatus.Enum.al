enum 6014539 "NPR NPRE K.Request Line Status"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; "Ready for Serving")
    {
        Caption = 'Ready for Serving';
    }
    value(1; "Serving Requested")
    {
        Caption = 'Serving Requested';
    }
    value(2; Planned)
    {
        Caption = 'Planned';
    }
    value(3; Served)
    {
        Caption = 'Served';
    }
    value(4; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
