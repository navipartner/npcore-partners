table 6014487 "NPR POS Turnover Calc. Buffer"
{
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(10; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }

        field(20; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
        }
        field(30; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(40; "This Year"; Text[100])
        {
            Caption = 'This Year';
            DataClassification = CustomerContent;
        }
        field(50; "Last Year"; Text[100])
        {
            Caption = 'Last Year';
            DataClassification = CustomerContent;
        }
        field(60; Difference; Text[100])
        {
            Caption = 'Difference';
            DataClassification = CustomerContent;
        }
        field(70; "Difference %"; Text[100])
        {
            Caption = 'Difference %';
            DataClassification = CustomerContent;
        }
        field(80; "Row Style"; Text[20])
        {
            Caption = 'Row Style';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        GlobalPOSStore: Record "NPR POS Store";
        GlobalPOSUnit: Record "NPR POS Unit";
        DayLastText: Label 'Day - Last';
        WeekThisCurrentText: Label 'Week - This Current';
        WeekLastText: Label 'Week - Last';
        MonthThisCurrentText: Label 'Month - This Current';
        MonthLastText: Label 'Month - Last';
        YearThisCurrentText: Label 'Year - This Current';
        YearLastText: Label 'Year - Last';
        NetText: Label 'Net';
        CostOfSalesText: Label 'Cost of Sales';
        ProfitText: Label 'Profit';
        ProfitPctText: Label 'Profit %';

    procedure FillData(BaseCalculationDate: Date; var POSStore: Record "NPR POS Store"; var POSUnit: Record "NPR POS Unit";
        var Buffer: Record "NPR POS Turnover Calc. Buffer")
    var
        POSEntry: Record "NPR POS Entry";
        i: Integer;
        FromDate, ToDate : array[2] of Date;
        DayOfWeek, WeekNo, CurrYear : Integer;
    begin
        GlobalPOSStore.CopyFilters(POSStore);
        GlobalPOSUnit.CopyFilters(POSUnit);

        Buffer.Reset();
        Buffer.DeleteAll();
        i := 1;

        if BaseCalculationDate = 0D then
            BaseCalculationDate := WorkDate();

        FromDate[1] := BaseCalculationDate - 1;
        ToDate[1] := BaseCalculationDate - 1;
        FromDate[2] := CalcDate('<-1Y>', BaseCalculationDate - 1);
        ToDate[2] := CalcDate('<-1Y>', BaseCalculationDate - 1);

        CreateHeaderRow(Buffer, i, DayLastText, Format(FromDate[1]), Format(FromDate[2]));
        CreateDataBlock(FromDate[1], ToDate[1], FromDate[2], ToDate[2], Buffer, i);

        DayOfWeek := Date2DWY(BaseCalculationDate, 1);
        WeekNo := Date2DWY(BaseCalculationDate, 2);
        CurrYear := Date2DWY(BaseCalculationDate, 3);
        FromDate[1] := DWY2Date(1, WeekNo, CurrYear);
        ToDate[1] := DWY2Date(7, WeekNo, CurrYear);
        FromDate[2] := DWY2Date(1, WeekNo, CurrYear - 1);
        ToDate[2] := DWY2Date(7, WeekNo, CurrYear - 1);
        CreateHeaderRow(Buffer, i, WeekThisCurrentText, Format(FromDate[1]) + '...' + Format(ToDate[1]),
            Format(FromDate[2]) + '...' + Format(ToDate[2]));
        CreateDataBlock(FromDate[1], ToDate[1], FromDate[2], ToDate[2], Buffer, i);

        FromDate[1] := DWY2Date(1, WeekNo, CurrYear) - 7;
        ToDate[1] := DWY2Date(7, WeekNo, CurrYear) - 7;
        FromDate[2] := CalcDate('<-1Y>', DWY2Date(1, WeekNo, CurrYear) - 7);
        ToDate[2] := CalcDate('<-1Y>', DWY2Date(7, WeekNo, CurrYear) - 7);
        CreateHeaderRow(Buffer, i, WeekLastText, Format(FromDate[1]) + '...' + Format(ToDate[1]),
            Format(FromDate[2]) + '...' + Format(ToDate[2]));
        CreateDataBlock(FromDate[1], ToDate[1], FromDate[2], ToDate[2], Buffer, i);

        FromDate[1] := CalcDate('<CM><-1M><+1D>', BaseCalculationDate);
        ToDate[1] := CalcDate('<CM>', BaseCalculationDate);
        FromDate[2] := CalcDate('<CM><-1M><-1Y>', BaseCalculationDate);
        ToDate[2] := CalcDate('<CM><-1Y>', BaseCalculationDate);
        CreateHeaderRow(Buffer, i, MonthThisCurrentText, Format(FromDate[1]) + '...' + Format(ToDate[1]),
            Format(FromDate[2]) + '...' + Format(ToDate[2]));
        CreateDataBlock(FromDate[1], ToDate[1], FromDate[2], ToDate[2], Buffer, i);

        FromDate[1] := CalcDate('<CM><-2M><+1D>', BaseCalculationDate);
        ToDate[1] := CalcDate('<CM><-2M>', BaseCalculationDate);
        FromDate[2] := CalcDate('<CM><-2M><+1D><-1Y>', BaseCalculationDate);
        ToDate[2] := CalcDate('<CM><-2M><-1Y>', BaseCalculationDate);
        CreateHeaderRow(Buffer, i, MonthLastText, Format(FromDate[1]) + '...' + Format(ToDate[1]),
            Format(FromDate[2]) + '...' + Format(ToDate[2]));
        CreateDataBlock(FromDate[1], ToDate[1], FromDate[2], ToDate[2], Buffer, i);

        FromDate[1] := DMY2Date(1, 1, Date2DMY(BaseCalculationDate, 3));
        ToDate[1] := BaseCalculationDate - 1;
        FromDate[2] := DMY2Date(1, 1, Date2DMY(BaseCalculationDate, 3) - 1);
        ToDate[2] := CalcDate('<-1Y>', BaseCalculationDate - 1);
        CreateHeaderRow(Buffer, i, YearThisCurrentText, Format(FromDate[1]) + '...' + Format(ToDate[1]),
            Format(FromDate[2]) + '...' + Format(ToDate[2]));
        CreateDataBlock(FromDate[1], ToDate[1], FromDate[2], ToDate[2], Buffer, i);

        FromDate[1] := DMY2Date(1, 1, Date2DMY(BaseCalculationDate, 3) - 1);
        ToDate[1] := CalcDate('<-1Y>', BaseCalculationDate - 1);
        FromDate[2] := DMY2Date(1, 1, Date2DMY(BaseCalculationDate, 3) - 2);
        ToDate[2] := CalcDate('<-2Y>', BaseCalculationDate - 1);
        CreateHeaderRow(Buffer, i, YearLastText, Format(FromDate[1]) + '...' + Format(ToDate[1]),
            Format(FromDate[2]) + '...' + Format(ToDate[2]));
        CreateDataBlock(FromDate[1], ToDate[1], FromDate[2], ToDate[2], Buffer, i);
    end;

    local procedure CreateHeaderRow(var Buffer: Record "NPR POS Turnover Calc. Buffer"; var i: Integer;
        Description: Text; ThisYearText: Text; LastYearText: Text)
    begin
        Buffer.Init();
        Buffer."Entry No." := i;
        Buffer.Indentation := 0;
        Buffer.Description := Description;
        Buffer."This Year" := ThisYearText;
        Buffer."Last Year" := LastYearText;
        Buffer."Row Style" := 'StrongAccent';
        Buffer.Insert();
        i := i + 1;
    end;

    local procedure CreateDataBlock(FromDate1: Date; ToDate1: Date; FromDate2: Date; ToDate2: Date;
        var Buffer: Record "NPR POS Turnover Calc. Buffer"; var i: Integer)
    var
        Values: array[10] of Decimal;
        Value1, Value2 : Decimal;
    begin
        CalcRowData(FromDate1, ToDate1,
            Values[1], Values[2], Values[3], Values[4]);
        CalcRowData(FromDate2, ToDate2,
            Values[5], Values[6], Values[7], Values[8]);

        Buffer.Init();
        Buffer."Entry No." := i;
        Buffer.Indentation := 1;
        Buffer.Description := NetText;
        if Values[1] <> 0 then
            Buffer."This Year" := Format(Values[1], 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        if Values[5] <> 0 then
            Buffer."Last Year" := Format(Values[5], 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        if (Values[5] - Values[1]) <> 0 then
            Buffer.Difference := Format(Values[5] - Values[1], 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        if Values[5] <> 0 then
            Buffer."Difference %" := Format(Round((Values[5] - Values[1]) * 100 / Values[5], 0.1), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        Buffer."Row Style" := 'Strong';
        Buffer.Insert();
        i := i + 1;

        Buffer.Init();
        Buffer."Entry No." := i;
        Buffer.Indentation := 1;
        Buffer.Description := CostOfSalesText;
        if Values[2] <> 0 then
            Buffer."This Year" := Format(Values[2], 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        if Values[6] <> 0 then
            Buffer."Last Year" := Format(Values[6], 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        if (Values[6] - Values[2]) <> 0 then
            Buffer.Difference := Format(Values[6] - Values[2], 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        if Values[6] <> 0 then
            Buffer."Difference %" := Format(Round((Values[6] - Values[2]) * 100 / Values[6], 0.1), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        Buffer."Row Style" := 'Strong';
        Buffer.Insert();
        i := i + 1;

        Buffer.Init();
        Buffer."Entry No." := i;
        Buffer.Indentation := 1;
        Buffer.Description := ProfitText;
        if Values[3] <> 0 then
            Buffer."This Year" := Format(Values[3], 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        if Values[7] <> 0 then
            Buffer."Last Year" := Format(Values[7], 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        if (Values[7] - Values[3]) <> 0 then
            Buffer.Difference := Format(Values[7] - Values[3], 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        if Values[7] <> 0 then
            Buffer."Difference %" := Format(Round((Values[7] - Values[3]) * 100 / Values[7], 0.1), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        Buffer."Row Style" := 'Strong';
        Buffer.Insert();
        i := i + 1;

        Buffer.Init();
        Buffer."Entry No." := i;
        Buffer.Indentation := 1;
        Buffer.Description := ProfitPctText;
        if Values[4] <> 0 then
            Buffer."This Year" := Format(Values[4], 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        if Values[8] <> 0 then
            Buffer."Last Year" := Format(Values[8], 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        if (Values[8] - Values[4]) <> 0 then
            Buffer.Difference := Format(Values[8] - Values[4], 0, '<Precision,2><sign><Integer Thousand><Decimals,3>');
        Buffer."Row Style" := 'Strong';
        Buffer.Insert();
        i := i + 1;
    end;

    local procedure CalcRowData(FromDate: Date; ToDate: Date; var NetAmount: Decimal; var CostOfSalesAmount: Decimal; var ProfitAmount: Decimal;
        var ProfitPct: Decimal)
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSTurnoverQuery: Query "NPR POS Turnover";
    begin
        NetAmount := 0;
        CostOfSalesAmount := 0;
        ProfitAmount := 0;

        if GlobalPOSStore.GetFilter(Code) <> '' then
            POSTurnoverQuery.SetFilter(POS_Store_Code, GlobalPOSStore.GetFilter(Code));
        if GlobalPOSUnit.GetFilter("No.") <> '' then
            POSTurnoverQuery.SetFilter(POS_Unit_No, GlobalPOSUnit.GetFilter("No."));
        POSTurnoverQuery.SetRange(Posting_Date, FromDate, ToDate);
        POSTurnoverQuery.Open();

        while POSTurnoverQuery.Read() do begin
            NetAmount := NetAmount + POSTurnoverQuery.Sales_Amount_Actual;
            CostOfSalesAmount := CostOfSalesAmount + POSTurnoverQuery.Cost_Amount_Actual;
        end;
        CostOfSalesAmount := -CostOfSalesAmount;
        ProfitAmount := NetAmount - CostOfSalesAmount;
        if CostOfSalesAmount <> 0 then
            ProfitPct := Round(100 * ProfitAmount / CostOfSalesAmount, 2);
    end;
}
