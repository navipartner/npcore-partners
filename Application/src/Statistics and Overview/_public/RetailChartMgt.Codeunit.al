codeunit 6059811 "NPR Retail Chart Mgt."
{
    var
        MarginLbl: Label 'Margin';
        TurnoverLbl: Label 'Turnover';
        StoreLbl: Label 'Store';

    internal procedure TurnOver_Revenue(var BusChartBuf: Record "Business Chart Buffer"; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; Results: Dictionary of [Text, Text])
    var
        I: Integer;
        StartDate: Date;
        Enddate: Date;
        TotNoOfPeriod: Integer;
        Margin: Decimal;
        Turnover: Decimal;
    begin
        if Period = Period::" " then begin
            Enddate := Today();
            BusChartBuf."Period Length" := PeriodType;
        end;

        SetdateRevenue(StartDate, Enddate, Period, PeriodType, BusChartBuf);
        BusChartBuf.Initialize();
#if BC17
        BusChartBuf.AddMeasure(TurnoverLbl, 0, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
        BusChartBuf.AddMeasure(MarginLbl, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
#else
        BusChartBuf.AddMeasure(TurnoverLbl, 0, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column.AsInteger());
        BusChartBuf.AddMeasure(MarginLbl, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column.AsInteger());
#endif
        BusChartBuf.InitializePeriodFilter(StartDate, Enddate);

        BusChartBuf."Period Length" := PeriodType;
        BusChartBuf.SetXAxis(Format(BusChartBuf."Period Length"), BusChartBuf."Data Type"::String);
        BusChartBuf.AddPeriods(StartDate, Enddate);
        TotNoOfPeriod := BusChartBuf.CalcNumberOfPeriods(StartDate, Enddate);

        for I := 1 to TotNoOfPeriod do begin
            Margin := 0;
            Turnover := 0;

            BusChartBuf.GetPeriodFromMapColumn(I - 1, StartDate, Enddate);
            if Results.ContainsKey('Margin ' + Format(I - 1)) then
                Evaluate(Margin, Results.Get('Margin ' + Format(I - 1)));
            if Results.ContainsKey('Turnover ' + Format(I - 1)) then
                Evaluate(Turnover, Results.Get('Turnover ' + Format(I - 1)));

            BusChartBuf.SetValue(MarginLbl, I - 1, Margin);
            BusChartBuf.SetValue(TurnoverLbl, I - 1, Turnover);
        end;
    end;

    internal procedure TurnOver_RevenuebyDim(var BusChartBuf: Record "Business Chart Buffer"; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; Results: Dictionary of [Text, Text])
    var
        I: Integer;
        TotalCounter: Integer;
        Margin: Decimal;
        Turnover: Decimal;
        StartDate: Date;
        Enddate: Date;
    begin
        if Period = Period::" " then begin
            Enddate := Today();
            BusChartBuf."Period Length" := PeriodType;
        end;
        SetdatebyDim(StartDate, Enddate, Period, PeriodType, BusChartBuf);
        BusChartBuf.Initialize();
#if BC17        
        BusChartBuf.AddMeasure(TurnoverLbl, 0, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
        BusChartBuf.AddMeasure(MarginLbl, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
#else
        BusChartBuf.AddMeasure(TurnoverLbl, 0, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column.AsInteger());
        BusChartBuf.AddMeasure(MarginLbl, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column.AsInteger());
#endif
        BusChartBuf.InitializePeriodFilter(StartDate, Enddate);
        BusChartBuf.SetXAxis(StoreLbl, BusChartBuf."Data Type"::String);
        Evaluate(TotalCounter, Results.Get('TotalCounter'));
        for I := 1 to TotalCounter do begin
            Margin := 0;
            Turnover := 0;

            if Results.ContainsKey('Margin ' + Format(I - 1)) then
                Evaluate(Margin, Results.Get('Margin ' + Format(I - 1)));
            if Results.ContainsKey('Turnover ' + Format(I - 1)) then
                Evaluate(Turnover, Results.Get('Turnover ' + Format(I - 1)));

            BusChartBuf.AddColumn(Results.Get('DimCode ' + Format(I - 1)));
            BusChartBuf.SetValue(MarginLbl, I - 1, Margin);
            BusChartBuf.SetValue(TurnoverLbl, I - 1, Turnover);
        end;
    end;

    local procedure SetdateRevenue(var StartDate: Date; var Enddate: Date; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; var BusChartBuf: Record "Business Chart Buffer")
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

    procedure SetdatebyDim(var StartDate: Date; var Enddate: Date; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; var BusChartBuf: Record "Business Chart Buffer")
    var
        Date: Record Date;
        NextLbl: Label '<C%1+1%1>', Locked = true;
        PreviousLbl: Label '<C%1-1%1>', Locked = true;
        CurrentLbl: Label '<C%1>', Locked = true;
        UntilLbl: Label '<-%1%2>', Locked = true;
    begin
        case Period of
            Period::Next:
                Enddate := CalcDate(StrSubstNo(NextLbl, BusChartBuf.GetPeriodLength()), BusChartBuf."Period Filter End Date");
            Period::Previous:
                Enddate := CalcDate(StrSubstNo(PreviousLbl, BusChartBuf.GetPeriodLength()), BusChartBuf."Period Filter End Date");
        end;

        Enddate := CalcDate(StrSubstNo(CurrentLbl, BusChartBuf.GetPeriodLength()), Enddate);
        if Enddate > Today then
            Enddate := Today();

        Date.SetRange("Period Type", PeriodType);
        Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(UntilLbl, 'C', BusChartBuf.GetPeriodLength()), Enddate));
        if Date.FindFirst() then
            StartDate := Date."Period Start";
    end;
}

