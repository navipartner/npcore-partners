enum 6014675 "NPR AT VAT Rate"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; STANDARD)
    {
        Caption = 'STANDARD';
    }
    value(2; REDUCED_1)
    {
        Caption = 'REDUCED_1';
    }
    value(3; REDUCED_2)
    {
        Caption = 'REDUCED_2';
    }
    value(4; SPECIAL)
    {
        Caption = 'SPECIAL';
    }
    value(5; ZERO)
    {
        Caption = 'ZERO';
    }
}
