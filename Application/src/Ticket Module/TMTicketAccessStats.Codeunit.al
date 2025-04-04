﻿codeunit 6060114 "NPR TM Ticket Access Stats"
{
    Access = Internal;
    trigger OnRun()
    begin
        BuildCompressedStatistics(Today);
    end;

    var
        Dialog001: Label '#1###################\@2@@@@@@@@@@@@@@@@@@@';
        Text001: Label 'Calculating... (%1)';
        Text002: Label 'Saving...';
        Text003: Label 'Statistics are not completly up to date for range %1.\Do you want to update them now?';
        Text004: Label 'There are no ticket statistics to display.';
        Window: Dialog;
        ProgressMaxCount: Integer;
        ProgressCurrentCount: Integer;
        AdHocEntryCounter: Integer;

#if (BC17 or BC18)
    procedure FindRec(DimOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code"; var DimCodeBuffer: Record "Dimension Code Buffer"; Which: Text; var FactFilter: Record "NPR TM Ticket Access Fact"; PeriodType: Option; PeriodFilter: Text; var PeriodInitialized: Boolean; InternalDateFilter: Text[30]) Found: Boolean
#else
    procedure FindRec(DimOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code"; var DimCodeBuffer: Record "Dimension Code Buffer"; Which: Text; var FactFilter: Record "NPR TM Ticket Access Fact"; PeriodType: Enum "Analysis Period Type"; PeriodFilter: Text; var PeriodInitialized: Boolean; InternalDateFilter: Text[30]) Found: Boolean
#endif
    var
        TicketFact: Record "NPR TM Ticket Access Fact";
        Period: Record Date;
#if (BC17 or BC18)
        PeriodFormMgt: Codeunit PeriodFormManagement;
#else
        PeriodPageMgt: Codeunit PeriodPageManagement;
#endif
    begin

        TicketFact."Fact Code" := DimCodeBuffer.Code;
        TicketFact.SetCurrentKey("Fact Name", "Fact Code");
        TicketFact.CopyFilters(FactFilter);
        TicketFact.SetFilter(Block, '=%1', false);

        case DimOption of
            DimOption::Item:
                begin
                    TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::ITEM);
                    TicketFact."Fact Name" := TicketFact."Fact Name"::ITEM;
                    Found := TicketFact.Find(Which);
                    if (Found) then
                        CopyFactToBuf(TicketFact, DimCodeBuffer);
                end;
            DimOption::"Ticket Type":
                begin
                    TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::TICKET_TYPE);
                    TicketFact."Fact Name" := TicketFact."Fact Name"::TICKET_TYPE;
                    Found := TicketFact.Find(Which);
                    if (Found) then
                        CopyFactToBuf(TicketFact, DimCodeBuffer);
                end;
            DimOption::"Admission Date":
                begin
                    TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_DATE);
                    TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_DATE;
                    Found := TicketFact.Find(Which);
                    if (Found) then
                        CopyFactToBuf(TicketFact, DimCodeBuffer);
                end;
            DimOption::"Admission Hour":
                begin
                    TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_HOUR);
                    TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_HOUR;
                    Found := TicketFact.Find(Which);
                    if (Found) then
                        CopyFactToBuf(TicketFact, DimCodeBuffer);
                end;
            DimOption::"Admission Code":
                begin
                    TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_CODE);
                    TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_CODE;
                    Found := TicketFact.Find(Which);
                    if (Found) then
                        CopyFactToBuf(TicketFact, DimCodeBuffer);
                end;

            DimOption::Period:
                begin
                    Period."Period Start" := DimCodeBuffer."Period Start";
                    if (PeriodFilter <> '') then
                        Period.SetFilter("Period Start", PeriodFilter)
                    else
                        if (not PeriodInitialized and (InternalDateFilter <> '')) then
                            Period.SetFilter("Period Start", InternalDateFilter);

#if (BC17 or BC18)
                    Found := PeriodFormMgt.FindDate(CopyStr(Which, 1, 3), Period, PeriodType);
#else
                    Found := PeriodPageMgt.FindDate(CopyStr(Which, 1, 3), Period, PeriodType);
#endif
                    if Found then
                        CopyPeriodToBuf(Period, DimCodeBuffer, PeriodFilter);

                    PeriodInitialized := true;
                end;

            DimOption::"Variant Code":
                begin
                    TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::VARIANT_CODE);
                    TicketFact."Fact Name" := TicketFact."Fact Name"::VARIANT_CODE;
                    Found := TicketFact.Find(Which);
                    if (Found) then
                        CopyFactToBuf(TicketFact, DimCodeBuffer);
                end;

            else
                Error('Unhandled option value in FindRec()');
        end;

        DimCodeBuffer.Visible := false;

        exit(Found);
    end;
#if (BC17 or BC18)
    procedure NextRec(DimOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code"; var DimCodeBuffer: Record "Dimension Code Buffer"; Steps: Integer; var FactFilter: Record "NPR TM Ticket Access Fact"; PeriodType: Option; PeriodFilter: Text) ResultSteps: Integer
#else    
    procedure NextRec(DimOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code"; var DimCodeBuffer: Record "Dimension Code Buffer"; Steps: Integer; var FactFilter: Record "NPR TM Ticket Access Fact"; PeriodType: Enum "Analysis Period Type"; PeriodFilter: Text) ResultSteps: Integer
#endif
    var
        TicketFact: Record "NPR TM Ticket Access Fact";
        Period: Record Date;
#if (BC17 or BC18)
        PeriodFormMgt: Codeunit PeriodFormManagement;
#else
        PeriodPageMgt: Codeunit PeriodPageManagement;
#endif
    begin

        TicketFact.SetCurrentKey("Fact Name", "Fact Code");
        TicketFact."Fact Code" := DimCodeBuffer.Code;
        TicketFact.CopyFilters(FactFilter);
        TicketFact.SetFilter(Block, '=%1', false);

        case DimOption of
            DimOption::Item:
                begin
                    TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::ITEM);
                    TicketFact."Fact Name" := TicketFact."Fact Name"::ITEM;
                    ResultSteps := TicketFact.Next(Steps);
                    if (ResultSteps <> 0) then
                        CopyFactToBuf(TicketFact, DimCodeBuffer);
                end;
            DimOption::"Ticket Type":
                begin
                    TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::TICKET_TYPE);
                    TicketFact."Fact Name" := TicketFact."Fact Name"::TICKET_TYPE;
                    ResultSteps := TicketFact.Next(Steps);
                    if (ResultSteps <> 0) then
                        CopyFactToBuf(TicketFact, DimCodeBuffer);
                end;
            DimOption::"Admission Date":
                begin
                    TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_DATE);
                    TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_DATE;
                    ResultSteps := TicketFact.Next(Steps);
                    if (ResultSteps <> 0) then
                        CopyFactToBuf(TicketFact, DimCodeBuffer);
                end;
            DimOption::"Admission Hour":
                begin
                    TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_HOUR);
                    TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_HOUR;
                    ResultSteps := TicketFact.Next(Steps);
                    if (ResultSteps <> 0) then
                        CopyFactToBuf(TicketFact, DimCodeBuffer);
                end;
            DimOption::"Admission Code":
                begin
                    TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_CODE);
                    TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_CODE;
                    ResultSteps := TicketFact.Next(Steps);
                    if (ResultSteps <> 0) then
                        CopyFactToBuf(TicketFact, DimCodeBuffer);
                end;
            DimOption::Period:
                begin
                    if (PeriodFilter <> '') then
                        Period.SetFilter("Period Start", PeriodFilter);

                    Period."Period Start" := DimCodeBuffer."Period Start";
