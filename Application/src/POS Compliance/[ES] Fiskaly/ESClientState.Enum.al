enum 6059775 "NPR ES Client State"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; ENABLED)
    {
        Caption = 'Enabled';
    }
    value(2; DISABLED)
    {
        Caption = 'Disabled';
    }
}
