enum 6014617 "NPR Show QR Code On"
{
    Extensible = false;
#if not BC17
    Access = Internal;
#endif

    value(0; "On Screen")
    {
        Caption = 'On Screen';
    }
    value(1; Terminal)
    {
        Caption = 'Terminal';
    }
}