report 6014662 "NPR Retail Inv.: Sales Stat."
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Retail Inventory - Sales Stat..rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Inventory - Sales Statistics';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("Inventory Posting Group");
            RequestFilterFields = "No.", "Search Description", "Assembly BOM", "Inventory Posting Group", "Statistics Group", "Base Unit of Measure", "Date Filter";
            column(PeriodTextCaption; StrSubstNo(Text000, PeriodText))
            {
            }
            column(CompanyName; CompanyName)
            {
            }
            column(PrintAlsoWithoutSale; PrintAlsoWithoutSale)
            {
            }
            column(ItemFilterCaption; StrSubstNo(Pct1Lbl, TableCaption, ItemFilter))
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(InventoryPostingGrp_Item; "Inventory Posting Group")
            {
            }
            column(No_Item; "No.")
            {
                IncludeCaption = true;
            }
            column(Description_Item; Description)
            {
                IncludeCaption = true;
            }
            column(AssemblyBOM_Item; Format("Assembly BOM"))
            {
            }
            column(BaseUnitofMeasure_Item; "Base Unit of Measure")
            {
                IncludeCaption = true;
            }
            column(UnitCost; UnitCost)
            {
            }
            column(UnitPrice; UnitPrice)
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
                AutoFormatType = 1;
            }
            column(ItemProfitPct; ItemProfitPct)
            {
                DecimalPlaces = 1 : 1;
            }
            column(InvSalesStatisticsCapt; InvSalesStatisticsCaptLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(IncludeNotSoldItemsCaption; IncludeNotSoldItemsCaptionLbl)
            {
            }
            column(ItemAssemblyBOMCaption; ItemAssemblyBOMCaptionLbl)
            {
            }
            column(UnitCostCaption; UnitCostCaptionLbl)
            {
            }
            column(UnitPriceCaption; UnitPriceCaptionLbl)
            {
            }
            column(SalesQtyCaption; SalesQtyCaptionLbl)
            {
            }
            column(SalesAmountCaption; SalesAmountCaptionLbl)
            {
            }
            column(ItemProfitCaption; ItemProfitCaptionLbl)
            {
            }
            column(ItemProfitPctCaption; ItemProfitPctCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                CalcFields("Assembly BOM");

                SetFilters();
                Calculate();

                if (SalesAmount = 0) and not PrintAlsoWithoutSale then
                    CurrReport.Skip();
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
                group(Options)
                {
                    Caption = 'Options';
                    field("Print Also Without Sale"; PrintAlsoWithoutSale)
                    {

                        Caption = 'Include Items Not Sold';
                        MultiLine = true;
                        ToolTip = 'Specifies if items that have not yet been sold are also included in the report.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        GLSetup.Get();

        ItemFilter := Item.GetFilters;
        PeriodText := Item.GetFilter("Date Filter");

        if Item.GetFilter("Date Filter") <> '' then
            ItemStatisticsBuf.SetFilter("Date Filter", PeriodText);
        if Item.GetFilter("Location Filter") <> '' then
            ItemStatisticsBuf.SetFilter("Location Filter", Item.GetFilter("Location Filter"));
        if Item.GetFilter("Variant Filter") <> '' then
            ItemStatisticsBuf.SetFilter("Variant Filter", Item.GetFilter("Variant Filter"));
        if Item.GetFilter("Global Dimension 1 Filter") <> '' then
            ItemStatisticsBuf.SetFilter("Global Dimension 1 Filter", Item.GetFilter("Global Dimension 1 Filter"));
        if Item.GetFilter("Global Dimension 2 Filter") <> '' then
            ItemStatisticsBuf.SetFilter("Global Dimension 2 Filter", Item.GetFilter("Global Dimension 2 Filter"));
    end;

    var
        GLSetup: Record "General Ledger Setup";
        ItemStatisticsBuf: Record "Item Statistics Buffer";
        PrintAlsoWithoutSale: Boolean;
        COGSAmount: Decimal;
        ItemProfit: Decimal;
        ItemProfitPct: Decimal;
        SalesAmount: Decimal;
        SalesQty: Decimal;
        UnitCost: Decimal;
        UnitPrice: Decimal;
        ItemAssemblyBOMCaptionLbl: Label 'BOM';
        InvSalesStatisticsCaptLbl: Label 'Inventory - Sales Statistics';
        PageCaptionLbl: Label 'Page';
        Text000: Label 'Period: %1';
        ItemProfitCaptionLbl: Label 'Profit';
        ItemProfitPctCaptionLbl: Label 'Profit %';
        SalesAmountCaptionLbl: Label 'Sales (LCY)';
        SalesQtyCaptionLbl: Label 'Sales (Qty.)';
        IncludeNotSoldItemsCaptionLbl: Label 'This report also includes items that are not sold.';
        TotalCaptionLbl: Label 'Total';
        UnitCostCaptionLbl: Label 'Unit Cost';
        UnitPriceCaptionLbl: Label 'Unit Price';
        ItemFilter: Text;
        PeriodText: Text;
        Pct1Lbl: Label '%1: %2', locked = true;


    local procedure Calculate()
    begin
        SalesQty := -CalcInvoicedQty();
        SalesAmount := CalcSalesAmount();
        COGSAmount := CalcCostAmount() + CalcCostAmountNonInvnt();
        ItemProfit := SalesAmount + COGSAmount;

        if SalesAmount <> 0 then
            ItemProfitPct := Round(100 * ItemProfit / SalesAmount, 0.1)
        else
            ItemProfitPct := 0;

        UnitPrice := CalcPerUnit(SalesAmount, SalesQty);
        UnitCost := -CalcPerUnit(COGSAmount, SalesQty);
    end;

    local procedure SetFilters()
    begin
        ItemStatisticsBuf.SetRange("Item Filter", Item."No.");
        ItemStatisticsBuf.SetRange("Item Ledger Entry Type Filter", ItemStatisticsBuf."Item Ledger Entry Type Filter"::Sale);
        ItemStatisticsBuf.SetFilter("Entry Type Filter", '<>%1', ItemStatisticsBuf."Entry Type Filter"::Revaluation);
    end;

    local procedure CalcSalesAmount(): Decimal
    begin
        ItemStatisticsBuf.CalcFields("Sales Amount (Actual)");
        exit(ItemStatisticsBuf."Sales Amount (Actual)");
    end;

    local procedure CalcCostAmount(): Decimal
    begin
        ItemStatisticsBuf.CalcFields("Cost Amount (Actual)");
        exit(ItemStatisticsBuf."Cost Amount (Actual)");
    end;

    local procedure CalcCostAmountNonInvnt(): Decimal
    begin
        ItemStatisticsBuf.SetRange("Item Ledger Entry Type Filter");
        ItemStatisticsBuf.CalcFields("Cost Amount (Non-Invtbl.)");
        exit(ItemStatisticsBuf."Cost Amount (Non-Invtbl.)");
    end;

    local procedure CalcInvoicedQty(): Decimal
    begin
        ItemStatisticsBuf.CalcFields("Invoiced Quantity");
        exit(ItemStatisticsBuf."Invoiced Quantity");
    end;

    local procedure CalcPerUnit(Amount: Decimal; Qty: Decimal): Decimal
    begin
        if Qty <> 0 then
            exit(Round(Amount / Abs(Qty), GLSetup."Unit-Amount Rounding Precision"));
        exit(0);
    end;
}

