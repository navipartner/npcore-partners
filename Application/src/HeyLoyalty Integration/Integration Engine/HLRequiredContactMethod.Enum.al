enum 6014601 "NPR HL Required Contact Method"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; Email)
    {
        Caption = 'Email';
    }
    value(1; Phone)
    {
        Caption = 'Phone';
    }
    value(2; Email_or_Phone)
    {
        Caption = 'Either (Email or Phone)';
    }
    value(3; Email_and_Phone)
    {
        Caption = 'Both (Email and Phone)';
    }
}