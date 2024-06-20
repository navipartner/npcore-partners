enum 6014697 "NPR Adyen Webhook Log Type"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; "Register")
    {
        Caption = 'Register';
    }
    value(10; "Process")
    {
        Caption = 'Process';
    }
    value(20; "Error")
    {
        Caption = 'Error';
    }
}
