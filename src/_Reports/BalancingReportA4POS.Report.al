report 6014459 "NPR Balancing Report A4 POS"
{
    // NPR5.42/ZESO/20180518  CASE 310459 Object Created
    // NPR5.48/JDH /20181109 CASE 334163 Added Object Caption
    // NPR5.55/BHR /20200525 CASE 404681 Replace POSEntry."POS Store Code" with POSEntry."POS Unit No."
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Balancing Report -A4 - POS.rdlc';

    Caption = 'Balancing Report -A4 - POS';

    dataset
    {
        dataitem("POS Workshift Checkpoint"; "NPR POS Workshift Checkpoint")
        {
            column(CompInfoPicture_; CompanyInfo.Picture)
            {
            }
            column(Saleslbl_; Saleslbl)
            {
            }
            column(Receiptslbl_; Receiptslbl)
            {
            }
            column(Terminalslbl_; Terminalslbl)
            {
            }
            column(Voucherslbl_; Voucherslbl)
            {
            }
            column(TurnoverProfitlbl_; TurnoverProfitlbl)
            {
            }
            column(Discountlbl_; Discountlbl)
            {
            }
            column(DiscountAmtlbl_; DiscountAmtlbl)
            {
            }
            column(DiscountPerclbl_; DiscountPerclbl)
            {
            }
            column(DiscountTotallbl_; DiscountTotallbl)
            {
            }
            column(Countinglbl_; Countinglbl)
            {
            }
            column(Closinglbl_; Closinglbl)
            {
            }
            column(VATTaxSummarylbl; VATTaxSummarylbl)
            {
            }
            column(AttachedPaymentBinslbl; AttachedPaymentBinslbl)
            {
            }
            column(CustomerPaymentlbl; CustomerPaymentLbl)
            {
            }
            column(Workshiftlbl_; Workshiftlbl)
            {
            }
            column(WorkshiftNo_; "POS Workshift Checkpoint"."Entry No.")
            {
            }
            column(POSUnitNo_; "POS Workshift Checkpoint"."POS Unit No.")
            {
            }
            column(CreatedAt_; "POS Workshift Checkpoint"."Created At")
            {
            }
            column(NetTurnoverLCY_; "POS Workshift Checkpoint"."Net Turnover (LCY)")
            {
            }
            column(ReturnSalesLCY_; "POS Workshift Checkpoint"."Direct Item Returns (LCY)")
            {
            }
            column(TotalDiscountLCY_; "POS Workshift Checkpoint"."Total Discount (LCY)")
            {
            }
            column(TerminalCardLCY_; "POS Workshift Checkpoint"."EFT (LCY)")
            {
            }
            column(ManualCardLCY_; "POS Workshift Checkpoint"."Manual Card (LCY)")
            {
            }
            column(OtherCreditCardLCY_; "POS Workshift Checkpoint"."Other Credit Card (LCY)")
            {
            }
            column(CashTerminalLCY_; "POS Workshift Checkpoint"."Cash Terminal (LCY)")
            {
            }
            column(CashMovementLCY_; "POS Workshift Checkpoint"."Local Currency (LCY)")
            {
            }
            column(CreatedGiftVoucherLCY_; "POS Workshift Checkpoint"."Issued Vouchers (LCY)")
            {
            }
            column(RedeemedGiftVoucherLCY_; "POS Workshift Checkpoint"."Redeemed Vouchers (LCY)")
            {
            }
            column(RedeemedCreditVoucherLCY_; "POS Workshift Checkpoint"."Redeemed Credit Voucher (LCY)")
            {
            }
            column(CreatedCreditVoucherLCY_; "POS Workshift Checkpoint"."Created Credit Voucher (LCY)")
            {
            }
            column(SalesCount_; "POS Workshift Checkpoint"."Direct Sales Count")
            {
            }
            column(ReceiptsCount_; "POS Workshift Checkpoint"."Receipts Count")
            {
            }
            column(ReturnSalesCount_; "POS Workshift Checkpoint"."Direct Item Returns Line Count")
            {
            }
            column(ReceiptCopiesCount_; "POS Workshift Checkpoint"."Receipt Copies Count")
            {
            }
            column(CashDrawerOpenCount_; "POS Workshift Checkpoint"."Cash Drawer Open Count")
            {
            }
            column(CancelledSalesCount_; "POS Workshift Checkpoint"."Cancelled Sales Count")
            {
            }
            column(DebitsalesCount_; "POS Workshift Checkpoint"."Credit Item Quantity Sum")
            {
            }
            column(SalesLCY_; "POS Workshift Checkpoint"."Direct Item Sales (LCY)")
            {
            }
            column(SalesStaffLCY_; "POS Workshift Checkpoint"."Direct Sales - Staff (LCY)")
            {
            }
            column(DebitSalesLCY_; "POS Workshift Checkpoint"."Credit Item Sales (LCY)")
            {
            }
            column(CustomerPaymentLCY_; "POS Workshift Checkpoint"."Debtor Payment (LCY)")
            {
            }
            column(ForeignCurrencyLCY_; "POS Workshift Checkpoint"."Foreign Currency (LCY)")
            {
            }
            column(GLPaymentLCY_; "POS Workshift Checkpoint"."GL Payment (LCY)")
            {
            }
            column(InvoicedSalesLCY_; "POS Workshift Checkpoint"."Credit Net Sales Amount (LCY)")
            {
            }
            column(RoundingLCY_; "POS Workshift Checkpoint"."Rounding (LCY)")
            {
            }
            column(TurnoverLCY_; "POS Workshift Checkpoint"."Turnover (LCY)")
            {
            }
            column(NetCostLCY_; "POS Workshift Checkpoint"."Net Cost (LCY)")
            {
            }
            column(ProfitAmountLCY_; "POS Workshift Checkpoint"."Profit Amount (LCY)")
            {
            }
            column(ProfitPerc_; "POS Workshift Checkpoint"."Profit %")
            {
            }
            column(CampaignDiscountLCY_; "POS Workshift Checkpoint"."Campaign Discount (LCY)")
            {
            }
            column(MixDiscountLCY_; "POS Workshift Checkpoint"."Mix Discount (LCY)")
            {
            }
            column(QtyDiscountLCY_; "POS Workshift Checkpoint"."Quantity Discount (LCY)")
            {
            }
            column(CustomDiscountLCY_; "POS Workshift Checkpoint"."Custom Discount (LCY)")
            {
            }
            column(BOMDiscountLCY_; "POS Workshift Checkpoint"."BOM Discount (LCY)")
            {
            }
            column(CustomerDiscountLCY_; "POS Workshift Checkpoint"."Customer Discount (LCY)")
            {
            }
            column(LineDiscountLCY_; "POS Workshift Checkpoint"."Line Discount (LCY)")
            {
            }
            column(CampaignDiscountPerc_; "POS Workshift Checkpoint"."Campaign Discount %")
            {
            }
            column(MixDiscountPerc_; "POS Workshift Checkpoint"."Mix Discount %")
            {
            }
            column(CustomerDiscountPerc_; "POS Workshift Checkpoint"."Customer Discount %")
            {
            }
            column(QtyDiscountPerc_; "POS Workshift Checkpoint"."Quantity Discount %")
            {
            }
            column(CustomDiscountPerc_; "POS Workshift Checkpoint"."Custom Discount %")
            {
            }
            column(BOMDiscountPerc_; "POS Workshift Checkpoint"."BOM Discount %")
            {
            }
            column(LineDiscountPerc_; "POS Workshift Checkpoint"."Line Discount %")
            {
            }
            column(TotalDiscountPerc_; "POS Workshift Checkpoint"."Total Discount %")
            {
            }
            column(VarMain_; VarMain)
            {
            }
            column(NetTurnoverLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Net Turnover (LCY)"))
            {
            }
            column(ReturnSalesLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Direct Item Returns (LCY)"))
            {
            }
            column(TotalDiscountLClbl_; "POS Workshift Checkpoint".FieldCaption("Total Discount (LCY)"))
            {
            }
            column(TerminalCardLCYlbl_; "POS Workshift Checkpoint".FieldCaption("EFT (LCY)"))
            {
            }
            column(ManualCardLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Manual Card (LCY)"))
            {
            }
            column(OtherCreditCardLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Other Credit Card (LCY)"))
            {
            }
            column(CashTerminalLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Cash Terminal (LCY)"))
            {
            }
            column(CashMovementLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Local Currency (LCY)"))
            {
            }
            column(CreatedGiftVoucherLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Issued Vouchers (LCY)"))
            {
            }
            column(RedeemedGiftVoucherLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Redeemed Vouchers (LCY)"))
            {
            }
            column(RedeemedCreditVoucherLClbl_; "POS Workshift Checkpoint".FieldCaption("Redeemed Credit Voucher (LCY)"))
            {
            }
            column(CreatedCreditVoucherLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Created Credit Voucher (LCY)"))
            {
            }
            column(SalesCountlbl_; "POS Workshift Checkpoint".FieldCaption("Direct Sales Count"))
            {
            }
            column(ReceiptsCountlbl_; "POS Workshift Checkpoint".FieldCaption("Receipts Count"))
            {
            }
            column(ReturnSalesCountlbl_; "POS Workshift Checkpoint".FieldCaption("Direct Item Returns Line Count"))
            {
            }
            column(ReceiptCopiesCountlbl_; "POS Workshift Checkpoint".FieldCaption("Receipt Copies Count"))
            {
            }
            column(CashDrawerOpenCountlbl_; "POS Workshift Checkpoint".FieldCaption("Cash Drawer Open Count"))
            {
            }
            column(CancelledSalesCountlbl_; "POS Workshift Checkpoint".FieldCaption("Cancelled Sales Count"))
            {
            }
            column(DebitSalesCountlbl_; "POS Workshift Checkpoint".FieldCaption("Credit Item Quantity Sum"))
            {
            }
            column(SalesLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Direct Item Sales (LCY)"))
            {
            }
            column(SalesStaffLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Direct Sales - Staff (LCY)"))
            {
            }
            column(DebitSalesLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Credit Item Sales (LCY)"))
            {
            }
            column(CustomerPaymentLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Debtor Payment (LCY)"))
            {
            }
            column(ForeignCurrencyLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Foreign Currency (LCY)"))
            {
            }
            column(GLPaymentLCYlbl_; "POS Workshift Checkpoint".FieldCaption("GL Payment (LCY)"))
            {
            }
            column(InvoicedSalesLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Credit Net Sales Amount (LCY)"))
            {
            }
            column(RoundingLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Rounding (LCY)"))
            {
            }
            column(TurnoverLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Turnover (LCY)"))
            {
            }
            column(NetCostLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Net Cost (LCY)"))
            {
            }
            column(ProfitAmountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Profit Amount (LCY)"))
            {
            }
            column(ProfitPerclbl_; "POS Workshift Checkpoint".FieldCaption("Profit %"))
            {
            }
            column(CampaignDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Campaign Discount (LCY)"))
            {
            }
            column(MixDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Mix Discount (LCY)"))
            {
            }
            column(QtyDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Quantity Discount (LCY)"))
            {
            }
            column(CustomDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Custom Discount (LCY)"))
            {
            }
            column(BOMDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("BOM Discount (LCY)"))
            {
            }
            column(CustomerDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Customer Discount (LCY)"))
            {
            }
            column(LineDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Line Discount (LCY)"))
            {
            }
            column(CampaignDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Campaign Discount %"))
            {
            }
            column(MixDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Mix Discount %"))
            {
            }
            column(QtyDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Quantity Discount %"))
            {
            }
            column(CustomDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Custom Discount %"))
            {
            }
            column(BOMDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("BOM Discount %"))
            {
            }
            column(CustomerDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Customer Discount %"))
            {
            }
            column(LineDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Line Discount %"))
            {
            }
            column(TotalDiscountLCYlbl_; "POS Workshift Checkpoint".FieldCaption("Total Discount (LCY)"))
            {
            }
            column(TotalDiscountPerclbl_; "POS Workshift Checkpoint".FieldCaption("Total Discount %"))
            {
            }
            column(StoreCode_; POSEntry."POS Unit No.")
            {
            }
            column(DocumentNo_; POSEntry."Document No.")
            {
            }
            column(StartingTime_; POSEntry."Starting Time")
            {
            }
            column(EndingTime_; POSEntry."Ending Time")
            {
            }
            column(ClosingDate_; POSEntry."Entry Date")
            {
            }
            column(RegisterNoLbl_; RegisterNoLbl)
            {
            }
            column(SalesTicketNoLbl_; SalesTicketNoLbl)
            {
            }
            column(OpeningHrsLbl_; OpeningHrsLbl)
            {
            }
            column(ClosingDatelbl_; ClosingDatelbl)
            {
            }
            column(SignatureLbl_; SignatureLbl)
            {
            }
            column(PricesIncVAT_; Format(POSEntry."Prices Including VAT"))
            {
            }
            column(PricesIncVATLbl_; POSEntry.FieldCaption("Prices Including VAT"))
            {
            }
            column(CompanyName_; CompanyName)
            {
            }
            column(POSEntryDescription_; POSEntry.Description)
            {
            }
            column(ReportTitle_; VarReportTitle)
            {
            }
            column(PrintSales_; PrintSales)
            {
            }
            column(PrintReceipts_; PrintReceipts)
            {
            }
            column(PrintTerminals_; PrintTerminals)
            {
            }
            column(PrintVouchers_; PrintVouchers)
            {
            }
            column(PrintTurnover_; PrintTurnOver)
            {
            }
            column(PrintDiscountAmt_; PrintDiscountAmt)
            {
            }
            column(PrintDiscountPerc_; PrintDiscountPerc)
            {
            }
            column(PrintDiscountTotal_; PrintDiscountTotal)
            {
            }
            column(PrintCounting_; PrintCounting)
            {
            }
            column(PrintClosing_; PrintClosing)
            {
            }
            column(PrintVAT_; PrintVAT)
            {
            }
            column(PrintAttachedBins_; PrintAttachedBins)
            {
            }
            column(PrintEmptyLines_; PrintEmptyLines)
            {
            }
            dataitem("POS Unit"; "NPR POS Unit")
            {
                DataItemLink = "No." = FIELD("POS Unit No.");
                DataItemTableView = SORTING("No.");
                column(POSUnitName_; "POS Unit".Name)
                {
                }
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
                column(VarBin_; VarBin)
                {
                }
                column(BinEntryNo_; BinCounting."Entry No.")
                {
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

                if POSEntry.Get("POS Workshift Checkpoint"."POS Entry No.") then;
                if Salesperson.Get(POSEntry."Salesperson Code") then;

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
                    field(PrintSales; PrintSales)
                    {
                        Caption = 'Print Sales';
                        ApplicationArea=All;
                    }
                    field(PrintReceipts; PrintReceipts)
                    {
                        Caption = 'Print Receipts';
                        ApplicationArea=All;
                    }
                    field(PrintTerminals; PrintTerminals)
                    {
                        Caption = 'Print Terminals';
                        ApplicationArea=All;
                    }
                    field(PrintVouchers; PrintVouchers)
                    {
                        Caption = 'Print Vouchers';
                        ApplicationArea=All;
                    }
                    field(PrintTurnOver; PrintTurnOver)
                    {
                        Caption = 'Print TurnOver';
                        ApplicationArea=All;
                    }
                    group(PrintDiscount)
                    {
                        Caption = 'Discount';
                        field(PrintDiscountAmt; PrintDiscountAmt)
                        {
                            Caption = '        Print Discount Amount';
                            ApplicationArea=All;

                            trigger OnValidate()
                            begin
                                //IF (PrintDiscountAmt) AND (PrintDiscount = FALSE) THEN
                                //ERROR(Text000);
                            end;
                        }
                        field(PrintDiscountPerc; PrintDiscountPerc)
                        {
                            Caption = '        Print Discount %';
                            ApplicationArea=All;

                            trigger OnValidate()
                            begin
                                //IF (PrintDiscountPerc) AND (PrintDiscount = FALSE) THEN
                                //ERROR(Text000);
                            end;
                        }
                        field(PrintDiscountTotal; PrintDiscountTotal)
                        {
                            Caption = '        Print Discount Total';
                            ApplicationArea=All;

                            trigger OnValidate()
                            begin
                                //IF (PrintDiscountTotal) AND (PrintDiscount = FALSE) THEN
                                //ERROR(Text000);
                            end;
                        }
                    }
                    field(PrintCounting; PrintCounting)
                    {
                        Caption = 'Print Counting';
                        ApplicationArea=All;
                    }
                    field("Print Closing"; PrintClosing)
                    {
                        Caption = 'Print Closing';
                        ApplicationArea=All;
                    }
                    field(PrintVAT; PrintVAT)
                    {
                        Caption = 'Print VAT';
                        ApplicationArea=All;
                    }
                    field(PrintAttachedBins; PrintAttachedBins)
                    {
                        Caption = 'Print Attached Bins';
                        ApplicationArea=All;
                    }
                    field(PrintEmptyLines; PrintEmptyLines)
                    {
                        Caption = 'Print Lines where Value is Zero.';
                        ApplicationArea=All;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        if CompanyInfo.Get then;
        CompanyInfo.CalcFields(Picture);
    end;

    var
        VarTax: Integer;
        VarMain: Integer;
        VarBin: Integer;
        POSEntry: Record "NPR POS Entry";
        RegisterNoLbl: Label 'Register No.';
        SalesTicketNoLbl: Label 'Sales Ticket No';
        OpeningHrsLbl: Label 'Opening Hours';
        ClosingDatelbl: Label 'Closing Date';
        BalancedByLbl: Label 'Register Balanced By';
        Salesperson: Record "Salesperson/Purchaser";
        VarBalancedBy: Text;
        WithLbl: Label 'With';
        VarReportTitle: Text;
        LblXReport: Label 'X-Report';
        LblZReport: Label 'Z-Report';
        SignatureLbl: Label 'Signature';
        VarAttachedBin: Integer;
        PrintSales: Boolean;
        PrintReceipts: Boolean;
        PrintTerminals: Boolean;
        PrintVouchers: Boolean;
        PrintTurnOver: Boolean;
        PrintDiscountAmt: Boolean;
        PrintDiscountPerc: Boolean;
        PrintDiscountTotal: Boolean;
        PrintCounting: Boolean;
        PrintClosing: Boolean;
        PrintVAT: Boolean;
        PrintAttachedBins: Boolean;
        PrintEmptyLines: Boolean;
        Saleslbl: Label 'Sales';
        Receiptslbl: Label 'Receipts';
        Terminalslbl: Label 'Terminals';
        Voucherslbl: Label 'Vouchers';
        TurnoverProfitlbl: Label 'Turnover /Profit';
        Discountlbl: Label 'Discount';
        DiscountAmtlbl: Label 'Discount Amount';
        DiscountPerclbl: Label 'Discount Percentage';
        DiscountTotallbl: Label 'Discount Total';
        Countinglbl: Label 'Counting';
        Closinglbl: Label 'Closing';
        VATTaxSummarylbl: Label 'VAT & TAX Summary';
        AttachedPaymentBinslbl: Label 'Attached Payment Bins';
        VarPrintAmt: Boolean;
        VarPrintPerc: Boolean;
        VarPrintTotal: Boolean;
        Text000: Label 'You need to select Print Discount first.';
        CustomerPaymentLbl: Label 'Payment';
        PrintDiscountlbl: Label 'Print Discount';
        Workshiftlbl: Label 'Workshift';
        CompanyInfo: Record "Company Information";
}

