report 6014611 "NPR Sales Stats w/ Variants"
{
    // NPR4.14/KN/20152408 CASE  221163  Added report ID and version.
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.55/YAHA/20200610  CASE 394884 Header layout modification
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Statistics w Variants.rdlc';

    Caption = 'Item - Sales Statistics';
    PreviewMode = PrintLayout;

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
            column(ItemFilterTxt; StrSubstNo('%1: %2', Item.TableCaption, ItemFilter))
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
                    SetFilters;
                    ItemStatisticsBuf.SetRange("Variant Filter", Code);
                    Item.SetRange("Variant Filter", Code);
                    Calculate;

                    ItemStatisticsBuf.SetRange("Variant Filter");
                    Item.SetRange("Variant Filter");

                    if (SalesAmount = 0) and not PrintAlsoWithoutSale then
                        CurrReport.Skip;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                //CALCFIELDS("Bill of Materials");

                SetFilters;
                Calculate;

                //-NPR4.14
                SalesQtyTotal := SalesQty;
                SalesAmountTotal := SalesAmount;
                COGSAmountTotal := COGSAmount;
                ItemProfitTotal := ItemProfit;
                //ItemProfitPctTotal := ItemProfitPct;
                //+NPR4.14


                if (SalesAmount = 0) and not PrintAlsoWithoutSale then
                    CurrReport.Skip;

                TotalQty += ItemInventory;
            end;

            trigger OnPreDataItem()
            begin

                //-NPR5.39
                // CurrReport.CREATETOTALS(SalesQty,SalesAmount,COGSAmount,ItemProfit,ItemInventory);
                // //-NPR4.14
                // CurrReport.CREATETOTALS(SalesQtyTotal,SalesAmountTotal,COGSAmountTotal,ItemProfitTotal);
                // //+NPR4.14
                //+NPR5.39
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Settings)
                {
                    field(PrintPrintAlsoWithoutSale; PrintAlsoWithoutSale)
                    {
                        Caption = 'Print Also Without Sale';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print Also Without Sale field';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        PageCaption = 'Page ';
    }

    trigger OnInitReport()
    begin
        //-NPR5.39
        // //-NPR4.14
        // Object.SETRANGE(ID, 6014611);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        // ObjectDetails := STRSUBSTNO('%1, %2', Object.ID, Object."Version List");
        // //+NPR4.14
        //+NPR5.39
    end;

    trigger OnPreReport()
    begin

        GLSetup.Get;

        ItemFilter := Item.GetFilters;
        PeriodText := Item.GetFilter("Date Filter");

        with ItemStatisticsBuf do begin
            if Item.GetFilter("Date Filter") <> '' then
                SetFilter("Date Filter", PeriodText);
            if Item.GetFilter("Location Filter") <> '' then
                SetFilter("Location Filter", Item.GetFilter("Location Filter"));
            if Item.GetFilter("Variant Filter") <> '' then
                SetFilter("Variant Filter", Item.GetFilter("Variant Filter"));
            if Item.GetFilter("Global Dimension 1 Filter") <> '' then
                SetFilter("Global Dimension 1 Filter", Item.GetFilter("Global Dimension 1 Filter"));
            if Item.GetFilter("Global Dimension 2 Filter") <> '' then
                SetFilter("Global Dimension 2 Filter", Item.GetFilter("Global Dimension 2 Filter"));
        end;
    end;

    var
        Report_Caption: Label 'Item - Sales Statistics';
        ItemsNotSoldTxt: Label 'The report also contains items, that have not been sold. ';
        ItemNo_Caption: Label 'No. ';
        ItemDescription_Caption: Label 'Description';
        ItemVendorNo_Caption: Label 'Vendor Item No.';
        ItemVariantInfo_Caption: Label 'Variant Info';
        ItemUnitCost_Caption: Label 'Cost Price';
        ItemUnitPrice_Caption: Label 'Sales Price';
        SalesQty_Caption: Label 'Sale (Qty)';
        SalesAmount_Caption: Label 'Sales (RV)';
        ItemProfit_Caption: Label 'Advance';
        ItemProfitPct_Caption: Label 'Adv. pct.';
        ItemInventory_Caption: Label 'Inventory';
        ItemStatisticsBuf: Record "Item Statistics Buffer";
        GLSetup: Record "General Ledger Setup";
        ItemFilter: Text[250];
        PeriodText: Text[30];
        SalesQty: Decimal;
        SalesAmount: Decimal;
        COGSAmount: Decimal;
        ItemProfit: Decimal;
        ItemProfitPct: Decimal;
        UnitPrice: Decimal;
        UnitCost: Decimal;
        PrintAlsoWithoutSale: Boolean;
        ItemInventory: Decimal;
        TotalQty: Decimal;
        SalesQtyTotal: Decimal;
        SalesAmountTotal: Decimal;
        COGSAmountTotal: Decimal;
        ItemProfitPctTotal: Decimal;
        ItemProfitTotal: Decimal;

    procedure Calculate()
    begin
        SalesQty := -CalcInvoicedQty;
        SalesAmount := CalcSalesAmount;
        COGSAmount := CalcCostAmount + CalcCostAmountNonInvnt;
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
        with ItemStatisticsBuf do begin
            SetRange("Item Filter", Item."No.");
            SetRange("Item Ledger Entry Type Filter", "Item Ledger Entry Type Filter"::Sale);
            SetFilter("Entry Type Filter", '<>%1', "Entry Type Filter"::Revaluation);
        end;
    end;

    local procedure CalcSalesAmount(): Decimal
    begin
        with ItemStatisticsBuf do begin
            CalcFields("Sales Amount (Actual)");
            exit("Sales Amount (Actual)");
        end;
    end;

    local procedure CalcCostAmount(): Decimal
    begin
        with ItemStatisticsBuf do begin
            CalcFields("Cost Amount (Actual)");
            exit("Cost Amount (Actual)");
        end;
    end;

    local procedure CalcCostAmountNonInvnt(): Decimal
    begin
        with ItemStatisticsBuf do begin
            SetRange("Item Ledger Entry Type Filter");
            CalcFields("Cost Amount (Non-Invtbl.)");
            exit("Cost Amount (Non-Invtbl.)");
        end;
    end;

    local procedure CalcInvoicedQty(): Decimal
    begin
        with ItemStatisticsBuf do begin
            SetRange("Entry Type Filter");
            CalcFields("Invoiced Quantity");
            exit("Invoiced Quantity");
        end;
    end;

    procedure CalcPerUnit(Amount: Decimal; Qty: Decimal): Decimal
    begin
        if Qty <> 0 then
            exit(Round(Amount / Abs(Qty), GLSetup."Unit-Amount Rounding Precision"));
        exit(0);
    end;
}

