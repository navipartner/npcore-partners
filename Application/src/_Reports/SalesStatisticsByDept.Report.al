report 6014535 "NPR Sales Statistics By Dept."
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Statistics By Department.rdlc';
    Caption = 'Sales Statistics By Department';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

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
            var
                TempValueEntry: Record "Value Entry" temporary;
                SalesAmount: Decimal;
                CostAmount: Decimal;
            begin
                VELocLastYearTotalCost := 0;

                if not isGroupedByLocation then
                    if not firstDimValue then
                        CurrReport.Skip()
                    else
                        firstDimValue := false;

                CurrentYearShow := true;
                LastYearShow := true;

                Clear(ValueEntry);
                ValueEntry.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                ValueEntry.SetRange(Filter_Dim_1_Code, Code);

                if dateFilter <> '' then
                    ValueEntry.SetFilter(Filter_DateTime, dateFilter);
                if dim1Filter <> '' then
                    ValueEntry.SetFilter(Filter_Dim_1_Code, dim1Filter);
                if dim2Filter <> '' then
                    ValueEntry.SetFilter(Filter_Dim_2_Code, dim2Filter);
                if vendorFilter <> '' then
                    ValueEntry.SetFilter(Filter_Vendor_No, vendorFilter);
                if SalesPerson <> '' then
                    ValueEntry.SetFilter(Filter_Salespers_Purch_Code, SalesPerson);
                ValueEntry.Open();
                while ValueEntry.Read() do begin
                    SalesAmount += ValueEntry.Sum_Sales_Amount_Actual;
                    CostAmount += ValueEntry.Sum_Cost_Amount_Actual;
                end;

                Clear(ILEByDeptQuery);
                Clear(ILEByPersonQuery);
                VELocQty := 0;
                case SalesPerson <> '' of
                    true:
                        begin
                            ILEByPersonQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                            ILEByPersonQuery.SetRange(Filter_Global_Dimension_1_Code, Code);

                            if dateFilter <> '' then
                                ILEByPersonQuery.SetFilter(Filter_Posting_Date, dateFilter);
                            if dim1Filter <> '' then
                                ILEByPersonQuery.SetFilter(Filter_Global_Dimension_1_Code, dim1Filter);
                            if dim2Filter <> '' then
                                ILEByPersonQuery.SetFilter(Filter_Global_Dimension_2_Code, dim2Filter);
                            if vendorFilter <> '' then
                                ILEByPersonQuery.SetFilter(Filter_Vendor_No_, vendorFilter);
                            ILEByPersonQuery.SetFilter(Filter_SalesPers_Purch_Code, SalesPerson);
                            ILEByPersonQuery.Open();
                            while ILEByPersonQuery.Read() do
                                VELocQty += -ILEByPersonQuery.Quantity;
                            ILEByPersonQuery.Close();
                        end;
                    false:
                        begin
                            ILEByDeptQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                            ILEByDeptQuery.SetRange(Filter_Global_Dimension_1_Code, Code);

                            if dateFilter <> '' then
                                ILEByDeptQuery.SetFilter(Filter_Posting_Date, dateFilter);
                            if dim1Filter <> '' then
                                ILEByDeptQuery.SetFilter(Filter_Global_Dimension_1_Code, dim1Filter);
                            if dim2Filter <> '' then
                                ILEByDeptQuery.SetFilter(Filter_Global_Dimension_2_Code, dim2Filter);
                            if vendorFilter <> '' then
                                ILEByDeptQuery.SetFilter(Vendor_No_, vendorFilter);
                            ILEByDeptQuery.Open();
                            while ILEByDeptQuery.Read() do
                                VELocQty += -ILEByDeptQuery.Quantity;
                            ILEByDeptQuery.Close();
                        end;
                end;
                VELocCost := -CostAmount;
                VELocSales := SalesAmount;

                VETotalSalesPerc := pct(VELocSales, VETotalSales);
                VETotalProfit := VELocSales - VELocCost;
                VETotalProfitSalesPerc := pct(VETotalProfit, VELocSales);
                VETotalProfitPerc := pct(VETotalProfit, VETotalGlobalProfit);
                CurrentYearShow := true;
                if ((dim1Filter <> '') and (dim1Filter <> Code)) or (VELocQty = 0) then
                    CurrentYearShow := false;

                //Second body :
                Clear(ValueEntryLastYear);
                ValueEntryLastYear.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                ValueEntryLastYear.SetRange(Filter_Dim_1_Code, Code);

                if dim1Filter <> '' then
                    ValueEntryLastYear.SetFilter(Filter_Dim_1_Code, dim1Filter);
                if dim2Filter <> '' then
                    ValueEntryLastYear.SetFilter(Filter_Dim_2_Code, dim2Filter);
                if vendorFilter <> '' then
                    ValueEntryLastYear.SetFilter(Filter_Vendor_No, vendorFilter);
                if SalesPerson <> '' then
                    ValueEntryLastYear.SetFilter(Filter_Salespers_Purch_Code, SalesPerson);

                if dateFilter <> '' then begin
                    TempValueEntry.SetFilter("Posting Date", dateFilter);
                    ValueEntryLastYear.SetRange(Filter_DateTime,
                    CalcDate('<-1Y>', TempValueEntry.GetRangeMin("Posting Date")),
                    CalcDate('<-1Y>', TempValueEntry.GetRangeMax("Posting Date")));
                end;
                Clear(CostAmount);
                Clear(SalesAmount);
                ValueEntryLastYear.Open();
                while ValueEntryLastYear.Read() do begin
                    SalesAmount += ValueEntryLastYear.Sum_Sales_Amount_Actual;
                    CostAmount += ValueEntryLastYear.Sum_Cost_Amount_Actual;
                end;

                Clear(ILEByDeptLastYearQuery);
                Clear(ILEByPersonLastYearQuery);
                VELocLastYearTotalQty := 0;
                case SalesPerson <> '' of
                    true:
                        begin
                            ILEByPersonLastYearQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                            ILEByPersonLastYearQuery.SetRange(Filter_Global_Dimension_1_Code, Code);

                            if dateFilter <> '' then
                                ILEByPersonLastYearQuery.SetFilter(Filter_Posting_Date, dateFilter);
                            if dim1Filter <> '' then
                                ILEByPersonLastYearQuery.SetFilter(Filter_Global_Dimension_1_Code, dim1Filter);
                            if dim2Filter <> '' then
                                ILEByPersonLastYearQuery.SetFilter(Filter_Global_Dimension_2_Code, dim2Filter);
                            if vendorFilter <> '' then
                                ILEByPersonLastYearQuery.SetFilter(Filter_Vendor_No_, vendorFilter);
                            if SalesPerson <> '' then
                                ILEByPersonLastYearQuery.SetFilter(Filter_SalesPers_Purch_Code, SalesPerson);

                            if dateFilter <> '' then begin
                                ILEByPersonLastYearQuery.SetRange(Filter_Posting_Date,
                                CalcDate('<-1Y>', dateMin),
                                CalcDate('<-1Y>', dateMax));
                            end;
                            ILEByPersonLastYearQuery.Open();
                            while ILEByPersonLastYearQuery.Read() do
                                VELocLastYearTotalQty += -ILEByPersonLastYearQuery.Quantity;
                            ILEByPersonLastYearQuery.Close();
                        end;
                    false:
                        begin
                            ILEByDeptLastYearQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                            ILEByDeptLastYearQuery.SetRange(Filter_Global_Dimension_1_Code, Code);

                            if dateFilter <> '' then
                                ILEByDeptLastYearQuery.SetFilter(Filter_Posting_Date, dateFilter);
                            if dim1Filter <> '' then
                                ILEByDeptLastYearQuery.SetFilter(Filter_Global_Dimension_1_Code, dim1Filter);
                            if dim2Filter <> '' then
                                ILEByDeptLastYearQuery.SetFilter(Filter_Global_Dimension_2_Code, dim2Filter);
                            if vendorFilter <> '' then
                                ILEByDeptLastYearQuery.SetFilter(Vendor_No_, vendorFilter);
                            if dateFilter <> '' then begin
                                ILEByDeptLastYearQuery.SetRange(Filter_Posting_Date,
                                CalcDate('<-1Y>', dateMin),
                                CalcDate('<-1Y>', dateMax));
                            end;
                            ILEByDeptLastYearQuery.Open();
                            while ILEByDeptLastYearQuery.Read() do
                                VELocLastYearTotalQty += -ILEByDeptLastYearQuery.Quantity;
                            ILEByDeptLastYearQuery.Close();
                        end;
                end;
                VELocLastYearTotalCost := -CostAmount;
                VELocLastYearTotalSales := SalesAmount;
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
            var
                SalesAmount: Decimal;
                CostAmount: Decimal;
            begin
                Clear(ValueEntry);
                ValueEntry.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                ValueEntry.SetFilter(Filter_Dim_1_Code, '<>%1', '');
                if dateFilter <> '' then
                    ValueEntry.SetFilter(Filter_DateTime, dateFilter);
                if dim1Filter <> '' then
                    ValueEntry.SetFilter(Filter_Dim_1_Code, dim1Filter);
                if dim2Filter <> '' then
                    ValueEntry.SetFilter(Filter_Dim_2_Code, dim2Filter);
                if vendorFilter <> '' then
                    ValueEntry.SetFilter(Filter_Vendor_No, vendorFilter);
                if SalesPerson <> '' then
                    ValueEntry.SetFilter(Filter_Salespers_Purch_Code, SalesPerson);
                ValueEntry.Open();
                while ValueEntry.Read() do begin
                    SalesAmount += ValueEntry.Sum_Sales_Amount_Actual;
                    CostAmount += ValueEntry.Sum_Cost_Amount_Actual;
                end;

                Clear(ILEByDeptQuery);
                Clear(ILEByPersonQuery);
                VETotalQuantity := 0;
                case SalesPerson <> '' of
                    true:
                        begin
                            ILEByPersonQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                            ILEByPersonQuery.SetFilter(Filter_Global_Dimension_1_Code, '<>%1', '');
                            if dateFilter <> '' then
                                ILEByPersonQuery.SetFilter(Filter_Posting_Date, dateFilter);
                            if dim1Filter <> '' then
                                ILEByPersonQuery.SetFilter(Filter_Global_Dimension_1_Code, dim1Filter);
                            if dim2Filter <> '' then
                                ILEByPersonQuery.SetFilter(Filter_Global_Dimension_2_Code, dim2Filter);
                            if vendorFilter <> '' then
                                ILEByPersonQuery.SetFilter(Filter_Vendor_No_, vendorFilter);
                            if SalesPerson <> '' then
                                ILEByPersonQuery.SetFilter(Filter_SalesPers_Purch_Code, SalesPerson);
                            ILEByPersonQuery.Open();
                            while ILEByPersonQuery.Read() do
                                VETotalQuantity += -ILEByPersonQuery.Quantity;
                            ILEByPersonQuery.Close();
                        end;
                    false:
                        begin
                            ILEByDeptQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                            ILEByDeptQuery.SetFilter(Filter_Global_Dimension_1_Code, '<>%1', '');
                            if dateFilter <> '' then
                                ILEByDeptQuery.SetFilter(Filter_Posting_Date, dateFilter);
                            if dim1Filter <> '' then
                                ILEByDeptQuery.SetFilter(Filter_Global_Dimension_1_Code, dim1Filter);
                            if dim2Filter <> '' then
                                ILEByDeptQuery.SetFilter(Filter_Global_Dimension_2_Code, dim2Filter);
                            if vendorFilter <> '' then
                                ILEByDeptQuery.SetFilter(Vendor_No_, vendorFilter);
                            ILEByDeptQuery.Open();
                            while ILEByDeptQuery.Read() do
                                VETotalQuantity += -ILEByDeptQuery.Quantity;
                            ILEByDeptQuery.Close();
                        end;
                end;
                VETotalCost := -CostAmount;
                VETotalSales := SalesAmount;
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
            var
                TempValueEntry: Record "Value Entry" temporary;
                CostAmount: Decimal;
                SalesAmount: Decimal;
            begin
                //-Past year
                if lastYear and (dateFilter <> '') then begin
                    Clear(ValueEntryLastYear);
                    ValueEntryLastYear.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                    ValueEntryLastYear.SetFilter(Filter_Dim_1_Code, '<>%1', '');

                    if dim1Filter <> '' then
                        ValueEntryLastYear.SetFilter(Filter_Dim_1_Code, dim1Filter);
                    if dim2Filter <> '' then
                        ValueEntryLastYear.SetFilter(Filter_Dim_2_Code, dim2Filter);
                    if vendorFilter <> '' then
                        ValueEntryLastYear.SetFilter(Filter_Vendor_No, vendorFilter);

                    if dateFilter <> '' then begin
                        TempValueEntry.SetFilter("Posting Date", dateFilter);
                        ValueEntryLastYear.SetRange(Filter_DateTime,
                        CalcDate('<-1Y>', TempValueEntry.GetRangeMin("Posting Date")),
                        CalcDate('<-1Y>', TempValueEntry.GetRangeMax("Posting Date")));
                    end;
                    ValueEntryLastYear.Open();
                    while ValueEntryLastYear.Read() do begin
                        CostAmount += ValueEntryLastYear.Sum_Cost_Amount_Actual;
                        SalesAmount += ValueEntryLastYear.Sum_Sales_Amount_Actual;
                    end;

                    Clear(ILEByDeptLastYearQuery);
                    Clear(ILEByPersonLastYearQuery);
                    VELastYearTotalQty := 0;
                    case SalesPerson <> '' of
                        true:
                            begin
                                ILEByPersonLastYearQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                                ILEByPersonLastYearQuery.SetRange(Filter_Global_Dimension_1_Code, '<>%1', '');

                                if dateFilter <> '' then
                                    ILEByPersonLastYearQuery.SetFilter(Filter_Posting_Date, dateFilter);
                                if dim1Filter <> '' then
                                    ILEByPersonLastYearQuery.SetFilter(Filter_Global_Dimension_1_Code, dim1Filter);
                                if dim2Filter <> '' then
                                    ILEByPersonLastYearQuery.SetFilter(Filter_Global_Dimension_2_Code, dim2Filter);
                                if vendorFilter <> '' then
                                    ILEByPersonLastYearQuery.SetFilter(Filter_Vendor_No_, vendorFilter);
                                if SalesPerson <> '' then
                                    ILEByPersonLastYearQuery.SetFilter(Filter_SalesPers_Purch_Code, SalesPerson);

                                if dateFilter <> '' then begin
                                    ILEByPersonLastYearQuery.SetRange(Filter_Posting_Date,
                                    CalcDate('<-1Y>', dateMin),
                                    CalcDate('<-1Y>', dateMax));
                                end;
                                ILEByPersonLastYearQuery.Open();
                                while ILEByPersonLastYearQuery.Read() do
                                    VELastYearTotalQty += -ILEByPersonLastYearQuery.Quantity;
                                ILEByPersonLastYearQuery.Close();
                            end;
                        false:
                            begin
                                ILEByDeptLastYearQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                                ILEByDeptLastYearQuery.SetRange(Filter_Global_Dimension_1_Code, '<>%1', '');

                                if dateFilter <> '' then
                                    ILEByDeptLastYearQuery.SetFilter(Filter_Posting_Date, dateFilter);
                                if dim1Filter <> '' then
                                    ILEByDeptLastYearQuery.SetFilter(Filter_Global_Dimension_1_Code, dim1Filter);
                                if dim2Filter <> '' then
                                    ILEByDeptLastYearQuery.SetFilter(Filter_Global_Dimension_2_Code, dim2Filter);
                                if vendorFilter <> '' then
                                    ILEByDeptLastYearQuery.SetFilter(Vendor_No_, vendorFilter);
                                if dateFilter <> '' then begin
                                    ILEByDeptLastYearQuery.SetRange(Filter_Posting_Date,
                                    CalcDate('<-1Y>', dateMin),
                                    CalcDate('<-1Y>', dateMax));
                                end;
                                ILEByDeptLastYearQuery.Open();
                                while ILEByDeptLastYearQuery.Read() do
                                    VELastYearTotalQty += -ILEByDeptLastYearQuery.Quantity;
                                ILEByDeptLastYearQuery.Close();
                            end;
                    end;
                    VELastYearTotalCost := -CostAmount;
                    VELastYearTotalSales := SalesAmount;
                    VELastYearTotalGlobalProfit := VELastYearTotalSales - VELastYearTotalCost;

                    VELastYearTotalSalesPerc := pct(VELastYearTotalSales, VELastYearTotalSales);
                    VELastYearTotalProfit := VELastYearTotalSales - VELastYearTotalCost;
                    VELastYearTotalProfitSalesPerc := pct(VELastYearTotalProfit, VELastYearTotalSales);//
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
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Control6150614)
                {
                    ShowCaption = false;
                    field("antal niveauer"; antalniveauer)
                    {
                        Caption = 'Levels To Show';
                        ToolTip = 'Specifies the value of the Show No. Of Levels field';
                        ApplicationArea = NPRRetail;
                    }
                    field("kunmed salg"; kunmedsalg)
                    {
                        Caption = 'With Sales Only';
                        ToolTip = 'Specifies the value of the Only with Sales field';
                        ApplicationArea = NPRRetail;
                    }
                    field("vis varer"; visvarer)
                    {
                        Caption = 'Show Items';
                        ToolTip = 'Specifies the value of the Print Items field';
                        ApplicationArea = NPRRetail;
                    }
                    field("last Year"; lastYear)
                    {
                        Caption = 'Show Last Year';
                        ToolTip = 'Specifies the value of the Print Last Years Numbers field';
                        ApplicationArea = NPRRetail;
                    }
                    field("is Grouped By Location"; isGroupedByLocation)
                    {
                        CaptionClass = txtLabeldim1;
                        Caption = 'Group By';

                        ToolTip = 'Specifies the value of the Group By field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales Person"; SalesPerson)
                    {
                        Caption = 'Sales Person';
                        TableRelation = "Salesperson/Purchaser".Code;

                        ToolTip = 'Specifies the value of the Sales Person field';
                        ApplicationArea = NPRRetail;
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
        Report_Caption = 'Sales Statistics By Department';
        QuantitySale_Caption = 'Quantity (sale)';
        CostExcVAT_Caption = 'Cost excl. VAT';
        TurnoverExcVAT_Caption = 'Turnover excl. VAT';
        Pct_Caption = 'Line Percentage';
        ProfitExcVAT_Caption = 'Profit excl. VAT';
        ProfitPct_Caption = 'Profit %';
        LastYear_Caption = 'Last year';
        Total_Caption = 'Total';
        Page_Caption = 'Page';
        Footer_Caption = 'ˆNAVIPARTNER K¢benhavn 2002';
        Turnover_Caption = 'Turnover';
        Profit_Caption = 'Profit';
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
    var
        TempValueEntry: Record "Value Entry" temporary;
        CostAmount: Decimal;
        SalesAmount: Decimal;
    begin
        if SalesPerson = '' then
            FilterList := "Item Category".GetFilters
        else
            FilterList := "Item Category".GETFILTERS + ' SalesPerson: ' + SalesPerson;
        dateFilter := "Item Category".GetFilter("NPR Date Filter");
        dateMin := "Item Category".GetRangeMin("NPR Date Filter");
        dateMax := "Item Category".GetRangeMax("NPR Date Filter");
        dim1Filter := "Item Category".GetFilter("NPR Global Dimension 1 Filter");
        dim2Filter := "Item Category".GetFilter("NPR Global Dimension 2 Filter");
        vendorFilter := "Item Category".GetFilter("NPR Vendor Filter");

        Clear(ValueEntry);
        ValueEntry.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
        ValueEntry.SetFilter(Filter_Dim_1_Code, '<>%1', '');

        if dateFilter <> '' then
            ValueEntry.SetFilter(Filter_DateTime, dateFilter);
        if dim1Filter <> '' then
            ValueEntry.SetFilter(Filter_Dim_1_Code, dim1Filter);
        if dim2Filter <> '' then
            ValueEntry.SetFilter(Filter_Dim_2_Code, dim2Filter);
        if vendorFilter <> '' then
            ValueEntry.SetFilter(Filter_Vendor_No, vendorFilter);
        if SalesPerson <> '' then
            ValueEntry.SetFilter(Filter_Salespers_Purch_Code, SalesPerson);
        ValueEntry.Open();
        while ValueEntry.Read() do begin
            CostAmount += ValueEntry.Sum_Cost_Amount_Actual;
            SalesAmount += ValueEntry.Sum_Sales_Amount_Actual;
        end;


        Clear(ILEByDeptQuery);
        Clear(ILEByPersonQuery);
        VETotalQuantity := 0;
        case SalesPerson <> '' of
            true:
                begin
                    ILEByPersonQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                    ILEByPersonQuery.SetRange(Filter_Global_Dimension_1_Code, '<>%1', '');

                    if dateFilter <> '' then
                        ILEByPersonQuery.SetFilter(Filter_Posting_Date, dateFilter);
                    if dim1Filter <> '' then
                        ILEByPersonQuery.SetFilter(Filter_Global_Dimension_1_Code, dim1Filter);
                    if dim2Filter <> '' then
                        ILEByPersonQuery.SetFilter(Filter_Global_Dimension_2_Code, dim2Filter);
                    if vendorFilter <> '' then
                        ILEByPersonQuery.SetFilter(Filter_Vendor_No_, vendorFilter);
                    ILEByPersonQuery.SetFilter(Filter_SalesPers_Purch_Code, SalesPerson);
                    ILEByPersonQuery.Open();
                    while ILEByPersonQuery.Read() do
                        VETotalQuantity += -ILEByPersonQuery.Quantity;
                    ILEByPersonQuery.Close();
                end;
            false:
                begin
                    ILEByDeptQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                    ILEByDeptQuery.SetRange(Filter_Global_Dimension_1_Code, '<>%1', '');

                    if dateFilter <> '' then
                        ILEByDeptQuery.SetFilter(Filter_Posting_Date, dateFilter);
                    if dim1Filter <> '' then
                        ILEByDeptQuery.SetFilter(Filter_Global_Dimension_1_Code, dim1Filter);
                    if dim2Filter <> '' then
                        ILEByDeptQuery.SetFilter(Filter_Global_Dimension_2_Code, dim2Filter);
                    if vendorFilter <> '' then
                        ILEByDeptQuery.SetFilter(Vendor_No_, vendorFilter);
                    ILEByDeptQuery.Open();
                    while ILEByDeptQuery.Read() do
                        VETotalQuantity += -ILEByDeptQuery.Quantity;
                    ILEByDeptQuery.Close();
                end;
        end;
        VETotalCost := -CostAmount;
        VETotalSales := SalesAmount;
        VETotalGlobalProfit := VETotalSales - VETotalCost;

        //-Past year
        if lastYear and (dateFilter <> '') then begin
            Clear(ValueEntryLastYear);
            ValueEntryLastYear.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
            ValueEntryLastYear.SetFilter(Filter_Dim_1_Code, '<>%1', '');

            if dim1Filter <> '' then
                ValueEntryLastYear.SetFilter(Filter_Dim_1_Code, dim1Filter);
            if dim2Filter <> '' then
                ValueEntryLastYear.SetFilter(Filter_Dim_2_Code, dim2Filter);
            if vendorFilter <> '' then
                ValueEntryLastYear.SetFilter(Filter_Vendor_No, vendorFilter);
            if SalesPerson <> '' then
                ValueEntryLastYear.SetFilter(Filter_Salespers_Purch_Code, SalesPerson);

            if dateFilter <> '' then begin
                TempValueEntry.SetFilter("Posting Date", dateFilter);
                ValueEntryLastYear.SetRange(Filter_DateTime,
                CalcDate('<-1Y>', TempValueEntry.GetRangeMin("Posting Date")),
                CalcDate('<-1Y>', TempValueEntry.GetRangeMax("Posting Date")));
            end;
            ValueEntryLastYear.Open();
            while ValueEntryLastYear.Read() do begin
                CostAmount += ValueEntryLastYear.Sum_Cost_Amount_Actual;
                SalesAmount += ValueEntryLastYear.Sum_Sales_Amount_Actual;
            end;

            Clear(ILEByDeptLastYearQuery);
            Clear(ILEByPersonLastYearQuery);
            VELastYearTotalQty := 0;
            case SalesPerson <> '' of
                true:
                    begin
                        ILEByPersonLastYearQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                        ILEByPersonLastYearQuery.SetRange(Filter_Global_Dimension_1_Code, '<>%1', '');

                        if dateFilter <> '' then
                            ILEByPersonLastYearQuery.SetFilter(Filter_Posting_Date, dateFilter);
                        if dim1Filter <> '' then
                            ILEByPersonLastYearQuery.SetFilter(Filter_Global_Dimension_1_Code, dim1Filter);
                        if dim2Filter <> '' then
                            ILEByPersonLastYearQuery.SetFilter(Filter_Global_Dimension_2_Code, dim2Filter);
                        if vendorFilter <> '' then
                            ILEByPersonLastYearQuery.SetFilter(Filter_Vendor_No_, vendorFilter);
                        if SalesPerson <> '' then
                            ILEByPersonLastYearQuery.SetFilter(Filter_SalesPers_Purch_Code, SalesPerson);

                        if dateFilter <> '' then begin
                            ILEByPersonLastYearQuery.SetRange(Filter_Posting_Date,
                            CalcDate('<-1Y>', dateMin),
                            CalcDate('<-1Y>', dateMax));
                        end;
                        ILEByPersonLastYearQuery.Open();
                        while ILEByPersonLastYearQuery.Read() do
                            VELastYearTotalQty += -ILEByPersonLastYearQuery.Quantity;
                        ILEByPersonLastYearQuery.Close();
                    end;
                false:
                    begin
                        ILEByDeptLastYearQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                        ILEByDeptLastYearQuery.SetRange(Filter_Global_Dimension_1_Code, '<>%1', '');

                        if dateFilter <> '' then
                            ILEByDeptLastYearQuery.SetFilter(Filter_Posting_Date, dateFilter);
                        if dim1Filter <> '' then
                            ILEByDeptLastYearQuery.SetFilter(Filter_Global_Dimension_1_Code, dim1Filter);
                        if dim2Filter <> '' then
                            ILEByDeptLastYearQuery.SetFilter(Filter_Global_Dimension_2_Code, dim2Filter);
                        if vendorFilter <> '' then
                            ILEByDeptLastYearQuery.SetFilter(Vendor_No_, vendorFilter);
                        if dateFilter <> '' then begin
                            ILEByDeptLastYearQuery.SetRange(Filter_Posting_Date,
                            CalcDate('<-1Y>', dateMin),
                            CalcDate('<-1Y>', dateMax));
                        end;
                        ILEByDeptLastYearQuery.Open();
                        while ILEByDeptLastYearQuery.Read() do
                            VELastYearTotalQty += -ILEByDeptLastYearQuery.Quantity;
                        ILEByDeptLastYearQuery.Close();
                    end;
            end;
            VELastYearTotalCost := -CostAmount;
            VELastYearTotalSales := SalesAmount;
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
        ILEByDeptLastYearQuery: Query "NPR Sales Statistics By Dept";
        ILEByDeptQuery: Query "NPR Sales Statistics By Dept";
        ILEByPersonLastYearQuery: Query "NPR Sales Statistics By Person";
        ILEByPersonQuery: Query "NPR Sales Statistics By Person";
        ValueEntryLastYear: Query "NPR Value Entry With Vendor";
        ValueEntry: Query "NPR Value Entry With Vendor";
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
        dateFilter: Text;
        dim1Filter: Text;
        dim2Filter: Text;
        pctfjortekst: Text[30];
        txtDim1: Text;
        vendorFilter: Text;
        txtLabeldim1: Text[100];
        FilterList: Text;
        dateMin: Date;
        dateMax: Date;

    internal procedure pct(Value: Decimal; total: Decimal) resultat: Decimal
    begin
        if Value <> 0 then
            if total <> 0 then
                resultat := Round((Value / total) * 100, 0.1)
            else
                resultat := 0;
    end;

    internal procedure opdaterSidsteAar(salg_dkk: Decimal; salg_antal: Decimal; forbrug: Decimal; i: Integer)
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

    internal procedure calcVareDg(Vare: Record Item; i: Integer)
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

