codeunit 6059811 "NPR Retail Chart Mgt."
{
    var
        MarginLbl: Label 'Margin';
        TurnoverLbl: Label 'Turnover';

    procedure TurnOver_Revenue(var BusChartBuf: Record "Business Chart Buffer"; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period)
    var
        Query1: Query "NPR Retail Sales Value Entry";
        I: Integer;
        StartDate: Date;
        Enddate: Date;
        TotNoOfPeriod: Integer;
    begin
        if Period = Period::" " then begin
            Enddate := Today();
            BusChartBuf."Period Length" := PeriodType;
        end;

        Setdate(StartDate, Enddate, Period, PeriodType, BusChartBuf);
        BusChartBuf.InitializePeriodFilter(StartDate, Enddate);

        BusChartBuf.Initialize();
#if BC17        
        BusChartBuf.AddMeasure(MarginLbl, 2, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
        BusChartBuf.AddMeasure(TurnoverLbl, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
#else
        BusChartBuf.AddMeasure(MarginLbl, 2, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column.AsInteger());
        BusChartBuf.AddMeasure(TurnoverLbl, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column.AsInteger());
#endif
        BusChartBuf."Period Length" := PeriodType;
        BusChartBuf.SetPeriodXAxis();
        BusChartBuf.AddPeriods(StartDate, Enddate);
        TotNoOfPeriod := BusChartBuf.CalcNumberOfPeriods(StartDate, Enddate);

        for I := 1 to TotNoOfPeriod do begin
            BusChartBuf.GetPeriodFromMapColumn(I - 1, StartDate, Enddate);
            Query1.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
            Query1.Open();
            Query1.Read();
            BusChartBuf.SetValue(MarginLbl, I - 1, Query1.Sum_Sales_Amount_Actual + Query1.Sum_Cost_Amount_Actual);
            BusChartBuf.SetValue(TurnoverLbl, I - 1, Query1.Sum_Sales_Amount_Actual);
            Query1.Close();
        end;
    end;

    local procedure Setdate(var StartDate: Date; var Enddate: Date; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; var BusChartBuf: Record "Business Chart Buffer")
    var
        Date: Record Date;
        NextLbl: Label '<C%1+7%1>', Locked = true;
        PreviousLbl: Label '<C%1-7%1>', Locked = true;
        UntilLbl: Label '<-%1%2>', Locked = true;
    begin
        case Period of
            Period::Next:
                begin
                    Enddate := CalcDate(StrSubstNo(NextLbl, BusChartBuf.GetPeriodLength()), BusChartBuf."Period Filter End Date");
                end;
            Period::Previous:
                begin
                    Enddate := CalcDate(StrSubstNo(PreviousLbl, BusChartBuf.GetPeriodLength()), BusChartBuf."Period Filter End Date");
                end;
        end;

        if Enddate > Today then
            Enddate := Today();

        Date.SetRange("Period Type", PeriodType);
        Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(UntilLbl, 7, BusChartBuf.GetPeriodLength()), Enddate));
        if Date.FindFirst() then
            StartDate := Date."Period Start"
    end;
}

