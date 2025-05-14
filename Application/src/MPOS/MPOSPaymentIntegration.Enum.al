enum 6059899 "NPR MPOS Payment Integration"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; None)
    {
        Caption = 'None', Locked = true;
    }
    value(1; TapToPay)
    {
        Caption = 'Tap-To-Pay App', Locked = true;
    }
    value(2; LocalTerminal)
    {
        Caption = 'Local Terminal', Locked = true;
    }
}
