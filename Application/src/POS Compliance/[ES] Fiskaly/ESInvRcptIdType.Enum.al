enum 6059781 "NPR ES Inv. Rcpt. Id Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; TAX_NUMBER)
    {
        Caption = 'Tax Number';
    }
    value(2; PASSPORT)
    {
        Caption = 'Passport';
    }
    value(3; DOCUMENT)
    {
        Caption = 'Document';
    }
    value(4; CERTIFICATE)
    {
        Caption = 'Certificate';
    }
    value(5; OTHER)
    {
        Caption = 'Other';
    }
}
