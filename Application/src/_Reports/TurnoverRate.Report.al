report 6014427 "NPR Turnover Rate"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Turnover Rate.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Turnover Rate';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Date Filter", "Vendor No.";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Heading2_Item; StrSubstNo(Text001, ValueMethod))
            {
            }
            column(GETFILTERS_Item; GetFilters)
            {
            }
            column(No_Item; Item."No.")
            {
                IncludeCaption = true;
            }
            column(Description_Item; Item.Description)
            {
                IncludeCaption = true;
            }
            column(SalesPeriod_Item; SalesPeriod)
            {
            }
            column(SalesQty_Item; _SalesQty)
            {
                DecimalPlaces = 0 : 5;
            }
            column(InventoryAmt_Item; InventoryAmt)
            {
            }
            column(TurnoverRate_Item; TurnoverRate)
            {
            }
            column(Column3_Item; StrSubstNo('%1 %2', PeriodSalesLabel, DateFilter))
            {
            }
            column(Column5_Item; StrSubstNo('%1 %2', ValuationDateLabel, Format(ValueDate)))
            {
            }
            column(IncludeItemWithNoVATSales; IncludeItemWithNoVATSales)
            {
            }
            column(AvgBalanceCostPrice; AvgBalanceCostPrice)
            {
            }
            column(ValueMethodCaption; StrSubstNo(Text001, ValueMethod))
            {
            }
            column(ShowSection1; ShowSection1)
            {
            }

            trigger OnAfterGetRecord()
            var
                SeriesBalanceSum: Decimal;
            begin
                Clear(InventoryAmt);
                Clear(SalesPeriod);
                Clear(TurnoverRate);
                Clear(AvgBalanceCostPrice);
                Clear(_SalesQty);

                if _PeriodSalesAmount.Get("No.", SalesPeriod) then;
                if _PeriodSalesQty.Get("No.", _SalesQty) then;
                SalesCost := _SalesQty * "Last Direct Cost";

                if _SeriesBalanceSum.Get("No.", SeriesBalanceSum) then
                    AvgBalanceCostPrice := SeriesBalanceSum / (MonthQty + 1);

                if AvgBalanceCostPrice <> 0 then
                    TurnoverRate := (SalesCost / AvgBalanceCostPrice) * (12 / (MonthQty + 1))
                else
                    TurnoverRate := 0;

                ShowSection1 := false;
                if not IncludeItemWithNoVATSales then
                    ShowSection1 := ((SalesPeriod <> 0) or (InventoryAmt <> 0));
            end;

            trigger OnPreDataItem()
            var
                MeasurementPoints: List of [Date];
                RunningBalance: Dictionary of [Code[20], Decimal];
                PointIndex: Integer;
            begin
                StartDate := GetRangeMin("Date Filter");
                EndDate := GetRangeMax("Date Filter");
                MonthQty := (Date2DMY(EndDate, 3) - Date2DMY(StartDate, 3)) * 12 + (Date2DMY(EndDate, 2) - Date2DMY(StartDate, 2));

                if PrintSupplier then
                    CurrReport.Break();

                Clear(_PeriodSalesAmount);
                Clear(_PeriodSalesQty);
                Clear(_SeriesBalanceSum);

                CollectPeriodSales();

                for PointIndex := 0 to MonthQty do
                    MeasurementPoints.Add(CalcDate('<-' + Format(PointIndex) + Text10600003 + '>', EndDate));

                // Each open covers one interval between measurement points; the running balance is cumulative from the start of history.
                CollectBalanceDeltas(0D, MeasurementPoints.Get(MonthQty + 1), RunningBalance);
                AddRunningBalancesToSeriesSum(RunningBalance);
                for PointIndex := MonthQty - 1 downto 0 do begin
                    CollectBalanceDeltas(MeasurementPoints.Get(PointIndex + 2) + 1, MeasurementPoints.Get(PointIndex + 1), RunningBalance);
                    AddRunningBalancesToSeriesSum(RunningBalance);
                end;
            end;
        }
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = SORTING("No.");
            column(No_Vendor; Vendor."No.")
            {
            }
            column(Index_Vendor; "No." + '        ' + Name + '    ' + "Name 2" + '      ' + Address + '    ' + "Address 2" + '        ' + "Post Code" + '  ' + City)
            {
            }
            dataitem(Item4; Item)
            {
                CalcFields = "Sales (LCY)", "Sales (Qty.)";
                DataItemLink = "Vendor No." = FIELD("No."), "Date Filter" = FIELD("Date Filter");
                DataItemTableView = SORTING("Vendor No.");
                column(No_Item4; Item4."No.")
                {
                }
                column(Description_Item4; Item4.Description)
                {
                }
                column(SalesPeriod_item4; SalesPeriod)
                {
                }
                column(SalesQty_Item4; Item4."Sales (Qty.)")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(PurchaseCostPrice);
                    Clear(InventoryAmt);
                    Clear(SalesPeriod);
                    Clear(TurnoverRate);
                    Clear(InventoryQty);
                    Clear(AvgBalanceCostPrice);

                    Item2.CopyFilters(Item);
                    Item2.SetRange("No.", "No.");
                    Item2.SetFilter("Date Filter", '..%1', ValueDate);
                    if Item2.FindFirst() then
                        Item2.CalcFields("Net Change");

                    if (ValueMethod = ValueMethod::"kostpris (gns.)") then
                        ItemCostMgt.CalculateAverageCost(Item4, AvgCost, PurchaseCostPrice);

                    if (ValueMethod = ValueMethod::"sidste koebspris") then
                        AvgCost := "Last Direct Cost";

                    SalesCost := "Sales (Qty.)" * AvgCost;

                    PurchaseCostPrice := Round(AvgCost * Item2."Net Change");
                    Amt1 := Round((AvgCost * Item2."Net Change") / 100 * "Indirect Cost %");
                    InventoryAmt := PurchaseCostPrice + Amt1;
                    SalesPeriod := "Sales (LCY)";

                    // Turnover rate
                    for x := 0 to MonthQty do
                        InventoryQty += Calculate("No.", 0D, CalcDate('<-' + Format(x) + Text10600003 + '>', EndDate));
                    AvgBalanceCostPrice := (InventoryQty / (MonthQty + 1));

                    if AvgBalanceCostPrice <> 0 then
                        TurnoverRate := (SalesCost / AvgBalanceCostPrice) * (12 / (MonthQty + 1))
                    else
                        TurnoverRate := 0;
                end;

                trigger OnPreDataItem()
                begin
                    Item.CopyFilter("Date Filter", Item4."Date Filter");
                end;
            }

            trigger OnPreDataItem()
            begin
                Item.CopyFilter("Date Filter", Vendor."Date Filter");
                Item.CopyFilter("Vendor No.", Vendor."No.");

                if not PrintSupplier then
                    CurrReport.Break();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }
    labels
    {
        Report_Caption = 'Turnover rate';
        No_Caption = 'No.';
        Description_Caption = 'Description';
        SalesQty_Caption = 'Sales (Qty.)';
        TurnoverRate_Caption = 'Turnover rate';
        Total_Caption = 'Total';
        CurrReport_PAGENOCaption = 'Page';
    }

    trigger OnPreReport()
    begin
        Item.CopyFilter("Date Filter", Vendor."Date Filter");
        Item.CopyFilter("Vendor No.", Vendor."No.");

        if not PrintSupplier then
            CurrReport.Break();
    end;

    var
        Item2: Record Item;
        Item3: Record Item;
        ItemCostMgt: Codeunit ItemCostManagement;
        IncludeItemWithNoVATSales: Boolean;
        PrintSupplier: Boolean;
        ShowSection1: Boolean;
        EndDate: Date;
        StartDate: Date;
        ValueDate: Date;
        Amt1: Decimal;
        AvgBalanceCostPrice: Decimal;
        AvgCost: Decimal;
        InventoryAmt: Decimal;
        InventoryQty: Decimal;
        PurchaseCostPrice: Decimal;
        SalesCost: Decimal;
        SalesPeriod: Decimal;
        TurnoverRate: Decimal;
        _PeriodSalesAmount: Dictionary of [Code[20], Decimal];
        _PeriodSalesQty: Dictionary of [Code[20], Decimal];
        _SeriesBalanceSum: Dictionary of [Code[20], Decimal];
        _SalesQty: Decimal;
        MonthQty: Integer;
        x: Integer;
        Text001: Label 'Inv.value is based on %1';
        Text10600003: Label 'M';
        ValueMethod: Option "sidste koebspris","kostpris (gns.)";
        DateFilter: Text[250];
        PeriodSalesLabel: Label 'Sales during the period';
        ValuationDateLabel: Label 'Stock Value on Date';

    internal procedure Calculate("ItemNo.": Code[20]; FromDate: Date; ToDate: Date) ValueAmt: Decimal
    begin
        Item3.SetRange("Date Filter", FromDate, ToDate);
        if PrintSupplier then
            Item3.Get(Item4."No.")
        else
            Item3.Get(Item."No.");
        Item3.CalcFields("Purchases (LCY)", "COGS (LCY)");
        ValueAmt := Item3."Purchases (LCY)" - (Item3."COGS (LCY)");
    end;

    local procedure CollectPeriodSales()
    var
        TurnoverRateAggregates: Query "NPR Turnover Rate Aggregates";
        ValueEntryType: Enum "Item Ledger Entry Type";
    begin
        ApplyItemFlowFilters(TurnoverRateAggregates);
        TurnoverRateAggregates.SetRange(Item_Ledger_Entry_Type_Filter, ValueEntryType::Sale);
        TurnoverRateAggregates.SetRange(Posting_Date_Filter, StartDate, EndDate);
        TurnoverRateAggregates.Open();
        while TurnoverRateAggregates.Read() do begin
            _PeriodSalesAmount.Set(TurnoverRateAggregates.Item_No, TurnoverRateAggregates.Sales_Amount_Actual);
            _PeriodSalesQty.Set(TurnoverRateAggregates.Item_No, -TurnoverRateAggregates.Invoiced_Quantity);
        end;
        TurnoverRateAggregates.Close();
    end;

    local procedure CollectBalanceDeltas(FromDate: Date; ToDate: Date; var RunningBalance: Dictionary of [Code[20], Decimal])
    var
        TurnoverRateAggregates: Query "NPR Turnover Rate Aggregates";
        ValueEntryType: Enum "Item Ledger Entry Type";
        Balance: Decimal;
    begin
        ApplyItemFlowFilters(TurnoverRateAggregates);
        TurnoverRateAggregates.SetFilter(Item_Ledger_Entry_Type_Filter, '%1|%2', ValueEntryType::Purchase, ValueEntryType::Sale);
        TurnoverRateAggregates.SetRange(Posting_Date_Filter, FromDate, ToDate);
        TurnoverRateAggregates.Open();
        while TurnoverRateAggregates.Read() do begin
            if not RunningBalance.Get(TurnoverRateAggregates.Item_No, Balance) then
                Balance := 0;
            if TurnoverRateAggregates.Item_Ledger_Entry_Type = ValueEntryType::Purchase then
                Balance += TurnoverRateAggregates.Purchase_Amount_Actual
            else
                Balance += TurnoverRateAggregates.Cost_Amount_Actual;
            RunningBalance.Set(TurnoverRateAggregates.Item_No, Balance);
        end;
        TurnoverRateAggregates.Close();
    end;

    local procedure ApplyItemFlowFilters(var TurnoverRateAggregates: Query "NPR Turnover Rate Aggregates")
    begin
        TurnoverRateAggregates.SetFilter(Item_No, Item.GetFilter("No."));
        TurnoverRateAggregates.SetFilter(Global_Dimension_1_Filter, Item.GetFilter("Global Dimension 1 Filter"));
        TurnoverRateAggregates.SetFilter(Global_Dimension_2_Filter, Item.GetFilter("Global Dimension 2 Filter"));
        TurnoverRateAggregates.SetFilter(Location_Filter, Item.GetFilter("Location Filter"));
        TurnoverRateAggregates.SetFilter(Variant_Filter, Item.GetFilter("Variant Filter"));
        TurnoverRateAggregates.SetFilter(Drop_Shipment_Filter, Item.GetFilter("Drop Shipment Filter"));
    end;

    local procedure AddRunningBalancesToSeriesSum(RunningBalance: Dictionary of [Code[20], Decimal])
    var
        ItemNo: Code[20];
        PointSum: Decimal;
    begin
        foreach ItemNo in RunningBalance.Keys() do begin
            if not _SeriesBalanceSum.Get(ItemNo, PointSum) then
                PointSum := 0;
            _SeriesBalanceSum.Set(ItemNo, PointSum + RunningBalance.Get(ItemNo));
        end;
    end;
}

