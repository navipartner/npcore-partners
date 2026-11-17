codeunit 6060149 "NPR RC MM Members.Burndown Mgt"
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        MembershipBurndownSetup: Record "NPR RC Members. Burndown Setup";
        MembershipEntry: Record "NPR MM Membership Entry";

    procedure OnPageOpen(var vMembershipBurndownSetup: Record "NPR RC Members. Burndown Setup")
    begin
        if not vMembershipBurndownSetup.Get(UserId) then begin
            vMembershipBurndownSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(vMembershipBurndownSetup."User ID"));
            vMembershipBurndownSetup."Use Work Date as Base" := true;
            vMembershipBurndownSetup."Period Length" := vMembershipBurndownSetup."Period Length"::Month;
            vMembershipBurndownSetup."Value to Calculate" := vMembershipBurndownSetup."Value to Calculate"::MEMBERSHIP_COUNT;
            vMembershipBurndownSetup."Chart Type" := vMembershipBurndownSetup."Chart Type"::"Stacked Area";
            vMembershipBurndownSetup."Show Change As" := vMembershipBurndownSetup."Show Change As"::ACK;
            Evaluate(vMembershipBurndownSetup."StartDate Offset", '<+12M>');
            vMembershipBurndownSetup.Insert();
        end;
    end;

    procedure DrillDown(var BusChartBuf: Record "Business Chart Buffer")
    var
        Measure: Integer;
    begin
        Measure := BusChartBuf."Drill-Down Measure Index";
        if (Measure < 0) or (Measure > 3) then
            exit;

        MembershipBurndownSetup.Get(UserId);
    end;

    procedure UpdateData(var BusChartBuf: Record "Business Chart Buffer")
    var
        ChartToStatusMap: array[7] of Integer;
        ToDate: array[24] of Date;
        FromDate: array[24] of Date;
        PeriodValue: array[7, 24] of Decimal;
        Value: Decimal;
        TotalValue: Decimal;
        ColumnNo: Integer;
        MembershipEntryContext: Integer;
    begin

        MembershipBurndownSetup.Get(UserId);

        BusChartBuf.Initialize();
        BusChartBuf."Period Length" := MembershipBurndownSetup."Period Length";
        BusChartBuf.SetPeriodXAxis();

        CreateMap(ChartToStatusMap);
        for MembershipEntryContext := 1 to ArrayLen(ChartToStatusMap) do begin
            MembershipEntry.Context := ChartToStatusMap[MembershipEntryContext];
#if BC17 or BC18
            BusChartBuf.AddMeasure(Format(MembershipEntry.Context), MembershipEntry.Context, BusChartBuf."Data Type"::Decimal, MembershipBurndownSetup.GetChartType());
#else
            BusChartBuf.AddMeasure(Format(MembershipEntry.Context), MembershipEntry.Context, BusChartBuf."Data Type"::Decimal, MembershipBurndownSetup.GetChartType().AsInteger());
#endif
        end;

        if (CalcPeriods(FromDate, ToDate, BusChartBuf)) then begin
            BusChartBuf.AddPeriods(ToDate[1], ToDate[ArrayLen(ToDate)]);

            if (MembershipBurndownSetup."Value to Calculate" = MembershipBurndownSetup."Value to Calculate"::MEMBERSHIP_COUNT) then
                CountEntriesPerPeriod(ChartToStatusMap, ToDate, PeriodValue);

            for MembershipEntryContext := 1 to ArrayLen(ChartToStatusMap) do begin
                TotalValue := 0;
                for ColumnNo := 1 to ArrayLen(ToDate) do begin
                    Value := PeriodValue[MembershipEntryContext, ColumnNo];
                    case MembershipBurndownSetup."Show Change As" of
                        MembershipBurndownSetup."Show Change As"::ACK:
                            if ColumnNo = 1 then
                                TotalValue := Value else
                                TotalValue += Value;
                        MembershipBurndownSetup."Show Change As"::NET:
                            TotalValue := Value;
                    end;
                    BusChartBuf.SetValueByIndex(MembershipEntryContext - 1, ColumnNo - 1, TotalValue);
                end;
            end;
        end;
    end;

    local procedure CalcPeriods(var FromDate: array[24] of Date; var ToDate: array[24] of Date; var BusChartBuf: Record "Business Chart Buffer"): Boolean
    var
        MaxPeriodNo: Integer;
        i: Integer;
    begin

        MaxPeriodNo := ArrayLen(ToDate);
        ToDate[MaxPeriodNo] := MembershipBurndownSetup.GetStartDate();

        if ToDate[MaxPeriodNo] = 0D then
            exit(false);

        for i := MaxPeriodNo downto 1 do begin
            if i > 1 then begin
                FromDate[i] := BusChartBuf.CalcFromDate(ToDate[i]);
                ToDate[i - 1] := FromDate[i] - 1;
            end else begin
                FromDate[i] := 0D;
            end;
        end;
        exit(true);
    end;

    local procedure CountEntriesPerPeriod(var ChartToStatusMap: array[7] of Integer; var ToDate: array[24] of Date; var PeriodValue: array[7, 24] of Decimal)
    var
        ValidFromQuery: Query "NPR MM Burndown Valid From";
        ValidUntilQuery: Query "NPR MM Burndown Valid Until";
        MeasureNo: Integer;
    begin
        ValidFromQuery.SetFilter(ValidFromDate, '..%1', ToDate[ArrayLen(ToDate)]);
        ValidFromQuery.Open();
        while (ValidFromQuery.Read()) do begin
            MeasureNo := FindMeasureNo(ChartToStatusMap, ValidFromQuery.Context);
            if (MeasureNo > 0) then
                PeriodValue[MeasureNo, FindColumnNo(ToDate, ValidFromQuery.ValidFromDate)] += ValidFromQuery.EntryCount;
        end;

        ValidUntilQuery.SetFilter(ValidUntilDate, '..%1', ToDate[ArrayLen(ToDate)]);
        ValidUntilQuery.Open();
        while (ValidUntilQuery.Read()) do begin
            MeasureNo := FindMeasureNo(ChartToStatusMap, ValidUntilQuery.Context);
            if (MeasureNo > 0) then
                PeriodValue[MeasureNo, FindColumnNo(ToDate, ValidUntilQuery.ValidUntilDate)] -= ValidUntilQuery.EntryCount;
        end;
    end;

    local procedure FindMeasureNo(var ChartToStatusMap: array[7] of Integer; Context: Integer): Integer
    var
        MeasureNo: Integer;
    begin
        for MeasureNo := 1 to ArrayLen(ChartToStatusMap) do
            if (ChartToStatusMap[MeasureNo] = Context) then
                exit(MeasureNo);
        exit(0);
    end;

    // EntryDate must not be after the last period end.
    local procedure FindColumnNo(var ToDate: array[24] of Date; EntryDate: Date) ColumnNo: Integer
    begin
        ColumnNo := 1;
        while (EntryDate > ToDate[ColumnNo]) do
            ColumnNo += 1;
    end;

    procedure CreateMap(var Map: array[7] of Integer)
    begin
        Map[1] := MembershipEntry.Context::NEW;
        Map[2] := MembershipEntry.Context::REGRET;
        Map[3] := MembershipEntry.Context::RENEW;
        Map[4] := MembershipEntry.Context::AUTORENEW;
        Map[5] := MembershipEntry.Context::UPGRADE;
        Map[6] := MembershipEntry.Context::EXTEND;
        Map[7] := MembershipEntry.Context::CANCEL;
    end;
}

