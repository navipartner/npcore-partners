enum 6014575 "NPR MM AzureRegistrationMethod"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; EMAIL)
    {
        Caption = 'E-Mail';
    }
    value(1; FACEBOOK)
    {
        Caption = 'Facebook';
    }
    value(2; APPLE)
    {
        Caption = 'Apple';
    }
    value(3; GOOGLE)
    {
        Caption = 'Google';
    }
    value(99; UNKNOWN)
    {
        Caption = 'Unknown';
    }
}