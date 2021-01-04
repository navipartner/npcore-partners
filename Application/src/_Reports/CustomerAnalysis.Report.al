report 6014432 "NPR Customer Analysis"
{
    // NPR70.00.00.00/LS/190514  CASE 176117 : Convert Report to Nav 2013
    // NPR4.14/KN/20150818 CASE  220283 Updated OptionCaptions to Control6150615 in request page
    // NPR4.21/LS/20151125 CASE 221808 Re writing codes/danish variables,use of FIND('-'),FIND('+') , changing Report name/label
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on obsolite property CurrReport_PAGENO
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.49/BHR /20190115  CASE 341969 Corrections as per OMA Guidelines
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Customer Analysis.rdlc';

    Caption = 'Customer Analysis';
    UsageCategory = ReportsAndAnalysis;
    UseSystemPrinter = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "Date Filter", "Customer Posting Group";

            trigger OnAfterGetRecord()
            begin
                Window.Update(1, "No.");
                CustomerCount += 1;
                Window.Update(2, (100 * Round(CustomerCount * 100 / DebCount, 1)));

                CalcFields("Sales (LCY)", "Balance (LCY)", "Profit (LCY)");
                if ("Sales (LCY)" = 0) and ("Balance (LCY)" = 0) and ("Profit (LCY)" = 0) then
                    CurrReport.Skip;
                CustomerAmountTemp.Init;
                CustomerAmountTemp."Customer No." := "No.";

                if Sorting = Sorting::Maximum then
                    Multipl := -1
                else
                    Multipl := 1;

                case ShowType of
                    ShowType::Sales:
                        begin
                            CustomerAmountTemp."Amount (LCY)" := Multipl * "Sales (LCY)";
                            CustomerAmountTemp."Amount 2 (LCY)" := Multipl * "Balance (LCY)";
                        end;
                    ShowType::Balance:
                        begin
                            CustomerAmountTemp."Amount (LCY)" := Multipl * "Balance (LCY)";
                            CustomerAmountTemp."Amount 2 (LCY)" := Multipl * "Sales (LCY)";
                        end;
                    ShowType::Margin:
                        begin
                            CustomerAmountTemp."Amount (LCY)" := Multipl * "Profit (LCY)";
                            CustomerAmountTemp."Amount 2 (LCY)" := Multipl * "Balance (LCY)";
                        end;
                end;

                CustomerAmountTemp.Insert;
                if (ShowQty = 0) or (i < ShowQty) then
                    i := i + 1
                else begin
                    CustomerAmountTemp.FindLast;
                    CustomerAmountTemp.Delete;
                end;

                //-NPR70.00.00.00/LS/190514
                CustomerSalesTotal += "Sales (LCY)";
                CustomerProfitTotal += "Profit (LCY)";
                CustomerBalanceTotal += "Balance (LCY)";
                //+NPR70.00.00.00/LS/190514
            end;

            trigger OnPreDataItem()
            begin
                Window.Open(Text10600000 +
                            '@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\' +
                            Text10600001 +
                            '@4@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\' +
                            Text10600002 +
                            '@5@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

                DebCount := Customer.Count;
                i := 0;
                CustomerAmountTemp.DeleteAll;
                //-NPR5.39
                //CurrReport.CREATETOTALS("Sales (LCY)","Balance (LCY)","Profit (LCY)");
                //+NPR5.39
            end;
        }
        dataitem(Integer1; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not Customer1.FindFirst then
                        CurrReport.Break;
                end else
                    if Customer1.Next = 0 then begin
                        CurrReport.Break;
                    end;
                CustomerCount += 1;
                Window.Update(4, (100 * Round(CustomerCount * 100 / DebCount, 1)));
                Customer1.CalcFields("Sales (LCY)", "Balance (LCY)", "Profit (LCY)");

                if (Customer1."Sales (LCY)" = 0) and (Customer1."Balance (LCY)" = 0) and (Customer1."Profit (LCY)" = 0) then
                    CurrReport.Skip;
                CustomerAmountTemp2.Init;
                CustomerAmountTemp2."Customer No." := Customer1."No.";
                if Sorting = Sorting::Maximum then
                    Multipl := -1
                else
                    Multipl := 1;

                case ShowType of
                    ShowType::Sales:
                        begin
                            CustomerAmountTemp2."Amount (LCY)" := Multipl * Customer1."Sales (LCY)";
                            CustomerAmountTemp2."Amount 2 (LCY)" := Multipl * Customer1."Balance (LCY)";
                            CustomerAmountTemp2."NPR Amount 3 (LCY)" := Multipl * Customer1."Profit (LCY)";
                        end;
                    ShowType::Balance:
                        begin
                            CustomerAmountTemp2."Amount (LCY)" := Multipl * Customer1."Balance (LCY)";
                            CustomerAmountTemp2."Amount 2 (LCY)" := Multipl * Customer1."Sales (LCY)";
                            CustomerAmountTemp2."NPR Amount 3 (LCY)" := Multipl * Customer1."Profit (LCY)";
                        end;
                    ShowType::Margin:
                        begin
                            CustomerAmountTemp2."Amount (LCY)" := Multipl * Customer1."Profit (LCY)";
                            CustomerAmountTemp2."Amount 2 (LCY)" := Multipl * Customer1."Sales (LCY)";
                            CustomerAmountTemp2."NPR Amount 3 (LCY)" := Multipl * Customer1."Balance (LCY)";
                        end;
                end;
                CustomerAmountTemp2.Insert;

                i += 1;

                //-NPR70.00.00.00/LS/190514
                Customer1SalesTotal += Customer1."Sales (LCY)";
                Customer1ProfitTotal += Customer1."Profit (LCY)";
                Customer1BalanceTotal += Customer1."Balance (LCY)";
                //+NPR70.00.00.00/LS/190514
            end;

            trigger OnPreDataItem()
            begin
                Customer1.CopyFilters(Customer);
                CustomerCount := 0;
                i := 0;
                if Customer.GetFilter("Date Filter") <> '' then begin
                    MinDate := Customer.GetRangeMin("Date Filter");
                    MaxDate := Customer.GetRangeMax("Date Filter");
                    MinDate := CalcDate('<-1Y>', MinDate);
                    MaxDate := CalcDate('<-1Y>', MaxDate);
                    Customer1.SetFilter("Date Filter", '%1..%2', MinDate, MaxDate);
                end;
                //-NPR5.39
                //CurrReport.CREATETOTALS(Customer1."Sales (LCY)",Customer1."Balance (LCY)",Customer1."Profit (LCY)");
                //+NPR5.39
            end;
        }
        dataitem(IntegerSorting; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not CustomerAmountTemp2.FindFirst then
                        CurrReport.Break;
                end else
                    if CustomerAmountTemp2.Next = 0 then begin
                        CurrReport.Break;
                    end;

                if Number <= ShowQty then
                    case ShowType of
                        ShowType::Sales:
                            begin
                                CustSalesDKK1 += -CustomerAmountTemp2."Amount (LCY)";
                                CustBalanceDKK1 += -CustomerAmountTemp2."Amount 2 (LCY)";
                                CustProfitDKK1 += -CustomerAmountTemp2."NPR Amount 3 (LCY)";
                            end;
                        ShowType::Balance:
                            begin
                                CustSalesDKK1 += -CustomerAmountTemp2."Amount 2 (LCY)";
                                CustBalanceDKK1 += -CustomerAmountTemp2."Amount (LCY)";
                                CustProfitDKK1 += -CustomerAmountTemp2."NPR Amount 3 (LCY)";
                            end;
                        ShowType::Margin:
                            begin
                                CustSalesDKK1 += -CustomerAmountTemp2."Amount 2 (LCY)";
                                CustBalanceDKK1 += -CustomerAmountTemp2."NPR Amount 3 (LCY)";
                                CustProfitDKK1 += -CustomerAmountTemp2."Amount (LCY)";
                            end;
                    end;

                CustomerAmountTemp2."NPR Location" := Number;
                CustomerAmountTemp2.Modify;
                Window.Update(5, (100 * Round(Number * 100 / DebCount, 1)));
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));
            column(Report_Caption; Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(PeriodFilter; StrSubstNo(Text10600003, CustomerDateFilter))
            {
            }
            column(SequenceFilter; StrSubstNo(Text10600004, ShowType, ShowQty))
            {
            }
            column(CustomerFilter; Customer.TableCaption + ': ' + CustomerFilter)
            {
            }
            column(Number_Integer; Integer.Number)
            {
            }
            column(No_Customer; Customer."No.")
            {
            }
            column(Name_Customer; Customer.Name)
            {
            }
            column(Sales_LCY_Customer; Customer."Sales (LCY)")
            {
            }
            column(Balance_LCY_Customer; Customer."Balance (LCY)")
            {
            }
            column(Profit_LCY_Customer; Customer."Profit (LCY)")
            {
            }
            column(CustomerSalesTotal; CustomerSalesTotal)
            {
            }
            column(CustomerProfitTotal; CustomerProfitTotal)
            {
            }
            column(CustomerBalanceTotal; CustomerBalanceTotal)
            {
            }
            column(AvancePct_Value; StrSubstNo('%1%', AvancePct))
            {
            }
            column(Share_Value; StrSubstNo('%1%', Share))
            {
            }
            column(TotalPct_Value; StrSubstNo('%1%', TotalPct))
            {
            }
            column(LastLocation; LastLocation)
            {
            }
            column(CustVarAmt; CustVarAmt)
            {
            }
            column(Index; Index)
            {
            }
            column(SequenceCaption; SequenceCaption_Lbl)
            {
            }
            column(NoCaption; NoCaptionLbl)
            {
            }
            column(NameCaption; NameCaptionLbl)
            {
            }
            column(SaleCaption; SaleCaptionLbl)
            {
            }
            column(BalanceCaption; BalanceCaptionLbl)
            {
            }
            column(ProfitCaption; ProfitCaptionLbl)
            {
            }
            column(ProfitPctCaption; ProfitPctCaptionLbl)
            {
            }
            column(LargestPctCaption; LargestPctCaptionLbl)
            {
            }
            column(ShareTotalCaption; ShareTotalCaptionLbl)
            {
            }
            column(PlacingLastYrCaption; PlacingLastYrCaptionLbl)
            {
            }
            column(DebVarBelCaption; StrSubstNo(Text10600005, ShowType))
            {
            }
            column(IndexCaption; IndexCaptionLbl)
            {
            }
            column(LastYearCaption; LastYearCaptionLbl)
            {
            }
            column(IndexSaleCaption; IndexSaleCaptionLbl)
            {
            }
            column(IndexProfitCaption; IndexProfitCaptionLbl)
            {
            }
            column(ThisYearCaption; ThisYearCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(SaleTotalCaption; SaleTotalCaptionLbl)
            {
            }
            column(SharePctCaption; SharePctCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(Greyed; Greyed)
            {
            }
            column(CustSalesDKK; CustSalesDKK)
            {
            }
            column(SalesPct; SalesPct)
            {
            }
            column(CustBalanceDKK; CustBalanceDKK)
            {
            }
            column(DebSaldoDKKFooter; DebSaldoDKKFooter)
            {
            }
            column(BalancePct; BalancePct)
            {
            }
            column(CustProfitDKK; CustProfitDKK)
            {
            }
            column(AvancePct; AvancePct)
            {
            }
            column(CustSalesDKK1; CustSalesDKK1)
            {
            }
            column(Debitor1_Sales_LCY_; Customer1."Sales (LCY)")
            {
            }
            column(SalesPct1; SalesPct1)
            {
            }
            column(CustProfitDKK1; CustProfitDKK1)
            {
            }
            column(Debitor1_Profit_LCY_; Customer1."Profit (LCY)")
            {
            }
            column(AvancePct1; AvancePct1)
            {
            }
            column(IndexSales_1_; IndexSales[1])
            {
            }
            column(IndexSales_2_; IndexSales[2])
            {
            }
            column(IndexDB_1_; IndexDB[1])
            {
            }
            column(IndexDB_2_; IndexDB[2])
            {
            }
            column(TotalPct; TotalPct)
            {
            }
            column(Customer1SalesTotal; Customer1SalesTotal)
            {
            }
            column(Customer1ProfitTotal; Customer1ProfitTotal)
            {
            }
            column(Customer1BalanceTotal; Customer1BalanceTotal)
            {
            }

            trigger OnAfterGetRecord()
            begin
                Counter += 1;
                if (Counter / 2) = Round((Counter / 2), 1) then
                    Greyed := false
                else
                    Greyed := true;

                if Number = 1 then begin
                    if not CustomerAmountTemp.FindFirst then
                        CurrReport.Break;
                end else
                    if CustomerAmountTemp.Next = 0 then
                        CurrReport.Break;

                CustomerAmountTemp."Amount (LCY)" := Multipl * CustomerAmountTemp."Amount (LCY)";

                Customer.Get(CustomerAmountTemp."Customer No.");
                Customer.CalcFields("Sales (LCY)", "Balance (LCY)", "Profit (LCY)");

                //-NPR70.00.00.00/LS/190514
                //Added Because createtotals no more supported
                CustSalesDKK += Customer."Sales (LCY)";
                CustBalanceDKK += Customer."Balance (LCY)";
                CustProfitDKK += Customer."Profit (LCY)";

                DebSaldoDKKFooter += CustBalanceDKK;
                //+NPR70.00.00.00/LS/190514

                AvancePct := "Pct."(Customer."Profit (LCY)", Customer."Sales (LCY)");

                if (Sorting = Sorting::Minimum) and (Number = 1) then begin
                    CustomerAmountTemp := CustomerAmountTemp;
                    CustomerAmountTemp.Next(+ShowQty);
                    MaxAmount := CustomerAmountTemp."Amount (LCY)";
                    CustomerAmountTemp := CustomerAmountTemp;
                end else begin
                    if Number = 1 then
                        MaxAmount := CustomerAmountTemp."Amount (LCY)";
                end;

                CustomerAmountTemp2.SetRange("Customer No.", Customer."No.");
                if CustomerAmountTemp2.FindFirst then
                    LastLocation := CustomerAmountTemp2."NPR Location"
                else begin
                    CustomerAmountTemp2."Amount (LCY)" := 0;
                    CustomerAmountTemp2."Amount 2 (LCY)" := 0;
                    LastLocation := 0;
                end;

                CustVarAmt := Multipl * CustomerAmountTemp2."Amount (LCY)";
                if (CustVarAmt = 0) then
                    Clear(LastLocation);

                case ShowType of
                    ShowType::Sales:
                        begin
                            TotalPct := "Pct."(Customer."Sales (LCY)", CustSalesDKK);
                            Index := "Pct."(Customer."Sales (LCY)", -CustomerAmountTemp2."Amount (LCY)");
                        end;
                    ShowType::Balance:
                        begin
                            TotalPct := "Pct."(Customer."Balance (LCY)", CustBalanceDKK);
                            Index := "Pct."(Customer."Balance (LCY)", -CustomerAmountTemp2."Amount (LCY)");
                        end;
                    ShowType::Margin:
                        begin
                            TotalPct := "Pct."(Customer."Profit (LCY)", CustProfitDKK);
                            Index := "Pct."(Customer."Profit (LCY)", -CustomerAmountTemp2."Amount (LCY)");
                        end;
                end;

                Share := "Pct."(CustomerAmountTemp."Amount (LCY)", MaxAmount);
                CustomerAmountTemp."Amount (LCY)" := Multipl * CustomerAmountTemp."Amount (LCY)";
            end;

            trigger OnPreDataItem()
            begin
                Window.Close;
                //-NPR5.39
                //CurrReport.CREATETOTALS(Customer."Sales (LCY)",Customer."Balance (LCY)",Customer."Profit (LCY)");
                //+NPR5.39
                //-NPR5.49 [341969]
                //CustomerAmountTemp2.SETCURRENTKEY("Customer No.");
                //+NPR5.49 [341969]
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
                    field(ShowType; ShowType)
                    {
                        Caption = 'Show Type';
                        OptionCaption = 'Sales,Balance,Margin';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Type field';
                    }
                    field("Sorting"; Sorting)
                    {
                        Caption = 'Sort By';
                        OptionCaption = 'Largest,Smallest';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sort By field';
                    }
                    field(ShowQty; ShowQty)
                    {
                        Caption = 'Quantity';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Quantity field';
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
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);

        //-NPR5.39
        // Object.SETRANGE(ID, 6014432);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39
        ShowQty := 10;
    end;

    trigger OnPreReport()
    begin
        CustomerFilter := Customer.GetFilters;
        CustomerDateFilter := Customer.GetFilter("Date Filter");
    end;

    var
        Window: Dialog;
        CompanyInfo: Record "Company Information";
        CustomerAmountTemp: Record "Customer Amount" temporary;
        CustomerAmountTemp2: Record "Customer Amount" temporary;
        Customer1: Record Customer;
        DebCount: Integer;
        CustomerCount: Integer;
        CustomerFilter: Text[250];
        CustomerDateFilter: Text[30];
        ShowType: Option Sales,Balance,Margin;
        Sorting: Option Maximum,Minimum;
        ShowQty: Integer;
        CustSalesDKK: Decimal;
        CustBalanceDKK: Decimal;
        CustProfitDKK: Decimal;
        CustSalesDKK1: Decimal;
        CustBalanceDKK1: Decimal;
        CustProfitDKK1: Decimal;
        MaxAmount: Decimal;
        Share: Decimal;
        i: Integer;
        Multipl: Integer;
        TotalPct: Decimal;
        Index: Decimal;
        Counter: Integer;
        Greyed: Boolean;
        MinDate: Date;
        MaxDate: Date;
        LastLocation: Integer;
        SalesPct1: Decimal;
        AvancePct1: Decimal;
        AvancePct: Decimal;
        BalancePct: Decimal;
        SalesPct: Decimal;
        IndexSales: array[2] of Decimal;
        IndexDB: array[2] of Decimal;
        CustVarAmt: Decimal;
        Text10600000: Label 'Customers Sorted: #1#########\';
        Text10600001: Label 'Creating Comparison...\';
        Text10600002: Label 'Sorting Data...\';
        Text10600003: Label 'Period: %1';
        Text10600004: Label 'Sequence after %1 top %2';
        Text10600005: Label 'Last Year %1';
        Report_Caption_Lbl: Label 'Customer Analysis';
        SequenceCaption_Lbl: Label 'Sequence';
        NoCaptionLbl: Label 'No.';
        NameCaptionLbl: Label 'Name';
        SaleCaptionLbl: Label 'Sale';
        BalanceCaptionLbl: Label 'Balance';
        ProfitCaptionLbl: Label 'Profit (LCY)';
        ProfitPctCaptionLbl: Label 'Profit %';
        LargestPctCaptionLbl: Label '% of Largest';
        ShareTotalCaptionLbl: Label 'Share of Total';
        PlacingLastYrCaptionLbl: Label 'Placing Last Year';
        IndexCaptionLbl: Label 'Index';
        LastYearCaptionLbl: Label 'Last Year';
        IndexSaleCaptionLbl: Label 'Index Sale';
        IndexProfitCaptionLbl: Label 'Index Profit (LCY)';
        ThisYearCaptionLbl: Label 'This Year';
        TotalCaptionLbl: Label 'Total';
        SaleTotalCaptionLbl: Label 'Sale Total';
        SharePctCaptionLbl: Label 'Share %';
        PageCaptionLbl: Label 'Page';
        Customer1SalesTotal: Decimal;
        Customer1ProfitTotal: Decimal;
        Customer1BalanceTotal: Decimal;
        CustomerSalesTotal: Decimal;
        CustomerProfitTotal: Decimal;
        CustomerBalanceTotal: Decimal;
        DebSaldoDKKFooter: Decimal;

    local procedure "Pct."(Tal1: Decimal; Tal2: Decimal): Decimal
    begin
        if Tal2 = 0 then
            exit(0);
        exit(Round(Tal1 / Tal2 * 100, 0.1));
    end;
}

