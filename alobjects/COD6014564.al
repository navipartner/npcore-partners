codeunit 6014564 "Report - Balancing Ticket"
{
    // Report - Balancing Ticket
    //  Work started by Jerome Cader on 13-03-2013
    //  Implements the functionality of the Balancing Ticket report.
    //  Fills a temp buffer using the CU "Line Print Buffer Mgt.".
    // 
    //  Only functionlity for extending the Sales Ticket Print should
    //  be put here. Nothing else.
    // 
    //  The individual functions reprensents sections in the report with
    //  ID 6060108.
    // 
    //  The function GetRecords, applies table filters to the necesarry data
    //  elements of the report, base on the codeunits run argument Rec: Record "Audit Roll".
    // 
    // NPR4.11/MMV/20150309 CASE 207268 "PrintPaymentTypePOS" now calculates the amount paid in each currency and no longer shows a total in DKK.
    //                                  "PrintPTPForeignCurrency" is no longer used.
    // NPR4.11/MMV/20150619 CASE 216240 Added total sales line.
    // NPR4.12/MMV/20150702 CASE 216240 Changed how total sales line (previous change) work.
    // NPR4.15/MMV/20150917 CASE 222832 Added foreign credit vouchers and foreign gift vouchers to total amount paid.
    // NPR4.18/MMV/20151119 CASE 227685 Updated PaymentOtherCreditCardsTxt textconstant.
    // NPR4.18/MMV/20151125 CASE 227928 Updated english text constants.
    //                                  Use LCY code from General Ledger Setup instead of hardcoded 'Kroner' to write currency.
    // NPR4.18/MMV/20151201 CASE 228246 Wrong dataitem was used to calculate total for 'Cash terminal' section.
    // NPR4.18/MMV/20151210 CASE 228246 Removed checksum & rounding from bottom of print.
    // NPR5.26/MMV /20160916 CASE 249408 Moved control codes from captions to in-line strings.
    // NPR5.29/MMV /20161122 CASE 259034 Split header text.
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.36/TJ  /20170905 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.38/JLK /20171107 CASE 295368 Corrected ENU Caption of MiscellaneouspaymentsTxt2
    // NPR5.39/JLK /20180219 CASE 305293 Corrected ENU Caption of MiscellaneouspaymentsTxt
    // NPR5.48/BHR /20181120 CASE 329505 Add correct amount pertaining to different types of sales document

    TableNo = "Audit Roll";

    trigger OnRun()
    begin
        RPLinePrintMgt.SetAutoLineBreak(true);
        AuditRoll.CopyFilters(Rec);
        GetRecords;

        RPLinePrintMgt.SetFont('A11');
        for CurrPageNo := 1 to 1 do begin
          // 0. AuditRoll
          AuditRollOnAfterGetRecord();
          PrintHeader;
          PrintAuditRollBody();
          // 1. Period
          PrintPeriod();
          // 0. Payment Type POS
          PrintPaymentTypePOS();
          // 0. Payment Type POS
          PrintPTPGiftVoucher();
          // 0. Payment Type POS
          PrintPTPForeignGiftVoucher();
          // 0. Payment Type POS
          PrintPTPCreditVoucher();
          // 0. Payment Type POS
          PrintPTPForeignCreditVoucher();
          // 0. Payment Type POS
          PrintPTPTerminalCard();
          // 0. Payment Type POS
          PrintPTPOtherCreditCards();
          // 0. Payment Type POS
          PrintPTPManualCards();
          // 0. Payment Type POS
          PrintPTPTerminal();
          // 0. Payment Type POS
          //-NPR4.11
          //PrintPTPForeignCurrency();
          //+NPR4.11
            // 0.  G/L Account
          PrintGLGiftVoucherDiscAcc();
          // 0. Integer
          PrintInteger();
          // 0. G/L Account
          PrintGLAccount();
          // 0. Payment Type POS
          PrintPTPPaymentTypeCounting();
          PrintFooter;
        end;
    end;

    var
        RPLinePrintMgt: Codeunit "RP Line Print Mgt.";
        AuditRoll: Record "Audit Roll";
        AuditRoll1: Record "Audit Roll";
        AuditRoll2: Record "Audit Roll";
        CompanyInformation: Record "Company Information";
        RetailSetup: Record "Retail Setup";
        Salesperson: Record "Salesperson/Purchaser";
        CurrPageNo: Integer;
        OpeningCashAmount: Decimal;
        CashChangeNetAmount: Decimal;
        DankortChangeNetAmount: Decimal;
        VisaCardChangeNetAmount: Decimal;
        OtherCreditCardsNetChangeAmount: Decimal;
        TerminalChangeNetAmount: Decimal;
        GiftVoucherChangeNetAmount: Decimal;
        CreditVoucherChangeNetAmount: Decimal;
        BankDepositAmount: Decimal;
        RegisterDifferenceAmount: Decimal;
        PositiveChangeAmount: Decimal;
        NegativeChangeAmount: Decimal;
        PositiveBalanceAmount: Decimal;
        NegativeBalanceAmount: Decimal;
        CreditCardBalanceAmount: Decimal;
        GrossTurnover: Decimal;
        NetTurnover: Decimal;
        COGSAmount: Decimal;
        TotalDiscountAmount: Decimal;
        GrossProfitMargin: Decimal;
        DiscountPct: Decimal;
        CustomDiscountAmount: Decimal;
        QuantityDiscountAmount: Decimal;
        MixDiscountAmount: Decimal;
        CampaignDiscountAmount: Decimal;
        CustomDiscountPct: Decimal;
        QuantityDiscountPct: Decimal;
        MixDiscountPct: Decimal;
        CampaignDiscountPct: Decimal;
        Calculate: Boolean;
        DebitSaleAmount: Decimal;
        LineDiscountAmount: Decimal;
        LineDiscountPct: Decimal;
        Register2: Record Register;
        HeaderText: Text[50];
        LastSalesTicketNo: Code[30];
        NoOfSalesTransactions: Integer;
        OpenTime: Time;
        CloseTime: Time;
        AuditRoll3: Record "Audit Roll";
        DepositAmountInclVAT: Decimal;
        PaymentAmountInclVAT: Decimal;
        LastRegister: Record Register;
        TotalReturnAmount: Decimal;
        TotalNoOfSales: Integer;
        FromSalesTicketNo: Code[10];
        ToSalesTicketNo: Code[10];
        NoOfGiftVoucherSales: Decimal;
        CreditVoucherMovementAmount: Decimal;
        MiscellaneousPaymentAmount: Decimal;
        ReceivedCashAmount: Decimal;
        BalancedCashAmount: Decimal;
        ChequeAmount: Decimal;
        TotalPaymentAmount: Decimal;
        CountTotalFooter: Decimal;
        GiftVoucherDebitAmount: Decimal;
        CancelledTransactions: Integer;
        DebitSaleAmountNew: Decimal;
        Register: Record Register;
        DetailedCounting: Boolean;
        ChangeCashAmount: Decimal;
        GlobalPeriod: Record Period;
        ShowHeader: Boolean;
        Text10600002: Label 'Department Code';
        Text10600003: Label 'Register No.';
        Text10600004: Label 'Opening Hours';
        Text10600006: Label 'Sales Ticket No.';
        Text10600007: Label 'Closing Date';
        Text10600010: Label 'Register closed by';
        TurnoverTitleTxt: Label 'Turnover:';
        TurnoverTxt: Label 'Turnover';
        DebitSalesTxt: Label 'Debit Sales';
        Period: Record Period;
        PaymentTypePOS: Record "Payment Type POS";
        GiftVoucherPaymentTypePOS: Record "Payment Type POS";
        ForeignGiftVoucherPaymentTypePOS: Record "Payment Type POS";
        CreditVoucherPaymentTypePOS: Record "Payment Type POS";
        ForeignCreditVoucherPaymentTypePOS: Record "Payment Type POS";
        TerminalCard: Record "Payment Type POS";
        OtherCreditCards: Record "Payment Type POS";
        ManualCards: Record "Payment Type POS";
        Terminal: Record "Payment Type POS";
        ForeignCurrency: Record "Payment Type POS";
        GiftVoucherDiscountAccount: Record "G/L Account";
        GLAccount: Record "G/L Account";
        PaymentTypeCounting: Record "Payment Type POS";
        PeriodLine: Record "Period Line";
        TotalSalesTxt: Label 'Total Sales';
        GiftVoucherMovementTxt: Label 'Gift Voucher Movement';
        CreditVoucherMovementTxt: Label 'Credit Voucher Movement';
        MiscellaneouspaymentsTxt: Label 'Pay In';
        MiscellaneouspaymentsTxt2: Label 'Pay Out';
        SumTxt: Label 'Sum';
        PaymentTypeTitleTxt: Label 'Balanced:';
        OpeningCashBalanceTxt: Label 'Opening cash';
        CashChangeNetAmountTxt: Label 'Net cash change';
        TotalCurrentCashTxt: Label 'Total current cash';
        CountedTxt: Label 'Counted';
        RegisterDifferenceTxt: Label 'Register Difference';
        NextDayOpeningCashTxt: Label 'Next Day Opening Cash';
        TransfertoBankTxt: Label 'Transfer to Bank';
        ExchangeBoxTxt: Label 'Exchange Box';
        OtherPaymentTypeTitleTxt: Label 'Other Payment Type:';
        OtherCurrencyPaymentTxt: Label 'Other Currency payments:';
        PaymentGiftvoucherTxt: Label 'Gift Voucher Payment:';
        PaymentForeignGiftVoucherTxt: Label 'Foreign Gift Voucher:';
        PaymentCreditVoucherTxt: Label 'Credit Voucher Payment:';
        PaymentTypePOSTotal: Decimal;
        PaymentForeignCreditVoucherTxt: Label 'Payment Type: Foreign credit voucher';
        PaymentTerminalTxt: Label 'Payment Type: Terminal Card';
        PaymentOtherCreditCardsTxt: Label 'Payment Type: Other Credit Cards ';
        PaymentManualCardsTxt: Label 'Payment Type: Manual Cards';
        PaymentTerminalOtherTxt: Label 'Payment Type: Terminal Other';
        PaymentForeignCurrencyTxt: Label 'Foreign Currency:';
        PayOutGVDiscountTxt: Label 'Gift Voucher Discount:';
        PayOutDebitSalesTxt: Label 'Debit Sales:';
        PayOutDebitSalesGVTxt: Label 'Debit Sales/Gift Voucher:';
        PayOutReturnSaleTxt: Label 'Return Sale:';
        PayOutGLTxt: Label 'PayOut:';
        PaymentCountingDetailsTxt: Label 'Counting Details:';
        DescriptionTxt: Label 'Description';
        NothingCountedTxt: Label 'Nothing counted';
        MaxIteration: Integer;
        PLCountUnitTxt: Label 'Count Unit:';
        PLQtyTxt: Label 'Qty:';
        PLTotalTxt: Label 'Total:';
        PLTOTALTxt2: Label 'TOTAL:';
        HeaderPrinted: Boolean;
        InvoicedSalesTxt: Label 'Debit Sales';
        ReturnedSalesTxt: Label 'Returned Sales';
        OrderedSalesTxt: Label 'Sales Orders';
        InvoiceAmount: Decimal;
        OrderAmount: Decimal;
        CreditAmount: Decimal;
        ReturnAmount: Decimal;
        OthersTxt: Label 'Others:';
        CashSalesTxt: Label 'Cash Sales';

    procedure AuditRollOnAfterGetRecord()
    begin
        // Audit Roll - OnAfterGetRecord()

        Register.Get(AuditRoll."Register No.");
        if Salesperson.Get(AuditRoll."Salesperson Code") then;

        GlobalPeriod.SetRange("Register No.",AuditRoll."Register No.");
        GlobalPeriod.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
        GlobalPeriod.Find('+');

        HeaderText := Register.Description;

        AuditRoll1.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type",Type);
        AuditRoll1.SetRange("Register No.",AuditRoll."Register No.");
        AuditRoll1.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
        AuditRoll1.SetRange("Sale Type",AuditRoll1."Sale Type"::Comment);
        AuditRoll1.SetRange(Type,AuditRoll1.Type::"Open/Close");
        if AuditRoll1.Find('-') then begin
          AuditRoll1.SetRange("Sales Ticket No.");
          AuditRoll1.Next(-1);
        end;

        NetTurnover := GlobalPeriod."Net Turnover (LCY)";
        GrossTurnover := GlobalPeriod."Sales (LCY)";
        TotalDiscountAmount := GlobalPeriod."Total Discount (LCY)";
        COGSAmount := GlobalPeriod."Net Cost (LCY)";
        CampaignDiscountAmount := GlobalPeriod."Campaign Discount (LCY)";
        MixDiscountAmount := GlobalPeriod."Mix Discount (LCY)";
        QuantityDiscountAmount := GlobalPeriod."Quantity Discount (LCY)";
        CustomDiscountAmount := GlobalPeriod."Custom Discount (LCY)";
        LineDiscountAmount := GlobalPeriod."Line Discount (LCY)";
        GrossProfitMargin := GlobalPeriod."Profit %";
        //-NPR5.48 [329505]
        InvoiceAmount := GlobalPeriod."Invoice Amount";
        OrderAmount := GlobalPeriod."Order Amount";
        CreditAmount := GlobalPeriod."Return Amount";
        ReturnAmount := GlobalPeriod."Credit Memo Amount";
        //+NPR5.48 [329505]
        if GrossTurnover <> 0 then begin
          CustomDiscountPct := CustomDiscountAmount * 100 / GrossTurnover;
          QuantityDiscountPct := QuantityDiscountAmount * 100 / GrossTurnover;
          MixDiscountPct := MixDiscountAmount * 100 / GrossTurnover;
          CampaignDiscountPct := CampaignDiscountAmount * 100 / GrossTurnover;
          LineDiscountPct := LineDiscountAmount * 100 / GrossTurnover;
          DiscountPct := TotalDiscountAmount * 100 / GrossTurnover;
        end;

        OpenTime := GlobalPeriod."Opening Time";
        CloseTime := GlobalPeriod."Closing Time";
        NoOfSalesTransactions := GlobalPeriod."Sales (Qty)";
        CancelledTransactions := GlobalPeriod."Cancelled Sales";
        LastSalesTicketNo := GlobalPeriod."Sales Ticket No.";

        PositiveChangeAmount := 0;
        NegativeChangeAmount := 0;

        TotalNoOfSales := GlobalPeriod."Negative Sales Count";//globalPeriod.NegSalesQty;
        TotalReturnAmount := GlobalPeriod."Negative Sales Amount";//globalPeriod.NegSalesAmt;

        OpeningCashAmount := GlobalPeriod."Opening Cash";
        BalanceUpdate(OpeningCashAmount,OpeningCashAmount > 0);

        CashChangeNetAmount := GlobalPeriod."Net. Cash Change";
        BalanceUpdate(CashChangeNetAmount,CashChangeNetAmount > 0);

        CreditVoucherChangeNetAmount := GlobalPeriod."Net. Credit Voucher Change";

        GiftVoucherChangeNetAmount := GlobalPeriod."Net. Gift Voucher Change";
        BalanceUpdate(GiftVoucherChangeNetAmount,GiftVoucherChangeNetAmount > 0);

        TerminalChangeNetAmount := GlobalPeriod."Net. Terminal Change";
        BalanceUpdate(TerminalChangeNetAmount,TerminalChangeNetAmount > 0);

        DankortChangeNetAmount := GlobalPeriod."Net. Dankort Change";
        BalanceUpdate(DankortChangeNetAmount,DankortChangeNetAmount > 0);

        VisaCardChangeNetAmount := GlobalPeriod."Net. VisaCard Change";
        BalanceUpdate(VisaCardChangeNetAmount,VisaCardChangeNetAmount > 0);

        OtherCreditCardsNetChangeAmount := GlobalPeriod."Net. Change Other Cedit Cards";
        BalanceUpdate(OtherCreditCardsNetChangeAmount,OtherCreditCardsNetChangeAmount > 0);

        NoOfGiftVoucherSales := GlobalPeriod."Gift Voucher Sales";
        BalanceUpdate(NoOfGiftVoucherSales,NoOfGiftVoucherSales > 0);

        CreditVoucherMovementAmount := GlobalPeriod."Credit Voucher issuing";
        BalanceUpdate(CreditVoucherMovementAmount,CreditVoucherMovementAmount > 0);

        ReceivedCashAmount := GlobalPeriod."Cash Received";
        BalanceUpdate(ReceivedCashAmount,ReceivedCashAmount > 0);

        MiscellaneousPaymentAmount := GlobalPeriod."Pay Out";
        BalanceUpdate(MiscellaneousPaymentAmount,MiscellaneousPaymentAmount > 0);

        DebitSaleAmount := GlobalPeriod."Debit Sale";
        DebitSaleAmountNew := GlobalPeriod."Debit Sale";
        BalanceUpdate(DebitSaleAmount,DebitSaleAmount > 0);

        GiftVoucherDebitAmount := GlobalPeriod."Gift Voucher Debit";
        BalanceUpdate(GiftVoucherDebitAmount,GiftVoucherDebitAmount > 0);

        ChangeCashAmount := GlobalPeriod."Change Register";
        BankDepositAmount := GlobalPeriod."Deposit in Bank";
        RegisterDifferenceAmount := GlobalPeriod.Difference;
        CreditCardBalanceAmount := OtherCreditCardsNetChangeAmount + VisaCardChangeNetAmount + DankortChangeNetAmount + TerminalChangeNetAmount;
        BalancedCashAmount := GlobalPeriod."Balanced Cash Amount";

        if RegisterDifferenceAmount < 0 then begin
          PositiveBalanceAmount := PositiveChangeAmount + (-RegisterDifferenceAmount);
          NegativeBalanceAmount := NegativeChangeAmount + BankDepositAmount + GlobalPeriod."Balanced Cash Amount";
        end else begin
          PositiveBalanceAmount := PositiveChangeAmount;
          NegativeBalanceAmount := NegativeChangeAmount + BankDepositAmount + RegisterDifferenceAmount + GlobalPeriod."Balanced Cash Amount";
        end;
        if CreditCardBalanceAmount < 0 then
          PositiveBalanceAmount := PositiveBalanceAmount + (-CreditCardBalanceAmount)
        else
          NegativeBalanceAmount := NegativeBalanceAmount + CreditCardBalanceAmount;

        //++003
        // Commented code.JC
        //--003

        //++004
        // Commented code.JC
        //--004

        // ohm - 10/10/06
        AuditRoll3.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type",Type);
        if not (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then
          AuditRoll3.SetRange("Register No.",AuditRoll."Register No.");
        AuditRoll3.SetFilter("Sales Ticket No.",'%1..%2',AuditRoll1."Sales Ticket No.",AuditRoll."Sales Ticket No.");

        //TilgodeInd
        AuditRoll3.SetRange(Type,AuditRoll3.Type::"G/L");
        AuditRoll3.SetRange("Sale Type",AuditRoll3."Sale Type"::Deposit);
        if AuditRoll3.Find('-') then
          repeat
            if AuditRoll3."Credit voucher ref." <> '' then
              DepositAmountInclVAT := AuditRoll3."Amount Including VAT"
          until AuditRoll3.Next = 0;

        //TilgodeUd
        AuditRoll3.SetRange(Type,AuditRoll3.Type::Payment);
        AuditRoll3.SetRange("Sale Type",AuditRoll3."Sale Type"::Payment);
        if AuditRoll3.Find('-') then
          repeat
            if AuditRoll3."Credit voucher ref." <> '' then
              PaymentAmountInclVAT := AuditRoll3."Amount Including VAT"
          until AuditRoll3.Next = 0;

        if (DepositAmountInclVAT - PaymentAmountInclVAT) > 0 then
          BalanceUpdate(DepositAmountInclVAT - PaymentAmountInclVAT,true)
        else
          BalanceUpdate(DepositAmountInclVAT - PaymentAmountInclVAT,false);
        //--003

        FromSalesTicketNo := AuditRoll1."Sales Ticket No.";
        ToSalesTicketNo := AuditRoll."Sales Ticket No.";

        //Bev�gPos := 0;
        //Bev�gNeg := 0;

        ChequeAmount := GlobalPeriod.Cheque;
        BalanceUpdate(ChequeAmount,ChequeAmount > 0);
    end;

    procedure PrintHeader()
    begin
        // Audit Roll, Header(1)
        RPLinePrintMgt.SetFont('B21');
        RPLinePrintMgt.SetBold(true);
        RPLinePrintMgt.AddLine(HeaderText);
        RPLinePrintMgt.SetPadChar(' ');
    end;

    procedure PrintAuditRollBody()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        // Audit Roll, Body(2)
        RPLinePrintMgt.SetFont('B21');
        RPLinePrintMgt.SetBold(false);
        //-NPR5.29 [259034]
        //Printer.AddLine(Text10600010+' '+Salesperson.Name);
        RPLinePrintMgt.AddLine(Text10600010);
        RPLinePrintMgt.AddLine(Salesperson.Name);
        //+NPR5.29 [259034]

        RPLinePrintMgt.SetFont('A11');
        RPLinePrintMgt.SetBold(false);
        RPLinePrintMgt.AddTextField(1,0,Text10600002);
        RPLinePrintMgt.AddTextField(2,2,AuditRoll."Department Code");
        RPLinePrintMgt.AddTextField(1,0,Text10600003);
        RPLinePrintMgt.AddTextField(2,2,AuditRoll."Register No.");
        RPLinePrintMgt.AddTextField(1,0,Text10600006);
        RPLinePrintMgt.AddTextField(2,2,AuditRoll."Sales Ticket No.");
        RPLinePrintMgt.AddTextField(3,2,Format(NoOfSalesTransactions) + ' / ' + Format(CancelledTransactions));
        RPLinePrintMgt.AddTextField(1,0,Text10600007);
        RPLinePrintMgt.AddDateField(2,2, AuditRoll."Sale Date");
        RPLinePrintMgt.AddTextField(1,0,Text10600004);
        RPLinePrintMgt.AddTextField(2,2,Format(OpenTime) + '/' + Format(CloseTime));
        RPLinePrintMgt.AddTextField(1,0,AuditRoll.FieldCaption(AuditRoll."Money bag no."));
        RPLinePrintMgt.AddTextField(2,2,AuditRoll."Money bag no.");
        RPLinePrintMgt.SetPadChar('_');
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetPadChar(' ');
        //-NPR5.48 [329505]
        //RPLinePrintMgt.SetFont('B21');
        //RPLinePrintMgt.SetBold(TRUE);
        //RPLinePrintMgt.AddLine(TurnoverTitleTxt);
        //+NPR5.48 [329505]

        RPLinePrintMgt.SetFont('A11');
        RPLinePrintMgt.SetBold(false);
        //-NPR5.48 [329505]
        //RPLinePrintMgt.AddTextField(1,0,TurnoverTxt);
        RPLinePrintMgt.AddTextField(1,0,CashSalesTxt);
        //+NPR5.48 [329505]
        RPLinePrintMgt.AddDecimalField(2,2,GrossTurnover);

        //-NPR5.48 [329505]
        //RPLinePrintMgt.AddLine('');

        //// Audit Roll, Body(3)

        //RPLinePrintMgt.AddTextField(1,0,DebitSalesTxt);
        //RPLinePrintMgt.AddDecimalField(2,2,DebitSaleAmountNew);
        //RPLinePrintMgt.AddLine('');
        // Audit Roll, Body(3)
        RPLinePrintMgt.AddTextField(1,0,DebitSalesTxt);
        RPLinePrintMgt.AddDecimalField(2,2,InvoiceAmount);

        RPLinePrintMgt.AddTextField(1,0,ReturnedSalesTxt);
        RPLinePrintMgt.AddDecimalField(2,2,ReturnAmount+CreditAmount);

        //+NPR5.48 [329505]

        // Audit Roll, Body(4)
        RPLinePrintMgt.AddTextField(1,0,TotalSalesTxt);
        //-NPR5.48 [329505]
        //RPLinePrintMgt.AddDecimalField(2,2,DebitSaleAmountNew + GrossTurnover);
        RPLinePrintMgt.AddDecimalField(2,2,InvoiceAmount + ReturnAmount + CreditAmount + GrossTurnover);
        //+NPR5.48 [329505]
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.AddTextField(1,0,GiftVoucherMovementTxt);
        RPLinePrintMgt.AddDecimalField(2,2,NoOfGiftVoucherSales);
        RPLinePrintMgt.AddTextField(1,0,CreditVoucherMovementTxt);
        RPLinePrintMgt.AddDecimalField(2,2,CreditVoucherMovementAmount);
        RPLinePrintMgt.AddTextField(1,0,MiscellaneouspaymentsTxt);
        RPLinePrintMgt.AddDecimalField(2,2,ReceivedCashAmount);
        RPLinePrintMgt.AddTextField(1,0,MiscellaneouspaymentsTxt2);
        RPLinePrintMgt.AddDecimalField(2,2,MiscellaneousPaymentAmount);
        RPLinePrintMgt.SetPadChar('_');
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetPadChar(' ');

        RPLinePrintMgt.AddTextField(1,0,SumTxt);
        //-NPR5.48 [329505]
        //RPLinePrintMgt.AddDecimalField(2,2,CreditVoucherMovementAmount + NoOfGiftVoucherSales + ReceivedCashAmount - MiscellaneousPaymentAmount + GrossTurnover + DebitSaleAmountNew);
        RPLinePrintMgt.AddDecimalField(2,2,CreditVoucherMovementAmount + NoOfGiftVoucherSales + ReceivedCashAmount - MiscellaneousPaymentAmount + GrossTurnover + InvoiceAmount + ReturnAmount + CreditAmount);

        RPLinePrintMgt.SetPadChar('_');
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetPadChar(' ');
        RPLinePrintMgt.SetFont('B21');
        RPLinePrintMgt.SetBold(true);
        RPLinePrintMgt.AddLine(OthersTxt);
        RPLinePrintMgt.SetFont('A11');
        RPLinePrintMgt.SetBold(false);
        RPLinePrintMgt.AddTextField(1,0,OrderedSalesTxt);
        RPLinePrintMgt.AddDecimalField(2,2,OrderAmount);
        RPLinePrintMgt.AddLine('');
        //+NPR5.48 [329505]
        RPLinePrintMgt.SetPadChar('_');
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetPadChar(' ');

        // Audit Roll, Body(5)
        RPLinePrintMgt.SetFont('B21');
        RPLinePrintMgt.SetBold(true);
        RPLinePrintMgt.AddLine(PaymentTypeTitleTxt);
        //-NPR4.18
        //Printer.AddLine(KronerTxt);
        if GLSetup.Get then
          RPLinePrintMgt.AddLine(GLSetup."LCY Code");
        //+NPR4.18

        RPLinePrintMgt.SetFont('A11');
        RPLinePrintMgt.SetBold(false);
        RPLinePrintMgt.AddTextField(1,0,OpeningCashBalanceTxt);
        RPLinePrintMgt.AddDecimalField(2,2,OpeningCashAmount);
        RPLinePrintMgt.AddTextField(1,0,CashChangeNetAmountTxt);
        RPLinePrintMgt.AddDecimalField(2,2,CashChangeNetAmount);
        RPLinePrintMgt.AddTextField(1,0,TotalCurrentCashTxt);
        RPLinePrintMgt.AddDecimalField(2,2,CashChangeNetAmount + OpeningCashAmount);

        RPLinePrintMgt.AddTextField(1,0,CountedTxt);
        RPLinePrintMgt.AddDecimalField(2,2,BalancedCashAmount);
        RPLinePrintMgt.AddTextField(1,0,RegisterDifferenceTxt);
        RPLinePrintMgt.AddDecimalField(2,2,RegisterDifferenceAmount);
        RPLinePrintMgt.SetPadChar('_');
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetPadChar(' ');

        RPLinePrintMgt.AddTextField(1,0,NextDayOpeningCashTxt);
        RPLinePrintMgt.AddDecimalField(2,2,AuditRoll."Closing Cash");
        RPLinePrintMgt.AddTextField(1,0,TransfertoBankTxt);
        RPLinePrintMgt.AddDecimalField(2,2,BankDepositAmount);

        RPLinePrintMgt.SetFont('B21');
        RPLinePrintMgt.SetBold(false);
        RPLinePrintMgt.AddTextField(1,0,ExchangeBoxTxt);
        RPLinePrintMgt.AddDecimalField(2,2,ChangeCashAmount);
        RPLinePrintMgt.SetPadChar('_');
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetPadChar(' ');
    end;

    procedure PrintPeriod()
    begin
        // Period - Properties
        Period.SetCurrentKey("Register No.","Sales Ticket No.","No.");
        Period.Ascending(true);
        Period.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
        Period.SetRange("Register No.",AuditRoll."Register No.");
        if Period.FindSet then
          repeat
          until Period.Next = 0;

        // Period, Footer(1)
        RPLinePrintMgt.SetFont('A11');
        RPLinePrintMgt.SetBold(false);
        //-NPR4.12
        RPLinePrintMgt.AddTextField(1,0,Period.FieldCaption(Period."Sales (Qty)"));
        RPLinePrintMgt.AddDecimalField(2,2,Period."Sales (Qty)");
        //+NPR4.12
        RPLinePrintMgt.AddTextField(1,0,Period.FieldCaption(Period."No. Of Goods Sold"));
        RPLinePrintMgt.AddDecimalField(2,2,Period."No. Of Goods Sold");
        RPLinePrintMgt.AddTextField(1,0,Period.FieldCaption(Period."No. Of Cash Receipts"));
        RPLinePrintMgt.AddDecimalField(2,2,Period."No. Of Cash Receipts");
        RPLinePrintMgt.AddTextField(1,0,Period.FieldCaption(Period."No. Of Cash Box Openings"));
        RPLinePrintMgt.AddDecimalField(2,2,Period."No. Of Cash Box Openings");
        RPLinePrintMgt.AddTextField(1,0,Period.FieldCaption(Period."No. Of Receipt Copies"));
        RPLinePrintMgt.AddDecimalField(2,2,Period."No. Of Receipt Copies");
        RPLinePrintMgt.AddTextField(1,0,Period.FieldCaption(Period."VAT Info String"));
        RPLinePrintMgt.AddTextField(2,2,Period."VAT Info String");

        RPLinePrintMgt.SetPadChar('_');
        RPLinePrintMgt.AddLine('');
        RPLinePrintMgt.SetPadChar(' ');
    end;

    procedure PrintPaymentTypePOS()
    begin
        // Payment Type POS - OnPreDataItem()
        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
          PaymentTypePOS.SetRange("Date Filter",AuditRoll2."Sale Date");
          Register2.Find('-');
          LastRegister.Find('+');
          PaymentTypePOS.SetRange("Register Filter",Register2."Register No.",LastRegister."Register No.");
          PaymentTypePOS.SetRange("Processing Type",PaymentTypePOS."Processing Type"::"Foreign Currency" );
          PaymentTypePOS.SetFilter("Receipt Filter",'%1..%2',AuditRoll1."Sales Ticket No.",AuditRoll."Sales Ticket No.");
          PaymentTypePOS.CalcFields(PaymentTypePOS."Amount in Audit Roll");
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") then begin
          PaymentTypePOS.SetRange("Date Filter",GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
          PaymentTypePOS.SetRange("Register Filter",GlobalPeriod."Register No.");
          PaymentTypePOS.SetRange("Processing Type",PaymentTypePOS."Processing Type"::"Foreign Currency");
          PaymentTypePOS.SetFilter("Receipt Filter",'%1..%2',GlobalPeriod."Opening Sales Ticket No.",GlobalPeriod."Sales Ticket No.");
          PaymentTypePOS.CalcFields(PaymentTypePOS."Amount in Audit Roll");
        end;

        ShowHeader := true;

        // - Calculate Total
        PaymentTypePOSTotal := 0;
        if PaymentTypePOS.FindSet then
          repeat
            PaymentTypePOS.CalcFields("Amount in Audit Roll");
            PaymentTypePOSTotal := PaymentTypePOSTotal + PaymentTypePOS."Amount in Audit Roll";
          until PaymentTypePOS.Next = 0;
        // + Calculate Total


        // Payment Type POS, Header(1)
        RPLinePrintMgt.SetFont('B21');
        RPLinePrintMgt.SetBold(true);
        RPLinePrintMgt.AddLine(OtherPaymentTypeTitleTxt);

        // Payment Type POS, Body (2) - OnPreSection()
        if ShowHeader and (PaymentTypePOSTotal <> 0) then begin
          ShowHeader := false;
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddLine(OtherCurrencyPaymentTxt);
        end;


        // Payment Type POS, Body (3) - OnPreSection()
        RPLinePrintMgt.SetFont('B11');
        RPLinePrintMgt.SetBold(false);
        if PaymentTypePOS.FindSet then
          repeat
            PaymentTypePOS.CalcFields("Amount in Audit Roll");
            if (PaymentTypePOS."Amount in Audit Roll" <> 0)  then begin
              RPLinePrintMgt.AddTextField(1,0,PaymentTypePOS.Description);
              //-NPR4.11
              if PaymentTypePOS."Fixed Rate" <> 0 then
                RPLinePrintMgt.AddDecimalField(2,2,((PaymentTypePOS."Amount in Audit Roll" * 100) / PaymentTypePOS."Fixed Rate"))
              else
                RPLinePrintMgt.AddDecimalField(2,2,((PaymentTypePOS."Amount in Audit Roll")));
              //+NPR4.11
            end;
          until PaymentTypePOS.Next = 0;

        //-NPR4.11
        // Payment Type POS, Footer (4) - OnPreSection()
        //IF PaymentTypePOSTotal<>0 THEN BEGIN
        //  Printer.SetFont('A11');
        //  Printer.SetBold(FALSE);
        //  Printer.AddDecimalField(2,2,PaymentTypePOSTotal);
        //END;
        //+NPR4.11

        // Payment Type POS - OnPostDataItem()
        TotalPaymentAmount := TotalPaymentAmount + PaymentTypePOSTotal;
    end;

    procedure PrintPTPGiftVoucher()
    begin
        // Gavekort - OnPreDataItem()
        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
          GiftVoucherPaymentTypePOS.SetRange("Date Filter",AuditRoll2."Sale Date");
          Register2.Find('-');
          LastRegister.Find('+');
          GiftVoucherPaymentTypePOS.SetRange("Register Filter",Register2."Register No.",LastRegister."Register No.");
          GiftVoucherPaymentTypePOS.SetRange("Processing Type",GiftVoucherPaymentTypePOS."Processing Type"::"Gift Voucher");
          GiftVoucherPaymentTypePOS.SetFilter("Receipt Filter",'%1..%2',AuditRoll1."Sales Ticket No.",AuditRoll."Sales Ticket No.");
          GiftVoucherPaymentTypePOS.CalcFields(GiftVoucherPaymentTypePOS."Amount in Audit Roll");
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") then begin
          GiftVoucherPaymentTypePOS.SetRange("Date Filter",GlobalPeriod."Date Opened",GlobalPeriod."Date Closed");
          GiftVoucherPaymentTypePOS.SetRange("Register Filter",GlobalPeriod."Register No.");
          GiftVoucherPaymentTypePOS.SetRange("Processing Type",GiftVoucherPaymentTypePOS."Processing Type"::"Gift Voucher");
          GiftVoucherPaymentTypePOS.SetFilter("Receipt Filter",'%1..%2',GlobalPeriod."Opening Sales Ticket No.", GlobalPeriod."Sales Ticket No.");
          GiftVoucherPaymentTypePOS.CalcFields("Amount in Audit Roll");
        end;

        ShowHeader := true;

        // - Calculate Total
        PaymentTypePOSTotal := 0;
        if GiftVoucherPaymentTypePOS.FindSet then
          repeat
            GiftVoucherPaymentTypePOS.CalcFields("Amount in Audit Roll");
            PaymentTypePOSTotal := PaymentTypePOSTotal + GiftVoucherPaymentTypePOS."Amount in Audit Roll";
          until GiftVoucherPaymentTypePOS.Next = 0;
        // + Calculate Total

        // Gavekort, Body (1) - OnPreSection()
        if ShowHeader and (PaymentTypePOSTotal <> 0) then begin
          ShowHeader := false;
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddLine(PaymentGiftvoucherTxt);
        end;

        RPLinePrintMgt.SetFont('B11');
        RPLinePrintMgt.SetBold(false);
        if GiftVoucherPaymentTypePOS.FindSet then
          repeat
            // Gavekort, Body (2) - OnPreSection()
            GiftVoucherPaymentTypePOS.CalcFields("Amount in Audit Roll");
            if (GiftVoucherPaymentTypePOS."Amount in Audit Roll" <> 0) then begin
              RPLinePrintMgt.AddTextField(1,0,GiftVoucherPaymentTypePOS.Description);
              RPLinePrintMgt.AddDecimalField(2,2,GiftVoucherPaymentTypePOS."Amount in Audit Roll");
            end;
          until GiftVoucherPaymentTypePOS.Next = 0;

        // Gavekort, Footer (3) - OnPreSection()
        if PaymentTypePOSTotal <> 0 then begin
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddDecimalField(2,2,PaymentTypePOSTotal);
        end;

        // Gavekort - OnPostDataItem()
        TotalPaymentAmount := TotalPaymentAmount + PaymentTypePOSTotal;
    end;

    procedure PrintPTPForeignGiftVoucher()
    begin
        // Fremmed Gavekort - OnPreDataItem()
        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
          ForeignGiftVoucherPaymentTypePOS.SetRange("Date Filter",AuditRoll2."Sale Date");
          Register2.Find('-');
          LastRegister.Find('+');
          ForeignGiftVoucherPaymentTypePOS.SetRange("Register Filter",Register2."Register No.",LastRegister."Register No.");
          ForeignGiftVoucherPaymentTypePOS.SetRange("Processing Type",ForeignGiftVoucherPaymentTypePOS."Processing Type"::"Foreign Gift Voucher");
          ForeignGiftVoucherPaymentTypePOS.SetFilter("Receipt Filter",'%1..%2',AuditRoll1."Sales Ticket No.",AuditRoll."Sales Ticket No.");
          ForeignGiftVoucherPaymentTypePOS.CalcFields(ForeignGiftVoucherPaymentTypePOS."Amount in Audit Roll");
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") then begin
          ForeignGiftVoucherPaymentTypePOS.SetRange("Date Filter",GlobalPeriod."Date Opened", GlobalPeriod."Date Closed");
          ForeignGiftVoucherPaymentTypePOS.SetRange("Register Filter",GlobalPeriod."Register No.");
          ForeignGiftVoucherPaymentTypePOS.SetRange("Processing Type",ForeignGiftVoucherPaymentTypePOS."Processing Type"::"Foreign Gift Voucher");
          ForeignGiftVoucherPaymentTypePOS.SetFilter("Receipt Filter",'%1..%2',GlobalPeriod."Opening Sales Ticket No.", GlobalPeriod."Sales Ticket No.");
          ForeignGiftVoucherPaymentTypePOS.CalcFields(ForeignGiftVoucherPaymentTypePOS."Amount in Audit Roll");
        end;

        ShowHeader := true;

        // - Calculate Total
        PaymentTypePOSTotal := 0;
        if ForeignGiftVoucherPaymentTypePOS.FindSet then
          repeat
            ForeignGiftVoucherPaymentTypePOS.CalcFields("Amount in Audit Roll");
            PaymentTypePOSTotal := PaymentTypePOSTotal + ForeignGiftVoucherPaymentTypePOS."Amount in Audit Roll";
          until ForeignGiftVoucherPaymentTypePOS.Next = 0;
        // + Calculate Total


        // Fremmed Gavekort, Body (1) - OnPreSection()
        if ShowHeader and (PaymentTypePOSTotal <> 0) then begin
          ShowHeader := false;
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddLine(PaymentForeignGiftVoucherTxt);
        end;

        RPLinePrintMgt.SetFont('B11');
        RPLinePrintMgt.SetBold(false);
        if ForeignGiftVoucherPaymentTypePOS.FindSet then
          repeat
            // Fremmed Gavekort, Body (2) - OnPreSection()
            ForeignGiftVoucherPaymentTypePOS.CalcFields("Amount in Audit Roll");
            if ForeignGiftVoucherPaymentTypePOS."Amount in Audit Roll" <> 0 then begin
              RPLinePrintMgt.AddTextField(1,0,ForeignGiftVoucherPaymentTypePOS.Description);
              RPLinePrintMgt.AddDecimalField(2,2,ForeignGiftVoucherPaymentTypePOS."Amount in Audit Roll");
            end;
          until ForeignGiftVoucherPaymentTypePOS.Next = 0;

        // Fremmed Gavekort, Footer (3) - OnPreSection()
        if PaymentTypePOSTotal <> 0 then begin
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddDecimalField(2,2,PaymentTypePOSTotal);
        end;

        //-NPR4.15
        TotalPaymentAmount += PaymentTypePOSTotal;
        //+NPR4.15
    end;

    procedure PrintPTPCreditVoucher()
    begin
        // Tilgodebevis - OnPreDataItem()
        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
          PaymentTypePOS.SetRange("Date Filter",AuditRoll2."Sale Date");
          Register2.Find('-');
          LastRegister.Find('+');
          CreditVoucherPaymentTypePOS.SetRange("Register Filter",Register2."Register No.",LastRegister."Register No.");
          CreditVoucherPaymentTypePOS.SetRange("Processing Type",CreditVoucherPaymentTypePOS."Processing Type"::"Credit Voucher");
          CreditVoucherPaymentTypePOS.SetFilter("Receipt Filter",'%1..%2',AuditRoll1."Sales Ticket No.",AuditRoll."Sales Ticket No.");
          CreditVoucherPaymentTypePOS.CalcFields("Amount in Audit Roll");
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") then begin
          CreditVoucherPaymentTypePOS.SetRange("Date Filter",GlobalPeriod."Date Opened",GlobalPeriod."Date Closed");
          CreditVoucherPaymentTypePOS.SetRange("Register Filter",GlobalPeriod."Register No.");
          CreditVoucherPaymentTypePOS.SetRange("Processing Type",CreditVoucherPaymentTypePOS."Processing Type"::"Credit Voucher");
          CreditVoucherPaymentTypePOS.SetFilter("Receipt Filter",'%1..%2',GlobalPeriod."Opening Sales Ticket No.", GlobalPeriod."Sales Ticket No.");
          CreditVoucherPaymentTypePOS.CalcFields("Amount in Audit Roll");
        end;

        ShowHeader := true;

        // - Calculate Total
        PaymentTypePOSTotal := 0;
        if CreditVoucherPaymentTypePOS.FindSet then
          repeat
            CreditVoucherPaymentTypePOS.CalcFields("Amount in Audit Roll");
            PaymentTypePOSTotal := PaymentTypePOSTotal + CreditVoucherPaymentTypePOS."Amount in Audit Roll";
          until CreditVoucherPaymentTypePOS.Next = 0;
        // + Calculate Total

        // Tilgodebevis, Body (1) - OnPreSection()
        if ShowHeader and (PaymentTypePOSTotal <> 0) then begin
          ShowHeader := false;
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddLine(PaymentCreditVoucherTxt);
        end;

        if CreditVoucherPaymentTypePOS.FindSet then
          repeat
            // Tilgodebevis, Body (2) - OnPreSection()
            CreditVoucherPaymentTypePOS.CalcFields("Amount in Audit Roll");
            if CreditVoucherPaymentTypePOS."Amount in Audit Roll" <> 0 then begin
              RPLinePrintMgt.SetFont('B11');
              RPLinePrintMgt.SetBold(false);
              RPLinePrintMgt.AddTextField(1,0,CreditVoucherPaymentTypePOS.Description);
              RPLinePrintMgt.AddDecimalField(2,2,CreditVoucherPaymentTypePOS."Amount in Audit Roll");
            end;
          until CreditVoucherPaymentTypePOS.Next = 0;

        // Tilgodebevis, Footer (3) - OnPreSection()
        if PaymentTypePOSTotal <> 0 then begin
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddDecimalField(2,2,PaymentTypePOSTotal);
        end;

        // Tilgodebevis - OnPostDataItem()
        TotalPaymentAmount := TotalPaymentAmount + PaymentTypePOSTotal;
    end;

    procedure PrintPTPForeignCreditVoucher()
    begin
        // Fremmed Tilgodebevis - OnPreDataItem()
        //-NPK.006
        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
          ForeignCreditVoucherPaymentTypePOS.SetRange("Date Filter",AuditRoll2."Sale Date");
          Register2.Find('-');
          LastRegister.Find('+');
          ForeignCreditVoucherPaymentTypePOS.SetRange("Register Filter",Register2."Register No.",LastRegister."Register No.");
          ForeignCreditVoucherPaymentTypePOS.SetRange("Processing Type",ForeignCreditVoucherPaymentTypePOS."Processing Type"::"Foreign Credit Voucher");
          ForeignCreditVoucherPaymentTypePOS.SetFilter("Receipt Filter",'%1..%2',AuditRoll1."Sales Ticket No.",AuditRoll."Sales Ticket No.");
          ForeignCreditVoucherPaymentTypePOS.CalcFields(ForeignCreditVoucherPaymentTypePOS."Amount in Audit Roll");
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") then begin
          ForeignCreditVoucherPaymentTypePOS.SetRange("Date Filter",GlobalPeriod."Date Opened",GlobalPeriod."Date Closed");
          ForeignCreditVoucherPaymentTypePOS.SetRange("Register Filter",GlobalPeriod."Register No.");
          ForeignCreditVoucherPaymentTypePOS.SetRange("Processing Type",ForeignCreditVoucherPaymentTypePOS."Processing Type"::"Foreign Credit Voucher");
          ForeignCreditVoucherPaymentTypePOS.SetFilter("Receipt Filter",'%1..%2',GlobalPeriod."Opening Sales Ticket No.",GlobalPeriod."Sales Ticket No.");
          ForeignCreditVoucherPaymentTypePOS.CalcFields(ForeignCreditVoucherPaymentTypePOS."Amount in Audit Roll");
        end;
        //+NPK.006

        ShowHeader := true;

        // - Calculate Total
        PaymentTypePOSTotal := 0;
        if ForeignCreditVoucherPaymentTypePOS.FindSet then
          repeat
            ForeignCreditVoucherPaymentTypePOS.CalcFields("Amount in Audit Roll");
            PaymentTypePOSTotal := PaymentTypePOSTotal + ForeignCreditVoucherPaymentTypePOS."Amount in Audit Roll";
          until ForeignCreditVoucherPaymentTypePOS.Next = 0;
        // + Calculate Total

        // Fremmed Tilgodebevis, Body (1) - OnPreSection()
        if ShowHeader and (PaymentTypePOSTotal <> 0) then begin
          ShowHeader := false;
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddLine(PaymentForeignCreditVoucherTxt);
        end;

        RPLinePrintMgt.SetFont('B11');
        RPLinePrintMgt.SetBold(false);
        if ForeignCreditVoucherPaymentTypePOS.FindSet then
          repeat
            // Fremmed Tilgodebevis, Body (2) - OnPreSection()
            ForeignCreditVoucherPaymentTypePOS.CalcFields("Amount in Audit Roll");
            if ForeignCreditVoucherPaymentTypePOS."Amount in Audit Roll"<>0 then begin
              RPLinePrintMgt.AddTextField(1,0,ForeignCreditVoucherPaymentTypePOS.Description);
              RPLinePrintMgt.AddDecimalField(2,2,ForeignCreditVoucherPaymentTypePOS."Amount in Audit Roll");
            end;
          until ForeignCreditVoucherPaymentTypePOS.Next = 0;

        // Fremmed Tilgodebevis, Footer (3) - OnPreSection()
        if PaymentTypePOSTotal <> 0 then begin
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddDecimalField(2,2,PaymentTypePOSTotal);
        end;

        //-NPR4.15
        TotalPaymentAmount += PaymentTypePOSTotal;
        //+NPR4.15
    end;

    procedure PrintPTPTerminalCard()
    begin
        // TerminalCard - OnPreDataItem()
        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
          PaymentTypePOS.SetRange("Date Filter",AuditRoll2."Sale Date");
          Register2.Find('-');
          LastRegister.Find('+');
          TerminalCard.SetRange("Register Filter",Register2."Register No.",LastRegister."Register No.");
          TerminalCard.SetRange("Processing Type",TerminalCard."Processing Type"::"Terminal Card");
          TerminalCard.SetFilter("Receipt Filter",'%1..%2',AuditRoll1."Sales Ticket No.",AuditRoll."Sales Ticket No.");
          TerminalCard.CalcFields("Amount in Audit Roll");
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") then begin
          TerminalCard.SetFilter("Date Filter",'%1..%2',GlobalPeriod."Date Opened",GlobalPeriod."Date Closed");
          TerminalCard.SetRange("Register Filter",GlobalPeriod."Register No.");
          TerminalCard.SetRange("Processing Type",TerminalCard."Processing Type"::"Terminal Card");
          TerminalCard.SetFilter("Receipt Filter",'%1..%2',
                                 GlobalPeriod."Opening Sales Ticket No.",
                                 GlobalPeriod."Sales Ticket No.");
          TerminalCard.CalcFields("Amount in Audit Roll");
        end;

        ShowHeader := true;

        // - Calculate Total
        PaymentTypePOSTotal := 0;
        if TerminalCard.FindSet then
          repeat
            TerminalCard.CalcFields("Amount in Audit Roll");
            PaymentTypePOSTotal := PaymentTypePOSTotal + TerminalCard."Amount in Audit Roll";
          until TerminalCard.Next = 0;
        // + Calculate Total


        // TerminalCard, Body (1) - OnPreSection()
        if ShowHeader and (PaymentTypePOSTotal <> 0) then begin
          ShowHeader := false;
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddLine(PaymentTerminalTxt);
        end;

        RPLinePrintMgt.SetFont('B11');
        RPLinePrintMgt.SetBold(false);
        if TerminalCard.FindSet then
          repeat
            // TerminalCard - OnAfterGetRecord()
            if (TerminalCard."Amount in Audit Roll" <> 0) and not ShowHeader then
              ShowHeader := true;

            // TerminalCard, Body (2) - OnPreSection()
            TerminalCard.CalcFields("Amount in Audit Roll");
            if TerminalCard."Amount in Audit Roll" <> 0 then begin
              RPLinePrintMgt.AddTextField(1,0,TerminalCard.Description);
              RPLinePrintMgt.AddDecimalField(2,2,TerminalCard."Amount in Audit Roll");
            end;
          until TerminalCard.Next = 0;

        // TerminalCard, Footer (3) - OnPreSection()
        if PaymentTypePOSTotal <> 0 then begin
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddDecimalField(2,2,PaymentTypePOSTotal);
        end;

        // TerminalCard - OnPostDataItem()
        TotalPaymentAmount := TotalPaymentAmount + PaymentTypePOSTotal;
    end;

    procedure PrintPTPOtherCreditCards()
    begin
        //OtherCreditCards - OnPreDataItem()
        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
          PaymentTypePOS.SetRange("Date Filter",AuditRoll2."Sale Date");
          Register2.Find('-');
          LastRegister.Find('+');
          OtherCreditCards.SetRange("Register Filter",Register2."Register No.",LastRegister."Register No.");
          OtherCreditCards.SetRange("Processing Type",OtherCreditCards."Processing Type"::"Other Credit Cards");
          OtherCreditCards.SetFilter("Receipt Filter",'%1..%2',AuditRoll1."Sales Ticket No.",AuditRoll."Sales Ticket No.");
          OtherCreditCards.CalcFields("Amount in Audit Roll");
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") then begin
          OtherCreditCards.SetRange("Date Filter",GlobalPeriod."Date Opened",GlobalPeriod."Date Closed");
          OtherCreditCards.SetRange("Register Filter",GlobalPeriod."Register No.");
          OtherCreditCards.SetRange("Processing Type",OtherCreditCards."Processing Type"::"Other Credit Cards");
          OtherCreditCards.SetFilter("Receipt Filter",'%1..%2',GlobalPeriod."Opening Sales Ticket No.",GlobalPeriod."Sales Ticket No.");
          OtherCreditCards.CalcFields("Amount in Audit Roll");
        end;

        ShowHeader := true;

        // - Calculate Total
        PaymentTypePOSTotal := 0;
        if OtherCreditCards.FindSet then
          repeat
            OtherCreditCards.CalcFields("Amount in Audit Roll");
            PaymentTypePOSTotal := PaymentTypePOSTotal + OtherCreditCards."Amount in Audit Roll";
          until OtherCreditCards.Next = 0;
        // + Calculate Total


        // OtherCreditCards, Body (1) - OnPreSection()
        if ShowHeader and (PaymentTypePOSTotal <> 0) then begin
          ShowHeader := false;
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddLine(PaymentOtherCreditCardsTxt);
        end;

        RPLinePrintMgt.SetFont('B11');
        RPLinePrintMgt.SetBold(false);
        if OtherCreditCards.FindSet then
          repeat
            // OtherCreditCards - OnAfterGetRecord()
            if (OtherCreditCards."Amount in Audit Roll" <> 0) and not ShowHeader then
              ShowHeader := true;

            // OtherCreditCards, Body (2) - OnPreSection()
            OtherCreditCards.CalcFields("Amount in Audit Roll");
            if OtherCreditCards."Amount in Audit Roll" <> 0 then begin
              RPLinePrintMgt.AddTextField(1,0,OtherCreditCards.Description);
              RPLinePrintMgt.AddDecimalField(2,2,OtherCreditCards."Amount in Audit Roll");
            end;
          until OtherCreditCards.Next = 0;

        //OtherCreditCards, Footer (3) - OnPreSection()
        if PaymentTypePOSTotal <> 0 then begin
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddDecimalField(2,2,PaymentTypePOSTotal);
        end;

        // OtherCreditCards - OnPostDataItem()
        TotalPaymentAmount := TotalPaymentAmount + PaymentTypePOSTotal;
    end;

    procedure PrintPTPManualCards()
    begin
        // ManualCards - OnPreDataItem()
        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
          PaymentTypePOS.SetRange("Date Filter",AuditRoll2."Sale Date");
          Register2.Find('-');
          LastRegister.Find('+');
          ManualCards.SetRange("Register Filter",Register2."Register No.",LastRegister."Register No.");
          ManualCards.SetRange("Processing Type",ManualCards."Processing Type"::"Manual Card");
          ManualCards.SetFilter("Receipt Filter",'%1..%2',AuditRoll1."Sales Ticket No.",AuditRoll."Sales Ticket No.");
          ManualCards.CalcFields("Amount in Audit Roll");
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") then begin
          ManualCards.SetRange("Date Filter",GlobalPeriod."Date Opened",GlobalPeriod."Date Closed");
          ManualCards.SetRange("Register Filter",GlobalPeriod."Register No.");
          ManualCards.SetRange("Processing Type",ManualCards."Processing Type"::"Manual Card");
          ManualCards.SetFilter("Receipt Filter",'%1..%2',GlobalPeriod."Opening Sales Ticket No.",GlobalPeriod."Sales Ticket No.");
          ManualCards.CalcFields("Amount in Audit Roll");
        end;

        ShowHeader := true;

        // - Calculate Total
        PaymentTypePOSTotal := 0;
        if ManualCards.FindSet then
          repeat
            ManualCards.CalcFields("Amount in Audit Roll");
            PaymentTypePOSTotal := PaymentTypePOSTotal + ManualCards."Amount in Audit Roll";
          until ManualCards.Next = 0;
        // + Calculate Total

        // ManualCards, Body (1) - OnPreSection()
        if ShowHeader and (PaymentTypePOSTotal <> 0) then begin
          ShowHeader := false;

          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddLine(PaymentManualCardsTxt);
        end;

        RPLinePrintMgt.SetFont('B11');
        RPLinePrintMgt.SetBold(false);
        if ManualCards.FindSet then repeat
          // ManualCards - OnAfterGetRecord()
          if (ManualCards."Amount in Audit Roll" <> 0) and not ShowHeader then
            ShowHeader := true;

          // ManualCards, Body (2) - OnPreSection()
          ManualCards.CalcFields("Amount in Audit Roll");
          if ManualCards."Amount in Audit Roll" <> 0 then begin
            RPLinePrintMgt.AddTextField(1,0,ManualCards.Description);
            RPLinePrintMgt.AddDecimalField(2,2,ManualCards."Amount in Audit Roll");
          end;
        until ManualCards.Next = 0;

        // ManualCards, Footer (3) - OnPreSection()
        if PaymentTypePOSTotal <> 0 then begin
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddDecimalField(2,2,PaymentTypePOSTotal);
        end;

        // ManualCards - OnPostDataItem()
        TotalPaymentAmount := TotalPaymentAmount + PaymentTypePOSTotal;
    end;

    procedure PrintPTPTerminal()
    begin
        // Terminal - OnPreDataItem()
        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
          PaymentTypePOS.SetRange("Date Filter",AuditRoll2."Sale Date");
          Register2.Find('-');
          LastRegister.Find('+');
          Terminal.SetRange("Register Filter",Register2."Register No.",LastRegister."Register No.");
          Terminal.SetRange("Processing Type",Terminal."Processing Type"::EFT);
          Terminal.SetFilter("Receipt Filter",'%1..%2',AuditRoll1."Sales Ticket No.",AuditRoll."Sales Ticket No.");
          Terminal.CalcFields("Amount in Audit Roll");
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") then begin
          Terminal.SetFilter("Date Filter",'%1..%2',GlobalPeriod."Date Opened",GlobalPeriod."Date Closed");
          Terminal.SetRange("Register Filter",GlobalPeriod."Register No.");
          Terminal.SetRange("Processing Type",Terminal."Processing Type"::EFT);
          Terminal.SetFilter("Receipt Filter",'%1..%2',
                                 GlobalPeriod."Opening Sales Ticket No.",
                                 GlobalPeriod."Sales Ticket No.");
          Terminal.CalcFields("Amount in Audit Roll");
        end;

        ShowHeader := true;

        // - Calculate Total
        PaymentTypePOSTotal := 0;
        //-NPR4.18
        //IF ManualCards.FINDSET THEN REPEAT
        //  ManualCards.CALCFIELDS("Amount in audit roll");
        //  PaymentTypePOSTotal := PaymentTypePOSTotal + ManualCards."Amount in audit roll";
        //UNTIL ManualCards.NEXT = 0;
        if Terminal.FindSet then
          repeat
            Terminal.CalcFields("Amount in Audit Roll");
            PaymentTypePOSTotal := PaymentTypePOSTotal + Terminal."Amount in Audit Roll";
          until Terminal.Next = 0;
        //+NPR4.18
        // + Calculate Total

        // Terminal, Body (1) - OnPreSection()
        if ShowHeader and (PaymentTypePOSTotal <> 0) then begin
          ShowHeader := false;
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddLine(PaymentTerminalOtherTxt);
        end;

        RPLinePrintMgt.SetFont('B11');
        RPLinePrintMgt.SetBold(false);
        if Terminal.FindSet then
          repeat
            // Terminal - OnAfterGetRecord()
            if (Terminal."Amount in Audit Roll" <> 0) and not ShowHeader then
              ShowHeader := true;

            // Terminal, Body (2) - OnPreSection()
            Terminal.CalcFields("Amount in Audit Roll");
            if Terminal."Amount in Audit Roll" <> 0 then begin
              RPLinePrintMgt.AddTextField(1,0,Terminal.Description);
              RPLinePrintMgt.AddDecimalField(2,2,Terminal."Amount in Audit Roll");
            end;
          until Terminal.Next = 0;

        // Terminal, Footer (3) - OnPreSection()
        if PaymentTypePOSTotal <> 0 then begin
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddDecimalField(2,2,PaymentTypePOSTotal);
        end;

        // Terminal - OnPostDataItem()
        TotalPaymentAmount := TotalPaymentAmount + PaymentTypePOSTotal;
    end;

    procedure PrintPTPForeignCurrency()
    begin
        // ForeignCurrency - Properties
        ForeignCurrency.Ascending(true);
        ForeignCurrency.SetRange("Processing Type",ForeignCurrency."Processing Type"::"Foreign Currency");

        // ForeignCurrency - OnPreDataItem()
        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::TOTAL) then begin
          PaymentTypePOS.SetRange("Date Filter",AuditRoll2."Sale Date");
          Register2.Find('-');
          LastRegister.Find('+');
          ForeignCurrency.SetRange("Register Filter",Register2."Register No.",LastRegister."Register No.");
          ForeignCurrency.SetRange("Processing Type",ForeignCurrency."Processing Type"::"Foreign Currency");
          ForeignCurrency.SetFilter("Receipt Filter",'%1..%2',AuditRoll1."Sales Ticket No.",AuditRoll."Sales Ticket No.");
          ForeignCurrency.CalcFields("Amount in Audit Roll");
        end;

        if (RetailSetup."Balancing Posting Type" = RetailSetup."Balancing Posting Type"::"PER REGISTER") then begin
          ForeignCurrency.SetFilter("Date Filter",'%1..%2',GlobalPeriod."Date Opened",GlobalPeriod."Date Closed");
          ForeignCurrency.SetRange("Register Filter",GlobalPeriod."Register No.");
          ForeignCurrency.SetRange("Processing Type",ForeignCurrency."Processing Type"::"Foreign Currency");
          ForeignCurrency.SetFilter("Receipt Filter",'%1..%2',
                                 GlobalPeriod."Opening Sales Ticket No.",
                                 GlobalPeriod."Sales Ticket No.");
          ForeignCurrency.CalcFields("Amount in Audit Roll");
        end;
        //

        // - Calculate Total
        PaymentTypePOSTotal := 0;
        if ForeignCurrency.FindSet then
          repeat
            ForeignCurrency.CalcFields("Amount in Audit Roll");
            PaymentTypePOSTotal := PaymentTypePOSTotal + ForeignCurrency."Amount in Audit Roll";
          until ForeignCurrency.Next = 0;
        // + Calculate Total

        if ForeignCurrency.FindSet then begin
          // ForeignCurrency, Header (1)
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddLine(PaymentForeignCurrencyTxt);
          RPLinePrintMgt.SetFont('B11');
          RPLinePrintMgt.SetBold(false);
          repeat
            // ForeignCurrency, Body (2) - OnPreSection()
            ForeignCurrency.CalcFields("Amount in Audit Roll");
            if ForeignCurrency."Amount in Audit Roll" <> 0 then begin
              RPLinePrintMgt.AddTextField(1,0,ForeignCurrency.Description);
              RPLinePrintMgt.AddDecimalField(2,2,ForeignCurrency."Amount in Audit Roll");
            end;
          until ForeignCurrency.Next = 0;
        end;

        // ForeignCurrency, Footer (3)
        RPLinePrintMgt.SetFont('A11');
        RPLinePrintMgt.AddDecimalField(2,2,PaymentTypePOSTotal);
    end;

    procedure PrintGLGiftVoucherDiscAcc()
    begin
        // Gavekortrabatkonto - OnPreDataItem()
        GiftVoucherDiscountAccount.SetRange("No.",Register."Gift Voucher Discount Account");

        RPLinePrintMgt.SetFont('A11');
        if GiftVoucherDiscountAccount.FindSet then
          repeat
            // Gavekortrabatkonto - OnAfterGetRecord()
            GiftVoucherDiscountAccount.SetRange("Date Filter",GlobalPeriod."Date Opened",GlobalPeriod."Date Closed");
            GiftVoucherDiscountAccount.SetRange("Register Filter",GlobalPeriod."Register No.");
            GiftVoucherDiscountAccount.SetFilter("Sales Ticket No. Filter",'%1..%2',
                                         GlobalPeriod."Opening Sales Ticket No.",
                                         GlobalPeriod."Sales Ticket No.");
            GiftVoucherDiscountAccount.CalcFields("G/L Entry in Audit Roll");

            //Gavekortrabatkonto, Body (1) - OnPreSection()
            if GiftVoucherDiscountAccount."G/L Entry in Audit Roll" <> 0 then begin
              RPLinePrintMgt.AddTextField(1,0,PayOutGVDiscountTxt);
              RPLinePrintMgt.AddDecimalField(2,2,GiftVoucherDiscountAccount."G/L Entry in Audit Roll");
            end;
          until GiftVoucherDiscountAccount.Next = 0;
    end;

    procedure PrintInteger()
    begin
        for MaxIteration := 1 to 1 do begin
          // Integer, Body (1) - OnPreSection()
          RPLinePrintMgt.SetFont('A11');
          if (DebitSaleAmount + GiftVoucherDebitAmount) <> 0 then begin
              RPLinePrintMgt.AddTextField(1,0,PayOutDebitSalesTxt);
            //-NPR5.48 [329505]
            //RPLinePrintMgt.AddDecimalField(2,2,DebitSaleAmount);
              RPLinePrintMgt.AddDecimalField(2,2,InvoiceAmount);
            //+NPR5.48 [329505]
              RPLinePrintMgt.AddTextField(1,0,PayOutDebitSalesGVTxt);
              RPLinePrintMgt.AddDecimalField(2,2,GiftVoucherDebitAmount);
          end;

          // Integer, Body (2)
          //-NPR4.18
        //  Printer.SetPadChar('_');
        //  Printer.AddLine('');
        //  Printer.SetPadChar(' ');

        //  Printer.AddTextField(1,0,CheckSumTxt);
        //  Printer.AddDecimalField(2,2,Kontantbev�g+BetalingerTotal+debetsalg+gkdebet);
        //  Printer.AddTextField(1,0,RoundingTxt);
        //  Printer.AddDecimalField(2,2, (Tilgodebevisudstedelse+Gavekortsalg+Debitorindbetalinger-Udbetalinger+Bruttooms�tning+debetsalg)
        //      -(Kontantbev�g+BetalingerTotal+debetsalg+gkdebet) );
          //+NPR4.18

          RPLinePrintMgt.SetPadChar('_');
          RPLinePrintMgt.AddLine('');
          RPLinePrintMgt.SetPadChar(' ');

          // Integer, Body (3) - OnPreSection()
          if TotalReturnAmount <> 0 then begin
            RPLinePrintMgt.SetFont('A11');
            RPLinePrintMgt.AddLine(PayOutReturnSaleTxt);

            RPLinePrintMgt.AddTextField(1,0,'Antal: ' + Format(TotalNoOfSales));
            RPLinePrintMgt.AddDecimalField(2,2,TotalReturnAmount);
          end;
        end;
    end;

    procedure PrintGLAccount()
    begin
        // G/L Account - Properties
        GLAccount.SetRange("Retail Payment", true);

        HeaderPrinted := false;
        if GLAccount.FindSet then
          repeat
            // G/L Account - OnAfterGetRecord()
            GLAccount.SetRange("Date Filter",GlobalPeriod."Date Opened",GlobalPeriod."Date Closed");
            GLAccount.SetRange("Register Filter",GlobalPeriod."Register No.");
            GLAccount.SetFilter("Sales Ticket No. Filter",'%1..%2',GlobalPeriod."Opening Sales Ticket No.",GlobalPeriod."Sales Ticket No.");
            GLAccount.CalcFields("G/L Entry in Audit Roll");

            if not HeaderPrinted then begin
              // G/L Account, Header (1)
              RPLinePrintMgt.SetFont('A11');
              RPLinePrintMgt.SetBold(false);
              RPLinePrintMgt.AddLine(PayOutGLTxt);

              HeaderPrinted := true;
              RPLinePrintMgt.SetFont('B11');
              RPLinePrintMgt.SetBold(false);
            end;

            // G/L Account, Body (2) - OnPreSection()
            if GLAccount."G/L Entry in Audit Roll" <> 0 then begin
              RPLinePrintMgt.AddTextField(1,0,GLAccount.Name + '  ' + Format(GLAccount."No."));
              RPLinePrintMgt.AddDecimalField(2,2,GLAccount."G/L Entry in Audit Roll");
            end;
          until GLAccount.Next = 0;

        // G/L Account, Footer (3) - OnPreSection()
        if MiscellaneousPaymentAmount <> 0 then begin
          RPLinePrintMgt.AddDecimalField(2,2,MiscellaneousPaymentAmount);
        end;
    end;

    procedure PrintPTPPaymentTypeCounting()
    begin
        // 0. Payment Type POS

        // PaymentTypeCounting - Properties
        PaymentTypeCounting.SetCurrentKey("Register No.","Processing Type");
        PaymentTypeCounting.SetFilter("Processing Type",'%1|%2',PaymentTypeCounting."Processing Type"::Cash,
                                                                PaymentTypeCounting."Processing Type"::"Foreign Currency");
        PaymentTypeCounting.SetRange("To be Balanced",true);
        if RetailSetup."Show Counting on Counter Rep." then begin //CurrReport.SKIP
          HeaderPrinted := false;
          if PaymentTypeCounting.FindSet then
            repeat
              // PaymentTypeCounting - OnAfterGetRecord()
              PeriodLine.SetRange("Register No.",AuditRoll."Register No.");
              PeriodLine.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
              PeriodLine.SetRange("Payment Type No.",PaymentTypeCounting."No.");
              DetailedCounting := PeriodLine.Find('-');

              if not HeaderPrinted then begin
                // PaymentTypeCounting, Header (1)
                RPLinePrintMgt.SetFont('B21');
                RPLinePrintMgt.SetBold(true);
                RPLinePrintMgt.AddLine(PaymentCountingDetailsTxt);
                HeaderPrinted := true;
              end;

              // PaymentTypeCounting, Body (2) - OnPreSection()
              if DetailedCounting then begin
                 RPLinePrintMgt.SetFont('A11');
                 RPLinePrintMgt.SetBold(false);
                 RPLinePrintMgt.AddLine(DescriptionTxt);
              end;

              // PaymentTypeCounting, Body (3) - OnPreSection()
              if not DetailedCounting then begin
                 RPLinePrintMgt.SetFont('A11');
                 RPLinePrintMgt.SetBold(false);
                 RPLinePrintMgt.AddTextField(1,0,DescriptionTxt);
                 RPLinePrintMgt.AddTextField(2,2,NothingCountedTxt);
              end;

              // 1 PeriodLine
              PrintPeriodLine();
            until PaymentTypeCounting.Next = 0;

        end;
    end;

    procedure PrintPeriodLine()
    begin
        // Period Line - OnPreDataItem()
        if RetailSetup."Show Counting on Counter Rep." then begin //CurrReport.BREAK
          PeriodLine.SetRange("Register No.",AuditRoll."Register No.");
          PeriodLine.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
          PeriodLine.SetRange("Payment Type No.",PaymentTypeCounting."No.");
          CountTotalFooter := 0;
          HeaderPrinted := false;
          if PeriodLine.FindSet then
            repeat
              // Period Line - OnAfterGetRecord()
              CountTotalFooter += PeriodLine.Amount;

              if not HeaderPrinted then begin
                // Period Line, Header (1)
                RPLinePrintMgt.SetFont('A11');
                RPLinePrintMgt.AddTextField(1,0,PLCountUnitTxt);
                RPLinePrintMgt.AddTextField(2,2,PLQtyTxt);
                RPLinePrintMgt.AddTextField(3,2,PLTotalTxt);
                HeaderPrinted := true;
              end;

              // Period Line, Body (2)
              RPLinePrintMgt.AddDecimalField(1,0,PeriodLine.Weight);
              RPLinePrintMgt.AddDecimalField(2,2,PeriodLine.Quantity);
              RPLinePrintMgt.AddDecimalField(3,2,PeriodLine.Amount);
            until PeriodLine.Next = 0;

          // Period Line, Footer (3)
          RPLinePrintMgt.AddTextField(1,0,PLTOTALTxt2);
          RPLinePrintMgt.AddDecimalField(2,2,CountTotalFooter);
        end;
    end;

    procedure PrintFooter()
    begin
        RPLinePrintMgt.SetFont('Control');
        //-NPR5.26 [249408]
        //Printer.AddLine(Text0002);
        RPLinePrintMgt.AddLine('P');
        //+NPR5.26 [249408]
    end;

    procedure GetRecords()
    begin
        //Audit Roll - Properties
        AuditRoll.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type","Line No.","No.");
        AuditRoll.FindSet;
        Register.Get(AuditRoll."Register No.");
        CompanyInformation.Get;

        //Audit Roll - OnPreDataItem
        RetailSetup.Get;
        Calculate := true;
    end;

    procedure BalanceUpdate(Amount: Decimal;Positive: Boolean)
    begin
        if Positive then
          PositiveChangeAmount := PositiveChangeAmount + Amount
        else
          NegativeChangeAmount := NegativeChangeAmount + Amount;
    end;
}

