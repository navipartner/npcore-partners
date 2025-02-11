enum 6059778 "NPR ES Invoice State"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; ISSUED)
    {
        Caption = 'Issued';
    }
    value(2; CANCELLED)
    {
        Caption = 'Cancelled';
    }
    value(3; IMPORTED)
    {
        Caption = 'Imported';
    }
}
