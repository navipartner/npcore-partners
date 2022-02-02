report 6014457 "NPR Sales Stat/Analysis"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales StatAnalysis.rdlc';
    Caption = 'Sales Stat/Analysis';
    PreviewMode = Normal;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(ItemCategoryHeader; "Item Category")
        {
            CalcFields = "NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR Consumption (Amount)";
            DataItemTableView = sorting("Presentation Order");
            RequestFilterFields = "Code", "NPR Date Filter", "NPR Global Dimension 1 Filter", "NPR Global Dimension 2 Filter", "NPR Vendor Filter";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Today; Format(Today, 0, 4))
            {
            }
            column(DateFilter_ItemCategoryHeader; ItemCategoryHeader.GetFilter("NPR Date Filter"))
            {
            }
            column(Filters_ItemCategoryHeader; ItemCategoryHeader.GetFilters)
            {
            }
            column(No_ItemCategoryHeader; ItemCategoryHeader."Code")
            {
            }
            column(Description_ItemCategoryHeader; ItemCategoryHeader.Description)
            {
            }
            column(SalesQty_ItemCategoryHeader; ItemCategoryHeader."NPR Sales (Qty.)")
            {
            }
            column(ConsumptionAmount_ItemCategoryHeader; ItemCategoryHeader."NPR Consumption (Amount)")
            {
            }
            column(SaleLCY_ItemCategoryHeader; ItemCategoryHeader."NPR Sales (LCY)")
            {
            }
            column(Profit_ItemCategoryHeader; ItemCategoryHeader."NPR Sales (LCY)" - ItemCategoryHeader."NPR Consumption (Amount)")
            {
            }
            column(TotalProfit_ItemCategoryHeader; TotalProfit)
            {
            }
            column(TotalRevenue_ItemCategoryHeader; TotalRevenue)
            {
            }
            column(TotalConsumption_ItemCategoryHeader; TotalConsumption)
            {
            }
            column(ShowItem; ShowItem)
            {
            }
            column(Profit_ItemCategoryH; Profit)
            {
            }
            column(Coverage_ItemCategoryH; Coverage)
            {
            }
            column(CoveragePct_ItemCategoryH; CoveragePct)
            {
            }
            column(TurnoverPct_ItemCategoryH; TurnoverPct)
            {
            }
            column(Picture_CompanyInformation; CompanyInfo.Picture)
            {
            }
            column(ItemGrpNoLvl0; StrSubstNo(TotalText, "Code"))
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "Item Category Code" = FIELD("Code");
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
                    ItemCategoryHeader.CopyFilter("NPR Date Filter", "Date Filter");
                    ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "Global Dimension 1 Filter");
                    ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "Global Dimension 2 Filter");
                    ItemCategoryHeader.CopyFilter("NPR Vendor Filter", "Vendor No.");
                    if not ShowItem then
                        CurrReport.Break();
                end;
            }
            dataitem(ItemCategorySub1; "Item Category")
            {
                CalcFields = "NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR Consumption (Amount)";
                DataItemLink = "Parent Category" = FIELD("Code");
                DataItemTableView = SORTING("Presentation Order");
                column(No_ItemCategorySub1; "Code")
                {
                }
                column(Description_ItemCategorySub1; Description)
                {
                }
                column(SalesQty_ItemCategorySub1; "NPR Sales (Qty.)")
                {
                }
                column(ConsumptionAmount_ItemCategorySub1; "NPR Consumption (Amount)")
                {
                }
                column(SaleLCY_ItemCategorySub1; "NPR Sales (LCY)")
                {
                }
                column(Profit_ItemCategorySub1; Profit)
                {
                }
                column(Coverage_ItemCategorySub1; Coverage)
                {
                }
                column(CoveragePct_ItemCategorySub1; CoveragePct)
                {
                }
                column(TurnoverPct_ItemCategorySub1; TurnoverPct)
                {
                }
                column(ItemGrpNoLvl1; StrSubstNo(TotalText, "Code"))
                {
                }
                dataitem(Item1; Item)
                {
                    DataItemLink = "Item Category Code" = FIELD("Code");
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
                        ItemCategoryHeader.CopyFilter("NPR Date Filter", "Date Filter");
                        ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "Global Dimension 1 Filter");
                        ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "Global Dimension 2 Filter");
                        ItemCategoryHeader.CopyFilter("NPR Vendor Filter", "Vendor No.");
                        if not ShowItem then
                            CurrReport.Break();
                    end;
                }
                dataitem(ItemCategorySub2; "Item Category")
                {
                    CalcFields = "NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR Consumption (Amount)";
                    DataItemLink = "Parent Category" = FIELD("Code");
                    DataItemTableView = SORTING("Presentation Order");
                    column(No_ItemCategorySub2; "Code")
                    {
                    }
                    column(Description_ItemCategorySub2; Description)
                    {
                    }
                    column(SalesQty_ItemCategorySub2; "NPR Sales (Qty.)")
                    {
                    }
                    column(ConsumptionAmount_ItemCategorySub2; "NPR Consumption (Amount)")
                    {
                    }
                    column(SaleLCY_ItemCategorySub2; "NPR Sales (LCY)")
                    {
                    }
                    column(Profit_ItemCategorySub2; Profit)
                    {
                    }
                    column(Coverage_ItemCategorySub2; Coverage)
                    {
                    }
                    column(CoveragePct_ItemCategorySub2; CoveragePct)
                    {
                    }
                    column(TurnoverPct_ItemCategorySub2; TurnoverPct)
                    {
                    }
                    column(ItemGrpNoLvl2; StrSubstNo(TotalText, "Code"))
                    {
                    }
                    dataitem(Item2; Item)
                    {
                        DataItemLink = "Item Category Code" = FIELD("Code");
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
                            ItemCategoryHeader.CopyFilter("NPR Date Filter", "Date Filter");
                            ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "Global Dimension 1 Filter");
                            ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "Global Dimension 2 Filter");
                            ItemCategoryHeader.CopyFilter("NPR Vendor Filter", "Vendor No.");
                            if not ShowItem then
                                CurrReport.Break();
                        end;
                    }
                    dataitem(ItemCategorySub3; "Item Category")
                    {
                        CalcFields = "NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR Consumption (Amount)";
                        DataItemLink = "Parent Category" = FIELD("Code");
                        DataItemTableView = SORTING("Presentation Order");
                        column(No_ItemCategorySub3; "Code")
                        {
                        }
                        column(Description_ItemCategorySub3; Description)
                        {
                        }
                        column(SalesQty_ItemCategorySub3; "NPR Sales (Qty.)")
                        {
                        }
                        column(ConsumptionAmount_ItemCategorySub3; "NPR Consumption (Amount)")
                        {
                        }
                        column(SaleLCY_ItemCategorySub3; "NPR Sales (LCY)")
                        {
                        }
                        column(Profit_ItemCategorySub3; Profit)
                        {
                        }
                        column(Coverage_ItemCategorySub3; Coverage)
                        {
                        }
                        column(CoveragePct_ItemCategorySub3; CoveragePct)
                        {
                        }
                        column(TurnoverPct_ItemCategorySub3; TurnoverPct)
                        {
                        }
                        column(ItemGrpNoLvl3; StrSubstNo(TotalText, "Code"))
                        {
                        }
                        dataitem(Item3; Item)
                        {
                            DataItemLink = "Item Category Code" = FIELD("Code");
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
                                ItemCategoryHeader.CopyFilter("NPR Date Filter", "Date Filter");
                                ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "Global Dimension 1 Filter");
                                ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "Global Dimension 2 Filter");
                                ItemCategoryHeader.CopyFilter("NPR Vendor Filter", "Vendor No.");
                                if not ShowItem then
                                    CurrReport.Break();
                            end;
                        }
                        dataitem(ItemCategorySub4; "Item Category")
                        {
                            CalcFields = "NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR Consumption (Amount)";
                            DataItemLink = "Parent Category" = FIELD("Code");
                            DataItemTableView = SORTING("Presentation Order");
                            column(No_ItemCategorySub4; "Code")
                            {
                            }
                            column(Description_ItemCategorySub4; Description)
                            {
                            }
                            column(SalesQty_ItemCategorySub4; "NPR Sales (Qty.)")
                            {
                            }
                            column(ConsumptionAmount_ItemCategorySub4; "NPR Consumption (Amount)")
                            {
                            }
                            column(SaleLCY_ItemCategorySub4; "NPR Sales (LCY)")
                            {
                            }
                            column(Profit_ItemCategorySub4; Profit)
                            {
                            }
                            column(Coverage_ItemCategorySub4; Coverage)
                            {
                            }
                            column(CoveragePct_ItemCategorySub4; CoveragePct)
                            {
                            }
                            column(TurnoverPct_ItemCategorySub4; TurnoverPct)
                            {
                            }
                            column(ItemGrpNoLvl4; StrSubstNo(TotalText, "Code"))
                            {
                            }
                            dataitem(Item4; Item)
                            {
                                DataItemLink = "Item Category Code" = FIELD("Code");
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
                                    ItemCategoryHeader.CopyFilter("NPR Date Filter", "Date Filter");
                                    ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "Global Dimension 1 Filter");
                                    ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "Global Dimension 2 Filter");
                                    ItemCategoryHeader.CopyFilter("NPR Vendor Filter", "Vendor No.");
                                    if not ShowItem then
                                        CurrReport.Break();
                                end;
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if TempItemCategoryPrinted.Get("Code") or (not (LevelsCount >= 4)) then
                                    CurrReport.Skip();

                                TempItemCategoryPrinted."Code" := "Code";
                                TempItemCategoryPrinted.Insert();

                                CalcFields("NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR Consumption (Amount)");

                                Clear(Profit);
                                Clear(Coverage);
                                Clear(CoveragePct);
                                Clear(TurnoverPct);
                                Profit := "NPR Sales (LCY)" - "NPR Consumption (Amount)";
                                Coverage := Pct(Profit, "NPR Sales (LCY)");
                                CoveragePct := Pct(Profit, TotalProfit);
                                TurnoverPct := Pct("NPR Sales (LCY)", TotalRevenue);

                                SQty += "NPR Sales (Qty.)";
                                SumSale += "NPR Sales (LCY)";
                                SumConsumption += "NPR Consumption (Amount)";
                            end;

                            trigger OnPreDataItem()
                            begin
                                ItemCategoryHeader.CopyFilter("NPR Date Filter", "NPR Date Filter");
                                ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "NPR Global Dimension 1 Filter");
                                ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "NPR Global Dimension 2 Filter");
                                ItemCategoryHeader.CopyFilter("NPR Vendor Filter", "NPR Vendor Filter");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if TempItemCategoryPrinted.Get("Code") or (not (LevelsCount >= 3)) then
                                CurrReport.Skip();

                            TempItemCategoryPrinted."Code" := "Code";
                            TempItemCategoryPrinted.Insert();

                            CalcFields("NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR Consumption (Amount)");

                            Clear(Profit);
                            Clear(Coverage);
                            Clear(CoveragePct);
                            Clear(TurnoverPct);
                            Profit := "NPR Sales (LCY)" - "NPR Consumption (Amount)";
                            Coverage := Pct(Profit, "NPR Sales (LCY)");
                            CoveragePct := Pct(Profit, TotalProfit);
                            TurnoverPct := Pct("NPR Sales (LCY)", TotalRevenue);

                            SQty += "NPR Sales (Qty.)";
                            SumSale += "NPR Sales (LCY)";
                            SumConsumption += "NPR Consumption (Amount)";
                        end;

                        trigger OnPreDataItem()
                        begin
                            ItemCategoryHeader.CopyFilter("NPR Date Filter", "NPR Date Filter");
                            ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "NPR Global Dimension 1 Filter");
                            ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "NPR Global Dimension 2 Filter");
                            ItemCategoryHeader.CopyFilter("NPR Vendor Filter", "NPR Vendor Filter");
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if TempItemCategoryPrinted.Get("Code") or (not (LevelsCount >= 2)) then
                            CurrReport.Skip();

                        TempItemCategoryPrinted."Code" := "Code";
                        TempItemCategoryPrinted.Insert();

                        CalcFields("NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR Consumption (Amount)");

                        Clear(Profit);
                        Clear(Coverage);
                        Clear(CoveragePct);
                        Clear(TurnoverPct);
                        Profit := "NPR Sales (LCY)" - "NPR Consumption (Amount)";
                        Coverage := Pct(Profit, "NPR Sales (LCY)");
                        CoveragePct := Pct(Profit, TotalProfit);
                        TurnoverPct := Pct("NPR Sales (LCY)", TotalRevenue);

                        SQty += "NPR Sales (Qty.)";
                        SumSale += "NPR Sales (LCY)";
                        SumConsumption += "NPR Consumption (Amount)";
                    end;

                    trigger OnPreDataItem()
                    begin
                        ItemCategoryHeader.CopyFilter("NPR Date Filter", "NPR Date Filter");
                        ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "NPR Global Dimension 1 Filter");
                        ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "NPR Global Dimension 2 Filter");
                        ItemCategoryHeader.CopyFilter("NPR Vendor Filter", "NPR Vendor Filter");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if TempItemCategoryPrinted.Get("Code") or (not (LevelsCount >= 1)) then
                        CurrReport.Skip();

                    TempItemCategoryPrinted."Code" := "Code";
                    TempItemCategoryPrinted.Insert();

                    CalcFields("NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR Consumption (Amount)");

                    Clear(Profit);
                    Clear(Coverage);
                    Clear(CoveragePct);
                    Clear(TurnoverPct);
                    Profit := "NPR Sales (LCY)" - "NPR Consumption (Amount)";
                    Coverage := Pct(Profit, "NPR Sales (LCY)");
                    CoveragePct := Pct(Profit, TotalProfit);
                    TurnoverPct := Pct("NPR Sales (LCY)", TotalRevenue);

                    SQty += "NPR Sales (Qty.)";
                    SumSale += "NPR Sales (LCY)";
                    SumConsumption += "NPR Consumption (Amount)";
                end;

                trigger OnPreDataItem()
                begin
                    ItemCategoryHeader.CopyFilter("NPR Date Filter", "NPR Date Filter");
                    ItemCategoryHeader.CopyFilter("NPR Global Dimension 1 Filter", "NPR Global Dimension 1 Filter");
                    ItemCategoryHeader.CopyFilter("NPR Global Dimension 2 Filter", "NPR Global Dimension 2 Filter");
                    ItemCategoryHeader.CopyFilter("NPR Vendor Filter", "NPR Vendor Filter");
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

                if TempItemCategoryPrinted.Get("Code") then
                    CurrReport.Skip();

                TempItemCategoryPrinted."Code" := "Code";
                TempItemCategoryPrinted.Insert();

                CalcFields("NPR Sales (Qty.)", "NPR Sales (LCY)", "NPR Consumption (Amount)");

                Clear(Profit);
                Clear(Coverage);
                Clear(CoveragePct);
                Clear(TurnoverPct);
                Profit := "NPR Sales (LCY)" - "NPR Consumption (Amount)";
                Coverage := Pct(Profit, "NPR Sales (LCY)");
                CoveragePct := Pct(Profit, TotalProfit);
                TurnoverPct := Pct("NPR Sales (LCY)", TotalRevenue);

                SQty += "NPR Sales (Qty.)";
                SumSale += "NPR Sales (LCY)";
                SumConsumption += "NPR Consumption (Amount)";
            end;

            trigger OnPreDataItem()
            begin
                TempItemCategoryPrinted.SetCurrentKey("Code");
                TempItemCategoryPrinted.DeleteAll();
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
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Request)
                {
                    Caption = 'Request';
                    field("Show Item"; ShowItem)
                    {
                        Caption = 'Print Items';

                        ToolTip = 'Specifies the value of the Print Items field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Only Sales"; OnlySales)
                    {
                        Caption = 'Only Sales';

                        ToolTip = 'Specifies the value of the Only Sales field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Levels Count"; LevelsCount)
                    {
                        Caption = 'Levels';

                        ToolTip = 'Specifies the value of the Levels field';
                        ApplicationArea = NPRRetail;
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
        Report_Caption = 'Sales Statistics/Item Category Analysis';
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

        ItemCategory1.Reset();
        ItemCategoryHeader.CopyFilter("NPR Date Filter", ItemCategory1."NPR Date Filter");
        if ItemCategory1.FindSet() then
            repeat
                ItemCategory1.CalcFields("NPR Sales (LCY)", "NPR Consumption (Amount)");
                TotalRevenue += ItemCategory1."NPR Sales (LCY)";
                TotalConsumption += ItemCategory1."NPR Consumption (Amount)";
            until ItemCategory1.Next() = 0;

        TotalProfit := TotalRevenue - TotalConsumption;
        TotalCoverage := Pct(TotalProfit, TotalRevenue);
    end;

    var
        CompanyInfo: Record "Company Information";
        ItemCategory1: Record "Item Category";
        TempItemCategoryPrinted: Record "Item Category" temporary;
        OnlySales: Boolean;
        ShowItem: Boolean;
        Coverage: Decimal;
        CoveragePct: Decimal;
        Profit: Decimal;
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
        LevelsCount: Integer;
        GroupByText: Label 'Group by ';
        TotalText: Label 'Total for Item Category %1';
        CaptionClassDim1: Text[30];
        TxtDim1: Text;
        TxtLabeldim1: Text[100];

    procedure Pct(Value: Decimal; Total: Decimal) Calculation: Decimal
    begin
        if (Value <> 0) and (Total <> 0) then
            Calculation := (Value / Total) * 100
        else
            Calculation := 0;
    end;
}

