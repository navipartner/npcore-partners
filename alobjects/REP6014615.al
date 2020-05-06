report 6014615 "Sales Statistics Per Variety"
{
    // NPR70.00.00.00/LS/20150116  CASE  204024 : Convert report
    // NPR5.25/LS/20151201  CASE 226253 Amend report to using Variety instead of VariantX + COrrect Report
    // NPR5.29/JLK /20170112  CASE 263047 Added Filters on Location Code and Dimensions
    // NPR5.29/TS  /20170119  CASE 261428 Correted Inventory Calculation
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj
    // NPR5.46/ZESO/20180919  CASE 327284 Added Totals for Sales(Qty), Cost of Goods(LCY),Sale(LCY) and average of columns Profit and Profit %. and Option to print the totals or not.
    // NPR5.51/ANPA/20190607  CASE 356180 Corrected Inventory Calculation
    // NPR5.54/BHR /20200212  CASE 390474 Add total Inventory Per Item
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Sales Statistics Per Variety.rdlc';

    Caption = 'Sales Statistics Variant';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item;Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.";
            column(PrintTotal_;PrintTotal)
            {
            }
            column(No_Item;Item."No.")
            {
            }
            column(No2_Item;Item."No. 2")
            {
            }
            column(Description_Item;Item.Description)
            {
            }
            column(VendorNo_Item;Item."Vendor No.")
            {
            }
            column(VendorItemNo_Item;Item."Vendor Item No.")
            {
            }
            column(InventoryPostingGroup_Item;Item."Inventory Posting Group")
            {
            }
            column(DateFilters;TextDateFilter)
            {
            }
            column(ItemFilters;TextItemFilter)
            {
            }
            column(COMPANYNAME;CompanyName)
            {
            }
            column(PrintAlsoWithoutSale;PrintAlsoWithoutSale)
            {
            }
            column(ObjectDetails;Format(AllObj."Object ID"))
            {
            }
            dataitem("Item Variant";"Item Variant")
            {
                DataItemLink = "Item No."=FIELD("No.");
                column(Code_ItemVariant;"Item Variant".Code)
                {
                }
                column(ItemNo_ItemVariant;"Item Variant"."Item No.")
                {
                }
                column(Description_ItemVariant;"Item Variant".Description)
                {
                }
                column(Description2_ItemVariant;"Item Variant"."Description 2")
                {
                }
                column(VariantUnitPrice;VariantUnitPrice)
                {
                }
                column(VariantUnitCost;VariantUnitCost)
                {
                }
                column(SalesQty;SalesQty)
                {
                }
                column(SalesAmount;SalesAmount)
                {
                }
                column(ItemProfit;ItemProfit)
                {
                }
                column(ItemProfitPct;ItemProfitPct)
                {
                }
                column(ItemInventory;ItemInventory)
                {
                }
                column(COGSAmount;COGSAmount)
                {
                }
                column(TotalSalesQty_;TotalSalesQty)
                {
                }
                column(TotalCOG_;TotalCOG)
                {
                }
                column(TotalSaleCLY_;TotalSaleLCY)
                {
                }
                column(AverageProfit_;AverageProfit)
                {
                }
                column(AverageProfitPerc_;AverageProfitPerc)
                {
                }
                column(TotalCount_;TotalCount)
                {
                }
                column(TotalProfit_;TotalProfit)
                {
                }
                column(TotalProfitPerc_;TotalProfitPerc)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    //-NPR5.25
                    CalculateVariantCost(Item,"Item Variant");

                    //-NPR5.29
                    if not PrintAlsoWithoutSale then begin
                      //-NPR5.29
                      //IF (ItemInventory = 0) OR (SalesAmount = 0) THEN
                      if (ItemInventory = 0) and (SalesAmount = 0) then
                      //+NPR5.29
                       CurrReport.Skip;
                    end;
                    //+NPR5.29

                    //+NPR5.25




                    //-NPR5.46] [327284]
                    TotalSalesQty += SalesQty;
                    TotalSaleLCY += SalesAmount;
                    TotalCOG += VariantUnitCost * SalesQty;

                    TotalCount += 1;
                    TotalProfit += ItemProfit;
                    TotalProfitPerc += ItemProfitPct;


                    if TotalCount <> 0 then begin
                      AverageProfit := TotalProfit/TotalCount;
                      AverageProfitPerc := TotalProfitPerc/TotalCount;
                    end;
                    //+NPR5.46] [327284]
                end;
            }

            trigger OnAfterGetRecord()
            var
                ItemLedgerEntry: Record "Item Ledger Entry";
            begin
                CalcFields("Assembly BOM");

                ItemInventory := 0;
                SalesQty := 0;
                SalesAmount :=0;
                COGSAmount := 0;
                ItemProfit := 0;
                COGSAmount := 0;


                ItemVariant.Reset;
                ItemVariant.SetRange("Item No.","No.");
                if not ItemVariant.FindFirst then
                  CurrReport.Skip;

                if not PrintAlsoWithoutSale then begin
                  ItemLedgerEntry.Reset;
                  ItemLedgerEntry.SetRange("Item No.","No.");
                  ItemLedgerEntry.SetRange("Entry Type",ItemLedgerEntry."Entry Type"::Sale);
                  ItemLedgerEntry.SetFilter("Posting Date",GetFilter("Date Filter"));
                  //-NPR5.29
                  ItemLedgerEntry.SetFilter("Location Code",GetFilter("Location Filter"));
                  ItemLedgerEntry.SetFilter("Global Dimension 1 Code", GetFilter("Global Dimension 1 Filter"));
                  ItemLedgerEntry.SetFilter("Global Dimension 2 Code", GetFilter("Global Dimension 2 Filter"));
                  //+NPR5.29
                  if ItemLedgerEntry.IsEmpty then
                    CurrReport.Skip;
                end;
            end;

            trigger OnPreDataItem()
            begin
                //-NPR5.46 [327284]
                TotalCount := 0;
                AverageProfit := 0;
                AverageProfitPerc := 0;
                TotalCOG := 0;
                TotalProfit := 0;
                TotalProfitPerc := 0;
                TotalSaleLCY := 0;
                TotalSalesQty := 0;
                //+NPR5.46  [327284]
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
                    Caption = 'Include Items Not Sold';
                }
                field(PrintTotals;PrintTotal)
                {
                    Caption = 'Print Totals';
                }
            }
        }

        actions
        {
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
        GLSetup.Get;
        //-NPR5.25
        //-NPR5.46 [322752]
        // Object.SETRANGE(ID, 6014615);
        // Object.SETRANGE(Type, 3);
        // Object.FINDFIRST;
         AllObj.SetRange("Object ID", 6014615);
         AllObj.SetRange("Object Type", 3);
         AllObj.FindFirst;
        //+NPR5.46 [322752]
        if Item.GetFilter("Date Filter") <> '' then
          TextDateFilter := StrSubstNo(Text000,Item.GetFilter("Date Filter"));

        if Item.GetFilters <> '' then
          TextItemFilter := StrSubstNo('%1: %2',Item.TableCaption,Item.GetFilters);
        //+NPR5.25
    end;

    var
        GLSetup: Record "General Ledger Setup";
        InvPostingGroup: Record "Inventory Posting Group";
        SalesQty: Decimal;
        SalesAmount: Decimal;
        COGSAmount: Decimal;
        ItemProfit: Decimal;
        ItemProfitPct: Decimal;
        UnitPrice: Decimal;
        UnitCost: Decimal;
        PrintAlsoWithoutSale: Boolean;
        ItemInventory: Decimal;
        ColorAndSize: Text[50];
        AvgUnitCost: Decimal;
        AvgUnitPrice: Decimal;
        Text000: Label 'Period: %1';
        ItemVariant: Record "Item Variant";
        VariantUnitPrice: Decimal;
        VariantUnitCost: Decimal;
        "Object": Record "Object";
        TextDateFilter: Text;
        TextItemFilter: Text;
        AllObj: Record AllObj;
        TotalSalesQty: Decimal;
        TotalCOG: Decimal;
        TotalSaleLCY: Decimal;
        AverageProfit: Decimal;
        AverageProfitPerc: Decimal;
        TotalProfit: Decimal;
        TotalProfitPerc: Decimal;
        TotalCount: Integer;
        PrintTotal: Boolean;

    procedure CalculateVariantCost(var Item2: Record Item;ItemVariant: Record "Item Variant")
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        Location: Record Location;
        Item3: Record Item;
    begin
        TempItemLedgEntry.Init;
        ItemLedgEntry.Reset;
        ItemLedgEntry.SetRange("Item No.",ItemVariant."Item No.");
        ItemLedgEntry.SetRange("Variant Code",ItemVariant.Code);
        ItemLedgEntry.SetRange("Entry Type",ItemLedgEntry."Entry Type"::Sale);
        ItemLedgEntry.SetFilter("Posting Date",Item2.GetFilter("Date Filter"));
        //-NPR5.29
        ItemLedgEntry.SetFilter("Location Code",Item2.GetFilter("Location Filter"));
        ItemLedgEntry.SetFilter("Global Dimension 1 Code", Item2.GetFilter("Global Dimension 1 Filter"));
        ItemLedgEntry.SetFilter("Global Dimension 2 Code", Item2.GetFilter("Global Dimension 2 Filter"));
        //+NPR5.29
        if ItemLedgEntry.FindSet then repeat
          ItemLedgEntry.CalcFields("Sales Amount (Actual)","Cost Amount (Actual)","Cost Amount (Non-Invtbl.)");

          TempItemLedgEntry.Quantity += ItemLedgEntry.Quantity;
          TempItemLedgEntry."Invoiced Quantity" += ItemLedgEntry."Invoiced Quantity";
          TempItemLedgEntry."Sales Amount (Actual)" += ItemLedgEntry."Sales Amount (Actual)";
          TempItemLedgEntry."Cost Amount (Actual)" += ItemLedgEntry."Cost Amount (Actual)";
          TempItemLedgEntry."Cost Amount (Non-Invtbl.)" += ItemLedgEntry."Cost Amount (Non-Invtbl.)";
        until ItemLedgEntry.Next = 0;
        //-NPR5.25
        //ItemInventory := TempItemLedgEntry.Quantity;
        //-NPR5.29

        //-NPR5.51 [356180]
        if Item3.Get(Item2."No.") then;
        Item3.CopyFilters(Item2);
        Item3.SetFilter("Variant Filter",ItemVariant.Code);
        Item3.CalcFields(Inventory);
        ItemInventory :=  Item3.Inventory;

        // Location.SETFILTER(Code,ItemLedgEntry."Location Code");
        // //Location.SETFILTER(Code,Item2.GETFILTER("Location Filter"));
        // Location.SETRANGE("Use As In-Transit",FALSE);
        // IF Location.FINDSET THEN BEGIN
        //  REPEAT
        //    IF Item3.GET(Item2."No.") THEN;
        //    Item3.COPYFILTERS(Item2);
        //    Item3.SETFILTER("Location Filter",Location.Code);
        //    Item3.SETFILTER("Variant Filter",ItemVariant.Code);
        //    Item3.CALCFIELDS(Inventory);
        //    ItemInventory :=  Item3.Inventory;
        //  UNTIL Location.NEXT = 0;
        // END;

        //+NPR5.51 [356180]
        //+NPR5.29
        //+NPR5.25
        SalesQty := -TempItemLedgEntry."Invoiced Quantity";
        SalesAmount := TempItemLedgEntry."Sales Amount (Actual)";
        COGSAmount := TempItemLedgEntry."Cost Amount (Actual)" + TempItemLedgEntry."Cost Amount (Non-Invtbl.)";
        ItemProfit := SalesAmount + COGSAmount;


        if SalesAmount <> 0 then
          ItemProfitPct := Round(100 * ItemProfit / SalesAmount,0.1)
        else
          ItemProfitPct := 0;

        UnitPrice := CalcPerUnit(SalesAmount,SalesQty);
        UnitCost := -CalcPerUnit(COGSAmount,SalesQty);

        VariantUnitPrice := UnitPrice;
        VariantUnitCost := UnitCost;
    end;

    procedure CalcPerUnit(Amount: Decimal;Qty: Decimal): Decimal
    begin
        if Qty <> 0 then
          exit(Round(Amount / Abs(Qty),GLSetup."Unit-Amount Rounding Precision"));
        exit(0);
    end;
}

