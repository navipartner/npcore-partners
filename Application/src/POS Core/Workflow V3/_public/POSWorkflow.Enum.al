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
    value(23; ITEM_PRICE)
    {
        Caption = 'ITEM_PRICE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action - Item Price";
    }
    value(24; TEXT_ENTER)
    {
        Caption = 'TEXT_ENTER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Text Enter";
    }
    value(25; ITEM_PROMPT)
    {
        Caption = 'ITEM_PROMPT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Item Prompt";
    }
    value(26; RUN_REPORT)
    {
        Caption = 'RUN_REPORT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction: Run Report";
    }
    value(27; ITEM_UNIT_PRICE)
    {
        Caption = 'ITEM_UNIT_PRICE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Item UnitPrice";
    }
    value(28; SS_PAYMENT_CASH)
    {
        Caption = 'SS_PAYMENT_CASH', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: SS Paym. Cash";
    }
    value(29; ITEM_QTY)
    {
        Caption = 'ITEM_QTY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Item Qty.";
    }
    value(30; EFT_EXT_TERMNL)
    {
        Caption = 'EFT_EXT_TERMNL', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Ext.Terminal";
    }
    value(31; LOOKUP)
    {
        Caption = 'LOOKUP', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Item Lookup";
    }
    value(32; CHANGE_VIEW)
    {
        Caption = 'CHANGE_VIEW', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action - Change View";
    }
    value(33; ITEM)
    {
        Caption = 'ITEM', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Insert Item";
    }

    value(34; CHANGE_UOM)
    {
        Caption = 'CHANGE_UOM', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Change UOM";
    }
    value(37; LOAD_FROM_POS_QUOTE)
    {
        Caption = 'LOAD_FROM_POS_QUOTE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: LoadPOSSvSl";
    }
    value(38; CANCEL_POS_SALE)
    {
        Caption = 'CANCEL_POS_SALE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction: Cancel Sale";
    }
    value(39; SAVE_AS_POS_QUOTE)
    {
        Caption = 'SAVE_AS_POS_QUOTE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: SavePOSSvSl";
    }
    value(41; IMPORT_POSTED_INV)
    {
        Caption = 'IMPORT_POSTED_INV', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Imp. Pstd. Inv";
    }
    value(43; REVERSE_CREDIT_SALE)
    {
        Caption = 'REVERSE_CREDIT_SALE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Reverse Sale";
    }
    value(40; BACKGND_TASK_EXAMPLE)
    {
        Caption = 'BACKGND_TASK_EXAMPLE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction - Task Example";
    }
    value(44; QUANTITY)
    {
        Caption = 'QUANTITY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Quantity";
    }

    value(42; REVERSE_DIRECT_SALE)
    {
        Caption = 'REVERSE_DIRECT_SALE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Rev. Dir. Sale";
    }
    value(6014600; BALANCE_V4)
    {
        Caption = 'BALANCE_V4', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: EndOfDay V4";
    }
}