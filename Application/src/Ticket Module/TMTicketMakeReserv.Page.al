﻿page 6060113 "NPR TM Ticket Make Reserv."
{
    Extensible = False;
    Caption = 'Make your reservation';
    DataCaptionExpression = GetDataCaptionExpr();
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = StandardDialog;
    SourceTable = "NPR TM Ticket Reservation Req.";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Item Code"; Rec."External Item Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Item No.';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;
                    ToolTip = 'Specifies the value of the Item No. field';

                    trigger OnValidate()
                    begin
                        gReservationEdited := true;
                    end;
                }
                field("Admission Code"; Rec."Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;
                    ToolTip = 'Specifies the value of the Admission Code field';

                    trigger OnDrillDown()
                    begin
                        SelectSchedule();
                        CurrPage.Update(false);
                    end;
                }
                field("ScheduledTimeDescription_PrimaryRequest"; Rec."Scheduled Time Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;
                    Visible = gPrimaryRequestMode;
                    ToolTip = 'Specifies the value of the Scheduled Time Description field';

                    trigger OnDrillDown()
                    begin
                        SelectSchedule();
                        CurrPage.Update(false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        SelectSchedule();
                        CurrPage.Update(false);
                    end;
                }
                field("ScheduledTimeDescription_ChangeRequest"; Rec."Scheduled Time Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    Style = Subordinate;
                    StyleExpr = gDisallowReschedule;
                    Visible = gChangeRequestMode;
                    ToolTip = 'Specifies the value of the Scheduled Time Description field';

                    trigger OnDrillDown()
                    begin
                        SelectSchedule();
                        CurrPage.Update(false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        SelectSchedule();
                        CurrPage.Update(false);
                    end;
                }

                field("Admission Description"; Rec."Admission Description")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;
                    ToolTip = 'Specifies the value of the Admission Description field';

                    trigger OnDrillDown()
                    begin
                        SelectSchedule();
                        CurrPage.Update(false);
                    end;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Editable = gAllowQuantityChange;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;
                    ToolTip = 'Specifies the value of the Quantity field';

                    trigger OnValidate()
                    begin

                        if (Rec."Admission Inclusion" = Rec."Admission Inclusion"::NOT_SELECTED) then
                            Error(QTY_NOT_EDITABLE);

                        if (Rec.Quantity < 1) then
                            Error(QTY_MUST_BE_GT_ZERO);

                        if (xRec.Quantity <> Rec.Quantity) then
                            ChangeQuantity(Rec.Quantity);

                        CurrPage.Update(false);
                    end;
                }
                field("Admission Inclusion"; Rec."Admission Inclusion")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Inclusion field';

                    trigger OnValidate()
                    var
                        CurrentEntryNo: Integer;
                        CommonQty: Integer;
                    begin

                        if (xRec."Admission Inclusion" = xRec."Admission Inclusion"::REQUIRED) then
                            Error(NOT_EDITABLE, Rec.FieldCaption("Admission Inclusion"));

                        if (Rec."Admission Inclusion" = Rec."Admission Inclusion"::REQUIRED) then
                            Error(NOT_EDITABLE, Rec.FieldCaption("Admission Inclusion"));

                        if (xRec."Admission Inclusion" <> xRec."Admission Inclusion"::REQUIRED) and (Rec."Admission Inclusion" = Rec."Admission Inclusion"::REQUIRED) then
                            Error(NOT_REQUIRED, Rec.FieldCaption("Admission Inclusion"));

                        if (xRec."Admission Inclusion" = xRec."Admission Inclusion"::NOT_SELECTED) and (Rec."Admission Inclusion" <> xRec."Admission Inclusion") then begin
                            CurrentEntryNo := Rec."Entry No.";
                            Rec.SetFilter(Quantity, '<>%1', 0);
                            if (Rec.FindFirst()) then
                                CommonQty := Rec.Quantity;
                            Rec.Reset();
                            Rec.Get(CurrentEntryNo);
                            Rec.Quantity := CommonQty;
                            Rec."Admission Inclusion" := Rec."Admission Inclusion"::SELECTED;
                            Rec.Modify();
                        end;

                        if (xRec."Admission Inclusion" = xRec."Admission Inclusion"::SELECTED) and (Rec."Admission Inclusion" <> xRec."Admission Inclusion") then begin
                            Rec.Quantity := 0;
                            Rec."Admission Inclusion" := Rec."Admission Inclusion"::NOT_SELECTED;
                            Rec.Modify();
                        end;

                        gReservationEdited := true;

                    end;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = gBatchTicketCreateMode;
                    ToolTip = 'Specifies the value of the Customer No. field';

                    trigger OnValidate()
                    begin

                        Rec.ModifyAll("Customer No.", Rec."Customer No.");
                        CurrPage.Update(false);

                        gReservationEdited := true;

                    end;
                }
                field("External Order No."; Rec."External Order No.")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = gBatchTicketCreateMode;
                    ToolTip = 'Specifies the value of the External Order No. field';

                    trigger OnValidate()
                    begin

                        Rec.ModifyAll("External Order No.", Rec."External Order No.");
                        CurrPage.Update(false);

                        gReservationEdited := true;

                    end;
                }
                field("Payment Option"; Rec."Payment Option")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Payment Option field';

                    trigger OnValidate()
                    begin

                        Rec.ModifyAll("Payment Option", Rec."Payment Option");
                        CurrPage.Update(false);

                        gReservationEdited := true;
                    end;
                }
                field("Waiting List Reference Code"; Rec."Waiting List Reference Code")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Waiting List Reference Code field';

                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                        TicketWaitingList: Record "NPR TM Ticket Wait. List";
                        WaitingListSetup: Record "NPR TM Waiting List Setup";
                        TicketWaitingListMgr: Codeunit "NPR TM Ticket WaitingList Mgr.";
                        ResponseMessage: Text;
                        Admission: Record "NPR TM Admission";
                        DateTimeLbl: Label '%1  - %2', Locked = true;
                    begin

                        if (Rec."Waiting List Reference Code" <> '') then
                            if (not TicketWaitingListMgr.GetWaitingListAdmSchEntry(Rec."Waiting List Reference Code", CreateDateTime(Today, Time), false, AdmissionScheduleEntry, TicketWaitingList, ResponseMessage)) then
                                Error(ResponseMessage);

                        if (Rec."Waiting List Reference Code" = '') then begin
                            Rec."External Adm. Sch. Entry No." := -1;
                            Rec."Scheduled Time Description" := '';

                        end else begin
                            Admission.Get(Rec."Admission Code");
                            WaitingListSetup.Get(Admission."Waiting List Setup Code");

                            if (WaitingListSetup."Enforce Same Item") then begin
                                Rec.TestField("Item No.", TicketWaitingList."Item No.");
                                Rec.TestField("Variant Code", TicketWaitingList."Variant Code");
                            end;

                            Rec.Validate(Quantity, TicketWaitingList.Quantity);
                            Rec."External Adm. Sch. Entry No." := AdmissionScheduleEntry."External Schedule Entry No.";
                            Rec."Scheduled Time Description" := StrSubstNo(DateTimeLbl, AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
                            if (gDeliverTicketTo = '') then
                                gDeliverTicketTo := TicketWaitingList."Notification Address";

                        end;

                        Rec.Modify();
                        gReservationEdited := true;
                        CurrPage.Update(false);

                        CalcVisualQueueUnfavorable(Rec);
                    end;
                }
            }
            group(Control6014406)
            {

                ShowCaption = false;
                Visible = gShowDeliverTo;
                field(gDeliverTicketTo; gDeliverTicketTo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Deliver eTicket To';
                    ToolTip = 'Specifies the value of the Deliver eTicket To field';
                }
            }
            group(Control6014400)
            {
                ShowCaption = false;
                field(gConfirmStatusText; gConfirmStatusText)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Reservation Confirm Status';
                    Enabled = false;
                    Style = Favorable;
                    StyleExpr = gConfirmStatusStyleFavorable;
                    ToolTip = 'Specifies the value of the Reservation Confirm Status field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            Action("Select Schedule")
            {
                ToolTip = 'Select a schedule entry for admission.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Select Schedule';
                Image = ChangeDate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    SelectSchedule();
                    CurrPage.Update(false);
                end;
            }
            Action("Update Schedule")
            {
                ToolTip = 'Append to the list of generated time slots.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Update Schedule';
                Image = "Action";

                trigger OnAction()
                var
                    AdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
                begin
                    AdmissionSchManagement.CreateAdmissionSchedule(Rec."Admission Code", false, Today);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        gVisualQueueUnfavorable := CalcVisualQueueUnfavorable(Rec);

        gConfirmStatusStyleFavorable := (not gVisualQueueUnfavorable);

        if (gConfirmStatusStyleFavorable) then
            if (gReservationEdited) then
                gConfirmStatusText := STATUS_UNCONFIRMED
            else
                gConfirmStatusText := STATUS_CONFIRMED;

        gDisallowReschedule := not IsRescheduleAllowed(Rec."External Adm. Sch. Entry No.");
    end;

    trigger OnModifyRecord(): Boolean
    begin

        if ((Rec."Request Status" = Rec."Request Status"::CONFIRMED) and (Rec."Admission Created")) then
            Error('Confirmed admissions can not be altered.');
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin

        if (CloseAction = Action::LookupOK) then begin

            if (gBatchTicketCreateMode) then
                if (Rec."Payment Option" <> Rec."Payment Option"::DIRECT) and (Rec."Entry Type" <> Rec."Entry Type"::CHANGE) then begin
                    Rec.TestField("External Order No.");
                    Rec.TestField("Customer No.");
                end;
        end;

        exit(true);
    end;

    var
        gVisualQueueUnfavorable: Boolean;
        gConfirmStatusText: Text;
        gConfirmStatusStyleFavorable: Boolean;
        gReservationEdited: Boolean;
        gQuantityChanged: Boolean;
        gAllowQuantityChange: Boolean;
        STATUS_CONFIRMED: Label 'The reservation is confirmed.';
        STATUS_UNCONFIRMED: Label 'Ticket is unconfirmed. Press OK to confirm new reservation.';
        QTY_MUST_BE_GT_ZERO: Label 'Ticket quantity must be greater than zero.';
        gBatchTicketCreateMode: Boolean;
        gTicketItemNo: Code[20];
        gTicketVariantCode: Code[10];
        gDeliverTicketTo: Text[100];
        gShowDeliverTo: Boolean;
        WAITING_LIST: Label 'Waiting List';
        NO_NOTIFICATION_ADDR: Label 'When you have selected a ticket schedule with waiting list, you need to provide e-mail or sms in the deliver-to field.';
        gLimitToDateSelected: Date;
        DIFFERENT_DATES: Label 'The selected time schedules have different dates. This schedule is for %1 whereas the previous was for %2. Continue anyway?';
        DIFFERENT_DATES_WARNING: Label 'Please note that the selected time schedules have different dates.';
        QTY_NOT_EDITABLE: Label 'Quantity can not be changed for admissions that are not included.';
        NOT_EDITABLE: Label '%1 can not be changed when admission is required.';
        NOT_REQUIRED: Label '%1 can not be changed to required when initial value was optional.';
        gIgnoreScheduleFilter: Boolean;
        gChangeRequestMode: Boolean;
        gPrimaryRequestMode: Boolean;
        gDisallowReschedule: Boolean;
        gTicketRequestEntryNo: Integer;
        RESCHEDULE_NOT_ALLOWED: Label 'The reschedule policy disallows change at this time.';

    local procedure ChangeQuantity(NewQuantity: Integer)
    var
        CurrentEntryNo: Integer;
    begin

        CurrentEntryNo := Rec."Entry No.";

        gReservationEdited := true;
        gQuantityChanged := true;

        Rec.Reset();
        Rec.ModifyAll(Quantity, NewQuantity);

        Rec.SetFilter("Admission Inclusion", '=%1', Rec."Admission Inclusion"::NOT_SELECTED);
        Rec.ModifyAll(Quantity, 0);

        Rec.Reset();
        Rec.Get(CurrentEntryNo);
    end;

    local procedure SelectSchedule()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TMAdmission: Record "NPR TM Admission";
        PageScheduleEntry: Page "NPR TM Ticket Select Schedule";
        PageAction: Action;
        OldEntryNo: Integer;
        "0DF": DateFormula;
        ToDate: Date;
        DateTimeLbl: Label '%1  - %2', Locked = true;
        PlaceHolderLbl: Label '%1', Locked = true;
    begin

        if (not IsRescheduleAllowed(Rec."External Adm. Sch. Entry No.")) then
            Error(RESCHEDULE_NOT_ALLOWED);

        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', Rec."Admission Code");
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '>=%1', Today);
        AdmissionScheduleEntry.SetFilter("Admission Is", '=%1', AdmissionScheduleEntry."Admission Is"::OPEN);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

        if (TMAdmission.Get(Rec."Admission Code")) then begin
            if (TMAdmission."POS Schedule Selection Date F." <> "0DF") then begin
                ToDate := CalcDate(TMAdmission."POS Schedule Selection Date F.", Today);

                if (not gIgnoreScheduleFilter) then
                    AdmissionScheduleEntry.SetRange("Admission Start Date", Today, ToDate);

            end;
        end;

        Clear(PageScheduleEntry);
        PageScheduleEntry.FillPage(AdmissionScheduleEntry, Rec.Quantity, gTicketItemNo, gTicketVariantCode);
        PageScheduleEntry.LookupMode(true);
        PageAction := PageScheduleEntry.RunModal();

        if ((PageAction = Action::Yes) or (PageAction = Action::LookupOK)) then begin
            OldEntryNo := Rec."External Adm. Sch. Entry No.";
            PageScheduleEntry.GetRecord(AdmissionScheduleEntry);

            Rec."External Adm. Sch. Entry No." := AdmissionScheduleEntry."External Schedule Entry No.";
            Rec."Scheduled Time Description" := StrSubstNo(DateTimeLbl, AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");

            if (AdmissionScheduleEntry."Allocation By" = AdmissionScheduleEntry."Allocation By"::WAITINGLIST) then begin
                Rec."Scheduled Time Description" := StrSubstNo(PlaceHolderLbl, WAITING_LIST);
                gShowDeliverTo := true;
            end;

            if (gLimitToDateSelected = 0D) then
                gLimitToDateSelected := AdmissionScheduleEntry."Admission Start Date";

            if (gLimitToDateSelected <> 0D) then
                if (gLimitToDateSelected <> AdmissionScheduleEntry."Admission Start Date") then begin
                    if (not Confirm(DIFFERENT_DATES, false, AdmissionScheduleEntry."Admission Start Date", gLimitToDateSelected)) then
                        Error('');
                    gLimitToDateSelected := AdmissionScheduleEntry."Admission Start Date";
                end;

            Rec.Modify();

            ConfirmOverlappingTimes(Rec."Entry No.", Rec."External Adm. Sch. Entry No.");

            if (OldEntryNo <> Rec."External Adm. Sch. Entry No.") then begin
                gReservationEdited := true;

            end;

        end;
    end;

    local procedure CalcVisualQueueUnfavorable(TicketReservationRequest: Record "NPR TM Ticket Reservation Req."): Boolean
    var
        AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        CapacityControl: Option;
        MaxCapacity: Integer;
        Remaining: Integer;
        ResponseMessage: Text;
        NonWorking: Boolean;
    begin

        gConfirmStatusText := '';

        if (TicketReservationRequest."External Adm. Sch. Entry No." <= 0) then
            exit(true);

        if (TicketReservationRequest."External Adm. Sch. Entry No." > 0) then begin
            AdmissionSchEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest."External Adm. Sch. Entry No.");
            AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);

            if (AdmissionSchEntry.FindFirst()) then begin
                AdmissionSchEntry.CalcFields("Open Reservations", "Open Admitted", "Initial Entry");
                ScheduleLine.Get(AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code");

                TicketManagement.CheckTicketBaseCalendar(TicketReservationRequest."Admission Code", gTicketItemNo, gTicketVariantCode, AdmissionSchEntry."Admission Start Date", NonWorking, ResponseMessage);
                if (NonWorking) then begin
                    gConfirmStatusText := ResponseMessage;
                    exit(true);
                end;
                TicketManagement.GetTicketCapacity(gTicketItemNo, gTicketVariantCode, AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code", AdmissionSchEntry."Entry No.", MaxCapacity, CapacityControl);

                case CapacityControl of
                    Admission."Capacity Control"::ADMITTED:
                        Remaining := MaxCapacity - AdmissionSchEntry."Open Admitted" - AdmissionSchEntry."Open Reservations";
                    Admission."Capacity Control"::FULL:
                        Remaining := MaxCapacity - AdmissionSchEntry."Open Admitted" - AdmissionSchEntry."Open Reservations";
                    Admission."Capacity Control"::NONE:
                        exit(false);
                    Admission."Capacity Control"::SALES:
                        Remaining := MaxCapacity - AdmissionSchEntry."Initial Entry";
                    Admission."Capacity Control"::SEATING:
                        Remaining := MaxCapacity - AdmissionSchEntry."Open Admitted" - AdmissionSchEntry."Open Reservations";
                end;

                exit(Remaining < TicketReservationRequest.Quantity);

            end;
        end;

        exit(false);
    end;

    internal procedure LoadTicketRequest(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ShowDifferentDatesWarning: Boolean;
    begin

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            gDeliverTicketTo := TicketReservationRequest."Notification Address";

            repeat
                Rec.TransferFields(TicketReservationRequest, true);
                Rec.Insert();

                if (TicketReservationRequest."External Adm. Sch. Entry No." > 0) then begin
                    AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest."External Adm. Sch. Entry No.");
                    AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                    if (AdmissionScheduleEntry.FindLast()) then begin

                        if (gLimitToDateSelected = 0D) then
                            gLimitToDateSelected := AdmissionScheduleEntry."Admission Start Date";

                        if (gLimitToDateSelected <> 0D) then
                            ShowDifferentDatesWarning := ShowDifferentDatesWarning or (gLimitToDateSelected <> AdmissionScheduleEntry."Admission Start Date");

                    end;
                end;

                if (Rec."Primary Request Line") then
                    gTicketRequestEntryNo := TicketReservationRequest."Entry No.";
                if ((Rec."Primary Request Line") and (TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::CHANGE)) then
                    gTicketRequestEntryNo := TicketReservationRequest."Superseeds Entry No.";

            until (TicketReservationRequest.Next() = 0);
        end;

        gReservationEdited := false;
        gBatchTicketCreateMode := (Rec."Payment Option" <> Rec."Payment Option"::DIRECT);
        gChangeRequestMode := (Rec."Entry Type" = Rec."Entry Type"::CHANGE);
        gPrimaryRequestMode := not gChangeRequestMode;

        if (ShowDifferentDatesWarning) then
            Message(DIFFERENT_DATES_WARNING);
    end;

    internal procedure SetTicketItem(ItemNo: Code[20]; VariantCode: Code[10])
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
    begin
        gTicketItemNo := ItemNo;
        gTicketVariantCode := VariantCode;

        if (Item.Get(ItemNo)) then
            if (TicketType.Get(Item."NPR Ticket Type")) then
                gShowDeliverTo := TicketType."eTicket Activated";

        TicketBOM.SetFilter("Item No.", '=%1', ItemNo);
        TicketBOM.SetFilter("Variant Code", '=%1', VariantCode);
        TicketBOM.SetFilter("Publish Ticket URL", '<>%1', TicketBOM."Publish Ticket URL"::DISABLE);
        if (not gShowDeliverTo) then
            gShowDeliverTo := TicketBOM.FindFirst();

        TicketBOM.Reset();
        TicketBOM.SetFilter("Item No.", '=%1', ItemNo);
        TicketBOM.SetFilter("Variant Code", '=%1', VariantCode);
        TicketBOM.SetFilter("Notification Profile Code", '<>%1', '');
        if (not gShowDeliverTo) then
            gShowDeliverTo := TicketBOM.FindFirst();
    end;

    internal procedure AllowQuantityChange(AllowQuantityChange: Boolean)
    begin
        gAllowQuantityChange := AllowQuantityChange;
    end;

    internal procedure FinalizeReservationRequest(FailWithError: Boolean; var ResponseMessage: Text): Integer
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketWaitingListMgr: Codeunit "NPR TM Ticket WaitingList Mgr.";
    begin

        if (gDeliverTicketTo <> '') then begin
            Rec.Reset();
            if (Rec.FindSet()) then;
            repeat
                TicketReservationRequest.Get(Rec."Entry No.");

                TicketReservationRequest."Notification Address" := gDeliverTicketTo;
                if (StrPos(gDeliverTicketTo, '@') > 0) then
                    TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::EMAIL
                else
                    TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::SMS;

                TicketReservationRequest.Modify();
            until (Rec.Next() = 0);
        end;

        Rec.Reset();
        Rec.SetFilter("Scheduled Time Description", '=%1', WAITING_LIST);
        if (Rec.FindSet()) then begin
            if (gDeliverTicketTo = '') then begin
                ResponseMessage := NO_NOTIFICATION_ADDR;
                exit(10);
            end;

            TicketRequestManager.DeleteReservationRequest(Rec."Session Token ID", false);
            repeat
                TicketReservationRequest.Get(Rec."Entry No.");
                TicketWaitingListMgr.CreateWaitingListEntry(Rec, gDeliverTicketTo);
            until (Rec.Next() = 0);
            Message('Added to waiting list.');
            ResponseMessage := 'If this message is shown, waiting list return code 11 is not handled properly.';
            exit(11);
        end;
        Rec.Reset();

        if (gReservationEdited) then begin

            TicketRequestManager.DeleteReservationRequest(Rec."Session Token ID", false);

            Rec.Reset();
            if (Rec.FindFirst()) then;
            repeat

                TicketReservationRequest.Get(Rec."Entry No.");
                TicketReservationRequest.Quantity := Rec.Quantity;
                TicketReservationRequest."External Adm. Sch. Entry No." := Rec."External Adm. Sch. Entry No.";
                TicketReservationRequest."Scheduled Time Description" := Rec."Scheduled Time Description";
                if (gBatchTicketCreateMode) then begin
                    TicketReservationRequest."External Order No." := Rec."External Order No.";
                    TicketReservationRequest."Payment Option" := Rec."Payment Option";
                    TicketReservationRequest."Customer No." := Rec."Customer No.";
                end;

                TicketReservationRequest."Admission Inclusion Status" := TicketReservationRequest."Admission Inclusion Status"::NO_CHANGE;
                if (TicketBOM.Get(Rec."Item No.", Rec."Variant Code", Rec."Admission Code")) then begin
                    TicketReservationRequest."Admission Inclusion Status" := TicketReservationRequest."Admission Inclusion Status"::NO_CHANGE;
                    if (TicketReservationRequest."Admission Inclusion" <> Rec."Admission Inclusion") then
                        case Rec."Admission Inclusion" of
                            Rec."Admission Inclusion"::NOT_SELECTED:
                                TicketReservationRequest."Admission Inclusion Status" := TicketReservationRequest."Admission Inclusion Status"::REMOVE;
                            Rec."Admission Inclusion"::SELECTED:
                                TicketReservationRequest."Admission Inclusion Status" := TicketReservationRequest."Admission Inclusion Status"::ADD;
                        end;
                end;

                TicketReservationRequest."Waiting List Reference Code" := Rec."Waiting List Reference Code";
                TicketReservationRequest."Admission Inclusion" := Rec."Admission Inclusion";

                if (not TicketReservationRequest."Admission Created") then
                    TicketReservationRequest.Modify();

            until (Rec.Next() = 0);

            TicketRequestManager.SetShowProgressBar(gBatchTicketCreateMode);
            exit(TicketRequestManager.IssueTicketFromReservationToken(Rec."Session Token ID", FailWithError, ResponseMessage));
        end;

        exit(0);
    end;

    internal procedure FinalizeChangeRequest(FailWithError: Boolean; var ResponseMessage: Text): Integer;
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        NewTicketRequestEntryNo: Integer;
    begin

        if (gDeliverTicketTo <> '') then begin
            Rec.Reset();
            if (Rec.FindSet()) then;
            repeat
                TicketReservationRequest.Get(Rec."Entry No.");
                TicketReservationRequest."Notification Address" := gDeliverTicketTo;
                if (STRPOS(gDeliverTicketTo, '@') > 0) then
                    TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::EMAIL
                else
                    TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::SMS;

                TicketReservationRequest.Modify();
            until (Rec.Next() = 0);
        end;

        Rec.Reset();
        Rec.SetFilter("Scheduled Time Description", '=%1', WAITING_LIST);
        if (not (Rec.IsEmpty())) then begin
            ResponseMessage := 'Not in this version: It is not supported to change to a timeslot that is on a waitinglist.';
            exit(13);
        end;

        if (gReservationEdited) then begin
            Rec.Reset();

            Rec.FindSet();
            repeat
                TicketReservationRequest.Get(Rec."Entry No.");
                TicketReservationRequest."External Adm. Sch. Entry No." := Rec."External Adm. Sch. Entry No.";
                TicketReservationRequest."Scheduled Time Description" := Rec."Scheduled Time Description";
                TicketReservationRequest.Modify();
            until (Rec.Next() = 0);

            Rec.Reset();
            Rec.SetFilter("Primary Request Line", '=%1', true);
            Rec.FindFirst();
            NewTicketRequestEntryNo := Rec."Entry No.";

            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', Rec."Superseeds Entry No.");
            if (Ticket.FindSet()) then begin
                repeat
                    Rec.Reset();
                    Rec.FindSet();
                    repeat
                        TicketManagement.RescheduleTicketAdmission(Ticket."No.", Rec."External Adm. Sch. Entry No.", true, Rec."Request Status Date Time");
                    until (Rec.Next() = 0);
                until (Ticket.Next() = 0);

                Ticket.ModifyAll("Ticket Reservation Entry No.", NewTicketRequestEntryNo, false);
            end;

            TicketRequestManager.ConfirmChangeRequest(Rec."Session Token ID");
        end;

        exit(0);
    end;

    internal procedure GetChangedTicketQuantity(var NewQuantity: Integer) QtyChanged: Boolean
    begin

        if (Rec.FindFirst()) then
            NewQuantity := Rec.Quantity;

        exit(gQuantityChanged);
    end;

    internal procedure SetTicketBatchMode()
    begin
        gBatchTicketCreateMode := true;
    end;

    local procedure ConfirmOverlappingTimes(SelectedRequestEntryNo: Integer; SelectedExternalAdmSchEntryNo: Integer)
    var
        AdmissionScheduleEntry1: Record "NPR TM Admis. Schedule Entry";
        AdmissionScheduleEntry2: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        TimeOverlapIssue: Boolean;
    begin

        AdmissionScheduleEntry1.SetFilter("External Schedule Entry No.", '=%1', SelectedExternalAdmSchEntryNo);
        AdmissionScheduleEntry1.SetFilter(Cancelled, '=%1', false);
        AdmissionScheduleEntry1.FindFirst();
        Admission.Get(AdmissionScheduleEntry1."Admission Code");
        if (Admission.Type = Admission.Type::LOCATION) then
            exit;

        Rec.Reset();
        Rec.FindSet();
        repeat
            TimeOverlapIssue := false;

            if (Rec."External Adm. Sch. Entry No." <> SelectedExternalAdmSchEntryNo) then begin
                if (Rec."External Adm. Sch. Entry No." <> 0) then begin
                    AdmissionScheduleEntry2.SetFilter("External Schedule Entry No.", '=%1', Rec."External Adm. Sch. Entry No.");
                    AdmissionScheduleEntry2.SetFilter(Cancelled, '=%1', false);
                    AdmissionScheduleEntry2.FindFirst();
                    Admission.Get(AdmissionScheduleEntry2."Admission Code");
                    if ((AdmissionScheduleEntry1."Admission Start Date" = AdmissionScheduleEntry2."Admission Start Date") and
                        (Admission.Type = Admission.Type::OCCASION)) then
                        TimeOverlapIssue := (((AdmissionScheduleEntry1."Admission Start Time" >= AdmissionScheduleEntry2."Admission Start Time") and
                                              (AdmissionScheduleEntry1."Admission Start Time" <= AdmissionScheduleEntry2."Admission end Time")) or
                                             ((AdmissionScheduleEntry1."Admission end Time" >= AdmissionScheduleEntry2."Admission Start Time") and
                                              (AdmissionScheduleEntry1."Admission end Time" <= AdmissionScheduleEntry2."Admission end Time")));

                end;
            end;

        until ((Rec.Next() = 0) or TimeOverlapIssue);

        Rec.Get(SelectedRequestEntryNo);

        if (TimeOverlapIssue) then
            if (not Confirm('Your selected time %1 for %2 seems to overlap with your time selection for %3 at %4. Do you want to continue anyway?', false,
               AdmissionScheduleEntry1."Admission Start Time", AdmissionScheduleEntry1."Admission Code",
               AdmissionScheduleEntry2."Admission Code", AdmissionScheduleEntry2."Admission Start Time")) then
                Error('');

    end;

    internal procedure SetIgnoreScheduleSelectionFilter(IgnoreFilter: Boolean): Boolean
    begin

        gIgnoreScheduleFilter := IgnoreFilter;
        exit(gIgnoreScheduleFilter);

    end;

    local procedure IsRescheduleAllowed(ExtAdmSchEntryNo: Integer) RescheduleAllowed: Boolean;
    var
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin

        RescheduleAllowed := true;

        if (gChangeRequestMode) then begin
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', gTicketRequestEntryNo);
            if (Ticket.FindFirst()) then
                RescheduleAllowed := TicketManagement.IsRescheduleAllowed(Ticket."External Ticket No.", ExtAdmSchEntryNo, CurrentDateTime());
        end;

        exit(RescheduleAllowed);

    end;

    local procedure GetDataCaptionExpr(): Text
    var
        DateTimeLbl: Label '%1  - %2', Locked = true;
    begin
        exit(StrSubstNo(DateTimeLbl, Today(), Time()));
    end;
}
