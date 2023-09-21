enum 6014593 "NPR NPRE Default No. of Guests"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = true;

    value(0; Default)
    {
        Caption = '<Default>';
    }
    value(1; Zero)
    {
        Caption = 'Zero';
    }
    value(2; One)
    {
        Caption = 'One';
    }
    value(3; "Min Party Size")
    {
        Caption = 'Seating Min Party Size';
    }
}
