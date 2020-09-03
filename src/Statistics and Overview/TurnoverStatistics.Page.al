page 6014411 "NPR Turnover Statistics"
{
    // NPR4.18/MMV/20151228 CASE 230380 Updated week calculation, since NAV implementation of DWY2DATE has been changed since 6.2.
    //                                  Also added missing handling of LY containing 53 weeks. (has been removed compared to 6.2 form?)
    // NPR5.35/TJ /20170816 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                  Removed unused variables
    // NPR5.41/TS  /20180105 NPR5.41 Removed Caption on Container

    Caption = 'Turnover Statistics';
    PageType = CardPart;

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
        //-NPR4.18
        Year := Date2DWY(CalcDate('<-1Y>', Today), 3);
        LastDay := DMY2Date(31, 12, Year);
        LastYear_W53 := Date2DWY(LastDay, 2) = 53;
        //+NPR4.18
    end;

    var
        Text10600000: Label '-1W+1D';
        Text10600001: Label '-1M+1D';
        Text10600002: Label '-1Y+1D';
        RetailSetup: Record "NPR Retail Setup";
        DepartmentFilter: Code[50];
        DateFilter: Text[30];
        DateFilterLast: Text[30];
        NettoLast: Decimal;
        Netto: Decimal;
        CostOfGoodsSoldLast: Decimal;
        CostOfGoodsSold: Decimal;
        DBLast: Decimal;
        DB: Decimal;
        DGLast: Decimal;
        DG: Decimal;
        TurnoverIndex: Decimal;
        DBIndex: Decimal;
        BarPct: Decimal;
        MidPct: Decimal;
        Label: Decimal;
        Bar1: Integer;
        Bar2: Integer;
        Int: Integer;
        D: Integer;
        W: Integer;
        Y: Integer;
        I: Integer;
        Limitation: Boolean;
        Utility: Codeunit "NPR Utility";
        LastYear_W53: Boolean;

    procedure SetDateFilter(FromStart: Boolean; Value: Integer)
    var
        StartDate: Date;
        EndDate: Date;
        StartDateLast: Date;
        EndDateLast: Date;
        Weekday: Integer;
        Week: Integer;
        Month: Integer;
        Year: Integer;
    begin

        if FromStart then begin
            case Value of
                1:
                    begin
                        DateFilter := StrSubstNo('%1', Today);
                        D := Date2DWY(Today, 1);
                        W := Date2DWY(Today, 2);
                        Y := Date2DWY(Today, 3) - 1;
                        //-NPR4.18
                        //IF Weeks53 THEN
                        //  W += 1;
                        if LastYear_W53 then
                            W += 1;

                        if Date2DWY(Today, 2) = 53 then begin
                            W := 1;
                            Y += 1;
                        end;
                        //+NPR4.18
                        DateFilterLast := StrSubstNo('%1', DWY2Date(D, W, Y));
                    end;
                7:
                    begin
                        EndDate := Today;
                        Weekday := Date2DWY(Today, 1);
                        Week := Date2DWY(Today, 2);
                        Year := Date2DWY(Today, 3);
                        StartDate := DWY2Date(1, Week, Year);
                        DateFilter := StrSubstNo('%1..%2', StartDate, EndDate);
                        Year := Year - 1;
                        //-NPR3.0o
                        //-NPR4.18
                        //IF Weeks53 THEN
                        //   Uge += 1;
                        if LastYear_W53 then
                            Week += 1;

                        if Date2DWY(Today, 2) = 53 then begin
                            Week := 1;
                            Year += 1;
                        end;
                        //+NPR4.18
                        EndDateLast := DWY2Date(Weekday, Week, Year);
                        StartDateLast := DWY2Date(1, Week, Year);
                        DateFilterLast := StrSubstNo('%1..%2', StartDateLast, EndDateLast);
                    end;
                31:
                    begin
                        EndDate := Today;
                        Weekday := Date2DMY(Today, 1);
                        Month := Date2DMY(Today, 2);
                        Year := Date2DMY(Today, 3);
                        StartDate := DMY2Date(1, Month, Year);
                        DateFilter := StrSubstNo('%1..%2', StartDate, EndDate);
                        Year := Year - 1;
                        EndDateLast := DMY2Date(Weekday, Month, Year);
                        StartDateLast := DMY2Date(1, Month, Year);
                        DateFilterLast := StrSubstNo('%1..%2', StartDateLast, EndDateLast);
                    end;
                12:
                    begin
                        EndDate := Today;
                        Year := Date2DMY(Today, 3);
                        StartDate := DMY2Date(1, 1, Year);
                        DateFilter := StrSubstNo('%1..%2', StartDate, EndDate);
                        EndDateLast := CalcDate('<-1Y>', Today);
                        StartDateLast := CalcDate('<-1Y>', StartDate);
                        DateFilterLast := StrSubstNo('%1..%2', StartDateLast, EndDateLast);
                    end;
            end;
        end else begin
            case Value of
                7:
                    begin
                        EndDate := Today;
                        StartDate := CalcDate(Text10600000, EndDate);
                        DateFilter := StrSubstNo('%1..%2', StartDate, EndDate);
                        Weekday := Date2DWY(EndDate, 1);
                        Week := Date2DWY(EndDate, 2);
                        Year := Date2DWY(EndDate, 3);
                        StartDate := DWY2Date(1, Week, Year);
                        Year := Year - 1;
                        //-NPR4.18
                        //IF Weeks53 THEN
                        //   Uge += 1;
                        if LastYear_W53 then
                            Week += 1;

                        if Date2DWY(Today, 2) = 53 then begin
                            Week := 1;
                            Year += 1;
                        end;
                        //+NPR4.18
                        EndDateLast := DWY2Date(Weekday, Week, Year);
                        StartDateLast := CalcDate(Text10600000, EndDateLast);
                        ;
                        DateFilterLast := StrSubstNo('%1..%2', StartDateLast, EndDateLast);
                    end;
                31:
                    begin
                        EndDate := Today;
                        StartDate := CalcDate(Text10600001, EndDate);
                        DateFilter := StrSubstNo('%1..%2', StartDate, EndDate);
                        StartDateLast := CalcDate('<-1Y>', StartDate);
                        EndDateLast := CalcDate('<-1Y>', EndDate);
                        DateFilterLast := StrSubstNo('%1..%2', StartDateLast, EndDateLast);
                    end;
                12:
                    begin
                        EndDate := Today;
                        StartDate := CalcDate(Text10600002, EndDate);
                        DateFilter := StrSubstNo('%1..%2', StartDate, EndDate);
                        StartDateLast := CalcDate('<-1Y>', StartDate);
                        EndDateLast := CalcDate('<-1Y>', EndDate);
                        DateFilterLast := StrSubstNo('%1..%2', StartDateLast, EndDateLast);
                    end;
            end;
        end;
        CalculateYear(DateFilter, DepartmentFilter);
        CalculateLastYear(DateFilterLast, DepartmentFilter);
    end;

    procedure CalculateYear(DateFilter: Code[50]; DepartmentFilter: Code[50])
    var
        ValueEntry: Record "Value Entry";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalesAmountActual: Decimal;
        CostAmountActual: Decimal;
    begin
        ValueEntry.SetCurrentKey("Salespers./Purch. Code", "NPR Item Group No.", "Item Ledger Entry Type", "Posting Date", "Global Dimension 1 Code");

        SalesAmountActual := 0;
        CostAmountActual := 0;
        if SalespersonPurchaser.Find('-') then
            repeat
                ValueEntry.SetRange("Salespers./Purch. Code", SalespersonPurchaser.Code);
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.SetFilter("Posting Date", DateFilter);
                ValueEntry.SetFilter("Global Dimension 1 Code", DepartmentFilter);
                ValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)");
                SalesAmountActual += ValueEntry."Sales Amount (Actual)";
                CostAmountActual += -ValueEntry."Cost Amount (Actual)";
            until SalespersonPurchaser.Next = 0;
        Netto := SalesAmountActual;
        CostOfGoodsSold := CostAmountActual;
        DB := Netto - CostOfGoodsSold;
        if Netto <> 0 then
            DG := DB * 100 / Netto
        else
            DG := 0;
    end;

    procedure CalculateLastYear(DateFilter: Code[50]; DepartmentFilter: Code[50])
    var
        ValueEntry: Record "Value Entry";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalesAmountActual: Decimal;
        CostAmountActual: Decimal;
    begin
        TurnoverIndex := 0;
        DBIndex := 0;
        ValueEntry.SetCurrentKey("Salespers./Purch. Code", "NPR Item Group No.", "Item Ledger Entry Type", "Posting Date", "Global Dimension 1 Code");
        SalesAmountActual := 0;
        CostAmountActual := 0;
        if SalespersonPurchaser.Find('-') then
            repeat
                ValueEntry.SetRange("Salespers./Purch. Code", SalespersonPurchaser.Code);
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.SetFilter("Posting Date", DateFilter);
                ValueEntry.SetFilter("Global Dimension 1 Code", DepartmentFilter);
                ValueEntry.CalcSums("Sales Amount (Actual)", "Cost Amount (Actual)");
                SalesAmountActual += ValueEntry."Sales Amount (Actual)";
                CostAmountActual += -ValueEntry."Cost Amount (Actual)";
            until SalespersonPurchaser.Next = 0;
        NettoLast := SalesAmountActual;
        CostOfGoodsSoldLast := CostAmountActual;
        DBLast := NettoLast - CostOfGoodsSoldLast;
        if NettoLast <> 0 then
            DGLast := DBLast * 100 / NettoLast
        else
            DGLast := 0;
        if NettoLast <> 0 then
            TurnoverIndex := Netto * 100 / NettoLast;
        if DBLast <> 0 then
            DBIndex := DB * 100 / DBLast;

        I := 0;
        if NettoLast <> 0 then
            MidPct := (1 - (Netto / NettoLast)) * 100
        else
            MidPct := -100;
        if (NettoLast = 0) and (Netto = 0) then
            MidPct := 0;
        SetBar(Round(MidPct, 0.01));
    end;

    procedure SetBar(Percent: Decimal)
    begin
        BarPct := Percent;
        if Abs(BarPct) > 100 then
            repeat
                I := I + 1;
                BarPct := Abs(BarPct) / 2;
            until Abs(BarPct) < 100;
        if MidPct < 0 then begin
            Bar2 := 0;
            Bar1 := Abs(Round(BarPct, 0.01)) * 100;
        end else begin
            Bar1 := 0;
            Bar2 := Abs(Round(BarPct, 1)) * 100;
        end;
        BarPct := Round(MidPct, 0.01);
        Label := 100 * Power(2, I);
    end;

    procedure Init()
    begin
        Int := 1;
        Limitation := true;
        DateFilter := StrSubstNo('%1', Today);
        D := Date2DWY(Today, 1);
        W := Date2DWY(Today, 2);
        Y := Date2DWY(Today, 3) - 1;

        //-NPR4.18
        //-NPR3.0o
        //IF Weeks53 THEN
        // W += 1;
        //+NPR3.0o
        if LastYear_W53 then
            W += 1;

        if Date2DWY(Today, 2) = 53 then begin
            W := 1;
            Y += 1;
        end;
        //+NPR4.18
        DateFilterLast := StrSubstNo('%1', DWY2Date(D, W, Y));

        RetailSetup.Get;
        if RetailSetup."Internal Dept. Code" <> '' then
            DepartmentFilter := StrSubstNo('<>%1', RetailSetup."Internal Dept. Code");

        CalculateYear(DateFilter, DepartmentFilter);
        CalculateLastYear(DateFilterLast, DepartmentFilter);
    end;

    procedure GetTurnoverStat(var NPRTempBuffer: Record "NPR TEMP Buffer")
    var
        TxtPer1: Label 'Day';
        TxtPer31: Label 'Month';
        TxtPer7: Label 'Week';
        TxtPer12: Label 'Year';
        Guid: Guid;
        Txt002: Label 'This year';
        Txt003: Label 'Last year';
        Txt004: Label '% difference';
        i: Integer;
        j: Integer;
        Txt005: Label 'Net';
        Txt006: Label 'Cost of sales';
        Txt007: Label 'Profit contribution';
        Txt008: Label 'Contribution ratio';
        Txt009: Label ' - This current';
        Txt010: Label ' - Last';
    begin
        //GetTurnoverStat

        i := 1;
        Guid := CreateGuid;

        NPRTempBuffer.Init;
        NPRTempBuffer.Template := Format(Guid);
        NPRTempBuffer."Line No." := i;
        NPRTempBuffer."Description 2" := Txt002;
        NPRTempBuffer."Bold 2" := true;
        NPRTempBuffer."Description 3" := Txt003;
        NPRTempBuffer."Bold 3" := true;
        NPRTempBuffer."Description 4" := Txt004;
        NPRTempBuffer."Bold 4" := true;
        NPRTempBuffer.Insert;

        for j := 2 to 8 do begin
            case j of
                1, 2:
                    PushDay;
                3, 4:
                    PushWeek;
                5, 6:
                    PushMonth;
                7, 8:
                    PushYear;
            end;

            if j in [1, 3, 5, 7] then
                Limitation := true
            else
                Limitation := false;

            SetDateFilter(Limitation, Int);
            i += 1;
            NPRTempBuffer.Init;
            NPRTempBuffer.Template := Format(Guid);
            NPRTempBuffer."Line No." := i;
            case j of
                1, 2:
                    NPRTempBuffer.Description := TxtPer1;
                3, 4:
                    NPRTempBuffer.Description := TxtPer7;
                5, 6:
                    NPRTempBuffer.Description := TxtPer31;
                7, 8:
                    NPRTempBuffer.Description := TxtPer12;
            end;

            if j in [1, 3, 5, 7] then
                NPRTempBuffer.Description += Txt009
            else
                NPRTempBuffer.Description += Txt010;

            NPRTempBuffer.Color := 255;
            NPRTempBuffer."Description 2" := DateFilter;
            NPRTempBuffer."Color 2" := 255;
            NPRTempBuffer."Description 3" := DateFilterLast;
            NPRTempBuffer."Color 3" := 255;
            NPRTempBuffer.Insert;
            i += 1;
            NPRTempBuffer.Init;
            NPRTempBuffer.Template := Format(Guid);
            NPRTempBuffer."Line No." := i;
            NPRTempBuffer.Description := Txt005;
            NPRTempBuffer.Bold := true;
            NPRTempBuffer."Description 2" := Utility.FormatDec2Text(Netto, 2);
            NPRTempBuffer."Description 3" := Utility.FormatDec2Text(NettoLast, 2);
            NPRTempBuffer."Description 4" := Utility.FormatDec2Text(MidPct, 2);
            NPRTempBuffer.Insert;

            i += 1;
            NPRTempBuffer.Init;
            NPRTempBuffer.Template := Format(Guid);
            NPRTempBuffer."Line No." := i;
            NPRTempBuffer.Description := Txt006;
            NPRTempBuffer.Bold := true;
            NPRTempBuffer."Description 2" := Utility.FormatDec2Text(CostOfGoodsSold, 2);
            NPRTempBuffer."Description 3" := Utility.FormatDec2Text(CostOfGoodsSoldLast, 2);
            NPRTempBuffer."Description 4" := Utility.FormatDec2Text(MidPct, 2);
            NPRTempBuffer.Insert;

            i += 1;
            NPRTempBuffer.Init;
            NPRTempBuffer.Template := Format(Guid);
            NPRTempBuffer."Line No." := i;
            NPRTempBuffer.Description := Txt007;
            NPRTempBuffer.Bold := true;
            NPRTempBuffer."Description 2" := Utility.FormatDec2Text(DB, 2);
            NPRTempBuffer."Description 3" := Utility.FormatDec2Text(DBLast, 2);
            NPRTempBuffer."Description 4" := Utility.FormatDec2Text(MidPct, 2);
            NPRTempBuffer.Insert;

            i += 1;
            NPRTempBuffer.Init;
            NPRTempBuffer.Template := Format(Guid);
            NPRTempBuffer."Line No." := i;
            NPRTempBuffer.Description := Txt008;
            NPRTempBuffer.Bold := true;
            NPRTempBuffer."Description 2" := Utility.FormatDec2Text(DG, 2);
            NPRTempBuffer."Description 3" := Utility.FormatDec2Text(DGLast, 2);
            NPRTempBuffer."Description 4" := Utility.FormatDec2Text(MidPct, 2);
            NPRTempBuffer.Insert;

            if j in [2, 4, 6] then begin
                i += 1;
                NPRTempBuffer.Init;
                NPRTempBuffer."Line No." := i;
                NPRTempBuffer.Insert;
            end;
        end;
    end;

    procedure PushDay()
    begin
        //PushDay

        Int := 1;
        SetDateFilter(Limitation, Int);
    end;

    procedure PushWeek()
    begin
        //PushWeek()
        Int := 7;
        SetDateFilter(Limitation, Int);
    end;

    procedure PushMonth()
    begin
        //PushMonth()
        Int := 31;
        SetDateFilter(Limitation, Int);
    end;

    procedure PushYear()
    begin
        Int := 12;
        SetDateFilter(Limitation, Int);
    end;

    procedure SetDeptFilter("Filter": Code[20])
    begin
        //SetDeptFilter

        DepartmentFilter := Filter;
    end;
}

