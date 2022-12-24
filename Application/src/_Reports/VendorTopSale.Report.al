report 6014426 "NPR Vendor Top/Sale"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Vendor TopSale.rdlc';
    Caption = 'Vendor Top/Sale';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            CalcFields = "Balance (LCY)";
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
                CalcFields = "Balance (LCY)";
                DataItemLink = "No." = FIELD("No.");
                DataItemTableView = SORTING("No.");

                trigger OnAfterGetRecord()
                begin
                    NPRGetVESalesLCYSalesQtyCOGSLCY(KreditorsidsteaarSalesLCY, KreditorsidsteaarSalesQty, KreditorsidsteaarCOGS);
                    if (KreditorsidsteaarSalesLCY = 0) and ("Balance (LCY)" = 0) and (KreditorsidsteaarSalesLCY - KreditorsidsteaarCOGS = 0) then
                        CurrReport.Skip();

                    TempVendorAmountLastYear.Init();
                    TempVendorAmountLastYear."Vendor No." := "No.";

                    case ShowType of
                        ShowType::"Item Sales":
                            begin
                                TempVendorAmountLastYear."Amount (LCY)" := Multipl * KreditorsidsteaarSalesLCY;
                            end;
                        ShowType::Gains:
                            begin
                                TempVendorAmountLastYear."Amount (LCY)" := Multipl * (KreditorsidsteaarSalesLCY - KreditorsidsteaarCOGS);
                            end;
                    end;

                    TempVendorAmountLastYear.Insert();
                    SalesLastYear += KreditorsidsteaarSalesLCY;
                    DbLastYear += KreditorsidsteaarSalesLCY - KreditorsidsteaarCOGS;
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
                NPRGetVESalesLCYSalesQtyCOGSLCY(SalesLCY, SalesQty, COGSLCY);


                TempVendorAmount.Init();
                TempVendorAmount."Vendor No." := "No.";
                case ShowType of
                    ShowType::"Item Sales":
                        begin
                            TempVendorAmount."Amount (LCY)" := Multipl * SalesLCY;
                        end;
                    ShowType::Gains:
                        begin
                            TempVendorAmount."Amount (LCY)" := Multipl * (SalesLCY - COGSLCY);
                        end;
                end;

                TempVendorAmount.Insert();
                if (ShowQty = 0) or (i < ShowQty) then
                    i := i + 1
                else begin
                    TempVendorAmount.FindLast();
                    TempVendorAmount.Delete();
                end;

                //Item sales
                if VendorInt = 1 then
                    MaxAmt := SalesLCY;

                MaxAmount := SalesLCY;

                if MaxAmount > MaxAmt then
                    MaxAmt := MaxAmount;
            end;

            trigger OnPostDataItem()
            begin
                // Insert order in the temp table which includes last year's values
                q := 1;
                if TempVendorAmountLastYear.FindFirst() then
                    repeat
                        if not (TempVendorAmountLastYear."Amount (LCY)" = 0.0) then begin
                            TempVendorAmountLastYear.Delete();
                            TempVendorAmountLastYear."Amount 2 (LCY)" := q;
                            TempVendorAmountLastYear.Insert();
                            q := q + 1;
                        end;
                    until TempVendorAmountLastYear.Next() = 0;
            end;

            trigger OnPreDataItem()
            begin
                i := 0;
                TempVendorAmount.DeleteAll();
                TempVendorAmountLastYear.DeleteAll();
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
            column(SalesLCY_Vendor; SalesLCY)
            {
            }
            column(COGSLCY_Vendor; COGSLCY)
            {
            }
            column(ProfitPct; ProfitPct)
            {
            }
            column(Share; StrSubstNo(Pct1Lbl, Share))
            {
            }
            column(PctOfTotal; StrSubstNo(Pct1Lbl, PctOfTotal))
            {
            }
            column(Stock_Vendor; Vendor3Stock)
            {
            }
            column(PctOfTotalInventory; StrSubstNo(Pct1Lbl, PctOfTotalInventory))
            {
            }
            column(RankingLastYear; RankingLastYear)
            {
            }
            column(AmountLastYear; AmountLastYear)
            {
            }
            column(DgLastYear; StrSubstNo(Pct1Lbl, DgLastYear))
            {
            }
            column(Index; Index)
            {
            }
            column(Show_Type; ShowType)
            {
            }
            column(Sales_LCY_Vendor2; Vendor2SalesLCY)
            {
            }
            column(Profit_Vendor2; Vendor2SalesLCY - Vendor2COGS)
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
            column(Qty_Vendor; SalesQty)
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
                    if not TempVendorAmount.FindFirst() then
                        CurrReport.Break();
                end else
                    if TempVendorAmount.Next() = 0 then
                        CurrReport.Break();

                TempVendorAmount."Amount (LCY)" := Multipl * TempVendorAmount."Amount (LCY)";

                Vendor.Get(TempVendorAmount."Vendor No.");
                Vendor.CalcFields("Balance (LCY)");
                Vendor.NPRGetVESalesLCYSalesQtyCOGSLCY(SalesLCY, SalesQty, COGSLCY);
                ProfitPct := "Pct."(SalesLCY - COGSLCY, SalesLCY);

                if (MaxAmt <> 0) then
                    Share := Round(SalesLCY * 100 / MaxAmt, 1)
                else
                    Share := 0;

                TempVendorAmount."Amount (LCY)" := Multipl * TempVendorAmount."Amount (LCY)";

                // Sales last year and db
                Vendor2.Get(TempVendorAmount."Vendor No.");
                Vendor2.SetRange("Date Filter", StartDateLastYear, EndDateLastYear);
                Vendor2.CalcFields("Balance (LCY)");
                Vendor2.NPRGetVESalesLCYSalesQtyCOGSLCY(Vendor2SalesLCY, Vendor2SalesQty, Vendor2COGS);


                // Read last year's ranking
                TempVendorAmountLastYear.SetFilter("Vendor No.", TempVendorAmount."Vendor No.");
                if TempVendorAmountLastYear.FindFirst() then
                    RankingLastYear := TempVendorAmountLastYear."Amount 2 (LCY)";

                case ShowType of
                    ShowType::"Item Sales":
                        begin
                            AmountLastYear := Vendor2SalesLCY;
                            PctOfTotal := "Pct."(SalesLCY, VendorSales);
                            Index := "Pct."(SalesLCY, AmountLastYear);
                        end;
                    ShowType::Gains:
                        begin
                            AmountLastYear := Vendor2SalesLCY - Vendor2COGS;
                            PctOfTotal := "Pct."(SalesLCY - COGSLCY, VendorProfit);
                            Index := "Pct."(SalesLCY - COGSLCY, AmountLastYear);
                        end;
                end;

                j := IncStr(j);

                // Calculates inventory for that supplier
                Vendor.CopyFilter("Global Dimension 1 Filter", Vendor3."Global Dimension 1 Filter");
                Vendor.CopyFilter("NPR Item Category Filter", Vendor3."NPR Item Category Filter");

                Vendor3.Get(TempVendorAmount."Vendor No.");
                Vendor3.NPRGetVEStock(Vendor3Stock);
                PctOfTotalInventory := "Pct."(Vendor3Stock, InventoryTotal);

                DgLastYear := "Pct."(Vendor2SalesLCY - Vendor2COGS, Vendor2SalesLCY);

                SalesPct := "Pct."(SalesLCY, VendorSales);
                ProfitPct2 := "Pct."(Vendor2SalesLCY - Vendor2COGS, DbLastYear);
                SalesPct2 := "Pct."(Vendor2SalesLCY, SalesLastYear);
                IndexSales[1] := "Pct."(SalesLCY, Vendor2SalesLCY);
                IndexSales[2] := "Pct."(VendorSales, SalesLastYear);
                IndexDb[1] := "Pct."(SalesLCY - COGSLCY, Vendor2SalesLCY - Vendor2COGS);
                IndexDb[2] := "Pct."(VendorProfit, DbLastYear);
                Clear(StockQty);
                ValueEntry2Query.SetFilter(Filter_DateTime, '..%1', Vendor.GetRangeMax("Date Filter"));
                ValueEntry2Query.SetFilter(ValueEntry2Query.Filter_Dim_1_Code, Vendor."Global Dimension 1 Filter");
                ValueEntry2Query.SetFilter(Filter_Vendor_No, Vendor."No.");
                ValueEntry2Query.SetFilter(Filter_Salespers_Purch_Code, Vendor."NPR Salesperson Filter");
                ValueEntry2Query.SetFilter(Filter_Cost_Amount_Actual, '<>%1', 0);
                ValueEntry2Query.Open();
                while ValueEntry2Query.Read() do begin
                    if ValueEntry2Query.Cost_per_Unit <> 0 then
                        StockQty += ValueEntry2Query.Sum_Cost_Amount_Actual / ValueEntry2Query.Cost_per_Unit;
                end;
            end;

            trigger OnPreDataItem()
            begin
                // Calculates sales and consumption in total
                ValueEntry.SetCurrentKey("Item Ledger Entry Type", "Posting Date");
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                Vendor.CopyFilter("Date Filter", ValueEntry."Posting Date");
                ValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)");
                VendorSales := ValueEntry."Sales Amount (Actual)";
                CostAmtFooter := ValueEntry."Cost Amount (Actual)";

                VendorProfit := VendorSales - Abs(ValueEntry."Cost Amount (Actual)");

                // Calculates the inventory total for the period '..GETRANGEMAX'
                Vendor3.SetFilter("Global Dimension 1 Filter", Vendor."Global Dimension 1 Filter");
                Vendor.CopyFilter("NPR Item Category Filter", Vendor3."NPR Item Category Filter");

                Vendor3.SetFilter("Date Filter", '..%1', Vendor.GetRangeMax("Date Filter"));
                if Vendor3.FindFirst() then
                    repeat
                        Vendor3.NPRGetVEStock(Vendor3Stock);
                        InventoryTotal += Vendor3Stock;
                    until Vendor3.Next() = 0;

                Clear(Index);
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
                field("Show Type"; ShowType)
                {
                    Caption = 'Show Type';
                    OptionCaption = 'Item Sales,,Gains,Margin';

                    ToolTip = 'Specifies the value of the Show Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Sorting"; SortOrder)
                {
                    Caption = 'Sorting';
                    OptionCaption = 'Show the highest first,Show the lowest first';

                    ToolTip = 'Specifies the value of the Sorting field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Quantity"; ShowQty)
                {
                    Caption = 'Show Quantity';

                    ToolTip = 'Specifies the value of the Show Quantity field';
                    ApplicationArea = NPRRetail;
                }
            }
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
        Clear(SalesLastYear);
        Clear(Counter);
    end;

    trigger OnPreReport()
    begin
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

        if SortOrder = SortOrder::Highest then
            Multipl := -1
        else
            Multipl := 1;
    end;

    var
        CompanyInfo: Record "Company Information";
        ValueEntry: Record "Value Entry";
        ValueEntry2Query: Query "NPR Value Entry With Vendor";
        Vendor2: Record Vendor;
        Vendor3: Record Vendor;
        TempVendorAmount: Record "Vendor Amount" temporary;
        TempVendorAmountLastYear: Record "Vendor Amount" temporary;
        Greyed: Boolean;
        EndDate: Date;
        EndDateLastYear: Date;
        StartDate: Date;
        StartDateLastYear: Date;
        AmountLastYear: Decimal;
        CostAmtFooter: Decimal;
        DbLastYear: Decimal;
        DgLastYear: Decimal;
        Index: Decimal;
        IndexDb: array[2] of Decimal;
        IndexSales: array[2] of Decimal;
        InventoryTotal: Decimal;
        MaxAmount: Decimal;
        MaxAmt: Decimal;
        PctOfTotal: Decimal;
        PctOfTotalInventory: Decimal;
        ProfitPct: Decimal;
        ProfitPct2: Decimal;
        RankingLastYear: Decimal;
        SalesLastYear: Decimal;
        SalesPct: Decimal;
        SalesPct2: Decimal;
        Share: Decimal;
        StockQty: Decimal;
        VendorProfit: Decimal;
        VendorSales: Decimal;
        Counter: Integer;
        i: Integer;
        Multipl: Integer;
        p: Integer;
        q: Integer;
        ShowQty: Integer;
        VendorInt: Integer;
        Text10600002: Label 'Order by %1 ';
        Text10600001: Label 'Period: %1';
        SortOrder: Option Highest,Lowest;
        ShowType: Option "Item Sales",,Gains,Margin;
        j: Text[30];
        VendorDateFilter: Text;
        Vendor2SalesLCY: Decimal;
        Vendor2SalesQty: Decimal;
        Vendor2COGS: Decimal;
        Vendor3Stock: Decimal;
        SalesLCY: Decimal;
        SalesQty: Decimal;
        COGSLCY: Decimal;
        KreditorsidsteaarSalesLCY: Decimal;
        KreditorsidsteaarSalesQty: Decimal;
        KreditorsidsteaarCOGS: Decimal;
        Pct1Lbl: Label '%1%', locked = true;
# pragma warning disable AA0228
    local procedure "Pct."(Tal1: Decimal; Tal2: Decimal): Decimal
    begin
        if Tal2 = 0 then
            exit(0);
        exit(Round(Tal1 / Tal2 * 100, 0.1));
    end;
# pragma warning restore
}

