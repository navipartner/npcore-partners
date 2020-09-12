report 6014456 "NPR Sales per week year/Last"
{
    // NPR70.00.00.00/LS/280613  CASE 176191 : Convert Report 6014456 to Nav 2013
    //                                         +
    //                                         Changed Danish Variables/codes to English + Proper indentation
    // NPR4.14/TR/20150807 CASE 220169 Report captions and layout alignment corrected.
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on obsolite property CurrReport_PAGENO
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales per week yearLast year.rdlc';

    Caption = 'Sales Per Week Year/Last Year';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    UseSystemPrinter = true;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number);
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Title; Title)
            {
            }
            column(text3; text3)
            {
            }
            column(Valgt_Date_Integer; StrSubstNo(text4, Format(Month), Format(Year)))
            {
            }
            column(Valgt_Dim_Integer; StrSubstNo(text5, Format("Dimension Value".Code)))
            {
            }
            column(Number_Integer; Integer.Number)
            {
            }
            column(LastWeekText_Integer; LastWeekText)
            {
            }
            column(Week_Integer; StrSubstNo(text6, Format(CurrentDate, 0, '<Week>')))
            {
            }
            column(Curr_Date_LY_WD_Integer; Format(CurrentDateLastYear, 0, '<Weekday Text>'))
            {
            }
            column(Curr_Date_LY_Month_Integer; Format(CurrentDateLastYear, 0, '<DAY>. <MONTH text> <YEAR4>'))
            {
            }
            column(Sales_LY_Integer; SalesAllPersonsLastYear)
            {
            }
            column(TotalOutput_LY_Integer; TotalOutputLastYear)
            {
            }
            column(Curr_Date_WD_Integer; Format(CurrentDate, 0, '<Weekday Text>'))
            {
            }
            column(Curr_Date_Month_Integer; Format(CurrentDate, 0, '<DAY>. <MONTH text> <YEAR4>'))
            {
            }
            column(Sales_Integer; SalesAllPersons)
            {
            }
            column(TotalOutput_Integer; TotalOutput)
            {
            }
            column(Index_Integer; Index)
            {
            }
            column(MonthTotal_LY_Integer; MonthTotalLastYear)
            {
            }
            column(MonthTotal_Integer; MonthTotal)
            {
            }
            column(IsDisplay; IsDisplay)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if CurrentDate = EndDate then
                    CurrReport.Break;

                if FirstRun then
                    FirstRun := false
                else begin
                    CurrentDate := CalcDate('<1D>', CurrentDate);
                    CurrentDateLastYear := CalcDate('<1D>', CurrentDateLastYear);
                end;

                // Month this year
                SalesPersonPurchaser.SetRange("Date Filter", CurrentDate);
                if SalesPersonPurchaser.Find('-') then begin
                    SalesAllPersons := 0;
                    repeat
                        SalesPersonPurchaser.CalcFields("NPR Sales (LCY)");
                        SalesAllPersons := SalesAllPersons + SalesPersonPurchaser."NPR Sales (LCY)";
                    until SalesPersonPurchaser.Next = 0;
                end;

                SalesAllPersons := SalesAllPersons * Multiplier;
                WeekTotal := WeekTotal + SalesAllPersons;
                MonthTotal := MonthTotal + SalesAllPersons;

                // Month last year
                LastWeekText := '';
                if not DateComparison then begin
                    LastWeekText := 'Uge ' + Format(CurrentDateLastYear, 0, '<Week>');
                end;

                SalesPersonPurchaser.SetRange("Date Filter", CurrentDateLastYear);
                if SalesPersonPurchaser.Find('-') then begin
                    SalesAllPersonsLastYear := 0;
                    repeat
                        SalesPersonPurchaser.CalcFields("NPR Sales (LCY)");
                        SalesAllPersonsLastYear := SalesAllPersonsLastYear + SalesPersonPurchaser."NPR Sales (LCY)";
                    until SalesPersonPurchaser.Next = 0;
                end;
                SalesAllPersonsLastYear := SalesAllPersonsLastYear * Multiplier;

                WeekTotalLastYear := WeekTotalLastYear + SalesAllPersonsLastYear;
                MonthTotalLastYear := MonthTotalLastYear + SalesAllPersonsLastYear;


                //-NPR70.00.00.00/LS/280613
                IsDisplay := false;
                if (Format(CurrentDate, 0, '<Weekday Text>') = 'mandag') or (CurrentDate = StartDate) then
                    IsDisplay := true
                else
                    IsDisplay := false;

                if (Format(CurrentDate, 0, '<Weekday Text>') = 's¢ndag') or ((CurrentDate = EndDate)) then begin
                    TotalOutput := WeekTotal;
                    WeekTotal := 0;
                    TotalOutputLastYear := WeekTotalLastYear;
                    WeekTotalLastYear := 0;
                    if ((TotalOutputLastYear <> 0) and (TotalOutput <> 0)) then
                        Index := (TotalOutput - TotalOutputLastYear) / TotalOutputLastYear * 100
                    else
                        Index := 0;
                end
                else begin
                    TotalOutput := 0;
                    TotalOutputLastYear := 0;
                    if ((SalesAllPersonsLastYear <> 0) and (SalesAllPersons <> 0)) then
                        Index := (SalesAllPersons - SalesAllPersonsLastYear) / SalesAllPersonsLastYear * 100
                    else
                        Index := 0;
                end;

                GrandTotal += TotalOutput;
                //+NPR70.00.00.00/LS/280613
            end;

            trigger OnPreDataItem()
            begin
                if "Dimension Value".Code <> '' then
                    SalesPersonPurchaser.SetRange("NPR Global Dimension 1 Filter", "Dimension Value".Code);
            end;
        }
        dataitem(Totals; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            MaxIteration = 2;
            column(Number_Totals; Totals.Number)
            {
            }
            column(GrandTotal_Totals; GrandTotal)
            {
            }
            column(MonthTotalLastYear_Totals; MonthTotalLastYear)
            {
            }
        }
    }

    requestpage
    {
        Caption = 'Date Comparisson';

        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(Month; Month)
                    {
                        Caption = 'Month';
                        ApplicationArea = All;
                    }
                    field(Year; Year)
                    {
                        Caption = 'Year';
                        ApplicationArea = All;
                    }
                    field(Department; "Dimension Value".Code)
                    {
                        Caption = 'Department';
                        TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
                        ApplicationArea = All;
                    }
                    field(DateComparison; DateComparison)
                    {
                        Caption = 'Date Comparison';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if DateComparison then
                                Nearest := false;
                        end;
                    }
                    field(Nearest; Nearest)
                    {
                        Caption = 'Compare To Closest Week';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if Nearest then
                                DateComparison := false;
                        end;
                    }
                    field(Multiplier; Multiplier)
                    {
                        Caption = 'Multiply With';
                        ApplicationArea = All;
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
        Period_LY_Caption = 'Period Last Year';
        Period_Sales_Caption = 'Sales for Period';
        Period_Caption = 'Period';
        Increase_Caption = 'Increase In %';
        Month_Total = 'Month Total';
        Page_Caption = 'Page';
    }

    trigger OnInitReport()
    begin
        Month := Date2DMY(Today, 2);
        Year := Date2DWY(Today, 3);
        FirstRun := true;
        MonthTotal := 0;
        DateComparison := true;
        Multiplier := 1.25;
    end;

    trigger OnPreReport()
    begin
        firmaoplysninger.Get();
        firmaoplysninger.CalcFields(Picture);
        //-NPR5.39
        // objectTxt := CurrReport.OBJECTID(FALSE);
        // objectTxt := COPYSTR(objectTxt,7);
        // IF EVALUATE(objectInt,objectTxt) THEN;
        // Object.SETFILTER(Type,'Report');
        // Object.SETFILTER(ID,FORMAT(objectInt));
        // IF Object.FINDFIRST THEN ;
        //+NPR5.39

        StartDate := DMY2Date(1, Month, Year);
        EndDate := CalcDate('<-1D>', CalcDate('<1M>', StartDate));
        CurrentDate := StartDate;


        if DateComparison then begin
            StartDateLastYear := CalcDate('<-1Y>', StartDate);
            Title := text2;
        end else begin
            if (Date2DWY(StartDate, 2) = 53) then
                StartDateLastYear := DWY2Date(Date2DWY(StartDate, 1), Date2DWY(StartDate, 2) - 1, Date2DWY(StartDate, 3) - 1)
            else
                StartDateLastYear := DWY2Date(Date2DWY(StartDate, 1), Date2DWY(StartDate, 2), Date2DWY(StartDate, 3) - 1);

            if Nearest then begin
                if Abs((StartDate - CalcDate('<1Y>', StartDateLastYear))) > 3 then
                    StartDateLastYear := CalcDate('<7D>', StartDateLastYear);
            end;
            Title := text1;
        end;

        EndDateLastYear := CalcDate('<1M>', StartDateLastYear);
        CurrentDateLastYear := StartDateLastYear;
    end;

    var
        SalesPersonPurchaser: Record "Salesperson/Purchaser";
        Month: Integer;
        Year: Integer;
        StartDate: Date;
        EndDate: Date;
        CurrentDate: Date;
        StartDateLastYear: Date;
        EndDateLastYear: Date;
        CurrentDateLastYear: Date;
        FirstRun: Boolean;
        MonthTotal: Decimal;
        WeekTotal: Decimal;
        MonthTotalLastYear: Decimal;
        WeekTotalLastYear: Decimal;
        TotalOutput: Decimal;
        TotalOutputLastYear: Decimal;
        SalesAllPersons: Decimal;
        SalesAllPersonsLastYear: Decimal;
        firmaoplysninger: Record "Company Information";
        Index: Decimal;
        "Dimension Value": Record "Dimension Value";
        DateComparison: Boolean;
        Title: Text[50];
        Nearest: Boolean;
        Multiplier: Decimal;
        LastWeekText: Text[50];
        text1: Label 'Time Report';
        text2: Label 'Time report';
        text3: Label '(Prices not included tax)';
        IsDisplay: Boolean;
        GrandTotal: Decimal;
        text4: Label 'Selected month/year: %1/%2';
        text5: Label 'Selected Department: %1';
        text6: Label 'Week %1';
}

