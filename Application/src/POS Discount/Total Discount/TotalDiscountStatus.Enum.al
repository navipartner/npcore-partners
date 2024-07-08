enum 6014555 "NPR Total Discount Status"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;
    value(0; Pending)
    {
        Caption = 'Pending';
    }
    value(1; Active)
    {
        Caption = 'Active';
    }
    value(2; Closed)
    {
        Caption = 'Closed';
    }
}
