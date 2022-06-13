﻿report 6014430 "NPR Item Sales Stats/Provider"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Sales StatisticsProvider.rdlc';
    Caption = 'Item Sales Statistics by Vendor';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            column(COMPANYNAME; CompanyName)
            {
            }
            column(CompanyInfoPicture; CompanyInformation.Picture)
            {
            }
            column(GlobalLanguage; GlobalLanguage)
            {
            }
            column(ShowItem; ShowItem)
            {
                AutoFormatType = 1;
            }
            column(ShowItemWithSales; ShowItemWithSales)
            {
                AutoFormatType = 2;
            }
            column(ShowItemCategory; ShowItemCategory)
            {
            }
            column(DateFilter; DateFilter)
            {
            }
            column(FilterDesc; FilterDesc)
            {
            }
            column(InventoryValueDesc; InventoryValueDesc)
            {
            }

            trigger OnAfterGetRecord()
            begin
                DateFilter := Text10600002 + ' ' + Format(StartDate) + '..' + Format(EndDate);
            end;
        }
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(VendorNo; Vendor."No.")
            {
            }
            column(VendorName; Vendor.Name)
            {
            }
            column(VisVarer_Vendor; ShowItem)
            {
                AutoFormatType = 1;
            }
            column(ShowItemWithSales_Vendor; ShowItemWithSales)
            {
                AutoFormatType = 2;
            }
            column(ShowItemCategory_Vendor; ShowItemCategory)
            {
            }
            dataitem(Varegruppe; "Item Category")
            {
                DataItemTableView = SORTING(Code);
                PrintOnlyIfDetail = true;
                column(ItemCategoryDesc; ItemCategoryDesc)
                {
                }
                column(ItemCategoryNo; Varegruppe.Code)
                {
                }
                column(ItemCategoryFooterDesc; ItemCategoryFooterDesc)
                {
                }
                dataitem(Item; Item)
                {
                    CalcFields = "Sales (Qty.)", "Sales (LCY)", "Scheduled Receipt (Qty.)", "Qty. on Purch. Order", "COGS (LCY)", "Purchases (Qty.)";
                    DataItemLink = "Item Category Code" = FIELD(Code);
                    RequestFilterFields = "Global Dimension 1 Filter", "Date Filter";
                    column(ItemDesc; Item.Description)
                    {
                    }
                    column(ItemVendorItemNo; Item."Vendor Item No.")
                    {
                    }
                    column(ItemNo; Item."No.")
                    {
                    }
                    column(ItemItemCategory; Item."Item Category Code")
                    {
                    }
                    column(ItemPurchasesQty; Item."Purchases (Qty.)")
                    {
                        AutoFormatType = 1;
                    }
                    column(ItemSalesQty; Item."Sales (Qty.)")
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(ItemSalesLCY; Item."Sales (LCY)")
                    {
                        AutoFormatType = 1;
                    }
                    column(db; GrossCoverage)
                    {
                        AutoFormatType = 1;
                    }
                    column(dg; Dg)
                    {
                        AutoFormatType = 1;
                    }
                    column(Item2NetChange; Item2."Net Change")
                    {
                        AutoFormatType = 1;
                    }
                    column(StockValue; StockValue)
                    {
                        AutoFormatType = 1;
                    }
                    column(ItemQtyonPurchOrder; Item."Qty. on Purch. Order")
                    {
                        AutoFormatType = 1;
                    }
                    column(TurnoverRate; TurnoverRate)
                    {
                        AutoFormatType = 1;
                    }
                    column(forpct; ProfitPriceCoveragePct)
                    {
                        AutoFormatType = 1;
                    }
                    column(ItemFooterDesc; ItemFooterDesc)
                    {
                    }
                    column(GnsBeholdningKpris; AvgInvPrice)
                    {
                    }
                    column(antalmdr; MonthsCount)
                    {
                    }
                    column(SalesCost; SalesCost)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        ItemFooterDesc := Text10600005 + Varegruppe.Code + ' ' + Varegruppe.Description;
                        if ShowItemWithSales and ("Sales (Qty.)" = 0) then
                            CurrReport.Skip();

                        Clear(PurchPrice);
                        Clear(StockValue);
                        Clear(PeriodSales);
                        Clear(TurnoverRate);
                        Clear(ItemInventory);
                        Clear(AvgInvPrice);

                        //Lagerbeholdning Ultimo
                        Item2.Get("No.");
                        Item2.SetFilter("Date Filter", '..%1', ValueDate);
                        Item2.CalcFields("Net Change");

                        //Lagervaerdi
                        if (ValueMethod = ValueMethod::"kostpris (gns.)") then
                            ItemCostMgt.CalculateAverageCost(Item, GNSCostPrice, PurchPrice);

                        if (ValueMethod = ValueMethod::"sidste koebspris") then
                            GNSCostPrice := "Last Direct Cost";

                        SalesCost := ("Sales (Qty.)" * GNSCostPrice);

                        Clear(PurchPrice);
                        PurchPrice := Round(GNSCostPrice * Item2."Net Change");
                        Hjemtagelsesomk := Round((GNSCostPrice * Item2."Net Change") / 100 * "Indirect Cost %");
                        StockValue := PurchPrice + Hjemtagelsesomk;
                        PeriodSales := "Sales (LCY)";

                        //Calculate  Gross Coverage
                        GrossCoverage := "Sales (LCY)" - "COGS (LCY)";

                        if "Sales (LCY)" <> 0 then
                            Dg := (GrossCoverage / "Sales (LCY)") * 100
                        else
                            Dg := 0;

                        //Turnover rate
                        for x := 0 to MonthsCount do
                            ItemInventory += Calculate(0D, CalcDate('<-' + Format(x) + Text10600003 + '>', EndDate));

                        AvgInvPrice := (ItemInventory / (MonthsCount + 1));

                        if AvgInvPrice <> 0 then begin
                            TurnoverRate := (SalesCost / AvgInvPrice) * (12 / (MonthsCount + 1));
                            ProfitPriceCoveragePct := (GrossCoverage * 100 / AvgInvPrice) * (12 / (MonthsCount + 1));
                        end
                        else begin
                            TurnoverRate := 0;
                            ProfitPriceCoveragePct := 0;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetFilter("Date Filter", '%1..%2', StartDate, EndDate);
                        SetRange("Vendor No.", Vendor."No.");
                        StartDate := GetRangeMin("Date Filter");
                        EndDate := GetRangeMax("Date Filter");
                        MonthsCount := (Date2DMY(EndDate, 3) - Date2DMY(StartDate, 3)) * 12 + (Date2DMY(EndDate, 2) - Date2DMY(StartDate, 2));
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    ItemCategoryDesc := Text10600004 + Code + ' ' + Description;
                    ItemCategoryFooterDesc := Text10600006 + Vendor.Name;
                end;

                trigger OnPreDataItem()
                begin
                    FilterDesc := Text10600001 + GetFilter(Code) + Text10600007 + Item.GetFilter("Global Dimension 1 Filter");
                    InventoryValueDesc := StrSubstNo(Text10600008, ValueDate, ValueMethod);
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Setting)
                {
                    Caption = 'Setting';
                    field("Value Date"; ValueDate)
                    {

                        Caption = 'Value Date';
                        ToolTip = 'Specifies the value of the Value Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Start Date"; StartDate)
                    {
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the value of the Start Date field';
                        ApplicationArea = NPRRetail;
                        ShowMandatory = true;
                    }
                    field("End date"; EndDate)
                    {
                        Caption = 'End date';
                        ToolTip = 'Specifies the value of the End Date field';
                        ApplicationArea = NPRRetail;
                        ShowMandatory = true;
                    }
                    field("Show Item With Sales"; ShowItemWithSales)
                    {

                        Caption = 'Only Items With Sale';
                        ToolTip = 'Specifies the value of the Only Items With Sale field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Item"; ShowItem)
                    {

                        Caption = 'View Items';
                        ToolTip = 'Specifies the value of the View Items field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Item Category"; ShowItemCategory)
                    {

                        Caption = 'Show Item Category';
                        ToolTip = 'Specifies the value of the Show Item Category field';
                        ApplicationArea = NPRRetail;
                    }
                    field(InventoryValueIsBasedOn; ValueMethod)
                    {

                        Caption = 'Inventory Value Is Based On:';
                        OptionCaption = 'Last Purchase Price,Cost Price (avg.)';
                        ToolTip = 'Specifies the value of the Inventory Value Is Based On: field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    labels
    {
        OnlyItemsWithSaleCap = 'Only items with sales';
        ShowItemsCap = 'Show items';
        Report_Caption = 'Item Sales Statistics by Vendor';
        Desc_Cap = 'Description';
        VendorItemNo_Cap = 'Supplier item no.';
        ItemNo_Cap = 'No.';
        ItemItemCategory_Cap = 'Belong to Item Cat. no.';
        Purchase_Cap = 'Purchase (qty)';
        SalesQty_Cap = 'Sales (qty)';
        SalesAmount_Cap = 'Sales (DKK)';
        db_Cap = 'Gross';
        dg_Cap = 'Advance %';
        varerec_Cap = 'Qty in inventory';
        lagerv_Cap = 'Value in inventory';
        Qty_cap = 'Anticipated acces';
        Oms_Cap = 'Turnover rate';
        for_Cap = 'Profit/Price coverrage %';
        Page_Caption = 'Page';
    }

    trigger OnPreReport()
    var
        DateNotPopulatedErr: Label 'Fields Start date and End Date need to be populated!';
        StartDateHigherThanEndDateErr: Label 'Field Start date must contain date that is before the End date';
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);

        if ValueDate = 0D then
            ValueDate := Today();

        if (StartDate = 0D) or (EndDate = 0D) then
            Error(DateNotPopulatedErr);

        if (StartDate > EndDate) then
            Error(StartDateHigherThanEndDateErr);
    end;

    var
        CompanyInformation: Record "Company Information";
        Item1: Record Item;
        Item2: Record Item;
        ItemCostMgt: Codeunit ItemCostManagement;
        ShowItem: Boolean;
        ShowItemCategory: Boolean;
        ShowItemWithSales: Boolean;
        EndDate: Date;
        StartDate: Date;
        ValueDate: Date;
        GrossCoverage: Decimal;
        Dg: Decimal;
        ProfitPriceCoveragePct: Decimal;
        AvgInvPrice: Decimal;
        GNSCostPrice: Decimal;
        Hjemtagelsesomk: Decimal;
        ItemInventory: Decimal;
        PeriodSales: Decimal;
        PurchPrice: Decimal;
        SalesCost: Decimal;
        StockValue: Decimal;
        TurnoverRate: Decimal;
        MonthsCount: Integer;
        x: Integer;
        Text10600001: Label 'Chosen Vendors';
        Text10600007: Label 'Department';
        Text10600002: Label 'For the period';
        Text10600008: Label 'Inventory is equal to inventories per %1 * %2 + delivery costs';
        Text10600004: Label 'Item Category';
        Text10600003: Label 'M';
        Text10600006: Label 'Total ';
        Text10600005: Label 'Total for the Item Category';
        ValueMethod: Option "sidste koebspris","kostpris (gns.)";
        DateFilter: Text[100];
        FilterDesc: Text[200];
        InventoryValueDesc: Text[200];
        ItemFooterDesc: Text[200];
        ItemCategoryDesc: Text[200];
        ItemCategoryFooterDesc: Text[200];

    internal procedure Calculate(DateFrom: Date; DateTo: Date): Decimal
    begin
        Item1.SetRange("Date Filter", DateFrom, DateTo);
        Item1.Get(Item."No.");
        Item1.CalcFields("Purchases (LCY)", "COGS (LCY)");
        Exit(Item1."Purchases (LCY)" - (Item1."COGS (LCY)"));
    end;
}

