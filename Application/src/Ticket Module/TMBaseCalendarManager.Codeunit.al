codeunit 6059911 "NPR TMBaseCalendarManager"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calendar Management", 'OnFillSourceRec', '', true, true)]
    local procedure FillSource(RecRef: RecordRef; var CustomCalendarChange: Record "Customized Calendar Change")
    begin
        case (RecRef.RecordId.TableNo) of
            Database::"Customized Calendar Change":
                SetCustomizedCalendar(RecRef, CustomCalendarChange);
            Database::"NPR TM Admission":
                SetAdmissionCalendar(RecRef, CustomCalendarChange);
            Database::"NPR TM Admis. Schedule":
                SetScheduleCalendar(RecRef, CustomCalendarChange);
            Database::"NPR TM Admis. Schedule Lines":
                SetAdmissionScheduleCalendar(RecRef, CustomCalendarChange);
            Database::"NPR TM Ticket Admission BOM":
                SetTicketBomCalendar(RecRef, CustomCalendarChange);
        end;
    end;

    local procedure SetCustomizedCalendar(RecRef: RecordRef; var CustomCalendarChange: Record "Customized Calendar Change")
    var
        TempCustomizedCalendar: Record "Customized Calendar Change" temporary;
    begin
        RecRef.SetTable(TempCustomizedCalendar);
        CustomCalendarChange.SetSource(
            TempCustomizedCalendar."Source Type", TempCustomizedCalendar."Source Code", TempCustomizedCalendar."Additional Source Code", TempCustomizedCalendar."Base Calendar Code");
    end;

    local procedure SetAdmissionCalendar(RecRef: RecordRef; var CustomCalendarChange: Record "Customized Calendar Change")
    var
        Admission: Record "NPR TM Admission";
    begin
        RecRef.SetTable(Admission);
        SetAdmissionCalendar(Admission, CustomCalendarChange);
    end;

    procedure SetAdmissionCalendar(Admission: Record "NPR TM Admission"; var CustomCalendarChange: Record "Customized Calendar Change")
    begin
        CustomCalendarChange.SetSource(
            CustomCalendarChange."Source Type"::NPR_TM_Admission, Admission."Admission Code", '', Admission."Admission Base Calendar Code");
    end;

    procedure CheckAdmissionIsNonWorking(Admission: Record "NPR TM Admission"; ReferenceDate: Date) IsNonWorking: Boolean
    var
        TempCustomCalendarChange: Record "Customized Calendar Change" temporary;
        CalendarManagement: Codeunit "Calendar Management";
    begin
        SetAdmissionCalendar(Admission, TempCustomCalendarChange);
        TempCustomCalendarChange.Date := ReferenceDate;
        CalendarManagement.CheckDateStatus(TempCustomCalendarChange);
        exit(TempCustomCalendarChange.Nonworking);
    end;


    local procedure SetScheduleCalendar(RecRef: RecordRef; var CustomCalendarChange: Record "Customized Calendar Change")
    var
        Schedule: Record "NPR TM Admis. Schedule";
    begin
        RecRef.SetTable(Schedule);
        SetScheduleCalendar(Schedule, CustomCalendarChange);
    end;

    procedure SetScheduleCalendar(Schedule: Record "NPR TM Admis. Schedule"; var CustomCalendarChange: Record "Customized Calendar Change")
    begin
        CustomCalendarChange.SetSource(
            CustomCalendarChange."Source Type"::NPR_TM_Schedule, Schedule."Schedule Code", '', Schedule."Admission Base Calendar Code");
    end;

    procedure CheckScheduleIsNonWorking(Schedule: Record "NPR TM Admis. Schedule"; ReferenceDate: Date) IsNonWorking: Boolean
    var
        TempCustomCalendarChange: Record "Customized Calendar Change" temporary;
        CalendarManagement: Codeunit "Calendar Management";
    begin
        SetScheduleCalendar(Schedule, TempCustomCalendarChange);
        TempCustomCalendarChange.Date := ReferenceDate;
        CalendarManagement.CheckDateStatus(TempCustomCalendarChange);
        exit(TempCustomCalendarChange.Nonworking);
    end;


    local procedure SetAdmissionScheduleCalendar(RecRef: RecordRef; var CustomCalendarChange: Record "Customized Calendar Change")
    var
        AdmissionSchedule: Record "NPR TM Admis. Schedule Lines";
    begin
        RecRef.SetTable(AdmissionSchedule);
        SetAdmissionScheduleCalendar(AdmissionSchedule, CustomCalendarChange);
    end;

    procedure SetAdmissionScheduleCalendar(AdmissionSchedule: Record "NPR TM Admis. Schedule Lines"; var CustomCalendarChange: Record "Customized Calendar Change")
    begin
        CustomCalendarChange.SetSource(
            CustomCalendarChange."Source Type"::NPR_TM_Admission_Schedule, AdmissionSchedule."Admission Code", AdmissionSchedule."Schedule Code", AdmissionSchedule."Admission Base Calendar Code");
    end;

    procedure CheckAdmissionScheduleIsNonWorking(AdmissionSchedule: Record "NPR TM Admis. Schedule Lines"; ReferenceDate: Date) IsNonWorking: Boolean
    var
        TempCustomCalendarChange: Record "Customized Calendar Change" temporary;
        CalendarManagement: Codeunit "Calendar Management";
    begin
        SetAdmissionScheduleCalendar(AdmissionSchedule, TempCustomCalendarChange);
        TempCustomCalendarChange.Date := ReferenceDate;
        CalendarManagement.CheckDateStatus(TempCustomCalendarChange);
        exit(TempCustomCalendarChange.Nonworking);
    end;

    // Ticket Base Calendar
    local procedure SetTicketBomCalendar(RecRef: RecordRef; var CustomCalendarChange: Record "Customized Calendar Change")
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        RecRef.SetTable(TicketBom);
        SetTicketBomCalendar(TicketBom, CustomCalendarChange);
    end;

    local procedure SetTicketBomCalendar(TicketBom: Record "NPR TM Ticket Admission BOM"; var CustomCalendarChange: Record "Customized Calendar Change")
    begin
        CustomCalendarChange.SetSource(
            CustomCalendarChange."Source Type"::NPR_TM_BOM_Admission_Item, TicketBom."Admission Code", TicketBom."Item No.", TicketBom."Ticket Base Calendar Code");
    end;

    procedure CheckTicketBomIsNonWorking(TicketBom: Record "NPR TM Ticket Admission BOM"; ReferenceDate: Date; var CustomCalendarChange: Record "Customized Calendar Change") IsNonWorking: Boolean
    var
        CalendarManagement: Codeunit "Calendar Management";
    begin
        SetTicketBomCalendar(TicketBom, CustomCalendarChange);
        CustomCalendarChange.Date := ReferenceDate;
        CalendarManagement.CheckDateStatus(CustomCalendarChange);
        exit(CustomCalendarChange.Nonworking);
    end;



    // Ticket Base Calendar 
    local procedure SetTicketBomAdmissionCalendar(TicketBom: Record "NPR TM Ticket Admission BOM"; var CustomCalendarChange: Record "Customized Calendar Change")
    begin
        CustomCalendarChange.SetSource(
            CustomCalendarChange."Source Type"::NPR_TM_BOM_Admission, TicketBom."Admission Code", '', TicketBom."Ticket Base Calendar Code");
    end;

    procedure TicketBomAdmissionChangesExist(TicketBom: Record "NPR TM Ticket Admission BOM"): Boolean
    var
        CustomizedCalendarChange: Record "Customized Calendar Change";
    begin
        SetTicketBomAdmissionCalendar(TicketBom, CustomizedCalendarChange);
        CustomizedCalendarChange.Reset();
        CustomizedCalendarChange.SetFilter("Source Type", '=%1', CustomizedCalendarChange."Source Type");
        CustomizedCalendarChange.SetFilter("Source Code", '=%1', CustomizedCalendarChange."Source Code");
        CustomizedCalendarChange.SetFilter("Base Calendar Code", '=%1', CustomizedCalendarChange."Base Calendar Code");
        exit(not CustomizedCalendarChange.IsEmpty());
    end;

    procedure CheckTicketBomAdmissionIsNonWorking(TicketBom: Record "NPR TM Ticket Admission BOM"; ReferenceDate: Date; var CustomCalendarChange: Record "Customized Calendar Change") IsNonWorking: Boolean
    var
        CalendarManagement: Codeunit "Calendar Management";
    begin
        SetTicketBomAdmissionCalendar(TicketBom, CustomCalendarChange);
        CustomCalendarChange.Date := ReferenceDate;
        CalendarManagement.CheckDateStatus(CustomCalendarChange);
        exit(CustomCalendarChange.Nonworking);
    end;


    procedure CollectTicketCalendarExceptions(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; FromDate: Date; ToDate: Date; var TempExceptions: Record "Customized Calendar Change" temporary)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        TempCalendarSource: Record "Customized Calendar Change" temporary;
        ResolvedSources: List of [Text];
    begin
        TempExceptions.Reset();
        TempExceptions.DeleteAll();

        if (FromDate = 0D) or (ToDate = 0D) or (FromDate > ToDate) then
            exit;

        if (not Admission.Get(AdmissionCode)) then
            exit;

        if (TicketBom.Get(ItemNo, VariantCode, AdmissionCode)) then begin
            SetTicketBomCalendar(TicketBom, TempCalendarSource);
            CollectCalendarSourceExceptions(TempCalendarSource, FromDate, ToDate, ResolvedSources, TempExceptions);

            SetTicketBomAdmissionCalendar(TicketBom, TempCalendarSource);
            CollectCalendarSourceExceptions(TempCalendarSource, FromDate, ToDate, ResolvedSources, TempExceptions);
        end;

        SetTicketBomAdmissionCalendar(Admission, TempCalendarSource);
        CollectCalendarSourceExceptions(TempCalendarSource, FromDate, ToDate, ResolvedSources, TempExceptions);
    end;

    local procedure CollectCalendarSourceExceptions(var TempCalendarSource: Record "Customized Calendar Change" temporary; FromDate: Date; ToDate: Date; var ResolvedSources: List of [Text]; var TempExceptions: Record "Customized Calendar Change" temporary)
    var
        CalendarManagement: Codeunit "Calendar Management";
        SourceKey: Text;
        IterationDate: Date;
        NextEntryNo: Integer;
        SourceKeyLbl: Label '%1|%2|%3|%4', Locked = true;
    begin
        // A source without a calendar has nothing to report. This has to be checked here rather than
        // relying on Calendar Management: its own blank-source exit requires source type Company, which
        // none of the ticket source types are, so it would read the change tables before finding out.
        if (TempCalendarSource."Base Calendar Code" = '') then
            exit;

        // The BOM and the admission may point at the same calendar, in which case the levels collapse.
        SourceKey := StrSubstNo(SourceKeyLbl, TempCalendarSource."Source Type".AsInteger(), TempCalendarSource."Source Code", TempCalendarSource."Additional Source Code", TempCalendarSource."Base Calendar Code");
        if (ResolvedSources.Contains(SourceKey)) then
            exit;
        ResolvedSources.Add(SourceKey);

        TempExceptions.Reset();
        TempExceptions.SetCurrentKey("Entry No.");
        if (TempExceptions.FindLast()) then
            NextEntryNo := TempExceptions."Entry No.";

        IterationDate := FromDate;
        while (IterationDate <= ToDate) do begin
            // CheckDateStatus clears these itself, but only when no subscriber handles the call.
            TempCalendarSource.Description := '';
            TempCalendarSource.Nonworking := false;
            TempCalendarSource.Date := IterationDate;
            CalendarManagement.CheckDateStatus(TempCalendarSource);

            if ((TempCalendarSource.Nonworking) or (TempCalendarSource.Description <> '')) then begin
                NextEntryNo += 1;
                TempExceptions := TempCalendarSource;
                TempExceptions."Entry No." := NextEntryNo;
                TempExceptions.Insert();
            end;

            IterationDate += 1;
        end;
    end;

    procedure ShowTicketBomAdmissionCalendar(TicketBom: Record "NPR TM Ticket Admission BOM")
    var
        TempCustomizedCalEntry: Record "Customized Calendar Entry" temporary;
        TempCustomizedCalendarChange: Record "Customized Calendar Change" temporary;
    begin
        SetTicketBomAdmissionCalendar(TicketBom, TempCustomizedCalendarChange);
        TempCustomizedCalEntry.CopyFromCustomizedCalendarChange(TempCustomizedCalendarChange);
        TempCustomizedCalEntry.Insert();
        PAGE.Run(PAGE::"Customized Calendar Entries", TempCustomizedCalEntry);
    end;

    // -- Overloads for Admission record and ticket base calendar
    local procedure SetTicketBomAdmissionCalendar(Admission: Record "NPR TM Admission"; var CustomCalendarChange: Record "Customized Calendar Change")
    begin
        CustomCalendarChange.SetSource(
            CustomCalendarChange."Source Type"::NPR_TM_BOM_Admission, Admission."Admission Code", '', Admission."Ticket Base Calendar Code");
    end;

    procedure TicketBomAdmissionChangesExist(Admission: Record "NPR TM Admission"): Boolean
    var
        CustomizedCalendarChange: Record "Customized Calendar Change";
    begin
        SetTicketBomAdmissionCalendar(Admission, CustomizedCalendarChange);
        CustomizedCalendarChange.Reset();
        CustomizedCalendarChange.SetFilter("Source Type", '=%1', CustomizedCalendarChange."Source Type");
        CustomizedCalendarChange.SetFilter("Source Code", '=%1', CustomizedCalendarChange."Source Code");
        CustomizedCalendarChange.SetFilter("Base Calendar Code", '=%1', CustomizedCalendarChange."Base Calendar Code");
        exit(not CustomizedCalendarChange.IsEmpty());
    end;

    procedure CheckTicketBomAdmissionIsNonWorking(Admission: Record "NPR TM Admission"; ReferenceDate: Date; var CustomCalendarChange: Record "Customized Calendar Change") IsNonWorking: Boolean
    var
        CalendarManagement: Codeunit "Calendar Management";
    begin
        SetTicketBomAdmissionCalendar(Admission, CustomCalendarChange);
        CustomCalendarChange.Date := ReferenceDate;
        CalendarManagement.CheckDateStatus(CustomCalendarChange);
        exit(CustomCalendarChange.Nonworking);
    end;

    procedure ShowTicketBomAdmissionCalendar(Admission: Record "NPR TM Admission")
    var
        TempCustomizedCalEntry: Record "Customized Calendar Entry" temporary;
        TempCustomizedCalendarChange: Record "Customized Calendar Change" temporary;
    begin
        SetTicketBomAdmissionCalendar(Admission, TempCustomizedCalendarChange);
        TempCustomizedCalEntry.CopyFromCustomizedCalendarChange(TempCustomizedCalendarChange);
        TempCustomizedCalEntry.Insert();
        PAGE.Run(PAGE::"Customized Calendar Entries", TempCustomizedCalEntry);
    end;


}