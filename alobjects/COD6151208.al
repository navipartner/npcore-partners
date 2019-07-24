codeunit 6151208 "NpCs Store Opening Hours Mgt."
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // #362443/MHA /20190719  CASE 362443 Introduced Opening Hour Set


    trigger OnRun()
    begin
    end;

    var
        TempNpCsOpenHourCalendarEntry: Record "NpCs Open. Hour Calendar Entry" temporary;
        Initialized: Boolean;
        StartDate: Date;
        EndDate: Date;

    local procedure "--- Calc"()
    begin
    end;

    procedure CalcNextClosingDTDaysQty(SetCode: Code[20];StartDT: DateTime;DaysQty: Integer) ClosingDT: DateTime
    var
        EndDT: DateTime;
        PrevStartDT: DateTime;
        OpeningDuration: Duration;
    begin
        if StartDT = 0DT then
          exit(0DT);

        if DaysQty <= 0 then
          exit(StartDT);

        if not IsOpeningHours(SetCode,StartDT) then begin
          EndDT := StartDT;
          StartDT := FindNextOpeningHours(SetCode,StartDT);
          if StartDT = 0DT then
            exit(0DT);

          if DT2Date(StartDT) > DT2Date(EndDT) then
            DaysQty -= 1;
        end;

        while DaysQty > 0 do begin
          EndDT := FindNextClosingHours(SetCode,StartDT);
          if EndDT = 0DT then
            exit(0DT);
          if EndDT <= StartDT then
            exit(ClosingDT);

          ClosingDT := EndDT;
          StartDT := FindNextOpeningHours(SetCode,EndDT + 1);
          if StartDT = 0DT then
              exit(0DT);
          if DT2Date(StartDT) > DT2Date(EndDT) then
            DaysQty -= 1;
        end;

        repeat
          ClosingDT := FindNextClosingHours(SetCode,StartDT);
          if ClosingDT = 0DT then
            exit(0DT);

          StartDT := FindNextOpeningHours(SetCode,ClosingDT + 1);
          if StartDT = 0DT then
            exit(0DT);
        until DT2Date(ClosingDT) <> DT2Date(StartDT);

        exit(ClosingDT);
    end;

    procedure CalcNextOpeningDTDuration(SetCode: Code[20];StartDT: DateTime;Duration: Duration) OpeningDT: DateTime
    var
        EndDT: DateTime;
        OpeningDuration: Duration;
    begin
        if StartDT = 0DT then
          exit(0DT);

        if Duration <= 0 then
          exit(StartDT);

        if not IsOpeningHours(SetCode,StartDT) then begin
          StartDT := FindNextOpeningHours(SetCode,StartDT);
          if StartDT = 0DT then
            exit(0DT);
        end;

        while Duration > 0 do begin
          EndDT := FindNextClosingHours(SetCode,StartDT);
          if EndDT = 0DT then
            exit(0DT);
          if EndDT <= StartDT then
            exit(OpeningDT);

          OpeningDuration := EndDT - StartDT;
          if OpeningDuration >= Duration then begin
            OpeningDT := StartDT + Duration;
            exit(OpeningDT);
          end;

          OpeningDT := StartDT + OpeningDuration;
          Duration -= OpeningDuration;
          StartDT := FindNextOpeningHours(SetCode,EndDT + 1);
          if StartDT = 0DT then
              exit(0DT);
        end;

        exit(OpeningDT);
    end;

    local procedure "--- Check/Find/Get"()
    begin
    end;

    local procedure IsOpeningHours(SetCode: Code[20];CheckDT: DateTime): Boolean
    var
        CheckDate: Date;
        CheckTime: Time;
    begin
        if CheckDT = 0DT then
            exit(false);

        CheckDate := DT2Date(CheckDT);
        CheckTime := DT2Time(CheckDT);
        Initialize(SetCode,CheckDate,CheckDate);

        TempNpCsOpenHourCalendarEntry.SetRange("Calendar Date",CheckDate);
        if TempNpCsOpenHourCalendarEntry.IsEmpty then
          exit(false);

        TempNpCsOpenHourCalendarEntry.SetFilter("Start Time",'<=%1',CheckTime);
        TempNpCsOpenHourCalendarEntry.SetFilter("End Time",'>=%1|=%2',CheckTime,0T);
        exit(TempNpCsOpenHourCalendarEntry.FindFirst);
    end;

    local procedure FindNextOpeningHours(SetCode: Code[20];CheckDT: DateTime) OpeningHours: DateTime
    var
        CheckDate: Date;
        CheckTime: Time;
    begin
        if CheckDT = 0DT then
          exit(0DT);

        CheckDate := DT2Date(CheckDT);
        CheckTime := DT2Time(CheckDT);
        Initialize(SetCode,CheckDate,CalcDate('<1Y>',CheckDate));

        TempNpCsOpenHourCalendarEntry.SetRange("Calendar Date",CheckDate);
        TempNpCsOpenHourCalendarEntry.SetFilter("End Time",'>%1|=%2',CheckTime,0T);
        if TempNpCsOpenHourCalendarEntry.FindSet then begin
          repeat
            if TempNpCsOpenHourCalendarEntry."Start Time" <= CheckTime then
              exit(CheckDT);

            exit(CreateDateTime(TempNpCsOpenHourCalendarEntry."Calendar Date",TempNpCsOpenHourCalendarEntry."Start Time"));
          until TempNpCsOpenHourCalendarEntry.Next = 0;
        end;

        Clear(TempNpCsOpenHourCalendarEntry);
        TempNpCsOpenHourCalendarEntry.SetFilter("Calendar Date",'>%1',CheckDate);
        if TempNpCsOpenHourCalendarEntry.FindFirst then
          exit(CreateDateTime(TempNpCsOpenHourCalendarEntry."Calendar Date",TempNpCsOpenHourCalendarEntry."Start Time"));

        exit(0DT);
    end;

    local procedure FindNextClosingHours(SetCode: Code[20];CheckDT: DateTime) ClosingHours: DateTime
    var
        CheckDate: Date;
        CheckTime: Time;
    begin
        if CheckDT = 0DT then
          exit(0DT);

        CheckDate := DT2Date(CheckDT);
        CheckTime := DT2Time(CheckDT);
        Initialize(SetCode,CheckDate,CalcDate('<1Y>',CheckDate));

        TempNpCsOpenHourCalendarEntry.SetRange("Calendar Date",CheckDate);
        TempNpCsOpenHourCalendarEntry.SetFilter("End Time",'>=%1|=%2',CheckTime,0T);
        if TempNpCsOpenHourCalendarEntry.FindSet then begin
          repeat
            if TempNpCsOpenHourCalendarEntry."End Time" = 0T then
              exit(CreateDateTime(CalcDate('<1D>',TempNpCsOpenHourCalendarEntry."Calendar Date"),TempNpCsOpenHourCalendarEntry."End Time"));

            exit(CreateDateTime(TempNpCsOpenHourCalendarEntry."Calendar Date",TempNpCsOpenHourCalendarEntry."End Time"));
          until TempNpCsOpenHourCalendarEntry.Next = 0;
        end;

        Clear(TempNpCsOpenHourCalendarEntry);
        TempNpCsOpenHourCalendarEntry.SetFilter("Calendar Date",'>%1',CheckDate);
        if not TempNpCsOpenHourCalendarEntry.FindFirst then
          exit(0DT);

        exit(CreateDateTime(TempNpCsOpenHourCalendarEntry."Calendar Date",TempNpCsOpenHourCalendarEntry."End Time"));
    end;

    local procedure "--- GUI"()
    begin
    end;

    procedure ShowOpeningHours(SetCode: Code[20])
    begin
        Initialize(SetCode,0D,0D);
        PAGE.Run(0,TempNpCsOpenHourCalendarEntry);
    end;

    local procedure "--- Setup"()
    begin
    end;

    local procedure SetupOpeningHourEntries(SetCode: Code[20])
    var
        NpCsOpenHourSet: Record "NpCs Open. Hour Set";
        NpCsOpenHourEntry: Record "NpCs Open. Hour Entry";
    begin
        if SetCode = '' then begin
          if not NpCsOpenHourSet.FindFirst then
            exit;
          SetCode := NpCsOpenHourSet.Code;
        end;

        if StartDate = 0D then
          StartDate := Today;
        if EndDate = 0D then
          EndDate := CalcDate('<5Y>',Today);

        NpCsOpenHourEntry.SetRange("Set Code",SetCode);
        if not NpCsOpenHourEntry.FindSet then
          exit;

        repeat
          ApplyOpeningHourEntry(NpCsOpenHourEntry);
          Clear(TempNpCsOpenHourCalendarEntry);
        until NpCsOpenHourEntry.Next = 0;
    end;

    local procedure ApplyOpeningHourEntry(NpCsOpenHourEntry: Record "NpCs Open. Hour Entry")
    begin
        case NpCsOpenHourEntry."Period Type" of
          NpCsOpenHourEntry."Period Type"::"Every Day":
            begin
              ApplyOpeningHourEntryEveryDay(NpCsOpenHourEntry);
            end;
          NpCsOpenHourEntry."Period Type"::Weekly:
            begin
              ApplyOpeningHourEntryWeekly(NpCsOpenHourEntry);
            end;
          NpCsOpenHourEntry."Period Type"::Yearly:
            begin
              ApplyOpeningHourEntryYearly(NpCsOpenHourEntry);
            end;
          NpCsOpenHourEntry."Period Type"::Date:
            begin
              ApplyOpeningHourEntryDate(NpCsOpenHourEntry);
            end;
        end;
    end;

    local procedure ApplyOpeningHourEntryEveryDay(NpCsOpenHourEntry: Record "NpCs Open. Hour Entry")
    var
        Date: Record Date;
    begin
        Date.SetRange("Period Type",Date."Period Type"::Date);
        Date.SetFilter("Period Start",'%1..%2',StartDate,EndDate);
        if Date.FindSet then
          repeat
            case NpCsOpenHourEntry."Entry Type" of
              NpCsOpenHourEntry."Entry Type"::"Store Closed":
                begin
                  TempNpCsOpenHourCalendarEntry.SetRange("Calendar Date",Date."Period Start");
                  if TempNpCsOpenHourCalendarEntry.FindFirst then
                    TempNpCsOpenHourCalendarEntry.DeleteAll;
                end;
              NpCsOpenHourEntry."Entry Type"::"Store Open":
                begin
                  if not TempNpCsOpenHourCalendarEntry.Get(Date."Period Start",NpCsOpenHourEntry."Start Time",NpCsOpenHourEntry."End Time") then begin
                    TempNpCsOpenHourCalendarEntry.Init;
                    TempNpCsOpenHourCalendarEntry."Calendar Date" := Date."Period Start";
                    TempNpCsOpenHourCalendarEntry."Start Time" := NpCsOpenHourEntry."Start Time";
                    TempNpCsOpenHourCalendarEntry."End Time" := NpCsOpenHourEntry."End Time";
                    TempNpCsOpenHourCalendarEntry.Insert;
                  end;
                end;
            end;
          until Date.Next = 0;
    end;

    local procedure ApplyOpeningHourEntryWeekly(NpCsOpenHourEntry: Record "NpCs Open. Hour Entry")
    var
        Date: Record Date;
    begin
        Date.SetRange("Period Type",Date."Period Type"::Date);
        Date.SetFilter("Period Start",'%1..%2',StartDate,EndDate);
        Date.SetFilter("Period No.",GetPeriodNoFilter(NpCsOpenHourEntry));
        if Date.FindSet then
          repeat
            case NpCsOpenHourEntry."Entry Type" of
              NpCsOpenHourEntry."Entry Type"::"Store Closed":
                begin
                  TempNpCsOpenHourCalendarEntry.SetRange("Calendar Date",Date."Period Start");
                  if TempNpCsOpenHourCalendarEntry.FindFirst then
                    TempNpCsOpenHourCalendarEntry.DeleteAll;
                end;
              NpCsOpenHourEntry."Entry Type"::"Store Open":
                begin
                  if not TempNpCsOpenHourCalendarEntry.Get(Date."Period Start",NpCsOpenHourEntry."Start Time",NpCsOpenHourEntry."End Time") then begin
                    TempNpCsOpenHourCalendarEntry.Init;
                    TempNpCsOpenHourCalendarEntry."Calendar Date" := Date."Period Start";
                    TempNpCsOpenHourCalendarEntry."Start Time" := NpCsOpenHourEntry."Start Time";
                    TempNpCsOpenHourCalendarEntry."End Time" := NpCsOpenHourEntry."End Time";
                    TempNpCsOpenHourCalendarEntry.Insert;
                  end;
                end;
            end;
          until Date.Next = 0;
    end;

    local procedure ApplyOpeningHourEntryYearly(NpCsOpenHourEntry: Record "NpCs Open. Hour Entry")
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        StartYear: Integer;
        EndYear: Integer;
        CalendarDate: Date;
    begin
        if NpCsOpenHourEntry."Entry Date" = 0D then
          exit;

        Day := Date2DMY(NpCsOpenHourEntry."Entry Date",1);
        Month := Date2DMY(NpCsOpenHourEntry."Entry Date",2);
        Year := Date2DMY(NpCsOpenHourEntry."Entry Date",3);
        StartYear := Date2DMY(Today,3);
        EndYear := StartYear + 5;

        if Year > StartYear then
          StartYear := Year;

        for Year := StartYear to EndYear do begin
          CalendarDate := DMY2Date(Day,Month,Year);
          if CalendarDate > EndDate then
            exit;
          if CalendarDate >= StartDate then
            case NpCsOpenHourEntry."Entry Type" of
              NpCsOpenHourEntry."Entry Type"::"Store Closed":
                begin
                  TempNpCsOpenHourCalendarEntry.SetRange("Calendar Date",CalendarDate);
                  if TempNpCsOpenHourCalendarEntry.FindFirst then
                    TempNpCsOpenHourCalendarEntry.DeleteAll;
                end;
              NpCsOpenHourEntry."Entry Type"::"Store Open":
                begin
                  if not TempNpCsOpenHourCalendarEntry.Get(CalendarDate,NpCsOpenHourEntry."Start Time",NpCsOpenHourEntry."End Time") then begin
                    TempNpCsOpenHourCalendarEntry.Init;
                    TempNpCsOpenHourCalendarEntry."Calendar Date" := CalendarDate;
                    TempNpCsOpenHourCalendarEntry."Start Time" := NpCsOpenHourEntry."Start Time";
                    TempNpCsOpenHourCalendarEntry."End Time" := NpCsOpenHourEntry."End Time";
                    TempNpCsOpenHourCalendarEntry.Insert;
                  end;
                end;
            end;
        end;
    end;

    local procedure ApplyOpeningHourEntryDate(NpCsOpenHourEntry: Record "NpCs Open. Hour Entry")
    begin
        if NpCsOpenHourEntry."Entry Date" = 0D then
          exit;
        if NpCsOpenHourEntry."Entry Date" > EndDate then
          exit;
        if NpCsOpenHourEntry."Entry Date" < StartDate then
          exit;

        case NpCsOpenHourEntry."Entry Type" of
          NpCsOpenHourEntry."Entry Type"::"Store Closed":
            begin
              TempNpCsOpenHourCalendarEntry.SetRange("Calendar Date",NpCsOpenHourEntry."Entry Date");
              if TempNpCsOpenHourCalendarEntry.FindFirst then
                TempNpCsOpenHourCalendarEntry.DeleteAll;
            end;
          NpCsOpenHourEntry."Entry Type"::"Store Open":
            begin
              if not TempNpCsOpenHourCalendarEntry.Get(NpCsOpenHourEntry."Entry Date",NpCsOpenHourEntry."Start Time",NpCsOpenHourEntry."End Time") then begin
                TempNpCsOpenHourCalendarEntry.Init;
                TempNpCsOpenHourCalendarEntry."Calendar Date" := NpCsOpenHourEntry."Entry Date";
                TempNpCsOpenHourCalendarEntry."Start Time" := NpCsOpenHourEntry."Start Time";
                TempNpCsOpenHourCalendarEntry."End Time" := NpCsOpenHourEntry."End Time";
                TempNpCsOpenHourCalendarEntry.Insert;
              end;
            end;
        end;
    end;

    local procedure GetPeriodNoFilter(NpCsOpenHourEntry: Record "NpCs Open. Hour Entry") PeriodNoFilter: Text
    begin
        if NpCsOpenHourEntry.Monday then
          PeriodNoFilter += '1|';

        if NpCsOpenHourEntry.Tuesday then
          PeriodNoFilter += '2|';

        if NpCsOpenHourEntry.Wednesday then
          PeriodNoFilter += '3|';

        if NpCsOpenHourEntry.Thursday then
          PeriodNoFilter += '4|';

        if NpCsOpenHourEntry.Friday then
          PeriodNoFilter += '5|';

        if NpCsOpenHourEntry.Saturday then
          PeriodNoFilter += '6|';

        if NpCsOpenHourEntry.Sunday then
          PeriodNoFilter += '7|';

        if PeriodNoFilter <> '' then
          PeriodNoFilter := DelStr(PeriodNoFilter,StrLen(PeriodNoFilter));

        if PeriodNoFilter = '' then
          PeriodNoFilter := '=0&<>0';

        exit(PeriodNoFilter);
    end;

    local procedure Initialize(SetCode: Code[20];NewStartDate: Date;NewEndDate: Date)
    begin
        if Initialized and (NewStartDate = StartDate) and (NewEndDate = EndDate) then
          exit;

        Clear(TempNpCsOpenHourCalendarEntry);
        TempNpCsOpenHourCalendarEntry.DeleteAll;
        Initialized := true;
        StartDate := NewStartDate;
        EndDate := NewEndDate;
        SetupOpeningHourEntries(SetCode);
    end;
}

