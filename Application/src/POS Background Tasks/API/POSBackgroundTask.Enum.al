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
    value(4; EFT_ADYEN_CLOUD_ABORT)
    {
        Caption = 'EFT_ADYEN_CLOUD_ABORT', Locked = true;
        Implementation = "NPR POS Background Task" = "NPR EFT Adyen Abort Trx Task";
    }
    value(5; EFT_ADYEN_CLOUD_TRX)
    {
        Caption = 'EFT_ADYEN_CLOUD_TRX', Locked = true;
        Implementation = "NPR POS Background Task" = "NPR EFT Adyen Trx Task";
    }
    value(6; EFT_ADYEN_CLOUD_ACQ_CARD)
    {
        Caption = 'EFT_ADYEN_CLOUD_ACQ_CARD', Locked = true;
        Implementation = "NPR POS Background Task" = "NPR EFT Adyen Acq.Card Task";
    }
    value(7; EFT_ADYEN_CLOUD_ACQ_ABORT)
    {
        Caption = 'EFT_ADYEN_CLOUD_ACQ_ABORT', Locked = true;
        Implementation = "NPR POS Background Task" = "NPR EFT Adyen Abort Acq. Task";
    }
    value(8; EFT_ADYEN_CLOUD_LOOKUP)
    {
        Caption = 'EFT_ADYEN_CLOUD_LOOKUP', Locked = true;
        Implementation = "NPR POS Background Task" = "NPR EFT Adyen Lookup Task";
    }
    value(9; EFT_ADYEN_CLOUD_SETUP_CHECK)
    {
        Caption = 'EFT_ADYEN_SETUP_CHECK', Locked = true;
        Implementation = "NPR POS Background Task" = "NPR EFT Adyen Setup Check Task";
    }
    value(10; EFT_PLANET_PAX_TRX)
    {
        Caption = 'EFT_PLANET_PAX_TRX', Locked = true;
        Implementation = "NPR POS Background Task" = "NPR EFT Planet PAX Trx";
    }
    value(11; EFT_PLANET_PAX_ABORT)
    {
        Caption = 'EFT_PLANET_PAX_ABORT', Locked = true;
        Implementation = "NPR POS Background Task" = "NPR EFT Planet PAX Abort";
    }
}