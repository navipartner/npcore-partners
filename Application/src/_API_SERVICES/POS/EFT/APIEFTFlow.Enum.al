#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
enum 6151090 "NPR API EFT Flow"
{
    Access = Internal;
    Extensible = false;

    value(0; Cloud)
    {
        Caption = 'Cloud';
    }
    value(1; Local)
    {
        Caption = 'Local';
    }
}
#endif
