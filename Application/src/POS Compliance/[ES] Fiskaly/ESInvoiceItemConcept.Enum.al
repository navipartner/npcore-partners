enum 6059785 "NPR ES Invoice Item Concept"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; NATIONAL_OR_SIMPLIFIED)
    {
        Caption = 'National or Simplified';
    }
    value(2; INTERNATIONAL_GOOD)
    {
        Caption = 'International Good';
    }
    value(3; INTERNATIONAL_SERVICE)
    {
        Caption = 'International Service';
    }
}
