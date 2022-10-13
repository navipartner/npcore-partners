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
        TempCustomCalendarChange.Insert();
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
        TempCustomCalendarChange.Insert();
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
        TempCustomCalendarChange.Insert();
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
        CustomCalendarChange.Insert();
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
        CustomizedCalendarChange.SetFilter("Base Calendar Code", '=%', CustomizedCalendarChange."Base Calendar Code");
        exit(not CustomizedCalendarChange.IsEmpty());
    end;

    procedure CheckTicketBomAdmissionIsNonWorking(TicketBom: Record "NPR TM Ticket Admission BOM"; ReferenceDate: Date; var CustomCalendarChange: Record "Customized Calendar Change") IsNonWorking: Boolean
    var
        CalendarManagement: Codeunit "Calendar Management";
    begin
        SetTicketBomAdmissionCalendar(TicketBom, CustomCalendarChange);
        CustomCalendarChange.Date := ReferenceDate;
        CustomCalendarChange.Insert();
        CalendarManagement.CheckDateStatus(CustomCalendarChange);
        exit(CustomCalendarChange.Nonworking);
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
        CustomizedCalendarChange.SetFilter("Base Calendar Code", '=%', CustomizedCalendarChange."Base Calendar Code");
        exit(not CustomizedCalendarChange.IsEmpty());
    end;

    procedure CheckTicketBomAdmissionIsNonWorking(Admission: Record "NPR TM Admission"; ReferenceDate: Date; var CustomCalendarChange: Record "Customized Calendar Change") IsNonWorking: Boolean
    var
        CalendarManagement: Codeunit "Calendar Management";
    begin
        SetTicketBomAdmissionCalendar(Admission, CustomCalendarChange);
        CustomCalendarChange.Date := ReferenceDate;
        CustomCalendarChange.Insert();
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