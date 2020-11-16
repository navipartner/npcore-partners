codeunit 6059811 "NPR Retail Chart Mgt."
{
    // NC1.17/BHR/20150528 CASE 212983 Navishop Chart
    // NC1.17/MH/20150619  CASE 216793 Changed hardcoded captions to text constants
    // NC1.17/BHR/20150619 CASE 216856 Changed Query and calculation for margin
    // NPR5.23.03/MHA/20160726  CASE 242557 Object renamed and re-versioned from NC1.22 to NPR5.23.03


    trigger OnRun()
    begin
    end;

    var
        NoofPeriod: Integer;
        Text000: Label 'Margin';
        Text001: Label 'Turnover';

    procedure TurnOver_Revenue(var BusChartBuf: Record "Business Chart Buffer"; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period)
    var
        Query1: Query "NPR Retail Sales Value Entry";
        I: Integer;
        BusChartMapColumn: Record "Business Chart Map";
        StartDate: Date;
        Enddate: Date;
        TotNoOfPeriod: Integer;
    begin
        with BusChartBuf do begin
            if Period = Period::" " then begin
                Enddate := Today;
                BusChartBuf."Period Length" := PeriodType;
            end;

            Setdate(StartDate, Enddate, Period, PeriodType, BusChartBuf);
            InitializePeriodFilter(StartDate, Enddate);

            Initialize;
            //-NC1.17
            //AddMeasure('Revenue',2 ,"Data Type"::Decimal,"Chart Type"::Column);
            //AddMeasure('Turnover',1 ,"Data Type"::Decimal,"Chart Type"::Column);
            AddMeasure(Text000, 2, "Data Type"::Decimal, "Chart Type"::Column);
            AddMeasure(Text001, 1, "Data Type"::Decimal, "Chart Type"::Column);
            //+NC1.17

            BusChartBuf."Period Length" := PeriodType;
            BusChartBuf.SetPeriodXAxis;
            BusChartBuf.AddPeriods(StartDate, Enddate);
            TotNoOfPeriod := BusChartBuf.CalcNumberOfPeriods(StartDate, Enddate);

            for I := 1 to TotNoOfPeriod do begin
                GetPeriodFromMapColumn(I - 1, StartDate, Enddate);
                Query1.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
                Query1.Open;
                Query1.Read;
                //+NC1.17
                //BusChartBuf.SetValue('Revenue',I-1,Query1.Sum_Profit_LCY);
                //BusChartBuf.SetValue('Turnover',I-1,Query1.Sum_Sales_LCY);
                //-NC1.17
                //BusChartBuf.SetValue(Text000,I-1,Query1.Sum_Sales_Amount_Actual);
                BusChartBuf.SetValue(Text000, I - 1, Query1.Sum_Sales_Amount_Actual + Query1.Sum_Cost_Amount_Actual);
                BusChartBuf.SetValue(Text001, I - 1, Query1.Sum_Sales_Amount_Actual);
                //-NC1.17
                //+NC1.17
                Query1.Close;
            end;
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
            Enddate := Today;

        Date.SetRange("Period Type", PeriodType);
        Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo('<-%1%2>', 7, BusChartBuf.GetPeriodLength()), Enddate));
        if Date.FindFirst then
            StartDate := Date."Period Start"
    end;
}

