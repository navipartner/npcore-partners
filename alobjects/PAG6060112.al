page 6060112 "TM Ticket Select Schedule"
{
    // TM80.1.09/TSA/20160301  CASE 235860 Sell event tickets in POS
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.17/TSA/20161024  CASE Sorting and filtering of schedule entreies, changed to temp record, added AddRecord function
    // TM1.17/NPKNAV/20161026  CASE 256205 Transport TM1.17
    // TM1.20/TSA/20170324  CASE 269171 The remaining ticket qty calculations refined
    // TM1.28/TSA /20180220 CASE 305707 Changed signature on FillPage()
    // TM1.37/TSA /20180926 CASE 327324 Retactored to use new field "Event Arrival From Time"
    // TM1.38/TSA /20181018 CASE 331917 Changed pagetype StandardDialog
    // NPR5.48/TSA /20181207 CASE 331917 Changed fields to non-editable
    // TM1.39/TSA /20181211 CASE 339259 Fixed 327324
    // #322432/TSA /20191121 CASE 322432 Added Remaining calculation for seating
    // TM1.45/TSA /20191121 CASE 378212 Added Sales cut-off date handling and cleaned green code
    // TM1.45/TSA /20191203 CASE 380754 Added waiting list caption
    // TM1.48/TSA /20200629 CASE 411704 Changed from GetAdmissionCapacity() to GetTicketCapacity()

    Caption = 'Ticket Select Schedule';
    DataCaptionFields = "Admission Code";
    DeleteAllowed = false;
    InsertAllowed = false;
    InstructionalText = 'Select time entry.';
    ModifyAllowed = false;
    PageType = StandardDialog;
    SourceTable = "TM Admission Schedule Entry";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Admission Start Date", "Admission Start Time");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Schedule Code"; "Schedule Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Admission Start Date"; "Admission Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = CalendarExceptionText = '';
                }
                field("Admission Start Time"; "Admission Start Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Remaining Reservation"; RemainingReservations)
                {
                    ApplicationArea = All;
                    Caption = 'Remaining Reservation';
                    Editable = false;
                    Visible = false;
                }
                field(RemainingAdmitted; RemainingAdmitted)
                {
                    ApplicationArea = All;
                    Caption = 'Remaining Admitted';
                    Editable = false;
                    Visible = false;
                }
                field(Remaining; RemainingText)
                {
                    ApplicationArea = All;
                    Caption = 'Remaining';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = Remaining <= 0;
                }
                field(CalendarException; CalendarExceptionText)
                {
                    ApplicationArea = All;
                    Caption = 'Calendar Exception';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = CalendarExceptionText <> '';
                    Visible = false;
                }
            }
            group(Control6014401)
            {
                ShowCaption = false;
                field(LocalDateTimeText; LocalDateTimeText)
                {
                    ApplicationArea = All;
                    Caption = 'Time:';
                    Enabled = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        MaxCapacity: Integer;
        CapacityControl: Option;
        Admission: Record "TM Admission";
    begin

        LocalDateTimeText := StrSubstNo('%1 %2', Format(Today), Format(Time));

        CalcFields("Open Reservations", "Open Admitted", "Initial Entry");

        //-TM1.48 [411704]
        //TicketManagement.GetAdmissionCapacity ("Admission Code", "Schedule Code", "Entry No.", MaxCapacity, CapacityControl);
        TicketManagement.GetTicketCapacity(gTicketItemNo, gTicketVariantCode, "Admission Code", "Schedule Code", "Entry No.", MaxCapacity, CapacityControl);
        //+TM1.48 [411704]

        RemainingReservations := MaxCapacity - "Open Reservations";
        RemainingAdmitted := MaxCapacity - "Open Admitted";

        case CapacityControl of
            Admission."Capacity Control"::ADMITTED:
                Remaining := MaxCapacity - "Open Admitted" - "Open Reservations";
            Admission."Capacity Control"::FULL:
                Remaining := MaxCapacity - "Open Admitted" - "Open Reservations";
            Admission."Capacity Control"::NONE:
                Remaining := MaxCapacity;
            Admission."Capacity Control"::SALES:
                Remaining := MaxCapacity - "Initial Entry";
            Admission."Capacity Control"::SEATING:
                Remaining := MaxCapacity - "Open Admitted" - "Open Reservations"; //-+#322432 [322432]
        end;

        //-TM1.45 [380754]
        RemainingText := Format(Remaining);
        if (Rec."Allocation By" = Rec."Allocation By"::WAITINGLIST) then begin
            CalcFields("Waiting List Queue");
            RemainingText := StrSubstNo('%1', WAITING_LIST);
            if ("Waiting List Queue" > 0) then
                RemainingText := StrSubstNo('%1 (%2)', WAITING_LIST, "Waiting List Queue");
        end;
        //+TM1.45 [380754]

        TicketManagement.CheckTicketBaseCalendar(false, Rec."Admission Code", gTicketItemNo, gTicketVariantCode, Rec."Admission Start Date", CalendarExceptionText);
    end;

    trigger OnInit()
    begin
        LocalDateTimeText := StrSubstNo('%1 %2', Format(Today), Format(Time));
    end;

    trigger OnOpenPage()
    begin

        //-TM1.45 [378212]
        // FINDFIRST ();
        if (not FindFirst()) then
            Error(NO_TIMESLOTS);
        //+TM1.45 [378212]
    end;

    var
        RemainingReservations: Integer;
        RemainingAdmitted: Integer;
        RemainingText: Text;
        Remaining: Integer;
        TicketManagement: Codeunit "TM Ticket Management";
        CalendarExceptionText: Text;
        gTicketItemNo: Code[20];
        gTicketVariantCode: Code[10];
        LocalDateTimeText: Text;
        NO_TIMESLOTS: Label 'There are no timeslots available for sales at this time for this event.';
        WAITING_LIST: Label 'Waiting List';

    procedure FillPage(var AdmissionScheduleEntryFilter: Record "TM Admission Schedule Entry"; TicketQty: Decimal; TicketItemNo: Code[20]; TicketVariantCode: Code[10]): Boolean
    var
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
    begin

        AdmissionScheduleEntry.CopyFilters(AdmissionScheduleEntryFilter);
        if (AdmissionScheduleEntry.IsEmpty()) then
            exit(false);

        if (AdmissionScheduleEntry.FindSet()) then begin
            repeat
                //-TM1.45 [378339]
                // AddToTempRecord (AdmissionScheduleEntry, TicketQty);
                AddToTempRecord(AdmissionScheduleEntry, TicketQty, TicketItemNo, TicketVariantCode);
            //+TM1.45 [378339]
            until (AdmissionScheduleEntry.Next() = 0);
        end;

        gTicketItemNo := TicketItemNo;
        gTicketVariantCode := TicketVariantCode;

        exit(true);
    end;

    local procedure AddToTempRecord(AdmissionScheduleEntry: Record "TM Admission Schedule Entry"; TicketQty: Decimal; TicketItemNo: Code[20]; TicketVariantCode: Code[10])
    var
        MaxCapacity: Integer;
        CapacityControl: Option;
        Admission: Record "TM Admission";
        DetailedTicketAccessEntry: Record "TM Det. Ticket Access Entry";
        Item: Record Item;
        TicketType: Record "TM Ticket Type";
        AdmitOnSales: Boolean;
    begin

        //-TM1.45 [378212] // refactored, moved code to function
        if (TicketManagement.ValidateAdmSchEntryForSales(AdmissionScheduleEntry, TicketItemNo, TicketVariantCode, Today, Time, Remaining)) then begin

            Rec.TransferFields(AdmissionScheduleEntry, true);
            if (Rec.Insert()) then;
        end;
        //+TM1.45 [378212]
    end;
}

