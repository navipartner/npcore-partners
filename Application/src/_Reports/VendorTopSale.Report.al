report 6014426 "NPR Vendor Top/Sale"
{
    // NPR70.00.00.00/LS CASE 176194 : Convert Report to Nav 2013
    // NPR4.16/TS/20150901  CASE 221897 Changed Labels on Reports
    // NPR4.16/LS/20151110  CASE 221733 Change Report CaptionML of English from Creditor Top/Sale to Vendor Top/Sale
    // NPR5.23/JDH /20160505 CASE 240735 Changed dan caption that made Powershell crash
    // NPR5.38/JLK /20171106 CASE 282571 Added Vendor Filters on Data Item and Layout
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.43/ZESO/20180607 CASE 317517 Corrected bug
    // NPR5.49/BHR /20190207 CASE 343119 Corrected report as per OMA
    // NPR5.54/YAHA/20200306 CASE 394856 Set logo visibility set to false
    // NPR5.55/ANPA/20200521  CASE 388517 Add quantity and filter to item group
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Vendor TopSale.rdlc';

    Caption = 'Vendor Top/Sale';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            CalcFields = "NPR Sales (LCY)", "Balance (LCY)", "NPR COGS (LCY)";
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Date Filter", "Global Dimension 1 Filter";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Picture_CompanyInfo; CompanyInfo.Picture)
            {
            }
            column(VendorDateFilter; StrSubstNo(Text10600001, VendorDateFilter))
            {
            }
            column(ShowTypeFilter; StrSubstNo(Text10600002, ShowType))
            {
            }
            column(Getfilters; Vendor.TableCaption + ':  ' + GetFilters)
            {
            }
            dataitem("<Kreditorsidsteaar>"; Vendor)
            {
                CalcFields = "NPR Sales (LCY)", "Balance (LCY)", "NPR COGS (LCY)";
                DataItemLink = "No." = FIELD("No.");
                DataItemTableView = SORTING("No.");

                trigger OnAfterGetRecord()
                begin
                    if ("NPR Sales (LCY)" = 0) and ("Balance (LCY)" = 0) and ("NPR Sales (LCY)" - "NPR COGS (LCY)" = 0) then
                        CurrReport.Skip;

                    VendorAmountLastYear.Init;
                    VendorAmountLastYear."Vendor No." := "No.";

                    case ShowType of
                        ShowType::Varesalg:
                            begin
                                VendorAmountLastYear."Amount (LCY)" := Multipl * "NPR Sales (LCY)";
                            end;
                        ShowType::Avance:
                            begin
                                VendorAmountLastYear."Amount (LCY)" := Multipl * ("NPR Sales (LCY)" - "NPR COGS (LCY)");
                            end;
                    end;

                    VendorAmountLastYear.Insert;
                    SalesLastYear += "NPR Sales (LCY)";
                    DbLastYear += "NPR Sales (LCY)" - "NPR COGS (LCY)";
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Date Filter", StartDateLastYear, EndDateLastYear);
                    Clear(p);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                VendorInt += 1;

                if "NPR Sales (LCY)" <> 0 then
                    dg := (("NPR Sales (LCY)" - "NPR COGS (LCY)") / "NPR Sales (LCY)") * 100
                else
                    dg := 0;

                VendorAmount.Init;
                VendorAmount."Vendor No." := "No.";
                case ShowType of
                    ShowType::Varesalg:
                        begin
                            VendorAmount."Amount (LCY)" := Multipl * "NPR Sales (LCY)";
                        end;
                    ShowType::Avance:
                        begin
                            VendorAmount."Amount (LCY)" := Multipl * ("NPR Sales (LCY)" - "NPR COGS (LCY)");
                        end;
                end;

                VendorAmount.Insert;
                if (ShowQty = 0) or (i < ShowQty) then
                    i := i + 1
                else begin
                    VendorAmount.FindLast;
                    VendorAmount.Delete;
                end;

                //Item sales
                if VendorInt = 1 then
                    MaxAmt := "NPR Sales (LCY)";

                MaxAmount := "NPR Sales (LCY)";

                if MaxAmount > MaxAmt then
                    MaxAmt := MaxAmount;
            end;

            trigger OnPostDataItem()
            begin
                // Insert order in the temp table which includes last year's values
                q := 1;
                if VendorAmountLastYear.FindFirst then
                    repeat
                        if not (VendorAmountLastYear."Amount (LCY)" = 0.0) then begin
                            VendorAmountLastYear.Delete;
                            VendorAmountLastYear."Amount 2 (LCY)" := q;
                            VendorAmountLastYear.Insert;
                            q := q + 1;
                        end;
                    until VendorAmountLastYear.Next = 0;
            end;

            trigger OnPreDataItem()
            begin
                VendorCount := Vendor.Count;
                i := 0;
                VendorAmount.DeleteAll;
                VendorAmountLastYear.DeleteAll;
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
            column(Number_Integer; Integer.Number)
            {
            }
            column(Greyed; Greyed)
            {
            }
            column(No_Vendor; Vendor."No.")
            {
            }
            column(Name_Vendor; Vendor.Name)
            {
            }
            column(SalesLCY_Vendor; Vendor."NPR Sales (LCY)")
            {
            }
            column(COGSLCY_Vendor; Vendor."NPR COGS (LCY)")
            {
            }
            column(ProfitPct; ProfitPct)
            {
            }
            column(Share; StrSubstNo('%1%', Share))
            {
            }
            column(PctOfTotal; StrSubstNo('%1%', PctOfTotal))
            {
            }
            column(Stock_Vendor; Vendor3."NPR Stock")
            {
            }
            column(PctOfTotalInventory; StrSubstNo('%1%', PctOfTotalInventory))
            {
            }
            column(RankingLastYear; RankingLastYear)
            {
            }
            column(AmountLastYear; AmountLastYear)
            {
            }
            column(DgLastYear; StrSubstNo('%1%', DgLastYear))
            {
            }
            column(Index; Index)
            {
            }
            column(ShowType; ShowType)
            {
            }
            column(Sales_LCY_Vendor2; Vendor2."NPR Sales (LCY)")
            {
            }
            column(Profit_Vendor2; Vendor2."NPR Sales (LCY)" - Vendor2."NPR COGS (LCY)")
            {
            }
            column(VendorSales; VendorSales)
            {
            }
            column(CostAmtFooter; CostAmtFooter)
            {
            }
            column(VendorProfit; VendorProfit)
            {
            }
            column(SalesPct; SalesPct)
            {
            }
            column(SalesLastYear; SalesLastYear)
            {
            }
            column(DbLastYear; DbLastYear)
            {
            }
            column(SalesPct2; SalesPct2)
            {
            }
            column(ProfitPct2; ProfitPct2)
            {
            }
            column(IndexSales_1; IndexSales[1])
            {
            }
            column(IndexSales_2; IndexSales[2])
            {
            }
            column(IndexDb_1; IndexDb[1])
            {
            }
            column(IndexDb_2; IndexDb[2])
            {
            }
            column(Qty_Vendor; Vendor."NPR Sales (Qty.)")
            {
            }
            column(StockQty; StockQty)
            {
            }

            trigger OnAfterGetRecord()
            begin
                Clear(RankingLastYear);

                Counter += 1;
                if (Counter / 2) = Round((Counter / 2), 1) then
                    Greyed := false
                else
                    Greyed := true;

                if Number = 1 then begin
                    if not VendorAmount.FindFirst then
                        CurrReport.Break;
                end else
                    if VendorAmount.Next = 0 then
                        CurrReport.Break;

                VendorAmount."Amount (LCY)" := Multipl * VendorAmount."Amount (LCY)";

                Vendor.Get(VendorAmount."Vendor No.");
                //-NPR5.55 [388517]
                Vendor.CalcFields("NPR Sales (LCY)", "Balance (LCY)", "NPR COGS (LCY)", "NPR Sales (Qty.)");
                //Vendor.CALCFIELDS("Sales (LCY)","Balance (LCY)","COGS (LCY)");
                //+NPR5.55 [388517]
                ProfitPct := "Pct."(Vendor."NPR Sales (LCY)" - Vendor."NPR COGS (LCY)", Vendor."NPR Sales (LCY)");

                if (MaxAmt <> 0) then
                    Share := Round(Vendor."NPR Sales (LCY)" * 100 / MaxAmt, 1)
                else
                    Share := 0;

                VendorAmount."Amount (LCY)" := Multipl * VendorAmount."Amount (LCY)";

                // Sales last year and db
                Vendor2.Get(VendorAmount."Vendor No.");
                Vendor2.SetRange("Date Filter", StartDateLastYear, EndDateLastYear);
                Vendor2.CalcFields("NPR Sales (LCY)", "NPR COGS (LCY)", "Balance (LCY)");

                // Read last year's ranking
                VendorAmountLastYear.SetFilter("Vendor No.", VendorAmount."Vendor No.");
                if VendorAmountLastYear.FindFirst then
                    RankingLastYear := VendorAmountLastYear."Amount 2 (LCY)";

                case ShowType of
                    ShowType::Varesalg:
                        begin
                            AmountLastYear := Vendor2."NPR Sales (LCY)";
                            PctOfTotal := "Pct."(Vendor."NPR Sales (LCY)", VendorSales);
                            Index := "Pct."(Vendor."NPR Sales (LCY)", AmountLastYear);
                        end;
                    ShowType::Avance:
                        begin
                            AmountLastYear := Vendor2."NPR Sales (LCY)" - Vendor2."NPR COGS (LCY)";
                            PctOfTotal := "Pct."(Vendor."NPR Sales (LCY)" - Vendor."NPR COGS (LCY)", VendorProfit);
                            Index := "Pct."(Vendor."NPR Sales (LCY)" - Vendor."NPR COGS (LCY)", AmountLastYear);
                        end;
                end;

                j := IncStr(j);

                // Calculates inventory for that supplier
                //-NPR5.55 [388517]
                Vendor.CopyFilter("Global Dimension 1 Filter", Vendor3."Global Dimension 1 Filter");
                Vendor.CopyFilter("NPR Item Group Filter", Vendor3."NPR Item Group Filter");
                //+NPR5.55 [388517]

                Vendor3.Get(VendorAmount."Vendor No.");
                Vendor3.CalcFields("NPR Stock");
                PctOfTotalInventory := "Pct."(Vendor3."NPR Stock", InventoryTotal);

                DgLastYear := "Pct."(Vendor2."NPR Sales (LCY)" - Vendor2."NPR COGS (LCY)", Vendor2."NPR Sales (LCY)");

                //-NPR70.00.00.00
                SalesPct := "Pct."(Vendor."NPR Sales (LCY)", VendorSales);
                BalancePct := "Pct."(Vendor."Balance (LCY)", VendorBalance);
                //-NPR5.43 [317517]
                //ProfitPct := "Pct."(Vendor."Sales (LCY)"-Vendor."COGS (LCY)",VendorProfit);
                //+NPR5.43 [317517]
                ProfitPct2 := "Pct."(Vendor2."NPR Sales (LCY)" - Vendor2."NPR COGS (LCY)", DbLastYear);
                SalesPct2 := "Pct."(Vendor2."NPR Sales (LCY)", SalesLastYear);
                IndexSales[1] := "Pct."(Vendor."NPR Sales (LCY)", Vendor2."NPR Sales (LCY)");
                IndexSales[2] := "Pct."(VendorSales, SalesLastYear);
                IndexDb[1] := "Pct."(Vendor."NPR Sales (LCY)" - Vendor."NPR COGS (LCY)", Vendor2."NPR Sales (LCY)" - Vendor2."NPR COGS (LCY)");
                IndexDb[2] := "Pct."(VendorProfit, DbLastYear);
                //+NPR70.00.00.00

                //-NPR5.55 [388517]
                //Calculates stock(Qty)
                Clear(StockQty);
                ValueEntry2.SetFilter("Posting Date", '..%1', Vendor.GetRangeMax("Date Filter"));
                Vendor.CopyFilter("Global Dimension 1 Filter", ValueEntry2."Global Dimension 1 Code");
                Vendor.CopyFilter("NPR Item Group Filter", ValueEntry2."NPR Item Group No.");
                Vendor.CopyFilter("NPR Salesperson Filter", ValueEntry2."Salespers./Purch. Code");
                ValueEntry2.SetFilter("NPR Vendor No.", Vendor."No.");

                if ValueEntry2.FindFirst then
                    repeat
                        if ValueEntry2."Cost per Unit" <> 0 then
                            StockQty += ValueEntry2."Cost Amount (Actual)" / ValueEntry2."Cost per Unit";
                    until ValueEntry2.Next = 0;

                //+NPR5.55 [388517]
            end;

            trigger OnPreDataItem()
            begin
                // Calculates sales and consumption in total
                //-NPR5.49 [343119]
                //ValueEntry.SETCURRENTKEY("Vendor No.","Item Ledger Entry Type","Posting Date","Item Group No.");
                ValueEntry.SetCurrentKey("Item Ledger Entry Type", "Posting Date");
                //+NPR5.49 [343119]
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                Vendor.CopyFilter("Date Filter", ValueEntry."Posting Date");
                ValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)");
                VendorSales := ValueEntry."Sales Amount (Actual)";

                //-NPR70.00.00.00
                CostAmtFooter := ValueEntry."Cost Amount (Actual)";
                //+NPR70.00.00.00

                VendorProfit := VendorSales - Abs(ValueEntry."Cost Amount (Actual)");

                // Calculates the inventory total for the period '..GETRANGEMAX'
                //-NPR5.55 [388517]
                Vendor3.SetFilter("Global Dimension 1 Filter", Vendor."Global Dimension 1 Filter");
                Vendor.CopyFilter("NPR Item Group Filter", Vendor3."NPR Item Group Filter");
                //+NPR5.55 [388517]

                Vendor3.SetFilter("Date Filter", '..%1', Vendor.GetRangeMax("Date Filter"));
                if Vendor3.FindFirst then
                    repeat
                        Vendor3.CalcFields("NPR Stock");
                        InventoryTotal += Vendor3."NPR Stock";
                    until Vendor3.Next = 0;

                Clear(Index);

                //-NPR5.39
                //CurrReport.CREATETOTALS(Vendor."Sales (LCY)",Vendor."Balance (LCY)",Vendor."COGS (LCY)");
                //CurrReport.CREATETOTALS(Vendor2."Sales (LCY)", Vendor2."Balance (LCY)", Vendor2."COGS (LCY)");
                //+NPR5.39
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(ShowType; ShowType)
                {
                    Caption = 'Show Type';
                    OptionCaption = 'Item Sales,,Gains,Margin';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Type field';
                }
                field("Sorting"; Sorting)
                {
                    Caption = 'Sorting';
                    OptionCaption = 'Show Biggest/Smallest Deb.';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sorting field';
                }
                field(ShowQty; ShowQty)
                {
                    Caption = 'Show Quantity';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Quantity field';
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if ShowQty = 0 then
                ShowQty := 10;
        end;
    }

    labels
    {
        Page_Caption = 'Page';
        Report_Caption = 'Top Vendor by Item Sales';
        Sequence_Caption = 'Ranking';
        No_Caption = 'No.';
        Name_Caption = 'Name';
        SalesLCY_Caption = 'Sales (LCY)';
        ProfitLCY_Caption = 'Profit (LCY)';
        Profit_Pct_Caption = '% of Total Profit';
        BiggestPct_Caption = '% of Highest Sale';
        ShareTotal_Caption = '% of Total Sales';
        Inventory_Caption = 'Inventory';
        InventoryShare_Caption = '% of Total Inventory';
        LastYear_Caption = 'Last year''s';
        SalesTotal_Caption = 'Sales';
        LastYearProfit = 'Last year''s profit %';
        Index_Caption = 'Index';
        ThisYear_Caption = 'This Year';
        Total_Caption = 'Total';
        SaleTotal_Caption = 'Sale Total';
        SharePct_Caption = '% of Yearly Sales';
        Sale_Caption = 'Sale';
        IndexSale_Caption = 'Index Sale';
        IndexDb_Caption = 'IndexDb';
        Qty_Caption = 'Sales (Qty)';
        Qty_Inventory = 'Inventory (Qty)';
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
        //-NPR5.39
        // Object.SETRANGE(ID, 6014426);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39

        Clear(SalesLastYear);
        Clear(Counter);
    end;

    trigger OnPreReport()
    begin
        VendorFilter := Vendor.GetFilters;
        VendorDateFilter := Vendor.GetFilter("Date Filter");

        j := '2';
        StartDate := Vendor.GetRangeMin("Date Filter");
        EndDate := Vendor.GetRangeMax("Date Filter");
        StartDateLastYear := CalcDate('<-1Y>', StartDate);
        EndDateLastYear := CalcDate('<-1Y>', EndDate);

        if StartDate <> NormalDate(StartDate) then
            StartDateLastYear := ClosingDate(StartDateLastYear);
        if EndDate <> NormalDate(EndDate) then
            EndDateLastYear := ClosingDate(EndDateLastYear);

        if Sorting = Sorting::Stoerste then
            Multipl := -1
        else
            Multipl := 1;
    end;

    var
        CompanyInfo: Record "Company Information";
        VendorAmount: Record "Vendor Amount" temporary;
        VendorCount: Integer;
        VendorInt: Integer;
        VendorFilter: Text[250];
        VendorDateFilter: Text[30];
        ShowType: Option Varesalg,,Avance,Daekningsgrad;
        ShowQty: Integer;
        VendorSales: Decimal;
        VendorBalance: Decimal;
        VendorProfit: Decimal;
        DbLastYear: Decimal;
        SalesPct: Decimal;
        BalancePct: Decimal;
        SalesPct2: Decimal;
        ProfitPct2: Decimal;
        MaxAmt: Decimal;
        Share: Decimal;
        i: Integer;
        ProfitPct: Decimal;
        Sorting: Option Stoerste,Mindste;
        Multipl: Integer;
        PctOfTotal: Decimal;
        j: Text[30];
        dg: Decimal;
        StartDate: Date;
        EndDate: Date;
        StartDateLastYear: Date;
        EndDateLastYear: Date;
        VendorAmountLastYear: Record "Vendor Amount" temporary;
        p: Integer;
        q: Integer;
        RankingLastYear: Decimal;
        Vendor2: Record Vendor;
        SalesLastYear: Decimal;
        MaxAmount: Decimal;
        AmountLastYear: Decimal;
        Index: Decimal;
        IndexSales: array[2] of Decimal;
        IndexDb: array[2] of Decimal;
        Counter: Integer;
        Greyed: Boolean;
        DgLastYear: Decimal;
        InventoryTotal: Decimal;
        PctOfTotalInventory: Decimal;
        Vendor3: Record Vendor;
        ValueEntry: Record "Value Entry";
        Text10600001: Label 'Period: %1';
        Text10600002: Label 'Order by %1 ';
        CostAmtFooter: Decimal;
        StockQty: Decimal;
        ValueEntry2: Record "Value Entry";

    local procedure "Pct."(Tal1: Decimal; Tal2: Decimal): Decimal
    begin
        if Tal2 = 0 then
            exit(0);
        exit(Round(Tal1 / Tal2 * 100, 0.1));
    end;
}

