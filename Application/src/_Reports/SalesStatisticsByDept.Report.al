report 6014535 "NPR Sales Statistics By Dept."
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Statistics By Department.rdlc';
    Caption = 'Sales Statistics By Department';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem("Dimension Value"; "Dimension Value")
        {
            DataItemTableView = SORTING(Code, "Global Dimension No.") WHERE("Global Dimension No." = CONST(1));
            column(COMPANYNAME; CompanyName)
            {
            }
            column(FilterList; FilterList)
            {
            }
            column(Code_DimensionValue; "Dimension Value".Code)
            {
            }
            column(Name_DimensionValue; "Dimension Value".Name)
            {
            }
            column(VELocQty_DimensionValue; VELocQty)
            {
            }
            column(VELocCost; VELocCost)
            {
            }
            column(VELocSales; VELocSales)
            {
            }
            column(VETotalSalesPerc; VETotalSalesPerc)
            {
            }
            column(VELocPrevYearPerc; VELocPrevYearPerc)
            {
            }
            column(VETotalProfit; VETotalProfit)
            {
            }
            column(VETotalProfitSalesPerc; VETotalProfitSalesPerc)
            {
            }
            column(VETotalProfitPerc; VETotalProfitPerc)
            {
            }
            column(txtDim1; txtDim1)
            {
            }
            column(VELocLastYearTotalQty; VELocLastYearTotalQty)
            {
            }
            column(VELocLastYearTotalCost; VELocLastYearTotalCost)
            {
            }
            column(VELocLastYearTotalSales; VELocLastYearTotalSales)
            {
            }
            column(VELocLastYearTotalSalesPerc; VELocLastYearTotalSalesPerc)
            {
            }
            column(VELocLastYearTotalProfit; VELocLastYearTotalProfit)
            {
            }
            column(VELocLastYearTotalProfSalePerc; VELocLastYearTotalProfSalePerc)
            {
            }
            column(VELocLastYearTotalProfitPerc; VELocLastYearTotalProfitPerc)
            {
            }
            column(pctfjortekst; pctfjortekst)
            {
            }
            column(dim1Filter; dim1Filter)
            {
            }
            column(dateFilter; dateFilter)
            {
            }
            column(LastYear; lastYear)
            {
            }
            column(CurrentYearShow; CurrentYearShow)
            {
            }
            column(LastYearShow; LastYearShow)
            {
            }
            column(SalesPerson; SalesPerson)
            {
            }

            trigger OnAfterGetRecord()
            begin
                VELocLastYearTotalCost := 0;

                if not isGroupedByLocation then
                    if not firstDimValue then
                        CurrReport.Skip
                    else
                        firstDimValue := false;

                CurrentYearShow := true;
                LastYearShow := true;

                Clear(ValueEntryRec);
                ValueEntryRec.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type"::Sale);
                ValueEntryRec.SetRange("Global Dimension 1 Code", Code);

                if dateFilter <> '' then
                    ValueEntryRec.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                    ValueEntryRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                    ValueEntryRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                    ValueEntryRec.SetFilter("NPR Vendor No.", vendorFilter);
                if SalesPerson <> '' then
                    ValueEntryRec.SETFILTER("NPR Salesperson Code", SalesPerson);

                ValueEntryRec.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Purchase Amount (Actual)");

                Clear(ItemLedgerEntryRec);
                ItemLedgerEntryRec.SetRange("Entry Type", ItemLedgerEntryRec."Entry Type"::Sale);
                ItemLedgerEntryRec.SetRange("Global Dimension 1 Code", Code);

                if dateFilter <> '' then
                    ItemLedgerEntryRec.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                    ItemLedgerEntryRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                    ItemLedgerEntryRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                    ItemLedgerEntryRec.SetFilter("NPR Vendor No.", vendorFilter);
                if SalesPerson <> '' then
                    ItemLedgerEntryRec.SETFILTER("NPR Salesperson Code", SalesPerson);

                ItemLedgerEntryRec.CalcSums(Quantity);

                VELocQty := -ItemLedgerEntryRec.Quantity;
                VELocCost := -ValueEntryRec."Cost Amount (Actual)";
                VELocSales := ValueEntryRec."Sales Amount (Actual)";

                VETotalSalesPerc := pct(VELocSales, VETotalSales);
                VETotalProfit := VELocSales - VELocCost;
                VETotalProfitSalesPerc := pct(VETotalProfit, VELocSales);
                VETotalProfitPerc := pct(VETotalProfit, VETotalGlobalProfit);
                CurrentYearShow := true;
                if ((dim1Filter <> '') and (dim1Filter <> Code)) or (VELocQty = 0) then
                    CurrentYearShow := false;

                //Second body :
                Clear(ValueEntryLastYearRec);
                ValueEntryLastYearRec.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type"::Sale);
                ValueEntryLastYearRec.SetRange("Global Dimension 1 Code", Code);

                if dateFilter <> '' then
                    ValueEntryLastYearRec.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                    ValueEntryLastYearRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                    ValueEntryLastYearRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                    ValueEntryLastYearRec.SetFilter("NPR Vendor No.", vendorFilter);
                if SalesPerson <> '' then
                    ValueEntryLastYearRec.SETFILTER("NPR Salesperson Code", SalesPerson);

                if dateFilter <> '' then begin
                    ValueEntryLastYearRec.SetRange("Posting Date",
                    CalcDate('<-1Y>', ValueEntryLastYearRec.GetRangeMin("Posting Date")),
                    CalcDate('<-1Y>', ValueEntryLastYearRec.GetRangeMax("Posting Date")));
                end;

                ValueEntryLastYearRec.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Purchase Amount (Actual)");
                Clear(ItemLedgerEntryLastYearRec);
                ItemLedgerEntryLastYearRec.SetRange("Entry Type", ItemLedgerEntryRec."Entry Type"::Sale);
                ItemLedgerEntryLastYearRec.SetRange("Global Dimension 1 Code", Code);

                if dateFilter <> '' then
                    ItemLedgerEntryLastYearRec.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                    ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                    ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                    ItemLedgerEntryLastYearRec.SetFilter("NPR Vendor No.", vendorFilter);
                if SalesPerson <> '' then
                    ItemLedgerEntryLastYearRec.SETFILTER("NPR Salesperson Code", SalesPerson);

                if dateFilter <> '' then begin
                    ItemLedgerEntryLastYearRec.SetRange("Posting Date",
                    CalcDate('<-1Y>', ItemLedgerEntryLastYearRec.GetRangeMin("Posting Date")),
                    CalcDate('<-1Y>', ItemLedgerEntryLastYearRec.GetRangeMax("Posting Date")));
                end;

                ItemLedgerEntryLastYearRec.CalcSums(Quantity);

                VELocLastYearTotalQty := -ItemLedgerEntryLastYearRec.Quantity;
                VELocLastYearTotalCost := -ValueEntryLastYearRec."Cost Amount (Actual)";
                VELocLastYearTotalSales := ValueEntryLastYearRec."Sales Amount (Actual)";
                VELocLastYearTotalProfit := VELocLastYearTotalSales - VELocLastYearTotalCost;

                VELocLastYearTotalSalesPerc := pct(VELocLastYearTotalSales, VELastYearTotalSales);
                VELocLastYearTotalProfit := VELocLastYearTotalSales - VELocLastYearTotalCost;
                VELocLastYearTotalProfSalePerc := pct(VELocLastYearTotalProfit, VELastYearTotalSales);
                VELocLastYearTotalProfitPerc := pct(VELocLastYearTotalProfit, VELastYearTotalGlobalProfit);


                LastYearShow := (lastYear and (dateFilter <> ''));
                if ((dim1Filter <> '') and (dim1Filter <> Code)) or (VELocLastYearTotalQty = 0) then
                    LastYearShow := false;
            end;
        }
        dataitem(FooterTotal; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(Number_FooterTotal; FooterTotal.Number)
            {
            }
            column(VETotalQuantity_FooterTotal; VETotalQuantity)
            {
            }
            column(VETotalCost_FooterTotal; VETotalCost)
            {
            }
            column(VETotalSales_FooterTotal; VETotalSales)
            {
            }
            column(VETotalSalesPerc_FooterTotal; VETotalSalesPerc)
            {
            }
            column(VETotalPrevYeasPerc_FooterTotal; VETotalPrevYeasPerc)
            {
            }
            column(VETotalProfit_FooterTotal; VETotalProfit)
            {
            }
            column(VETotalProfitSalesPerc_FooterTotal; VETotalProfitSalesPerc)
            {
            }
            column(VETotalProfitPerc_FooterTotal; VETotalProfitPerc)
            {
            }

            trigger OnAfterGetRecord()
            begin
                ValueEntryRec.Reset();
                Clear(ValueEntryRec);
                ValueEntryRec.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type"::Sale);
                ValueEntryRec.SetFilter("Global Dimension 1 Code", '<>%1', '');
                if dateFilter <> '' then
                    ValueEntryRec.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                    ValueEntryRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                    ValueEntryRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                    ValueEntryRec.SetFilter("NPR Vendor No.", vendorFilter);
                if SalesPerson <> '' then
                    ValueEntryRec.SETFILTER(ValueEntryRec."NPR Salesperson Code", SalesPerson);

                ValueEntryRec.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Purchase Amount (Actual)");

                Clear(ItemLedgerEntryRec);
                ItemLedgerEntryRec.SetRange("Entry Type", ItemLedgerEntryRec."Entry Type"::Sale);
                ItemLedgerEntryRec.SetFilter("Global Dimension 1 Code", '<>%1', '');
                if dateFilter <> '' then
                    ItemLedgerEntryRec.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                    ItemLedgerEntryRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                    ItemLedgerEntryRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                    ItemLedgerEntryRec.SetFilter("NPR Vendor No.", vendorFilter);
                if SalesPerson <> '' then
                    ItemLedgerEntryRec.SETFILTER("NPR Salesperson Code", SalesPerson);

                ItemLedgerEntryRec.CalcSums(Quantity);

                VETotalQuantity := -ItemLedgerEntryRec.Quantity;
                VETotalCost := -ValueEntryRec."Cost Amount (Actual)";
                VETotalSales := ValueEntryRec."Sales Amount (Actual)";
                VETotalGlobalProfit := VETotalSales - VETotalCost;

                VETotalSalesPerc := pct(VETotalSales, VETotalSales);
                VETotalProfit := VETotalSales - VETotalCost;
                VETotalProfitSalesPerc := pct(VETotalProfit, VETotalSales);
                VETotalProfitPerc := pct(VETotalProfit, VETotalGlobalProfit);
            end;
        }
        dataitem(FooterTotalLY; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(Number_FooterTotalLY; FooterTotalLY.Number)
            {
            }
            column(LastYearShowFooter; LastYearShowFooter)
            {
            }
            column(VELastYearTotalQty_FooterTotalLY; VELastYearTotalQty)
            {
            }
            column(VELastYearTotalCost_FooterTotalLY; VELastYearTotalCost)
            {
            }
            column(VELastYearTotalSales_FooterTotalLY; VELastYearTotalSales)
            {
            }
            column(VELastYearTotalSalesPerc_FooterTotalLY; VELastYearTotalSalesPerc)
            {
            }
            column(VELastYearTotalProfit_FooterTotalLY; VELastYearTotalProfit)
            {
            }
            column(VELastYearTotalProfitSalesPerc_FooterTotalLY; VELastYearTotalProfitSalesPerc)
            {
            }
            column(VELastYearTotalProfitPerc_FooterTotalLY; VELastYearTotalProfitPerc)
            {
            }

            trigger OnAfterGetRecord()
            begin
                //-Past year
                if lastYear and (dateFilter <> '') then begin
                    ValueEntryLastYearRec.Reset();
                    Clear(ValueEntryLastYearRec);
                    ValueEntryLastYearRec.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type"::Sale);
                    ValueEntryLastYearRec.SetFilter("Global Dimension 1 Code", '<>%1', '');

                    if dateFilter <> '' then
                        ValueEntryLastYearRec.SetFilter("Posting Date", dateFilter);
                    if dim1Filter <> '' then
                        ValueEntryLastYearRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                    if dim2Filter <> '' then
                        ValueEntryLastYearRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                    if vendorFilter <> '' then
                        ValueEntryLastYearRec.SetFilter("NPR Vendor No.", vendorFilter);

                    if dateFilter <> '' then begin
                        ValueEntryLastYearRec.SetRange("Posting Date",
                        CalcDate('<-1Y>', ValueEntryLastYearRec.GetRangeMin("Posting Date")),
                        CalcDate('<-1Y>', ValueEntryLastYearRec.GetRangeMax("Posting Date")));
                    end;

                    ValueEntryLastYearRec.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Purchase Amount (Actual)");
                    Clear(ItemLedgerEntryLastYearRec);
                    ItemLedgerEntryLastYearRec.SetRange("Entry Type", ItemLedgerEntryRec."Entry Type"::Sale);
                    ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 1 Code", '<>%1', '');

                    if dateFilter <> '' then
                        ItemLedgerEntryLastYearRec.SetFilter("Posting Date", dateFilter);
                    if dim1Filter <> '' then
                        ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 1 Code", dim1Filter);
                    if dim2Filter <> '' then
                        ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 2 Code", dim2Filter);
                    if vendorFilter <> '' then
                        ItemLedgerEntryLastYearRec.SetFilter("NPR Vendor No.", vendorFilter);
                    if SalesPerson <> '' then
                        ItemLedgerEntryLastYearRec.SETFILTER("NPR Salesperson Code", SalesPerson);

                    if dateFilter <> '' then begin
                        ItemLedgerEntryLastYearRec.SetRange("Posting Date",
                        CalcDate('<-1Y>', ItemLedgerEntryLastYearRec.GetRangeMin("Posting Date")),
                        CalcDate('<-1Y>', ItemLedgerEntryLastYearRec.GetRangeMax("Posting Date")));
                    end;

                    ItemLedgerEntryLastYearRec.CalcSums(Quantity);

                    VELastYearTotalQty := -ItemLedgerEntryLastYearRec.Quantity;
                    VELastYearTotalCost := -ValueEntryLastYearRec."Cost Amount (Actual)";
                    VELastYearTotalSales := ValueEntryLastYearRec."Sales Amount (Actual)";
                    VELastYearTotalGlobalProfit := VELastYearTotalSales - VELastYearTotalCost;

                    VELastYearTotalSalesPerc := pct(VELastYearTotalSales, VELastYearTotalSales);
                    VELastYearTotalProfit := VELastYearTotalSales - VELastYearTotalCost;
                    VELastYearTotalProfitSalesPerc := pct(VELastYearTotalProfit, VELastYearTotalSales);
                    VELastYearTotalProfitPerc := pct(VELastYearTotalProfit, VELastYearTotalGlobalProfit);

                end;

                if lastYear and (dateFilter <> '') then begin
                    VELastYearTotalSalesPerc := pct(VELastYearTotalSales, VELastYearTotalSales);
                    VELastYearTotalProfit := VELastYearTotalSales - VELastYearTotalCost;
                    VELastYearTotalProfitSalesPerc := pct(VELastYearTotalProfit, VELastYearTotalSales);
                    VELastYearTotalProfitPerc := pct(VELastYearTotalProfit, VELastYearTotalGlobalProfit);
                end;

                LastYearShowFooter := lastYear and (dateFilter <> '');
            end;
        }
        dataitem("Item Group"; "NPR Item Group")
        {
            RequestFilterFields = "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter", "Vendor Filter";
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
                    field(antalniveauer; antalniveauer)
                    {
                        Caption = 'Show no. of levels';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show no. of levels field';
                    }
                    field(kunmedsalg; kunmedsalg)
                    {
                        Caption = 'Only with sales';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Only with sales field';
                    }
                    field(visvarer; visvarer)
                    {
                        Caption = 'Print items';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print items field';
                    }
                    field(lastYear; lastYear)
                    {
                        Caption = 'Print last years numbers';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print last years numbers field';
                    }
                    field(isGroupedByLocation; isGroupedByLocation)
                    {
                        CaptionClass = txtLabeldim1;
                        Caption = 'Group by';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Group by field';
                    }
                    field("Sales Person"; SalesPerson)
                    {
                        Caption = 'Sales Person';
                        TableRelation = "Salesperson/Purchaser".Code;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sales Person field';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            antalniveauer := 2;
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
        Footer_Caption = 'ˆNAVIPARTNER K¢benhavn 2002';
    }

    trigger OnInitReport()
    begin
        firmaopl.Get();
        firmaopl.CalcFields(Picture);

        isGroupedByLocation := true;

        captionClassDim1 := '1,1,1';
        txtDim1 := CaptionClassTranslate(captionClassDim1);

        txtLabeldim1 := 'Group by ' + txtDim1;
        if GlobalLanguage = 1030 then  //Danish
            txtLabeldim1 := 'Grupper ved ' + txtDim1;
    end;

    trigger OnPreReport()
    begin
        if SalesPerson = '' then
            FilterList := "Item Group".GetFilters
        else
            FilterList := "Item Group".GETFILTERS + ' SalesPerson: ' + SalesPerson;
        dateFilter := "Item Group".GetFilter("Date Filter");
        dim1Filter := "Item Group".GetFilter("Global Dimension 1 Filter");
        dim2Filter := "Item Group".GetFilter("Global Dimension 2 Filter");
        vendorFilter := "Item Group".GetFilter("Vendor Filter");

        Clear(ValueEntryRec);
        ValueEntryRec.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type"::Sale);
        ValueEntryRec.SetFilter("Global Dimension 1 Code", '<>%1', '');

        if dateFilter <> '' then
            ValueEntryRec.SetFilter("Posting Date", dateFilter);
        if dim1Filter <> '' then
            ValueEntryRec.SetFilter("Global Dimension 1 Code", dim1Filter);
        if dim2Filter <> '' then
            ValueEntryRec.SetFilter("Global Dimension 2 Code", dim2Filter);
        if vendorFilter <> '' then
            ValueEntryRec.SetFilter("NPR Vendor No.", vendorFilter);
        if SalesPerson <> '' then
            ValueEntryRec.SETFILTER("NPR Salesperson Code", SalesPerson);

        ValueEntryRec.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Purchase Amount (Actual)");

        Clear(ItemLedgerEntryRec);
        ItemLedgerEntryRec.SetRange("Entry Type", ItemLedgerEntryRec."Entry Type"::Sale);
        ItemLedgerEntryRec.SetFilter("Global Dimension 1 Code", '<>%1', '');

        if dateFilter <> '' then
            ItemLedgerEntryRec.SetFilter("Posting Date", dateFilter);
        if dim1Filter <> '' then
            ItemLedgerEntryRec.SetFilter("Global Dimension 1 Code", dim1Filter);
        if dim2Filter <> '' then
            ItemLedgerEntryRec.SetFilter("Global Dimension 2 Code", dim2Filter);
        if vendorFilter <> '' then
            ItemLedgerEntryRec.SetFilter("NPR Vendor No.", vendorFilter);
        if SalesPerson <> '' then
            ItemLedgerEntryRec.SETFILTER("NPR Salesperson Code", SalesPerson);

        ItemLedgerEntryRec.CalcSums(Quantity);

        VETotalQuantity := -ItemLedgerEntryRec.Quantity;
        VETotalCost := -ValueEntryRec."Cost Amount (Actual)";
        VETotalSales := ValueEntryRec."Sales Amount (Actual)";
        VETotalGlobalProfit := VETotalSales - VETotalCost;

        //-Past year
        if lastYear and (dateFilter <> '') then begin
            Clear(ValueEntryLastYearRec);
            ValueEntryLastYearRec.SetRange("Item Ledger Entry Type", ValueEntryRec."Item Ledger Entry Type"::Sale);
            ValueEntryLastYearRec.SetFilter("Global Dimension 1 Code", '<>%1', '');

            if dateFilter <> '' then
                ValueEntryLastYearRec.SetFilter("Posting Date", dateFilter);
            if dim1Filter <> '' then
                ValueEntryLastYearRec.SetFilter("Global Dimension 1 Code", dim1Filter);
            if dim2Filter <> '' then
                ValueEntryLastYearRec.SetFilter("Global Dimension 2 Code", dim2Filter);
            if vendorFilter <> '' then
                ValueEntryLastYearRec.SetFilter("NPR Vendor No.", vendorFilter);
            if SalesPerson <> '' then
                ValueEntryLastYearRec.SETFILTER("NPR Salesperson Code", SalesPerson);

            if dateFilter <> '' then begin
                ValueEntryLastYearRec.SetRange("Posting Date",
                CalcDate('<-1Y>', ValueEntryLastYearRec.GetRangeMin("Posting Date")),
                CalcDate('<-1Y>', ValueEntryLastYearRec.GetRangeMax("Posting Date")));
            end;
            ValueEntryLastYearRec.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Purchase Amount (Actual)");

            Clear(ItemLedgerEntryLastYearRec);
            ItemLedgerEntryLastYearRec.SetRange("Entry Type", ItemLedgerEntryRec."Entry Type"::Sale);
            ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 1 Code", '<>%1', '');
            if dateFilter <> '' then
                ItemLedgerEntryLastYearRec.SetFilter("Posting Date", dateFilter);
            if dim1Filter <> '' then
                ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 1 Code", dim1Filter);
            if dim2Filter <> '' then
                ItemLedgerEntryLastYearRec.SetFilter("Global Dimension 2 Code", dim2Filter);
            if vendorFilter <> '' then
                ItemLedgerEntryLastYearRec.SetFilter("NPR Vendor No.", vendorFilter);
            if SalesPerson <> '' then
                ItemLedgerEntryLastYearRec.SETFILTER("NPR Salesperson Code", SalesPerson);

            if dateFilter <> '' then begin
                ItemLedgerEntryLastYearRec.SetRange("Posting Date",
                CalcDate('<-1Y>', ItemLedgerEntryLastYearRec.GetRangeMin("Posting Date")),
                CalcDate('<-1Y>', ItemLedgerEntryLastYearRec.GetRangeMax("Posting Date")));
            end;

            ItemLedgerEntryLastYearRec.CalcSums(Quantity);

            VELastYearTotalQty := -ItemLedgerEntryLastYearRec.Quantity;
            VELastYearTotalCost := -ValueEntryLastYearRec."Cost Amount (Actual)";
            VELastYearTotalSales := ValueEntryLastYearRec."Sales Amount (Actual)";
            VELastYearTotalGlobalProfit := VELastYearTotalSales - VELastYearTotalCost;

            VELastYearTotalSalesPerc := pct(VELastYearTotalSales, VELastYearTotalSales);
            VELastYearTotalProfit := VELastYearTotalSales - VELastYearTotalCost;
            VELastYearTotalProfitSalesPerc := pct(VELastYearTotalProfit, VELastYearTotalSales);
            VELastYearTotalProfitPerc := pct(VELastYearTotalProfit, VELastYearTotalGlobalProfit);
        end;
        //+Last year

        firstDimValue := true;

        first := true;
    end;

    var
        firmaopl: Record "Company Information";
        ItemLedgerEntryLastYearRec: Record "Item Ledger Entry";
        ItemLedgerEntryRec: Record "Item Ledger Entry";
        ValueEntryLastYearRec: Record "Value Entry";
        ValueEntryRec: Record "Value Entry";
        CurrentYearShow: Boolean;
        first: Boolean;
        firstDimValue: Boolean;
        isGroupedByLocation: Boolean;
        kunmedsalg: Boolean;
        lastYear: Boolean;
        LastYearShow: Boolean;
        LastYearShowFooter: Boolean;
        visvarer: Boolean;
        antalfjor: array[5] of Decimal;
        db: Decimal;
        dbVare: array[5] of Decimal;
        dg: Decimal;
        dgpct: Decimal;
        dgVare: array[5] of Decimal;
        forbrugfjor: array[5] of Decimal;
        salgfjor: array[5] of Decimal;
        totaldb: Decimal;
        totalTurnover: Decimal;
        turnoverPct: Decimal;
        VELastYearTotalCost: Decimal;
        VELastYearTotalGlobalProfit: Decimal;
        VELastYearTotalProfit: Decimal;
        VELastYearTotalProfitPerc: Decimal;
        VELastYearTotalProfitSalesPerc: Decimal;
        VELastYearTotalQty: Decimal;
        VELastYearTotalSales: Decimal;
        VELastYearTotalSalesPerc: Decimal;
        VELocCost: Decimal;
        VELocLastYearTotalCost: Decimal;
        VELocLastYearTotalProfit: Decimal;
        VELocLastYearTotalProfitPerc: Decimal;
        VELocLastYearTotalProfSalePerc: Decimal;
        VELocLastYearTotalQty: Decimal;
        VELocLastYearTotalSales: Decimal;
        VELocLastYearTotalSalesPerc: Decimal;
        VELocPrevYearPerc: Decimal;
        VELocQty: Decimal;
        VELocSales: Decimal;
        VETotalCost: Decimal;
        VETotalGlobalProfit: Decimal;
        VETotalPrevYeasPerc: Decimal;
        VETotalProfit: Decimal;
        VETotalProfitPerc: Decimal;
        VETotalProfitSalesPerc: Decimal;
        VETotalQuantity: Decimal;
        VETotalSales: Decimal;
        VETotalSalesPerc: Decimal;
        antalniveauer: Integer;
        SalesPerson: Text;
        captionClassDim1: Text[30];
        dateFilter: Text[30];
        dim1Filter: Text[30];
        dim2Filter: Text[30];
        pctfjortekst: Text[30];
        txtDim1: Text[30];
        vendorFilter: Text[30];
        txtLabeldim1: Text[100];
        FilterList: Text[200];

    procedure pct(var Value: Decimal; var total: Decimal) resultat: Decimal
    begin
        if Value <> 0 then
            if total <> 0 then
                resultat := Round((Value / total) * 100, 0.1)
            else
                resultat := 0;
    end;

    procedure opdaterSidsteAar(salg_dkk: Decimal; salg_antal: Decimal; forbrug: Decimal; i: Integer)
    var
        j: Integer;
    begin
        j := i;
        if i = 1 then begin
            salgfjor[i] += salg_dkk;
            antalfjor[i] += salg_antal;
            forbrugfjor[i] += forbrug;
        end
        else
            while j > 0 do begin
                salgfjor[j] += salg_dkk;
                antalfjor[j] += salg_antal;
                forbrugfjor[j] += forbrug;
                j -= 1;
            end;
    end;

    procedure calcVareDg(Vare: Record Item; i: Integer)
    begin
        Clear(db);
        Clear(dg);
        Clear(dgpct);
        Clear(turnoverPct);
        db := Vare."Sales (LCY)" - Vare."COGS (LCY)";
        dg := pct(db, Vare."Sales (LCY)");
        dgpct := pct(db, totaldb);
        turnoverPct := pct(Vare."Sales (LCY)", totalTurnover);

        dbVare[i] += db;
        dgVare[i] += dg;
    end;
}

