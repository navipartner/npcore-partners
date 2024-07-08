codeunit 6150806 "NPR Retail Chart by Shop BT"
{
    Access = Internal;
    trigger OnRun()
    begin
        Execute();
    end;

    local procedure Execute()
    var
        RetailSalesCue: Record "NPR Retail Sales Cue";
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period;
        Period: Option " ",Next,Previous;
        PeriodLength: Text[1];
        PeriodEndDate: Date;
        ChartType: Option "Dimension 1","Dimension 2";
    begin
        if not RetailSalesCue.Get() then
            exit;

        if not Evaluate(ChartType, Page.GetBackgroundParameters().Get('ChartType')) then
            Error('Could not parse parameter ChartType');
        if not Evaluate(Period, Page.GetBackgroundParameters().Get('Period')) then
            Error('Could not parse parameter Period');
        if not Evaluate(PeriodType, Page.GetBackgroundParameters().Get('PeriodType')) then
            Error('Could not parse parameter PeriodType');
        if not Evaluate(PeriodLength, Page.GetBackgroundParameters().Get('PeriodLength')) then
            Error('Could not parse parameter PeriodLength');
        if Page.GetBackgroundParameters().Get('PeriodEndDate') = '' then
            PeriodEndDate := 0D
        else
            if not Evaluate(PeriodEndDate, Page.GetBackgroundParameters().Get('PeriodEndDate')) then
                Error('Could not parse parameter PeriodEndDate');

        ReadData(Period, PeriodType, PeriodLength, PeriodEndDate, ChartType);
    end;

    local procedure GetPeriodLength(var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period): Text[1]
    begin
        case PeriodType of
            PeriodType::Day:
                exit('D');
            PeriodType::Week:
                exit('W');
            PeriodType::Month:
                exit('M');
            PeriodType::Quarter:
                exit('Q');
            PeriodType::Year:
                exit('Y');
        end;
    end;

    local procedure ReadData(Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; PeriodLength: Text[1]; PeriodEndDate: Date; ChartType: Option "Dimension 1","Dimension 2")
    var
        BusChartBuf: Record "Business Chart Buffer";
        Result: Dictionary of [Text, Text];
        Query1: Query "NPR Retail Sales by Dim. 1";
        Query2: Query "NPR Retail Sales by Dim. 2";
        I: Integer;
        StartDate: Date;
        EndDate: Date;
        StoreLbl: Label 'Store';
    begin
        if Period = Period::" " then begin
            Enddate := Today();
            PeriodLength := GetPeriodLength(PeriodType);
        end;
        Setdate(StartDate, Enddate, Period, PeriodType, PeriodLength, PeriodEndDate);

        BusChartBuf.Initialize();
        BusChartBuf.SetXAxis(StoreLbl, BusChartBuf."Data Type"::String);
        BusChartBuf.AddPeriods(StartDate, Enddate);
        case ChartType of
            ChartType::"Dimension 1":
                begin
                    Query1.SetRange(Posting_Date, StartDate, Enddate);
                    Query1.Open();
                    while Query1.Read() do begin
                        I += 1;
                        Result.Add('DimCode ' + Format(I - 1), Query1.Global_Dimension_1_Code);
                        Result.Add('Margin ' + Format(I - 1), Format(Query1.Sum_Sales_Amount_Actual + Query1.Sum_Cost_Amount_Actual));
                        Result.Add('Turnover ' + Format(I - 1), Format(Query1.Sum_Sales_Amount_Actual));
                    end;
                    Query1.Close();
                end;
            ChartType::"Dimension 2":
                begin
                    Query2.SetRange(Posting_Date, StartDate, Enddate);
                    Query2.Open();
                    while Query2.Read() do begin
                        I += 1;
                        Result.Add('DimCode ' + Format(I - 1), Query2.Global_Dimension_2_Code);
                        Result.Add('Margin ' + Format(I - 1), Format(Query2.Sum_Sales_Amount_Actual + Query2.Sum_Cost_Amount_Actual));
                        Result.Add('Turnover ' + Format(I - 1), Format(Query2.Sum_Sales_Amount_Actual));
                    end;
                    Query2.Close();
                end;
        end;
        Result.Add('TotalCounter', Format(I));

        Page.SetBackgroundTaskResult(Result);
    end;

    procedure Setdate(var StartDate: Date; var Enddate: Date; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; PeriodLength: Text[1]; PeriodEndDate: Date)
    var
        Date: Record Date;
        NextLbl: Label '<C%1+1%1>', Locked = true;
        PreviousLbl: Label '<C%1-1%1>', Locked = true;
        CurrentLbl: Label '<C%1>', Locked = true;
        UntilLbl: Label '<-%1%2>', Locked = true;
    begin
        case Period of
            Period::Next:
                begin
                    Enddate := CalcDate(StrSubstNo(NextLbl, PeriodLength), PeriodEndDate);
                end;
            Period::Previous:
                begin
                    Enddate := CalcDate(StrSubstNo(PreviousLbl, PeriodLength), PeriodEndDate);
                end;
        end;
        Enddate := CalcDate(StrSubstNo(CurrentLbl, PeriodLength), Enddate);
        if Enddate > Today then
            Enddate := Today();

        Date.SetRange("Period Type", PeriodType);
        Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(UntilLbl, 'C', PeriodLength), Enddate));
        if Date.FindFirst() then
            StartDate := Date."Period Start";
    end;
}

