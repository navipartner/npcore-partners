report 6014410 "NPR Sales Ticket Statistics"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Ticket Statistics.rdlc';

    Caption = 'Sale Statistics';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem("NPR POS Unit"; "NPR POS Unit")
        {
            dataitem(POSPaymentMethod; "NPR POS Payment Method")
            {
                CalcFields = "Normal Sale in POS", "Debit Sale in POS", "No. of Sales in POS", "Cost Amount in POS", "No. of Items in POS", "No. of Sale Lines in POS", "No. of Item Lines in POS", "No. of Deb. Sales in POS", "Norm. Sales in POS Excl. VAT", "Debit Sales in POS Excl. VAT", "Unit Cost in POS Sale";
                RequestFilterFields = "Date Filter", "POS Unit Filter", "Salesperson Filter";

                column(COMPANYNAME; COMPANYNAME)
                {
                }
                column(RegisterFilter_Periode; GETFILTER("POS Unit Filter"))
                {
                }
                column(DateFilter_Periode; GETFILTER("Date Filter"))
                {
                }
                column(No_PaymentTypePeriod; POSPaymentMethod."Code")
                {
                }
                column(SalesQty1_PaymentTypePeriod; POSPaymentMethod."No. of Sales in POS")
                {
                }
                column(Turnover1_PaymentTypePeriod; POSPaymentMethod."Normal Sale in POS")
                {
                }
                column(DebitSales1_PaymentTypePeriod; POSPaymentMethod."Debit Sale in POS" - varDebitSales)
                {
                }
                column(SalesQty2_PaymentTypePeriod; PaymentLastYr."No. of Sales in POS")
                {
                }
                column(Turnover2_PaymentTypePeriod; PaymentLastYr."Normal Sale in POS")
                {
                }
                column(DebitSales2_PaymentTypePeriod; PaymentLastYr."Debit Sale in POS" - varDebitSalesLastYr)
                {
                }
                column(SalesTotal1_PaymentTypePeriod; POSPaymentMethod."Normal Sale in POS" + (POSPaymentMethod."Debit Sale in POS" - varDebitSales))
                {
                }
                column(SalesTotal2_PaymentTypePeriod; PaymentLastYr."Normal Sale in POS" + (PaymentLastYr."Debit Sale in POS" - varDebitSalesLastYr))
                {
                }
                column(ItemCost1_PaymentTypePeriod; POSPaymentMethod."Cost Amount in POS" + POSPaymentMethod."Unit Cost in POS Sale")
                {
                }
                column(ItemCost2_PaymentTypePeriod; PaymentLastYr."Cost Amount in POS" + PaymentLastYr."Unit Cost in POS Sale")
                {
                }
                column(SalesTotalExcVAT_PaymentTypePeriod; "Norm. Sales in POS Excl. VAT" + "Debit Sales in POS Excl. VAT")
                {
                }
                column(ClickandCollect1_; varDebitSales)
                {
                }
                column(ClickandCollect2_; varDebitSalesLastYr)
                {
                }
                column(SalesExVatLYr; SalesExVatLYr)
                {
                }
                column(Profit_LCY1_PaymentTypePeriod; CalcPCT(("Norm. Sales in POS Excl. VAT" + "Debit Sales in POS Excl. VAT") - ("Cost Amount in POS" + "Unit Cost in POS Sale"), ("Norm. Sales in POS Excl. VAT" + "Debit Sales in POS Excl. VAT")))
                {
                }
                column(Profit_LCYAmt1_PaymentTypePeriod; ("Norm. Sales in POS Excl. VAT" + "Debit Sales in POS Excl. VAT") - ("Cost Amount in POS" + "Unit Cost in POS Sale"))
                {
                }
                column(Profit_LCY2_PaymentTypePeriod; Profit_LCY2_Amt)
                {
                }
                column(Profit_LCY2Pct_PaymentTypePeriod; Profit_LCY2_Pct)
                {
                }
                column(Turnover_avg1_PaymentTypePeriod; Divider(("Normal Sale in POS" + "Debit Sale in POS" - varDebitSales), ("No. of Sales in POS" + "No. of Deb. Sales in POS")))
                {
                }
                column(Turnover_avg2_PaymentTypePeriod; Divider((PaymentLastYr."Normal Sale in POS" + PaymentLastYr."Debit Sale in POS" - varDebitSalesLastYr), (PaymentLastYr."No. of Sales in POS" + PaymentLastYr."No. of Deb. Sales in POS")))
                {
                }
                column(ItemQty1_PaymentTypePeriod; "No. of Items in POS" + "No. of Item Lines in POS")
                {
                }
                column(ItemQty2_PaymentTypePeriod; PaymentLastYr."No. of Items in POS" + PaymentLastYr."No. of Item Lines in POS")
                {
                }
                column(ItemQtySale1_PaymentTypePeriod; Divider(("No. of Items in POS" + "No. of Item Lines in POS"), ("No. of Sales in POS" + "No. of Item Lines in POS")))
                {
                }
                column(ItemQtySale2_PaymentTypePeriod; Divider((PaymentLastYr."No. of Items in POS" + PaymentLastYr."No. of Item Lines in POS"), (PaymentLastYr."No. of Sales in POS" + PaymentLastYr."No. of Deb. Sales in POS")))
                {
                }
                column(ItemLines1_PaymentTypePeriod; NoOfItemsInAuditRoll)
                {
                }
                column(ItemLines2_PaymentTypePeriod; NoOfItemsInAuditRollLastYr)
                {
                }
                column(ItemQtyLine1_PaymentTypePeriod; Divider(NoOfItemsInAuditRoll, (POSPaymentMethod."No. of Sales in POS" + POSPaymentMethod."No. of Deb. Sales in POS")))
                {
                }
                column(ItemQtyLine2_PaymentTypePeriod; Divider(NoOfItemsInAuditRollLastYr, (PaymentLastYr."No. of Sales in POS" + PaymentLastYr."No. of Deb. Sales in POS")))
                {
                }
                column(ItemCost1_Adj; SumOfILELineCurrentYear * -1)
                {
                }
                column(ItemCost2_Adj; SumOfILELinePreviousYear * -1)
                {
                }
                column(SalesTotalExcVAT_PaymentTypePeriod_Adj; ("Norm. Sales in POS Excl. VAT" + "Debit Sales in POS Excl. VAT"))
                {
                }
                column(SalesExVatLYr_Adj; SalesExVatLYr)
                {
                }
                column(Profit_LCY1_PaymentTypePeriod_Adj; CalcPCT(("Norm. Sales in POS Excl. VAT" + "Debit Sales in POS Excl. VAT") - (SumOfILELineCurrentYear * -1), ("Norm. Sales in POS Excl. VAT" + "Debit Sales in POS Excl. VAT")))
                {
                }
                column(Profit_LCYAmt1_PaymentTypePeriod_Adj; ("Norm. Sales in POS Excl. VAT" + "Debit Sales in POS Excl. VAT") - (SumOfILELineCurrentYear * -1))
                {
                }
                column(Profit_LCY2_PaymentTypePeriod_Adj; Profit_LCY3_Amt)
                {
                }
                column(Profit_LCY2Pct_PaymentTypePeriod_Adj; Profit_LCY3_Pct)
                {
                }
                column(ShowAdj; ShowAdj)
                {
                }
                dataitem(PaymentLastYr; "NPR POS Payment Method")
                {
                    CalcFields = "Normal Sale in POS", "Debit Sale in POS", "No. of Sales in POS", "Cost Amount in POS", "No. of Items in POS", "No. of Sale Lines in POS", "No. of Item Lines in POS", "No. of Deb. Sales in POS", "Norm. Sales in POS Excl. VAT", "Debit Sales in POS Excl. VAT", "Unit Cost in POS Sale";
                    DataItemTableView = sorting(Code);
                    column(No_PaymentLastYr; PaymentLastYr."Code")
                    {
                    }
                    column(DateFilter_PaymentLastYr; GETFILTER("Date Filter"))
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Profit_LCY2_Amt := (PaymentLastYr."Norm. Sales in POS Excl. VAT" + PaymentLastYr."Debit Sales in POS Excl. VAT") - (PaymentLastYr."Cost Amount in POS" + PaymentLastYr."Unit Cost in POS Sale");
                        Profit_LCY3_Amt := (PaymentLastYr."Norm. Sales in POS Excl. VAT" + PaymentLastYr."Debit Sales in POS Excl. VAT") - (PaymentLastYr."Cost Amount in POS" + PaymentLastYr."Unit Cost in POS Sale");

                        Profit_LCY2_Pct := CalcPCT((PaymentLastYr."Norm. Sales in POS Excl. VAT" + PaymentLastYr."Debit Sales in POS Excl. VAT") - (PaymentLastYr."Cost Amount in POS" + PaymentLastYr."Unit Cost in POS Sale")
                        , (PaymentLastYr."Norm. Sales in POS Excl. VAT" + PaymentLastYr."Debit Sales in POS Excl. VAT"));

                        Profit_LCY3_Amt := CalcPCT((PaymentLastYr."Norm. Sales in POS Excl. VAT" + PaymentLastYr."Debit Sales in POS Excl. VAT") - (PaymentLastYr."Cost Amount in POS" + PaymentLastYr."Unit Cost in POS Sale")
                        , (PaymentLastYr."Norm. Sales in POS Excl. VAT" + PaymentLastYr."Debit Sales in POS Excl. VAT"));

                        SalesExVatLYr := (PaymentLastYr."Norm. Sales in POS Excl. VAT" + PaymentLastYr."Debit Sales in POS Excl. VAT");

                        Clear(NoOfItemsInAuditRollLastYr);
                        POSEntryLastYr.SetFilter("Entry Date", GETFILTER("Date Filter"));
                        POSEntryLastYr.SetFilter("POS Unit No.", GETFILTER("POS Unit Filter"));
                        POSEntryLastYr.SetRange("Entry Type", POSEntry."Entry Type"::Other);
                        NoOfItemsInAuditRollLastYr := POSEntryLastYr.Count();
                        varDebitSalesLastYr := 0;

                        DebitAmtQuery.SetRange(Entry_Date_Filter, StartDate, EndDate);
                        DebitAmtQuery.SetFilter(POS_Unit_No_Filter, GETFILTER("POS Unit Filter"));
                        DebitAmtQuery.SetRange(Entry_Type_Filter, 2);
                        DebitAmtQuery.SetRange(Entry_Type_Filter, 1);
                        DebitAmtQuery.SetFilter(Salesperson_Code_Filter, GETFILTER("Salesperson Filter"));
                        DebitAmtQuery.SetFilter(Shortcut_Dim_1_Code_Filter, GETFILTER("Global Dimension Code 1 Filter"));
                        DebitAmtQuery.SetFilter(Shortcut_Dim_2_Code_Filter, GETFILTER("Global Dimension Code 2 Filter"));



                        DebitAmtQuery.OPEN();
                        while DebitAmtQuery.READ() do begin
                            ArchDocument.Reset();
                            ArchDocument.SetRange("Delivery Document Type", ArchDocument."Delivery Document Type"::"POS Entry");
                            ArchDocument.SetRange("Delivery Document No.", DebitAmtQuery.Document_No);
                            if ArchDocument.FindFirst() then
                                varDebitSalesLastYr += DebitAmtQuery.Amount_Incl_Tax;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        COPYFILTERS(POSPaymentMethod);
                        if not Compare_Day then begin
                            StartDate := CALCDATE('<-1Y>', POSPaymentMethod.GetRangeMin("Date Filter"));
                            EndDate := CALCDATE('<-1Y>', POSPaymentMethod.GetRangeMax("Date Filter"));
                        end
                        else begin
                            StartDate := POSPaymentMethod.GetRangeMin("Date Filter");
                            EndDate := POSPaymentMethod.GetRangeMax("Date Filter");
                            WeekDay := DATE2DWY(StartDate, 1);
                            Week := DATE2DWY(StartDate, 2);
                            Year := DATE2DWY(StartDate, 3) - 1;
                            if Compare_Nearest_Date then
                                Week += 1;
                            StartDate := DWY2DATE(WeekDay, Week, Year);
                            WeekDay := DATE2DWY(EndDate, 1);
                            Week := DATE2DWY(EndDate, 2);
                            Year := DATE2DWY(EndDate, 3) - 1;
                            if Compare_Nearest_Date then
                                Week += 1;
                            EndDate := DWY2DATE(WeekDay, Week, Year);
                        end;
                        SetRange("Date Filter", StartDate, EndDate);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(NoOfItemsInAuditRoll);
                    POSEntry.SetFilter("Posting Date", GETFILTER("Date Filter"));
                    POSEntry.SetFilter("POS Unit No.", GETFILTER("POS Unit Filter"));
                    POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::Other);
                    NoOfItemsInAuditRoll := POSEntry.Count();

                    varDebitSales := 0;
                    if POSPaymentMethod.GETFILTER("Date Filter") = '' then
                        DebitAmtQuery.SetFilter(Entry_Date_Filter, '%1', WORKDATE())
                    else
                        DebitAmtQuery.SetFilter(Entry_Date_Filter, GETFILTER("Date Filter"));
                    DebitAmtQuery.SetFilter(POS_Unit_No_Filter, GETFILTER("POS Unit Filter"));
                    DebitAmtQuery.SetRange(Entry_Type_Filter, 2);
                    DebitAmtQuery.SetRange(Entry_Type_Filter, 1);
                    DebitAmtQuery.SetFilter(Salesperson_Code_Filter, GETFILTER("Salesperson Filter"));
                    DebitAmtQuery.SetFilter(Shortcut_Dim_1_Code_Filter, GETFILTER("Global Dimension Code 1 Filter"));
                    DebitAmtQuery.SetFilter(Shortcut_Dim_2_Code_Filter, GETFILTER("Global Dimension Code 2 Filter"));



                    DebitAmtQuery.OPEN();
                    while DebitAmtQuery.READ() do begin
                        ArchDocument.Reset();
                        ArchDocument.SetRange("Delivery Document Type", ArchDocument."Delivery Document Type"::"POS Entry");
                        ArchDocument.SetRange("Delivery Document No.", DebitAmtQuery.Document_No);
                        if ArchDocument.FindFirst() then
                            varDebitSales += DebitAmtQuery.Amount_Incl_Tax;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    POSPaymentMethod.SetRange("POS Unit Filter", "NPR POS Unit"."No.");

                    if POSPaymentMethod.GETFILTER("Date Filter") = '' then
                        POSPaymentMethod.SetFilter("Date Filter", '%1', WORKDATE());

                    EndDate := (POSPaymentMethod.GetRangeMax("Date Filter"));

                    ILEntry.SetFilter("Posting Date", '%1..%2', POSPaymentMethod.GetRangeMin("Date Filter"), POSPaymentMethod.GetRangeMax("Date Filter"));
                    ILEntry.SetRange("Entry Type", ILEntry."Entry Type"::Sale);
                    ILEntry.SetRange("Document Type", ILEntry."Document Type"::" ");

                    if ILEntry.FindSet() then begin
                        repeat
                            ILEntry.CalcFields("Cost Amount (Actual)");
                            SumOfILELineCurrentYear += ILEntry."Cost Amount (Actual)";
                        until ILEntry.Next() = 0;
                    end;
                end;
            }
            dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
            {
                DataItemTableView = sorting(Code);
                column(Code_SalespersonPurchaser; "Salesperson/Purchaser".Code)
                {
                }
                column(Name_SalespersonPurchaser; "Salesperson/Purchaser".Name)
                {
                }
                column(Eksp1_SalespersonPurchaser; (PaymentTypePOS."No. of Sales in POS" + PaymentTypePOS."No. of Deb. Sales in POS"))
                {
                }
                column(Eksp1_PaymentTypePOS; Eksp1)
                {
                }
                column(Sale1_SalespersonPurchaser; PaymentTypePOS."Normal Sale in POS")
                {
                }
                column(Sale1_PaymentTypePOS; Sale1)
                {
                }
                column(AverageAmt_SalespersonPurchaser; AverageAmt)
                {
                }
                column(Credit1_SalespersonPurchaser; PaymentTypePOS."Debit Sale in POS")
                {
                }
                column(Debit1_PaymentTypePOS; Debit1)
                {
                }
                column(Total1_SalespersonPurchaser; Total)
                {
                }
                column(Eksp2_SalespersonPurchaser; ekspWithoutSalesperson)
                {
                }
                column(Sale2_SalespersonPurchaser; NormalSaleWithoutSalesperson)
                {
                }
                column(Credit2_SalespersonPurchaser; DebitSaleWithoutSalesperson)
                {
                }
                column(Total2_SalespersonPurchaser; TotalSaleWithoutSalesperson)
                {
                }
                column(Eksp3_SalespersonPurchaser; Eksp3)
                {
                }
                column(Sale3_SalespersonPurchaser; Sale3)
                {
                }
                column(Credit3_SalespersonPurchaser; Credit3)
                {
                }
                column(Total3_SalespersonPurchaser; Total + TotalSaleWithoutSalesperson)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    PaymentTypePOS.SetRange("Salesperson Filter", Code);
                    PaymentTypePOS.CalcFields("Debit Sale in POS", "Normal Sale in POS", "No. of Sales in POS"
                    , "No. of Deb. Sales in POS");
                    OrdinarySale := PaymentTypePOS."Normal Sale in POS";
                    DebitAmt := PaymentTypePOS."Debit Sale in POS";
                    Total := OrdinarySale + DebitAmt;
                    ekspTotal := (PaymentTypePOS."No. of Sales in POS" + PaymentTypePOS."No. of Deb. Sales in POS");

                    Eksp1 := 0;
                    Debit1 := 0;
                    Sale1 := 0;
                    Eksp1 := (PaymentTypePOS."No. of Sales in POS" + PaymentTypePOS."No. of Deb. Sales in POS");
                    Debit1 := PaymentTypePOS."Debit Sale in POS";
                    Sale1 := PaymentTypePOS."Normal Sale in POS";

                    if PaymentTypePOS."No. of Sales in POS" <> 0 then begin
                        AverageAmt := Total / Eksp1;
                    end;

                    NormalSaleWithoutSalesperson := 0;
                    DebitSaleWithoutSalesperson := 0;
                    TotalSaleWithoutSalesperson := 0;
                    ekspWithoutSalesperson := 0;

                    PaymentTypePOSTotal.Reset();
                    Clear(PaymentTypePOSTotal);

                    PaymentTypePOSTotal.SetRange("Salesperson Filter", '');
                    PaymentTypePOSTotal.CalcFields("Debit Sale in POS", "Normal Sale in POS", "No. of Sales in POS", "No. of Deb. Sales in POS");
                    NormalSaleWithoutSalesperson := PaymentTypePOSTotal."Normal Sale in POS";
                    DebitSaleWithoutSalesperson := PaymentTypePOSTotal."Debit Sale in POS";
                    TotalSaleWithoutSalesperson := NormalSaleWithoutSalesperson + DebitSaleWithoutSalesperson;
                    ekspWithoutSalesperson := PaymentTypePOSTotal."No. of Sales in POS" + PaymentTypePOSTotal."No. of Deb. Sales in POS";

                    Eksp3 := ekspWithoutSalesperson + ekspTotal;
                    Sale3 := OrdinarySale + NormalSaleWithoutSalesperson;
                    Credit3 := DebitAmt + DebitSaleWithoutSalesperson;
                end;

                trigger OnPreDataItem()
                begin
                    POSPaymentMethod.SetRange("POS Unit Filter", "NPR POS Unit"."No.");
                    POSPaymentMethod.COPYFILTER("Date Filter", PaymentTypePOS."Date Filter");
                    POSPaymentMethod.COPYFILTER("POS Unit Filter", PaymentTypePOS."POS Unit Filter");
                    Clear(Total);
                    Clear(OrdinarySale);
                    Clear(DebitAmt);
                    Clear(ekspTotal);
                end;
            }
            dataitem(POSPaymentMethodCash; "NPR POS Payment Method")
            {
                CalcFields = "Amount in POS";
                DataItemTableView = sorting(Code) ORDER(Ascending);
                column(No_POSPaymentMethodCash; POSPaymentMethodCash."Code")
                {
                }
                column(RegisterNo_POSPaymentMethodCash; "NPR POS Unit"."No.")
                {
                }
                column(Description_POSPaymentMethodCash; POSPaymentMethodCash.Description)
                {
                }
                column(Amountinauditroll_POSPaymentMethodCash; POSPaymentMethodCash."Amount in POS")
                {
                }

                trigger OnPreDataItem()
                begin
                    POSPaymentMethod.COPYFILTER("Date Filter", POSPaymentMethodCash."Date Filter");
                    POSPaymentMethod.COPYFILTER("POS Unit Filter", POSPaymentMethodCash."POS Unit Filter");

                    SetRange("Processing Type", "Processing Type"::"Cash");
                    CalcFields("Amount in POS");
                end;
            }
            dataitem(POSPaymentMethodVoucher; "NPR POS Payment Method")
            {
                CalcFields = "Amount in POS";
                DataItemTableView = sorting("Code") ORDER(Ascending);
                column(No_POSPaymentMethodVoucher; POSPaymentMethodVoucher."Code")
                {
                }
                column(RegisterNo_POSPaymentMethodVoucher; "NPR POS Unit"."No.")
                {
                }
                column(Description_POSPaymentMethodVoucher; POSPaymentMethodVoucher.Description)
                {
                }
                column(Amountinauditroll_POSPaymentMethodVoucher; POSPaymentMethodVoucher."Amount in POS")
                {
                }

                trigger OnPreDataItem()
                begin
                    POSPaymentMethod.COPYFILTER("Date Filter", POSPaymentMethodVoucher."Date Filter");
                    POSPaymentMethod.COPYFILTER("POS Unit Filter", POSPaymentMethodVoucher."POS Unit Filter");
                    SetRange("Processing Type", "Processing Type"::VOUCHER);
                end;
            }
            dataitem(POSPaymentMethodForeignVoucher; "NPR POS Payment Method")
            {
                CalcFields = "Amount in POS";
                DataItemTableView = sorting("Code") ORDER(Ascending);
                column(No_POSPaymentMethodForeignVoucher; POSPaymentMethodVoucher."Code")
                {
                }
                column(RegisterNo_POSPaymentMethodForeignVoucher; "NPR POS Unit"."No.")
                {
                }
                column(Description_POSPaymentMethodForeignVoucher; POSPaymentMethodVoucher.Description)
                {
                }
                column(Amountinauditroll_POSPaymentMethodForeignVoucher; POSPaymentMethodVoucher."Amount in POS")
                {
                }

                trigger OnPreDataItem()
                begin
                    POSPaymentMethod.COPYFILTER("Date Filter", POSPaymentMethodVoucher."Date Filter");
                    POSPaymentMethod.COPYFILTER("POS Unit Filter", POSPaymentMethodVoucher."POS Unit Filter");
                    SetRange("Processing Type", "Processing Type"::"FOREIGN VOUCHER");
                end;
            }
            dataitem(POSPaymentMethodEFT; "NPR POS Payment Method")
            {
                CalcFields = "Amount in POS";
                DataItemTableView = sorting("Code")
                                ORDER(Ascending);
                column(No_POSPaymentMethodEFT; POSPaymentMethodEFT."Code")
                {
                }
                column(RegisterNo_POSPaymentMethodEFT; "NPR POS Unit"."No.")
                {
                }
                column(Description_POSPaymentMethodEFT; POSPaymentMethodEFT.Description)
                {
                }
                column(Amountinauditroll_POSPaymentMethodEFT; POSPaymentMethodEFT."Amount in POS")
                {
                }

                trigger OnPreDataItem()
                begin
                    POSPaymentMethod.COPYFILTER("Date Filter", POSPaymentMethodEFT."Date Filter");
                    POSPaymentMethod.COPYFILTER("POS Unit Filter", POSPaymentMethodEFT."POS Unit Filter");
                    SetRange("Processing Type", "Processing Type"::"EFT");
                end;
            }
            dataitem(POSPaymentMethodCheck; "NPR POS Payment Method")
            {
                CalcFields = "Amount in POS";
                DataItemTableView = sorting(Code) ORDER(Ascending);
                column(No_POSPaymentMethodCheck; POSPaymentMethodCheck."Code")
                {
                }
                column(RegisterNo_POSPaymentMethodCheck; "NPR POS Unit"."No.")
                {
                }
                column(Description_POSPaymentMethodCheck; POSPaymentMethodCheck.Description)
                {
                }
                column(Amountinauditroll_POSPaymentMethodCheck; POSPaymentMethodCheck."Amount in POS")
                {
                }

                trigger OnPreDataItem()
                begin
                    POSPaymentMethod.COPYFILTER("Date Filter", POSPaymentMethodCheck."Date Filter");
                    POSPaymentMethod.COPYFILTER("POS Unit Filter", POSPaymentMethodCheck."POS Unit Filter");
                    SetRange("Processing Type", "Processing Type"::"CHECK");
                end;
            }
            dataitem(PaymentMethodPayout; "NPR POS Payment Method")
            {
                CalcFields = "Amount in POS";
                DataItemTableView = sorting("Code") ORDER(Ascending);
                column(No_PaymentMethodPayout; PaymentMethodPayout."Code")
                {
                }
                column(RegisterNo_PaymentMethodPayout; "NPR POS Unit"."No.")
                {
                }
                column(Description_PaymentMethodPayout; PaymentMethodPayout.Description)
                {
                }
                column(Amountinauditroll_PaymentMethodPayout; PaymentMethodPayout."Amount in POS")
                {
                }

                trigger OnPreDataItem()
                begin
                    POSPaymentMethod.COPYFILTER("Date Filter", PaymentMethodPayout."Date Filter");
                    POSPaymentMethod.COPYFILTER("POS Unit Filter", PaymentMethodPayout."POS Unit Filter");
                    SetRange("Processing Type", "Processing Type"::"PAYOUT");
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(CompareDay; Compare_Day)
                    {
                        Caption = 'Compare To Day';
                        ToolTip = 'Specifies the value of the Compare To Day field';
                        ApplicationArea = All;
                    }
                    field(compareNearestDate; Compare_Nearest_Date)
                    {
                        Caption = 'Compare Nearest Date';
                        ToolTip = 'Specifies the value of the Compare Nearest Date field';
                        ApplicationArea = All;
                    }
                    field("Show Adjusted Cost"; ShowAdj)
                    {
                        Caption = 'Show Adjusted Cost';
                        ToolTip = 'Specifies the value of the ShowAdj field';
                        ApplicationArea = All;
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

    trigger OnInitReport()
    begin
        ShowAdj := false;
    end;



    var
        StartDate: Date;
        EndDate: Date;
        PaymentTypePOS: Record "NPR POS Payment Method";
        Total: Decimal;
        DebitAmt: Decimal;
        OrdinarySale: Decimal;
        NormalSaleWithoutSalesperson: Decimal;
        DebitSaleWithoutSalesperson: Decimal;
        TotalSaleWithoutSalesperson: Decimal;
        ekspWithoutSalesperson: Decimal;
        ekspTotal: Decimal;
        Compare_Day: Boolean;
        Compare_Nearest_Date: Boolean;
        WeekDay: Integer;
        Week: Integer;
        Year: Integer;
        AverageAmt: Decimal;
        Eksp1: Decimal;
        Debit1: Decimal;
        Sale1: Decimal;
        Eksp3: Decimal;
        Sale3: Decimal;
        Credit3: Decimal;
        PaymentTypePOSTotal: Record "NPR POS Payment Method";
        Profit_LCY2_Amt: Decimal;
        Profit_LCY2_Pct: Decimal;
        SalesExVatLYr: Decimal;
        NoOfItemsInAuditRoll: Decimal;
        POSEntry: Record "NPR POS Entry";
        NoOfItemsInAuditRollLastYr: Decimal;
        POSEntryLastYr: Record "NPR POS Entry";
        ILEntry: Record "Item Ledger Entry";
        SumOfILELineCurrentYear: Decimal;
        SumOfILELinePreviousYear: Integer;
        Profit_LCY3_Amt: Decimal;
        Profit_LCY3_Pct: Decimal;
        ShowAdj: Boolean;
        DebitAmtQuery: Query "NPR Sales Ticket Statistics";
        varDebitSales: Decimal;
        ArchDocument: Record "NPR NpCs Arch. Document";
        varDebitSalesLastYr: Decimal;

    local procedure CalcPCT(Tal1: Decimal; Tal2: Decimal): Decimal
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

