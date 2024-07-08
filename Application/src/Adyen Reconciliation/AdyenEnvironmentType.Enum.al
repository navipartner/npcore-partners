enum 6014696 "NPR Adyen Environment Type"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; "Test")
    {
        Caption = 'Test Environment';
    }
    value(10; "Live")
    {
        Caption = 'Live Environment';
    }
}