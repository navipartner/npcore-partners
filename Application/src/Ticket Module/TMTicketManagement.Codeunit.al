codeunit 6059784 "NPR TM Ticket Management"
{
    var
        Text6059776: Label 'This value must be an integer between 1 and 4.';

        UNSUPPORTED_VALIDATION_METHOD: Label 'Unsupported Ticket Entry Validation Method.';
        INVALID_REFERENCE: Label 'Invalid %1 %2';
        REFERENCE: Label 'reference';
        UNEXPECTED: Label 'Houston, we have a problem. %1.%2 [%3] <> %4.%5 [%6]';
        RESERVATION_NOT_FOUND: Label 'The required reservation for ticket %1 and %2 was not found.';
        NOT_VALID: Label 'Ticket %1 is not valid for %2.';
        CAPACITY_EXCEEDED: Label 'The capacity for %1 has been exceeded. Entry is not allowed.';
        CONCURRENT_CAPACITY_EXCEEDED: Label 'The concurrent capacity for group %1 has been exceeded. Entry is not allowed.';
        RESERVATION_MISMATCH: Label 'Your reservation is not for the current event.';
        RESERVATION_NOT_FOR_TODAY: Label 'Your reservation seem not to be valid for the current %1 event. Reservation entry is for %2 %3. ';
        CONF_RES_NOT_FOR_TODAY: Label 'Your reservation seem not to be valid for the current %1 event. Reservation entry is for %2 %3.\\Do you want to proceed with the current action anyway? ';
        RESERVATION_EXCEEDED: Label 'The reservation capacity for %1 at %2 has been exceeded. A maximum of %3 with method %4 is permitted. This action would make it %5.';
        GREATER_THAN: Label '%1 must be greater than %2';
        ADM_NOT_OPEN: Label 'Admission code %1 does not have a schedule that is open for date %2';
        ADM_NOT_OPEN_ENTRY: Label 'Admission code %1 does not have a schedule that is open for entry %2';
        NOT_CONFIRMED: Label 'Ticket %1 has not been confirmed.';
        MISSING_PAYMENT: Label 'Ticket %1 is missing the payment transaction.';
        TICKET_CANCELED: Label 'Ticket %1 has been canceled and is not valid.';
        ADMISSION_MISMATCH: Label 'The Schedule Entry %1 is for admission to %2, but the Ticket Access Entry requires %3.';
        NO_SCHEDULE_FOR_ADM: Label 'There is no valid admission schedule available for %1 today.';
        NO_ADMISSION_CODE: Label 'No admission code was specified and no admission code was marked as default for item %1.';
        TICKET_NOT_VALID_YET: Label 'Ticket %1 is not valid until %2.';
        TICKET_EXPIRED: Label 'Ticket %1 expired on %2.';
        SHOULD_NOT_BE_ZERO: Label 'Should not be zero.';
        QTY_CHANGE_NOT_ALLOWED: Label 'Ticket %1 has been used and quantity cannot be changed. %2 %3.';
        QTY_TOO_LARGE: Label 'The new ticket quantity cannot be greater than %1.';
        SCHEDULE_ENTRY_EXPIRED: Label 'The schedule entry %1 specifies a time in the past (%2) and cant be used for ticket reservation at this time (%3).';
        TICKET_CALENDAR: Label 'Ticket calendar defined for %1 %2 %3 states that ticket is not valid for %4.';
        RESERVATION_NOT_FOR_NOW: Label 'The ticket reservation for %4 allows admission from %1 until %2 on %3.\\Current time is: %5';
        RESCHEDULE_NOT_ALLOWED: Label 'The ticket reschedule policy for %1 and %2, prevents changes at this time.';
        NO_DEFAULT_ADMISSION_SELECTED: Label 'When ticket is scanned and no admission code is specified, system attempts to find a default admission. With current setup, a default admission could not be found for item %1.';
        INVALID_REFERENCE_NO: Label '-1001';
        RESERVATION_NOT_FOUND_NO: Label '-1002';
        NOT_VALID_NO: Label '-1003';
        CAPACITY_EXCEEDED_NO: Label '-1004';
        RESERVATION_MISMATCH_NO: Label '-1005';
        ADM_NOT_OPEN_NO: Label '-1008';
        ADM_NOT_OPEN_NO2: Label '-1009';
        NOT_CONFIRMED_NO: Label '-1010';
        RESERVATION_NOT_FOR_TODAY_NO: Label '-1014';
        RESERVATION_EXCEEDED_NO: Label '-1015';
        TICKET_CANCELED_NO: Label '-1016';
        TICKET_NOT_VALID_YET_NO: Label '-1017';
        TICKET_EXPIRED_NO: Label '-1018';
        QTY_CHANGE_NOT_ALLOWED_NO: Label '-1019';
        QTY_TOO_LARGE_NO: Label '-1020';
        NO_DEFAULT_SCHEDULE_NO: Label '-1021';
        MISSING_PAYMENT_NO: Label '-1022';
        SCHEDULE_ENTRY_EXPIRED_NO: Label '-1023';
        SCHEDULE_ENTRY_EXPIRED_NO2: Label '-1024';
        SCHEDULE_ENTRY_EXPIRED_NO3: Label '-1025';
        RESERVATION_NOT_FOR_NOW_NO: Label '-1028';
        CONCURRENT_CAPACITY_EXCEEDED_NO: Label '-1030';
        RESCHEDULE_NOT_ALLOWED_NO: Label '-1031';
        INVOICE_TEXT2: Label 'Admission on %1 {%2,...}';
        POSTPAID_RESULT: Label 'Number of postpaid tickets: %1\\Number of invoices: %2\\Invoices created: %3';
        gAccessEntryPaymentType: Option PAYMENT,PREPAID,POSTPAID;
        HANDLE_POSTPAID: Label 'Do you want to generate invoices for postpaid ticket?';
        HANDLE_POSTPAID_STATUS: Label '#1#################\@2@@@@@@@@@@@@@@@@@@';
        gWindow: Dialog;
        POSTPAID_COLLECT: Label 'Scanning ticket admissions...';
        POSTPAID_AGGREGATE: Label 'Aggregating...';
        POSTPAID_INVOICE: Label 'Creating invoices...';
        POSTPAID_UPDATING: Label 'Closing prepaid payments...';
        NO_DEFAULT_SCHEDULE: Label 'The ticket request did not specify a valid time-slot for admission %1 and the ticket rule is to get the default schedule. But there are currently no time-slots that matches %2 "%3".';
        WORKFLOW_DESC: Label 'Print Ticket';

        _TicketExecutionContext: Option SALES,ADMISSION;

    [EventSubscriber(ObjectType::"Codeunit", Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSSalesLine', '', true, true)]
    local procedure IssueTicketsFromPosEntrySaleLine(POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        Token: Text[100];
    begin
        if (not (GetReceiptRequestToken(POSEntry."Document No.", POSSalesLine."Line No.", Token))) then
            exit;

        IssueTicketsFromToken(Token, POSEntry."Document No.", POSSalesLine."Line No.", POSEntry."POS Unit No.");
    end;

    procedure IssueTicketsFromToken(Token: Text[100]; SalesReceiptNo: Code[20]; SalesLineNo: Integer; PosUnitNo: Code[10])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketType: Record "NPR TM Ticket Type";
        Ticket: Record "NPR TM Ticket";
        ResponseMessage: Text;
        IsCheckedBySubscriber: Boolean;
        IsValid: Boolean;
    begin

        if (TicketRequestManager.IsReservationRequest(Token)) then begin
            TicketRequestManager.ConfirmReservationRequestWithValidate(Token);

            Ticket.Reset();
            Ticket.SetCurrentKey("Sales Receipt No.");
            Ticket.SetFilter("Sales Receipt No.", '=%1', SalesReceiptNo);
            Ticket.SetFilter("Line No.", '=%1', SalesLineNo);
            if (Ticket.FindSet()) then begin
                repeat

                    if (TicketType.Get(Ticket."Ticket Type Code")) then begin

                        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_TYPE) then begin
                            if (TicketType."Activation Method" = TicketType."Activation Method"::POS_DEFAULT) then
                                RegisterDefaultAdmissionArrivalOnPosSales(Ticket);

                            if (TicketType."Activation Method" = TicketType."Activation Method"::POS_ALL) then
                                RegisterAllAdmissionArrivalOnPosSales(Ticket);
                        end;

                        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then
                            RegisterTicketBomAdmissionArrival(Ticket, PosUnitNo, 0);

                    end;
                until (Ticket.Next() = 0);

                OnAfterPosTicketArrival(IsCheckedBySubscriber, IsValid, Ticket."No.", Ticket."External Member Card No.", Token, ResponseMessage);
                if ((IsCheckedBySubscriber) and (not IsValid)) then
                    Error(ResponseMessage);

            end;
        end;

        if (TicketRequestManager.IsRevokeRequest(Token)) then begin
            TicketRequestManager.RevokeReservationTokenRequest(Token, false);

            OnAfterPosTicketRevoke(IsCheckedBySubscriber, IsValid, Token, ResponseMessage);

        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPosTicketArrival(var IsCheckedBySubscriber: Boolean; var IsValid: Boolean; TicketNumber: Code[20]; TicketExternalMemberReference: Code[20]; Token: Text[100]; var ResponseMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPosTicketRevoke(var IsCheckedBySubscriber: Boolean; var IsValid: Boolean; Token: Text[100]; var ResponseMessage: Text)
    begin
    end;

    procedure PrintTicketFromSalesTicketNo(SalesTicketNo: Code[20])
    var
        Ticket: Record "NPR TM Ticket";
        Ticket2: Record "NPR TM Ticket";
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketDIYTicketPrint: Codeunit "NPR TM Ticket DIY Ticket Print";
        ResponseMessage: Text;
        PrintTicket: Boolean;
        PublishError: Boolean;
    begin

        Ticket.SetCurrentKey("Sales Receipt No.");
        Ticket.SetRange("Sales Receipt No.", SalesTicketNo);

        if (Ticket.IsEmpty()) then
            exit;

        Ticket.FindSet();
        repeat

            PrintTicket := true;

            if (TicketRequestManager.IsETicket(Ticket."No.")) then begin
                TicketSetup.Get();

                if (TicketRequestManager.CreateAndSendETicket(Ticket."No.", ResponseMessage)) then begin
                    PrintTicket := not TicketSetup."Suppress Print When eTicket";
                end else begin
                    if (TicketSetup."Show Send Fail Message In POS") then
                        Message(ResponseMessage);
                end;
            end;

            if (TicketDIYTicketPrint.CheckPublishTicketUrl(Ticket."No.")) then begin
                TicketSetup.Get();

                PublishError := not TicketDIYTicketPrint.PublishTicketUrl(Ticket."No.", ResponseMessage);

                if (not PublishError) and (TicketDIYTicketPrint.CheckSendTicketUrl(Ticket."No.")) then
                    PublishError := not TicketDIYTicketPrint.SendTicketUrl(Ticket."No.", ResponseMessage);

                if (PublishError) then begin
                    if (TicketSetup."Show Send Fail Message In POS") then
                        Message(ResponseMessage);
                end else begin
                    PrintTicket := not TicketSetup."Suppress Print When eTicket";
                end;

            end;

            if (PrintTicket) then begin
                Ticket2.SetFilter("No.", '=%1', Ticket."No.");
                Ticket2.Get(Ticket."No.");
                if (PrintSingleTicket(Ticket2)) then;
            end;

        until (Ticket.Next() = 0);
    end;

    local procedure PrintTicketUsingFormatter(var Ticket: Record "NPR TM Ticket"; PrintObjectType: Option; PrintObjectId: Integer; PrintTemplateCode: Code[20]): Boolean
    var
        TicketType: Record "NPR TM Ticket Type";
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin

        case PrintObjectType of
            TicketType."Print Object Type"::Codeunit:
                begin
                    if (ObjectOutputMgt.GetCodeunitOutputPath(PrintObjectId) <> '') then
                        LinePrintMgt.ProcessCodeunit(PrintObjectId, Ticket)
                    else
                        Codeunit.Run(PrintObjectId, Ticket);
                end;

            TicketType."Print Object Type"::Report:
                ReportPrinterInterface.RunReport(PrintObjectId, false, false, Ticket);

            TicketType."Print Object Type"::TEMPLATE:
                PrintTemplateMgt.PrintTemplate(PrintTemplateCode, Ticket, 0);

            else
                exit(false);
        end;

        exit(true);
    end;

    procedure PrintSingleTicket(var Ticket: Record "NPR TM Ticket") Printed: Boolean
    var
        TicketType: Record "NPR TM Ticket Type";
    begin

        if (not TicketType.Get(Ticket."Ticket Type Code")) then
            exit(false);

        if (not TicketType."Print Ticket") then
            exit(false);

        Printed := PrintTicketUsingFormatter(Ticket, TicketType."Print Object Type", TicketType."Print Object ID", TicketType."RP Template Code");
        if (Printed) then begin
            Ticket."Printed Date" := Today();
            Ticket.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin

        if (Rec."Subscriber Codeunit ID" <> CurrentCodeunitId()) then
            exit;
        if (Rec."Subscriber Function" <> 'PrintTicketsOnSale') then
            exit;

        Rec.Description := WORKFLOW_DESC;
        Rec."Sequence No." := 120;
    end;

    local procedure CurrentCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR TM Ticket Management");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnFinishSale', '', true, true)]
    local procedure PrintTicketsOnSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    begin
        if (POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrentCodeunitId()) then
            exit;
        if (POSSalesWorkflowStep."Subscriber Function" <> 'PrintTicketsOnSale') then
            exit;

        PrintTicketFromSalesTicketNo(SalePOS."Sales Ticket No.");
    end;


    procedure AttemptValidateTicketForArrival(TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO; TicketIdentifier: Text[50]; AdmissionCode: Code[20]; AdmissionScheduleEntryNo: Integer; var ResponseMessage: Text): Boolean
    var
        AttemptTicket: Codeunit "NPR Ticket Attempt Create";
    begin
        exit(AttemptTicket.AttemptValidateTicketForArrival(TicketIdentifierType, TicketIdentifier, AdmissionCode, AdmissionScheduleEntryNo, ResponseMessage));
    end;

    procedure ValidateTicketForArrival(TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO; TicketIdentifier: Text[50]; AdmissionCode: Code[20]; AdmissionScheduleEntryNo: Integer)
    var
        Admission: Record "NPR TM Admission";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntryNo: Integer;
    begin

        if (not GetTicket(TicketIdentifierType, TicketIdentifier, Ticket)) then
            RaiseError(StrSubstNo(INVALID_REFERENCE, REFERENCE, TicketIdentifier), INVALID_REFERENCE_NO);

        if (AdmissionCode = '') then
            AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");

        if (not (Admission.Get(AdmissionCode))) then
            RaiseError(StrSubstNo(INVALID_REFERENCE, Admission.FieldName("Admission Code"), AdmissionCode), INVALID_REFERENCE_NO);

        ValidateTicketReference(TicketIdentifierType, TicketIdentifier, AdmissionCode, TicketAccessEntryNo);
        ValidateScheduleReference(TicketAccessEntryNo, AdmissionCode, AdmissionScheduleEntryNo);

        RegisterArrival_Worker(TicketAccessEntryNo, AdmissionScheduleEntryNo);

        ValidateAdmissionDependencies(TicketAccessEntryNo);

        ValidateTicketConstraintsExceeded(TicketAccessEntryNo);
        ValidateTicketAdmissionCapacityExceeded(Ticket, AdmissionScheduleEntryNo, _TicketExecutionContext::ADMISSION);

    end;

    procedure ValidateTicketForDeparture(TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO; TicketIdentifier: Text[50]; AdmissionCode: Code[20])
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin

        if (GetTicket(TicketIdentifierType, TicketIdentifier, Ticket)) then begin

            if (AdmissionCode = '') then
                AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");

            TicketAccessEntry.SetCurrentKey("Ticket No.", "Admission Code");
            TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
            TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            if (TicketAccessEntry.FindFirst()) then
                RegisterDeparture_Worker(TicketAccessEntry."Entry No.");
        end;

    end;

    procedure SetTicketProperties(var Ticket: Record "NPR TM Ticket"; ValidFromDate: Date)
    var
        TicketType: Record "NPR TM Ticket Type";
    begin

        TicketType.Get(Ticket."Ticket Type Code");
        Ticket."Valid From Date" := ValidFromDate;
        Ticket.TestField("Valid From Date");

        Ticket."Valid From Time" := 000000T;
        Ticket."Valid To Time" := 235959T;
        Ticket.Blocked := false;
        Ticket."Document Date" := Today();

        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then
            exit;

        case TicketType."Ticket Entry Validation" of
            TicketType."Ticket Entry Validation"::SINGLE,
            TicketType."Ticket Entry Validation"::SAME_DAY:
                begin
                    Ticket."Valid To Date" := Ticket."Valid From Date";
                    if (Format(TicketType."Duration Formula") <> '') then begin
                        Ticket."Valid To Date" := CalcDate(TicketType."Duration Formula", ValidFromDate);
                        if (Ticket."Valid To Date" < Ticket."Valid From Date") then
                            Error(GREATER_THAN, Ticket.FieldCaption("Valid To Date"), Ticket.FieldCaption("Valid From Date"));
                    end;
                end;

            TicketType."Ticket Entry Validation"::MULTIPLE:
                begin
                    TicketType.TestField("Duration Formula");
                    Ticket."Valid To Date" := CalcDate(TicketType."Duration Formula", ValidFromDate);
                    if (Ticket."Valid To Date" < Ticket."Valid From Date") then
                        Error(GREATER_THAN, Ticket.FieldCaption("Valid To Date"), Ticket.FieldCaption("Valid From Date"));
                end;
            else
                Error(UNSUPPORTED_VALIDATION_METHOD);
        end;
    end;

    procedure GetTicketAccessEntryValidDateBoundary(Ticket: Record "NPR TM Ticket"; var LowDate: Date; var HighDate: Date)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        LowDate := DMY2Date(31, 12, 9999);
        HighDate := 0D;

        // Each admission must only contribute with only one of its INITIAL_ENTRY or RESERVATION entries
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.SetLoadFields("Admission Code");
        if (TicketAccessEntry.FindSet()) then begin
            repeat
                if (TicketBom.Get(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code")) then begin
                    DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
                    DetTicketAccessEntry.SetFilter(Type, '=%1 | =%2', DetTicketAccessEntry.Type::INITIAL_ENTRY, DetTicketAccessEntry.Type::RESERVATION);
                    DetTicketAccessEntry.FindLast();

                    AdmissionScheduleEntry.SetCurrentKey("External Schedule Entry No.");
                    AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
                    AdmissionScheduleEntry.FindFirst();

                    if (AdmissionScheduleEntry."Admission Start Date" < LowDate) then
                        LowDate := AdmissionScheduleEntry."Admission Start Date";

                    if (Format(TicketBom."Duration Formula") <> '') then
                        if (CalcDate(TicketBom."Duration Formula", AdmissionScheduleEntry."Admission Start Date") > HighDate) then
                            HighDate := CalcDate(TicketBom."Duration Formula", AdmissionScheduleEntry."Admission Start Date");

                    if (AdmissionScheduleEntry."Admission End Date" > HighDate) then
                        HighDate := AdmissionScheduleEntry."Admission End Date";

                end;
            until (TicketAccessEntry.Next() = 0);
        end;

    end;

    procedure CreateAdmissionAccessEntry(Ticket: Record "NPR TM Ticket"; TicketQty: Integer; AdmissionCode: Code[20]; AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry")
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketType: Record "NPR TM Ticket Type";
        Admission: Record "NPR TM Admission";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        MaxCapacity: Integer;
        CapacityControl: Option;
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin

        if (TicketQty <= 0) then
            exit;

        Admission.Get(AdmissionCode);
        TicketType.Get(Ticket."Ticket Type Code");


        if (AdmissionSchEntry."Entry No." <= 0) then begin
            case GetAdmissionSchedule(Ticket."Item No.", Ticket."Variant Code", AdmissionCode) of
                Admission."Default Schedule"::TODAY,
              Admission."Default Schedule"::NEXT_AVAILABLE:

                    if (not AdmissionSchEntry.Get(GetCurrentScheduleEntry(Ticket, Admission."Admission Code", true))) then
                        RaiseError(StrSubstNo(NO_DEFAULT_SCHEDULE, Admission."Admission Code", Admission.FieldCaption("Default Schedule"), Admission."Default Schedule"), NO_DEFAULT_SCHEDULE_NO);
            end;
        end else begin

            if (IsSelectedAdmissionSchEntryExpired(AdmissionSchEntry, Today, Time, ResponseMessage, ResponseCode)) then
                RaiseError(ResponseMessage, Format(ResponseCode, 0, 9));

        end;

        TicketAccessEntry.Init();
        TicketAccessEntry."Entry No." := 0;
        TicketAccessEntry."Ticket No." := Ticket."No.";
        TicketAccessEntry."Admission Code" := Admission."Admission Code";
        TicketAccessEntry."Ticket Type Code" := Ticket."Ticket Type Code";
        TicketAccessEntry.Description := CopyStr(Admission.Description, 1, MaxStrLen(TicketAccessEntry.Description));
        TicketAccessEntry.Status := TicketAccessEntry.Status::ACCESS;
        TicketAccessEntry.Quantity := TicketQty;
        TicketAccessEntry.Insert(true);

        DetailedTicketAccessEntry.Init();
        DetailedTicketAccessEntry."Entry No." := 0;
        DetailedTicketAccessEntry."Ticket No." := TicketAccessEntry."Ticket No.";
        DetailedTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";
        DetailedTicketAccessEntry.Type := DetailedTicketAccessEntry.Type::INITIAL_ENTRY;
        DetailedTicketAccessEntry."External Adm. Sch. Entry No." := AdmissionSchEntry."External Schedule Entry No.";
        DetailedTicketAccessEntry.Quantity := TicketAccessEntry.Quantity;
        DetailedTicketAccessEntry.Open := true;
        DetailedTicketAccessEntry.Insert(true);

        if (Admission.Type = Admission.Type::OCCASION) then begin
            RegisterReservation_Worker(Ticket, TicketAccessEntry."Entry No.", AdmissionSchEntry."Entry No.");
            ValidateReservationCapacityExceeded(Ticket, AdmissionSchEntry);
        end;

        if (GetAdmissionCapacity(AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code", AdmissionSchEntry."Entry No.", MaxCapacity, CapacityControl)) then
            if (CapacityControl = Admission."Capacity Control"::SALES) then
                ValidateTicketAdmissionCapacityExceeded(Ticket, AdmissionSchEntry."Entry No.", _TicketExecutionContext::SALES);

        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_TYPE) then
            ValidateTicketAdmissionCapacityExceeded(Ticket, AdmissionSchEntry."Entry No.", _TicketExecutionContext::SALES);

        ValidateTicketBaseCalendar(TicketAccessEntry."Admission Code", Ticket."Item No.", Ticket."Variant Code", AdmissionSchEntry."Admission Start Date");

    end;

    procedure RescheduleTicketAdmission(TicketNo: Code[20]; NewExtScheduleEntryNo: Integer; EnforceReschedulePolicy: Boolean; ReferenceDateTime: DateTime)
    var
        Ticket: Record "NPR TM Ticket";
        Admission: Record "NPR TM Admission";
        NewAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        OldDetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        NewDetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        CapacityControl: Option;
        MaxCapacity: Integer;
    begin

        Ticket.Get(TicketNo);

        NewAdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', NewExtScheduleEntryNo);
        NewAdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not NewAdmissionScheduleEntry.FindFirst()) then
            RaiseError(StrSubstNo(INVALID_REFERENCE, NewAdmissionScheduleEntry.TableCaption(), NewAdmissionScheduleEntry), '-2002');

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketAccessEntry.SetFilter("Admission Code", '=%1', NewAdmissionScheduleEntry."Admission Code");
        TicketAccessEntry.FindFirst();

        OldDetTicketAccessEntry.SetFilter(Type, '=%1', OldDetTicketAccessEntry.Type::INITIAL_ENTRY);
        OldDetTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type, Open, "Posting Date");
        OldDetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        OldDetTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
        OldDetTicketAccessEntry.FindLast();

        if (NewExtScheduleEntryNo = OldDetTicketAccessEntry."External Adm. Sch. Entry No.") then
            exit;

        if (EnforceReschedulePolicy) then
            if (not IsRescheduleAllowed(Ticket."External Ticket No.", OldDetTicketAccessEntry."External Adm. Sch. Entry No.", ReferenceDateTime)) then
                RaiseError(StrSubstNo(RESCHEDULE_NOT_ALLOWED, Ticket."Item No.", NewAdmissionScheduleEntry."Admission Code"), RESCHEDULE_NOT_ALLOWED_NO);

        NewDetTicketAccessEntry.TransferFields(OldDetTicketAccessEntry, false);

        // create a new initial entry for the new time
        NewDetTicketAccessEntry."Entry No." := 0;
        NewDetTicketAccessEntry."External Adm. Sch. Entry No." := NewExtScheduleEntryNo;
        NewDetTicketAccessEntry."Created Datetime" := CurrentDateTime();
        NewDetTicketAccessEntry.Insert();

        // reverse original initial entry
        NewDetTicketAccessEntry."Entry No." := 0;
        NewDetTicketAccessEntry."External Adm. Sch. Entry No." := OldDetTicketAccessEntry."External Adm. Sch. Entry No.";
        NewDetTicketAccessEntry.Quantity := OldDetTicketAccessEntry.Quantity * -1;
        NewDetTicketAccessEntry.Insert();

        // link original entry with reversal entry instead of payment entry
        OldDetTicketAccessEntry."Closed By Entry No." := NewDetTicketAccessEntry."Entry No.";
        OldDetTicketAccessEntry.Modify();

        Admission.Get(NewAdmissionScheduleEntry."Admission Code");
        if (Admission.Type = Admission.Type::OCCASION) then begin
            OldDetTicketAccessEntry.SetFilter(Type, '=%1', OldDetTicketAccessEntry.Type::RESERVATION);
            OldDetTicketAccessEntry.FindLast();

            OldDetTicketAccessEntry.Type := OldDetTicketAccessEntry.Type::CANCELED_RESERVATION;
            OldDetTicketAccessEntry."Closed By Entry No." := RegisterReservation_Worker(Ticket, TicketAccessEntry."Entry No.", NewAdmissionScheduleEntry."Entry No.");
            OldDetTicketAccessEntry.Open := false;
            OldDetTicketAccessEntry.Modify();

            ValidateReservationCapacityExceeded(Ticket, NewAdmissionScheduleEntry);

        end;

        if (GetAdmissionCapacity(NewAdmissionScheduleEntry."Admission Code", NewAdmissionScheduleEntry."Schedule Code", NewAdmissionScheduleEntry."Entry No.", MaxCapacity, CapacityControl)) then
            if (CapacityControl = Admission."Capacity Control"::SALES) then
                ValidateTicketAdmissionCapacityExceeded(Ticket, NewAdmissionScheduleEntry."Entry No.", _TicketExecutionContext::SALES);

        ValidateTicketAdmissionReservationDate(TicketAccessEntry."Entry No.", NewAdmissionScheduleEntry."Entry No.");

        ValidateTicketBaseCalendar(TicketAccessEntry."Admission Code", Ticket."Item No.", Ticket."Variant Code", NewAdmissionScheduleEntry."Admission Start Date");

    end;

    procedure IsRescheduleAllowed(ExternalTicketNumber: Text[30]; ExtAdmSchEntryNo: Integer; ReferenceDateTime: DateTime): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin

        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNumber);
        Ticket.SetFilter(Blocked, '=%1', false);
        if (not Ticket.FindFirst()) then
            exit(false);

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtAdmSchEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindFirst()) then
            exit(false);

        if (not TicketAdmissionBOM.Get(Ticket."Item No.", Ticket."Variant Code", AdmissionScheduleEntry."Admission Code")) then
            exit(false);

        case TicketAdmissionBOM."Reschedule Policy" of

            TicketAdmissionBOM."Reschedule Policy"::NOT_ALLOWED:
                exit(false);
            TicketAdmissionBOM."Reschedule Policy"::UNTIL_USED:
                begin
                    TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                    TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
                    TicketAccessEntry.SetFilter("Access Date", '=%1', 0D);
                    if (TicketAccessEntry.IsEmpty()) then
                        exit(false);

                    ReferenceDateTime := CurrentDateTime();
                    exit(not IsSelectedAdmissionSchEntryExpired(AdmissionScheduleEntry, DT2DATE(ReferenceDateTime), DT2TIME(ReferenceDateTime), ResponseMessage, ResponseCode));
                end;
            TicketAdmissionBOM."Reschedule Policy"::CUTOFF_HOUR:
                begin
                    TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                    TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
                    TicketAccessEntry.SetFilter("Access Date", '=%1', 0D);
                    if (TicketAccessEntry.IsEmpty()) then
                        exit(false);

                    ReferenceDateTime += TicketAdmissionBOM."Reschedule Cut-Off (Hours)" * 60 * 60 * 1000;
                    exit(not IsSelectedAdmissionSchEntryExpired(AdmissionScheduleEntry, DT2DATE(ReferenceDateTime), DT2TIME(ReferenceDateTime), ResponseMessage, ResponseCode));
                end;
        end;

        exit(false);

    end;

    local procedure IsSelectedAdmissionSchEntryExpired(AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry"; ReferenceDate: Date; ReferenceTime: Time; var ResponseMessage: Text; var ResponseCode: Integer): Boolean
    var
        DateTimeLbl: Label '%1  - %2', Locked = true;
    begin
        if (AdmissionSchEntry."Admission End Date" = ReferenceDate) then begin

            if ((AdmissionSchEntry."Event Arrival Until Time" = 0T) and
                (AdmissionSchEntry."Admission End Time" < ReferenceTime)) then begin
                ResponseMessage := StrSubstNo(SCHEDULE_ENTRY_EXPIRED,
                    AdmissionSchEntry."External Schedule Entry No.",
                    StrSubstNo(DateTimeLbl, Format(AdmissionSchEntry."Admission End Date", 0, 9), Format(AdmissionSchEntry."Admission Start Time", 0, 9)),
                    StrSubstNo(DateTimeLbl, Format(ReferenceDate, 0, 9), Format(ReferenceTime, 0, 9)));
                Evaluate(ResponseCode, SCHEDULE_ENTRY_EXPIRED_NO);
                exit(true);
            end;

            if ((AdmissionSchEntry."Event Arrival Until Time" <> 0T) and
                (AdmissionSchEntry."Event Arrival Until Time" < ReferenceTime)) then begin
                ResponseMessage := StrSubstNo(SCHEDULE_ENTRY_EXPIRED,
                    AdmissionSchEntry."External Schedule Entry No.",
                    StrSubstNo(DateTimeLbl, Format(AdmissionSchEntry."Admission End Date", 0, 9), Format(AdmissionSchEntry."Admission Start Time", 0, 9)),
                    StrSubstNo(DateTimeLbl, Format(ReferenceDate, 0, 9), Format(ReferenceTime, 0, 9)));
                Evaluate(ResponseCode, SCHEDULE_ENTRY_EXPIRED_NO2);
                exit(true);
            end;

        end;

        if (AdmissionSchEntry."Admission End Date" < ReferenceDate) then begin
            ResponseMessage := StrSubstNo(SCHEDULE_ENTRY_EXPIRED,
                AdmissionSchEntry."External Schedule Entry No.",
                StrSubstNo(DateTimeLbl, Format(AdmissionSchEntry."Admission End Date", 0, 9), Format(AdmissionSchEntry."Admission End Time", 0, 9)),
                StrSubstNo(DateTimeLbl, Format(ReferenceDate, 0, 9), Format(ReferenceTime, 0, 9)));
            Evaluate(ResponseCode, SCHEDULE_ENTRY_EXPIRED_NO3);
            exit(true);
        end;

        exit(false); // not expired

    end;

    procedure CreatePaymentEntry(Ticket: Record "NPR TM Ticket")
    var
        PaymentType: Option PAYMENT,PREPAID,POSTPAID;
    begin
        CreatePaymentEntryType(Ticket, PaymentType::PAYMENT, 'POS', '');
    end;

    procedure CreatePaymentEntryType(Ticket: Record "NPR TM Ticket"; PaymentType: Option PAYMENT,PREPAID,POSTPAID; PaymentReferenceNo: Code[20]; CustomerNo: Code[20])
    var
        AdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        Admission: Record "NPR TM Admission";
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
    begin

        AdmissionBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
        AdmissionBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        AdmissionBOM.FindSet();
        repeat
            Item.Get(Ticket."Item No.");
            TicketType.Get(Item."NPR Ticket Type");
            Admission.Get(AdmissionBOM."Admission Code");
            TicketAccessEntry.SetCurrentKey("Ticket No.", "Admission Code");
            TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
            TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionBOM."Admission Code");

            if (TicketAccessEntry.FindFirst()) then begin
                RegisterPayment_Worker(TicketAccessEntry."Entry No.", PaymentType, PaymentReferenceNo);

                if (CustomerNo <> '') then begin
                    TicketAccessEntry."Customer No." := CustomerNo;
                    TicketAccessEntry.Modify();
                end;

                NotifyParticipant.CreateAdmissionReservationReminder(TicketAccessEntry);

            end;

        until (AdmissionBOM.Next() = 0);
    end;

    procedure AttemptChangeConfirmedTicketQuantity(TicketNo: Code[20]; AdmissionCode: Code[20]; NewTicketQuantity: Integer; var ResponseMessage: Text): Boolean
    var
        AttemptTicket: Codeunit "NPR Ticket Attempt Create";
    begin
        exit(AttemptTicket.AttemptChangeConfirmedTicketQuantity(TicketNo, AdmissionCode, NewTicketQuantity, ResponseMessage));
    end;

    procedure ChangeConfirmedTicketQuantity(TicketNo: Code[20]; AdmissionCode: Code[20]; NewTicketQuantity: Integer)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketAccessEntryNo: Integer;
    begin

        ValidateTicketReference(0, TicketNo, AdmissionCode, TicketAccessEntryNo);

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        if (AdmissionCode <> '') then
            TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        TicketAccessEntry.FindSet();
        repeat
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
            if (DetTicketAccessEntry.FindFirst()) then
                RaiseError(StrSubstNo(QTY_CHANGE_NOT_ALLOWED, TicketNo, DetTicketAccessEntry.TableCaption(), DetTicketAccessEntry."Entry No."), QTY_CHANGE_NOT_ALLOWED_NO);
        until (TicketAccessEntry.Next() = 0);

        DetTicketAccessEntry.Reset();
        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
        DetTicketAccessEntry.FindFirst();
        if (NewTicketQuantity > DetTicketAccessEntry.Quantity) then
            RaiseError(StrSubstNo(QTY_TOO_LARGE, DetTicketAccessEntry.Quantity), QTY_TOO_LARGE_NO);

        TicketAccessEntry.FindSet();
        repeat
            TicketAccessEntry.Quantity := NewTicketQuantity;
            TicketAccessEntry.Modify();
        until (TicketAccessEntry.Next() = 0);

    end;

    local procedure RegisterDefaultAdmissionArrivalOnPosSales(Ticket: Record "NPR TM Ticket")
    var
        AdmissionCode: Code[20];
    begin

        AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");
        ValidateTicketForArrival(Ticket, AdmissionCode);

    end;

    local procedure RegisterAllAdmissionArrivalOnPosSales(Ticket: Record "NPR TM Ticket")
    var
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin

        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        if (TicketBom.IsEmpty()) then
            Error(NO_ADMISSION_CODE, Ticket."Item No.");

        TicketBom.FindSet();
        repeat
            Admission.Get(TicketBom."Admission Code");
            ValidateTicketForArrival(Ticket, Admission."Admission Code");
        until (TicketBom.Next() = 0);
    end;

    procedure RegisterTicketBomAdmissionArrival(Ticket: Record "NPR TM Ticket"; PosUnitNo: Code[10]; ProcessFlow: Option SALES,SCAN)
    var
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketType: Record "NPR TM Ticket Type";
        TicketAdmitted: Boolean;
    begin

        TicketType.Get(Ticket."Ticket Type Code");

        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        if (not TicketBom.FindSet()) then
            Error(NO_ADMISSION_CODE, Ticket."Item No.");

        TicketAdmitted := false;
        repeat
            Admission.Get(TicketBom."Admission Code");

            case TicketBom."Activation Method" of
                TicketBom."Activation Method"::SCAN:
                    if (ProcessFlow = ProcessFlow::SCAN) then
                        TicketAdmitted := ValidateTicketForArrival(Ticket, Admission."Admission Code");

                TicketBom."Activation Method"::POS:
                    if (ProcessFlow = ProcessFlow::SALES) then
                        TicketAdmitted := ValidateTicketForArrival(Ticket, Admission."Admission Code");

                TicketBom."Activation Method"::ALWAYS:
                    TicketAdmitted := ValidateTicketForArrival(Ticket, Admission."Admission Code");

                TicketBom."Activation Method"::PER_UNIT:
                    begin
                        if (ProcessFlow = ProcessFlow::SCAN) then
                            if (IsSelectedAdmissionDefaultOnPosScan(Ticket."Item No.", Ticket."Variant Code", Admission."Admission Code", PosUnitNo)) then
                                TicketAdmitted := ValidateTicketForArrival(Ticket, Admission."Admission Code");

                        if (ProcessFlow = ProcessFlow::SALES) then
                            if (IsSelectedAdmissionDefaultOnPosSale(Ticket."Item No.", Ticket."Variant Code", Admission."Admission Code", PosUnitNo)) then
                                TicketAdmitted := ValidateTicketForArrival(Ticket, Admission."Admission Code");
                    end;

                TicketBom."Activation Method"::NA: // Fallback (default) to Ticket Type setup
                    begin
                        if (ProcessFlow = ProcessFlow::SALES) then begin
                            if ((TicketType."Activation Method" = TicketType."Activation Method"::POS_DEFAULT) and TicketBom.Default) then
                                TicketAdmitted := ValidateTicketForArrival(Ticket, Admission."Admission Code");

                            if (TicketType."Activation Method" = TicketType."Activation Method"::POS_ALL) then
                                TicketAdmitted := ValidateTicketForArrival(Ticket, Admission."Admission Code");
                        end;

                        if (ProcessFlow = ProcessFlow::SCAN) then
                            if (TicketBom.Default) then
                                TicketAdmitted := ValidateTicketForArrival(Ticket, Admission."Admission Code");
                    end;
            end;
        until (TicketBom.Next() = 0);

        if ((ProcessFlow = ProcessFlow::SCAN) and (not TicketAdmitted)) then
            Error(NO_DEFAULT_ADMISSION_SELECTED, Ticket."Item No.");

    end;

    local procedure IsSelectedAdmissionDefaultOnPosSale(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; PosUnitNo: Code[10]): Boolean
    var
        PosDefaultAdmission: Record "NPR TM POS Default Admission";
    begin
        if (PosDefaultAdmission.Get(ItemNo, VariantCode, AdmissionCode, PosDefaultAdmission."Station Type"::POS_UNIT, PosUnitNo)) then
            exit((PosDefaultAdmission."Activation Method" = PosDefaultAdmission."Activation Method"::ON_SALES) or
                 (PosDefaultAdmission."Activation Method" = PosDefaultAdmission."Activation Method"::ALWAYS));
        exit(false);
    end;

    local procedure IsSelectedAdmissionDefaultOnPosScan(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; PosUnitNo: Code[10]): Boolean
    var
        PosDefaultAdmission: Record "NPR TM POS Default Admission";
    begin
        if (PosDefaultAdmission.Get(ItemNo, VariantCode, AdmissionCode, PosDefaultAdmission."Station Type"::POS_UNIT, PosUnitNo)) then
            exit((PosDefaultAdmission."Activation Method" = PosDefaultAdmission."Activation Method"::ON_SCAN) or
                 (PosDefaultAdmission."Activation Method" = PosDefaultAdmission."Activation Method"::ALWAYS));
        exit(false);
    end;

    local procedure ValidateTicketForArrival(Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]): Boolean
    begin
        ValidateTicketForArrival(0, Ticket."No.", AdmissionCode, -1); // Throws error on fail
        exit(true);
    end;

    procedure GetReceiptRequestToken(ReceiptNo: Code[20]; LineNumber: Integer; var Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        Token := '';

        TicketReservationRequest.SetCurrentKey("Receipt No.");
        TicketReservationRequest.SetFilter("Receipt No.", '=%1', ReceiptNo);
        TicketReservationRequest.SetFilter("Line No.", '=%1', LineNumber);

        if (TicketReservationRequest.FindFirst()) then
            Token := TicketReservationRequest."Session Token ID";

        exit(Token <> '');
    end;

    procedure RevokeTicketAccessEntry(TicketAccessEntryNo: Integer)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
    begin

        if (not TicketAccessEntry.Get(TicketAccessEntryNo)) then
            RaiseError(StrSubstNo(INVALID_REFERENCE, TicketAccessEntry.FieldCaption("Entry No."), TicketAccessEntryNo), INVALID_REFERENCE_NO);

        TicketAccessEntry.Status := TicketAccessEntry.Status::BLOCKED;
        TicketAccessEntry.Modify();

        Ticket.Get(TicketAccessEntry."Ticket No.");
        if (not Ticket.Blocked) then begin
            Ticket.Blocked := true;
            Ticket."Blocked Date" := Today();
            Ticket.Modify();
        end;

        RegisterCancel_Worker(TicketAccessEntry."Entry No.");

        TicketRequestManager.OnAfterBlockTicketPublisher(Ticket."No.");
        NotifyParticipant.CreateRevokeNotification(TicketAccessEntry);

    end;

    procedure ValidateTicketReference(TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO; TicketIdentifier: Text[50]; AdmissionCode: Code[20]; var TicketAccessEntryNo: Integer)
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        if (not GetTicket(TicketIdentifierType, TicketIdentifier, Ticket)) then
            RaiseError(StrSubstNo(INVALID_REFERENCE, REFERENCE, TicketIdentifier), INVALID_REFERENCE_NO);

        if (Ticket."Ticket Reservation Entry No." <> 0) then begin
            if (not TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
                RaiseError(StrSubstNo(NOT_CONFIRMED, TicketIdentifier), NOT_CONFIRMED_NO);

            if (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CANCELED) then
                RaiseError(StrSubstNo(TICKET_CANCELED, TicketIdentifier), TICKET_CANCELED_NO);

            if (TicketReservationRequest."Request Status" <> TicketReservationRequest."Request Status"::CONFIRMED) then
                RaiseError(StrSubstNo(NOT_CONFIRMED, TicketIdentifier), NOT_CONFIRMED_NO);
        end;

        if (Ticket.Blocked) then
            RaiseError(StrSubstNo(TICKET_CANCELED, TicketIdentifier), TICKET_CANCELED_NO);

        TicketAccessEntry.SetCurrentKey("Ticket No.");
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (AdmissionCode <> '') then
            TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        if (not TicketAccessEntry.FindFirst()) then
            RaiseError(StrSubstNo(NOT_VALID, TicketIdentifier, AdmissionCode), NOT_VALID_NO);

        if (TicketAccessEntry.Status = TicketAccessEntry.Status::BLOCKED) then
            RaiseError(StrSubstNo(TICKET_CANCELED, TicketIdentifier), TICKET_CANCELED_NO);

        DetailedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.");
        DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetailedTicketAccessEntry.SetFilter(Type, '=%1|=%2|%3', DetailedTicketAccessEntry.Type::PAYMENT, DetailedTicketAccessEntry.Type::PREPAID, DetailedTicketAccessEntry.Type::POSTPAID);
        if (DetailedTicketAccessEntry.IsEmpty()) then
            RaiseError(StrSubstNo(MISSING_PAYMENT, TicketIdentifier), MISSING_PAYMENT_NO);

        TicketAccessEntryNo := TicketAccessEntry."Entry No.";
        exit;
    end;

    procedure CheckIfCanBeConsumed(TicketNo: Code[20]; AdmissionCode: Code[20]; ItemNo: Code[20]; var ReasonText: Text): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        if (not Ticket.Get(TicketNo)) then begin
            ReasonText := StrSubstNo(INVALID_REFERENCE, Ticket.TableCaption(), TicketNo);
            exit(false);
        end;

        if (AdmissionCode = '') then
            AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (not TicketAccessEntry.FindFirst()) then begin
            ReasonText := StrSubstNo(INVALID_REFERENCE, TicketAccessEntry.TableCaption(), TicketAccessEntry.GetFilters());
            exit(false);
        end;

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::CONSUMED);
        DetTicketAccessEntry.SetFilter("Sales Channel No.", '=%1', ItemNo);

        if (not DetTicketAccessEntry.IsEmpty()) then begin
            ReasonText := 'Already consumed.';
            exit(false); // can not be consumed
        end;

        exit(true);
    end;

    procedure CheckAndConsumeItem(TicketNo: Code[20]; AdmissionCode: Code[20]; ItemNo: Code[20]; var ReasonText: Text): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        if (not Ticket.Get(TicketNo)) then begin
            ReasonText := StrSubstNo(INVALID_REFERENCE, Ticket.TableCaption(), TicketNo);
            exit(false);
        end;

        if (AdmissionCode = '') then
            AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (not TicketAccessEntry.FindFirst()) then begin
            ReasonText := StrSubstNo(INVALID_REFERENCE, TicketAccessEntry.TableCaption(), TicketAccessEntry.GetFilters());
            exit(false);
        end;

        DetTicketAccessEntry.Init();
        DetTicketAccessEntry."Entry No." := 0;
        DetTicketAccessEntry."Ticket No." := TicketNo;
        DetTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";
        DetTicketAccessEntry.Type := DetTicketAccessEntry.Type::CONSUMED;
        DetTicketAccessEntry.Quantity := 1;
        DetTicketAccessEntry.Open := false;
        DetTicketAccessEntry."Sales Channel No." := ItemNo;
        DetTicketAccessEntry."Created Datetime" := CurrentDateTime;
        DetTicketAccessEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(DetTicketAccessEntry."User ID"));
        DetTicketAccessEntry.Insert();

        exit(true);
    end;

    procedure LookUpTicketType(var TicketTypeCode: Code[20])
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketTypeForm: Page "NPR TM Ticket Type";
    begin
        TicketTypeForm.HideTickets();
        TicketTypeForm.LookupMode(true);
        if (TicketTypeForm.RunModal() = Action::LookupOK) then begin
            TicketTypeForm.GetRecord(TicketType);
            TicketTypeCode := TicketType.Code;
        end;
    end;

    local procedure ValidateScheduleReference(TicketAccessEntryNo: Integer; AdmissionCode: Code[20]; var AdmissionScheduleEntryNo: Integer)
    var
        Admission: Record "NPR TM Admission";
        AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry";
        ReservationSchEntry: Record "NPR TM Admis. Schedule Entry";
        ReservationAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        ReferenceTime: DateTime;
        AdmissionStartTime: DateTime;
        AdmissionEndTime: DateTime;
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
    begin

        // Requirements, should be checked elsewhere
        TicketAccessEntry.Get(TicketAccessEntryNo);
        Ticket.Get(TicketAccessEntry."Ticket No.");
        Admission.Get(AdmissionCode);

        Clear(AdmissionSchEntry);
        if (Admission."Prebook Is Required") then begin
            // Fast check-in, get events current schedule
            // reservation
            if (not GetReservationEntry(TicketAccessEntryNo, ReservationAccessEntry)) then
                RaiseError(StrSubstNo(RESERVATION_NOT_FOUND, Ticket."External Ticket No.", Admission.Description), RESERVATION_NOT_FOUND_NO);

            ReservationAccessEntry.SetCurrentKey("External Adm. Sch. Entry No.");

            ReservationSchEntry.SetFilter(Cancelled, '=%1', false);
            ReservationSchEntry.SetFilter("Admission Is", '=%1', ReservationSchEntry."Admission Is"::Open);

            ReservationSchEntry.SetFilter("External Schedule Entry No.", '=%1', ReservationAccessEntry."External Adm. Sch. Entry No.");
            ReservationSchEntry.FindFirst();

            // find the todays/now entry
            if (AdmissionScheduleEntryNo < 0) then begin
                ReferenceTime := CreateDateTime(Today, Time);
                AdmissionStartTime := CreateDateTime(ReservationSchEntry."Admission Start Date", ReservationSchEntry."Admission Start Time");
                AdmissionEndTime := CreateDateTime(ReservationSchEntry."Admission End Date", ReservationSchEntry."Admission End Time");

                if (AdmissionScheduleLines.Get(ReservationSchEntry."Admission Code", ReservationSchEntry."Schedule Code")) then begin
                    if (ReservationSchEntry."Event Arrival From Time" = 0T) then
                        ReservationSchEntry."Event Arrival From Time" := AdmissionScheduleLines."Event Arrival From Time";
                    if (ReservationSchEntry."Event Arrival Until Time" = 0T) then
                        ReservationSchEntry."Event Arrival Until Time" := AdmissionScheduleLines."Event Arrival Until Time";
                end;

                if (ReservationSchEntry."Event Arrival From Time" <> 0T) then
                    AdmissionStartTime := CreateDateTime(ReservationSchEntry."Admission Start Date", ReservationSchEntry."Event Arrival From Time");

                if (ReservationSchEntry."Event Arrival Until Time" <> 0T) then
                    AdmissionEndTime := CreateDateTime(ReservationSchEntry."Admission End Date", ReservationSchEntry."Event Arrival Until Time");

                if (not ((ReferenceTime >= AdmissionStartTime) and (ReferenceTime <= AdmissionEndTime))) then
                    RaiseError(StrSubstNo(RESERVATION_NOT_FOR_NOW, DT2Time(AdmissionStartTime), DT2Time(AdmissionEndTime), DT2Date(AdmissionStartTime), AdmissionCode, Time), RESERVATION_NOT_FOR_NOW_NO);

                AdmissionScheduleEntryNo := ReservationSchEntry."Entry No.";
            end;

            if (AdmissionScheduleEntryNo = 0) then
                RaiseError(StrSubstNo(RESERVATION_NOT_FOR_TODAY, Admission."Admission Code", ReservationSchEntry."Admission Start Date", ReservationSchEntry."Admission Start Time"), RESERVATION_NOT_FOR_TODAY_NO);

            if (not AdmissionSchEntry.Get(AdmissionScheduleEntryNo)) then
                RaiseError(StrSubstNo(RESERVATION_NOT_FOUND, Ticket."External Ticket No.", Admission.Description), RESERVATION_NOT_FOUND_NO);

            if (AdmissionSchEntry."External Schedule Entry No." <> ReservationAccessEntry."External Adm. Sch. Entry No.") then
                if (not GuiAllowed()) then begin
                    RaiseError(StrSubstNo(RESERVATION_MISMATCH), RESERVATION_MISMATCH_NO);
                end else begin
                    if (not Confirm(CONF_RES_NOT_FOR_TODAY, true, Admission.Description, ReservationSchEntry."Admission Start Date", ReservationSchEntry."Admission Start Time")) then
                        RaiseError(StrSubstNo(RESERVATION_MISMATCH), RESERVATION_MISMATCH_NO);
                    AdmissionScheduleEntryNo := ReservationSchEntry."Entry No.";
                end;

        end else begin

            // Get suggested admission schedule entry
            if (AdmissionScheduleEntryNo > 0) then begin
                AdmissionSchEntry.SetFilter("External Schedule Entry No.", '=%1', AdmissionScheduleEntryNo);
                AdmissionSchEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
                AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);
                AdmissionSchEntry.SetFilter("Admission Is", '=%1', AdmissionSchEntry."Admission Is"::Open);
                if (not AdmissionSchEntry.FindFirst()) then
                    RaiseError(StrSubstNo(ADM_NOT_OPEN_ENTRY, AdmissionCode, AdmissionScheduleEntryNo), ADM_NOT_OPEN_NO2);

            end else begin
                // Get the current admission schedule
                AdmissionScheduleEntryNo := GetCurrentScheduleEntry(Ticket, AdmissionCode, true);
                if (not AdmissionSchEntry.Get(AdmissionScheduleEntryNo)) then
                    RaiseError(StrSubstNo(ADM_NOT_OPEN, AdmissionCode, Today), ADM_NOT_OPEN_NO2);
            end;

        end;

        if (AdmissionSchEntry."Admission Is" <> AdmissionSchEntry."Admission Is"::Open) then
            RaiseError(StrSubstNo(ADM_NOT_OPEN, AdmissionCode, Today), ADM_NOT_OPEN_NO);

        exit
    end;

    local procedure ValidateAdmissionDependencies(TicketAccessEntryNo: Integer)
    var
        AdmissionDependencyLine: Record "NPR TM Adm. Dependency Line";
        AdmissionDependency: Record "NPR TM Adm. Dependency";
        Admission: Record "NPR TM Admission";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        Ticket: Record "NPR TM Ticket";
        StopRuleChecking: Boolean;
        DependencyCode: Code[20];
        ResponseMessage: Text;
    begin

        TicketAccessEntry.Get(TicketAccessEntryNo);
        Admission.Get(TicketAccessEntry."Admission Code");
        Ticket.Get(TicketAccessEntry."Ticket No.");
        TicketAdmissionBOM.Get(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code");

        DependencyCode := TicketAdmissionBOM."Admission Dependency Code";
        if (DependencyCode = '') then
            DependencyCode := Admission."Dependency Code";

        if ((DependencyCode <> '') and (AdmissionDependency.Get(DependencyCode))) then begin
            AdmissionDependencyLine.SetCurrentKey("Dependency Code", "Rule Sequence");
            AdmissionDependencyLine.SetFilter("Dependency Code", '=%1', DependencyCode);
            AdmissionDependencyLine.SetFilter(Disabled, '=%1', false);
            if (AdmissionDependencyLine.FindSet()) then begin
                repeat
                    if (not CheckDependencyRule(TicketAccessEntry, AdmissionDependencyLine, StopRuleChecking, ResponseMessage)) then
                        RaiseError(ResponseMessage, '-1013');

                until ((AdmissionDependencyLine.Next() = 0) or (StopRuleChecking));
            end else begin
                ; // Consider OK, no active rules
            end;
        end;

        exit;

    end;

    local procedure CheckDependencyRule(SourceAccessEntry: Record "NPR TM Ticket Access Entry"; AdmissionDependencyLine: Record "NPR TM Adm. Dependency Line"; var StopRuleChecking: Boolean; var ResponseMessage: Text): Boolean
    var
        DependentAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        Ticket: Record "NPR TM Ticket";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        AllowUntilDate: Date;
        AdmittedCount: Integer;
        IsValid: Boolean;
        AdmissionDateTime: DateTime;
        EXCLUDE_ADMISSION: Label 'Admission not allowed. The ticket does allow access to both %1 and %2.';
        NOT_WITHIN_TIMEFRAME: Label 'Admission not allowed. Admission to %1 expired on %2.';
        DEPENDENT_ADMISSION: Label 'Admission not allowed. Ticket need to be validated for %1 first.';
        ADM_DAILY_SCAN_LIMIT: Label 'Admission to %1 has a daily limited of %2 visits.';
        ADM_SCAN_FREQUENCY: Label 'Admission to %1 is limited to once per %2 minutes, previous admission was %3 minute(s) ago.';
        ResponseLbl: Label 'Dependency Rule %1, line %2 does not apply for ticket %3.';
    begin
        DependentAccessEntry.SetFilter("Ticket No.", '=%1', SourceAccessEntry."Ticket No.");
        DependentAccessEntry.SetFilter("Admission Code", '=%1', AdmissionDependencyLine."Admission Code");
        if (not DependentAccessEntry.FindFirst()) then begin
            ResponseMessage := StrSubstNo(ResponseLbl, AdmissionDependencyLine."Admission Code", AdmissionDependencyLine."Line No.", SourceAccessEntry."Ticket No.");
            exit(true);
        end;

        IsValid := true;
        case AdmissionDependencyLine."Rule Type" of
            AdmissionDependencyLine."Rule Type"::STOP_ON_ADMISSION:
                StopRuleChecking := (SourceAccessEntry."Admission Code" = DependentAccessEntry."Admission Code");

            AdmissionDependencyLine."Rule Type"::REQUIRED:
                begin
                    if (DependentAccessEntry."Access Date" = 0D) then begin
                        ResponseMessage := StrSubstNo(DEPENDENT_ADMISSION, AdmissionDependencyLine."Admission Code");
                        IsValid := false;
                    end;
                end;

            AdmissionDependencyLine."Rule Type"::EXCLUDE_OTHER:
                begin
                    if ((DependentAccessEntry."Access Date" <> 0D) and (SourceAccessEntry."Admission Code" <> DependentAccessEntry."Admission Code")) then begin
                        ResponseMessage := StrSubstNo(EXCLUDE_ADMISSION, SourceAccessEntry."Admission Code", AdmissionDependencyLine."Admission Code");
                        IsValid := false;
                    end;
                end;

            AdmissionDependencyLine."Rule Type"::EXCLUDE_SELF:
                begin
                    if ((DependentAccessEntry."Access Date" <> 0D) and (SourceAccessEntry."Admission Code" = DependentAccessEntry."Admission Code")) then begin
                        ResponseMessage := StrSubstNo(EXCLUDE_ADMISSION, SourceAccessEntry."Admission Code", AdmissionDependencyLine."Admission Code");
                        IsValid := false;
                    end;
                end;

            AdmissionDependencyLine."Rule Type"::TIMEFRAME:
                begin
                    if ((DependentAccessEntry."Access Date" <> 0D) and (SourceAccessEntry."Admission Code" <> DependentAccessEntry."Admission Code")) then begin

                        if (Format(AdmissionDependencyLine.Timeframe) = '') then
                            Evaluate(AdmissionDependencyLine.Timeframe, '<0D>');

                        AllowUntilDate := CalcDate(AdmissionDependencyLine.Timeframe, DependentAccessEntry."Access Date");

                        if (SourceAccessEntry."Access Date" > AllowUntilDate) then begin
                            ResponseMessage := StrSubstNo(NOT_WITHIN_TIMEFRAME, SourceAccessEntry."Admission Code", AllowUntilDate);
                            IsValid := false;
                        end;
                    end;
                end;

            AdmissionDependencyLine."Rule Type"::DAILY_ADM_SCAN_COUNT:
                begin
                    if (SourceAccessEntry."Admission Code" = DependentAccessEntry."Admission Code") then begin
                        DetTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.");
                        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', SourceAccessEntry."Entry No.");
                        DetTicketAccessEntry.SetFilter("Created Datetime", '%1..%2', CreateDateTime(Today, 0T), CreateDateTime(Today, 235959.999T));
                        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
                        AdmittedCount := DetTicketAccessEntry.Count();

                        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::CANCELED_ADMISSION);
                        AdmittedCount -= DetTicketAccessEntry.Count();

                        if (AdmittedCount > AdmissionDependencyLine.Limit) then begin
                            ResponseMessage := StrSubstNo(ADM_DAILY_SCAN_LIMIT, SourceAccessEntry."Admission Code", AdmissionDependencyLine.Limit);
                            IsValid := false;
                        end;
                    end
                end;

            AdmissionDependencyLine."Rule Type"::ADM_SCAN_FREQUENCY:
                begin
                    if (SourceAccessEntry."Admission Code" = DependentAccessEntry."Admission Code") then begin
                        DetTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.");
                        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', SourceAccessEntry."Entry No.");
                        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
                        if (DetTicketAccessEntry.Find('+')) then begin
                            AdmissionDateTime := DetTicketAccessEntry."Created Datetime";
                            // Find the previous admission entry
                            if (DetTicketAccessEntry.Next(-1) <> 0) then begin
                                if ((AdmissionDateTime - DetTicketAccessEntry."Created Datetime") < AdmissionDependencyLine.Limit * 1000 * 60) then begin
                                    ResponseMessage := StrSubstNo(ADM_SCAN_FREQUENCY, SourceAccessEntry."Admission Code", AdmissionDependencyLine.Limit, Round((AdmissionDateTime - DetTicketAccessEntry."Created Datetime") / 1000 / 60, 0.1));
                                    IsValid := false;
                                end;

                                // The speed gate vs a mom and a run-away kid ... 
                                if (not IsValid) then begin
                                    Ticket.Get(SourceAccessEntry."Ticket No.");
                                    TicketBom.Get(Ticket."Item No.", Ticket."Variant Code", SourceAccessEntry."Admission Code");
                                    case TicketBOM."Allow Rescan Within (Sec.)" of
                                        TicketBom."Allow Rescan Within (Sec.)"::SINGLE_ENTRY_ONLY:
                                            IsValid := false;

                                        TicketBom."Allow Rescan Within (Sec.)"::"15":
                                            IsValid := ((AdmissionDateTime - DetTicketAccessEntry."Created Datetime") < 15 * 1000);

                                        TicketBom."Allow Rescan Within (Sec.)"::"30":
                                            IsValid := ((AdmissionDateTime - DetTicketAccessEntry."Created Datetime") < 30 * 1000);

                                        TicketBom."Allow Rescan Within (Sec.)"::"60":
                                            IsValid := ((AdmissionDateTime - DetTicketAccessEntry."Created Datetime") < 60 * 1000);

                                        TicketBom."Allow Rescan Within (Sec.)"::"120":
                                            IsValid := ((AdmissionDateTime - DetTicketAccessEntry."Created Datetime") < 120 * 1000);

                                    end;

                                end;
                            end;
                        end;
                    end;
                end;
        end;

        if (not IsValid) then
            if (AdmissionDependencyLine."Response Message" <> '') then
                ResponseMessage := StrSubstNo(AdmissionDependencyLine."Response Message");

        exit(IsValid);

    end;

    procedure GetAdmissionSchedule(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]): Option
    var
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
    begin
        if (not Admission.Get(AdmissionCode)) then
            exit(Admission."Default Schedule"::NONE);

        if (TicketAdmissionBOM.Get(ItemNo, VariantCode, AdmissionCode)) then begin
            case TicketAdmissionBom."Ticket Schedule Selection" of
                TicketAdmissionBom."Ticket Schedule Selection"::ADMISSION:
                    exit(Admission."Default Schedule");
                TicketAdmissionBom."Ticket Schedule Selection"::TODAY:
                    exit(Admission."Default Schedule"::TODAY);
                TicketAdmissionBom."Ticket Schedule Selection"::NEXT_AVAILABLE:
                    exit(Admission."Default Schedule"::NEXT_AVAILABLE);
                TicketAdmissionBom."Ticket Schedule Selection"::SCHEDULE_ENTRY:
                    exit(Admission."Default Schedule"::SCHEDULE_ENTRY);
                TicketAdmissionBom."Ticket Schedule Selection"::"NONE":
                    exit(Admission."Default Schedule"::"NONE")
            end;
        end;

        exit(Admission."Default Schedule");
    end;

    local procedure GetDefaultAdmissionCode(ItemNo: Code[20]; VariantCode: Code[10]): Code[20]
    var
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
    begin
        TicketAdmissionBOM.Reset();
        TicketAdmissionBOM.SetFilter("Item No.", '=%1', ItemNo);
        TicketAdmissionBOM.SetFilter("Variant Code", '=%1', VariantCode);

        if (TicketAdmissionBOM.Count() = 1) then
            if (TicketAdmissionBOM.FindFirst()) then
                exit(TicketAdmissionBOM."Admission Code");

        TicketAdmissionBOM.SetFilter(Default, '=%1', true);
        if (TicketAdmissionBOM.FindFirst()) then
            exit(TicketAdmissionBOM."Admission Code");

        exit('');
    end;

    local procedure RaiseError(MessageText: Text; MessageId: Text)
    var
        ResponseMessage: Text;
        ResponseLbl: Label '[%1] - %2', Locked = true;
    begin
        ResponseMessage := MessageText;

        if (MessageId <> '') then
            ResponseMessage := StrSubstNo(ResponseLbl, MessageId, MessageText);

        Error(ResponseMessage);
    end;

    procedure GenerateCertificateNumber(GeneratePattern: Text[30]; TicketNo: Code[20]) PatternOut: Code[30]
    var
        ErrPattern: Label 'Error in Pattern %1';
        PosStartClause: Integer;
        PosEndClause: Integer;
        Pattern: Text[5];
        PatternLength: Integer;
        Left: Text[10];
        Right: Text[10];
        Itt: Integer;
        PlaceHolderLbl: Label '%1%2', Locked = true;
    begin
#pragma warning disable AA0139
        if (GeneratePattern = '') then
            exit('');

        GeneratePattern := UpperCase(GeneratePattern);

        PatternOut := '';
        if (StrLen(DelChr(GeneratePattern, '=', '[')) <> StrLen(DelChr(GeneratePattern, '=', ']'))) then
            Error(ErrPattern, GeneratePattern);

        while (StrLen(GeneratePattern) > 0) do begin
            PosStartClause := StrPos(GeneratePattern, '[');
            PosEndClause := StrPos(GeneratePattern, ']');
            PatternLength := PosEndClause - PosStartClause - 1;

            Pattern := '';
            if (PatternLength > 0) then
                Pattern := CopyStr(GeneratePattern, PosStartClause + 1, PatternLength);

            if (PatternLength < 1) then begin
                PatternOut := PatternOut + GeneratePattern;
                exit;
            end;

            if (PosStartClause > 1) then begin
                PatternOut := PatternOut + CopyStr(GeneratePattern, 1, PosStartClause - 1);
            end;

            if (PatternLength > 0) then begin
                Left := Pattern;
                Right := '1';
                if (STRPOS(Pattern, '*') > 1) then begin
                    Left := CopyStr(Pattern, 1, STRPOS(Pattern, '*') - 1);
                    Right := CopyStr(Pattern, STRPOS(Pattern, '*') + 1);
                end;

                case Left of
                    'S':
                        PatternOut := StrSubstNo(PlaceHolderLbl, PatternOut, TicketNo);
                    'N', 'A', 'X', 'AN':
                        begin
                            Evaluate(PatternLength, Right);
                            for Itt := 1 to PatternLength do
                                PatternOut := StrSubstNo(PlaceHolderLbl, PatternOut, GenerateRandom(Left));
                        end;
                    else begin
                            PatternOut := StrSubstNo(PlaceHolderLbl, PatternOut, Pattern);
                        end;
                end;
            end;

            if (StrLen(GeneratePattern) > PosEndClause) then
                GeneratePattern := CopyStr(GeneratePattern, PosEndClause + 1)
            else
                GeneratePattern := '';

        end;
#pragma warning restore
    end;

    local procedure GenerateRandom(Pattern: Code[2]) Random: Code[1]
    var
        Number: Integer;
        RandomCharacter: Code[1];
    begin
        Number := GetRandom(2);
        case Pattern of
            'N':
                Random := Format(Number mod 10);
            'A':
                RandomCharacter[1] := (Number mod 25) + 65;
            'X':
                begin
                    if (GetRandom(2) mod 35) < 10 then
                        Random := Format(Number mod 10)
                    else
                        RandomCharacter[1] := (Number mod 25) + 65;
                end;
        end;

        if (Random = '') then
            exit(RandomCharacter);
    end;

    local procedure GetRandom(Bytes: Integer) RandomInt: Integer
    var
        RandomHexStringLen: Integer;
        i: Integer;
        RandomHexString: Text[100];
    begin
        if (not (Bytes in [1 .. 4])) then
            Error(Text6059776);

        RandomHexStringLen := StrLen(RandomHexString);
        if (RandomHexStringLen < Bytes) then
            RandomHexString += UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));

        RandomInt := 0;
        for i := 1 to Bytes do
            case CopyStr(RandomHexString, i, 1) of
                '1':
                    RandomInt += Power(16, Bytes - i);
                '2':
                    RandomInt += 2 * Power(16, Bytes - i);
                '3':
                    RandomInt += 3 * Power(16, Bytes - i);
                '4':
                    RandomInt += 4 * Power(16, Bytes - i);
                '5':
                    RandomInt += 5 * Power(16, Bytes - i);
                '6':
                    RandomInt += 6 * Power(16, Bytes - i);
                '7':
                    RandomInt += 7 * Power(16, Bytes - i);
                '8':
                    RandomInt += 8 * Power(16, Bytes - i);
                '9':
                    RandomInt += 9 * Power(16, Bytes - i);
                'A':
                    RandomInt += 10 * Power(16, Bytes - i);
                'B':
                    RandomInt += 11 * Power(16, Bytes - i);
                'C':
                    RandomInt += 12 * Power(16, Bytes - i);
                'D':
                    RandomInt += 13 * Power(16, Bytes - i);
                'E':
                    RandomInt += 14 * Power(16, Bytes - i);
                'F':
                    RandomInt += 15 * Power(16, Bytes - i);
            end;

        if (RandomHexStringLen = Bytes) then
            RandomHexString := ''
        else
