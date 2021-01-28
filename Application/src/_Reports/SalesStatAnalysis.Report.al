report 6014457 "NPR Sales Stat/Analysis"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales StatAnalysis.rdlc';
    Caption = 'Sales Stat/Analysis';
    PreviewMode = Normal;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem(ItemGroupHeader; "NPR Item Group")
        {
            CalcFields = "Sales (Qty.)", "Sales (LCY)", "Consumption (Amount)";
            DataItemTableView = SORTING("Sorting-Key");
            RequestFilterFields = "No.", "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter", "Vendor Filter";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Today; Format(Today, 0, 4))
            {
            }
            column(DateFilter_ItemGroupHeader; ItemGroupHeader.GetFilter("Date Filter"))
            {
            }
            column(Filters_ItemGroupHeader; ItemGroupHeader.GetFilters)
            {
            }
            column(No_ItemGroupHeader; ItemGroupHeader."No.")
            {
            }
            column(Description_ItemGroupHeader; ItemGroupHeader.Description)
            {
            }
            column(SalesQty_ItemGroupHeader; ItemGroupHeader."Sales (Qty.)")
            {
            }
            column(ConsumptionAmount_ItemGroupHeader; ItemGroupHeader."Consumption (Amount)")
            {
            }
            column(SaleLCY_ItemGroupHeader; ItemGroupHeader."Sales (LCY)")
            {
            }
            column(Profit_ItemGroupHeader; ItemGroupHeader."Sales (LCY)" - ItemGroupHeader."Consumption (Amount)")
            {
            }
            column(TotalProfit_ItemGroupHeader; TotalProfit)
            {
            }
            column(TotalRevenue_ItemGroupHeader; TotalRevenue)
            {
            }
            column(TotalConsumption_ItemGroupHeader; TotalConsumption)
            {
            }
            column(ShowItem; ShowItem)
            {
            }
            column(Profit_ItemGroupH; Profit)
            {
            }
            column(Coverage_ItemGroupH; Coverage)
            {
            }
            column(CoveragePct_ItemGroupH; CoveragePct)
            {
            }
            column(TurnoverPct_ItemGroupH; TurnoverPct)
            {
            }
            column(Picture_CompanyInformation; CompanyInfo.Picture)
            {
            }
            column(ItemGrpNoLvl0; StrSubstNo(TotalText, "No."))
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "NPR Item Group" = FIELD("No.");
                DataItemTableView = SORTING("NPR Group sale", "NPR Item Group", "Vendor No.");
                column(No_Item; "No.")
                {
                }
                column(Description_Item; Description)
                {
                }
                column(SalesQty_Item; "Sales (Qty.)")
                {
                }
                column(COGSLCY_Item; "COGS (LCY)")
                {
                }
                column(SalesLCY_Item; "Sales (LCY)")
                {
                }
                column(Inventory; Inventory)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if ("Sales (Qty.)" = 0) and OnlySales then
                        CurrReport.Skip();

                    CalcFields(Inventory);
                    SInventory += Inventory;
                end;

                trigger OnPreDataItem()
                begin
                    ItemGroupHeader.CopyFilter("Date Filter", "Date Filter");
                    ItemGroupHeader.CopyFilter("Global Dimension 1 Filter", "Global Dimension 1 Filter");
                    ItemGroupHeader.CopyFilter("Global Dimension 2 Filter", "Global Dimension 2 Filter");
                    ItemGroupHeader.CopyFilter("Vendor Filter", "Vendor No.");
                    if not ShowItem then
                        CurrReport.Break();
                end;
            }
            dataitem(ItemGroupSub1; "NPR Item Group")
            {
                CalcFields = "Sales (Qty.)", "Sales (LCY)", "Consumption (Amount)";
                DataItemLink = "Parent Item Group No." = FIELD("No.");
                DataItemTableView = SORTING("Sorting-Key");
                column(No_ItemGroupSub1; "No.")
                {
                }
                column(Description_ItemGroupSub1; Description)
                {
                }
                column(SalesQty_ItemGroupSub1; "Sales (Qty.)")
                {
                }
                column(ConsumptionAmount_ItemGroupSub1; "Consumption (Amount)")
                {
                }
                column(SaleLCY_ItemGroupSub1; "Sales (LCY)")
                {
                }
                column(Profit_ItemGroupSub1; Profit)
                {
                }
                column(Coverage_ItemGroupSub1; Coverage)
                {
                }
                column(CoveragePct_ItemGroupSub1; CoveragePct)
                {
                }
                column(TurnoverPct_ItemGroupSub1; TurnoverPct)
                {
                }
                column(ItemGrpNoLvl1; StrSubstNo(TotalText, "No."))
                {
                }
                dataitem(Item1; Item)
                {
                    DataItemLink = "NPR Item Group" = FIELD("No.");
                    DataItemTableView = SORTING("NPR Group sale", "NPR Item Group", "Vendor No.");
                    column(No_Item1; "No.")
                    {
                    }
                    column(Description_Item1; Description)
                    {
                    }
                    column(SalesQty_Item1; "Sales (Qty.)")
                    {
                    }
                    column(COGSLCY_Item1; "COGS (LCY)")
                    {
                    }
                    column(SalesLCY_Item1; "Sales (LCY)")
                    {
                    }
                    column(Inventory1; Inventory)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if ("Sales (Qty.)" = 0) and OnlySales then
                            CurrReport.Skip();

                        CalcFields(Inventory);
                        SInventory += Inventory;
                    end;

                    trigger OnPreDataItem()
                    begin
                        ItemGroupHeader.CopyFilter("Date Filter", "Date Filter");
                        ItemGroupHeader.CopyFilter("Global Dimension 1 Filter", "Global Dimension 1 Filter");
                        ItemGroupHeader.CopyFilter("Global Dimension 2 Filter", "Global Dimension 2 Filter");
                        ItemGroupHeader.CopyFilter("Vendor Filter", "Vendor No.");
                        if not ShowItem then
                            CurrReport.Break();
                    end;
                }
                dataitem(ItemGroupSub2; "NPR Item Group")
                {
                    CalcFields = "Sales (Qty.)", "Sales (LCY)", "Consumption (Amount)";
                    DataItemLink = "Parent Item Group No." = FIELD("No.");
                    DataItemTableView = SORTING("Sorting-Key");
                    column(No_ItemGroupSub2; "No.")
                    {
                    }
                    column(Description_ItemGroupSub2; Description)
                    {
                    }
                    column(SalesQty_ItemGroupSub2; "Sales (Qty.)")
                    {
                    }
                    column(ConsumptionAmount_ItemGroupSub2; "Consumption (Amount)")
                    {
                    }
                    column(SaleLCY_ItemGroupSub2; "Sales (LCY)")
                    {
                    }
                    column(Profit_ItemGroupSub2; Profit)
                    {
                    }
                    column(Coverage_ItemGroupSub2; Coverage)
                    {
                    }
                    column(CoveragePct_ItemGroupSub2; CoveragePct)
                    {
                    }
                    column(TurnoverPct_ItemGroupSub2; TurnoverPct)
                    {
                    }
                    column(ItemGrpNoLvl2; StrSubstNo(TotalText, "No."))
                    {
                    }
                    dataitem(Item2; Item)
                    {
                        DataItemLink = "NPR Item Group" = FIELD("No.");
                        DataItemTableView = SORTING("NPR Group sale", "NPR Item Group", "Vendor No.");
                        column(No_Item2; "No.")
                        {
                        }
                        column(Description_Item2; Description)
                        {
                        }
                        column(SalesQty_Item2; "Sales (Qty.)")
                        {
                        }
                        column(COGSLCY_Item2; "COGS (LCY)")
                        {
                        }
                        column(SalesLCY_Item2; "Sales (LCY)")
                        {
                        }
                        column(Inventory2; Inventory)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if ("Sales (Qty.)" = 0) and OnlySales then
                                CurrReport.Skip();

                            CalcFields(Inventory);
                            SInventory += Inventory;
                        end;

                        trigger OnPreDataItem()
                        begin
                            ItemGroupHeader.CopyFilter("Date Filter", "Date Filter");
                            ItemGroupHeader.CopyFilter("Global Dimension 1 Filter", "Global Dimension 1 Filter");
                            ItemGroupHeader.CopyFilter("Global Dimension 2 Filter", "Global Dimension 2 Filter");
                            ItemGroupHeader.CopyFilter("Vendor Filter", "Vendor No.");
                            if not ShowItem then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(ItemGroupSub3; "NPR Item Group")
                    {
                        CalcFields = "Sales (Qty.)", "Sales (LCY)", "Consumption (Amount)";
                        DataItemLink = "Parent Item Group No." = FIELD("No.");
                        DataItemTableView = SORTING("Sorting-Key");
                        column(No_ItemGroupSub3; "No.")
                        {
                        }
                        column(Description_ItemGroupSub3; Description)
                        {
                        }
                        column(SalesQty_ItemGroupSub3; "Sales (Qty.)")
                        {
                        }
                        column(ConsumptionAmount_ItemGroupSub3; "Consumption (Amount)")
                        {
                        }
                        column(SaleLCY_ItemGroupSub3; "Sales (LCY)")
                        {
                        }
                        column(Profit_ItemGroupSub3; Profit)
                        {
                        }
                        column(Coverage_ItemGroupSub3; Coverage)
                        {
                        }
                        column(CoveragePct_ItemGroupSub3; CoveragePct)
                        {
                        }
                        column(TurnoverPct_ItemGroupSub3; TurnoverPct)
                        {
                        }
                        column(ItemGrpNoLvl3; StrSubstNo(TotalText, "No."))
                        {
                        }
                        dataitem(Item3; Item)
                        {
                            DataItemLink = "NPR Item Group" = FIELD("No.");
                            DataItemTableView = SORTING("NPR Group sale", "NPR Item Group", "Vendor No.");
                            column(No_Item3; "No.")
                            {
                            }
                            column(Description_Item3; Description)
                            {
                            }
                            column(SalesQty_Item3; "Sales (Qty.)")
                            {
                            }
                            column(COGSLCY_Item3; "COGS (LCY)")
                            {
                            }
                            column(SalesLCY_Item3; "Sales (LCY)")
                            {
                            }
                            column(Inventory3; Inventory)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if ("Sales (Qty.)" = 0) and OnlySales then
                                    CurrReport.Skip();

                                CalcFields(Inventory);
                                SInventory += Inventory;
                            end;

                            trigger OnPreDataItem()
                            begin
                                ItemGroupHeader.CopyFilter("Date Filter", "Date Filter");
                                ItemGroupHeader.CopyFilter("Global Dimension 1 Filter", "Global Dimension 1 Filter");
                                ItemGroupHeader.CopyFilter("Global Dimension 2 Filter", "Global Dimension 2 Filter");
                                ItemGroupHeader.CopyFilter("Vendor Filter", "Vendor No.");
                                if not ShowItem then
                                    CurrReport.Break();
                            end;
                        }
                        dataitem(ItemGroupSub4; "NPR Item Group")
                        {
                            CalcFields = "Sales (Qty.)", "Sales (LCY)", "Consumption (Amount)";
                            DataItemLink = "Parent Item Group No." = FIELD("No.");
                            DataItemTableView = SORTING("Sorting-Key");
                            column(No_ItemGroupSub4; "No.")
                            {
                            }
                            column(Description_ItemGroupSub4; Description)
                            {
                            }
                            column(SalesQty_ItemGroupSub4; "Sales (Qty.)")
                            {
                            }
                            column(ConsumptionAmount_ItemGroupSub4; "Consumption (Amount)")
                            {
                            }
                            column(SaleLCY_ItemGroupSub4; "Sales (LCY)")
                            {
                            }
                            column(Profit_ItemGroupSub4; Profit)
                            {
                            }
                            column(Coverage_ItemGroupSub4; Coverage)
                            {
                            }
                            column(CoveragePct_ItemGroupSub4; CoveragePct)
                            {
                            }
                            column(TurnoverPct_ItemGroupSub4; TurnoverPct)
                            {
                            }
                            column(ItemGrpNoLvl4; StrSubstNo(TotalText, "No."))
                            {
                            }
                            dataitem(Item4; Item)
                            {
                                DataItemLink = "NPR Item Group" = FIELD("No.");
                                DataItemTableView = SORTING("NPR Group sale", "NPR Item Group", "Vendor No.");
                                column(No_Item4; "No.")
                                {
                                }
                                column(Description_Item4; Description)
                                {
                                }
                                column(SalesQty_Item4; "Sales (Qty.)")
                                {
                                }
                                column(COGSLCY_Item4; "COGS (LCY)")
                                {
                                }
                                column(SalesLCY_Item4; "Sales (LCY)")
                                {
                                }
                                column(Inventory4; Inventory)
                                {
                                }

                                trigger OnAfterGetRecord()
                                begin
                                    if ("Sales (Qty.)" = 0) and OnlySales then
                                        CurrReport.Skip();

                                    CalcFields(Inventory);
                                    SInventory += Inventory;
                                end;

                                trigger OnPreDataItem()
                                begin
                                    ItemGroupHeader.CopyFilter("Date Filter", "Date Filter");
                                    ItemGroupHeader.CopyFilter("Global Dimension 1 Filter", "Global Dimension 1 Filter");
                                    ItemGroupHeader.CopyFilter("Global Dimension 2 Filter", "Global Dimension 2 Filter");
                                    ItemGroupHeader.CopyFilter("Vendor Filter", "Vendor No.");
                                    if not ShowItem then
                                        CurrReport.Break();
                                end;
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if ItemGroupPrinted.Get("No.") or (not (LevelsCount >= 4)) then
                                    CurrReport.Skip();

                                ItemGroupPrinted."No." := "No.";
                                ItemGroupPrinted.Insert();

                                CalcFields("Sales (Qty.)", "Sales (LCY)", "Consumption (Amount)");

                                Clear(Profit);
                                Clear(Coverage);
                                Clear(CoveragePct);
                                Clear(TurnoverPct);
                                Profit := "Sales (LCY)" - "Consumption (Amount)";
                                Coverage := Pct(Profit, "Sales (LCY)");
                                CoveragePct := Pct(Profit, TotalProfit);
                                TurnoverPct := Pct("Sales (LCY)", TotalRevenue);

                                SQty += "Sales (Qty.)";
                                SumSale += "Sales (LCY)";
                                SumConsumption += "Consumption (Amount)";
                            end;

                            trigger OnPreDataItem()
                            begin
                                ItemGroupHeader.CopyFilter("Date Filter", "Date Filter");
                                ItemGroupHeader.CopyFilter("Global Dimension 1 Filter", "Global Dimension 1 Filter");
                                ItemGroupHeader.CopyFilter("Global Dimension 2 Filter", "Global Dimension 2 Filter");
                                ItemGroupHeader.CopyFilter("Vendor Filter", "Vendor Filter");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if ItemGroupPrinted.Get("No.") or (not (LevelsCount >= 3)) then
                                CurrReport.Skip();

                            ItemGroupPrinted."No." := "No.";
                            ItemGroupPrinted.Insert();

                            CalcFields("Sales (Qty.)", "Sales (LCY)", "Consumption (Amount)");

                            Clear(Profit);
                            Clear(Coverage);
                            Clear(CoveragePct);
                            Clear(TurnoverPct);
                            Profit := "Sales (LCY)" - "Consumption (Amount)";
                            Coverage := Pct(Profit, "Sales (LCY)");
                            CoveragePct := Pct(Profit, TotalProfit);
                            TurnoverPct := Pct("Sales (LCY)", TotalRevenue);

                            SQty += "Sales (Qty.)";
                            SumSale += "Sales (LCY)";
                            SumConsumption += "Consumption (Amount)";
                        end;

                        trigger OnPreDataItem()
                        begin
                            ItemGroupHeader.CopyFilter("Date Filter", "Date Filter");
                            ItemGroupHeader.CopyFilter("Global Dimension 1 Filter", "Global Dimension 1 Filter");
                            ItemGroupHeader.CopyFilter("Global Dimension 2 Filter", "Global Dimension 2 Filter");
                            ItemGroupHeader.CopyFilter("Vendor Filter", "Vendor Filter");
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if ItemGroupPrinted.Get("No.") or (not (LevelsCount >= 2)) then
                            CurrReport.Skip();

                        ItemGroupPrinted."No." := "No.";
                        ItemGroupPrinted.Insert();

                        CalcFields("Sales (Qty.)", "Sales (LCY)", "Consumption (Amount)");

                        Clear(Profit);
                        Clear(Coverage);
                        Clear(CoveragePct);
                        Clear(TurnoverPct);
                        Profit := "Sales (LCY)" - "Consumption (Amount)";
                        Coverage := Pct(Profit, "Sales (LCY)");
                        CoveragePct := Pct(Profit, TotalProfit);
                        TurnoverPct := Pct("Sales (LCY)", TotalRevenue);

                        SQty += "Sales (Qty.)";
                        SumSale += "Sales (LCY)";
                        SumConsumption += "Consumption (Amount)";
                    end;

                    trigger OnPreDataItem()
                    begin
                        ItemGroupHeader.CopyFilter("Date Filter", "Date Filter");
                        ItemGroupHeader.CopyFilter("Global Dimension 1 Filter", "Global Dimension 1 Filter");
                        ItemGroupHeader.CopyFilter("Global Dimension 2 Filter", "Global Dimension 2 Filter");
                        ItemGroupHeader.CopyFilter("Vendor Filter", "Vendor Filter");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if ItemGroupPrinted.Get("No.") or (not (LevelsCount >= 1)) then
                        CurrReport.Skip();

                    ItemGroupPrinted."No." := "No.";
                    ItemGroupPrinted.Insert();

                    CalcFields("Sales (Qty.)", "Sales (LCY)", "Consumption (Amount)");

                    Clear(Profit);
                    Clear(Coverage);
                    Clear(CoveragePct);
                    Clear(TurnoverPct);
                    Profit := "Sales (LCY)" - "Consumption (Amount)";
                    Coverage := Pct(Profit, "Sales (LCY)");
                    CoveragePct := Pct(Profit, TotalProfit);
                    TurnoverPct := Pct("Sales (LCY)", TotalRevenue);

                    SQty += "Sales (Qty.)";
                    SumSale += "Sales (LCY)";
                    SumConsumption += "Consumption (Amount)";
                end;

                trigger OnPreDataItem()
                begin
                    ItemGroupHeader.CopyFilter("Date Filter", "Date Filter");
                    ItemGroupHeader.CopyFilter("Global Dimension 1 Filter", "Global Dimension 1 Filter");
                    ItemGroupHeader.CopyFilter("Global Dimension 2 Filter", "Global Dimension 2 Filter");
                    ItemGroupHeader.CopyFilter("Vendor Filter", "Vendor Filter");
                end;
            }
            dataitem("Sum"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(SProfit; SProfit)
                {
                }
                column(SCoverage; SCoverage)
                {
                }
                column(SCoveragePct; SCoveragePct)
                {
                }
                column(STurnoverPct; STurnoverPct)
                {
                }
                column(SSale; SumSale)
                {
                }
                column(SConsumption; SumConsumption)
                {
                }
                column(SInventory; SInventory)
                {
                }
                column(SQty; SQty)
                {
                }

                trigger OnAfterGetRecord()
                begin

                    SProfit := SumSale - SumConsumption;
                    SCoverage := Pct(SProfit, SumSale);
                    SCoveragePct := Pct(SProfit, TotalProfit);
                    STurnoverPct := Pct(SumSale, TotalRevenue);

                    TSumSale += SumSale;
                    TSumConsumption += SumConsumption;
                    TSQty += SQty;
                end;
            }

            trigger OnAfterGetRecord()
            begin

                Clear(SProfit);
                Clear(SumSale);
                Clear(SumConsumption);
                Clear(SCoverage);
                Clear(SCoveragePct);
                Clear(STurnoverPct);
                Clear(SQty);

                if ItemGroupPrinted.Get("No.") then
                    CurrReport.Skip();

                ItemGroupPrinted."No." := "No.";
                ItemGroupPrinted.Insert();

                CalcFields("Sales (Qty.)", "Sales (LCY)", "Consumption (Amount)");

                Clear(Profit);
                Clear(Coverage);
                Clear(CoveragePct);
                Clear(TurnoverPct);
                Profit := "Sales (LCY)" - "Consumption (Amount)";
                Coverage := Pct(Profit, "Sales (LCY)");
                CoveragePct := Pct(Profit, TotalProfit);
                TurnoverPct := Pct("Sales (LCY)", TotalRevenue);

                SQty += "Sales (Qty.)";
                SumSale += "Sales (LCY)";
                SumConsumption += "Consumption (Amount)";
            end;

            trigger OnPreDataItem()
            begin
                ItemGroupPrinted.SetCurrentKey("No.");
                ItemGroupPrinted.DeleteAll();
            end;
        }
        dataitem(Total; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(TSProfit; TSProfit)
            {
            }
            column(TSCoverage; TSCoverage)
            {
            }
            column(TSCoveragePct; TSCoveragePct)
            {
            }
            column(TSTurnoverPct; TSTurnoverPct)
            {
            }
            column(TSSale; TSumSale)
            {
            }
            column(TSConsumption; TSumConsumption)
            {
            }
            column(TSInventory; TSInventory)
            {
            }
            column(TSQty; TSQty)
            {
            }

            trigger OnAfterGetRecord()
            begin

                TSProfit := TSumSale - TSumConsumption;
                TSCoverage := Pct(TSProfit, TSumSale);
                TSCoveragePct := Pct(TSProfit, TotalProfit);
                TSTurnoverPct := Pct(TSumSale, TotalRevenue);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Request)
                {
                    Caption = 'Request';
                    field(ShowItem; ShowItem)
                    {
                        Caption = 'Print Items';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print Items field';
                    }
                    field(OnlySales; OnlySales)
                    {
                        Caption = 'Only Sales';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Only Sales field';
                    }
                    field(LevelsCount; LevelsCount)
                    {
                        Caption = 'Levels';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Levels field';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            LevelsCount := 2;
        end;
    }

    labels
    {
        Report_Caption = 'Sales Statistics/Item Group Analysis';
        Page_Caption = 'Page';
        No_Caption = 'No.';
        Name_Caption = 'Name';
        SaleQty_Caption = 'Quantity (sale)';
        CostExclVat_Caption = 'Cost excl. VAT';
        TurnoverExclVat_Caption = 'Turnover excl. VAT';
        Percentage_Caption = 'Percentage';
        ProfitExclVat_Caption = 'Profit excl. VAT';
        ProfitPct_Caption = 'Profit %';
        InventoryLbl = 'Inv.';
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
        CaptionClassDim1 := '1,1,1';
        TxtDim1 := CaptionClassTranslate(CaptionClassDim1);
        TxtLabeldim1 := GroupByText + TxtDim1;
    end;

    trigger OnPreReport()
    begin
        Clear(TotalProfit);
        Clear(TotalCoverage);

        ItemGroup1.Reset();
        ItemGroupHeader.CopyFilter("Date Filter", ItemGroup1."Date Filter");
        if ItemGroup1.FindSet then
            repeat
                ItemGroup1.CalcFields("Sales (LCY)", "Consumption (Amount)");
                TotalRevenue += ItemGroup1."Sales (LCY)";
                TotalConsumption += ItemGroup1."Consumption (Amount)";
            until ItemGroup1.Next() = 0;

        TotalProfit := TotalRevenue - TotalConsumption;
        TotalCoverage := Pct(TotalProfit, TotalRevenue);
    end;

    var
        CompanyInfo: Record "Company Information";
        ItemGroup1: Record "NPR Item Group";
        ItemGroupPrinted: Record "NPR Item Group" temporary;
        DateFiltersApplied: Boolean;
        FirstDimValue: Boolean;
        OnlySales: Boolean;
        ShowItem: Boolean;
        Consumption: Decimal;
        Coverage: Decimal;
        CoveragePct: Decimal;
        Profit: Decimal;
        Sale: Decimal;
        SCoverage: Decimal;
        SCoveragePct: Decimal;
        SInventory: Decimal;
        SProfit: Decimal;
        SQty: Decimal;
        STurnoverPct: Decimal;
        SumConsumption: Decimal;
        SumSale: Decimal;
        TotalConsumption: Decimal;
        TotalCoverage: Decimal;
        TotalProfit: Decimal;
        TotalRevenue: Decimal;
        TSCoverage: Decimal;
        TSCoveragePct: Decimal;
        TSInventory: Decimal;
        TSProfit: Decimal;
        TSQty: Decimal;
        TSTurnoverPct: Decimal;
        TSumConsumption: Decimal;
        TSumSale: Decimal;
        TurnoverPct: Decimal;
        i: Integer;
        LevelsCount: Integer;
        GroupByText: Label 'Group by ';
        Text001: Label 'Percentage of last years sales';
        Text10600002: Label 'Salesstatistics/Itemgroupanalysis';
        TotalText: Label 'Total for Item Group %1';
        CaptionClassDim1: Text[30];
        Date: Text[30];
        TxtDim1: Text[30];
        TxtLabeldim1: Text[100];

    procedure Pct(var Value: Decimal; var Total: Decimal) Calculation: Decimal
    begin
        if (Value <> 0) and (Total <> 0) then
            Calculation := (Value / Total) * 100
        else
            Calculation := 0;
    end;
}

