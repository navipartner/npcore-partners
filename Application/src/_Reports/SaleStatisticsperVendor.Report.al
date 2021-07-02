report 6014416 "NPR Sale Statistics per Vendor"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sale Statistics per Vendor.rdlc';
    Caption = 'Sale Statistics Per Vendor';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem(Vendor; Vendor)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Search Name", "Vendor Posting Group";
            column(PageNoCaptionLbl; PageNoCaptionLbl)
            {
            }
            column(Report_Caption; Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Date_Filters_Caption; Date_Filters_Caption_Lbl)
            {
            }
            column(Creditor_Filter_Caption; Creditor_Filter_Caption_Lbl)
            {
            }
            column(Name_Caption; Name_Caption_Lbl)
            {
            }
            column(Inventory_Caption; Inventory_Caption_Lbl)
            {
            }
            column(InventoryValue_Caption; InventoryValue_Caption_Lbl)
            {
            }
            column(Unit_Value_Caption; Unit_Value_Caption_Lbl)
            {
            }
            column(Profit_LCY_Caption; Profit_LCY_Caption_Lbl)
            {
            }
            column(Profit_Pct_Caption; Profit_Pct_Caption_Lbl)
            {
            }
            column(Purchases_LCY_Caption; Purchases_LCY_Caption_Lbl)
            {
            }
            column(Sales_Qty_Caption; Sales_Qty_Caption_Lbl)
            {
            }
            column(Cost_Caption; Cost_Caption_Lbl)
            {
            }
            column(Sale_Caption; Sale_Caption_Lbl)
            {
            }
            column(Speed_Caption; Speed_Caption_Lbl)
            {
            }
            column(Avg_Inventory_Caption; Avg_Inventory_Caption_Lbl)
            {
            }
            column(OnlyTotal; TotalOnly)
            {
            }
            column(DateFilter_Vendor; DateFilterVendor)
            {
            }
            column(No_Vendor; Vendor."No.")
            {
            }
            column(Name_Vendor; Vendor.Name)
            {
            }
            column(Avoid0Sales; AvoidZeroSales)
            {
            }
            column(InventoryDate; InventoryDate)
            {
            }
            column(NextPageGroupNo; NextPageGroupNo)
            {
            }
            dataitem(Item; Item)
            {
                CalcFields = "Sales (Qty.)", "COGS (LCY)", "Sales (LCY)", "Purchases (LCY)";
                DataItemLink = "Vendor No." = FIELD("No.");
                PrintOnlyIfDetail = false;
                RequestFilterFields = "Item Category Code", "Location Filter", "Date Filter";
                column(No_Item; Item."No.")
                {
                }
                column(Description_Item; Item.Description)
                {
                }
                column(Net_Change_Item; Item1."Net Change")
                {
                }
                column(InventoryValuation; InventoryValuation)
                {
                }
                column(ActualSales; ActualSales)
                {
                }
                column(db; db)
                {
                }
                column(dg; dg)
                {
                }
                column(PurchasesLCY_Item; Item."Purchases (LCY)")
                {
                }
                column(SalesQty_Item; Item."Sales (Qty.)")
                {
                }
                column(COGSLCY_Item; Item."COGS (LCY)")
                {
                }
                column(SalesLCY_Item; Item."Sales (LCY)")
                {
                }
                column(SalesDb; SalesDb)
                {
                }
                column(SalesDg; SalesDg)
                {
                }
                column(Speed; Speed)
                {
                }
                column(Inventory; Inventory)
                {
                }
                column(AvgInventory; AvgInventory)
                {
                }
                column(Name_Footer2; Vendor.Name + Text10600000)
                {
                }
                column(TextNetChangeDate; TextNetChangeDate)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    StartDateInventory := 0;
                    EndDateInventory := 0;
                    PeriodPurchaseQty := 0;
                    ItemUsage := 0;
                    AvgInventory := 0;
                    Speed := 0;
                    Inventory := 0;

                    Item1.Get("No.");
                    Item1.CalcFields("Net Change");

                    if "Price Includes VAT" then begin
                        if VatPostingSetup.Get("VAT Bus. Posting Gr. (Price)", "VAT Prod. Posting Group") then;
                        ActualSales := Item1."Net Change" * ("Unit Price" / (1 + (VatPostingSetup."VAT %" / 100)));
                    end else
                        ActualSales := Item1."Net Change" * "Unit Price";

                    InventoryValuation := (Item1."Net Change" * "Last Direct Cost");
                    db := ActualSales - InventoryValuation;

                    if ("Unit Price" <> 0) and (ActualSales <> 0) then
                        dg := 100 * (db / ActualSales)
                    else
                        dg := 0;

                    SalesDb := ("Sales (LCY)" - "COGS (LCY)");

                    if "Sales (LCY)" <> 0 then
                        SalesDg := 100 * (SalesDb / "Sales (LCY)")
                    else
                        SalesDg := 0;

                    Item2.Reset();
                    if Item2.Get(Item."No.") then begin
                        Item2.SetFilter("Date Filter", '..%1', StartDate);
                        Item2.CalcFields("Net Change");
                        StartDateInventory := Item2."Net Change";
                    end;

                    Item2.Reset();
                    if Item2.Get(Item."No.") then begin
                        Item2.SetFilter("Date Filter", '..%1', EndDate);
                        Item2.CalcFields("Net Change");
                        EndDateInventory := Item2."Net Change";
                    end;

                    Item2.Reset();
                    if Item2.Get(Item."No.") then begin
                        Item2.SetRange(Item2."Date Filter", StartDate, EndDate);
                        Item2.CalcFields("Purchases (Qty.)");
                        PeriodPurchaseQty := Item2."Purchases (Qty.)";
                    end;
                    ItemUsage := (StartDateInventory + PeriodPurchaseQty) - EndDateInventory;

                    if (StartDateInventory + EndDateInventory) <> 0 then
                        AvgInventory := (StartDateInventory + EndDateInventory) / 2;

                    if (ItemUsage <> 0) and (AvgInventory <> 0) then
                        Speed := ItemUsage / AvgInventory;

                    InventoryValVendor += InventoryValuation;
                    SalesValVendor += ActualSales;
                    dbVendor := dbVendor + db;
                    NetChangeVendor += Item1."Net Change";
                    SalesQtyVendor += Item."Sales (Qty.)";
                    COGS_LCY_Vendor += Item."COGS (LCY)";
                    Sales_LCY_Vendor += Item."Sales (LCY)";
                    Purchases_LCY_Vendor += Item."Purchases (LCY)";
                    SpeedVendor += Speed;
                    AvgInventory_Vendor += AvgInventory;
                end;

                trigger OnPreDataItem()
                begin
                    Item.SetFilter("Location Filter", GetFilter("Location Filter"));
                    Item1.CopyFilters(Item);
                    Item1.SetFilter("Date Filter", '..%1', InventoryDate);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if PrintOnePerPage then
                    NextPageGroupNo += 1;
            end;

            trigger OnPreDataItem()
            begin
                NextPageGroupNo := 1;
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            column(Number_Integer; Integer.Number)
            {
            }
            column(InventoryValVendor; InventoryValVendor)
            {
            }
            column(SalesValVendor; SalesValVendor)
            {
            }
            column(dbVendor; dbVendor)
            {
            }
            column(NetChangeVendor; NetChangeVendor)
            {
            }
            column(SalesQtyVendor; SalesQtyVendor)
            {
            }
            column(COGS_LCY_Vendor; COGS_LCY_Vendor)
            {
            }
            column(Sales_LCY_Vendor; Sales_LCY_Vendor)
            {
            }
            column(Purchases_LCY_Vendor; Purchases_LCY_Vendor)
            {
            }
            column(SpeedVendor; SpeedVendor)
            {
            }
            column(AvgInventory_Vendor; AvgInventory_Vendor)
            {
            }
            column(Total_Caption; Total_Caption_Lbl)
            {
            }
            column(DgVendor; DgVendor)
            {
            }
            column(SalesDbVendor; SalesDbVendor)
            {
            }
            column(SalesDgVendor; SalesDgVendor)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if SalesValVendor <> 0 then
                    DgVendor := 100 * (dbVendor / SalesValVendor)
                else
                    DgVendor := 0;

                SalesDbVendor := (Sales_LCY_Vendor - COGS_LCY_Vendor);

                if Sales_LCY_Vendor <> 0 then
                    SalesDgVendor := 100 * (SalesDbVendor / Sales_LCY_Vendor)
                else
                    SalesDgVendor := 0;
            end;
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
                    Caption = 'Options';
                    field("Inventory Date"; InventoryDate)
                    {
                        Caption = 'Inventory Per Date';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Inventory Per Date field';
                    }
                    field("Print One Per Page"; PrintOnePerPage)
                    {
                        Caption = 'New Page Per Creditor';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the New Page Per Creditor field';
                    }
                    field("Total Only"; TotalOnly)
                    {
                        Caption = 'Totals Only';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Totals Only field';
                    }
                    field(Avoid0Sales; AvoidZeroSales)
                    {
                        Caption = 'Avoid 0 Sales';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Avoid 0 Sales field';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            InventoryDate := Today();
        end;
    }

    labels
    {
        Page_Caption = 'Page';
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
        if Item.GetFilter("Date Filter") <> '' then begin
            StartDate := Item.GetRangeMin("Date Filter");
            EndDate := Item.GetRangeMax("Date Filter");
        end;

        if Item.GetFilters <> '' then
            LocationFilterItem := Item.GetFilters;
        if Vendor.GetFilters <> '' then
            DateFilterVendor := Vendor.GetFilters
        else
            DateFilterVendor := 'As at ' + Format(InventoryDate);

        NextPageGroupNo := 1;
    end;

    var
        CompanyInfo: Record "Company Information";
        Item1: Record Item;
        Item2: Record Item;
        VatPostingSetup: Record "VAT Posting Setup";
        AvoidZeroSales: Boolean;
        TotalOnly: Boolean;
        PrintOnePerPage: Boolean;
        EndDate: Date;
        InventoryDate: Date;
        StartDate: Date;
        ActualSales: Decimal;
        AvgInventory: Decimal;
        AvgInventory_Vendor: Decimal;
        COGS_LCY_Vendor: Decimal;
        db: Decimal;
        dbVendor: Decimal;
        dg: Decimal;
        DgVendor: Decimal;
        EndDateInventory: Decimal;
        InventoryValuation: Decimal;
        InventoryValVendor: Decimal;
        ItemUsage: Decimal;
        NetChangeVendor: Decimal;
        PeriodPurchaseQty: Decimal;
        Purchases_LCY_Vendor: Decimal;
        Sales_LCY_Vendor: Decimal;
        SalesDb: Decimal;
        SalesDbVendor: Decimal;
        SalesDg: Decimal;
        SalesDgVendor: Decimal;
        SalesQtyVendor: Decimal;
        SalesValVendor: Decimal;
        Speed: Decimal;
        SpeedVendor: Decimal;
        StartDateInventory: Decimal;
        NextPageGroupNo: Integer;
        Avg_Inventory_Caption_Lbl: Label 'Average Inventory';
        Cost_Caption_Lbl: Label 'COGS (LCY)';
        Creditor_Filter_Caption_Lbl: Label 'Creditor filter';
        Date_Filters_Caption_Lbl: Label 'Date filter';
        InventoryValue_Caption_Lbl: Label 'Inv.Value @ Cost';
        Unit_Value_Caption_Lbl: Label 'Inv. Value @ S.Price';
        Inventory_Caption_Lbl: Label 'Inventory per Date';
        Name_Caption_Lbl: Label 'Name';
        PageNoCaptionLbl: Label 'Page';
        Profit_Pct_Caption_Lbl: Label 'Profit %';
        Profit_LCY_Caption_Lbl: Label 'Profit (LCY)';
        Purchases_LCY_Caption_Lbl: Label 'Purchases (LCY)';
        Sale_Caption_Lbl: Label 'Sales (LCY)';
        Sales_Qty_Caption_Lbl: Label 'Sales (Qty)';
        Report_Caption_Lbl: Label 'Sale Statistics per Vendor';
        Speed_Caption_Lbl: Label 'Speed';
        Total_Caption_Lbl: Label 'Total';
        Text10600000: Label ' total';
        DateFilterVendor: Text;
        LocationFilterItem: Text;
        TextNetChangeDate: Text;
}

