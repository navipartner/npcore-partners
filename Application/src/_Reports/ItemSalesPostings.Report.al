report 6014439 "NPR Item Sales Postings"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Sales Postings.rdlc';
    Caption = 'Item Sales Postings';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    UseSystemPrinter = true;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(CompanyInformation; "Company Information")
        {
            column(COMPANYNAME; CompanyName)
            {
            }
            column(ItemFilters; (Pct1Lbl + ' ' + ItemFilter))
            {
            }
            column(DimFilters; Item.GetFilter("Global Dimension 1 Code"))
            {
            }
            column(PrintAlsoWithoutSale; PrintAlsoWithoutSale)
            {
            }

        }
        dataitem(Item; Item)
        {
            CalcFields = "Sales (Qty.)", "Sales (LCY)", "COGS (LCY)", "Assembly BOM", Inventory;
            DataItemTableView = SORTING("No.") ORDER(Ascending);
            RequestFilterFields = "No.", "Date Filter", "Item Category Code", "Vendor No.";
            column(No_Item; Item."No.")
            {
                IncludeCaption = true;
            }
            column(Description_Item; Item.Description)
            {
                IncludeCaption = true;
            }
            column(VendorNo_; Item."Vendor No.")
            {
                IncludeCaption = true;
            }
            column(VendorItemNo_Item; Item."Vendor Item No.")
            {
            }
            column(UnitCost_Item; Item."Unit Cost")
            {
                IncludeCaption = true;
            }
            column(UnitPrice_Item; Item.CalcUnitPriceExclVAT())
            {
            }
            column(SalesQty_Item; ItemSalesQty)
            {
            }
            column(Sales_Unit_Price; Item.CalcUnitPriceExclVAT() * ItemSalesQty)
            {
            }
            column(SalesAmount_Item; ItemSalesAmount)
            {
            }
            column(DiscountAmount; DiscountAmount)
            {
            }
            column(Profit_Item; Profit)
            {
            }
            column(ProfitPct_Item; ItemProfitPct)
            {
            }
            column(Inventory_Item; Item.Inventory)
            {
                IncludeCaption = true;
            }
            column(ShowVendorNo_; ShowVendorNo)
            {
            }
            column(ShowVendorItemNo; ShowVendorItemNo)
            {
            }

            trigger OnAfterGetRecord()
            var
                ValueEntry: Record "Value Entry";
                ItemLedgerEntry: Record "Item Ledger Entry";
            begin

                Clear(ItemSalesQty);
                Clear(ItemSalesAmount);
                Clear(CostAmountActual);
                Clear(CostAmountNonInvtbl);
                Clear(DiscountAmount);
                ItemLedgerEntry.Reset();
                ItemLedgerEntry.SetRange("Item No.", Item."No.");
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
                ItemLedgerEntry.SetFilter("Global Dimension 1 Code", Item.GetFilter("Global Dimension 1 Code"));
                ItemLedgerEntry.SetFilter("Global Dimension 2 Code", Item.GetFilter("Global Dimension 2 Code"));
                ItemLedgerEntry.SetFilter("Location Code", Item.GetFilter("Location Filter"));
                ItemLedgerEntry.SetFilter("Posting Date", Item.GetFilter("Date Filter"));
                ItemLedgerEntry.CalcSums("Invoiced Quantity");
                IF ItemLedgerEntry.FindSet() THEN
                    repeat
                        ItemLedgerEntry.CalcFields("Sales Amount (Actual)", "Cost Amount (Actual)", "Cost Amount (Non-Invtbl.)");
                        ItemSalesQty += -ItemLedgerEntry."Invoiced Quantity";
                        ItemSalesAmount += ItemLedgerEntry."Sales Amount (Actual)";
                        CostAmountActual += ItemLedgerEntry."Cost Amount (Actual)";
                        CostAmountNonInvtbl += ItemLedgerEntry."Cost Amount (Non-Invtbl.)";
                    until ItemLedgerEntry.Next() = 0;

                ValueEntry.Reset();
                ValueEntry.SetRange("Item No.", Item."No.");
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.SetFilter("Global Dimension 1 Code", Item.GetFilter("Global Dimension 1 Code"));
                ValueEntry.SetFilter("Global Dimension 2 Code", Item.GetFilter("Global Dimension 2 Code"));
                ValueEntry.SetFilter("Location Code", Item.GetFilter("Location Filter"));
                ValueEntry.SetFilter("Posting Date", Item.GetFilter("Date Filter"));
                ValueEntry.CalcSums("Discount Amount");
                DiscountAmount := Abs(ValueEntry."Discount Amount");

                if Item.Type = Item.Type::Service then
                    ItemCOG := CostAmountNonInvtbl
                else
                    ItemCOG := CostAmountActual;
                Profit := ItemSalesAmount - Abs(ItemCOG);

                if ItemSalesAmount <> 0 then
                    ItemProfitPct := Round(Profit / ItemSalesAmount * 100, 0.1)
                else
                    ItemProfitPct := 0;

                if not PrintAlsoWithoutSale then
                    if (ItemSalesQty = 0) and (ItemSalesAmount = 0) then
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
                field("Print Also Without Sale"; PrintAlsoWithoutSale)
                {
                    Caption = 'Include Items That Has Not Been Sold';
                    ToolTip = 'Specifies if items without sale should be listed.';
                    ApplicationArea = NPRRetail;
                }
                field("Show Vendor Item No"; ShowVendorItemNo)
                {
                    Caption = 'Show Vendor Item No.';
                    ToolTip = 'Displays Vendor Item No. on the report.';
                    ApplicationArea = NPRRetail;
                }
                field("Show Vendor No"; ShowVendorNo)
                {
                    Caption = 'Show Vendor No';
                    ToolTip = 'Displays Vendor No. on the report.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    labels
    {
        Report_Caption = 'Item Sales Postings';
        Page_Caption = 'Page';
        UnitPrice_Caption = 'Unit price';
        SalesQty_Caption = 'Sales (Qty.)';
        SalesAmtActual_Caption = 'Sales amount (Actual)';
        Profit_Caption = 'Profit (LCY)';
        ProfitPct_Caption = 'Profit %';
        Total_Caption = 'Total';
        VendorItemNo_Caption = 'Vendor Item No.';
        SalesUnitPrice_Caption = 'Sales (Unit Price)';
        DiscountAmount_Caption = 'Discount Amount';
    }

    trigger OnPreReport()
    begin
        ItemFilter := Item.GetFilters;
    end;

    var
        PrintAlsoWithoutSale: Boolean;
        ItemFilter: Text[250];
        Profit: Decimal;
        ItemProfitPct: Decimal;
        ShowVendorItemNo: Boolean;
        ItemSalesQty: Decimal;
        ItemSalesAmount: Decimal;
        DiscountAmount: Decimal;
        CostAmountActual: Decimal;
        CostAmountNonInvtbl: Decimal;
        ItemCOG: Decimal;
        ShowVendorNo: Boolean;
        Pct1Lbl: Label 'Item Filter:', locked = true;
}