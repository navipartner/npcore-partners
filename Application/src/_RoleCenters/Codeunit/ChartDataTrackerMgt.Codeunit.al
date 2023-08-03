codeunit 6060006 "NPR Chart Data Tracker Mgt."
{
    Access = Internal;

    procedure ShouldUpdateChartFromTable(var ChartDataUpdateTracker: Record "NPR Chart Data Update Tracker"; ChartPageId: Integer; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; PeriodLength: Text[1]; PeriodEndDate: Date; DimensionType: Option "Dimension 1","Dimension 2"; IncludeDim: Boolean): Boolean
    var
        RetailChartbyShopBT: Codeunit "NPR Retail Chart by Shop BT";
        RetailSalesChartBT: Codeunit "NPR Retail Sales Chart BT";
        EndDate, StartDate : Date;
    begin
        if Period = Period::" " then begin
            EndDate := Today();
            PeriodLength := RetailSalesChartBT.GetPeriodLength(PeriodType);
        end;

        if IncludeDim then
            RetailChartbyShopBT.Setdate(StartDate, EndDate, Period, PeriodType, PeriodLength, PeriodEndDate)
        else
            RetailSalesChartBT.Setdate(StartDate, EndDate, Period, PeriodType, PeriodLength, PeriodEndDate);

        ChartDataUpdateTracker.SetRange("Chart Page ID", ChartPageId);
        ChartDataUpdateTracker.SetRange("Period Type", PeriodType);
        ChartDataUpdateTracker.SetRange("Start Date", StartDate);
        ChartDataUpdateTracker.SetRange("End Date", EndDate);
        if IncludeDim then
            ChartDataUpdateTracker.SetRange(Dimension, DimensionType);

        if not ChartDataUpdateTracker.FindFirst() then
            exit;

        if CheckLastUpdateTimestamp(ChartDataUpdateTracker) then
            exit;

        exit(true);
    end;

    procedure UpsertTrackerTable(ChartPageId: Integer; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; StartDate: Date; EndDate: Date; DimensionType: Option "Dimension 1","Dimension 2"; IncludeDim: Boolean; Results: Dictionary of [Text, Text])
    var
        ChartData: Record "NPR Chart Data";
        ChartDataUpdateTracker: Record "NPR Chart Data Update Tracker";
        "Key": Text;
    begin
        ChartDataUpdateTracker.SetRange("Chart Page ID", ChartPageId);
        ChartDataUpdateTracker.SetRange("Period Type", PeriodType);
        ChartDataUpdateTracker.SetRange("Start Date", StartDate);
        ChartDataUpdateTracker.SetRange("End Date", EndDate);

        if IncludeDim then
            ChartDataUpdateTracker.SetRange(Dimension, DimensionType);

        if not ChartDataUpdateTracker.FindFirst() then begin
            ChartDataUpdateTracker.Init();
            ChartDataUpdateTracker."Chart Page ID" := ChartPageId;
            ChartDataUpdateTracker."Last Computed" := CurrentDateTime();
            ChartDataUpdateTracker.Period := Period;
            ChartDataUpdateTracker."Period Type" := PeriodType;
            ChartDataUpdateTracker."Start Date" := StartDate;
            ChartDataUpdateTracker."End Date" := EndDate;
            ChartDataUpdateTracker.Dimension := DimensionType;
            ChartDataUpdateTracker.Insert();

            foreach "Key" in Results.Keys() do begin
                ChartData.Init();
                ChartData."Tracker Entry No." := ChartDataUpdateTracker."Entry No.";
#pragma warning disable AA0139
                ChartData."Key" := "Key";
                ChartData.Val := Results.Get("Key");
#pragma warning restore
                ChartData.Insert();
            end;
        end
        else begin
            ChartDataUpdateTracker."Last Computed" := CurrentDateTime();
            ChartDataUpdateTracker.Modify();

            ChartData.SetRange("Tracker Entry No.", ChartDataUpdateTracker."Entry No.");

            if ChartData.FindSet() then
                repeat
#pragma warning disable AA0139
                    ChartData.Val := Results.Get(ChartData."Key");
#pragma warning restore
                until ChartData.Next() = 0;
            ChartData.Modify();
        end;
    end;

    procedure GetResultsFromTable(ChartDataUpdateTracker: Record "NPR Chart Data Update Tracker"; Results: Dictionary of [Text, Text])
    var
        ChartData: Record "NPR Chart Data";
    begin
        ChartData.SetRange("Tracker Entry No.", ChartDataUpdateTracker."Entry No.");

        if not ChartData.FindSet() then
            exit;

        repeat
            Results.Add(ChartData."Key", Format(ChartData.Val));
        until ChartData.Next() = 0;
    end;

    local procedure CheckLastUpdateTimestamp(ChartDataUpdateTracker: Record "NPR Chart Data Update Tracker"): Boolean
    var
        FifteenMinutes: Duration;
    begin
        if ChartDataUpdateTracker."Last Computed" = 0DT then
            exit(true);
        FifteenMinutes := 15 * 60 * 1000;
        exit(CurrentDateTime() - ChartDataUpdateTracker."Last Computed" > FifteenMinutes);
    end;
}