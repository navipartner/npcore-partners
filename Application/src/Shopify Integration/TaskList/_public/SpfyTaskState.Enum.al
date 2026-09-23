enum 6014623 "NPR Spfy Task State"
{
    Access = Public;
    Extensible = false;

    value(0; Pending)
    {
        Caption = 'Pending';
    }
    value(1; Waiting)
    {
        Caption = 'Waiting';
    }
    value(2; "In Flight")
    {
        Caption = 'In Flight';
    }
    value(3; Quarantined)
    {
        Caption = 'Quarantined';
    }
    value(4; Completed)
    {
        Caption = 'Completed';
    }
}
