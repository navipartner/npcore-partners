codeunit 6151208 "NpCs Store Opening Hours Mgt."
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store


    trigger OnRun()
    begin
    end;

    var
        TempNpCsStoreOpeningHourEntry: Record "NpCs Store Opening Hours Entry" temporary;
        Initialized: Boolean;
        StartDate: Date;
        EndDate: Date;

    local procedure "--- Calc"()
    begin
    end;

    procedure CalcNextClosingDTDaysQty(StartDT: DateTime;DaysQty: Integer) ClosingDT: DateTime
    var
        EndDT: DateTime;
        PrevStartDT: DateTime;
        OpeningDuration: Duration;
    begin
        if StartDT = 0DT then
          exit(0DT);

        if DaysQty <= 0 then
          exit(StartDT);

        if not IsOpeningHours(StartDT) then begin
          EndDT := StartDT;
          StartDT := FindNextOpeningHours(StartDT);
          if StartDT = 0DT then
            exit(0DT);

          if DT2Date(StartDT) > DT2Date(EndDT) then
            DaysQty -= 1;
        end;

        while DaysQty > 0 do begin
          EndDT := FindNextClosingHours(StartDT);
          if EndDT = 0DT then
            exit(0DT);
          if EndDT <= StartDT then
            exit(ClosingDT);

          ClosingDT := EndDT;
          StartDT := FindNextOpeningHours(EndDT + 1);
          if StartDT = 0DT then
              exit(0DT);
          if DT2Date(StartDT) > DT2Date(EndDT) then
            DaysQty -= 1;
        end;

        repeat
          ClosingDT := FindNextClosingHours(StartDT);
          if ClosingDT = 0DT then
            exit(0DT);

          StartDT := FindNextOpeningHours(ClosingDT + 1);
          if StartDT = 0DT then
            exit(0DT);
        until DT2Date(ClosingDT) <> DT2Date(StartDT);

        exit(ClosingDT);
    end;

    procedure CalcNextOpeningDTDuration(StartDT: DateTime;Duration: Duration) OpeningDT: DateTime
    var
        EndDT: DateTime;
        OpeningDuration: Duration;
    begin
        if StartDT = 0DT then
          exit(0DT);

        if Duration <= 0 then
          exit(StartDT);

        if not IsOpeningHours(StartDT) then begin
          StartDT := FindNextOpeningHours(StartDT);
          if StartDT = 0DT then
            exit(0DT);
        end;

        while Duration > 0 do begin
          EndDT := FindNextClosingHours(StartDT);
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
          StartDT := FindNextOpeningHours(EndDT + 1);
          if StartDT = 0DT then
              exit(0DT);
        end;

        exit(OpeningDT);
    end;

    local procedure "--- Check/Find/Get"()
    begin
    end;

    local procedure IsOpeningHours(CheckDT: DateTime): Boolean
    var
        CheckDate: Date;
        CheckTime: Time;
    begin
        if CheckDT = 0DT then
            exit(false);

        CheckDate := DT2Date(CheckDT);
        CheckTime := DT2Time(CheckDT);
        Initialize(CheckDate,CheckDate);

        TempNpCsStoreOpeningHourEntry.SetRange("Calendar Date",CheckDate);
        if TempNpCsStoreOpeningHourEntry.IsEmpty then
          exit(false);

        TempNpCsStoreOpeningHourEntry.SetFilter("Start Time",'<=%1',CheckTime);
        TempNpCsStoreOpeningHourEntry.SetFilter("End Time",'>=%1|=%2',CheckTime,0T);
        exit(TempNpCsStoreOpeningHourEntry.FindFirst);
    end;

    local procedure FindNextOpeningHours(CheckDT: DateTime) OpeningHours: DateTime
    var
        CheckDate: Date;
        CheckTime: Time;
    begin
        if CheckDT = 0DT then
          exit(0DT);

        CheckDate := DT2Date(CheckDT);
        CheckTime := DT2Time(CheckDT);
        Initialize(CheckDate,CalcDate('<1Y>',CheckDate));

        TempNpCsStoreOpeningHourEntry.SetRange("Calendar Date",CheckDate);
        TempNpCsStoreOpeningHourEntry.SetFilter("End Time",'>%1|=%2',CheckTime,0T);
        if TempNpCsStoreOpeningHourEntry.FindSet then begin
          repeat
            if TempNpCsStoreOpeningHourEntry."Start Time" <= CheckTime then
              exit(CheckDT);

            exit(CreateDateTime(TempNpCsStoreOpeningHourEntry."Calendar Date",TempNpCsStoreOpeningHourEntry."Start Time"));
          until TempNpCsStoreOpeningHourEntry.Next = 0;
        end;

        Clear(TempNpCsStoreOpeningHourEntry);
        TempNpCsStoreOpeningHourEntry.SetFilter("Calendar Date",'>%1',CheckDate);
        if TempNpCsStoreOpeningHourEntry.FindFirst then
          exit(CreateDateTime(TempNpCsStoreOpeningHourEntry."Calendar Date",TempNpCsStoreOpeningHourEntry."Start Time"));

        exit(0DT);
    end;

    local procedure FindNextClosingHours(CheckDT: DateTime) ClosingHours: DateTime
    var
        CheckDate: Date;
        CheckTime: Time;
    begin
        if CheckDT = 0DT then
          exit(0DT);

        CheckDate := DT2Date(CheckDT);
        CheckTime := DT2Time(CheckDT);
        Initialize(CheckDate,CalcDate('<1Y>',CheckDate));

        TempNpCsStoreOpeningHourEntry.SetRange("Calendar Date",CheckDate);
        TempNpCsStoreOpeningHourEntry.SetFilter("End Time",'>=%1|=%2',CheckTime,0T);
        if TempNpCsStoreOpeningHourEntry.FindSet then begin
          repeat
            if TempNpCsStoreOpeningHourEntry."End Time" = 0T then
              exit(CreateDateTime(CalcDate('<1D>',TempNpCsStoreOpeningHourEntry."Calendar Date"),TempNpCsStoreOpeningHourEntry."End Time"));

            exit(CreateDateTime(TempNpCsStoreOpeningHourEntry."Calendar Date",TempNpCsStoreOpeningHourEntry."End Time"));
          until TempNpCsStoreOpeningHourEntry.Next = 0;
        end;

        Clear(TempNpCsStoreOpeningHourEntry);
        TempNpCsStoreOpeningHourEntry.SetFilter("Calendar Date",'>%1',CheckDate);
        if not TempNpCsStoreOpeningHourEntry.FindFirst then
          exit(0DT);

        exit(CreateDateTime(TempNpCsStoreOpeningHourEntry."Calendar Date",TempNpCsStoreOpeningHourEntry."End Time"));
    end;

    local procedure "--- GUI"()
    begin
    end;

    procedure ShowOpeningHours()
    begin
        Initialize(0D,0D);
        PAGE.Run(0,TempNpCsStoreOpeningHourEntry);
    end;

    local procedure "--- Setup"()
    begin
    end;

    procedure SetupOpeningHourEntries(var TempNpCsStoreOpeningHourEntry: Record "NpCs Store Opening Hours Entry" temporary)
    var
        NpCsStoreOpeningHourSetup: Record "NpCs Store Opening Hours Setup";
    begin
        if StartDate = 0D then
          StartDate := Today;
        if EndDate = 0D then
          EndDate := CalcDate('<5Y>',Today);

        if not NpCsStoreOpeningHourSetup.FindSet then
          exit;

        repeat
          ApplyOpeningHourSetup(NpCsStoreOpeningHourSetup,TempNpCsStoreOpeningHourEntry);
          Clear(TempNpCsStoreOpeningHourEntry);
        until NpCsStoreOpeningHourSetup.Next = 0;
    end;

    local procedure ApplyOpeningHourSetup(NpCsStoreOpeningHourSetup: Record "NpCs Store Opening Hours Setup";var TempNpCsStoreOpeningHourEntry: Record "NpCs Store Opening Hours Entry" temporary)
    begin
        case NpCsStoreOpeningHourSetup."Period Type" of
          NpCsStoreOpeningHourSetup."Period Type"::"Every Day":
            begin
              ApplyOpeningHourSetupEveryDay(NpCsStoreOpeningHourSetup,TempNpCsStoreOpeningHourEntry);
            end;
          NpCsStoreOpeningHourSetup."Period Type"::Weekly:
            begin
              ApplyOpeningHourSetupWeekly(NpCsStoreOpeningHourSetup,TempNpCsStoreOpeningHourEntry);
            end;
          NpCsStoreOpeningHourSetup."Period Type"::Yearly:
            begin
              ApplyOpeningHourSetupYearly(NpCsStoreOpeningHourSetup,TempNpCsStoreOpeningHourEntry);
            end;
          NpCsStoreOpeningHourSetup."Period Type"::Date:
            begin
              ApplyOpeningHourSetupDate(NpCsStoreOpeningHourSetup,TempNpCsStoreOpeningHourEntry);
            end;
        end;
    end;

    local procedure ApplyOpeningHourSetupEveryDay(NpCsStoreOpeningHourSetup: Record "NpCs Store Opening Hours Setup";var TempNpCsStoreOpeningHourEntry: Record "NpCs Store Opening Hours Entry" temporary)
    var
        Date: Record Date;
    begin
        Date.SetRange("Period Type",Date."Period Type"::Date);
        Date.SetFilter("Period Start",'%1..%2',StartDate,EndDate);
        if Date.FindSet then
          repeat
            case NpCsStoreOpeningHourSetup."Entry Type" of
              NpCsStoreOpeningHourSetup."Entry Type"::"Store Closed":
                begin
                  TempNpCsStoreOpeningHourEntry.SetRange("Calendar Date",Date."Period Start");
                  if TempNpCsStoreOpeningHourEntry.FindFirst then
                    TempNpCsStoreOpeningHourEntry.DeleteAll;
                end;
              NpCsStoreOpeningHourSetup."Entry Type"::"Store Open":
                begin
                  if not TempNpCsStoreOpeningHourEntry.Get(Date."Period Start",NpCsStoreOpeningHourSetup."Start Time",NpCsStoreOpeningHourSetup."End Time") then begin
                    TempNpCsStoreOpeningHourEntry.Init;
                    TempNpCsStoreOpeningHourEntry."Calendar Date" := Date."Period Start";
                    TempNpCsStoreOpeningHourEntry."Start Time" := NpCsStoreOpeningHourSetup."Start Time";
                    TempNpCsStoreOpeningHourEntry."End Time" := NpCsStoreOpeningHourSetup."End Time";
                    TempNpCsStoreOpeningHourEntry.Insert;
                  end;
                end;
            end;
          until Date.Next = 0;
    end;

    local procedure ApplyOpeningHourSetupWeekly(NpCsStoreOpeningHourSetup: Record "NpCs Store Opening Hours Setup";var TempNpCsStoreOpeningHourEntry: Record "NpCs Store Opening Hours Entry" temporary)
    var
        Date: Record Date;
    begin
        Date.SetRange("Period Type",Date."Period Type"::Date);
        Date.SetFilter("Period Start",'%1..%2',StartDate,EndDate);
        Date.SetFilter("Period No.",GetPeriodNoFilter(NpCsStoreOpeningHourSetup));
        if Date.FindSet then
          repeat
            case NpCsStoreOpeningHourSetup."Entry Type" of
              NpCsStoreOpeningHourSetup."Entry Type"::"Store Closed":
                begin
                  TempNpCsStoreOpeningHourEntry.SetRange("Calendar Date",Date."Period Start");
                  if TempNpCsStoreOpeningHourEntry.FindFirst then
                    TempNpCsStoreOpeningHourEntry.DeleteAll;
                end;
              NpCsStoreOpeningHourSetup."Entry Type"::"Store Open":
                begin
                  if not TempNpCsStoreOpeningHourEntry.Get(Date."Period Start",NpCsStoreOpeningHourSetup."Start Time",NpCsStoreOpeningHourSetup."End Time") then begin
                    TempNpCsStoreOpeningHourEntry.Init;
                    TempNpCsStoreOpeningHourEntry."Calendar Date" := Date."Period Start";
                    TempNpCsStoreOpeningHourEntry."Start Time" := NpCsStoreOpeningHourSetup."Start Time";
                    TempNpCsStoreOpeningHourEntry."End Time" := NpCsStoreOpeningHourSetup."End Time";
                    TempNpCsStoreOpeningHourEntry.Insert;
                  end;
                end;
            end;
          until Date.Next = 0;
    end;

    local procedure ApplyOpeningHourSetupYearly(NpCsStoreOpeningHourSetup: Record "NpCs Store Opening Hours Setup";var TempNpCsStoreOpeningHourEntry: Record "NpCs Store Opening Hours Entry" temporary)
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
        StartYear: Integer;
        EndYear: Integer;
        CalendarDate: Date;
    begin
        if NpCsStoreOpeningHourSetup."Entry Date" = 0D then
          exit;

        Day := Date2DMY(NpCsStoreOpeningHourSetup."Entry Date",1);
        Month := Date2DMY(NpCsStoreOpeningHourSetup."Entry Date",2);
        Year := Date2DMY(NpCsStoreOpeningHourSetup."Entry Date",3);
        StartYear := Date2DMY(Today,3);
        EndYear := StartYear + 5;

        if Year > StartYear then
          StartYear := Year;

        for Year := StartYear to EndYear do begin
          CalendarDate := DMY2Date(Day,Month,Year);
          if CalendarDate > EndDate then
            exit;
          if CalendarDate >= StartDate then
            case NpCsStoreOpeningHourSetup."Entry Type" of
              NpCsStoreOpeningHourSetup."Entry Type"::"Store Closed":
                begin
                  TempNpCsStoreOpeningHourEntry.SetRange("Calendar Date",CalendarDate);
                  if TempNpCsStoreOpeningHourEntry.FindFirst then
                    TempNpCsStoreOpeningHourEntry.DeleteAll;
                end;
              NpCsStoreOpeningHourSetup."Entry Type"::"Store Open":
                begin
                  if not TempNpCsStoreOpeningHourEntry.Get(CalendarDate,NpCsStoreOpeningHourSetup."Start Time",NpCsStoreOpeningHourSetup."End Time") then begin
                    TempNpCsStoreOpeningHourEntry.Init;
                    TempNpCsStoreOpeningHourEntry."Calendar Date" := CalendarDate;
                    TempNpCsStoreOpeningHourEntry."Start Time" := NpCsStoreOpeningHourSetup."Start Time";
                    TempNpCsStoreOpeningHourEntry."End Time" := NpCsStoreOpeningHourSetup."End Time";
                    TempNpCsStoreOpeningHourEntry.Insert;
                  end;
                end;
            end;
        end;
    end;

    local procedure ApplyOpeningHourSetupDate(NpCsStoreOpeningHourSetup: Record "NpCs Store Opening Hours Setup";var TempNpCsStoreOpeningHourEntry: Record "NpCs Store Opening Hours Entry" temporary)
    begin
        if NpCsStoreOpeningHourSetup."Entry Date" = 0D then
          exit;
        if NpCsStoreOpeningHourSetup."Entry Date" > EndDate then
          exit;
        if NpCsStoreOpeningHourSetup."Entry Date" < StartDate then
          exit;

        case NpCsStoreOpeningHourSetup."Entry Type" of
          NpCsStoreOpeningHourSetup."Entry Type"::"Store Closed":
            begin
              TempNpCsStoreOpeningHourEntry.SetRange("Calendar Date",NpCsStoreOpeningHourSetup."Entry Date");
              if TempNpCsStoreOpeningHourEntry.FindFirst then
                TempNpCsStoreOpeningHourEntry.DeleteAll;
            end;
          NpCsStoreOpeningHourSetup."Entry Type"::"Store Open":
            begin
              if not TempNpCsStoreOpeningHourEntry.Get(NpCsStoreOpeningHourSetup."Entry Date",NpCsStoreOpeningHourSetup."Start Time",NpCsStoreOpeningHourSetup."End Time") then begin
                TempNpCsStoreOpeningHourEntry.Init;
                TempNpCsStoreOpeningHourEntry."Calendar Date" := NpCsStoreOpeningHourSetup."Entry Date";
                TempNpCsStoreOpeningHourEntry."Start Time" := NpCsStoreOpeningHourSetup."Start Time";
                TempNpCsStoreOpeningHourEntry."End Time" := NpCsStoreOpeningHourSetup."End Time";
                TempNpCsStoreOpeningHourEntry.Insert;
              end;
            end;
        end;
    end;

    local procedure GetPeriodNoFilter(NpCsStoreOpeningHourSetup: Record "NpCs Store Opening Hours Setup") PeriodNoFilter: Text
    begin
        if NpCsStoreOpeningHourSetup.Monday then
          PeriodNoFilter += '1|';

        if NpCsStoreOpeningHourSetup.Tuesday then
          PeriodNoFilter += '2|';

        if NpCsStoreOpeningHourSetup.Wednesday then
          PeriodNoFilter += '3|';

        if NpCsStoreOpeningHourSetup.Thursday then
          PeriodNoFilter += '4|';

        if NpCsStoreOpeningHourSetup.Friday then
          PeriodNoFilter += '5|';

        if NpCsStoreOpeningHourSetup.Saturday then
          PeriodNoFilter += '6|';

        if NpCsStoreOpeningHourSetup.Sunday then
          PeriodNoFilter += '7|';

        if PeriodNoFilter <> '' then
          PeriodNoFilter := DelStr(PeriodNoFilter,StrLen(PeriodNoFilter));

        if PeriodNoFilter = '' then
          PeriodNoFilter := '=0&<>0';

        exit(PeriodNoFilter);
    end;

    local procedure Initialize(NewStartDate: Date;NewEndDate: Date)
    begin
        if Initialized and (NewStartDate = StartDate) and (NewEndDate = EndDate) then
          exit;

        Clear(TempNpCsStoreOpeningHourEntry);
        TempNpCsStoreOpeningHourEntry.DeleteAll;
        Initialized := true;
        StartDate := NewStartDate;
        EndDate := NewEndDate;
        SetupOpeningHourEntries(TempNpCsStoreOpeningHourEntry);
    end;
}

