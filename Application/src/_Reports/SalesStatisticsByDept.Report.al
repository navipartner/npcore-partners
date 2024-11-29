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
        dataitem(Buffer; "NPR Sales Stat Buffer Table")
        {
            UseTemporary = true;
            column(COMPANYNAME; CompanyName()) { }
            column(FilterList; FilterList) { }
            column(Code_DimensionValue; Buffer.Code) { }
            column(Name_DimensionValue; Buffer.Description) { }
            column(VELocQty_DimensionValue; VELocQty) { }
            column(VELocCost; VELocCost) { }
            column(VELocSales; VELocSales) { }
            column(VELocPrevYearPerc; VELocPrevYearPerc) { }
            column(VETotalProfit; VETotalProfit) { }
            column(VELocProfitPct; VELocProfitPct) { }
            column(VELastYearProfitPct; VELastYearProfitPct) { }
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
            column(SalesPerson; SalespersonFilter) { }

            trigger OnAfterGetRecord()
            begin
                CurrentYearShow := true;

                VELocSales := Buffer."Decimal Field 1";
                VELocCost := -Buffer."Decimal Field 2";
                VELocQty := -Buffer."Decimal Field 3";

                if VELocSales = 0 then
                    VELocProfitPct := 0
                else
                    VELocProfitPct := Round((VELocSales - VELocCost) / VELocSales, 0.01);

                VETotalProfit := VELocSales - VELocCost;
                VETotalGlobalProfit += VETotalProfit;

                VELocLastYearTotalCost := 0;
                VELocLastYearTotalQty := 0;
                VELocLastYearTotalSales := 0;

                if LastYear then begin
                    LastYearShow := true;
                    VELocLastYearTotalSales := Buffer."Decimal Field 4";
                    VELocLastYearTotalCost := -Buffer."Decimal Field 5";
                    VELocLastYearTotalQty := -Buffer."Decimal Field 6";
                    VELocLastYearTotalProfit := VELocLastYearTotalSales - VELocLastYearTotalCost;
                    VELastYearTotalGlobalProfit += VELocLastYearTotalProfit;
                    if VELocLastYearTotalSales = 0 then
                        VELastYearProfitPct := 0
                    else
                        VELastYearProfitPct := Round((VELocLastYearTotalSales - VELocLastYearTotalCost) / VELocLastYearTotalSales, 0.01)
                end;
            end;

            trigger OnPostDataItem()
            begin
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

                    field("last Year"; LastYear)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Show Last Year';
                        ToolTip = 'Specifies the value of the Print Last Years Numbers field';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
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

        CaptionClassDim1 := '1,1,1';
        Dim1Txt := CaptionClassTranslate(CaptionClassDim1);

        Dim1LabelTxt := 'Group by ' + Dim1Txt;
        if GlobalLanguage = 1030 then
            Dim1LabelTxt := 'Grupper ved ' + Dim1Txt;
    end;

    trigger OnPreReport()
    begin
        FilterList := "Item Category".GetFilters();
        SalespersonFilter := "Item Category"."NPR Salesperson/Purch. Filter";
        DateFilter := "Item Category".GetFilter("NPR Date Filter");
        MinDate := "Item Category".GetRangeMin("NPR Date Filter");
        MaxDate := "Item Category".GetRangeMax("NPR Date Filter");
        Dim1Filter := "Item Category".GetFilter("NPR Global Dimension 1 Filter");
        Dim2Filter := "Item Category".GetFilter("NPR Global Dimension 2 Filter");
        VendorFilter := "Item Category".GetFilter("NPR Vendor Filter");

        InitBuffer();
        GetPeriodData();
        if LastYear then
            GetPreviousYearData();
    end;


    local procedure InitBuffer()
    var
        DimensionValue: Record "Dimension Value";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        DimensionValue.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 1 Code");
        if Dim1Filter <> '' then
            DimensionValue.SetFilter(Code, Dim1Filter);
        if DimensionValue.FindSet() then
            repeat
                Buffer.Init();
                Buffer.Code := DimensionValue.Code;
                Buffer.Description := DimensionValue.Name;
                Buffer.Insert();
            until DimensionValue.Next() = 0;
    end;

    local procedure GetPeriodData()
    var
        SalesStatisticsbyDepar: Query "NPR Sales Statistics by Depar";
    begin
        SalesStatisticsbyDepar.SetFilter(Posting_Date_Filter, DateFilter);

        if Dim1Filter <> '' then
            SalesStatisticsbyDepar.SetFilter(Global_Dimension_1_Filter, Dim1Filter);
        if Dim2Filter <> '' then
            SalesStatisticsbyDepar.SetFilter(Global_Dimension_2_Filter, Dim2Filter);
        if SalespersonFilter <> '' then
            SalesStatisticsbyDepar.SetFilter(Salespers__Purch__Filter, SalespersonFilter);
        if VendorFilter <> '' then
            SalesStatisticsbyDepar.SetFilter(Vendor_No_Filter, VendorFilter);

        SalesStatisticsbyDepar.Open();
        while SalesStatisticsbyDepar.Read() do begin
            PopulateBuffer(SalesStatisticsbyDepar);
        end;
        SalesStatisticsbyDepar.Close();
    end;

    local procedure PopulateBuffer(SalesStatisticsbyDepar: Query "NPR Sales Statistics by Depar")
    begin
        if not Buffer.Get(SalesStatisticsbyDepar.Dimension_1_Code) then begin
            Buffer.Init();
            Buffer.Code := SalesStatisticsbyDepar.Dimension_1_Code;
            Buffer.Insert();
        end;
        Buffer."Decimal Field 1" := SalesStatisticsbyDepar.Sales_Amount__Actual;
        Buffer."Decimal Field 2" := SalesStatisticsbyDepar.Cost_Amount__Actual;
        Buffer."Decimal Field 3" := SalesStatisticsbyDepar.Item_Ledger_Entry_Quantity;
        Buffer.Modify();
    end;

    local procedure GetPreviousYearData()
    var
        SalesStatisticsbyDepar: Query "NPR Sales Statistics by Depar";
    begin
        SalesStatisticsbyDepar.SetRange(Posting_Date_Filter, CalcDate('<-1Y>', MinDate), CalcDate('<-1Y>', MaxDate));
        if Dim1Filter <> '' then
            SalesStatisticsbyDepar.SetFilter(Global_Dimension_1_Filter, Dim1Filter);
        if Dim2Filter <> '' then
            SalesStatisticsbyDepar.SetFilter(Global_Dimension_2_Filter, Dim2Filter);
        if SalespersonFilter <> '' then
            SalesStatisticsbyDepar.SetFilter(Salespers__Purch__Filter, SalespersonFilter);
        if VendorFilter <> '' then
            SalesStatisticsbyDepar.SetFilter(Vendor_No_Filter, VendorFilter);

        SalesStatisticsbyDepar.Open();
        while SalesStatisticsbyDepar.Read() do begin
            PopulateBufferPrevious(SalesStatisticsbyDepar);
        end;
        SalesStatisticsbyDepar.Close();
    end;

    local procedure PopulateBufferPrevious(SalesStatisticsbyDepar: Query "NPR Sales Statistics by Depar")
    begin
        if not Buffer.Get(SalesStatisticsbyDepar.Dimension_1_Code) then begin
            Buffer.Init();
            Buffer.Code := SalesStatisticsbyDepar.Dimension_1_Code;
            Buffer.Insert();
        end;
        Buffer."Decimal Field 4" := SalesStatisticsbyDepar.Sales_Amount__Actual;
        Buffer."Decimal Field 5" := SalesStatisticsbyDepar.Cost_Amount__Actual;
        Buffer."Decimal Field 6" := SalesStatisticsbyDepar.Item_Ledger_Entry_Quantity;
        Buffer.Modify();
    end;

    var
        CompanyInformation: Record "Company Information";
        CurrentYearShow: Boolean;

        LastYear: Boolean;
        LastYearShow: Boolean;
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
        VELocProfitPct: Decimal;
        VELastYearProfitPct: Decimal;
        DateFilter: Text;
        Dim1Filter: Text;
        Dim1Txt: Text;
        Dim2Filter: Text;
        FilterList: Text;
        SalespersonFilter: Text;
        VendorFilter: Text;
        CaptionClassDim1: Text[30];
        Dim1LabelTxt: Text[100];
}