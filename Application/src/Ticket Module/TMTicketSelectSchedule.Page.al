page 6060112 "NPR TM Ticket Select Schedule"
{
    Extensible = False;
    Caption = 'Ticket Select Schedule';
    DataCaptionFields = "Admission Code";
    DeleteAllowed = false;
    InsertAllowed = false;
    InstructionalText = 'Select time entry.';
    ModifyAllowed = false;
    PageType = Worksheet;
    SourceTable = "NPR TM Admis. Schedule Entry";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Admission Start Date", "Admission Start Time");
    UsageCategory = None;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';

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
                field(UnitPrice; _UnitPriceDisplay)
                {
                    ApplicationArea = NPRTicketAdvanced, NPRTicketDynamicPrice;
                    Caption = 'Unit Price';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = CalendarExceptionText <> '';
                    ToolTip = 'Specifies the value of the admission unit price.';
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
        BasePrice, AddonPrice : Decimal;
        FormatLabel: Label '<Sign><Integer><Decimals>', Locked = true;
    begin

        LocalDateTimeText := StrSubstNo(DateTimeLbl, Format(Today()), Format(Time()));

        TicketManagement.ValidateAdmSchEntryForSales(Rec, _TicketItemNo, _TicketVariantCode, Today, Time, ReasonCode, Remaining);
        RemainingText := Format(Remaining);
        if (Rec."Allocation By" = Rec."Allocation By"::WAITINGLIST) then begin
            Rec.CalcFields("Waiting List Queue");
            RemainingText := StrSubstNo(RemainingLbl, WAITING_LIST);
            if (Rec."Waiting List Queue" > 0) then
                RemainingText := StrSubstNo(Remaining2Lbl, WAITING_LIST, Rec."Waiting List Queue");
        end;

        TicketManagement.CheckTicketBaseCalendar(Rec."Admission Code", _TicketItemNo, _TicketVariantCode, Rec."Admission Start Date", NonWorking, CalendarExceptionText);
        if (CalendarExceptionText <> '') then
            RemainingText := Format(Remaining) + ' - ' + CalendarExceptionText;

        if (NonWorking) then
            RemainingText := CalendarExceptionText;

        GetAdmissionPrice(Rec."Admission Code", Rec."External Schedule Entry No.", Today(), Time(), BasePrice, AddonPrice);
        _UnitPriceDisplay := StrSubstNo('%1', Format(BasePrice, 0, FormatLabel));
        if (BasePrice <> 0) or (AddonPrice <> 0) then
            _UnitPriceDisplay := StrSubstNo('%1 [%2 / %3]', Format(BasePrice + AddonPrice, 0, FormatLabel), Format(BasePrice, 0, FormatLabel), Format(AddonPrice, 0, FormatLabel));

    end;

    trigger OnInit()
    var
        DateTimeLbl: Label '%1 %2', Locked = true;
    begin
        LocalDateTimeText := StrSubstNo(DateTimeLbl, Format(Today), Format(Time));
    end;

    trigger OnOpenPage()
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        Item: Record Item;
    begin

        if (not Rec.FindFirst()) then
            Error(NO_TIMESLOTS);

        _UnitPrice := 0;
        _DiscountPct := 0;
        _UnitPriceIncludesVat := false;
        _UnitPriceVatPercentage := 0;

        if (_TicketItemNo <> '') then begin
            if (not TicketPrice.CalculateErpUnitPrice(_TicketItemNo, _TicketVariantCode, '', Today(), 1, _UnitPrice, _DiscountPct, _UnitPriceIncludesVat, _UnitPriceVatPercentage)) then begin
                Item.Get(_TicketItemNo);
                _UnitPrice := Item."Unit Price";
                _UnitPriceIncludesVat := Item."Price Includes VAT";
                _UnitPriceVatPercentage := TicketPrice.GetItemDefaultVat(_TicketItemNo);
            end;
        end;
    end;

    var
        RemainingReservations: Integer;
        RemainingAdmitted: Integer;
        RemainingText: Text;
        Remaining: Integer;
        TicketManagement: Codeunit "NPR TM Ticket Management";
        CalendarExceptionText: Text;
        _TicketItemNo: Code[20];
        _TicketVariantCode: Code[10];
        LocalDateTimeText: Text;
        NO_TIMESLOTS: Label 'There are no timeslots available for sales at this time for this event.';
        WAITING_LIST: Label 'Waiting List';
        _UnitPriceDisplay: Text;
        _UnitPrice: Decimal;
        _DiscountPct: Decimal;
        _UnitPriceIncludesVat: Boolean;
        _UnitPriceVatPercentage: Decimal;


    internal procedure FillPage(var AdmissionScheduleEntryFilter: Record "NPR TM Admis. Schedule Entry"; TicketQty: Decimal; TicketItemNo: Code[20]; TicketVariantCode: Code[10]): Boolean
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

        _TicketItemNo := TicketItemNo;
        _TicketVariantCode := TicketVariantCode;

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

    local procedure GetAdmissionPrice(AdmissionCode: Code[20]; ExternalScheduleEntryNo: Integer; BookingDateDate: Date; BookingTime: Time; var BasePrice: Decimal; var AddonPrice: Decimal) HavePriceRule: Boolean
    var
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        SelectedPriceRule: Record "NPR TM Dynamic Price Rule";
    begin
        HavePriceRule := TicketPrice.CalculateScheduleEntryPrice(
                    _TicketItemNo,
                    _TicketVariantCode,
                    AdmissionCode,
                    ExternalScheduleEntryNo,
                    _UnitPrice,
                    _UnitPriceIncludesVat,
                    _UnitPriceVatPercentage,
                    BookingDateDate,
                    BookingTime,
                    BasePrice,
                    AddonPrice,
                    SelectedPriceRule
                );
    end;
}

