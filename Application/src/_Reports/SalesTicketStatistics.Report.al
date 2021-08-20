report 6014410 "NPR Sales Ticket Statistics"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Ticket Statistics.rdlc';
    Caption = 'Sale Statistics';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("NPR POS Entry Statistics"; "NPR POS Entry Statistics")
        {
            RequestFilterFields = "Date Filter", "Salesperson Filter";
            RequestFilterHeading = 'Filters';

            trigger OnPreDataItem()
            begin
                //To keep filters set in request page
                POSEntryStatisticsFilters.CopyFilters("NPR POS Entry Statistics");
                CurrReport.Break();
            end;
        }
        dataitem("NPR POS Unit"; "NPR POS Unit")
        {
            column(COMPANYNAME; CompanyName()) { }
            column(POSUnitFilter_POSEntryStatistics; POSEntryStatisticsFilters.GetFilter("POS Unit Filter")) { }
            column(DateFilter_POSEntryStatistics; POSEntryStatisticsFilters.GetFilter("Date Filter")) { }

            dataitem(POSPaymentMethod; "NPR POS Payment Method")
            {
                column(Code_PaymentMethodGeneral; Code) { }
                column(Description_PaymentMethodGeneral; Description) { }
                column(PaymentAmount_POSEntryStatisticsPerUnit; POSEntryStatisticsPaymentMethodGeneral."Payment Amount") { }
                column(TaxPaymentAmount_POSEntryStatisticsPerUnit; POSEntryStatisticsPaymentMethodGeneral."Tax Payment Amount") { }
                column(TaxPaymentBaseAmount_POSEntryStatisticsPerUnit; POSEntryStatisticsPaymentMethodGeneral."Tax Payment Base Amount") { }

                trigger OnAfterGetRecord()
                begin
                    POSEntryStatisticsPaymentMethodGeneral.Calculate(POSPaymentMethod);
                    POSEntryStatisticsPaymentMethodGeneral.SetFilter("POS Payment Method Filter", POSPaymentMethod.Code);
                    POSEntryStatisticsPaymentMethodGeneral.SetFilter("POS Unit Filter", POSEntryStatisticsFilters.GetFilter("POS Unit Filter"));
                    POSEntryStatisticsPaymentMethodGeneral.SetFilter("Date Filter", POSEntryStatisticsFilters.GetFilter("Date Filter"));
                    POSEntryStatisticsPaymentMethodGeneral.CalcFields("Payment Amount", "Tax Payment Amount", "Tax Payment Base Amount");
                end;
            }
            dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
            {
                DataItemTableView = sorting(Code);
                column(Code_SalespersonPurchaser; "Salesperson/Purchaser".Code) { }
                column(Name_SalespersonPurchaser; "Salesperson/Purchaser".Name) { }
                column(DebitAmtExclTax_POSEntryStatisticsSalesperson; POSEntryStatisticsSalesperson."Debit Sale Amount Excl. Tax") { }
                column(DebitTaxAmt; POSEntryStatisticsSalesperson."Debit Sale Amount Incl. Tax" - POSEntryStatisticsSalesperson."Debit Sale Amount Excl. Tax") { }
                column(DebitAmtInclTax_POSEntryStatisticsSalesperson; POSEntryStatisticsSalesperson."Debit Sale Amount Incl. Tax") { }
                column(CreditAmtExclTax_POSEntryStatisticsSalesperson; POSEntryStatisticsSalesperson."Credit Sale Amount Excl. Tax") { }
                column(CreditTaxAmt; POSEntryStatisticsSalesperson."Credit Sale Amount Incl. Tax" - POSEntryStatisticsSalesperson."Credit Sale Amount Excl. Tax") { }
                column(CreditAmountInclTax_POSEntryStatisticsSalesperson; POSEntryStatisticsSalesperson."Credit Sale Amount Incl. Tax") { }
                column(DirectAmtExclTax_POSEntryStatisticsSalesperson; POSEntryStatisticsSalesperson."Direct Sale Amount Excl. Tax") { }
                column(DirectTaxAmt; POSEntryStatisticsSalesperson."Direct Sale Amount Incl. Tax" - POSEntryStatisticsSalesperson."Direct Sale Amount Excl. Tax") { }
                column(DirectAmtInclTax_POSEntryStatisticsSalesperson; POSEntryStatisticsSalesperson."Direct Sale Amount Incl. Tax") { }
                column(BalancingAmtExclTax_POSEntryStatisticsSalesperson; POSEntryStatisticsSalesperson."Balancing Amount Excl. Tax") { }
                column(BalancingTaxAmt; POSEntryStatisticsSalesperson."Balancing Amount Incl. Tax" - POSEntryStatisticsSalesperson."Balancing Amount Excl. Tax") { }
                column(BalancingAmtInclTax_POSEntryStatisticsSalesperson; POSEntryStatisticsSalesperson."Balancing Amount Incl. Tax") { }

                trigger OnAfterGetRecord()
                begin
                    POSEntryStatisticsSalesperson.Calculate(POSPaymentMethod);
                    POSEntryStatisticsSalesperson.SetFilter("Salesperson Filter", "Salesperson/Purchaser".Code);
                    POSEntryStatisticsSalesperson.SetFilter("POS Unit Filter", POSEntryStatisticsFilters.GetFilter("POS Unit Filter"));
                    POSEntryStatisticsSalesperson.SetFilter("Date Filter", POSEntryStatisticsFilters.GetFilter("Date Filter"));
                    POSEntryStatisticsSalesperson.CalcFields("Payment Amount", "Tax Payment Amount", "Tax Payment Base Amount");
                end;

            }
            dataitem(POSPaymentMethodCash; "NPR POS Payment Method")
            {
                DataItemTableView = sorting(Code) ORDER(Ascending);

                column(Code_PaymentMethodCash; Code) { }
                column(Description_PaymentMethodCash; Description) { }
                column(PaymentAmount_POSEntryStatisticsCash; POSEntryStatPymMethodCash."Payment Amount") { }
                column(TaxPaymentAmount_POSEntryStatisticsCash; POSEntryStatPymMethodCash."Tax Payment Amount") { }
                column(TaxPaymentBaseAmount_POSEntryStatisticsCash; POSEntryStatPymMethodCash."Tax Payment Base Amount") { }

                trigger OnPreDataItem()
                begin
                    SetRange("Processing Type", "Processing Type"::"Cash");
                end;

                trigger OnAfterGetRecord()
                begin
                    POSEntryStatPymMethodCash.Calculate(POSPaymentMethod);
                    POSEntryStatPymMethodCash.SetFilter("POS Payment Method Filter", POSPaymentMethod.Code);
                    POSEntryStatPymMethodCash.SetFilter("POS Unit Filter", POSEntryStatisticsFilters.GetFilter("POS Unit Filter"));
                    POSEntryStatPymMethodCash.SetFilter("Date Filter", POSEntryStatisticsFilters.GetFilter("Date Filter"));
                    POSEntryStatPymMethodCash.CalcFields("Payment Amount", "Tax Payment Amount", "Tax Payment Base Amount");
                end;
            }
            dataitem(POSPaymentMethodVoucher; "NPR POS Payment Method")
            {
                DataItemTableView = sorting("Code") ORDER(Ascending);
                column(Code_PaymentMethodVoucher; Code) { }
                column(Description_PaymentMethodVoucher; Description) { }
                column(PaymentAmount_POSEntryStatisticsVoucher; POSEntryStatPymMethodVoucher."Payment Amount") { }
                column(TaxPaymentAmount_POSEntryStatisticsVoucher; POSEntryStatPymMethodVoucher."Tax Payment Amount") { }
                column(TaxPaymentBaseAmount_POSEntryStatisticsVoucher; POSEntryStatPymMethodVoucher."Tax Payment Base Amount") { }

                trigger OnPreDataItem()
                begin
                    SetRange("Processing Type", "Processing Type"::VOUCHER);
                end;

                trigger OnAfterGetRecord()
                begin
                    POSEntryStatPymMethodVoucher.Calculate(POSPaymentMethod);
                    POSEntryStatPymMethodVoucher.SetFilter("POS Payment Method Filter", POSPaymentMethod.Code);
                    POSEntryStatPymMethodVoucher.SetFilter("POS Unit Filter", POSEntryStatisticsFilters.GetFilter("POS Unit Filter"));
                    POSEntryStatPymMethodVoucher.SetFilter("Date Filter", POSEntryStatisticsFilters.GetFilter("Date Filter"));
                    POSEntryStatPymMethodVoucher.CalcFields("Payment Amount", "Tax Payment Amount", "Tax Payment Base Amount");
                end;
            }
            dataitem(POSPaymentMethodForeignVoucher; "NPR POS Payment Method")
            {
                DataItemTableView = sorting(Code) ORDER(Ascending);
                column(Code_PaymentMethodFrnVoucher; Code) { }
                column(Description_PaymentMethodFrnVoucher; Description) { }
                column(PaymentAmount_POSEntryStatisticsFrnVoucher; POSEntryStatisticsFrnVoucher."Payment Amount") { }
                column(TaxPaymentAmount_POSEntryStatisticsFrnVoucher; POSEntryStatisticsFrnVoucher."Tax Payment Amount") { }
                column(TaxPaymentBaseAmount_POSEntryStatisticsFrnVoucher; POSEntryStatisticsFrnVoucher."Tax Payment Base Amount") { }

                trigger OnPreDataItem()
                begin
                    SetRange("Processing Type", "Processing Type"::"FOREIGN VOUCHER");
                end;

                trigger OnAfterGetRecord()
                begin
                    POSEntryStatisticsFrnVoucher.Calculate(POSPaymentMethod);
                    POSEntryStatisticsFrnVoucher.SetFilter("POS Payment Method Filter", POSPaymentMethod.Code);
                    POSEntryStatisticsFrnVoucher.SetFilter("POS Unit Filter", POSEntryStatisticsFilters.GetFilter("POS Unit Filter"));
                    POSEntryStatisticsFrnVoucher.SetFilter("Date Filter", POSEntryStatisticsFilters.GetFilter("Date Filter"));
                    POSEntryStatisticsFrnVoucher.CalcFields("Payment Amount", "Tax Payment Amount", "Tax Payment Base Amount");
                end;
            }
            dataitem(POSPaymentMethodEFT; "NPR POS Payment Method")
            {
                DataItemTableView = sorting("Code") ORDER(Ascending);
                column(Code_PaymentMethodEFT; Code) { }
                column(Description_PaymentMethodEFT; Description) { }
                column(PaymentAmount_POSEntryStatisticsEFT; POSEntryStatisticsEFT."Payment Amount") { }
                column(TaxPaymentAmount_POSEntryStatisticsEFT; POSEntryStatisticsEFT."Tax Payment Amount") { }
                column(TaxPaymentBaseAmount_POSEntryStatisticsEFT; POSEntryStatisticsEFT."Tax Payment Base Amount") { }

                trigger OnPreDataItem()
                begin
                    SetRange("Processing Type", "Processing Type"::"EFT");
                end;

                trigger OnAfterGetRecord()
                begin
                    POSEntryStatisticsEFT.Calculate(POSPaymentMethod);
                    POSEntryStatisticsEFT.SetFilter("POS Payment Method Filter", POSPaymentMethod.Code);
                    POSEntryStatisticsEFT.SetFilter("POS Unit Filter", POSEntryStatisticsFilters.GetFilter("POS Unit Filter"));
                    POSEntryStatisticsEFT.SetFilter("Date Filter", POSEntryStatisticsFilters.GetFilter("Date Filter"));
                    POSEntryStatisticsEFT.CalcFields("Payment Amount", "Tax Payment Amount", "Tax Payment Base Amount");
                end;
            }
            dataitem(POSPaymentMethodCheck; "NPR POS Payment Method")
            {
                DataItemTableView = sorting(Code) ORDER(Ascending);
                column(Code_PaymentMethodCheck; Code) { }
                column(Description_PaymentMethodCheck; Description) { }
                column(PaymentAmount_POSEntryStatisticsCheck; POSEntryStatisticsCheck."Payment Amount") { }
                column(TaxPaymentAmount_POSEntryStatisticsCheck; POSEntryStatisticsCheck."Tax Payment Amount") { }
                column(TaxPaymentBaseAmount_POSEntryStatisticsCheck; POSEntryStatisticsCheck."Tax Payment Base Amount") { }

                trigger OnPreDataItem()
                begin
                    SetRange("Processing Type", "Processing Type"::"CHECK");
                end;

                trigger OnAfterGetRecord()
                begin
                    POSEntryStatisticsCheck.Calculate(POSPaymentMethod);
                    POSEntryStatisticsCheck.SetFilter("POS Payment Method Filter", POSPaymentMethod.Code);
                    POSEntryStatisticsCheck.SetFilter("POS Unit Filter", POSEntryStatisticsFilters.GetFilter("POS Unit Filter"));
                    POSEntryStatisticsCheck.SetFilter("Date Filter", POSEntryStatisticsFilters.GetFilter("Date Filter"));
                    POSEntryStatisticsCheck.CalcFields("Payment Amount", "Tax Payment Amount", "Tax Payment Base Amount");
                end;
            }
            dataitem(PaymentMethodPayout; "NPR POS Payment Method")
            {
                DataItemTableView = sorting("Code") ORDER(Ascending);
                column(Code_PaymentMethodPayout; Code) { }
                column(Description_PaymentMethodPayout; Description) { }
                column(PaymentAmount_POSEntryStatisticsPayout; POSEntryStatisticsPayout."Payment Amount") { }
                column(TaxPaymentAmount_POSEntryStatisticsPayout; POSEntryStatisticsPayout."Tax Payment Amount") { }
                column(TaxPaymentBaseAmount_POSEntryStatisticsPayout; POSEntryStatisticsPayout."Tax Payment Base Amount") { }

                trigger OnPreDataItem()
                begin
                    SetRange("Processing Type", "Processing Type"::"PAYOUT");
                end;

                trigger OnAfterGetRecord()
                begin
                    POSEntryStatisticsPayout.Calculate(POSPaymentMethod);
                    POSEntryStatisticsPayout.SetFilter("POS Payment Method Filter", POSPaymentMethod.Code);
                    POSEntryStatisticsPayout.SetFilter("POS Unit Filter", POSEntryStatisticsFilters.GetFilter("POS Unit Filter"));
                    POSEntryStatisticsPayout.SetFilter("Date Filter", POSEntryStatisticsFilters.GetFilter("Date Filter"));
                    POSEntryStatisticsPayout.CalcFields("Payment Amount", "Tax Payment Amount", "Tax Payment Base Amount");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                POSEntryStatisticsPaymentMethodGeneral.Reset();
                POSEntryStatisticsPaymentMethodGeneral.DeleteAll();

                POSEntryStatisticsSalesperson.Reset();
                POSEntryStatisticsSalesperson.DeleteAll();

                POSEntryStatPymMethodVoucher.Reset();
                POSEntryStatPymMethodVoucher.DeleteAll();

                POSEntryStatisticsFrnVoucher.Reset();
                POSEntryStatisticsFrnVoucher.DeleteAll();

                POSEntryStatisticsCheck.Reset();
                POSEntryStatisticsCheck.DeleteAll();

                POSEntryStatisticsEFT.Reset();
                POSEntryStatisticsEFT.DeleteAll();

                POSEntryStatisticsPayout.Reset();
                POSEntryStatisticsPayout.DeleteAll();
            end;
        }
    }

    labels
    {
        Report_Caption = 'Sale Statistics';
        PaymentTypeInclVAT_Caption = 'Payment Type incl. VAT:';
        AnalysisPeriod_Caption = 'Analysis Period';
        LastYearCaption = 'Last Year';
        SalesQty_Caption = 'Sales (Qty)';
        TurnoverTotal_Caption = 'Turnover Total';
        DebitSales_Caption = 'Debit Sales';
        SalesTotal_Caption = 'Sales Total';
        SalesTotalExcVAT_Caption = 'Sales Excl. VAT';
        ItemCostTotal = 'Item Cost Total';
        ProfitLCY_Total = 'Profit (LCY)';
        ProfitLCY_Pct = 'Profit Pct';
        TurnoverAvg_Caption = 'Turnover (avg.)/Sales Ticket';
        ItemQty_Caption = 'Item (Qty)';
        ItemQtySalesTicket_Caption = 'Items (Qty)/Sales Ticket';
        ItemLines_Caption = 'Item Lines';
        ItemQtyLine_Caption = 'Item Line/Sales (Qty)';
        Salespersons_Caption = 'Salespersons:';
        Sale_Caption = 'Sale';
        Sale2_Caption = 'Sale';
        Avg_Caption = 'Avg.';
        Debit_Caption = 'Credit';
        Credit_Caption = 'Credit';
        Total_Caption = 'Total';
        PaymentType_Caption = 'Payment Type:';
        RegisterFilter_Caption = 'Register Filter';
        DateFilter_Caption = 'Date Filter';
        DateFilter_LY_Caption = 'Date Filter last year';
        ProfitExcVat_Caption = 'Profit Excl. VAT';
        AdjustedCost_Caption = 'Adjusted Cost Details:';
        AdjSalesTotalExcVAT_Caption = 'Adj Sales Excl. VAT';
        AdjItemCostTotal = 'Adj Item Cost Total';
        AdjProfitLCY_Total = 'Adj Profit (LCY)';
        AdjProfitLCY_Pct = 'Adj Profit Pct';
        ClickCollectOrders = 'Click & Collect Orders';
    }


    var
        POSEntryStatisticsFilters: Record "NPR POS Entry Statistics";
        POSEntryStatisticsPaymentMethodGeneral: Record "NPR POS Entry Statistics";
        POSEntryStatPymMethodCash: Record "NPR POS Entry Statistics";
        POSEntryStatPymMethodVoucher: Record "NPR POS Entry Statistics";
        POSEntryStatisticsSalesperson: Record "NPR POS Entry Statistics";
        POSEntryStatisticsFrnVoucher: Record "NPR POS Entry Statistics";
        POSEntryStatisticsCheck: Record "NPR POS Entry Statistics";
        POSEntryStatisticsEFT: Record "NPR POS Entry Statistics";
        POSEntryStatisticsPayout: Record "NPR POS Entry Statistics";
}

