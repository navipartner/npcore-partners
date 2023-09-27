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
            column(CreditRealAmtLCYlbl_; CreditRealAmtLCYlbl_)
            {
            }
            column(CreditRealReturnAmtLCYlbl_; CreditRealReturnAmtLCYlbl_)
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
            column(IssuedGiftVoucherLCY_; IssuedGiftVoucherLCY)
            {
            }
            column(IssuedCreditVoucherLCY_; IssuedCreditVoucherLCY)
            {
            }
            column(DirectReturnSalesLCY_; DirectReturnSalesLCY)
            {
            }
            column(NetDirectTurnover_; NetDirectTurnover)
            {
            }
            column(NetCreditTurnover_; NetCreditTurnover)
            {
            }
            column(CreditUnrealReturnAmtLCY_; CreditUnrealReturnAmtLCY)
            {
            }
            column(RedeemedCreditVoucherLCY_; RedeemedCreditVoucherLCY)
            {
            }
            column(RedeemedGiftVoucherLCY_; RedeemedGiftVoucherLCY)
            {
            }
            column(Turnover_; Turnover)
            {
            }
            column(DirectSalesExcVAT_; DirectSalesExcVAT)
            {
            }
            column(CreditSalesExcVAT_; CreditSalesExcVAT)
            {
            }
            column(DirectReturnExcVAT_; DirectReturnExcVAT)
            {
            }
            column(CreditSalesMemoExcVAT_; CreditSalesMemoExcVAT)
            {
            }
            column(SalesTicket_; SalesTicket)
            {
            }
            column(ItemSoldQty_; ItemSoldQty)
            {
            }
            column(ItemReturnQty_; ItemReturnQty)
            {
            }
            column(DirectTurnover_; DirectTurnover)
            {
            }
            column(SumOfDirectSalesTicket_; SumOfDirectSalesTicket)
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
                column(DirectItemSalesLineCount; DirectItemSalesLineCount)
                {
                }
                column(DirectItemSalesQuantity; DirectItemSalesQuantity)
                {
                }
                column(DirectItemReturnsLCY; DirectItemReturnsLCY)
                {
                }
                column(DirectItemReturnsLineCount_; DirectItemReturnsLineCount)
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
                column(IssuedVouchersLCY_; IssuedVouchersLCY)
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
                column(PrintDiscountAmt_; PrintDiscountAmt)
                {
                }
                column(PrintDiscountPerc_; PrintDiscountPerc)
                {
                }
                column(PrintDiscountTotal_; PrintDiscountTotal)
                {
                }
                column(PrintNetTurnover_; PrintNetTurnover)
                {
                }
                column(DirectSalesCount_; DirectSalesCount)
                {
                }
                column(CreditSalesCount_; CreditSalesCount)
                {
                }
                column(DirectSalesReturnCount_; DirectSalesReturnCount)
                {
                }
                column(CashDraweropnCount_; CashDraweropnCount_)
                {
                }
                column(ItemCostTotal_; ItemCostTotal)
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
                column(ItemQty_; ItemQty)
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
                column(LocalCurrencyLCY_; LocalCurrencyLCY)
                {
                }
                column(IssuesVouchersLCy; IssuesVouchersLCy)
                {
                }
                column(RedeemedVoucherLCY_; RedeemedVoucherLCY)
                {
                }
                column(CancelledSalesCount_; CancelledSalesCount)
                {
                }
                column(PrintOldVouchers_; PrintOldVouchers)
                {
                }
                dataitem(POSEntry2; "NPR POS Entry")
                {
                    DataItemTableView = sorting("Entry No.");
                    column(POSEntry2_SalesPersonCode; POSEntry2."Salesperson Code")
                    {
                    }
                    column(POSEntry2_Qty; SalesPersonSalesCount)
                    {
                    }
                    column(POSEntry2_AmtInclTax; POSEntry2."Amount Excl. Tax")
                    {
                    }
                    column(Name_SalesPerson; Salesperson.Name)
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
                        end;
                    }
                    dataitem("POS Payment Line"; "NPR POS Entry Payment Line")
                    {
                        DataItemLink = "POS Entry No." = field("Entry No.");
                        DataItemTableView = sorting("POS Entry No.", "Line No.");
                        column(POSEntryNo_POSPaymentLine; "POS Payment Line"."POS Entry No.")
                        {
                        }
                        column(PosPaymentmethodcode_POSPaymentLine; "POS Payment Method Code")
                        {
                        }
                        column(AmountLCY_POSPaymentLine; Amount)
                        {
                        }
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Salesperson.Get(POSEntry2."Salesperson Code");
                        SalesPersonSalesCount := POSSalesLineValue."Quantity";
                    end;

                    trigger OnPreDataItem()
                    begin
                        POSEntry2.SetRange("Entry Date", "POS Entry"."Entry Date");
                        POSEntry2.SetRange("System Entry", false);
                        POSEntry2.SetFilter("Entry Type", '%1|%2|%3|%4|%5',
                        POSEntry2."Entry Type"::"Credit Sale",
                        POSEntry2."Entry Type"::"Direct Sale",
                        POSEntry2."Entry Type"::Balancing,
                        POSEntry2."Entry Type"::Other,
                        POSEntry2."Entry Type"::Comment);
                    end;
                }
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
                                        EFTLCY += POSPaymentLine.Amount;
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
                                        LocalCurrencyLCY += POSPaymentLine.Amount;
                                    until POSPaymentLine.Next() = 0;
                            until POSPaymentMethod.Next() = 0;

                        if POSEntryValue."Entry Type" = POSEntryValue."Entry Type"::"Direct Sale" then begin
                            POSSalesLineValue.Reset();
                            POSSalesLineValue.SetRange("POS Entry No.", POSEntryValue."Entry No.");
                            if POSEntryValue."Sales Document Type" = POSEntryValue."Sales Document Type"::Quote then
                                if (POSEntryValue."Sales Quantity" <> 0) or (POSEntryValue."Return Sales Quantity" <> 0) then
                                    SumOfDirectSalesTicket += 1;
                            if POSSalesLineValue.FindSet() then
                                repeat
                                    TotalDiscountLCY += POSSalesLineValue."Line Dsc. Amt. Excl. VAT (LCY)";
                                    if POSSalesLineValue.Quantity > 0 then begin
                                        ItemSoldQty += 1;
                                    end else begin
                                        ItemReturnQty += 1;
                                    end;
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::"G/L Account" then
                                        GLPaymentLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Customer then
                                        DebtorPaymentLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Payout then
                                        GLPaymentLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Rounding then
                                        RoundingLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";

                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Voucher then
                                        AssignVoucherValuesForSalesLine(POSSalesLineValue);

                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Item then begin
                                        ItemCost := POSSalesLineValue."Unit Cost (LCY)" * POSSalesLineValue.Quantity;
                                        ItemCostTotal += ItemCost;
                                        if POSSalesLineValue.Quantity > 0 then begin
                                            DirectSalesCount += 1;
                                            DirectSalesExcVAT += POSSalesLineValue."Amount Excl. VAT";
                                            DirectItemNetSalesLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                        end else begin
                                            DirectSalesReturnCount += 1;
                                            DirectReturnSalesLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                            DirectReturnExcVAT += POSSalesLineValue."Amount Excl. VAT";
                                        end;
                                        if POSEntryValue."Sales Document Type" = POSEntryValue."Sales Document Type"::Quote then
                                            NetDirectTurnover += POSSalesLineValue."Amount Excl. VAT (LCY)";
                                    end;
                                until POSSalesLineValue.Next() = 0;
                        end;

                        if POSEntryValue."Entry Type" = POSEntryValue."Entry Type"::"Credit Sale" then begin
                            POSSalesLineValue.Reset();
                            POSSalesLineValue.SetRange("POS Entry No.", POSEntryValue."Entry No.");
                            if POSEntryValue."Sales Document Type" = POSEntryValue."Sales Document Type"::Invoice then
                                CreditSalesCount += 1;
                            if POSSalesLineValue.FindSet() then
                                repeat
                                    TotalDiscountLCY += POSSalesLineValue."Line Dsc. Amt. Excl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::"G/L Account" then
                                        GLPaymentLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Customer then
                                        DebtorPaymentLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Payout then
                                        GLPaymentLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Rounding then
                                        RoundingLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";

                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Voucher then
                                        AssignVoucherValuesForSalesLine(POSSalesLineValue);

                                    if POSSalesLineValue.Quantity > 0 then
                                        ItemSoldQty += 1
                                    else
                                        ItemReturnQty += 1;
                                    if POSSalesLineValue.Type = POSSalesLineValue.Type::Item then begin
                                        ItemCost := POSSalesLineValue."Unit Cost (LCY)" * POSSalesLineValue.Quantity;
                                        ItemCostTotal += ItemCost;

                                        if POSEntryValue."Sales Document Type" = POSEntryValue."Sales Document Type"::Invoice then
                                            if POSSalesLineValue."Amount Incl. VAT (LCY)" > 0 then
                                                CreditRealSaleAmtLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                        if POSEntryValue."Sales Document Type" = POSEntryValue."Sales Document Type"::"Credit Memo" then begin
                                            CreditRealReturnAmtLCY += POSSalesLineValue."Amount Incl. VAT (LCY)";
                                            CreditSalesMemoExcVAT += POSSalesLineValue."Amount Excl. VAT";
                                            CreditMemoCount += 1;
                                        end;
                                        if (POSEntryValue."Sales Document Type" = POSEntryValue."Sales Document Type"::"Credit Memo") or (POSEntryValue."Sales Document Type" = POSEntryValue."Sales Document Type"::Invoice) then
                                            NetCreditTurnover += POSSalesLineValue."Amount Excl. VAT (LCY)";
                                        if POSEntryValue."Sales Document Type" = POSEntryValue."Sales Document Type"::Order then
                                            CreditUnrealSaleAmtLCY += POSSalesLineValue."Amount Excl. VAT (LCY)";
                                        if POSEntryValue."Sales Document Type" = POSEntryValue."Sales Document Type"::"Return Order" then
                                            CreditUnrealReturnAmtLCY += POSSalesLineValue."Amount Excl. VAT (LCY)";
                                    end;
                                    CreditSalesExcVAT += POSSalesLineValue."Amount Excl. VAT";
                                until POSSalesLineValue.Next() = 0;
                        end;
                        AssignVoucherValuesForPaymentLine(POSEntryValue."Entry No.");
                    until POSEntryValue.Next() = 0;

                NetTurnoverLCY := NetDirectTurnover + NetCreditTurnover;
                ProfitLcy := NetTurnoverLCY - ItemCostTotal;
                if NetTurnoverLCY <> 0 then
                    ProfitPct := ProfitLcy / NetTurnoverLCY;

                Turnover := (DirectSalesExcVAT + CreditSalesExcVAT) - (DirectReturnExcVAT + CreditSalesMemoExcVAT);
                ItemQty := ItemSoldQty - ItemReturnQty;
                SalesTicket := SumOfDirectSalesTicket + CreditSalesCount + CreditMemoCount;

                DirectTurnover := DirectSalesExcVAT + DirectReturnExcVAT;

                POSEntryValue.Reset();
                POSEntryValue.SetFilter("Entry Date", '=%1', "POS Entry"."Entry Date");
                POSEntryValue.SetFilter("Entry Type", '=%1', POSEntryValue."Entry Type"::"Cancelled Sale");
                CancelledSalesCount := POSEntryValue.Count;
            end;
        }
    }

    labels
    {
        ProfitExclVatLbl = 'Price Excl. VAT';
        NetTurnoverLCYLbl = 'Net Turnover (LCY)';
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
        ItemLineslbl = 'Item Lines';
        itemLineSalesQtyLbl = 'Item Lines/Sales (Qty)';
        SalesQTYLbl = 'Sales (Qty)';
        SalesAmtLbl = 'Sales Amt.';
        SalesAvgLbl = 'Avg. Sales';
        PaymentDetailsLbl = 'Payment Details';
        PaymentMethodLbl = 'Payment Method';
        AmountLbl = 'Amount LCY';
        ItemQTYSalesTicket = 'Item (Qty)/Sales Ticket';
        ItemCostTotalLbl = 'Item Cost Total';
        DirectTurnoverLCYlbl = 'Direct Turnover (LCY)';
        IssuedGiftVouchersLCYlbl = 'Issued Gift Vouchers (LCY)';
        IssuedCreditVouchersLCYlbl = 'Issued Credit Vouchers (LCY)';
        RedeemedGiftVoucherslbl = 'Redeemed Gift Vouchers';
        RedeemedCreditVoucherslbl = 'Redeemed Credit Vouchers';
        DirectTurnoverDirectSalesTicketLbl = 'Direct Turnover/Direct Sales Ticket';
        GrossDirectTurnoverLCYLbl = 'Gross Direct Turnover (LCY)';
        OrderLbl = 'Order';
        NetCreditUnrealSaleAmtLbl = 'Net Credit Unreal. Sale Amt';
        NetCreditUnrealSaleReturnAmtLbl = 'Net Credit Unreal. Return Sale Amt';
        NetDirectTurnoverLbl = 'Net Direct Turnover';
        NetCreditTurnoverLbl = 'Net Credit Turnover';
        OtherPaymentsLCYLbl = 'Other Payments (LCY)';
        RedeemedVouchersLCYLbl = 'Redeemed Vouchers (LCY)';
        IssuedVouchersLCYLbl = 'Issued Vouchers (LCY)';
    }

    trigger OnPreReport()
    begin
        if CompanyInfo.Get() then;
        CompanyInfo.CalcFields(Picture);
    end;

    var
        CompanyInfo: Record "Company Information";
        POSEntry: Record "NPR POS Entry";
        POSEntryValue: Record "NPR POS Entry";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSSalesLineValue: Record "NPR POS Entry Sales Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Salesperson: Record "Salesperson/Purchaser";
        NPRNpRvVoucherType: Record "NPR NpRv Voucher Type";
        PrintDiscountAmt: Boolean;
        PrintDiscountPerc: Boolean;
        PrintDiscountTotal: Boolean;
        PrintNetTurnover: Boolean;
        PrintReceipts: Boolean;
        PrintSales: Boolean;
        PrintTerminals: Boolean;
        PrintOldVouchers: Boolean;
        AdjitemCostTotal: Decimal;
        AdjProfitLCY: Decimal;
        AdjProfitPct: Decimal;
        AdjSalesExclVAT: Decimal;
        CashDraweropnCount_: Decimal;
        CreditItemQuantitySum: Decimal;
        CreditItemSalesLCY: Decimal;
        CreditNetTurnOverLCY: Decimal;
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
        DirectNetTurnoverLCY: Decimal;
        DirectReturnSalesLCY: Decimal;
        DirectSalesLCY: Decimal;
        DirectTurnoverLCY: Decimal;
        EFTLCY: Decimal;
        GLPaymentLCY: Decimal;
        IssuedVouchersLCY: Decimal;
        IssuesVouchersLCy: Decimal;
        ItemLineSalesQty: Decimal;
        LocalCurrencyLCY: Decimal;
        NetCostLCY: Decimal;
        NetTurnoverLCY: Decimal;
        ProfitLcy: Decimal;
        ProfitPct: Decimal;
        RedeemedVoucherLCY: Decimal;
        RoundingLCY: Decimal;
        TotalDiscountLCY: Decimal;
        TurnoverAvgSalesTicket: Decimal;
        TurnoverLCY: Decimal;
        ItemCostTotal: Decimal;
        IssuedGiftVoucherLCY: Decimal;
        IssuedCreditVoucherLCY: Decimal;
        NetDirectTurnover: Decimal;
        NetCreditTurnover: Decimal;
        CreditUnrealReturnAmtLCY: Decimal;
        ItemCost: Decimal;
        RedeemedCreditVoucherLCY: Decimal;
        RedeemedGiftVoucherLCY: Decimal;
        Turnover: Decimal;
        DirectSalesExcVAT: Decimal;
        CreditSalesExcVAT: Decimal;
        DirectReturnExcVAT: Decimal;
        CreditSalesMemoExcVAT: Decimal;
        DirectTurnover: Decimal;
        CancelledSalesCount: Integer;
        DirectSalesCount: Integer;
        ItemQty: Integer;
        CreditSalesCount: Integer;
        DirectSalesReturnCount: Integer;
        CreditMemoCount: Integer;
        ItemSoldQty: Integer;
        ItemReturnQty: Integer;
        SalesTicket: Integer;
        SalesPersonSalesCount: Integer;
        SumOfDirectSalesTicket: Integer;
        DirectItemReturnsLineCount: Integer;
        DirectItemSalesLineCount: Integer;
        ItemLines: Integer;
        VarMain: Integer;
        VarTax: Integer;
        AmtInclTaxlbl_: Label 'Amount Including Tax';
        AttachedPaymentBinslbl: Label 'Attached Payment Bins';
        BOMDiscountLCYlbl_: Label 'BOM Discount (LCY)';
        BOMDiscountPerclbl_: Label 'BOM Discount %';
        CampaignDiscountLCYlbl_: Label 'Campaign Discount (LCY)';
        CampaignDiscountPerclbl_: Label 'Campaign Discount %';
        CancelledSalesCountlbl_: Label 'Cancelled Sales Count';
        CashMovementLCYlbl_: Label 'Local Currency (LCY)';
        CashTerminalLCYlbl_: Label 'Cash Terminal (LCY)';
        ClosingDatelbl: Label 'Date Filter';
        Closinglbl: Label 'Closing';
        Countinglbl: Label 'Counting';
        CreatedCreditVoucherLCYlbl_: Label 'Created Credit Voucher (LCY)';
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
        DirectReturnSalesLCYlbl_: Label 'Direct Item Returns (LCY)';
        DirectSalesLCYlbl_: Label 'Direct Item Sales (LCY)';
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
        LineDiscountLCYlbl_: Label 'Line Discount (LCY)';
        LineDiscountPerclbl_: Label 'Line Discount %';
        LocalCurrencyLCYlbl_: Label 'Local Currency (LCY)';
        ManualCardLCYlbl_: Label 'Manual Card (LCY)';
        MixDiscountLCYlbl_: Label 'Mix Discount (LCY)';
        MixDiscountPerclbl_: Label 'Mix Discount %';
        NetCostLCYlbl_: Label 'Net Cost (LCY)';
        NetTurnoverLCYlbl_: Label 'Net Turnover (LCY)';
        OpeningHrsLbl: Label 'Opening Hours';
        OtherCreditCardLCYlbl_: Label 'Other Credit Card (LCY)';
        POSUnitLbl: Label 'POS Unit';
        ProfitAmountLCYlbl_: Label 'Profit Amount (LCY)';
        ProfitPerclbl_: Label 'Profit %';
        QtyDiscountLCYlbl_: Label 'Quantity Discount (LCY)';
        QtyDiscountPerclbl_: Label 'Quantity Discount %';
        ReceiptCopiesCountlbl_: Label 'Receipt Copies Count';
        ReceiptsCountlbl_: Label 'Receipts Count';
        Receiptslbl: Label 'Receipts';
        RedeemedCreditVoucherLClbl_: Label 'Redeemed Credit Voucher (LCY)';
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
        TotalDiscountLClbl_: Label 'Total Discount (LCY)';
        TotalDiscountLCYlbl_: Label 'Total Discount (LCY)';
        TotalDiscountPerclbl_: Label 'Total Discount %';
        Turnoverlbl: Label 'Turnover (LCY)';
        VATIdentifierlbl_: Label 'VAT Identifier';
        VATTaxSummarylbl: Label 'VAT & TAX Summary';
        Voucherslbl: Label 'Vouchers';
        Workshiftlbl: Label 'Workshift';
        VarReportTitle: Text;

    [Obsolete('Not used anymore.', 'NPR25.0')]
    procedure Divider("Tal 1": Decimal; "Tal 2": Decimal): Decimal
    begin
        if "Tal 2" = 0 then
            exit(0);
        exit(("Tal 1" / "Tal 2"));
    end;

    local procedure AssignVoucherValuesForPaymentLine(EntryNo: Integer)
    begin
        POSPaymentMethod.Reset();
        POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::VOUCHER);
        if POSPaymentMethod.FindSet() then
            repeat
                POSPaymentLine.Reset();
                POSPaymentLine.SetRange("POS Entry No.", EntryNo);
                POSPaymentLine.SetRange("POS Payment Method Code", POSPaymentMethod.Code);
                if POSPaymentLine.FindSet() then
                    repeat
                        case POSPaymentLine."Voucher Category" of
                            NPRNpRvVoucherType."Voucher Category"::"Gift Voucher":
                                if POSPaymentLine."Amount (LCY)" > 0 then
                                    RedeemedGiftVoucherLCY += POSPaymentLine."Amount (LCY)";
                            NPRNpRvVoucherType."Voucher Category"::"Credit Voucher":
                                if POSPaymentLine."Amount (LCY)" > 0 then
                                    RedeemedCreditVoucherLCY += POSPaymentLine."Amount (LCY)"
                                else
                                    IssuedCreditVoucherLCY += Abs(POSPaymentLine."Amount (LCY)");
                            else
                                PrintOldVouchers := true;
                        end;
                        if POSPaymentLine."Amount (LCY)" < 0 then
                            IssuedVouchersLCY += Abs(POSPaymentLine."Amount (LCY)")
                        else
                            RedeemedVoucherLCY += POSPaymentLine."Amount (LCY)";
                    until POSPaymentLine.Next() = 0;
            until POSPaymentMethod.Next() = 0;
    end;

    local procedure AssignVoucherValuesForSalesLine(_POSSalesLineValue: Record "NPR POS Entry Sales Line")
    begin
        IssuedVouchersLCY += _POSSalesLineValue."Amount Incl. VAT (LCY)";
        case _POSSalesLineValue."Voucher Category" of
            _POSSalesLineValue."Voucher Category"::"Gift Voucher":
                IssuedGiftVoucherLCY += _POSSalesLineValue."Amount Incl. VAT (LCY)";
            _POSSalesLineValue."Voucher Category"::"Credit Voucher":
                IssuedCreditVoucherLCY += _POSSalesLineValue."Amount Incl. VAT (LCY)";
            else
                PrintOldVouchers := true;
        end;
    end;

}
