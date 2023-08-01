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
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: EFT Trx";
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
        Implementation = "NPR IPOS Workflow" = "NPR POSAction PaymentWithCheck";
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
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Pepper Aux";
    }
    value(6184485; EFT_PEPPER_INSTALL)
    {
        Caption = 'EFT_PEPPER_INSTALL', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Pepper Install";
    }

    value(6060014; EFT_PEPPER_PAYMENT)
    {
        Caption = 'EFT_PEPPER_PAYMENT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Pepper Payment";
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
    value(35; CHANGE_AMOUNT)
    {
        Caption = 'CHANGE_AMOUNT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Change LineAm.";
    }
    value(36; "SS-SALE-SCREEN")
    {
        Caption = 'SS-SALE-SCREEN', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR SS Action - Sale Screen";
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
    value(40; BACKGND_TASK_EXAMPLE)
    {
        Caption = 'BACKGND_TASK_EXAMPLE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction - Task Example";
    }
    value(41; IMPORT_POSTED_INV)
    {
        Caption = 'IMPORT_POSTED_INV', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Imp. Pstd. Inv";
    }
    value(42; REVERSE_DIRECT_SALE)
    {
        Caption = 'REVERSE_DIRECT_SALE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Rev. Dir. Sale";
    }
    value(43; REVERSE_CREDIT_SALE)
    {
        Caption = 'REVERSE_CREDIT_SALE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Reverse Sale";
    }
    value(44; QUANTITY)
    {
        Caption = 'QUANTITY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Quantity";
    }
    value(45; INSERT_COMMENT)
    {
        Caption = 'INSERT_COMMENT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action - Insert Comm.";
    }
    value(46; "SS-PAY-SCREEN")
    {
        Caption = 'SS-PAY-SCREEN', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR SS Action: Payment Screen";
    }
    value(47; EFT_MOBILEPAY)
    {
        Caption = 'EFT_MOBILEPAY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action - MobilePay Trx";
    }
    value(48; "SS-IDLE-TIMEOUT")
    {
        Caption = 'SS-IDLE-TIMEOUT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR SS Action: Idle Timeout";
    }
    value(49; SALES_DOC_EXP)
    {
        Caption = 'SALES_DOC_EXP', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Doc. Export";
    }
    value(50; "SS-QTY+")
    {
        Caption = 'SS-QTY+', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR SS Action - Qty Increase";
    }
    value(51; EFT_GIFT_CARD_2)
    {
        Caption = 'EFT_GIFT_CARD_2', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: EFTGiftCard 2";
    }
    value(52; EFT_FLEXIITERM)
    {
        Caption = 'EFT_FLEXIITERM', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: EFT Flexiiterm";
    }

    value(53; GET_EVENT)
    {
        Caption = 'GET_EVENT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Get Event";
    }
    value(54; CASHOUT_VOUCHER)
    {
        Caption = 'CASHOUT_VOUCHER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Cash Voucher";
    }
    value(55; SOFTPAY)
    {
        Caption = 'SOFTPAY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: EFT Softpay";
    }
    value(56; "SS-QTY-")
    {
        Caption = 'SS-QTY-', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR SS Action - Qty Decrease";
    }

    value(64; CREATE_COLLECT_ORD)
    {
        Caption = 'CREATE_COLLECT_ORD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NpCs POSAction Cre. Order";
    }

    value(57; EFT_NETS_CLOUD_TRX)
    {
        Caption = 'EFT_NETS_CLOUD_TRX', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: NetsCloud Trx";
    }
    value(58; "SS-ITEM")
    {
        Caption = 'SS-ITEM', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR SS Action: Insert Item";
    }
    value(59; SALES_DOC_PAY_POST)
    {
        Caption = 'SALES_DOC_PAY_POST', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Doc. Pay&Post";

    }
    value(60; CHECK_VOUCHER)
    {
        Caption = 'CHECK_VOUCHER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NpRvCheckVoucher";
    }

    value(63; CROSS_REF_RETURN)
    {
        Caption = 'CROSS_REF_RETURN', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: NpGp Return";
    }
    value(61; SALES_DOC_PREPAY)
    {
        Caption = 'SALES_DOC_PREPAY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Doc. Prepay";
    }
    value(62; CONTACT_SELECT)
    {
        Caption = 'CONTACT_SELECT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Contact Select";
    }
    value(65; INSERT_CUSTOMER)
    {
        Caption = 'INSERT_CUSTOMER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction: Ins. Customer";
    }
    value(66; ITEMINVOV)
    {
        Caption = 'ITEMINVOV', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: ItemInv Overv.";
    }
    value(67; TOPUP_VOUCHER)
    {
        Caption = 'TOPUP_VOUCHER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NpRv POS Action Top-up";
    }
    value(68; SALES_DOC_PRE_REFUND)
    {
        Caption = 'SALES_DOC_PRE_REFUND', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction: DocPrepayRefund";
    }
    value(69; ITEM_AVAILABILITY)
    {
        Caption = 'ITEM_AVAILABILITY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Check Avail.";
    }
    value(70; ITEM_VARIANTS)
    {
        Caption = 'ITEM_VARIANTS', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Item Variants";
    }
    value(71; SALES_DOC_IMP)
    {
        Caption = 'SALES_DOC_IMP', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Doc. Import";
    }
    value(72; SALES_DOC_SHOW)
    {
        Caption = 'SALES_DOC_SHOW', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Doc. Show";
    }
    value(73; RUNPAGE)
    {
        Caption = 'RUNPAGE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Run Page";
    }
    value(74; CUSTOMER_DEPOSIT)
    {
        Caption = 'CUSTOMER_DEPOSIT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Cust. Deposit";
    }
    value(75; ISSUE_VOUCHER)
    {
        Caption = 'ISSUE_VOUCHER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NpRv Issue POSAction Mgt.";
    }

    value(77; EFT_NETS_BAXI_NATIVE)
    {
        Caption = 'EFT_NETS_BAXI_NATIVE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: EFT Nets Baxi";
    }
    value(78; MERGE_SIMILAR_LINES)
    {
        Caption = 'MERGE_SIMILAR_LINES', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction: Merg.Smlr.Lines";
    }
    value(79; CHECK_COUPON)
    {
        Caption = 'CHECK_COUPON', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NP NpDC Coupon Verify";
    }
    value(80; ISSUE_COUPON)
    {
        Caption = 'ISSUE_COUPON', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NpDc Module Issue: OnSale";
    }
    value(81; LAYAWAY_CREATE)
    {
        Caption = 'LAYAWAY_CREATE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Layaway Create";
    }
    value(82; LAYAWAY_SHOW)
    {
        Caption = 'LAYAWAY_SHOW', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: LayawayShow";
    }
    value(83; LAYAWAY_CANCEL)
    {
        Caption = 'LAYAWAY_CANCEL', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Layaway Cancel";
    }
    value(86; SCAN_VOUCHER_2)
    {
        Caption = 'SCAN_VOUCHER_2', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Scan Voucher2";
    }

    value(87; ISSUE_RETURN_VCHR_2)
    {
        Caption = 'ISSUE_RETURN_VCHR_2', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Act.Issue Return Vchr";
    }
    value(88; "SS-VOUCHER-APPLY-2")
    {
        Caption = 'SS-VOUCHER-APPLY-2', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR SS Action: Voucher Apply";
    }
    value(94; RETAIL_INVENTORY)
    {
        Caption = 'RETAIL_INVENTORY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action - Retail Inv.";
    }
    value(93; "SS-LOGIN-SCREEN")
    {
        Caption = 'SS-LOGIN-SCREEN', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR SS Action: Login Screen";
    }
    value(91; "SS-ITEM-ADDON")
    {
        Caption = 'SS-ITEM-ADDON', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR SS Action - Item AddOn";
    }
    value(90; "SS-DELETE-LINE")
    {
        Caption = 'SS-DELETE-LINE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR SS Action: Delete POS Line";
    }
    value(85; LAYAWAY_PAY)
    {
        Caption = 'LAYAWAY_PAY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Layaway Pay";
    }
    value(95; LOCK_POS)
    {
        Caption = 'LOCK_POS', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Lock POS";
    }
    value(99; EXCHANGELABEL)
    {
        Caption = 'EXCHANGELABEL', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: ScanExchLabel";
    }
    value(96; RUNOBJECT)
    {
        Caption = 'RUNOBJECT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Run Object";
    }
    value(97; NOTIFICATIONCARD)
    {
        Caption = 'NOTIFICATIONCARD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Notif. Card";
    }
    value(98; NOTIFICATIONLIST)
    {
        Caption = 'NOTIFICATIONLIST', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Notif. List";
    }
    value(100; "SS-START-POS")
    {
        Caption = 'SS-START-POS', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR SS Action: Start SelfServ.";
    }
    value(101; "CURRENT_SALE_STATS")
    {
        Caption = 'CURRENT_SALE_STATS', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Cur Sale Stats";
    }
    value(102; "PRINT_RECEIPT")
    {
        Caption = 'PRINT_RECEIPT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Print Receipt";
    }
    value(103; DELIVER_COLLECT_ORD)
    {
        Caption = 'DELIVER_COLLECT_ORD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NpCs POSAction Deliv.Order";
    }
    value(104; PROCESS_COLLECT_ORD)
    {
        Caption = 'PROCESS_COLLECT_ORD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NpCs POSAction Proc. Order";
    }
    value(105; "PRINT_ITEM")
    {
        Caption = 'PRINT_ITEM', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Print Item";
    }
    value(106; "POSINFO")
    {
        Caption = 'POSINFO', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Pos Info";
    }
    value(107; "PLAY_SOUND")
    {
        Caption = 'PLAY_SOUND', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action - Play Sound";
    }
    value(108; DELETE_POS_LINE)
    {
        Caption = 'DELETE_POS_LINE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction: Delete POS Line";
    }
    value(109; SET_SALE_VAT)
    {
        Caption = 'SET_SALE_VAT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action - Set Sale VAT";
    }
    value(110; "SINGLE_SALE_STATS")
    {
        Caption = 'SINGLE_SALE_STATS', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Sin Sale Stats";
    }
    value(111; "HTML_DISPLAY")
    {
        Caption = 'HTML_DISPLAY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: HTML Disp.";
    }
    value(112; "SPLIT_BILL")
    {
        Caption = 'SPLIT_BILL', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE POS Action: SplitBill";
    }
    value(113; "SETVATBPGRP")
    {
        Caption = 'SETVATBPGRP', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction: Set VAT B.P.Grp";

    }
    value(114; "MM_CREATE_MEMBER")
    {
        Caption = 'MM_CREATE_MEMBER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Create Member";
    }
    value(115; CHANGE_LOCATION)
    {
        Caption = 'CHANGE_LOCATION', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Change Loc.";
    }
    value(116; OPEN_CASH_DRAWER)
    {
        Caption = 'OPEN_CASH_DRAWER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Open Drawer";
    }
    value(117; "SPLIT_WAITER_PAD")
    {
        Caption = 'SPLIT_WAITER_PAD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE POSAction: Split Wa.";
    }
    value(118; "SHOW_RET_AMT_DIALOG")
    {
        Caption = 'SHOW_RET_AMT_DIALOG', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Ret.Amt.Dialog";
    }
    value(119; TM_TICKETMGMT_3)
    {
        Caption = 'TM_TICKETMGMT_3', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR TM POS Action: Ticket Mgt.";
    }
    value(120; CHANGE_BIN)
    {
        Caption = 'CHANGE_BIN', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Change Bin";
    }
    value(121; VATREFUSION)
    {
        Caption = 'VATREFUSION', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction: VAT Refusion";
    }
    value(122; MPOS_API)
    {
        Caption = 'MPOS_API', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Mpos API";
    }
    value(123; SETTAXAREACODE)
    {
        Caption = 'SETTAXAREACODE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction: Set TaxAreaCode";
    }
    value(124; TAX_FREE)
    {
        Caption = 'TAX_FREE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Tax Free";
    }
    value(125; "SEND_RECEIPT")
    {
        Caption = 'SEND_RECEIPT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Send Receipt";
    }
    value(126; SET_ACTIVE_EVENT)
    {
        Caption = 'SET_ACTIVE_EVENT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Chg.Actv.Event";
    }
    value(127; TM_SEATING)
    {
        Caption = 'TM_SEATING', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR TM POS Action - Seating";
    }
    value(128; PRINT_TEMPLATE)
    {
        Caption = 'PRINT_TEMPLATE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Print Template";
    }
    value(129; QUICK_LOGIN)
    {
        Caption = 'QUICK_LOGIN', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Quick Login";
    }
    value(130; INSERT_TABLE_BUZZER)
    {
        Caption = 'INSERT_TABLE_BUZZER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: TableBuzzerNo";
    }
    value(131; PRINT_TMPL_POSTED)
    {
        Caption = 'PRINT_TMPL_POSTED', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Prnt Post.Exch";
    }
    value(132; CHANGE_RESP_CENTER)
    {
        Caption = 'CHANGE_RESP_CENTER', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAct:Change Resp. Center";
    }
    value(133; RV_SELECT_TABLE)
    {
        Caption = 'RV_SELECT_TABLE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE RVA: Select Table";
    }
    value(134; RV_NEW_WAITER_PAD)
    {
        Caption = 'RV_NEW_WAITER_PAD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE RVA: New WPad";
    }
    value(135; RV_GET_WAITER_PAD)
    {
        Caption = 'RV_GET_WAITER_PAD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE RVA: Get WPad";
    }
    value(136; MM_MEMBER_ARRIVAL)
    {
        Caption = 'MM_MEMBER_ARRIVAL', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR MM POS Action: Member Arr.";
    }
    value(137; MM_MEMBER_BACKEND)
    {
        Caption = 'MM_MEMBER_BACKEND', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR MM POS Action: BackEnd Fun";
    }
    value(138; RV_SET_PARTYSIZE)
    {
        Caption = 'RV_SET_PARTYSIZE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE RVA: Set No.of Guests";
    }
    value(139; RV_SAVE_LAYOUT)
    {
        Caption = 'RV_SAVE_LAYOUT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE RVA: Save Layout";
    }
    value(140; "RV_RUN_W/PAD_ACTION")
    {
        Caption = 'RV_RUN_W/PAD_ACTION', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE RVA: Run WPad Act.";
    }
    value(141; "RV_SET_R-VIEW")
    {
        Caption = 'RV_SET_R-VIEW', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE RVA: Set R-View";
    }
    value(142; RV_SET_TABLE_STATUS)
    {
        Caption = 'RV_SET_TABLE_STATUS', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE RVA: Set Table Status";
    }
    value(143; "RV_SET_W/PAD_STATUS")
    {
        Caption = 'RV_SET_W/PAD_STATUS', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE RVA: Set WPad Status";
    }
    value(144; SAVE_TO_WAITER_PAD)
    {
        Caption = 'SAVE_TO_WAITER_PAD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE POSAction: Save2Wa.";
    }
    value(145; LOGIN)
    {
        Caption = 'LOGIN', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action - Login";
    }
    value(146; "SETTAXLIABLE")
    {
        Caption = 'SETTAXLIABLE', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction: Set Tax Liable";
    }
    value(147; PRINT_WAITER_PAD)
    {
        Caption = 'PRINT_WAITER_PAD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE POSAction: Print Wa.";
    }
    value(148; "RUN_W/PAD_ACTION")
    {
        Caption = 'RUN_W/PAD_ACTION', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE POSAction: Run Wa.Act";
    }
    value(149; NEW_WAITER_PAD)
    {
        Caption = 'NEW_WAITER_PAD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE POSAction: New Wa.";
    }
    value(156; SHOW_WAITER_PAD)
    {
        Caption = 'SHOW_WAITER_PAD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE POSAction: Show Wa.";
    }
    value(155; GET_WAITER_PAD)
    {
        Caption = 'GET_WAITER_PAD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR NPRE POSAction: Get Wa.";
    }
    value(150; "RUN_ITEM_ADDONS")
    {
        Caption = 'RUN_ITEM_ADDONS', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Run Item AddOn";
    }
    value(151; START_POS)
    {
        Caption = 'START_POS', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Start POS";
    }
    value(152; RAPTOR)
    {
        Caption = 'RAPTOR', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Raptor";
    }
    value(157; HYPERLINK)
    {
        Caption = 'HYPERLINK', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action - Hyperlink";
    }
    value(158; PRINT_EXCH_LABEL)
    {
        Caption = 'PRINT_EXCH_LABEL', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: PrintExchLabel";
    }
    value(159; SCAN_COUPON)
    {
        Caption = 'SCAN_COUPON', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Scan Coupon";
    }
    value(164; MM_MEMBER_LOYALTY)
    {
        Caption = 'MM_MEMBER_LOYALTY', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR MM POS Action: Member Loy.";
    }
    value(161; RUNPAGE_ITEM)
    {
        Caption = 'RUNPAGE_ITEM', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: RunPage (Item)";
    }
    value(162; ITEMCARD)
    {
        Caption = 'ITEMCARD', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Item Card";

    }
    value(163; MM_MEMBERMGMT_WF3)
    {
        Caption = 'MM_MEMBERMGMT_WF3', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Member Mgt WF3";
    }
    value(165; M_SCANDITITEMINFO)
    {
        Caption = 'M_SCANDITITEMINFO', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR MPOS Action Scan Item Info";

    }
    value(166; M_SCANDITFINDITEM)
    {
        Caption = 'M_SCANDITFINDITEM', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR MPOS Action ScanFind Item";
    }
    value(167; M_SCANDITSCAN)
    {
        Caption = 'M_SCANDITSCAN', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR MPOS Action Scandit Scan";
    }
    value(168; ASSIGN_SERIAL_NO)
    {
        Caption = 'ASSIGN_SERIAL_NO', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Set Serial No";
    }
    value(180; "RS_INSERT_CUST_IDENT")
    {
        Caption = 'INSERT_CUST_IDENT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action - Insert CustId";
    }
    value(181; "RS_INSERT_ADD_CUST_F")
    {
        Caption = 'INSERT_ADD_CUST_F', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action - Ins. AddCustF";
    }
    value(182; "RS_AUDIT_LOOKUP")
    {
        Caption = 'RS_AUDIT_LOOKUP', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: RSAudit Lookup";
    }
    value(183; "CALCULATE_DISCOUNTS")
    {
        Caption = 'CALCULATE_DISCOUNTS', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Calc Discounts";
    }
    value(169; DISCOUNT)
    {
        Caption = 'DISCOUNT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action - Discount";
    }
    value(6014600; BALANCE_V4)
    {
        Caption = 'BALANCE_V4', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: EndOfDay V4";
    }
    value(6059935; VOUCHER_PAYMENT)
    {
        Caption = 'VOUCHER_PAYMENT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action Scan Voucher2";
    }
    value(6059939; FOREIGN_VOUCHER_PMT)
    {
        Caption = 'FOREIGN_VOUCHER_PMT', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSAction ForeignVoucher";
    }
    value(6150803; ZOOM)
    {
        Caption = 'ZOOM', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POS Action: Zoom";
    }
    value(6151324; INPUTBOX_JSON)
    {
        Caption = 'INPUTBOX_JSON', Locked = true, MaxLength = 20;
        Implementation = "NPR IPOS Workflow" = "NPR POSActionInputBoxJson";
    }
}