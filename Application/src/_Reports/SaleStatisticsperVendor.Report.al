report 6014416 "NPR Sale Statistics per Vendor"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sale Statistics per Vendor.rdlc';
    Caption = 'Sale Statistics Per Vendor';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Search Name", "Vendor Posting Group";
            column(COMPANYNAME; CompanyName)
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
                CalcFields = "Net Change", "Sales (Qty.)", "COGS (LCY)", "Sales (LCY)", "Purchases (LCY)";
                DataItemLink = "Vendor No." = FIELD("No.");
                PrintOnlyIfDetail = false;
                RequestFilterFields = "Item Category Code", "Location Filter", "Date Filter";
                column(Description_Item; Item.Description)
                {
                }
                column(No_Item; Item."No.")
                {
                }
                column(InventoryOnDate; "Net Change")
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

                    if "Price Includes VAT" then begin
                        if VatPostingSetup.Get("VAT Bus. Posting Gr. (Price)", "VAT Prod. Posting Group") then;
                        ActualSales := "Net Change" * ("Unit Price" / (1 + (VatPostingSetup."VAT %" / 100)));
                    end else
                        ActualSales := "Net Change" * "Unit Price";

                    InventoryValuation := ("Net Change" * "Last Direct Cost");
                    db := ActualSales - InventoryValuation;

                    if ("Unit Price" <> 0) and (ActualSales <> 0) then
                        dg := 100 * (db / ActualSales)
                    else
                        dg := 0;

                    SalesDb := ("Sales (LCY)" - "COGS (LCY)");

                    // if ("Unit Price" <> 0) and (ActualSales <> 0) then
                    //     DgTotal := (Db / "ActualSales") * 100
                    // else
                    //     DgTotal := 0;

                    if "Sales (LCY)" <> 0 then
                        SalesDg := 100 * (SalesDb / "Sales (LCY)")
                    else
                        SalesDg := 0;

                    Item2.Reset();
                    if Item2.Get(Item."No.") then begin
                        //Item2.SetFilter("Date Filter", '..%1', StartDate);
                        Item2.CalcFields("Net Change");
                        StartDateInventory := Item2."Net Change";
                    end;

                    Item2.Reset();
                    if Item2.Get(Item."No.") then begin
                        //Item2.SetFilter("Date Filter", '..%1', EndDate);
                        Item2.CalcFields("Net Change");
                        EndDateInventory := Item2."Net Change";
                    end;

                    Item2.Reset();
                    if Item2.Get(Item."No.") then begin
                        //Item2.SetRange(Item2."Date Filter", StartDate, EndDate);
                        Item2.CalcFields("Purchases (Qty.)");
                        PeriodPurchaseQty := Item2."Purchases (Qty.)";
                    end;
                    ItemUsage := (StartDateInventory + PeriodPurchaseQty) - EndDateInventory;

                    if (StartDateInventory + EndDateInventory) <> 0 then
                        AvgInventory := (StartDateInventory + EndDateInventory) / 2;

                    if (ItemUsage <> 0) and (AvgInventory <> 0) then
                        Speed := ItemUsage / AvgInventory;
                end;

                trigger OnPreDataItem()
                begin
                    Item.SetFilter("Date Filter", '..%1', InventoryDate);
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

                        ToolTip = 'Specifies the value of the Inventory Per Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print One Per Page"; PrintOnePerPage)
                    {
                        Caption = 'New Page Per Creditor';

                        ToolTip = 'Specifies the value of the New Page Per Creditor field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Total Only"; TotalOnly)
                    {
                        Caption = 'Totals Only';

                        ToolTip = 'Specifies the value of the Totals Only field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Avoid0Sales; AvoidZeroSales)
                    {
                        Caption = 'Exclude 0 Sales';

                        ToolTip = 'Specifies the value without 0 Sales';
                        ApplicationArea = NPRRetail;
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
        Report_Caption_Lbl = 'Sale Statistics per Vendor';
        Page_Caption = 'Page';
        Inventory_Caption_Lbl = 'Inventory per Date';
        Avg_Inventory_Caption_Lbl = 'Average Inventory';
        Cost_Caption_Lbl = 'COGS (LCY)';
        InventoryValue_Caption_Lbl = 'Inv.Value @ Cost';
        Unit_Value_Caption_Lbl = 'Inv. Value @ S.Price';
        Profit_Pct_Caption_Lbl = 'Profit %';
        Profit_LCY_Caption_Lbl = 'Profit (LCY)';
        Purchases_LCY_Caption_Lbl = 'Purchases (LCY)';
        Sale_Caption_Lbl = 'Sales (LCY)';
        Sales_Qty_Caption_Lbl = 'Sales (Qty)';
        Speed_Caption_Lbl = 'Speed';
        Total_Caption_Lbl = 'Total';
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);

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
        Item2: Record Item;
        VatPostingSetup: Record "VAT Posting Setup";
        AvoidZeroSales: Boolean;
        TotalOnly: Boolean;
        PrintOnePerPage: Boolean;
        InventoryDate: Date;
        ActualSales: Decimal;
        AvgInventory: Decimal;
        db: Decimal;
        dg: Decimal;
        EndDateInventory: Decimal;
        InventoryValuation: Decimal;
        ItemUsage: Decimal;
        PeriodPurchaseQty: Decimal;
        SalesDb: Decimal;
        SalesDg: Decimal;
        Speed: Decimal;
        StartDateInventory: Decimal;
        NextPageGroupNo: Integer;
        Text10600000: label ' total';
        DateFilterVendor: Text;
        LocationFilterItem: Text;
        TextNetChangeDate: Text;
}