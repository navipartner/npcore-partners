enum 6059770 "NPR ES Taxpayer Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; COMPANY)
    {
        Caption = 'Company';
    }
    value(2; INDIVIDUAL)
    {
        Caption = 'Individual';
    }
}
