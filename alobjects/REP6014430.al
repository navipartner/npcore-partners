report 6014430 "Item Sales Statistics/Provider"
{
    // NPR4.12/TSA/2015-06-30/217683 - Removed trailing CRLF on global text variable Text1060008
    // NPR4.16/TS/20151028  CASE 226008 Changed Report Caption
    // NPR5.25/LS/20160129  CASE 226251 Changed formatting codes/Dataset names/Variables name
    //                                  Changed Report caption from DAN=Saelger oms pr. varegruppe;ENU=Sales Person Trn. by Item Gr.;NOR=Saelger oms pr. varegruppe
    //                                                        to DAN=Vare salgsstatistik/leverand�ropdelt;ENU=Item sales statistics/provider split
    // NPR5.25/JLK /20160627 CASE 226251 Removed field "Belong to item gr no."
    //                                   Adjusted fields "Sales Qty" to contain decimal places and moved Total to left
    //                                   Changed Qty_cap from DAN=Forventet tilgang;ENU=Anticipated acces to DAN=Antal i k�bsordre;ENU=Qty. on Purch. Order
    //                                   Corrected Total Issue
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer in Request Page
    // NPR5.38/JLK /20180125  CASE 303595 Removed Spaced on Request Page Caption
    // NPR5.39/TJ  /20180206  CASE 302684 Changed Name property of request page control ValueMethod to english version
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.49/BHR /20190212  CASE 345313 Correct Report As per OMA
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Item Sales StatisticsProvider.rdlc';

    Caption = 'Sales Person Trn. by Item Gr.';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Integer";"Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            column(COMPANYNAME;CompanyName)
            {
            }
            column(CompanyInfoPicture;CompanyInformation.Picture)
            {
            }
            column(GlobalLanguage;GlobalLanguage)
            {
            }
            column(ShowItem;ShowItem)
            {
                AutoFormatType = 1;
            }
            column(ShowItemWithSales;ShowItemWithSales)
            {
                AutoFormatType = 2;
            }
            column(ShowItemGroup;ShowItemGroup)
            {
            }
            column(DateFilter;DateFilter)
            {
            }
            column(FilterDesc;FilterDesc)
            {
            }
            column(InventoryValueDesc;InventoryValueDesc)
            {
            }

            trigger OnAfterGetRecord()
            begin
                DateFilter := Text10600002 + ' ' + Format(Item.GetFilter("Date Filter"));
            end;
        }
        dataitem(Vendor;Vendor)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.";
            column(VendorNo;Vendor."No.")
            {
            }
            column(VendorName;Vendor.Name)
            {
            }
            column(VisVarer_Vendor;ShowItem)
            {
                AutoFormatType = 1;
            }
            column(ShowItemWithSales_Vendor;ShowItemWithSales)
            {
                AutoFormatType = 2;
            }
            column(ShowItemGroup_Vendor;ShowItemGroup)
            {
            }
            dataitem(Varegruppe;"Item Group")
            {
                DataItemTableView = SORTING("No.");
                PrintOnlyIfDetail = true;
                column(ItemGroupDesc;ItemGroupDesc)
                {
                }
                column(ItemGroupNo;Varegruppe."No.")
                {
                }
                column(ItemGroupFooterDesc;ItemGroupFooterDesc)
                {
                }
                dataitem(Item;Item)
                {
                    CalcFields = "Sales (Qty.)","Sales (LCY)","Scheduled Receipt (Qty.)","Qty. on Purch. Order","COGS (LCY)","Purchases (Qty.)";
                    DataItemLink = "Item Group"=FIELD("No.");
                    DataItemTableView = SORTING("Group sale","Item Group","Vendor No.") ORDER(Ascending);
                    RequestFilterFields = "Global Dimension 1 Filter","Date Filter";
                    column(ItemDesc;Item.Description)
                    {
                    }
                    column(ItemVendorItemNo;Item."Vendor Item No.")
                    {
                    }
                    column(ItemNo;Item."No.")
                    {
                    }
                    column(ItemItemGroup;Item."Item Group")
                    {
                    }
                    column(ItemPurchasesQty;Item."Purchases (Qty.)")
                    {
                        AutoFormatType = 1;
                    }
                    column(ItemSalesQty;Item."Sales (Qty.)")
                    {
                        DecimalPlaces = 0:5;
                    }
                    column(ItemSalesLCY;Item."Sales (LCY)")
                    {
                        AutoFormatType = 1;
                    }
                    column(db;Db)
                    {
                        AutoFormatType = 1;
                    }
                    column(dg;Dg)
                    {
                        AutoFormatType = 1;
                    }
                    column(Item2NetChange;Item2."Net Change")
                    {
                        AutoFormatType = 1;
                    }
                    column(StockValue;StockValue)
                    {
                        AutoFormatType = 1;
                    }
                    column(ItemQtyonPurchOrder;Item."Qty. on Purch. Order")
                    {
                        AutoFormatType = 1;
                    }
                    column(TurnoverRate;TurnoverRate)
                    {
                        AutoFormatType = 1;
                    }
                    column(forpct;Forpct)
                    {
                        AutoFormatType = 1;
                    }
                    column(ItemFooterDesc;ItemFooterDesc)
                    {
                    }
                    column(GnsBeholdningKpris;GnsBeholdningKpris)
                    {
                    }
                    column(antalmdr;Antalmdr)
                    {
                    }
                    column(SalesCost;SalesCost)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        ItemFooterDesc := Text10600005 + Varegruppe."No." + ' ' + Varegruppe.Description;
                        if ShowItemWithSales and ("Sales (Qty.)" = 0) then
                          CurrReport.Skip;

                        Clear(PurchPrice);
                        Clear(StockValue);
                        Clear(PeriodSales);
                        Clear(TurnoverRate);
                        Clear(ItemInventory);
                        Clear(GnsBeholdningKpris);

                        //Lagerbeholdning Ultimo
                        Item2.Get("No.");
                        Item2.SetFilter("Date Filter",'..%1', ValueDate);
                        Item2.CalcFields("Net Change");

                        //Lagervaerdi
                        if (ValueMethod = ValueMethod::"kostpris (gns.)") then
                          ItemCostMgt.CalculateAverageCost(Item,GNSCostPrice,PurchPrice);

                        if (ValueMethod = ValueMethod::"sidste koebspris") then
                          GNSCostPrice := "Last Direct Cost";

                        SalesCost := ("Sales (Qty.)" * GNSCostPrice);

                        Clear(PurchPrice);
                        PurchPrice := Round(GNSCostPrice * Item2."Net Change");
                        Hjemtagelsesomk := Round((GNSCostPrice * Item2."Net Change") / 100 * "Indirect Cost %");
                        StockValue := PurchPrice + Hjemtagelsesomk;
                        PeriodSales := "Sales (LCY)";

                        //Beregn db
                        Db := "Sales (LCY)" - "COGS (LCY)";

                        if "Sales (LCY)" <> 0 then
                          Dg := (Db / "Sales (LCY)") * 100
                        else
                          Dg := 0;

                        //Omsaetningshastighed
                        for x := 0 to Antalmdr do
                          //-NPR5.39
                          //ItemInventory += Beregn("No.",0D,CALCDATE('-'+FORMAT(x)+Text10600003,EndDate));
                          //-NPR5.49 [343119]
                          //ItemInventory += Beregn(0D,CALCDATE('-' + FORMAT(x) + Text10600003,EndDate));
                          ItemInventory += Beregn(0D,CalcDate('<-' + Format(x) + Text10600003 + '>',EndDate));
                          //+NPR5.49 [343119]
                          //+NPR5.39

                        GnsBeholdningKpris := (ItemInventory / (Antalmdr + 1));

                        if GnsBeholdningKpris <> 0 then begin
                         TurnoverRate := (SalesCost / GnsBeholdningKpris) * (12 / (Antalmdr + 1));
                         Forpct := (Db * 100 / GnsBeholdningKpris) * (12 / (Antalmdr + 1));
                        end
                        else begin
                          TurnoverRate := 0;
                          Forpct := 0;
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Vendor No.", Vendor."No.");
                        //-NPR5.39
                        // CurrReport.CREATETOTALS("Sales (Qty.)","Sales (LCY)","Qty. on Purch. Order","COGS (LCY)","Purchases (Qty.)");
                        // CurrReport.CREATETOTALS(db,StockValue,SalesCost,Item2."Net Change",GnsBeholdningKpris);
                        //+NPR5.39

                        StartDate := GetRangeMin("Date Filter");
                        EndDate := GetRangeMax("Date Filter");
                        Antalmdr := (Date2DMY(EndDate,3) - Date2DMY(StartDate,3)) * 12 + (Date2DMY(EndDate,2) - Date2DMY(StartDate,2));
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    ItemGroupDesc := Text10600004 + "No." + ' ' + Description;
                    ItemGroupFooterDesc := Text10600006 + Vendor.Name;
                end;

                trigger OnPreDataItem()
                begin
                    //-NPR5.39
                    // CurrReport.CREATETOTALS(db,StockValue,Item."Sales (Qty.)",Item."Sales (LCY)",Item."Qty. on Purch. Order",Item2."Net Change"
                    // ,Item."Sales (LCY)",Item."COGS (LCY)",GnsBeholdningKpris,SalesCost);
                    // CurrReport.CREATETOTALS(Item."Purchases (Qty.)");
                    //+NPR5.39

                    FilterDesc := Text10600001 + GetFilter("No.") + Text10600007 + Item.GetFilter("Global Dimension 1 Filter");
                    InventoryValueDesc := StrSubstNo(Text10600008,ValueDate,ValueMethod);
                    //DateFilter := Text10600002+' '+FORMAT(Item.GETFILTER("Date Filter"));
                end;
            }

            trigger OnPreDataItem()
            begin
                //-NPR5.39
                //CurrReport.CREATETOTALS(db,StockValue,Item."Sales (Qty.)",Item."Sales (LCY)",Item."Qty. on Purch. Order",Item2."Net Change"
                //,Item."Sales (LCY)",Item."COGS (LCY)",GnsBeholdningKpris,SalesCost);
                //CurrReport.CREATETOTALS(Item."Purchases (Qty.)");
                //ObjectDetails := FORMAT(Object.ID)+', '+FORMAT(Object."Version List");
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
                group(Setting)
                {
                    Caption = 'Setting';
                    field(ValueDate;ValueDate)
                    {
                        Caption = 'Value Date';
                    }
                    field(ShowItemWithSales;ShowItemWithSales)
                    {
                        Caption = 'Only Items With Sale';
                    }
                    field(ShowItem;ShowItem)
                    {
                        Caption = 'View Items';
                    }
                    field(ShowItemGroup;ShowItemGroup)
                    {
                        Caption = 'Show Item Groups';
                    }
                    field(InventoryValueIsBasedOn;ValueMethod)
                    {
                        Caption = 'Inventory Value Is Based On:';
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
        OnlyItemsWithSaleCap = 'Only items with sales';
        ShowItemsCap = 'Show items';
        Report_Caption = 'Sales Person Trn. by Item Gr.';
        Desc_Cap = 'Description';
        VendorItemNo_Cap = 'Supplier item no.';
        ItemNo_Cap = 'No.';
        ItemItemGroup_Cap = 'Belong to item gr. no.';
        Purchase_Cap = 'Purchase (qty)';
        SalesQty_Cap = 'Sales (qty)';
        SalesAmount_Cap = 'Sales (DKK)';
        db_Cap = 'Gross';
        dg_Cap = 'Advance %';
        varerec_Cap = 'Qty in inventory';
        lagerv_Cap = 'Value in inventory';
        Qty_cap = 'Anticipated acces';
        Oms_Cap = 'Turnover rate';
        for_Cap = 'Forr. %';
        Page_Caption = 'Page';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
        CompanyInformation.CalcFields(Picture);

        //-NPR5.39
        // Object.SETRANGE(ID, 6014430);
        // Object.SETRANGE(Type, 3);
        // //-NPR5.25
        // //Object.FIND('-');
        // Object.FINDFIRST;
        // //+NPR5.25
        //+NPR5.39

        if ValueDate = 0D then
          ValueDate := Today;
    end;

    var
        Item1: Record Item;
        CompanyInformation: Record "Company Information";
        ShowItemWithSales: Boolean;
        ShowItem: Boolean;
        TurnoverRate: Decimal;
        ShowItemGroup: Boolean;
        ValueDate: Date;
        PurchPrice: Decimal;
        Hjemtagelsesomk: Decimal;
        StockValue: Decimal;
        PeriodSales: Decimal;
        Item2: Record Item;
        Db: Decimal;
        Dg: Decimal;
        ItemCostMgt: Codeunit ItemCostManagement;
        GNSCostPrice: Decimal;
        ValueMethod: Option "sidste koebspris","kostpris (gns.)";
        StartDate: Date;
        EndDate: Date;
        Antalmdr: Integer;
        x: Integer;
        ItemInventory: Decimal;
        GnsBeholdningKpris: Decimal;
        Forpct: Decimal;
        SalesCost: Decimal;
        FilterDesc: Text[200];
        InventoryValueDesc: Text[200];
        ItemGroupDesc: Text[200];
        DateFilter: Text[100];
        ItemFooterDesc: Text[200];
        ItemGroupFooterDesc: Text[200];
        Text10600001: Label 'Chosen Vendors';
        Text10600002: Label 'For the period';
        Text10600003: Label 'M';
        Text10600005: Label 'Total for the item group';
        Text10600004: Label 'Item group';
        Text10600006: Label 'Total ';
        Text10600007: Label 'Department';
        Text10600008: Label 'Inventory is equal to inventories per %1 * %2 + delivery costs';

    procedure Beregn(DateFrom: Date;DateTo: Date) vaerdibeh: Decimal
    begin
        Item1.SetRange("Date Filter",DateFrom,DateTo);
        Item1.Get(Item."No.");
        Item1.CalcFields("Purchases (LCY)","COGS (LCY)");
        vaerdibeh := Item1."Purchases (LCY)" - (Item1."COGS (LCY)");
    end;
}

