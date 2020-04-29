codeunit 6059812 "Retail Chart Mgt by Shop"
{
    // NPR5.29/BHR/20160401 CASE 262439 Chart sales by dimension1 or dimension2


    trigger OnRun()
    begin
    end;

    var
        NoofPeriod: Integer;
        Text000: Label 'Margin';
        Text001: Label 'Turnover';
        Text002: Label 'Store';

    procedure TurnOver_RevenuebyDim1(var BusChartBuf: Record "Business Chart Buffer";Period: Option " ",Next,Previous;var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;var StartDate: Date;var Enddate: Date)
    var
        Query1: Query "Retail Sales by Dimension 1";
        I: Integer;
        BusChartMapColumn: Record "Business Chart Map";
        TotNoOfPeriod: Integer;
    begin
        with BusChartBuf do begin
          if Period = Period::" " then
            begin
              Enddate := Today;
              BusChartBuf."Period Length" := PeriodType;
            end;
          Setdate(StartDate,Enddate,Period,PeriodType,BusChartBuf);
          Initialize;
          AddMeasure(Text000,2 ,"Data Type"::Decimal,"Chart Type"::Column);
          AddMeasure(Text001,1 ,"Data Type"::Decimal,"Chart Type"::Column);
          SetXAxis(Text002,"Data Type"::String);

          Query1.SetRange(Posting_Date,StartDate,Enddate);
          Query1.Open;
          while Query1.Read do begin
            I+=1;
            BusChartBuf.AddColumn(Query1.Global_Dimension_1_Code);
            BusChartBuf.SetValue(Text000,I-1,Query1.Sum_Sales_Amount_Actual + Query1.Sum_Cost_Amount_Actual);
            BusChartBuf.SetValue(Text001,I-1,Query1.Sum_Sales_Amount_Actual);
            end;
            Query1.Close;
        end;
    end;

    procedure TurnOver_RevenuebyDim2(var BusChartBuf: Record "Business Chart Buffer";Period: Option " ",Next,Previous;var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;var StartDate: Date;var Enddate: Date)
    var
        Query1: Query "Retail Sales by Dimension 2";
        I: Integer;
        BusChartMapColumn: Record "Business Chart Map";
        TotNoOfPeriod: Integer;
    begin
        with BusChartBuf do begin
          if Period = Period::" " then
            begin
              Enddate := Today;
              BusChartBuf."Period Length" := PeriodType;
            end;
          Setdate(StartDate,Enddate,Period,PeriodType,BusChartBuf);
          Initialize;
          AddMeasure(Text000,2 ,"Data Type"::Decimal,"Chart Type"::Column);
          AddMeasure(Text001,1 ,"Data Type"::Decimal,"Chart Type"::Column);
          SetXAxis(Text002,"Data Type"::String);

          Query1.SetRange(Posting_Date,StartDate,Enddate);
          Query1.Open;
          while Query1.Read do begin
            I+=1;
            BusChartBuf.AddColumn(Query1.Global_Dimension_2_Code);
            BusChartBuf.SetValue(Text000,I-1,Query1.Sum_Sales_Amount_Actual + Query1.Sum_Cost_Amount_Actual);
            BusChartBuf.SetValue(Text001,I-1,Query1.Sum_Sales_Amount_Actual);
            end;
            Query1.Close;
        end;
    end;

    local procedure Setdate(var StartDate: Date;var Enddate: Date;Period: Option " ",Next,Previous;var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;var BusChartBuf: Record "Business Chart Buffer")
    var
        Date: Record Date;
    begin

        case Period of
         Period::Next:
          begin
            Enddate := CalcDate(StrSubstNo('<C%1+1%1>',BusChartBuf.GetPeriodLength()),Enddate);
          end;
         Period::Previous:
          begin
            Enddate := CalcDate(StrSubstNo('<C%1-1%1>',BusChartBuf.GetPeriodLength()),Enddate);
          end;
        end;

        Enddate := CalcDate(StrSubstNo('<C%1>',BusChartBuf.GetPeriodLength()),Enddate);
        if Enddate > Today then
         Enddate := Today;

        Date.SetRange("Period Type",PeriodType);
        Date.SetFilter("Period Start",'%1..',CalcDate(StrSubstNo('<-%1%2>','C',BusChartBuf.GetPeriodLength()),Enddate));
        if Date.FindFirst then
         StartDate := Date."Period Start";
    end;
}

