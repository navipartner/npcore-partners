report 6014416 "Sale Statistics per Vendor"
{
    // NPR70.00.00.00/LS/27-11-12 CASE 143264 : Convert Report to Nav 2013
    // NPR4.14/KN/20150818 CASE 220286 Removed field with 'NAVIPARTNER K�benhavn 2000' caption from footer
    // NPR4.21/LS/20160321  CASE 236888 Correction of report
    // NPR5.26/JLK /20160824  CASE 249097 Corrected SalesDg formula in rdlc to calculate correct value instead of using Sum function
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on obsolite property CurrReport_PAGENO
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.40/TJ  /20180319  CASE 307717 Replaced hardcoded dates with DMY2DATE structure
    // NPR5.54/LS  /20190205  CASE 389133 Changed Global var Report_Caption_Lbl from 'Item Sale per Vendor' to 'Sale Statistics per Vendor'
    // NPR5.54/LS  /20190206  CASE 389133 Changed Global var Inventory_Caption_Lbl from 'Net Inv. Change' to 'Inventory per Date'
    // NPR5.54/ANPA/20200327  CASE 392703 Avoid 0 sales and changed Net_Change_Item from Net change to Inventory
    DefaultLayout = RDLC;
    RDLCLayout = './Sale Statistics per Vendor.rdlc';

    Caption = 'Sale Statistics Per Vendor';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Vendor;Vendor)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.","Search Name","Vendor Posting Group","Date Filter","Global Dimension 1 Filter";
            column(PageNoCaptionLbl;PageNoCaptionLbl)
            {
            }
            column(Report_Caption;Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME;CompanyName)
            {
            }
            column(Date_Filters_Caption;Date_Filters_Caption_Lbl)
            {
            }
            column(Creditor_Filter_Caption;Creditor_Filter_Caption_Lbl)
            {
            }
            column(Name_Caption;Name_Caption_Lbl)
            {
            }
            column(Inventory_Caption;Inventory_Caption_Lbl)
            {
            }
            column(InventoryValue_Caption;InventoryValue_Caption_Lbl)
            {
            }
            column(Unit_Value_Caption;Unit_Value_Caption_Lbl)
            {
            }
            column(Profit_LCY_Caption;Profit_LCY_Caption_Lbl)
            {
            }
            column(Profit_Pct_Caption;Profit_Pct_Caption_Lbl)
            {
            }
            column(Purchases_LCY_Caption;Purchases_LCY_Caption_Lbl)
            {
            }
            column(Sales_Qty_Caption;Sales_Qty_Caption_Lbl)
            {
            }
            column(Cost_Caption;Cost_Caption_Lbl)
            {
            }
            column(Sale_Caption;Sale_Caption_Lbl)
            {
            }
            column(Speed_Caption;Speed_Caption_Lbl)
            {
            }
            column(Avg_Inventory_Caption;Avg_Inventory_Caption_Lbl)
            {
            }
            column(OnlyTotal;OnlyTotal)
            {
            }
            column(DateFilter_Vendor;DateFilterVendor)
            {
            }
            column(No_Vendor;Vendor."No.")
            {
            }
            column(Name_Vendor;Vendor.Name)
            {
            }
            column(Avoid0Sales;Avoid0Sales)
            {
            }
            column(InventoryDate;InventoryDate)
            {
            }
            column(NextPageGroupNo;NextPageGroupNo)
            {
            }
            dataitem(Item;Item)
            {
                CalcFields = "Sales (Qty.)","COGS (LCY)","Sales (LCY)","Purchases (LCY)";
                DataItemLink = "Vendor No."=FIELD("No.");
                PrintOnlyIfDetail = false;
                RequestFilterFields = "Item Group";
                column(No_Item;Item."No.")
                {
                }
                column(Description_Item;Item.Description)
                {
                }
                column(Net_Change_Item;Item1."Net Change")
                {
                }
                column(InventoryValuation;InventoryValuation)
                {
                }
                column(ActualSales;ActualSales)
                {
                }
                column(db;db)
                {
                }
                column(dg;dg)
                {
                }
                column(PurchasesLCY_Item;Item."Purchases (LCY)")
                {
                }
                column(SalesQty_Item;Item."Sales (Qty.)")
                {
                }
                column(COGSLCY_Item;Item."COGS (LCY)")
                {
                }
                column(SalesLCY_Item;Item."Sales (LCY)")
                {
                }
                column(SalesDb;SalesDb)
                {
                }
                column(SalesDg;SalesDg)
                {
                }
                column(Speed;Speed)
                {
                }
                column(Inventory;Inventory)
                {
                }
                column(AvgInventory;AvgInventory)
                {
                }
                column(Name_Footer2;Vendor.Name+Text10600000)
                {
                }
                column(TextNetChangeDate;TextNetChangeDate)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    StartDateInventory := 0;
                    EndDateInventory   := 0;
                    PeriodPurchaseQty  := 0;
                    ItemUsage          := 0;
                    AvgInventory       := 0;
                    Speed              := 0;
                    //-NPR5.54 [384505]
                    Inventory :=  0;
                    //+NPR5.54 [384505]

                    Item1.Get("No.");
                    Item1.CalcFields("Net Change");

                    if "Price Includes VAT" then begin
                      if VatPostingSetup.Get("VAT Bus. Posting Gr. (Price)","VAT Prod. Posting Group") then;
                      ActualSales := Item1."Net Change"*("Unit Price"/(1+(VatPostingSetup."VAT %" / 100)));
                    end else
                      ActualSales := Item1."Net Change" * "Unit Price";

                    InventoryValuation := (Item1."Net Change" * "Last Direct Cost");
                    db := ActualSales - InventoryValuation;

                    if ("Unit Price" <> 0) and (ActualSales <> 0) then
                      dg := 100 * (db / ActualSales)
                    else
                      dg := 0;

                    SalesDb := ("Sales (LCY)" - "COGS (LCY)");

                    if "Sales (LCY)" <> 0 then
                      SalesDg := 100 * (SalesDb / "Sales (LCY)")
                    else
                      SalesDg := 0;

                    Item2.Reset;
                    if Item2.Get(Item."No.") then begin
                      Item2.SetFilter("Date Filter", '..%1', StartDate);
                      Item2.CalcFields("Net Change");
                      StartDateInventory :=  Item2."Net Change";
                    end;

                    Item2.Reset;
                    if Item2.Get(Item."No.") then begin
                      Item2.SetFilter("Date Filter", '..%1', EndDate );
                      Item2.CalcFields("Net Change");
                      EndDateInventory :=  Item2."Net Change";
                    end;

                    Item2.Reset;
                    if Item2.Get(Item."No.") then begin
                      Item2.SetRange(Item2."Date Filter", StartDate, EndDate );
                      Item2.CalcFields("Purchases (Qty.)");
                      PeriodPurchaseQty :=  Item2."Purchases (Qty.)";
                    end;

                    //-NPR5.54 [384505]
                    Item2.Reset;
                    if Item2.Get(Item."No.") then begin
                      Item2.CopyFilters(Item);
                      Item2.SetFilter("Date Filter", '..%1', InventoryDate);
                      Item2.CalcFields("Net Change");
                      Inventory :=  Item2."Net Change";
                    end;
                    //+NPR5.54 [384505]

                    ItemUsage := (StartDateInventory + PeriodPurchaseQty) - EndDateInventory;

                    if (StartDateInventory + EndDateInventory) <> 0 then
                       AvgInventory := (StartDateInventory+EndDateInventory)/2;

                    if (ItemUsage <> 0) and (AvgInventory <>0) then
                       Speed := ItemUsage/AvgInventory;

                    //-NPR70.00.00.00
                    InventoryValVendor   += InventoryValuation;
                    SalesValVendor       += ActualSales;
                    dbVendor             := dbVendor + db;
                    //-NPR5.54 [384505]
                    //NetChangeVendor      += Item1."Net Change";
                    NetChangeVendor      += Inventory;
                    //+NPR5.54 [384505]
                    SalesQtyVendor       += Item."Sales (Qty.)";
                    COGS_LCY_Vendor      += Item."COGS (LCY)";
                    Sales_LCY_Vendor     += Item."Sales (LCY)";
                    Purchases_LCY_Vendor += Item."Purchases (LCY)";
                    SpeedVendor          += Speed;
                    AvgInventory_Vendor  += AvgInventory;
                    //+NPR70.00.00.00
                end;

                trigger OnPreDataItem()
                begin
                    Vendor.CopyFilter("Global Dimension 1 Filter",Item."Global Dimension 1 Filter");

                    Item1.CopyFilters(Item);

                    if (StartDate <> 0D) and (EndDate <> 0D) then begin
                      if StartDate = EndDate then
                        Item1.SetFilter("Date Filter", '..%1', EndDate)
                      else
                        Item1.SetRange("Date Filter", StartDate, EndDate);

                    end
                    else begin
                      //-NPR5.40 [307717]
                      //StartDate := 010180D;
                      StartDate := DMY2Date(1,1,1980);
                      //+NPR5.40 [307717]
                      EndDate   := InventoryDate;
                      //-NPR5.40 [307717]
                      //Item1.SETRANGE("Date Filter", 010180D, InventoryDate);
                      Item1.SetRange("Date Filter",StartDate,InventoryDate);
                      //+NPR5.40 [307717]
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                //-NPR70.00.00.00
                if PrintOnePerPage then
                  NextPageGroupNo += 1;
                //+NPR70.00.00.00
            end;

            trigger OnPreDataItem()
            begin
                //-NPR5.39
                //CurrReport.NEWPAGEPERRECORD := PrintOnePerPage;
                //+NPR5.39

                //-NPR70.00.00.00
                NextPageGroupNo := 1;
                //+NPR70.00.00.00
            end;
        }
        dataitem("Integer";"Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            column(Number_Integer;Integer.Number)
            {
            }
            column(InventoryValVendor;InventoryValVendor)
            {
            }
            column(SalesValVendor;SalesValVendor)
            {
            }
            column(dbVendor;dbVendor)
            {
            }
            column(NetChangeVendor;NetChangeVendor)
            {
            }
            column(SalesQtyVendor;SalesQtyVendor)
            {
            }
            column(COGS_LCY_Vendor;COGS_LCY_Vendor)
            {
            }
            column(Sales_LCY_Vendor;Sales_LCY_Vendor)
            {
            }
            column(Purchases_LCY_Vendor;Purchases_LCY_Vendor)
            {
            }
            column(SpeedVendor;SpeedVendor)
            {
            }
            column(AvgInventory_Vendor;AvgInventory_Vendor)
            {
            }
            column(Total_Caption;Total_Caption_Lbl)
            {
            }
            column(DgVendor;DgVendor)
            {
            }
            column(SalesDbVendor;SalesDbVendor)
            {
            }
            column(SalesDgVendor;SalesDgVendor)
            {
            }

            trigger OnAfterGetRecord()
            begin
                //-NPR70.00.00.00
                if SalesValVendor <>0 then
                  DgVendor := 100 * (dbVendor / SalesValVendor)
                else
                  DgVendor := 0;

                SalesDbVendor := (Sales_LCY_Vendor - COGS_LCY_Vendor);

                if Sales_LCY_Vendor <> 0 then
                  SalesDgVendor := 100 * (SalesDbVendor / Sales_LCY_Vendor)
                else
                  SalesDgVendor := 0;
                //+NPR70.00.00.00
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(InventoryDate;InventoryDate)
                    {
                        Caption = 'Inventory Per Date';
                    }
                    field(PrintOnePerPage;PrintOnePerPage)
                    {
                        Caption = 'New Page Per Creditor';
                    }
                    field(OnlyTotal;OnlyTotal)
                    {
                        Caption = 'Totals Only';
                    }
                    field(Avoid0Sales;Avoid0Sales)
                    {
                        Caption = 'Avoid 0 Sales';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            InventoryDate := Today;
        end;
    }

    labels
    {
        Page_Caption = 'Page';
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);

        //-NPR5.39
        // Object.SETRANGE(ID, 6014416);
        // Object.SETRANGE(Type, 3);
        // //-NPR4.21
        // //Object.FIND('-');
        // Object.FINDFIRST;
        // //+NPR4.21
        //-NPR5.39

        if Vendor.GetFilter("Date Filter") <> '' then
           begin
              StartDate := Vendor.GetRangeMin("Date Filter");
              EndDate := Vendor.GetRangeMax("Date Filter");
           end;

        //-NPR4.21
        //-NPR70.00.00.00
        //IF Vendor.GETFILTER("Date Filter") <> '' THEN
        //  DateFilterVendor := Date_Filters_Caption_Lbl + ' ' + Vendor.GETFILTER("Date Filter")
        //ELSE
        //  DateFilterVendor := '';
        if Vendor.GetFilters <> '' then
          DateFilterVendor := Vendor.GetFilters
        else
          DateFilterVendor := 'As at ' + Format(InventoryDate);
        //+NPR4.21

        PageGroupNo := 1;
        NextPageGroupNo := 1;
        //+NPR70.00.00.00
    end;

    var
        PrintOnePerPage: Boolean;
        CompanyInfo: Record "Company Information";
        ActualSales: Decimal;
        db: Decimal;
        dg: Decimal;
        InventoryValuation: Decimal;
        SalesDb: Decimal;
        SalesDg: Decimal;
        OnlyTotal: Boolean;
        VatPostingSetup: Record "VAT Posting Setup";
        Item1: Record Item;
        InventoryDate: Date;
        StartDate: Date;
        EndDate: Date;
        Item2: Record Item;
        StartDateInventory: Decimal;
        EndDateInventory: Decimal;
        PeriodPurchaseQty: Decimal;
        ItemUsage: Decimal;
        AvgInventory: Decimal;
        Speed: Decimal;
        Text10600000: Label ' total';
        PageNoCaptionLbl: Label 'Page';
        Report_Caption_Lbl: Label 'Sale Statistics per Vendor';
        Date_Filters_Caption_Lbl: Label 'Date filter';
        Creditor_Filter_Caption_Lbl: Label 'Creditor filter';
        Name_Caption_Lbl: Label 'Name';
        Inventory_Caption_Lbl: Label 'Inventory per Date';
        InventoryValue_Caption_Lbl: Label 'Inv.Value @ Cost';
        Unit_Value_Caption_Lbl: Label 'Inv. Value @ S.Price';
        Profit_LCY_Caption_Lbl: Label 'Profit (LCY)';
        Profit_Pct_Caption_Lbl: Label 'Profit %';
        Purchases_LCY_Caption_Lbl: Label 'Purchases (LCY)';
        Sales_Qty_Caption_Lbl: Label 'Sales (Qty)';
        Cost_Caption_Lbl: Label 'COGS (LCY)';
        Sale_Caption_Lbl: Label 'Sales (LCY)';
        Speed_Caption_Lbl: Label 'Speed';
        Avg_Inventory_Caption_Lbl: Label 'Average Inventory';
        Total_Caption_Lbl: Label 'Total';
        InventoryValVendor: Decimal;
        SalesValVendor: Decimal;
        dbVendor: Decimal;
        NetChangeVendor: Decimal;
        SalesQtyVendor: Decimal;
        COGS_LCY_Vendor: Decimal;
        Sales_LCY_Vendor: Decimal;
        Purchases_LCY_Vendor: Decimal;
        SpeedVendor: Decimal;
        AvgInventory_Vendor: Decimal;
        DgVendor: Decimal;
        SalesDbVendor: Decimal;
        SalesDgVendor: Decimal;
        DateFilterVendor: Text;
        PageGroupNo: Integer;
        NextPageGroupNo: Integer;
        TextNetChangeDate: Text;
        Avoid0Sales: Boolean;
        Inventory: Integer;
}

