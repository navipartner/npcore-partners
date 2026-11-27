#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
enum 6151089 "NPR API EFT Provider" implements "NPR API EFT Provider"
{
    Access = Internal;
    Extensible = false;

    value(0; ADYEN_CLOUD)
    {
        Caption = 'Adyen Cloud';
        Implementation = "NPR API EFT Provider" = "NPR API EFT Adyen Cloud";
    }
    value(1; ADYEN_MPOS_TTP)
    {
        Caption = 'Adyen Tap to Pay';
        Implementation = "NPR API EFT Provider" = "NPR API EFT Adyen TTP";
    }
    value(2; NETS_CLOUD)
    {
        Caption = 'NETS Cloud';
        Implementation = "NPR API EFT Provider" = "NPR API EFT NETS Cloud";
    }
}
#endif
