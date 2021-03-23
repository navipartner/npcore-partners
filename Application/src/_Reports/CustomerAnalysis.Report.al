report 6014432 "NPR Customer Analysis"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Customer Analysis.rdlc';
    Caption = 'Customer Analysis';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
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
                    CurrReport.Skip();
                CustomerAmountTemp.Init();
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

                CustomerAmountTemp.Insert();
                if (ShowQty = 0) or (i < ShowQty) then
                    i := i + 1
                else begin
                    CustomerAmountTemp.FindLast();
                    CustomerAmountTemp.Delete();
                end;

                CustomerSalesTotal += "Sales (LCY)";
                CustomerProfitTotal += "Profit (LCY)";
                CustomerBalanceTotal += "Balance (LCY)";
            end;

            trigger OnPreDataItem()
            begin
                Window.Open(CustSortedLbl +
                            '@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\' +
                            CreatingComparisonLbl +
                            '@4@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\' +
                            SortingDataLbl +
                            '@5@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');

                DebCount := Customer.Count();
                i := 0;
                CustomerAmountTemp.DeleteAll();
            end;
        }
        dataitem(Integer1; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not Customer1.FindFirst() then
                        CurrReport.Break();
                end else
                    if Customer1.Next() = 0 then
                        CurrReport.Break();
                CustomerCount += 1;
                Window.Update(4, (100 * Round(CustomerCount * 100 / DebCount, 1)));
                Customer1.CalcFields("Sales (LCY)", "Balance (LCY)", "Profit (LCY)");

                if (Customer1."Sales (LCY)" = 0) and (Customer1."Balance (LCY)" = 0) and (Customer1."Profit (LCY)" = 0) then
                    CurrReport.Skip();
                CustomerAmountTemp2.Init();
                CustomerAmountTemp2."Customer No." := Customer1."No.";
                TempCustomerBuffer.Init();
                TempCustomerBuffer."No." := Customer1."No.";

                if Sorting = Sorting::Maximum then
                    Multipl := -1
                else
                    Multipl := 1;

                case ShowType of
                    ShowType::Sales:
                        begin
                            CustomerAmountTemp2."Amount (LCY)" := Multipl * Customer1."Sales (LCY)";
                            CustomerAmountTemp2."Amount 2 (LCY)" := Multipl * Customer1."Balance (LCY)";
                            TempCustomerBuffer.Amount := Multipl * Customer1."Profit (LCY)";
                        end;
                    ShowType::Balance:
                        begin
                            CustomerAmountTemp2."Amount (LCY)" := Multipl * Customer1."Balance (LCY)";
                            CustomerAmountTemp2."Amount 2 (LCY)" := Multipl * Customer1."Sales (LCY)";
                            TempCustomerBuffer.Amount := Multipl * Customer1."Profit (LCY)";
                        end;
                    ShowType::Margin:
                        begin
                            CustomerAmountTemp2."Amount (LCY)" := Multipl * Customer1."Profit (LCY)";
                            CustomerAmountTemp2."Amount 2 (LCY)" := Multipl * Customer1."Sales (LCY)";
                            TempCustomerBuffer.Amount := Multipl * Customer1."Balance (LCY)";
                        end;
                end;
                CustomerAmountTemp2.Insert();
                TempCustomerBuffer.Insert();

                i += 1;

                Customer1SalesTotal += Customer1."Sales (LCY)";
                Customer1ProfitTotal += Customer1."Profit (LCY)";
                Customer1BalanceTotal += Customer1."Balance (LCY)";
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
            end;
        }
        dataitem(IntegerSorting; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = FILTER(1 ..));

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not CustomerAmountTemp2.FindFirst() then
                        CurrReport.Break();
                end else
                    if CustomerAmountTemp2.Next() = 0 then begin
                        CurrReport.Break();
                    end;

                TempCustomerBuffer.Get(CustomerAmountTemp2."Customer No.");

                if Number <= ShowQty then
                    case ShowType of
                        ShowType::Sales:
                            begin
                                CustSalesDKK1 += -CustomerAmountTemp2."Amount (LCY)";
                                CustBalanceDKK1 += -CustomerAmountTemp2."Amount 2 (LCY)";
                                CustProfitDKK1 += -TempCustomerBuffer.Amount;
                            end;
                        ShowType::Balance:
                            begin
                                CustSalesDKK1 += -CustomerAmountTemp2."Amount 2 (LCY)";
                                CustBalanceDKK1 += -CustomerAmountTemp2."Amount (LCY)";
                                CustProfitDKK1 += -TempCustomerBuffer.Amount;
                            end;
                        ShowType::Margin:
                            begin
                                CustSalesDKK1 += -CustomerAmountTemp2."Amount 2 (LCY)";
                                CustBalanceDKK1 += -TempCustomerBuffer.Amount;
                                CustProfitDKK1 += -CustomerAmountTemp2."Amount (LCY)";
                            end;
                    end;

                TempCustomerBuffer."Last Statement No." := Number;
                TempCustomerBuffer.Modify();
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
            column(PeriodFilter; StrSubstNo(CustDateLbl, CustomerDateFilter))
            {
            }
            column(SequenceFilter; StrSubstNo(SequenceLbl, ShowType, ShowQty))
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
            column(DebVarBelCaption; StrSubstNo(LastYearLbl, ShowType))
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
                    if not CustomerAmountTemp.FindFirst() then
                        CurrReport.Break();
                end else
                    if CustomerAmountTemp.Next() = 0 then
                        CurrReport.Break();

                CustomerAmountTemp."Amount (LCY)" := Multipl * CustomerAmountTemp."Amount (LCY)";

                Customer.Get(CustomerAmountTemp."Customer No.");
                Customer.CalcFields("Sales (LCY)", "Balance (LCY)", "Profit (LCY)");

                //Added Because createtotals no more supported
                CustSalesDKK += Customer."Sales (LCY)";
                CustBalanceDKK += Customer."Balance (LCY)";
                CustProfitDKK += Customer."Profit (LCY)";

                DebSaldoDKKFooter += CustBalanceDKK;
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
                if CustomerAmountTemp2.FindFirst() then begin
                    TempCustomerBuffer.Get(CustomerAmountTemp2."Customer No.");
                    LastLocation := TempCustomerBuffer."Last Statement No.";
                end else begin
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
                Window.Close();
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

    }


    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
        ShowQty := 10;
    end;

    trigger OnPreReport()
    begin
        CustomerFilter := Customer.GetFilters;
        CustomerDateFilter := Customer.GetFilter("Date Filter");
    end;

    var
        CompanyInfo: Record "Company Information";
        Customer1: Record Customer;
        CustomerAmountTemp: Record "Customer Amount" temporary;
        CustomerAmountTemp2: Record "Customer Amount" temporary;
        TempCustomerBuffer: Record Customer temporary;
        Greyed: Boolean;
        MaxDate: Date;
        MinDate: Date;
        AvancePct: Decimal;
        AvancePct1: Decimal;
        BalancePct: Decimal;
        CustBalanceDKK: Decimal;
        CustBalanceDKK1: Decimal;
        Customer1BalanceTotal: Decimal;
        Customer1ProfitTotal: Decimal;
        Customer1SalesTotal: Decimal;
        CustomerBalanceTotal: Decimal;
        CustomerProfitTotal: Decimal;
        CustomerSalesTotal: Decimal;
        CustProfitDKK: Decimal;
        CustProfitDKK1: Decimal;
        CustSalesDKK: Decimal;
        CustSalesDKK1: Decimal;
        CustVarAmt: Decimal;
        DebSaldoDKKFooter: Decimal;
        Index: Decimal;
        IndexDB: array[2] of Decimal;
        IndexSales: array[2] of Decimal;
        MaxAmount: Decimal;
        SalesPct: Decimal;
        SalesPct1: Decimal;
        Share: Decimal;
        TotalPct: Decimal;
        Window: Dialog;
        Counter: Integer;
        CustomerCount: Integer;
        DebCount: Integer;
        i: Integer;
        LastLocation: Integer;
        Multipl: Integer;
        ShowQty: Integer;
        LargestPctCaptionLbl: Label '% of Largest';
        BalanceCaptionLbl: Label 'Balance';
        CreatingComparisonLbl: Label 'Creating Comparison...\';
        Report_Caption_Lbl: Label 'Customer Analysis';
        CustSortedLbl: Label 'Customers Sorted: #1#########\';
        IndexCaptionLbl: Label 'Index';
        IndexProfitCaptionLbl: Label 'Index Profit (LCY)';
        IndexSaleCaptionLbl: Label 'Index Sale';
        LastYearCaptionLbl: Label 'Last Year';
        LastYearLbl: Label 'Last Year %1', Comment = '%1 = Last Year';
        NameCaptionLbl: Label 'Name';
        NoCaptionLbl: Label 'No.';
        PageCaptionLbl: Label 'Page';
        CustDateLbl: Label 'Period: %1', Comment = '%1 = Customer Date filter';
        PlacingLastYrCaptionLbl: Label 'Placing Last Year';
        ProfitPctCaptionLbl: Label 'Profit %';
        ProfitCaptionLbl: Label 'Profit (LCY)';
        SaleCaptionLbl: Label 'Sale';
        SaleTotalCaptionLbl: Label 'Sale Total';
        SequenceCaption_Lbl: Label 'Sequence';
        SequenceLbl: Label 'Sequence after %1 top %2', Comment = '%1 = Show Type, %2 = Show Quantity';
        SharePctCaptionLbl: Label 'Share %';
        ShareTotalCaptionLbl: Label 'Share of Total';
        SortingDataLbl: Label 'Sorting Data...\';
        ThisYearCaptionLbl: Label 'This Year';
        TotalCaptionLbl: Label 'Total';
        Sorting: Option Maximum,Minimum;
        ShowType: Option Sales,Balance,Margin;
        CustomerDateFilter: Text[30];
        CustomerFilter: Text[250];

    local procedure "Pct."(Tal1: Decimal; Tal2: Decimal): Decimal
    begin
        if Tal2 = 0 then
            exit(0);
        exit(Round(Tal1 / Tal2 * 100, 0.1));
    end;
}

