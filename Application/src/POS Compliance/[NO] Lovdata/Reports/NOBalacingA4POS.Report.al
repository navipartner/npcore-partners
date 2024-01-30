report 6014468 "NPR NO Balacing A4 POS"
{
#if not BC17
    Extensible = false;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/POS Compliance/[NO] Lovdata/Reports/layouts/NOBalancingA4POS.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRNOFiscal;
    Caption = 'NO Balancing Report A4 POS';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("POS Workshift Checkpoint"; "NPR POS Workshift Checkpoint")
        {
            RequestFilterFields = "Entry No.";
            CalcFields = "FF Total Dir. Item Return(LCY)", "FF Total Dir. Item Sales (LCY)";

            column(CompInfoPicture_; CompanyInfo.Picture) { }
            column(CompanyAddress; StrSubstNo(CompanyAddressInfoLbl, CompanyInfo.Address, CompanyInfo.City, CompanyInfo."Post Code")) { }
            column(CompanyVATRegNumber; StrSubstNo(VATRegistationNoLbl, CompanyInfo."VAT Registration No.")) { }
            column(Saleslbl_; Saleslbl) { }
            column(Receiptslbl_; Receiptslbl) { }
            column(Terminalslbl_; Terminalslbl) { }
            column(Voucherslbl_; Voucherslbl) { }
            column(Turnoverlbl_; Turnoverlbl) { }
            column(TurnoverProfitlbl; TurnoverProfitlbl) { }
            column(Discountlbl_; Discountlbl) { }
            column(OnOrderlbl_; OnOrderlbl) { }
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
            column(DirectReturnSalesLCY_; "POS Workshift Checkpoint"."Direct Item Returns (LCY)") { }
            column(TotalDiscountLCY_; "POS Workshift Checkpoint"."Total Discount (LCY)") { }
            column(TerminalCardLCY_; "POS Workshift Checkpoint"."EFT (LCY)") { }
            column(ManualCardLCY_; "POS Workshift Checkpoint"."Manual Card (LCY)") { }
            column(OtherCreditCardLCY_; "POS Workshift Checkpoint"."Other Credit Card (LCY)") { }
            column(CashTerminalLCY_; "POS Workshift Checkpoint"."Cash Terminal (LCY)") { }
            column(CashMovementLCY_; "POS Workshift Checkpoint"."Local Currency (LCY)") { }
            column(IssuedVoucherLCY_; "POS Workshift Checkpoint"."Issued Vouchers (LCY)") { }
            column(RedeemedVoucherLCY_; "POS Workshift Checkpoint"."Redeemed Vouchers (LCY)") { }
            column(RedeemedCreditVoucherLCY_; "POS Workshift Checkpoint"."Redeemed Credit Voucher (LCY)") { }
            column(CreatedCreditVoucherLCY_; "POS Workshift Checkpoint"."Created Credit Voucher (LCY)") { }
            column(SalesCount_; "POS Workshift Checkpoint"."Direct Sales Count") { }
            column(ReceiptsCount_; "POS Workshift Checkpoint"."Receipts Count") { }
            column(ReturnSalesCount_; "POS Workshift Checkpoint"."Direct Item Returns Line Count") { }
            column(ReceiptCopiesCount_; "POS Workshift Checkpoint"."Receipt Copies Count") { }
            column(CashDrawerOpenCount_; "POS Workshift Checkpoint"."Cash Drawer Open Count") { }
            column(CancelledSalesCount_; "POS Workshift Checkpoint"."Cancelled Sales Count") { }
            column(DebitsalesCount_; "POS Workshift Checkpoint"."Credit Item Quantity Sum") { }
            column(DirectSalesLCY_; "POS Workshift Checkpoint"."Direct Item Sales (LCY)") { }
            column(SalesStaffLCY_; "POS Workshift Checkpoint"."Direct Sales - Staff (LCY)") { }
            column(DebitSalesLCY_; "POS Workshift Checkpoint"."Credit Item Sales (LCY)") { }
            column(DebtorPaymentLCY_; "POS Workshift Checkpoint"."Debtor Payment (LCY)") { }
            column(ForeignCurrencyLCY_; "POS Workshift Checkpoint"."Foreign Currency (LCY)") { }
            column(GLPaymentLCY_; "POS Workshift Checkpoint"."GL Payment (LCY)") { }
            column(InvoicedSalesLCY_; "POS Workshift Checkpoint"."Credit Net Sales Amount (LCY)") { }
            column(RoundingLCY_; "POS Workshift Checkpoint"."Rounding (LCY)") { }
            column(TurnoverLCY_; "POS Workshift Checkpoint"."Turnover (LCY)") { }
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
            column(CreditTurnoverLCY_; "POS Workshift Checkpoint"."Credit Turnover (LCY)") { }
            column(DirectNetTurnoverLCY_; "POS Workshift Checkpoint"."Direct Net Turnover (LCY)") { }
            column(CreditRealAmtLCY_; "POS Workshift Checkpoint"."Credit Real. Sale Amt. (LCY)") { }
            column(CreditRealReturnAmtLCY_; "POS Workshift Checkpoint"."Credit Real. Return Amt. (LCY)") { }
            column(CreditNetTurnOverLCY_; "POS Workshift Checkpoint"."Credit Net Turnover (LCY)") { }
            column(CreditUnrealSaleAmtLCY_; "POS Workshift Checkpoint"."Credit Unreal. Sale Amt. (LCY)") { }
            column(EFTLCY_; "POS Workshift Checkpoint"."EFT (LCY)") { }
            column(LocalCurrencyLCY_; "POS Workshift Checkpoint"."Local Currency (LCY)") { }
            column(DiscountsCount_; "Discounts Count") { }
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
            column(DiscountsCountLbl_; "POS Workshift Checkpoint".FieldCaption("Discounts Count")) { }
            column(Total_WithItemCategoryQuantity; WithItemCategoryQuantity) { }
            column(Total_WithItemCategoryAmount; WithItemCategoryAmount) { }
            column(Total_WithoutItemCategoryQuantity; WithoutItemCategoryQuantity) { }
            column(Total_WithoutItemCategoryAmount; WithoutItemCategoryAmount) { }
            column(Total_ReturnSales; "FF Total Dir. Item Return(LCY)") { }
            column(Total_BrutoSales; "FF Total Dir. Item Sales (LCY)") { }
            column(Total_NetoSales; "FF Total Dir. Item Sales (LCY)" - Abs("FF Total Dir. Item Return(LCY)")) { }
            column(Total_PriceLookupQuantity; TotalPriceLookupQuantity) { }
            column(AppVersionText; AppVersionTxt) { }
            column(FirstSaleDatetimeTxt; FirstSaleDatetimeTxt) { }
            column(LastSaleDatetimeTxt; LastSaleDatetimeTxt) { }
            column(FirstLoginDatetimeTxt; FirstLoginDatetimeTxt) { }
            column(ClosingDatetimeTxt; ClosingDatetimeTxt) { }
            column(POSOpenedByTxt; POSOpenedByTxt) { }
            column(POSClosedByTxt; POSClosedByTxt) { }
            column(PreviousZReportDateTimeTxt; PreviousZReportDateTimeTxt) { }
            column(StoreCode_; POSEntry."POS Store Code") { }
            column(DocumentNo_; POSEntry."Document No.") { }
            column(StartingTime_; POSEntry."Starting Time") { }
            column(EndingTime_; POSEntry."Ending Time") { }
            column(ClosingDate_; POSEntry."Entry Date") { }
            column(UserFullName_; User."Full Name") { }
            column(SalespersonName_; Salesperson.Name) { }
            column(StoreLbl_; StoreLbl) { }
            column(SalesTicketNoLbl_; SalesTicketNoLbl) { }
            column(OpeningHrsLbl_; OpeningHrsLbl) { }
            column(ClosingDatelbl_; ClosingDatelbl) { }
            column(SignatureLbl_; SignatureLbl) { }
            column(PrintedBylbl_; PrintedByLbl) { }
            column(Salespersonlbl_; Salespersonlbl) { }
            column(PricesIncVAT_; Format(POSEntry."Prices Including VAT")) { }
            column(PricesIncVATLbl_; POSEntry.FieldCaption("Prices Including VAT")) { }
            column(OtherPaymentslbl; OtherPaymentslbl) { }
            column(CompanyName_; CompanyName()) { }
            column(POSEntryDescription_; POSEntry.Description) { }
            column(ReportTitle_; VarReportTitle) { }
            column(PrintSales_; PrintSales) { }
            column(PrintReceipts_; PrintReceipts) { }
            column(PrintTerminals_; PrintTerminals) { }
            column(PrintVouchers_; PrintVouchers) { }
            column(PrintOnOrder_; PrintOnOrder) { }
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
            column(CountedAmountInclFloatlbl_; CountedAmountInclFloatlbl_) { }
            dataitem("POS Unit"; "NPR POS Unit")
            {
                DataItemLink = "No." = field("POS Unit No.");
                DataItemTableView = sorting("No.");
                column(POSUnitName_; "POS Unit".Name) { }
            }
            dataitem("POS Workshift Tax Checkpoint"; "NPR POS Worksh. Tax Checkp.")
            {
                DataItemLink = "Workshift Checkpoint Entry No." = field("Entry No.");
                DataItemTableView = sorting("Workshift Checkpoint Entry No.", "Tax Area Code", "VAT Identifier", "Tax Calculation Type");
                column(TaxAreaCode_; "POS Workshift Tax Checkpoint"."Tax Area Code") { }
                column(VATIdentifier_; "POS Workshift Tax Checkpoint"."VAT Identifier") { }
                column(TaxType_; "POS Workshift Tax Checkpoint"."Tax Type") { }
                column(TaxCalculationType_; "POS Workshift Tax Checkpoint"."Tax Calculation Type") { }
                column(TaxPerc_; "POS Workshift Tax Checkpoint"."Tax %") { }
                column(TaxAmount_; "POS Workshift Tax Checkpoint"."Tax Amount") { }
                column(TaxBaseAmount_; "POS Workshift Tax Checkpoint"."Tax Base Amount") { }
                column(AmtInclTax_; "POS Workshift Tax Checkpoint"."Amount Including Tax") { }
                column(VarTax_; VarTax) { }
                column(TaxEntryNo_; "POS Workshift Tax Checkpoint"."Entry No.") { }
                column(TaxAreaCodelbl_; "POS Workshift Tax Checkpoint".FieldCaption("Tax Area Code")) { }
                column(VATIdentifierlbl_; "POS Workshift Tax Checkpoint".FieldCaption("VAT Identifier")) { }
                column(TaxTypelbl_; "POS Workshift Tax Checkpoint".FieldCaption("Tax Type")) { }
                column(TaxCalculationTypelbl_; "POS Workshift Tax Checkpoint".FieldCaption("Tax Calculation Type")) { }
                column(TaxPerclbl_; "POS Workshift Tax Checkpoint".FieldCaption("Tax %")) { }
                column(TaxAmountlbl_; "POS Workshift Tax Checkpoint".FieldCaption("Tax Amount")) { }
                column(TaxBaseAmountlbl_; "POS Workshift Tax Checkpoint".FieldCaption("Tax Base Amount")) { }
                column(AmtInclTaxlbl_; "POS Workshift Tax Checkpoint".FieldCaption("Amount Including Tax")) { }

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
                DataItemLink = "Workshift Checkpoint Entry No." = field("Entry No.");
                DataItemTableView = sorting("Entry No.");
                column(PaymentMethodNolbl_; BinCounting.FieldCaption("Payment Method No.")) { }
                column(Descriptionlbl_; BinCounting.FieldCaption(Description)) { }
                column(CalculatedAmountIncFloatlbl_; BinCounting.FieldCaption("Calculated Amount Incl. Float")) { }
                column(BankDepositBinCodelbl_; BinCounting.FieldCaption("Bank Deposit Bin Code")) { }
                column(BankDepositReferencelbl_; BinCounting.FieldCaption("Bank Deposit Reference")) { }
                column(BankDepositAmountlbl_; BinCounting.FieldCaption("Bank Deposit Amount")) { }
                column(MovetoBinCodelbl_; BinCounting.FieldCaption("Move to Bin Code")) { }
                column(MovetoBinReferencelbl_; BinCounting.FieldCaption("Move to Bin Reference")) { }
                column(MovetoBinAmountlbl_; BinCounting.FieldCaption("Move to Bin Amount")) { }
                column(NewFloatAmountlbl_; BinCounting.FieldCaption("New Float Amount")) { }
                column(CurrencyCodelbl_; BinCounting.FieldCaption("Currency Code")) { }
                column(PaymentTypeNolbl_; BinCounting.FieldCaption("Payment Type No.")) { }
                column(FloatAmountlbl_; BinCounting.FieldCaption("Float Amount")) { }
                column(PaymentsCountLbl_; BinCounting.FieldCaption("Payments Count")) { }
                column(Commentlbl_; BinCounting.FieldCaption(Comment)) { }
                column(PaymentMethodNo_; BinCounting."Payment Method No.") { }
                column(Description_; BinCounting.Description) { }
                column(CalculatedAmountIncFloat_; BinCounting."Calculated Amount Incl. Float") { }
                column(BankDepositBinCode_; BinCounting."Bank Deposit Bin Code") { }
                column(BankDepositReference_; BinCounting."Bank Deposit Reference") { }
                column(BankDepositAmount_; BinCounting."Bank Deposit Amount") { }
                column(MovetoBinCode_; BinCounting."Move to Bin Code") { }
                column(MovetoBinReference_; BinCounting."Move to Bin Reference") { }
                column(MovetoBinAmount_; BinCounting."Move to Bin Amount") { }
                column(NewFloatAmount_; BinCounting."New Float Amount") { }
                column(CurrencyCode_; BinCounting."Currency Code") { }
                column(PaymentTypeNo_; BinCounting."Payment Type No.") { }
                column(FloatAmount_; BinCounting."Float Amount") { }
                column(CountedAmountInclFloat_; BinCounting."Counted Amount Incl. Float") { }
                column(Comment_; BinCounting.Comment) { }
                column(TransferredAmount_; BinCounting."Transfer In Amount" + BinCounting."Transfer Out Amount") { }
                column(VarBin_; VarBin) { }
                column(BinEntryNo_; BinCounting."Entry No.") { }
                column(PaymentsCount_; "Payments Count") { }
                column(ifBankDenominExists; ifBankDenominExists) { }
                column(ifMoveBinDenominExists; ifMoveBinDenominExists) { }
                column(ifCountingDenominExists; ifCountingDenominExists) { }
                dataitem(BinDenomination; "NPR POS Paym. Bin Denomin.")
                {
                    DataItemLink = "Bin Checkpoint Entry No." = field("Entry No.");
                    DataItemTableView = sorting("Bin Checkpoint Entry No.");
                    column(Denomination_Type; BinDenomination."Denomination Type") { }
                    column(Denomination; BinDenomination.Denomination) { }
                    column(Amount; BinDenomination.Amount) { }
                    column(Quantity; BinDenomination.Quantity) { }
                    column(AttachedToID; BinDenomination."Attached-to ID".AsInteger()) { }
                    column(VarDenomination_; VarDenomination) { }

                    trigger OnAfterGetRecord()
                    begin
                        VarDenomination := 1;

                        case BinDenomination."Attached-to ID".AsInteger() of
                            0:
                                ifCountingDenominExists := true;
                            1:
                                ifBankDenominExists := true;
                            2:
                                ifMoveBinDenominExists := true;
                            else begin
                                ifCountingDenominExists := false;
                                ifBankDenominExists := false;
                                ifMoveBinDenominExists := false;
                            end;
                        end;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    VarTax := 0;
                    VarMain := 0;
                    VarBin := 1;
                    VarDenomination := 0;
                    VarAttachedBin := 0;
                    ifCountingDenominExists := false;
                    ifBankDenominExists := false;
                    ifMoveBinDenominExists := false;
                end;
            }
            dataitem(AttachedPaymentBins; "NPR POS Unit to Bin Relation")
            {
                DataItemLink = "POS Unit No." = field("POS Unit No.");
                DataItemTableView = sorting("POS Unit No.", "POS Payment Bin No.");
                column(AttPOSUnitNo_; AttachedPaymentBins."POS Unit No.") { }
                column(AttPOSUnitStatus_; AttachedPaymentBins."POS Unit Status") { }
                column(AttPOSUnitName_; AttachedPaymentBins."POS Unit Name") { }
                column(AttPOSBinStatus_; AttachedPaymentBins."POS Payment Bin Status") { }
                column(AttPOSBinNo_; AttachedPaymentBins."POS Payment Bin No.") { }
                column(AttPOSUnitNolbl_; AttachedPaymentBins.FieldCaption("POS Unit No.")) { }
                column(AttPOSUnitStatuslbl_; AttachedPaymentBins.FieldCaption("POS Unit Status")) { }
                column(AttPOSUnitNamelbl_; AttachedPaymentBins.FieldCaption("POS Unit Name")) { }
                column(AttPOSBinStatuslbl_; AttachedPaymentBins.FieldCaption("POS Payment Bin Status")) { }
                column(AttPOSBinNolbl_; AttachedPaymentBins.FieldCaption("POS Payment Bin No.")) { }
                column(VarAttached_; VarAttachedBin) { }

                trigger OnAfterGetRecord()
                begin
                    VarTax := 0;
                    VarMain := 0;
                    VarBin := 0;
                    VarAttachedBin := 1;
                end;
            }

            dataitem(ItemCategories; "NPR Item Category Buffer")
            {
                DataItemTableView = sorting("Entry No.");
                UseTemporary = true;

                column(ItemCategory_Code; "Code") { }
                column(ItemCategory_Quantity; "Calc Field 1") { }
                column(ItemCategory_AmountInclVATLCY; "Calc Field 2") { }
            }

            dataitem(Salespersons; "Salesperson/Purchaser")
            {
                DataItemTableView = sorting(Code);

                column(Salesperson_Code; "Code") { }
                column(Salesperson_Name; Name) { }
                column(Salesperson_Title; StrSubstNo(SalespersonTitleLbl, Salespersons.Name, Salespersons.Code)) { }

                column(Salesperson_QuantityCards; QuantityCards) { }
                column(Salesperson_TotalCards; TotalCards) { }
                column(Salesperson_QuantityOthers; QuantityOther) { }
                column(Salesperson_TotalOther; TotalOther) { }
                column(Salesperson_ZeroLinesQuantity; ZeroLinesQuantity) { }
                column(Salesperson_BrutoAmount; BrutoAmount) { }
                column(Salesperson_ReturnAmount; ReturnAmount) { }
                column(Salesperson_NetoAmount; NetoAmount) { }
                column(Salesperson_Tax25Amount; Tax25Amount) { }
                column(Salesperson_TaxAmount; TaxAmount) { }
                column(Salesperson_ReturnTax25Amount; ReturnTax25Amount) { }
                column(Salesperson_ReturnTaxAmount; ReturnTaxAmount) { }
                column(Salesperson_InitialFloatAmount; InitialFloatAmount) { }
                column(Salesperson_DiscountAmount; DiscountAmount) { }
                column(Salesperson_ReturnedRecieptsQuantity; ReturnedRecieptsQuantity) { }
                column(Salesperson_SoldProductsQuantity; SoldProductsQuantity) { }
                column(Salesperson_ReturnedProductsQuantity; Abs(ReturnedProductsQuantity)) { }
                column(Salesperson_DiscountQuantity; DiscountQuantity) { }
                column(Salesperson_CashDrawerOpenQuantity; CashDrawerOpenQuantity) { }
                column(Salesperson_ReceiptCopyAmount; ReceiptCopyAmount) { }
                column(Salesperson_ReceiptCopyQuantity; ReceiptCopyQuantity) { }
                column(Salesperson_ReceiptPrintQuantity; ReceiptPrintQuantity) { }
                column(Salesperson_CancelledReceiptsQuantity; CancelledReceiptsQuantity) { }
                column(Salesperson_CancelledReceiptsAmount; CancelledReceiptsAmount) { }
                column(Salesperson_PriceLookupQuantity; PriceLookupQuantity) { }

                trigger OnAfterGetRecord()
                begin
                    TempSalespersonBuffer.Reset();
                    if TempSalespersonBuffer.IsEmpty() then
                        CurrReport.Skip();

                    TempSalespersonBuffer.SetRange("Vendor No.", Salespersons.Code);

                    if not TempSalespersonBuffer.FindFirst() then
                        CurrReport.Skip();

                    SetSalespersonStatistics("POS Workshift Checkpoint", Salespersons);
                end;
            }

            trigger OnAfterGetRecord()
            var
                POSUnit: Record "NPR POS Unit";
                PreviousZReport: Record "NPR POS Workshift Checkpoint";
            begin
                VarMain := 1;
                Clear(FromPOSEntryNo);

                POSEntry.Get("POS Workshift Checkpoint"."POS Entry No.");
                Salesperson.Get(POSEntry."Salesperson Code");
                User.Get(UserSecurityId());
                POSUnit.Get("POS Workshift Checkpoint"."POS Unit No.");
                FromPOSEntryNo := NOReportStatisticsMgt.FindFromEntryNo("POS Workshift Checkpoint"."POS Unit No.", "POS Workshift Checkpoint"."Entry No.");
                ClosingDatetimeTxt := Format("POS Workshift Checkpoint".SystemCreatedAt);
                POSClosedByTxt := Salesperson.Name;
                FillItemCategoryBuffer(ItemCategories, FromPOSEntryNo, "POS Workshift Checkpoint"."POS Entry No.", POSUnit, WithItemCategoryAmount, WithoutItemCategoryAmount, WithItemCategoryQuantity, WithoutItemCategoryQuantity);
                FillSalespersonBuffer(TempSalespersonBuffer, FromPOSEntryNo, "POS Workshift Checkpoint"."POS Entry No.", POSUnit);

                Clear(PreviousZReportDateTimeTxt);
                if NOReportStatisticsMgt.FindPreviousZReport(PreviousZReport, "POS Workshift Checkpoint"."POS Unit No.", "POS Workshift Checkpoint"."Entry No.") then
                    PreviousZReportDateTimeTxt := Format(PreviousZReport.SystemCreatedAt)
                else
                    PreviousZReportDateTimeTxt := Format("POS Workshift Checkpoint".SystemCreatedAt);

                VarBalancedBy := '';
                VarBalancedBy := BalancedByLbl + ' ' + Salesperson.Name + ' ' + WithLbl;

                VarReportTitle := '';
                if "POS Workshift Checkpoint".Open then
                    VarReportTitle := LblXReport
                else
                    VarReportTitle := LblZReport;

                NOReportStatisticsMgt.GetAppVersionText(AppVersionTxt);

                NOReportStatisticsMgt.SetFilterOnPOSEntry(POSEntry, POSUnit, FromPOSEntryNo, "POS Workshift Checkpoint"."POS Entry No.", '');
                if POSEntry.FindFirst() then
                    FirstSaleDatetimeTxt := Format(POSEntry.SystemCreatedAt);

                if POSEntry.FindLast() then
                    LastSaleDatetimeTxt := Format(POSEntry.SystemCreatedAt);

                GetFirstLoginTimeAndPOSOpenedBy("POS Workshift Checkpoint", POSOpenedByTxt, FirstLoginDatetimeTxt);
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
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print On Order"; PrintOnOrder)
                    {
                        Caption = 'Print On Order';
                        ToolTip = 'Specifies the value of the Print On Order field';
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print Discount"; PrintDiscount)
                    {
                        Caption = 'Print Discount';
                        ToolTip = 'Specifies the value of the Print Discount field';
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print Discount Amount"; PrintDiscountAmt)
                    {
                        Caption = 'Print Discount Amount';
                        ToolTip = 'Specifies the value of the Print Discount Amount field';
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print Discount Percentage"; PrintDiscountPerc)
                    {
                        Caption = 'Print Discount Percentage';
                        ToolTip = 'Specifies the value of the Print Discount Percentage field';
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print Discount Total"; PrintDiscountTotal)
                    {
                        Caption = 'Print Discount Total';
                        ToolTip = 'Specifies the value of the Print Discount Total field';
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print VAT"; PrintVAT)
                    {
                        Caption = 'Print VAT';
                        ToolTip = 'Specifies the value of the Print VAT field';
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print EFT"; PrintEFT)
                    {
                        Caption = 'Print EFT';
                        ToolTip = 'Specifies the value of the Print EFT field';
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print Vouchers"; PrintVouchers)
                    {
                        Caption = 'Print Vouchers';
                        ToolTip = 'Specifies the value of the Print Vouchers field';
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print Counting"; PrintCounting)
                    {
                        Caption = 'Print Counting';
                        ToolTip = 'Specifies the value of the Print Counting field';
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print Counted Amt Incl Float"; PrintCountedAmtInclFloat)
                    {
                        Caption = 'Print Counted Amt Incl Float';
                        ToolTip = 'Specifies the value of the Print Counted Amt Incl Float field';
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print Closing"; PrintClosing)
                    {
                        Caption = 'Print Closing';
                        ToolTip = 'Specifies the value of the Print Closing field';
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print Attached Bins"; PrintAttachedBins)
                    {
                        Caption = 'Print Attached Bins';
                        ToolTip = 'Specifies the value of the Print Attached Bins field';
                        ApplicationArea = NPRNOFiscal;
                    }
                    field("Print Empty Lines"; PrintEmptyLines)
                    {
                        Caption = 'Print Lines Where Value Is Zero';
                        ToolTip = 'Specifies the value of the Print Lines Where Value Is Zero field';
                        ApplicationArea = NPRNOFiscal;
                    }
                }
            }
        }
    }

    labels
    {
        CountingDetailsCaptionLbl = 'Tellingsdetaljer', Locked = true;
        BankDepositAmountDetailsCaptionLbl = 'Informasjon om bankinnskuddsbeløp', Locked = true;
        MoveToBinAmountDetailsCaptionLbl = 'Flytt til detaljer om beholderbeløp', Locked = true;
        EndOfDayCaptionLbl = 'EOD', Locked = true;
        LCYCaptionLbl = 'NOK', Locked = true;
        LastZReportCaptionLbl = 'Siste Z-rapport', Locked = true;
        DateCaptionLbl = 'Dato', Locked = true;
        ZReportEntryNoCaptionLbl = 'Z-rapport Serienummer', Locked = true;
        POSUnitNoCaptionLbl = 'Kasse-ID', Locked = true;
        POSUnitNameCaptionLbl = 'Kassenavn', Locked = true;
        VATRegNumberCaptionLbl = 'MVA nummer', Locked = true;
        POSOpenedByCaptionLbl = 'Åpnet av', Locked = true;
        POSClosedByCaptionLbl = 'Lukket av', Locked = true;
        BrutoSalesCaptionLbl = 'Bruttoomsetning', Locked = true;
        ReturnCaptionLbl = 'Returer', Locked = true;
        NetoSalesCaptionLbl = 'Omsetning', Locked = true;
        TipsCaptionLbl = 'Driks', Locked = true;
        IssuedVoucherCaptionLbl = 'Solgt gavekort', Locked = true;
        RedeemedVoucherCaptionLbl = 'Innløst gavekort', Locked = true;
        InitialFloatCaptionLbl = 'Kontanter ved start', Locked = true;
        EndFloatCaptionLbl = 'Kontanter ved slutt', Locked = true;
        InBankCaptionLbl = 'Innskudd til bank', Locked = true;
        EndFloatCashCaptionLbl = 'Kontanter ved dagens slutt', Locked = true;
        StartCardCaptionLbl = 'Kort ved slutt', Locked = true;
        StartOtherCaptionLbl = 'Annet ved slutt', Locked = true;
        LoyaltiesCaptionLbl = 'Lojalitetspoeng', Locked = true;
        DifferenceCaptionLbl = 'Avvik kontant', Locked = true;
        DifferenceCardCaptionLbl = 'Avvik kort', Locked = true;
        TotalDifferenceCaptionLbl = 'Avvik total', Locked = true;
        ItemCategoryCaptionLbl = 'Artikkelgruppe', Locked = true;
        SoldProductsCaptionLbl = 'Antall solgte produkter', Locked = true;
        QuantityCardCaptionLbl = 'Antall kort', Locked = true;
        TotalCardsCaptionLbl = 'Totalt kort', Locked = true;
        QuantityOtherCaptionLbl = 'Antall annet', Locked = true;
        TotalOtherCaptionLbl = 'Totalt annet', Locked = true;
        CorrectionsCaptionLbl = 'Korreksjoner pr bruker', Locked = true;
        ZeroLinesCaptionLbl = 'Linjeantall redusert til 0', Locked = true;
        GeneralInfoCaptionLbl = 'Generell info', Locked = true;
        SumOfVATCaptionLbl = 'Sum MVA', Locked = true;
        VAT25PctCaptionLbl = 'MVA 25%', Locked = true;
        ReturnedProductsQuantityCaptionLbl = 'Antall returnerte produkter', Locked = true;
        SalesQuantityCaptionLbl = 'Antall salg', Locked = true;
        ReturnQuantityCaptionLbl = 'Antall returer', Locked = true;
        DiscountQuantityCaptionLbl = 'Antall rabatterte salg', Locked = true;
        NotEndedSalesQuantityCaptionLbl = 'Antall uavsluttede handeler', Locked = true;
        PrintedReceiptsQuantityCaptionLbl = 'Antall utskrevne kvitteringer', Locked = true;
        CopiedReceiptsQuantityCaptionLbl = 'Antall kopi kvitteringer', Locked = true;
        CancelledQuantityCaptionLbl = 'Antall kansellerte ordrer', Locked = true;
        TotalDiscountAmountCaptionLbl = 'Totalt rabatter', Locked = true;
        TotalReturnAmountCaptionLbl = 'Totalt returnert', Locked = true;
        MoreInfoCaptionLbl = 'Tilleggsinfo', Locked = true;
        FirstSaleCaptionLbl = 'Første salg', Locked = true;
        LastSaleCaptionLbl = 'Siste salg', Locked = true;
        AppVersionCaptionLbl = 'App versjon', Locked = true;
        SumOfVATOnReturnCaptionLbl = 'Sum MVA fra returer', Locked = true;
        ReturnVAT25PctCaptionLbl = 'Returer MVA 25%', Locked = true;
        TotalPrepaidCaptionLbl = 'Totalt forhåndsbetalinger', Locked = true;
        POSOpeningQuantityCaptionLbl = 'Antall skuffåpninger', Locked = true;
        ProformaReceiptsCaptionLbl = 'Antall utskrevne pro forma kvittering', Locked = true;
        ProformaReceiptsAmountCaptionLbl = 'Omsetning pro forma kvittering', Locked = true;
        PrepaidQuantityCaptionLbl = 'Antall forhåndsbetalinger', Locked = true;
        TotalOnCancelledCaptionLbl = 'Totalt fra kansellerte salg', Locked = true;
        TotalSalesAmountCaptionLbl = 'Totalt salg', Locked = true;
        TotalSalesNetoCaptionLbl = 'Totalt netto', Locked = true;
        POSLawCategoriesCaptionLbl = 'Kassalov-kategorier', Locked = true;
        UncategorizedSalesCaptionLbl = '04999 - Other', Locked = true;
        CategorizedSalesCaptionLbl = '04999 - Øvrige', Locked = true;
        PriceLookupQuantityCaptionLbl = 'Antall prisoppslag', Locked = true;
        CopyReceiptsAmountCaptionLbl = 'Totalt kopi kvitteringer', Locked = true;
        ProvisionalReceiptQtyCaptionLbl = 'Antall foreløpige kvitteringer', Locked = true;
        TrainingReceiptQtyCaptionLbl = 'Antall opplærings kvitteringer', Locked = true;
        DeliveryReceiptQtyCaptionLbl = 'Antall leverings kvitteringer', Locked = true;
        ProvisionalReceiptAmountCaptionLbl = 'Totalt foreløpige kvitteringer', Locked = true;
        TrainingReceiptAmountCaptionLbl = 'Totalt opplærings kvitteringer', Locked = true;
        DeliveryReceiptAmountCaptionLbl = 'Totalt leverings kvitteringer', Locked = true;
        PaymentsPerCashierCaptionLbl = 'Betalinger per kasserer', Locked = true;
        TotalCaptionLbl = 'Totalt', Locked = true;
    }

    trigger OnInitReport()
    begin
        PrintTurnOver := true;
        PrintDiscount := true;
        PrintDiscountAmt := true;
        PrintDiscountPerc := true;
        PrintDiscountTotal := true;
        PrintVAT := true;
        PrintEFT := true;
        PrintVouchers := true;
        PrintCounting := true;
        PrintCountedAmtInclFloat := true;
        PrintClosing := true;
        PrintAttachedBins := true;
        PrintOnOrder := true;
    end;

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    local procedure FillItemCategoryBuffer(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; FromEntryNo: Integer; ToPOSEntryNo: Integer; POSUnit: Record "NPR POS Unit"; var CategorizedSalesAmount: Decimal; var UncategorizedSalesAmount: Decimal; var CategorizedSalesQuantity: Decimal; var UncategorizedSalesQuantity: Decimal)
    var
        ItemCategory: Record "Item Category";
        ItemCategoryQuery: Query "NPR NO Sales By Item Category";
    begin
        Clear(CategorizedSalesAmount);
        Clear(CategorizedSalesQuantity);
        Clear(UncategorizedSalesAmount);
        Clear(UncategorizedSalesQuantity);

        if not ItemCategoryBuffer.IsEmpty() then
            ItemCategoryBuffer.DeleteAll();

        ItemCategoryQuery.SetFilter(EntryNo, '%1..%2', FromEntryNo, ToPOSEntryNo);
        ItemCategoryQuery.SetFilter(EntryType, '%1|%2', ItemCategoryQuery.EntryType::"Direct Sale", ItemCategoryQuery.EntryType::"Credit Sale");
        ItemCategoryQuery.SetRange(POSUnitNo, POSUnit."No.");
        ItemCategoryQuery.SetRange(POSStoreCode, POSUnit."POS Store Code");

        ItemCategoryQuery.Open();
        while ItemCategoryQuery.Read() do begin
            if ItemCategoryQuery.ItemCategoryCode = '' then begin
                UncategorizedSalesQuantity := ItemCategoryQuery.Quantity;
                UncategorizedSalesAmount := ItemCategoryQuery.AmountInclVATLCY;
            end;

            if ItemCategory.Get(ItemCategoryQuery.ItemCategoryCode) then begin
                CategorizedSalesQuantity += ItemCategoryQuery.Quantity;
                CategorizedSalesAmount += ItemCategoryQuery.AmountInclVATLCY;
                InsertToBuffer(ItemCategoryBuffer, ItemCategory.Code, ItemCategoryQuery.Quantity, ItemCategoryQuery.AmountInclVATLCY);
            end;
        end;
        ItemCategoryQuery.Close();
    end;

    local procedure FillSalespersonBuffer(var SalespersonBuffer: Record "Vendor Amount" temporary; FromEntryNo: Integer; ToEntryNo: Integer; POSUnit: Record "NPR POS Unit")
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalespersonQuery: Query "NPR NO Group Sales by Salespr.";
    begin
        if not SalespersonBuffer.IsEmpty() then
            SalespersonBuffer.DeleteAll();

        SalespersonQuery.SetFilter(EntryNo, '%1..%2', FromEntryNo, ToEntryNo);
        SalespersonQuery.SetFilter(EntryType, '%1|%2', SalespersonQuery.EntryType::"Direct Sale", SalespersonQuery.EntryType::"Credit Sale");
        SalespersonQuery.SetRange(POSUnitNo, POSUnit."No.");
        SalespersonQuery.SetRange(POSStoreCode, POSUnit."POS Store Code");

        SalespersonQuery.Open();
        while (SalespersonQuery.Read()) do
            if SalespersonPurchaser.Get(SalespersonQuery.SalespersonCode) then
                InsertToBuffer(SalespersonBuffer, SalespersonPurchaser.Code, 0, 0);
        SalespersonQuery.Close();
    end;

    local procedure InsertToBuffer(var Buffer: Record "Vendor Amount" temporary; No: Code[20]; Amount: Decimal; Amount2: Decimal)
    begin
        Buffer.Init();
        Buffer."Vendor No." := No;
        Buffer."Amount (LCY)" := Amount;
        Buffer."Amount 2 (LCY)" := Amount2;
        Buffer.Insert();
    end;

    local procedure InsertToBuffer(var Buffer: Record "NPR Item Category Buffer" temporary; No: Code[20]; Amount: Decimal; Amount2: Decimal)
    begin
        Buffer.Init();
        Buffer."Entry No." := GetEntryNo(Buffer);
        Buffer.Code := No;
        Buffer."Calc Field 1" := Amount;
        Buffer."Calc Field 2" := Amount2;
        Buffer.Insert();
    end;

    local procedure GetEntryNo(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary): Integer
    begin
        ItemCategoryBuffer.Reset();

        if ItemCategoryBuffer.FindLast() then
            exit(ItemCategoryBuffer."Entry No." + 10000);
        exit(10000);
    end;

    local procedure GetFirstLoginTimeAndPOSOpenedBy(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; var POSOpenedBy: Text; var LoginDatetime: Text)
    var
        POSAuditLog: Record "NPR POS Audit Log";
        SalespersonPurchaser2: Record "Salesperson/Purchaser";
        FirstLoginDatetime: DateTime;
    begin
        Clear(POSOpenedBy);
        Clear(LoginDatetime);
        FirstLoginDatetime := CreateDateTime(DT2Date(POSWorkshiftCheckpoint.SystemCreatedAt), 060000T);
        POSAuditLog.SetFilter(SystemCreatedAt, '%1..%2', FirstLoginDatetime, POSWorkshiftCheckpoint.SystemCreatedAt);
        POSAuditLog.SetRange("Active POS Unit No.", POSWorkshiftCheckpoint."POS Unit No.");
        POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::SIGN_IN);
        if not POSAuditLog.FindFirst() then
            exit;

        LoginDatetime := Format(POSAuditLog.SystemCreatedAt);
        if SalespersonPurchaser2.Get(POSAuditLog."Active Salesperson Code") then
            POSOpenedByTxt := SalespersonPurchaser2.Name;
    end;

    local procedure SetSalespersonStatistics(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; SalespersonPurchaser: Record "Salesperson/Purchaser")
    var
        CashBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSUnit: Record "NPR POS Unit";
        PreviousZReport: Record "NPR POS Workshift Checkpoint";
        PreviousZReportDateTime: DateTime;
        POSEntry2: Record "NPR POS Entry";
    begin
        POSUnit.Get(POSWorkshiftCheckpoint."POS Unit No.");
        NOReportStatisticsMgt.SetFilterOnPOSEntry(POSEntry2, POSUnit, FromPOSEntryNo, POSWorkshiftCheckpoint."POS Entry No.", SalespersonPurchaser.Code);

        NOReportStatisticsMgt.CalcCardsAmountAndQuantity(POSEntry2, TotalCards, QuantityCards);
        NOReportStatisticsMgt.CalcOtherPaymentsAmountAndQuantity(POSEntry2, TotalOther, QuantityOther);

        if NOReportStatisticsMgt.FindPreviousZReport(PreviousZReport, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint."Entry No.") then
            PreviousZReportDateTime := PreviousZReport.SystemCreatedAt
        else
            PreviousZReportDateTime := POSWorkshiftCheckpoint.SystemCreatedAt;

        Clear(ZeroLinesQuantity);
        ZeroLinesQuantity := NOReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaser.Code, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::DELETE_POS_SALE_LINE);

        NOReportStatisticsMgt.CalcReturnsAndSalesAmount(POSEntry2, BrutoAmount, ReturnAmount);
        NetoAmount := BrutoAmount - Abs(ReturnAmount);

        NOReportStatisticsMgt.CalcTaxAmount(POSEntry2, TaxAmount, 0, false);
        NOReportStatisticsMgt.CalcTaxAmount(POSEntry2, Tax25Amount, 25, false);
        NOReportStatisticsMgt.CalcReturnTaxAmount(POSEntry2, ReturnTaxAmount, 0, false);
        NOReportStatisticsMgt.CalcReturnTaxAmount(POSEntry2, ReturnTax25Amount, 25, false);

        Clear(InitialFloatAmount);
        if NOReportStatisticsMgt.FindCashBalacingLine(POSWorkshiftCheckpoint."Entry No.", CashBinCheckpoint) then
            InitialFloatAmount := CashBinCheckpoint."Float Amount";

        NOReportStatisticsMgt.CalcReturnSaleDiscountQuantity(POSEntry2, DiscountAmount, ReturnedRecieptsQuantity, SoldProductsQuantity, ReturnedProductsQuantity, DiscountQuantity);

        Clear(CashDrawerOpenQuantity);
        CashDrawerOpenQuantity := NOReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaser.Code, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::MANUAL_DRAWER_OPEN);

        NOReportStatisticsMgt.CalcCopyAndPrintReceiptsQuantity(POSEntry2, ReceiptCopyAmount, ReceiptCopyQuantity, ReceiptPrintQuantity);

        Clear(CancelledReceiptsQuantity);
        CancelledReceiptsQuantity := NOReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaser.Code, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::CANCEL_SALE_END);

        Clear(PriceLookupQuantity);
        PriceLookupQuantity := NOReportStatisticsMgt.GetPOSAuditLogCount(SalespersonPurchaser.Code, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, POSAuditLog."Action Type"::PRICE_CHECK);
        TotalPriceLookupQuantity += PriceLookupQuantity;
        NOReportStatisticsMgt.CalcAmountsFromPOSAuditLogInfo(SalespersonPurchaser.Code, POSWorkshiftCheckpoint."POS Unit No.", POSWorkshiftCheckpoint.SystemCreatedAt, PreviousZReportDateTime, CancelledReceiptsAmount, POSAuditLog."Action Type"::CANCEL_POS_SALE_LINE);
    end;

    var
        CompanyInfo: Record "Company Information";
        POSEntry: Record "NPR POS Entry";
        Salesperson: Record "Salesperson/Purchaser";
        TempSalespersonBuffer: Record "Vendor Amount" temporary;
        User: Record User;
        NOReportStatisticsMgt: Codeunit "NPR NO Report Statistics Mgt.";
        ifBankDenominExists: Boolean;
        ifCountingDenominExists: Boolean;
        ifMoveBinDenominExists: Boolean;
        PrintAttachedBins: Boolean;
        PrintClosing: Boolean;
        PrintCountedAmtInclFloat: Boolean;
        PrintCounting: Boolean;
        PrintDiscount: Boolean;
        PrintDiscountAmt: Boolean;
        PrintDiscountPerc: Boolean;
        PrintDiscountTotal: Boolean;
        PrintEFT: Boolean;
        PrintEmptyLines: Boolean;
        PrintNetTurnover: Boolean;
        PrintOnOrder: Boolean;
        PrintReceipts: Boolean;
        PrintSales: Boolean;
        PrintTerminals: Boolean;
        PrintTurnOver: Boolean;
        PrintVAT: Boolean;
        PrintVouchers: Boolean;
        BrutoAmount: Decimal;
        CancelledReceiptsAmount: Decimal;
        DiscountAmount: Decimal;
        InitialFloatAmount: Decimal;
        NetoAmount: Decimal;
        ReceiptCopyAmount: Decimal;
        ReturnAmount: Decimal;
        ReturnTax25Amount: Decimal;
        ReturnTaxAmount: Decimal;
        Tax25Amount: Decimal;
        TaxAmount: Decimal;
        TotalCards: Decimal;
        TotalOther: Decimal;
        WithItemCategoryAmount, WithoutItemCategoryAmount, WithItemCategoryQuantity, WithoutItemCategoryQuantity : Decimal;
        CancelledReceiptsQuantity: Integer;
        CashDrawerOpenQuantity: Integer;
        DiscountQuantity: Integer;
        FromPOSEntryNo: Integer;
        PriceLookupQuantity: Integer;
        QuantityCards: Integer;
        QuantityOther: Integer;
        ReceiptCopyQuantity: Integer;
        ReceiptPrintQuantity: Integer;
        ReturnedProductsQuantity: Integer;
        ReturnedRecieptsQuantity: Integer;
        SoldProductsQuantity: Integer;
        TotalPriceLookupQuantity: Integer;
        VarAttachedBin: Integer;
        VarBin: Integer;
        VarDenomination: Integer;
        VarMain: Integer;
        VarTax: Integer;
        ZeroLinesQuantity: Integer;
        AppVersionTxt: Text;
        ClosingDatetimeTxt: Text;
        FirstLoginDatetimeTxt: Text;
        FirstSaleDatetimeTxt: Text;
        LastSaleDatetimeTxt: Text;
        POSClosedByTxt: Text;
        POSOpenedByTxt: Text;
        PreviousZReportDateTimeTxt: Text;
        VarBalancedBy: Text;
        VarReportTitle: Text;
        AttachedPaymentBinslbl: Label 'Vedlagte betalingsbinger', Locked = true;
        BalancedByLbl: Label 'Registrer balansert etter', Locked = true;
        ClosingDatelbl: Label 'Dato', Locked = true;
        Closinglbl: Label 'Lukking', Locked = true;
        CompanyAddressInfoLbl: Label '%1, %2 %3', Comment = '%1 - specifies Company Address, %2 - specifies Company City, %3 - specifies Company Post Code', Locked = true;
        CountedAmountInclFloatlbl_: Label 'Telt Beløp Inkl. Flyte', Locked = true;
        Countinglbl: Label 'Telling', Locked = true;
        CustomerPaymentLbl: Label 'Innbetaling', Locked = true;
        DiscountAmtlbl: Label 'Rabattbeløp', Locked = true;
        Discountlbl: Label 'Rabatt', Locked = true;
        DiscountPerclbl: Label 'Rabattprosent', Locked = true;
        DiscountTotallbl: Label 'Rabatt totalt', Locked = true;
        EFTlbl: Label 'EFT', Locked = true;
        LblXReport: Label 'X-rapport', Locked = true;
        LblZReport: Label 'Z-rapport', Locked = true;
        OnOrderlbl: Label 'På bestilling', Locked = true;
        OpeningHrsLbl: Label 'Åpningstider', Locked = true;
        OtherPaymentslbl: Label 'Andre betalinger (NOK)', Locked = true;
        POSUnitLbl: Label 'Kasse-ID', Locked = true;
        PrintedByLbl: Label 'Trykket av', Locked = true;
        Receiptslbl: Label 'Kvitteringer', Locked = true;
        Saleslbl: Label 'Salg', Locked = true;
        Salespersonlbl: Label 'Selger', Locked = true;
        SalespersonTitleLbl: Label '%1 (%2)', Comment = '%1 - Name, %2 - Code', Locked = true;
        SalesTicketNoLbl: Label 'Salgsbillett nr', Locked = true;
        SignatureLbl: Label 'Signatur', Locked = true;
        StoreLbl: Label 'Kasse-enhet', Locked = true;
        Terminalslbl: Label 'Terminaler', Locked = true;
        Turnoverlbl: Label 'Omsetning (NOK)', Locked = true;
        TurnoverProfitlbl: Label 'Omsetning/Fortjeneste', Locked = true;
        VATRegistationNoLbl: Label '%1 MVA', Locked = true;
        VATTaxSummarylbl: Label 'MVA & SKATT Sammendrag', Locked = true;
        Voucherslbl: Label 'Bilag', Locked = true;
        WithLbl: Label 'Med', Locked = true;
        Workshiftlbl: Label 'Z-rapport SerieNummer', Locked = true;
}