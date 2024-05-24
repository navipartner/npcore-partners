enum 6014664 "NPR Adyen WWS Security Type"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF
    value(0; " ")
    {
        Caption = ' ';
    }
    value(10; "Basic authentication")
    {
        Caption = 'Basic authentication';
    }
}
