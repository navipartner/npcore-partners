codeunit 6059811 "NPR Retail Chart Mgt."
{
    var
        ChartDefinitionMissingErr: Label 'There are no charts defined.';
        DefaultStatusTxt: Label '%1 | View by %2', Comment = '%1 - Chart Name, %2 - Period Length';
        MarginLbl: Label 'Margin';
        RetailSalesByShopDescLbl: Label 'The Margin/Turnover by Shop chart illustrates sales performance across different shops over specified time intervals. It merges margin (profit) and turnover (sales frequency) data, providing insights into pricing impact, cost efficiency, and inventory management. This chart aids in comparing shops, optimizing strategies, and identifying top-performing outlets for enhanced profitability.';
        RetailSalesByShopTitleLbl: Label 'Margin/Turnover by Shop';
        RetailSalesChartDescLbl: Label 'The Margin/Turnover per Period chart provides a comprehensive overview of the retail store''s sales performance within a selected time frame. This chart effectively combines two essential metrics, margin and turnover, to offer valuable insights into the store''s revenue generation and efficiency.';
        RetailSalesChartTitleLbl: Label 'Margin/Turnover by Period';
        StatusTxtWithDimLbl: Label '%1 | View by %2 - %3', Comment = '%1 - Chart Name, %2 - Period Length, %3 - Dimension';
        StoreLbl: Label 'Store';
        TurnoverLbl: Label 'Turnover';


    internal procedure TurnOver_Revenue(var BusChartBuf: Record "Business Chart Buffer"; Period: Option " ",Next,Previous; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; Results: Dictionary of [Text, Text])
    var
        Enddate: Date;
        StartDate: Date;
        Margin: Decimal;
        Turnover: Decimal;
        I: Integer;
        TotNoOfPeriod: Integer;
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
        Enddate: Date;
        StartDate: Date;
        Margin: Decimal;
        Turnover: Decimal;
        I: Integer;
        TotalCounter: Integer;
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
                Enddate := CalcDate(StrSubstNo(NextLbl, BusChartBuf.GetPeriodLength()), BusChartBuf."Period Filter End Date");
            Period::Previous:
                Enddate := CalcDate(StrSubstNo(PreviousLbl, BusChartBuf.GetPeriodLength()), BusChartBuf."Period Filter End Date");
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
        CurrentLbl: Label '<C%1>', Locked = true;
        NextLbl: Label '<C%1+1%1>', Locked = true;
        PreviousLbl: Label '<C%1-1%1>', Locked = true;
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

    internal procedure SelectChart(var ChartDefinition: Record "Chart Definition")
    var
        ChartList: Page "Chart List";
    begin
        ChartDefinition.SetRange(Enabled, true);
        ChartDefinition.SetFilter("Code Unit ID", GetCodeunitIDFilter());

        if ChartDefinition.IsEmpty() then
            if ChartDefinition.WritePermission then begin
                PopulateChartDefinitionTable();
                Commit();
            end else
                Error(ChartDefinitionMissingErr);

        ChartList.SetTableView(ChartDefinition);
        ChartList.SetRecord(ChartDefinition);
        ChartList.LookupMode(true);

        if ChartList.RunModal() = Action::LookupOK then
            ChartList.GetRecord(ChartDefinition);
    end;

    internal procedure InitializeChartDefinition(var ChartDefinition: Record "Chart Definition"; UserId: Text)
    var
        LastUsedChart: Record "Last Used Chart";
    begin
        LastUsedChart.SetRange(UID, UserId);
        LastUsedChart.SetFilter("Code Unit ID", GetCodeunitIDFilter());

        if LastUsedChart.FindFirst() then
            if ChartDefinition.Get(LastUsedChart."Code Unit ID", LastUsedChart."Chart Name") then
                exit;

        ChartDefinition.SetRange(Enabled, true);
        ChartDefinition.SetFilter("Code Unit ID", GetCodeunitIDFilter());

        if ChartDefinition.IsEmpty() then
            if ChartDefinition.WritePermission then begin
                PopulateChartDefinitionTable();
                Commit();
            end else
                Error(ChartDefinitionMissingErr);

        ChartDefinition.Reset();
        ChartDefinition.SetRange(Enabled, true);
        ChartDefinition.SetFilter("Code Unit ID", GetCodeunitIDFilter());

        if not ChartDefinition.FindFirst() then
            Error(ChartDefinitionMissingErr);
    end;

    internal procedure UpdateChart(ChartDefinition: Record "Chart Definition"; var BusinessChartBuffer: Record "Business Chart Buffer"; Period: Option " ",Next,Previous; PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; Results: Dictionary of [Text, Text])
    begin
        case ChartDefinition."Code Unit ID" of
            Codeunit::"NPR Retail Sales Chart BT":
                TurnOver_Revenue(BusinessChartBuffer, Period, PeriodType, Results);
            Codeunit::"NPR Retail Chart by Shop BT":
                TurnOver_RevenuebyDim(BusinessChartBuffer, Period, PeriodType, Results);
        end;
        UpdateLastUsedChart(ChartDefinition);
    end;

    internal procedure ChartDescription(ChartDefinition: Record "Chart Definition"): Text
    begin
        case ChartDefinition."Code Unit ID" of
            Codeunit::"NPR Retail Sales Chart BT":
                exit(RetailSalesChartDescLbl);
            Codeunit::"NPR Retail Chart by Shop BT":
                exit(RetailSalesByShopDescLbl);
        end;
    end;

    internal procedure UpdateStatusText(ChartDefinition: Record "Chart Definition"; var PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; ChartType: Option "Dimension 1","Dimension 2"; var StatusText: Text)
    begin
        if IsChartTypeUsed(ChartDefinition) then
            StatusText := StrSubstNo(StatusTxtWithDimLbl, ChartDefinition."Chart Name", PeriodType, ChartType)
        else
            StatusText := StrSubstNo(DefaultStatusTxt, ChartDefinition."Chart Name", PeriodType);
    end;

    internal procedure SetBackgroundTaskParameters(ChartDefinition: Record "Chart Definition"; Period: Option " ",Next,Previous; PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period",Period; PeriodLength: Text[1]; PeriodFilterEndDate: Date; ChartType: Option "Dimension 1","Dimension 2"; var Parameters: Dictionary of [Text, Text])
    begin
        Clear(Parameters);
        Parameters.Add('Period', Format(Period));
        Parameters.Add('PeriodType', Format(PeriodType));
        Parameters.Add('PeriodLength', Format(PeriodLength));
        Parameters.Add('PeriodEndDate', Format(PeriodFilterEndDate));

        if IsChartTypeUsed(ChartDefinition) then
            Parameters.Add('ChartType', Format(ChartType));
    end;

    internal procedure IsChartTypeUsed(ChartDefinition: Record "Chart Definition"): Boolean
    begin
        exit(ChartDefinition."Code Unit ID" in
          [Codeunit::"NPR Retail Chart by Shop BT"]);
    end;

    internal procedure GetCodeunitIDFilter(): Text
    var
        TxtBuilder: TextBuilder;
    begin
        TxtBuilder.Append(Format(Codeunit::"NPR Retail Sales Chart BT") + '|');
        TxtBuilder.Append(Format(Codeunit::"NPR Retail Chart by Shop BT"));

        exit(TxtBuilder.ToText());
    end;

    internal procedure PopulateChartDefinitionTable()
    begin
        InsertChartDefinition(Codeunit::"NPR Retail Sales Chart BT", RetailSalesChartTitleLbl);
        InsertChartDefinition(Codeunit::"NPR Retail Chart by Shop BT", RetailSalesByShopTitleLbl);
    end;

    local procedure InsertChartDefinition(ChartCodeunitId: Integer; ChartName: Text[60])
    var
        ChartDefinition: Record "Chart Definition";
    begin
        if not ChartDefinition.Get(ChartCodeunitId, ChartName) then begin
            ChartDefinition."Code Unit ID" := ChartCodeunitId;
            ChartDefinition."Chart Name" := ChartName;
            ChartDefinition.Enabled := true;
            ChartDefinition.Insert();
        end;
    end;

    local procedure UpdateLastUsedChart(ChartDefinition: Record "Chart Definition")
    var
        LastUsedChart: Record "Last Used Chart";
    begin
        if LastUsedChart.Get(UserId()) then begin
            if (LastUsedChart."Code Unit ID" <> ChartDefinition."Code Unit ID") or (LastUsedChart."Chart Name" <> ChartDefinition."Chart Name") then begin
                LastUsedChart.Validate("Code Unit ID", ChartDefinition."Code Unit ID");
                LastUsedChart.Validate("Chart Name", ChartDefinition."Chart Name");
                LastUsedChart.Modify();
            end;
        end else begin
            LastUsedChart.Validate(UID, UserId());
            LastUsedChart.Validate("Code Unit ID", ChartDefinition."Code Unit ID");
            LastUsedChart.Validate("Chart Name", ChartDefinition."Chart Name");
            LastUsedChart.Insert();
        end;
    end;
}