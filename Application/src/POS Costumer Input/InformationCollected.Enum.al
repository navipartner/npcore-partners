enum 6014561 "NPR Information Collected"
{
    Extensible = false;
#IF NOT BC17
    Access = Internal;
#ENDIF

    value(0; Signature)
    {
        Caption = 'Signature';
    }
    value(1; "Phone No.")
    {
        Caption = 'Phone No.';
    }
    value(2; "E-Mail")
    {
        Caption = 'E-Mail';
    }
}
