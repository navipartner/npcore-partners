enum 6014470 "NPR POS Workflow" implements "NPR IPOS Workflow"
{
    Extensible = true;
#if not BC17
    Access = Public;
    UnknownValueImplementation = "NPR IPOS Workflow" = "NPR Unknown Workflow";
#endif

    value(0; LEGACY)
    {
        Caption = 'LEGACY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR Unknown Workflow";
    }
    value(1; PAYMENT_CASH)
    {
        Caption = 'PAYMENT_CASH', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Cash Payment";
    }
    value(2; EFT_MOCK_CLIENT)
    {
        Caption = 'EFT_MOCK_CLIENT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: EFT Mock";
    }
    value(3; EFT_PAYMENT)
    {
        Caption = 'EFT_PAYMENT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: EFT Payment";
    }
    value(4; EFT_GENERIC_CLOSE)
    {
        Caption = 'EFT_GENERIC_CLOSE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action HWC Gen. Close";
    }
    value(5; EFT_GENERIC_OPEN)
    {
        Caption = 'EFT_GENERIC_OPEN', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action HWC Gen. Open";
    }
    value(6; EFT_OPERATION_2)
    {
        Caption = 'EFT_OPERATION_2', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: EFT Op 2";
    }
    value(7; PAYMENT_2)
    {
        Caption = 'PAYMENT_2', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Payment WF2";
    }
    value(8; EFT_GENERIC_AUX)
    {
        Caption = 'EFT_GENERIC_AUX', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action HWC Gen. Aux";
    }

    value(9; PAYMENT_PAYIN_PAYOUT)
    {
        Caption = 'PAYMENT_PAYIN_PAYOUT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Pay-in Payout";
    }

    value(10; PAYMENT_CHECK)
    {
        Caption = 'PAYMENT_CHECK', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Check Payment";
    }


}