#if (BC17 or BC18)
                    ResultSteps := PeriodFormMgt.NextDate(Steps, Period, PeriodType);
#else
                    ResultSteps := PeriodPageMgt.NextDate(Steps, Period, PeriodType);
#endif
                    if (ResultSteps <> 0) then
                        CopyPeriodToBuf(Period, DimCodeBuffer, PeriodFilter);
                end;
            DimOption::"Variant Code":
                begin
                    TicketFact.SetFilter("Fact Name", '=%1', TicketFact."Fact Name"::VARIANT_CODE);
                    TicketFact."Fact Name" := TicketFact."Fact Name"::VARIANT_CODE;
                    ResultSteps := TicketFact.Next(Steps);
                    if (ResultSteps <> 0) then
                        CopyFactToBuf(TicketFact, DimCodeBuffer);
                end;
            else
                Error('Unhandled option value in NextRec()');
        end;


        DimCodeBuffer.Visible := false;


        exit(ResultSteps);
    end;

    procedure CopyFactToBuf(TicketFact: Record "NPR TM Ticket Access Fact"; var DimCodeBuf: Record "Dimension Code Buffer")
    begin

        DimCodeBuf.Init();
        DimCodeBuf.Code := TicketFact."Fact Code";
        DimCodeBuf.Name := TicketFact.Description;
    end;

    local procedure CopyPeriodToBuf(var Period: Record Date; var DimCodeBuf: Record "Dimension Code Buffer"; DateFilter: Text)
    var
        Period2: Record Date;
    begin

        DimCodeBuf.Init();
        DimCodeBuf.Code := Format(Period."Period Start");
        DimCodeBuf."Period Start" := Period."Period Start";
        DimCodeBuf."Period End" := Period."Period End";
        if DateFilter <> '' then begin
            Period2.SetFilter("Period End", DateFilter);
            if Period2.GetRangeMax("Period End") < DimCodeBuf."Period End" then
                DimCodeBuf."Period End" := Period2.GetRangeMax("Period End");
        end;
        DimCodeBuf.Name := Period."Period Name";
    end;

    procedure CalcCount(LineFactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code"; LineFactCode: Code[20]; ColumnFactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code"; ColumnFactCode: Code[20]; ColumnFilter: Boolean; var TicketStatisticsFilter: Record "NPR TM Ticket Access Stats"; PeriodFilter: Text; AdmissionDefinition: Option) SumAdmissionCount: Decimal
    var
        TicketStatistics: Record "NPR TM Ticket Access Stats";
    begin


        TicketStatistics.Reset();
        TicketStatistics.Init();
        SumAdmissionCount := 0;

        TicketStatistics.CopyFilters(TicketStatisticsFilter);
        SetCodeFlowFilter(LineFactOption, LineFactCode, TicketStatistics, PeriodFilter);

        if (ColumnFilter) then
            SetCodeFlowFilter(ColumnFactOption, ColumnFactCode, TicketStatistics, PeriodFilter);

        if (PeriodFilter <> '') then
            if ((LineFactOption <> LineFactOption::"Admission Date") and (ColumnFactOption <> ColumnFactOption::"Admission Date")) then
                TicketStatistics.SetFilter("Admission Date Filter", PeriodFilter);

        case AdmissionDefinition of
            0:
                TicketStatistics.CalcFields("Sum Admission Count", "Sum Admission Count (Neg)");
            1:
                TicketStatistics.CalcFields("Sum Admission Count");
            2:
                TicketStatistics.CalcFields("Sum Admission Count", "Sum Admission Count (Re-Entry)");
        end;

        case AdmissionDefinition of
            0:
                SumAdmissionCount := TicketStatistics."Sum Admission Count" - TicketStatistics."Sum Admission Count (Neg)";
            1:
                SumAdmissionCount := TicketStatistics."Sum Admission Count";
            2:
                SumAdmissionCount := TicketStatistics."Sum Admission Count" + TicketStatistics."Sum Admission Count (Re-Entry)";
        end;

        exit(SumAdmissionCount);
    end;

    procedure CalcVerticalTotal(LineFactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code"; ColumnFactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code"; var TicketStatisticsFilter: Record "NPR TM Ticket Access Stats"; PeriodFilter: Text; AdmissionDefinition: Option) AdmissionTotal: Decimal
    var
        TicketStatistics: Record "NPR TM Ticket Access Stats";
    begin


        TicketStatistics.Reset();
        TicketStatistics.Init();
        AdmissionTotal := 0;

        TicketStatistics.CopyFilters(TicketStatisticsFilter);

        if (PeriodFilter <> '') then
            if ((LineFactOption <> LineFactOption::"Admission Date") and
                (ColumnFactOption <> ColumnFactOption::"Admission Date")) then
                TicketStatistics.SetFilter("Admission Date Filter", PeriodFilter);

        case AdmissionDefinition of
            0:
                TicketStatistics.CalcFields("Sum Admission Count", "Sum Admission Count (Neg)");
            1:
                TicketStatistics.CalcFields("Sum Admission Count");
            2:
                TicketStatistics.CalcFields("Sum Admission Count", "Sum Admission Count (Re-Entry)");
        end;

        case AdmissionDefinition of
            0:
                AdmissionTotal := TicketStatistics."Sum Admission Count" - TicketStatistics."Sum Admission Count (Neg)";
            1:
                AdmissionTotal := TicketStatistics."Sum Admission Count";
            2:
                AdmissionTotal := TicketStatistics."Sum Admission Count" + TicketStatistics."Sum Admission Count (Re-Entry)";
        end;

        exit(AdmissionTotal);
    end;

