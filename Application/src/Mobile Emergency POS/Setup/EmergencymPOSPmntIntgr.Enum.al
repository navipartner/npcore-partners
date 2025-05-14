enum 6059888 "NPR Emergency mPOS PmntIntgr"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; None)
    {
        Caption = 'None', Locked = true;
    }
    value(1; AdyenTapToPay)
    {
        Caption = 'Tap To Pay', Locked = true;
    }
    value(2; AdyenLanTerminal)
    {
        Caption = 'LAN Terminal', Locked = true;
    }
}
