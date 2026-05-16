enum 6014584 "NPR CMOrderStatus"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF
    Caption = 'Channel Manager Order Status';

    value(0; Processing)
    {
        Caption = 'Processing...';
    }

    value(5; Draft)
    {
        Caption = 'Draft';
    }

    value(10; Issued)
    {
        Caption = 'Issued';
    }

    value(30; Cancelled)
    {
        Caption = 'Cancelled';
    }

    value(40; Error)
    {
        Caption = 'Error';
    }
}
