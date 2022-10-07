enum 6014505 "NPR POS Background Task" implements "NPR POS Background Task"
{
    Extensible = false;
#if not BC17
    Access = Internal;
    UnknownValueImplementation = "NPR POS Background Task" = "NPR Unknown POS Bgnd. Task";
#endif

    value(0; Example)
    {
        Caption = 'Example';
        Implementation = "NPR POS Background Task" = "NPR POSAction - Task Example";
    }
    value(1; EFT_NETS_CLOUD_TRX)
    {
        Caption = 'EFT_NETS_CLOUD_TRX', Locked = true;
        Implementation = "NPR POS Background Task" = "NPR EFT NETS Cloud Trx Task";
    }
    value(2; EFT_NETS_CLOUD_LOOKUP)
    {
        Caption = 'EFT_NETS_CLOUD_LOOKUP', Locked = true;
        Implementation = "NPR POS Background Task" = "NPR EFT NETS Cloud Lookup Task";
    }
    value(3; EFT_NETS_CLOUD_ABORT)
    {
        Caption = 'EFT_NETS_CLOUD_ABORT', Locked = true;
        Implementation = "NPR POS Background Task" = "NPR EFT NETS Cloud Abort Task";
    }
}