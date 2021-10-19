codeunit 6151241 "NPR Purchase Ord Mgt"
{
    var
        TrailingPurchOrdersSetup: Record "NPR Trail. Purch. Orders Setup";
        PurchHeader: Record "Purchase Header";

    procedure OnOpenPage(var TrailingPurchOrdersSetup: Record "NPR Trail. Purch. Orders Setup")
    begin
        if not TrailingPurchOrdersSetup.Get(UserId) then begin
            TrailingPurchOrdersSetup.LockTable();
            TrailingPurchOrdersSetup."User ID" := CopyStr(UserId, 1, MaxStrLen(TrailingPurchOrdersSetup."User ID"));
            TrailingPurchOrdersSetup."Use Work Date as Base" := true;
            TrailingPurchOrdersSetup."Period Length" := TrailingPurchOrdersSetup."Period Length"::Month;
            TrailingPurchOrdersSetup."Value to Calculate" := TrailingPurchOrdersSetup."Value to Calculate"::"No. of Orders";
            TrailingPurchOrdersSetup."Chart Type" := TrailingPurchOrdersSetup."Chart Type"::"Stacked Column";
            TrailingPurchOrdersSetup.Insert();
        end;
    end;

    procedure DrillDown(var BusChartBuf: Record "Business Chart Buffer")
    var
        PurchaseHeader: Record "Purchase Header";
        ToDate: Date;
        Measure: Integer;
    begin
        Measure := BusChartBuf."Drill-Down Measure Index";
        if (Measure < 0) or (Measure > 3) then
            exit;
        TrailingPurchOrdersSetup.Get(UserId);
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        if TrailingPurchOrdersSetup."Show Orders" = TrailingPurchOrdersSetup."Show Orders"::"Delayed Orders" then
            PurchaseHeader.SetFilter("Posting Date", '<%1', TrailingPurchOrdersSetup.GetStartDate());
        if Evaluate(PurchaseHeader.Status, BusChartBuf.GetMeasureValueString(Measure), 9) then
            PurchaseHeader.SetRange(Status, PurchaseHeader.Status);

        ToDate := BusChartBuf.GetXValueAsDate(BusChartBuf."Drill-Down X Index");
        PurchaseHeader.SetRange("Document Date", 0D, ToDate);
        PAGE.Run(PAGE::"Purchase Order List", PurchaseHeader);
    end;

    procedure UpdateData(var BusChartBuf: Record "Business Chart Buffer")
    var
        ChartToStatusMap: array[4] of Enum "Purchase Document Status";
        ToDate: array[5] of Date;
        FromDate: array[5] of Date;
        Value: Decimal;
        TotalValue: Decimal;
        ColumnNo: Integer;
        PurchHeaderStatus: Integer;
    begin
        TrailingPurchOrdersSetup.Get(UserId);
        BusChartBuf.Initialize();
        BusChartBuf."Period Length" := TrailingPurchOrdersSetup."Period Length";
        BusChartBuf.SetPeriodXAxis();

        CreateMap(ChartToStatusMap);
        for PurchHeaderStatus := 1 to ArrayLen(ChartToStatusMap) do begin
            PurchHeader.Status := ChartToStatusMap[PurchHeaderStatus];
            BusChartBuf.AddMeasure(Format(PurchHeader.Status), PurchHeader.Status, BusChartBuf."Data Type"::Decimal, TrailingPurchOrdersSetup.GetChartType());
        end;

        if CalcPeriods(FromDate, ToDate, BusChartBuf) then begin
            BusChartBuf.AddPeriods(ToDate[1], ToDate[ArrayLen(ToDate)]);

            for PurchHeaderStatus := 1 to ArrayLen(ChartToStatusMap) do begin
                TotalValue := 0;
                for ColumnNo := 1 to ArrayLen(ToDate) do begin
                    Value := GetPurchOrderValue(ChartToStatusMap[PurchHeaderStatus], FromDate[ColumnNo], ToDate[ColumnNo]);
                    if ColumnNo = 1 then
                        TotalValue := Value
                    else
                        TotalValue += Value;
                    BusChartBuf.SetValueByIndex(PurchHeaderStatus - 1, ColumnNo - 1, TotalValue);
                end;
            end;
        end;
    end;

    local procedure CalcPeriods(var FromDate: array[5] of Date; var ToDate: array[5] of Date; var BusChartBuf: Record "Business Chart Buffer"): Boolean
    var
        MaxPeriodNo: Integer;
        i: Integer;
    begin
        MaxPeriodNo := ArrayLen(ToDate);
        ToDate[MaxPeriodNo] := TrailingPurchOrdersSetup.GetStartDate();
        if ToDate[MaxPeriodNo] = 0D then
            exit(false);
        for i := MaxPeriodNo downto 1 do begin
            if i > 1 then begin
                FromDate[i] := BusChartBuf.CalcFromDate(ToDate[i]);
                ToDate[i - 1] := FromDate[i] - 1;
            end else
                FromDate[i] := 0D
        end;
        exit(true);
    end;

    local procedure GetPurchOrderValue(Status: Enum "Purchase Document Status"; FromDate: Date; ToDate: Date): Decimal
    begin
        if TrailingPurchOrdersSetup."Value to Calculate" = TrailingPurchOrdersSetup."Value to Calculate"::"No. of Orders" then
            exit(GetPurchOrderCount(Status, FromDate, ToDate));
        exit(GetPurchOrderAmount(Status, FromDate, ToDate));
    end;

    local procedure GetPurchOrderAmount(Status: Enum "Purchase Document Status"; FromDate: Date; ToDate: Date): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
        TrailingSalesOrderQry: Query "NPR Trailing Purch Order";
        Amount: Decimal;
        TotalAmount: Decimal;
    begin
        if TrailingPurchOrdersSetup."Show Orders" = TrailingPurchOrdersSetup."Show Orders"::"Delayed Orders" then
            TrailingSalesOrderQry.SetFilter(ShipmentDate, '<%1', TrailingPurchOrdersSetup.GetStartDate());

        TrailingSalesOrderQry.SetRange(Status, Status);
        TrailingSalesOrderQry.SetRange(DocumentDate, FromDate, ToDate);
        TrailingSalesOrderQry.Open();
        while TrailingSalesOrderQry.Read() do begin
            if TrailingSalesOrderQry.CurrencyCode = '' then
                Amount := TrailingSalesOrderQry.Amount
            else
                Amount := Round(TrailingSalesOrderQry.Amount / CurrExchRate.ExchangeRate(Today, TrailingSalesOrderQry.CurrencyCode));
            TotalAmount := TotalAmount + Amount;
        end;
        exit(TotalAmount);
    end;

    local procedure GetPurchOrderCount(Status: Enum "Purchase Document Status"; FromDate: Date; ToDate: Date): Decimal
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        if TrailingPurchOrdersSetup."Show Orders" = TrailingPurchOrdersSetup."Show Orders"::"Delayed Orders" then
            PurchHeader.SetFilter("Posting Date", '<%1', TrailingPurchOrdersSetup.GetStartDate())
        else
            PurchHeader.SetRange("Posting Date");
        PurchHeader.SetRange(Status, Status);
        PurchHeader.SetRange("Document Date", FromDate, ToDate);
        exit(PurchHeader.Count());
    end;

    procedure CreateMap(var Map: array[4] of Enum "Purchase Document Status")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        Map[1] := PurchaseHeader.Status::Released;
        Map[2] := PurchaseHeader.Status::"Pending Prepayment";
        Map[3] := PurchaseHeader.Status::"Pending Approval";
        Map[4] := PurchaseHeader.Status::Open;
    end;
}