#if (BC17 or BC18)
    procedure FormatCellValue(LineFactOption: Option; LineFactCode: Code[20]; ColumnFactOption: Option; ColumnFactCode: Code[20]; ColumnFilter: Boolean; var TicketStatisticsFilter: Record "NPR TM Ticket Access Stats"; PeriodFilter: Text; DisplayOption: Option "COUNT",COUNT_TREND,TREND; PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period"; TrendPeriodType: Option PERIOD,YEAR; AdmissionDefinition: Option) CellValue: Text
#else
    procedure FormatCellValue(LineFactOption: Option; LineFactCode: Code[20]; ColumnFactOption: Option; ColumnFactCode: Code[20]; ColumnFilter: Boolean; var TicketStatisticsFilter: Record "NPR TM Ticket Access Stats"; PeriodFilter: Text; DisplayOption: Option "COUNT",COUNT_TREND,TREND; PeriodType: Enum "Analysis Period Type"; TrendPeriodType: Option PERIOD,YEAR; AdmissionDefinition: Option) CellValue: Text
#endif    
    var
        AdmissionCount: Decimal;
        AdmissionCount2: Decimal;
        CellValueLbl: Label '%1', Locked = true;
        CellValue2Lbl: Label '%1 [%2]', Locked = true;
        CellValue3Lbl: Label '%1 [%2%]', Locked = true;
        CellValue4Lbl: Label '[%1]', Locked = true;
        CellValue5Lbl: Label '[%1%]', Locked = true;
    begin

        AdmissionCount := CalcCount(LineFactOption, LineFactCode,
                            ColumnFactOption, ColumnFactCode, ColumnFilter,
                            TicketStatisticsFilter, PeriodFilter, AdmissionDefinition);

        if (AdmissionCount = 0) then begin
            CellValue := '';
        end else begin
            CellValue := StrSubstNo(CellValueLbl, AdmissionCount);
        end;

        if (PeriodFilter <> '') and (DisplayOption > DisplayOption::COUNT) then begin
            PeriodFilter := FindMatrixPeriod('<=', PeriodFilter, PeriodType, TrendPeriodType);

            AdmissionCount2 := CalcCount(LineFactOption, LineFactCode,
                                 ColumnFactOption, ColumnFactCode, ColumnFilter,
                                 TicketStatisticsFilter, PeriodFilter, AdmissionDefinition);

            CellValue := '';
            case DisplayOption of
                DisplayOption::COUNT_TREND:
                    begin
                        if ((AdmissionCount2 = 0) and (AdmissionCount <> 0)) then
                            CellValue := StrSubstNo(CellValue2Lbl, AdmissionCount, '---');
                        if (AdmissionCount2 <> 0) then
                            CellValue := StrSubstNo(CellValue3Lbl, AdmissionCount, Round((AdmissionCount - AdmissionCount2) / AdmissionCount2 * 100, 1));

                    end;
                DisplayOption::TREND:
                    begin
                        if ((AdmissionCount2 = 0) and (AdmissionCount <> 0)) then
                            CellValue := StrSubstNo(CellValue4Lbl, '---');
                        if (AdmissionCount2 <> 0) then
                            CellValue := StrSubstNo(CellValue5Lbl, Round((AdmissionCount - AdmissionCount2) / AdmissionCount2 * 100, 1));
                    end;
            end;
        end;
    end;

    procedure SetCodeFilter(FactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code"; FactCode: Code[20]; var TicketStatistics: Record "NPR TM Ticket Access Stats"; PeriodFilter: Text)
    var
        FactDateBucket: Date;
        FactHourBucket: Integer;
    begin

        case FactOption of
            FactOption::Item:
                TicketStatistics.SetFilter("Item No.", '=%1', FactCode);

            FactOption::"Ticket Type":
                TicketStatistics.SetFilter("Ticket Type", '=%1', FactCode);

            FactOption::"Admission Code":
                TicketStatistics.SetFilter("Admission Code", '=%1', FactCode);

            FactOption::"Admission Date":
                begin
                    if (Evaluate(FactDateBucket, FactCode, 9)) then
                        TicketStatistics.SetFilter("Admission Date", '%1', FactDateBucket);
                end;

            FactOption::"Admission Hour":
                begin
                    if (Evaluate(FactHourBucket, FactCode)) then
                        TicketStatistics.SetFilter("Admission Hour", '=%1', FactHourBucket);
                end;

            FactOption::Period:
                TicketStatistics.SetFilter("Admission Date", PeriodFilter);

            FactOption::"Variant Code":
                TicketStatistics.SetFilter("Variant Code", '=%1', FactCode);

            else
                Error('Unhandled option value in SetCodeFilter()');

        end;
    end;

    procedure SetCodeFlowFilter(FactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code"; FactCode: Code[20]; var TicketStatistics: Record "NPR TM Ticket Access Stats"; PeriodFilter: Text)
    var
        FactDateBucket: Date;
        FactHourBucket: Integer;
    begin

        case FactOption of
            FactOption::Item:
                TicketStatistics.SetFilter("Item No. Filter", '=%1', FactCode);

            FactOption::"Ticket Type":
                TicketStatistics.SetFilter("Ticket Type Filter", '=%1', FactCode);

            FactOption::"Admission Code":
                TicketStatistics.SetFilter("Admission Code Filter", '=%1', FactCode);

            FactOption::"Admission Date":
                begin
                    if (Evaluate(FactDateBucket, FactCode, 9)) then
                        TicketStatistics.SetFilter("Admission Date Filter", '%1', FactDateBucket);
                end;

            FactOption::"Admission Hour":
                begin
                    if (Evaluate(FactHourBucket, FactCode)) then
                        TicketStatistics.SetFilter("Admission Hour Filter", '=%1', FactHourBucket);
                end;

            FactOption::Period:
                TicketStatistics.SetFilter("Admission Date Filter", PeriodFilter);

            FactOption::"Variant Code":
                TicketStatistics.SetFilter("Variant Code Filter", '=%1', FactCode);

            else
                Error('Unhandled option value in SetCodeFlowFilter()');

        end;
    end;

#if (BC17 or BC18)
    procedure FindMatrixPeriod(SearchText: Text[3]; PeriodStartFilter: Text; PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period"; TrendPeriodType: Option PERIOD,YEAR) MatrixDateFilter: Text
#else    
    procedure FindMatrixPeriod(SearchText: Text[3]; PeriodStartFilter: Text; PeriodType: Enum "Analysis Period Type"; TrendPeriodType: Option PERIOD,YEAR) MatrixDateFilter: Text
#endif
    var
        TicketStatistics: Record "NPR TM Ticket Access Stats";
        Calendar: Record Date;
#if (BC17 or BC18)
        PeriodFormMgt: Codeunit PeriodFormManagement;
#else
        PeriodPageMgt: Codeunit PeriodPageManagement;
#endif
    begin

        if (PeriodStartFilter <> '') then begin
            Calendar.SetFilter("Period Start", PeriodStartFilter);
#if (BC17 or BC18)
            if (not PeriodFormMgt.FindDate('+', Calendar, PeriodType)) then
                PeriodFormMgt.FindDate('+', Calendar, PeriodType::Day);
#else
            if (not PeriodPageMgt.FindDate('+', Calendar, PeriodType)) then
                PeriodPageMgt.FindDate('+', Calendar, PeriodType::Day);
#endif

            Calendar.SetRange("Period Start");
        end;

        if (TrendPeriodType = TrendPeriodType::PERIOD) then begin
#if (BC17 or BC18)
            PeriodFormMgt.FindDate(SearchText, Calendar, PeriodType);
#else
            PeriodPageMgt.FindDate(SearchText, Calendar, PeriodType);
#endif
            TicketStatistics.SetRange("Admission Date Filter", Calendar."Period Start", Calendar."Period End");
        end;

        if (TrendPeriodType = TrendPeriodType::YEAR) then begin
#if (BC17 or BC18)
            PeriodFormMgt.FindDate('', Calendar, PeriodType);
#else
            PeriodPageMgt.FindDate('', Calendar, PeriodType);
#endif
            TicketStatistics.SetRange("Admission Date Filter", CalcDate('<-1Y>', Calendar."Period Start"), CalcDate('<-1Y>', Calendar."Period End"));
        end;

        if TicketStatistics.GetRangeMin("Admission Date Filter") = TicketStatistics.GetRangeMax("Admission Date Filter") then
            TicketStatistics.SetRange("Admission Date Filter", TicketStatistics.GetRangeMin("Admission Date Filter"));

        MatrixDateFilter := TicketStatistics.GetFilter("Admission Date Filter");
    end;

    procedure BuildCompressedStatistics(SuggestedMaxDate: Date)
    begin

        BuildCompressedStatistics(SuggestedMaxDate, true);

    end;

    procedure BuildCompressedStatistics(SuggestedMaxDate: Date; Verbose: Boolean)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TempTicketStatisticsResult: Record "NPR TM Ticket Access Stats" temporary;
        StartDate: Date;
        MaxDate: Date;
        FirstEntryNo: Integer;
        LastEntryNo: Integer;
        FromToLbl: Label '[%1 - %2]', Locked = true;
    begin

        if (not TicketAccessEntry.FindLast()) then
            if (Verbose) then
                Message(Text004);

        if (SelectEntries(FirstEntryNo, LastEntryNo, StartDate, MaxDate) = -1) then
            SelectEntriesOnDateTime(FirstEntryNo, LastEntryNo, StartDate, MaxDate); // Handles upgraded data without "Highest Entry No."

        // Compress and save to DB
        if ((LastEntryNo >= FirstEntryNo) and (LastEntryNo > 0)) then begin

            if (Verbose) then
                if (not Confirm(Text003, true, StrSubstNo(FromToLbl, StartDate, MaxDate))) then
                    exit;

            LockResource();
            if (SelectEntries(FirstEntryNo, LastEntryNo, StartDate, MaxDate) = -1) then
                SelectEntriesOnDateTime(FirstEntryNo, LastEntryNo, StartDate, MaxDate); // Handles upgraded data without "Highest Entry No."

            if (FirstEntryNo = 0) then
                exit; // Done, someone else did all work already.

            BuildCompressedStatisticsWorker(FirstEntryNo, LastEntryNo, false, TempTicketStatisticsResult, Verbose);

        end;
    end;

    procedure BuildCompressedStatisticsAdHoc(FromDate: Date; UntilDate: Date; var TempTicketStatisticsResult: Record "NPR TM Ticket Access Stats" temporary)
    var
        DetailAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        FirstEntryNo: Integer;
        LastEntryNo: Integer;
    begin

        if (not TempTicketStatisticsResult.IsTemporary()) then
            Error('Result table must be temporary.');

        DetailAccessEntry.SetFilter("Created Datetime", '>=%1&<%2', CreateDateTime(FromDate, 0T), CreateDateTime(CalcDate('<+1D>', UntilDate), 0T));
        if (not DetailAccessEntry.FindFirst()) then
            exit;

        FirstEntryNo := DetailAccessEntry."Entry No.";

        DetailAccessEntry.FindLast();
        LastEntryNo := DetailAccessEntry."Entry No.";

        BuildCompressedStatisticsWorker(FirstEntryNo, LastEntryNo, true, TempTicketStatisticsResult, true);

        // The date span when translated to an entry number range might find transaction that belong outside the date range (time travel).
        TempTicketStatisticsResult.SetFilter("Admission Date", '<%1|>%2', FromDate, UntilDate);
        TempTicketStatisticsResult.DeleteAll();

    end;

    local procedure BuildCompressedStatisticsWorker(FirstEntryNo: Integer; LastEntryNo: Integer; AdHoc: Boolean; var TmpTicketStatisticsResult: Record "NPR TM Ticket Access Stats" temporary; Verbose: Boolean)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetailAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketStatistics: Dictionary of [Text, JSonObject];
        Ticket: Record "NPR TM Ticket";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        IsReEntry: Boolean;
        DoneAggregating: Boolean;
        ValidEntry: Boolean;
    begin

        DetailAccessEntry.Reset();
        DetailAccessEntry.SetRange("Entry No.", FirstEntryNo, LastEntryNo);
        if (not DetailAccessEntry.FindSet()) then
            exit;

        ProgressMaxCount := DetailAccessEntry.Count();
        ProgressCurrentCount := 0;
        if (GuiAllowed and Verbose) then begin
            Window.Open(Dialog001);
            Window.Update(1, StrSubstNo(Text001, ProgressMaxCount));
            Window.Update(2, 0);
        end;

        repeat
            if ((DetailAccessEntry.Type = DetailAccessEntry.Type::ADMITTED) or
                (DetailAccessEntry.Type = DetailAccessEntry.Type::CANCELED_ADMISSION) or
                (DetailAccessEntry.Type = DetailAccessEntry.Type::INITIAL_ENTRY)) then begin

                ValidEntry := TicketAccessEntry.Get(DetailAccessEntry."Ticket Access Entry No.");
                ValidEntry := ValidEntry and Ticket.Get(TicketAccessEntry."Ticket No.");
                ValidEntry := ValidEntry and TicketAdmissionBOM.Get(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code");
                if (ValidEntry) then begin
                    IsReEntry := CheckForReEntry(DetailAccessEntry, TicketAdmissionBOM."Revisit Condition (Statistics)");

                    if (CreateDateTime(DetailAccessEntry.AdmittedDate, DetailAccessEntry.AdmittedTime) > CreateDateTime(0D, 0T)) then begin
                        TicketAccessEntry."Access Date" := DetailAccessEntry.AdmittedDate;
                        TicketAccessEntry."Access Time" := DetailAccessEntry.AdmittedTime;
                    end else begin
                        TicketAccessEntry."Access Date" := DT2Date(DetailAccessEntry."Created Datetime");
                        TicketAccessEntry."Access Time" := DT2Time(DetailAccessEntry."Created Datetime");
                    end;
                    TicketAccessEntry.Quantity := DetailAccessEntry.Quantity;

                    if (not AdHoc) then
                        AddAccessFact(TicketAccessEntry);

                    AggregateStatistics(TicketStatistics, TicketAccessEntry, Ticket, DetailAccessEntry."Entry No.", DetailAccessEntry.Type, IsReEntry);

                    if (GuiAllowed and Verbose) then begin
                        if (ProgressCurrentCount mod 100 = 0) then begin
                            Window.Update(1, StrSubstNo(Text001, ProgressMaxCount - ProgressCurrentCount));
                            Window.Update(2, Round(ProgressCurrentCount / ProgressMaxCount * 10000, 1));
                        end;
                    end;
                    ProgressCurrentCount += 1;

                end;
            end;
        until ((DetailAccessEntry.Next() = 0) or (DoneAggregating));

        SaveStatistics(TicketStatistics, AdHoc, TmpTicketStatisticsResult, Verbose);

        if (GuiAllowed and Verbose) then
            Window.Close();
    end;

    procedure AddAccessFact(TicketAccessEntry: Record "NPR TM Ticket Access Entry")
    var
        TicketFact: Record "NPR TM Ticket Access Fact";
        TicketType: Record "NPR TM Ticket Type";
        Item: Record Item;
        FactCode: Code[20];
        Ticket: Record "NPR TM Ticket";
        Admission: Record "NPR TM Admission";
        Variant: Record "Item Variant";
        FactCodeLbl: Label '0%1', Locked = true;
        FactDescLbl: Label '%1:00 - %1:59', Locked = true;
    begin

        // Item, annual card have same ticket type for different guest ticket types.
        FactCode := ''; //TicketAccessEntry."Item No.";
        if (FactCode = '') then
            if (Ticket.Get(TicketAccessEntry."Ticket No.")) then
                FactCode := Ticket."Item No.";

        if (FactCode = '') then
            FactCode := '<BLANK>';

        if (not TicketFact.Get(TicketFact."Fact Name"::ITEM, FactCode)) then begin
            TicketFact.Init();
            TicketFact."Fact Name" := TicketFact."Fact Name"::ITEM;
            TicketFact."Fact Code" := FactCode;
            if (Item.Get(FactCode)) then
                TicketFact.Description := CopyStr(Item.Description, 1, MaxStrLen(TicketFact.Description));
            TicketFact.Insert();
        end;

        // VAriant Code
        FactCode := '';
        if (FactCode = '') then
            if (Ticket.Get(TicketAccessEntry."Ticket No.")) then
                FactCode := Ticket."Variant Code";

        if (FactCode = '') then
            FactCode := '<BLANK>';

        if (not TicketFact.Get(TicketFact."Fact Name"::VARIANT_CODE, FactCode)) then begin
            TicketFact.Init();
            TicketFact."Fact Name" := TicketFact."Fact Name"::VARIANT_CODE;
            TicketFact."Fact Code" := FactCode;
            if (Variant.Get(Ticket."Item No.", FactCode)) then
                TicketFact.Description := CopyStr(Variant.Description, 1, MaxStrLen(TicketFact.Description));
            TicketFact.Insert();
        end;

        // Ticket Type
        FactCode := '';
        FactCode := TicketAccessEntry."Ticket Type Code";
        if (FactCode = '') then
            FactCode := '<BLANK>';

        if (not TicketFact.Get(TicketFact."Fact Name"::TICKET_TYPE, FactCode)) then begin
            TicketFact.Init();
            TicketFact."Fact Name" := TicketFact."Fact Name"::TICKET_TYPE;
            TicketFact."Fact Code" := FactCode;
            if (TicketType.Get(FactCode)) then
                TicketFact.Description := TicketType.Description;
            TicketFact.Insert();
        end;

        // Admission Date
        FactCode := '';
        FactCode := Format(TicketAccessEntry."Access Date", 0, 9);
        if (not TicketFact.Get(TicketFact."Fact Name"::ADMISSION_DATE, FactCode)) then begin
            TicketFact.Init();
            TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_DATE;
            TicketFact."Fact Code" := FactCode;
            TicketFact.Description := Format(TicketAccessEntry."Access Date", 0, 4);
            TicketFact.Insert();
        end;

        // Admission Time
        FactCode := '';
        FactCode := Format(TicketAccessEntry."Access Time", 0, '<Hours24,2>');
        if (StrLen(FactCode) = 1) then
            FactCode := StrSubstNo(FactCodeLbl, FactCode);
        if (not TicketFact.Get(TicketFact."Fact Name"::ADMISSION_HOUR, FactCode)) then begin
            TicketFact.Init();
            TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_HOUR;
            TicketFact."Fact Code" := FactCode;
            TicketFact.Description := StrSubstNo(FactDescLbl, FactCode);
            TicketFact.Insert();
        end;

        // Admission Code
        FactCode := '';
        FactCode := TicketAccessEntry."Admission Code";
        if (FactCode = '') then
            FactCode := '<BLANK>';

        if (not TicketFact.Get(TicketFact."Fact Name"::ADMISSION_CODE, FactCode)) then begin
            TicketFact.Init();
            TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_CODE;
            TicketFact."Fact Code" := FactCode;
            if (Admission.Get(FactCode)) then
                TicketFact.Description := TicketType.Description;
            TicketFact.Insert();
        end;
    end;

    local procedure AggregateStatistics(var Statistics: Dictionary of [Text, JSonObject]; TicketAccessEntry: Record "NPR TM Ticket Access Entry"; Ticket: Record "NPR TM Ticket"; MaxAdmissionEntryNo: Integer; AdmissionType: Option; IsReEntry: Boolean)
    var
        TicketStatisticsLeaf: JsonObject;
        FactKey: Text;
        ItemFactCode: Code[20];
        TicketTypeFactCode: Code[20];
        VariantFactCode: Code[10];
        AdmissionHour: Integer;
        DetailAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        if (AdmissionType = DetailAccessEntry.Type::CANCELED_ADMISSION) then begin
            // only cancelled admissions should count as cancelled
            DetailAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type);
            DetailAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetailAccessEntry.SetFilter(Type, '=%1', DetailAccessEntry.Type::ADMITTED);
            if (DetailAccessEntry.IsEmpty()) then
                exit;
        end;

        ItemFactCode := '';
        if (ItemFactCode = '') then begin
            ItemFactCode := Ticket."Item No.";
            VariantFactCode := Ticket."Variant Code";
        end;

        if (ItemFactCode = '') then
            ItemFactCode := '<BLANK>';

        if (VariantFactCode = '') then
            VariantFactCode := '<BLANK>';

        TicketTypeFactCode := TicketAccessEntry."Ticket Type Code";
        if (TicketTypeFactCode = '') then
            TicketTypeFactCode := '<BLANK>';

        Evaluate(AdmissionHour, Format(TicketAccessEntry."Access Time", 0, '<Hours24>'));

        FactKey := StrSubstNo('[%1][%2][%3][%4][%5][%6]', ItemFactCode, TicketTypeFactCode, TicketAccessEntry."Admission Code", Format(TicketAccessEntry."Access Date", 0, 9), AdmissionHour, VariantFactCode);
        if (not Statistics.ContainsKey(FactKey)) then begin
            InitializeLeaf(TicketStatisticsLeaf, TicketAccessEntry."Admission Code", TicketAccessEntry."Access Date", MaxAdmissionEntryNo, ItemFactCode, TicketTypeFactCode, VariantFactCode, AdmissionHour);
            ReplaceAdmissionCount(TicketStatisticsLeaf, AdmissionType, IsReEntry, TicketAccessEntry.Quantity);

            Statistics.Add(FactKey, TicketStatisticsLeaf);
        end else begin
            TicketStatisticsLeaf := Statistics.Get(FactKey);
            ReplaceAdmissionCount(TicketStatisticsLeaf, AdmissionType, IsReEntry, TicketAccessEntry.Quantity);
            TicketStatisticsLeaf.Replace('MaxAdmissionEntryNo', MaxAdmissionEntryNo);
        end;

    end;

    internal procedure AdjustStatistics(var TicketAccessEntry: Record "NPR TM Ticket Access Entry"; Ticket: Record "NPR TM Ticket"; MaxAdmissionEntryNo: Integer; AdmissionType: Option; IsReEntry: Boolean)
    var
        Statistics: Dictionary of [Text, JSonObject];
        TempTicketStatisticsResult: Record "NPR TM Ticket Access Stats" temporary;
    begin
        AggregateStatistics(Statistics, TicketAccessEntry, Ticket, MaxAdmissionEntryNo, AdmissionType, IsReEntry);
        SaveStatistics(Statistics, false, TempTicketStatisticsResult, false);
    end;

    local procedure ReplaceAdmissionCount(var Statistics: JSonObject; AdmissionType: Option; IsReEntry: Boolean; AdmissionCount: Decimal)
    var
        DetailAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        if (AdmissionType = DetailAccessEntry.Type::ADMITTED) then begin
            if (not IsReEntry) then begin
                Statistics.Replace('AdmissionCount', AsInteger(Statistics, 'AdmissionCount') + Abs(AdmissionCount));
            end;

            if (IsReEntry) then
                Statistics.Replace('AdmissionCountReEntry', AsInteger(Statistics, 'AdmissionCountReEntry') + Abs(AdmissionCount));
        end;

        if (AdmissionType = DetailAccessEntry.Type::CANCELED_ADMISSION) then begin
            if (not IsReEntry) then
                Statistics.Replace('AdmissionCountNeg', AsInteger(Statistics, 'AdmissionCountNeg') + Abs(AdmissionCount));
        end;

        if (AdmissionType = DetailAccessEntry.Type::INITIAL_ENTRY) then begin
            if (AdmissionCount > 0) then
                Statistics.Replace('GeneratedCountPos', AsInteger(Statistics, 'GeneratedCountPos') + AdmissionCount);

            if (AdmissionCount < 0) then
                Statistics.Replace('GeneratedCountNeg', AsInteger(Statistics, 'GeneratedCountNeg') + Abs(AdmissionCount));
        end;
    end;


    local procedure SaveStatistics(var Statistics: Dictionary of [Text, JSonObject]; AdHoc: Boolean; var TempAdHocTicketStatistics: Record "NPR TM Ticket Access Stats"; Verbose: Boolean)
    var
        FactKey: Text;
        TicketStatisticsJson: JsonObject;
        TicketStatistics: Record "NPR TM Ticket Access Stats";
    begin

        if (GuiAllowed and Verbose) then
            Window.Update(1, Text002);

        foreach FactKey in Statistics.Keys do begin

            TicketStatisticsJson := Statistics.Get(FactKey);
            if (not AdHoc) then begin
                // Transfer to persistent table
                TransferJsonToRecord(TicketStatisticsJson, TicketStatistics);
                TicketStatistics."Entry No." := 0;
                TicketStatistics.Insert();
            end else begin
                // Transfer from dictionary to temp table for further processing
                TransferJsonToRecord(TicketStatisticsJson, TempAdHocTicketStatistics);
                AdHocEntryCounter += 1;
                TempAdHocTicketStatistics."Entry No." := AdHocEntryCounter;
                TempAdHocTicketStatistics.Insert();
            end;
        end;
    end;

    procedure StatisticsDrillDown(LineFactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period; LineFactCode: Code[20]; ColumnFactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period; ColumnFactCode: Code[20]; ColumnFilter: Boolean; var TicketStatisticsFilter: Record "NPR TM Ticket Access Stats"; PeriodFilter: Text)
    var
        TicketStatistics: Record "NPR TM Ticket Access Stats";
        "Page": Page "NPR TM Ticket Access Stats";
    begin

        TicketStatistics.Reset();
        TicketStatistics.Init();

        TicketStatistics.CopyFilters(TicketStatisticsFilter);
        SetCodeFilter(LineFactOption, LineFactCode, TicketStatistics, PeriodFilter);

        if (ColumnFilter) then
            SetCodeFilter(ColumnFactOption, ColumnFactCode, TicketStatistics, PeriodFilter);

        if (PeriodFilter <> '') then
            if ((LineFactOption <> LineFactOption::"Admission Date") and (ColumnFactOption <> ColumnFactOption::"Admission Date")) then
                TicketStatistics.SetFilter("Admission Date", PeriodFilter);

        Page.SetTableView(TicketStatistics);
        Page.Run();
    end;

    local procedure CheckForReEntry(DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry"; ReEntryOption: Option): Boolean
    var
        DetTicketAccessEntry2: Record "NPR TM Det. Ticket AccessEntry";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
    begin

        if (ReEntryOption = TicketAdmissionBOM."Revisit Condition (Statistics)"::NEVER) then
            exit(false);

        DetTicketAccessEntry2.SetCurrentKey("Ticket Access Entry No.", Type);
        DetTicketAccessEntry2.SetFilter("Ticket Access Entry No.", '=%1', DetTicketAccessEntry."Ticket Access Entry No.");
        DetTicketAccessEntry2.SetFilter(Type, '=%1', DetTicketAccessEntry.Type);
        DetTicketAccessEntry2.SetFilter("Entry No.", '<%1', DetTicketAccessEntry."Entry No.");

        if (ReEntryOption = TicketAdmissionBOM."Revisit Condition (Statistics)"::DAILY_NONINITIAL) then
            if (DetTicketAccessEntry.AdmittedDate = 0D) then
                DetTicketAccessEntry2.SetFilter("Created Datetime", '%1..%2', CreateDateTime(DT2Date(DetTicketAccessEntry."Created Datetime"), 0T), CreateDateTime(DT2Date(DetTicketAccessEntry."Created Datetime"), 235959.999T))
            else
                DetTicketAccessEntry2.SetFilter(AdmittedDate, '=%1', DetTicketAccessEntry.AdmittedDate);

        exit(not DetTicketAccessEntry2.IsEmpty());
    end;

    local procedure SelectEntriesOnDateTime(var FirstEntryNo: Integer; var LastEntryNo: Integer; var StartDate: Date; var MaxDate: Date)
    var
        DetailAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketStatistics: Record "NPR TM Ticket Access Stats";
        StartHour: Integer;
        StartTime: Time;
        ZeroHourPrefix: Text[30];
        MaxTime: Time;
        MaxHour: Integer;
        MaxTimeLbl: Label '%1%2:00:00', Locked = true;
        StartTimeLbl: Label '%1%2%3', Locked = true;
    begin

        // Find max date / time for compression
        MaxTime := 235959.999T; //TIME;
        MaxDate := Today();
        MaxDate := CalcDate('<-1D>', Today);

        // Find from which time to start
        StartDate := DMY2Date(1, 1, 1900);
        StartTime := 0T;
        if (TicketStatistics.Find('+')) then begin
            StartDate := TicketStatistics."Admission Date";
            StartHour := TicketStatistics."Admission Hour";
            if (StartHour = 23) then begin
                StartDate := CalcDate('<+1D>', StartDate);
                StartHour := 0;
            end else begin
                StartHour += 1;
            end;
            if (StartHour < 10) then ZeroHourPrefix := '0';
            Evaluate(StartTime, StrSubstNo(StartTimeLbl, ZeroHourPrefix, Format(StartHour), ':00:00'), 9);
        end;

        // find first entry to compress
        DetailAccessEntry.SetCurrentKey(Type, "Created Datetime");
        DetailAccessEntry.SetFilter(Type, '=%1', DetailAccessEntry.Type::ADMITTED);
        DetailAccessEntry.SetFilter("Created Datetime", '>%1', CreateDateTime(StartDate, StartTime));
        if (not DetailAccessEntry.FindFirst()) then exit;
        FirstEntryNo := DetailAccessEntry."Entry No.";

        // find last entry no
        DetailAccessEntry.FindLast();
        if (CurrentDateTime - DetailAccessEntry."Created Datetime" < 3600 * 1000) then begin
            MaxDate := DT2Date(DetailAccessEntry."Created Datetime");
            MaxTime := DT2Time(DetailAccessEntry."Created Datetime");
            Evaluate(MaxHour, Format(MaxTime, 0, '<Hours24>'));
            ZeroHourPrefix := '';
            if (MaxHour < 10) then ZeroHourPrefix := '0';
            Evaluate(MaxTime, StrSubstNo(MaxTimeLbl, ZeroHourPrefix, Format(MaxHour)));
            DetailAccessEntry.SetFilter("Created Datetime", '<%1', CreateDateTime(MaxDate, MaxTime));
            DetailAccessEntry.FindLast();
        end;
        LastEntryNo := DetailAccessEntry."Entry No.";
    end;

    local procedure SelectEntries(var FirstEntryNo: Integer; var LastEntryNo: Integer; var StartDate: Date; var MaxDate: Date): Integer
    var
        TicketAccessStatistics: Record "NPR TM Ticket Access Stats";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        SelectLatestVersion();

        FirstEntryNo := 0;
        LastEntryNo := 0;

        TicketAccessStatistics.SetCurrentKey("Highest Access Entry No.");

        if (TicketAccessStatistics.FindLast()) then
            if (TicketAccessStatistics."Highest Access Entry No." = 0) then
                exit(-1);

        DetTicketAccessEntry.SetFilter("Entry No.", '>%1', TicketAccessStatistics."Highest Access Entry No.");
        if (not DetTicketAccessEntry.FindFirst()) then
            exit(0);

        FirstEntryNo := DetTicketAccessEntry."Entry No.";
        StartDate := DT2Date(DetTicketAccessEntry."Created Datetime");

        DetTicketAccessEntry.FindLast();
        LastEntryNo := DetTicketAccessEntry."Entry No.";
        MaxDate := DT2Date(DetTicketAccessEntry."Created Datetime");

        exit(LastEntryNo);
    end;

    local procedure LockResource()
    var
        TicketAccessFact: Record "NPR TM Ticket Access Fact";
    begin

        if (TicketAccessFact.IsEmpty()) then
            exit;

        TicketAccessFact.LockTable(true);
        TicketAccessFact.FindFirst();

    end;

    local procedure InitializeLeaf(var TicketStatisticsLeaf: JsonObject; AdmissionCode: Code[20]; AccessDate: Date; MaxAdmissionEntryNo: Integer; ItemFactCode: Code[20]; TicketTypeFactCode: Code[20]; VariantFactCode: Code[10]; AdmissionHour: Integer)
    begin
        TicketStatisticsLeaf.Add('ItemCode', ItemFactCode);
        TicketStatisticsLeaf.Add('TicketTypeCode', TicketTypeFactCode);
        TicketStatisticsLeaf.Add('AdmissionCode', AdmissionCode);
        TicketStatisticsLeaf.Add('AccessDate', AccessDate);
        TicketStatisticsLeaf.Add('AdmissionHour', AdmissionHour);
        TicketStatisticsLeaf.Add('VariantCode', VariantFactCode);

        TicketStatisticsLeaf.Add('MaxAdmissionEntryNo', MaxAdmissionEntryNo);

        TicketStatisticsLeaf.Add('AdmissionCount', 0);
        TicketStatisticsLeaf.Add('AdmissionCountReEntry', 0);
        TicketStatisticsLeaf.Add('AdmissionCountNeg', 0);
        TicketStatisticsLeaf.Add('GeneratedCountPos', 0);
        TicketStatisticsLeaf.Add('GeneratedCountNeg', 0);
    end;

    local procedure TransferJsonToRecord(TicketStatisticsJson: JsonObject; var TicketStatistics: Record "NPR TM Ticket Access Stats")
    begin
        TicketStatistics."Item No." := AsCode20(TicketStatisticsJson, 'ItemCode');
        TicketStatistics."Ticket Type" := AsCode20(TicketStatisticsJson, 'TicketTypeCode');
        TicketStatistics."Admission Code" := AsCode20(TicketStatisticsJson, 'AdmissionCode');
        TicketStatistics."Admission Date" := AsDate(TicketStatisticsJson, 'AccessDate');
        TicketStatistics."Admission Hour" := AsInteger(TicketStatisticsJson, 'AdmissionHour');
        TicketStatistics."Variant Code" := AsCode10(TicketStatisticsJson, 'VariantCode');

        TicketStatistics."Highest Access Entry No." := AsInteger(TicketStatisticsJson, 'MaxAdmissionEntryNo');

        TicketStatistics."Admission Count" := AsInteger(TicketStatisticsJson, 'AdmissionCount');
        TicketStatistics."Admission Count (Re-Entry)" := AsInteger(TicketStatisticsJson, 'AdmissionCountReEntry');
        TicketStatistics."Admission Count (Neg)" := AsInteger(TicketStatisticsJson, 'AdmissionCountNeg');
        TicketStatistics."Generated Count (Pos)" := AsInteger(TicketStatisticsJson, 'GeneratedCountPos');
        TicketStatistics."Generated Count (Neg)" := AsInteger(TicketStatisticsJson, 'GeneratedCountNeg');
    end;

    local procedure AsInteger(JObject: JsonObject; KeyName: Text): Integer
    var
        JToken: JsonToken;
    begin
        JObject.Get(KeyName, JToken);
        exit(JToken.AsValue().AsInteger());
    end;

    local procedure AsDate(JObject: JsonObject; KeyName: Text): Date
    var
        JToken: JsonToken;
    begin
        JObject.Get(KeyName, JToken);
        exit(JToken.AsValue().AsDate());
    end;

#pragma warning disable AA0139
    local procedure AsCode10(JObject: JsonObject; KeyName: Text): Code[10]
    var
        JToken: JsonToken;
        Result: Text;
    begin
        JObject.Get(KeyName, JToken);
        Result := JToken.AsValue().AsText();
        exit(Result);
    end;

    local procedure AsCode20(JObject: JsonObject; KeyName: Text): Code[20]
    var
        JToken: JsonToken;
        Result: Text;
    begin
        JObject.Get(KeyName, JToken);
        Result := JToken.AsValue().AsText();
        exit(Result);
    end;
#pragma warning restore AA0139
}