#pragma warning disable AA0139
            RandomHexString := CopyStr(RandomHexString, Bytes + 1);
#pragma warning restore
    end;

    local procedure RegisterArrival_Worker(TicketAccessEntryNo: Integer; TicketAdmissionSchEntryNo: Integer)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        AdmittedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
        FirstAdmission: Boolean;
    begin

        TicketAccessEntry.LockTable();
        TicketAccessEntry.Get(TicketAccessEntryNo);
        FirstAdmission := (TicketAccessEntry."Access Date" = 0D);

        if (TicketAccessEntry."Access Date" = 0D) then begin
            TicketAccessEntry."Access Date" := Today();
            TicketAccessEntry."Access Time" := Time;
            TicketAccessEntry.Modify();
        end;

        if (AdmissionScheduleEntry.Get(TicketAdmissionSchEntryNo)) then;

        AdmittedTicketAccessEntry.Init();
        AdmittedTicketAccessEntry."Ticket No." := TicketAccessEntry."Ticket No.";
        AdmittedTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";
        AdmittedTicketAccessEntry.Type := AdmittedTicketAccessEntry.Type::ADMITTED;
        AdmittedTicketAccessEntry."External Adm. Sch. Entry No." := AdmissionScheduleEntry."External Schedule Entry No.";
        AdmittedTicketAccessEntry.Quantity := TicketAccessEntry.Quantity;
        AdmittedTicketAccessEntry.Open := true;
        AdmittedTicketAccessEntry.Insert(true);

        OnDetailedTicketEvent(AdmittedTicketAccessEntry);
        CloseReservationEntry(AdmittedTicketAccessEntry);

        if (FirstAdmission) then
            NotifyParticipant.CreateFirstAdmissionNotification(TicketAccessEntry);
    end;

    local procedure RegisterReservation_Worker(Ticket: Record "NPR TM Ticket"; TicketAccessEntryNo: Integer; TicketAdmissionSchEntryNo: Integer): Integer
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        ReservationTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
    begin

        TicketAccessEntry.Get(TicketAccessEntryNo);
        if (Admission."Default Schedule"::NONE = GetAdmissionSchedule(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code")) then
            exit(0);

        if (not AdmissionScheduleEntry.Get(TicketAdmissionSchEntryNo)) then
            Error(NO_SCHEDULE_FOR_ADM, TicketAccessEntry."Admission Code");

        if (TicketAccessEntry."Admission Code" <> AdmissionScheduleEntry."Admission Code") then
            Error(ADMISSION_MISMATCH, TicketAdmissionSchEntryNo, TicketAccessEntry."Admission Code", AdmissionScheduleEntry."Admission Code");

        ReservationTicketAccessEntry.Init();
        ReservationTicketAccessEntry."Ticket No." := TicketAccessEntry."Ticket No.";
        ReservationTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";
        ReservationTicketAccessEntry.Type := ReservationTicketAccessEntry.Type::RESERVATION;
        ReservationTicketAccessEntry."External Adm. Sch. Entry No." := AdmissionScheduleEntry."External Schedule Entry No.";
        ReservationTicketAccessEntry.Quantity := TicketAccessEntry.Quantity;
        ReservationTicketAccessEntry.Open := true;
        ReservationTicketAccessEntry.Insert(true);

        OnDetailedTicketEvent(ReservationTicketAccessEntry);

        exit(ReservationTicketAccessEntry."Entry No.");
    end;

    local procedure RegisterDeparture_Worker(TicketAccessEntryNo: Integer)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DepartureTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        TicketAccessEntry.Get(TicketAccessEntryNo);

        DepartureTicketAccessEntry.Init();
        DepartureTicketAccessEntry."Ticket No." := TicketAccessEntry."Ticket No.";
        DepartureTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";
        DepartureTicketAccessEntry.Type := DepartureTicketAccessEntry.Type::DEPARTED;
        DepartureTicketAccessEntry."External Adm. Sch. Entry No." := -1; // updated by the closing function
        DepartureTicketAccessEntry.Quantity := TicketAccessEntry.Quantity;
        DepartureTicketAccessEntry.Open := false;
        DepartureTicketAccessEntry.Insert(true);

        if (not CloseArrivalEntry(DepartureTicketAccessEntry)) then
            exit; // Something wrong with the references - nothing fatal, but messy. Hard error is no good...

        DepartureTicketAccessEntry.Modify();
        OnDetailedTicketEvent(DepartureTicketAccessEntry);

    end;

    local procedure RegisterPayment_Worker(TicketAccessEntryNo: Integer; PaymentType: Option; PaymentReferenceNo: Code[20])
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        PaymentTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        TicketAccessEntry.Get(TicketAccessEntryNo);

        PaymentTicketAccessEntry.Init();
        PaymentTicketAccessEntry."Ticket No." := TicketAccessEntry."Ticket No.";
        PaymentTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";
        PaymentTicketAccessEntry.Open := false;
        PaymentTicketAccessEntry."Sales Channel No." := PaymentReferenceNo;

        case PaymentType of
            gAccessEntryPaymentType::PAYMENT:
                PaymentTicketAccessEntry.Type := PaymentTicketAccessEntry.Type::PAYMENT;
            gAccessEntryPaymentType::PREPAID:
                PaymentTicketAccessEntry.Type := PaymentTicketAccessEntry.Type::PREPAID;
            gAccessEntryPaymentType::POSTPAID:
                begin
                    PaymentTicketAccessEntry.Type := PaymentTicketAccessEntry.Type::POSTPAID;
                    PaymentTicketAccessEntry.Open := true;
                end;
            else
                Error('Unsupported Payment Type in function RegisterPayment_Worker.');
        end;

        PaymentTicketAccessEntry."External Adm. Sch. Entry No." := 0;
        PaymentTicketAccessEntry.Quantity := TicketAccessEntry.Quantity;
        PaymentTicketAccessEntry.Insert(true);

        CloseInitialEntry(PaymentTicketAccessEntry);
        OnDetailedTicketEvent(PaymentTicketAccessEntry);

    end;

    local procedure RegisterCancel_Worker(TicketAccessEntryNo: Integer)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        CancelTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        OpenTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        InitialTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmittedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        ReservationTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        QtyToCancel: Integer;
        HaveAdmissionEntry: Boolean;
        ClosedByEntryNo: Integer;
        ReservedQty: Integer;
    begin

        TicketAccessEntry.Get(TicketAccessEntryNo);

        OpenTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.");
        OpenTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntryNo);
        OpenTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
        if (OpenTicketAccessEntry.FindSet()) then begin

            InitialTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.");
            InitialTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntryNo);
            InitialTicketAccessEntry.SetFilter(Type, '=%1', InitialTicketAccessEntry.Type::INITIAL_ENTRY);
            InitialTicketAccessEntry.FindFirst();

            AdmittedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.");
            AdmittedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntryNo);
            AdmittedTicketAccessEntry.SetFilter(Type, '=%1', InitialTicketAccessEntry.Type::ADMITTED);

            HaveAdmissionEntry := AdmittedTicketAccessEntry.FindFirst();
            if (not HaveAdmissionEntry) then
                AdmittedTicketAccessEntry.Quantity := 0;

            ReservationTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.");
            ReservationTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntryNo);
            ReservationTicketAccessEntry.SetFilter(Type, '=%1', InitialTicketAccessEntry.Type::RESERVATION);
            if (not ReservationTicketAccessEntry.FindFirst()) then
                ReservationTicketAccessEntry.Quantity := 0;

            QtyToCancel := InitialTicketAccessEntry.Quantity - AdmittedTicketAccessEntry.Quantity;
            if (QtyToCancel = 0) then
                QtyToCancel := InitialTicketAccessEntry.Quantity;

            CancelTicketAccessEntry.Init();
            CancelTicketAccessEntry."Ticket No." := TicketAccessEntry."Ticket No.";
            CancelTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";
            CancelTicketAccessEntry.Type := CancelTicketAccessEntry.Type::CANCELED_ADMISSION;
            CancelTicketAccessEntry."External Adm. Sch. Entry No." := InitialTicketAccessEntry."External Adm. Sch. Entry No.";
            CancelTicketAccessEntry.Quantity := QtyToCancel;
            CancelTicketAccessEntry.Open := false;

            if (not HaveAdmissionEntry) then begin
                CancelTicketAccessEntry.Insert(true);
                OnDetailedTicketEvent(CancelTicketAccessEntry);
            end;

            ClosedByEntryNo := CancelTicketAccessEntry."Entry No.";
            repeat
                case OpenTicketAccessEntry.Type of

                    OpenTicketAccessEntry.Type::ADMITTED:
                        begin
                            CancelTicketAccessEntry."Closed By Entry No." := OpenTicketAccessEntry."Entry No.";
                            CancelTicketAccessEntry."Entry No." := 0;
                            CancelTicketAccessEntry.Type := CancelTicketAccessEntry.Type::CANCELED_ADMISSION;
                            CancelTicketAccessEntry.Quantity := QtyToCancel;
                            CancelTicketAccessEntry."External Adm. Sch. Entry No." := OpenTicketAccessEntry."External Adm. Sch. Entry No.";
                            CancelTicketAccessEntry.Insert(true);

                            if (QtyToCancel = AdmittedTicketAccessEntry.Quantity) then
                                OpenTicketAccessEntry.Open := false;

                            OpenTicketAccessEntry."Closed By Entry No." := CancelTicketAccessEntry."Entry No.";
                            OpenTicketAccessEntry.Modify();

                        end;

                    OpenTicketAccessEntry.Type::RESERVATION:
                        begin

                            ReservedQty := OpenTicketAccessEntry.Quantity;
                            if ((ReservedQty <> QtyToCancel) and (OpenTicketAccessEntry.Open)) then begin
                                OpenTicketAccessEntry.Quantity := ReservedQty - QtyToCancel; // new reserved qty, line is still open, reservation is active
                                OpenTicketAccessEntry.Modify();
                            end;

                            if ((ReservedQty = QtyToCancel) and (OpenTicketAccessEntry.Open)) then begin
                                OpenTicketAccessEntry.Open := false;
                                OpenTicketAccessEntry."Closed By Entry No." := ClosedByEntryNo;
                                OpenTicketAccessEntry.Modify();
                            end;

                            CancelTicketAccessEntry."Closed By Entry No." := ClosedByEntryNo;
                            CancelTicketAccessEntry."Entry No." := 0;
                            CancelTicketAccessEntry.Type := CancelTicketAccessEntry.Type::RESERVATION;
                            CancelTicketAccessEntry.Quantity := -QtyToCancel;
                            CancelTicketAccessEntry."External Adm. Sch. Entry No." := ReservationTicketAccessEntry."External Adm. Sch. Entry No.";
                            CancelTicketAccessEntry.Insert(true);

                            OnDetailedTicketEvent(CancelTicketAccessEntry);
                        end;

                    OpenTicketAccessEntry.Type::INITIAL_ENTRY:
                        begin
                            CancelTicketAccessEntry."Closed By Entry No." := ClosedByEntryNo;
                            CancelTicketAccessEntry."Entry No." := 0;
                            CancelTicketAccessEntry.Type := CancelTicketAccessEntry.Type::INITIAL_ENTRY;
                            CancelTicketAccessEntry.Quantity := -QtyToCancel;
                            CancelTicketAccessEntry."External Adm. Sch. Entry No." := InitialTicketAccessEntry."External Adm. Sch. Entry No.";
                            CancelTicketAccessEntry.Insert(true);
                        end;
                end;

            until (OpenTicketAccessEntry.Next() = 0);

        end else begin
            CancelTicketAccessEntry.Init();
            CancelTicketAccessEntry."Ticket No." := TicketAccessEntry."Ticket No.";
            CancelTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";
            CancelTicketAccessEntry.Type := CancelTicketAccessEntry.Type::CANCELED_ADMISSION;
            CancelTicketAccessEntry."External Adm. Sch. Entry No." := 0;
            CancelTicketAccessEntry.Quantity := TicketAccessEntry.Quantity;
            CancelTicketAccessEntry.Open := false;
            CancelTicketAccessEntry.Insert(true);

            OnDetailedTicketEvent(CancelTicketAccessEntry);
        end;
    end;

    local procedure CloseInitialEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"): Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        exit(CloseTicketAccessEntry(ClosedByAccessEntry, DetailedTicketAccessEntry.Type::INITIAL_ENTRY));
    end;

    local procedure CloseReservationEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"): Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        exit(CloseTicketAccessEntry(ClosedByAccessEntry, DetailedTicketAccessEntry.Type::RESERVATION));
    end;

    local procedure CloseArrivalEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"): Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        exit(CloseTicketAccessEntry(ClosedByAccessEntry, DetailedTicketAccessEntry.Type::ADMITTED));
    end;

    local procedure CloseTicketAccessEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"; ClosingEntryType: Option) Closed: Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        DetailedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type, Open, "Posting Date");
        DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', ClosedByAccessEntry."Ticket Access Entry No.");
        DetailedTicketAccessEntry.SetFilter(Type, '=%1', ClosingEntryType);
        DetailedTicketAccessEntry.SetFilter(Open, '=%1', true);
        if (DetailedTicketAccessEntry.FindFirst()) then begin
            DetailedTicketAccessEntry."Closed By Entry No." := ClosedByAccessEntry."Entry No.";
            DetailedTicketAccessEntry.Open := false;
            DetailedTicketAccessEntry.Modify();
            Closed := true;
        end;

        if (ClosedByAccessEntry.Type = ClosedByAccessEntry.Type::DEPARTED) then
            ClosedByAccessEntry."External Adm. Sch. Entry No." := DetailedTicketAccessEntry."External Adm. Sch. Entry No.";

        if (ClosedByAccessEntry.Quantity < 0) then
            ClosedByAccessEntry."External Adm. Sch. Entry No." := DetailedTicketAccessEntry."External Adm. Sch. Entry No.";

        exit(Closed);
    end;

    local procedure GetReservationEntry(TicketAccessEntryNo: Integer; var DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry"): Boolean
    begin

        Clear(DetailedTicketAccessEntry);
        DetailedTicketAccessEntry.Reset();
        DetailedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type, Open);
        DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntryNo);
        DetailedTicketAccessEntry.SetFilter(Type, '=%1', DetailedTicketAccessEntry.Type::RESERVATION);

        exit(DetailedTicketAccessEntry.FindFirst());
    end;

    procedure GetCurrentScheduleEntry(Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; WithCreate: Boolean): Integer
    begin
        exit(GetCurrentScheduleEntry(Ticket."Item No.", Ticket."Variant Code", AdmissionCode, WithCreate));
    end;

    procedure GetCurrentScheduleEntry(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; WithCreate: Boolean): Integer
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
    begin

        Clear(AdmissionScheduleEntry);
        if (GetAdmScheduleEntry(ItemNo, VariantCode, AdmissionCode, Today, Time, AdmissionScheduleEntry, WithCreate)) then
            exit(AdmissionScheduleEntry."Entry No.");

        if (Admission."Default Schedule"::NEXT_AVAILABLE = GetAdmissionSchedule(ItemNo, VariantCode, AdmissionCode)) then begin
            AdmissionScheduleEntry.Reset();
            AdmissionScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '>%1', Today);
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
            if (AdmissionScheduleEntry.FindFirst()) then
                exit(AdmissionScheduleEntry."Entry No.");
        end;

        exit(0);
    end;

    local procedure GetAdmScheduleEntry(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; AdmissionDate: Date; AdmissionTime: Time; var AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry"; WithCreate: Boolean): Boolean
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        AdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
        CurrentAdmissionEntryNo: Integer;
        NextAdmissionEntryNo: Integer;
        ReferenceTime: DateTime;
        AdmissionStartTime: DateTime;
        AdmissionEndTime: DateTime;
    begin

        if (AdmissionSchEntry."Entry No." = 0) then begin

            Admission.Get(AdmissionCode);

            AdmissionSchEntry.Reset();
            AdmissionSchEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
            AdmissionSchEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            AdmissionSchEntry.SetFilter("Admission Start Date", '=%1', AdmissionDate);
            AdmissionSchEntry.SetFilter("Admission Is", '=%1', AdmissionSchEntry."Admission Is"::Open);
            AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);

            if (WithCreate) then begin
                // gently check
                if (AdmissionSchManagement.IsUpdateScheduleEntryRequired(AdmissionCode, Today)) then
                    AdmissionSchManagement.CreateAdmissionSchedule(AdmissionCode, false, AdmissionDate);

                // still empty, try harder
                if (AdmissionSchEntry.IsEmpty()) then
                    AdmissionSchManagement.CreateAdmissionSchedule(AdmissionCode, false, AdmissionDate);
            end;

            if (AdmissionSchEntry.IsEmpty()) then
                exit(false);

            AdmissionSchEntry.FindSet();
            ReferenceTime := CreateDateTime(AdmissionDate, AdmissionTime);
            repeat

                AdmissionStartTime := CreateDateTime(AdmissionSchEntry."Admission Start Date", AdmissionSchEntry."Admission Start Time");
                AdmissionEndTime := CreateDateTime(AdmissionSchEntry."Admission End Date", AdmissionSchEntry."Admission End Time");

                if (AdmissionScheduleLines.Get(AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code")) then begin
                    if (AdmissionSchEntry."Event Arrival From Time" = 0T) then
                        AdmissionSchEntry."Event Arrival From Time" := AdmissionScheduleLines."Event Arrival From Time";
                    if (AdmissionSchEntry."Event Arrival Until Time" = 0T) then
                        AdmissionSchEntry."Event Arrival Until Time" := AdmissionScheduleLines."Event Arrival Until Time";
                end;

                if (AdmissionSchEntry."Event Arrival From Time" <> 0T) then
                    AdmissionStartTime := CreateDateTime(AdmissionSchEntry."Admission Start Date", AdmissionSchEntry."Event Arrival From Time");

                if (AdmissionSchEntry."Event Arrival Until Time" <> 0T) then
                    AdmissionEndTime := CreateDateTime(AdmissionSchEntry."Admission End Date", AdmissionSchEntry."Event Arrival Until Time");

                if ((ReferenceTime > AdmissionStartTime) and
                    (ReferenceTime > AdmissionEndTime) and
                    (CurrentAdmissionEntryNo = 0)) then begin
                end;

                if ((ReferenceTime >= AdmissionStartTime) and
                    (ReferenceTime <= AdmissionEndTime)) then begin
                    CurrentAdmissionEntryNo := AdmissionSchEntry."Entry No.";
                end;

                if ((ReferenceTime < AdmissionStartTime) and
                    (ReferenceTime < AdmissionStartTime) and
                    (NextAdmissionEntryNo = 0)) then begin
                    NextAdmissionEntryNo := AdmissionSchEntry."Entry No.";
                end;

            until (AdmissionSchEntry.Next() = 0);

            if (CurrentAdmissionEntryNo <> 0) then
                exit(AdmissionSchEntry.Get(CurrentAdmissionEntryNo));

            case GetAdmissionSchedule(ItemNo, VariantCode, AdmissionCode) of
                Admission."Default Schedule"::TODAY:
                    if ((NextAdmissionEntryNo <> 0) and (AdmissionDate = Today)) then // not open yet, add a grace period here?
                        exit(AdmissionSchEntry.Get(NextAdmissionEntryNo));

                Admission."Default Schedule"::NEXT_AVAILABLE:
                    if (NextAdmissionEntryNo <> 0) then
                        exit(AdmissionSchEntry.Get(NextAdmissionEntryNo));
            end;

            exit(false);

        end else begin
            AdmissionSchEntry.Get(AdmissionSchEntry."Entry No.");

        end;
    end;

    local procedure GetTicket(TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO; TicketIdentifier: Text[50]; var Ticket: Record "NPR TM Ticket"): Boolean
    begin
        Clear(Ticket);

        case TicketIdentifierType of
            TicketIdentifierType::INTERNAL_TICKET_NO:
                begin
                    Ticket.SetCurrentKey("No.");
                    Ticket.SetFilter("No.", '=%1', CopyStr(TicketIdentifier, 1, MaxStrLen(Ticket."No.")));
                end;
            TicketIdentifierType::EXTERNAL_TICKET_NO:
                begin
                    Ticket.SetCurrentKey("External Ticket No.");
                    Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketIdentifier, 1, MaxStrLen(Ticket."External Ticket No.")));
                end;
            TicketIdentifierType::PRINTED_TICKET_NO:
                begin
                    Ticket.SetCurrentKey("Ticket No. for Printing");
                    Ticket.SetFilter("Ticket No. for Printing", '=%1', CopyStr(TicketIdentifier, 1, MaxStrLen(Ticket."Ticket No. for Printing")));
                end;
            else
                Error(UNSUPPORTED_VALIDATION_METHOD);
        end;

        exit(Ticket.FindFirst());
    end;

    procedure GetTicketCapacity(TicketItemNo: Code[20]; TicketVariantCode: Code[10]; AdmissionCode: Code[20]; ScheduleCode: Code[20]; AdmissionScheduleEntryNo: Integer; var MaxCapacity: Integer; var CapacityControl: Option): Boolean
    var
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
    begin
        if (not GetAdmissionCapacity(AdmissionCode, ScheduleCode, AdmissionScheduleEntryNo, MaxCapacity, CapacityControl)) then
            exit(false);

        if (not TicketAdmissionBOM.Get(TicketItemNo, TicketVariantCode, AdmissionCode)) then
            exit(false);

        MaxCapacity := Round(MaxCapacity * TicketAdmissionBOM."Percentage of Adm. Capacity" / 100, 1);

        exit(true);

    end;

    procedure GetAdmissionCapacity(AdmissionCode: Code[20]; ScheduleCode: Code[20]; AdmissionScheduleEntryNo: Integer; var MaxCapacity: Integer; var CapacityControl: Option): Boolean
    var
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
        AdmissionSchedule: Record "NPR TM Admis. Schedule Lines";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        SeatingTemplate: Record "NPR TM Seating Template";
    begin
        if (not Admission.Get(AdmissionCode)) then
            exit(false);

        case Admission."Capacity Limits By" of
            Admission."Capacity Limits By"::ADMISSION:
                begin
                    CapacityControl := Admission."Capacity Control";
                    MaxCapacity := Admission."Max Capacity Per Sch. Entry";
                end;
            Admission."Capacity Limits By"::SCHEDULE:
                begin
                    if (not Schedule.Get(ScheduleCode)) then
                        exit(false);
                    CapacityControl := Schedule."Capacity Control";
                    MaxCapacity := Schedule."Max Capacity Per Sch. Entry";
                end;
            Admission."Capacity Limits By"::OVERRIDE:
                begin
                    if (not AdmissionSchedule.Get(AdmissionCode, ScheduleCode)) then
                        exit(false);
                    CapacityControl := AdmissionSchedule."Capacity Control";
                    MaxCapacity := AdmissionSchedule."Max Capacity Per Sch. Entry";
                    if (AdmissionScheduleEntry.Get(AdmissionScheduleEntryNo)) then begin
                        if (AdmissionScheduleEntry."Max Capacity Per Sch. Entry" <> 0) then
                            MaxCapacity := AdmissionScheduleEntry."Max Capacity Per Sch. Entry";
                    end;
                end;
            else
                Error(UNSUPPORTED_VALIDATION_METHOD);
        end;

        if (CapacityControl = Admission."Capacity Control"::SEATING) then begin
            SeatingTemplate.SetFilter("Admission Code", '=%1', Admission."Admission Code");
            SeatingTemplate.SetFilter("Reservation Category", '=%1|=%2', SeatingTemplate."Reservation Category"::AVAILABLE, SeatingTemplate."Reservation Category"::NA);
            SeatingTemplate.SetFilter("Entry Type", '=%1', SeatingTemplate."Entry Type"::LEAF);
            MaxCapacity := SeatingTemplate.Count();
        end;

        exit(true);
    end;

    procedure ValidateAdmSchEntryForSales(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; TicketItemNo: Code[20]; TicketVariantCode: Code[10]; ReferenceDate: Date; ReferenceTime: Time; var RemainingQuantityOut: Integer): Boolean
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        MaxCapacity: Integer;
        CapacityControl: Option;
        ActivateOnSales: Boolean;
        IsReservation: Boolean;
        ConcurrentQuantity: Integer;
        ConcurrentMaxQty: Integer;
    begin
        if (not Admission.Get(AdmissionScheduleEntry."Admission Code")) then
            Admission.Init();

        if (not TicketBOM.Get(TicketItemNo, TicketVariantCode, AdmissionScheduleEntry."Admission Code")) then
            TicketBOM.Init();

        GetTicketCapacity(TicketItemNo, TicketVariantCode, AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", AdmissionScheduleEntry."Entry No.", MaxCapacity, CapacityControl);
        RemainingQuantityOut := MaxCapacity - CalculateCurrentCapacity(CapacityControl, AdmissionScheduleEntry."Entry No.");

        if (CalculateConcurrentCapacity(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", AdmissionScheduleEntry."Admission Start Date", ConcurrentQuantity, ConcurrentMaxQty)) then
            if (ConcurrentQuantity >= ConcurrentMaxQty) then
                exit(false);

        // Should this time slot be listed?
        IsReservation := ((Admission.Type = Admission.Type::OCCASION) and (Admission."Prebook Is Required"));
        ActivateOnSales := false;
        if (Item.Get(TicketItemNo)) then begin
            if (TicketType.Get(Item."NPR Ticket Type")) then begin
                if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then begin
                    ActivateOnSales := (TicketBOM."Activation Method" = TicketBOM."Activation Method"::POS);
                    if (TicketBOM."Activation Method" = TicketBOM."Activation Method"::NA) then
                        TicketType."Ticket Configuration Source" := TicketType."Ticket Configuration Source"::TICKET_TYPE; // delegate to Ticket Type setup
                end;

                if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_TYPE) then begin
                    ActivateOnSales := ((TicketType."Activation Method" = TicketType."Activation Method"::POS_ALL) or
                                        ((TicketType."Activation Method" = TicketType."Activation Method"::POS_DEFAULT) and TicketBOM.Default));
                end;

            end;
        end;

        if (AdmissionScheduleEntry."Event Arrival From Time" = 0T) then
            AdmissionScheduleEntry."Event Arrival From Time" := AdmissionScheduleEntry."Admission Start Time";

        if (AdmissionScheduleEntry."Event Arrival Until Time" = 0T) then
            AdmissionScheduleEntry."Event Arrival Until Time" := AdmissionScheduleEntry."Admission End Time";

        // if ticket will be admitted automatically, we also need to check valid admission time
        if (ActivateOnSales) then begin
            if (AdmissionScheduleEntry."Admission Start Date" <> ReferenceDate) then
                exit(false); // When ticket is activated on sales, and its a reservation for another date than the reference date, it cant be sold now, don't validate the time slot

            if (ReferenceTime < AdmissionScheduleEntry."Event Arrival From Time") then
                exit(false);
        end;

        //if (IsReservation) or (Admission."Default Schedule" = Admission."Default Schedule"::SCHEDULE_ENTRY) then begin
        if (IsReservation) or (Admission."Default Schedule"::SCHEDULE_ENTRY = GetAdmissionSchedule(TicketItemNo, TicketVariantCode, AdmissionScheduleEntry."Admission Code")) then begin
            // when we pass arrival until time, we cant sell this time slot.
            if ((AdmissionScheduleEntry."Admission Start Date" = ReferenceDate) and (ReferenceTime > AdmissionScheduleEntry."Event Arrival Until Time")) then
                exit(false);
        end;

        // Verify the general window of sales
        if (TicketBOM."Enforce Schedule Sales Limits") then begin
            if (AdmissionScheduleEntry."Sales From Date" <> 0D) then begin
                if (AdmissionScheduleEntry."Sales From Date" > ReferenceDate) then
                    exit(false);
                if (AdmissionScheduleEntry."Sales From Date" = ReferenceDate) then
                    if (AdmissionScheduleEntry."Sales From Time" > ReferenceTime) then
                        exit(false);
            end;

            if (AdmissionScheduleEntry."Sales Until Date" <> 0D) then begin
                if (ReferenceDate > AdmissionScheduleEntry."Sales Until Date") then
                    exit(false);
                if (ReferenceDate = AdmissionScheduleEntry."Sales Until Date") then
                    if (ReferenceTime > AdmissionScheduleEntry."Sales Until Time") then
                        exit(false);
            end;
        end;

        exit(true);
    end;

    local procedure ValidateTicketAdmissionCapacityExceeded(Ticket: Record "NPR TM Ticket"; AdmissionScheduleEntryNo: Integer; TicketExecutionContext: Option SALES,ADMISSION)
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Schedule: Record "NPR TM Admis. Schedule";
        AdmissionSchedule: Record "NPR TM Admis. Schedule Lines";
        WaitingListSetup: Record "NPR TM Waiting List Setup";
        AdmissionGroupConcurrency: Record "NPR TM Concurrent Admis. Setup";
        MaxCapacity: Integer;
        AdmittedCount: Integer;
        CapacityExceeded: Boolean;
        CapacityControl: Option;
    begin
        // This function should be called after the entry transaction have been created
        // That will allow us to catch a zero count as an error

        AdmissionScheduleEntry.Get(AdmissionScheduleEntryNo);
        Admission.Get(AdmissionScheduleEntry."Admission Code");
        Schedule.Get(AdmissionScheduleEntry."Schedule Code");
        AdmissionSchedule.Get(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code");

        GetTicketCapacity(Ticket."Item No.", Ticket."Variant Code", AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", AdmissionScheduleEntryNo, MaxCapacity, CapacityControl);

        if (CapacityControl = Admission."Capacity Control"::NONE) then
            exit;

        if (TicketExecutionContext = TicketExecutionContext::ADMISSION) and (CapacityControl = Admission."Capacity Control"::SALES) then
            exit;

        AdmittedCount := CalculateCurrentCapacity(CapacityControl, AdmissionScheduleEntryNo);

        if (AdmittedCount = 0) then
            Error(UNEXPECTED, AdmissionScheduleEntry.TableCaption(), Admission."Admission Code", AdmittedCount, SHOULD_NOT_BE_ZERO, 0, 0);

        CapacityExceeded := (AdmittedCount > MaxCapacity);

        if (CapacityExceeded) then
            RaiseError(StrSubstNo(CAPACITY_EXCEEDED, Admission."Admission Code"), CAPACITY_EXCEEDED_NO);

        if (CalculateConcurrentCapacity(AdmissionSchedule."Admission Code", AdmissionSchedule."Schedule Code", AdmissionScheduleEntry."Admission Start Date", AdmittedCount, MaxCapacity)) then begin
            AdmissionGroupConcurrency.Get(AdmissionSchedule."Concurrency Code");
            CapacityExceeded := (AdmittedCount > MaxCapacity);
            if (CapacityExceeded) then
                RaiseError(StrSubstNo(CONCURRENT_CAPACITY_EXCEEDED, AdmissionGroupConcurrency.Code), CONCURRENT_CAPACITY_EXCEEDED_NO);
        end;

        if (MaxCapacity > 0) then
            if (AdmittedCount / MaxCapacity * 100 > Schedule."Notify When Percentage Sold") then
                OnSelloutThresholdReached(1, Ticket, AdmissionScheduleEntry, AdmittedCount, MaxCapacity);

        if (Admission."Waiting List Setup Code" <> '') then begin
            if (not WaitingListSetup.Get(Admission."Waiting List Setup Code")) then
                WaitingListSetup.Init();

            if (AdmittedCount >= MaxCapacity - WaitingListSetup."Activate WL at Remaining Qty.") then begin
                AdmissionScheduleEntry."Allocation By" := AdmissionScheduleEntry."Allocation By"::WAITINGLIST;
                AdmissionScheduleEntry.Modify();
                OnSelloutThresholdReached(2, Ticket, AdmissionScheduleEntry, AdmittedCount, MaxCapacity);
            end;
        end;

    end;

    local procedure CalculateCurrentCapacity(CapacityControl: Option; AdmissionScheduleEntryNo: Integer) AdmittedCount: Integer
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        SeatingReservationEntry: Record "NPR TM Seating Reserv. Entry";
    begin
        AdmissionScheduleEntry.Get(AdmissionScheduleEntryNo);

        case CapacityControl of
            Admission."Capacity Control"::NONE:
                exit(0);

            Admission."Capacity Control"::SALES:
                begin
                    // Performance / Deadlock. SUM (x) flowfield issues SQL with statement for repeatable read "with(UPDLOCK)"
                    // TODO
                    AdmissionScheduleEntry.CalcFields("Initial Entry (All)");
                    AdmittedCount := AdmissionScheduleEntry."Initial Entry (All)";
                end;

            Admission."Capacity Control"::ADMITTED:
                begin
                    // Performance / Deadlock. SUM (x) flowfield issues SQL with statement for repeatable read "with(UPDLOCK)"
                    // TODO
                    AdmissionScheduleEntry.CalcFields("Open Admitted");
                    AdmittedCount := AdmissionScheduleEntry."Open Admitted";
                end;

            Admission."Capacity Control"::FULL:
                begin
                    // Performance / Deadlock. SUM (x) flowfield issues SQL with statement for repeatable read "with(UPDLOCK)"
                    // TODO
                    AdmissionScheduleEntry.CalcFields("Open Reservations", "Open Admitted");
                    AdmittedCount := AdmissionScheduleEntry."Open Admitted" + AdmissionScheduleEntry."Open Reservations";
                end;

            Admission."Capacity Control"::SEATING:
                begin
                    SeatingReservationEntry.SetCurrentKey("External Schedule Entry No.");
                    SeatingReservationEntry.SetFilter("External Schedule Entry No.", '=%1', AdmissionScheduleEntry."External Schedule Entry No.");
                    AdmittedCount := SeatingReservationEntry.Count();
                end;

            else
                Error(UNSUPPORTED_VALIDATION_METHOD);
        end;

        exit(AdmittedCount);
    end;

    procedure CalculateConcurrentCapacity(AdmissionCode: Code[20]; ScheduleCode: Code[20]; ReferenceDate: Date; var ActualCount: Integer; var MaxCount: Integer): Boolean
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        AdmissionSchedule: Record "NPR TM Admis. Schedule Lines";
        AdmissionGroupConcurrency: Record "NPR TM Concurrent Admis. Setup";
    begin
        if (not AdmissionSchedule.Get(AdmissionCode, ScheduleCode)) then
            exit(false);

        if (not AdmissionGroupConcurrency.Get(AdmissionSchedule."Concurrency Code")) then
            exit(false);

        if (AdmissionGroupConcurrency."Concurrency Type" = AdmissionGroupConcurrency."Concurrency Type"::NA) then
            exit(false);

        if (AdmissionGroupConcurrency."Total Capacity" = 0) then
            exit(false);

        ActualCount := 0;
        MaxCount := AdmissionGroupConcurrency."Total Capacity";

        AdmissionSchedule.Reset();
        AdmissionSchedule.SetFilter("Concurrency Code", '=%1', AdmissionSchedule."Concurrency Code");

        case AdmissionGroupConcurrency."Concurrency Type" of
            AdmissionGroupConcurrency."Concurrency Type"::CONCURRENCY_CODE:
                ;
            AdmissionGroupConcurrency."Concurrency Type"::ADMISSION:
                AdmissionSchedule.SetFilter("Admission Code", '=%1', AdmissionCode);
            AdmissionGroupConcurrency."Concurrency Type"::SCHEDULE:
                AdmissionSchedule.SetFilter("Schedule Code", '=%1', ScheduleCode);
        end;

        if (AdmissionSchedule.FindSet()) then begin
            repeat
                AdmissionScheduleEntry.Reset();
                AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionSchedule."Admission Code");
                AdmissionScheduleEntry.SetFilter("Schedule Code", '=%1', AdmissionSchedule."Schedule Code");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReferenceDate);
                if (AdmissionScheduleEntry.FindLast()) then
                    ActualCount += CalculateCurrentCapacity(AdmissionGroupConcurrency."Capacity Control", AdmissionScheduleEntry."Entry No.");

            until (AdmissionSchedule.Next() = 0);
        end;

        exit(true);
    end;

    local procedure ValidateTicketConstraintsExceeded(TicketAccessEntryNo: Integer)
    var
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        AdmittedCount: Integer;
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        CapacityExceeded: Boolean;
        FirstAccessDate: Date;
        LastAccessDate: Date;
        EntryValidation: Option UNDEFINED,SINGLE,SAME_DAY,MULTIPLE;
        MaxNoOfEntries: Integer;
        FirstLastEntryDurationFormula: DateFormula;
        FirstAccessTime: Time;
        LastAccessTime: Time;
    begin
        // This function should be called after the entry transaction have been created
        // That will allow us to catch a zero count as an error
        TicketAccessEntry.Get(TicketAccessEntryNo);
        Ticket.Get(TicketAccessEntry."Ticket No.");
        TicketBOM.Get(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code");

        if (TicketBOM.Quantity = 0) then
            TicketBOM.Quantity := 1;

        TicketType.Get(TicketAccessEntry."Ticket Type Code");
        GetEntryValidationConstraints(TicketType, TicketBOM, EntryValidation, MaxNoOfEntries, FirstLastEntryDurationFormula);

        DetailedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type, Open);
        DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetailedTicketAccessEntry.SetFilter(Type, '=%1', DetailedTicketAccessEntry.Type::ADMITTED);
        DetailedTicketAccessEntry.SetFilter(Open, '=%1', true);

        AdmittedCount := DetailedTicketAccessEntry.Count() * TicketAccessEntry.Quantity;

        if (AdmittedCount = 0) then
            Error(UNEXPECTED, DetailedTicketAccessEntry.TableCaption(), TicketAccessEntry."Admission Code", AdmittedCount, SHOULD_NOT_BE_ZERO, 0, 0);

        DetailedTicketAccessEntry.FindFirst();
        CapacityExceeded := false;

        case EntryValidation of
            EntryValidation::SINGLE:
                begin
                    // Number of simultaneous open entries may not exceed the quantity on ticket access bom
                    CapacityExceeded := (AdmittedCount > TicketAccessEntry.Quantity);

                    // and we cant allow access on different dates
                    DetailedTicketAccessEntry.SetFilter(Open, '');
                    FirstAccessDate := DT2Date(DetailedTicketAccessEntry."Created Datetime");
                    FirstAccessTime := DT2Time(DetailedTicketAccessEntry."Created Datetime");

                    DetailedTicketAccessEntry.FindLast();
                    LastAccessDate := DT2Date(DetailedTicketAccessEntry."Created Datetime");
                    LastAccessTime := DT2Time(DetailedTicketAccessEntry."Created Datetime");

                    CapacityExceeded := CapacityExceeded or (FirstAccessDate <> LastAccessDate);

                    if ((CapacityExceeded) and (FirstAccessDate = LastAccessDate)) then begin
                        case TicketBOM."Allow Rescan Within (Sec.)" of
                            TicketBOM."Allow Rescan Within (Sec.)"::"15":
                                CapacityExceeded := ((LastAccessTime - FirstAccessTime) > 15000);
                            TicketBOM."Allow Rescan Within (Sec.)"::"30":
                                CapacityExceeded := (LastAccessTime - FirstAccessTime) > 30000;
                            TicketBOM."Allow Rescan Within (Sec.)"::"60":
                                CapacityExceeded := (LastAccessTime - FirstAccessTime) > 60000;
                            TicketBOM."Allow Rescan Within (Sec.)"::"120":
                                CapacityExceeded := (LastAccessTime - FirstAccessTime) > 120000;
                        end;
                        if (not CapacityExceeded) then begin
                            if (MaxNoOfEntries > 1) then
                                CapacityExceeded := (AdmittedCount > MaxNoOfEntries);
                        end;
                    end;
                end;

            EntryValidation::SAME_DAY:
                begin
                    // we cant allow access on different dates
                    DetailedTicketAccessEntry.SetFilter(Open, '');
                    FirstAccessDate := DT2Date(DetailedTicketAccessEntry."Created Datetime");
                    DetailedTicketAccessEntry.FindLast();
                    LastAccessDate := DT2Date(DetailedTicketAccessEntry."Created Datetime");
                    CapacityExceeded := (FirstAccessDate <> LastAccessDate);

                    if (not CapacityExceeded) and (MaxNoOfEntries > 0) then begin
                        AdmittedCount := DetailedTicketAccessEntry.Count();
                        CapacityExceeded := (AdmittedCount > MaxNoOfEntries);
                    end;

                end;

            EntryValidation::MULTIPLE:
                begin
                    // Total number of entries may not exceed
                    DetailedTicketAccessEntry.SetFilter(Open, '');
                    AdmittedCount := DetailedTicketAccessEntry.Count();
                    CapacityExceeded := (AdmittedCount > MaxNoOfEntries);

                    FirstAccessDate := DT2Date(DetailedTicketAccessEntry."Created Datetime");
                    DetailedTicketAccessEntry.FindLast();
                    LastAccessDate := DT2Date(DetailedTicketAccessEntry."Created Datetime");
                end;
            else
                Error(UNSUPPORTED_VALIDATION_METHOD);
        end;

        if (CapacityExceeded) then
            RaiseError(StrSubstNo(CAPACITY_EXCEEDED, Ticket."External Ticket No."), CAPACITY_EXCEEDED_NO);

        // Check if date of access violates ticket validity
        if (FirstAccessDate < Ticket."Valid From Date") then
            RaiseError(StrSubstNo(TICKET_NOT_VALID_YET, Ticket."External Ticket No.", Ticket."Valid From Date"), TICKET_NOT_VALID_YET_NO);

        if (LastAccessDate > Ticket."Valid To Date") then
            RaiseError(StrSubstNo(TICKET_EXPIRED, Ticket."External Ticket No.", Ticket."Valid To Date"), TICKET_EXPIRED_NO);

        ValidateTicketBaseCalendar(TicketAccessEntry."Admission Code", Ticket."Item No.", Ticket."Variant Code", LastAccessDate);
    end;

    local procedure ValidateReservationCapacityExceeded(Ticket: Record "NPR TM Ticket"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry")
    var
        Admission: Record "NPR TM Admission";
        AdmissionText: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
        AdmissionSchedule: Record "NPR TM Admis. Schedule Lines";
        AdmittedCount: Integer;
        CapacityExceeded: Boolean;
        MaxCapacity: Integer;
        CapacityControl: Option;
        DateTimeLbl: Label '%1  - %2', Locked = true;
    begin
        Admission.Get(AdmissionScheduleEntry."Admission Code");
        CapacityExceeded := false;
        if (Admission.Type <> Admission.Type::OCCASION) then
            exit;

        Schedule.Get(AdmissionScheduleEntry."Schedule Code");
        AdmissionSchedule.Get(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code");

        GetTicketCapacity(Ticket."Item No.", Ticket."Variant Code", Admission."Admission Code", Schedule."Schedule Code", AdmissionScheduleEntry."Entry No.", MaxCapacity, CapacityControl);

        AdmissionText."Capacity Control" := CapacityControl;

        case CapacityControl of
            Admission."Capacity Control"::NONE:
                exit;

            Admission."Capacity Control"::SALES:
                begin
                    // Performance / Deadlock. SUM (x) flowfield issues SQL with statement for repeatable read "with(UPDLOCK)"
                    // TODO
                    AdmissionScheduleEntry.CalcFields("Open Reservations (All)");
                    AdmittedCount := AdmissionScheduleEntry."Open Reservations (All)";
                end;

            Admission."Capacity Control"::ADMITTED, // Admitted and Full mode are the same when it comes to reservations
            Admission."Capacity Control"::FULL:
                begin
                    // Performance / Deadlock. SUM (x) flowfield issues SQL with statement for repeatable read "with(UPDLOCK)"
                    // TODO
                    AdmissionScheduleEntry.CalcFields("Open Reservations", "Open Admitted");
                    AdmittedCount := AdmissionScheduleEntry."Open Admitted" + AdmissionScheduleEntry."Open Reservations";
                end;

            Admission."Capacity Control"::SEATING:
                begin
                    AdmissionScheduleEntry.CalcFields("Open Reservations", "Open Admitted");
                    AdmittedCount := AdmissionScheduleEntry."Open Admitted" + AdmissionScheduleEntry."Open Reservations";
                end;

            else
                Error(UNSUPPORTED_VALIDATION_METHOD);
        end;

        if (AdmittedCount = 0) then
            Error(UNEXPECTED, AdmissionScheduleEntry.TableCaption(), Admission."Admission Code", AdmittedCount, SHOULD_NOT_BE_ZERO, 0, 0);

        CapacityExceeded := (AdmittedCount > MaxCapacity);

        if (CapacityExceeded) then
            RaiseError(StrSubstNo(RESERVATION_EXCEEDED, Admission."Admission Code",
                StrSubstNo(DateTimeLbl, AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time"),
                MaxCapacity, AdmissionText."Capacity Control", AdmittedCount), RESERVATION_EXCEEDED_NO);
        exit;
    end;

    local procedure ValidateTicketAdmissionReservationDate(TicketAccessEntryNo: Integer; AdmissionScheduleEntryNo: Integer)
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        TicketAccessEntry.Get(TicketAccessEntryNo);
        ScheduleEntry.Get(AdmissionScheduleEntryNo);
        Ticket.Get(TicketAccessEntry."Ticket No.");

        if ((ScheduleEntry."Admission Start Date" < Ticket."Valid From Date") or
            (ScheduleEntry."Admission Start Date" > Ticket."Valid To Date")) then
            RaiseError(StrSubstNo(NOT_VALID, Ticket."No.", ScheduleEntry."Admission Start Date"), NOT_VALID_NO);
    end;

    local procedure CheckTicketBaseCalendarWorker(AdmissionCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionDate: Date; var NonWorking: Boolean; var ResponseMessage: Text)
    var
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        TempCustomizedCalendarChange: Record "Customized Calendar Change" temporary;
        CalendarManagement: Codeunit "Calendar Management";
        CalendarDesc: Text;
    begin
        ResponseMessage := '';
        NonWorking := false;

        if (TicketBOM.Get(ItemNo, VariantCode, AdmissionCode)) then
            if (TicketBOM."Ticket Base Calendar Code" <> '') then begin
                TempCustomizedCalendarChange.Init();
                TempCustomizedCalendarChange."Source Type" := TempCustomizedCalendarChange."Source Type"::Service;
                TempCustomizedCalendarChange."Base Calendar Code" := TicketBOM."Ticket Base Calendar Code";
                TempCustomizedCalendarChange."Date" := AdmissionDate;
                TempCustomizedCalendarChange.Description := CopyStr(CalendarDesc, 1, MaxStrLen(TempCustomizedCalendarChange.Description));
                TempCustomizedCalendarChange."Source Code" := AdmissionCode;
                TempCustomizedCalendarChange.Insert();

                CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);
                NonWorking := TempCustomizedCalendarChange.Nonworking;
                CalendarDesc := TempCustomizedCalendarChange.Description;

                if (not TempCustomizedCalendarChange.Nonworking) then begin
                    TempCustomizedCalendarChange.DeleteAll();
                    TempCustomizedCalendarChange.Init();
                    TempCustomizedCalendarChange."Source Type" := TempCustomizedCalendarChange."Source Type"::Service;
                    TempCustomizedCalendarChange."Base Calendar Code" := TicketBOM."Ticket Base Calendar Code";
                    TempCustomizedCalendarChange."Date" := AdmissionDate;
                    TempCustomizedCalendarChange.Description := CopyStr(CalendarDesc, 1, MaxStrLen(TempCustomizedCalendarChange.Description));
                    TempCustomizedCalendarChange."Source Code" := AdmissionCode;
                    TempCustomizedCalendarChange."Additional Source Code" := ItemNo;
                    TempCustomizedCalendarChange.Insert();

                    CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);
                    NonWorking := TempCustomizedCalendarChange.Nonworking;
                    CalendarDesc := TempCustomizedCalendarChange.Description;
                end;
            end;

        if (not NonWorking) then
            if (Admission.Get(AdmissionCode)) then
                if (Admission."Ticket Base Calendar Code" <> '') then begin
                    TempCustomizedCalendarChange.DeleteAll();
                    TempCustomizedCalendarChange.Init();
                    TempCustomizedCalendarChange."Source Type" := TempCustomizedCalendarChange."Source Type"::Service;
                    TempCustomizedCalendarChange."Base Calendar Code" := Admission."Ticket Base Calendar Code";
                    TempCustomizedCalendarChange."Date" := AdmissionDate;
                    TempCustomizedCalendarChange.Description := CopyStr(CalendarDesc, 1, MaxStrLen(TempCustomizedCalendarChange.Description));
                    TempCustomizedCalendarChange."Source Code" := AdmissionCode;
                    TempCustomizedCalendarChange.Insert();

                    CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);
                    NonWorking := TempCustomizedCalendarChange.Nonworking;
                    CalendarDesc := TempCustomizedCalendarChange.Description;
                end;


        if (NonWorking) then
            if (CalendarDesc = '') then
                CalendarDesc := StrSubstNo(TICKET_CALENDAR, ItemNo, VariantCode, AdmissionCode, AdmissionDate);

        ResponseMessage := CalendarDesc;

    end;

    procedure CheckTicketBaseCalendar(AdmissionCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionDate: Date; var NonWorking: Boolean; var ResponseMessage: Text)
    begin
        CheckTicketBaseCalendarWorker(AdmissionCode, ItemNo, VariantCode, AdmissionDate, NonWorking, ResponseMessage);
    end;

    procedure ValidateTicketBaseCalendar(AdmissionCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionDate: Date)
    var
        ResponseMessage: Text;
        NonWorking: Boolean;
    begin
        CheckTicketBaseCalendarWorker(AdmissionCode, ItemNo, VariantCode, AdmissionDate, NonWorking, ResponseMessage);
        if (NonWorking) then
            Error(ResponseMessage);
    end;

    local procedure GetEntryValidationConstraints(TicketType: Record "NPR TM Ticket Type"; TicketBom: Record "NPR TM Ticket Admission BOM"; var EntryValidationType: Option UNDEFINED,SINGLE,SAME_DAY,MULTIPLE; var MaxEntryCount: Integer; var TimespanFormula: DateFormula)
    begin
        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then begin
            case TicketBom."Admission Entry Validation" of
                TicketBom."Admission Entry Validation"::SINGLE:
                    EntryValidationType := EntryValidationType::SINGLE;
                TicketBom."Admission Entry Validation"::SAME_DAY:
                    EntryValidationType := EntryValidationType::SAME_DAY;
                TicketBom."Admission Entry Validation"::MULTIPLE:
                    EntryValidationType := EntryValidationType::MULTIPLE;
                else
                    EntryValidationType := EntryValidationType::UNDEFINED;
            end;
            MaxEntryCount := TicketBom."Max No. Of Entries";
            TimespanFormula := TicketBom."Duration Formula";
        end;

        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_TYPE) then begin
            case TicketType."Ticket Entry Validation" of
                TicketType."Ticket Entry Validation"::SINGLE:
                    EntryValidationType := EntryValidationType::SINGLE;
                TicketType."Ticket Entry Validation"::SAME_DAY:
                    EntryValidationType := EntryValidationType::SAME_DAY;
                TicketType."Ticket Entry Validation"::MULTIPLE:
                    EntryValidationType := EntryValidationType::MULTIPLE;
                else
                    EntryValidationType := EntryValidationType::UNDEFINED;
            end;
            MaxEntryCount := TicketType."Max No. Of Entries";
            TimespanFormula := TicketType."Duration Formula";
        end;
    end;

    procedure HandlePostpaidTickets(PreviewDocument: Boolean)
    var
        TempTicket: Record "NPR TM Ticket" temporary;
        TempAggregatedPerRequest: Record "NPR TM Ticket Access Entry" temporary;
        TempAdmissionPerDate: Record "NPR TM Det. Ticket AccessEntry" temporary;
        TempDetailedAccessEntries: Record "NPR TM Det. Ticket AccessEntry" temporary;
        FirstInvoiceNo: Code[20];
        LastInvoiceNo: Code[20];
        InvoiceDetailsMessage: Text;
        ShowDialog: Boolean;
        FromToInvLbl: Label '{%1..%2}', Locked = true;
    begin
        if (not Confirm(HANDLE_POSTPAID)) then
            Error('');

        ShowDialog := (true and GuiAllowed());

        if (ShowDialog) then
            gWindow.Open(HANDLE_POSTPAID_STATUS);

        CollectUnhandledPostpaidTickets(ShowDialog, TempTicket, TempDetailedAccessEntries);
        AggregatePaymentEntries(ShowDialog, TempTicket, TempAggregatedPerRequest, TempAdmissionPerDate);

        if (not PreviewDocument) then begin
            CreatePostpaidTicketInvoice(ShowDialog, TempAggregatedPerRequest, TempAdmissionPerDate);
            MarkPostpaidTicketAsInvoiced(ShowDialog, TempDetailedAccessEntries, TempAggregatedPerRequest, TempTicket);
            if (not TempAggregatedPerRequest.IsEmpty()) then begin
                TempAggregatedPerRequest.FindFirst();
                FirstInvoiceNo := CopyStr(TempAggregatedPerRequest.Description, 1, 20);
                TempAggregatedPerRequest.FindLast();
                LastInvoiceNo := CopyStr(TempAggregatedPerRequest.Description, 1, 20);
                InvoiceDetailsMessage := StrSubstNo(FromToInvLbl, FirstInvoiceNo, LastInvoiceNo);
            end;
        end;

        if (ShowDialog) then
            gWindow.Close();

        Message(POSTPAID_RESULT, TempTicket.Count(), TempAggregatedPerRequest.Count(), InvoiceDetailsMessage);
    end;

    local procedure CollectUnhandledPostpaidTickets(ShowDialog: Boolean; var TmpPostpaidTickets: Record "NPR TM Ticket" temporary; var TmpDetailedAccessEntries: Record "NPR TM Det. Ticket AccessEntry" temporary)
    var
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        DetTicketAccessEntry2: Record "NPR TM Det. Ticket AccessEntry";
        Ticket: Record "NPR TM Ticket";
        CollectPayment: Boolean;
        MaxCount: Integer;
        Index: Integer;
    begin
        DetTicketAccessEntry.SetCurrentKey(Type, Open, "Posting Date");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::POSTPAID);
        DetTicketAccessEntry.SetFilter(Open, '=%1', true);

        DetTicketAccessEntry2.SetCurrentKey("Ticket Access Entry No.", Type);
        if (DetTicketAccessEntry.FindSet()) then begin
            MaxCount := DetTicketAccessEntry.Count();
            Index := 0;
            if (ShowDialog) then
                gWindow.Update(1, POSTPAID_COLLECT);

            repeat
                DetTicketAccessEntry2.SetFilter("Ticket Access Entry No.", '=%1', DetTicketAccessEntry."Ticket Access Entry No.");
                DetTicketAccessEntry2.SetFilter(Type, '=%1|=%2', DetTicketAccessEntry2.Type::ADMITTED, DetTicketAccessEntry2.Type::CANCELED_ADMISSION);
                CollectPayment := (not DetTicketAccessEntry2.IsEmpty());

                if (CollectPayment) then begin
                    Ticket.Get(DetTicketAccessEntry."Ticket No.");
                    TmpPostpaidTickets.TransferFields(Ticket, true);
                    if (not TmpPostpaidTickets.Insert()) then;

                    TmpDetailedAccessEntries.TransferFields(DetTicketAccessEntry, true);
                    TmpDetailedAccessEntries.Insert();
                end;

                Index += 1;
                if (ShowDialog) then
                    if ((Index mod (MaxCount + 100 div 100) = 0)) then
                        gWindow.Update(2, Round(Index / MaxCount * 10000, 1));

            until (DetTicketAccessEntry.Next() = 0);
        end;
    end;

    local procedure AggregatePaymentEntries(ShowDialog: Boolean; var TmpPostpaidTickets: Record "NPR TM Ticket" temporary; var TmpAggregatedPerRequest: Record "NPR TM Ticket Access Entry" temporary; var TmpAdmissionsPerDate: Record "NPR TM Det. Ticket AccessEntry" temporary)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        EntryNo: Integer;
        MaxCount: Integer;
        Index: Integer;
    begin
        TmpPostpaidTickets.Reset();
        if (TmpPostpaidTickets.IsEmpty()) then
            exit;

        TmpAggregatedPerRequest.Reset();
        TmpAggregatedPerRequest.DeleteAll();

        // Ticket Access Entry and Detailed Ticket Access Entry are
        // not ideal to aggregate over because the terminolgy for fields are wrong

        TmpPostpaidTickets.FindSet();
        repeat

            MaxCount := TmpPostpaidTickets.Count();
            Index := 0;
            if (ShowDialog) then
                gWindow.Update(1, POSTPAID_AGGREGATE);

            TicketAccessEntry.SetFilter("Ticket No.", '=%1', TmpPostpaidTickets."No.");
            if (TicketAccessEntry.FindFirst()) then begin

                if (TicketReservationRequest.Get(TmpPostpaidTickets."Ticket Reservation Entry No.")) then begin

                    if (TmpAggregatedPerRequest.Get(TmpPostpaidTickets."Ticket Reservation Entry No.")) then begin
                        TmpAggregatedPerRequest.Quantity += TicketAccessEntry.Quantity;
                        TmpAggregatedPerRequest.Modify();

                    end else begin
                        TmpAggregatedPerRequest.Init();
                        TmpAggregatedPerRequest."Entry No." := TmpPostpaidTickets."Ticket Reservation Entry No.";
                        TmpAggregatedPerRequest.Quantity := TicketAccessEntry.Quantity;
                        TmpAggregatedPerRequest."Customer No." := TicketAccessEntry."Customer No.";
                        if (TmpAggregatedPerRequest."Customer No." <> '') then
                            TmpAggregatedPerRequest.Insert();
                    end;

                    TmpAdmissionsPerDate.SetFilter("Ticket Access Entry No.", '=%1', TmpAggregatedPerRequest."Entry No.");
                    TmpAdmissionsPerDate.SetFilter("Posting Date", '=%1', TicketAccessEntry."Access Date");
                    if (TmpAdmissionsPerDate.FindFirst()) then begin
                        TmpAdmissionsPerDate.Quantity += TicketAccessEntry.Quantity;
                        TmpAdmissionsPerDate.Modify();

                    end else begin
                        EntryNo += 1;
                        TmpAdmissionsPerDate."Entry No." := EntryNo;
                        TmpAdmissionsPerDate."Ticket Access Entry No." := TmpAggregatedPerRequest."Entry No.";
                        TmpAdmissionsPerDate."Posting Date" := TicketAccessEntry."Access Date";
                        TmpAdmissionsPerDate.Quantity := TicketAccessEntry.Quantity;
                        TmpAdmissionsPerDate."Ticket No." := TicketAccessEntry."Ticket No.";
                        TmpAdmissionsPerDate.Insert();
                    end;
                end;
            end;

            Index += 1;
            if (ShowDialog) then
                if ((Index mod (MaxCount + 100 div 100) = 0)) then
                    gWindow.Update(2, Round(Index / MaxCount * 10000, 1));

        until (TmpPostpaidTickets.Next() = 0);
    end;

    local procedure CreatePostpaidTicketInvoice(ShowDialog: Boolean; var TmpAggregatedPerRequest: Record "NPR TM Ticket Access Entry" temporary; var TmpAdmissionsPerDate: Record "NPR TM Det. Ticket AccessEntry" temporary)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LineNo: Integer;
        MaxCount: Integer;
        Index: Integer;
    begin
        TmpAggregatedPerRequest.Reset();
        if (not TmpAggregatedPerRequest.FindSet()) then
            exit;

        MaxCount := TmpAggregatedPerRequest.Count();
        Index := 0;
        if (ShowDialog) then
            gWindow.Update(1, POSTPAID_INVOICE);

        repeat
            if (TicketReservationRequest.Get(TmpAggregatedPerRequest."Entry No.")) then begin
                SalesHeader.Init();
                SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
                SalesHeader."No." := '';
                SalesHeader.Insert(true);

                SalesHeader.SetHideValidationDialog(true);
                SalesHeader.Validate("Sell-to Customer No.", TmpAggregatedPerRequest."Customer No.");
                SalesHeader."NPR External Order No." := TicketReservationRequest."External Order No.";
                SalesHeader."External Document No." := TicketReservationRequest."External Order No.";
                SalesHeader.Modify(true);

                TmpAggregatedPerRequest.Description := SalesHeader."No.";
                TmpAggregatedPerRequest.Modify();

                TmpAdmissionsPerDate.Reset();
                TmpAdmissionsPerDate.SetFilter("Ticket Access Entry No.", '=%1', TmpAggregatedPerRequest."Entry No.");
                LineNo := 0;
                if (TmpAdmissionsPerDate.FindSet()) then begin
                    repeat
                        LineNo += 10000;
                        SalesLine."Document Type" := SalesHeader."Document Type";
                        SalesLine."Document No." := SalesHeader."No.";
                        SalesLine."Line No." := LineNo;
                        SalesLine.Insert(true);

                        SalesLine.Type := SalesLine.Type::Item;
                        SalesLine.Validate("No.", TicketReservationRequest."Item No.");
                        SalesLine.Validate("Variant Code", TicketReservationRequest."Variant Code");

                        SalesLine.Validate(Quantity, TmpAdmissionsPerDate.Quantity);
                        SalesLine.Description := StrSubstNo(INVOICE_TEXT2, TmpAdmissionsPerDate."Posting Date", TmpAdmissionsPerDate."Ticket No.");
                        SalesLine.Modify(true);
                    until (TmpAdmissionsPerDate.Next() = 0);
                end;
            end;

            Index += 1;
            if (ShowDialog) then
                if ((Index mod (MaxCount + 100 div 100) = 0)) then
                    gWindow.Update(2, Round(Index / MaxCount * 10000, 1));

        until (TmpAggregatedPerRequest.Next() = 0);
    end;

    local procedure MarkPostpaidTicketAsInvoiced(ShowDialog: Boolean; var TmpDetailedAccessEntries: Record "NPR TM Det. Ticket AccessEntry" temporary; var TmpAggregatedPerRequest: Record "NPR TM Ticket Access Entry" temporary; var TmpTicket: Record "NPR TM Ticket" temporary)
    var
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        MaxCount: Integer;
        Index: Integer;
    begin
        TmpDetailedAccessEntries.Reset();
        if (TmpDetailedAccessEntries.IsEmpty()) then
            exit;

        TmpTicket.Reset();
        TmpAggregatedPerRequest.Reset();

        MaxCount := TmpDetailedAccessEntries.Count();
        Index := 0;
        if (ShowDialog) then
            gWindow.Update(1, POSTPAID_UPDATING);

        TmpDetailedAccessEntries.FindSet();
        repeat
            DetTicketAccessEntry.Get(TmpDetailedAccessEntries."Entry No.");
            TmpTicket.Get(TmpDetailedAccessEntries."Ticket No.");

            if (TmpAggregatedPerRequest.Get(TmpTicket."Ticket Reservation Entry No.")) then begin
                // if the request is missing vital data (customer no) it will not aggregate, no invoice created, no payment was claimed
                DetTicketAccessEntry.Open := false;
                DetTicketAccessEntry."Scanner Station ID" := TmpAggregatedPerRequest.Description; // Invoice number
            end;

            DetTicketAccessEntry.Modify();

            Index += 1;
            if (ShowDialog) then
                if ((Index mod (MaxCount + 100 div 100) = 0)) then
                    gWindow.Update(2, Round(Index / MaxCount * 10000, 1));

        until (TmpDetailedAccessEntries.Next() = 0);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDetailedTicketEvent(DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSelloutThresholdReached(SellOutEventType: Option NA,TICKET,WAITINGLIST; Ticket: Record "npr tm ticket"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; AdmittedCount: Integer; MaxCapacity: Integer);
    begin
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', true, true)]
    local procedure OnAfterNavigateFindRecordsSubscriber(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        SalesInvHeader: Record "Sales Invoice Header";
        RowsFound: Integer;
    begin
        if (Ticket.ReadPermission()) then begin
            if (not Ticket.SetCurrentKey("Sales Receipt No.")) then;
            Ticket.SetFilter("Sales Receipt No.", '%1', DocNoFilter);
            InsertIntoDocEntry(DocumentEntry, Database::"NPR TM Ticket", 0, CopyStr(DocNoFilter, 1, 20), Ticket.TableCaption(), Ticket.Count());

            if (not TicketReservationReq.SetCurrentKey("External Order No.")) then;
            SalesInvHeader.SetFilter("No.", '%1', DocNoFilter);
            if (SalesInvHeader.FindFirst()) then begin
                if (SalesInvHeader."External Document No." <> '') then begin
                    TicketReservationReq.SetFilter("External Order No.", '%1', SalesInvHeader."External Document No.");
                end;
                if ((RowsFound = 0) and (SalesInvHeader."NPR External Order No." <> '')) then begin
                    TicketReservationReq.SetFilter("External Order No.", '%1', SalesInvHeader."NPR External Order No.");
                    RowsFound := InsertIntoDocEntry(DocumentEntry, Database::"NPR TM Ticket Reservation Req.", 0, SalesInvHeader."NPR External Order No.", TicketReservationReq.TableCaption(), TicketReservationReq.Count());
                    RowsFound := InsertIntoDocEntry(DocumentEntry, Database::"NPR TM Ticket Reservation Req.", 0, CopyStr(SalesInvHeader."External Document No.", 1, 20), TicketReservationReq.TableCaption(), TicketReservationReq.Count());
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateShowRecords', '', true, true)]
    local procedure OnAfterNavigateShowRecordsSubscriber(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean)
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if (TableID = Database::"NPR TM Ticket") then begin
            if (not Ticket.SetCurrentKey("Sales Receipt No.")) then;
            Ticket.SetFilter("Sales Receipt No.", DocNoFilter);
            if (Ticket.IsEmpty()) then
                exit;
            Page.Run(Page::"NPR TM Ticket List", Ticket);
        end;

        if (TableID = Database::"NPR TM Ticket Reservation Req.") then begin
            if (not TicketReservationReq.SetCurrentKey("External Order No.")) then;
            if (SalesInvHeader.Get(DocNoFilter)) then begin
                TicketReservationReq.SetFilter("External Order No.", SalesInvHeader."External Document No.");
                if (not TicketReservationReq.IsEmpty()) then
                    exit;
                Page.Run(Page::"NPR TM Ticket Request", TicketReservationReq);
            end;
        end
    end;

    local procedure InsertIntoDocEntry(var DocumentEntry: Record "Document Entry" temporary; DocTableID: Integer; DocType: Integer; DocNoFilter: Code[20]; DocTableName: Text; DocNoOfRecords: Integer): Integer
    begin
        if (DocNoOfRecords = 0) then
            exit(DocNoOfRecords);

        DocumentEntry.Init();
        DocumentEntry."Entry No." := DocumentEntry."Entry No." + 1;
        DocumentEntry."Table ID" := DocTableID;
#if BC17         
        DocumentEntry."Document Type" := DocType;
#else        
        DocumentEntry."Document Type" := "Document Entry Document Type".FromInteger(DocType);
#endif
        DocumentEntry."Document No." := DocNoFilter;
        DocumentEntry."Table Name" := CopyStr(DocTableName, 1, MaxStrLen(DocumentEntry."Table Name"));
        DocumentEntry."No. of Records" := DocNoOfRecords;
        if (not DocumentEntry.Insert()) then;

        exit(DocNoOfRecords);
    end;
}

