enum 6059833 "NPR DE Taxpayer Salutation"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; "1")
    {
        Caption = '1 - Herr', Locked = true;
    }
    value(2; "2")
    {
        Caption = '2 - Frau', Locked = true;
    }
    value(3; "3")
    {
        Caption = '3 - Divers', Locked = true;
    }
}
