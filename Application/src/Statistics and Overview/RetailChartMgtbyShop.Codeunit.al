codeunit 6059812 "NPR Retail Chart Mgt by Shop"
{
    Access = Internal;
    var
        MarginLbl: Label 'Margin';
        TurnoverLbl: Label 'Turnover';
        StoreLbl: Label 'Store';

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
#if BC17        
        BusChartBuf.AddMeasure(MarginLbl, 2, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
        BusChartBuf.AddMeasure(TurnoverLbl, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
#else
        BusChartBuf.AddMeasure(MarginLbl, 2, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column.AsInteger());
        BusChartBuf.AddMeasure(TurnoverLbl, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column.AsInteger());
#endif
        BusChartBuf.SetXAxis(StoreLbl, BusChartBuf."Data Type"::String);

        Query1.SetRange(Posting_Date, StartDate, Enddate);
        Query1.Open();
        while Query1.Read() do begin
            I += 1;
            BusChartBuf.AddColumn(Query1.Global_Dimension_1_Code);
            BusChartBuf.SetValue(MarginLbl, I - 1, Query1.Sum_Sales_Amount_Actual + Query1.Sum_Cost_Amount_Actual);
            BusChartBuf.SetValue(TurnoverLbl, I - 1, Query1.Sum_Sales_Amount_Actual);
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
#if BC17        
        BusChartBuf.AddMeasure(MarginLbl, 2, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
        BusChartBuf.AddMeasure(TurnoverLbl, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column);
#else
        BusChartBuf.AddMeasure(MarginLbl, 2, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column.AsInteger());
        BusChartBuf.AddMeasure(TurnoverLbl, 1, BusChartBuf."Data Type"::Decimal, BusChartBuf."Chart Type"::Column.AsInteger());
#endif
        BusChartBuf.SetXAxis(StoreLbl, BusChartBuf."Data Type"::String);

        Query1.SetRange(Posting_Date, StartDate, Enddate);
        Query1.Open();
        while Query1.Read() do begin
            I += 1;
            BusChartBuf.AddColumn(Query1.Global_Dimension_2_Code);
            BusChartBuf.SetValue(MarginLbl, I - 1, Query1.Sum_Sales_Amount_Actual + Query1.Sum_Cost_Amount_Actual);
            BusChartBuf.SetValue(TurnoverLbl, I - 1, Query1.Sum_Sales_Amount_Actual);
        end;
        Query1.Close();
    end;

    local procedure Setdate(var StartDate: Date; var Enddate: Date; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; var BusChartBuf: Record "Business Chart Buffer")
    var
        Date: Record Date;
        NextLbl: Label '<C%1+1%1>', Locked = true;
        PreviousLbl: Label '<C%1-1%1>', Locked = true;
        CurrentLbl: Label '<C%1>', Locked = true;
        UntilLbl: Label '<-%1%2>', Locked = true;
    begin
        case Period of
            Period::Next:
                Enddate := CalcDate(StrSubstNo(NextLbl, BusChartBuf.GetPeriodLength()), Enddate);
            Period::Previous:
                Enddate := CalcDate(StrSubstNo(PreviousLbl, BusChartBuf.GetPeriodLength()), Enddate);
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

