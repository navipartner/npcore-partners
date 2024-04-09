enum 6014648 "NPR DocLXCities"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; NOT_SELECTED)
    {
        Caption = 'Not Selected';
    }

    value(1; COPENHAGEN)
    {
        Caption = 'Copenhagen';
    }

    value(2; OSLO)
    {
        Caption = 'Oslo';
    }

}