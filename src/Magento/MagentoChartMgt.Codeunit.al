codeunit 6151480 "NPR Magento Chart Mgt."
{
    // MAG1.17/BHR/20150528 CASE 212983 Navishop Chart
    // MAG1.17/MH/20150619  CASE 216793 Changed hardcoded captions to text constants
    // MAG1.17/BHR/20150619 CASE 216856 Changed Query and calculation for margin
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration


    trigger OnRun()
    begin
    end;

    var
        NoofPeriod: Integer;
        Text000: Label 'Margin';
        Text001: Label 'Turnover';

    procedure TurnOver_Revenue(var BusChartBuf: Record "Business Chart Buffer"; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period)
    var
        Query1: Query "NPR Sales Value Entry";
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
            //-MAG1.17
            //AddMeasure('Revenue',2 ,"Data Type"::Decimal,"Chart Type"::Column);
            //AddMeasure('Turnover',1 ,"Data Type"::Decimal,"Chart Type"::Column);
            AddMeasure(Text000, 2, "Data Type"::Decimal, "Chart Type"::Column);
            AddMeasure(Text001, 1, "Data Type"::Decimal, "Chart Type"::Column);
            //+MAG1.17

            BusChartBuf."Period Length" := PeriodType;
            BusChartBuf.SetPeriodXAxis;
            BusChartBuf.AddPeriods(StartDate, Enddate);
            TotNoOfPeriod := BusChartBuf.CalcNumberOfPeriods(StartDate, Enddate);

            for I := 1 to TotNoOfPeriod do begin
                GetPeriodFromMapColumn(I - 1, StartDate, Enddate);
                Query1.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
                Query1.Open;
                Query1.Read;
                //+MAG1.17
                //BusChartBuf.SetValue('Revenue',I-1,Query1.Sum_Profit_LCY);
                //BusChartBuf.SetValue('Turnover',I-1,Query1.Sum_Sales_LCY);
                //-MAG1.17
                //BusChartBuf.SetValue(Text000,I-1,Query1.Sum_Sales_Amount_Actual);
                BusChartBuf.SetValue(Text000, I - 1, Query1.Sum_Sales_Amount_Actual + Query1.Sum_Cost_Amount_Actual);
                BusChartBuf.SetValue(Text001, I - 1, Query1.Sum_Sales_Amount_Actual);
                //-MAG1.17
                //+MAG1.17
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

