report 6014470 "NPR RS Sales Stats Per Variety"
{
    Extensible = false;
    DefaultLayout = RDLC;
#pragma warning disable AL0835
    RDLCLayout = './src/_Reports/layouts/Sales Statistics Per Variety.rdlc';
#pragma warning restore AL0835
    Caption = 'Sales Stats Per Variety';
    UsageCategory = None;
    ApplicationArea = NPRRSRLocal;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Item Category Code", "Date Filter";
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
                DataItemLink = "Item No." = field("No.");
                RequestFilterFields = Code, Description;

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
                    if not PrintAlsoWithoutSale then
                        if (ItemInventory = 0) and (SalesAmount = 0) then
                            CurrReport.Skip();
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
                ItemInventory := 0;
                SalesQty := 0;
                SalesAmount := 0;
                COGSAmount := 0;
                ItemProfit := 0;
                COGSAmount := 0;


                _ItemVariant.Reset();
                _ItemVariant.SetRange("Item No.", "No.");
                if _ItemVariant.IsEmpty() then
                    CurrReport.Skip();

                if not PrintAlsoWithoutSale then begin
                    ItemLedgerEntry.Reset();
                    ItemLedgerEntry.SetRange("Item No.", "No.");
                    ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
                    ItemLedgerEntry.SetFilter("Document Type", '<>%1', ItemLedgerEntry."Document Type"::"NPR Nivelation");
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
        Report_Caption = 'Sales Stats Per Variety';
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
        Inventory_Caption = 'Inventory';
        TotalForGroup_Caption = 'Total for Group';
        Page_Caption = 'Page';
        COGS_Caption = 'COGS (LCY)';
        Total_Caption = 'Total';
    }

    trigger OnPreReport()
    begin
        GLSetup.Get();
        AllObj.Get(AllObj."Object Type"::Report, Report::"NPR RS Sales Stats Per Variety");
        if Item.GetFilter("Date Filter") <> '' then
            TextDateFilter := StrSubstNo(PeriodLbl, Item.GetFilter("Date Filter"));

        if Item.GetFilters() <> '' then
            TextItemFilter := StrSubstNo(Pct1Lbl, Item.TableCaption(), Item.GetFilters());
    end;

    var
        AllObj: Record AllObj;
        GLSetup: Record "General Ledger Setup";
        _ItemVariant: Record "Item Variant";
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
        PeriodLbl: Label 'Period: %1', Comment = '%1 = Date Filter';
        TextDateFilter: Text;
        TextItemFilter: Text;
        Pct1Lbl: Label '%1: %2', locked = true;

    internal procedure CalculateVariantCost(var Item2: Record Item; ItemVariant: Record "Item Variant")
    var
        Item3: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
        RSVariantSalesAmounts: Query "NPR RS Variant Sales Amounts";
        TotalSalesAmountActual: Decimal;
        TotalCostAmountActual: Decimal;
        TotalCostAmountNonInvtbl: Decimal;
    begin
        ItemLedgEntry.SetRange("Item No.", ItemVariant."Item No.");
        ItemLedgEntry.SetRange("Variant Code", ItemVariant.Code);
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Sale);
        ItemLedgEntry.SetFilter("Document Type", '<>%1', ItemLedgEntry."Document Type"::"NPR Nivelation");
        ItemLedgEntry.SetFilter("Posting Date", Item2.GetFilter("Date Filter"));
        ItemLedgEntry.SetFilter("Location Code", Item2.GetFilter("Location Filter"));
        ItemLedgEntry.SetFilter("Global Dimension 1 Code", Item2.GetFilter("Global Dimension 1 Filter"));
        ItemLedgEntry.SetFilter("Global Dimension 2 Code", Item2.GetFilter("Global Dimension 2 Filter"));
        ItemLedgEntry.CalcSums("Invoiced Quantity");

        RSVariantSalesAmounts.SetRange(Filter_Item_No, ItemVariant."Item No.");
        RSVariantSalesAmounts.SetRange(Filter_Variant_Code, ItemVariant.Code);
        RSVariantSalesAmounts.SetFilter(Filter_Posting_Date, Item2.GetFilter("Date Filter"));
        RSVariantSalesAmounts.SetFilter(Filter_Location_Code, Item2.GetFilter("Location Filter"));
        RSVariantSalesAmounts.SetFilter(Filter_Dim_1_Code, Item2.GetFilter("Global Dimension 1 Filter"));
        RSVariantSalesAmounts.SetFilter(Filter_Dim_2_Code, Item2.GetFilter("Global Dimension 2 Filter"));
        RSVariantSalesAmounts.SetFilter(Filter_Entry_Type, '<>%1&<>%2', Enum::"Cost Entry Type"::"NPR RS Retail Calculation", Enum::"Cost Entry Type"::"NPR Nivelation");
        RSVariantSalesAmounts.Open();
        if RSVariantSalesAmounts.Read() then begin
            TotalSalesAmountActual := RSVariantSalesAmounts.Sum_Sales_Amount_Actual;
            TotalCostAmountActual := RSVariantSalesAmounts.Sum_Cost_Amount_Actual;
            TotalCostAmountNonInvtbl := RSVariantSalesAmounts.Sum_Cost_Amount_Non_Invtbl;
        end;
        RSVariantSalesAmounts.Close();

        RSVariantSalesAmounts.SetRange(Filter_Entry_Type, Enum::"Cost Entry Type"::"NPR RS Retail Calculation");
        RSVariantSalesAmounts.SetFilter(Filter_Invoiced_Quantity, '<>0');
        RSVariantSalesAmounts.Open();
        if RSVariantSalesAmounts.Read() then begin
            TotalCostAmountActual += RSVariantSalesAmounts.Sum_Cost_Amount_Actual;
            TotalCostAmountNonInvtbl += RSVariantSalesAmounts.Sum_Cost_Amount_Non_Invtbl;
        end;
        RSVariantSalesAmounts.Close();

        if Item3.Get(Item2."No.") then;
        Item3.CopyFilters(Item2);
        Item3.SetFilter("Variant Filter", ItemVariant.Code);
        Item3.CalcFields(Inventory);
        ItemInventory := Item3.Inventory;
        SalesQty := -ItemLedgEntry."Invoiced Quantity";
        SalesAmount := TotalSalesAmountActual;
        COGSAmount := TotalCostAmountActual + TotalCostAmountNonInvtbl;
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

    internal procedure CalcPerUnit(Amount: Decimal; Qty: Decimal): Decimal
    begin
        if Qty <> 0 then
            exit(Round(Amount / Abs(Qty), GLSetup."Unit-Amount Rounding Precision"));
        exit(0);
    end;
}

