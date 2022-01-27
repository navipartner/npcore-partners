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
        dataitem(AuxItemLedgerEntry; "NPR Aux. Item Ledger Entry")
        {
            DataItemTableView = SORTING("Item No.", "Entry Type", "Posting Date") ORDER(Ascending) WHERE("Entry Type" = FILTER(Sale));
            RequestFilterFields = "Item No.", "Posting Date", "Global Dimension 1 Code", "Global Dimension 2 Code", "Salespers./Purch. Code", "Item Category Code", Quantity;
            column(ItemFilters; StrSubstNo(Pct1Lbl, TableCaption, ItemFilter))
            {
            }
            column(DimFilters; GetFilter("Global Dimension 1 Code"))
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(ItemNo_ItemLedgerEntry; AuxItemLedgerEntry."Item No.")
            {
            }
            column(EntryNo_ItemLedgerEntry; AuxItemLedgerEntry."Entry No.")
            {
            }
            column(No_Item; Item."No.")
            {
            }
            column(Description_Item; Item.Description)
            {
            }
            column(UnitCost_Item; Item."Unit Cost")
            {
            }
            column(UnitPrice_Item; Item."Unit Price")
            {
            }
            column(SalesQty_Item; ItemSalesQty)
            {
            }
            column(SalesLCY_Item; ItemSalesAmount)
            {
            }
            column(Profit; Profit)
            {
            }
            column(ItemProfitPct; ItemProfitPct)
            {
            }
            column(Inventory_Item; Item.Inventory)
            {
            }
            column(Quantity_ItemLedgerEntry; AuxItemLedgerEntry.Quantity)
            {
            }
            column(ShowVendorItemNo; ShowVendorItemNo)
            {
            }
            column(VendorItemNo; VendorItemNo)
            {
            }
            column(Sales_Unit_Price; Item."Unit Price" * ItemSalesQty)
            {
            }
            column(Report_Filters; AuxItemLedgerEntry.GetFilters)
            {
            }
            column(ShowVendorNo_; ShowVendorNo)
            {
            }
            column(VendorNo_; Item."Vendor No.")
            {
            }

            trigger OnAfterGetRecord()
            begin
                Item.Get("Item No.");
                Item.SetFilter("Global Dimension 1 Filter", GetFilter("Global Dimension 1 Code"));
                Item.SetFilter("Global Dimension 2 Filter", GetFilter("Global Dimension 2 Code"));
                Item.SetFilter("Location Filter", GetFilter("Location Code"));
                Item.SetFilter("Variant Filter", GetFilter("Variant Code"));
                Item.SetFilter("Serial No. Filter", GetFilter("Serial No."));
                Item.SetFilter("Date Filter", GetFilter("Posting Date"));
                Item.CalcFields(Inventory);
                Item.CalcFields("Sales (Qty.)", "Sales (LCY)", "COGS (LCY)", "Assembly BOM");

                ItemSalesQty := 0;
                ItemSalesAmount := 0;
                ItemCOG := 0;
                Profit := 0;
                ValueEntry.Reset();
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.SetFilter("Global Dimension 1 Code", GetFilter("Global Dimension 1 Code"));
                ValueEntry.SetFilter("Global Dimension 2 Code", GetFilter("Global Dimension 2 Code"));
                ValueEntry.SetFilter("Location Code", GetFilter("Location Code"));
                ValueEntry.SetFilter("Posting Date", GetFilter("Posting Date"));
                ValueEntry.SetFilter("Salespers./Purch. Code", GetFilter("Salespers./Purch. Code"));
                ValueEntry.SetRange("Item No.", AuxItemLedgerEntry."Item No.");
                ValueEntry.CalcSums("Invoiced Quantity", "Sales Amount (Actual)", "Cost Amount (Actual)", "Cost Amount (Non-Invtbl.)");
                ItemSalesQty := -ValueEntry."Invoiced Quantity";
                ItemSalesAmount := ValueEntry."Sales Amount (Actual)";
                if Item.Type = Item.Type::Service then
                    ItemCOG := -ValueEntry."Cost Amount (Non-Invtbl.)"
                else
                    ItemCOG := -ValueEntry."Cost Amount (Actual)";
                Profit := ItemSalesAmount - ItemCOG;
                if ItemSalesAmount <> 0 then
                    ItemProfitPct := Round(Profit / ItemSalesAmount * 100, 0.1)
                else
                    ItemProfitPct := 0;
                SetRange("Item No.", "Item No.");
                FindLast();
                //+NPR4.21
                SetFilter("Item No.", Reportfilter);
                VendorItemNo := '';
                if ShowVendorItemNo then
                    if Item1.Get(AuxItemLedgerEntry."Item No.") then
                        VendorItemNo := Item1."Vendor Item No.";
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

                    ToolTip = 'Specifies the value of the Include Items That Has Not Been Sold field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Vendor Item No"; ShowVendorItemNo)
                {
                    Caption = 'Show Vendor Item No.';

                    ToolTip = 'Specifies the value of the Show Vendor Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Vendor No"; ShowVendorNo)
                {
                    Caption = 'Show Vendor No';

                    ToolTip = 'Specifies the value of the Show Vendor No field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    labels
    {
        Report_Caption = 'Item Sales Postings';
        Page_Caption = 'Page';
        No_Caption = 'No.';
        Description_Caption = 'Description';
        CostAmount_Caption = 'Cost amount';
        SalesAmount_Caption = 'Sales amount';
        SalesQty_Caption = 'Sales (Qty.)';
        SalesRCY_Caption = 'Sales(RCY)';
        Profit_Caption = 'Profit (LCY)';
        ProfitPct_Caption = 'Profit %';
        Inventory_Caption = 'Inventory';
        Total_Caption = 'Total';
        VendorItemNo_Caption = 'Vendor Item No.';
        SalesUnitPrice_Caption = 'Sales (Unit Price)';
        VendorNo_Caption = 'Vendor No.';
    }

    trigger OnPreReport()
    begin
        Reportfilter := AuxItemLedgerEntry.GetFilter("Item No.");
    end;

    var
        PrintAlsoWithoutSale: Boolean;
        ItemFilter: Text[250];
        Profit: Decimal;
        ItemProfitPct: Decimal;
        Item: Record Item;
        Reportfilter: Text;
        ShowVendorItemNo: Boolean;
        Item1: Record Item;
        VendorItemNo: Text;
        ItemSalesQty: Decimal;
        ItemSalesAmount: Decimal;
        ValueEntry: Record "Value Entry";
        ItemCOG: Decimal;
        ShowVendorNo: Boolean;
        Pct1Lbl: Label '%1: %2', locked = true;
}

