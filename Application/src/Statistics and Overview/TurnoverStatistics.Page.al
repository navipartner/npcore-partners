page 6014411 "NPR Turnover Statistics"
{
    Extensible = False;
    Caption = 'Turnover Statistics';
    PageType = CardPart;
    UsageCategory = None;


    layout
    {
        area(content)
        {
        }
    }

    actions
    {
    }

    trigger OnInit()
    var
        Year: Integer;
        LastDay: Date;
    begin
        Year := Date2DWY(CalcDate('<-1Y>', Today), 3);
        LastDay := DMY2Date(31, 12, Year);
        LastYear_W53 := Date2DWY(LastDay, 2) = 53;
    end;

    var
        Text10600000: Label '<-1W+1D>';
        Text10600001: Label '<-1M+1D>';
        Text10600002: Label '<-1Y+1D>';
        _DepartmentFilter: Code[50];
        _DateFilter: Text[30];
        DateFilterLast: Text[30];
        NettoLast: Decimal;
        Netto: Decimal;
        BarPct: Decimal;
        MidPct: Decimal;
        Int: Integer;
        D: Integer;
        W: Integer;
        Y: Integer;
        I: Integer;
        Limitation: Boolean;
        LastYear_W53: Boolean;

    internal procedure SetDateFilter(FromStart: Boolean; Value: Integer)
    var
        StartDate: Date;
        EndDate: Date;
        StartDateLast: Date;
        EndDateLast: Date;
        Weekday: Integer;
        Week: Integer;
        Month: Integer;
        Year: Integer;
        DayLbl: Label '%1', Locked = true;
        DateLbl: Label '%1..%2', Locked = true;
        YearLbl: Label '<-1Y>', Locked = true;
    begin

        if FromStart then begin
            case Value of
                1:
                    begin
                        _DateFilter := StrSubstNo(DayLbl, Today);
                        D := Date2DWY(Today, 1);
                        W := Date2DWY(Today, 2);
                        Y := Date2DWY(Today, 3) - 1;
                        if LastYear_W53 then
                            W += 1;

                        if Date2DWY(Today, 2) = 53 then begin
                            W := 1;
                            Y += 1;
                        end;
                        DateFilterLast := StrSubstNo(DayLbl, DWY2Date(D, W, Y));
                    end;
                7:
                    begin
                        EndDate := Today();
                        Weekday := Date2DWY(Today, 1);
                        Week := Date2DWY(Today, 2);
                        Year := Date2DWY(Today, 3);
                        StartDate := DWY2Date(1, Week, Year);
                        _DateFilter := StrSubstNo(DateLbl, StartDate, EndDate);
                        Year := Year - 1;
                        if LastYear_W53 then
                            Week += 1;

                        if Date2DWY(Today, 2) = 53 then begin
                            Week := 1;
                            Year += 1;
                        end;
                        EndDateLast := DWY2Date(Weekday, Week, Year);
                        StartDateLast := DWY2Date(1, Week, Year);
                        DateFilterLast := StrSubstNo(DateLbl, StartDateLast, EndDateLast);
                    end;
                31:
                    begin
                        EndDate := Today();
                        Weekday := Date2DMY(Today, 1);
                        Month := Date2DMY(Today, 2);
                        Year := Date2DMY(Today, 3);
                        StartDate := DMY2Date(1, Month, Year);
                        _DateFilter := StrSubstNo(DateLbl, StartDate, EndDate);
                        Year := Year - 1;
                        EndDateLast := DMY2Date(Weekday, Month, Year);
                        StartDateLast := DMY2Date(1, Month, Year);
                        DateFilterLast := StrSubstNo(DateLbl, StartDateLast, EndDateLast);
                    end;
                12:
                    begin
                        EndDate := Today();
                        Year := Date2DMY(Today, 3);
                        StartDate := DMY2Date(1, 1, Year);
                        _DateFilter := StrSubstNo(DateLbl, StartDate, EndDate);
                        EndDateLast := CalcDate(YearLbl, Today);
                        StartDateLast := CalcDate(YearLbl, StartDate);
                        DateFilterLast := StrSubstNo(DateLbl, StartDateLast, EndDateLast);
                    end;
            end;
        end else begin
            case Value of
                7:
                    begin
                        EndDate := Today();
                        StartDate := CalcDate(Text10600000, EndDate);
                        _DateFilter := StrSubstNo(DateLbl, StartDate, EndDate);
                        Weekday := Date2DWY(EndDate, 1);
                        Week := Date2DWY(EndDate, 2);
                        Year := Date2DWY(EndDate, 3);
                        StartDate := DWY2Date(1, Week, Year);
                        Year := Year - 1;
                        if LastYear_W53 then
                            Week += 1;

                        if Date2DWY(Today, 2) = 53 then begin
                            Week := 1;
                            Year += 1;
                        end;
                        EndDateLast := DWY2Date(Weekday, Week, Year);
                        StartDateLast := CalcDate(Text10600000, EndDateLast);
                        ;
                        DateFilterLast := StrSubstNo(DateLbl, StartDateLast, EndDateLast);
                    end;
                31:
                    begin
                        EndDate := Today();
                        StartDate := CalcDate(Text10600001, EndDate);
                        _DateFilter := StrSubstNo(DateLbl, StartDate, EndDate);
                        StartDateLast := CalcDate(YearLbl, StartDate);
                        EndDateLast := CalcDate(YearLbl, EndDate);
                        DateFilterLast := StrSubstNo(DateLbl, StartDateLast, EndDateLast);
                    end;
                12:
                    begin
                        EndDate := Today();
                        StartDate := CalcDate(Text10600002, EndDate);
                        _DateFilter := StrSubstNo(DateLbl, StartDate, EndDate);
                        StartDateLast := CalcDate(YearLbl, StartDate);
                        EndDateLast := CalcDate(YearLbl, EndDate);
                        DateFilterLast := StrSubstNo(DateLbl, StartDateLast, EndDateLast);
                    end;
            end;
        end;
        CalculateYear(_DateFilter, _DepartmentFilter);
        CalculateLastYear(DateFilterLast, _DepartmentFilter);
    end;

    internal procedure CalculateYear(DateFilter: Code[50]; DepartmentFilter: Code[50])
    var
        ValueEntry: Record "Value Entry";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalesAmountActual: Decimal;
    begin
        ValueEntry.SetCurrentKey("Salespers./Purch. Code", "Item Ledger Entry Type", "Posting Date", "Global Dimension 1 Code");

        SalesAmountActual := 0;
        if SalespersonPurchaser.Find('-') then
            repeat
                ValueEntry.SetRange("Salespers./Purch. Code", SalespersonPurchaser.Code);
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.SetFilter("Posting Date", DateFilter);
                ValueEntry.SetFilter("Global Dimension 1 Code", DepartmentFilter);
                ValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)");
                SalesAmountActual += ValueEntry."Sales Amount (Actual)";
            until SalespersonPurchaser.Next() = 0;
        Netto := SalesAmountActual;

    end;

    internal procedure CalculateLastYear(DateFilter: Code[50]; DepartmentFilter: Code[50])
    var
        ValueEntry: Record "Value Entry";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalesAmountActual: Decimal;
    begin
        ValueEntry.SetCurrentKey("Salespers./Purch. Code", "Item Ledger Entry Type", "Posting Date", "Global Dimension 1 Code");
        SalesAmountActual := 0;
        if SalespersonPurchaser.Find('-') then
            repeat
                ValueEntry.SetRange("Salespers./Purch. Code", SalespersonPurchaser.Code);
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.SetFilter("Posting Date", DateFilter);
                ValueEntry.SetFilter("Global Dimension 1 Code", DepartmentFilter);
                ValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)");
                SalesAmountActual += ValueEntry."Sales Amount (Actual)";
            until SalespersonPurchaser.Next() = 0;
        NettoLast := SalesAmountActual;


        I := 0;
        if NettoLast <> 0 then
            MidPct := (1 - (Netto / NettoLast)) * 100
        else
            MidPct := -100;
        if (NettoLast = 0) and (Netto = 0) then
            MidPct := 0;
        SetBar(Round(MidPct, 0.01));
    end;

    internal procedure SetBar(Percent: Decimal)
    begin
        BarPct := Percent;
        if Abs(BarPct) > 100 then
            repeat
                I := I + 1;
                BarPct := Abs(BarPct) / 2;
            until Abs(BarPct) < 100;
        BarPct := Round(MidPct, 0.01);
    end;

    internal procedure PushDay()
    begin
        //PushDay

        Int := 1;
        SetDateFilter(Limitation, Int);
    end;

    internal procedure PushWeek()
    begin
        //PushWeek()
        Int := 7;
        SetDateFilter(Limitation, Int);
    end;

    internal procedure PushMonth()
    begin
        //PushMonth()
        Int := 31;
        SetDateFilter(Limitation, Int);
    end;

    internal procedure PushYear()
    begin
        Int := 12;
        SetDateFilter(Limitation, Int);
    end;

    internal procedure SetDeptFilter("Filter": Code[20])
    begin
        //SetDeptFilter

        _DepartmentFilter := Filter;
    end;
}

