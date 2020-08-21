page 6060113 "TM Ticket Make Reservation"
{
    // TM1.09/TSA /20160301  CASE 235860 Sell event tickets in POS
    // TM1.12/TSA /20160407  CASE 230600 Added DAN Captions
    // TM1.17/TSA /20160930  CASE 253951 Added the drill down on the fields for access to changing the times
    // TM1.20/NPKNAV/20170331  CASE 269171 Transport TM1.20 - 31 March 2017
    // TM1.21/ANEN /20170406 CASE 271150 Aplying filter with to-date on adm. sch. entries when selecting schedule
    // TM1.21/TSA /20170503  CASE 267611 Adding possibility to change quantity on the line
    //                                    - page changed to work on temp rec (to remove the locking issues)
    //                                    - the AquireTicketAdmissionSchedule function in 6060117 handles the actual change.
    //                                    - new function SetToken
    // TM1.22/TSA /20170526  CASE 278142 Added fields Customer No. and Payment Option visible for Ticket Batch Create Mode
    // TM1.23/TSA /20170703  CASE 282137 Cancelled lines must be respected when handling override capacity
    // TM1.28/TSA /20180220  CASE 305707 Added func SetTicketItem to be able to show ticket calendar exceptions
    // TM1.33/TSA /20180528 CASE 316195 Place cursor on first record in event selection
    // TM1.38/TSA /20181012 CASE 332109 Added Deliver Ticket To field
    // TM1.38/TSA /20181018 CASE 331917 Changed PageType on page 6060112
    // TM1.38.01/TSA /20181012 CASE 332109 Missplaced code section
    // TM1.39/TS  /20181206 CASE 343939 Added Missing Picture to Action
    // TM1.42/ALST/20190718 CASE 362158 made the page of type list to be compatible with mobile app
    // TM1.43/ALST/20191015 CASE 362158 reverted 1.42, page is now back to worksheet
    // TM1.44/ALST/20191016 CASE 362158 made the page of type listPlus to be compatible with mobile app and avoid extra click situation on open
    // TM1.45/TSA /20191112 CASE 322432 Seating capacity
    // TM1.45/TSA /20191126 CASE 379541 Detecting change to reservation when customer no and external reference changes
    // TM1.45/TSA /20200114 CASE 380754 Waitinglist, Added Time Overlap confirmation
    // TM1.45/TSA /20200114 CASE 382535 Dynamic Admission
    // TM90.1.46/TSA /20200123 CASE 386850 Added SetIgnoreScheduleSelectionFilter() to show all schedules rather then applying the POS schedule filter
    // TM90.1.46/TSA /20200127 CASE 387138 Ticket Server - show eTicket notification address field
    // TM90.1.46/TSA /20200304 CASE 399138 Make sure deliver-to field is displayed when allocation changes to waitinglist
    // TM1.47/TSA/20200611  CASE 382535-01 Transport TM1.47 - 11 June 2020
    // TM1.48/TSA /20200629 CASE 411704 Changed from GetAdmissionCapacity() to GetTicketCapacity()
    // TM1.48/TSA /20200630 CASE 412015 Changed dialog type from ListPlus to StandardDialog (for operation on mobile devices)

    Caption = 'Make your reservation';
    DataCaptionExpression = StrSubstNo('%1  - %2', Today, Time);
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = StandardDialog;
    SourceTable = "TM Ticket Reservation Request";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Item Code"; "External Item Code")
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;

                    trigger OnValidate()
                    begin

                        //-TM1.45 [379541]
                        gReservationEdited := true;
                        //+TM1.45 [379541]
                    end;
                }
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;

                    trigger OnDrillDown()
                    begin

                        SelectSchedule();
                        CurrPage.Update(false);
                    end;
                }
                field("Scheduled Time Description"; "Scheduled Time Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;

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
                field("Admission Description"; "Admission Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;

                    trigger OnDrillDown()
                    begin
                        SelectSchedule();
                        CurrPage.Update(false);
                    end;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    Editable = gAllowQuantityChange;
                    Style = Unfavorable;
                    StyleExpr = gVisualQueueUnfavorable;

                    trigger OnValidate()
                    var
                        TicketRequestManager: Codeunit "TM Ticket Request Manager";
                        ResponseMessage: Text;
                    begin

                        //-TM1.45 [382535]
                        if ("Admission Inclusion" = "Admission Inclusion"::NOT_SELECTED) then
                            Error(QTY_NOT_EDITABLE);
                        //+TM1.45 [382535]

                        if (Quantity < 1) then
                            Error(QTY_MUST_BE_GT_ZERO);

                        if (xRec.Quantity <> Quantity) then
                            ChangeQuantity(Quantity);

                        CurrPage.Update(false);
                    end;
                }
                field("Admission Inclusion"; "Admission Inclusion")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        CurrentEntryNo: Integer;
                        CommonQty: Integer;
                    begin

                        //-TM1.45 [382535] Required is a system option that cant be changed by user
                        if (xRec."Admission Inclusion" = xRec."Admission Inclusion"::REQUIRED) then
                            Error(NOT_EDITABLE, FieldCaption("Admission Inclusion"));

                        if (Rec."Admission Inclusion" = Rec."Admission Inclusion"::REQUIRED) then
                            Error(NOT_EDITABLE, FieldCaption("Admission Inclusion"));

                        if (xRec."Admission Inclusion" <> xRec."Admission Inclusion"::REQUIRED) and (Rec."Admission Inclusion" = Rec."Admission Inclusion"::REQUIRED) then
                            Error(NOT_REQUIRED, FieldCaption("Admission Inclusion"));

                        // User can set either Selected or Not Selected
                        if (xRec."Admission Inclusion" = xRec."Admission Inclusion"::NOT_SELECTED) and (Rec."Admission Inclusion" <> xRec."Admission Inclusion") then begin
                            CurrentEntryNo := Rec."Entry No.";
                            Rec.SetFilter(Quantity, '<>%1', 0);
                            if (Rec.FindFirst()) then
                                CommonQty := Rec.Quantity;
                            Rec.Reset;
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
                        //+TM1.45 [382535]
                    end;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Visible = gBatchTicketCreateMode;

                    trigger OnValidate()
                    begin

                        ModifyAll("Customer No.", "Customer No.");
                        CurrPage.Update(false);

                        //-TM1.45 [379541]
                        gReservationEdited := true;
                        //+TM1.45 [379541]
                    end;
                }
                field("External Order No."; "External Order No.")
                {
                    ApplicationArea = All;
                    Visible = gBatchTicketCreateMode;

                    trigger OnValidate()
                    begin

                        ModifyAll("External Order No.", "External Order No.");
                        CurrPage.Update(false);

                        //-TM1.45 [379541]
                        gReservationEdited := true;
                        //+TM1.45 [379541]
                    end;
                }
                field("Payment Option"; "Payment Option")
                {
                    ApplicationArea = All;
                    Visible = false;

                    trigger OnValidate()
                    begin

                        ModifyAll("Payment Option", "Payment Option");
                        CurrPage.Update(false);

                        //-TM1.45 [379541]
                        gReservationEdited := true;
                        //+TM1.45 [379541]
                    end;
                }
                field("Waiting List Reference Code"; "Waiting List Reference Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
                        TicketWaitingList: Record "TM Ticket Waiting List";
                        WaitingListSetup: Record "TM Waiting List Setup";
                        TicketWaitingListMgr: Codeunit "TM Ticket Waiting List Mgr.";
                        ResponseMessage: Text;
                        Admission: Record "TM Admission";
                    begin

                        //-TM1.45 [380754]
                        if ("Waiting List Reference Code" <> '') then
                            if (not TicketWaitingListMgr.GetWaitingListAdmSchEntry("Waiting List Reference Code", CreateDateTime(Today, Time), false, AdmissionScheduleEntry, TicketWaitingList, ResponseMessage)) then
                                Error(ResponseMessage);

                        if ("Waiting List Reference Code" = '') then begin
                            "External Adm. Sch. Entry No." := -1;
                            "Scheduled Time Description" := '';

                        end else begin
                            Admission.Get("Admission Code");
                            WaitingListSetup.Get(Admission."Waiting List Setup Code");

                            if (WaitingListSetup."Enforce Same Item") then begin
                                TestField("Item No.", TicketWaitingList."Item No.");
                                TestField("Variant Code", TicketWaitingList."Variant Code");
                            end;

                            Validate(Quantity, TicketWaitingList.Quantity);
                            "External Adm. Sch. Entry No." := AdmissionScheduleEntry."External Schedule Entry No.";
                            "Scheduled Time Description" := StrSubstNo('%1 - %2', AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
                            if (gDeliverTicketTo = '') then
                                gDeliverTicketTo := TicketWaitingList."Notification Address";

                        end;

                        Modify();
                        gReservationEdited := true;
                        CurrPage.Update(false);

                        CalcVisualQueueUnfavorable(Rec);
                        //+TM1.45 [380754]
                    end;
                }
            }
            group(Control6014406)
            {
                //The GridLayout property is only supported on controls of type Grid
                //GridLayout = Columns;
                ShowCaption = false;
                Visible = gShowDeliverTo;
                field(gDeliverTicketTo; gDeliverTicketTo)
                {
                    ApplicationArea = All;
                    Caption = 'Deliver eTicket To';
                }
            }
            group(Control6014400)
            {
                ShowCaption = false;
                field(gConfirmStatusText; gConfirmStatusText)
                {
                    ApplicationArea = All;
                    Caption = 'Reservation Confirm Status';
                    Enabled = false;
                    Style = Favorable;
                    StyleExpr = gConfirmStatusStyleFavorable;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Select Schedule")
            {
                Caption = 'Select Schedule';
                Image = ChangeDate;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    SelectSchedule();
                    CurrPage.Update(false);
                end;
            }
            action("Update Schedule")
            {
                Caption = 'Update Schedule';
                Image = "Action";

                trigger OnAction()
                var
                    AdmissionSchManagement: Codeunit "TM Admission Sch. Management";
                begin
                    AdmissionSchManagement.CreateAdmissionSchedule("Admission Code", false, Today);
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
    end;

    trigger OnModifyRecord(): Boolean
    begin

        //-TM1.47 [382535]
        //IF ("Admission Created") THEN
        //  ERROR ('Confirmed admissions can not be altered.');
        if (("Request Status" = "Request Status"::CONFIRMED) and ("Admission Created")) then
            Error('Confirmed admissions can not be altered.');
        //+TM1.47 [382535]
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin

        if (CloseAction = ACTION::LookupOK) then begin

            if (gBatchTicketCreateMode) then
                if ("Payment Option" <> "Payment Option"::DIRECT) then begin
                    TestField("External Order No.");
                    TestField("Customer No.");
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
        gRequestToken: Text[100];
        STATUS_CONFIRMED: Label 'The reservation is confirmed.';
        STATUS_UNCONFIRMED: Label 'Ticket is unconfirmed. Press OK to confirm new reservation.';
        QTY_MUST_BE_GT_ZERO: Label 'Ticket quantity must be greater than zero.';
        gBatchTicketCreateMode: Boolean;
        gTicketItemNo: Code[20];
        gTicketVariantCode: Code[10];
        gDeliverTicketTo: Text;
        gShowDeliverTo: Boolean;
        WAITING_LIST: Label 'Waiting List';
        gAddToWaitingList: Boolean;
        NO_NOTIFICATION_ADDR: Label 'When you have selected a ticket schedule with waiting list, you need to provide e-mail or sms in the deliver-to field.';
        gLimitToDateSelected: Date;
        DIFFERENT_DATES: Label 'The selected time schedules have different dates. This schedule is for %1 whereas the previous was for %2. Continue anyway?';
        DIFFERENT_DATES_WARNING: Label 'Please note that the selected time schedules have different dates.';
        QTY_NOT_EDITABLE: Label 'Quantity can not be changed for admissions that are not included.';
        NOT_EDITABLE: Label '%1 can not be changed when admission is required.';
        NOT_REQUIRED: Label '%1 can not be chanegd to required when intial value was optional.';
        gIgnoreScheduleFilter: Boolean;

    local procedure ChangeQuantity(NewQuantity: Integer)
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ResponseMessage: Text;
        CurrentEntryNo: Integer;
    begin

        CurrentEntryNo := Rec."Entry No.";

        gReservationEdited := true;
        gQuantityChanged := true;


        Rec.Reset();
        ModifyAll(Quantity, NewQuantity);

        Rec.SetFilter("Admission Inclusion", '=%1', Rec."Admission Inclusion"::NOT_SELECTED);
        ModifyAll(Quantity, 0);

        Rec.Reset();
        Rec.Get(CurrentEntryNo);
    end;

    local procedure SelectSchedule()
    var
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TMAdmission: Record "TM Admission";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        TicketWaitingListMgr: Codeunit "TM Ticket Waiting List Mgr.";
        PageScheduleEntry: Page "TM Ticket Select Schedule";
        PageAction: Action;
        OldEntryNo: Integer;
        ResponseMessage: Text;
        "0DF": DateFormula;
        ToDate: Date;
    begin

        //AdmissionScheduleEntry.FILTERGROUP (2);
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', "Admission Code");
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '>=%1', Today);
        AdmissionScheduleEntry.SetFilter("Admission Is", '=%1', AdmissionScheduleEntry."Admission Is"::OPEN);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

        //-TM1.21
        //Selecting end range for from-date
        if TMAdmission.Get("Admission Code") then begin
            if (TMAdmission."POS Schedule Selection Date F." <> "0DF") then begin
                ToDate := CalcDate(TMAdmission."POS Schedule Selection Date F.", Today);

                //-TM90.1.46 [386850]
                // 31041AdmissionScheduleEntry.SETRANGE ("Admission Start Date", TODAY, ToDate);
                if (not gIgnoreScheduleFilter) then
                    AdmissionScheduleEntry.SetRange("Admission Start Date", Today, ToDate);
                //+TM90.1.46 [386850]

            end;
        end;
        //-TM1.21

        Clear(PageScheduleEntry);
        PageScheduleEntry.FillPage(AdmissionScheduleEntry, Quantity, gTicketItemNo, gTicketVariantCode);
        PageScheduleEntry.LookupMode(true);
        PageAction := PageScheduleEntry.RunModal();

        //-TM1.38 [331917]
        //IF (PageAction = ACTION::Yes) THEN BEGIN
        if ((PageAction = ACTION::Yes) or (PageAction = ACTION::LookupOK)) then begin
            //+TM1.38 [331917]
            OldEntryNo := "External Adm. Sch. Entry No.";
            PageScheduleEntry.GetRecord(AdmissionScheduleEntry);

            "External Adm. Sch. Entry No." := AdmissionScheduleEntry."External Schedule Entry No.";
            "Scheduled Time Description" := StrSubstNo('%1 - %2', AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");

            //-TM1.45 [380754]
            if (AdmissionScheduleEntry."Allocation By" = AdmissionScheduleEntry."Allocation By"::WAITINGLIST) then begin
                "Scheduled Time Description" := StrSubstNo('%1', WAITING_LIST);
                //-TM90.1.46 [399138]
                gShowDeliverTo := true;
                //+TM90.1.46 [399138]
            end;

            if (gLimitToDateSelected = 0D) then
                gLimitToDateSelected := AdmissionScheduleEntry."Admission Start Date";

            if (gLimitToDateSelected <> 0D) then
                if (gLimitToDateSelected <> AdmissionScheduleEntry."Admission Start Date") then begin
                    if (not Confirm(DIFFERENT_DATES, false, AdmissionScheduleEntry."Admission Start Date", gLimitToDateSelected)) then
                        Error('');
                    gLimitToDateSelected := AdmissionScheduleEntry."Admission Start Date";
                end;
            //+TM1.45 [380754]

            Modify();

            //-#380754 [380754]
            ConfirmOverlappingTimes(Rec."Entry No.", Rec."External Adm. Sch. Entry No.");
            //+#380754 [380754]

            if (OldEntryNo <> "External Adm. Sch. Entry No.") then begin
                gReservationEdited := true;

                //    TicketRequestManager.DeleteReservationRequest (Rec."Session Token ID", FALSE);
                //    TicketRequestManager.IssueTicketFromReservationToken (Rec."Session Token ID", TRUE, ResponseMessage);
            end;

        end else begin
            // "External Adm. Sch. Entry No." := 0;
            // "Scheduled Time Description" := '';
        end;
    end;

    local procedure CalcVisualQueueUnfavorable(TicketReservationRequest: Record "TM Ticket Reservation Request"): Boolean
    var
        AdmissionSchEntry: Record "TM Admission Schedule Entry";
        Admission: Record "TM Admission";
        ScheduleLine: Record "TM Admission Schedule Lines";
        TicketManagement: Codeunit "TM Ticket Management";
        CapacityControl: Option;
        MaxCapacity: Integer;
        Remaining: Integer;
        ResponseMessage: Text;
    begin

        gConfirmStatusText := '';

        if (TicketReservationRequest."External Adm. Sch. Entry No." <= 0) then
            exit(true);

        if (TicketReservationRequest."External Adm. Sch. Entry No." > 0) then begin
            AdmissionSchEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest."External Adm. Sch. Entry No.");
            //-TM1.23 [282137]
            AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);
            //+TM1.23 [282137]

            if (AdmissionSchEntry.FindFirst()) then begin
                AdmissionSchEntry.CalcFields("Open Reservations", "Open Admitted", "Initial Entry");
                ScheduleLine.Get(AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code");

                //-TM1.28 [305707]
                if (TicketManagement.CheckTicketBaseCalendar(false, TicketReservationRequest."Admission Code", gTicketItemNo, gTicketVariantCode, AdmissionSchEntry."Admission Start Date", ResponseMessage) <> 0) then begin
                    gConfirmStatusText := ResponseMessage;
                    exit(true);
                end;
                //+TM1.28 [305707]


                //-TM1.20 [269171]
                //-TM1.48 [411704]
                //TicketManagement.GetAdmissionCapacity (AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code", AdmissionSchEntry."Entry No.", MaxCapacity, CapacityControl);
                TicketManagement.GetTicketCapacity(gTicketItemNo, gTicketVariantCode, AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code", AdmissionSchEntry."Entry No.", MaxCapacity, CapacityControl);
                //+TM1.48 [411704]

                case CapacityControl of
                    Admission."Capacity Control"::ADMITTED:
                        Remaining := MaxCapacity - AdmissionSchEntry."Open Admitted" - AdmissionSchEntry."Open Reservations";
                    Admission."Capacity Control"::FULL:
                        Remaining := MaxCapacity - AdmissionSchEntry."Open Admitted" - AdmissionSchEntry."Open Reservations";
                    Admission."Capacity Control"::NONE:
                        exit(false);
                    Admission."Capacity Control"::SALES:
                        Remaining := MaxCapacity - AdmissionSchEntry."Initial Entry";
                    //-TM1.45 [322432]
                    Admission."Capacity Control"::SEATING:
                        Remaining := MaxCapacity - AdmissionSchEntry."Open Admitted" - AdmissionSchEntry."Open Reservations";
                //+TM1.45 [322432]
                end;

                //IF ((ScheduleLine."Max Capacity Per Sch. Entry" - AdmissionSchEntry."Open Reservations" - AdmissionSchEntry."Open Admitted") < TicketReservationRequest.Quantity) THEN
                //  EXIT (TRUE);
                exit(Remaining < TicketReservationRequest.Quantity);
                //+TM1.20 [269171]
            end;
        end;

        exit(false);
    end;

    procedure LoadTicketRequest(Token: Text[100])
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
        ShowDifferentDatesWarning: Boolean;
    begin

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            //-TM1.38 [332109]
            gDeliverTicketTo := TicketReservationRequest."Notification Address";
            //+TM1.38 [332109]

            repeat
                TransferFields(TicketReservationRequest, true);
                Insert();

                //-TM1.45 [380754]
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
            //+TM1.45 [380754]

            until (TicketReservationRequest.Next() = 0);
        end;
        gReservationEdited := false;
        gBatchTicketCreateMode := (Rec."Payment Option" <> Rec."Payment Option"::DIRECT);

        //-TM1.45 [380754]
        if (ShowDifferentDatesWarning) then
            Message(DIFFERENT_DATES_WARNING, AdmissionScheduleEntry."Admission Start Date", gLimitToDateSelected);
        //+TM1.45 [380754]
    end;

    procedure SetTicketItem(ItemNo: Code[20]; VariantCode: Code[10])
    var
        Item: Record Item;
        TicketType: Record "TM Ticket Type";
        TicketBOM: Record "TM Ticket Admission BOM";
    begin
        gTicketItemNo := ItemNo;
        gTicketVariantCode := VariantCode;

        //-TM1.38 [332109]
        if (Item.Get(ItemNo)) then
            if (TicketType.Get(Item."Ticket Type")) then
                gShowDeliverTo := TicketType."eTicket Activated";
        //+TM1.38 [332109]

        //-TM90.1.46 [387138]
        TicketBOM.SetFilter("Item No.", '=%1', ItemNo);
        TicketBOM.SetFilter("Publish Ticket URL", '<>%1', TicketBOM."Publish Ticket URL"::DISABLE);
        if (not gShowDeliverTo) then
            gShowDeliverTo := TicketBOM.FindFirst();
        //+TM90.1.46 [387138]
    end;

    procedure AllowQuantityChange(AllowQuantityChange: Boolean)
    begin
        gAllowQuantityChange := AllowQuantityChange;
    end;

    procedure FinalizeReservationRequest(FailWithError: Boolean; var ResponseMessage: Text): Integer
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketBOM: Record "TM Ticket Admission BOM";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        TicketWaitingListMgr: Codeunit "TM Ticket Waiting List Mgr.";
    begin

        //-TM1.38 [332109]
        if (gDeliverTicketTo <> '') then begin
            Rec.Reset;
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
        //+TM1.38 [332109]

        //-TM1.45 [380754]
        Rec.Reset;
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
        //-TM1.45 [380754]

        if (gReservationEdited) then begin
            //TicketRequestManager.DeleteReservationRequest (Rec."Session Token ID", FALSE);

            Rec.Reset;
            if (Rec.FindFirst()) then; //+-TM1.33 [316195]
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

                //-TM1.47 [382535]
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
                //-TM1.47 [382535]

                TicketReservationRequest."Waiting List Reference Code" := Rec."Waiting List Reference Code"; //-+TM1.45 [380754]
                TicketReservationRequest."Admission Inclusion" := Rec."Admission Inclusion"; //-+TM1.45 [382535]

                //-TM1.45 [382535]
                //TicketReservationRequest.MODIFY ();
                if (not TicketReservationRequest."Admission Created") then
                    TicketReservationRequest.Modify();
            //+TM1.45 [382535]

            until (Rec.Next() = 0);
            TicketRequestManager.SetShowProgressBar(gBatchTicketCreateMode);
            exit(TicketRequestManager.IssueTicketFromReservationToken(Rec."Session Token ID", FailWithError, ResponseMessage));
        end;

        exit(0);
    end;

    procedure GetChangedTicketQuantity(var NewQuantity: Integer) QtyChanged: Boolean
    begin

        if (Rec.FindFirst()) then
            NewQuantity := Rec.Quantity;

        exit(gQuantityChanged);
    end;

    procedure SetTicketBatchMode()
    begin
        gBatchTicketCreateMode := true;
    end;

    local procedure ConfirmOverlappingTimes(SelectedRequestEntryNo: Integer; SelectedExternaAdmSchEntryNo: Integer)
    var
        AdmissionScheduleEntry1: Record "TM Admission Schedule Entry";
        AdmissionScheduleEntry2: Record "TM Admission Schedule Entry";
        Admission: Record "TM Admission";
        TimeOverlapIssue: Boolean;
    begin

        //-#380754 [380754]
        AdmissionScheduleEntry1.SetFilter("External Schedule Entry No.", '=%1', SelectedExternaAdmSchEntryNo);
        AdmissionScheduleEntry1.SetFilter(Cancelled, '=%1', false);
        AdmissionScheduleEntry1.FindFirst();
        Admission.Get(AdmissionScheduleEntry1."Admission Code");
        if (Admission.Type = Admission.Type::LOCATION) then
            exit;

        Rec.Reset();
        Rec.FindSet();
        repeat
            TimeOverlapIssue := false;

            if (Rec."External Adm. Sch. Entry No." <> SelectedExternaAdmSchEntryNo) then begin
                if (Rec."External Adm. Sch. Entry No." <> 0) then begin
                    AdmissionScheduleEntry2.SetFilter("External Schedule Entry No.", '=%1', Rec."External Adm. Sch. Entry No.");
                    AdmissionScheduleEntry2.SetFilter(Cancelled, '=%1', false);
                    AdmissionScheduleEntry2.FindFirst();
                    Admission.Get(AdmissionScheduleEntry2."Admission Code");
                    if ((AdmissionScheduleEntry1."Admission Start Date" = AdmissionScheduleEntry2."Admission Start Date") and
                        (Admission.Type = Admission.Type::OCCASION)) then
                        TimeOverlapIssue := (((AdmissionScheduleEntry1."Admission Start Time" >= AdmissionScheduleEntry2."Admission Start Time") and
                                              (AdmissionScheduleEntry1."Admission Start Time" <= AdmissionScheduleEntry2."Admission End Time")) or
                                             ((AdmissionScheduleEntry1."Admission End Time" >= AdmissionScheduleEntry2."Admission Start Time") and
                                              (AdmissionScheduleEntry1."Admission End Time" <= AdmissionScheduleEntry2."Admission End Time")));

                end;
            end;

        until ((Rec.Next() = 0) or TimeOverlapIssue);

        Rec.Get(SelectedRequestEntryNo);

        if (TimeOverlapIssue) then
            if (not Confirm('Your selected time %1 for %2 seems to overlap with your time selection for %3 at %4. Do you want to continue anyway?', false,
               AdmissionScheduleEntry1."Admission Start Time", AdmissionScheduleEntry1."Admission Code",
               AdmissionScheduleEntry2."Admission Code", AdmissionScheduleEntry2."Admission Start Time")) then
                Error('');

        //+#380754 [380754]
    end;

    procedure SetIgnoreScheduleSelectionFilter(IgnoreFilter: Boolean): Boolean
    begin

        //-TM90.1.46 [386850]
        gIgnoreScheduleFilter := IgnoreFilter;
        exit(gIgnoreScheduleFilter);

        //+TM90.1.46 [386850]
    end;
}

