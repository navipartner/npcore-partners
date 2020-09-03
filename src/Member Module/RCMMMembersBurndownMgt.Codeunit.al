codeunit 6060149 "NPR RC MM Members.Burndown Mgt"
{
    // TM1.16/TSA/20160816  CASE 233430 Transport TM1.16 - 19 July 2016
    // #302920/TSA /20180124 CASE 302920 Added auto-renew


    trigger OnRun()
    begin
    end;

    var
        MembershipBurndownSetup: Record "NPR RC Members. Burndown Setup";
        MembershipEntry: Record "NPR MM Membership Entry";

    procedure OnPageOpen(var vMembershipBurndownSetup: Record "NPR RC Members. Burndown Setup")
    begin
        with vMembershipBurndownSetup do
            if not Get(UserId) then begin
                "User ID" := UserId;
                "Use Work Date as Base" := true;
                "Period Length" := "Period Length"::Month;
                "Value to Calculate" := "Value to Calculate"::MEMBERSHIP_COUNT;
                "Chart Type" := "Chart Type"::"Stacked Area";
                "Show Change As" := "Show Change As"::ACK;
                Evaluate("StartDate Offset", '<+12M>');
                Insert;
            end;
    end;

    procedure DrillDown(var BusChartBuf: Record "Business Chart Buffer")
    var
        SalesHeader: Record "Sales Header";
        ToDate: Date;
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
            BusChartBuf.AddMeasure(Format(MembershipEntry.Context), MembershipEntry.Context, BusChartBuf."Data Type"::Decimal, MembershipBurndownSetup.GetChartType);
        end;

        if (CalcPeriods(FromDate, ToDate, BusChartBuf)) then begin
            BusChartBuf.AddPeriods(ToDate[1], ToDate[ArrayLen(ToDate)]);

            for MembershipEntryContext := 1 to ArrayLen(ChartToStatusMap) do begin
                TotalValue := 0;
                for ColumnNo := 1 to ArrayLen(ToDate) do begin
                    Value := GetValue(ChartToStatusMap[MembershipEntryContext], FromDate[ColumnNo], ToDate[ColumnNo]);
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

    local procedure GetValue(Status: Option; FromDate: Date; ToDate: Date): Decimal
    begin
        if (MembershipBurndownSetup."Value to Calculate" = MembershipBurndownSetup."Value to Calculate"::MEMBERSHIP_COUNT) then
            exit(GetCount(Status, FromDate, ToDate));

        exit(GetAmount(Status, FromDate, ToDate));
    end;

    local procedure GetAmount(Status: Option; FromDate: Date; ToDate: Date): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
        Amount: Decimal;
        TotalAmount: Decimal;
    begin

        MembershipEntry.Reset();
        MembershipEntry.SetFilter(Context, '=%1', Status);
        MembershipEntry.SetRange("Valid From Date", FromDate, ToDate);
        MembershipEntry.SetFilter(Blocked, '=%1', false);

        exit(TotalAmount);
    end;

    local procedure GetCount(Status: Option; FromDate: Date; ToDate: Date): Decimal
    var
        EntryCount: Integer;
    begin
        EntryCount := 0;

        MembershipEntry.Reset();
        MembershipEntry.SetFilter(Context, '=%1', Status);
        MembershipEntry.SetRange("Valid From Date", FromDate, ToDate);
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        EntryCount := MembershipEntry.Count;

        MembershipEntry.Reset();
        MembershipEntry.SetFilter(Context, '=%1', Status);
        MembershipEntry.SetRange("Valid Until Date", FromDate, ToDate);
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        EntryCount -= MembershipEntry.Count;

        exit(EntryCount);
    end;

    procedure CreateMap(var Map: array[7] of Integer)
    var
        SalesHeader: Record "Sales Header";
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

