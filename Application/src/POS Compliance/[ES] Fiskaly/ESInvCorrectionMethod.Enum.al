enum 6059786 "NPR ES Inv. Correction Method"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; SUBSTITUTION)
    {
        Caption = 'Substitution';
    }
    value(2; DIFFERENCES)
    {
        Caption = 'Differences';
    }
}
