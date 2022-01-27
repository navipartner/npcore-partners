report 6014615 "NPR Sales Stats Per Variety"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Statistics Per Variety.rdlc';
    Caption = 'Sales Statistics Variant';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            column(PrintTotal_; PrintTotal)
            {
            }
            column(No_Item; Item."No.")
            {
            }
            column(No2_Item; Item."No. 2")
            {
            }
            column(Description_Item; Item.Description)
            {
            }
            column(VendorNo_Item; Item."Vendor No.")
            {
            }
            column(VendorItemNo_Item; Item."Vendor Item No.")
            {
            }
            column(InventoryPostingGroup_Item; Item."Inventory Posting Group")
            {
            }
            column(DateFilters; TextDateFilter)
            {
            }
            column(ItemFilters; TextItemFilter)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(PrintAlsoWithoutSale; PrintAlsoWithoutSale)
            {
            }
            column(ObjectDetails; Format(AllObj."Object ID"))
            {
            }
            dataitem("Item Variant"; "Item Variant")
            {
                DataItemLink = "Item No." = FIELD("No.");
                column(Code_ItemVariant; "Item Variant".Code)
                {
                }
                column(ItemNo_ItemVariant; "Item Variant"."Item No.")
                {
                }
                column(Description_ItemVariant; "Item Variant".Description)
                {
                }
                column(Description2_ItemVariant; "Item Variant"."Description 2")
                {
                }
                column(VariantUnitPrice; VariantUnitPrice)
                {
                }
                column(VariantUnitCost; VariantUnitCost)
                {
                }
                column(SalesQty; SalesQty)
                {
                }
                column(SalesAmount; SalesAmount)
                {
                }
                column(ItemProfit; ItemProfit)
                {
                }
                column(ItemProfitPct; ItemProfitPct)
                {
                }
                column(ItemInventory; ItemInventory)
                {
                }
                column(COGSAmount; COGSAmount)
                {
                }
                column(TotalSalesQty_; TotalSalesQty)
                {
                }
                column(TotalCOG_; TotalCOG)
                {
                }
                column(TotalSaleCLY_; TotalSaleLCY)
                {
                }
                column(AverageProfit_; AverageProfit)
                {
                }
                column(AverageProfitPerc_; AverageProfitPerc)
                {
                }
                column(TotalCount_; TotalCount)
                {
                }
                column(TotalProfit_; TotalProfit)
                {
                }
                column(TotalProfitPerc_; TotalProfitPerc)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    CalculateVariantCost(Item, "Item Variant");
                    if not PrintAlsoWithoutSale then begin
                        if (ItemInventory = 0) and (SalesAmount = 0) then
                            CurrReport.Skip();
                    end;
                    TotalSalesQty += SalesQty;
                    TotalSaleLCY += SalesAmount;
                    TotalCOG += VariantUnitCost * SalesQty;

                    TotalCount += 1;
                    TotalProfit += ItemProfit;
                    TotalProfitPerc += ItemProfitPct;


                    if TotalCount <> 0 then begin
                        AverageProfit := TotalProfit / TotalCount;
                        AverageProfitPerc := TotalProfitPerc / TotalCount;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                ItemLedgerEntry: Record "Item Ledger Entry";
            begin
                CalcFields("Assembly BOM");

                ItemInventory := 0;
                SalesQty := 0;
                SalesAmount := 0;
                COGSAmount := 0;
                ItemProfit := 0;
                COGSAmount := 0;


                ItemVariant.Reset();
                ItemVariant.SetRange("Item No.", "No.");
                if not ItemVariant.FindFirst() then
                    CurrReport.Skip();

                if not PrintAlsoWithoutSale then begin
                    ItemLedgerEntry.Reset();
                    ItemLedgerEntry.SetRange("Item No.", "No.");
                    ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
                    ItemLedgerEntry.SetFilter("Posting Date", GetFilter("Date Filter"));
                    ItemLedgerEntry.SetFilter("Location Code", GetFilter("Location Filter"));
                    ItemLedgerEntry.SetFilter("Global Dimension 1 Code", GetFilter("Global Dimension 1 Filter"));
                    ItemLedgerEntry.SetFilter("Global Dimension 2 Code", GetFilter("Global Dimension 2 Filter"));
                    if ItemLedgerEntry.IsEmpty() then
                        CurrReport.Skip();
                end;
            end;

            trigger OnPreDataItem()
            begin
                TotalCount := 0;
                AverageProfit := 0;
                AverageProfitPerc := 0;
                TotalCOG := 0;
                TotalProfit := 0;
                TotalProfitPerc := 0;
                TotalSaleLCY := 0;
                TotalSalesQty := 0;
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
                field("Print Also Without Sale"; PrintAlsoWithoutSale)
                {
                    Caption = 'Include Items Not Sold';
                    ToolTip = 'Specifies the value of the Include Items Not Sold field';
                    ApplicationArea = NPRRetail;
                }
                field(PrintTotals; PrintTotal)
                {
                    Caption = 'Print Totals';
                    ToolTip = 'Specifies the value of the Print Totals field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    labels
    {
        Report_Caption = 'Inventory - Sales Statistics';
        HeaderNote_Caption = 'This report also includes items that are not sold.';
        No_Caption = 'No.';
        Description_Caption = 'Description';
        VendorItemNo_Caption = 'Vendor Item No.';
        UnitCost_Caption = 'Unit Cost';
        UnitPrice_Caption = 'Unit Price';
        SaleQty_Caption = 'Sales (Qty.)';
        SaleLCY_Caption = 'Sales (LCY)';
        Profit_Caption = 'Profit';
        ProfitPct_Caption = 'Profit %';
        Inventory_Caption = 'Invent.';
        Total_Caption = 'Total';
        Page_Caption = 'Page';
        COGS_Caption = 'COGS (LCY)';
    }

    trigger OnPreReport()
    begin
        GLSetup.Get();
        AllObj.SetRange("Object ID", 6014615);
        AllObj.SetRange("Object Type", 3);
        AllObj.FindFirst();
        if Item.GetFilter("Date Filter") <> '' then
            TextDateFilter := StrSubstNo(Text000, Item.GetFilter("Date Filter"));

        if Item.GetFilters <> '' then
            TextItemFilter := StrSubstNo(Pct1Lbl, Item.TableCaption, Item.GetFilters);
    end;

    var
        AllObj: Record AllObj;
        GLSetup: Record "General Ledger Setup";
        ItemVariant: Record "Item Variant";
        PrintAlsoWithoutSale: Boolean;
        PrintTotal: Boolean;
        AverageProfit: Decimal;
        AverageProfitPerc: Decimal;
        COGSAmount: Decimal;
        ItemInventory: Decimal;
        ItemProfit: Decimal;
        ItemProfitPct: Decimal;
        SalesAmount: Decimal;
        SalesQty: Decimal;
        TotalCOG: Decimal;
        TotalProfit: Decimal;
        TotalProfitPerc: Decimal;
        TotalSaleLCY: Decimal;
        TotalSalesQty: Decimal;
        UnitCost: Decimal;
        UnitPrice: Decimal;
        VariantUnitCost: Decimal;
        VariantUnitPrice: Decimal;
        TotalCount: Integer;
        Text000: Label 'Period: %1';
        TextDateFilter: Text;
        TextItemFilter: Text;
        Pct1Lbl: Label '%1: %2', locked = true;

    procedure CalculateVariantCost(var Item2: Record Item; ItemVariant: Record "Item Variant")
    var
        Item3: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
    begin
        TempItemLedgEntry.Init();
        ItemLedgEntry.Reset();
        ItemLedgEntry.SetRange("Item No.", ItemVariant."Item No.");
        ItemLedgEntry.SetRange("Variant Code", ItemVariant.Code);
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Sale);
        ItemLedgEntry.SetFilter("Posting Date", Item2.GetFilter("Date Filter"));
        ItemLedgEntry.SetFilter("Location Code", Item2.GetFilter("Location Filter"));
        ItemLedgEntry.SetFilter("Global Dimension 1 Code", Item2.GetFilter("Global Dimension 1 Filter"));
        ItemLedgEntry.SetFilter("Global Dimension 2 Code", Item2.GetFilter("Global Dimension 2 Filter"));
        if ItemLedgEntry.FindSet() then
            repeat
                ItemLedgEntry.CalcFields("Sales Amount (Actual)", "Cost Amount (Actual)", "Cost Amount (Non-Invtbl.)");
                TempItemLedgEntry.Quantity += ItemLedgEntry.Quantity;
                TempItemLedgEntry."Invoiced Quantity" += ItemLedgEntry."Invoiced Quantity";
                TempItemLedgEntry."Sales Amount (Actual)" += ItemLedgEntry."Sales Amount (Actual)";
                TempItemLedgEntry."Cost Amount (Actual)" += ItemLedgEntry."Cost Amount (Actual)";
                TempItemLedgEntry."Cost Amount (Non-Invtbl.)" += ItemLedgEntry."Cost Amount (Non-Invtbl.)";
            until ItemLedgEntry.Next() = 0;
        if Item3.Get(Item2."No.") then;
        Item3.CopyFilters(Item2);
        Item3.SetFilter("Variant Filter", ItemVariant.Code);
        Item3.CalcFields(Inventory);
        ItemInventory := Item3.Inventory;
        SalesQty := -TempItemLedgEntry."Invoiced Quantity";
        SalesAmount := TempItemLedgEntry."Sales Amount (Actual)";
        COGSAmount := TempItemLedgEntry."Cost Amount (Actual)" + TempItemLedgEntry."Cost Amount (Non-Invtbl.)";
        ItemProfit := SalesAmount + COGSAmount;

        if SalesAmount <> 0 then
            ItemProfitPct := Round(100 * ItemProfit / SalesAmount, 0.1)
        else
            ItemProfitPct := 0;

        UnitPrice := CalcPerUnit(SalesAmount, SalesQty);
        UnitCost := -CalcPerUnit(COGSAmount, SalesQty);

        VariantUnitPrice := UnitPrice;
        VariantUnitCost := UnitCost;
    end;

    procedure CalcPerUnit(Amount: Decimal; Qty: Decimal): Decimal
    begin
        if Qty <> 0 then
            exit(Round(Amount / Abs(Qty), GLSetup."Unit-Amount Rounding Precision"));
        exit(0);
    end;
}

