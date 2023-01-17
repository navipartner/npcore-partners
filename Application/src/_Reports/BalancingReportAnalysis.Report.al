﻿report 6014460 "NPR Balancing Report Analysis"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Balancing Report-Analysis.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Balancing Report - A4';
    DataAccessIntent = ReadOnly;
    PreviewMode = PrintLayout;
    UseSystemPrinter = true;

    dataset
    {
        dataitem("POS Workshift Checkpoint"; "NPR POS Workshift Checkpoint")
        {
            column(CompInfoPicture_; CompanyInfo.Picture) { }
            column(Saleslbl_; Saleslbl) { }
            column(Receiptslbl_; Receiptslbl) { }
            column(Terminalslbl_; Terminalslbl) { }
            column(Voucherslbl_; Voucherslbl) { }
            column(Turnoverlbl_; Turnoverlbl) { }
            column(LastYearLbl_; LastYearLbl) { }
            column(AnalysisPeriodLbl_; AnalysisPeriodLbl) { }
            column(Discountlbl_; Discountlbl) { }
            column(DiscountAmtlbl_; DiscountAmtlbl) { }
            column(DiscountPerclbl_; DiscountPerclbl) { }
            column(DiscountTotallbl_; DiscountTotallbl) { }
            column(Countinglbl_; Countinglbl) { }
            column(Closinglbl_; Closinglbl) { }
            column(VATTaxSummarylbl; VATTaxSummarylbl) { }
            column(AttachedPaymentBinslbl; AttachedPaymentBinslbl) { }
            column(CustomerPaymentlbl; CustomerPaymentLbl) { }
            column(Workshiftlbl_; Workshiftlbl) { }
            column(EFTlbl_; EFTlbl) { }
            column(POSUnitLbl_; POSUnitLbl) { }
            column(WorkshiftNo_; "POS Workshift Checkpoint"."Entry No.") { }
            column(POSUnitNo_; "POS Workshift Checkpoint"."POS Unit No.") { }
            column(CreatedAt_; "POS Workshift Checkpoint"."Created At") { }
            column(NetTurnoverLCY_; "POS Workshift Checkpoint"."Net Turnover (LCY)") { }
            column(NetTurnoverLCYLastYear_; TempPOSWorkshiftCheckpoint."Net Turnover (LCY)") { }
            column(DirectReturnSalesLCY_; "POS Workshift Checkpoint"."Direct Item Returns (LCY)") { }
            column(DirectReturnSalesLCYLastYear_; TempPOSWorkshiftCheckpoint."Direct Item Returns (LCY)") { }
            column(TotalDiscountLCY_; "POS Workshift Checkpoint"."Total Discount (LCY)") { }
            column(TotalDiscountLCYLastYear_; TempPOSWorkshiftCheckpoint."Total Discount (LCY)") { }
            column(TerminalCardLCY_; "POS Workshift Checkpoint"."EFT (LCY)") { }
            column(ManualCardLCY_; "POS Workshift Checkpoint"."Manual Card (LCY)") { }
            column(OtherCreditCardLCY_; "POS Workshift Checkpoint"."Other Credit Card (LCY)") { }
            column(CashTerminalLCY_; "POS Workshift Checkpoint"."Cash Terminal (LCY)") { }
            column(CashMovementLCY_; "POS Workshift Checkpoint"."Local Currency (LCY)") { }
            column(IssuedVoucherLCY_; "POS Workshift Checkpoint"."Issued Vouchers (LCY)") { }
            column(IssuedVoucherLCYLastYear_; TempPOSWorkshiftCheckpoint."Issued Vouchers (LCY)") { }
            column(RedeemedVoucherLCY_; "POS Workshift Checkpoint"."Redeemed Vouchers (LCY)") { }
            column(RedeemedVoucherLCYLastYear_; TempPOSWorkshiftCheckpoint."Redeemed Vouchers (LCY)") { }
            column(RedeemedCreditVoucherLCY_; "POS Workshift Checkpoint"."Redeemed Credit Voucher (LCY)") { }
            column(CreatedCreditVoucherLCY_; "POS Workshift Checkpoint"."Created Credit Voucher (LCY)") { }
            column(SalesCount_; "POS Workshift Checkpoint"."Direct Sales Count") { }
            column(SalesCountLastYear_; TempPOSWorkshiftCheckpoint."Direct Sales Count") { }
            column(ReceiptsCount_; "POS Workshift Checkpoint"."Receipts Count") { }
            column(ReceiptsCountLastYear_; TempPOSWorkshiftCheckpoint."Receipts Count") { }
            column(ReturnSalesCount_; "POS Workshift Checkpoint"."Direct Item Returns Line Count") { }
            column(ReturnSalesCountLastYear_; TempPOSWorkshiftCheckpoint."Direct Item Returns Line Count") { }
            column(ReceiptCopiesCount_; "POS Workshift Checkpoint"."Receipt Copies Count") { }
            column(ReceiptCopiesCountLastYear_; TempPOSWorkshiftCheckpoint."Receipt Copies Count") { }
            column(CashDrawerOpenCount_; "POS Workshift Checkpoint"."Cash Drawer Open Count") { }
            column(CashDrawerOpenCountLastYear_; TempPOSWorkshiftCheckpoint."Cash Drawer Open Count") { }
            column(CancelledSalesCount_; "POS Workshift Checkpoint"."Cancelled Sales Count") { }
            column(CancelledSalesCountLastYear_; TempPOSWorkshiftCheckpoint."Cancelled Sales Count") { }
            column(DebitsalesCount_; "POS Workshift Checkpoint"."Credit Item Quantity Sum") { }
            column(DirectSalesLCY_; "POS Workshift Checkpoint"."Direct Item Sales (LCY)") { }
            column(DirectSalesLCYLastYear_; TempPOSWorkshiftCheckpoint."Direct Item Sales (LCY)") { }
            column(SalesStaffLCY_; "POS Workshift Checkpoint"."Direct Sales - Staff (LCY)") { }
            column(DebitSalesLCY_; "POS Workshift Checkpoint"."Credit Item Sales (LCY)") { }
            column(DebtorPaymentLCY_; "POS Workshift Checkpoint"."Debtor Payment (LCY)") { }
            column(DebtorPaymentLCYLastYear_; TempPOSWorkshiftCheckpoint."Debtor Payment (LCY)") { }
            column(ForeignCurrencyLCY_; "POS Workshift Checkpoint"."Foreign Currency (LCY)") { }
            column(GLPaymentLCY_; "POS Workshift Checkpoint"."GL Payment (LCY)") { }
            column(GLPaymentLCYLastYear_; TempPOSWorkshiftCheckpoint."GL Payment (LCY)") { }
            column(InvoicedSalesLCY_; "POS Workshift Checkpoint"."Credit Net Sales Amount (LCY)") { }
            column(RoundingLCY_; "POS Workshift Checkpoint"."Rounding (LCY)") { }
            column(TurnoverLCY_; "POS Workshift Checkpoint"."Turnover (LCY)") { }
            column(TurnoverLCYLastYear_; TempPOSWorkshiftCheckpoint."Turnover (LCY)") { }
            column(NetCostLCY_; "POS Workshift Checkpoint"."Net Cost (LCY)") { }
            column(ProfitAmountLCY_; "POS Workshift Checkpoint"."Profit Amount (LCY)") { }
            column(ProfitPerc_; "POS Workshift Checkpoint"."Profit %") { }
            column(CampaignDiscountLCY_; "POS Workshift Checkpoint"."Campaign Discount (LCY)") { }
            column(MixDiscountLCY_; "POS Workshift Checkpoint"."Mix Discount (LCY)") { }
            column(QtyDiscountLCY_; "POS Workshift Checkpoint"."Quantity Discount (LCY)") { }
            column(CustomDiscountLCY_; "POS Workshift Checkpoint"."Custom Discount (LCY)") { }
            column(BOMDiscountLCY_; "POS Workshift Checkpoint"."BOM Discount (LCY)") { }
            column(CustomerDiscountLCY_; "POS Workshift Checkpoint"."Customer Discount (LCY)") { }
            column(LineDiscountLCY_; "POS Workshift Checkpoint"."Line Discount (LCY)") { }
            column(CampaignDiscountPerc_; "POS Workshift Checkpoint"."Campaign Discount %") { }
            column(MixDiscountPerc_; "POS Workshift Checkpoint"."Mix Discount %") { }
            column(CustomerDiscountPerc_; "POS Workshift Checkpoint"."Customer Discount %") { }
            column(QtyDiscountPerc_; "POS Workshift Checkpoint"."Quantity Discount %") { }
            column(CustomDiscountPerc_; "POS Workshift Checkpoint"."Custom Discount %") { }
            column(BOMDiscountPerc_; "POS Workshift Checkpoint"."BOM Discount %") { }
            column(LineDiscountPerc_; "POS Workshift Checkpoint"."Line Discount %") { }
            column(TotalDiscountPerc_; "POS Workshift Checkpoint"."Total Discount %") { }
            column(DirectTurnoverLCY_; "POS Workshift Checkpoint"."Direct Turnover (LCY)") { }
            column(DirectTurnoverLCYLastYear_; TempPOSWorkshiftCheckpoint."Direct Turnover (LCY)") { }
            column(CreditTurnoverLCY_; "POS Workshift Checkpoint"."Credit Turnover (LCY)") { }
            column(CreditTurnoverLCYLastYear_; TempPOSWorkshiftCheckpoint."Credit Turnover (LCY)") { }
            column(DirectNetTurnoverLCY_; "POS Workshift Checkpoint"."Direct Net Turnover (LCY)") { }
            column(DirectNetTurnoverLCYLastYear_; TempPOSWorkshiftCheckpoint."Direct Net Turnover (LCY)") { }
            column(CreditRealAmtLCY_; "POS Workshift Checkpoint"."Credit Real. Sale Amt. (LCY)") { }
            column(CreditRealAmtLCYLastYear_; TempPOSWorkshiftCheckpoint."Credit Real. Sale Amt. (LCY)") { }
            column(CreditRealReturnAmtLCY_; "POS Workshift Checkpoint"."Credit Real. Return Amt. (LCY)") { }
            column(CreditRealReturnAmtLCYLastYear_; TempPOSWorkshiftCheckpoint."Credit Real. Return Amt. (LCY)") { }
            column(CreditNetTurnOverLCY_; "POS Workshift Checkpoint"."Credit Net Turnover (LCY)") { }
            column(CreditNetTurnOverLCYLastYear_; "POS Workshift Checkpoint"."Credit Net Turnover (LCY)") { }
            column(CreditUnrealSaleAmtLCY_; "POS Workshift Checkpoint"."Credit Unreal. Sale Amt. (LCY)") { }
            column(CreditUnrealSaleAmtLCYLastYear_; TempPOSWorkshiftCheckpoint."Credit Unreal. Sale Amt. (LCY)") { }
            column(EFTLCY_; "POS Workshift Checkpoint"."EFT (LCY)") { }
            column(EFTLCYLastYear_; TempPOSWorkshiftCheckpoint."EFT (LCY)") { }
            column(LocalCurrencyLCY_; "POS Workshift Checkpoint"."Local Currency (LCY)") { }
            column(LocalCurrencyLCYLastYear_; "POS Workshift Checkpoint"."Local Currency (LCY)") { }
            column(VarMain_; VarMain) { }
            column(NetTurnoverLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Net Turnover (LCY)")) { }
            column(DirectReturnSalesLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Direct Item Returns (LCY)")) { }
            column(TotalDiscountLClbl_; "POS Workshift Checkpoint".FieldCaption("Total Discount (LCY)")) { }
            column(TerminalCardLCYlbl_; "POS Workshift Checkpoint".FieldCaption("EFT (LCY)")) { }
            column(ManualCardLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Manual Card (LCY)")) { }
            column(OtherCreditCardLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Other Credit Card (LCY)")) { }
            column(CashTerminalLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Cash Terminal (LCY)")) { }
            column(CashMovementLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Local Currency (LCY)")) { }
            column(IssuedVoucherLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Issued Vouchers (LCY)")) { }
            column(RedeemedVoucherLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Redeemed Vouchers (LCY)")) { }
            column(RedeemedCreditVoucherLClbl_; "POS Workshift Checkpoint".FieldCaption("Redeemed Credit Voucher (LCY)")) { }
            column(CreatedCreditVoucherLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Created Credit Voucher (LCY)")) { }
            column(SalesCountlbl_; "POS Workshift Checkpoint".FieldCaption("Direct Sales Count")) { }
            column(ReceiptsCountlbl_; "POS Workshift Checkpoint".FieldCaption("Receipts Count")) { }
            column(ReturnSalesCountlbl_; "POS Workshift Checkpoint".FieldCaption("Direct Item Returns Line Count")) { }
            column(ReceiptCopiesCountlbl_; "POS Workshift Checkpoint".FieldCaption("Receipt Copies Count")) { }
            column(CashDrawerOpenCountlbl_; "POS Workshift Checkpoint".FieldCaption("Cash Drawer Open Count")) { }
            column(CancelledSalesCountlbl_; "POS Workshift Checkpoint".FieldCaption("Cancelled Sales Count")) { }
            column(DebitSalesCountlbl_; "POS Workshift Checkpoint".FieldCaption("Credit Item Quantity Sum")) { }
            column(DirectSalesLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Direct Item Sales (LCY)")) { }
            column(SalesStaffLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Direct Sales - Staff (LCY)")) { }
            column(DebitSalesLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Credit Item Sales (LCY)")) { }
            column(DebtorPaymentLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Debtor Payment (LCY)")) { }
            column(ForeignCurrencyLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Foreign Currency (LCY)")) { }
            column(GLPaymentLCYlbl_; "POS Workshift Checkpoint".FieldCaption("GL Payment (LCY)")) { }
            column(InvoicedSalesLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Credit Net Sales Amount (LCY)")) { }
            column(RoundingLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Rounding (LCY)")) { }
            column(TurnoverLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Turnover (LCY)")) { }
            column(NetCostLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Net Cost (LCY)")) { }
            column(ProfitAmountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Profit Amount (LCY)")) { }
            column(ProfitPerclbl_; "POS Workshift Checkpoint".FieldCaption("Profit %")) { }
            column(CampaignDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Campaign Discount (LCY)")) { }
            column(MixDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Mix Discount (LCY)")) { }
            column(QtyDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Quantity Discount (LCY)")) { }
            column(CustomDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Custom Discount (LCY)")) { }
            column(BOMDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("BOM Discount (LCY)")) { }
            column(CustomerDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Customer Discount (LCY)")) { }
            column(LineDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Line Discount (LCY)")) { }
            column(CampaignDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Campaign Discount %")) { }
            column(MixDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Mix Discount %")) { }
            column(QtyDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Quantity Discount %")) { }
            column(CustomDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Custom Discount %")) { }
            column(BOMDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("BOM Discount %")) { }
            column(CustomerDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Customer Discount %")) { }
            column(LineDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Line Discount %")) { }
            column(TotalDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Total Discount (LCY)")) { }
            column(TotalDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Total Discount %")) { }
            column(DirectTurnoverLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Direct Turnover (LCY)")) { }
            column(CreditTurnoverLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Credit Turnover (LCY)")) { }
            column(DirectNetTurnoverLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Direct Net Turnover (LCY)")) { }
            column(CreditRealAmtLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Credit Real. Sale Amt. (LCY)")) { }
            column(CreditRealReturnAmtLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Credit Real. Return Amt. (LCY)")) { }
            column(CreditNetTurnOverLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Credit Net Turnover (LCY)")) { }
            column(CreditUnrealSaleAmtLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Credit Unreal. Sale Amt. (LCY)")) { }
            column(EFTLCYlbl_; "POS Workshift Checkpoint".FieldCaption("EFT (LCY)")) { }
            column(LocalCurrencyLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Local Currency (LCY)")) { }
            column(StoreCode_; _POSEntry."POS Store Code") { }
            column(DocumentNo_; _POSEntry."Document No.") { }
            column(StartingTime_; _POSEntry."Starting Time") { }
            column(EndingTime_; _POSEntry."Ending Time") { }
            column(ClosingDate_; _POSEntry."Entry Date") { }
            column(UserFullName_; User."Full Name") { }
            column(SalespersonName_; Salesperson.Name) { }
            column(StoreLbl_; StoreLbl) { }
            column(SalesTicketNoLbl_; SalesTicketNoLbl) { }
            column(OpeningHrsLbl_; OpeningHrsLbl) { }
            column(ClosingDatelbl_; ClosingDatelbl) { }
            column(PreviousPeriodCaption; PreviousPeriodCaption) { }
            column(SignatureLbl_; SignatureLbl) { }
            column(PrintedBylbl_; PrintedByLbl) { }
            column(Salespersonlbl_; Salespersonlbl) { }
            column(PricesIncVAT_; Format(_POSEntry."Prices Including VAT")) { }
            column(PricesIncVATLbl_; _POSEntry.FieldCaption("Prices Including VAT")) { }
            column(CompanyName_; CompanyName) { }
            column(POSEntryDescription_; _POSEntry.Description) { }
            column(ReportTitle_; VarReportTitle) { }
            column(PrintSales_; PrintSales) { }
            column(PrintReceipts_; PrintReceipts) { }
            column(PrintTerminals_; PrintTerminals) { }
            column(PrintVouchers_; PrintVouchers) { }
            column(PrintTurnover_; PrintTurnOver) { }
            column(PrintDiscountAmt_; PrintDiscountAmt) { }
            column(PrintDiscountPerc_; PrintDiscountPerc) { }
            column(PrintDiscountTotal_; PrintDiscountTotal) { }
            column(PrintCounting_; PrintCounting) { }
            column(PrintClosing_; PrintClosing) { }
            column(PrintVAT_; PrintVAT) { }
            column(PrintAttachedBins_; PrintAttachedBins) { }
            column(PrintEmptyLines_; PrintEmptyLines) { }
            column(PrintNetTurnover_; PrintNetTurnover) { }
            column(PrintDiscount_; PrintDiscount) { }
            column(PrintCountedAmtInclFloat_; PrintCountedAmtInclFloat) { }
            column(PrintEFT_; PrintEFT) { }
            dataitem("POS Unit"; "NPR POS Unit")
            {
                DataItemLink = "No." = FIELD("POS Unit No.");
                DataItemTableView = SORTING("No.");
                column(POSUnitName_; "POS Unit".Name) { }
            }
            dataitem("POS Workshift Tax Checkpoint"; "NPR POS Worksh. Tax Checkp.")
            {
                DataItemLink = "Workshift Checkpoint Entry No." = FIELD("Entry No.");
                DataItemTableView = SORTING("Workshift Checkpoint Entry No.", "Tax Area Code", "VAT Identifier", "Tax Calculation Type");
                column(TaxAreaCode_; "POS Workshift Tax Checkpoint"."Tax Area Code")
                {
                }
                column(VATIdentifier_; "POS Workshift Tax Checkpoint"."VAT Identifier")
                {
                }
                column(TaxType_; "POS Workshift Tax Checkpoint"."Tax Type")
                {
                }
                column(TaxCalculationType_; "POS Workshift Tax Checkpoint"."Tax Calculation Type")
                {
                }
                column(TaxPerc_; "POS Workshift Tax Checkpoint"."Tax %")
                {
                }
                column(TaxAmount_; "POS Workshift Tax Checkpoint"."Tax Amount")
                {
                }
                column(TaxBaseAmount_; "POS Workshift Tax Checkpoint"."Tax Base Amount")
                {
                }
                column(AmtInclTax_; "POS Workshift Tax Checkpoint"."Amount Including Tax")
                {
                }
                column(VarTax_; VarTax)
                {
                }
                column(TaxEntryNo_; "POS Workshift Tax Checkpoint"."Entry No.")
                {
                }
                column(TaxAreaCodelbl_; "POS Workshift Tax Checkpoint".FieldCaption("Tax Area Code"))
                {
                }
                column(VATIdentifierlbl_; "POS Workshift Tax Checkpoint".FieldCaption("VAT Identifier"))
                {
                }
                column(TaxTypelbl_; "POS Workshift Tax Checkpoint".FieldCaption("Tax Type"))
                {
                }
                column(TaxCalculationTypelbl_; "POS Workshift Tax Checkpoint".FieldCaption("Tax Calculation Type"))
                {
                }
                column(TaxPerclbl_; "POS Workshift Tax Checkpoint".FieldCaption("Tax %"))
                {
                }
                column(TaxAmountlbl_; "POS Workshift Tax Checkpoint".FieldCaption("Tax Amount"))
                {
                }
                column(TaxBaseAmountlbl_; "POS Workshift Tax Checkpoint".FieldCaption("Tax Base Amount"))
                {
                }
                column(AmtInclTaxlbl_; "POS Workshift Tax Checkpoint".FieldCaption("Amount Including Tax"))
                {
                }

                trigger OnAfterGetRecord()
                begin
                    VarTax := 1;
                    VarMain := 0;
                    VarBin := 0;
                    VarAttachedBin := 0;
                end;
            }
            dataitem(BinCounting; "NPR POS Payment Bin Checkp.")
            {
                DataItemLink = "Workshift Checkpoint Entry No." = FIELD("Entry No.");
                DataItemTableView = SORTING("Entry No.");
                column(PaymentMethodNolbl_; BinCounting.FieldCaption("Payment Method No."))
                {
                }
                column(Descriptionlbl_; BinCounting.FieldCaption(Description))
                {
                }
                column(CalculatedAmountIncFloatlbl_; BinCounting.FieldCaption("Calculated Amount Incl. Float"))
                {
                }
                column(BankDepositBinCodelbl_; BinCounting.FieldCaption("Bank Deposit Bin Code"))
                {
                }
                column(BankDepositReferencelbl_; BinCounting.FieldCaption("Bank Deposit Reference"))
                {
                }
                column(BankDepositAmountlbl_; BinCounting.FieldCaption("Bank Deposit Amount"))
                {
                }
                column(MovetoBinCodelbl_; BinCounting.FieldCaption("Move to Bin Code"))
                {
                }
                column(MovetoBinReferencelbl_; BinCounting.FieldCaption("Move to Bin Reference"))
                {
                }
                column(MovetoBinAmountlbl_; BinCounting.FieldCaption("Move to Bin Amount"))
                {
                }
                column(NewFloatAmountlbl_; BinCounting.FieldCaption("New Float Amount"))
                {
                }
                column(CurrencyCodelbl_; BinCounting.FieldCaption("Currency Code"))
                {
                }
                column(PaymentTypeNolbl_; BinCounting.FieldCaption("Payment Type No."))
                {
                }
                column(FloatAmountlbl_; BinCounting.FieldCaption("Float Amount"))
                {
                }
                column(CountedAmountInclFloatlbl_; BinCounting.FieldCaption("Counted Amount Incl. Float"))
                {
                }
                column(Commentlbl_; BinCounting.FieldCaption(Comment))
                {
                }
                column(PaymentMethodNo_; BinCounting."Payment Method No.")
                {
                }
                column(Description_; BinCounting.Description)
                {
                }
                column(CalculatedAmountIncFloat_; BinCounting."Calculated Amount Incl. Float")
                {
                }
                column(BankDepositBinCode_; BinCounting."Bank Deposit Bin Code")
                {
                }
                column(BankDepositReference_; BinCounting."Bank Deposit Reference")
                {
                }
                column(BankDepositAmount_; BinCounting."Bank Deposit Amount")
                {
                }
                column(MovetoBinCode_; BinCounting."Move to Bin Code")
                {
                }
                column(MovetoBinReference_; BinCounting."Move to Bin Reference")
                {
                }
                column(MovetoBinAmount_; BinCounting."Move to Bin Amount")
                {
                }
                column(NewFloatAmount_; BinCounting."New Float Amount")
                {
                }
                column(CurrencyCode_; BinCounting."Currency Code")
                {
                }
                column(PaymentTypeNo_; BinCounting."Payment Type No.")
                {
                }
                column(FloatAmount_; BinCounting."Float Amount")
                {
                }
                column(CountedAmountInclFloat_; BinCounting."Counted Amount Incl. Float")
                {
                }
                column(Comment_; BinCounting.Comment)
                {
                }
                column(TransferredAmount_; BinCounting."Transfer In Amount" + BinCounting."Transfer Out Amount")
                {
                }
                column(VarBin_; VarBin)
                {
                }
                column(BinEntryNo_; BinCounting."Entry No.")
                {
                }
                dataitem(BinDenomination; "NPR POS Paym. Bin Denomin.")
                {
                    DataItemLink = "Bin Checkpoint Entry No." = FIELD("Entry No.");
                    DataItemTableView = SORTING("Bin Checkpoint Entry No.");
                    column(Denomination_Type; BinDenomination."Denomination Type")
                    {
                    }
                    column(Denomination; BinDenomination.Denomination)
                    {
                    }
                    column(Amount; BinDenomination.Amount)
                    {
                    }
                    column(Quantity; BinDenomination.Quantity)
                    {
                    }
                    column(AttachedToID; BinDenomination."Attached-to ID".AsInteger()) { }
                    column(VarDenomination_; VarDenomination)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        VarDenomination := 1;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    VarTax := 0;
                    VarMain := 0;
                    VarBin := 1;
                    VarAttachedBin := 0;
                end;
            }
            dataitem(AttachedPaymentBins; "NPR POS Unit to Bin Relation")
            {
                DataItemLink = "POS Unit No." = FIELD("POS Unit No.");
                DataItemTableView = SORTING("POS Unit No.", "POS Payment Bin No.");
                column(AttPOSUnitNo_; AttachedPaymentBins."POS Unit No.")
                {
                }
                column(AttPOSUnitStatus_; AttachedPaymentBins."POS Unit Status")
                {
                }
                column(AttPOSUnitName_; AttachedPaymentBins."POS Unit Name")
                {
                }
                column(AttPOSBinStatus_; AttachedPaymentBins."POS Payment Bin Status")
                {
                }
                column(AttPOSBinNo_; AttachedPaymentBins."POS Payment Bin No.")
                {
                }
                column(AttPOSUnitNolbl_; AttachedPaymentBins.FieldCaption("POS Unit No."))
                {
                }
                column(AttPOSUnitStatuslbl_; AttachedPaymentBins.FieldCaption("POS Unit Status"))
                {
                }
                column(AttPOSUnitNamelbl_; AttachedPaymentBins.FieldCaption("POS Unit Name"))
                {
                }
                column(AttPOSBinStatuslbl_; AttachedPaymentBins.FieldCaption("POS Payment Bin Status"))
                {
                }
                column(AttPOSBinNolbl_; AttachedPaymentBins.FieldCaption("POS Payment Bin No."))
                {
                }
                column(VarAttached_; VarAttachedBin)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    VarTax := 0;
                    VarMain := 0;
                    VarBin := 0;
                    VarAttachedBin := 1;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                VarMain := 1;

                if _POSEntry.Get("POS Workshift Checkpoint"."POS Entry No.") then
                    CalcInPreviousPeriod(PreviousPeriodCaption, TempPOSWorkshiftCheckpoint, _POSEntry);
                if Salesperson.Get(_POSEntry."Salesperson Code") then;
                IF User.GET(USERSECURITYID()) THEN;

                VarBalancedBy := '';
                VarBalancedBy := BalancedByLbl + ' ' + Salesperson.Name + ' ' + WithLbl;

                VarReportTitle := '';
                if "POS Workshift Checkpoint".Open then
                    VarReportTitle := LblXReport
                else
                    VarReportTitle := LblZReport;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group("Print Options")
                {
                    Caption = 'Print Options';
                    field("Print TurnOver"; PrintTurnOver)
                    {
                        Caption = 'Print TurnOver';
                        ToolTip = 'Specifies the value of the Print TurnOver field';
                        ApplicationArea = NPRRetail;
                    }
                    field(CompareDay_; CompareDay)
                    {
                        Caption = 'Compare To Day';
                        ToolTip = 'Specifies the value of the Compare To Day field';
                        ApplicationArea = NPRRetail;
                    }
                    field(compareNearestDate_; CompareNearestDate)
                    {
                        Caption = 'Compare Nearest Date';
                        ToolTip = 'Specifies the value of the Compare Nearest Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Discount"; PrintDiscount)
                    {
                        Caption = 'Print Discount';
                        ToolTip = 'Specifies the value of the Print Discount field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print VAT"; PrintVAT)
                    {
                        Caption = 'Print VAT';
                        ToolTip = 'Specifies the value of the Print VAT field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print EFT"; PrintEFT)
                    {
                        Caption = 'Print EFT';
                        ToolTip = 'Specifies the value of the Print EFT field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Vouchers"; PrintVouchers)
                    {
                        Caption = 'Print Vouchers';
                        ToolTip = 'Specifies the value of the Print Vouchers field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Counting"; PrintCounting)
                    {
                        Caption = 'Print Counting';
                        ToolTip = 'Specifies the value of the Print Counting field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Counted Amt Incl Float"; PrintCountedAmtInclFloat)
                    {
                        Caption = 'Print Counted Amt Incl Float';
                        ToolTip = 'Specifies the value of the Print Counted Amt Incl Float field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Closing"; PrintClosing)
                    {
                        Caption = 'Print Closing';
                        ToolTip = 'Specifies the value of the Print Closing field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Attached Bins"; PrintAttachedBins)
                    {
                        Caption = 'Print Attached Bins';
                        ToolTip = 'Specifies the value of the Print Attached Bins field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Empty Lines"; PrintEmptyLines)
                    {
                        Caption = 'Print Lines Where Value Is Zero';
                        ToolTip = 'Specifies the value of the Print Lines Where Value Is Zero field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            PrintTurnOver := true;
            PrintDiscount := true;
            PrintVAT := true;
            PrintEFT := true;
            PrintVouchers := true;
            PrintCounting := true;
            PrintCountedAmtInclFloat := true;
            PrintClosing := true;
            PrintAttachedBins := true;
            CompareDay := true;
            CompareNearestDate := true;
        end;
    }

    trigger OnPreReport()
    begin
        if CompanyInfo.Get() then;
        CompanyInfo.CalcFields(Picture);
    end;

    var
        CompanyInfo: Record "Company Information";
        _POSEntry: Record "NPR POS Entry";
        Salesperson: Record "Salesperson/Purchaser";
        User: Record User;
        TempPOSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint" temporary;
        CompareNearestDate, CompareDay, PrintVouchers, PrintVAT, PrintTurnOver, PrintTerminals, PrintSales, PrintReceipts, PrintNetTurnover, PrintAttachedBins, PrintClosing, PrintCountedAmtInclFloat, PrintCounting, PrintDiscount, PrintDiscountAmt, PrintDiscountPerc, PrintDiscountTotal, PrintEFT, PrintEmptyLines : Boolean;
        VarTax, VarMain, VarDenomination, VarBin, VarAttachedBin : Integer;
        AttachedPaymentBinslbl: Label 'Attached Payment Bins';
        Closinglbl: Label 'Closing';
        ClosingDatelbl: Label 'Closing Date';
        Countinglbl: Label 'Counting';
        Discountlbl: Label 'Discount';
        DiscountAmtlbl: Label 'Discount Amount';
        DiscountPerclbl: Label 'Discount Percentage';
        DiscountTotallbl: Label 'Discount Total';
        EFTlbl: Label 'EFT';
        OpeningHrsLbl: Label 'Opening Hours';
        CustomerPaymentLbl: Label 'Payment';
        StoreLbl: Label 'POS Store';
        POSUnitLbl: Label 'POS Unit';
        Receiptslbl: Label 'Receipts';
        BalancedByLbl: Label 'Register Balanced By';
        Saleslbl: Label 'Sales';
        SalesTicketNoLbl: Label 'Sales Ticket No';
        SignatureLbl: Label 'Signature';
        Terminalslbl: Label 'Terminals';
        Turnoverlbl: Label 'Turnover (LCY)';
        VATTaxSummarylbl: Label 'VAT & TAX Summary';
        Voucherslbl: Label 'Vouchers';
        WithLbl: Label 'With';
        Workshiftlbl: Label 'Workshift';
        LblXReport: Label 'X-Report';
        LblZReport: Label 'Z-Report';
        PrintedByLbl: Label 'Printed by';
        Salespersonlbl: Label 'Salesperson';
        AnalysisPeriodLbl: Label 'Analysis Period';
        LastYearLbl: Label 'Previous Period';
        CompareToDayLbl: Label 'Compare to Day %1', Comment = '%1=DateFilter';
        CompareToLastYearLbl: Label 'Compare to Last Year %1', Comment = '%1=DateFilter';
        VarBalancedBy, PreviousPeriodCaption, VarReportTitle : Text;

    local procedure CalcInPreviousPeriod(var PreviousPeriod: Text; var WorkshiftCheckpointPrevious: Record "NPR POS Workshift Checkpoint"; POSEntry: Record "NPR POS Entry")
    var
        WorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        TempWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint" temporary;
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSEntry2: Record "NPR POS Entry";
        POSWorkshiftCheckpointUnit: codeunit "NPR POS Workshift Checkpoint";
        StartDate, EndDate : Date;
        WeekDay, Week, Year : Integer;
    begin
        if not CompareDay then begin
            StartDate := CalcDate('<-1Y>', POSEntry."Entry Date");
            EndDate := CalcDate('<-1Y>', POSEntry."Entry Date");
            if StartDate <> EndDate then
                PreviousPeriod := StrSubStNo(CompareToLastYearLbl, Format(StartDate) + '..' + Format(EndDate))
            else
                PreviousPeriod := StrSubStNo(CompareToLastYearLbl, Format(StartDate));
        end else begin
            StartDate := POSEntry."Entry Date";
            EndDate := POSEntry."Entry Date";
            WeekDay := Date2DWY(StartDate, 1);
            Week := Date2DWY(StartDate, 2);
            Year := Date2DWY(StartDate, 3) - 1;
            if CompareNearestDate then
                Week += 1;
            StartDate := DWY2Date(WeekDay, Week, Year);
            WeekDay := Date2DWY(EndDate, 1);
            Week := Date2DWY(EndDate, 2);
            Year := Date2DWY(EndDate, 3) - 1;
            if CompareNearestDate then
                Week += 1;
            EndDate := DWY2Date(WeekDay, Week, Year);
            PreviousPeriod := CompareToDayLbl;
            if StartDate <> EndDate then
                PreviousPeriod := StrSubStNo(CompareToDayLbl, Format(StartDate) + '..' + Format(EndDate))
            else
                PreviousPeriod := StrSubStNo(CompareToDayLbl, Format(StartDate));
        end;
        WorkshiftCheckpoint.SetRange("POS Unit No.", POSEntry."POS Unit No.");
        WorkshiftCheckpoint.SetRange("Created at", CreateDateTime(StartDate, 0T), CreateDateTime(EndDate, 0T));
        if not WorkshiftCheckpoint.IsEmpty() then begin
            WorkshiftCheckpoint.CalcSums(
                                "Net Turnover (LCY)", "Direct Item Returns (LCY)", "Direct Item Sales (LCY)", "Debtor Payment (LCY)",
                                "GL Payment (LCY)", "Direct Turnover (LCY)", "Credit Turnover (LCY)", "Direct Net Turnover (LCY)", "Credit Real. Sale Amt. (LCY)",
                                "Credit Real. Return Amt. (LCY)", "Total Discount (LCY)", "Credit Unreal. Sale Amt. (LCY)", "Local Currency (LCY)", "EFT (LCY)",
                                "Issued Vouchers (LCY)", "Redeemed Vouchers (LCY)", "Direct Sales Count", "Cancelled Sales Count", "Direct Item Returns Line Count",
                                "Receipts Count", "Receipt Copies Count", "Cash Drawer Open Count");
            WorkshiftCheckpointPrevious := WorkshiftCheckpoint;
        end else begin
            GeneralLedgerSetup.Get();
            POSEntry2.SetRange("POS Store Code", POSEntry."POS Store Code");
            POSEntry2.SetRange("POS Unit No.", POSEntry."POS Unit No.");
            POSEntry2.SetFilter("Entry Date", '%1..%2', StartDate, EndDate);
            if POSEntry2.FindSet() then begin
                POSEntrySalesLine.Reset();
                POSEntrySalesLine.SetRange("POS Entry No.", POSEntry2."Entry No.");
                POSEntrySalesLine.SetRange("Exclude from Posting", false);
                if POSEntrySalesLine.FindSet() then begin
                    repeat
                        POSWorkshiftCheckpointUnit.SetTurnoverAndProfit(TempWorkshiftCheckpoint, POSEntrySalesLine, POSEntry2);
                        POSWorkshiftCheckpointUnit.SetDiscounts(TempWorkshiftCheckpoint, POSEntrySalesLine);
                    until POSEntrySalesLine.Next() = 0;
                end;
                POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry2."Entry No.");
                if POSEntryPaymentLine.FindSet() then begin
                    repeat
                        POSWorkshiftCheckpointUnit.SetPayments(TempWorkshiftCheckpoint, POSEntryPaymentLine, GeneralLedgerSetup."LCY Code");
                    until POSEntryPaymentLine.Next() = 0;
                end;
            end;
            POSEntry2.SetRange("Entry Type", POSEntry2."Entry Type"::"Direct Sale");
            POSEntry2.SetRange("System Entry", false);
            TempWorkshiftCheckpoint."Direct Sales Count" := POSEntry2.Count();

            POSEntry2.SetRange("Entry Type", POSEntry2."Entry Type"::"Cancelled Sale");
            TempWorkshiftCheckpoint."Cancelled Sales Count" := POSEntry2.Count();

            WorkshiftCheckpointPrevious.Copy(TempWorkshiftCheckpoint, true);
        end;
    end;
}

