enum 6014558 "NPR Total Disc Ben Value Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(2; "Percent")
    {
        Caption = 'Percent';
    }

    value(3; "Amount")
    {
        Caption = 'Amount';
    }
}
