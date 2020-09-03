report 6014409 "NPR Sales Ticket Stat."
{
    // NPR70.00.00.00/LS CASE 156110 : Convert Report to NAV 2013
    // NPR4.16/TR/20140723  CASE 184250 : Report layout edited such that it fits a receip (epson 4). Report created for previewing - but does also fit receip size if printed on epson.
    // NPR4.16/TS/20151020  CASE 222088 Changed Layout on Reports
    // NPR5.26/LS/20151202  CASE 224592 : Corrected Report + Layout/Figures/labels
    //                                       Changed Report name/caption/label name from Sale Statistics to Sales Ticket Statistics
    //                                       This is the receipt Layout
    // NPR5.30/JLK /20170127  CASE 228985 Modified Item Lines, Item Lines/Sales Qty and Percentage calculation
    // NPR5.31/JLK /20170411  CASE 271517 Added Register Filter
    // NPR5.35/KENU/20170803  CASE 285732 Used "Register Filter" instead of "Register No."
    // NPR5.35/KENU/20170824  CASE 287897 Modified calculation
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.40/TSA /20180327 CASE 301544 Dereferenced cu 6014452 from OnInitReport and OnPreReport
    // NPR5.42/BHR /20180516 CASE 315147 Set datefilter to curent workdate
    // NPR5.55/YAHA/20191129 CASE 376369 Addnig a new section called Adjust Cost
    // NPR5.55/ZESO/20200505 CASE 398134 Calculate Click and Collect Sales + Remove from Debit Sale Value
    // NPR5.55/ANPA/20200505 CASE 402923 Removed ':' from ProfitExcVat_Caption
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Ticket Statistics.rdlc';

    Caption = 'Sale Statistics';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(PaymentTypePeriod; "NPR Payment Type POS")
        {
            CalcFields = "Normal Sale in Audit Roll", "Debit Sale in Audit Roll", "No. of Sales in Audit Roll", "Cost Amount in Audit Roll", "No. of Items in Audit Roll", "No. of Sale Lines in Aud. Roll", "No. of Items in Audit Debit", "No. of Item Lines in Aud. Deb.", "No. of Deb. Sales in Aud. Roll", "Norm. Sales in Audit Excl. VAT", "Debit Sales in Audit Excl. VAT", "Debit Cost Amount Audit Roll";
            RequestFilterFields = "Date Filter", "Register Filter", "Salesperson Filter";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(RegisterFilter_Periode; GetFilter("Register Filter"))
            {
            }
            column(DateFilter_Periode; GetFilter("Date Filter"))
            {
            }
            column(No_PaymentTypePeriod; PaymentTypePeriod."No.")
            {
            }
            column(SalesQty1_PaymentTypePeriod; PaymentTypePeriod."No. of Sales in Audit Roll" + PaymentTypePeriod."No. of Deb. Sales in Aud. Roll")
            {
            }
            column(Turnover1_PaymentTypePeriod; PaymentTypePeriod."Normal Sale in Audit Roll")
            {
            }
            column(DebitSales1_PaymentTypePeriod; PaymentTypePeriod."Debit Sale in Audit Roll" - varDebitSales)
            {
            }
            column(SalesQty2_PaymentTypePeriod; PaymentLastYr."No. of Sales in Audit Roll" + PaymentLastYr."No. of Deb. Sales in Aud. Roll")
            {
            }
            column(Turnover2_PaymentTypePeriod; PaymentLastYr."Normal Sale in Audit Roll")
            {
            }
            column(DebitSales2_PaymentTypePeriod; PaymentLastYr."Debit Sale in Audit Roll" - varDebitSalesLastYr)
            {
            }
            column(SalesTotal1_PaymentTypePeriod; PaymentTypePeriod."Normal Sale in Audit Roll" + (PaymentTypePeriod."Debit Sale in Audit Roll" - varDebitSales))
            {
            }
            column(SalesTotal2_PaymentTypePeriod; PaymentLastYr."Normal Sale in Audit Roll" + (PaymentLastYr."Debit Sale in Audit Roll" - varDebitSalesLastYr))
            {
            }
            column(ItemCost1_PaymentTypePeriod; PaymentTypePeriod."Cost Amount in Audit Roll" + PaymentTypePeriod."Debit Cost Amount Audit Roll")
            {
            }
            column(ItemCost2_PaymentTypePeriod; PaymentLastYr."Cost Amount in Audit Roll" + PaymentLastYr."Debit Cost Amount Audit Roll")
            {
            }
            column(SalesTotalExcVAT_PaymentTypePeriod; ("Norm. Sales in Audit Excl. VAT" + "Debit Sales in Audit Excl. VAT"))
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
            column(Profit_LCY1_PaymentTypePeriod; "Pct."(("Norm. Sales in Audit Excl. VAT" + "Debit Sales in Audit Excl. VAT") - ("Cost Amount in Audit Roll" + "Debit Cost Amount Audit Roll"), ("Norm. Sales in Audit Excl. VAT" + "Debit Sales in Audit Excl. VAT")))
            {
            }
            column(Profit_LCYAmt1_PaymentTypePeriod; ("Norm. Sales in Audit Excl. VAT" + "Debit Sales in Audit Excl. VAT") - ("Cost Amount in Audit Roll" + "Debit Cost Amount Audit Roll"))
            {
            }
            column(Profit_LCY2_PaymentTypePeriod; Profit_LCY2_Amt)
            {
            }
            column(Profit_LCY2Pct_PaymentTypePeriod; Profit_LCY2_Pct)
            {
            }
            column(Turnover_avg1_PaymentTypePeriod; Divider(("Normal Sale in Audit Roll" + "Debit Sale in Audit Roll" - varDebitSales), ("No. of Sales in Audit Roll" + "No. of Deb. Sales in Aud. Roll")))
            {
            }
            column(Turnover_avg2_PaymentTypePeriod; Divider((PaymentLastYr."Normal Sale in Audit Roll" + PaymentLastYr."Debit Sale in Audit Roll" - varDebitSalesLastYr), (PaymentLastYr."No. of Sales in Audit Roll" + PaymentLastYr."No. of Deb. Sales in Aud. Roll")))
            {
            }
            column(ItemQty1_PaymentTypePeriod; "No. of Items in Audit Roll" + "No. of Items in Audit Debit")
            {
            }
            column(ItemQty2_PaymentTypePeriod; PaymentLastYr."No. of Items in Audit Roll" + PaymentLastYr."No. of Items in Audit Debit")
            {
            }
            column(ItemQtySale1_PaymentTypePeriod; Divider(("No. of Items in Audit Roll" + "No. of Items in Audit Debit"), ("No. of Sales in Audit Roll" + "No. of Deb. Sales in Aud. Roll")))
            {
            }
            column(ItemQtySale2_PaymentTypePeriod; Divider((PaymentLastYr."No. of Items in Audit Roll" + PaymentLastYr."No. of Items in Audit Debit"), (PaymentLastYr."No. of Sales in Audit Roll" + PaymentLastYr."No. of Deb. Sales in Aud. Roll")))
            {
            }
            column(ItemLines1_PaymentTypePeriod; NoOfItemsInAuditRoll)
            {
            }
            column(ItemLines2_PaymentTypePeriod; NoOfItemsInAuditRollLastYr)
            {
            }
            column(ItemQtyLine1_PaymentTypePeriod; Divider(NoOfItemsInAuditRoll, (PaymentTypePeriod."No. of Sales in Audit Roll" + PaymentTypePeriod."No. of Deb. Sales in Aud. Roll")))
            {
            }
            column(ItemQtyLine2_PaymentTypePeriod; Divider(NoOfItemsInAuditRollLastYr, (PaymentLastYr."No. of Sales in Audit Roll" + PaymentLastYr."No. of Deb. Sales in Aud. Roll")))
            {
            }
            column(ItemCost1_Adj; SumOfILELineCurrentYear * -1)
            {
            }
            column(ItemCost2_Adj; SumOfILELinePreviousYear * -1)
            {
            }
            column(SalesTotalExcVAT_PaymentTypePeriod_Adj; ("Norm. Sales in Audit Excl. VAT" + "Debit Sales in Audit Excl. VAT"))
            {
            }
            column(SalesExVatLYr_Adj; SalesExVatLYr)
            {
            }
            column(Profit_LCY1_PaymentTypePeriod_Adj; "Pct."(("Norm. Sales in Audit Excl. VAT" + "Debit Sales in Audit Excl. VAT") - (SumOfILELineCurrentYear * -1), ("Norm. Sales in Audit Excl. VAT" + "Debit Sales in Audit Excl. VAT")))
            {
            }
            column(Profit_LCYAmt1_PaymentTypePeriod_Adj; ("Norm. Sales in Audit Excl. VAT" + "Debit Sales in Audit Excl. VAT") - (SumOfILELineCurrentYear * -1))
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
            dataitem(PaymentLastYr; "NPR Payment Type POS")
            {
                CalcFields = "Normal Sale in Audit Roll", "Debit Sale in Audit Roll", "No. of Sales in Audit Roll", "Cost Amount in Audit Roll", "No. of Items in Audit Roll", "No. of Sale Lines in Aud. Roll", "No. of Items in Audit Debit", "No. of Item Lines in Aud. Deb.", "No. of Deb. Sales in Aud. Roll", "Norm. Sales in Audit Excl. VAT", "Debit Sales in Audit Excl. VAT", "Debit Cost Amount Audit Roll";
                DataItemTableView = SORTING("No.", "Register No.");
                column(No_PaymentLastYr; PaymentLastYr."No.")
                {
                }
                column(DateFilter_PaymentLastYr; GetFilter("Date Filter"))
                {
                }

                trigger OnAfterGetRecord()
                begin
                    //-NPK1.01
                    //Profit_LCY2_Amt := "Pct."((PaymentLastYr."Norm sales in audit ex VAT"+PaymentLastYr."Debit sales in audit ex VAT")-(PaymentLastYr."Cost amount in audit roll"+PaymentLastYr."Debit cost amount audit roll")
                    //,(PaymentLastYr."Norm sales in audit ex VAT"+PaymentLastYr."Debit sales in audit ex VAT"));

                    Profit_LCY2_Amt := (PaymentLastYr."Norm. Sales in Audit Excl. VAT" + PaymentLastYr."Debit Sales in Audit Excl. VAT") - (PaymentLastYr."Cost Amount in Audit Roll" + PaymentLastYr."Debit Cost Amount Audit Roll");
                    //-NPR5.55 [376369]
                    Profit_LCY3_Amt := (PaymentLastYr."Norm. Sales in Audit Excl. VAT" + PaymentLastYr."Debit Sales in Audit Excl. VAT") - (PaymentLastYr."Cost Amount in Audit Roll" + PaymentLastYr."Debit Cost Amount Audit Roll");
                    //+NPR5.55 [376369]


                    Profit_LCY2_Pct := "Pct."((PaymentLastYr."Norm. Sales in Audit Excl. VAT" + PaymentLastYr."Debit Sales in Audit Excl. VAT") - (PaymentLastYr."Cost Amount in Audit Roll" + PaymentLastYr."Debit Cost Amount Audit Roll")
                    , (PaymentLastYr."Norm. Sales in Audit Excl. VAT" + PaymentLastYr."Debit Sales in Audit Excl. VAT"));

                    //-NPR5.55 [376369]
                    Profit_LCY3_Amt := "Pct."((PaymentLastYr."Norm. Sales in Audit Excl. VAT" + PaymentLastYr."Debit Sales in Audit Excl. VAT") - (PaymentLastYr."Cost Amount in Audit Roll" + PaymentLastYr."Debit Cost Amount Audit Roll")
                    , (PaymentLastYr."Norm. Sales in Audit Excl. VAT" + PaymentLastYr."Debit Sales in Audit Excl. VAT"));
                    //+NPR5.55 [376369]



                    SalesExVatLYr := (PaymentLastYr."Norm. Sales in Audit Excl. VAT" + PaymentLastYr."Debit Sales in Audit Excl. VAT");
                    //+NPK1.01

                    //-NPR5.30
                    Clear(NoOfItemsInAuditRollLastYr);
                    AuditRollLastYr.SetFilter("Sale Date", GetFilter("Date Filter"));
                    //-NPR5.31
                    //AuditRollLastYr.SETFILTER("Register No.","Register No.");
                    //-NPR5.32
                    AuditRollLastYr.SetFilter("Register No.", GetFilter("Register Filter"));
                    //+NPR5.32
                    //-NPR5.31
                    AuditRollLastYr.SetRange(Type, AuditRoll.Type::Item);
                    NoOfItemsInAuditRollLastYr := AuditRollLastYr.Count;
                    //+NPR5.30
                    //-NPR5.55 [398134]
                    varDebitSalesLastYr := 0;

                    DebitAmtQuery.SetRange(Sale_Date_Filter, StartDate, EndDate);
                    DebitAmtQuery.SetFilter(Register_No_Filter, GetFilter("Register Filter"));
                    DebitAmtQuery.SetRange(Sale_Type_Filter, 2);
                    DebitAmtQuery.SetRange(Type_Filter, 1);
                    DebitAmtQuery.SetFilter(Gift_voucher_ref_Filter, '');
                    DebitAmtQuery.SetFilter(Salesperson_Code_Filter, GetFilter("Salesperson Filter"));
                    DebitAmtQuery.SetFilter(Closing_Time_Filter, GetFilter("End Time Filter"));
                    DebitAmtQuery.SetFilter(Shortcut_Dim_1_Code_Filter, GetFilter("Global Dimension Code 1 Filter"));
                    DebitAmtQuery.SetFilter(Shortcut_Dim_2_Code_Filter, GetFilter("Global Dimension Code 2 Filter"));
                    DebitAmtQuery.SetFilter(Sales_Ticket_No_Filter, GetFilter("Receipt Filter"));


                    DebitAmtQuery.Open;
                    while DebitAmtQuery.Read do begin
                        ArchDocument.Reset;
                        ArchDocument.SetRange("Delivery Document Type", ArchDocument."Delivery Document Type"::"POS Entry");
                        ArchDocument.SetRange("Delivery Document No.", DebitAmtQuery.Sales_Ticket_No);
                        if ArchDocument.FindFirst then
                            varDebitSalesLastYr += DebitAmtQuery.Amount_Including_VAT;
                    end;
                    //-NPR5.55 [398134]
                end;

                trigger OnPreDataItem()
                begin
                    CopyFilters(PaymentTypePeriod);
                    if not CompareDay then begin
                        StartDate := CalcDate('<-1Y>', PaymentTypePeriod.GetRangeMin("Date Filter"));
                        EndDate := CalcDate('<-1Y>', PaymentTypePeriod.GetRangeMax("Date Filter"));
                    end
                    else begin
                        StartDate := PaymentTypePeriod.GetRangeMin("Date Filter");
                        EndDate := PaymentTypePeriod.GetRangeMax("Date Filter");
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
                    end;
                    SetRange("Date Filter", StartDate, EndDate);
                end;
            }

            trigger OnAfterGetRecord()
            begin

                //-NPR5.30
                Clear(NoOfItemsInAuditRoll);
                AuditRoll.SetFilter("Sale Date", GetFilter("Date Filter"));
                //-NPR5.31
                AuditRoll.SetFilter("Register No.", GetFilter("Register Filter"));
                //-NPR5.31
                AuditRoll.SetRange(Type, AuditRoll.Type::Item);
                NoOfItemsInAuditRoll := AuditRoll.Count;
                //+NPR5.30
                //-NPR5.55 [398134]
                varDebitSales := 0;
                if PaymentTypePeriod.GetFilter("Date Filter") = '' then
                    DebitAmtQuery.SetFilter(Sale_Date_Filter, '%1', WorkDate)
                else
                    DebitAmtQuery.SetFilter(Sale_Date_Filter, GetFilter("Date Filter"));
                DebitAmtQuery.SetFilter(Register_No_Filter, GetFilter("Register Filter"));
                DebitAmtQuery.SetRange(Sale_Type_Filter, 2);
                DebitAmtQuery.SetRange(Type_Filter, 1);
                DebitAmtQuery.SetFilter(Gift_voucher_ref_Filter, '');
                DebitAmtQuery.SetFilter(Salesperson_Code_Filter, GetFilter("Salesperson Filter"));
                DebitAmtQuery.SetFilter(Closing_Time_Filter, GetFilter("End Time Filter"));
                DebitAmtQuery.SetFilter(Shortcut_Dim_1_Code_Filter, GetFilter("Global Dimension Code 1 Filter"));
                DebitAmtQuery.SetFilter(Shortcut_Dim_2_Code_Filter, GetFilter("Global Dimension Code 2 Filter"));
                DebitAmtQuery.SetFilter(Sales_Ticket_No_Filter, GetFilter("Receipt Filter"));


                DebitAmtQuery.Open;
                while DebitAmtQuery.Read do begin
                    ArchDocument.Reset;
                    ArchDocument.SetRange("Delivery Document Type", ArchDocument."Delivery Document Type"::"POS Entry");
                    ArchDocument.SetRange("Delivery Document No.", DebitAmtQuery.Sales_Ticket_No);
                    if ArchDocument.FindFirst then
                        varDebitSales += DebitAmtQuery.Amount_Including_VAT;
                end;
                //-NPR5.55 [398134]
            end;

            trigger OnPreDataItem()
            begin
                if PaymentTypePeriod.GetFilter("Date Filter") = '' then
                    //-NPR5.42 [315147]
                    //ERROR(Trans0001);
                    PaymentTypePeriod.SetFilter("Date Filter", '%1', WorkDate);
                //+NPR5.42 [315147]

                //-NPR5.55 [376369]
                StartDateAdj := (PaymentTypePeriod.GetRangeMin("Date Filter"));
                EndDate := (PaymentTypePeriod.GetRangeMax("Date Filter"));

                ILEntry.SetFilter("Posting Date", '%1..%2', PaymentTypePeriod.GetRangeMin("Date Filter"), PaymentTypePeriod.GetRangeMax("Date Filter"));
                ILEntry.SetRange("Entry Type", ILEntry."Entry Type"::Sale);
                ILEntry.SetRange("Document Type", ILEntry."Document Type"::" ");

                if ILEntry.FindSet then begin
                    repeat
                        ILEntry.CalcFields("Cost Amount (Actual)");
                        SumOfILELineCurrentYear += ILEntry."Cost Amount (Actual)";
                    until ILEntry.Next = 0;
                end;
                //+NPR5.55 [376369]
            end;
        }
        dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
        {
            DataItemTableView = SORTING(Code);
            column(Code_SalespersonPurchaser; "Salesperson/Purchaser".Code)
            {
            }
            column(Name_SalespersonPurchaser; "Salesperson/Purchaser".Name)
            {
            }
            column(Eksp1_SalespersonPurchaser; (PaymentTypePOS."No. of Sales in Audit Roll" + PaymentTypePOS."No. of Deb. Sales in Aud. Roll"))
            {
            }
            column(Eksp1_PaymentTypePOS; Eksp1)
            {
            }
            column(Sale1_SalespersonPurchaser; PaymentTypePOS."Normal Sale in Audit Roll")
            {
            }
            column(Sale1_PaymentTypePOS; Sale1)
            {
            }
            column(AverageAmt_SalespersonPurchaser; AverageAmt)
            {
            }
            column(Credit1_SalespersonPurchaser; PaymentTypePOS."Debit Sale in Audit Roll")
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
                PaymentTypePOS.CalcFields("Debit Sale in Audit Roll", "Normal Sale in Audit Roll", "No. of Sales in Audit Roll"
                , "No. of Deb. Sales in Aud. Roll");
                OrdinarySale := PaymentTypePOS."Normal Sale in Audit Roll";
                DebitAmt := PaymentTypePOS."Debit Sale in Audit Roll";
                Total := OrdinarySale + DebitAmt;
                ekspTotal := (PaymentTypePOS."No. of Sales in Audit Roll" + PaymentTypePOS."No. of Deb. Sales in Aud. Roll");


                //-NPR70.00.00.00/LS
                Eksp1 := 0;
                Debit1 := 0;
                Sale1 := 0;
                Eksp1 := (PaymentTypePOS."No. of Sales in Audit Roll" + PaymentTypePOS."No. of Deb. Sales in Aud. Roll");
                Debit1 := PaymentTypePOS."Debit Sale in Audit Roll";
                Sale1 := PaymentTypePOS."Normal Sale in Audit Roll";

                if PaymentTypePOS."No. of Sales in Audit Roll" <> 0 then begin
                    //-NPR5.35
                    //AverageAmt := PaymentTypePOS."Normal Sale in Audit Roll" / PaymentTypePOS."No. of Sales in Audit Roll";
                    AverageAmt := Total / Eksp1;
                    //+NPR5.35
                end;

                NormalSaleWithoutSalesperson := 0;
                DebitSaleWithoutSalesperson := 0;
                TotalSaleWithoutSalesperson := 0;
                ekspWithoutSalesperson := 0;

                PaymentTypePOSTotal.Reset;
                Clear(PaymentTypePOSTotal);

                PaymentTypePOSTotal.SetRange("Salesperson Filter", '');
                PaymentTypePOSTotal.CalcFields("Debit Sale in Audit Roll", "Normal Sale in Audit Roll", "No. of Sales in Audit Roll", "No. of Deb. Sales in Aud. Roll");
                NormalSaleWithoutSalesperson := PaymentTypePOSTotal."Normal Sale in Audit Roll";
                DebitSaleWithoutSalesperson := PaymentTypePOSTotal."Debit Sale in Audit Roll";
                TotalSaleWithoutSalesperson := NormalSaleWithoutSalesperson + DebitSaleWithoutSalesperson;
                ekspWithoutSalesperson := PaymentTypePOSTotal."No. of Sales in Audit Roll" + PaymentTypePOSTotal."No. of Deb. Sales in Aud. Roll";

                Eksp3 := ekspWithoutSalesperson + ekspTotal;
                Sale3 := OrdinarySale + NormalSaleWithoutSalesperson;
                Credit3 := DebitAmt + DebitSaleWithoutSalesperson;
                //+NPR70.00.00.00/LS
            end;

            trigger OnPreDataItem()
            begin
                PaymentTypePeriod.CopyFilter("Date Filter", PaymentTypePOS."Date Filter");
                PaymentTypePeriod.CopyFilter("Register Filter", PaymentTypePOS."Register Filter");
                //-NPR5.39
                //CurrReport.CREATETOTALS(OrdinarySale,DebitAmt,Total,ekspTotal);
                //+CNPR5.39
                Clear(Total);
                Clear(OrdinarySale);
                Clear(DebitAmt);
                Clear(ekspTotal);
            end;
        }
        dataitem("Payment Type POS"; "NPR Payment Type POS")
        {
            CalcFields = "Amount in Audit Roll";
            DataItemTableView = SORTING("No.", "Register No.") ORDER(Ascending);
            column(No_PaymentTypePOS; "Payment Type POS"."No.")
            {
            }
            column(RegisterNo_PaymentTypePOS; "Payment Type POS"."Register No.")
            {
            }
            column(Description_PaymentTypePOS; "Payment Type POS".Description)
            {
            }
            column(Amountinauditroll_PaymentTypePOS; "Payment Type POS"."Amount in Audit Roll")
            {
            }

            trigger OnPreDataItem()
            begin
                PaymentTypePeriod.CopyFilter("Date Filter", "Payment Type POS"."Date Filter");
                PaymentTypePeriod.CopyFilter("Register Filter", "Payment Type POS"."Register Filter");

                SetRange("Processing Type", "Processing Type"::"Foreign Currency");
                CalcFields("Amount in Audit Roll");
            end;
        }
        dataitem(GiftVoucher; "NPR Payment Type POS")
        {
            CalcFields = "Amount in Audit Roll";
            DataItemTableView = SORTING("No.", "Register No.") ORDER(Ascending);
            column(No_GiftVoucher; GiftVoucher."No.")
            {
            }
            column(RegisterNo_GiftVoucher; GiftVoucher."Register No.")
            {
            }
            column(Description_GiftVoucher; GiftVoucher.Description)
            {
            }
            column(Amountinauditroll_GiftVoucher; GiftVoucher."Amount in Audit Roll")
            {
            }

            trigger OnPreDataItem()
            begin
                PaymentTypePeriod.CopyFilter("Date Filter", GiftVoucher."Date Filter");
                PaymentTypePeriod.CopyFilter("Register Filter", GiftVoucher."Register Filter");
                SetRange("Processing Type", "Processing Type"::"Gift Voucher");
            end;
        }
        dataitem(CreditVoucher; "NPR Payment Type POS")
        {
            CalcFields = "Amount in Audit Roll";
            DataItemTableView = SORTING("No.", "Register No.") ORDER(Ascending);
            column(No_CreditVoucher; CreditVoucher."No.")
            {
            }
            column(RegisterNo_CreditVoucher; CreditVoucher."Register No.")
            {
            }
            column(Description_CreditVoucher; CreditVoucher.Description)
            {
            }
            column(Amountinauditroll_CreditVoucher; CreditVoucher."Amount in Audit Roll")
            {
            }

            trigger OnPreDataItem()
            begin
                PaymentTypePeriod.CopyFilter("Date Filter", CreditVoucher."Date Filter");
                PaymentTypePeriod.CopyFilter("Register Filter", CreditVoucher."Register Filter");
                SetRange("Processing Type", "Processing Type"::"Credit Voucher");
            end;
        }
        dataitem(PaymentTypePOS4; "NPR Payment Type POS")
        {
            CalcFields = "Amount in Audit Roll";
            DataItemTableView = SORTING("No.", "Register No.") ORDER(Ascending);
            column(No_PaymentTypePOS4; PaymentTypePOS4."No.")
            {
            }
            column(RegisterNo_PaymentTypePOS4; PaymentTypePOS4."Register No.")
            {
            }
            column(Description_PaymentTypePOS4; PaymentTypePOS4.Description)
            {
            }
            column(Amountinauditroll_PaymentTypePOS4; PaymentTypePOS4."Amount in Audit Roll")
            {
            }

            trigger OnPreDataItem()
            begin
                PaymentTypePeriod.CopyFilter("Date Filter", PaymentTypePOS4."Date Filter");
                PaymentTypePeriod.CopyFilter("Register Filter", PaymentTypePOS4."Register Filter");
                SetRange("Processing Type", "Processing Type"::"Terminal Card");
            end;
        }
        dataitem(PaymentTypePOS5; "NPR Payment Type POS")
        {
            CalcFields = "Amount in Audit Roll";
            DataItemTableView = SORTING("No.", "Register No.") ORDER(Ascending);
            column(No_PaymentTypePOS5; PaymentTypePOS5."No.")
            {
            }
            column(RegisterNo_PaymentTypePOS5; PaymentTypePOS5."Register No.")
            {
            }
            column(Description_PaymentTypePOS5; PaymentTypePOS5.Description)
            {
            }
            column(Amountinauditroll_PaymentTypePOS5; PaymentTypePOS5."Amount in Audit Roll")
            {
            }

            trigger OnPreDataItem()
            begin
                PaymentTypePeriod.CopyFilter("Date Filter", PaymentTypePOS5."Date Filter");
                PaymentTypePeriod.CopyFilter("Register Filter", PaymentTypePOS5."Register Filter");
                SetRange("Processing Type", "Processing Type"::"Other Credit Cards");
            end;
        }
        dataitem(PaymentTypePOS6; "NPR Payment Type POS")
        {
            CalcFields = "Amount in Audit Roll";
            DataItemTableView = SORTING("No.", "Register No.") ORDER(Ascending);
            column(No_PaymentTypePOS6; PaymentTypePOS6."No.")
            {
            }
            column(RegisterNo_PaymentTypePOS6; PaymentTypePOS6."Register No.")
            {
            }
            column(Description_PaymentTypePOS6; PaymentTypePOS6.Description)
            {
            }
            column(Amountinauditroll_PaymentTypePOS6; PaymentTypePOS6."Amount in Audit Roll")
            {
            }

            trigger OnPreDataItem()
            begin
                PaymentTypePeriod.CopyFilter("Date Filter", PaymentTypePOS6."Date Filter");
                PaymentTypePeriod.CopyFilter("Register Filter", PaymentTypePOS6."Register Filter");
                SetRange("Processing Type", "Processing Type"::"Manual Card");
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Control6150614)
                {
                    ShowCaption = false;
                    field(CompareDay; CompareDay)
                    {
                        Caption = 'Compare To Day';
                    }
                    field(compareNearestDate; CompareNearestDate)
                    {
                        Caption = 'Compare Nearest Date';
                    }
                    field("Show Adjusted Cost"; ShowAdj)
                    {
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
        Betalt_med_Caption = 'Payment Type:';
        Betalt_med_Gavekort = 'Payment Type:';
        Betalt_med_Tilgod = 'Payment Type:';
        Betalt_med_Dankort = 'Payment Type:';
        Betalt_med_Teleterminal = 'Payment Type:';
        Manuelle_kort_ = 'Payment Type:';
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
        //-NPR5.55 [376369]
        ShowAdj := false;
        //+NPR5.55 [376369]
    end;

    trigger OnPreReport()
    begin
        //-NPR5.42 [315147]
        //IF PaymentTypePeriod.GETFILTER("Date Filter")='' THEN
        //    ERROR(Trans0001);
        //+NPR5.42 [315147]
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);

        //-NPR5.39
        // Object.SETRANGE(ID, 6014409);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39
    end;

    var
        CompanyInformation: Record "Company Information";
        StartDate: Date;
        EndDate: Date;
        PaymentTypePOS: Record "NPR Payment Type POS";
        Total: Decimal;
        DebitAmt: Decimal;
        OrdinarySale: Decimal;
        NormalSaleWithoutSalesperson: Decimal;
        DebitSaleWithoutSalesperson: Decimal;
        TotalSaleWithoutSalesperson: Decimal;
        ekspWithoutSalesperson: Decimal;
        ekspTotal: Decimal;
        CompareDay: Boolean;
        CompareNearestDate: Boolean;
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
        PaymentTypePOSTotal: Record "NPR Payment Type POS";
        Profit_LCY2_Amt: Decimal;
        Profit_LCY2_Pct: Decimal;
        SalesExVatLYr: Decimal;
        NoOfItemsInAuditRoll: Decimal;
        AuditRoll: Record "NPR Audit Roll";
        NoOfItemsInAuditRollLastYr: Decimal;
        AuditRollLastYr: Record "NPR Audit Roll";
        ILEntry: Record "Item Ledger Entry";
        SumOfILECost: Decimal;
        SumOfILELineCurrentYear: Decimal;
        SumOfILELinePreviousYear: Integer;
        Profit_LCY3_Amt: Decimal;
        Profit_LCY3_Pct: Decimal;
        ShowAdj: Boolean;
        StartDateAdj: Date;
        EndDateAdj: Date;
        DebitAmtQuery: Query "NPR ClickNCollectSales_Stats";
        varDebitSales: Decimal;
        ArchDocument: Record "NPR NpCs Arch. Document";
        varDebitSalesLastYr: Decimal;
        Trans0001: Label 'Please specify date range!';

    local procedure "Pct."(Tal1: Decimal; Tal2: Decimal): Decimal
    begin
        if Tal2 = 0 then
            exit(0);
        //-NPR5.30
        //EXIT(ROUND(Tal1 / Tal2 * 100,0.1));
        exit(Tal1 / Tal2 * 100);
        //+NPR5.30
    end;

    procedure Divider("Tal 1": Decimal; "Tal 2": Decimal): Decimal
    begin
        if "Tal 2" = 0 then
            exit(0);
        exit(("Tal 1" / "Tal 2"));
    end;
}

