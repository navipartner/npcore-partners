enum 6059780 "NPR ES Inv. Cancellation State"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; NOT_CANCELLED)
    {
        Caption = 'Not cancelled';
    }
    value(2; PENDING)
    {
        Caption = 'Pending';
    }
    value(3; STORED)
    {
        Caption = 'Stored';
    }
    value(4; CANCELLED)
    {
        Caption = 'Cancelled';
    }
    value(5; REQUIRES_INSPECTION)
    {
        Caption = 'Requires inspection';
    }
    value(6; INVALID)
    {
        Caption = 'Invalid';
    }
}
