﻿report 6014427 "NPR Turnover Rate"
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
            CalcFields = "Sales (LCY)", "Sales (Qty.)";
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
            column(SalesQty_Item; Item."Sales (Qty.)")
            {
            }
            column(InventoryAmt_Item; InventoryAmt)
            {
            }
            column(TurnoverRate_Item; TurnoverRate)
            {
            }
            column(Column3_Item; 'Salg i perioden ' + DateFilter)
            {
            }
            column(Column5_Item; 'Lagervaerdi pr. ' + Format(ValueDate))
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
            begin
                Clear(PurchaseCostPrice);
                Clear(InventoryAmt);
                Clear(SalesPeriod);
                Clear(TurnoverRate);
                Clear(Inventory);
                Clear(AvgBalanceCostPrice);

                Item2.CopyFilters(Item);
                Item2.SetRange("No.", "No.");
                Item2.SetFilter("Date Filter", '..%1', ValueDate);
                if Item2.FindFirst() then
                    Item2.CalcFields("Net Change");

                if (ValueMethod = ValueMethod::"kostpris (gns.)") then
                    ItemCostMgt.CalculateAverageCost(Item, AvgCost, PurchaseCostPrice);

                if (ValueMethod = ValueMethod::"sidste koebspris") then
                    AvgCost := "Last Direct Cost";

                SalesCost := "Sales (Qty.)" * AvgCost;

                PurchaseCostPrice := Round(AvgCost * Item2."Net Change");
                Amt1 := Round((AvgCost * Item2."Net Change") / 100 * "Indirect Cost %");
                InventoryAmt := PurchaseCostPrice + Amt1;
                SalesPeriod := "Sales (LCY)";

                // Turnover rate
                for x := 0 to MonthQty do
                    Inventory += Calculate("No.", 0D, CalcDate('<-' + Format(x) + Text10600003 + '>', EndDate));
                AvgBalanceCostPrice := (Inventory / (MonthQty + 1));

                if AvgBalanceCostPrice <> 0 then
                    TurnoverRate := (SalesCost / AvgBalanceCostPrice) * (12 / (MonthQty + 1))
                else
                    TurnoverRate := 0;

                ShowSection1 := false;
                if not IncludeItemWithNoVATSales then
                    ShowSection1 := ((SalesPeriod <> 0) or (InventoryAmt <> 0));
            end;

            trigger OnPreDataItem()
            begin
                StartDate := GetRangeMin("Date Filter");
                EndDate := GetRangeMax("Date Filter");
                MonthQty := (Date2DMY(EndDate, 3) - Date2DMY(StartDate, 3)) * 12 + (Date2DMY(EndDate, 2) - Date2DMY(StartDate, 2));

                if PrintSupplier then
                    CurrReport.Break();
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
                    Clear(Inventory);
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
                        Inventory += Calculate("No.", 0D, CalcDate('<-' + Format(x) + Text10600003 + '>', EndDate));
                    AvgBalanceCostPrice := (Inventory / (MonthQty + 1));

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
        PurchaseCostPrice: Decimal;
        SalesCost: Decimal;
        SalesPeriod: Decimal;
        TurnoverRate: Decimal;
        MonthQty: Integer;
        x: Integer;
        Text001: Label 'Inv.value is based on %1';
        Text10600003: Label 'M';
        ValueMethod: Option "sidste koebspris","kostpris (gns.)";
        DateFilter: Text[250];

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
}

