enum 6151501 "NPR Nc FTP Encryption mode"
{
#if BC17
    Extensible = true;
#endif

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