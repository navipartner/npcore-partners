report 6014457 "Sales Stat/Analysis"
{
    // NPR70.00.00.00/LS/070714  CASE 143307 : Convert Report 6014457 to Nav 2013
    // NPR5.29/JLK /20160921  CASE 242555 Report corrected and semi complete
    // NPR5.30/JLK /20170301  CASE 267660 Added Vendor Filter and commented code to allow search per Item Group and removed some redundant ones
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on ControlContainer Caption in Request Page
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.50/ZESO/201905006 CASE 353382 Remove Reference to Wrapper Codeunit
    DefaultLayout = RDLC;
    RDLCLayout = './Sales StatAnalysis.rdlc';

    Caption = 'Sales Stat/Analysis';
    PreviewMode = Normal;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(ItemGroupHeader;"Item Group")
        {
            CalcFields = "Sales (Qty.)","Sales (LCY)","Consumption (Amount)";
            DataItemTableView = SORTING("Sorting-Key");
            RequestFilterFields = "No.","Date Filter","Global Dimension 1 Filter","Global Dimension 2 Filter","Vendor Filter";
            column(COMPANYNAME;CompanyName)
            {
            }
            column(Today;Format(Today,0,4))
            {
            }
            column(DateFilter_ItemGroupHeader;ItemGroupHeader.GetFilter("Date Filter"))
            {
            }
            column(Filters_ItemGroupHeader;ItemGroupHeader.GetFilters)
            {
            }
            column(No_ItemGroupHeader;ItemGroupHeader."No.")
            {
            }
            column(Description_ItemGroupHeader;ItemGroupHeader.Description)
            {
            }
            column(SalesQty_ItemGroupHeader;ItemGroupHeader."Sales (Qty.)")
            {
            }
            column(ConsumptionAmount_ItemGroupHeader;ItemGroupHeader."Consumption (Amount)")
            {
            }
            column(SaleLCY_ItemGroupHeader;ItemGroupHeader."Sales (LCY)")
            {
            }
            column(Profit_ItemGroupHeader;ItemGroupHeader."Sales (LCY)"-ItemGroupHeader."Consumption (Amount)")
            {
            }
            column(TotalProfit_ItemGroupHeader;TotalProfit)
            {
            }
            column(TotalRevenue_ItemGroupHeader;TotalRevenue)
            {
            }
            column(TotalConsumption_ItemGroupHeader;TotalConsumption)
            {
            }
            column(ShowItem;ShowItem)
            {
            }
            column(Profit_ItemGroupH;Profit)
            {
            }
            column(Coverage_ItemGroupH;Coverage)
            {
            }
            column(CoveragePct_ItemGroupH;CoveragePct)
            {
            }
            column(TurnoverPct_ItemGroupH;TurnoverPct)
            {
            }
            column(Picture_CompanyInformation;CompanyInfo.Picture)
            {
            }
            column(ItemGrpNoLvl0;StrSubstNo(TotalText,"No."))
            {
            }
            dataitem(Item;Item)
            {
                DataItemLink = "Item Group"=FIELD("No.");
                DataItemTableView = SORTING("Group sale","Item Group","Vendor No.");
                column(No_Item;"No.")
                {
                }
                column(Description_Item;Description)
                {
                }
                column(SalesQty_Item;"Sales (Qty.)")
                {
                }
                column(COGSLCY_Item;"COGS (LCY)")
                {
                }
                column(SalesLCY_Item;"Sales (LCY)")
                {
                }
                column(Inventory;Inventory)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if ("Sales (Qty.)" = 0) and OnlySales then
                      CurrReport.Skip;

                    CalcFields(Inventory);
                    SInventory += Inventory;
                end;

                trigger OnPreDataItem()
                begin
                    ItemGroupHeader.CopyFilter("Date Filter","Date Filter");
                    ItemGroupHeader.CopyFilter("Global Dimension 1 Filter","Global Dimension 1 Filter");
                    //-NPR5.30
                    ItemGroupHeader.CopyFilter("Global Dimension 2 Filter","Global Dimension 2 Filter");
                    ItemGroupHeader.CopyFilter("Vendor Filter","Vendor No.");
                    //+NPR5.30

                    if not ShowItem then
                      CurrReport.Break;
                end;
            }
            dataitem(ItemGroupSub1;"Item Group")
            {
                CalcFields = "Sales (Qty.)","Sales (LCY)","Consumption (Amount)";
                DataItemLink = "Parent Item Group No."=FIELD("No.");
                DataItemTableView = SORTING("Sorting-Key");
                column(No_ItemGroupSub1;"No.")
                {
                }
                column(Description_ItemGroupSub1;Description)
                {
                }
                column(SalesQty_ItemGroupSub1;"Sales (Qty.)")
                {
                }
                column(ConsumptionAmount_ItemGroupSub1;"Consumption (Amount)")
                {
                }
                column(SaleLCY_ItemGroupSub1;"Sales (LCY)")
                {
                }
                column(Profit_ItemGroupSub1;Profit)
                {
                }
                column(Coverage_ItemGroupSub1;Coverage)
                {
                }
                column(CoveragePct_ItemGroupSub1;CoveragePct)
                {
                }
                column(TurnoverPct_ItemGroupSub1;TurnoverPct)
                {
                }
                column(ItemGrpNoLvl1;StrSubstNo(TotalText,"No."))
                {
                }
                dataitem(Item1;Item)
                {
                    DataItemLink = "Item Group"=FIELD("No.");
                    DataItemTableView = SORTING("Group sale","Item Group","Vendor No.");
                    column(No_Item1;"No.")
                    {
                    }
                    column(Description_Item1;Description)
                    {
                    }
                    column(SalesQty_Item1;"Sales (Qty.)")
                    {
                    }
                    column(COGSLCY_Item1;"COGS (LCY)")
                    {
                    }
                    column(SalesLCY_Item1;"Sales (LCY)")
                    {
                    }
                    column(Inventory1;Inventory)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if ("Sales (Qty.)" = 0) and OnlySales then
                          CurrReport.Skip;

                        CalcFields(Inventory);
                        SInventory += Inventory;
                    end;

                    trigger OnPreDataItem()
                    begin
                        ItemGroupHeader.CopyFilter("Date Filter","Date Filter");
                        ItemGroupHeader.CopyFilter("Global Dimension 1 Filter","Global Dimension 1 Filter");
                        //-NPR5.30
                        ItemGroupHeader.CopyFilter("Global Dimension 2 Filter","Global Dimension 2 Filter");
                        ItemGroupHeader.CopyFilter("Vendor Filter","Vendor No.");
                        //+NPR5.30

                        if not ShowItem then
                          CurrReport.Break;
                    end;
                }
                dataitem(ItemGroupSub2;"Item Group")
                {
                    CalcFields = "Sales (Qty.)","Sales (LCY)","Consumption (Amount)";
                    DataItemLink = "Parent Item Group No."=FIELD("No.");
                    DataItemTableView = SORTING("Sorting-Key");
                    column(No_ItemGroupSub2;"No.")
                    {
                    }
                    column(Description_ItemGroupSub2;Description)
                    {
                    }
                    column(SalesQty_ItemGroupSub2;"Sales (Qty.)")
                    {
                    }
                    column(ConsumptionAmount_ItemGroupSub2;"Consumption (Amount)")
                    {
                    }
                    column(SaleLCY_ItemGroupSub2;"Sales (LCY)")
                    {
                    }
                    column(Profit_ItemGroupSub2;Profit)
                    {
                    }
                    column(Coverage_ItemGroupSub2;Coverage)
                    {
                    }
                    column(CoveragePct_ItemGroupSub2;CoveragePct)
                    {
                    }
                    column(TurnoverPct_ItemGroupSub2;TurnoverPct)
                    {
                    }
                    column(ItemGrpNoLvl2;StrSubstNo(TotalText,"No."))
                    {
                    }
                    dataitem(Item2;Item)
                    {
                        DataItemLink = "Item Group"=FIELD("No.");
                        DataItemTableView = SORTING("Group sale","Item Group","Vendor No.");
                        column(No_Item2;"No.")
                        {
                        }
                        column(Description_Item2;Description)
                        {
                        }
                        column(SalesQty_Item2;"Sales (Qty.)")
                        {
                        }
                        column(COGSLCY_Item2;"COGS (LCY)")
                        {
                        }
                        column(SalesLCY_Item2;"Sales (LCY)")
                        {
                        }
                        column(Inventory2;Inventory)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if ("Sales (Qty.)" = 0) and OnlySales then
                              CurrReport.Skip;

                            CalcFields(Inventory);
                            SInventory += Inventory;
                        end;

                        trigger OnPreDataItem()
                        begin
                            ItemGroupHeader.CopyFilter("Date Filter","Date Filter");
                            ItemGroupHeader.CopyFilter("Global Dimension 1 Filter","Global Dimension 1 Filter");
                            //-NPR5.30
                            ItemGroupHeader.CopyFilter("Global Dimension 2 Filter","Global Dimension 2 Filter");
                            ItemGroupHeader.CopyFilter("Vendor Filter","Vendor No.");
                            //+NPR5.30

                            if not ShowItem then
                              CurrReport.Break;
                        end;
                    }
                    dataitem(ItemGroupSub3;"Item Group")
                    {
                        CalcFields = "Sales (Qty.)","Sales (LCY)","Consumption (Amount)";
                        DataItemLink = "Parent Item Group No."=FIELD("No.");
                        DataItemTableView = SORTING("Sorting-Key");
                        column(No_ItemGroupSub3;"No.")
                        {
                        }
                        column(Description_ItemGroupSub3;Description)
                        {
                        }
                        column(SalesQty_ItemGroupSub3;"Sales (Qty.)")
                        {
                        }
                        column(ConsumptionAmount_ItemGroupSub3;"Consumption (Amount)")
                        {
                        }
                        column(SaleLCY_ItemGroupSub3;"Sales (LCY)")
                        {
                        }
                        column(Profit_ItemGroupSub3;Profit)
                        {
                        }
                        column(Coverage_ItemGroupSub3;Coverage)
                        {
                        }
                        column(CoveragePct_ItemGroupSub3;CoveragePct)
                        {
                        }
                        column(TurnoverPct_ItemGroupSub3;TurnoverPct)
                        {
                        }
                        column(ItemGrpNoLvl3;StrSubstNo(TotalText,"No."))
                        {
                        }
                        dataitem(Item3;Item)
                        {
                            DataItemLink = "Item Group"=FIELD("No.");
                            DataItemTableView = SORTING("Group sale","Item Group","Vendor No.");
                            column(No_Item3;"No.")
                            {
                            }
                            column(Description_Item3;Description)
                            {
                            }
                            column(SalesQty_Item3;"Sales (Qty.)")
                            {
                            }
                            column(COGSLCY_Item3;"COGS (LCY)")
                            {
                            }
                            column(SalesLCY_Item3;"Sales (LCY)")
                            {
                            }
                            column(Inventory3;Inventory)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if ("Sales (Qty.)" = 0) and OnlySales then
                                  CurrReport.Skip;

                                CalcFields(Inventory);
                                SInventory += Inventory;
                            end;

                            trigger OnPreDataItem()
                            begin
                                ItemGroupHeader.CopyFilter("Date Filter","Date Filter");
                                ItemGroupHeader.CopyFilter("Global Dimension 1 Filter","Global Dimension 1 Filter");
                                //-NPR5.30
                                ItemGroupHeader.CopyFilter("Global Dimension 2 Filter","Global Dimension 2 Filter");
                                ItemGroupHeader.CopyFilter("Vendor Filter","Vendor No.");
                                //+NPR5.30

                                if not ShowItem then
                                  CurrReport.Break;
                            end;
                        }
                        dataitem(ItemGroupSub4;"Item Group")
                        {
                            CalcFields = "Sales (Qty.)","Sales (LCY)","Consumption (Amount)";
                            DataItemLink = "Parent Item Group No."=FIELD("No.");
                            DataItemTableView = SORTING("Sorting-Key");
                            column(No_ItemGroupSub4;"No.")
                            {
                            }
                            column(Description_ItemGroupSub4;Description)
                            {
                            }
                            column(SalesQty_ItemGroupSub4;"Sales (Qty.)")
                            {
                            }
                            column(ConsumptionAmount_ItemGroupSub4;"Consumption (Amount)")
                            {
                            }
                            column(SaleLCY_ItemGroupSub4;"Sales (LCY)")
                            {
                            }
                            column(Profit_ItemGroupSub4;Profit)
                            {
                            }
                            column(Coverage_ItemGroupSub4;Coverage)
                            {
                            }
                            column(CoveragePct_ItemGroupSub4;CoveragePct)
                            {
                            }
                            column(TurnoverPct_ItemGroupSub4;TurnoverPct)
                            {
                            }
                            column(ItemGrpNoLvl4;StrSubstNo(TotalText,"No."))
                            {
                            }
                            dataitem(Item4;Item)
                            {
                                DataItemLink = "Item Group"=FIELD("No.");
                                DataItemTableView = SORTING("Group sale","Item Group","Vendor No.");
                                column(No_Item4;"No.")
                                {
                                }
                                column(Description_Item4;Description)
                                {
                                }
                                column(SalesQty_Item4;"Sales (Qty.)")
                                {
                                }
                                column(COGSLCY_Item4;"COGS (LCY)")
                                {
                                }
                                column(SalesLCY_Item4;"Sales (LCY)")
                                {
                                }
                                column(Inventory4;Inventory)
                                {
                                }

                                trigger OnAfterGetRecord()
                                begin
                                    if ("Sales (Qty.)" = 0) and OnlySales then
                                      CurrReport.Skip;

                                    CalcFields(Inventory);
                                    SInventory += Inventory;
                                end;

                                trigger OnPreDataItem()
                                begin
                                    ItemGroupHeader.CopyFilter("Date Filter","Date Filter");
                                    ItemGroupHeader.CopyFilter("Global Dimension 1 Filter","Global Dimension 1 Filter");
                                    //-NPR5.30
                                    ItemGroupHeader.CopyFilter("Global Dimension 2 Filter","Global Dimension 2 Filter");
                                    ItemGroupHeader.CopyFilter("Vendor Filter","Vendor No.");
                                    //+NPR5.30

                                    if not ShowItem then
                                      CurrReport.Break;
                                end;
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if ItemGroupPrinted.Get("No.") or (not (LevelsCount >= 4)) then
                                  CurrReport.Skip;

                                ItemGroupPrinted."No.":="No.";
                                ItemGroupPrinted.Insert;

                                CalcFields("Sales (Qty.)","Sales (LCY)","Consumption (Amount)");

                                Clear(Profit);
                                Clear(Coverage);
                                Clear(CoveragePct);
                                Clear(TurnoverPct);
                                Profit:="Sales (LCY)"-"Consumption (Amount)";
                                Coverage:=Pct(Profit,"Sales (LCY)");
                                CoveragePct:=Pct(Profit,TotalProfit);
                                TurnoverPct:=Pct("Sales (LCY)",TotalRevenue);

                                SQty += "Sales (Qty.)";
                                SumSale += "Sales (LCY)";
                                SumConsumption += "Consumption (Amount)";
                            end;

                            trigger OnPreDataItem()
                            begin
                                ItemGroupHeader.CopyFilter("Date Filter","Date Filter");
                                ItemGroupHeader.CopyFilter("Global Dimension 1 Filter","Global Dimension 1 Filter");
                                ItemGroupHeader.CopyFilter("Global Dimension 2 Filter","Global Dimension 2 Filter");
                                //-NPR5.30
                                ItemGroupHeader.CopyFilter("Vendor Filter","Vendor Filter");
                                //SETRANGE(Level,4);
                                //+NPR5.30
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if ItemGroupPrinted.Get("No.") or (not (LevelsCount >= 3)) then
                              CurrReport.Skip;

                            ItemGroupPrinted."No.":="No.";
                            ItemGroupPrinted.Insert;

                            CalcFields("Sales (Qty.)","Sales (LCY)","Consumption (Amount)");

                            Clear(Profit);
                            Clear(Coverage);
                            Clear(CoveragePct);
                            Clear(TurnoverPct);
                            Profit:="Sales (LCY)"-"Consumption (Amount)";
                            Coverage:=Pct(Profit,"Sales (LCY)");
                            CoveragePct:=Pct(Profit,TotalProfit);
                            TurnoverPct:=Pct("Sales (LCY)",TotalRevenue);

                            SQty += "Sales (Qty.)";
                            SumSale += "Sales (LCY)";
                            SumConsumption += "Consumption (Amount)";
                        end;

                        trigger OnPreDataItem()
                        begin
                            ItemGroupHeader.CopyFilter("Date Filter","Date Filter");
                            ItemGroupHeader.CopyFilter("Global Dimension 1 Filter","Global Dimension 1 Filter");
                            ItemGroupHeader.CopyFilter("Global Dimension 2 Filter","Global Dimension 2 Filter");
                            //-NPR5.30
                            ItemGroupHeader.CopyFilter("Vendor Filter","Vendor Filter");
                            //SETRANGE(Level,3);
                            //+NPR5.30
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if ItemGroupPrinted.Get("No.") or (not (LevelsCount >= 2)) then
                          CurrReport.Skip;

                        ItemGroupPrinted."No.":="No.";
                        ItemGroupPrinted.Insert;

                        CalcFields("Sales (Qty.)","Sales (LCY)","Consumption (Amount)");

                        Clear(Profit);
                        Clear(Coverage);
                        Clear(CoveragePct);
                        Clear(TurnoverPct);
                        Profit:="Sales (LCY)"-"Consumption (Amount)";
                        Coverage:=Pct(Profit,"Sales (LCY)");
                        CoveragePct:=Pct(Profit,TotalProfit);
                        TurnoverPct:=Pct("Sales (LCY)",TotalRevenue);

                        SQty += "Sales (Qty.)";
                        SumSale += "Sales (LCY)";
                        SumConsumption += "Consumption (Amount)";
                    end;

                    trigger OnPreDataItem()
                    begin
                        ItemGroupHeader.CopyFilter("Date Filter","Date Filter");
                        ItemGroupHeader.CopyFilter("Global Dimension 1 Filter","Global Dimension 1 Filter");
                        ItemGroupHeader.CopyFilter("Global Dimension 2 Filter","Global Dimension 2 Filter");
                        //-NPR5.30
                        ItemGroupHeader.CopyFilter("Vendor Filter","Vendor Filter");
                        //SETRANGE(Level,2);
                        //+NPR5.30
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if ItemGroupPrinted.Get("No.") or (not (LevelsCount >= 1)) then
                      CurrReport.Skip;

                    ItemGroupPrinted."No.":="No.";
                    ItemGroupPrinted.Insert;

                    CalcFields("Sales (Qty.)","Sales (LCY)","Consumption (Amount)");

                    Clear(Profit);
                    Clear(Coverage);
                    Clear(CoveragePct);
                    Clear(TurnoverPct);
                    Profit:="Sales (LCY)"-"Consumption (Amount)";
                    Coverage:=Pct(Profit,"Sales (LCY)");
                    CoveragePct:=Pct(Profit,TotalProfit);
                    TurnoverPct:=Pct("Sales (LCY)",TotalRevenue);

                    SQty += "Sales (Qty.)";
                    SumSale += "Sales (LCY)";
                    SumConsumption += "Consumption (Amount)";
                end;

                trigger OnPreDataItem()
                begin
                    ItemGroupHeader.CopyFilter("Date Filter","Date Filter");
                    ItemGroupHeader.CopyFilter("Global Dimension 1 Filter","Global Dimension 1 Filter");
                    ItemGroupHeader.CopyFilter("Global Dimension 2 Filter","Global Dimension 2 Filter");
                    //-NPR5.30
                    ItemGroupHeader.CopyFilter("Vendor Filter","Vendor Filter");
                    //SETRANGE(Level,1);
                    //+NPR5.30
                end;
            }
            dataitem("Sum";"Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
                column(SProfit;SProfit)
                {
                }
                column(SCoverage;SCoverage)
                {
                }
                column(SCoveragePct;SCoveragePct)
                {
                }
                column(STurnoverPct;STurnoverPct)
                {
                }
                column(SSale;SumSale)
                {
                }
                column(SConsumption;SumConsumption)
                {
                }
                column(SInventory;SInventory)
                {
                }
                column(SQty;SQty)
                {
                }

                trigger OnAfterGetRecord()
                begin

                    SProfit:=SumSale-SumConsumption;
                    SCoverage:=Pct(SProfit,SumSale);
                    SCoveragePct:=Pct(SProfit,TotalProfit);
                    STurnoverPct:=Pct(SumSale,TotalRevenue);

                    TSumSale += SumSale;
                    TSumConsumption += SumConsumption;
                    TSQty += SQty;
                end;
            }

            trigger OnAfterGetRecord()
            begin

                Clear(SProfit);
                Clear(SumSale);
                Clear(SumConsumption);
                Clear(SCoverage);
                Clear(SCoveragePct);
                Clear(STurnoverPct);
                Clear(SQty);

                if ItemGroupPrinted.Get("No.") then
                  CurrReport.Skip;

                ItemGroupPrinted."No.":="No.";
                ItemGroupPrinted.Insert;

                CalcFields("Sales (Qty.)","Sales (LCY)","Consumption (Amount)");

                Clear(Profit);
                Clear(Coverage);
                Clear(CoveragePct);
                Clear(TurnoverPct);
                Profit:="Sales (LCY)"-"Consumption (Amount)";
                Coverage:=Pct(Profit,"Sales (LCY)");
                CoveragePct:=Pct(Profit,TotalProfit);
                TurnoverPct:=Pct("Sales (LCY)",TotalRevenue);

                SQty += "Sales (Qty.)";
                SumSale += "Sales (LCY)";
                SumConsumption += "Consumption (Amount)";
            end;

            trigger OnPreDataItem()
            begin
                ItemGroupPrinted.SetCurrentKey("No.");
                ItemGroupPrinted.DeleteAll;
                //-NPR5.30
                // SETRANGE(Level,0);
                //+NPR5.30
            end;
        }
        dataitem(Total;"Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
            column(TSProfit;TSProfit)
            {
            }
            column(TSCoverage;TSCoverage)
            {
            }
            column(TSCoveragePct;TSCoveragePct)
            {
            }
            column(TSTurnoverPct;TSTurnoverPct)
            {
            }
            column(TSSale;TSumSale)
            {
            }
            column(TSConsumption;TSumConsumption)
            {
            }
            column(TSInventory;TSInventory)
            {
            }
            column(TSQty;TSQty)
            {
            }

            trigger OnAfterGetRecord()
            begin

                TSProfit:=TSumSale-TSumConsumption;
                TSCoverage:=Pct(TSProfit,TSumSale);
                TSCoveragePct:=Pct(TSProfit,TotalProfit);
                TSTurnoverPct:=Pct(TSumSale,TotalRevenue);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Request)
                {
                    Caption = 'Request';
                    field(ShowItem;ShowItem)
                    {
                        Caption = 'Print Items';
                    }
                    field(OnlySales;OnlySales)
                    {
                        Caption = 'Only Sales';
                    }
                    field(LevelsCount;LevelsCount)
                    {
                        Caption = 'Levels';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            LevelsCount := 2;
        end;
    }

    labels
    {
        Report_Caption = 'Sales Statistics/Item Group Analysis';
        Page_Caption = 'Page';
        No_Caption = 'No.';
        Name_Caption = 'Name';
        SaleQty_Caption = 'Quantity (sale)';
        CostExclVat_Caption = 'Cost excl. VAT';
        TurnoverExclVat_Caption = 'Turnover excl. VAT';
        Percentage_Caption = 'Percentage';
        ProfitExclVat_Caption = 'Profit excl. VAT';
        ProfitPct_Caption = 'Profit %';
        InventoryLbl = 'Inv.';
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get;
        CompanyInfo.CalcFields(Picture);

        //-NPR5.30
        // TxtLabeldim1 := 'Group by ' + TxtDim1;
        // IF GLOBALLANGUAGE = 1030 THEN  //Danish
        //  TxtLabeldim1 := 'Grupper ved ' + TxtDim1;
        CaptionClassDim1 := '1,1,1';



        //-#[353382] [353382]
        //-TM1.39 [334644]
        //TxtDim1 := SystemEventWrapper.CaptionClassTranslate(GLOBALLANGUAGE, CaptionClassDim1);
        //+TM1.39 [334644]
        TxtDim1 := CaptionClassTranslate(CaptionClassDim1);
        //+#[353382] [353382]


        TxtLabeldim1 := GroupByText + TxtDim1;
        //+NPR5.30
    end;

    trigger OnPreReport()
    begin
        //-NPR5.39
        // Object.SETRANGE(ID, 6014457);
        // Object.SETRANGE(Type, 3);
        // Object.FINDFIRST;
        //+NPR5.39

        Clear(TotalProfit);
        Clear(TotalCoverage);

        ItemGroup1.Reset;
        ItemGroupHeader.CopyFilter("Date Filter",ItemGroup1."Date Filter");
        if ItemGroup1.FindSet then
          repeat
            ItemGroup1.CalcFields("Sales (LCY)","Consumption (Amount)");
            TotalRevenue += ItemGroup1."Sales (LCY)";
            TotalConsumption += ItemGroup1."Consumption (Amount)";
          until ItemGroup1.Next = 0;

        TotalProfit := TotalRevenue-TotalConsumption;
        TotalCoverage := Pct(TotalProfit,TotalRevenue);
    end;

    var
        Coverage: Decimal;
        TurnoverPct: Decimal;
        Profit: Decimal;
        CoveragePct: Decimal;
        CompanyInfo: Record "Company Information";
        i: Integer;
        TotalRevenue: Decimal;
        TotalProfit: Decimal;
        Date: Text[30];
        DateFiltersApplied: Boolean;
        TotalConsumption: Decimal;
        TotalCoverage: Decimal;
        Sale: Decimal;
        Consumption: Decimal;
        ItemGroupPrinted: Record "Item Group" temporary;
        ItemGroup1: Record "Item Group";
        LevelsCount: Integer;
        OnlySales: Boolean;
        ShowItem: Boolean;
        FirstDimValue: Boolean;
        TxtDim1: Text[30];
        CaptionClassDim1: Text[30];
        TxtLabeldim1: Text[100];
        Text10600002: Label 'Salesstatistics/Itemgroupanalysis';
        Text001: Label 'Percentage of last years sales';
        SumSale: Decimal;
        SumConsumption: Decimal;
        SProfit: Decimal;
        SCoverage: Decimal;
        SCoveragePct: Decimal;
        STurnoverPct: Decimal;
        SInventory: Decimal;
        SQty: Decimal;
        TotalText: Label 'Total for Item Group %1';
        TSProfit: Decimal;
        TSCoverage: Decimal;
        TSCoveragePct: Decimal;
        TSTurnoverPct: Decimal;
        TSInventory: Decimal;
        TSQty: Decimal;
        TSumSale: Decimal;
        TSumConsumption: Decimal;
        GroupByText: Label 'Group by ';

    procedure Pct(var Value: Decimal;var Total: Decimal) Calculation: Decimal
    begin
        //-NPR5.30
        // IF v�rdi<>0 THEN
        // IF total<>0 THEN
        // resultat:=(v�rdi/total)*100
        // ELSE
        // resultat:=0;
        if (Value <> 0) and (Total <> 0) then
          Calculation := (Value/Total)*100
        else
          Calculation := 0;
        //+NPR5.30
    end;
}

