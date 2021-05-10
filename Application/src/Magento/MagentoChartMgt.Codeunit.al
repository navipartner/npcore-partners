codeunit 6151480 "NPR Magento Chart Mgt."
{
    var
        Text000: Label 'Margin';
        Text001: Label 'Turnover';

    procedure TurnOver_Revenue(var BusChartBuf: Record "Business Chart Buffer"; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period)
    var
        Query1: Query "NPR Sales Value Entry";
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
        BusChartBuf.AddMeasure(Text000, 2, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
        BusChartBuf.AddMeasure(Text001, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);

        BusChartBuf."Period Length" := PeriodType;
        BusChartBuf.SetPeriodXAxis();
        BusChartBuf.AddPeriods(StartDate, Enddate);
        TotNoOfPeriod := BusChartBuf.CalcNumberOfPeriods(StartDate, Enddate);

        for I := 1 to TotNoOfPeriod do begin
            BusChartBuf.GetPeriodFromMapColumn(I - 1, StartDate, Enddate);
            Query1.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
            Query1.Open();
            Query1.Read();
            BusChartBuf.SetValue(Text000, I - 1, Query1.Sum_Sales_Amount_Actual + Query1.Sum_Cost_Amount_Actual);
            BusChartBuf.SetValue(Text001, I - 1, Query1.Sum_Sales_Amount_Actual);
            Query1.Close();
        end;
    end;

    local procedure Setdate(var StartDate: Date; var Enddate: Date; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; var BusChartBuf: Record "Business Chart Buffer")
    var
        Date: Record Date;
    begin
        case Period of
            Period::Next:
                begin
                    Enddate := CalcDate(StrSubstNo('<C%1+7%1>', BusChartBuf.GetPeriodLength()), BusChartBuf."Period Filter End Date");
                end;
            Period::Previous:
                begin
                    Enddate := CalcDate(StrSubstNo('<C%1-7%1>', BusChartBuf.GetPeriodLength()), BusChartBuf."Period Filter End Date");
                end;
        end;

        if Enddate > Today then
            Enddate := Today();

        Date.SetRange("Period Type", PeriodType);
        Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<-%1%2>', 7, BusChartBuf.GetPeriodLength()), Enddate));
        if Date.FindFirst() then
            StartDate := Date."Period Start"
    end;
}