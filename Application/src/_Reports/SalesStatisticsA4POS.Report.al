report 6014462 "NPR Sales Statistics A4 POS"
{
#if not BC17
    Extensible = false;
#endif
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/SalesStatisticsA4POS.rdlc';
    Caption = 'Sales Statistics by POS Store/Unit';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("POS Entry"; "NPR POS Entry")
        {
            MaxIteration = 1;
            RequestFilterFields = "Entry Date", "POS Store Code", "POS Unit No.";
            column(EntryDate_POSEntry; "POS Entry"."Entry Date")
            {
            }
            column(ReportTitleLbl_; ReportTitleLbl)
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
            column(Turnoverlbl_; Turnoverlbl)
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
            column(EFTlbl_; EFTlbl)
            {
            }
            column(POSUnitLbl_; POSUnitLbl)
            {
            }
            column(DirectReturnSalesLCYlbl_; DirectReturnSalesLCYlbl_)
            {
            }
            column(TotalDiscountLClbl_; TotalDiscountLClbl_)
            {
            }
            column(TerminalCardLCYlbl_; TerminalCardLCYlbl_)
            {
            }
            column(ManualCardLCYlbl_; ManualCardLCYlbl_)
            {
            }
            column(OtherCreditCardLCYlbl_; OtherCreditCardLCYlbl_)
            {
            }
            column(CashTerminalLCYlbl_; CashTerminalLCYlbl_)
            {
            }
            column(CashMovementLCYlbl_; CashMovementLCYlbl_)
            {
            }
            column(IssuedVoucherLCYlbl_; IssuedVoucherLCYlbl_)
            {
            }
            column(RedeemedVoucherLCYlbl_; RedeemedVoucherLCYlbl_)
            {
            }
            column(RedeemedCreditVoucherLClbl_; RedeemedCreditVoucherLClbl_)
            {
            }
            column(CreatedCreditVoucherLCYlbl_; CreatedCreditVoucherLCYlbl_)
            {
            }
            column(SalesCountlbl_; SalesCountlbl_)
            {
            }
            column(ReceiptsCountlbl_; ReceiptsCountlbl_)
            {
            }
            column(ReturnSalesCountlbl_; ReturnSalesCountlbl_)
            {
            }
            column(ReceiptCopiesCountlbl_; ReceiptCopiesCountlbl_)
            {
            }
            column(CashDrawerOpenCountlbl_; ReceiptCopiesCountlbl_)
            {
            }
            column(CancelledSalesCountlbl_; CancelledSalesCountlbl_)
            {
            }
            column(DebitSalesCountlbl_; DebitSalesCountlbl_)
            {
            }
            column(DirectSalesLCYlbl_; DirectSalesLCYlbl_)
            {
            }
            column(SalesStaffLCYlbl_; SalesStaffLCYlbl_)
            {
            }
            column(DebitSalesLCYlbl_; DebitSalesLCYlbl_)
            {
            }
            column(DebtorPaymentLCYlbl_; DebtorPaymentLCYlbl_)
            {
            }
            column(ForeignCurrencyLCYlbl_; ForeignCurrencyLCYlbl_)

            {
            }
            column(GLPaymentLCYlbl_; GLPaymentLCYlbl_)
            {
            }
            column(InvoicedSalesLCYlbl_; InvoicedSalesLCYlbl_)
            {
            }
            column(RoundingLCYlbl_; RoundingLCYlbl_)
            {
            }
            column(TurnoverLCYlbl_; TurnoverLCYlbl_)
            {
            }
            column(NetCostLCYlbl_; NetCostLCYlbl_)
            {
            }
            column(ProfitAmountLCYlbl_; ProfitAmountLCYlbl_)
            {
            }
            column(ProfitPerclbl_; ProfitPerclbl_)
            {
            }
            column(CampaignDiscountLCYlbl_; CampaignDiscountLCYlbl_)
            {
            }
            column(MixDiscountLCYlbl_; MixDiscountLCYlbl_)
            {
            }
            column(QtyDiscountLCYlbl_; QtyDiscountLCYlbl_)
            {
            }
            column(CustomDiscountLCYlbl_; CustomDiscountLCYlbl_)
            {
            }
            column(BOMDiscountLCYlbl_; BOMDiscountLCYlbl_)
            {
            }
            column(CustomerDiscountLCYlbl_; CustomerDiscountLCYlbl_)
            {
            }
            column(LineDiscountLCYlbl_; LineDiscountLCYlbl_)
            {
            }
            column(CampaignDiscountPerclbl_; CampaignDiscountPerclbl_)
            {
            }
            column(MixDiscountPerclbl_; MixDiscountPerclbl_)
            {
            }
            column(QtyDiscountPerclbl_; QtyDiscountPerclbl_)
            {
            }
            column(CustomDiscountPerclbl_; CustomDiscountPerclbl_)
            {
            }
            column(CreditUnrealSaleAmtLCY_; CreditUnrealSaleAmtLCY)
            {
            }
            column(BOMDiscountPerclbl_; BOMDiscountPerclbl_)
            {
            }
            column(CustomerDiscountPerclbl_; CustomerDiscountPerclbl_)
            {
            }
            column(LineDiscountPerclbl_; LineDiscountPerclbl_)
            {
            }
            column(TotalDiscountLCYlbl_; TotalDiscountLCYlbl_)
            {
            }
            column(TotalDiscountPerclbl_; TotalDiscountPerclbl_)
            {
            }
            column(DirectTurnoverLCYlbl_; DirectTurnoverLCYlbl_)
            {
            }
            column(CreditTurnoverLCYlbl_; CreditTurnoverLCYlbl_)
            {
            }
            column(DirectNetTurnoverLCYlbl_; DirectNetTurnoverLCYlbl_)
            {
            }
            column(CreditRealAmtLCYlbl_; CreditRealAmtLCYlbl_)
            {
            }
            column(CreditRealReturnAmtLCYlbl_; CreditRealReturnAmtLCYlbl_)
            {
            }
            column(CreditNetTurnOverLCYlbl_; CreditNetTurnOverLCYlbl_)
            {
            }
            column(CreditUnrealSaleAmtLCYlbl_; CreditUnrealSaleAmtLCYlbl_)
            {
            }
            column(EFTLCYlbl_; EFTLCYlbl_)
            {
            }
            column(LocalCurrencyLCYlbl_; LocalCurrencyLCYlbl_)
            {
            }
            column(NetTurnoverLCYlbl_; NetTurnoverLCYlbl_)
            {
            }
            dataitem("POS Sales Line"; "NPR POS Entry Sales Line")
            {
                DataItemLink = "Entry Date" = field("Entry Date");
                DataItemTableView = sorting("POS Entry No.", "Line No.");
                MaxIteration = 1;
                column(TurnOverLCY; TurnoverLCY)
                {
                }
                column(CompInfoPicture_; CompanyInfo.Picture)
                {
                }
                column(NetTurnoverLCY_; NetTurnoverLCY)
                {
                }
                column(DirectReturnSalesLCY_; DirectReturnSalesLCY)
                {
                }
                column(CreditRealSaleAmtLCY; CreditRealSaleAmtLCY)
                {
                }
                column(DirectItemSalesLineCount; DirectItemSalesLineCount)
                {
                }
                column(DirectItemSalesQuantity; DirectItemSalesQuantity)
                {
                }
                column(DirectItemReturnsLCY; DirectItemReturnsLCY)
                {
                }
                column(DirectItemReturnsLineCount; DirectItemReturnsLineCount)
                {
                }
                column(TotalDiscountLCY_; TotalDiscountLCY)
                {
                }
                column(DirectItemReturnsQuantity; DirectItemReturnsQuantity)
                {
                }
                column(DirectItemQuantitySum; DirectItemQuantitySum)
                {
                }
                column(CreditItemSalesLCY; CreditItemSalesLCY)
                {
                }
                column(CreditItemQuantitySum; CreditItemQuantitySum)
                {
                }
                column(RoundingLCY; RoundingLCY)
                {
                }
                column(IssuedVouchersLCY; IssuedVouchersLCY)
                {
                }
                column(DirectSalesLCY_; DirectSalesLCY)
                {
                }
                column(TurnoverLCY_; TurnoverLCY)
                {
                }
                column(NetCostLCY_; NetCostLCY)
                {
                }
                column(DirectItemSalesLCY; DirectItemSalesLCY)
                {
                }
                column(DirectItemNetSalesLCY; DirectItemNetSalesLCY)
                {
                }
                column(DebtorPaymentLCY_; DebtorPaymentLCY)
                {
                }
                column(GLPaymentLCY_; GLPaymentLCY)
                {
                }
                column(DirectTurnoverLCY_; DirectTurnoverLCY)
                {
                }
                column(CreditTurnoverLCY_; CreditTurnoverLCY)
                {
                }
                column(DirectNetTurnoverLCY_; DirectNetTurnoverLCY)
                {
                }
                column(CreditRealAmtLCY_; CreditRealSaleAmtLCY)
                {
                }
                column(CreditRealReturnAmtLCY_; CreditRealReturnAmtLCY)
                {
                }
                column(CreditNetTurnOverLCY_; CreditNetTurnOverLCY)
                {
                }
                column(VarMain_; VarMain)
                {
                }
                column(StoreCode_; POSEntry."POS Store Code")
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
                column(StoreLbl_; StoreLbl)
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
                column(SalespersonSumarylbl; SalespersonSumarylbl)
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
                column(PrintNetTurnover_; PrintNetTurnover)
                {
                }
                column(PrintDiscount_; PrintDiscount)
                {
                }
                column(PrintCountedAmtInclFloat_; PrintCountedAmtInclFloat)
                {
                }
                column(PrintEFT_; PrintEFT)
                {
                }
                column(SalesCount_; SalesCount_)
                {
                }
                column(ReturnSalesCount_; ReturnSalesCount_)
                {
                }
                column(CashDraweropnCount_; CashDraweropnCount_)
                {
                }
                column(CancellesSalesCount_; CancellesSalesCount_)
                {
                }
                column(itemCostTotal; itemCostTotal)
                {
                }
                column(ProfitLcy; ProfitLcy)
                {
                }
                column(ProfitPct; ProfitPct)
                {
                }
                column(TurnoverAvgSalesTicket; TurnoverAvgSalesTicket)
                {
                }
                column(ItemQty; ItemQty)
                {
                }
                column(ItemLines; ItemLines)
                {
                }
                column(ItemLineSalesQty; ItemLineSalesQty)
                {
                }
                column(AdjSalesExclVAT; AdjSalesExclVAT)
                {
                }
                column(AdjitemCostTotal; AdjitemCostTotal)
                {
                }
                column(AdjProfitLCY; AdjProfitLCY)
                {
                }
                column(AdjProfitPct; AdjProfitPct)
                {
                }
                column(EFTLCY; EFTLCY)
                {
                }
                column(LocalCurrencyLCY; LocalCurrencyLCY)
                {
                }
                column(IssuesVouchersLCy; IssuesVouchersLCy)
                {
                }
                column(RedeemedVoucherLCY; RedeemedVoucherLCY)
                {
                }
                column(CancellesSalesCount; CancellesSalesCount_)
                {
                }
                column(ItemQtySalesTicket_; ItemQtySalesTicket)
                {
                }
                dataitem(posentry2; "NPR POS Entry")
                {
                    DataItemTableView = sorting("Entry No.");
                    column(POSEntry2_SalesPersonCode; posentry2."Salesperson Code")
                    {
                    }
                    column(POSEntry2_Qty; posentry2."No. of Sales Lines")
                    {
                    }
                    column(POSEntry2_AmtInclTax; posentry2."Amount Incl. Tax")
                    {
                    }
                    column(Name_SalesPerson; Salesperson.Name)
                    {
                    }
                    column(i_; I)
                    {
                    }
                    dataitem("POS Tax Amount Line"; "NPR POS Entry Tax Line")
                    {
                        DataItemLink = "POS Entry No." = field("Entry No.");
                        DataItemTableView = sorting("POS Entry No.", "Tax Area Code for Key", "Tax Jurisdiction Code", "VAT Identifier", "Tax %", "Tax Group Code", "Expense/Capitalize", "Tax Type", "Use Tax", Positive);
                        column(TaxAreaCode_; "POS Tax Amount Line"."Tax Area Code")
                        {
                        }
                        column(VATIdentifier_; "POS Tax Amount Line"."VAT Identifier")
                        {
                        }
                        column(TaxType_; "POS Tax Amount Line"."Tax Type")
                        {
                        }
                        column(TaxCalculationType_; "POS Tax Amount Line"."Tax Calculation Type")
                        {
                        }
                        column(TaxPerc_; "POS Tax Amount Line"."Tax %")
                        {
                        }
                        column(TaxAmount_; "POS Tax Amount Line"."Tax Amount")
                        {
                        }
                        column(TaxBaseAmount_; "POS Tax Amount Line"."Tax Base Amount")
                        {
                        }
                        column(AmtInclTax_; "POS Tax Amount Line"."Amount Including Tax")
                        {
                        }
                        column(VarTax_; VarTax)
                        {
                        }
                        column(TaxEntryNo_; "POS Tax Amount Line"."POS Entry No.")
                        {
                        }
                        column(TaxAreaCodelbl_; TaxAreaCodelbl_)
                        {
                        }
                        column(VATIdentifierlbl_; VATIdentifierlbl_)
                        {
                        }
                        column(TaxTypelbl_; TaxTypelbl_)
                        {
                        }
                        column(TaxCalculationTypelbl_; TaxCalculationTypelbl_)
                        {
                        }
                        column(TaxPerclbl_; TaxPerclbl_)
                        {
                        }
                        column(TaxAmountlbl_; TaxAmountlbl_)
                        {
                        }
                        column(TaxBaseAmountlbl_; TaxBaseAmountlbl_)
                        {
                        }
                        column(AmtInclTaxlbl_; AmtInclTaxlbl_)
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
                    dataitem("POS Payment Line"; "NPR POS Entry Payment Line")
                    {
                        DataItemLink = "POS Entry No." = field("Entry No.");
                        DataItemTableView = sorting("POS Entry No.", "Line No.");
                        column(POSEntryNo_POSPaymentLine; "POS Payment Line"."POS Entry No.")
                        {
                        }
                        column(PosPaymentmethodcode_POSPaymentLine; "POS Payment Line"."POS Payment Method Code")
                        {
                        }
                        column(AmountLCY_POSPaymentLine; "POS Payment Line"."Amount (LCY)")
                        {
                        }
                    }

                    trigger OnAfterGetRecord()
                    begin

                        if Salesperson.Get(posentry2."Salesperson Code") then;
                        I := 1;
                    end;

                    trigger OnPreDataItem()
                    begin
                        posentry2.SetRange("Entry Date", "POS Entry"."Entry Date");
                        posentry2.SetRange("System Entry", false);
                        posentry2.SetFilter("Entry Type", '%1|%2|%3|%4|%5',
                        posentry2."Entry Type"::"Credit Sale",
                        posentry2."Entry Type"::"Direct Sale",
                        posentry2."Entry Type"::Balancing,
                        posentry2."Entry Type"::Other,
                        posentry2."Entry Type"::Comment);
                    end;
                }

                trigger OnPreDataItem()
                begin
                end;
            }

            trigger OnAfterGetRecord()
            begin
                POSEntryValue.Reset();
                POSEntryValue.CopyFilters("POS Entry");
                POSEntryValue.SetFilter("Entry Type", '%1|%2', POSEntryValue."Entry Type"::"Direct Sale", POSEntryValue."Entry Type"::"Credit Sale");

                if POSEntryValue.FindSet() then
                    repeat
                        POSPaymentMethod.Reset();
                        POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::EFT);
                        if POSPaymentMethod.FindSet() then
                            repeat
                                POSPaymentLine.Reset();
                                POSPaymentLine.SetRange("POS Payment Method Code", POSPaymentMethod.Code);
                                POSPaymentLine.SetRange("POS Entry No.", POSEntryValue."Entry No.");

                                if POSPaymentLine.FindSet() then
                                    repeat
                                        EFTLCY += POSPaymentLine."Amount (LCY)";
                                    until POSPaymentLine.Next() = 0;
                            until POSPaymentMethod.Next() = 0;

                        POSPaymentMethod.Reset();
                        POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::CASH);
                        if POSPaymentMethod.FindSet() then
                            repeat
                                POSPaymentLine.Reset();
                                POSPaymentLine.SetRange("POS Payment Method Code", POSPaymentMethod.Code);
                                POSPaymentLine.SetRange("POS Entry No.", POSEntryValue."Entry No.");

                                if POSPaymentLine.FindSet() then
                                    repeat
                                        LocalCurrencyLCY += POSPaymentLine."Amount (LCY)";
                                    until POSPaymentLine.Next() = 0;
                            until POSPaymentMethod.Next() = 0;

                        TurnoverLCY += POSEntryValue."Amount Incl. Tax";
                        NetTurnoverLCY += POSEntryValue."Amount Excl. Tax";
                        if POSEntryValue."Return Sales Quantity" < 0 then
                            ReturnSalesCount_ += 1;

                        if POSEntryValue."Entry Type" = POSEntryValue."Entry Type"::"Direct Sale" then begin
                            SalesCount_ += 1;
                            POSSalesLineValue.Reset();
                            POSSalesLineValue.SetRange("POS Entry No.", POSEntryValue."Entry No.");
                            if POSSalesLineValue.FindSet() then
                                repeat
                                    TotalDiscountLCY += POSSalesLineValue."Line Dsc. Amt. Incl. VAT (LCY)";
                                    itemCostTotal += POSSalesLineValue."Unit Cost (LCY)";

                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Item then
                                        if POSSalesLineValue.Quantity > 0 then begin
                                            DirectItemNetSalesLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                            ItemQty += POSSalesLineValue.Quantity;
                                        end else
                                            DirectReturnSalesLCY += (POSSalesLineValue."Amount Incl. VAT (LCY)");
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::"G/L Account" then
                                        GLPaymentLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Customer then
                                        DebtorPaymentLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Payout then
                                        GLPaymentLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Rounding then
                                        RoundingLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";

                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Voucher then
                                        IssuedVouchersLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";

                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Item then begin
                                        POSPaymentMethod.Reset();
                                        POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::VOUCHER);
                                        if POSPaymentMethod.FindSet() then
                                            repeat
                                                POSPaymentLine.Reset();
                                                POSPaymentLine.SetRange("POS Entry No.", POSSalesLineValue."POS Entry No.");
                                                POSPaymentLine.SetRange("POS Payment Method Code", POSPaymentMethod.Code);
                                                if POSPaymentLine.FindSet() then
                                                    repeat
                                                        if POSPaymentLine."Amount (LCY)" < 0 then
                                                            IssuedVouchersLCY += POSPaymentLine."Amount (LCY)"
                                                        else
                                                            RedeemedVoucherLCY += POSPaymentLine."Amount (LCY)";
                                                    until POSPaymentLine.Next() = 0;
                                            until POSPaymentMethod.Next() = 0;
                                    end;
                                until POSSalesLineValue.Next() = 0;
                        end;

                        if POSEntryValue."Entry Type" = POSEntryValue."Entry Type"::"Credit Sale" then begin
                            POSSalesLineValue.Reset();
                            POSSalesLineValue.SetRange("POS Entry No.", POSEntryValue."Entry No.");
                            if POSSalesLineValue.FindSet() then
                                repeat

                                    itemCostTotal += POSSalesLineValue."Unit Cost (LCY)";
                                    TotalDiscountLCY += POSSalesLineValue."Line Dsc. Amt. Incl. VAT (LCY)";
                                    CreditTurnoverLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue."Amount Incl. VAT (LCY)" > 0 then
                                        CreditRealSaleAmtLCY += POSSalesLineValue."Amount Incl. VAT (LCY)"
                                    else
                                        CreditRealReturnAmtLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::"G/L Account" then
                                        GLPaymentLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Customer then
                                        DebtorPaymentLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Payout then
                                        GLPaymentLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Rounding then
                                        RoundingLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";

                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Voucher then
                                        IssuedVouchersLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";

                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Item then begin
                                        POSPaymentMethod.Reset();
                                        POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::VOUCHER);
                                        if POSPaymentMethod.FindSet() then
                                            repeat
                                                POSPaymentLine.Reset();
                                                POSPaymentLine.SetRange("POS Entry No.", POSSalesLineValue."POS Entry No.");
                                                POSPaymentLine.SetRange("POS Payment Method Code", POSPaymentMethod.Code);
                                                if POSPaymentLine.FindSet() then
                                                    repeat
                                                        if POSPaymentLine."Amount (LCY)" < 0 then
                                                            IssuedVouchersLCY += POSPaymentLine."Amount (LCY)"
                                                        else
                                                            RedeemedVoucherLCY += POSPaymentLine."Amount (LCY)";
                                                    until POSPaymentLine.Next() = 0;
                                            until POSPaymentMethod.Next() = 0;
                                    end;
                                until POSSalesLineValue.Next() = 0;
                        end;
                    until POSEntryValue.Next() = 0;

                ProfitLcy := NetTurnoverLCY - itemCostTotal;
                ProfitPct := (itemCostTotal / NetTurnoverLCY);

                POSEntryValue.Reset();
                POSEntryValue.SetFilter("Entry Date", '=%1', "POS Entry"."Entry Date");
                POSEntryValue.SetFilter("Entry Type", '=%1', POSEntryValue."Entry Type"::"Cancelled Sale");
                if POSEntryValue.FindSet() then
                    CancellesSalesCount_ := POSEntryValue.Count;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group("Print Options")
                {
                    Caption = 'Print Options';
                    field(PrintTurnOver; PrintTurnOver)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Print TurnOver';
                        ToolTip = 'Specifies the value of the Print TurnOver field.';
                    }
                    field(PrintDiscount; PrintDiscount)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Print Discount';
                        ToolTip = 'Specifies the value of the Print Discount field.';
                    }
                    field(PrintVAT; PrintVAT)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Print VAT';
                        ToolTip = 'Specifies the value of the Print VAT field.';
                    }
                    field(PrintEFT; PrintEFT)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Print EFT';
                        ToolTip = 'Specifies the value of the Print EFT field.';
                    }
                    field(PrintVouchers; PrintVouchers)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Print Vouchers';
                        ToolTip = 'Specifies the value of the Print Vouchers field.';
                    }
                    field(PrintCounting; PrintCounting)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Print Counting';
                        ToolTip = 'Specifies the value of the Print Counting field.';
                    }
                    field(PrintCountedAmtInclFloat; PrintCountedAmtInclFloat)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Print Counted Amt Incl Float';
                        ToolTip = 'Specifies the value of the Print Counted Amt Incl Float field.';
                    }
                    field("Print Closing"; PrintClosing)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Print Closing';
                        ToolTip = 'Specifies the value of the Print Closing field.';
                    }
                    field(PrintAttachedBins; PrintAttachedBins)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Print Attached Bins';
                        ToolTip = 'Specifies the value of the Print Attached Bins field.';
                    }
                    field(PrintEmptyLines; PrintEmptyLines)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Print Lines where Value is Zero.';
                        ToolTip = 'Specifies the value of the Print Lines where Value is Zero. field.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        var
            UserSetup: Record "User Setup";
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
        end;
    }

    labels
    {
        ProfitExclVatLbl = 'Price Excl. VAT';
        NetTurnoverLCYLbl = 'Net Turnover (LCY)';
        ItemCostTotalLbl = 'item Cost Total';
        ProfitLCYLbl = 'Profit (LCY)';
        ProfitPCTLbl = 'Profit Pct';
        AdjustedCostDetailsLbl = 'Adjusted Cost Details';
        AdjSalesExclVATLbl = 'Adj Sales Excl. VAT';
        AdjItemCostTotalLbl = 'Adj Item Cost Total';
        AdjProfitLCYLbl = 'Adj Profit (LCY)';
        AdjProfitPctLbl = 'Adj Profit Pct';
        TurnoverBasketLbl = 'Turnover Basket';
        TurnoverAvgSalesTicketLbl = 'Turnover (avg.)/SalesTicket';
        ItemQTYLbl = 'Item (Qty)';
        itemQTYSalesTicket = 'Item (Qty)/Sales Ticket';
        ItemLineslbl = 'Item Lines';
        itemLineSalesQtyLbl = 'Item Lines/Sales (Qty)';
        SalesQTYLbl = 'Sales (Qty)';
        SalesAmtLbl = 'Sales Amt.';
        SalesAvgLbl = 'Avg. Sales';
        PaymentDetailsLbl = 'Payment Details';
        PaymentMethodLbl = 'Payment Method';
        AmountLbl = 'Amount LCY';
    }

    trigger OnPreReport()
    begin
        if CompanyInfo.Get() then;
        CompanyInfo.CalcFields(Picture);
    end;

    var
        CompanyInfo: Record "Company Information";
        ILEntry: Record "Item Ledger Entry";
        POSEntry: Record "NPR POS Entry";
        POSEntryPayment2: Record "NPR POS Entry";
        PosEntrySalesPerson: Record "NPR POS Entry";
        POSEntryValue: Record "NPR POS Entry";
        NPRPOSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSSalesLineValue: Record "NPR POS Entry Sales Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Salesperson: Record "Salesperson/Purchaser";
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
        PrintReceipts: Boolean;
        PrintSales: Boolean;
        PrintTerminals: Boolean;
        PrintTurnOver: Boolean;
        PrintVAT: Boolean;
        PrintVouchers: Boolean;
        VarPrintAmt: Boolean;
        VarPrintPerc: Boolean;
        VarPrintTotal: Boolean;
        AdjitemCostTotal: Decimal;
        AdjProfitLCY: Decimal;
        AdjProfitPct: Decimal;
        AdjSalesExclVAT: Decimal;
        CancellesSalesCount_: Decimal;
        CashDraweropnCount_: Decimal;
        CreditItemQuantitySum: Decimal;
        CreditItemSalesLCY: Decimal;
        CreditNetSalesLCY: Decimal;
        CreditNetTurnOverLCY: Decimal;
        CreditRealAmtLCY: Decimal;
        CreditRealReturnAmtLCY: Decimal;
        CreditRealSaleAmtLCY: Decimal;
        CreditTurnoverLCY: Decimal;
        CreditUnrealSaleAmtLCY: Decimal;
        DebtorPaymentLCY: Decimal;
        DirectItemNetSalesLCY: Decimal;
        DirectItemQuantitySum: Decimal;
        DirectItemReturnsLCY: Decimal;
        DirectItemReturnsQuantity: Decimal;
        DirectItemSalesLCY: Decimal;
        DirectItemSalesQuantity: Decimal;
        DirectNegativeTurnoverLCY: Decimal;
        DirectNetTurnoverLCY: Decimal;
        DirectReturnSalesLCY: Decimal;
        DirectSalesLCY: Decimal;
        DirectTurnoverLCY: Decimal;
        EFTLCY: Decimal;
        GLPaymentLCY: Decimal;
        IssuedVouchersLCY: Decimal;
        IssuesVouchersLCy: Decimal;
        itemCostTotal: Decimal;
        ItemLineSalesQty: Decimal;
        itemLinesSalesQTY: Decimal;
        ItemQty: Decimal;
        ItemQtySalesTicket: Decimal;
        LocalCurrencyLCY: Decimal;
        NetCostLCY: Decimal;
        NetTurnoverLCY: Decimal;
        ProfitLcy: Decimal;
        ProfitPct: Decimal;
        RedeemedVoucherLCY: Decimal;
        ReturnSalesCount_: Decimal;
        RoundingLCY: Decimal;
        SalesCount_: Decimal;
        SumOfILELineCurrentYear: Decimal;
        TotalDiscountLCY: Decimal;
        TotalNetDiscountLCY: Decimal;
        TurnoverAvgSalesTicket: Decimal;
        TurnoverLCY: Decimal;
        DirectItemReturnsLineCount: Integer;
        DirectItemSalesLineCount: Integer;
        I: Integer;
        ItemLines: Integer;
        NoOfSalesTicket: Integer;
        salesCountSP: Integer;
        VarAttachedBin: Integer;
        VarBin: Integer;
        VarDenomination: Integer;
        VarMain: Integer;
        VarTax: Integer;
        AmtInclTaxlbl_: Label 'Amount Including Tax';
        AttachedPaymentBinslbl: Label 'Attached Payment Bins';
        BalancedByLbl: Label 'Register Balanced By';
        BOMDiscountLCYlbl_: Label 'BOM Discount (LCY)';
        BOMDiscountPerclbl_: Label 'BOM Discount %';
        CampaignDiscountLCYlbl_: Label 'Campaign Discount (LCY)';
        CampaignDiscountPerclbl_: Label 'Campaign Discount %';
        CancelledSalesCountlbl_: Label 'Cancelled Sales Count';
        CashDrawerOpenCountlbl_: Label 'Cash Drawer Open Count';
        CashMovementLCYlbl_: Label 'Local Currency (LCY)';
        CashTerminalLCYlbl_: Label 'Cash Terminal (LCY)';
        ClosingDatelbl: Label 'Date Filter';
        Closinglbl: Label 'Closing';
        CountedAmtInclFloatlbl: Label 'Counted Amount Incl Float';
        Countinglbl: Label 'Counting';
        CreatedCreditVoucherLCYlbl_: Label 'Created Credit Voucher (LCY)';
        CreditNetTurnOverLCYlbl_: Label 'Credit Net Turnover (LCY)';
        CreditRealAmtLCYlbl_: Label 'Credit Real. Sale Amt. (LCY)';
        CreditRealReturnAmtLCYlbl_: Label 'Credit Real. Return Amt. (LCY)';
        CreditTurnoverLCYlbl_: Label 'Credit Turnover (LCY)';
        CreditUnrealSaleAmtLCYlbl_: Label 'Credit Unreal. Sale Amt. (LCY)';
        CustomDiscountLCYlbl_: Label 'Custom Discount (LCY)';
        CustomDiscountPerclbl_: Label 'Custom Discount %';
        CustomerDiscountLCYlbl_: Label 'Customer Discount (LCY)';
        CustomerDiscountPerclbl_: Label 'Customer Discount %';
        CustomerPaymentLbl: Label 'Payment';
        DebitSalesCountlbl_: Label 'Credit Item Quantity Sum';
        DebitSalesLCYlbl_: Label 'Credit Item Sales (LCY)';
        DebtorPaymentLCYlbl_: Label 'Debtor Payment (LCY)';
        DirectNetTurnoverLCYlbl_: Label 'Direct Net Turnover (LCY)';
        DirectReturnSalesLCYlbl_: Label 'Direct Item Returns (LCY)';
        DirectSalesLCYlbl_: Label 'Direct Item Sales (LCY)';
        DirectTurnoverlbl: Label 'Direct Turnover (LCY)';
        DirectTurnoverLCYlbl_: Label 'Direct Turnover (LCY)';
        DiscountAmtlbl: Label 'Discount Amount';
        Discountlbl: Label 'Discount';
        DiscountPerclbl: Label 'Discount Percentage';
        DiscountTotallbl: Label 'Discount Total';
        EFTlbl: Label 'EFT';
        EFTLCYlbl_: Label 'EFT (LCY)';
        ForeignCurrencyLCYlbl_: Label 'Foreign Currency (LCY)';
        GLPaymentLCYlbl_: Label 'GL Payment (LCY)';
        InvoicedSalesLCYlbl_: Label 'Credit Net Sales Amount (LCY)';
        IssuedVoucherLCYlbl_: Label 'Issued Vouchers (LCY)';
        LblXReport: Label 'X-Report';
        LblZReport: Label 'Z-Report';
        LineDiscountLCYlbl_: Label 'Line Discount (LCY)';
        LineDiscountPerclbl_: Label 'Line Discount %';
        LocalCurrencyLCYlbl_: Label 'Local Currency (LCY)';
        ManualCardLCYlbl_: Label 'Manual Card (LCY)';
        MixDiscountLCYlbl_: Label 'Mix Discount (LCY)';
        MixDiscountPerclbl_: Label 'Mix Discount %';
        NetCostLCYlbl_: Label 'Net Cost (LCY)';
        NetTurnoverlbl: Label 'Net Turnover';
        NetTurnoverLCYlbl_: Label 'Net Turnover (LCY)';
        OpeningHrsLbl: Label 'Opening Hours';
        OtherCreditCardLCYlbl_: Label 'Other Credit Card (LCY)';
        POSUnitLbl: Label 'POS Unit';
        PrintDiscountlbl: Label 'Print Discount';
        ProfitAmountLCYlbl_: Label 'Profit Amount (LCY)';
        ProfitPerclbl_: Label 'Profit %';
        QtyDiscountLCYlbl_: Label 'Quantity Discount (LCY)';
        QtyDiscountPerclbl_: Label 'Quantity Discount %';
        ReceiptCopiesCountlbl_: Label 'Receipt Copies Count';
        ReceiptsCountlbl_: Label 'Receipts Count';
        Receiptslbl: Label 'Receipts';
        RedeemedCreditVoucherLClbl_: Label 'Redeemed Credit Voucher (LCY)';
        RedeemedVoucherLCYlbl_: Label 'Redeemed Vouchers (LCY)';
        ReportTitleLbl: Label 'Sales Statistics';
        ReturnSalesCountlbl_: Label 'Direct Item Returns Line Count';
        RoundingLCYlbl_: Label 'Rounding (LCY)';
        SalesCountlbl_: Label 'Direct Sales Count';
        Saleslbl: Label 'Sales';
        SalespersonSumarylbl: Label 'SalesPerson Summary';
        SalesStaffLCYlbl_: Label 'Direct Sales - Staff (LCY)';
        SalesTicketNoLbl: Label 'Sales Ticket No';
        SignatureLbl: Label 'Signature';
        StoreLbl: Label 'POS Store';
        TaxAmountlbl_: Label 'Tax Amount';
        TaxAreaCodelbl_: Label 'Tax Area Code';
        TaxBaseAmountlbl_: Label 'Tax Base Amount';
        TaxCalculationTypelbl_: Label 'Tax Calculation Type';
        TaxPerclbl_: Label 'Tax %';
        TaxTypelbl_: Label 'Tax Type';
        TerminalCardLCYlbl_: Label 'EFT (LCY)';
        Terminalslbl: Label 'Terminals';
        Text000: Label 'You need to select Print Discount first.';
        TotalDiscountLClbl_: Label 'Total Discount (LCY)';
        TotalDiscountLCYlbl_: Label 'Total Discount (LCY)';
        TotalDiscountPerclbl_: Label 'Total Discount %';
        Turnoverlbl: Label 'Turnover (LCY)';
        TurnoverLCYlbl_: Label 'Turnover (LCY)';
        VATIdentifierlbl_: Label 'VAT Identifier';
        VATTaxSummarylbl: Label 'VAT & TAX Summary';
        Voucherslbl: Label 'Vouchers';
        WithLbl: Label 'With';
        Workshiftlbl: Label 'Workshift';
        VarBalancedBy: Text;
        VarReportTitle: Text;

    local procedure "Pct."(Tal1: Decimal; Tal2: Decimal): Decimal
    begin
        if Tal2 = 0 then
            exit(0);
        exit(Tal1 / Tal2 * 100);
    end;

    procedure Divider("Tal 1": Decimal; "Tal 2": Decimal): Decimal
    begin
        if "Tal 2" = 0 then
            exit(0);
        exit(("Tal 1" / "Tal 2"));
    end;
}
