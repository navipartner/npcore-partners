codeunit 6059818 "NPR POS Statistics Mgt."
{
    Access = Internal;

    procedure FillSingleStatsBuffer(var POSSingleStatsBuffer: Record "NPR POS Single Stats Buffer"; var POSEntry: Record "NPR POS Entry")
    begin
        POSSingleStatsBuffer.Init();
        POSSingleStatsBuffer."Entry No." := POSEntry."Entry No.";
        POSSingleStatsBuffer."Document No." := POSEntry."Document No.";
        POSSingleStatsBuffer."POS Unit No." := POSEntry."POS Unit No.";
        POSSingleStatsBuffer."Discount Amount" := POSEntry."Discount Amount";
        POSSingleStatsBuffer."Tax Amount" := POSEntry."Tax Amount";
        POSSingleStatsBuffer."Amount Incl. Tax" := POSEntry."Amount Incl. Tax";
        POSSingleStatsBuffer."Sales Quantity" := POSEntry."Sales Quantity";
        POSSingleStatsBuffer."Return Sales Quantity" := POSEntry."Return Sales Quantity";

        GetAmountData(POSEntry."Entry No.", POSSingleStatsBuffer);

        POSSingleStatsBuffer.Insert();
    end;

    procedure FillCurrentStatsBuffer(var POSCurrentStatsBuffer: Record "NPR POS Single Stats Buffer"; var POSSale: Record "NPR POS Sale")
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        if not POSSaleLine.FindSet() then
            exit;

        POSCurrentStatsBuffer.Init();
        POSCurrentStatsBuffer."Document No." := POSSale."Sales Ticket No.";
        POSCurrentStatsBuffer."POS Unit No." := POSSale."Register No.";

        repeat
            if POSSaleLine.Quantity > 0 then
                POSCurrentStatsBuffer."Sales Quantity" += POSSaleLine.Quantity
            else
                POSCurrentStatsBuffer."Return Sales Quantity" -= POSSaleLine.Quantity;

            POSCurrentStatsBuffer."Cost Amount" += GetCostAmount(POSSaleLine) * POSSaleLine.Quantity;
            POSCurrentStatsBuffer."Profit Amount" += POSSaleLine.Amount - (GetCostAmount(POSSaleLine) * POSSaleLine.Quantity);
            POSCurrentStatsBuffer."Sales Amount" += POSSaleLine.Amount;
            POSCurrentStatsBuffer."Discount Amount" += POSSaleLine."Discount Amount";
            POSCurrentStatsBuffer."Tax Amount" += POSSaleLine."Amount Including VAT" - POSSaleLine.Amount;
            POSCurrentStatsBuffer."Amount Incl. Tax" += POSSaleLine."Amount Including VAT";
        until POSSaleLine.Next() = 0;

        POSCurrentStatsBuffer."Profit %" := CalculatePercentAmount(POSCurrentStatsBuffer."Sales Amount" - POSCurrentStatsBuffer."Cost Amount", POSCurrentStatsBuffer."Sales Amount");
        POSCurrentStatsBuffer.Insert();
    end;

    procedure TryGetPOSEntry(var POSEntry: Record "NPR POS Entry"; POSUnitNo: Code[10]): Boolean
    begin
        POSEntry.SetLoadFields("Document No.", "POS Unit No.", "Discount Amount", "Tax Amount", "Amount Incl. Tax", "Sales Quantity", "Return Sales Quantity");
        POSEntry.SetRange("POS Unit No.", POSUnitNo);
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale");
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Posted);

        exit(POSEntry.FindLast());
    end;

    local procedure GetAmountData(EntryNo: Integer; var POSSingleStatsBuffer: Record "NPR POS Single Stats Buffer")
    var
        POSSingleStatsQuery: Query "NPR POS Single Statistics";
    begin
        POSSingleStatsQuery.SetRange("Entry_No_", EntryNo);
        POSSingleStatsQuery.Open();
        while POSSingleStatsQuery.Read() do begin
            POSSingleStatsBuffer."Cost Amount" -= POSSingleStatsQuery.Cost_Amount_Actual;
            POSSingleStatsBuffer."Sales Amount" += POSSingleStatsQuery.Sales_Amount_Actual;
        end;

        if POSSingleStatsBuffer."Sales Amount" <> 0 then
            POSSingleStatsBuffer."Profit %" := (POSSingleStatsBuffer."Sales Amount" - POSSingleStatsBuffer."Cost Amount") / POSSingleStatsBuffer."Sales Amount"
        else
            POSSingleStatsBuffer."Profit %" := 0;
    end;

    procedure FillTurnoverData(var POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer"; BaseCalculationDate: Date; POSStoreCode: Code[10]; POSUnitNo: Code[10])
    begin
        ClearData(POSTurnoverCalcBuffer);

        SetFilters(POSStoreCode, POSUnitNo);

        if BaseCalculationDate = 0D then
            BaseCalculationDate := WorkDate();

        FillDataCurrentDay(POSTurnoverCalcBuffer, BaseCalculationDate);

        FillDataCurrentWeek(POSTurnoverCalcBuffer, BaseCalculationDate);
        FillDataLastWeek(POSTurnoverCalcBuffer, BaseCalculationDate);

        FillDataCurrentMonth(POSTurnoverCalcBuffer, BaseCalculationDate);
        FillDataLastMonth(POSTurnoverCalcBuffer, BaseCalculationDate);

        FillDataCurrentYear(POSTurnoverCalcBuffer, BaseCalculationDate);
        FillDataLastYear(POSTurnoverCalcBuffer, BaseCalculationDate);
    end;

    local procedure FillDataCurrentDay(var POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer"; BaseDate: Date)
    var
        FromDateCurrent: Date;
        ToDateCurrent: Date;
        FromDateLast: Date;
        ToDateLast: Date;
        DayLastText: Label 'Day - This Current';
    begin
        FromDateCurrent := BaseDate;
        ToDateCurrent := FromDateCurrent;
        FromDateLast := CalcDate('<-1Y>', BaseDate);
        ToDateLast := FromDateLast;

        CreateHeaderRow(POSTurnoverCalcBuffer, DayLastText, Format(FromDateCurrent), Format(FromDateLast));
        CreateDataBlock(POSTurnoverCalcBuffer, FromDateCurrent, ToDateCurrent, FromDateLast, ToDateLast);
    end;

    local procedure FillDataCurrentWeek(var POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer"; BaseDate: Date)
    var
        FromDateCurrent: Date;
        ToDateCurrent: Date;
        FromDateLast: Date;
        ToDateLast: Date;
        WeekNo: Integer;
        CurrYear: Integer;
        WeekThisCurrentText: Label 'Week - This Current';
    begin
        WeekNo := Date2DWY(BaseDate, 2);
        CurrYear := Date2DWY(BaseDate, 3);

        FromDateCurrent := DWY2Date(1, WeekNo, CurrYear);
        ToDateCurrent := DWY2Date(7, WeekNo, CurrYear);
        FromDateLast := DWY2Date(1, WeekNo, CurrYear - 1);
        ToDateLast := DWY2Date(7, WeekNo, CurrYear - 1);
        CreateHeaderRow(POSTurnoverCalcBuffer, WeekThisCurrentText, Format(FromDateCurrent) + '...' + Format(ToDateCurrent), Format(FromDateLast) + '...' + Format(ToDateLast));
        CreateDataBlock(POSTurnoverCalcBuffer, FromDateCurrent, ToDateCurrent, FromDateLast, ToDateLast);
    end;

    local procedure FillDataLastWeek(var POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer"; BaseDate: Date)
    var
        FromDateCurrent: Date;
        ToDateCurrent: Date;
        FromDateLast: Date;
        ToDateLast: Date;
        WeekNo: Integer;
        CurrYear: Integer;
        WeekLastText: Label 'Week - Last';
    begin
        WeekNo := Date2DWY(BaseDate, 2);
        CurrYear := Date2DWY(BaseDate, 3);

        FromDateCurrent := DWY2Date(1, WeekNo, CurrYear) - 7;
        ToDateCurrent := DWY2Date(7, WeekNo, CurrYear) - 7;
        FromDateLast := CalcDate('<-1Y>', DWY2Date(1, WeekNo, CurrYear) - 7);
        ToDateLast := CalcDate('<-1Y>', DWY2Date(7, WeekNo, CurrYear) - 7);
        CreateHeaderRow(POSTurnoverCalcBuffer, WeekLastText, Format(FromDateCurrent) + '...' + Format(ToDateCurrent), Format(FromDateLast) + '...' + Format(ToDateLast));
        CreateDataBlock(POSTurnoverCalcBuffer, FromDateCurrent, ToDateCurrent, FromDateLast, ToDateLast);
    end;

    local procedure FillDataCurrentMonth(var POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer"; BaseDate: Date)
    var
        FromDateCurrent: Date;
        ToDateCurrent: Date;
        FromDateLast: Date;
        ToDateLast: Date;
        MonthThisCurrentText: Label 'Month - This Current';
    begin
        FromDateCurrent := CalcDate('<CM><-1M><+1D>', BaseDate);
        ToDateCurrent := CalcDate('<CM>', BaseDate);
        FromDateLast := CalcDate('<CM><-1M><-1Y>', BaseDate);
        ToDateLast := CalcDate('<CM><-1Y>', BaseDate);
        CreateHeaderRow(POSTurnoverCalcBuffer, MonthThisCurrentText, Format(FromDateCurrent) + '...' + Format(ToDateCurrent), Format(FromDateLast) + '...' + Format(ToDateLast));
        CreateDataBlock(POSTurnoverCalcBuffer, FromDateCurrent, ToDateCurrent, FromDateLast, ToDateLast);
    end;

    local procedure FillDataLastMonth(var POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer"; BaseDate: Date)
    var
        FromDateCurrent: Date;
        ToDateCurrent: Date;
        FromDateLast: Date;
        ToDateLast: Date;
        MonthLastText: Label 'Month - Last';
    begin
        FromDateCurrent := CalcDate('<CM><-2M><+1D>', BaseDate);
        ToDateCurrent := CalcDate('<-CM><-1D>', BaseDate);
        FromDateLast := CalcDate('<CM><-2M><+1D><-1Y>', BaseDate);
        ToDateLast := CalcDate('<-CM><-1D><-1Y>', BaseDate);
        CreateHeaderRow(POSTurnoverCalcBuffer, MonthLastText, Format(FromDateCurrent) + '...' + Format(ToDateCurrent), Format(FromDateLast) + '...' + Format(ToDateLast));
        CreateDataBlock(POSTurnoverCalcBuffer, FromDateCurrent, ToDateCurrent, FromDateLast, ToDateLast);
    end;

    local procedure FillDataCurrentYear(var POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer"; BaseDate: Date)
    var
        FromDateCurrent: Date;
        ToDateCurrent: Date;
        FromDateLast: Date;
        ToDateLast: Date;
        YearThisCurrentText: Label 'Year - This Current';
    begin
        FromDateCurrent := DMY2Date(1, 1, Date2DMY(BaseDate, 3));
        ToDateCurrent := BaseDate - 1;
        FromDateLast := DMY2Date(1, 1, Date2DMY(BaseDate, 3) - 1);
        ToDateLast := CalcDate('<-1Y>', BaseDate - 1);
        CreateHeaderRow(POSTurnoverCalcBuffer, YearThisCurrentText, Format(FromDateCurrent) + '...' + Format(ToDateCurrent), Format(FromDateLast) + '...' + Format(ToDateLast));
        CreateDataBlock(POSTurnoverCalcBuffer, FromDateCurrent, ToDateCurrent, FromDateLast, ToDateLast);
    end;

    local procedure FillDataLastYear(var POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer"; BaseDate: Date)
    var
        FromDateCurrent: Date;
        ToDateCurrent: Date;
        FromDateLast: Date;
        ToDateLast: Date;
        YearLastText: Label 'Year - Last';
    begin
        FromDateCurrent := DMY2Date(1, 1, Date2DMY(BaseDate, 3) - 1);
        ToDateCurrent := CalcDate('<-1Y>', BaseDate - 1);
        FromDateLast := DMY2Date(1, 1, Date2DMY(BaseDate, 3) - 2);
        ToDateLast := CalcDate('<-2Y>', BaseDate - 1);
        CreateHeaderRow(POSTurnoverCalcBuffer, YearLastText, Format(FromDateCurrent) + '...' + Format(ToDateCurrent), Format(FromDateLast) + '...' + Format(ToDateLast));
        CreateDataBlock(POSTurnoverCalcBuffer, FromDateCurrent, ToDateCurrent, FromDateLast, ToDateLast);
    end;

    local procedure CreateHeaderRow(var POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer"; Description: Text[50]; Current: Text[100]; Last: Text[100])
    begin
        CreateBuffer(POSTurnoverCalcBuffer, true, Description, Current, Last, '', 'StrongAccent');
    end;

    local procedure CreateDataBlock(var POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer"; FromDateCurrent: Date; ToDateCurrent: Date; FromDateLast: Date; ToDateLast: Date)
    var
        NetAmountCurrent: Decimal;
        CostAmountCurrent: Decimal;
        ProfitAmountCurrent: Decimal;
        ProfitPctCurrent: Decimal;
        NetAmountLast: Decimal;
        CostAmountLast: Decimal;
        ProfitAmountLast: Decimal;
        ProfitPctLast: Decimal;
        StrongLbl: Label 'Strong';
        NetText: Label 'Net';
        CostOfSalesText: Label 'Cost of Sales';
        ProfitText: Label 'Profit';
        ProfitPctText: Label 'Profit %';
    begin
        CalcRowData(FromDateCurrent, ToDateCurrent, NetAmountCurrent, CostAmountCurrent, ProfitAmountCurrent, ProfitPctCurrent);
        CalcRowData(FromDateLast, ToDateLast, NetAmountLast, CostAmountLast, ProfitAmountLast, ProfitPctLast);

        CreateBuffer(POSTurnoverCalcBuffer, false, NetText, FormatDecimal(NetAmountCurrent), FormatDecimal(NetAmountLast), CalcAndFormatDiff(NetAmountCurrent, NetAmountLast), StrongLbl);
        CreateBuffer(POSTurnoverCalcBuffer, false, CostOfSalesText, FormatDecimal(CostAmountCurrent), FormatDecimal(CostAmountLast), CalcAndFormatDiff(CostAmountCurrent, CostAmountLast), StrongLbl);
        CreateBuffer(POSTurnoverCalcBuffer, false, ProfitText, FormatDecimal(ProfitAmountCurrent), FormatDecimal(ProfitAmountLast), CalcAndFormatDiff(ProfitAmountCurrent, ProfitAmountLast), StrongLbl);
        CreateBuffer(POSTurnoverCalcBuffer, false, ProfitPctText, FormatDecimal(ProfitPctCurrent), FormatDecimal(ProfitAmountLast), CalcAndFormatDiff(ProfitPctCurrent, ProfitPctLast), StrongLbl);
    end;

    local procedure CreateBuffer(var POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer"; IsHeader: Boolean; Description: Text[50]; Current: Text[100]; Last: Text[100]; Diff: Text[100]; RowStyle: Text[20])
    begin
        POSTurnoverCalcBuffer.Init();
        POSTurnoverCalcBuffer."Entry No." := EntryNo;
        POSTurnoverCalcBuffer.IsHeader := IsHeader;
        POSTurnoverCalcBuffer.Description := Description;
        POSTurnoverCalcBuffer."This Year" := Current;
        POSTurnoverCalcBuffer."Last Year" := Last;
        POSTurnoverCalcBuffer."Difference %" := Diff;
        POSTurnoverCalcBuffer."Row Style" := RowStyle;
        POSTurnoverCalcBuffer.Insert();

        EntryNo += 1;
    end;

    local procedure CalcRowData(FromDate: Date; ToDate: Date; var NetAmount: Decimal; var CostOfSalesAmount: Decimal; var ProfitAmount: Decimal; var ProfitPct: Decimal)
    begin
        NetAmount := 0;
        CostOfSalesAmount := 0;
        ProfitAmount := 0;

        CalcDirectSaleAmounts(FromDate, ToDate, NetAmount, CostOfSalesAmount);
        CalcCreditSaleInvoiceAmounts(FromDate, ToDate, NetAmount, CostOfSalesAmount);
        CalcCreditSaleCrMemoAmounts(FromDate, ToDate, NetAmount, CostOfSalesAmount);

        ProfitAmount := NetAmount - CostOfSalesAmount;

        if CostOfSalesAmount <> 0 then
            ProfitPct := Round(100 * ProfitAmount / CostOfSalesAmount, 2);
    end;

    local procedure CalcDirectSaleAmounts(FromDate: Date; ToDate: Date; var NetAmount: Decimal; var CostOfSalesAmount: Decimal)
    var
        POSTurnoverQuery: Query "NPR POS Turnover";
    begin
        if POSStoreCode <> '' then
            POSTurnoverQuery.SetFilter(POS_Store_Code, POSStoreCode);
        if POSUnitNo <> '' then
            POSTurnoverQuery.SetFilter(POS_Unit_No, POSUnitNo);
        POSTurnoverQuery.SetRange(Posting_Date, FromDate, ToDate);
        POSTurnoverQuery.Open();

        while POSTurnoverQuery.Read() do begin
            NetAmount += POSTurnoverQuery.Sales_Amount_Actual;
            CostOfSalesAmount -= POSTurnoverQuery.Cost_Amount_Actual;
        end;
    end;

    local procedure CalcCreditSaleInvoiceAmounts(FromDate: Date; ToDate: Date; var NetAmount: Decimal; var CostOfSalesAmount: Decimal)
    var
        POSCreditSalesInvoiceQuery: Query "NPR POS Credit Sales Invoice";
    begin
        if POSEntriesEmpty(FromDate, ToDate) then
            exit;

        if POSStoreCode <> '' then
            POSCreditSalesInvoiceQuery.SetFilter(POS_Store_Code, POSStoreCode);
        if POSUnitNo <> '' then
            POSCreditSalesInvoiceQuery.SetFilter(POS_Unit_No, POSUnitNo);

        POSCreditSalesInvoiceQuery.SetRange(Posting_Date, FromDate, ToDate);
        POSCreditSalesInvoiceQuery.SetRange(Sales_Document_Type, Enum::"Sales Document Type"::Invoice);
        POSCreditSalesInvoiceQuery.SetFilter(Sales_Document_No_, '<>%1', '');
        POSCreditSalesInvoiceQuery.Open();

        while POSCreditSalesInvoiceQuery.Read() do begin
            NetAmount += POSCreditSalesInvoiceQuery.Sales_Amount_Actual;
            CostOfSalesAmount -= POSCreditSalesInvoiceQuery.Cost_Amount_Actual;
        end;
    end;

    local procedure CalcCreditSaleCrMemoAmounts(FromDate: Date; ToDate: Date; var NetAmount: Decimal; var CostOfSalesAmount: Decimal)
    var
        POSCreditSalesCrMemoQuery: Query "NPR POS Credit Sales Cr. Memo";
    begin
        if POSEntriesEmpty(FromDate, ToDate) then
            exit;

        if POSStoreCode <> '' then
            POSCreditSalesCrMemoQuery.SetFilter(POS_Store_Code, POSStoreCode);
        if POSUnitNo <> '' then
            POSCreditSalesCrMemoQuery.SetFilter(POS_Unit_No, POSUnitNo);

        POSCreditSalesCrMemoQuery.SetRange(Posting_Date, FromDate, ToDate);
        POSCreditSalesCrMemoQuery.SetRange(Sales_Document_Type, Enum::"Sales Document Type"::"Credit Memo");
        POSCreditSalesCrMemoQuery.SetFilter(Sales_Document_No_, '<>%1', '');
        POSCreditSalesCrMemoQuery.Open();

        while POSCreditSalesCrMemoQuery.Read() do begin
            NetAmount += POSCreditSalesCrMemoQuery.Sales_Amount_Actual;
            CostOfSalesAmount -= POSCreditSalesCrMemoQuery.Cost_Amount_Actual;
        end;
    end;

    local procedure POSEntriesEmpty(FromDate: Date; ToDate: Date): Boolean
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("Posting Date", FromDate, ToDate);
        POSEntry.SetRange("Sales Document Type", Enum::"Sales Document Type"::"Credit Memo");
        POSEntry.SetFilter("Sales Document No.", '<>%1', '');

        exit(POSEntry.IsEmpty());
    end;

    local procedure CalcAndFormatDiff(Current: Decimal; Last: Decimal): Text[100]
    begin
        if Last = 0 then
            exit(FormatDecimal(0));

        exit(FormatDecimal(Round((Last - Current) * 100 / Last, 0.01)));
    end;

    local procedure SetFilters(StoreCode: Code[10]; UnitNo: Code[10])
    begin
        POSStoreCode := StoreCode;
        POSUnitNo := UnitNo;
    end;

    local procedure ClearData(var POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer")
    begin
        POSTurnoverCalcBuffer.DeleteAll();
        EntryNo := 1;
    end;

    local procedure FormatDecimal(Value: Decimal): Text[100]
    begin
        exit(Format(Value, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'))
    end;

    local procedure CalculatePercentAmount(Amount: Decimal; Total: Decimal): Decimal
    begin
        if (Amount = 0) or (Total = 0) then
            exit(0);

        exit(Amount / Total);
    end;

    local procedure GetCostAmount(POSSaleLine: Record "NPR POS Sale Line") Cost: Decimal
    var
        Item: Record Item;
    begin
        Cost := POSSaleLine."Unit Cost (LCY)";

        if POSSaleLine.Type <> POSSaleLine.Type::Item then
            exit;

        Item.SetLoadFields("Last Direct Cost", "Unit Cost");
        if not Item.Get(POSSaleLine."No.") then
            exit;

        if Item."Last Direct Cost" <> 0 then
            Cost := Item."Last Direct Cost"
        else
            Cost := Item."Unit Cost";
    end;

    procedure FillSalePersonTop20(var SalespersonStatsBuffer: Record "NPR POS Salesperson St Buffer" temporary; FromDate: Date; ToDate: Date)
    var
        POSSalespersonStatsQuery: Query "NPR POS Salesperson Stats";
    begin
        SalespersonStatsBuffer.DeleteAll();

        POSSalespersonStatsQuery.SetRange(Posting_Date, FromDate, ToDate);
        POSSalespersonStatsQuery.Open();
        while POSSalespersonStatsQuery.Read() do begin
            SalespersonStatsBuffer.Init();
            SalespersonStatsBuffer."Entry No." += 1;
            SalespersonStatsBuffer.Name := POSSalespersonStatsQuery.Name;
            SalespersonStatsBuffer."Sales (LCY)" := POSSalespersonStatsQuery.Sales_Amount_Actual;
            SalespersonStatsBuffer."Discount Amount" := -POSSalespersonStatsQuery.Discount_Amount;
            SalespersonStatsBuffer."Discount %" := CalculatePercentAmount(SalespersonStatsBuffer."Discount Amount", SalespersonStatsBuffer."Discount Amount" + SalespersonStatsBuffer."Sales (LCY)");
            SalespersonStatsBuffer."Profit (LCY)" := POSSalespersonStatsQuery.Sales_Amount_Actual + POSSalespersonStatsQuery.Cost_Amount_Actual;
            SalespersonStatsBuffer."Profit %" := CalculatePercentAmount(SalespersonStatsBuffer."Profit (LCY)", SalespersonStatsBuffer."Sales (LCY)");
            SalespersonStatsBuffer.Insert();
        end;
    end;

    var
        POSStoreCode: Code[10];
        POSUnitNo: Code[10];
        EntryNo: Integer;
}