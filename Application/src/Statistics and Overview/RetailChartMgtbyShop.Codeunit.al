codeunit 6059812 "NPR Retail Chart Mgt by Shop"
{
    var
        Text000: Label 'Margin';
        Text001: Label 'Turnover';
        Text002: Label 'Store';

    procedure TurnOver_RevenuebyDim1(var BusChartBuf: Record "Business Chart Buffer"; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; var StartDate: Date; var Enddate: Date; ChangedChartType: Boolean)
    var
        Query1: Query "NPR Retail Sales by Dim. 1";
        I: Integer;
    begin
        if Period = Period::" " then begin
            Enddate := Today();
            BusChartBuf."Period Length" := PeriodType;
        end;
        if not ChangedChartType then
            Setdate(StartDate, Enddate, Period, PeriodType, BusChartBuf);
        BusChartBuf.Initialize();
        BusChartBuf.AddMeasure(Text000, 2, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
        BusChartBuf.AddMeasure(Text001, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
        BusChartBuf.SetXAxis(Text002, BusChartBuf."Data Type"::String);

        Query1.SetRange(Posting_Date, StartDate, Enddate);
        Query1.Open();
        while Query1.Read() do begin
            I += 1;
            BusChartBuf.AddColumn(Query1.Global_Dimension_1_Code);
            BusChartBuf.SetValue(Text000, I - 1, Query1.Sum_Sales_Amount_Actual + Query1.Sum_Cost_Amount_Actual);
            BusChartBuf.SetValue(Text001, I - 1, Query1.Sum_Sales_Amount_Actual);
        end;
        Query1.Close();
    end;

    procedure TurnOver_RevenuebyDim2(var BusChartBuf: Record "Business Chart Buffer"; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; var StartDate: Date; var Enddate: Date; ChangedChartType: Boolean)
    var
        Query1: Query "NPR Retail Sales by Dim. 2";
        I: Integer;
    begin
        if Period = Period::" " then begin
            Enddate := Today();
            BusChartBuf."Period Length" := PeriodType;
        end;
        if not ChangedChartType then
            Setdate(StartDate, Enddate, Period, PeriodType, BusChartBuf);
        BusChartBuf.Initialize();
        BusChartBuf.AddMeasure(Text000, 2, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
        BusChartBuf.AddMeasure(Text001, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
        BusChartBuf.SetXAxis(Text002, BusChartBuf."Data Type"::String);

        Query1.SetRange(Posting_Date, StartDate, Enddate);
        Query1.Open();
        while Query1.Read() do begin
            I += 1;
            BusChartBuf.AddColumn(Query1.Global_Dimension_2_Code);
            BusChartBuf.SetValue(Text000, I - 1, Query1.Sum_Sales_Amount_Actual + Query1.Sum_Cost_Amount_Actual);
            BusChartBuf.SetValue(Text001, I - 1, Query1.Sum_Sales_Amount_Actual);
        end;
        Query1.Close();
    end;

    local procedure Setdate(var StartDate: Date; var Enddate: Date; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; var BusChartBuf: Record "Business Chart Buffer")
    var
        Date: Record Date;
    begin
        case Period of
            Period::Next:
                Enddate := CalcDate(StrSubstNo('<C%1+1%1>', BusChartBuf.GetPeriodLength()), Enddate);
            Period::Previous:
                Enddate := CalcDate(StrSubstNo('<C%1-1%1>', BusChartBuf.GetPeriodLength()), Enddate);
        end;

        Enddate := CalcDate(StrSubstNo('<C%1>', BusChartBuf.GetPeriodLength()), Enddate);
        if Enddate > Today then
            Enddate := Today();

        Date.SetRange("Period Type", PeriodType);
        Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<-%1%2>', 'C', BusChartBuf.GetPeriodLength()), Enddate));
        if Date.FindFirst() then
            StartDate := Date."Period Start";
    end;
}

