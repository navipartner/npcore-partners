report 6014533 "NPR Inventory - flow"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Inventory - flow.rdlc'; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    Caption = 'Inventory Flow';
    UseRequestPage = true;
    UseSystemPrinter = true;
    dataset
    {
        dataitem(Vendor; Vendor)
        {
            RequestFilterFields = "No.", "Date Filter";
            column(No_Vendor; Vendor."No.")
            {
            }
            column(Name_Vendor; Vendor.Name)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(ShowVendorSection_Vendor; ShowVendorSection)
            {
            }
            column(Filters_Vendor; Vendor.GetFilters)
            {
            }
            column(CompanyInfoPicture; CompanyInfo.Picture)
            {
            }
            dataitem(Item; Item)
            {
                CalcFields = "Sales (Qty.)", "Purchases (Qty.)", "Purchases (LCY)", "Sales (LCY)", "Positive Adjmt. (Qty.)", "Negative Adjmt. (Qty.)", "COGS (LCY)";
                DataItemLink = "Vendor No." = FIELD("No.");
                DataItemTableView = SORTING("NPR Group sale", "NPR Item Group", "Vendor No.") ORDER(Ascending);
                RequestFilterFields = "No.", "Statistics Group", "NPR Item Group", "Location Filter";
                column(No_Item; Item."No.")
                {
                }
                column(Description_Item; Item.Description)
                {
                }
                column(ItemGroup_Item; Item."NPR Item Group")
                {
                }
                column(StockInventoryStart_Item; StockInventoryStart)
                {
                }
                column(Regulatory_Item; Regulatory)
                {
                }
                column(StockInventoryEnd_Item; StockInventoryEnd)
                {
                }
                column(PurchasesQty_Item; Item."Purchases (Qty.)")
                {
                }
                column(SalesQty_Item; Item."Sales (Qty.)")
                {
                }
                column(SalesFlowQty_Item; SalesFlowQty)
                {
                }
                column(PurchasesLCY_Item; Item."Purchases (LCY)")
                {
                }
                column(SalesLCY_Item; Item."Sales (LCY)")
                {
                }
                column(COGSLCY_Item; Item."COGS (LCY)")
                {
                }
                column(Profit_Item; Item."Sales (LCY)" - Item."COGS (LCY)")
                {
                }
                column(dg_Item; dg)
                {
                }
                column(SalesFlowAmt_Item; SalesFlowAmt)
                {
                }
                column(ShowItemSection_Item; ShowItemSection)
                {
                }
                dataitem("Item Group"; "NPR Item Group")
                {
                    DataItemLink = "No." = FIELD("NPR Item Group"), "Vendor Filter" = FIELD("Vendor No.");
                    DataItemTableView = SORTING("No.");
                    column(No_ItemGroup; "Item Group"."No.")
                    {
                    }
                    column(Description_ItemGroup; "Item Group".Description)
                    {
                    }
                    column(StockInventoryStart2; StockInventoryStart2)
                    {
                    }
                    column(ShowItemGroupSection_ItemGroup; ShowItemGroupSection)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        ItemL2: Record Item;
                        ItemL3: Record Item;
                        Done: Boolean;
                    begin
                        Item2.SetRange("NPR Item Group", "Item Group"."No.");
                        Item2.SetRange("Vendor No.", Item."Vendor No.");
                        if Item.GetFilter("Statistics Group") <> '' then
                            Item2.SetRange("Statistics Group", Item."Statistics Group");

                        StockInventoryEnd2 := 0;
                        StockInventoryStart2 := 0;
                        GroupSalesFlowQty := 0;

                        Done := false;
                        ItemL3.SetRange("Vendor No.", Item."Vendor No.");
                        ItemL3.SetRange("NPR Item Group", "Item Group"."No.");
                        if Item.GetFilter("Statistics Group") <> '' then
                            ItemL3.SetRange("Statistics Group", Item."Statistics Group");
                        if ItemL3.FindFirst() then
                            repeat
                                if ItemL3."No." = ItemNo then begin
                                    if ItemL3.Next = 0 then begin
                                        NewGroup := true;
                                        Done := true;
                                    end;
                                    if ItemL3."NPR Item Group" <> "Item Group"."No." then begin
                                        NewGroup := true;
                                        Done := true;
                                    end;
                                end;
                                if ItemL3.Next() = 0 then
                                    Done := true;
                            until Done;

                        if NewGroup then begin
                            if Item2.FindFirst() then
                                repeat
                                    ShowTotalGroup := true;

                                    // Stocks - calculates inventory at the beginning and end
                                    ItemL2.Get(Item2."No.");
                                    ItemL2.SetRange("Date Filter", 0D, Item.GetRangeMin("Date Filter"));
                                    ItemL2.CalcFields("Net Change");
                                    StockInventoryStart2 := StockInventoryStart2 + ItemL2."Net Change";

                                    ItemL2.SetRange("Date Filter", 0D, Item.GetRangeMax("Date Filter"));
                                    ItemL2.CalcFields("Net Change");
                                    StockInventoryEnd2 += ItemL2."Net Change";
                                    GroupSalesQty += Item2."Sales (Qty.)";

                                    GroupSalesFlowQty := 0;
                                    if (StockInventoryStart2 + GroupPurchaseQty) <> 0 then
                                        GroupSalesFlowQty := GroupSalesQty / (StockInventoryStart2 + GroupPurchaseQty) * 100
                                    else
                                        GroupSalesFlowQty := 0;
                                until Item2.Next() = 0;
                        end;

                        ShowItemGroupSection := (ShowGroups and ShowTotalGroup);
                    end;

                    trigger OnPreDataItem()
                    begin
                        ShowTotalGroup := false;
                        NewGroup := false;
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    ItemL: Record Item;
                    Done: Boolean;
                    UpdateGroupSales: Boolean;
                begin
                    dg := 0;
                    if "Sales (LCY)" <> 0 then
                        dg := ("Sales (LCY)" - "COGS (LCY)") / "Sales (LCY)" * 100;

                    ItemNo := "No.";

                    // Stocks - calculates inventory at the beginning and end
                    Item1.CopyFilters(Item);
                    StockInventoryStart := 0;
                    Item1.Get("No.");
                    Item1.SetRange("Date Filter", 0D, Item.GetRangeMin("Date Filter"));
                    Item1.CalcFields("Net Change");
                    StockInventoryStart := Item1."Net Change";
                    Item1.SetRange("Date Filter", 0D, Item.GetRangeMax("Date Filter"));
                    Item1.CalcFields("Net Change");
                    StockInventoryEnd := Item1."Net Change";

                    // If any. inventory adjustments
                    Regulatory := 0;
                    Regulatory := ("Positive Adjmt. (Qty.)" - "Negative Adjmt. (Qty.)");

                    SalesFlowQty := 0;
                    if (StockInventoryStart + "Purchases (Qty.)") <> 0 then
                        SalesFlowQty := ("Sales (Qty.)" / (StockInventoryStart + "Purchases (Qty.)") * 100)
                    else
                        SalesFlowQty := 0;

                    SalesFlowAmt := 0;
                    if "Purchases (LCY)" <> 0 then
                        SalesFlowAmt := "COGS (LCY)" / "Purchases (LCY)" * 100
                    else
                        SalesFlowAmt := 0;

                    ShowTotalGroup2 := false;
                    if SkipWithoutPortfolio then begin
                        Done := false;
                        ItemL.SetRange("Vendor No.", Item."Vendor No.");
                        if ItemL.FindFirst then
                            repeat
                                if ItemL."No." = ItemNo then begin
                                    if ItemL.Next = 0 then begin
                                        ShowTotalGroup2 := true;
                                        Done := true;
                                    end;
                                end;
                                if ItemL.Next() = 0 then
                                    Done := true;
                            until Done;

                        if not ShowTotalGroup2 then
                            if StockInventoryEnd = 0 then
                                CurrReport.Skip();
                    end;

                    ShowTotalGroup2 := false;
                    if SkipNoSales then begin
                        Done := false;
                        ItemL.SetRange("Vendor No.", Item."Vendor No.");
                        if ItemL.FindFirst() then
                            repeat
                                if ItemL."No." = ItemNo then begin
                                    if ItemL.Next = 0 then begin
                                        ShowTotalGroup2 := true;
                                        Done := true;
                                    end;
                                end;
                                if ItemL.Next() = 0 then
                                    Done := true;
                            until Done;

                        // if the next item does not belong to another group of products
                        if not ShowTotalGroup2 then
                            if "Sales (LCY)" = 0 then
                                CurrReport.Skip();
                    end;

                    UpdateGroupSales := true;
                    if ItemGroupPrevious = Item."NPR Item Group" then begin
                        if SkipNoSales then
                            if "Sales (LCY)" = 0 then
                                UpdateGroupSales := false;

                        if SkipWithoutPortfolio then
                            if StockInventoryEnd = 0 then
                                UpdateGroupSales := false;

                        if UpdateGroupSales then begin
                            GroupSalesQty += Item."Sales (Qty.)";
                            GroupPurchaseQty += Item."Purchases (Qty.)";
                            PurchaseLCY += Item."Purchases (LCY)";
                            SalesLCY += Item."Sales (LCY)";
                            ConsumptionLCY += Item."COGS (LCY)";
                            GroupProfitPct := 0;
                            if SalesLCY <> 0 then
                                GroupProfitPct := (SalesLCY + ConsumptionLCY) / SalesLCY * 100;

                            GroupSalesFlowAmt := 0;
                            if PurchaseLCY <> 0 then
                                GroupSalesFlowAmt := ConsumptionLCY / PurchaseLCY * 100
                            else
                                GroupSalesFlowAmt := 0;

                            GroupControl += ("Positive Adjmt. (Qty.)" - "Negative Adjmt. (Qty.)");
                        end;
                    end else begin
                        GroupSalesQty := Item."Sales (Qty.)";
                        GroupPurchaseQty := Item."Purchases (Qty.)";
                        PurchaseLCY := Item."Purchases (LCY)";
                        SalesLCY := Item."Sales (LCY)";
                        ConsumptionLCY := Item."COGS (LCY)";
                        GroupControl := 0;
                    end;

                    ItemGroupPrevious := Item."NPR Item Group";

                    ShowItem := false;
                    ShowItemSection := (not OnlyTotal and not SkipWithoutPortfolio and not SkipNoSales);

                    ShowItem := false;

                    if SkipWithoutPortfolio then begin
                        if StockInventoryEnd <> 0 then
                            ShowItem := true;
                        ShowItemSection := (not OnlyTotal and ShowItem);
                    end;

                    if SkipNoSales then begin
                        if "Sales (LCY)" <> 0 then
                            ShowItem := true;
                        ShowItemSection := (not OnlyTotal and ShowItem);
                    end;
                end;

                trigger OnPreDataItem()
                begin

                    Vendor.CopyFilter("Date Filter", Item."Date Filter");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                ShowVendorSection := (not OnlyTotal);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Control6150614)
                {
                    ShowCaption = false;
                    field(SkipNoSales; SkipNoSales)
                    {
                        Caption = 'Hide Items With No Sales';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Hide Items With No Sales field';
                    }
                    field(SkipWithoutPortfolio; SkipWithoutPortfolio)
                    {
                        Caption = 'Hide Items With No Inventory';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Hide Items With No Inventory field';
                    }
                    field(OnlyTotal; OnlyTotal)
                    {
                        Caption = 'Show Only Total';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Only Total field';
                    }
                    field(ShowGroups; ShowGroups)
                    {
                        Caption = 'Show Groups';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Groups field';
                    }
                }
            }
        }
    }

    labels
    {
        Report_Caption = 'Inventory Flow';
        Inventory_Caption = 'Inventory';
        Quantity_Caption = 'Quantity';
        Amount_Caption = 'Amount';
        Start_Qty_Caption = 'Start (Qty.)';
        Regulatory_Caption = 'Regulatory (Qty.)';
        End_Qty_Caption = 'End (Qty.)';
        Purchases_Qty_Caption = 'Purchases (Qty.)';
        Sales_Qty_Caption = 'Sales (Qty.)';
        InventoryFlow_Qty_Caption = 'InventoryFlow (Qty) (&)';
        Purchases_LCY_Caption = 'Purchases (LCY)';
        Sales_LCY_Caption = 'Sales (LCY)';
        COGS_LCY_Caption = 'COGS (LCY)';
        Profit_Caption = 'Profit';
        Profit_Pct_Caption = 'Profit %';
        InventoryFlow_Amt_Caption = 'InventoryFlow (LCY) (&)';
        Total_Caption = 'Total';
        ItemGroup_Caption = 'Item Group';
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get;
        CompanyInfo.CalcFields(Picture);

        ShowVendorSection := false;
        ShowItemSection := false;
        ShowItemGroupSection := false;
    end;

    var
        CompanyInfo: Record "Company Information";
        Item1: Record Item;
        Item2: Record Item;
        NewGroup: Boolean;
        OnlyTotal: Boolean;
        ShowGroups: Boolean;
        ShowItem: Boolean;
        ShowItemGroupSection: Boolean;
        ShowItemSection: Boolean;
        ShowTotalGroup: Boolean;
        ShowTotalGroup2: Boolean;
        ShowVendorSection: Boolean;
        SkipNoSales: Boolean;
        SkipWithoutPortfolio: Boolean;
        ItemGroupPrevious: Code[10];
        ItemNo: Code[20];
        ConsumptionLCY: Decimal;
        dg: Decimal;
        GroupControl: Decimal;
        GroupProfitPct: Decimal;
        GroupPurchaseQty: Decimal;
        GroupSalesFlowAmt: Decimal;
        GroupSalesFlowQty: Decimal;
        GroupSalesQty: Decimal;
        PurchaseLCY: Decimal;
        Regulatory: Decimal;
        SalesFlowAmt: Decimal;
        SalesFlowQty: Decimal;
        SalesLCY: Decimal;
        StockInventoryEnd: Decimal;
        StockInventoryEnd2: Decimal;
        StockInventoryStart: Decimal;
        StockInventoryStart2: Decimal;
}

