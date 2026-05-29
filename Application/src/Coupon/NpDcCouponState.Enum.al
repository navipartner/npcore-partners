enum 6014595 "NPR NpDc CouponState"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; ACTIVE)
    {
        Caption = 'Active';
    }
    value(10; NOT_YET_VALID)
    {
        Caption = 'Not Yet Valid';
    }
    value(20; EXPIRED)
    {
        Caption = 'Expired';
    }
    value(30; CONSUMED)
    {
        Caption = 'Consumed';
    }
    value(40; EXHAUSTED)
    {
        Caption = 'Exhausted';
    }
    value(50; RESERVED)
    {
        Caption = 'Reserved';
    }
    value(60; MAX_PER_SALE_EXCEEDED)
    {
        Caption = 'Max Per Sale Exceeded';
    }
    value(70; TYPE_DISABLED)
    {
        Caption = 'Type Disabled';
    }
}
