report 6014429 "NPR Sales per month year"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales per month yearLast year.rdlc';
    Caption = 'Sales Per Month Current Year/Last Year';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    UseSystemPrinter = true;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number);
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Report_Caption; Report_Caption_Lbl)
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
            var
                SalesLCY: Decimal;
            begin
                if CurrentDate = EndDate then
                    CurrReport.Break();

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
                        SalesPersonPurchaser.NPRGetVESalesLCY(SalesLCY);
                        SalesAllPersons := SalesAllPersons + SalesLCY;
                    until SalesPersonPurchaser.Next() = 0;
                end;
                WeekTotal := WeekTotal + SalesAllPersons;
                MonthTotal := MonthTotal + SalesAllPersons;

                if (SalesAllPersons = 0) and (ShowEmptyLines = false) then
                    CurrReport.Skip();

                // Month last year
                LastWeekText := '';
                if not DateComparison then begin
                    LastWeekText := 'Uge ' + Format(CurrentDateLastYear, 0, '<Week>');
                end;

                SalesPersonPurchaser.SetRange("Date Filter", CurrentDateLastYear);
                if SalesPersonPurchaser.Find('-') then begin
                    SalesAllPersonsLastYear := 0;
                    repeat
                        SalesPersonPurchaser.NPRGetVESalesLCY(SalesLCY);
                        SalesAllPersonsLastYear := SalesAllPersonsLastYear + SalesLCY;
                    until SalesPersonPurchaser.Next() = 0;
                end;


                WeekTotalLastYear := WeekTotalLastYear + SalesAllPersonsLastYear;
                MonthTotalLastYear := MonthTotalLastYear + SalesAllPersonsLastYear;

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
        SaveValues = true;
        Caption = 'Date Comparisson';

        layout
        {
            area(content)
            {
                group(Options)
                {
                    field("Month."; Month)
                    {
                        Caption = 'Month';

                        ToolTip = 'Specifies the value of the Month field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Year."; Year)
                    {
                        Caption = 'Year';

                        ToolTip = 'Specifies the value of the Year field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Department; "Dimension Value".Code)
                    {
                        Caption = 'Department';
                        TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

                        ToolTip = 'Specifies the value of the Department field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Date Comparison"; DateComparison)
                    {
                        Caption = 'Date Comparison';

                        ToolTip = 'Specifies the value of the Date Comparison field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            if DateComparison then
                                Nearest := false;
                        end;
                    }
                    field("Near est"; Nearest)
                    {
                        Caption = 'Compare To Closest Week';

                        ToolTip = 'Specifies the value of the Compare To Closest Week field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            if Nearest then
                                DateComparison := false;
                        end;
                    }
                    field("Show Empty Lines"; ShowEmptyLines)
                    {
                        Caption = 'Show Empty Lines';
                        ToolTip = 'Specifies the value of the Show Empty Lines field.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

    }

    labels
    {
        Period_LY_Caption = 'Month Last Year';
        Period_Sales_CaptionLY = 'Sales for Last Year Month';
        Period_Sales_CaptionCM = 'Sales for Current Year Month';
        Period_Caption = 'Month Current Year';
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
    end;

    trigger OnPreReport()
    begin
        firmaoplysninger.Get();
        firmaoplysninger.CalcFields(Picture);

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

        CurrentDateLastYear := StartDateLastYear;
    end;

    var
        firmaoplysninger: Record "Company Information";
        "Dimension Value": Record "Dimension Value";
        SalesPersonPurchaser: Record "Salesperson/Purchaser";
        DateComparison: Boolean;
        FirstRun: Boolean;
        IsDisplay: Boolean;
        Nearest: Boolean;
        CurrentDate: Date;
        CurrentDateLastYear: Date;
        EndDate: Date;
        StartDate: Date;
        StartDateLastYear: Date;
        GrandTotal: Decimal;
        Index: Decimal;
        MonthTotal: Decimal;
        MonthTotalLastYear: Decimal;
        SalesAllPersons: Decimal;
        SalesAllPersonsLastYear: Decimal;
        TotalOutput: Decimal;
        TotalOutputLastYear: Decimal;
        WeekTotal: Decimal;
        WeekTotalLastYear: Decimal;
        Month: Integer;
        Year: Integer;
        text3: Label '(Prices not included tax)';
        text5: Label 'Selected Department: %1';
        text4: Label 'Selected month/year: %1/%2';
        text1: Label 'Time Report';
        text2: Label 'Time report';
        text6: Label 'Week %1';
        LastWeekText: Text[50];
        Title: Text[50];
        Report_Caption_Lbl: Label 'Sales Per Month Current Year/Last Year';
        ShowEmptyLines: Boolean;
}

