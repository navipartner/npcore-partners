enum 6014538 "NPR NPRE Kitchen Order Status"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(10; "Ready for Serving")
    {
        Caption = 'Ready for Serving';
    }
    value(20; "In-Production")
    {
        Caption = 'In-Production';
    }
    value(30; Released)
    {
        Caption = 'Released';
    }
    value(40; Planned)
    {
        Caption = 'Planned';
    }
    value(50; Finished)
    {
        Caption = 'Finished';
    }
    value(60; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
