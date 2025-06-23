codeunit 6059784 "NPR TM Ticket Management"
{
    Access = Internal;

    var

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

        HAS_PAYMENT: Label 'Ticket %1 does not permit changes to quantity after payment.';
        TICKET_CANCELED: Label 'Ticket %1 has been canceled and is not valid.';
        ADMISSION_MISMATCH: Label 'The Schedule Entry %1 is for admission to %2, but the Ticket Access Entry requires %3.';
        NO_SCHEDULE_FOR_ADM: Label 'There is no valid admission schedule available for %1 today.';
        NO_ADMISSION_CODE: Label 'No admission code was specified and no admission code was marked as default for item %1.';
        TICKET_NOT_VALID_YET: Label 'Ticket %1 is not valid until %2.';
        TICKET_EXPIRED: Label 'Ticket %1 expired on %2.';
        SHOULD_NOT_BE_ZERO: Label 'Should not be zero.';
        SCHEDULE_ENTRY_EXPIRED: Label 'The schedule entry %1 specifies a time in the past (%2) and cant be used for ticket reservation at this time (%3).';
        TICKET_CALENDAR: Label 'Ticket calendar defined for %1 %2 %3 states that ticket is not valid for %4.';
        RESERVATION_NOT_FOR_NOW: Label 'The ticket reservation for %4 allows admission from %1 until %2 on %3.\\Current time is: %5';
        RESCHEDULE_NOT_ALLOWED: Label 'The ticket reschedule policy for %1 and %2, prevents changes at this time.';
        INVALID_ADMISSION_CODE: Label 'Ticket %1 does not contain entry for admission code %2.';
        NO_DEFAULT_ADMISSION_SELECTED: Label 'When ticket is scanned and no admission code is specified, system attempts to find a default admission. With current setup, a default admission could not be found for item %1.';
        DURATION_EXCEEDED: Label 'The duration set for admission %1 expired at %2.';
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
        NO_DEFAULT_SCHEDULE_NO: Label '-1021';
        MISSING_PAYMENT_NO: Label '-1022';
        SCHEDULE_ENTRY_EXPIRED_NO: Label '-1023';
        SCHEDULE_ENTRY_EXPIRED_NO2: Label '-1024';
        SCHEDULE_ENTRY_EXPIRED_NO3: Label '-1025';
        RESERVATION_NOT_FOR_NOW_NO: Label '-1028';
        CONCURRENT_CAPACITY_EXCEEDED_NO: Label '-1030';
        RESCHEDULE_NOT_ALLOWED_NO: Label '-1031';
        INVALID_ADMISSION_CODE_NO: Label '-1032';
        HAS_PAYMENT_NO: Label '-1033';
        ENTRY_NOT_FOUND_NO: Label '-1034';
        DURATION_EXCEEDED_NO: Label '-1035';
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
        CONFIRM_EXCEED_CAPACITY: Label 'Capacity for %1 will be exceeded. Do you want to continue?';
        _TicketExecutionContext: Option SALES,ADMISSION;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        _FeatureFlagManagement: Codeunit "NPR Feature Flags Management";
#endif

    /**
    * Finalize ticket from end of sale
    **/
    [EventSubscriber(ObjectType::"Codeunit", Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSSalesLine', '', true, true)]
    local procedure ConfirmTicketsFromPosEntrySaleLine(POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        Token: Text[100];
        TokenLineNumber: Integer;
        TicketAction: Codeunit "NPR POS Action - Ticket Mgt B.";
        ListPriceInclVat: Decimal;
        ListPriceExclVat: Decimal;
    begin
        if (not TicketAction.GetRequestToken(POSEntry."Document No.", POSSalesLine."Line No.", Token, TokenLineNumber)) then
            exit;

        if (POSEntry."Prices Including VAT") then begin
            ListPriceInclVat := POSSalesLine."Unit Price";
            ListPriceExclVat := POSSalesLine."Unit Price" / (1 + (POSSalesLine."VAT %") / 100);
        end else begin
            ListPriceInclVat := POSSalesLine."Unit Price" * (1 + (POSSalesLine."VAT %") / 100);
            ListPriceExclVat := POSSalesLine."Unit Price";
        end;
        ConfirmAndAdmitTicketsFromToken(Token, TokenLineNumber, POSEntry."Document No.", POSSalesLine."Line No.", POSEntry."POS Unit No.",
            POSSalesLine."Amount Incl. VAT (LCY)" / POSSalesLine.Quantity, POSSalesLine."Amount Excl. VAT (LCY)" / POSSalesLine.Quantity,
            ListPriceInclVat, ListPriceExclVat);
    end;

    procedure ConfirmAndAdmitTicketsFromToken(Token: Text[100]; TokenLineNumber: Integer; SalesReceiptNo: Code[20]; SalesLineNo: Integer; PosUnitNo: Code[10]; UnitAmountInclVat: Decimal; UnitAmountExclVat: Decimal; UnitPriceInclVat: Decimal; UnitPriceExclVat: Decimal)
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Ticket: Record "NPR TM Ticket";
        ResponseMessage: Text;
        IsCheckedBySubscriber: Boolean;
        IsValid: Boolean;
    begin
        TicketRequestManager.LockResources('IssueTicketsFromToken');

        if (TicketRequestManager.IsChangeRequest(Token)) then begin
            TicketRequestManager.ConfirmReservationRequestWithValidate(Token, TokenLineNumber);
        end;

        if (TicketRequestManager.IsReservationRequest(Token)) then begin

            Ticket.Reset();
            Ticket.SetCurrentKey("Sales Receipt No.");
            Ticket.SetFilter("Sales Receipt No.", '=%1', SalesReceiptNo);
            Ticket.SetFilter("Line No.", '=%1', SalesLineNo);
            if (Ticket.FindSet()) then begin

                TicketRequestManager.ConfirmReservationRequestWithValidate(Token, TokenLineNumber);
                repeat

                    Ticket.AmountInclVat := UnitAmountInclVat;
                    Ticket.AmountExclVat := UnitAmountExclVat;
                    Ticket.ListPriceInclVat := UnitPriceInclVat;
                    Ticket.ListPriceExclVat := UnitPriceExclVat;
                    Ticket.Modify();

                    if (not AdmitTicketsFromWorkflowOnEndSale(PosUnitNo)) then
                        AdmitTicketFromEndOfSale(Token, Ticket, PosUnitNo);

                until (Ticket.Next() = 0);
            end;
        end;

        if (TicketRequestManager.IsRevokeRequest(Token)) then begin
            TicketRequestManager.RevokeReservationTokenRequest(Token, false);

            OnAfterPosTicketRevoke(IsCheckedBySubscriber, IsValid, Token, ResponseMessage);
        end;
    end;

    internal procedure AdmitTicketFromEndOfSale(Token: Text[100]; Ticket: Record "NPR TM Ticket"; PosUnitNo: Code[10]) Admitted: Boolean
    var
        TicketType: Record "NPR TM Ticket Type";
        ResponseMessage: Text;
        IsCheckedBySubscriber: Boolean;
        IsValid: Boolean;
    begin
        if (not TicketType.Get(Ticket."Ticket Type Code")) then
            exit;

        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_TYPE) then begin
            if (TicketType."Activation Method" = "NPR TM ActivationMethod_Type"::POS_DEFAULT) then
                Admitted := RegisterDefaultAdmissionArrivalOnPosSales(Ticket, '');

            if (TicketType."Activation Method" = "NPR TM ActivationMethod_Type"::POS_ALL) then
                Admitted := RegisterAllAdmissionArrivalOnPosSales(Ticket, '');
        end;

        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then
            Admitted := RegisterTicketBomAdmissionArrival(Ticket, PosUnitNo, '', 0);

        if (Admitted) then begin
            OnAfterPosTicketArrival(IsCheckedBySubscriber, IsValid, Ticket."No.", Ticket."External Member Card No.", Token, ResponseMessage);
            if ((IsCheckedBySubscriber) and (not IsValid)) then
                Error(ResponseMessage);
        end;

    end;

    internal procedure AdmitTicketsFromWorkflowOnEndSale(PosUnitNo: Code[10]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        TicketProfile: Record "NPR TM POS Ticket Profile";
    begin
        POSUnit.SetLoadFields("POS Ticket Profile");
        if (not POSUnit.Get(PosUnitNo)) then
            exit(false);

        if (not TicketProfile.Get(POSUnit."POS Ticket Profile")) then
            exit(false);

        if (TicketProfile."EndOfSaleAdmitMethod" = TicketProfile."EndOfSaleAdmitMethod"::LEGACY) then
            exit(false);

        exit(true);
    end;


    [IntegrationEvent(false, false)]
    internal procedure OnAfterPosTicketArrival(var IsCheckedBySubscriber: Boolean; var IsValid: Boolean; TicketNumber: Code[20]; TicketExternalMemberReference: Code[20]; Token: Text[100]; var ResponseMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPosTicketRevoke(var IsCheckedBySubscriber: Boolean; var IsValid: Boolean; Token: Text[100]; var ResponseMessage: Text)
    begin
    end;

    [CommitBehavior(CommitBehavior::Error)]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterRegisterArrival(Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; DetAccessEntryNo: Integer)
    begin
    end;

    procedure PrintTicketFromEndOfSale(SalesTicketNo: Code[20])
    var
        Ticket: Record "NPR TM Ticket";
        Wallet: Codeunit "NPR AttractionWallet";
        WalletPrintEnabled: Boolean;
    begin
        Ticket.SetCurrentKey("Sales Receipt No.");
        Ticket.SetRange("Sales Receipt No.", SalesTicketNo);
        Ticket.SetFilter(Blocked, '=%1', false);
        if (Ticket.FindSet()) then begin

            WalletPrintEnabled := Wallet.IsEndOfSalePrintEnabled();

            repeat
                if (WalletPrintEnabled) then begin
                    if (not Wallet.IsTicketInWallet(Ticket)) then
                        DoTicketPrint(Ticket);
                end else begin
                    DoTicketPrint(Ticket);
                end;
            until (Ticket.Next() = 0);
        end
    end;

    procedure PrintTicketFromSalesTicketNo(SalesTicketNo: Code[20])
    var
        Ticket: Record "NPR TM Ticket";
    begin
        Ticket.SetCurrentKey("Sales Receipt No.");
        Ticket.SetRange("Sales Receipt No.", SalesTicketNo);
        PrintTicketBatch(Ticket);
    end;

    procedure PrintTicketsFromToken(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token Id");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                Ticket.Reset();
                Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                if (not Ticket.IsEmpty()) then
                    PrintTicketBatch(Ticket);
            until (TicketReservationRequest.Next() = 0);
        end
    end;

    procedure PrintTicketsFromExternalOrderNumber(ExternalOrderNumber: Code[20])
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        TicketRequest.SetCurrentKey("External Order No.");
        TicketRequest.SetFilter("External Order No.", '=%1', ExternalOrderNumber);
        TicketRequest.SetFilter("Primary Request Line", '=%1', true);
        if (not TicketRequest.FindSet()) then
            exit;

        repeat
            Ticket.Reset();
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
            PrintTicketBatch(Ticket);
        until (TicketRequest.Next() = 0);
    end;

    procedure PrintTicketBatch(var TicketFilter: Record "NPR TM Ticket")
    var
        Ticket: Record "NPR TM Ticket";
    begin
        Ticket.CopyFilters(TicketFilter);
        Ticket.SetFilter(Blocked, '=%1', false);
        if (not (Ticket.FindSet())) then
            exit;

        repeat
            DoTicketPrint(Ticket);
        until (Ticket.Next() = 0);
    end;

    internal procedure DoTicketPrint(var Ticket: Record "NPR TM Ticket")
    var
        Ticket2: Record "NPR TM Ticket";
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketDIYTicketPrint: Codeunit "NPR TM Ticket DIY Ticket Print";
        ResponseMessage: Text;
        PrintTicket: Boolean;
        PublishError: Boolean;
    begin

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

        if (TicketDIYTicketPrint.CheckCreateTicketDesignerNotification(Ticket."No.")) then begin
            TicketSetup.Get();
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
            if (PrintSingleTicket(Ticket2)) then begin
                IncrementPrintCount(Ticket."No.");
                Commit();
            end
        end;

    end;

    internal procedure IncrementPrintCount(TicketNo: Code[20])
    var
        Ticket: Record "NPR TM Ticket";
    begin
        if (Ticket.Get(TicketNo)) then begin
            Ticket."Printed Date" := Today();
            Ticket.PrintCount += 1;
            Ticket.PrintedDateTime := CurrentDateTime();
            Ticket.Modify();
        end;
    end;

    internal procedure IncrementPrintCount(TicketId: Guid)
    var
        Ticket: Record "NPR TM Ticket";
    begin
        if (Ticket.GetBySystemId(TicketId)) then begin
            Ticket."Printed Date" := Today();
            Ticket.PrintCount += 1;
            Ticket.PrintedDateTime := CurrentDateTime();
            Ticket.Modify();
        end;
    end;

    local procedure PrintTicketUsingFormatter(var Ticket: Record "NPR TM Ticket"; PrintObjectType: Option; PrintObjectId: Integer; PrintTemplateCode: Code[20]): Boolean
    var
        TicketType: Record "NPR TM Ticket Type";
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin

        case PrintObjectType of
            TicketType."Print Object Type"::Codeunit:
                Codeunit.Run(PrintObjectId, Ticket);

            TicketType."Print Object Type"::Report:
                Report.Run(PrintObjectId, false, false, Ticket);

            TicketType."Print Object Type"::TEMPLATE:
                PrintTemplateMgt.PrintTemplate(PrintTemplateCode, Ticket, 0);

            else
                exit(false);
        end;

        exit(true);
    end;

    /// <summary>
    /// Some Print implementations uses RunModal, meaning it will block writing transactions on each subsequent call.
    /// If this is called multiple times make sure to Commit(), before calling it again to ensure no that there no ongoing writing transaction. 
    /// </summary>
    procedure PrintSingleTicket(var Ticket: Record "NPR TM Ticket") Printed: Boolean
    var
        TicketType: Record "NPR TM Ticket Type";
    begin
        if (not TicketType.Get(Ticket."Ticket Type Code")) then
            exit(false);

        if (not TicketType."Print Ticket") then
            exit(false);

        Printed := PrintTicketUsingFormatter(Ticket, TicketType."Print Object Type", TicketType."Print Object ID", TicketType."RP Template Code");
    end;

    [Obsolete('Remove after POS Scenario is removed', '2024-03-28')]
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


    [Obsolete('Remove after POS Scenario is removed', '2024-03-28')]
    local procedure CurrentCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR TM Ticket Management");
    end;

    internal procedure ValidateTicketForArrival(Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; ScannerStationId: Text[30]): Boolean
    var
        TimeHelper: Codeunit "NPR TM TimeHelper";
    begin
        if (AdmissionCode = '') then
            AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");

        ValidateTicketForArrival(Ticket, AdmissionCode, -1, TimeHelper.GetLocalTimeAtAdmission(AdmissionCode), ScannerStationId); // Throws error on fail
        exit(true);
    end;

    internal procedure ValidateTicketForArrival(Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; AdmissionScheduleEntryNo: Integer; EventDateTime: DateTime; ScannerStationId: Text[30])
    var
        Admission: Record "NPR TM Admission";
        TicketAccessEntryNo: Integer;
        TicketBom: Record "NPR TM Ticket Admission BOM";
        AllowAdmissionOverAllocation: Enum "NPR TM Ternary";
        AdmissionEntryNo: Integer;
    begin

        if (AdmissionCode = '') then
            AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");

        if (not (Admission.Get(AdmissionCode))) then
            RaiseError(StrSubstNo(INVALID_REFERENCE, Admission.FieldName("Admission Code"), AdmissionCode), INVALID_REFERENCE_NO);

        if (not (TicketBom.Get(Ticket."Item No.", Ticket."Variant Code", Admission."Admission Code"))) then
            RaiseError(StrSubstNo(INVALID_ADMISSION_CODE, Ticket."External Ticket No.", AdmissionCode), INVALID_ADMISSION_CODE_NO);

        ValidateTicketReference(Ticket, AdmissionCode, TicketAccessEntryNo, false);
        ValidateScheduleReference(TicketAccessEntryNo, AdmissionCode, AdmissionScheduleEntryNo, EventDateTime);

        AdmissionEntryNo := RegisterArrival_Worker(TicketAccessEntryNo, AdmissionScheduleEntryNo, TicketBom.DurationGroupCode, EventDateTime, ScannerStationId);

        ValidateAdmissionDependencies(TicketAccessEntryNo);

        ValidateTicketConstraintsExceeded(TicketAccessEntryNo);
        ValidateAdmissionDurationExceeded(TicketAccessEntryNo, EventDateTime);

        AllowAdmissionOverAllocation := AllowAdmissionOverAllocation::TERNARY_FALSE;
        if (TicketBom."POS Sale May Exceed Capacity") then
            AllowAdmissionOverAllocation := AllowAdmissionOverAllocation::TERNARY_TRUE;

        ValidateTicketAdmissionCapacityExceeded(Ticket, AdmissionScheduleEntryNo, _TicketExecutionContext::ADMISSION, AllowAdmissionOverAllocation);

        OnAfterRegisterArrival(Ticket, AdmissionCode, AdmissionEntryNo);

    end;

    procedure ValidateTicketForDeparture(TicketIdentifierType: Enum "NPR TM TicketIdentifierType"; TicketIdentifier: Text[50];
                                                                   AdmissionCode: Code[20])
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
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin

        TicketType.Get(Ticket."Ticket Type Code");
        Ticket."Valid From Date" := ValidFromDate;
        Ticket."Valid To Date" := Ticket."Valid From Date";
        Ticket.TestField("Valid From Date");

        Ticket."Valid From Time" := 000000T;
        Ticket."Valid To Time" := 235959T;
        Ticket.Blocked := false;
        Ticket."Document Date" := Today();

        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then begin
            TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
            TicketBom.FindSet();

            repeat
                case TicketBom."Admission Entry Validation" of
                    TicketBom."Admission Entry Validation"::SINGLE,
                    TicketBom."Admission Entry Validation"::SAME_DAY:
                        begin
                            if (Format(TicketBom."Duration Formula") <> '') then begin
                                if (Ticket."Valid To Date" < CalcDate(TicketBom."Duration Formula", ValidFromDate)) then
                                    Ticket."Valid To Date" := CalcDate(TicketBom."Duration Formula", ValidFromDate);

                                if (Ticket."Valid To Date" < Ticket."Valid From Date") then
                                    Error(GREATER_THAN, Ticket.FieldCaption("Valid To Date"), Ticket.FieldCaption("Valid From Date"));
                            end;
                        end;

                    TicketBom."Admission Entry Validation"::MULTIPLE:
                        begin
                            TicketBom.TestField("Duration Formula");
                            if (Ticket."Valid To Date" < CalcDate(TicketBom."Duration Formula", ValidFromDate)) then
                                Ticket."Valid To Date" := CalcDate(TicketBom."Duration Formula", ValidFromDate);

                            if (Ticket."Valid To Date" < Ticket."Valid From Date") then
                                Error(GREATER_THAN, Ticket.FieldCaption("Valid To Date"), Ticket.FieldCaption("Valid From Date"));
                        end;
                    else
                        Error(UNSUPPORTED_VALIDATION_METHOD);
                end;
            until (TicketBom.Next() = 0);
            exit;
        end;

        case TicketType."Ticket Entry Validation" of
            TicketType."Ticket Entry Validation"::SINGLE,
            TicketType."Ticket Entry Validation"::SAME_DAY:
                begin
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
        TicketAccessEntry.SetCurrentKey("Ticket No.");
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.SetLoadFields("Admission Code", "Entry No.");
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

                    if (AdmissionScheduleEntry."Admission End Date" > HighDate) then
                        HighDate := AdmissionScheduleEntry."Admission End Date";

                end;
            until (TicketAccessEntry.Next() = 0);
        end;

    end;

    procedure CreateAdmissionAccessEntry(Ticket: Record "NPR TM Ticket"; TicketQty: Integer; AdmissionCode: Code[20]; AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry"; var AllowAdmissionOverAllocation: Enum "NPR TM Ternary")
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
            ValidateReservationCapacityExceeded(Ticket, AdmissionSchEntry, AllowAdmissionOverAllocation);
        end;

        if (GetAdmissionCapacity(AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code", AdmissionSchEntry."Entry No.", MaxCapacity, CapacityControl)) then
            if (CapacityControl = Admission."Capacity Control"::SALES) then
                ValidateTicketAdmissionCapacityExceeded(Ticket, AdmissionSchEntry."Entry No.", _TicketExecutionContext::SALES, AllowAdmissionOverAllocation);

        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_TYPE) then
            ValidateTicketAdmissionCapacityExceeded(Ticket, AdmissionSchEntry."Entry No.", _TicketExecutionContext::SALES, AllowAdmissionOverAllocation);

        ValidateTicketBaseCalendar(TicketAccessEntry."Admission Code", Ticket."Item No.", Ticket."Variant Code", AdmissionSchEntry."Admission Start Date");

    end;

    procedure CreateAdmissionAccessEntryDynamicTicket(var Ticket: Record "NPR TM Ticket"; TicketQty: Integer; AdmissionCode: Code[20]; var AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry"; var TicketAccessEntry: Record "NPR TM Ticket Access Entry"; var AllowAdmissionOverAllocation: Enum "NPR TM Ternary")
    var
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
            ValidateReservationCapacityExceeded(Ticket, AdmissionSchEntry, AllowAdmissionOverAllocation);
        end;

        if (GetAdmissionCapacity(AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code", AdmissionSchEntry."Entry No.", MaxCapacity, CapacityControl)) then
            if (CapacityControl = Admission."Capacity Control"::SALES) then
                ValidateTicketAdmissionCapacityExceeded(Ticket, AdmissionSchEntry."Entry No.", _TicketExecutionContext::SALES, AllowAdmissionOverAllocation);

        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_TYPE) then
            ValidateTicketAdmissionCapacityExceeded(Ticket, AdmissionSchEntry."Entry No.", _TicketExecutionContext::SALES, AllowAdmissionOverAllocation);

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
        AllowAdmissionAllowOverAllocation: Enum "NPR TM Ternary";
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
        NewDetTicketAccessEntry.Open := false;
        NewDetTicketAccessEntry.Insert();

        // link original entry with reversal entry instead of payment entry
        OldDetTicketAccessEntry."Closed By Entry No." := NewDetTicketAccessEntry."Entry No.";
        OldDetTicketAccessEntry.Open := false;
        OldDetTicketAccessEntry.Modify();


        AllowAdmissionAllowOverAllocation := AllowAdmissionAllowOverAllocation::TERNARY_FALSE; // TODO, allow over allocation on change requests
        Admission.Get(NewAdmissionScheduleEntry."Admission Code");
        if (Admission.Type = Admission.Type::OCCASION) then begin
            OldDetTicketAccessEntry.SetFilter(Type, '=%1', OldDetTicketAccessEntry.Type::RESERVATION);
            OldDetTicketAccessEntry.FindLast();

            OldDetTicketAccessEntry.Type := OldDetTicketAccessEntry.Type::CANCELED_RESERVATION;
            OldDetTicketAccessEntry."Closed By Entry No." := RegisterReservation_Worker(Ticket, TicketAccessEntry."Entry No.", NewAdmissionScheduleEntry."Entry No.");
            OldDetTicketAccessEntry.Open := false;
            OldDetTicketAccessEntry.Modify();

            ValidateReservationCapacityExceeded(Ticket, NewAdmissionScheduleEntry, AllowAdmissionAllowOverAllocation);

        end;

        if (GetAdmissionCapacity(NewAdmissionScheduleEntry."Admission Code", NewAdmissionScheduleEntry."Schedule Code", NewAdmissionScheduleEntry."Entry No.", MaxCapacity, CapacityControl)) then
            if (CapacityControl = Admission."Capacity Control"::SALES) then
                ValidateTicketAdmissionCapacityExceeded(Ticket, NewAdmissionScheduleEntry."Entry No.", _TicketExecutionContext::SALES, AllowAdmissionAllowOverAllocation);

        ValidateTicketAdmissionReservationDate(TicketAccessEntry."Entry No.", NewAdmissionScheduleEntry."Entry No.");
        ValidateTicketBaseCalendar(TicketAccessEntry."Admission Code", Ticket."Item No.", Ticket."Variant Code", NewAdmissionScheduleEntry."Admission Start Date");

    end;

    procedure RescheduleDynamicTicketAdmission(TicketNo: Code[20]; NewExtScheduleEntryNo: Integer; EnforceReschedulePolicy: Boolean; ReferenceDateTime: DateTime; POSSession: Codeunit "NPR POS Session"; var SalesTicketNo: Code[20]; EntryNo: Integer)
    var
        Ticket: Record "NPR TM Ticket";
        Admission: Record "NPR TM Admission";
        NewAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        OldDetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        NewDetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionOverAllocationConfirmed: Enum "NPR TM Ternary";
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
        if not TicketAccessEntry.FindFirst() then begin // adding new admission
            CreateAdmissionAccessEntryDynamicTicket(Ticket, 1, NewAdmissionScheduleEntry."Admission Code", NewAdmissionScheduleEntry, TicketAccessEntry, AdmissionOverAllocationConfirmed);
            // create POS line, get correct item,     
            CreateSalesLinePerAdmission(POSSession, SalesTicketNo, NewAdmissionScheduleEntry, EntryNo, Ticket."Item No.");
        end
        else begin
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

                ValidateReservationCapacityExceeded(Ticket, NewAdmissionScheduleEntry, AdmissionOverAllocationConfirmed);

            end;
        end;
        if (GetAdmissionCapacity(NewAdmissionScheduleEntry."Admission Code", NewAdmissionScheduleEntry."Schedule Code", NewAdmissionScheduleEntry."Entry No.", MaxCapacity, CapacityControl)) then
            if (CapacityControl = Admission."Capacity Control"::SALES) then
                ValidateTicketAdmissionCapacityExceeded(Ticket, NewAdmissionScheduleEntry."Entry No.", _TicketExecutionContext::SALES, AdmissionOverAllocationConfirmed);

        ValidateTicketAdmissionReservationDate(TicketAccessEntry."Entry No.", NewAdmissionScheduleEntry."Entry No.");

        ValidateTicketBaseCalendar(TicketAccessEntry."Admission Code", Ticket."Item No.", Ticket."Variant Code", NewAdmissionScheduleEntry."Admission Start Date");

    end;

    internal procedure ReplanReservation(DetTicketAccessEntryNo: Integer; NewExternalEntryNo: Integer; IncludeInitialEntry: Boolean): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        OldDetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        NewDetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        NewAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        if (not OldDetTicketAccessEntry.Get(DetTicketAccessEntryNo)) then
            exit(false);

        if (OldDetTicketAccessEntry.Type <> OldDetTicketAccessEntry.Type::RESERVATION) then
            exit(false);

        NewAdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', NewExternalEntryNo);
        NewAdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not NewAdmissionScheduleEntry.FindFirst()) then
            exit(false);

        if (not Ticket.Get(OldDetTicketAccessEntry."Ticket No.")) then
            exit(false);

        OldDetTicketAccessEntry.Type := OldDetTicketAccessEntry.Type::CANCELED_RESERVATION;
        OldDetTicketAccessEntry."Closed By Entry No." := RegisterReservation_Worker(Ticket, OldDetTicketAccessEntry."Ticket Access Entry No.", NewAdmissionScheduleEntry."Entry No.");
        OldDetTicketAccessEntry.Open := false;
        OldDetTicketAccessEntry.Modify();

        if (IncludeInitialEntry) then begin
            OldDetTicketAccessEntry.Reset();
            OldDetTicketAccessEntry.SetFilter(Type, '=%1', OldDetTicketAccessEntry.Type::INITIAL_ENTRY);
            OldDetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', OldDetTicketAccessEntry."Ticket Access Entry No.");
            OldDetTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
            OldDetTicketAccessEntry.FindLast();

            // Make new entry with new time
            NewDetTicketAccessEntry.TransferFields(OldDetTicketAccessEntry, false);
            NewDetTicketAccessEntry."Entry No." := 0;
            NewDetTicketAccessEntry."External Adm. Sch. Entry No." := NewAdmissionScheduleEntry."External Schedule Entry No.";
            NewDetTicketAccessEntry."Created Datetime" := CurrentDateTime();
            NewDetTicketAccessEntry.Insert();

            // reverse original initial entry
            NewDetTicketAccessEntry."Entry No." := 0;
            NewDetTicketAccessEntry."External Adm. Sch. Entry No." := OldDetTicketAccessEntry."External Adm. Sch. Entry No.";
            NewDetTicketAccessEntry.Quantity := OldDetTicketAccessEntry.Quantity * -1;
            NewDetTicketAccessEntry.Open := false;
            NewDetTicketAccessEntry.Insert();

            // link original entry with reversal entry instead of payment entry
            OldDetTicketAccessEntry."Closed By Entry No." := NewDetTicketAccessEntry."Entry No.";
            OldDetTicketAccessEntry.Open := false;
            OldDetTicketAccessEntry.Modify();
        end;

        exit(true);
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

        if (DT2Date(ReferenceDateTime) > Ticket."Valid To Date") then
            exit(false);

        if ExtAdmSchEntryNo = 0 then
            exit(true);

        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtAdmSchEntryNo);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindFirst()) then
            exit(false);

        if (not TicketAdmissionBOM.Get(Ticket."Item No.", Ticket."Variant Code", AdmissionScheduleEntry."Admission Code")) then
            exit(false);

        case TicketAdmissionBOM."Reschedule Policy" of

            TicketAdmissionBOM."Reschedule Policy"::NOT_ALLOWED:
                exit(false);
            TicketAdmissionBOM."Reschedule Policy"::UNTIL_USED: // admitted or expired
                begin
                    TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                    TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
                    if (not TicketAccessEntry.FindFirst()) then
                        exit(false); // can not be rescheduled

                    if (TicketAccessEntry."Access Date" <> 0D) then
                        exit(false); // ticket admission was admitted and can not be rescheduled.

                    exit(not IsSelectedAdmissionSchEntryExpired(AdmissionScheduleEntry, DT2DATE(ReferenceDateTime), DT2TIME(ReferenceDateTime), ResponseMessage, ResponseCode));
                end;
            TicketAdmissionBOM."Reschedule Policy"::CUTOFF_HOUR:
                begin
                    TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                    TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
                    if (not TicketAccessEntry.FindFirst()) then
                        exit(false); // can not be rescheduled

                    if (TicketAccessEntry."Access Date" <> 0D) then
                        exit(false); // ticket admission was admitted and can not be rescheduled.

                    ReferenceDateTime += TicketAdmissionBOM."Reschedule Cut-Off (Hours)" * 60 * 60 * 1000;
                    exit(not IsSelectedAdmissionSchEntryExpired(AdmissionScheduleEntry, DT2DATE(ReferenceDateTime), DT2TIME(ReferenceDateTime), ResponseMessage, ResponseCode));
                end;
            TicketAdmissionBOM."Reschedule Policy"::UNTIL_ADMITTED:
                begin
                    TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                    TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
                    if (not TicketAccessEntry.FindFirst()) then
                        exit(false); // can not be rescheduled

                    exit(TicketAccessEntry."Access Date" = 0D); // ticket admission was not admitted and can be rescheduled.
                end;
        end;

        exit(false);

    end;

    procedure IsSelectedAdmissionSchEntryExpired(AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry"; ReferenceDate: Date; ReferenceTime: Time; var ResponseMessage: Text; var ResponseCode: Integer): Boolean
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

    internal procedure CreatePaymentEntryType(Ticket: Record "NPR TM Ticket"; PaymentType: Option PAYMENT,PREPAID,POSTPAID; PaymentReferenceNo: Code[20]; CustomerNo: Code[20])
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

                NotifyParticipant.CreateAdmissionWelcomeReminder(TicketAccessEntry, Ticket."External Member Card No.");
                NotifyParticipant.CreateAdmissionReservationReminder(TicketAccessEntry, Ticket."External Member Card No.");
            end;
        until (AdmissionBOM.Next() = 0);
    end;

    internal procedure CreatePaymentEntryType(Ticket: Record "NPR TM Ticket"; PaymentType: Option PAYMENT,PREPAID,POSTPAID; PaymentReferenceNo: Code[20]; CustomerNo: Code[20]; AdmissionCode: Code[20])
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        Admission: Record "NPR TM Admission";
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
    begin
        Item.Get(Ticket."Item No.");
        TicketType.Get(Item."NPR Ticket Type");
        Admission.Get(AdmissionCode);
        TicketAccessEntry.SetCurrentKey("Ticket No.", "Admission Code");
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        if (TicketAccessEntry.FindFirst()) then begin
            RegisterPayment_Worker(TicketAccessEntry."Entry No.", PaymentType, PaymentReferenceNo);

            if (CustomerNo <> '') then begin
                TicketAccessEntry."Customer No." := CustomerNo;
                TicketAccessEntry.Modify();
            end;

            NotifyParticipant.CreateAdmissionWelcomeReminder(TicketAccessEntry, Ticket."External Member Card No.");
            NotifyParticipant.CreateAdmissionReservationReminder(TicketAccessEntry, Ticket."External Member Card No.");

        end;
    end;

    procedure AttemptChangeConfirmedTicketQuantity(TicketNo: Code[20]; AdmissionCode: Code[20]; NewTicketQuantity: Integer; var ResponseMessage: Text): Boolean
    var
        AttemptTicket: Codeunit "NPR Ticket Attempt Create";
    begin
        exit(AttemptTicket.AttemptChangeConfirmedTicketQuantity(TicketNo, AdmissionCode, NewTicketQuantity, ResponseMessage));
    end;

    procedure ChangeConfirmedTicketQuantity(TicketNo: Code[20]; AdmissionCode: Code[20]; NewTicketQuantity: Integer)
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketAccessEntryNo: Integer;
        AllowAdmissionOverAllocation: Enum "NPR TM Ternary";
        PaidQty: Integer;
        CurrentQty: Integer;
        ExtAdmSchEntryNo: Integer;
        QTY_CHANGE_NOT_ALLOWED: Label 'Ticket %1 has been used and quantity cannot be changed. %2 %3.';
        ENTRY_NOT_FOUND: Label 'Ticket %1 has been paid and quantity cannot be changed. %2 %3.';
    begin

        ValidateTicketReference("NPR TM TicketIdentifierType"::INTERNAL_TICKET_NO, TicketNo, AdmissionCode, TicketAccessEntryNo, true);
        Ticket.Get(TicketNo);

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        if (AdmissionCode <> '') then
            TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        TicketAccessEntry.FindSet();
        repeat

            if (TicketAccessEntry.Quantity = NewTicketQuantity) then
                exit;

            TicketBom.Get(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code");

            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
            if (DetTicketAccessEntry.FindFirst()) then
                RaiseError(StrSubstNo(QTY_CHANGE_NOT_ALLOWED, TicketNo, DetTicketAccessEntry.TableCaption(), DetTicketAccessEntry."Entry No."), QTY_CHANGE_NOT_ALLOWED_NO);

            PaidQty := 0;
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.");
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1|=%2|%3', DetTicketAccessEntry.Type::PAYMENT, DetTicketAccessEntry.Type::PREPAID, DetTicketAccessEntry.Type::POSTPAID);
            if (DetTicketAccessEntry.FindFirst()) then
                PaidQty := DetTicketAccessEntry.Quantity;

            if (NewTicketQuantity > PaidQty) then
                RaiseError(StrSubstNo(HAS_PAYMENT, Ticket."External Ticket No."), HAS_PAYMENT_NO);

            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
            DetTicketAccessEntry.SetFilter(Quantity, '>0');
            if (not DetTicketAccessEntry.FindLast()) then
                RaiseError(StrSubstNo(ENTRY_NOT_FOUND, TicketNo, DetTicketAccessEntry.TableCaption(), DetTicketAccessEntry."Entry No."), ENTRY_NOT_FOUND_NO);

            CurrentQty := DetTicketAccessEntry.Quantity;
            ExtAdmSchEntryNo := DetTicketAccessEntry."External Adm. Sch. Entry No.";

            DetTicketAccessEntry.Quantity := NewTicketQuantity;
            DetTicketAccessEntry.Modify();
            TicketAccessEntry.Quantity := NewTicketQuantity;
            TicketAccessEntry.Modify();

            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
            if (DetTicketAccessEntry.FindFirst()) then begin
                ExtAdmSchEntryNo := DetTicketAccessEntry."External Adm. Sch. Entry No.";
                DetTicketAccessEntry.Quantity := NewTicketQuantity;
                DetTicketAccessEntry.Modify();
            end;

            if (NewTicketQuantity > CurrentQty) then begin
                AllowAdmissionOverAllocation := AllowAdmissionOverAllocation::TERNARY_FALSE;
                if (TicketBom."POS Sale May Exceed Capacity") then
                    AllowAdmissionOverAllocation := AllowAdmissionOverAllocation::TERNARY_UNKNOWN;
                AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtAdmSchEntryNo);
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                AdmissionScheduleEntry.FindFirst();
                ValidateTicketAdmissionCapacityExceeded(Ticket, AdmissionScheduleEntry."Entry No.", _TicketExecutionContext::SALES, AllowAdmissionOverAllocation);
            end;

        until (TicketAccessEntry.Next() = 0);
    end;

    local procedure RegisterDefaultAdmissionArrivalOnPosSales(Ticket: Record "NPR TM Ticket"; ScannerStationId: Text[30]): Boolean
    var
        AdmissionCode: Code[20];
    begin

        AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");
        exit(ValidateTicketForArrival(Ticket, AdmissionCode, ScannerStationId));
    end;

    local procedure RegisterAllAdmissionArrivalOnPosSales(Ticket: Record "NPR TM Ticket"; ScannerStationId: Text[30]): Boolean
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
            if (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::REQUIRED) then
                ValidateTicketForArrival(Ticket, Admission."Admission Code", ScannerStationId);

            if (TicketBom."Admission Inclusion" <> TicketBom."Admission Inclusion"::REQUIRED) then
                if (AdmissionIsOptionalAndSelected(Ticket, Admission."Admission Code")) then
                    ValidateTicketForArrival(Ticket, Admission."Admission Code", ScannerStationId);

        until (TicketBom.Next() = 0);
        exit(true);
    end;

    local procedure AdmissionIsOptionalAndSelected(Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]): Boolean
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        if (not TicketRequest.Get(Ticket."Ticket Reservation Entry No.")) then
            Error('Ticket Request was not found for ticket %1 during ticket admission.', Ticket."External Ticket No.");

        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', TicketRequest."Session Token ID");
        TicketRequest.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (not TicketRequest.FindFirst()) then
            Error('Ticket Admission %1 for request %2 was not found during ticket admission.', AdmissionCode, TicketRequest."Session Token ID");

        exit(TicketRequest."Admission Inclusion" = TicketRequest."Admission Inclusion"::SELECTED);
    end;

    procedure RegisterArrivalScanTicket(TicketIdentifierType: Enum "NPR TM TicketIdentifierType"; TicketReference: Code[50];
                                                                  AdmissionCode: Code[20];
                                                                  AdmissionScheduleEntryNo: Integer;
                                                                  PosUnitNo: Code[10];
                                                                  ScannerStationId: Code[10];
                                                                  WithPrint: Boolean)
    var
        AdmittedTicketCount: Integer;
    begin
        RegisterArrivalScanTicket(TicketIdentifierType, TicketReference, AdmissionCode, AdmissionScheduleEntryNo, PosUnitNo, ScannerStationId, WithPrint, AdmittedTicketCount);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure RegisterArrivalScanTicket(TicketIdentifierType: Enum "NPR TM TicketIdentifierType"; TicketReference: Code[50];
                                                                  AdmissionCode: Code[20];
                                                                  AdmissionScheduleEntryNo: Integer;
                                                                  PosUnitNo: Code[10];
                                                                  ScannerStationId: Code[10];
                                                                  WithPrint: Boolean; var AdmittedTicketCount: Integer)
    begin
        if (TicketIdentifierType <> TicketIdentifierType::EXTERNAL_ORDER_REF) then begin
            ValidateRegisterArrivalScanTicketWorker(TicketIdentifierType, TicketReference, AdmissionCode, AdmissionScheduleEntryNo, PosUnitNo, ScannerStationId, WithPrint);
            AdmittedTicketCount := 1;
        end;

        if (TicketIdentifierType = TicketIdentifierType::EXTERNAL_ORDER_REF) then
            ValidateRegisterArrivalScanOrderWorker(TicketIdentifierType, TicketReference, AdmissionCode, AdmissionScheduleEntryNo, PosUnitNo, ScannerStationId, WithPrint, AdmittedTicketCount);
    end;

    local procedure ValidateRegisterArrivalScanOrderWorker(TicketIdentifierType: Enum "NPR TM TicketIdentifierType"; TicketReference: Code[50];
                                                                                     AdmissionCode: Code[20];
                                                                                     AdmissionScheduleEntryNo: Integer;
                                                                                     PosUnitNo: Code[10];
                                                                                     ScannerStationId: Code[10];
                                                                                     WithPrint: Boolean; var AdmittedTicketCount: Integer)
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        if (TicketIdentifierType <> "NPR TM TicketIdentifierType"::EXTERNAL_ORDER_REF) then
            Error(UNSUPPORTED_VALIDATION_METHOD);

        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', TicketReference);
        if (not TicketRequest.FindSet()) then
            RaiseError(StrSubstNo(INVALID_REFERENCE, REFERENCE, TicketReference), INVALID_REFERENCE_NO);

        repeat
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
            if (Ticket.FindSet()) then begin
                repeat
                    ValidateRegisterArrivalScanTicketWorker("NPR TM TicketIdentifierType"::INTERNAL_TICKET_NO, Ticket."No.", AdmissionCode, AdmissionScheduleEntryNo, PosUnitNo, ScannerStationId, false);
                    AdmittedTicketCount += 1;
                until (Ticket.Next() = 0);
            end;
        until (TicketRequest.Next() = 0);

        if (WithPrint) then
            PrintTicketsFromToken(TicketReference);

    end;

    local procedure ValidateRegisterArrivalScanTicketWorker(TicketIdentifierType: Enum "NPR TM TicketIdentifierType"; TicketNumber: Code[50];
                                                                                      AdmissionCode: Code[20];
                                                                                      AdmissionScheduleEntryNo: Integer;
                                                                                      PosUnitNo: Code[10];
                                                                                      ScannerStationId: Code[10];
                                                                                      WithPrint: Boolean)
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Ticket: Record "NPR TM Ticket";
        AdmissionScannerStation: Record "NPR MM Admis. Scanner Stations";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        ProcessFlow: Option SALES,SCAN;
    begin

        if (not GetTicket(TicketIdentifierType, TicketNumber, Ticket)) then
            RaiseError(StrSubstNo(INVALID_REFERENCE, REFERENCE, TicketNumber), INVALID_REFERENCE_NO);
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        if (not (_FeatureFlagManagement.IsEnabled('enableTriStateLockingFeaturesInTicketModule'))) then
            TicketRequestManager.LockResources('RegisterArrival');
#else
        TicketRequestManager.LockResources('RegisterArrival');
#endif

        Ticket.SetRecFilter();

        if ((ScannerStationId <> '') and (AdmissionCode = '')) then
            if (AdmissionScannerStation.Get(ScannerStationId)) then
                if (not AdmissionScannerStation.IsDynamicAdmissionGate) then
                    ScannerStationId := '';

        if ((AdmissionCode = '') and ((PosUnitNo <> '') or (ScannerStationId <> ''))) then begin
            RegisterTicketBomAdmissionArrival(Ticket, PosUnitNo, ScannerStationId, ProcessFlow::SCAN);

        end else begin
            if (AdmissionCode = '') then
                AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");

            ValidateTicketForArrival(Ticket, AdmissionCode, AdmissionScheduleEntryNo, TimeHelper.GetLocalTimeAtAdmission(AdmissionCode), ScannerStationId);
        end;

        if (WithPrint) then
            if (PrintSingleTicket(Ticket)) then begin
                Ticket."Printed Date" := Today();
                Ticket.Modify();
            end;
    end;

    internal procedure RegisterTicketBomAdmissionArrival(Ticket: Record "NPR TM Ticket"; PosUnitNo: Code[10]; ScannerStationId: Code[10]; ProcessFlow: Option SALES,SCAN) TicketAdmitted: Boolean;
    var
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketType: Record "NPR TM Ticket Type";
        PosDefaultAdmission: Record "NPR TM POS Default Admission";
        StationType: Option;
        StationIdentifier: Code[10];
        AttemptAdmission: Boolean;
    begin

        TicketType.Get(Ticket."Ticket Type Code");

        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        if (not TicketBom.FindSet()) then
            Error(NO_ADMISSION_CODE, Ticket."Item No.");

        TicketAdmitted := false;
        repeat
            Admission.Get(TicketBom."Admission Code");

            AttemptAdmission := (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::REQUIRED);
            if (not AttemptAdmission) then
                AttemptAdmission := AdmissionIsOptionalAndSelected(Ticket, TicketBom."Admission Code");

            if (AttemptAdmission) then begin
                if (ScannerStationId <> '') then
                    TicketBom."Activation Method" := "NPR TM ActivationMethod_Bom"::PER_UNIT;

                case TicketBom."Activation Method" of
                    "NPR TM ActivationMethod_Bom"::SCAN:
                        if (ProcessFlow = ProcessFlow::SCAN) then
                            TicketAdmitted := TicketAdmitted or ValidateTicketForArrival(Ticket, Admission."Admission Code", ScannerStationId);

                    "NPR TM ActivationMethod_Bom"::POS:
                        if (ProcessFlow = ProcessFlow::SALES) then
                            TicketAdmitted := TicketAdmitted or ValidateTicketForArrival(Ticket, Admission."Admission Code", ScannerStationId);

                    "NPR TM ActivationMethod_Bom"::ALWAYS:
                        TicketAdmitted := TicketAdmitted or ValidateTicketForArrival(Ticket, Admission."Admission Code", ScannerStationId);

                    "NPR TM ActivationMethod_Bom"::PER_UNIT:
                        begin
                            if (PosUnitNo <> '') then begin
                                StationType := PosDefaultAdmission."Station Type"::POS_UNIT;
                                StationIdentifier := PosUnitNo;
                            end;

                            if (ScannerStationId <> '') then begin
                                StationType := PosDefaultAdmission."Station Type"::SCANNER_STATION;
                                StationIdentifier := ScannerStationId;
                            end;

                            if (ProcessFlow = ProcessFlow::SCAN) then
                                if (IsSelectedAdmissionDefaultOnPosScan(Ticket."Item No.", Ticket."Variant Code", Admission."Admission Code", StationType, StationIdentifier)) then
                                    TicketAdmitted := TicketAdmitted or ValidateTicketForArrival(Ticket, Admission."Admission Code", ScannerStationId);

                            if (ProcessFlow = ProcessFlow::SALES) then
                                if (IsSelectedAdmissionDefaultOnPosSale(Ticket."Item No.", Ticket."Variant Code", Admission."Admission Code", StationType, StationIdentifier)) then
                                    TicketAdmitted := TicketAdmitted or ValidateTicketForArrival(Ticket, Admission."Admission Code", ScannerStationId);
                        end;

                    "NPR TM ActivationMethod_Bom"::NA: // Fallback (default) to Ticket Type setup
                        begin
                            if (ProcessFlow = ProcessFlow::SALES) then begin
                                if ((TicketType."Activation Method" = "NPR TM ActivationMethod_Type"::POS_DEFAULT) and TicketBom.Default) then
                                    TicketAdmitted := TicketAdmitted or ValidateTicketForArrival(Ticket, Admission."Admission Code", ScannerStationId);

                                if (TicketType."Activation Method" = "NPR TM ActivationMethod_Type"::POS_ALL) then
                                    TicketAdmitted := TicketAdmitted or ValidateTicketForArrival(Ticket, Admission."Admission Code", ScannerStationId);
                            end;

                            if (ProcessFlow = ProcessFlow::SCAN) then
                                if (TicketBom.Default) then
                                    TicketAdmitted := TicketAdmitted or ValidateTicketForArrival(Ticket, Admission."Admission Code", ScannerStationId);
                        end;
                end;
            end;
        until (TicketBom.Next() = 0);

        if ((ProcessFlow = ProcessFlow::SCAN) and (not TicketAdmitted)) then
            Error(NO_DEFAULT_ADMISSION_SELECTED, Ticket."Item No.");

    end;

    local procedure IsSelectedAdmissionDefaultOnPosSale(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; StationType: Option; StationIdentifier: Code[10]): Boolean
    var
        PosDefaultAdmission: Record "NPR TM POS Default Admission";
    begin
        if (PosDefaultAdmission.Get(ItemNo, VariantCode, AdmissionCode, StationType, StationIdentifier)) then
            exit((PosDefaultAdmission."Activation Method" = PosDefaultAdmission."Activation Method"::ON_SALES) or
                 (PosDefaultAdmission."Activation Method" = PosDefaultAdmission."Activation Method"::ALWAYS));
        exit(false);
    end;

    local procedure IsSelectedAdmissionDefaultOnPosScan(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; StationType: Option; StationIdentifier: Code[10]): Boolean
    var
        PosDefaultAdmission: Record "NPR TM POS Default Admission";
    begin
        if (PosDefaultAdmission.Get(ItemNo, VariantCode, AdmissionCode, StationType, StationIdentifier)) then
            exit((PosDefaultAdmission."Activation Method" = PosDefaultAdmission."Activation Method"::ON_SCAN) or
                 (PosDefaultAdmission."Activation Method" = PosDefaultAdmission."Activation Method"::ALWAYS));
        exit(false);
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
        TicketDeferral: Codeunit "NPR TM RevenueDeferral";
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

        TicketDeferral.AbortDeferral(Ticket."No.");
    end;

    procedure ValidateTicketReference(TicketIdentifierType: Enum "NPR TM TicketIdentifierType"; TicketIdentifier: Text[50];
                                                                AdmissionCode: Code[20]; var TicketAccessEntryNo: Integer)
    begin
        ValidateTicketReference(TicketIdentifierType, TicketIdentifier, AdmissionCode, TicketAccessEntryNo, false);
    end;

    internal procedure ValidateTicketReference(TicketIdentifierType: Enum "NPR TM TicketIdentifierType"; TicketIdentifier: Text[50];
                                                                         AdmissionCode: Code[20]; var TicketAccessEntryNo: Integer; SkipPaymentCheck: Boolean)
    var
        Ticket: Record "NPR TM Ticket";
    begin
        if (not GetTicket(TicketIdentifierType, TicketIdentifier, Ticket)) then
            RaiseError(StrSubstNo(INVALID_REFERENCE, REFERENCE, TicketIdentifier), INVALID_REFERENCE_NO);

        ValidateTicketReference(Ticket, AdmissionCode, TicketAccessEntryNo, SkipPaymentCheck);
    end;

    local procedure ValidateTicketReference(Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; var TicketAccessEntryNo: Integer; SkipPaymentCheck: Boolean)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketIdentifier: Text[30];
    begin

        TicketIdentifier := Ticket."External Ticket No.";
        TicketAccessEntryNo := -1;

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

        if (not SkipPaymentCheck) then
            if (not CheckAdmissionIsPaid(TicketAccessEntry."Entry No.")) then
                RaiseError(StrSubstNo(MISSING_PAYMENT, TicketIdentifier), MISSING_PAYMENT_NO);

        TicketAccessEntryNo := TicketAccessEntry."Entry No.";
        exit;
    end;

    internal procedure CheckAdmissionIsPaid(TicketAccessEntryNo: Integer): Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        DetailedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.");
        DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntryNo);
        DetailedTicketAccessEntry.SetFilter(Type, '=%1|=%2|%3', DetailedTicketAccessEntry.Type::PAYMENT, DetailedTicketAccessEntry.Type::PREPAID, DetailedTicketAccessEntry.Type::POSTPAID);
        exit(not DetailedTicketAccessEntry.IsEmpty());
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

    local procedure ValidateScheduleReference(TicketAccessEntryNo: Integer; AdmissionCode: Code[20]; var AdmissionScheduleEntryNo: Integer; ReferenceTime: DateTime)
    var
        ReasonText: Text;
        ReasonCode: Text;
    begin
        if (not (CheckScheduleReference(TicketAccessEntryNo, AdmissionCode, AdmissionScheduleEntryNo, ReferenceTime, ReasonText, ReasonCode))) then
            RaiseError(ReasonText, ReasonCode);
    end;

    local procedure CheckScheduleReference(TicketAccessEntryNo: Integer; AdmissionCode: Code[20]; var AdmissionScheduleEntryNo: Integer; ReferenceTime: DateTime; var ReasonText: Text; var ReasonCode: Text): Boolean
    var
        Admission: Record "NPR TM Admission";
        AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry";
        ReservationSchEntry: Record "NPR TM Admis. Schedule Entry";
        ReservationAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        AdmissionStartTime: DateTime;
        AdmissionEndTime: DateTime;
        DurationUntilTime: DateTime;
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        LocalTime: DateTime;
    begin

        // Requirements, should be checked elsewhere
        TicketAccessEntry.Get(TicketAccessEntryNo);
        DurationUntilTime := CreateDateTime(TicketAccessEntry.DurationUntilDate, TicketAccessEntry.DurationUntilTime);

        Ticket.Get(TicketAccessEntry."Ticket No.");
        Admission.Get(AdmissionCode);

        Clear(AdmissionSchEntry);
        if (Admission."Prebook Is Required") then begin
            // Fast check-in, get events current schedule
            // reservation
            if (not GetReservationEntry(TicketAccessEntryNo, ReservationAccessEntry)) then begin
                ReasonText := StrSubstNo(RESERVATION_NOT_FOUND, Ticket."External Ticket No.", Admission.Description);
                ReasonCode := RESERVATION_NOT_FOUND_NO;
                exit(false);
            end;

            ReservationAccessEntry.SetCurrentKey("External Adm. Sch. Entry No.");

            ReservationSchEntry.SetFilter(Cancelled, '=%1', false);
            ReservationSchEntry.SetFilter("Admission Is", '=%1', ReservationSchEntry."Admission Is"::Open);
            ReservationSchEntry.SetFilter("External Schedule Entry No.", '=%1', ReservationAccessEntry."External Adm. Sch. Entry No.");
            if (not ReservationSchEntry.FindFirst()) then begin
                LocalTime := TimeHelper.GetLocalTimeAtAdmission(AdmissionCode);
                RaiseError(StrSubstNo(ADM_NOT_OPEN, AdmissionCode, LocalTime), ADM_NOT_OPEN_NO);
            end;

            // find the todays/now entry
            if (AdmissionScheduleEntryNo < 0) then begin
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

                if (DurationUntilTime <> CreateDateTime(0D, 0T)) then
                    AdmissionEndTime := DurationUntilTime;

                if (not ((ReferenceTime >= AdmissionStartTime) and (ReferenceTime <= AdmissionEndTime))) then begin
                    LocalTime := TimeHelper.GetLocalTimeAtAdmission(AdmissionCode);
                    ReasonText := StrSubstNo(RESERVATION_NOT_FOR_NOW, DT2Time(AdmissionStartTime), DT2Time(AdmissionEndTime), DT2Date(AdmissionStartTime), AdmissionCode, LocalTime);
                    ReasonCode := RESERVATION_NOT_FOR_NOW_NO;
                    exit(false);
                end;

                AdmissionScheduleEntryNo := ReservationSchEntry."Entry No.";
            end;

            if (AdmissionScheduleEntryNo = 0) then begin
                ReasonText := StrSubstNo(RESERVATION_NOT_FOR_TODAY, Admission."Admission Code", ReservationSchEntry."Admission Start Date", ReservationSchEntry."Admission Start Time");
                ReasonCode := RESERVATION_NOT_FOR_TODAY_NO;
                exit(false);
            end;

            if (not AdmissionSchEntry.Get(AdmissionScheduleEntryNo)) then
                RaiseError(StrSubstNo(RESERVATION_NOT_FOUND, Ticket."External Ticket No.", Admission.Description), RESERVATION_NOT_FOUND_NO);

            if (AdmissionSchEntry."External Schedule Entry No." <> ReservationAccessEntry."External Adm. Sch. Entry No.") then
                if (not GuiAllowed()) then begin
                    ReasonText := StrSubstNo(RESERVATION_MISMATCH);
                    ReasonCode := RESERVATION_MISMATCH_NO;
                    exit(false);
                end else begin
                    if (not Confirm(CONF_RES_NOT_FOR_TODAY, true, Admission.Description, ReservationSchEntry."Admission Start Date", ReservationSchEntry."Admission Start Time")) then begin
                        ReasonText := StrSubstNo(RESERVATION_MISMATCH);
                        ReasonCode := RESERVATION_MISMATCH_NO;
                        exit(false);
                    end;
                    AdmissionScheduleEntryNo := ReservationSchEntry."Entry No.";
                end;

        end else begin

            // Get suggested admission schedule entry
            if (AdmissionScheduleEntryNo > 0) then begin
                AdmissionSchEntry.SetFilter("External Schedule Entry No.", '=%1', AdmissionScheduleEntryNo);
                AdmissionSchEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
                AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);
                AdmissionSchEntry.SetFilter("Admission Is", '=%1', AdmissionSchEntry."Admission Is"::Open);
                if (not AdmissionSchEntry.FindFirst()) then begin
                    ReasonText := StrSubstNo(ADM_NOT_OPEN_ENTRY, AdmissionCode, AdmissionScheduleEntryNo);
                    ReasonCode := ADM_NOT_OPEN_NO2;
                    exit(false);
                end;

            end else begin
                // Get the current admission schedule
                AdmissionScheduleEntryNo := GetCurrentScheduleEntry(Ticket, AdmissionCode, true);
                if (not AdmissionSchEntry.Get(AdmissionScheduleEntryNo)) then begin
                    ReasonText := StrSubstNo(ADM_NOT_OPEN, AdmissionCode, ReferenceTime);
                    ReasonCode := ADM_NOT_OPEN_NO2;
                    exit(false);
                end;
            end;
        end;

        if (AdmissionSchEntry."Admission Is" <> AdmissionSchEntry."Admission Is"::Open) then begin
            ReasonText := StrSubstNo(ADM_NOT_OPEN, AdmissionCode, ReferenceTime);
            ReasonCode := ADM_NOT_OPEN_NO;
            exit(false);
        end;

        if (DurationUntilTime <> CreateDateTime(0D, 0T)) then
            if (DurationUntilTime < ReferenceTime) then begin
                ReasonText := StrSubstNo(DURATION_EXCEEDED, AdmissionSchEntry."Admission Code", DurationUntilTime);
                ReasonCode := DURATION_EXCEEDED_NO;
                exit(false);
            end;

        exit(true);
    end;

    local procedure GetTicketScheduleReference(TicketAccessEntryNo: Integer; AdmissionCode: Code[20]; var AdmissionScheduleEntryNo: Integer): Boolean
    var
        Admission: Record "NPR TM Admission";
        AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry";
        ReservationSchEntry: Record "NPR TM Admis. Schedule Entry";
        ReservationAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        Ticket: Record "NPR TM Ticket";
    begin

        AdmissionScheduleEntryNo := 0;

        if (not (Admission.Get(AdmissionCode))) then
            exit(false);

        Clear(AdmissionSchEntry);
        if (Admission."Prebook Is Required") then begin
            if (not GetReservationEntry(TicketAccessEntryNo, ReservationAccessEntry)) then
                exit(false);

            ReservationSchEntry.SetFilter(Cancelled, '=%1', false);
            ReservationSchEntry.SetFilter("Admission Is", '=%1', ReservationSchEntry."Admission Is"::Open);
            ReservationSchEntry.SetFilter("External Schedule Entry No.", '=%1', ReservationAccessEntry."External Adm. Sch. Entry No.");
            ReservationSchEntry.FindFirst();

            AdmissionScheduleEntryNo := ReservationSchEntry."Entry No.";

        end else begin
            AdmissionScheduleEntryNo := GetCurrentScheduleEntry(Ticket, AdmissionCode, true);
            if (not AdmissionSchEntry.Get(AdmissionScheduleEntryNo)) then
                exit(false);
        end;

        exit(true);
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

    internal procedure GetDefaultAdmissionCode(TicketNo: Code[20]): Code[20]
    var
        Ticket: Record "NPR TM Ticket";
    begin
        if (not Ticket.Get(TicketNo)) then
            exit('');
        exit(GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code"));
    end;

    internal procedure GetDefaultAdmissionCode(ItemNo: Code[20]; VariantCode: Code[10]): Code[20]
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

    procedure GenerateNumberPattern(GeneratePattern: Text[30]; TicketNo: Code[20]) PatternOut: Code[30]
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
                                PatternOut := StrSubstNo(PlaceHolderLbl, PatternOut, GenerateRandomFromPattern(Left));
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

    internal procedure GenerateRandomFromPattern(Pattern: Code[2]) Random: Code[1]
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

    local procedure GetRandom(SeedSize: Integer) RandomInt: Integer
    var
        RandomHexString: Text;
        InvalidValue: Label 'This value must be an integer between 1 and 4.';
    begin
        if (not (SeedSize in [1 .. 4])) then
            Error(InvalidValue);

        RandomHexString := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));

#pragma warning disable AA0139
        RandomInt := HexStringToDecimal(CopyStr(RandomHexString, 1, SeedSize));
#pragma warning restore AA0139
    end;

    internal procedure HexStringToDecimal(HexString: Text[4]) Result: Integer
    var
        InvalidHexDigit: Label 'Invalid hex digit: %1 in string; %2';
        i, HexLen : Integer;
        HexDigit: Char;
        DigitValue: Integer;
    begin
        Result := 0;
        HexLen := StrLen(HexString);
        HexString := UpperCase(HexString);
        for i := 1 to HexLen do begin
            HexDigit := HexString[HexLen - i + 1];
            case (HexDigit) of
                '0' .. '9':
                    DigitValue := HexDigit - '0';
                'A' .. 'F':
                    DigitValue := HexDigit - 'A' + 10;
                else
                    Error(InvalidHexDigit, HexDigit, HexString);
            end;
            Result += DigitValue * Power(16, i - 1);
        end;
    end;

    //local procedure RegisterArrival_Worker(TicketAccessEntryNo: Integer; TicketAdmissionSchEntryNo: Integer; DurationGroupCode: Code[10]; EventDate: Date; EventTime: Time; TimeZoneCode: Code[20]): Integer
    local procedure RegisterArrival_Worker(TicketAccessEntryNo: Integer; TicketAdmissionSchEntryNo: Integer; DurationGroupCode: Code[10]; EventDateTime: DateTime; ScannerStationId: Text[30]): Integer
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        AdmittedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
        DeferRevenue: Codeunit "NPR TM RevenueDeferral";
        FirstAdmission: Boolean;
    begin

        TicketAccessEntry.LockTable();
        TicketAccessEntry.Get(TicketAccessEntryNo);
        FirstAdmission := (TicketAccessEntry."Access Date" = 0D);

        if (TicketAccessEntry."Access Date" = 0D) then begin
            TicketAccessEntry."Access Date" := DT2Date(EventDateTime);
            TicketAccessEntry."Access Time" := DT2Time(EventDateTime);
            TicketAccessEntry.Modify();
            if (DurationGroupCode <> '') then
                SetDuration(TicketAccessEntryNo, TicketAdmissionSchEntryNo, DurationGroupCode, DT2Date(EventDateTime), DT2Time(EventDateTime));

            DeferRevenue.ReadyToRecognize(TicketAccessEntryNo, DT2Date(EventDateTime));
        end;

        if (AdmissionScheduleEntry.Get(TicketAdmissionSchEntryNo)) then;

        AdmittedTicketAccessEntry.Init();
        AdmittedTicketAccessEntry."Ticket No." := TicketAccessEntry."Ticket No.";
        AdmittedTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";
        AdmittedTicketAccessEntry.Type := AdmittedTicketAccessEntry.Type::ADMITTED;
        AdmittedTicketAccessEntry."External Adm. Sch. Entry No." := AdmissionScheduleEntry."External Schedule Entry No.";
        AdmittedTicketAccessEntry.Quantity := TicketAccessEntry.Quantity;
        AdmittedTicketAccessEntry.Open := true;
        AdmittedTicketAccessEntry."Scanner Station ID" := ScannerStationId;
        AdmittedTicketAccessEntry.Insert(true);
        AdmittedTicketAccessEntry."Created Datetime" := CurrentDateTime();
        AdmittedTicketAccessEntry.AdmittedDate := DT2Date(EventDateTime);
        AdmittedTicketAccessEntry.AdmittedTime := DT2Time(EventDateTime);

        AdmittedTicketAccessEntry.Modify();

        OnDetailedTicketEvent(AdmittedTicketAccessEntry);
        CloseReservationEntry(AdmittedTicketAccessEntry);

        NotifyParticipant.CreateOnAdmissionNotification(TicketAccessEntry, AdmittedTicketAccessEntry, FirstAdmission);
        exit(AdmittedTicketAccessEntry."Entry No.");
    end;

    local procedure SetDuration(TicketAccessEntryNo: Integer; TicketAdmissionSchEntryNo: Integer; DurationGroupCode: Code[10]; EventDate: Date; EventTime: Time)
    var
        DurationGroup: Record "NPR TM DurationGroup";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Admission: Record "NPR TM Admission";
        Ticket: Record "NPR TM Ticket";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        AdmissionScheduleEntryNo: Integer;
        ValidUntil: DateTime;
        ReferenceDateTime: DateTime;
        UpdateAccessEntry: Boolean;
    begin
        if (not DurationGroup.Get(DurationGroupCode)) then
            exit;

        ReferenceDateTime := CreateDateTime(EventDate, EventTime);
        ValidUntil := CreateDateTime(0D, 0T);

        TicketAccessEntry.Get(TicketAccessEntryNo);
        TicketAccessEntry.SetCurrentKey("Ticket No.");
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketAccessEntry."Ticket No.");
        TicketAccessEntry.FindSet();

        if (DurationGroup.AlignmentSource = DurationGroup.AlignmentSource::SCANNED) then
            ValidUntil := CalculateDurationValidUntil(DurationGroup, TicketAdmissionSchEntryNo, ReferenceDateTime);

        if (DurationGroup.AlignmentSource = DurationGroup.AlignmentSource::DEFAULT) then
            if (GetTicketScheduleReference(TicketAccessEntry."Entry No.", GetDefaultAdmissionCode(TicketAccessEntry."Ticket No."), AdmissionScheduleEntryNo)) then
                ValidUntil := CalculateDurationValidUntil(DurationGroup, AdmissionScheduleEntryNo, ReferenceDateTime);

        Ticket.Get(TicketAccessEntry."Ticket No.");

        repeat
            TicketBom.Get(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code");
            UpdateAccessEntry := false;

            if (TicketBom.DurationGroupCode = DurationGroupCode) then begin
                if (GetTicketScheduleReference(TicketAccessEntry."Entry No.", TicketAccessEntry."Admission Code", AdmissionScheduleEntryNo)) then begin

                    if (DurationGroup.AlignmentSource = DurationGroup.AlignmentSource::INDIVIDUAL) then
                        ValidUntil := CalculateDurationValidUntil(DurationGroup, AdmissionScheduleEntryNo, ReferenceDateTime);

                    if (Admission.Get(TicketAccessEntry."Admission Code")) then begin
                        case (DurationGroup.SynchronizedActivation) of
                            DurationGroup.SynchronizedActivation::LOCATION:
                                UpdateAccessEntry := (Admission.Type = Admission.Type::LOCATION);
                            DurationGroup.SynchronizedActivation::OCCASION:
                                UpdateAccessEntry := (Admission.Type = Admission.Type::OCCASION);
                            DurationGroup.SynchronizedActivation::ALL_MEMBERS:
                                UpdateAccessEntry := true;
                            DurationGroup.SynchronizedActivation::NA:
                                UpdateAccessEntry := (TicketAccessEntryNo = TicketAccessEntry."Entry No.");
                        end;
                    end;
                end;

                if ((UpdateAccessEntry) and (DT2Date(ValidUntil) > 0D)) then begin
                    if (TicketAccessEntry.DurationUntilDate = 0D) then begin
                        TicketAccessEntry.DurationUntilDate := DT2Date(ValidUntil);
                        TicketAccessEntry.DurationUntilTime := DT2Time(ValidUntil);
                        TicketAccessEntry.Modify();
                    end
                end;
            end;

        until (TicketAccessEntry.Next() = 0);

    end;

    local procedure CalculateDurationValidUntil(DurationGroup: Record "NPR TM DurationGroup"; AdmSchEntryNo: Integer; ReferenceDateTime: DateTime) ValidUntil: DateTime
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        if (not AdmissionScheduleEntry.Get(AdmSchEntryNo)) then
            exit;

        ValidUntil := ReferenceDateTime;
        if (ReferenceDateTime < CreateDateTime(AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time")) then begin
            case (DurationGroup.AlignEarlyArrivalOn) of
                DurationGroup.AlignEarlyArrivalOn::ARRIVAL:
                    ValidUntil := ReferenceDateTime;
                DurationGroup.AlignEarlyArrivalOn::SCHEDULE_START:
                    ValidUntil := CreateDateTime(AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
            end;
        end;

        if (ReferenceDateTime > CreateDateTime(AdmissionScheduleEntry."Admission End Date", AdmissionScheduleEntry."Admission End Time")) then begin
            case (DurationGroup.AlignLateArrivalOn) of
                DurationGroup.AlignLateArrivalOn::ARRIVAL:
                    ValidUntil := ReferenceDateTime;
                DurationGroup.AlignLateArrivalOn::SCHEDULE_END:
                    ValidUntil := CreateDateTime(AdmissionScheduleEntry."Admission End Date", AdmissionScheduleEntry."Admission End Time");
            end;
        end;

        ValidUntil += DurationGroup.DurationMinutes * 60 * 1000;

        if (DurationGroup.CapOnEndTime) then
            if (ValidUntil > CreateDateTime(AdmissionScheduleEntry."Admission End Date", AdmissionScheduleEntry."Admission End Time")) then
                ValidUntil := CreateDateTime(AdmissionScheduleEntry."Admission End Date", AdmissionScheduleEntry."Admission End Time");

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
        DeferRevenue: Codeunit "NPR TM RevenueDeferral";
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

        DeferRevenue.CreateDeferRevenueRequest(TicketAccessEntryNo, Today());

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
            InitialTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
            InitialTicketAccessEntry.FindLast();

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
                            if not CheckIfInitialEntryIsClosedByAnother(OpenTicketAccessEntry) then begin
                                CancelTicketAccessEntry."Closed By Entry No." := ClosedByEntryNo;
                                CancelTicketAccessEntry."Entry No." := 0;
                                CancelTicketAccessEntry.Type := CancelTicketAccessEntry.Type::INITIAL_ENTRY;
                                CancelTicketAccessEntry.Quantity := -QtyToCancel;
                                CancelTicketAccessEntry."External Adm. Sch. Entry No." := InitialTicketAccessEntry."External Adm. Sch. Entry No.";
                                CancelTicketAccessEntry.Insert(true);
                            end;
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

    local procedure CloseTicketAccessEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"; ClosingEntryType: Option): Boolean
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        exit(CloseTicketAccessEntryV2(ClosedByAccessEntry, ClosingEntryType));
#else
        exit(CloseTicketAccessEntryV1(ClosedByAccessEntry, ClosingEntryType));
#endif
    end;

#if (BC17 or BC18 or BC19 or BC20 or BC21)
    local procedure CloseTicketAccessEntryV1(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"; ClosingEntryType: Option) Closed: Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        EntryNo: Integer;
    begin

        DetailedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type, Open, "Posting Date");
        DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', ClosedByAccessEntry."Ticket Access Entry No.");
        DetailedTicketAccessEntry.SetFilter(Type, '=%1', ClosingEntryType);
        DetailedTicketAccessEntry.SetFilter(Open, '=%1', true);
        if (DetailedTicketAccessEntry.FindLast()) then begin
            EntryNo := DetailedTicketAccessEntry."Entry No.";
            DetailedTicketAccessEntry.SetFilter("Closed By Entry No.", '=%1', 0);
            DetailedTicketAccessEntry.SetFilter(Quantity, '=%1', ClosedByAccessEntry.Quantity);
            if (not DetailedTicketAccessEntry.FindFirst()) then
                DetailedTicketAccessEntry.Get(EntryNo);

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
#endif

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    local procedure CloseTicketAccessEntryV2(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"; ClosingEntryType: Option) Closed: Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        DetailedTicketAccessEntryUpdate: Record "NPR TM Det. Ticket AccessEntry";
        EntryNo: Integer;
    begin

        DetailedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type, Open, "Posting Date");
        DetailedTicketAccessEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
        DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', ClosedByAccessEntry."Ticket Access Entry No.");
        DetailedTicketAccessEntry.SetFilter(Type, '=%1', ClosingEntryType);
        DetailedTicketAccessEntry.SetFilter(Open, '=%1', true);
        if (DetailedTicketAccessEntry.FindLast()) then begin
            EntryNo := DetailedTicketAccessEntry."Entry No.";

            // Prefer an entry without a closed link and that has same quantity
            DetailedTicketAccessEntry.SetFilter("Closed By Entry No.", '=%1', 0);
            DetailedTicketAccessEntry.SetFilter(Quantity, '=%1', ClosedByAccessEntry.Quantity);
            if (DetailedTicketAccessEntry.FindFirst()) then
                EntryNo := DetailedTicketAccessEntry."Entry No.";

            DetailedTicketAccessEntryUpdate.ReadIsolation := IsolationLevel::UpdLock;
            DetailedTicketAccessEntryUpdate.Get(EntryNo);
            DetailedTicketAccessEntryUpdate."Closed By Entry No." := ClosedByAccessEntry."Entry No.";
            DetailedTicketAccessEntryUpdate.Open := false;
            DetailedTicketAccessEntryUpdate.Modify();
            Closed := true;
        end;

        if (ClosedByAccessEntry.Type = ClosedByAccessEntry.Type::DEPARTED) then
            ClosedByAccessEntry."External Adm. Sch. Entry No." := DetailedTicketAccessEntry."External Adm. Sch. Entry No.";

        if (ClosedByAccessEntry.Quantity < 0) then
            ClosedByAccessEntry."External Adm. Sch. Entry No." := DetailedTicketAccessEntry."External Adm. Sch. Entry No.";

        exit(Closed);
    end;
#endif

    local procedure GetReservationEntry(TicketAccessEntryNo: Integer; var DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry"): Boolean
    begin

        Clear(DetailedTicketAccessEntry);
        DetailedTicketAccessEntry.Reset();
        DetailedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type, Open);
        DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntryNo);
        DetailedTicketAccessEntry.SetFilter(Type, '=%1', DetailedTicketAccessEntry.Type::RESERVATION);
        DetailedTicketAccessEntry.SetFilter(Quantity, '>0');
        exit(DetailedTicketAccessEntry.FindLast());
    end;

    procedure GetCurrentScheduleEntryForSales(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]): Integer
    var
        ScheduleContext: Option Admit,Sale;
    begin
        exit(GetCurrentScheduleEntry(ItemNo, VariantCode, AdmissionCode, false, ScheduleContext::Sale));
    end;

    procedure GetCurrentScheduleEntry(Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; WithCreate: Boolean): Integer
    begin
        exit(GetCurrentScheduleEntry(Ticket."Item No.", Ticket."Variant Code", AdmissionCode, WithCreate, 0));
    end;

    procedure GetCurrentScheduleEntry(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; WithCreate: Boolean; ScheduleContext: Option Admit,Sale): Integer
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        LocalTime: DateTime;
    begin

        Clear(AdmissionScheduleEntry);
        LocalTime := TimeHelper.GetLocalTimeAtAdmission(AdmissionCode);

        if (GetAdmScheduleEntry(ItemNo, VariantCode, AdmissionCode, DT2Date(LocalTime), DT2Time(LocalTime), AdmissionScheduleEntry, WithCreate, ScheduleContext)) then
            exit(AdmissionScheduleEntry."Entry No.");

        if (Admission."Default Schedule"::NEXT_AVAILABLE = GetAdmissionSchedule(ItemNo, VariantCode, AdmissionCode)) then begin
            AdmissionScheduleEntry.Reset();
            AdmissionScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '>%1', DT2Date(LocalTime));
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
            if (AdmissionScheduleEntry.FindFirst()) then
                exit(AdmissionScheduleEntry."Entry No.");
        end;

        exit(0);
    end;


    local procedure GetAdmScheduleEntry(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; AdmissionDate: Date; AdmissionTime: Time; var AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry"; WithCreate: Boolean; ScheduleContext: Option Admit,Sale): Boolean
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        AdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
        CurrentAdmissionEntryNo: Integer;
        NextAdmissionEntryNo: Integer;
        ReferenceTime: DateTime;
        AdmissionStartTime: DateTime;
        AdmissionEndTime: DateTime;
        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
        RemainingQty: Integer;
    begin

        if (AdmissionSchEntry."Entry No." = 0) then begin

            Admission.Get(AdmissionCode);

            AdmissionSchEntry.Reset();
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
            AdmissionSchEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
            AdmissionSchEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
            AdmissionSchEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            AdmissionSchEntry.SetFilter("Admission Start Date", '=%1', AdmissionDate);
            AdmissionSchEntry.SetFilter("Admission Is", '=%1', AdmissionSchEntry."Admission Is"::Open);
            AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);

            if (WithCreate) then begin
                // gently check
                if (AdmissionSchManagement.IsUpdateScheduleEntryRequired(AdmissionCode, Today())) then
                    AdmissionSchManagement.CreateAdmissionSchedule(AdmissionCode, false, AdmissionDate, 'NPRTMTicketManagement.GetAdmScheduleEntry.1()');

                // still empty, try harder, FindFirst() uses index hinting
                if (not AdmissionSchEntry.FindFirst()) then
                    AdmissionSchManagement.CreateAdmissionSchedule(AdmissionCode, false, AdmissionDate, 'NPRTMTicketManagement.GetAdmScheduleEntry.2()');
            end;

            if (not AdmissionSchEntry.FindSet()) then
                exit(false);

            ReferenceTime := CreateDateTime(AdmissionDate, AdmissionTime);
            repeat

                AdmissionStartTime := CreateDateTime(AdmissionSchEntry."Admission Start Date", AdmissionSchEntry."Admission Start Time");
                AdmissionEndTime := CreateDateTime(AdmissionSchEntry."Admission End Date", AdmissionSchEntry."Admission End Time");

                if (ScheduleContext = ScheduleContext::Admit) then begin
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
                end;

                if ((ScheduleContext = ScheduleContext::Admit) or
                    ((ScheduleContext = ScheduleContext::Sale) and (ValidateAdmSchEntryForSales(AdmissionSchEntry, ItemNo, VariantCode, AdmissionDate, AdmissionTime, ReasonCode, RemainingQty)))) then begin

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

    internal procedure GetTicket(TicketIdentifierType: Enum "NPR TM TicketIdentifierType"; TicketIdentifier: Text[50]; var Ticket: Record "NPR TM Ticket"): Boolean
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


    procedure ValidateAdmSchEntryForSales(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; TicketItemNo: Code[20]; TicketVariantCode: Code[10]; ReferenceDate: Date; ReferenceTime: Time; var ReasonCode: Enum "NPR TM Sch. Block Sales Reason"; var RemainingQuantityOut: Integer): Boolean
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
        DurationFormula: DateFormula;
    begin
        if (not Admission.Get(AdmissionScheduleEntry."Admission Code")) then
            Admission.Init();

        if (not TicketBOM.Get(TicketItemNo, TicketVariantCode, AdmissionScheduleEntry."Admission Code")) then
            TicketBOM.Init();

        // Should this time slot be listed? 
        ActivateOnSales := false;
        if (Item.Get(TicketItemNo)) then begin
            if (TicketType.Get(Item."NPR Ticket Type")) then begin
                if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then begin
                    DurationFormula := TicketBOM."Duration Formula";
                    ActivateOnSales := (TicketBOM."Activation Method" = "NPR TM ActivationMethod_Bom"::POS);
                    if (TicketBOM."Activation Method" = "NPR TM ActivationMethod_Bom"::NA) then
                        // if activate method on BOM is undefined, delegate back to Ticket Type setup
                        ActivateOnSales := ((TicketType."Activation Method" = "NPR TM ActivationMethod_Type"::POS_ALL) or
                                           ((TicketType."Activation Method" = "NPR TM ActivationMethod_Type"::POS_DEFAULT) and TicketBOM.Default));
                end;

                if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_TYPE) then begin
                    ActivateOnSales := ((TicketType."Activation Method" = "NPR TM ActivationMethod_Type"::POS_ALL) or
                                        ((TicketType."Activation Method" = "NPR TM ActivationMethod_Type"::POS_DEFAULT) and TicketBOM.Default));
                    DurationFormula := TicketType."Duration Formula";
                end;

                // Is this schedule beyond the duration set for ticket?
                if (Format(DurationFormula) = '') then
                    Evaluate(DurationFormula, '<0D>', 9);
                if (AdmissionScheduleEntry."Admission Start Date" > CalcDate(DurationFormula, ReferenceDate)) then begin
                    ReasonCode := ReasonCode::ScheduleExceedTicketDuration;
                    exit(false);
                end
            end;
        end;

        // Verify the general window of sales
        if (TicketBOM."Enforce Schedule Sales Limits") then begin
            if (AdmissionScheduleEntry."Sales From Date" <> 0D) then begin
                if (AdmissionScheduleEntry."Sales From Date" > ReferenceDate) then begin
                    ReasonCode := ReasonCode::AdmissionSaleHasNotStartedDate;
                    exit(false);
                end;
                if (AdmissionScheduleEntry."Sales From Date" = ReferenceDate) then
                    if (AdmissionScheduleEntry."Sales From Time" > ReferenceTime) then begin
                        ReasonCode := ReasonCode::AdmissionSaleHasNotStartedTime;
                        exit(false);
                    end;
            end;
            if ((AdmissionScheduleEntry."Sales From Date" = 0D) and (AdmissionScheduleEntry."Sales From Time" <> 0T)) then
                if (AdmissionScheduleEntry."Sales From Time" > ReferenceTime) then begin
                    ReasonCode := ReasonCode::AdmissionSaleHasNotStartedTime;
                    exit(false);
                end;

            if (AdmissionScheduleEntry."Sales Until Date" <> 0D) then begin
                if (ReferenceDate > AdmissionScheduleEntry."Sales Until Date") then begin
                    ReasonCode := ReasonCode::AdmissionSalesHasEndedDate;
                    exit(false);
                end;
                if (ReferenceDate = AdmissionScheduleEntry."Sales Until Date") then
                    if (ReferenceTime > AdmissionScheduleEntry."Sales Until Time") then begin
                        ReasonCode := ReasonCode::AdmissionSalesHasEndedTime;
                        exit(false);
                    end;
            end;
            if ((AdmissionScheduleEntry."Sales Until Date" = 0D) and (AdmissionScheduleEntry."Sales Until Time" <> 0T)) then
                if (ReferenceTime > AdmissionScheduleEntry."Sales Until Time") then begin
                    ReasonCode := ReasonCode::AdmissionSalesHasEndedTime;
                    exit(false);
                end;

        end;

        if (AdmissionScheduleEntry."Event Arrival From Time" = 0T) then
            AdmissionScheduleEntry."Event Arrival From Time" := AdmissionScheduleEntry."Admission Start Time";

        if (AdmissionScheduleEntry."Event Arrival Until Time" = 0T) then
            AdmissionScheduleEntry."Event Arrival Until Time" := AdmissionScheduleEntry."Admission End Time";

        // if ticket will be admitted automatically, we also need to check valid admission time
        if (ActivateOnSales) then begin
            if (AdmissionScheduleEntry."Admission Start Date" <> ReferenceDate) then begin
                ReasonCode := ReasonCode::EventDateNotReferenceDate;
                exit(false); // When ticket is activated on sales, and its a reservation for another date than the reference date, it cant be sold now, don't validate the time slot
            end;

            if (ReferenceTime < AdmissionScheduleEntry."Event Arrival From Time") then begin
                ReasonCode := ReasonCode::EventAdmissionNotStarted;
                exit(false);
            end;
        end;

        IsReservation := ((Admission.Type = Admission.Type::OCCASION) and (Admission."Prebook Is Required"));
        if (IsReservation) or (Admission."Default Schedule"::SCHEDULE_ENTRY = GetAdmissionSchedule(TicketItemNo, TicketVariantCode, AdmissionScheduleEntry."Admission Code")) then begin
            // when we pass arrival until time, we cant sell this time slot.
            if ((AdmissionScheduleEntry."Admission Start Date" = ReferenceDate) and (ReferenceTime > AdmissionScheduleEntry."Event Arrival Until Time")) then begin
                ReasonCode := ReasonCode::EventHasEndedTime;
                exit(false);
            end;
        end;

        // Check the numeric capacity, this is expensive so do it last.
        if (CalculateConcurrentCapacity(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", AdmissionScheduleEntry."Admission Start Date", ConcurrentQuantity, ConcurrentMaxQty)) then
            if (ConcurrentQuantity >= ConcurrentMaxQty) then begin
                ReasonCode := ReasonCode::ConcurrentCapacityExceeded;
                exit(false);
            end;

        GetTicketCapacity(TicketItemNo, TicketVariantCode, AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", AdmissionScheduleEntry."Entry No.", MaxCapacity, CapacityControl);
        RemainingQuantityOut := MaxCapacity - CalculateCurrentCapacity(CapacityControl, AdmissionScheduleEntry."Entry No.");

        ReasonCode := ReasonCode::OpenForSales;
        exit(true);
    end;

    local procedure ValidateTicketAdmissionCapacityExceeded(Ticket: Record "NPR TM Ticket"; AdmissionScheduleEntryNo: Integer; TicketExecutionContext: Option SALES,ADMISSION; var AllowAdmissionOverAllocation: Enum "NPR TM Ternary")
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

        if (TicketExecutionContext = TicketExecutionContext::SALES) and (CapacityControl = Admission."Capacity Control"::ADMITTED) then
            CapacityControl := Admission."Capacity Control"::SALES;

        AdmittedCount := CalculateCurrentCapacity(CapacityControl, AdmissionScheduleEntryNo);
        if (AdmittedCount = 0) then
            Error(UNEXPECTED, AdmissionScheduleEntry.TableCaption(), Admission."Admission Code", AdmittedCount, SHOULD_NOT_BE_ZERO, 0, 0);

        CapacityExceeded := (AdmittedCount > MaxCapacity);

        if (GuiAllowed) then begin
            if (CapacityExceeded) and (AllowAdmissionOverAllocation = AllowAdmissionOverAllocation::TERNARY_UNKNOWN) then begin
                AllowAdmissionOverAllocation := AllowAdmissionOverAllocation::TERNARY_FALSE;
                if (Confirm(CONFIRM_EXCEED_CAPACITY, true, Admission."Admission Code")) then
                    AllowAdmissionOverAllocation := AllowAdmissionOverAllocation::TERNARY_TRUE;
            end;

            if (AllowAdmissionOverAllocation = AllowAdmissionOverAllocation::TERNARY_TRUE) then
                CapacityExceeded := false;
        end;

        if (CapacityExceeded) then
            RaiseError(StrSubstNo(CAPACITY_EXCEEDED, Admission."Admission Code"), CAPACITY_EXCEEDED_NO);

        if (not (AllowAdmissionOverAllocation = AllowAdmissionOverAllocation::TERNARY_TRUE)) then
            if (CalculateConcurrentCapacity(AdmissionSchedule."Admission Code", AdmissionSchedule."Schedule Code", AdmissionScheduleEntry."Admission Start Date", AdmittedCount, MaxCapacity)) then begin
                AdmissionGroupConcurrency.Get(AdmissionSchedule."Concurrency Code");
                CapacityExceeded := (AdmittedCount > MaxCapacity);

                if (CapacityExceeded) then
                    RaiseError(StrSubstNo(CONCURRENT_CAPACITY_EXCEEDED, AdmissionGroupConcurrency.Code), CONCURRENT_CAPACITY_EXCEEDED_NO);
            end;

        if (MaxCapacity > 0) then
            if (AdmittedCount / MaxCapacity * 100 >= Schedule."Notify When Percentage Sold") then
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
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        AdmissionScheduleEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
        AdmissionScheduleEntry.Get(AdmissionScheduleEntryNo);

        case CapacityControl of
            Admission."Capacity Control"::NONE:
                exit(0);

            Admission."Capacity Control"::SALES:
                begin
                    AdmissionScheduleEntry.CalcFields("Initial Entry (All)");
                    AdmittedCount := AdmissionScheduleEntry."Initial Entry (All)";
                end;

            Admission."Capacity Control"::ADMITTED:
                begin
                    AdmissionScheduleEntry.CalcFields("Open Admitted");
                    AdmittedCount := AdmissionScheduleEntry."Open Admitted";
                end;

            Admission."Capacity Control"::FULL:
                begin
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

    local procedure ValidateAdmissionDurationExceeded(TicketAccessEntryNo: Integer; EventDateTime: DateTime)
    var
        ErrorMessage: Text;
    begin
        if (CheckAdmissionDurationExceeded(TicketAccessEntryNo, EventDateTime, ErrorMessage)) then
            RaiseError(ErrorMessage, DURATION_EXCEEDED_NO);
    end;

    local procedure CheckAdmissionDurationExceeded(TicketAccessEntryNo: Integer; EventDateTime: DateTime; var ErrorMessage: Text): Boolean
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DurationLimitDateTime: DateTime;
    begin
        ErrorMessage := '';
        TicketAccessEntry.Get(TicketAccessEntryNo);
        DurationLimitDateTime := CreateDateTime(TicketAccessEntry.DurationUntilDate, TicketAccessEntry.DurationUntilTime);
        if (DurationLimitDateTime = CreateDateTime(0D, 0T)) then
            exit(false);

        if (EventDateTime > DurationLimitDateTime) then begin
            ErrorMessage := StrSubstNo(DURATION_EXCEEDED, TicketAccessEntry."Admission Code", DurationLimitDateTime);
            exit(true);
        end;

        exit(false);
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
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        DetailedTicketAccessEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
        DetailedTicketAccessEntry.SetLoadFields("Entry No.", "Created Datetime");
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

    local procedure ValidateReservationCapacityExceeded(Ticket: Record "NPR TM Ticket"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; var AllowAdmissionOverAllocation: Enum "NPR TM Ternary")
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

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        AdmissionScheduleEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
        AdmissionSchedule.Get(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code");

        GetTicketCapacity(Ticket."Item No.", Ticket."Variant Code", Admission."Admission Code", Schedule."Schedule Code", AdmissionScheduleEntry."Entry No.", MaxCapacity, CapacityControl);

        AdmissionText."Capacity Control" := CapacityControl;

        case CapacityControl of
            Admission."Capacity Control"::NONE:
                exit;

            Admission."Capacity Control"::SALES:
                begin
                    AdmissionScheduleEntry.CalcFields("Open Reservations (All)");
                    AdmittedCount := AdmissionScheduleEntry."Open Reservations (All)";
                end;

            Admission."Capacity Control"::ADMITTED, // Admitted and Full mode are the same when it comes to reservations
            Admission."Capacity Control"::FULL:
                begin
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

        if (GuiAllowed) then begin
            if (CapacityExceeded) and (AllowAdmissionOverAllocation = AllowAdmissionOverAllocation::TERNARY_UNKNOWN) then begin
                AllowAdmissionOverAllocation := AllowAdmissionOverAllocation::TERNARY_FALSE;
                if (Confirm(CONFIRM_EXCEED_CAPACITY, true, Admission."Admission Code")) then
                    AllowAdmissionOverAllocation := AllowAdmissionOverAllocation::TERNARY_TRUE;
            end;

            if (AllowAdmissionOverAllocation = AllowAdmissionOverAllocation::TERNARY_TRUE) then
                CapacityExceeded := false;
        end;

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
        CalendarManagement: Codeunit "NPR TMBaseCalendarManager";
        CalendarDesc: Text;
    begin
        ResponseMessage := '';
        NonWorking := false;
        if (not Admission.Get(AdmissionCode)) then
            exit;

        if (TicketBOM.Get(ItemNo, VariantCode, AdmissionCode)) then
            if (TicketBOM."Ticket Base Calendar Code" <> '') then begin

                CalendarManagement.CheckTicketBomIsNonWorking(TicketBOM, AdmissionDate, TempCustomizedCalendarChange);
                NonWorking := TempCustomizedCalendarChange.Nonworking;
                CalendarDesc := TempCustomizedCalendarChange.Description;

                if (not NonWorking) then begin
                    CalendarManagement.CheckTicketBomAdmissionIsNonWorking(TicketBOM, AdmissionDate, TempCustomizedCalendarChange);
                    NonWorking := TempCustomizedCalendarChange.Nonworking;
                    CalendarDesc := TempCustomizedCalendarChange.Description;
                end;
            end;

        if (not NonWorking) then
            if (Admission."Ticket Base Calendar Code" <> '') then begin
                CalendarManagement.CheckTicketBomAdmissionIsNonWorking(Admission, AdmissionDate, TempCustomizedCalendarChange);
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
        InvoiceListPage: Page "Sales Invoice List";
        SalesHeader: Record "Sales Header";
    begin
        if (not Confirm(HANDLE_POSTPAID)) then
            Error('');

        ShowDialog := (true and GuiAllowed());

        if (ShowDialog) then
            gWindow.Open(HANDLE_POSTPAID_STATUS);

        CollectUnhandledPostpaidTickets(ShowDialog, TempTicket, TempDetailedAccessEntries);
        AggregatePaymentEntries(ShowDialog, TempTicket, TempAggregatedPerRequest, TempAdmissionPerDate);

        if (not PreviewDocument) then begin
            CreatePostpaidTicketInvoice(ShowDialog, TempAggregatedPerRequest, TempAdmissionPerDate, TempTicket);
            MarkPostpaidTicketAsInvoiced(ShowDialog, TempDetailedAccessEntries, TempAggregatedPerRequest, TempTicket);
            if (not TempAggregatedPerRequest.IsEmpty()) then begin
                TempAggregatedPerRequest.FindFirst();
                FirstInvoiceNo := CopyStr(TempAggregatedPerRequest.Description, 1, 20);
                TempAggregatedPerRequest.FindLast();
                LastInvoiceNo := CopyStr(TempAggregatedPerRequest.Description, 1, 20);
                InvoiceDetailsMessage := StrSubstNo(FromToInvLbl, FirstInvoiceNo, LastInvoiceNo);

                SalesHeader.SetRange("No.", FirstInvoiceNo, LastInvoiceNo);
                InvoiceListPage.SetTableView(SalesHeader);
                InvoiceListPage.Run();
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

                    TmpPostpaidTickets."Line No." := TmpAdmissionsPerDate."Entry No.";
                    TmpPostpaidTickets.Modify();
                end;
            end;

            Index += 1;
            if (ShowDialog) then
                if ((Index mod (MaxCount + 100 div 100) = 0)) then
                    gWindow.Update(2, Round(Index / MaxCount * 10000, 1));

        until (TmpPostpaidTickets.Next() = 0);
    end;

    local procedure CreatePostpaidTicketInvoice(ShowDialog: Boolean; var TmpAggregatedPerRequest: Record "NPR TM Ticket Access Entry" temporary; var TmpAdmissionsPerDate: Record "NPR TM Det. Ticket AccessEntry" temporary; var TmpTicket: Record "NPR TM Ticket" temporary)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ItemDescription: Text;
        LineNo: Integer;
        MaxCount: Integer;
        Index: Integer;
        INVOICE_TEXT: Label 'Admitted on %1 - %2';
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
                        SalesLine.Init();
                        SalesLine."Document Type" := SalesHeader."Document Type";
                        SalesLine."Document No." := SalesHeader."No.";
                        SalesLine."Line No." := LineNo;

                        SalesLine.Validate(Type, SalesLine.Type::Item);
                        SalesLine.Validate("No.", TicketReservationRequest."Item No.");
                        SalesLine.Validate("Variant Code", TicketReservationRequest."Variant Code");
                        ItemDescription := SalesLine.Description;

                        SalesLine.Validate(Quantity, TmpAdmissionsPerDate.Quantity);
                        SalesLine.Description := CopyStr(StrSubstNo(INVOICE_TEXT, TmpAdmissionsPerDate."Posting Date", ItemDescription), 1, MaxStrLen(SalesLine.Description));
                        SalesLine.Insert(true);

                        TmpTicket.SetFilter("Line No.", '=%1', TmpAdmissionsPerDate."Entry No.");
                        if (TmpTicket.FindSet()) then begin
                            repeat
                                LineNo += 10000;
                                SalesLine.Init();
                                SalesLine."Document Type" := SalesHeader."Document Type";
                                SalesLine."Document No." := SalesHeader."No.";
                                SalesLine."Line No." := LineNo;
                                SalesLine.Validate(Type, SalesLine.Type::" ");
                                SalesLine.Description := TmpTicket."External Ticket No.";
                                SalesLine.Insert(true);
                            until (TmpTicket.Next() = 0)
                        end;

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

                // This was a bit of misuse, we should not put the invoice number in the scanner station id.
                // 
                // DetTicketAccessEntry."Scanner Station ID" := TmpAggregatedPerRequest.Description; // Invoice number
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
                if (TicketReservationReq.IsEmpty()) then
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

    local procedure CreateSalesLinePerAdmission(var POSSession: Codeunit "NPR POS Session"; var SalesTicketNo: Code[20]; NewAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; EntryNo: Integer; ItemNo: Code[20])
    var
        Admission: Record "NPR TM Admission";
        SaleLinePOS: Record "NPR POS Sale Line";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        SaleLine: Codeunit "NPR POS Sale Line";
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        BasePrice, AddonPrice : Decimal;
    begin
        Admission.Get(NewAdmissionScheduleEntry."Admission Code");
        if Admission."Additional Experience Item No." = '' then
            exit;

        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        SaleLinePOS."No." := Admission."Additional Experience Item No.";
        SaleLinePOS.Description := Admission.Description;
        SaleLinePOS.Quantity := 1;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.InsertLine(SaleLinePOS, false);
        TicketPrice.CalculateScheduleEntryPrice(ItemNo, SaleLinePOS."Variant Code", NewAdmissionScheduleEntry."Admission Code", NewAdmissionScheduleEntry."External Schedule Entry No.", SaleLinePOS."Unit Price", SaleLinePOS."Price Includes VAT", SaleLinePOS."VAT %", Today(), Time(), BasePrice, AddonPrice);
        SaleLinePOS.Validate("Unit Price", BasePrice + AddonPrice);
        SaleLinePOS.Modify();

        SalesTicketNo := SaleLinePOS."Sales Ticket No.";

        TicketReservationRequest.Get(EntryNo);
        TicketReservationRequest."Line No." := SaleLinePOS."Line No.";
        TicketReservationRequest.Modify();
    end;

    internal procedure TicketAdmissionSimulation(Ticket: Record "NPR TM Ticket")
    var
        TMTicketCheck: Page "NPR TM Ticket Admission Sim";
    begin
        TMTicketCheck.SetTicket(Ticket."External Ticket No.");
        TMTicketCheck.RunModal();
    end;

    procedure ShowTicketAccess(Ticket: Record "NPR TM Ticket")
    var
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        AdmisScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TxtBuilder: TextBuilder;
        AdmissionLbl: Label '%1 - Admission is valid between %2 %3 and %4 %5', Comment = '%1 = Admission code, %2 = Start date, %3 = Start time, %4 = End date, %5 = End time';
        ScheduledStartLbl: Label 'Scheduled Start date and time is %1 %2', Comment = '%1 = Start date, %2 = Start time';
        ScheduledEndLbl: Label 'Scheduled End date and time is %1 %2', Comment = '%1 = End date, %2 = End time';
        AllowedStartLbl: Label 'Allowed Start date and time of entry is %1 %2', Comment = '%1 = Start date, %2 = Start time';
        AllowedEndLbl: Label 'Allowed End date and time of entry is %1 %2', Comment = '%1 = End date, %2 = End time';
        TicketStartLbl: Label 'Ticket Valid From date and time is %1 %2', Comment = '%1 = Start date, %2 = Start time';
        TicketEndLbl: Label 'Ticket Valid Until date and time is %1 %2', Comment = '%1 = End date, %2 = End time';
        StartTime, EndTime : Time;
    begin
        TicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
        if TicketAccessEntry.FindSet(false) then
            repeat
                //from reservation
                DetTicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
                DetTicketAccessEntry.SetRange(Type, DetTicketAccessEntry.Type::RESERVATION);
                DetTicketAccessEntry.SetRange("Ticket Access Entry No.", TicketAccessEntry."Entry No.");
                if DetTicketAccessEntry.FindFirst() then begin
                    AdmisScheduleEntry.SetRange("External Schedule Entry No.", DetTicketAccessEntry."External Adm. Sch. Entry No.");
                    if AdmisScheduleEntry.FindFirst() then begin
                        if AdmisScheduleEntry."Event Arrival From Time" <> 0T then
                            StartTime := AdmisScheduleEntry."Event Arrival From Time"
                        else
                            StartTime := AdmisScheduleEntry."Admission Start Time";
                        if AdmisScheduleEntry."Event Arrival Until Time" <> 0T then
                            EndTime := AdmisScheduleEntry."Event Arrival Until Time"
                        else
                            EndTime := AdmisScheduleEntry."Admission End Time";
                        //schedule    
                        TxtBuilder.AppendLine(StrSubstNo(AdmissionLbl, TicketAccessEntry.Description, AdmisScheduleEntry."Admission Start Date", StartTime, AdmisScheduleEntry."Admission End Date", EndTime));
                        TxtBuilder.AppendLine('');
                        TxtBuilder.AppendLine(StrSubstNo(ScheduledStartLbl, AdmisScheduleEntry."Admission Start Date", AdmisScheduleEntry."Admission Start Time"));
                        TxtBuilder.AppendLine(StrSubstNo(ScheduledEndLbl, AdmisScheduleEntry."Admission End Date", AdmisScheduleEntry."Admission End Time"));
                        //event arrival
                        if AdmisScheduleEntry."Event Arrival From Time" <> 0T then
                            TxtBuilder.AppendLine(StrSubstNo(AllowedStartLbl, AdmisScheduleEntry."Admission Start Date", AdmisScheduleEntry."Event Arrival From Time"));
                        if AdmisScheduleEntry."Event Arrival Until Time" <> 0T then
                            TxtBuilder.AppendLine(StrSubstNo(AllowedEndLbl, AdmisScheduleEntry."Admission End Date", AdmisScheduleEntry."Event Arrival Until Time"));
                        TxtBuilder.AppendLine('');
                    end;
                end else begin
                    //from ticket
                    TxtBuilder.AppendLine(StrSubstNo(AdmissionLbl, TicketAccessEntry.Description, Ticket."Valid From Date", Ticket."Valid From Time", Ticket."Valid To Date", Ticket."Valid To Time"));
                    TxtBuilder.AppendLine('');
                    TxtBuilder.AppendLine(StrSubstNo(TicketStartLbl, Ticket."Valid From Date", Ticket."Valid From Time"));
                    TxtBuilder.AppendLine(StrSubstNo(TicketEndLbl, Ticket."Valid To Date", Ticket."Valid To Time"));
                    TxtBuilder.AppendLine('');
                end;
            until TicketAccessEntry.Next() = 0;
        Message(TxtBuilder.ToText());
    end;

    local procedure CheckIfInitialEntryIsClosedByAnother(OpenTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry"): Boolean
    var
        RelatedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        if not RelatedTicketAccessEntry.Get(OpenTicketAccessEntry."Closed By Entry No.") then
            exit(false);
        if RelatedTicketAccessEntry.Type = RelatedTicketAccessEntry.Type::INITIAL_ENTRY then
            exit(true);
        exit(false);
    end;
}

