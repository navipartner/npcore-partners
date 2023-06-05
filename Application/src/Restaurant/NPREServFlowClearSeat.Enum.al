enum 6014542 "NPR NPRE Serv.Flow Clear Seat."
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; "Waiter Pad Close")
    {
        Caption = 'Waiter Pad Close';
    }
    value(1; "Pre-Receipt")
    {
        Caption = 'Pre-Receipt';
    }
    value(2; "Pre-Receipt if Served")
    {
        Caption = 'Pre-Receipt if Served';
    }
}
