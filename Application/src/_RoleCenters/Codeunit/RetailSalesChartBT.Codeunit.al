codeunit 6150814 "NPR Retail Sales Chart BT"
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
    begin
        if not RetailSalesCue.Get() then
            exit;

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

        ReadData(Period, PeriodType, PeriodLength, PeriodEndDate);
    end;

    procedure GetPeriodLength(var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period): Text[1]
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

    local procedure ReadData(Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; PeriodLength: Text[1]; PeriodEndDate: Date)
    var
        BusChartBuf: Record "Business Chart Buffer";
        Result: Dictionary of [Text, Text];
        Query1: Query "NPR Retail Sales Value Entry";
        I: Integer;
        StartDate: Date;
        Enddate: Date;
        TotNoOfPeriod: Integer;
    begin
        if Period = Period::" " then begin
            Enddate := Today();
            PeriodLength := GetPeriodLength(PeriodType);
        end;

        Setdate(StartDate, Enddate, Period, PeriodType, PeriodLength, PeriodEndDate);
        BusChartBuf.Initialize();
        BusChartBuf.InitializePeriodFilter(StartDate, Enddate);
        BusChartBuf."Period Length" := PeriodType;
        BusChartBuf.SetXAxis(Format(BusChartBuf."Period Length"), BusChartBuf."Data Type"::String);
        BusChartBuf.AddPeriods(StartDate, Enddate);
        TotNoOfPeriod := BusChartBuf.CalcNumberOfPeriods(StartDate, Enddate);

        for I := 1 to TotNoOfPeriod do begin
            BusChartBuf.GetPeriodFromMapColumn(I - 1, StartDate, Enddate);
            Query1.SetFilter(Posting_Date, '%1..%2', StartDate, Enddate);
            Query1.Open();
            Query1.Read();
            Result.Add('Margin ' + Format(I - 1), Format(Query1.Sum_Sales_Amount_Actual + Query1.Sum_Cost_Amount_Actual, 0, '<Precision,2:2><Standard Format,9>'));
            Result.Add('Turnover ' + Format(I - 1), Format(Query1.Sum_Sales_Amount_Actual, 0, '<Precision,2:2><Standard Format,9>'));
            Query1.Close();
        end;

        Page.SetBackgroundTaskResult(Result);
    end;

    procedure Setdate(var StartDate: Date; var Enddate: Date; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; PeriodLength: Text[1]; PeriodEndDate: Date)
    var
        Date: Record Date;
        NextLbl: Label '<C%1+7%1>', Locked = true;
        PreviousLbl: Label '<C%1-7%1>', Locked = true;
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

        if Enddate > Today then
            Enddate := Today();

        Date.SetRange("Period Type", PeriodType);
        Date.SetFilter("Period Start", '%1..', CalcDate(StrSubstNo(UntilLbl, 7, PeriodLength), Enddate));
        if Date.FindFirst() then
            StartDate := Date."Period Start"
    end;
}
