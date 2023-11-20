enum 6014570 "NPR RS Nivelation Status"
{
#if not BC17
    Access = Internal;
#endif
    Extensible = false;

    value(0; Unposted)
    {
        Caption = 'Unposted';
    }
    value(1; Posted)
    {
        Caption = 'Posted';
    }
}