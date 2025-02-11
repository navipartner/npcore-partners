enum 6059773 "NPR ES Signer State"
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
    value(3; DEFECTIVE)
    {
        Caption = 'Defective';
    }
}
