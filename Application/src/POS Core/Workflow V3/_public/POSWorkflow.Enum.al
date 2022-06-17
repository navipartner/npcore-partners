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
    value(6184481; EFT_PEPPER_OPEN)
    {
        Caption = 'EFT_PEPPER_OPEN', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Pepper Open";
    }
    value(6184482; EFT_PEPPER_TRX)
    {
        Caption = 'EFT_PEPPER_TRX', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Pepper Trx";
    }
    value(6184483; EFT_PEPPER_CLOSE)
    {
        Caption = 'EFT_PEPPER_CLOSE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Pepper Close";
    }
    value(6184484; EFT_PEPPER_AUX)
    {
        Caption = 'EFT_PEPPER_AUX', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Pepper AUX";
    }
    value(6184485; EFT_PEPPER_INSTALL)
    {
        Caption = 'EFT_PEPPER_INSTALL', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Pepper Install";
    }
    value(11; CUSTOMER_SELECT)
    {
        Caption = 'CUSTOMER_SELECT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Cust. Select";
    }
    value(12; CUSTOMER_INFO)
    {
        Caption = 'CUSTOMER_INFO', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Cust.Info-I";
    }
    value(13; ADD_BARCODE)
    {
        Caption = 'ADD_BARCODE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Add Barcode";
    }
    value(14; ADJUST_INVENTORY)
    {
        Caption = 'ADJUST_INVENTORY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Adjust Inv.";
    }
    value(15; BIN_TRANSFER)
    {
        Caption = 'BIN_TRANSFER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Bin Transfer";
    }
    value(16; BLOCK_DISCOUNT)
    {
        Caption = 'BLOCK_DISCOUNT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Block Discount";
    }
    value(17; TURNOVER_STATS)
    {
        Caption = 'TURNOVER_STATS', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Turnover Stats";
    }
    value(18; BOARDINGPASS)
    {
        Caption = 'BOARDINGPASS', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Boarding Pass";
    }
    value(19; TAKE_PHOTO)
    {
        Caption = 'TAKE_PHOTO', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Take Photo";
    }
    value(20; TRANSFER_ORDER)
    {
        Caption = 'TRANSFER_ORDER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Transf. Order";
    }

    value(21; SALE_DIMENSION)
    {
        Caption = 'SALE_DIMENSION', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Sale Dimension";
    }
    value(22; SWITCH_REGISTER)
    {
        Caption = 'SWITCH_REGISTER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Switch Regist.";
    }
    value(26; RUN_REPORT)
    {
        Caption = 'RUN_REPORT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction: Run Report";
    }

    value(37; LOAD_FROM_POS_QUOTE)
    {
        Caption = 'LOAD_FROM_POS_QUOTE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: LoadPOSSvSl";
    }
    value(39; SAVE_AS_POS_QUOTE)
    {
        Caption = 'SAVE_AS_POS_QUOTE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: SavePOSSvSl";
    }
}