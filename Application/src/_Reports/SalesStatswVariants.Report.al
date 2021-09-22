report 6014611 "NPR Sales Stats w/ Variants"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Statistics w Variants.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Item - Sales Statistics';
    PreviewMode = PrintLayout;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Search Description", "Inventory Posting Group", "Statistics Group", "Base Unit of Measure", "Date Filter", "NPR Group sale";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(USERID; UserId)
            {
            }
            column(ItemVendorNo; "Vendor No.")
            {
            }
            column(No_Item; "No.")
            {
            }
            column(Description_Item; Description)
            {
            }
            column(VendorItemNo_Item; "Vendor Item No.")
            {
            }
            column(InvPostGroup_Item; "Inventory Posting Group")
            {
            }
            column(SalesQty_Item; SalesQty)
            {
            }
            column(SalesAmount_Item; SalesAmount)
            {
            }
            column(ItemProfit_Item; ItemProfit)
            {
            }
            column(ItemProfitPct_Item; ItemProfitPct)
            {
            }
            column(ItemInventory_Item; ItemInventory)
            {
            }
            column(SalesQtyTotal; SalesQtyTotal)
            {
            }
            column(SalesAmountTotal; SalesAmountTotal)
            {
            }
            column(ItemProfitTotal; ItemProfitTotal)
            {
            }
            column(ItemProfitPctTotal; ItemProfitPctTotal)
            {
            }
            column(TotalQty; TotalQty)
            {
            }
            column(PrintAlsoWithoutSale; PrintAlsoWithoutSale)
            {
            }
            column(ItemFilterTxt; StrSubstNo(Pct1Lbl, Item.TableCaption, ItemFilter))
            {
            }
            column(Report_Caption; Report_Caption)
            {
            }
            column(ItemsNotSoldTxt; ItemsNotSoldTxt)
            {
            }
            column(ItemNo_Caption; ItemNo_Caption)
            {
            }
            column(ItemDescription_Caption; ItemDescription_Caption)
            {
            }
            column(ItemVendorNo_Caption; ItemVendorNo_Caption)
            {
            }
            column(ItemUnitCost_Caption; ItemUnitCost_Caption)
            {
            }
            column(ItemUnitPrice_Caption; ItemUnitPrice_Caption)
            {
            }
            column(SalesQty_Caption; SalesQty_Caption)
            {
            }
            column(SalesAmount_Caption; SalesAmount_Caption)
            {
            }
            column(ItemProfit_Caption; ItemProfit_Caption)
            {
            }
            column(ItemProfitPct_Caption; ItemProfitPct_Caption)
            {
            }
            column(ItemInventory_Caption; ItemInventory_Caption)
            {
            }
            column(ItemVariantInfo_Caption; ItemVariantInfo_Caption)
            {
            }
            dataitem("Item Variant"; "Item Variant")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", Code);
                column(Code_ItemVariant; Code)
                {
                }
                column(Description_ItemVariant; Description)
                {
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
                }
                column(ItemProfitPct; ItemProfitPct)
                {
                }
                column(ItemInventory; ItemInventory)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    SetFilters();
                    ItemStatisticsBuf.SetRange("Variant Filter", Code);
                    Item.SetRange("Variant Filter", Code);
                    Calculate();

                    ItemStatisticsBuf.SetRange("Variant Filter");
                    Item.SetRange("Variant Filter");

                    if (SalesAmount = 0) and not PrintAlsoWithoutSale then
                        CurrReport.Skip();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                SetFilters();
                Calculate();

                SalesQtyTotal := SalesQty;
                SalesAmountTotal := SalesAmount;
                ItemProfitTotal := ItemProfit;
                if (SalesAmount = 0) and not PrintAlsoWithoutSale then
                    CurrReport.Skip();

                TotalQty += ItemInventory;
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
                group(Settings)
                {
                    field(PrintPrintAlsoWithoutSale; PrintAlsoWithoutSale)
                    {
                        Caption = 'Print Also Without Sale';

                        ToolTip = 'Specifies the value of the Print Also Without Sale field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    labels
    {
        PageCaption = 'Page ';
    }

    trigger OnPreReport()
    begin

        GLSetup.Get();

        ItemFilter := Item.GetFilters();
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
        ItemInventory: Decimal;
        ItemProfit: Decimal;
        ItemProfitPct: Decimal;
        ItemProfitPctTotal: Decimal;
        ItemProfitTotal: Decimal;
        SalesAmount: Decimal;
        SalesAmountTotal: Decimal;
        SalesQty: Decimal;
        SalesQtyTotal: Decimal;
        TotalQty: Decimal;
        UnitCost: Decimal;
        UnitPrice: Decimal;
        ItemProfitPct_Caption: Label 'Adv. pct.';
        ItemProfit_Caption: Label 'Advance';
        ItemUnitCost_Caption: Label 'Cost Price';
        ItemDescription_Caption: Label 'Description';
        ItemInventory_Caption: Label 'Inventory';
        Report_Caption: Label 'Item - Sales Statistics';
        ItemNo_Caption: Label 'No. ';
        SalesQty_Caption: Label 'Sale (Qty)';
        SalesAmount_Caption: Label 'Sales (RV)';
        ItemUnitPrice_Caption: Label 'Sales Price';
        ItemsNotSoldTxt: Label 'The report also contains items, that have not been sold. ';
        ItemVariantInfo_Caption: Label 'Variant Info';
        ItemVendorNo_Caption: Label 'Vendor Item No.';
        PeriodText: Text;
        ItemFilter: Text;
        Pct1Lbl: Label '%1: %2', locked = true;

    procedure Calculate()
    begin
        SalesQty := -CalcInvoicedQty();
        SalesAmount := CalcSalesAmount();
        COGSAmount := CalcCostAmount() + CalcCostAmountNonInvnt();
        ItemProfit := SalesAmount + COGSAmount;

        Item.CalcFields(Inventory);
        ItemInventory := Item.Inventory;

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
        ItemStatisticsBuf.SetRange("Entry Type Filter");
        ItemStatisticsBuf.CalcFields("Invoiced Quantity");
        exit(ItemStatisticsBuf."Invoiced Quantity");
    end;

    procedure CalcPerUnit(Amount: Decimal; Qty: Decimal): Decimal
    begin
        if Qty <> 0 then
            exit(Round(Amount / Abs(Qty), GLSetup."Unit-Amount Rounding Precision"));
        exit(0);
    end;
}

