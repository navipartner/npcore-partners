report 6014439 "Item Sales Postings"
{
    // NPR70.00.00.00/LS/010714 : CASE 187451 : Convert Report to NAV 2013
    // NPR4.21/LS/20151210  CASE 227005  Changed report Name, Caption, report label
    //                                   Changed code + dataset names + Layout +  deleted unused variables
    // NPR5.23/JDH /20160513 CASE 240916 Removed Old VariaX Solution
    // NPR5.25/JLK /20160719 CASE 247113 Captions for CostAmount_Caption, SalesAmount_Caption and SaleRCY_Caption
    // NPR5.33/LS  /20170605 CASE 278326 Added Option to ShowVendorItemNo
    // NPR5.33/BHR /20170629 CASE 280196 Field "Salesperson Filter" not to be use
    // NPR5.48/ZESO/20181219 CASE 340243 Changed left margin of Report from 0 to 1.5 cm
    // NPR5.49/ZESO/20181219 CASE 348784 Added New Column Sales Unit Price and Report filter
    // NPR5.50/ZESO/20190528 CASE 355450 Calculate Sales(Qty) and Sales Amount(Actual) directly from Value Entry
    // NPR5.51/ZESO/20190730 CASE 363111 Added Option to Show Vendor No
    // NPR5.51/ZESO/20190731 CASE 332037 Removed Option Print Sale Inc. VAT
    // NPR5.55/BHR/20200728  CASE 361515 remove Key reference not used in AL
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Item Sales Postings.rdlc';

    Caption = 'Item Sales Postings';
    UsageCategory = ReportsAndAnalysis;
    UseSystemPrinter = true;

    dataset
    {
        dataitem("Item Ledger Entry";"Item Ledger Entry")
        {
            DataItemTableView = SORTING("Item No.","Entry Type","Posting Date") ORDER(Ascending) WHERE("Entry Type"=FILTER(Sale));
            RequestFilterFields = "Item No.","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code","Salesperson Code","Item Group No.",Quantity,Description;
            column(ItemFilters;StrSubstNo('%1: %2',TableCaption,ItemFilter))
            {
            }
            column(DimFilters;GetFilter("Global Dimension 1 Code"))
            {
            }
            column(COMPANYNAME;CompanyName)
            {
            }
            column(ItemNo_ItemLedgerEntry;"Item Ledger Entry"."Item No.")
            {
            }
            column(EntryNo_ItemLedgerEntry;"Item Ledger Entry"."Entry No.")
            {
            }
            column(No_Item;Item."No.")
            {
            }
            column(Description_Item;Item.Description)
            {
            }
            column(UnitCost_Item;Item."Unit Cost")
            {
            }
            column(UnitPrice_Item;Item."Unit Price")
            {
            }
            column(SalesQty_Item;ItemSalesQty)
            {
            }
            column(SalesLCY_Item;ItemSalesAmount)
            {
            }
            column(Profit;Profit)
            {
            }
            column(ItemProfitPct;ItemProfitPct)
            {
            }
            column(Inventory_Item;Item.Inventory)
            {
            }
            column(Quantity_ItemLedgerEntry;"Item Ledger Entry".Quantity)
            {
            }
            column(ShowVendorItemNo;ShowVendorItemNo)
            {
            }
            column(VendorItemNo;VendorItemNo)
            {
            }
            column(Sales_Unit_Price;Item."Unit Price" *ItemSalesQty)
            {
            }
            column(Report_Filters;"Item Ledger Entry".GetFilters)
            {
            }
            column(ShowVendorNo_;ShowVendorNo)
            {
            }
            column(VendorNo_;Item."Vendor No.")
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
                //-NPR5.33 [280196]
                //Item.SETFILTER("Salesperson Filter", GETFILTER("Salesperson Code"));
                //+NPR5.33 [280196]
                //-NPR5.23 [240916]
                // Item.SETFILTER("Size Filter", GETFILTER(Size));
                // Item.SETFILTER("Color Filter", GETFILTER(Color));
                //+NPR5.23 [240916]



                Item.SetFilter("Date Filter", GetFilter("Posting Date"));
                Item.CalcFields(Inventory);

                CurrReport.CreateTotals(Item."Sales (Qty.)",Item."Sales (LCY)",Profit,Item.Inventory);

                Item.CalcFields("Sales (Qty.)","Sales (LCY)","COGS (LCY)","Assembly BOM");

                //-NPR5.50 [355450]
                ItemSalesQty := 0;
                ItemSalesAmount := 0;
                ItemCOG := 0;
                Profit := 0;
                ValueEntry.Reset;
                //-NPR5.55 [361515]
                //ValueEntry.SETCURRENTKEY("Item Ledger Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code","Salespers./Purch. Code","Item Group No.","Item No.","Vendor No.","Source No.","Group Sale");
                //+NPR5.55 [361515]
                ValueEntry.SetRange("Item Ledger Entry Type",ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.SetFilter("Global Dimension 1 Code",GetFilter("Global Dimension 1 Code"));
                ValueEntry.SetFilter("Global Dimension 2 Code",GetFilter("Global Dimension 2 Code"));
                ValueEntry.SetFilter("Location Code",GetFilter("Location Code"));
                ValueEntry.SetFilter("Posting Date",GetFilter("Posting Date"));
                ValueEntry.SetFilter("Salespers./Purch. Code",GetFilter("Salesperson Code"));
                ValueEntry.SetRange("Item No.","Item Ledger Entry"."Item No.");
                ValueEntry.CalcSums("Invoiced Quantity","Sales Amount (Actual)","Cost Amount (Actual)");
                ItemSalesQty := -ValueEntry."Invoiced Quantity";
                ItemSalesAmount := ValueEntry."Sales Amount (Actual)";
                ItemCOG := -ValueEntry."Cost Amount (Actual)";
                Profit := ItemSalesAmount - ItemCOG;
                //Profit := Item."Sales (LCY)" - Item."COGS (LCY)";

                //IF Item."Sales (LCY)" <> 0 THEN
                  //ItemProfitPct := ROUND(Profit / Item."Sales (LCY)"  * 100,0.1)
                //ELSE
                  //ItemProfitPct := 0;

                if ItemSalesAmount <> 0 then
                  ItemProfitPct := Round(Profit / ItemSalesAmount  * 100,0.1)
                else
                  ItemProfitPct := 0;
                //-NPR5.50 [355450]


                //-NPR5.51 [332037]
                //IF PrintUsingInclVAT THEN
                  //Item."Sales (LCY)" += 0;
                //+NPR5.51 [332037]

                SetRange("Item No.","Item No.");
                //-NPR4.21
                //FIND('+');
                FindLast;
                //+NPR4.21
                SetFilter("Item No.", Reportfilter);

                //-NPR5.33 [278326]
                VendorItemNo := '';
                if ShowVendorItemNo then
                  if Item1.Get("Item Ledger Entry"."Item No.") then
                    VendorItemNo := Item1."Vendor Item No.";
                //+NPR5.33 [278326]
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(PrintAlsoWithoutSale;PrintAlsoWithoutSale)
                {
                    Caption = 'Include Items That Has Not Been Sold';
                }
                field(ShowVendorItemNo;ShowVendorItemNo)
                {
                    Caption = 'Show Vendor Item No.';
                }
                field(ShowVendorNo;ShowVendorNo)
                {
                    Caption = 'Show Vendor No';
                }
            }
        }

        actions
        {
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
        Reportfilter := "Item Ledger Entry".GetFilter("Item No.");
    end;

    var
        PrintAlsoWithoutSale: Boolean;
        PrintUsingInclVAT: Boolean;
        ItemFilter: Text[250];
        Profit: Decimal;
        ItemProfitPct: Decimal;
        Item: Record Item;
        Reportfilter: Text[1024];
        "//-NPR5.33": Integer;
        ShowVendorItemNo: Boolean;
        Item1: Record Item;
        VendorItemNo: Text;
        "//+NPR5.33": Integer;
        ItemSalesQty: Decimal;
        ItemSalesAmount: Decimal;
        ValueEntry: Record "Value Entry";
        ItemCOG: Decimal;
        ShowVendorNo: Boolean;
}

