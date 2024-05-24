enum 6014673 "NPR Adyen Report Type"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; "Undefined")
    {
        Caption = 'Undefined';
    }
    value(10; "Settlement details")
    {
        Caption = 'Settlement details';
    }
    value(20; "External Settlement detail (C)")
    {
        Caption = 'External Settlement detail (C)';
    }
}
