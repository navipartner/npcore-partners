enum 6014540 "NPR NPRE K.Req.L. Prod.Status"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; "Not Started")
    {
        Caption = 'Not Started';
    }
    value(1; Started)
    {
        Caption = 'Started';
    }
    value(2; "On Hold")
    {
        Caption = 'On Hold';
    }
    value(3; Finished)
    {
        Caption = 'Finished';
    }
    value(4; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
