enum 6014541 "NPR NPRE Serv.Flow Close W/Pad"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; Manual)
    {
        Caption = 'Manual';
    }
    value(1; "Pre-Receipt")
    {
        Caption = 'Pre-Receipt';
    }
    value(2; Payment)
    {
        Caption = 'Payment';
    }
    value(3; "Pre-Receipt if Served")
    {
        Caption = 'Pre-Receipt if Served';
    }
    value(4; "Payment if Served")
    {
        Caption = 'Payment if Served';
    }
}
