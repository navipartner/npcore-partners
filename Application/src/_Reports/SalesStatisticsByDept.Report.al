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
                        CurrReport.Skip()
                    else
                        firstDimValue := false;

                CurrentYearShow := true;
                LastYearShow := true;

                Clear(AuxValueEntry);
                AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
                AuxValueEntry.SetRange("Global Dimension 1 Code", Code);

                if dateFilter <> '' then
                    AuxValueEntry.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                    AuxValueEntry.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                    AuxValueEntry.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                    AuxValueEntry.SetFilter("Vendor No.", vendorFilter);
                if SalesPerson <> '' then
                    AuxValueEntry.SETFILTER("Salespers./Purch. Code", SalesPerson);

                AuxValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Purchase Amount (Actual)");

                Clear(AuxItemLedgerEntry);
                AuxItemLedgerEntry.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
                AuxItemLedgerEntry.SetRange("Global Dimension 1 Code", Code);

                if dateFilter <> '' then
                    AuxItemLedgerEntry.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                    AuxItemLedgerEntry.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                    AuxItemLedgerEntry.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                    AuxItemLedgerEntry.SetFilter("Vendor No.", vendorFilter);
                if SalesPerson <> '' then
                    AuxItemLedgerEntry.SETFILTER("Salespers./Purch. Code", SalesPerson);

                AuxItemLedgerEntry.CalcSums(Quantity);

                VELocQty := -AuxItemLedgerEntry.Quantity;
                VELocCost := -AuxValueEntry."Cost Amount (Actual)";
                VELocSales := AuxValueEntry."Sales Amount (Actual)";

                VETotalSalesPerc := pct(VELocSales, VETotalSales);
                VETotalProfit := VELocSales - VELocCost;
                VETotalProfitSalesPerc := pct(VETotalProfit, VELocSales);
                VETotalProfitPerc := pct(VETotalProfit, VETotalGlobalProfit);
                CurrentYearShow := true;
                if ((dim1Filter <> '') and (dim1Filter <> Code)) or (VELocQty = 0) then
                    CurrentYearShow := false;

                //Second body :
                Clear(AuxValueEntryLastYear);
                AuxValueEntryLastYear.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
                AuxValueEntryLastYear.SetRange("Global Dimension 1 Code", Code);

                if dateFilter <> '' then
                    AuxValueEntryLastYear.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                    AuxValueEntryLastYear.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                    AuxValueEntryLastYear.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                    AuxValueEntryLastYear.SetFilter("Vendor No.", vendorFilter);
                if SalesPerson <> '' then
                    AuxValueEntryLastYear.SETFILTER("Salespers./Purch. Code", SalesPerson);

                if dateFilter <> '' then begin
                    AuxValueEntryLastYear.SetRange("Posting Date",
                    CalcDate('<-1Y>', AuxValueEntryLastYear.GetRangeMin("Posting Date")),
                    CalcDate('<-1Y>', AuxValueEntryLastYear.GetRangeMax("Posting Date")));
                end;

                AuxValueEntryLastYear.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Purchase Amount (Actual)");
                Clear(AuxItemLedgerEntryLastYear);
                AuxItemLedgerEntryLastYear.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
                AuxItemLedgerEntryLastYear.SetRange("Global Dimension 1 Code", Code);

                if dateFilter <> '' then
                    AuxItemLedgerEntryLastYear.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                    AuxItemLedgerEntryLastYear.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                    AuxItemLedgerEntryLastYear.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                    AuxItemLedgerEntryLastYear.SetFilter("Vendor No.", vendorFilter);
                if SalesPerson <> '' then
                    AuxItemLedgerEntryLastYear.SETFILTER("Salespers./Purch. Code", SalesPerson);

                if dateFilter <> '' then begin
                    AuxItemLedgerEntryLastYear.SetRange("Posting Date",
                    CalcDate('<-1Y>', AuxItemLedgerEntryLastYear.GetRangeMin("Posting Date")),
                    CalcDate('<-1Y>', AuxItemLedgerEntryLastYear.GetRangeMax("Posting Date")));
                end;

                AuxItemLedgerEntryLastYear.CalcSums(Quantity);

                VELocLastYearTotalQty := -AuxItemLedgerEntryLastYear.Quantity;
                VELocLastYearTotalCost := -AuxValueEntryLastYear."Cost Amount (Actual)";
                VELocLastYearTotalSales := AuxValueEntryLastYear."Sales Amount (Actual)";
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
                AuxValueEntry.Reset();
                Clear(AuxValueEntry);
                AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
                AuxValueEntry.SetFilter("Global Dimension 1 Code", '<>%1', '');
                if dateFilter <> '' then
                    AuxValueEntry.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                    AuxValueEntry.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                    AuxValueEntry.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                    AuxValueEntry.SetFilter("Vendor No.", vendorFilter);
                if SalesPerson <> '' then
                    AuxValueEntry.SETFILTER("Salespers./Purch. Code", SalesPerson);

                AuxValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Purchase Amount (Actual)");

                Clear(AuxItemLedgerEntry);
                AuxItemLedgerEntry.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
                AuxItemLedgerEntry.SetFilter("Global Dimension 1 Code", '<>%1', '');
                if dateFilter <> '' then
                    AuxItemLedgerEntry.SetFilter("Posting Date", dateFilter);
                if dim1Filter <> '' then
                    AuxItemLedgerEntry.SetFilter("Global Dimension 1 Code", dim1Filter);
                if dim2Filter <> '' then
                    AuxItemLedgerEntry.SetFilter("Global Dimension 2 Code", dim2Filter);
                if vendorFilter <> '' then
                    AuxItemLedgerEntry.SetFilter("Vendor No.", vendorFilter);
                if SalesPerson <> '' then
                    AuxItemLedgerEntry.SETFILTER("Salespers./Purch. Code", SalesPerson);

                AuxItemLedgerEntry.CalcSums(Quantity);

                VETotalQuantity := -AuxItemLedgerEntry.Quantity;
                VETotalCost := -AuxValueEntry."Cost Amount (Actual)";
                VETotalSales := AuxValueEntry."Sales Amount (Actual)";
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
                    AuxValueEntryLastYear.Reset();
                    Clear(AuxValueEntryLastYear);
                    AuxValueEntryLastYear.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
                    AuxValueEntryLastYear.SetFilter("Global Dimension 1 Code", '<>%1', '');

                    if dateFilter <> '' then
                        AuxValueEntryLastYear.SetFilter("Posting Date", dateFilter);
                    if dim1Filter <> '' then
                        AuxValueEntryLastYear.SetFilter("Global Dimension 1 Code", dim1Filter);
                    if dim2Filter <> '' then
                        AuxValueEntryLastYear.SetFilter("Global Dimension 2 Code", dim2Filter);
                    if vendorFilter <> '' then
                        AuxValueEntryLastYear.SetFilter("Vendor No.", vendorFilter);

                    if dateFilter <> '' then begin
                        AuxValueEntryLastYear.SetRange("Posting Date",
                        CalcDate('<-1Y>', AuxValueEntryLastYear.GetRangeMin("Posting Date")),
                        CalcDate('<-1Y>', AuxValueEntryLastYear.GetRangeMax("Posting Date")));
                    end;

                    AuxValueEntryLastYear.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Purchase Amount (Actual)");
                    Clear(AuxItemLedgerEntryLastYear);
                    AuxItemLedgerEntryLastYear.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
                    AuxItemLedgerEntryLastYear.SetFilter("Global Dimension 1 Code", '<>%1', '');

                    if dateFilter <> '' then
                        AuxItemLedgerEntryLastYear.SetFilter("Posting Date", dateFilter);
                    if dim1Filter <> '' then
                        AuxItemLedgerEntryLastYear.SetFilter("Global Dimension 1 Code", dim1Filter);
                    if dim2Filter <> '' then
                        AuxItemLedgerEntryLastYear.SetFilter("Global Dimension 2 Code", dim2Filter);
                    if vendorFilter <> '' then
                        AuxItemLedgerEntryLastYear.SetFilter("Vendor No.", vendorFilter);
                    if SalesPerson <> '' then
                        AuxItemLedgerEntryLastYear.SETFILTER("Salespers./Purch. Code", SalesPerson);

                    if dateFilter <> '' then begin
                        AuxItemLedgerEntryLastYear.SetRange("Posting Date",
                        CalcDate('<-1Y>', AuxItemLedgerEntryLastYear.GetRangeMin("Posting Date")),
                        CalcDate('<-1Y>', AuxItemLedgerEntryLastYear.GetRangeMax("Posting Date")));
                    end;

                    AuxItemLedgerEntryLastYear.CalcSums(Quantity);

                    VELastYearTotalQty := -AuxItemLedgerEntryLastYear.Quantity;
                    VELastYearTotalCost := -AuxValueEntryLastYear."Cost Amount (Actual)";
                    VELastYearTotalSales := AuxValueEntryLastYear."Sales Amount (Actual)";
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
        dataitem("Item Category"; "Item Category")
        {
            RequestFilterFields = "NPR Date Filter", "NPR Global Dimension 1 Filter", "NPR Global Dimension 2 Filter", "NPR Vendor Filter";
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
            FilterList := "Item Category".GetFilters
        else
            FilterList := "Item Category".GETFILTERS + ' SalesPerson: ' + SalesPerson;
        dateFilter := "Item Category".GetFilter("NPR Date Filter");
        dim1Filter := "Item Category".GetFilter("NPR Global Dimension 1 Filter");
        dim2Filter := "Item Category".GetFilter("NPR Global Dimension 2 Filter");
        vendorFilter := "Item Category".GetFilter("NPR Vendor Filter");

        Clear(AuxValueEntry);
        AuxValueEntry.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
        AuxValueEntry.SetFilter("Global Dimension 1 Code", '<>%1', '');

        if dateFilter <> '' then
            AuxValueEntry.SetFilter("Posting Date", dateFilter);
        if dim1Filter <> '' then
            AuxValueEntry.SetFilter("Global Dimension 1 Code", dim1Filter);
        if dim2Filter <> '' then
            AuxValueEntry.SetFilter("Global Dimension 2 Code", dim2Filter);
        if vendorFilter <> '' then
            AuxValueEntry.SetFilter("Vendor No.", vendorFilter);
        if SalesPerson <> '' then
            AuxValueEntry.SETFILTER("Salespers./Purch. Code", SalesPerson);

        AuxValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Purchase Amount (Actual)");

        Clear(AuxItemLedgerEntry);
        AuxItemLedgerEntry.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
        AuxItemLedgerEntry.SetFilter("Global Dimension 1 Code", '<>%1', '');

        if dateFilter <> '' then
            AuxItemLedgerEntry.SetFilter("Posting Date", dateFilter);
        if dim1Filter <> '' then
            AuxItemLedgerEntry.SetFilter("Global Dimension 1 Code", dim1Filter);
        if dim2Filter <> '' then
            AuxItemLedgerEntry.SetFilter("Global Dimension 2 Code", dim2Filter);
        if vendorFilter <> '' then
            AuxItemLedgerEntry.SetFilter("Vendor No.", vendorFilter);
        if SalesPerson <> '' then
            AuxItemLedgerEntry.SETFILTER("Salespers./Purch. Code", SalesPerson);

        AuxItemLedgerEntry.CalcSums(Quantity);

        VETotalQuantity := -AuxItemLedgerEntry.Quantity;
        VETotalCost := -AuxValueEntry."Cost Amount (Actual)";
        VETotalSales := AuxValueEntry."Sales Amount (Actual)";
        VETotalGlobalProfit := VETotalSales - VETotalCost;

        //-Past year
        if lastYear and (dateFilter <> '') then begin
            Clear(AuxValueEntryLastYear);
            AuxValueEntryLastYear.SetRange("Item Ledger Entry Type", AuxValueEntry."Item Ledger Entry Type"::Sale);
            AuxValueEntryLastYear.SetFilter("Global Dimension 1 Code", '<>%1', '');

            if dateFilter <> '' then
                AuxValueEntryLastYear.SetFilter("Posting Date", dateFilter);
            if dim1Filter <> '' then
                AuxValueEntryLastYear.SetFilter("Global Dimension 1 Code", dim1Filter);
            if dim2Filter <> '' then
                AuxValueEntryLastYear.SetFilter("Global Dimension 2 Code", dim2Filter);
            if vendorFilter <> '' then
                AuxValueEntryLastYear.SetFilter("Vendor No.", vendorFilter);
            if SalesPerson <> '' then
                AuxValueEntryLastYear.SETFILTER("Salespers./Purch. Code", SalesPerson);

            if dateFilter <> '' then begin
                AuxValueEntryLastYear.SetRange("Posting Date",
                CalcDate('<-1Y>', AuxValueEntryLastYear.GetRangeMin("Posting Date")),
                CalcDate('<-1Y>', AuxValueEntryLastYear.GetRangeMax("Posting Date")));
            end;
            AuxValueEntryLastYear.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)", "Purchase Amount (Actual)");

            Clear(AuxItemLedgerEntryLastYear);
            AuxItemLedgerEntryLastYear.SetRange("Entry Type", AuxItemLedgerEntry."Entry Type"::Sale);
            AuxItemLedgerEntryLastYear.SetFilter("Global Dimension 1 Code", '<>%1', '');
            if dateFilter <> '' then
                AuxItemLedgerEntryLastYear.SetFilter("Posting Date", dateFilter);
            if dim1Filter <> '' then
                AuxItemLedgerEntryLastYear.SetFilter("Global Dimension 1 Code", dim1Filter);
            if dim2Filter <> '' then
                AuxItemLedgerEntryLastYear.SetFilter("Global Dimension 2 Code", dim2Filter);
            if vendorFilter <> '' then
                AuxItemLedgerEntryLastYear.SetFilter("Vendor No.", vendorFilter);
            if SalesPerson <> '' then
                AuxItemLedgerEntryLastYear.SETFILTER("Salespers./Purch. Code", SalesPerson);

            if dateFilter <> '' then begin
                AuxItemLedgerEntryLastYear.SetRange("Posting Date",
                CalcDate('<-1Y>', AuxItemLedgerEntryLastYear.GetRangeMin("Posting Date")),
                CalcDate('<-1Y>', AuxItemLedgerEntryLastYear.GetRangeMax("Posting Date")));
            end;

            AuxItemLedgerEntryLastYear.CalcSums(Quantity);

            VELastYearTotalQty := -AuxItemLedgerEntryLastYear.Quantity;
            VELastYearTotalCost := -AuxValueEntryLastYear."Cost Amount (Actual)";
            VELastYearTotalSales := AuxValueEntryLastYear."Sales Amount (Actual)";
            VELastYearTotalGlobalProfit := VELastYearTotalSales - VELastYearTotalCost;

            VELastYearTotalSalesPerc := pct(VELastYearTotalSales, VELastYearTotalSales);
            VELastYearTotalProfit := VELastYearTotalSales - VELastYearTotalCost;
            VELastYearTotalProfitSalesPerc := pct(VELastYearTotalProfit, VELastYearTotalSales);
            VELastYearTotalProfitPerc := pct(VELastYearTotalProfit, VELastYearTotalGlobalProfit);
        end;
        //+Last year

        firstDimValue := true;

    end;

    var
        firmaopl: Record "Company Information";
        AuxItemLedgerEntryLastYear: Record "NPR Aux. Item Ledger Entry";
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
        AuxValueEntryLastYear: Record "NPR Aux. Value Entry";
        AuxValueEntry: Record "NPR Aux. Value Entry";
        CurrentYearShow: Boolean;
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

    procedure pct(Value: Decimal; total: Decimal) resultat: Decimal
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

