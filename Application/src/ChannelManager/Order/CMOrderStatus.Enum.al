enum 6014584 "NPR CMOrderStatus"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF
    Caption = 'OTA Channel Manager Order Status';

    value(0; Processing)
    {
        Caption = 'Processing...';
    }

    value(1; Submitted)
    {
        Caption = 'Submitted';
    }

    value(2; Scheduled)
    {
        Caption = 'Scheduled';
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
