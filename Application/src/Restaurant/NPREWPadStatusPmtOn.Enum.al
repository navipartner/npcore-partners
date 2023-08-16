enum 6014551 "NPR NPRE W/Pad Status Pmt. On"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; Manual)
    {
        Caption = 'Manual';
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
