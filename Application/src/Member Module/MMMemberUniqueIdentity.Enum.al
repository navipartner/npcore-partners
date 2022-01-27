enum 6014482 "NPR MM Member Unique Identity"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = false;

    value(0; NONE)
    {
        Caption = 'None';
    }

    value(1; EMAIL)
    {
        Caption = 'E-Mail';
    }

    value(2; PHONENO)
    {
        Caption = 'Phone No.';
    }

    value(3; SSN)
    {
        Caption = 'Social Security No.';
    }

    value(4; EMAIL_AND_PHONE)
    {
        Caption = 'E-Mail and Phone No. (Combination)';
    }

    value(5; EMAIL_OR_PHONE)
    {
        Caption = 'E-Mail or Phone No. (Individually)';
    }
}
