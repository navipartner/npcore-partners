codeunit 6060114 "TM Ticket Access Statistics"
{
    // NPR4.14/TSA/20150803 CASE214262 - Initial Version
    // TM1.00/TSA /20151217 CASE 228982 NaviPartner Ticket Management
    // TM1.07/TSA /20160125 CASE 232495 Admission Code as a fact in ticket statistics
    // TM1.12/TSA /20160407 CASE 230600 Added DAN Captions
    // TM1.14/TSA /20160520 CASE 240358 Fixed various features witht the RTC version of Access Statistics Matrix
    // TM1.15/TSA /20160530 CASE 242771 Added a vertical sum (CalcVerticalTotal) function
    // TM1.17/TSA /20161025 CASE 256152 Conform to OMA Guidelines
    // TM1.20/TSA /20170314 CASE 263142 Recognize the initial change from 0D to date as an invalid reason for commiting the statistics.
    // TM1.22/TSA /20170601 CASE 274464 Changing the principal for recognizing last transaction aggregated
    // TM1.23/TSA /20170719 CASE 279257 Fixed minor issues with blocking facts
    // TM1.26/TSA /20171120 CASE 293916 Added support for AdmissionDefinition parameter - refactored CalcCount and CalcVerticalTotal
    // TM1.29/TSA /20180315 CASE 308299 I18 hardcoded date
    // TM1.33/TSA /20180525 CASE 316468 Only cancelled admissions should count as cancelled, (not cancelled sales)
    // TM1.36/TSA /20180727 CASE 323024 Added dimension variant code
    // TM1.36/TSA /20180727 CASE 323400 Added Sum Admission Count (Re-Entry) handling
    // TM1.39/TSA /20181120 CASE 336823 Fixed a concurrency issue when 2 people update statistics at the exact same time.
    // TM1.39/TSA /20190103 CASE 341289 Hide lines that have zero count
    // TM1.39/TSA /20190122 CASE 341335 Expose adhoc statistics to 3rd party.


    trigger OnRun()
    begin
        BuildCompressedStatistics (Today);
    end;

    var
        Dialog001: Label '#1###################\@2@@@@@@@@@@@@@@@@@@@';
        Text001: Label 'Calculating... (%1)';
        Text002: Label 'Saving...';
        Text003: Label 'Statistics are not completly up to date for range %1.\Do you want to update them now?';
        Text004: Label 'There are no ticket statistics to display.';
        EntryNoIndex: Integer;
        Window: Dialog;
        ProgressMaxCount: Integer;
        ProgressCurrentCount: Integer;
        AdHocEntryCounter: Integer;

    procedure FindRec(DimOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code";var DimCodeBuffer: Record "Dimension Code Buffer";Which: Text[1024];var FactFilter: Record "TM Ticket Access Fact";PeriodType: Option;PeriodFilter: Text[30];var PeriodInitialized: Boolean;InternalDateFilter: Text[30]) Found: Boolean
    var
        TicketFact: Record "TM Ticket Access Fact";
        Period: Record Date;
        PeriodFormMgt: Codeunit PeriodFormManagement;
    begin

        TicketFact."Fact Code" := DimCodeBuffer.Code;
        TicketFact.SetCurrentKey ("Fact Name", "Fact Code");
        TicketFact.CopyFilters (FactFilter);
        TicketFact.SetFilter (Block, '=%1', false);

        case DimOption of
          DimOption::Item :
            begin
              TicketFact.SetFilter ("Fact Name", '=%1', TicketFact."Fact Name"::ITEM);
              TicketFact."Fact Name" := TicketFact."Fact Name"::ITEM;
              Found := TicketFact.Find (Which);
              if (Found) then
                CopyFactToBuf (TicketFact, DimCodeBuffer);
            end;
          DimOption::"Ticket Type" :
            begin
              TicketFact.SetFilter ("Fact Name", '=%1', TicketFact."Fact Name"::TICKET_TYPE);
              TicketFact."Fact Name" := TicketFact."Fact Name"::TICKET_TYPE;
              Found := TicketFact.Find (Which);
              if (Found) then
                CopyFactToBuf (TicketFact, DimCodeBuffer);
            end;
          DimOption::"Admission Date" :
            begin
              TicketFact.SetFilter ("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_DATE);
              TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_DATE;
              Found := TicketFact.Find (Which);
              if (Found) then
                CopyFactToBuf (TicketFact, DimCodeBuffer);
            end;
          DimOption::"Admission Hour" :
            begin
              TicketFact.SetFilter ("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_HOUR);
              TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_HOUR;
              Found := TicketFact.Find (Which);
              if (Found) then
                CopyFactToBuf (TicketFact, DimCodeBuffer);
            end;
          DimOption::"Admission Code" :
            begin
              TicketFact.SetFilter ("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_CODE);
              TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_CODE;
              Found := TicketFact.Find (Which);
              if (Found) then
                CopyFactToBuf (TicketFact, DimCodeBuffer);
            end;

          DimOption::Period :
            begin
              Period."Period Start" := DimCodeBuffer."Period Start";
              if (PeriodFilter <> '') then
                Period.SetFilter("Period Start", PeriodFilter)
              else
                if (not PeriodInitialized and (InternalDateFilter <> '')) then
                  Period.SetFilter ("Period Start", InternalDateFilter);

              Found := PeriodFormMgt.FindDate (Which, Period, PeriodType);
              if Found then
                CopyPeriodToBuf (Period, DimCodeBuffer, PeriodFilter);

              PeriodInitialized := true;
            end;

          //-TM1.36 [323024]
          DimOption::"Variant Code" :
            begin
              TicketFact.SetFilter ("Fact Name", '=%1', TicketFact."Fact Name"::VARIANT_CODE);
              TicketFact."Fact Name" := TicketFact."Fact Name"::VARIANT_CODE;
              Found := TicketFact.Find (Which);
              if (Found) then
                CopyFactToBuf (TicketFact, DimCodeBuffer);
            end;
          //+TM1.36 [323024]

          else
            Error ('Unhandled option value in FindRec()');
        end;

        //-TM1.39 [341289]
        DimCodeBuffer.Visible := false;
        //+TM1.39 [341289]

        exit (Found);
    end;

    procedure NextRec(DimOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code";var DimCodeBuffer: Record "Dimension Code Buffer";Steps: Integer;var FactFilter: Record "TM Ticket Access Fact";PeriodType: Option;PeriodFilter: Text[30]) ResultSteps: Integer
    var
        TicketFact: Record "TM Ticket Access Fact";
        Period: Record Date;
        PeriodFormMgt: Codeunit PeriodFormManagement;
    begin

        TicketFact.SetCurrentKey ("Fact Name", "Fact Code");
        TicketFact."Fact Code" := DimCodeBuffer.Code;
        TicketFact.CopyFilters (FactFilter);
        TicketFact.SetFilter (Block, '=%1', false);

        case DimOption of
          DimOption::Item :
            begin
              TicketFact.SetFilter ("Fact Name", '=%1', TicketFact."Fact Name"::ITEM);
              TicketFact."Fact Name" := TicketFact."Fact Name"::ITEM;
              ResultSteps := TicketFact.Next (Steps);
              if (ResultSteps <> 0) then
                CopyFactToBuf (TicketFact, DimCodeBuffer);
            end;
          DimOption::"Ticket Type" :
            begin
              TicketFact.SetFilter ("Fact Name", '=%1', TicketFact."Fact Name"::TICKET_TYPE);
              TicketFact."Fact Name" := TicketFact."Fact Name"::TICKET_TYPE;
              ResultSteps := TicketFact.Next (Steps);
              if (ResultSteps <> 0) then
                CopyFactToBuf (TicketFact, DimCodeBuffer);
            end;
          DimOption::"Admission Date" :
            begin
              TicketFact.SetFilter ("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_DATE);
              TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_DATE;
              ResultSteps := TicketFact.Next (Steps);
              if (ResultSteps <> 0) then
                CopyFactToBuf (TicketFact, DimCodeBuffer);
            end;
          DimOption::"Admission Hour" :
            begin
              TicketFact.SetFilter ("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_HOUR);
              TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_HOUR;
              ResultSteps := TicketFact.Next (Steps);
              if (ResultSteps <> 0) then
                CopyFactToBuf (TicketFact, DimCodeBuffer);
            end;
          DimOption::"Admission Code" :
            begin
              TicketFact.SetFilter ("Fact Name", '=%1', TicketFact."Fact Name"::ADMISSION_CODE);
              TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_CODE;
              ResultSteps := TicketFact.Next (Steps);
              if (ResultSteps <> 0) then
                CopyFactToBuf (TicketFact, DimCodeBuffer);
            end;
           DimOption::Period :
            begin
              if (PeriodFilter <> '') then
                Period.SetFilter ("Period Start", PeriodFilter);

              Period."Period Start" := DimCodeBuffer."Period Start";
              ResultSteps := PeriodFormMgt.NextDate (Steps, Period, PeriodType);
              if (ResultSteps <> 0) then
                CopyPeriodToBuf (Period, DimCodeBuffer, PeriodFilter);
            end;
          //-TM1.36 [323024]
          DimOption::"Variant Code" :
            begin
              TicketFact.SetFilter ("Fact Name", '=%1', TicketFact."Fact Name"::VARIANT_CODE);
              TicketFact."Fact Name" := TicketFact."Fact Name"::VARIANT_CODE;
              ResultSteps := TicketFact.Next (Steps);
              if (ResultSteps <> 0) then
                CopyFactToBuf (TicketFact, DimCodeBuffer);
            end;
          //+TM1.36 [323024]
          else
            Error ('Unhandled option value in NextRec()');
        end;

        //-TM1.39 [341289]
        DimCodeBuffer.Visible := false;
        //+TM1.39 [341289]

        exit (ResultSteps);
    end;

    procedure CopyFactToBuf(TicketFact: Record "TM Ticket Access Fact";var DimCodeBuf: Record "Dimension Code Buffer")
    begin

        DimCodeBuf.Init;
        DimCodeBuf.Code := TicketFact."Fact Code";
        DimCodeBuf.Name := TicketFact.Description;
    end;

    local procedure CopyPeriodToBuf(var Period: Record Date;var DimCodeBuf: Record "Dimension Code Buffer";DateFilter: Text[30])
    var
        Period2: Record Date;
    begin

        with DimCodeBuf do begin
          Init;
          Code := Format(Period."Period Start");
          "Period Start" := Period."Period Start";
          "Period End" := Period."Period End";
          if DateFilter <> '' then begin
            Period2.SetFilter("Period End",DateFilter);
            if Period2.GetRangeMax("Period End") < "Period End" then
              "Period End" := Period2.GetRangeMax("Period End");
          end;
          Name := Period."Period Name";
        end;
    end;

    procedure CalcCount(LineFactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code";LineFactCode: Code[20];ColumnFactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code";ColumnFactCode: Code[20];ColumnFilter: Boolean;var TicketStatisticsFilter: Record "TM Ticket Access Statistics";PeriodFilter: Text[30];AdmissionDefinition: Option) SumAdmissionCount: Decimal
    var
        TicketStatistics: Record "TM Ticket Access Statistics";
    begin

        //-TM1.26 [293916] Refactored
        TicketStatistics.Reset();
        TicketStatistics.Init();
        SumAdmissionCount := 0;

        TicketStatistics.CopyFilters (TicketStatisticsFilter);
        SetCodeFlowFilter (LineFactOption, LineFactCode, TicketStatistics, PeriodFilter);

        if (ColumnFilter) then
          SetCodeFlowFilter (ColumnFactOption, ColumnFactCode, TicketStatistics, PeriodFilter);

        if (PeriodFilter <> '') then
          if ((LineFactOption <> LineFactOption::"Admission Date") and (ColumnFactOption <> ColumnFactOption::"Admission Date")) then
            TicketStatistics.SetFilter ("Admission Date Filter", PeriodFilter);

        case AdmissionDefinition of
          0 : TicketStatistics.CalcFields ("Sum Admission Count");
          1 : TicketStatistics.CalcFields ("Sum Admission Count", "Sum Admission Count (Neg)");
          2 : TicketStatistics.CalcFields ("Sum Admission Count", "Sum Admission Count (Re-Entry)"); //-+TM1.36 [323400]
        end;

        case AdmissionDefinition of
          0 : SumAdmissionCount := TicketStatistics."Sum Admission Count";
          1 : SumAdmissionCount := TicketStatistics."Sum Admission Count" - TicketStatistics."Sum Admission Count (Neg)";
          2 : SumAdmissionCount := TicketStatistics."Sum Admission Count" + TicketStatistics."Sum Admission Count (Re-Entry)";//-+TM1.36 [323400]
        end;

        exit (SumAdmissionCount);
    end;

    procedure CalcVerticalTotal(LineFactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code";ColumnFactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code";var TicketStatisticsFilter: Record "TM Ticket Access Statistics";PeriodFilter: Text[30];AdmissionDefinition: Option) AdmissionTotal: Decimal
    var
        TicketStatistics: Record "TM Ticket Access Statistics";
    begin

        //-TM1.26 [293916] Refactored
        TicketStatistics.Reset();
        TicketStatistics.Init();
        AdmissionTotal := 0;

        TicketStatistics.CopyFilters (TicketStatisticsFilter);

        if (PeriodFilter <> '') then
          if ((LineFactOption <> LineFactOption::"Admission Date") and
              (ColumnFactOption <> ColumnFactOption::"Admission Date")) then
            TicketStatistics.SetFilter ("Admission Date Filter", PeriodFilter);

        case AdmissionDefinition of
          0 : TicketStatistics.CalcFields ("Sum Admission Count");
          1 : TicketStatistics.CalcFields ("Sum Admission Count", "Sum Admission Count (Neg)");
          2 : TicketStatistics.CalcFields ("Sum Admission Count", "Sum Admission Count (Re-Entry)"); //-+TM1.36 [323400]
        end;

        case AdmissionDefinition of
          0 : AdmissionTotal := TicketStatistics."Sum Admission Count";
          1 : AdmissionTotal := TicketStatistics."Sum Admission Count" - TicketStatistics."Sum Admission Count (Neg)";
          2 : AdmissionTotal := TicketStatistics."Sum Admission Count" + TicketStatistics."Sum Admission Count (Re-Entry)";//-+TM1.36 [323400]
        end;

        exit (AdmissionTotal);
    end;

    procedure FormatCellValue(LineFactOption: Option;LineFactCode: Code[20];ColumnFactOption: Option;ColumnFactCode: Code[20];ColumnFilter: Boolean;var TicketStatisticsFilter: Record "TM Ticket Access Statistics";PeriodFilter: Text[30];DisplayOption: Option "COUNT",COUNT_TREND,TREND;PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";TrendPeriodType: Option PERIOD,YEAR;AdmissionDefinition: Option) CellValue: Text[1024]
    var
        AdmissionCount: Decimal;
        AdmissionCount2: Decimal;
    begin

        AdmissionCount := CalcCount (LineFactOption, LineFactCode,
                            ColumnFactOption, ColumnFactCode, ColumnFilter,
                            TicketStatisticsFilter, PeriodFilter, AdmissionDefinition);

        if (AdmissionCount = 0) then begin
          CellValue := '';
        end else begin
          CellValue := StrSubstNo ('%1', AdmissionCount);
        end;

        if (PeriodFilter <> '') and (DisplayOption > DisplayOption::COUNT) then begin
          PeriodFilter := FindMatricsPeriod ('<=', PeriodFilter, PeriodType, TrendPeriodType);

          AdmissionCount2 := CalcCount (LineFactOption, LineFactCode,
                               ColumnFactOption, ColumnFactCode, ColumnFilter,
                               TicketStatisticsFilter, PeriodFilter, AdmissionDefinition);

          CellValue := '';
          case DisplayOption of
            DisplayOption::COUNT_TREND :
              begin
                if ((AdmissionCount2 = 0) and (AdmissionCount <> 0)) then
                  CellValue := StrSubstNo ('%1 [%2]', AdmissionCount, '---');
                if (AdmissionCount2 <> 0) then
                  CellValue := StrSubstNo ('%1 [%2%]', AdmissionCount, Round((AdmissionCount - AdmissionCount2)/AdmissionCount2*100, 1));

                // CellValue := STRSUBSTNO ('%1 [%2] {%3}', AdmissionCount, AdmissionCount2, PeriodFilter);
              end;
            DisplayOption::TREND :
              begin
                if ((AdmissionCount2 = 0) and (AdmissionCount <> 0)) then
                  CellValue := StrSubstNo ('[%1]', '---');
                if (AdmissionCount2 <> 0) then
                  CellValue := StrSubstNo ('[%1%]', Round((AdmissionCount - AdmissionCount2)/AdmissionCount2*100, 1));
              end;
          end;
        end;
    end;

    procedure SetCodeFilter(FactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code";FactCode: Code[20];var TicketStatistics: Record "TM Ticket Access Statistics";PeriodFilter: Text[30])
    var
        FactDateBucket: Date;
        FactHourBucket: Integer;
    begin

        case FactOption of
          FactOption::Item :
            TicketStatistics.SetFilter ("Item No.", '=%1', FactCode);

          FactOption::"Ticket Type" :
            TicketStatistics.SetFilter ("Ticket Type", '=%1', FactCode);

          FactOption::"Admission Code" :
            TicketStatistics.SetFilter ("Admission Code", '=%1', FactCode);

          FactOption::"Admission Date" :
            begin
              if (Evaluate (FactDateBucket, FactCode, 9)) then
                TicketStatistics.SetFilter ("Admission Date", '%1', FactDateBucket);
            end;

          FactOption::"Admission Hour" :
            begin
              if (Evaluate (FactHourBucket, FactCode)) then
                TicketStatistics.SetFilter ("Admission Hour", '=%1', FactHourBucket);
            end;

          FactOption::Period :
            TicketStatistics.SetFilter ("Admission Date", PeriodFilter);

          //-TM1.36 [323024]
          FactOption::"Variant Code" :
            TicketStatistics.SetFilter ("Variant Code", '=%1', FactCode);
          //+TM1.36 [323024]

          else
            Error ('Unhandled option value in SetCodeFilter()');

        end;
    end;

    procedure SetCodeFlowFilter(FactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period,"Admission Code","Variant Code";FactCode: Code[20];var TicketStatistics: Record "TM Ticket Access Statistics";PeriodFilter: Text[30])
    var
        FactDateBucket: Date;
        FactHourBucket: Integer;
    begin

        case FactOption of
          FactOption::Item :
            TicketStatistics.SetFilter ("Item No. Filter", '=%1', FactCode);

          FactOption::"Ticket Type" :
            TicketStatistics.SetFilter ("Ticket Type Filter", '=%1', FactCode);

          FactOption::"Admission Code" :
            TicketStatistics.SetFilter ("Admission Code Filter", '=%1', FactCode);

          FactOption::"Admission Date" :
            begin
              if (Evaluate (FactDateBucket, FactCode, 9)) then
                TicketStatistics.SetFilter ("Admission Date Filter", '%1', FactDateBucket);
            end;

          FactOption::"Admission Hour" :
            begin
              if (Evaluate (FactHourBucket, FactCode)) then
                TicketStatistics.SetFilter ("Admission Hour Filter", '=%1', FactHourBucket);
            end;

          FactOption::Period :
            TicketStatistics.SetFilter ("Admission Date Filter", PeriodFilter);

          //-TM1.36 [323024]
          FactOption::"Variant Code" :
            TicketStatistics.SetFilter ("Variant Code Filter", '=%1', FactCode);
          //+TM1.36 [323024]

          else
            Error ('Unhandled option value in SetCodeFlowFilter()');

        end;
    end;

    procedure FindMatricsPeriod(SearchText: Code[10];BaseDate: Text[30];PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";TrendPeriodType: Option PERIOD,YEAR) MatricsDateFilter: Text[30]
    var
        TicketStatistics: Record "TM Ticket Access Statistics";
        Calendar: Record Date;
        PeriodFormMgt: Codeunit PeriodFormManagement;
    begin

        if (BaseDate <> '') then begin
          Calendar.SetFilter ("Period Start", BaseDate);
          if (not PeriodFormMgt.FindDate ('+', Calendar, PeriodType)) then
            PeriodFormMgt.FindDate ('+', Calendar, PeriodType::Day);

          Calendar.SetRange ("Period Start");
        end;

        if (TrendPeriodType = TrendPeriodType::PERIOD) then begin
          PeriodFormMgt.FindDate (SearchText, Calendar, PeriodType);
          TicketStatistics.SetRange ("Admission Date Filter", Calendar."Period Start", Calendar."Period End");
        end;

        if (TrendPeriodType = TrendPeriodType::YEAR) then begin
          PeriodFormMgt.FindDate ('', Calendar, PeriodType);
          TicketStatistics.SetRange ("Admission Date Filter", CalcDate ('<-1Y>', Calendar."Period Start"),
                                                              CalcDate ('<-1Y>', Calendar."Period End"));
        end;

        if TicketStatistics.GetRangeMin("Admission Date Filter") = TicketStatistics.GetRangeMax("Admission Date Filter") then
          TicketStatistics.SetRange("Admission Date Filter", TicketStatistics.GetRangeMin("Admission Date Filter"));

        MatricsDateFilter := TicketStatistics.GetFilter("Admission Date Filter");
    end;

    procedure BuildCompressedStatistics(SuggestedMaxDate: Date)
    var
        TicketAccessEntry: Record "TM Ticket Access Entry";
        DetailAccessEntry: Record "TM Det. Ticket Access Entry";
        TmpTicketStatistics: Record "TM Ticket Access Statistics" temporary;
        TmpTicketStatisticsResult: Record "TM Ticket Access Statistics" temporary;
        StartDate: Date;
        MaxDate: Date;
        FirstEntryNo: BigInteger;
        LastEntryNo: BigInteger;
        TmpRecBuf: Record "Record Buffer" temporary;
        PreviousAdmissionDate: Date;
        Ticket: Record "TM Ticket";
        IsReEntry: Boolean;
        DoneAggregating: Boolean;
    begin

        if (not TicketAccessEntry.FindLast()) then
          Message (Text004);

        if (SelectEntries (FirstEntryNo, LastEntryNo, StartDate, MaxDate) = -1) then
          SelectEntriesOnDateTime (FirstEntryNo, LastEntryNo, StartDate, MaxDate); // Handles upgradeded data without "Highest Entry No."

        // Compress and save to DB
        if ((LastEntryNo >= FirstEntryNo) and (LastEntryNo > 0)) then begin

          if (not Confirm (Text003, true, StrSubstNo ('[%1 - %2]', StartDate, MaxDate))) then
            exit;

          //-TM1.39 [336823] Acquire lock and re-acquire workscope.
          LockResource ();
          DoneAggregating := false;
          if (SelectEntries (FirstEntryNo, LastEntryNo, StartDate, MaxDate) = -1) then
            SelectEntriesOnDateTime (FirstEntryNo, LastEntryNo, StartDate, MaxDate); // Handles upgradeded data without "Highest Entry No."

          if (FirstEntryNo = 0) then
            exit; // Done, someone else did all work already.
          //+TM1.39 [336823]

           //-TM1.39 [341335] All code moved to worker
           BuildCompressedStatisticsWorker (FirstEntryNo, LastEntryNo, false, TmpTicketStatisticsResult);
           //+TM1.39 [341335]

        end;
    end;

    procedure BuildCompressedStatisticsAdHoc(FromDate: Date;UntilDate: Date;var TmpTicketStatisticsResult: Record "TM Ticket Access Statistics" temporary)
    var
        DetailAccessEntry: Record "TM Det. Ticket Access Entry";
        FirstEntryNo: BigInteger;
        LastEntryNo: BigInteger;
    begin

        //-TM1.39 [341335]
        if (not TmpTicketStatisticsResult.IsTemporary ()) then
          Error ('Result table must be temporary.');

        DetailAccessEntry.SetFilter ("Created Datetime", '>=%1&<%2', CreateDateTime (FromDate, 0T), CreateDateTime (CalcDate ('<+1D>', UntilDate), 0T));
        if (not DetailAccessEntry.FindFirst ()) then
          exit;

        FirstEntryNo := DetailAccessEntry."Entry No.";

        DetailAccessEntry.FindLast ();
        LastEntryNo := DetailAccessEntry."Entry No.";

        BuildCompressedStatisticsWorker (FirstEntryNo, LastEntryNo, true, TmpTicketStatisticsResult);

        // The date span when translated to an entry number range might find transaction that belong outside the date range (time travel).
        TmpTicketStatisticsResult.SetFilter ("Admission Date", '<%1|>%2', FromDate, UntilDate);
        TmpTicketStatisticsResult.DeleteAll ();

        //+TM1.39 [341335]
    end;

    local procedure BuildCompressedStatisticsWorker(FirstEntryNo: BigInteger;LastEntryNo: BigInteger;AdHoc: Boolean;var TmpTicketStatisticsResult: Record "TM Ticket Access Statistics" temporary)
    var
        TicketAccessEntry: Record "TM Ticket Access Entry";
        DetailAccessEntry: Record "TM Det. Ticket Access Entry";
        TmpTicketStatistics: Record "TM Ticket Access Statistics" temporary;
        TmpRecBuf: Record "Record Buffer" temporary;
        PreviousAdmissionDate: Date;
        Ticket: Record "TM Ticket";
        IsReEntry: Boolean;
        DoneAggregating: Boolean;
    begin

        //-TM1.39 [341335]
        DetailAccessEntry.Reset;
        DetailAccessEntry.SetRange ("Entry No.", FirstEntryNo, LastEntryNo);
        if  (not DetailAccessEntry.FindSet ()) then
          exit;

        ProgressMaxCount := DetailAccessEntry.Count ();
        ProgressCurrentCount := 0;
        EntryNoIndex := 0;
        if (GuiAllowed) then begin
          Window.Open (Dialog001);
          Window.Update (1, StrSubstNo (Text001, ProgressMaxCount));
          Window.Update (2, 0);
        end;

        repeat
          if ((DetailAccessEntry.Type = DetailAccessEntry.Type::ADMITTED) or
              (DetailAccessEntry.Type = DetailAccessEntry.Type::CANCELED) or
              (DetailAccessEntry.Type = DetailAccessEntry.Type::INITIAL_ENTRY)) then begin
            if (TicketAccessEntry.Get (DetailAccessEntry."Ticket Access Entry No.")) then begin

              IsReEntry := CheckForReEntry (DetailAccessEntry);
              TicketAccessEntry."Access Date" := DT2Date (DetailAccessEntry."Created Datetime");
              TicketAccessEntry."Access Time" := DT2Time (DetailAccessEntry."Created Datetime");
              TicketAccessEntry.Quantity := DetailAccessEntry.Quantity;

              //-TM1.39 [341335] No need for fact in adhoc mode
              // AddAccessFact (TicketAccessEntry);
              // AddAccessStatistic (TmpTicketStatistics, TicketAccessEntry, DetailAccessEntry."Entry No.", DetailAccessEntry.Type, IsReEntry);

              if (not AdHoc) then
                AddAccessFact (TicketAccessEntry);
              //+TM1.39 [341335]

              if (GuiAllowed) then begin
                if (ProgressCurrentCount mod 100 = 0) then begin
                  Window.Update (1, StrSubstNo (Text001, ProgressMaxCount-ProgressCurrentCount));
                  Window.Update (2, Round (ProgressCurrentCount/ProgressMaxCount * 10000, 1));
                end;
              end;
              ProgressCurrentCount += 1;

              if (PreviousAdmissionDate <> DT2Date (DetailAccessEntry."Created Datetime")) then begin
                if (PreviousAdmissionDate <> 0D) then begin //-+TM1.20 [263142]
                  SaveStatistics (TmpTicketStatistics, AdHoc, TmpTicketStatisticsResult);
                  TmpTicketStatistics.DeleteAll ();
                  TmpRecBuf.DeleteAll ();
                  Commit;

                  //-TM1.39 [341335] No need to lock resource in adhoc mode,
                  if (not AdHoc) then begin
                    //-TM1.39 [336823] Acquire lock and re-acquire workscope.
                    LockResource ();
                    ReSelectEntries (FirstEntryNo, LastEntryNo);
                    DoneAggregating := (FirstEntryNo = 0);
                    if (not DoneAggregating) then begin
                      DetailAccessEntry.SetRange ("Entry No.", FirstEntryNo, LastEntryNo);
                      DetailAccessEntry.FindSet ();
                    end;
                    //+TM1.39 [336823]
                  end;

                end;
              end;

              //-TM1.39 [341335]
              AddAccessStatistic (TmpTicketStatistics, TicketAccessEntry, DetailAccessEntry."Entry No.", DetailAccessEntry.Type, IsReEntry);
              //+TM1.39 [341335]

              PreviousAdmissionDate := DT2Date (DetailAccessEntry."Created Datetime");

            end;
          end;
        //UNTIL (DetailAccessEntry.NEXT () = 0);
        until ((DetailAccessEntry.Next () = 0) or (DoneAggregating));

        SaveStatistics (TmpTicketStatistics, AdHoc, TmpTicketStatisticsResult);

        if (GuiAllowed) then
          Window.Close ();
    end;

    procedure AddAccessFact(TicketAccessEntry: Record "TM Ticket Access Entry")
    var
        TicketFact: Record "TM Ticket Access Fact";
        TicketType: Record "TM Ticket Type";
        Item: Record Item;
        FactCode: Code[20];
        Ticket: Record "TM Ticket";
        Admission: Record "TM Admission";
        Variant: Record "Item Variant";
    begin

        // Item, annual card have same ticket type for different guest ticket types.
        FactCode := ''; //TicketAccessEntry."Item No.";
        if (FactCode = '') then
          if (Ticket.Get (TicketAccessEntry."Ticket No.")) then
            FactCode := Ticket."Item No.";

        if (FactCode = '') then
          FactCode := '<BLANK>';

        if (not TicketFact.Get (TicketFact."Fact Name"::ITEM, FactCode)) then begin
          TicketFact.Init ();
          TicketFact."Fact Name" := TicketFact."Fact Name"::ITEM;
          TicketFact."Fact Code" := FactCode;
          if (Item.Get (FactCode)) then
            TicketFact.Description := CopyStr (Item.Description, 1, MaxStrLen(TicketFact.Description));
          TicketFact.Insert ();
        end;

        //-TM1.36 [323024]
        // VAriant Code
        FactCode := '';
        if (FactCode = '') then
          if (Ticket.Get (TicketAccessEntry."Ticket No.")) then
            FactCode := Ticket."Variant Code";

        if (FactCode = '') then
          FactCode := '<BLANK>';

        if (not TicketFact.Get (TicketFact."Fact Name"::VARIANT_CODE, FactCode)) then begin
          TicketFact.Init ();
          TicketFact."Fact Name" := TicketFact."Fact Name"::VARIANT_CODE;
          TicketFact."Fact Code" := FactCode;
          if (Variant.Get (Ticket."Item No.", FactCode)) then
            TicketFact.Description := CopyStr (Variant.Description, 1, MaxStrLen(TicketFact.Description));
          TicketFact.Insert ();
        end;
        //+TM1.36 [323024]

        // Ticket Type
        FactCode := '';
        FactCode := TicketAccessEntry."Ticket Type Code";
        if (FactCode = '') then
          FactCode := '<BLANK>';

        if (not TicketFact.Get (TicketFact."Fact Name"::TICKET_TYPE, FactCode)) then begin
          TicketFact.Init ();
          TicketFact."Fact Name" := TicketFact."Fact Name"::TICKET_TYPE;
          TicketFact."Fact Code" := FactCode;
          if (TicketType.Get (FactCode)) then
            TicketFact.Description := TicketType.Description;
          TicketFact.Insert ();
        end;

        // Admission Date
        FactCode := '';
        FactCode := Format (TicketAccessEntry."Access Date", 0, 9);
        if (not TicketFact.Get (TicketFact."Fact Name"::ADMISSION_DATE, FactCode)) then begin
          TicketFact.Init ();
          TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_DATE;
          TicketFact."Fact Code" := FactCode;
          TicketFact.Description := Format (TicketAccessEntry."Access Date", 0, 4);
          TicketFact.Insert ();
        end;

        // Admission Time
        FactCode := '';
        FactCode := Format (TicketAccessEntry."Access Time", 0, '<Hours24,2>');
        if (StrLen (FactCode) = 1) then
          FactCode := StrSubstNo ('0%1', FactCode);
        if (not TicketFact.Get (TicketFact."Fact Name"::ADMISSION_HOUR, FactCode)) then begin
          TicketFact.Init ();
          TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_HOUR;
          TicketFact."Fact Code" := FactCode;
          TicketFact.Description := StrSubstNo ('%1:00 - %1:59', FactCode);
          TicketFact.Insert ();
        end;

        // Admission Code
        FactCode := '';
        FactCode := TicketAccessEntry."Admission Code";
        if (FactCode = '') then
          FactCode := '<BLANK>';

        if (not TicketFact.Get (TicketFact."Fact Name"::ADMISSION_CODE, FactCode)) then begin
          TicketFact.Init ();
          TicketFact."Fact Name" := TicketFact."Fact Name"::ADMISSION_CODE;
          TicketFact."Fact Code" := FactCode;
          if (Admission.Get (FactCode)) then
            TicketFact.Description := TicketType.Description;
          TicketFact.Insert ();
        end;
    end;

    local procedure AddAccessStatistic(var tmpTicketStatistics: Record "TM Ticket Access Statistics";TicketAccessEntry: Record "TM Ticket Access Entry";AdmissionEntryNo: BigInteger;AdmissionType: Option;IsReEntry: Boolean)
    var
        ItemFactCode: Code[20];
        TicketTypeFactCode: Code[20];
        VariantFactCode: Code[10];
        AdmissionHour: Integer;
        Ticket: Record "TM Ticket";
        DetailAccessEntry: Record "TM Det. Ticket Access Entry";
    begin

        //-TM1.33 [316468]
        if (AdmissionType = DetailAccessEntry.Type::CANCELED) then begin
          // only cancelled admissions should count as cancelled
          DetailAccessEntry.SetCurrentKey ("Ticket Access Entry No.", Type);
          DetailAccessEntry.SetFilter ("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
          DetailAccessEntry.SetFilter (Type, '=%1', DetailAccessEntry.Type::ADMITTED);
          if (DetailAccessEntry.IsEmpty ()) then
            exit;
        end;
        //+TM1.33 [316468]


        // Item No.,Ticket Type,Admission Date,Admission Hour
        ItemFactCode := ''; //TicketAccessEntry."Item No.";
        if (ItemFactCode = '') then
          if (Ticket.Get (TicketAccessEntry."Ticket No.")) then begin
            ItemFactCode := Ticket."Item No.";
            //-TM1.36 [323024]
            VariantFactCode := Ticket."Variant Code";
            //+TM1.36 [323024]
          end;

        if (ItemFactCode = '') then
          ItemFactCode := '<BLANK>';

        if (VariantFactCode = '') then
          VariantFactCode := '<BLANK>';

        TicketTypeFactCode := TicketAccessEntry."Ticket Type Code";
        if (TicketTypeFactCode = '') then
          TicketTypeFactCode := '<BLANK>';

        Evaluate (AdmissionHour, Format (TicketAccessEntry."Access Time", 0, '<Hours24>'));

        tmpTicketStatistics.Reset ();
        tmpTicketStatistics.SetFilter ("Item No.", '=%1', ItemFactCode);
        tmpTicketStatistics.SetFilter ("Ticket Type", '=%1', TicketTypeFactCode);
        tmpTicketStatistics.SetFilter ("Admission Code", '=%1',TicketAccessEntry."Admission Code");
        tmpTicketStatistics.SetFilter ("Admission Date", '=%1', TicketAccessEntry."Access Date");
        tmpTicketStatistics.SetFilter ("Admission Hour", '=%1', AdmissionHour);

        //-TM1.36 [323024]
        tmpTicketStatistics.SetFilter ("Variant Code", '=%1', VariantFactCode);
        //+TM1.36 [323024]

        if (tmpTicketStatistics.FindFirst ()) then begin
          SetAdmissionCount (tmpTicketStatistics, AdmissionType, IsReEntry, TicketAccessEntry.Quantity);

          tmpTicketStatistics."Highest Access Entry No." := AdmissionEntryNo;
          tmpTicketStatistics.Modify ();
        end else begin
          EntryNoIndex += 1;
          tmpTicketStatistics.Init ();
          tmpTicketStatistics."Entry No." := EntryNoIndex;
          tmpTicketStatistics."Item No." := ItemFactCode;
          tmpTicketStatistics."Ticket Type" := TicketTypeFactCode;
          tmpTicketStatistics."Admission Code" := TicketAccessEntry."Admission Code";
          tmpTicketStatistics."Admission Date" := TicketAccessEntry."Access Date";
          tmpTicketStatistics."Admission Hour" := AdmissionHour;
          //-TM1.36 [323024]
          tmpTicketStatistics."Variant Code" := VariantFactCode;
          //+TM1.36 [323024]

          SetAdmissionCount (tmpTicketStatistics, AdmissionType, IsReEntry, TicketAccessEntry.Quantity);

          tmpTicketStatistics."Highest Access Entry No." := AdmissionEntryNo;
          tmpTicketStatistics.Insert ();
        end;
    end;

    local procedure SetAdmissionCount(var TmpTicketStatistics: Record "TM Ticket Access Statistics";AdmissionType: Option;IsReEntry: Boolean;AdmissionCount: Decimal)
    var
        DetailAccessEntry: Record "TM Det. Ticket Access Entry";
    begin

        if (AdmissionType = DetailAccessEntry.Type::ADMITTED) then begin
          if (not IsReEntry) then begin
            TmpTicketStatistics."Admission Count" += Abs (AdmissionCount);
          end;

          if (IsReEntry) then
            TmpTicketStatistics."Admission Count (Re-Entry)" += Abs (AdmissionCount);
        end;

        if (AdmissionType = DetailAccessEntry.Type::CANCELED) then begin
          if (not IsReEntry) then
            TmpTicketStatistics."Admission Count (Neg)" += Abs (AdmissionCount);
        end;

        if (AdmissionType = DetailAccessEntry.Type::INITIAL_ENTRY) then begin
          if (AdmissionCount > 0) then
            TmpTicketStatistics."Generated Count (Pos)" += AdmissionCount;

          if (AdmissionCount < 0) then
            TmpTicketStatistics."Generated Count (Neg)" += Abs (AdmissionCount);
        end;
    end;

    procedure SaveStatistics(var tmpTicketStatistics: Record "TM Ticket Access Statistics" temporary;AdHoc: Boolean;var TmpAdHocTicketStatistics: Record "TM Ticket Access Statistics")
    var
        TicketStatistics: Record "TM Ticket Access Statistics";
    begin

        // Transfer stats to DB
        tmpTicketStatistics.Reset ();
        if (tmpTicketStatistics.FindSet ()) then begin

          if (GuiAllowed) then
            Window.Update (1, Text002);

          repeat
            //-TM1.39 [341335]
            // TicketStatistics.TRANSFERFIELDS (tmpTicketStatistics, FALSE);
            // TicketStatistics."Entry No." := 0;
            // TicketStatistics.INSERT ();
            if (not AdHoc) then begin
              TicketStatistics.TransferFields (tmpTicketStatistics, false);
              TicketStatistics."Entry No." := 0;
              TicketStatistics.Insert ();
            end else begin
              AdHocEntryCounter += 1;
              TmpAdHocTicketStatistics.TransferFields (tmpTicketStatistics, false);
              TmpAdHocTicketStatistics."Entry No." := AdHocEntryCounter;
              TmpAdHocTicketStatistics.Insert ();
            end;
            //+TM1.39 [341335]

          until (tmpTicketStatistics.Next () = 0);
        end;
    end;

    procedure StatisticsDrilldown(LineFactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period;LineFactCode: Code[20];ColumnFactOption: Option Item,"Ticket Type","Admission Date","Admission Hour",Period;ColumnFactCode: Code[20];ColumnFilter: Boolean;var TicketStatisticsFilter: Record "TM Ticket Access Statistics";PeriodFilter: Text[30])
    var
        TicketStatistics: Record "TM Ticket Access Statistics";
        "Page": Page "TM Ticket Access Statistics";
    begin

        TicketStatistics.Reset();
        TicketStatistics.Init();

        TicketStatistics.CopyFilters (TicketStatisticsFilter);
        SetCodeFilter (LineFactOption, LineFactCode, TicketStatistics, PeriodFilter);

        if (ColumnFilter) then
          SetCodeFilter (ColumnFactOption, ColumnFactCode, TicketStatistics, PeriodFilter);

        if (PeriodFilter <> '') then
          if ((LineFactOption <> LineFactOption::"Admission Date") and (ColumnFactOption <> ColumnFactOption::"Admission Date")) then
            TicketStatistics.SetFilter ("Admission Date", PeriodFilter);

        Page.SetTableView (TicketStatistics);
        Page.Run ();
    end;

    local procedure CheckForReEntry(DetTicketAccessEntry: Record "TM Det. Ticket Access Entry"): Boolean
    var
        DetTicketAccessEntry2: Record "TM Det. Ticket Access Entry";
    begin

        DetTicketAccessEntry2.SetCurrentKey ("Ticket Access Entry No.",Type);
        DetTicketAccessEntry2.SetFilter ("Ticket Access Entry No.", '=%1', DetTicketAccessEntry."Ticket Access Entry No.");
        DetTicketAccessEntry2.SetFilter (Type, '=%1', DetTicketAccessEntry.Type);
        DetTicketAccessEntry2.SetFilter ("Entry No.", '<%1', DetTicketAccessEntry."Entry No.");

        exit (not DetTicketAccessEntry2.IsEmpty ());
    end;

    local procedure SelectEntriesOnDateTime(var FirstEntryNo: BigInteger;var LastEntryNo: BigInteger;var StartDate: Date;var MaxDate: Date)
    var
        DetailAccessEntry: Record "TM Det. Ticket Access Entry";
        TicketStatistics: Record "TM Ticket Access Statistics";
        StartHour: Integer;
        StartTime: Time;
        ZeroHourPrefix: Text[30];
        MaxTime: Time;
        MaxDatetime: DateTime;
        MaxHour: Integer;
    begin

        // Find max date / time for compression
        MaxTime := 235959.999T; //TIME;
        MaxDate := Today;
        MaxDate := CalcDate ('<-1D>', Today);

        // Find from which time to start
        StartDate := DMY2Date (1,1,1900); //010100D;
        StartTime := 0T;
        if (TicketStatistics.Find ('+')) then begin
          StartDate := TicketStatistics."Admission Date";
          StartHour := TicketStatistics."Admission Hour";
          if (StartHour = 23) then begin
            StartDate := CalcDate ('<+1D>', StartDate);
            StartHour := 0;
          end else begin
            StartHour += 1;
          end;
          if (StartHour < 10) then ZeroHourPrefix := '0';
          Evaluate (StartTime, StrSubstNo ('%1%2%3', ZeroHourPrefix, Format (StartHour), ':00:00'), 9);
        end;

        // find first entry to compress
        DetailAccessEntry.SetCurrentKey (Type,"Created Datetime");
        DetailAccessEntry.SetFilter (Type, '=%1', DetailAccessEntry.Type::ADMITTED);
        DetailAccessEntry.SetFilter ("Created Datetime", '>%1', CreateDateTime (StartDate, StartTime));
        if (not DetailAccessEntry.FindFirst ()) then exit;
        FirstEntryNo := DetailAccessEntry."Entry No.";

        // find last entry no
        DetailAccessEntry.FindLast ();
        if (CurrentDateTime - DetailAccessEntry."Created Datetime" < 3600*1000) then begin
          MaxDate := DT2Date (DetailAccessEntry."Created Datetime");
          MaxTime := DT2Time (DetailAccessEntry."Created Datetime");
          Evaluate (MaxHour, Format (MaxTime, 0, '<Hours24>'));
          ZeroHourPrefix := '';
          if (MaxHour < 10) then ZeroHourPrefix := '0';
          Evaluate (MaxTime, StrSubstNo ('%1%2:00:00', ZeroHourPrefix, Format (MaxHour), 9));
          DetailAccessEntry.SetFilter ("Created Datetime", '<%1', CreateDateTime (MaxDate, MaxTime));
          DetailAccessEntry.FindLast ();
        end;
        LastEntryNo := DetailAccessEntry."Entry No.";
    end;

    local procedure SelectEntries(var FirstEntryNo: BigInteger;var LastEntryNo: BigInteger;var StartDate: Date;var MaxDate: Date): Integer
    var
        TicketAccessStatistics: Record "TM Ticket Access Statistics";
        DetTicketAccessEntry: Record "TM Det. Ticket Access Entry";
    begin

        //-TM1.39 [336823]
        FirstEntryNo := 0;
        LastEntryNo := 0;
        //+TM1.39 [336823]

        TicketAccessStatistics.SetCurrentKey ("Highest Access Entry No.");

        if (TicketAccessStatistics.FindLast ()) then
          if (TicketAccessStatistics."Highest Access Entry No." = 0) then
            exit (-1);

        DetTicketAccessEntry.SetFilter ("Entry No.", '>%1', TicketAccessStatistics."Highest Access Entry No.");
        if (DetTicketAccessEntry.FindFirst ()) then begin
          FirstEntryNo := DetTicketAccessEntry."Entry No.";
          StartDate := DT2Date (DetTicketAccessEntry."Created Datetime");
        end;

        if (DetTicketAccessEntry.FindLast ()) then begin
          LastEntryNo := DetTicketAccessEntry."Entry No.";
          MaxDate := DT2Date (DetTicketAccessEntry."Created Datetime");
        end;

        exit (LastEntryNo);
    end;

    local procedure ReSelectEntries(var FirstEntryNo: BigInteger;var LastEntryNo: BigInteger): Integer
    var
        TicketAccessStatistics: Record "TM Ticket Access Statistics";
        DetTicketAccessEntry: Record "TM Det. Ticket Access Entry";
    begin

        //-TM1.39 [336823]
        FirstEntryNo := 0;
        LastEntryNo := 0;

        TicketAccessStatistics.SetCurrentKey ("Highest Access Entry No.");

        if (TicketAccessStatistics.FindLast ()) then
          if (TicketAccessStatistics."Highest Access Entry No." = 0) then
            exit (-1);

        DetTicketAccessEntry.SetFilter ("Entry No.", '>%1', TicketAccessStatistics."Highest Access Entry No.");
        if (DetTicketAccessEntry.FindFirst ()) then
          FirstEntryNo := DetTicketAccessEntry."Entry No.";

        if (DetTicketAccessEntry.FindLast ()) then
          LastEntryNo := DetTicketAccessEntry."Entry No.";

        exit (LastEntryNo);

        //+TM1.39 [336823]
    end;

    local procedure LockResource()
    var
        TicketAccessFact: Record "TM Ticket Access Fact";
    begin

        if (TicketAccessFact.IsEmpty ()) then
          exit;

        TicketAccessFact.LockTable ();
        TicketAccessFact.FindFirst ();
    end;
}

