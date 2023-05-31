report 6014535 "NPR Sales Statistics By Dept."
{
#IF NOT BC17
    Extensible = false;
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
            DataItemTableView = sorting(Code, "Global Dimension No.") where("Global Dimension No." = const(1));
            column(COMPANYNAME; CompanyName) { }
            column(FilterList; FilterList) { }
            column(Code_DimensionValue; "Dimension Value".Code) { }
            column(Name_DimensionValue; "Dimension Value".Name) { }
            column(VELocQty_DimensionValue; VELocQty) { }
            column(VELocCost; VELocCost) { }
            column(VELocSales; VELocSales) { }
            column(VELocPrevYearPerc; VELocPrevYearPerc) { }
            column(VETotalProfit; VETotalProfit) { }
            column(txtDim1; Dim1Txt) { }
            column(VELocLastYearTotalQty; VELocLastYearTotalQty) { }
            column(VELocLastYearTotalCost; VELocLastYearTotalCost) { }
            column(VELocLastYearTotalSales; VELocLastYearTotalSales) { }
            column(VELocLastYearTotalProfit; VELocLastYearTotalProfit) { }
            column(VETotalGlobalProfit; VETotalGlobalProfit) { }
            column(VELastYearTotalGlobalProfit; VELastYearTotalGlobalProfit) { }
            column(dim1Filter; Dim1Filter) { }
            column(dateFilter; DateFilter) { }
            column(LastYear; LastYear) { }
            column(CurrentYearShow; CurrentYearShow) { }
            column(LastYearShow; LastYearShow) { }
            column(SalesPerson; SalespersonCode) { }

            trigger OnAfterGetRecord()
            var
                TempValueEntry: Record "Value Entry" temporary;
                CostAmount: Decimal;
                SalesAmount: Decimal;
            begin
                VELocLastYearTotalCost := 0;

                if not IsGroupedByLocation then
                    if not firstDimValue then
                        CurrReport.Skip()
                    else
                        firstDimValue := false;

                CurrentYearShow := true;
                LastYearShow := true;

                Clear(ValueEntry);
                ValueEntry.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                ValueEntry.SetRange(Filter_Dim_1_Code, Code);

                if DateFilter <> '' then
                    ValueEntry.SetFilter(Filter_DateTime, DateFilter);
                if Dim1Filter <> '' then
                    ValueEntry.SetFilter(Filter_Dim_1_Code, Dim1Filter);
                if Dim2Filter <> '' then
                    ValueEntry.SetFilter(Filter_Dim_2_Code, Dim2Filter);
                if VendorFilter <> '' then
                    ValueEntry.SetFilter(Filter_Vendor_No, VendorFilter);
                if SalespersonCode <> '' then
                    ValueEntry.SetFilter(Filter_Salespers_Purch_Code, SalespersonCode);
                ValueEntry.Open();
                while ValueEntry.Read() do begin
                    SalesAmount += ValueEntry.Sum_Sales_Amount_Actual;
                    CostAmount += ValueEntry.Sum_Cost_Amount_Actual;
                end;

                Clear(ILEByDeptQuery);
                Clear(ILEByPersonQuery);
                VELocQty := 0;
                case SalespersonCode <> '' of
                    true:
                        begin
                            ILEByPersonQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                            ILEByPersonQuery.SetRange(Filter_Global_Dimension_1_Code, Code);

                            if DateFilter <> '' then
                                ILEByPersonQuery.SetFilter(Filter_Posting_Date, DateFilter);
                            if Dim1Filter <> '' then
                                ILEByPersonQuery.SetFilter(Filter_Global_Dimension_1_Code, Dim1Filter);
                            if Dim2Filter <> '' then
                                ILEByPersonQuery.SetFilter(Filter_Global_Dimension_2_Code, Dim2Filter);
                            if VendorFilter <> '' then
                                ILEByPersonQuery.SetFilter(Filter_Vendor_No_, VendorFilter);
                            ILEByPersonQuery.SetFilter(Filter_SalesPers_Purch_Code, SalespersonCode);
                            ILEByPersonQuery.Open();
                            while ILEByPersonQuery.Read() do
                                VELocQty += -ILEByPersonQuery.Quantity;
                            ILEByPersonQuery.Close();
                        end;
                    false:
                        begin
                            ILEByDeptQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                            ILEByDeptQuery.SetRange(Filter_Global_Dimension_1_Code, Code);

                            if DateFilter <> '' then
                                ILEByDeptQuery.SetFilter(Filter_Posting_Date, DateFilter);
                            if Dim1Filter <> '' then
                                ILEByDeptQuery.SetFilter(Filter_Global_Dimension_1_Code, Dim1Filter);
                            if Dim2Filter <> '' then
                                ILEByDeptQuery.SetFilter(Filter_Global_Dimension_2_Code, Dim2Filter);
                            if VendorFilter <> '' then
                                ILEByDeptQuery.SetFilter(Filter_Vendor_No, VendorFilter);
                            ILEByDeptQuery.Open();
                            while ILEByDeptQuery.Read() do
                                VELocQty += -ILEByDeptQuery.Quantity;
                            ILEByDeptQuery.Close();
                        end;
                end;
                VELocCost := -CostAmount;
                VELocSales := SalesAmount;

                VETotalProfit := VELocSales - VELocCost;
                VETotalGlobalProfit += VETotalProfit;
                CurrentYearShow := true;

                if ((Dim1Filter <> '') and (Dim1Filter <> Code)) or (VELocQty = 0) then
                    CurrentYearShow := false;

                Clear(ValueEntryLastYear);
                ValueEntryLastYear.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                ValueEntryLastYear.SetRange(Filter_Dim_1_Code, Code);

                if Dim1Filter <> '' then
                    ValueEntryLastYear.SetFilter(Filter_Dim_1_Code, Dim1Filter);
                if Dim2Filter <> '' then
                    ValueEntryLastYear.SetFilter(Filter_Dim_2_Code, Dim2Filter);
                if VendorFilter <> '' then
                    ValueEntryLastYear.SetFilter(Filter_Vendor_No, VendorFilter);
                if SalespersonCode <> '' then
                    ValueEntryLastYear.SetFilter(Filter_Salespers_Purch_Code, SalespersonCode);

                if DateFilter <> '' then begin
                    TempValueEntry.SetFilter("Posting Date", DateFilter);
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
                case SalespersonCode <> '' of
                    true:
                        begin
                            ILEByPersonLastYearQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                            ILEByPersonLastYearQuery.SetRange(Filter_Global_Dimension_1_Code, Code);

                            if DateFilter <> '' then
                                ILEByPersonLastYearQuery.SetFilter(Filter_Posting_Date, DateFilter);
                            if Dim1Filter <> '' then
                                ILEByPersonLastYearQuery.SetFilter(Filter_Global_Dimension_1_Code, Dim1Filter);
                            if Dim2Filter <> '' then
                                ILEByPersonLastYearQuery.SetFilter(Filter_Global_Dimension_2_Code, Dim2Filter);
                            if VendorFilter <> '' then
                                ILEByPersonLastYearQuery.SetFilter(Filter_Vendor_No_, VendorFilter);
                            if SalespersonCode <> '' then
                                ILEByPersonLastYearQuery.SetFilter(Filter_SalesPers_Purch_Code, SalespersonCode);

                            if DateFilter <> '' then
                                ILEByPersonLastYearQuery.SetRange(Filter_Posting_Date,
                                CalcDate('<-1Y>', MinDate),
                                CalcDate('<-1Y>', MaxDate));
                            ILEByPersonLastYearQuery.Open();
                            while ILEByPersonLastYearQuery.Read() do
                                VELocLastYearTotalQty += -ILEByPersonLastYearQuery.Quantity;
                            ILEByPersonLastYearQuery.Close();
                        end;
                    false:
                        begin
                            ILEByDeptLastYearQuery.SetRange(Filter_Entry_Type, Enum::"Item Ledger Entry Type"::Sale);
                            ILEByDeptLastYearQuery.SetRange(Filter_Global_Dimension_1_Code, Code);

                            if DateFilter <> '' then
                                ILEByDeptLastYearQuery.SetFilter(Filter_Posting_Date, DateFilter);
                            if Dim1Filter <> '' then
                                ILEByDeptLastYearQuery.SetFilter(Filter_Global_Dimension_1_Code, Dim1Filter);
                            if Dim2Filter <> '' then
                                ILEByDeptLastYearQuery.SetFilter(Filter_Global_Dimension_2_Code, Dim2Filter);
                            if VendorFilter <> '' then
                                ILEByDeptLastYearQuery.SetFilter(Filter_Vendor_No, VendorFilter);
                            if DateFilter <> '' then
                                ILEByDeptLastYearQuery.SetRange(Filter_Posting_Date,
                                CalcDate('<-1Y>', MinDate),
                                CalcDate('<-1Y>', MaxDate));
                            ILEByDeptLastYearQuery.Open();
                            while ILEByDeptLastYearQuery.Read() do
                                VELocLastYearTotalQty += -ILEByDeptLastYearQuery.Quantity;
                            ILEByDeptLastYearQuery.Close();
                        end;
                end;
                VELocLastYearTotalCost := -CostAmount;
                VELocLastYearTotalSales := SalesAmount;
                VELocLastYearTotalProfit := VELocLastYearTotalSales - VELocLastYearTotalCost;
                VELastYearTotalGlobalProfit += VELocLastYearTotalProfit;

                LastYearShow := (LastYear and (DateFilter <> ''));
                if ((Dim1Filter <> '') and (Dim1Filter <> Code)) or (VELocLastYearTotalQty = 0) then
                    LastYearShow := false;
            end;
        }

        dataitem("Item Category"; "Item Category")
        {
            RequestFilterFields = "NPR Date Filter", "NPR Global Dimension 1 Filter", "NPR Global Dimension 2 Filter", "NPR Vendor Filter", "NPR Salesperson/Purch. Filter";
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(Control6150614)
                {
                    ShowCaption = false;
                    field("antal niveauer"; LevelsToShow)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Levels To Show';
                        ToolTip = 'Specifies the value of the Show No. Of Levels field';
                    }
                    field("kunmed salg"; SalesOnly)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Sales Only';
                        ToolTip = 'Specifies the value of the Only with Sales field';
                    }
                    field("last Year"; LastYear)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Show Last Year';
                        ToolTip = 'Specifies the value of the Print Last Years Numbers field';
                    }
                    field("is Grouped By Location"; IsGroupedByLocation)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Group By';
                        CaptionClass = Dim1LabelTxt;

                        ToolTip = 'Specifies the value of the Group By field';
                    }
                    field("Sales Person"; SalespersonCode)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Salesperson';
                        TableRelation = "Salesperson/Purchaser".Code;

                        ToolTip = 'Specifies the value of the Sales Person field';
                        Visible = false;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            LevelsToShow := 2;
        end;
    }

    labels
    {
        Report_Caption = 'Sales Statistics By Department';
        QuantitySale_Caption = 'Sales (Qty.)';
        CostExcVAT_Caption = 'Cost Excl. VAT';
        TurnoverExcVAT_Caption = 'Turnover Excl. VAT';
        Pct_Caption = 'Part %';
        ProfitExcVAT_Caption = 'Profit Excl. VAT';
        ProfitPct_Caption = 'Profit %';
        LastYear_Caption = 'Last year';
        Total_Caption = 'Total';
        Page_Caption = 'Page';
        Footer_Caption = 'NaviPartner København';
        Turnover_Caption = 'Turnover';
        Profit_Caption = 'Profit';
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);

        IsGroupedByLocation := true;

        CaptionClassDim1 := '1,1,1';
        Dim1Txt := CaptionClassTranslate(CaptionClassDim1);

        Dim1LabelTxt := 'Group by ' + Dim1Txt;
        if GlobalLanguage = 1030 then
            Dim1LabelTxt := 'Grupper ved ' + Dim1Txt;
    end;

    trigger OnPreReport()
    begin
        if SalespersonCode = '' then
            FilterList := "Item Category".GetFilters()
        else
            FilterList := "Item Category".GetFilters() + ' SalesPerson: ' + SalespersonCode;
        SalespersonCode := "Item Category"."NPR Salesperson/Purch. Filter";
        DateFilter := "Item Category".GetFilter("NPR Date Filter");
        MinDate := "Item Category".GetRangeMin("NPR Date Filter");
        MaxDate := "Item Category".GetRangeMax("NPR Date Filter");
        Dim1Filter := "Item Category".GetFilter("NPR Global Dimension 1 Filter");
        Dim2Filter := "Item Category".GetFilter("NPR Global Dimension 2 Filter");
        VendorFilter := "Item Category".GetFilter("NPR Vendor Filter");

        firstDimValue := true;
    end;

    var
        CompanyInformation: Record "Company Information";
        ILEByDeptLastYearQuery: Query "NPR Sales Statistics By Dept";
        ILEByDeptQuery: Query "NPR Sales Statistics By Dept";
        ILEByPersonLastYearQuery: Query "NPR Sales Statistics By Person";
        ILEByPersonQuery: Query "NPR Sales Statistics By Person";
        ValueEntry: Query "NPR Value Entry With Vendor";
        ValueEntryLastYear: Query "NPR Value Entry With Vendor";
        CurrentYearShow: Boolean;
        firstDimValue: Boolean;
        IsGroupedByLocation: Boolean;
        LastYear: Boolean;
        LastYearShow: Boolean;
        SalesOnly: Boolean;
        MaxDate: Date;
        MinDate: Date;
        VELastYearTotalGlobalProfit: Decimal;
        VELocCost: Decimal;
        VELocLastYearTotalCost: Decimal;
        VELocLastYearTotalProfit: Decimal;
        VELocLastYearTotalQty: Decimal;
        VELocLastYearTotalSales: Decimal;
        VELocPrevYearPerc: Decimal;
        VELocQty: Decimal;
        VELocSales: Decimal;
        VETotalGlobalProfit: Decimal;
        VETotalProfit: Decimal;
        LevelsToShow: Integer;
        DateFilter: Text;
        Dim1Filter: Text;
        Dim1Txt: Text;
        Dim2Filter: Text;
        FilterList: Text;
        SalespersonCode: Text;
        VendorFilter: Text;
        CaptionClassDim1: Text[30];
        Dim1LabelTxt: Text[100];
}