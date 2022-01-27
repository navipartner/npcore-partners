page 6060112 "NPR TM Ticket Select Schedule"
{
    Extensible = False;
    Caption = 'Ticket Select Schedule';
    DataCaptionFields = "Admission Code";
    DeleteAllowed = false;
    InsertAllowed = false;
    InstructionalText = 'Select time entry.';
    ModifyAllowed = false;
    PageType = StandardDialog;
    SourceTable = "NPR TM Admis. Schedule Entry";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Admission Start Date", "Admission Start Time");
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Schedule Code"; Rec."Schedule Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Schedule Code field';
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Admission Start Date"; Rec."Admission Start Date")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = CalendarExceptionText = '';
                    ToolTip = 'Specifies the value of the Admission Start Date field';
                }
                field("Admission Start Time"; Rec."Admission Start Time")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Admission Start Time field';
                }
                field("Remaining Reservation"; RemainingReservations)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Remaining Reservation';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Remaining Reservation field';
                }
                field(RemainingAdmitted; RemainingAdmitted)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Remaining Admitted';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Remaining Admitted field';
                }
                field(Remaining; RemainingText)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Remaining';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = Remaining <= 0;
                    ToolTip = 'Specifies the value of the Remaining field';
                }
                field(CalendarException; CalendarExceptionText)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    Caption = 'Calendar Exception';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = CalendarExceptionText <> '';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Calendar Exception field';
                }
            }
            group(Control6014401)
            {
                ShowCaption = false;
                field(LocalDateTimeText; LocalDateTimeText)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Time:';
                    Enabled = false;
                    ToolTip = 'Specifies the value of the Time: field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        NonWorking: Boolean;
        DateTimeLbl: Label '%1 %2', Locked = true;
        RemainingLbl: Label '%1', Locked = true;
        Remaining2Lbl: Label '%1 (%2)', Locked = true;
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
    begin

        LocalDateTimeText := StrSubstNo(DateTimeLbl, Format(Today()), Format(Time()));

        TicketManagement.ValidateAdmSchEntryForSales(Rec, gTicketItemNo, gTicketVariantCode, Today, Time, ReasonCode, Remaining);

        RemainingText := Format(Remaining);
        if (Rec."Allocation By" = Rec."Allocation By"::WAITINGLIST) then begin
            Rec.CalcFields("Waiting List Queue");
            RemainingText := StrSubstNo(RemainingLbl, WAITING_LIST);
            if (Rec."Waiting List Queue" > 0) then
                RemainingText := StrSubstNo(Remaining2Lbl, WAITING_LIST, Rec."Waiting List Queue");
        end;

        TicketManagement.CheckTicketBaseCalendar(Rec."Admission Code", gTicketItemNo, gTicketVariantCode, Rec."Admission Start Date", NonWorking, CalendarExceptionText);
        if (CalendarExceptionText <> '') then
            RemainingText := Format(Remaining) + ' - ' + CalendarExceptionText;

        if (NonWorking) then
            RemainingText := CalendarExceptionText;
    end;

    trigger OnInit()
    var
        DateTimeLbl: Label '%1 %2', Locked = true;
    begin
        LocalDateTimeText := StrSubstNo(DateTimeLbl, Format(Today), Format(Time));
    end;

    trigger OnOpenPage()
    begin

        if (not Rec.FindFirst()) then
            Error(NO_TIMESLOTS);

    end;

    var
        RemainingReservations: Integer;
        RemainingAdmitted: Integer;
        RemainingText: Text;
        Remaining: Integer;
        TicketManagement: Codeunit "NPR TM Ticket Management";
        CalendarExceptionText: Text;
        gTicketItemNo: Code[20];
        gTicketVariantCode: Code[10];
        LocalDateTimeText: Text;
        NO_TIMESLOTS: Label 'There are no timeslots available for sales at this time for this event.';
        WAITING_LIST: Label 'Waiting List';

    procedure FillPage(var AdmissionScheduleEntryFilter: Record "NPR TM Admis. Schedule Entry"; TicketQty: Decimal; TicketItemNo: Code[20]; TicketVariantCode: Code[10]): Boolean
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        AdmissionScheduleEntry.CopyFilters(AdmissionScheduleEntryFilter);
        if (AdmissionScheduleEntry.IsEmpty()) then
            exit(false);

        if (AdmissionScheduleEntry.FindSet()) then begin
            repeat
                AddToTempRecord(AdmissionScheduleEntry, TicketItemNo, TicketVariantCode);
            until (AdmissionScheduleEntry.Next() = 0);
        end;

        gTicketItemNo := TicketItemNo;
        gTicketVariantCode := TicketVariantCode;

        exit(true);
    end;

    local procedure AddToTempRecord(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; TicketItemNo: Code[20]; TicketVariantCode: Code[10])
    var
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
    begin

        if (TicketManagement.ValidateAdmSchEntryForSales(AdmissionScheduleEntry, TicketItemNo, TicketVariantCode, Today, Time, ReasonCode, Remaining)) then begin

            Rec.TransferFields(AdmissionScheduleEntry, true);
            if (Rec.Insert()) then;
        end;
    end;
}

