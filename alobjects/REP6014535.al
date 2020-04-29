report 6014535 "Sales Statistics By Department"
{
    // NPR70.00.00.00/LS/140514 : Convert Report to Nav 2013
    //           -NPR3.2 Ved Nikolai Pedersen  Rettet s� sidste �r udregnes rigtigt
    //           -NPR3.2a ved Nikolai og Simon feb05 tilf�jet db dg til varer
    //           -NPR3.2b 2005.08.02 ved Simon Oversaettelser
    //           -NPR3.2cNPR 5 DB rettet s� filtre virker som de skal, �ndret fra hovedgruppe.copyfilter-->setfilter(hovedgruppe.getfilter(......))
    //                            samt sorteringen p� hovedgruppe er �ndret fra sorting(parent item group) til sorting(main item group)
    // 
    // NPR5.30/JDH /20170312 CASE        Removed field Balanced amount. It has been discontinued
    // NPR5.36/TJ  /20170927 CASE 286283 Renamed variables with danish specific letters into english letters
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on obsolite property CurrReport_PAGENO
    // NPR5.39/TJ  /20180206  CASE 302634 Changed Name property of column lastYear to english version
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // NPR5.50/ZESO/201905006 CASE 353382 Remove Reference to Wrapper Codeunit
    // NPR5.51/BHR /20190708 CASE 361268  Add filter on blank dimension
    // NPR5.54/YAHA/20200306 CASE 394848  Increase field Percentage in RDLC
    DefaultLayout = RDLC;
    RDLCLayout = './Sales Statistics By Department.rdlc';

    Caption = 'Sales Statistics By Department';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Dimension Value";"Dimension Value")
        {
            DataItemTableView = SORTING(Code,"Global Dimension No.") WHERE("Global Dimension No."=CONST(1));
            column(COMPANYNAME;CompanyName)
            {
            }
            column(FilterList;FilterList)
            {
            }
            column(Code_DimensionValue;"Dimension Value".Code)
            {
            }
            column(Name_DimensionValue;"Dimension Value".Name)
            {
            }
            column(VELocQty_DimensionValue;VELocQty)
            {
            }
            column(VELocCost;VELocCost)
            {
            }
            column(VELocSales;VELocSales)
            {
            }
            column(VETotalSalesPerc;VETotalSalesPerc)
            {
            }
            column(VELocPrevYearPerc;VELocPrevYearPerc)
            {
            }
            column(VETotalProfit;VETotalProfit)
            {
            }
            column(VETotalProfitSalesPerc;VETotalProfitSalesPerc)
            {
            }
            column(VETotalProfitPerc;VETotalProfitPerc)
            {
            }
            column(txtDim1;txtDim1)
            {
            }
            column(VELocLastYearTotalQty;VELocLastYearTotalQty)
            {
            }
            column(VELocLastYearTotalCost;VELocLastYearTotalCost)
            {
            }
            column(VELocLastYearTotalSales;VELocLastYearTotalSales)
            {
            }
            column(VELocLastYearTotalSalesPerc;VELocLastYearTotalSalesPerc)
            {
            }
            column(VELocLastYearTotalProfit;VELocLastYearTotalProfit)
            {
            }
            column(VELocLastYearTotalProfSalePerc;VELocLastYearTotalProfSalePerc)
            {
            }
            column(VELocLastYearTotalProfitPerc;VELocLastYearTotalProfitPerc)
            {
            }
            column(pctfjortekst;pctfjortekst)
            {
            }
            column(dim1Filter;dim1Filter)
            {
            }
            column(dateFilter;dateFilter)
            {
            }
            column(LastYear;lastYear)
            {
            }
            column(CurrentYearShow;CurrentYearShow)
            {
            }
            column(LastYearShow;LastYearShow)
            {
            }

            trigger OnAfterGetRecord()
            begin
                VELocLastYearTotalCost:=0;

                if not isGroupedByLocation then
                  if not firstDimValue then
                    CurrReport.Skip
                  else
                    firstDimValue := false;

                //-NPR7
                CurrentYearShow:=true;
                LastYearShow:=true;

                Clear(ValueEntryRec);
                ValueEntryRec.SetCurrentKey("Item Ledger Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code",
                "Salespers./Purch. Code","Item Group No.","Item No.","Vendor No.","Source No.","Group Sale");
                ValueEntryRec.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type"::Sale);
                ValueEntryRec.SetRange("Global Dimension 1 Code", Code);

                if dateFilter <> '' then
                  ValueEntryRec.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                  ValueEntryRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                  ValueEntryRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                  ValueEntryRec.SetFilter("Vendor No.", vendorFilter);

                //-NPR5.30
                //ValueEntryRec.CALCSUMS("Sales Amount (Actual)","Cost Amount (Actual)","Purchase Amount (Actual)","Balanced amount");
                ValueEntryRec.CalcSums("Sales Amount (Actual)","Cost Amount (Actual)","Purchase Amount (Actual)");
                //+NPR5.30

                Clear(ItemLedgerEntryRec);
                ItemLedgerEntryRec.SetCurrentKey("Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code",
                "Item Group No.","Vendor No.","Salesperson Code","Item No.","Source No.");
                ItemLedgerEntryRec.SetRange("Entry Type", ItemLedgerEntryRec."Entry Type"::Sale);
                ItemLedgerEntryRec.SetRange("Global Dimension 1 Code", Code);

                if dateFilter <> '' then
                  ItemLedgerEntryRec.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                  ItemLedgerEntryRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                  ItemLedgerEntryRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                  ItemLedgerEntryRec.SetFilter("Vendor No.", vendorFilter);

                ItemLedgerEntryRec.CalcSums(Quantity);

                VELocQty   := -ItemLedgerEntryRec.Quantity;
                VELocCost  := -ValueEntryRec."Cost Amount (Actual)";
                VELocSales := ValueEntryRec."Sales Amount (Actual)";

                VETotalSalesPerc := pct(VELocSales, VETotalSales);
                VETotalProfit    := VELocSales - VELocCost;
                VETotalProfitSalesPerc := pct(VETotalProfit, VELocSales);
                VETotalProfitPerc := pct(VETotalProfit, VETotalGlobalProfit);

                //IF sidste�r AND (dateFilter<>'') THEN
                //  VETotalPrevYeasPerc := pct(VELocSales, VELastYearTotalSales);

                //-NPR7
                CurrentYearShow:=true;
                if ((dim1Filter <> '') and (dim1Filter <> Code)) or (VELocQty = 0) then
                  CurrentYearShow:=false;
                //+NPR7

                //Second body :
                Clear(ValueEntryLastYearRec);
                ValueEntryLastYearRec.SetCurrentKey("Item Ledger Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code",
                "Salespers./Purch. Code","Item Group No.","Item No.","Vendor No.","Source No.","Group Sale");
                ValueEntryLastYearRec.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type"::Sale);
                ValueEntryLastYearRec.SetRange("Global Dimension 1 Code", Code);

                if dateFilter <> '' then
                  ValueEntryLastYearRec.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                  ValueEntryLastYearRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                  ValueEntryLastYearRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                  ValueEntryLastYearRec.SetFilter("Vendor No.", vendorFilter);

                if dateFilter <> '' then begin
                  ValueEntryLastYearRec.SetRange("Posting Date",
                  CalcDate('<-1Y>', ValueEntryLastYearRec.GetRangeMin("Posting Date")),
                  CalcDate('<-1Y>', ValueEntryLastYearRec.GetRangeMax("Posting Date")));
                end;

                //-NPR5.30
                //ValueEntryLastYearRec.CALCSUMS("Sales Amount (Actual)","Cost Amount (Actual)","Purchase Amount (Actual)","Balanced amount");
                ValueEntryLastYearRec.CalcSums("Sales Amount (Actual)","Cost Amount (Actual)","Purchase Amount (Actual)");
                //+NPR5.30

                Clear(ItemLedgerEntryLastYearRec);
                ItemLedgerEntryLastYearRec.SetCurrentKey("Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code",
                "Item Group No.","Vendor No.","Salesperson Code","Item No.","Source No.");
                ItemLedgerEntryLastYearRec.SetRange("Entry Type", ItemLedgerEntryRec."Entry Type"::Sale);
                ItemLedgerEntryLastYearRec.SetRange("Global Dimension 1 Code", Code);

                if dateFilter <> '' then
                  ItemLedgerEntryLastYearRec.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                  ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                  ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                  ItemLedgerEntryLastYearRec.SetFilter("Vendor No.", vendorFilter);

                if dateFilter <> '' then begin
                  ItemLedgerEntryLastYearRec.SetRange("Posting Date",
                  CalcDate('<-1Y>', ItemLedgerEntryLastYearRec.GetRangeMin("Posting Date")),
                  CalcDate('<-1Y>', ItemLedgerEntryLastYearRec.GetRangeMax("Posting Date")));
                end;

                ItemLedgerEntryLastYearRec.CalcSums(Quantity);

                VELocLastYearTotalQty          := -ItemLedgerEntryLastYearRec.Quantity;
                VELocLastYearTotalCost         := -ValueEntryLastYearRec."Cost Amount (Actual)";
                VELocLastYearTotalSales        := ValueEntryLastYearRec."Sales Amount (Actual)";
                VELocLastYearTotalProfit       := VELocLastYearTotalSales - VELocLastYearTotalCost;

                VELocLastYearTotalSalesPerc := pct(VELocLastYearTotalSales, VELastYearTotalSales);
                VELocLastYearTotalProfit    := VELocLastYearTotalSales - VELocLastYearTotalCost;
                VELocLastYearTotalProfSalePerc := pct(VELocLastYearTotalProfit, VELastYearTotalSales);
                VELocLastYearTotalProfitPerc := pct(VELocLastYearTotalProfit , VELastYearTotalGlobalProfit);


                LastYearShow:=(lastYear and (dateFilter<>''));
                if ( (dim1Filter <> '') and (dim1Filter <> Code) ) or (VELocLastYearTotalQty = 0) then
                 LastYearShow:=false;
                //+NPR7
            end;
        }
        dataitem(FooterTotal;"Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
            column(Number_FooterTotal;FooterTotal.Number)
            {
            }
            column(VETotalQuantity_FooterTotal;VETotalQuantity)
            {
            }
            column(VETotalCost_FooterTotal;VETotalCost)
            {
            }
            column(VETotalSales_FooterTotal;VETotalSales)
            {
            }
            column(VETotalSalesPerc_FooterTotal;VETotalSalesPerc)
            {
            }
            column(VETotalPrevYeasPerc_FooterTotal;VETotalPrevYeasPerc)
            {
            }
            column(VETotalProfit_FooterTotal;VETotalProfit)
            {
            }
            column(VETotalProfitSalesPerc_FooterTotal;VETotalProfitSalesPerc)
            {
            }
            column(VETotalProfitPerc_FooterTotal;VETotalProfitPerc)
            {
            }

            trigger OnAfterGetRecord()
            begin
                ValueEntryRec.Reset;
                Clear(ValueEntryRec);
                ValueEntryRec.SetCurrentKey("Item Ledger Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code",
                "Salespers./Purch. Code","Item Group No.","Item No.","Vendor No.","Source No.","Group Sale");
                ValueEntryRec.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type"::Sale);
                //-NPR5.51 [361268]
                ValueEntryRec.SetFilter("Global Dimension 1 Code",'<>%1','');
                //+NPR5.51 [361268]
                if dateFilter <> '' then
                  ValueEntryRec.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                  ValueEntryRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                  ValueEntryRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                  ValueEntryRec.SetFilter("Vendor No.", vendorFilter);

                //-NPR5.30
                //ValueEntryRec.CALCSUMS("Sales Amount (Actual)","Cost Amount (Actual)","Purchase Amount (Actual)","Balanced amount");
                ValueEntryRec.CalcSums("Sales Amount (Actual)","Cost Amount (Actual)","Purchase Amount (Actual)");
                //+NPR5.30


                Clear(ItemLedgerEntryRec);
                ItemLedgerEntryRec.SetCurrentKey("Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code",
                "Item Group No.","Vendor No.","Salesperson Code","Item No.","Source No.");
                ItemLedgerEntryRec.SetRange("Entry Type", ItemLedgerEntryRec."Entry Type"::Sale);
                //-NPR5.51 [361268]
                ItemLedgerEntryRec.SetFilter("Global Dimension 1 Code",'<>%1','');
                //+NPR5.51 [361268]
                if dateFilter <> '' then
                  ItemLedgerEntryRec.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                  ItemLedgerEntryRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                  ItemLedgerEntryRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                  ItemLedgerEntryRec.SetFilter("Vendor No.", vendorFilter);

                ItemLedgerEntryRec.CalcSums(Quantity);


                VETotalQuantity     := -ItemLedgerEntryRec.Quantity;
                VETotalCost         := -ValueEntryRec."Cost Amount (Actual)";
                VETotalSales        := ValueEntryRec."Sales Amount (Actual)";
                VETotalGlobalProfit := VETotalSales - VETotalCost;

                VETotalSalesPerc := pct(VETotalSales, VETotalSales);
                VETotalProfit    := VETotalSales - VETotalCost;
                VETotalProfitSalesPerc := pct(VETotalProfit, VETotalSales);
                VETotalProfitPerc := pct(VETotalProfit, VETotalGlobalProfit);
            end;
        }
        dataitem(FooterTotalLY;"Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
            column(Number_FooterTotalLY;FooterTotalLY.Number)
            {
            }
            column(LastYearShowFooter;LastYearShowFooter)
            {
            }
            column(VELastYearTotalQty_FooterTotalLY;VELastYearTotalQty)
            {
            }
            column(VELastYearTotalCost_FooterTotalLY;VELastYearTotalCost)
            {
            }
            column(VELastYearTotalSales_FooterTotalLY;VELastYearTotalSales)
            {
            }
            column(VELastYearTotalSalesPerc_FooterTotalLY;VELastYearTotalSalesPerc)
            {
            }
            column(VELastYearTotalProfit_FooterTotalLY;VELastYearTotalProfit)
            {
            }
            column(VELastYearTotalProfitSalesPerc_FooterTotalLY;VELastYearTotalProfitSalesPerc)
            {
            }
            column(VELastYearTotalProfitPerc_FooterTotalLY;VELastYearTotalProfitPerc)
            {
            }

            trigger OnAfterGetRecord()
            begin
                //-Past year
                if lastYear and (dateFilter<>'') then begin
                  ValueEntryLastYearRec.Reset;
                  Clear(ValueEntryLastYearRec);
                  ValueEntryLastYearRec.SetCurrentKey(
                  "Item Ledger Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code",
                  "Salespers./Purch. Code","Item Group No.","Item No.","Vendor No.","Source No.","Group Sale");
                  ValueEntryLastYearRec.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type"::Sale);
                  //-NPR5.51 [361268]
                  ValueEntryLastYearRec.SetFilter("Global Dimension 1 Code",'<>%1','');
                  //+NPR5.51 [361268]

                  if dateFilter <> '' then
                    ValueEntryLastYearRec.SetFilter("Posting Date", dateFilter);
                  if dim1Filter <> '' then
                    ValueEntryLastYearRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                  if dim2Filter <> '' then
                    ValueEntryLastYearRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                  if vendorFilter <> '' then
                    ValueEntryLastYearRec.SetFilter("Vendor No.", vendorFilter);

                  if dateFilter <> '' then begin
                    ValueEntryLastYearRec.SetRange("Posting Date",
                    CalcDate('<-1Y>', ValueEntryLastYearRec.GetRangeMin("Posting Date")),
                    CalcDate('<-1Y>', ValueEntryLastYearRec.GetRangeMax("Posting Date")));
                  end;

                  //-NPR5.30
                  //ValueEntryLastYearRec.CALCSUMS(  "Sales Amount (Actual)","Cost Amount (Actual)","Purchase Amount (Actual)","Balanced amount");
                  ValueEntryLastYearRec.CalcSums(  "Sales Amount (Actual)","Cost Amount (Actual)","Purchase Amount (Actual)");
                  //+NPR5.30

                  Clear(ItemLedgerEntryLastYearRec);
                  ItemLedgerEntryLastYearRec.SetCurrentKey("Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code",
                  "Item Group No.","Vendor No.","Salesperson Code","Item No.","Source No.");
                  ItemLedgerEntryLastYearRec.SetRange("Entry Type", ItemLedgerEntryRec."Entry Type"::Sale);
                  //-NPR5.51 [361268]
                  ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 1 Code",'<>%1','');
                  //+NPR5.51 [361268]

                  if dateFilter <> '' then
                    ItemLedgerEntryLastYearRec.SetFilter("Posting Date", dateFilter);
                  if dim1Filter <> '' then
                    ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                  if dim2Filter <> '' then
                    ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                  if vendorFilter <> '' then
                    ItemLedgerEntryLastYearRec.SetFilter("Vendor No.", vendorFilter);

                  if dateFilter <> '' then begin
                    ItemLedgerEntryLastYearRec.SetRange("Posting Date",
                    CalcDate('<-1Y>', ItemLedgerEntryLastYearRec.GetRangeMin("Posting Date")),
                    CalcDate('<-1Y>', ItemLedgerEntryLastYearRec.GetRangeMax("Posting Date")));
                  end;

                  ItemLedgerEntryLastYearRec.CalcSums(Quantity);

                  VELastYearTotalQty          := -ItemLedgerEntryLastYearRec.Quantity;
                  VELastYearTotalCost         := -ValueEntryLastYearRec."Cost Amount (Actual)";
                  VELastYearTotalSales        := ValueEntryLastYearRec."Sales Amount (Actual)";
                  VELastYearTotalGlobalProfit       := VELastYearTotalSales - VELastYearTotalCost;

                  VELastYearTotalSalesPerc := pct(VELastYearTotalSales, VELastYearTotalSales);
                  VELastYearTotalProfit    := VELastYearTotalSales - VELastYearTotalCost;
                  VELastYearTotalProfitSalesPerc := pct(VELastYearTotalProfit, VELastYearTotalSales);
                  VELastYearTotalProfitPerc := pct(VELastYearTotalProfit, VELastYearTotalGlobalProfit);

                end;

                if lastYear and (dateFilter<>'') then begin
                  VELastYearTotalSalesPerc := pct(VELastYearTotalSales, VELastYearTotalSales);
                  VELastYearTotalProfit    := VELastYearTotalSales - VELastYearTotalCost;
                  VELastYearTotalProfitSalesPerc := pct(VELastYearTotalProfit, VELastYearTotalSales);
                  VELastYearTotalProfitPerc := pct(VELastYearTotalProfit , VELastYearTotalGlobalProfit);
                end;

                LastYearShowFooter:=lastYear and (dateFilter<>'');
                //CurrReport.SHOWOUTPUT(sidste�r AND (dateFilter<>''));
            end;
        }
        dataitem("Item Group";"Item Group")
        {
            RequestFilterFields = "Date Filter","Global Dimension 1 Filter","Global Dimension 2 Filter","Vendor Filter";
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Control6150614)
                {
                    ShowCaption = false;
                    field(antalniveauer;antalniveauer)
                    {
                        Caption = 'Show no. of levels';
                    }
                    field(kunmedsalg;kunmedsalg)
                    {
                        Caption = 'Only with sales';
                    }
                    field(visvarer;visvarer)
                    {
                        Caption = 'Print items';
                    }
                    field(lastYear;lastYear)
                    {
                        Caption = 'Print last years numbers';
                    }
                    field(isGroupedByLocation;isGroupedByLocation)
                    {
                        CaptionClass = txtLabeldim1;
                        Caption = 'Group by';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            antalniveauer:=2;
        end;
    }

    labels
    {
        Report_Caption = 'Salesstatistics';
        QuantitySale_Caption = 'Quantity (sale)';
        CostExcVAT_Caption = 'Cost excl. VAT';
        TurnoverExcVAT_Caption = 'Turnover excl. VAT';
        Pct_Caption = 'Percentage';
        ProfitExcVAT_Caption = 'Profit excl. VAT';
        ProfitPct_Caption = 'Profit %';
        LastYear_Caption = 'Last year';
        Total_Caption = 'Total';
        Page_Caption = 'Page';
    }

    trigger OnInitReport()
    begin
        firmaopl.Get;
        firmaopl.CalcFields(Picture);

        isGroupedByLocation := true;

        captionClassDim1 := '1,1,1';

        //-#[353382] [353382]
        //-TM1.39 [334644]
        //txtDim1 := SystemEventWrapper.CaptionClassTranslate(GLOBALLANGUAGE, captionClassDim1);
        //+TM1.39 [334644]
        txtDim1 := CaptionClassTranslate(captionClassDim1);

        //+#[353382] [353382]

        txtLabeldim1 := 'Group by ' + txtDim1;
        if GlobalLanguage = 1030 then  //Danish
          txtLabeldim1 := 'Grupper ved ' + txtDim1;
    end;

    trigger OnPreReport()
    begin
        FilterList := "Item Group".GetFilters;
        dateFilter := "Item Group".GetFilter("Date Filter");
        dim1Filter := "Item Group".GetFilter("Global Dimension 1 Filter");
        dim2Filter := "Item Group".GetFilter("Global Dimension 2 Filter");
        vendorFilter := "Item Group".GetFilter("Vendor Filter");
        
        Clear(ValueEntryRec);
        ValueEntryRec.SetCurrentKey("Item Ledger Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code",
        "Salespers./Purch. Code","Item Group No.","Item No.","Vendor No.","Source No.","Group Sale");
        ValueEntryRec.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type"::Sale);
        //-NPR5.51 [361268]
        ValueEntryRec.SetFilter("Global Dimension 1 Code",'<>%1','');
        //+NPR5.51 [361268]
        
        if dateFilter <> '' then
          ValueEntryRec.SetFilter("Posting Date", dateFilter);
        if dim1Filter <> '' then
          ValueEntryRec.SetFilter("Global Dimension 1 Code", dim1Filter);
        if dim2Filter <> '' then
          ValueEntryRec.SetFilter("Global Dimension 2 Code", dim2Filter);
        if vendorFilter <> '' then
          ValueEntryRec.SetFilter("Vendor No.", vendorFilter);
        
        //-NPR5.30
        //ValueEntryRec.CALCSUMS("Sales Amount (Actual)","Cost Amount (Actual)","Purchase Amount (Actual)","Balanced amount");
        ValueEntryRec.CalcSums("Sales Amount (Actual)","Cost Amount (Actual)","Purchase Amount (Actual)");
        //+NPR5.30
        
        Clear(ItemLedgerEntryRec);
        ItemLedgerEntryRec.SetCurrentKey("Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code",
        "Item Group No.","Vendor No.","Salesperson Code","Item No.","Source No.");
        ItemLedgerEntryRec.SetRange("Entry Type", ItemLedgerEntryRec."Entry Type"::Sale);
        //-NPR5.51 [361268]
        ItemLedgerEntryRec.SetFilter("Global Dimension 1 Code",'<>%1','');
        //+NPR5.51 [361268]
        
        if dateFilter <> '' then
          ItemLedgerEntryRec.SetFilter("Posting Date", dateFilter);
        if dim1Filter <> '' then
          ItemLedgerEntryRec.SetFilter("Global Dimension 1 Code", dim1Filter);
        if dim2Filter <> '' then
          ItemLedgerEntryRec.SetFilter("Global Dimension 2 Code", dim2Filter);
        if vendorFilter <> '' then
          ItemLedgerEntryRec.SetFilter("Vendor No.", vendorFilter);
        
        ItemLedgerEntryRec.CalcSums(Quantity);
        
        VETotalQuantity     := -ItemLedgerEntryRec.Quantity;
        VETotalCost         := -ValueEntryRec."Cost Amount (Actual)";
        VETotalSales        := ValueEntryRec."Sales Amount (Actual)";
        VETotalGlobalProfit := VETotalSales - VETotalCost;
        
        
        
        
        //-Past year
        if lastYear and (dateFilter<>'') then begin
        //pctfjortekst:=text001;
        Clear(ValueEntryLastYearRec);
        ValueEntryLastYearRec.SetCurrentKey(
        "Item Ledger Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code",
        "Salespers./Purch. Code","Item Group No.","Item No.","Vendor No.","Source No.","Group Sale"
        );
        ValueEntryLastYearRec.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type"::Sale);
        //-NPR5.51 [361268]
        ValueEntryLastYearRec.SetFilter("Global Dimension 1 Code",'<>%1','');
        //+NPR5.51 [361268]
        
        if dateFilter <> '' then
          ValueEntryLastYearRec.SetFilter("Posting Date", dateFilter);
        if dim1Filter <> '' then
          ValueEntryLastYearRec.SetFilter("Global Dimension 1 Code", dim1Filter);
        if dim2Filter <> '' then
          ValueEntryLastYearRec.SetFilter("Global Dimension 2 Code", dim2Filter);
        if vendorFilter <> '' then
          ValueEntryLastYearRec.SetFilter("Vendor No.", vendorFilter);
        
        if dateFilter <> '' then begin
          ValueEntryLastYearRec.SetRange("Posting Date",
          CalcDate('<-1Y>', ValueEntryLastYearRec.GetRangeMin("Posting Date")),
          CalcDate('<-1Y>', ValueEntryLastYearRec.GetRangeMax("Posting Date")));
        end;
        
        //-NPR5.30
        //ValueEntryLastYearRec.CALCSUMS("Sales Amount (Actual)","Cost Amount (Actual)","Purchase Amount (Actual)","Balanced amount");
        ValueEntryLastYearRec.CalcSums("Sales Amount (Actual)","Cost Amount (Actual)","Purchase Amount (Actual)");
        //+NPR5.30
        
        Clear(ItemLedgerEntryLastYearRec);
        ItemLedgerEntryLastYearRec.SetCurrentKey("Entry Type","Posting Date","Global Dimension 1 Code","Global Dimension 2 Code",
        "Item Group No.","Vendor No.","Salesperson Code","Item No.","Source No.");
        ItemLedgerEntryLastYearRec.SetRange("Entry Type", ItemLedgerEntryRec."Entry Type"::Sale);
        //-NPR5.51 [361268]
        ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 1 Code",'<>%1','');
        //+NPR5.51 [361268]
        if dateFilter <> '' then
          ItemLedgerEntryLastYearRec.SetFilter("Posting Date", dateFilter);
        if dim1Filter <> '' then
          ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 1 Code", dim1Filter);
        if dim2Filter <> '' then
          ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 2 Code", dim2Filter);
        if vendorFilter <> '' then
          ItemLedgerEntryLastYearRec.SetFilter("Vendor No.", vendorFilter);
        
        if dateFilter <> '' then begin
          ItemLedgerEntryLastYearRec.SetRange("Posting Date",
          CalcDate('<-1Y>', ItemLedgerEntryLastYearRec.GetRangeMin("Posting Date")),
          CalcDate('<-1Y>', ItemLedgerEntryLastYearRec.GetRangeMax("Posting Date")));
        end;
        
        ItemLedgerEntryLastYearRec.CalcSums(Quantity);
        
        
        VELastYearTotalQty          := -ItemLedgerEntryLastYearRec.Quantity;
        VELastYearTotalCost         := -ValueEntryLastYearRec."Cost Amount (Actual)";
        VELastYearTotalSales        := ValueEntryLastYearRec."Sales Amount (Actual)";
        VELastYearTotalGlobalProfit       := VELastYearTotalSales - VELastYearTotalCost;
        
        VELastYearTotalSalesPerc := pct(VELastYearTotalSales, VELastYearTotalSales);
        VELastYearTotalProfit    := VELastYearTotalSales - VELastYearTotalCost;
        VELastYearTotalProfitSalesPerc := pct(VELastYearTotalProfit, VELastYearTotalSales);
        VELastYearTotalProfitPerc := pct(VELastYearTotalProfit, VELastYearTotalGlobalProfit);
        
        
        //VETotalPrevYeasPerc := pct(VETotalSales, VELastYearTotalSales);
        end;
        //+Last year
        
        firstDimValue := true;
        
        first := true;
        
        //-NPR5.39
        // objekt.SETRANGE(ID, 6014535);
        // objekt.SETRANGE(Type, 3);
        // objekt.FIND('-');
        //+NPR5.39
        
        /*
        CLEAR(totaloms�tning);
        CLEAR(totalforbrug);
        CLEAR(totaldb);
        CLEAR(totaldg);
        CLEAR(totalforbrugfjor);
        CLEAR(totaloms�tningfjor);
        CLEAR(totaldbfjor);
        CLEAR(totaldgfjor);
        CLEAR(salgfjor);
        CLEAR(antalfjor);
        CLEAR(forbrugfjor);
        */

    end;

    var
        dg: Decimal;
        turnoverPct: Decimal;
        db: Decimal;
        dgpct: Decimal;
        firmaopl: Record "Company Information";
        totalTurnover: Decimal;
        totaldb: Decimal;
        antalniveauer: Integer;
        kunmedsalg: Boolean;
        visvarer: Boolean;
        lastYear: Boolean;
        salgfjor: array [5] of Decimal;
        forbrugfjor: array [5] of Decimal;
        antalfjor: array [5] of Decimal;
        pctfjortekst: Text[30];
        dbVare: array [5] of Decimal;
        dgVare: array [5] of Decimal;
        first: Boolean;
        isGroupedByLocation: Boolean;
        firstDimValue: Boolean;
        txtDim1: Text[30];
        captionClassDim1: Text[30];
        txtLabeldim1: Text[100];
        ValueEntryRec: Record "Value Entry";
        ItemLedgerEntryRec: Record "Item Ledger Entry";
        VETotalQuantity: Decimal;
        VETotalCost: Decimal;
        VETotalSales: Decimal;
        VETotalGlobalProfit: Decimal;
        VETotalSalesPerc: Decimal;
        VETotalPrevYeasPerc: Decimal;
        VETotalProfit: Decimal;
        VETotalProfitSalesPerc: Decimal;
        VETotalProfitPerc: Decimal;
        VELocQty: Decimal;
        VELocCost: Decimal;
        VELocSales: Decimal;
        VELocPrevYearPerc: Decimal;
        ValueEntryLastYearRec: Record "Value Entry";
        ItemLedgerEntryLastYearRec: Record "Item Ledger Entry";
        VELocLastYearTotalQty: Decimal;
        VELocLastYearTotalCost: Decimal;
        VELocLastYearTotalSales: Decimal;
        VELocLastYearTotalSalesPerc: Decimal;
        VELocLastYearTotalProfit: Decimal;
        VELocLastYearTotalProfSalePerc: Decimal;
        VELocLastYearTotalProfitPerc: Decimal;
        VELastYearTotalQty: Decimal;
        VELastYearTotalCost: Decimal;
        VELastYearTotalSales: Decimal;
        VELastYearTotalGlobalProfit: Decimal;
        VELastYearTotalSalesPerc: Decimal;
        VELastYearTotalProfit: Decimal;
        VELastYearTotalProfitSalesPerc: Decimal;
        VELastYearTotalProfitPerc: Decimal;
        FilterList: Text[200];
        dateFilter: Text[30];
        dim1Filter: Text[30];
        dim2Filter: Text[30];
        vendorFilter: Text[30];
        CurrentYearShow: Boolean;
        LastYearShow: Boolean;
        LastYearShowFooter: Boolean;

    procedure pct(var Value: Decimal;var total: Decimal) resultat: Decimal
    begin
        if Value<>0 then
        if total<>0 then
        resultat:=Round((Value/total)*100,0.1)
        else
        resultat:=0;
    end;

    procedure opdaterSidsteAar(salg_dkk: Decimal;salg_antal: Decimal;forbrug: Decimal;i: Integer)
    var
        j: Integer;
    begin
        j := i;
        if i = 1 then
        begin
          salgfjor[i]+=salg_dkk;
          antalfjor[i]+=salg_antal;
          forbrugfjor[i]+=forbrug;
        end
        else
        while j > 0 do
        begin
          salgfjor[j]+=salg_dkk;
          antalfjor[j]+=salg_antal;
          forbrugfjor[j]+=forbrug;
          j-=1;
        end;
    end;

    procedure calcVareDg(Vare: Record Item;i: Integer)
    begin
        //-NPR3.2a
        Clear(db);
        Clear(dg);
        Clear(dgpct);
        Clear(turnoverPct);
        db:=Vare."Sales (LCY)" - Vare."COGS (LCY)";
        dg:=pct(db,Vare."Sales (LCY)");
        dgpct:=pct(db,totaldb);
        turnoverPct:=pct(Vare."Sales (LCY)",totalTurnover);

        dbVare[i] += db;
        dgVare[i] += dg;
        //+NPR3.2a
    end;
}

