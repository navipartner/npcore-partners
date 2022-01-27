enum 6151501 "NPR Nc FTP Encryption mode"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = true;

    value(0; "None")
    {
        Caption = 'None';
    }
    value(1; Implicit)
    {
        Caption = 'Implicit';
    }
    value(3; Explicit)
    {
        Caption = 'Explicit';
    }
}