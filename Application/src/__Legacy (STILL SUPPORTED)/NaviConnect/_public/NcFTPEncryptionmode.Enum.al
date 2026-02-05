enum 6151501 "NPR Nc FTP Encryption mode"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
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