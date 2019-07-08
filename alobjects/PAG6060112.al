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

    Caption = 'Ticket Select Schedule';
    DataCaptionFields = "Admission Code";
    DeleteAllowed = false;
    InsertAllowed = false;
    InstructionalText = 'Select time entry.';
    ModifyAllowed = false;
    PageType = StandardDialog;
    SourceTable = "TM Admission Schedule Entry";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Admission Start Date","Admission Start Time");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Admission Code";"Admission Code")
                {
                    Editable = false;
                }
                field("Admission Start Date";"Admission Start Date")
                {
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = CalendarExceptionText ='';
                }
                field("Admission Start Time";"Admission Start Time")
                {
                    Editable = false;
                }
                field("Remaining Reservation";RemainingReservations)
                {
                    Caption = 'Remaining Reservation';
                    Editable = false;
                    Visible = false;
                }
                field(RemainingAdmitted;RemainingAdmitted)
                {
                    Caption = 'Remaining Admitted';
                    Editable = false;
                    Visible = false;
                }
                field(Remaining;Remaining)
                {
                    BlankNumbers = BlankNegAndZero;
                    Caption = 'Remaining';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = Remaining <= 0;
                }
                field(CalendarException;CalendarExceptionText)
                {
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
                field(LocalDateTimeText;LocalDateTimeText)
                {
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

        //-TM1.39 [339259]
        LocalDateTimeText := StrSubstNo ('%1 %2', Format (Today), Format (Time));
        //+TM1.39 [339259]

        CalcFields ("Open Reservations", "Open Admitted", "Initial Entry");
        TicketManagement.GetMaxCapacity ("Admission Code", "Schedule Code", "Entry No.", MaxCapacity, CapacityControl);

        RemainingReservations := MaxCapacity - "Open Reservations";
        RemainingAdmitted := MaxCapacity - "Open Admitted";

        //-TM1.20 [269171]
        case CapacityControl of
          Admission."Capacity Control"::ADMITTED : Remaining := MaxCapacity - "Open Admitted" - "Open Reservations";
          Admission."Capacity Control"::FULL : Remaining :=  MaxCapacity - "Open Admitted" - "Open Reservations";
          Admission."Capacity Control"::NONE : Remaining :=  MaxCapacity;
          Admission."Capacity Control"::SALES : Remaining := MaxCapacity - "Initial Entry";
        end;
        //+TM1.20 [269171]

        //-TM1.28 [305707]
        TicketManagement.CheckTicketBaseCalendar (false, Rec."Admission Code", gTicketItemNo, gTicketVariantCode, Rec."Admission Start Date", CalendarExceptionText);
        //+TM1.28 [305707]
    end;

    trigger OnInit()
    begin
        //-TM1.39 [339259]
        LocalDateTimeText := StrSubstNo ('%1 %2', Format (Today), Format (Time));
        //+TM1.39 [339259]
    end;

    trigger OnOpenPage()
    begin
        FindFirst ();
    end;

    var
        RemainingReservations: Integer;
        RemainingAdmitted: Integer;
        Remaining: Integer;
        TicketManagement: Codeunit "TM Ticket Management";
        CalendarExceptionText: Text;
        gTicketItemNo: Code[20];
        gTicketVariantCode: Code[10];
        LocalDateTimeText: Text;

    procedure FillPage(var AdmissionScheduleEntryFilter: Record "TM Admission Schedule Entry";TicketQty: Decimal;TicketItemNo: Code[20];TicketVariantCode: Code[10]): Boolean
    var
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
    begin

        AdmissionScheduleEntry.CopyFilters (AdmissionScheduleEntryFilter);
        if (AdmissionScheduleEntry.IsEmpty ()) then
          exit (false);

        if (AdmissionScheduleEntry.FindSet ()) then begin
          repeat
            AddToTempRecord (AdmissionScheduleEntry, TicketQty);
          until (AdmissionScheduleEntry.Next() = 0);
        end;

        //-TM1.28 [305707]
        gTicketItemNo := TicketItemNo;
        gTicketVariantCode := TicketVariantCode;
        //+TM1.28 [305707]

        exit (true);
    end;

    local procedure AddToTempRecord(AdmissionScheduleEntry: Record "TM Admission Schedule Entry";TicketQty: Decimal)
    var
        MaxCapacity: Integer;
        CapacityControl: Option;
        Admission: Record "TM Admission";
        DetailedTicketAccessEntry: Record "TM Det. Ticket Access Entry";
    begin

        with AdmissionScheduleEntry do begin

          TicketManagement.GetMaxCapacity ("Admission Code", "Schedule Code", "Entry No.", MaxCapacity, CapacityControl);

          if ("Admission Start Date" = Today) then begin

            //-TM1.37 [327324]
            //    IF ("Bookable Passed Start (Secs)" = 0) AND ("Admission End Time"  < TIME) THEN
            //      EXIT;
            //    IF ("Bookable Passed Start (Secs)" <> 0) AND (("Admission Start Time" + "Bookable Passed Start (Secs)"*1000) < TIME) THEN
            //      EXIT;
            if (("Event Arrival From Time" = 0T) and ("Admission End Time"  < Time)) then
              exit;

            //-TM1.39 [339259]
            // IF (("Event Arrival From Time" <> 0T) AND ("Event Arrival From Time" < TIME)) THEN
            //      EXIT;
            //+TM1.37 [327324]

            if (("Event Arrival From Time" <> 0T) and ("Event Arrival From Time" > Time)) then
              exit;

            if (("Event Arrival Until Time" <> 0T) and ("Event Arrival Until Time" < Time)) then
              exit;
            //+TM1.39 [339259]


          end;

          //-TM1.20 [269171]
          CalcFields ("Open Reservations", "Open Admitted", "Initial Entry");
          case CapacityControl of
            Admission."Capacity Control"::ADMITTED : Remaining := MaxCapacity - "Open Admitted" - "Open Reservations";
            Admission."Capacity Control"::FULL : Remaining :=  MaxCapacity - "Open Admitted" - "Open Reservations";
            Admission."Capacity Control"::NONE : Remaining :=  MaxCapacity;
            Admission."Capacity Control"::SALES : Remaining := MaxCapacity - "Initial Entry";
          end;

          //Remaining :=  MaxCapacity - "Open Admitted" - "Open Reservations";
          //IF (Remaining < TicketQty) THEN
          //  EXIT;
          //+TM1.20 [269171]
        end;

        Rec.TransferFields (AdmissionScheduleEntry, true);
        if (Rec.Insert ()) then ;
    end;
}

