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
    value(1; "Started [Obsolete]")
    {
        Caption = 'Started [Obsolete]';
        ObsoleteState = Pending;
        ObsoleteTag = '2024-02-28';
        ObsoleteReason = 'Replaced by value 10.';
    }
    value(2; "On Hold [Obsolete]")
    {
        Caption = 'On Hold [Obsolete]';
        ObsoleteState = Pending;
        ObsoleteTag = '2024-02-28';
        ObsoleteReason = 'Replaced by value 20.';
    }
    value(3; "Finished [Obsolete]")
    {
        Caption = 'Finished [Obsolete]';
        ObsoleteState = Pending;
        ObsoleteTag = '2024-02-28';
        ObsoleteReason = 'Replaced by value 30.';
    }
    value(4; "Cancelled [Obsolete]")
    {
        Caption = 'Cancelled [Obsolete]';
        ObsoleteState = Pending;
        ObsoleteTag = '2024-02-28';
        ObsoleteReason = 'Replaced by value 40.';
    }
    value(5; Pending)
    {
        Caption = 'Pending';
    }
    value(10; Started)
    {
        Caption = 'Started';
    }
    value(20; "On Hold")
    {
        Caption = 'On Hold';
    }
    value(30; Finished)
    {
        Caption = 'Finished';
    }
    value(40; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
