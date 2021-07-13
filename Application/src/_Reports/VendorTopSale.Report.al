report 6014426 "NPR Vendor Top/Sale"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Vendor TopSale.rdlc';
    Caption = 'Vendor Top/Sale';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
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
                        CurrReport.Skip();

                    TempVendorAmountLastYear.Init();
                    TempVendorAmountLastYear."Vendor No." := "No.";

                    case ShowType of
                        ShowType::"Item Sales":
                            begin
                                TempVendorAmountLastYear."Amount (LCY)" := Multipl * "NPR Sales (LCY)";
                            end;
                        ShowType::Gains:
                            begin
                                TempVendorAmountLastYear."Amount (LCY)" := Multipl * ("NPR Sales (LCY)" - "NPR COGS (LCY)");
                            end;
                    end;

                    TempVendorAmountLastYear.Insert();
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



                TempVendorAmount.Init();
                TempVendorAmount."Vendor No." := "No.";
                case ShowType of
                    ShowType::"Item Sales":
                        begin
                            TempVendorAmount."Amount (LCY)" := Multipl * "NPR Sales (LCY)";
                        end;
                    ShowType::Gains:
                        begin
                            TempVendorAmount."Amount (LCY)" := Multipl * ("NPR Sales (LCY)" - "NPR COGS (LCY)");
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
                    MaxAmt := "NPR Sales (LCY)";

                MaxAmount := "NPR Sales (LCY)";

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
            column(SalesLCY_Vendor; Vendor."NPR Sales (LCY)")
            {
            }
            column(COGSLCY_Vendor; Vendor."NPR COGS (LCY)")
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
            column(Stock_Vendor; Vendor3."NPR Stock")
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
                    if not TempVendorAmount.FindFirst() then
                        CurrReport.Break();
                end else
                    if TempVendorAmount.Next() = 0 then
                        CurrReport.Break();

                TempVendorAmount."Amount (LCY)" := Multipl * TempVendorAmount."Amount (LCY)";

                Vendor.Get(TempVendorAmount."Vendor No.");
                Vendor.CalcFields("NPR Sales (LCY)", "Balance (LCY)", "NPR COGS (LCY)", "NPR Sales (Qty.)");
                ProfitPct := "Pct."(Vendor."NPR Sales (LCY)" - Vendor."NPR COGS (LCY)", Vendor."NPR Sales (LCY)");

                if (MaxAmt <> 0) then
                    Share := Round(Vendor."NPR Sales (LCY)" * 100 / MaxAmt, 1)
                else
                    Share := 0;

                TempVendorAmount."Amount (LCY)" := Multipl * TempVendorAmount."Amount (LCY)";

                // Sales last year and db
                Vendor2.Get(TempVendorAmount."Vendor No.");
                Vendor2.SetRange("Date Filter", StartDateLastYear, EndDateLastYear);
                Vendor2.CalcFields("NPR Sales (LCY)", "NPR COGS (LCY)", "Balance (LCY)");

                // Read last year's ranking
                TempVendorAmountLastYear.SetFilter("Vendor No.", TempVendorAmount."Vendor No.");
                if TempVendorAmountLastYear.FindFirst() then
                    RankingLastYear := TempVendorAmountLastYear."Amount 2 (LCY)";

                case ShowType of
                    ShowType::"Item Sales":
                        begin
                            AmountLastYear := Vendor2."NPR Sales (LCY)";
                            PctOfTotal := "Pct."(Vendor."NPR Sales (LCY)", VendorSales);
                            Index := "Pct."(Vendor."NPR Sales (LCY)", AmountLastYear);
                        end;
                    ShowType::Gains:
                        begin
                            AmountLastYear := Vendor2."NPR Sales (LCY)" - Vendor2."NPR COGS (LCY)";
                            PctOfTotal := "Pct."(Vendor."NPR Sales (LCY)" - Vendor."NPR COGS (LCY)", VendorProfit);
                            Index := "Pct."(Vendor."NPR Sales (LCY)" - Vendor."NPR COGS (LCY)", AmountLastYear);
                        end;
                end;

                j := IncStr(j);

                // Calculates inventory for that supplier
                Vendor.CopyFilter("Global Dimension 1 Filter", Vendor3."Global Dimension 1 Filter");
                Vendor.CopyFilter("NPR Item Category Filter", Vendor3."NPR Item Category Filter");

                Vendor3.Get(TempVendorAmount."Vendor No.");
                Vendor3.CalcFields("NPR Stock");
                PctOfTotalInventory := "Pct."(Vendor3."NPR Stock", InventoryTotal);

                DgLastYear := "Pct."(Vendor2."NPR Sales (LCY)" - Vendor2."NPR COGS (LCY)", Vendor2."NPR Sales (LCY)");

                SalesPct := "Pct."(Vendor."NPR Sales (LCY)", VendorSales);
                ProfitPct2 := "Pct."(Vendor2."NPR Sales (LCY)" - Vendor2."NPR COGS (LCY)", DbLastYear);
                SalesPct2 := "Pct."(Vendor2."NPR Sales (LCY)", SalesLastYear);
                IndexSales[1] := "Pct."(Vendor."NPR Sales (LCY)", Vendor2."NPR Sales (LCY)");
                IndexSales[2] := "Pct."(VendorSales, SalesLastYear);
                IndexDb[1] := "Pct."(Vendor."NPR Sales (LCY)" - Vendor."NPR COGS (LCY)", Vendor2."NPR Sales (LCY)" - Vendor2."NPR COGS (LCY)");
                IndexDb[2] := "Pct."(VendorProfit, DbLastYear);
                Clear(StockQty);
                AuxValueEntry2.SetFilter("Posting Date", '..%1', Vendor.GetRangeMax("Date Filter"));
                Vendor.CopyFilter("Global Dimension 1 Filter", AuxValueEntry2."Global Dimension 1 Code");
                Vendor.CopyFilter("NPR Item Category Filter", AuxValueEntry2."Item Category Code");
                Vendor.CopyFilter("NPR Salesperson Filter", AuxValueEntry2."Salespers./Purch. Code");
                AuxValueEntry2.SetFilter("Vendor No.", Vendor."No.");

                AuxValueEntry2.CalcSums("Cost per Unit");
                StockQty := AuxValueEntry2."Cost Amount (Actual)" / AuxValueEntry2."Cost per Unit";
            end;

            trigger OnPreDataItem()
            begin
                // Calculates sales and consumption in total
                AuxValueEntry.SetCurrentKey("Item Ledger Entry Type", "Posting Date");
                AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
                Vendor.CopyFilter("Date Filter", AuxValueEntry."Posting Date");
                AuxValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)");
                VendorSales := AuxValueEntry."Sales Amount (Actual)";
                CostAmtFooter := AuxValueEntry."Cost Amount (Actual)";

                VendorProfit := VendorSales - Abs(AuxValueEntry."Cost Amount (Actual)");

                // Calculates the inventory total for the period '..GETRANGEMAX'
                Vendor3.SetFilter("Global Dimension 1 Filter", Vendor."Global Dimension 1 Filter");
                Vendor.CopyFilter("NPR Item Category Filter", Vendor3."NPR Item Category Filter");

                Vendor3.SetFilter("Date Filter", '..%1', Vendor.GetRangeMax("Date Filter"));
                if Vendor3.FindFirst() then
                    repeat
                        Vendor3.CalcFields("NPR Stock");
                        InventoryTotal += Vendor3."NPR Stock";
                    until Vendor3.Next() = 0;

                Clear(Index);
            end;
        }
    }

    requestpage
    {

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

        if SortOrder = SortOrder::Highest then
            Multipl := -1
        else
            Multipl := 1;
    end;

    var
        CompanyInfo: Record "Company Information";
        AuxValueEntry: Record "NPR Aux. Value Entry";
        AuxValueEntry2: Record "NPR Aux. Value Entry";
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
        VendorDateFilter: Text[30];
        VendorFilter: Text[250];
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

