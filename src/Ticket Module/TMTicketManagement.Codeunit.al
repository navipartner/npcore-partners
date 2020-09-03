codeunit 6059784 "NPR TM Ticket Management"
{
    // NPR4.16/TSA/20150804 CASE 219658 - New Ticket Module, existing functions refactored, new functions added
    // NPR4.16/MMV/20150819 CASE 217433 - Added support for LinePrintMgt print method to PrintTicket()
    // TM1.00/TSA/20151217  CASE 219658-01 NaviPartner Ticket Management
    // TM1.01/TSA/20151222  CASE 230152 Scopechange on functions
    // TM1.02/TSA/20160105  CASE 230873 Fixed the pritning function
    // TM1.03/TSA/20160113  CASE 231260 Added "Admission Registration" option for singel group ticket
    // TM1.04/TSA/20160114 CASE 231834 Added the GetDefaulAdmissionCode function
    // TM80.1.06/TSA/20160119  CASE 232301 Added protection for wrongly typed AuditRole line. Type==Item could be comment,
    // TM80.1.06/TSA/20160121  CASE 232301 Added Serial No. transfer from Audit Role
    // TM1.07/TSA/20160125  CASE 232495 Activation in POS must only activate default admission object
    // TM1.08/TSA/20160212 CASE 234604 Admission Schedule not picked up from XML
    // TM1.08/TSA/20160262  CASE 232262 Dependant admission objects
    // TM1.09/TSA/20160229  CASE 235795 Default Schedule option on Admission Code
    // TM1.09/TSA/20160301  CASE 235860 Sell event tickets in POS
    // TM1.09/TSA/20160321  CASE 237374 tickets with return sales
    // TM1.11/BR/20160331  CASE 237850 change finding of Schedule Entry,multiply by BOM qty
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.13.01/TSA/20160505  CASE Added report.run codeunit wrapper for smoother 2016 transition
    // TM1.15/TSA/20160513  CASE 240864 Cancel Ticket, refactoring of validate arrival
    // TM1.15/TSA/20160525  CASE 242414 Only first ticket being actived
    // TM1.16/TSA/20160627  CASE 245455 Added check that the selected schedule date entry is withing the ticket valid from-to date
    // TM1.17/TSA/20161019  CASE 255556 Added support for multiple different printouts from same sales
    // TM1.17/TSA/20161025  CASE 256205 Refactored GetMaxCapacity function to alose handle max capacity override on AdmSchEntry
    // TM1.17/TSA/20161025  CASE 256152 Conform to OMA Guidelines
    // TM1.19/TSA/20170103  CASE 250631 Added the Cancel entry event if there was no entry to close - as when it is refunded with no admission
    // TM1.20/TSA/20170321  CASE 270164 Events without pre-book required, failed to recognize the request for a specific timeslot and use the current slot instead
    // TM1.20/TSA/20170320  CASE 269171 New function - ChangeConfirmedTicketQuantity
    // TM1.21/TSA/20170418  CASE 272421 New function - IsIdentifierTicketNumber - subscriber of Codeunit Identifier Dissociation
    // TM1.21/TSA/20170508  CASE 271405 Schedule Entries can now own its open/close status will be lost on force generate from RTC page
    // TM1.21/TSA/20170515  CASE 267611 Reducing the number of times a scedule is (re)generated.
    // TM1.22/TSA/20170526  CASE 278142 Changed function to CreatePaymentEntry to invoke CreatePaymentEntryType with type PAYMENT
    // TM1.22/TSA/20170526  CASE 278142 Changed VerifyTicketReference to accept the new payment types
    // TM1.22/TSA/20170608  CASE 279248 Breaking up many tickets to individual print-jobs performs better
    // TM1.23/TSA /20170719 CASE 284248 Changed the error message when MISSING_PAYMENT
    // TM1.23/TSA /20170724 CASE 284798 Corrected Spelling for subscriber function IdentifyThisCodePublisher
    // TM1.24/TSA /20170824 CASE 287582 Payments always close the initial entry
    // TM1.24/TSA /20170906 CASE 287582 Added a check to dissallow assigning a historical schedule entry on ticket create
    // TM1.25/TSA /20171024 CASE 294389 A problem with selecting the Nable schedule for reservation entries and having grace period
    // TM1.26/TSA /20171101 CASE 285601 "Printed Date" set when ticket is printed
    // TM1.26/TSA /20171120 CASE 293916 Refactor of RegisterCancel_Worker()
    // TM1.26/TSA /20171120 CASE 296731 Refactor of RegisterCancel_Worker()
    // TM1.26/TSA /20171122 CASE 297301 Full refactor of GetAdmScheduleEntry()
    // TM1.27/TSA /20171207 CASE 296731 Closed reservation entry on revoke
    // TM1.27/TSA /20171211 CASE 269456 Added support for Template Printing
    // TM1.28/TSA /20180130 CASE 301222 Added function CheckIfConsumed and ConsumeItem
    // TM1.28/MHA /20180202 CASE 302779 Added OnFinishSale POS Workflow
    // TM1.28/TSA /20180220 CASE 305707 Added Base Calander for ticket, defines invalid / closed days.
    // TM1.28/MMV /20180222 CASE 304639 Added OnFinishDebitSale POS Workflow
    // TM1.29/TSA /20180312 CASE 307885 Revoke reservation entry must be closed.
    // TM1.29/TSA /20180314 CASE 307440 Added function IssueTicketsFromToken
    // TM1.29/TSA /20180315 CASE 308299 I18 hardcoded date
    // TM1.29/TSA /20180327 CASE 307113 Added publishers
    // TM1.30/TSA /20180424 CASE 310947 Reworked the RegisterCancel_Worker() function
    // TM1.31/TSA /20180517 CASE 315779 Changed workflow step discovery process to support auto-added steps not enabled by default.
    // TM1.35/TSA /20180723 CASE 322658 SetCurrentKey
    // TM1.36/TSA /20180801 CASE 316463 Added a "Rescan within" function to handle mother with kids that escape during entry through speed gate
    // TM1.36/MHA /20180814  CASE 319706 Deleted function IsIdentifierTicketNumber()
    // TM1.37/TSA /20180910 CASE 327324 Handling "Event Arrival Until Time" and "Event Arrival Start Time"
    // TM1.37/MMV /20180911 CASE 304693 Reverted functions not ready for release in (20180222 CASE 304639)
    // TM1.38/TSA /20181014 CASE 332109 Added eTicket functionality
    // TM1.39/TSA /20190122 CASE 340984 Sort on date due to unexpected order of schedule entries
    // TM1.40/TSA /20190327 CASE 350287 Revoking ticket marks admission as closed (and thus restores capacity)
    // TM1.41/TSA /20190501 CASE 352873 Handling of external number correctly in postpaid tickets
    // TM1.42/TSA /20190826 CASE 340984 Changed sort order for next_available
    // TM1.43/TSA /20190904 CASE 357359 Ticketing, changed RegisterDefaultAdmissionArrivalOnPosSales() to local
    // TM1.43/TSA /20190910 CASE 368043 Refactored "External Item Code"
    // TM1.45/TSA /20191107 CASE 374620 Added OnDetailedTicketEvent() publisher
    // TM1.45/TSA /20191121 CASE 378339 Added ValidateAdmSchEntryForSales()
    // TM1.45/TSA /20191127 CASE 379766 Deligates ticket activation method to Ticket BOM
    // TM1.45/TSA /20191202 CASE 357359 Tickets
    // TM1.45/TSA /20191204 CASE 380754 Waiting list adoption
    // TM1.45/TSA /20200116 CASE 385922 refactored CheckAdmissionCapacityExceeded() to also check for concurrent capacity
    // TM1.46/TSA /20200127 CASE 387138 DiyPrint URL via mail
    // TM1.46/TSA /20200214 CASE 391018 Fixed a problem with admission capacity controll NONE
    // TM1.47/TSA /20200611 CASE 408958 Fixed date range include same day
    // TM1.48/TSA /20200626 CASE 411704 Renamed GetMaxCapacity() to GetAdmissionCapacity(), added GetTicketCapacity()
    // TM1.48/TSA /20200629 CASE 411704 Renamed CheckTicketCapacityExceeded() to CheckTicketConstraintsExceeded()
    // TM1.48/TSA /20200629 CASE 411704 Renamed CheckAdmissionCapacityExceeded() to CheckTicketAdmissionCapacityExceeded()
    // TM1.48/TSA /20200629 CASE 411704 Added Ticket record as parameter to CheckReservationCapacityExceeded()
    // TM1.48/TSA /20200716 CASE 415186 Implement Navigate for tickets


    trigger OnRun()
    var
        Item: Record Item;
        GIUDText: Text[100];
    begin
    end;

    var
        Text6059776: Label 'This value must be an integer between 1 and 4.';
        RandomHexString: Text[100];
        UNSUPPORTED_VALIDATION_METHOD: Label 'Unsupported Ticket Entry Validation Method.';
        INVALID_REFERENCE: Label 'Invalid %1 %2';
        REFERENCE: Label 'reference';
        UNEXPECTED: Label 'Houston, we have a problem. %1.%2 [%3] <> %4.%5 [%6]';
        RESERVATION_NOT_FOUND: Label 'The required reservation for ticket %1 and %2 was not found.';
        NOT_VALID: Label 'Ticket %1 is not valid for %2.';
        CAPACITY_EXCEEDED: Label 'The capacity for %1 has been exceeded. Entry is not allowed.';
        CONCURRENT_CAPACITY_EXCEEDED: Label 'The cuncurrent capacity for group %1 has been exceeded. Entry is not allowed.';
        RESERVATION_MISMATCH: Label 'Your reservation is not for the current event.';
        RESERVATION_NOT_FOR_TODAY: Label 'Your reservation seem not to be valid for the current %1 event. Reservation entry is for %2 %3. ';
        CONF_RES_NOT_FOR_TODAY: Label 'Your reservation seem not to be valid for the current %1 event. Reservation entry is for %2 %3.\\Do you want to proceed with the current action anyway? ';
        RESERVATION_EXCEEDED: Label 'The reservation capacity for %1 at %2 has been exceeded. A maximum of %3 with method %4 is permitted. This action would make it %5.';
        REENTRY_COUNT: Label 'Please specify a valid reentry count for %1 %2.';
        GREATER_THAN: Label '%1 must be greater than %2';
        ADM_NOT_OPEN: Label 'Admission code %1 does not have a schedule that is open for date %2';
        ADM_NOT_OPEN_ENTRY: Label 'Admission code %1 does not have a schedule that is open for entry %2';
        NOT_CONFIRMED: Label 'Ticket %1 has not been confirmed.';
        MISSING_PAYMENT: Label 'Ticket %1 is missing the payment transaction.';
        TICKET_CANCELED: Label 'Ticket %1 has been canceled and is not valid.';
        ADMISSION_MISMATCH: Label 'The Schedule Entry %1 is for admission to %2, but the Ticket Access Entry requires %3.';
        NO_SCHEDULE_FOR_ADM: Label 'There is no valid admission schedule available for %1 today.';
        NO_ADMISSION_CODE: Label 'No admission code was specified and no admission code was marked as default for item %1.';
        EXCLUDE_ADMISSION: Label 'Admission not allowed. The ticket does allow access to both %1 and %2.';
        NOT_WITHIN_TIMEFRAME: Label 'Admission not allowed. Admission to %1 expired on %2.';
        DEPENDENT_ADMISSION: Label 'Admission not allowed. Ticket need to be validated for %1 first.';
        SCHEDULE_REQUIRED: Label 'Admission %1 requires a valid schedule entry to register arrival.';
        TICKET_NOT_VALID_YET: Label 'Ticket %1 is not valid until %2.';
        TICKET_EXPIRED: Label 'Ticket %1 expired on %2.';
        SHOULD_NOT_BE_ZERO: Label 'Should not be zero.';
        QTY_CHANGE_NOT_ALLOWED: Label 'Ticket %1 has been used and quantity cannot be changed. %2 %3.';
        QTY_TOO_LARGE: Label 'The new ticket quantity cannot be greater than %1.';
        SCHEDULE_ENTRY_EXPIRED: Label 'The schedule entry %1 specifies a time in the past (%2) and cant be used for ticket reservation at this time (%3).';
        ITEM_CONSUMED: Label '%1 is marked as consumed for ticket %2.';
        TICKET_CALENDAR: Label 'Ticket calendar defined for %1 %2 %3 states that ticket is not valid for %4.';
        RESERVATION_NOT_FOR_NOW: Label 'The ticket reservation for %4 allows admission from %1 until %2 on %3.\\Current time is: %5';
        EVENT_SOLD_OUT: Label 'This event is sold out. Sign-up on the waiting list to get notified if ticket cancelations.';
        SUCCESS: Label '0';
        UNEXPECTED_NO: Label '-1000';
        INVALID_REFERENCE_NO: Label '-1001';
        RESERVATION_NOT_FOUND_NO: Label '-1002';
        NOT_VALID_NO: Label '-1003';
        CAPACITY_EXCEEDED_NO: Label '-1004';
        RESERVATION_MISMATCH_NO: Label '-1005';
        REENTRY_COUNT_NO: Label '-1006';
        GREATER_THAN_NO: Label '-1007';
        ADM_NOT_OPEN_NO: Label '-1008';
        ADM_NOT_OPEN_NO2: Label '-1009';
        NOT_CONFIRMED_NO: Label '-1010';
        EXCLUDE_ADMISSION_NO: Label '-1011';
        NOT_WITHIN_TIMEFRAME_NO: Label '-1012';
        DEPENDENT_ADMISSION_NO: Label '-1013';
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
        ITEM_CONSUMED_NO: Label '-1026';
        TICKET_CALENDAR_NO: Label '-1027';
        RESERVATION_NOT_FOR_NOW_NO: Label '-1028';
        EVENT_SOLD_OUT_NO: Label '-1029';
        CONCURRENT_CAPACITY_EXCEEDED_NO: Label '-1030';
        INVOICE_TEXT1: Label 'Admission on %1 {%2}';
        INVOICE_TEXT2: Label 'Admission on %1 {%2,...}';
        POSTPAID_RESULT: Label 'Number of postpaid tickets: %1\\Number of invoices: %2\\Invoices created: %3';
        gAccesEntryPaymentType: Option PAYMENT,PREPAID,POSTPAID;
        HANDLE_POSTPAID: Label 'Do you want to generate invoices for postpaid ticket?';
        HANDLE_POSTPAID_STATUS: Label '#1#################\@2@@@@@@@@@@@@@@@@@@';
        gWindow: Dialog;
        POSTPAID_COLLECT: Label 'Scanning ticket admissions...';
        POSTPAID_AGGREGATE: Label 'Aggregating...';
        POSTPAID_INVOICE: Label 'Creating invoices...';
        POSTPAID_UPDATING: Label 'Closing prepaid payments...';
        NO_DEFAULT_SCHEDULE: Label 'The ticket request did not specify a valid timeslot for admission %1 and the ticket rule is to get the default schedule. But there are currently no timeslots that matches %2 "%3".';
        WORKFLOW_DESC: Label 'Print Ticket';

    local procedure IssueTickets(var ItemJournalLine: Record "Item Journal Line")
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        Ticket: Record "NPR TM Ticket";
        TicketNo: Integer;
        TicketQty: Integer;
    begin
        //DELETE THIS FUNCTION
        if ItemJournalLine."Entry Type" <> ItemJournalLine."Entry Type"::Sale then exit;

        Item.Get(ItemJournalLine."Item No.");

        TicketQty := ItemJournalLine.Quantity;

        if TicketType.Get(Item."NPR Ticket Type") and TicketType."Is Ticket" then begin
            for TicketNo := 1 to TicketQty do begin
                Ticket.Init;
                Ticket."No." := '';
                Ticket."No. Series" := TicketType."No. Series";
                Ticket."Ticket Type Code" := TicketType.Code;
                Ticket."Item No." := ItemJournalLine."Item No.";
                Ticket."Variant Code" := ItemJournalLine."Variant Code";
                Ticket."Customer No." := ItemJournalLine."Source No.";
                Ticket."Sales Receipt No." := ItemJournalLine."Source Code";
                Ticket."Sales Header No." := ItemJournalLine."Document No.";
                // Ticket.INSERT(TRUE);
            end;
        end;
    end;

    local procedure IssueTicketsFromSales(var Salesline: Record "Sales Line")
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        Ticket: Record "NPR TM Ticket";
        TicketNo: Integer;
        TicketQty: Integer;
        SalesHeader: Record "Sales Header";
    begin
        //DELETE THIS FUNCTION
        TicketQty := Salesline."Qty. to Ship";

        if Salesline.Type <> Salesline.Type::Item then exit;
        //-NPR4.16
        SalesHeader.Get(Salesline."Document Type", Salesline."Document No.");
        //+NPR4.16

        Item.Get(Salesline."No.");

        if TicketType.Get(Item."NPR Ticket Type") and TicketType."Is Ticket" then begin
            for TicketNo := 1 to TicketQty do begin
                Ticket.Init;
                Ticket."No." := '';
                Ticket."No. Series" := TicketType."No. Series";
                Ticket."Ticket Type Code" := TicketType.Code;
                Ticket."Item No." := Salesline."No.";
                Ticket."Variant Code" := Salesline."Variant Code";
                Ticket."Customer No." := Salesline."Sell-to Customer No.";
                Ticket."Sales Header Type" := Salesline."Document Type";
                Ticket."Sales Header No." := Salesline."Document No.";
                Ticket."Line No." := Salesline."Line No.";
                //-NPR4.16
                Ticket."Sales Receipt No." := SalesHeader."NPR Sales Ticket No.";
                //+NPR4.16
                // Ticket.INSERT(TRUE);
            end;
        end;
    end;

    procedure IssueTicketsFromAuditRoll(var Auditroll: Record "NPR Audit Roll")
    var
        Token: Text[100];
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketType: Record "NPR TM Ticket Type";
        TicketNo: Code[20];
        Ticket: Record "NPR TM Ticket";
        ResponseMessage: Text;
    begin

        if (not (GetReceiptRequestToken(Auditroll."Sales Ticket No.", Auditroll."Line No.", Token))) then
            exit;

        IssueTicketsFromToken(Token, Auditroll."Sales Ticket No.", Auditroll."Line No.");
    end;

    procedure IssueTicketsFromToken(Token: Text[100]; SalesReceiptNo: Code[20]; SalesLineNo: Integer)
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketType: Record "NPR TM Ticket Type";
        Ticket: Record "NPR TM Ticket";
        TicketNo: Code[20];
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

                        //-TM1.45 [379766]
                        // IF (TicketType."Activation Method" = TicketType."Activation Method"::POS_DEFAULT) THEN
                        //   RegisterDefaultAdmissionArrivalOnPosSales (TRUE, Ticket, '', ResponseMessage);
                        //
                        // IF (TicketType."Activation Method" = TicketType."Activation Method"::POS_ALL) THEN
                        //   RegisterAllAdmissionArrivalOnPosSales (TRUE, Ticket, ResponseMessage);

                        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_TYPE) then begin
                            if (TicketType."Activation Method" = TicketType."Activation Method"::POS_DEFAULT) then
                                RegisterDefaultAdmissionArrivalOnPosSales(true, Ticket, ResponseMessage);

                            if (TicketType."Activation Method" = TicketType."Activation Method"::POS_ALL) then
                                RegisterAllAdmissionArrivalOnPosSales(true, Ticket, ResponseMessage);
                        end;

                        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then
                            RegisterTicketBomAdmissionArrivalOnPosSales(true, Ticket, ResponseMessage);
                        //+TM1.45 [379766]

                    end;
                until (Ticket.Next() = 0);

                OnAfterPosTicketArrival(IsCheckedBySubscriber, IsValid, Ticket."No.", Ticket."External Member Card No.", Token, ResponseMessage);
                if ((IsCheckedBySubscriber) and (not IsValid)) then
                    Error(ResponseMessage);

            end;
        end;

        if (TicketRequestManager.IsRevokeRequest(Token)) then begin
            TicketRequestManager.RevokeReservationTokenRequest(Token, false, true, ResponseMessage);

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

    procedure "--Prints--"()
    begin
    end;

    local procedure PrintTicketFromSalesHeader(var SalesHeader: Record "Sales Header")
    var
        Ticket: Record "NPR TM Ticket";
    begin

        Ticket.SetCurrentKey("Sales Header Type", "Sales Header No.");
        Ticket.SetRange("Sales Header Type", SalesHeader."Document Type");
        Ticket.SetRange("Sales Header No.", SalesHeader."No.");

        //-TM1.27 [269456]
        //IF Ticket.FINDSET THEN
        //  IF (PrintSingleTicket(Ticket)) THEN ;
        if (Ticket.FindSet()) then begin
            repeat
                if (PrintSingleTicket(Ticket)) then;
            until (Ticket.Next() = 0);
        end;
        //+TM1.27 [269456]
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

            //-TM1.38 [332109]
            // Ticket2.SETFILTER ("No.", '=%1', Ticket."No.");
            // Ticket2.GET (Ticket."No.");
            // IF (PrintSingleTicket (Ticket2)) THEN ;

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

            //-TM90.1.46 [387138]
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
            //+TM90.1.46 [387138]

            if (PrintTicket) then begin
                Ticket2.SetFilter("No.", '=%1', Ticket."No.");
                Ticket2.Get(Ticket."No.");
                if (PrintSingleTicket(Ticket2)) then;
            end;
        //+TM1.38 [332109]

        until (Ticket.Next() = 0);
    end;

    local procedure PrintTicketUsingFormater(var Ticket: Record "NPR TM Ticket"; PrintObjectType: Option; PrintObjectId: Integer; PrintTemplateCode: Code[20]) Printed: Boolean
    var
        TicketType: Record "NPR TM Ticket Type";
        StdCodeunitCode: Codeunit "NPR Std. Codeunit Code";
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
        TicketUpd: Record "NPR TM Ticket";
        PrintTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin

        case PrintObjectType of
            TicketType."Print Object Type"::CODEUNIT:
                begin
                    if (ObjectOutputMgt.GetCodeunitOutputPath(PrintObjectId) <> '') then
                        LinePrintMgt.ProcessCodeunit(PrintObjectId, Ticket)
                    else
                        CODEUNIT.Run(PrintObjectId, Ticket);
                end;

            TicketType."Print Object Type"::REPORT:
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
        StdCodeunitCode: Codeunit "NPR Std. Codeunit Code";
        ObjectOutputMgt: Codeunit "NPR Object Output Mgt.";
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
    begin

        if (not TicketType.Get(Ticket."Ticket Type Code")) then
            exit(false);

        if (not TicketType."Print Ticket") then
            exit(false);

        Printed := PrintTicketUsingFormater(Ticket, TicketType."Print Object Type", TicketType."Print Object ID", TicketType."RP Template Code");
        if (Printed) then begin
            Ticket."Printed Date" := Today;
            Ticket.Modify();
        end;
    end;

    local procedure "--- OnFinishSale Workflow"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin

        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if Rec."Subscriber Function" <> 'PrintTicketsOnSale' then
            exit;

        Rec.Description := WORKFLOW_DESC;
        Rec."Sequence No." := 120;
    end;

    local procedure CurrCodeunitId(): Integer
    begin

        exit(CODEUNIT::"NPR TM Ticket Management");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure PrintTicketsOnSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR Sale POS")
    begin
        //-#302779 [302779]
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'PrintTicketsOnSale' then
            exit;

        PrintTicketFromSalesTicketNo(SalePOS."Sales Ticket No.");
        //+#302779 [302779]
    end;

    local procedure "--External_API"()
    begin
    end;

    procedure ValidateTicketForArrival(TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO; TicketIdentifier: Text[50]; AdmissionCode: Code[20]; AdmissionScheduleEntryNo: BigInteger; FailWithError: Boolean; var ResponseMessage: Text) MessageNumber: Integer
    var
        Admission: Record "NPR TM Admission";
        ReservationSchEntry: Record "NPR TM Admis. Schedule Entry";
        Ticket: Record "NPR TM Ticket";
        ReservationAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketAccessEntry2: Record "NPR TM Ticket Access Entry";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        AllowUntilDate: Date;
        TicketAccessEntryNo: BigInteger;
    begin

        // Refactored
        ResponseMessage := '';//SUCCESS;

        if (not GetTicket(TicketIdentifierType, TicketIdentifier, Ticket)) then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(INVALID_REFERENCE, REFERENCE, TicketIdentifier), INVALID_REFERENCE_NO));

        if (AdmissionCode = '') then
            AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");

        if not (Admission.Get(AdmissionCode)) then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(INVALID_REFERENCE, Admission.FieldName("Admission Code"), AdmissionCode), INVALID_REFERENCE_NO));

        MessageNumber := VerifyTicketReference(TicketIdentifierType, TicketIdentifier, AdmissionCode, TicketAccessEntryNo, FailWithError, ResponseMessage);
        if (MessageNumber <> 0) then
            exit(RaiseError(FailWithError, ResponseMessage, ResponseMessage, ''));

        MessageNumber := VerifyScheduleReference(TicketAccessEntryNo, AdmissionCode, AdmissionScheduleEntryNo, FailWithError, ResponseMessage);
        if (MessageNumber <> 0) then
            exit(RaiseError(FailWithError, ResponseMessage, ResponseMessage, ''));


        RegisterArrival_Worker(TicketAccessEntryNo, AdmissionScheduleEntryNo);

        MessageNumber := VerifyAdmissionDependencies(TicketAccessEntryNo, FailWithError, ResponseMessage);
        if (MessageNumber <> 0) then
            exit(RaiseError(FailWithError, ResponseMessage, ResponseMessage, ''));

        if (CheckTicketConstraintsExceeded(FailWithError, TicketAccessEntryNo, ResponseMessage)) then
            exit(RaiseError(FailWithError, ResponseMessage, ResponseMessage, ''));

        //IF (CheckAdmissionCapacityExceeded (FailWithError, AdmissionScheduleEntryNo, ResponseMessage)) THEN
        //MessageNumber := CheckAdmissionCapacityExceeded (FailWithError, AdmissionScheduleEntryNo, ResponseMessage);
        MessageNumber := CheckTicketAdmissionCapacityExceeded(FailWithError, Ticket, AdmissionScheduleEntryNo, ResponseMessage); //-+TM1.48 [411704]
        if (MessageNumber <> 0) then
            exit(RaiseError(FailWithError, ResponseMessage, ResponseMessage, ''));

        // Ticket was valid for entry and admission is recorded.
        exit(0);
    end;

    procedure ValidateTicketForDeparture(TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO; TicketIdentifier: Text[50]; AdmissionCode: Code[20]; FailWithError: Boolean; var ResponseMessage: Text) MessageNumber: Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        DepartureAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        //-NPR4.16 - New Functions
        if (GetTicket(TicketIdentifierType, TicketIdentifier, Ticket)) then begin

            //-TM1.04
            if (AdmissionCode = '') then
                AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");
            //+TM1.04

            TicketAccessEntry.SetCurrentKey("Ticket No.", "Admission Code");
            TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
            TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            if (TicketAccessEntry.FindFirst()) then
                RegisterDeparture_Worker(TicketAccessEntry."Entry No.");
        end;

        exit(0);
    end;

    procedure SetTicketProperties(var Ticket: Record "NPR TM Ticket"; ValidFromDate: Date)
    var
        TicketType: Record "NPR TM Ticket Type";
    begin
        //-NPR4.16 - New Function

        TicketType.Get(Ticket."Ticket Type Code");
        Ticket."Valid From Date" := ValidFromDate;
        Ticket.TestField("Valid From Date");

        Ticket."Valid From Time" := 000000T;
        Ticket."Valid To Time" := 235959T;
        Ticket.Blocked := false;
        Ticket."Document Date" := Today;

        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then
            exit;

        case TicketType."Ticket Entry Validation" of
            TicketType."Ticket Entry Validation"::SINGLE,
            TicketType."Ticket Entry Validation"::SAME_DAY:
                begin
                    Ticket."Valid To Date" := Ticket."Valid From Date";
                    if (Format(TicketType."Duration Formula") <> '') then begin
                        Ticket."Valid To Date" := CalcDate(TicketType."Duration Formula", ValidFromDate);
                        if (Ticket."Valid To Date" < Ticket."Valid From Date") then //-+TM90.1.47 [408958]
                            Error(GREATER_THAN, Ticket.FieldCaption("Valid To Date"), Ticket.FieldCaption("Valid From Date"));
                    end;
                end;

            TicketType."Ticket Entry Validation"::MULTIPLE:
                begin
                    TicketType.TestField("Duration Formula");
                    Ticket."Valid To Date" := CalcDate(TicketType."Duration Formula", ValidFromDate);
                    if (Ticket."Valid To Date" < Ticket."Valid From Date") then //-+TM90.1.47 [408958]
                        Error(GREATER_THAN, Ticket.FieldCaption("Valid To Date"), Ticket.FieldCaption("Valid From Date"));
                end;
            else
                Error(UNSUPPORTED_VALIDATION_METHOD);
        end;
    end;

    procedure GetTicketAccessEntryValidDateBoundery(Ticket: Record "NPR TM Ticket"; var LowDate: Date; var HighDate: Date)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        LowDate := DMY2Date(31, 12, 9999); //31129999D;
        HighDate := 0D;

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (TicketAccessEntry.FindSet()) then begin
            repeat
                if (TicketBom.Get(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code")) then begin
                    DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
                    DetTicketAccessEntry.SetFilter(Type, '=%1 | =%2', DetTicketAccessEntry.Type::INITIAL_ENTRY, DetTicketAccessEntry.Type::RESERVATION);
                    DetTicketAccessEntry.FindLast();

                    //-TM1.35 [322658]
                    AdmissionScheduleEntry.SetCurrentKey("External Schedule Entry No.");
                    //+TM1.35 [322658]

                    AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
                    AdmissionScheduleEntry.FindFirst();

                    if (AdmissionScheduleEntry."Admission Start Date" < LowDate) then
                        LowDate := AdmissionScheduleEntry."Admission Start Date";

                    //      IF (TicketBom."Admission Entry Validation" = TicketBom."Admission Entry Validation"::MULTIPLE) THEN
                    if (Format(TicketBom."Duration Formula") <> '') then
                        AdmissionScheduleEntry."Admission End Date" := CalcDate(TicketBom."Duration Formula", AdmissionScheduleEntry."Admission End Date");

                    if (AdmissionScheduleEntry."Admission End Date" > HighDate) then
                        HighDate := AdmissionScheduleEntry."Admission End Date";

                end;
            until (TicketAccessEntry.Next() = 0);
        end;
    end;

    procedure CreateAdmissionAccessEntry(FailWithError: Boolean; Ticket: Record "NPR TM Ticket"; TicketQty: Integer; AdmissionCode: Code[20]; AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry"; var ResponseMessage: Text) ResponseCode: Integer
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        Admission: Record "NPR TM Admission";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        MaxCapacity: Integer;
        CapacityControl: Option;
    begin

        //-NPR5.31 [237374]
        if (TicketQty <= 0) then
            exit(0);
        //+NPR5.31 [237374]

        Admission.Get(AdmissionCode);
        TicketType.Get(Ticket."Ticket Type Code");

        if (AdmissionSchEntry."Entry No." <= 0) then begin
            case Admission."Default Schedule" of
                Admission."Default Schedule"::TODAY,
              Admission."Default Schedule"::NEXT_AVAILABLE:
                    //-#283758 [283758]
                    //AdmissionSchEntry.GET (GetCurrentScheduleEntry (Admission."Admission Code", TRUE));
                    if (not AdmissionSchEntry.Get(GetCurrentScheduleEntry(Admission."Admission Code", true))) then
                        exit(RaiseError(FailWithError, ResponseMessage,
                              StrSubstNo(NO_DEFAULT_SCHEDULE, Admission."Admission Code", Admission.FieldCaption("Default Schedule"), Admission."Default Schedule"), NO_DEFAULT_SCHEDULE_NO));
            //+#283758 [283758]
            //XX_TOADD
            //ELSE
            //  ERROR (Setting requires a schedule entry to allow admission)
            //
            end;
        end else begin

            //-#380754 [380754] refactored
            if (IsSelectedAdmissionSchEntryExpired(AdmissionSchEntry, Today, Time, ResponseMessage, ResponseCode)) then
                exit(RaiseError(FailWithError, ResponseMessage, ResponseMessage, Format(ResponseCode, 0, 9)));
            //+#380754 [380754]

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
        //DetailedTicketAccessEntry."External Adm. Sch. Entry No." := 0; // initial entry has no schedule attached
        DetailedTicketAccessEntry."External Adm. Sch. Entry No." := AdmissionSchEntry."External Schedule Entry No.";
        DetailedTicketAccessEntry.Quantity := TicketAccessEntry.Quantity;
        DetailedTicketAccessEntry.Open := true;
        DetailedTicketAccessEntry.Insert(true);

        if (Admission.Type = Admission.Type::OCCASION) then begin
            RegisterReservation_Worker(TicketAccessEntry."Entry No.", AdmissionSchEntry."Entry No.");
            //ResponseCode := CheckReservationCapacityExceeded (FailWithError, AdmissionSchEntry, ResponseMessage);
            ResponseCode := CheckReservationCapacityExceeded(FailWithError, Ticket, AdmissionSchEntry, ResponseMessage); //-+TM1.48 [411704]
            if (ResponseCode <> 0) then
                exit(ResponseCode);
        end;

        if (GetAdmissionCapacity(AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code", AdmissionSchEntry."Entry No.", MaxCapacity, CapacityControl)) then
            if (CapacityControl = Admission."Capacity Control"::SALES) then begin
                //ResponseCode := CheckAdmissionCapacityExceeded (FailWithError, AdmissionSchEntry."Entry No.", ResponseMessage);
                ResponseCode := CheckTicketAdmissionCapacityExceeded(FailWithError, Ticket, AdmissionSchEntry."Entry No.", ResponseMessage); //-+TM1.48 [411704]
                if (ResponseCode <> 0) then
                    exit(ResponseCode);
            end;

        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_TYPE) then begin
            ResponseCode := CheckTicketAdmissionReservationDate(FailWithError, TicketAccessEntry."Entry No.", AdmissionSchEntry."Entry No.", ResponseMessage);
            if (ResponseCode <> 0) then
                exit(ResponseCode);
        end;

        ResponseCode := CheckTicketBaseCalendar(FailWithError, TicketAccessEntry."Admission Code", Ticket."Item No.", Ticket."Variant Code", AdmissionSchEntry."Admission Start Date", ResponseMessage);
        if (ResponseCode <> 0) then
            exit(ResponseCode);

        exit(0);
    end;

    local procedure IsSelectedAdmissionSchEntryExpired(AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry"; ReferenceDate: Date; ReferenceTime: Time; var ResponseMessage: Text; var ResponseCode: Integer) IsExpired: Boolean
    begin

        //-#380754 [380754]
        if (AdmissionSchEntry."Admission End Date" = ReferenceDate) then begin

            if ((AdmissionSchEntry."Event Arrival Until Time" = 0T) and
                (AdmissionSchEntry."Admission End Time" < ReferenceTime)) then begin
                ResponseMessage := StrSubstNo(SCHEDULE_ENTRY_EXPIRED,
                    AdmissionSchEntry."External Schedule Entry No.",
                    StrSubstNo('%1 - %2', Format(AdmissionSchEntry."Admission End Date", 0, 9), Format(AdmissionSchEntry."Admission Start Time", 0, 9)),
                    StrSubstNo('%1 - %2', Format(ReferenceDate, 0, 9), Format(ReferenceTime, 0, 9)));
                Evaluate(ResponseCode, SCHEDULE_ENTRY_EXPIRED_NO);
                exit(true);
            end;

            if ((AdmissionSchEntry."Event Arrival Until Time" <> 0T) and
                (AdmissionSchEntry."Event Arrival Until Time" < ReferenceTime)) then begin
                ResponseMessage := StrSubstNo(SCHEDULE_ENTRY_EXPIRED,
                    AdmissionSchEntry."External Schedule Entry No.",
                    StrSubstNo('%1 - %2', Format(AdmissionSchEntry."Admission End Date", 0, 9), Format(AdmissionSchEntry."Admission Start Time", 0, 9)),
                    StrSubstNo('%1 - %2', Format(ReferenceDate, 0, 9), Format(ReferenceTime, 0, 9)));
                Evaluate(ResponseCode, SCHEDULE_ENTRY_EXPIRED_NO2);
                exit(true);
            end;

        end;

        if (AdmissionSchEntry."Admission End Date" < ReferenceDate) then begin
            ResponseMessage := StrSubstNo(SCHEDULE_ENTRY_EXPIRED,
                AdmissionSchEntry."External Schedule Entry No.",
                StrSubstNo('%1 - %2', Format(AdmissionSchEntry."Admission End Date", 0, 9), Format(AdmissionSchEntry."Admission End Time", 0, 9)),
                StrSubstNo('%1 - %2', Format(ReferenceDate, 0, 9), Format(ReferenceTime, 0, 9)));
            Evaluate(ResponseCode, SCHEDULE_ENTRY_EXPIRED_NO3);
            exit(true);
        end;

        exit(false); // not expired
        //+#380754 [380754]
    end;

    procedure CreatePaymentEntry(Ticket: Record "NPR TM Ticket")
    var
        AdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        Admission: Record "NPR TM Admission";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        PaymentType: Option PAYMENT,PREPAID,POSPAID;
    begin

        // [278142] Implementation moved to CreatePaymentEntryType
        CreatePaymentEntryType(Ticket, PaymentType::PAYMENT, 'POS', '');
    end;

    procedure CreatePaymentEntryType(Ticket: Record "NPR TM Ticket"; PaymentType: Option PAYMENT,PREPAID,POSPAID; PaymentReferenceNo: Code[20]; CustomerNo: Code[20])
    var
        AdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        Admission: Record "NPR TM Admission";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        //-TM1.22 [278142]

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
            end;

        until (AdmissionBOM.Next() = 0);
    end;

    procedure ChangeConfirmedTicketQuantity(FailWithError: Boolean; TicketNo: Code[20]; AdmissionCode: Code[20]; NewTicketQuantity: Integer; var ResponseMessage: Text): Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        ResultCode: Integer;
        TicketAccessEntryNo: BigInteger;
    begin

        //-TM1.20 [269171]
        ResultCode := VerifyTicketReference(0, TicketNo, AdmissionCode, TicketAccessEntryNo, FailWithError, ResponseMessage);
        if (ResultCode <> 0) then
            exit(RaiseError(FailWithError, ResponseMessage, ResponseMessage, ''));

        // multi admission tickets
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        if (AdmissionCode <> '') then
            TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        TicketAccessEntry.FindSet();
        repeat
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
            if (DetTicketAccessEntry.FindFirst()) then
                exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(QTY_CHANGE_NOT_ALLOWED, TicketNo,
                      DetTicketAccessEntry.TableCaption, DetTicketAccessEntry."Entry No."), QTY_CHANGE_NOT_ALLOWED_NO));
        until (TicketAccessEntry.Next() = 0);

        // All entries have initial sales quantity
        DetTicketAccessEntry.Reset();
        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
        DetTicketAccessEntry.FindFirst();
        if (NewTicketQuantity > DetTicketAccessEntry.Quantity) then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(QTY_TOO_LARGE, DetTicketAccessEntry.Quantity), QTY_TOO_LARGE_NO));

        TicketAccessEntry.FindSet();
        repeat
            TicketAccessEntry.Quantity := NewTicketQuantity;
            TicketAccessEntry.Modify();
        until (TicketAccessEntry.Next() = 0);

        exit(0);
        //-TM1.20 [269171]
    end;

    local procedure RegisterDefaultAdmissionArrivalOnPosSales(FailWithError: Boolean; Ticket: Record "NPR TM Ticket"; ResponseMessage: Text): Boolean
    var
        AdmissionCode: Code[20];
    begin

        AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");

        //-TM1.45 [379766] - refactored, implementation moved
        exit(RegisterAdmissionArrivalOnPosSales(FailWithError, Ticket, AdmissionCode, ResponseMessage));
        //+TM1.45 [379766]
    end;

    local procedure RegisterAllAdmissionArrivalOnPosSales(FailWithError: Boolean; Ticket: Record "NPR TM Ticket"; ResponseMessage: Text)
    var
        Admission: Record "NPR TM Admission";
        AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin

        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        if (TicketBom.IsEmpty()) then
            Error(NO_ADMISSION_CODE, Ticket."Item No.");

        TicketBom.FindSet();
        repeat
            Admission.Get(TicketBom."Admission Code");
            //-TM1.45 [379766]
            // RegisterDefaultAdmissionArrivalOnPosSales (FailWithError, Ticket, Admission."Admission Code", ResponseMessage);
            RegisterAdmissionArrivalOnPosSales(FailWithError, Ticket, Admission."Admission Code", ResponseMessage);
        //+TM1.45 [379766]

        until (TicketBom.Next() = 0);
    end;

    local procedure RegisterTicketBomAdmissionArrivalOnPosSales(FailWithError: Boolean; Ticket: Record "NPR TM Ticket"; ResponseMessage: Text)
    var
        Admission: Record "NPR TM Admission";
        AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketType: Record "NPR TM Ticket Type";
    begin

        //-TM1.45 [379766]
        TicketType.Get(Ticket."Ticket Type Code");

        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        if (not TicketBom.FindSet()) then
            Error(NO_ADMISSION_CODE, Ticket."Item No.");

        repeat
            Admission.Get(TicketBom."Admission Code");

            case TicketBom."Activation Method" of
                TicketBom."Activation Method"::SCAN:
                    ; // Ignore
                TicketBom."Activation Method"::POS:
                    RegisterAdmissionArrivalOnPosSales(FailWithError, Ticket, Admission."Admission Code", ResponseMessage);
                TicketBom."Activation Method"::NA:
                    begin
                        if ((TicketType."Activation Method" = TicketType."Activation Method"::POS_DEFAULT) and TicketBom.Default) then
                            RegisterAdmissionArrivalOnPosSales(FailWithError, Ticket, Admission."Admission Code", ResponseMessage);
                        if (TicketType."Activation Method" = TicketType."Activation Method"::POS_ALL) then
                            RegisterAdmissionArrivalOnPosSales(FailWithError, Ticket, Admission."Admission Code", ResponseMessage);
                    end;
            end;
        until (TicketBom.Next() = 0);
        //+TM1.45 [379766]
    end;

    local procedure RegisterAdmissionArrivalOnPosSales(FailWithError: Boolean; Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; ResponseMessage: Text): Boolean
    var
        Admission: Record "NPR TM Admission";
        AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        //-TM1.45 [379766] - refactored
        if (Admission."Default Schedule" = Admission."Default Schedule"::SCHEDULE_ENTRY) then begin
            DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
            if (not DetTicketAccessEntry.FindFirst()) then
                Error(SCHEDULE_REQUIRED, AdmissionCode);

            AdmissionSchEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
            AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);
            if not (AdmissionSchEntry.FindFirst()) then
                AdmissionSchEntry."Entry No." := -1;

        end else begin

            AdmissionSchEntry."Entry No." := -1;

        end;

        exit(0 = ValidateTicketForArrival(0, Ticket."No.", AdmissionCode, AdmissionSchEntry."Entry No.", FailWithError, ResponseMessage));

        //+TM1.45 [379766]
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

    procedure RevokeTicketAccessEntry(TicketAccessEntryNo: Integer; FailWithError: Boolean; var ResponseMessage: Text) MessageNumber: Integer
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin

        if (not TicketAccessEntry.Get(TicketAccessEntryNo)) then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(INVALID_REFERENCE, TicketAccessEntry.FieldCaption("Entry No."), TicketAccessEntryNo), INVALID_REFERENCE_NO));

        TicketAccessEntry.Status := TicketAccessEntry.Status::BLOCKED;
        TicketAccessEntry.Modify();

        Ticket.Get(TicketAccessEntry."Ticket No.");
        if (not Ticket.Blocked) then begin
            Ticket.Blocked := true;
            Ticket."Blocked Date" := Today;
            Ticket.Modify();
        end;

        RegisterCancel_Worker(TicketAccessEntry."Entry No.");

        //-TM1.38 [332109]
        TicketRequestManager.OnAfterBlockTicketPublisher(Ticket."No.");
        //+TM1.38 [332109]
    end;

    procedure VerifyTicketReference(TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO; TicketIdentifier: Text[50]; AdmissionCode: Code[20]; var TicketAccessEntryNo: BigInteger; FailWithError: Boolean; var ResponseMessage: Text) MessageNumber: Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        if (not GetTicket(TicketIdentifierType, TicketIdentifier, Ticket)) then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(INVALID_REFERENCE, REFERENCE, TicketIdentifier), INVALID_REFERENCE_NO));

        if (Ticket."Ticket Reservation Entry No." <> 0) then begin
            if (not TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
                exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(NOT_CONFIRMED, TicketIdentifier), NOT_CONFIRMED_NO));

            if (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CANCELED) then
                exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(TICKET_CANCELED, TicketIdentifier), TICKET_CANCELED_NO));

            if (TicketReservationRequest."Request Status" <> TicketReservationRequest."Request Status"::CONFIRMED) then
                exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(NOT_CONFIRMED, TicketIdentifier), NOT_CONFIRMED_NO));
        end;

        if (Ticket.Blocked) then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(TICKET_CANCELED, TicketIdentifier), TICKET_CANCELED_NO));

        TicketAccessEntry.SetCurrentKey("Ticket No.");
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (AdmissionCode <> '') then
            TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

        if (not TicketAccessEntry.FindFirst()) then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(NOT_VALID, TicketIdentifier, AdmissionCode), NOT_VALID_NO));

        if (TicketAccessEntry.Status = TicketAccessEntry.Status::BLOCKED) then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(TICKET_CANCELED, TicketIdentifier), TICKET_CANCELED_NO));

        DetailedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.");
        DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetailedTicketAccessEntry.SetFilter(Type, '=%1|=%2|%3', DetailedTicketAccessEntry.Type::PAYMENT, DetailedTicketAccessEntry.Type::PREPAID, DetailedTicketAccessEntry.Type::POSTPAID);
        if (DetailedTicketAccessEntry.IsEmpty()) then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(MISSING_PAYMENT, TicketIdentifier), MISSING_PAYMENT_NO));

        TicketAccessEntryNo := TicketAccessEntry."Entry No.";
        exit(0);
    end;

    procedure CheckIfConsumed(FailOnError: Boolean; TicketNo: Code[20]; AdmissionCode: Code[20]; ItemNo: Code[20]; var ReasonText: Text): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        //-TM1.28 [301222]
        if (not Ticket.Get(TicketNo)) then
            exit(0 = RaiseError(FailOnError, ReasonText, StrSubstNo(INVALID_REFERENCE, Ticket.TableCaption, TicketNo), INVALID_REFERENCE_NO));

        if (AdmissionCode = '') then
            AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (not TicketAccessEntry.FindFirst()) then
            exit(0 = RaiseError(FailOnError, ReasonText, StrSubstNo(INVALID_REFERENCE, TicketAccessEntry.TableCaption, TicketAccessEntry.GetFilters), INVALID_REFERENCE_NO));

        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::CONSUMED);
        DetTicketAccessEntry.SetFilter("Sales Channel No.", '=%1', ItemNo);

        if (not FailOnError) then
            exit(not DetTicketAccessEntry.IsEmpty());

        if (DetTicketAccessEntry.IsEmpty()) then
            exit(false); // not consumed

        Error(ITEM_CONSUMED, ItemNo, Ticket."External Ticket No.");
    end;

    procedure ConsumeItem(FailOnError: Boolean; TicketNo: Code[20]; AdmissionCode: Code[20]; ItemNo: Code[20]; var ReasonText: Text): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        //-TM1.28 [301222]
        if (not Ticket.Get(TicketNo)) then
            exit(0 = RaiseError(FailOnError, ReasonText, StrSubstNo(INVALID_REFERENCE, Ticket.TableCaption, TicketNo), INVALID_REFERENCE_NO));

        if (AdmissionCode = '') then
            AdmissionCode := GetDefaultAdmissionCode(Ticket."Item No.", Ticket."Variant Code");

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (not TicketAccessEntry.FindFirst()) then
            exit(0 = RaiseError(FailOnError, ReasonText, StrSubstNo(INVALID_REFERENCE, TicketAccessEntry.TableCaption, TicketAccessEntry.GetFilters), INVALID_REFERENCE_NO));

        DetTicketAccessEntry.Init;
        DetTicketAccessEntry."Entry No." := 0;
        DetTicketAccessEntry."Ticket No." := TicketNo;
        DetTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";
        DetTicketAccessEntry.Type := DetTicketAccessEntry.Type::CONSUMED;
        DetTicketAccessEntry.Quantity := 1;
        DetTicketAccessEntry.Open := false;
        DetTicketAccessEntry."Sales Channel No." := ItemNo;
        DetTicketAccessEntry."Created Datetime" := CurrentDateTime;
        DetTicketAccessEntry."User ID" := UserId;
        DetTicketAccessEntry.Insert();

        exit(true);
    end;

    procedure "--UI--"()
    begin
    end;

    procedure LookUpTicketType(var TicketTypeCode: Code[20])
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketTypeForm: Page "NPR TM Ticket Type";
    begin
        TicketTypeForm.HideTickets;
        TicketTypeForm.LookupMode(true);
        if TicketTypeForm.RunModal = ACTION::LookupOK then begin
            TicketTypeForm.GetRecord(TicketType);
            TicketTypeCode := TicketType.Code;
        end;
    end;

    procedure "--Locals--"()
    begin
    end;

    local procedure VerifyScheduleReference(TicketAccessEntryNo: BigInteger; AdmissionCode: Code[20]; var AdmissionScheduleEntryNo: BigInteger; FailWithError: Boolean; var ResponseMessage: Text) MessageNumber: Integer
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
                exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(RESERVATION_NOT_FOUND, Ticket."External Ticket No.", Admission.Description), RESERVATION_NOT_FOUND_NO));

            ReservationAccessEntry.SetCurrentKey("External Adm. Sch. Entry No.");

            //-TM1.37 [327324]
            ReservationSchEntry.SetFilter(Cancelled, '=%1', false);
            ReservationSchEntry.SetFilter("Admission Is", '=%1', ReservationSchEntry."Admission Is"::OPEN);
            //+TM1.37 [327324]

            ReservationSchEntry.SetFilter("External Schedule Entry No.", '=%1', ReservationAccessEntry."External Adm. Sch. Entry No.");
            ReservationSchEntry.FindFirst();

            //-TM1.37 [327324]
            // find the todays/now entry
            // IF (AdmissionScheduleEntryNo < 0) THEN
            //   AdmissionScheduleEntryNo := GetCurrentScheduleEntry (AdmissionCode, TRUE);
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

                if not ((ReferenceTime >= AdmissionStartTime) and (ReferenceTime <= AdmissionEndTime)) then
                    exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(RESERVATION_NOT_FOR_NOW, DT2Time(AdmissionStartTime), DT2Time(AdmissionEndTime), DT2Date(AdmissionStartTime), AdmissionCode, Time), RESERVATION_NOT_FOR_NOW_NO));

                AdmissionScheduleEntryNo := ReservationSchEntry."Entry No.";
            end;

            //+TM1.37 [327324]

            if (AdmissionScheduleEntryNo = 0) then
                exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(RESERVATION_NOT_FOR_TODAY, Admission."Admission Code", ReservationSchEntry."Admission Start Date", ReservationSchEntry."Admission Start Time"), RESERVATION_NOT_FOR_TODAY_NO));

            if (not AdmissionSchEntry.Get(AdmissionScheduleEntryNo)) then
                exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(RESERVATION_NOT_FOUND, Ticket."External Ticket No.", Admission.Description), RESERVATION_NOT_FOUND_NO));

            if (AdmissionSchEntry."External Schedule Entry No." <> ReservationAccessEntry."External Adm. Sch. Entry No.") then
                if (not GuiAllowed) then begin
                    exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(RESERVATION_MISMATCH), RESERVATION_MISMATCH_NO));
                end else begin
                    //-TM1.20 [270164]
                    if (not Confirm(CONF_RES_NOT_FOR_TODAY, true, Admission.Description, ReservationSchEntry."Admission Start Date", ReservationSchEntry."Admission Start Time")) then
                        exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(RESERVATION_MISMATCH), RESERVATION_MISMATCH_NO));
                    AdmissionScheduleEntryNo := ReservationSchEntry."Entry No.";
                    //+TM1.20 [270164]
                end;

        end else begin

            // Get suggested admission schedule entry
            //-TM1.20 [270164]
            if (AdmissionScheduleEntryNo > 0) then begin
                AdmissionSchEntry.SetFilter("External Schedule Entry No.", '=%1', AdmissionScheduleEntryNo);
                AdmissionSchEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
                AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);
                AdmissionSchEntry.SetFilter("Admission Is", '=%1', AdmissionSchEntry."Admission Is"::OPEN);
                if (not AdmissionSchEntry.FindFirst()) then
                    exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(ADM_NOT_OPEN_ENTRY, AdmissionCode, AdmissionScheduleEntryNo), ADM_NOT_OPEN_NO2));
                //+TM1.20 [270164]
            end else begin
                // Get the current admission schedule
                AdmissionScheduleEntryNo := GetCurrentScheduleEntry(AdmissionCode, true);
                if (not AdmissionSchEntry.Get(AdmissionScheduleEntryNo)) then
                    exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(ADM_NOT_OPEN, AdmissionCode, Today), ADM_NOT_OPEN_NO2));
            end;

        end;

        if (AdmissionSchEntry."Admission Is" <> AdmissionSchEntry."Admission Is"::OPEN) then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(ADM_NOT_OPEN, AdmissionCode, Today), ADM_NOT_OPEN_NO));

        exit(0);
    end;

    local procedure VerifyAdmissionDependencies(TicketAccessEntryNo: BigInteger; FailWithError: Boolean; var ResponseMessage: Text) MessageNumber: Integer
    var
        Admission: Record "NPR TM Admission";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketAccessEntry2: Record "NPR TM Ticket Access Entry";
        AllowUntilDate: Date;
    begin
        //-TM1.08
        TicketAccessEntry.Get(TicketAccessEntryNo);
        Admission.Get(TicketAccessEntry."Admission Code");

        if (Admission."Dependent Admission Code" <> '') then begin
            TicketAccessEntry2.SetFilter("Ticket No.", '=%1', TicketAccessEntry."Ticket No.");
            TicketAccessEntry2.SetFilter("Admission Code", '=%1', Admission."Dependent Admission Code");

            if (TicketAccessEntry2.FindFirst()) then begin
                if (TicketAccessEntry2."Access Date" = 0D) then
                    if (Admission."Dependency Type" = Admission."Dependency Type"::NA) then
                        exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(DEPENDENT_ADMISSION, Admission."Dependent Admission Code"), DEPENDENT_ADMISSION_NO));

                if (TicketAccessEntry2."Access Date" <> 0D) then begin
                    if (Admission."Dependency Type" = Admission."Dependency Type"::EXCLUDE) then
                        exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(EXCLUDE_ADMISSION, Admission."Admission Code", Admission."Dependent Admission Code"), EXCLUDE_ADMISSION_NO));

                    if (Admission."Dependency Type" = Admission."Dependency Type"::TIMEFRAME) then begin
                        Admission.TestField("Dependency Timeframe");
                        AllowUntilDate := CalcDate(Admission."Dependency Timeframe", TicketAccessEntry2."Access Date");
                        if (TicketAccessEntry."Access Date" > AllowUntilDate) then
                            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(NOT_WITHIN_TIMEFRAME, Admission."Admission Code", AllowUntilDate), NOT_WITHIN_TIMEFRAME_NO));
                    end;
                end;
            end;
        end;

        exit(0);
    end;

    local procedure GetDefaultAdmissionCode(ItemNo: Code[20]; VariantCode: Code[10]) AdmissionCode: Code[20]
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

    local procedure RaiseError(FailWithError: Boolean; var ResponseMessage: Text; MessageText: Text; MessageId: Text) MessageNumber: Integer
    begin
        ResponseMessage := MessageText;

        if (MessageId <> '') then
            ResponseMessage := StrSubstNo('[%1] - %2', MessageId, MessageText);

        if (FailWithError) then
            Error(ResponseMessage);

        if ((MessageId = '') or (not Evaluate(MessageNumber, MessageId))) then
            MessageNumber := -1;

        asserterror Error(''); // quiet rollback!
        exit(MessageNumber);
    end;

    procedure GenerateCertificateNumber(GeneratePattern: Text[30]; TicketNo: Code[20]) "Certificate Number": Code[30]
    var
        String: Codeunit "NPR String Library";
        ClauseString: Codeunit "NPR String Library";
        Clauses: Integer;
        Clause: Integer;
        PosStartClause: Integer;
        PosEndClause: Integer;
        Pattern: Text[5];
        SubPattern: Text[2];
        PatternLength: Integer;
        Itt: Integer;
        ErrPattern: Label 'Error in Pattern %1';
    begin
        if GeneratePattern = '' then
            exit;

        "Certificate Number" := '';
        String.Construct(UpperCase(GeneratePattern));
        Clauses := String.CountOccurences('[');
        if String.CountOccurences(']') <> Clauses then
            Error(ErrPattern, GeneratePattern);

        while StrLen(GeneratePattern) > 0 do begin
            PosStartClause := StrPos(GeneratePattern, '[');
            PosEndClause := StrPos(GeneratePattern, ']');
            PatternLength := PosEndClause - PosStartClause - 1;
            Pattern := CopyStr(GeneratePattern, PosStartClause + 1, PatternLength);
            if PosStartClause > 1 then begin
                "Certificate Number" := "Certificate Number" + CopyStr(GeneratePattern, 1, PosStartClause - 1);
                GeneratePattern := CopyStr(GeneratePattern, PosStartClause);
            end else begin
                String.Construct(Pattern);
                SubPattern := String.SelectStringSep(1, '*');
                if SubPattern = 'S' then
                    "Certificate Number" := "Certificate Number" + TicketNo
                else begin
                    Evaluate(PatternLength, String.SelectStringSep(2, '*'));
                    for Itt := 1 to PatternLength do
                        "Certificate Number" := "Certificate Number" + GenerateRandom(SubPattern);

                    if (PosEndClause + 1) <= StrLen(GeneratePattern) then
                        GeneratePattern := CopyStr(GeneratePattern, PosEndClause + 1);

                end;
                if StrLen(GeneratePattern) > PosEndClause then
                    GeneratePattern := CopyStr(GeneratePattern, PosEndClause + 1)
                else
                    GeneratePattern := '';
            end;
        end;
    end;

    local procedure GenerateRandom(Pattern: Code[2]) Random: Code[1]
    var
        Number: Integer;
        Char: Char;
    begin
        Number := GetRandom(2);
        case Pattern of
            'N':
                Random := Format(Number mod 10);
            'A':
                Char := (Number mod 25) + 65;
            'AN':
                begin
                    if (GetRandom(2) mod 35) < 10 then
                        Random := Format(Number mod 10)
                    else
                        Char := (Number mod 25) + 65;
                end;
        end;

        if Random = '' then
            exit(UpperCase(Format(Char)));
    end;

    local procedure GetRandom(Bytes: Integer) RandomInt: Integer
    var
        RandomHexStringLen: Integer;
        i: Integer;
    begin
        if not (Bytes in [1 .. 4]) then
            Error(Text6059776);

        RandomHexStringLen := StrLen(RandomHexString);
        if RandomHexStringLen < Bytes then
            RandomHexString += UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

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

        if RandomHexStringLen = Bytes then
            RandomHexString := ''
        else
            RandomHexString := CopyStr(RandomHexString, Bytes + 1);
    end;

    local procedure RegisterArrival_Worker(TicketAccessEntryNo: BigInteger; TicketAdmissionSchEntryNo: BigInteger)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        AdmittedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        //-NPR4.16 - New Function
        TicketAccessEntry.LockTable();
        TicketAccessEntry.Get(TicketAccessEntryNo);
        if (TicketAccessEntry."Access Date" = 0D) then begin
            TicketAccessEntry."Access Date" := Today;
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

        //-TM1.45 [374620]
        OnDetailedTicketEvent(AdmittedTicketAccessEntry);
        //+TM1.45 [374620]

        CloseReservationEntry(AdmittedTicketAccessEntry);
    end;

    local procedure RegisterReservation_Worker(TicketAccessEntryNo: BigInteger; TicketAdmissionSchEntryNo: BigInteger)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        ReservationTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
    begin
        //-NPR4.16 - New Function

        TicketAccessEntry.Get(TicketAccessEntryNo);

        //-NPR5.31 [235795]
        Admission.Get(TicketAccessEntry."Admission Code");
        if (Admission."Default Schedule" = Admission."Default Schedule"::NONE) then
            exit;
        //+NPR5.31 [235795]

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

        //-TM1.45 [374620]
        OnDetailedTicketEvent(ReservationTicketAccessEntry);
        //+TM1.45 [374620]
    end;

    local procedure RegisterDeparture_Worker(TicketAccessEntryNo: BigInteger)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DepartureTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        //-NPR4.16 - New Function

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

        //-TM1.45 [374620]
        OnDetailedTicketEvent(DepartureTicketAccessEntry);
        //+TM1.45 [374620]
    end;

    local procedure RegisterPayment_Worker(TicketAccessEntryNo: BigInteger; PaymentType: Option; PaymentReferenceNo: Code[20])
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        PaymentTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        //-TM1.22 [278142] Changed signature and implementation

        TicketAccessEntry.Get(TicketAccessEntryNo);

        PaymentTicketAccessEntry.Init();
        PaymentTicketAccessEntry."Ticket No." := TicketAccessEntry."Ticket No.";
        PaymentTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";

        PaymentTicketAccessEntry.Open := false;
        PaymentTicketAccessEntry."Sales Channel No." := PaymentReferenceNo;

        case PaymentType of
            gAccesEntryPaymentType::PAYMENT:
                PaymentTicketAccessEntry.Type := PaymentTicketAccessEntry.Type::PAYMENT;
            gAccesEntryPaymentType::PREPAID:
                PaymentTicketAccessEntry.Type := PaymentTicketAccessEntry.Type::PREPAID;
            gAccesEntryPaymentType::POSTPAID:
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

        //-TM1.24 [287582] - If there is a payment we close an link the initial entry. Sales Capacity require it
        // IF (PaymentType = gAccesEntryPaymentType::PAYMENT) THEN
        //  CloseInitialEntry (PaymentTicketAccessEntry);
        CloseInitialEntry(PaymentTicketAccessEntry);
        //+TM1.24 [287582]

        //-TM1.45 [374620]
        OnDetailedTicketEvent(PaymentTicketAccessEntry);
        //+TM1.45 [374620]
    end;

    local procedure RegisterCancel_Worker(TicketAccessEntryNo: BigInteger)
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
            CancelTicketAccessEntry.Type := CancelTicketAccessEntry.Type::CANCELED;
            CancelTicketAccessEntry."External Adm. Sch. Entry No." := InitialTicketAccessEntry."External Adm. Sch. Entry No.";
            CancelTicketAccessEntry.Quantity := QtyToCancel;
            CancelTicketAccessEntry.Open := false;

            //-TM1.45 [374620]
            //IF (NOT HaveAdmissionEntry) THEN
            //  CancelTicketAccessEntry.INSERT (TRUE);
            if (not HaveAdmissionEntry) then begin
                CancelTicketAccessEntry.Insert(true);
                OnDetailedTicketEvent(CancelTicketAccessEntry);
            end;
            //+TM1.45 [374620]

            ClosedByEntryNo := CancelTicketAccessEntry."Entry No.";

            repeat
                case OpenTicketAccessEntry.Type of
                    //-TM1.26 [296731]
                    OpenTicketAccessEntry.Type::ADMITTED:
                        begin
                            CancelTicketAccessEntry."Closed By Entry No." := OpenTicketAccessEntry."Entry No.";
                            CancelTicketAccessEntry."Entry No." := 0;
                            CancelTicketAccessEntry.Type := CancelTicketAccessEntry.Type::CANCELED;
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

                            //-TM1.45 [374620]
                            OnDetailedTicketEvent(CancelTicketAccessEntry);
                            //+TM1.45 [374620]

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
            CancelTicketAccessEntry.Type := CancelTicketAccessEntry.Type::CANCELED;
            CancelTicketAccessEntry."External Adm. Sch. Entry No." := 0;
            CancelTicketAccessEntry.Quantity := TicketAccessEntry.Quantity;
            CancelTicketAccessEntry.Open := false;
            CancelTicketAccessEntry.Insert(true);

            //-TM1.45 [374620]
            OnDetailedTicketEvent(CancelTicketAccessEntry);
            //+TM1.45 [374620]

        end;
    end;

    local procedure CloseInitialEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"): Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        //-NPR4.16 - New Function

        exit(CloseTicketAccessEntry(ClosedByAccessEntry, DetailedTicketAccessEntry.Type::INITIAL_ENTRY));
    end;

    local procedure CloseReservationEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"): Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        //-NPR4.16 - New Function

        exit(CloseTicketAccessEntry(ClosedByAccessEntry, DetailedTicketAccessEntry.Type::RESERVATION));
    end;

    local procedure CloseArrivalEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"): Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        //-NPR4.16 - New Function

        exit(CloseTicketAccessEntry(ClosedByAccessEntry, DetailedTicketAccessEntry.Type::ADMITTED));
    end;

    local procedure ClosePostpaidEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"): Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin

        exit(CloseTicketAccessEntry(ClosedByAccessEntry, DetailedTicketAccessEntry.Type::PAYMENT));
    end;

    local procedure CloseTicketAccessEntry(var ClosedByAccessEntry: Record "NPR TM Det. Ticket AccessEntry"; ClosingEntryType: Option) Closed: Boolean
    var
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        //-NPR4.16 - New Function

        DetailedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type, Open, "Posting Date");
        DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', ClosedByAccessEntry."Ticket Access Entry No.");
        DetailedTicketAccessEntry.SetFilter(Type, '=%1', ClosingEntryType);
        DetailedTicketAccessEntry.SetFilter(Open, '=%1', true);
        if (DetailedTicketAccessEntry.FindFirst()) then begin
            DetailedTicketAccessEntry."Closed By Entry No." := ClosedByAccessEntry."Entry No.";
            DetailedTicketAccessEntry.Open := false;

            //x  IF (DetailedTicketAccessEntry.Type = DetailedTicketAccessEntry.Type::INITIAL_ENTRY) THEN
            //x    DetailedTicketAccessEntry."External Adm. Sch. Entry No." := ClosedByAccessEntry."External Adm. Sch. Entry No.";

            DetailedTicketAccessEntry.Modify();
            Closed := true;
        end;

        if (ClosedByAccessEntry.Type = ClosedByAccessEntry.Type::DEPARTED) then
            ClosedByAccessEntry."External Adm. Sch. Entry No." := DetailedTicketAccessEntry."External Adm. Sch. Entry No.";

        if (ClosedByAccessEntry.Quantity < 0) then
            ClosedByAccessEntry."External Adm. Sch. Entry No." := DetailedTicketAccessEntry."External Adm. Sch. Entry No.";

        exit(Closed);
    end;

    local procedure GetReservationEntry(TicketAccessEntryNo: BigInteger; var DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry") Closed: Boolean
    begin
        //-NPR4.16 - New Function

        Clear(DetailedTicketAccessEntry);
        DetailedTicketAccessEntry.Reset();
        DetailedTicketAccessEntry.SetCurrentKey("Ticket Access Entry No.", Type, Open);
        DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntryNo);
        DetailedTicketAccessEntry.SetFilter(Type, '=%1', DetailedTicketAccessEntry.Type::RESERVATION);
        //-+TM1.37 [327324] DetailedTicketAccessEntry.SETFILTER (Open, '=%1', TRUE);

        exit(DetailedTicketAccessEntry.FindFirst());
    end;

    procedure GetCurrentScheduleEntry(AdmissionCode: Code[20]; WithCreate: Boolean): BigInteger
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
    begin
        //-NPR4.16 - New Function

        Admission.Get(AdmissionCode);

        Clear(AdmissionScheduleEntry);
        if (GetAdmScheduleEntry(AdmissionCode, Today, Time, AdmissionScheduleEntry, WithCreate)) then
            exit(AdmissionScheduleEntry."Entry No.");

        //-NPR5.31 [235795]
        if (Admission."Default Schedule" = Admission."Default Schedule"::NEXT_AVAILABLE) then begin
            AdmissionScheduleEntry.Reset();

            //-TM1.39 [340984]
            //-TM1.42 [340984]
            //AdmissionScheduleEntry.SETCURRENTKEY ("Admission Code","Schedule Code","Admission Start Date");
            AdmissionScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
            //+TM1.42 [340984]
            //+TM1.39 [340984]

            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '>%1', Today);
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
            if (AdmissionScheduleEntry.FindFirst()) then
                exit(AdmissionScheduleEntry."Entry No.");
        end;
        //+NPR5.31 [235795]

        exit(0);
    end;

    local procedure GetAdmScheduleEntry(AdmissionCode: Code[20]; AdmissionDate: Date; AdmissionTime: Time; var AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry"; WithCreate: Boolean) Found: Boolean
    var
        ScheduleCode: Code[20];
        Schedule: Record "NPR TM Admis. Schedule";
        Admission: Record "NPR TM Admission";
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        AdmissionSchManagement: Codeunit "NPR TM Admission Sch. Mgt.";
        BookablePassedStart: Integer;
        PreviousAdmissionEntryNo: Integer;
        CurrentAdmissionEntryNo: Integer;
        NextAdmissionEntryNo: Integer;
        ReferenceTime: DateTime;
        AdmissionStartTime: DateTime;
        AdmissionEndTime: DateTime;
    begin

        if (AdmissionSchEntry."Entry No." = 0) then begin

            Admission.Get(AdmissionCode);

            //-TM1.26 [297301] refactored multiple timeslots for same date
            AdmissionSchEntry.Reset();
            AdmissionSchEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
            AdmissionSchEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            AdmissionSchEntry.SetFilter("Admission Start Date", '=%1', AdmissionDate);
            AdmissionSchEntry.SetFilter("Admission Is", '=%1', AdmissionSchEntry."Admission Is"::OPEN);
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
                //+TM1.37 [327324]
                //    IF (AdmissionScheduleLines.GET (AdmissionSchEntry."Admission Code", AdmissionSchEntry."Schedule Code")) THEN
                //      BookablePassedStart := AdmissionScheduleLines."Bookable Passed Start (Secs)" * 1000;
                //
                //    AdmissionStartTime := CREATEDATETIME (AdmissionSchEntry."Admission Start Date", AdmissionSchEntry."Admission Start Time");
                //    AdmissionEndTime := CREATEDATETIME (AdmissionSchEntry."Admission End Date", AdmissionSchEntry."Admission End Time");
                //
                //    IF ((ReferenceTime > AdmissionStartTime) AND
                //        (ReferenceTime > AdmissionEndTime) AND
                //        (CurrentAdmissionEntryNo = 0)) THEN BEGIN
                //      PreviousAdmissionEntryNo := AdmissionSchEntry."Entry No.";
                //    END;
                //
                //    IF (BookablePassedStart <> 0) THEN BEGIN
                //      IF ((ReferenceTime >= AdmissionStartTime) AND
                //          (ReferenceTime <= AdmissionStartTime + BookablePassedStart)) THEN BEGIN
                //        PreviousAdmissionEntryNo := CurrentAdmissionEntryNo;
                //        CurrentAdmissionEntryNo := AdmissionSchEntry."Entry No.";
                //      END;
                //    END;
                //
                //    IF (BookablePassedStart = 0) THEN BEGIN
                //      IF ((ReferenceTime >= AdmissionStartTime) AND
                //          (ReferenceTime <= AdmissionEndTime)) THEN BEGIN
                //        PreviousAdmissionEntryNo := CurrentAdmissionEntryNo;
                //        CurrentAdmissionEntryNo := AdmissionSchEntry."Entry No.";
                //      END;
                //    END;
                //
                //    IF ((ReferenceTime < AdmissionStartTime) AND
                //        (ReferenceTime < AdmissionStartTime) AND
                //        (NextAdmissionEntryNo = 0)) THEN BEGIN
                //      NextAdmissionEntryNo := AdmissionSchEntry."Entry No.";
                //    END;


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
                    PreviousAdmissionEntryNo := AdmissionSchEntry."Entry No.";
                end;

                if ((ReferenceTime >= AdmissionStartTime) and
                    (ReferenceTime <= AdmissionEndTime)) then begin
                    PreviousAdmissionEntryNo := CurrentAdmissionEntryNo;
                    CurrentAdmissionEntryNo := AdmissionSchEntry."Entry No.";
                end;

                if ((ReferenceTime < AdmissionStartTime) and
                    (ReferenceTime < AdmissionStartTime) and
                    (NextAdmissionEntryNo = 0)) then begin
                    NextAdmissionEntryNo := AdmissionSchEntry."Entry No.";
                end;
            //+TM1.37 [327324]

            until (AdmissionSchEntry.Next() = 0);

            if (CurrentAdmissionEntryNo <> 0) then
                exit(AdmissionSchEntry.Get(CurrentAdmissionEntryNo));

            case Admission."Default Schedule" of
                Admission."Default Schedule"::TODAY:
                    if ((NextAdmissionEntryNo <> 0) and (AdmissionDate = Today)) then // not open yet, add a grace period here?
                        exit(AdmissionSchEntry.Get(NextAdmissionEntryNo));

                Admission."Default Schedule"::NEXT_AVAILABLE:
                    if (NextAdmissionEntryNo <> 0) then
                        exit(AdmissionSchEntry.Get(NextAdmissionEntryNo));
            end;

            exit(false);
            //+TM1.26 [297301]

        end else begin
            AdmissionSchEntry.Get(AdmissionSchEntry."Entry No.");

        end;
    end;

    local procedure GetTicket(TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO; TicketIdentifier: Text[50]; var Ticket: Record "NPR TM Ticket"): Boolean
    begin
        //-NPR4.16 - New Function

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

        //-TM1.48 [411704]
        if (not GetAdmissionCapacity(AdmissionCode, ScheduleCode, AdmissionScheduleEntryNo, MaxCapacity, CapacityControl)) then
            exit(false);

        if (not TicketAdmissionBOM.Get(TicketItemNo, TicketVariantCode, AdmissionCode)) then
            exit(false);

        MaxCapacity := Round(MaxCapacity * TicketAdmissionBOM."Percentage of Adm. Capacity" / 100, 1);

        exit(true);
        //+TM1.48 [411704]
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

        //-TM1.45 [357359]
        if (CapacityControl = Admission."Capacity Control"::SEATING) then begin
            // MaxCapacity := 150;
            SeatingTemplate.SetFilter("Admission Code", '=%1', Admission."Admission Code");
            SeatingTemplate.SetFilter("Reservation Category", '=%1|=%2', SeatingTemplate."Reservation Category"::AVAILABLE, SeatingTemplate."Reservation Category"::NA);
            SeatingTemplate.SetFilter("Entry Type", '=%1', SeatingTemplate."Entry Type"::LEAF);
            MaxCapacity := SeatingTemplate.Count();
        end;
        //+TM1.45 [357359]

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

        //-TM1.45 [378339]
        with AdmissionScheduleEntry do begin

            if (not Admission.Get("Admission Code")) then
                Admission.Init();

            if (not TicketBOM.Get(TicketItemNo, TicketVariantCode, "Admission Code")) then
                TicketBOM.Init();

            //-TM1.48 [411704]
            // GetAdmissionCapacity ("Admission Code", "Schedule Code", "Entry No.", MaxCapacity, CapacityControl);
            GetTicketCapacity(TicketItemNo, TicketVariantCode, "Admission Code", "Schedule Code", "Entry No.", MaxCapacity, CapacityControl);
            //+TM1.48 [411704]

            RemainingQuantityOut := MaxCapacity - CalculateCurrentCapacity(CapacityControl, AdmissionScheduleEntry."Entry No.");

            with AdmissionScheduleEntry do
                if (CalculateConcurrentCapacity("Admission Code", "Schedule Code", "Admission Start Date", ConcurrentQuantity, ConcurrentMaxQty)) then
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

            if ("Event Arrival From Time" = 0T) then
                "Event Arrival From Time" := "Admission Start Time";

            if ("Event Arrival Until Time" = 0T) then
                "Event Arrival Until Time" := "Admission End Time";

            // if ticket will be admitted automatically, we also need to check valid admission time
            if (ActivateOnSales) then begin
                if ("Admission Start Date" <> ReferenceDate) then
                    exit(false); // When ticket is activated on sales, and its a reservation for another date than the reference date, it cant be sold now, dont validate the time slot

                if (ReferenceTime < "Event Arrival From Time") then
                    exit(false);
            end;

            if (IsReservation) or (Admission."Default Schedule" = Admission."Default Schedule"::SCHEDULE_ENTRY) then begin
                // when we pass arrival until time, we cant sell this time slot.
                if (("Admission Start Date" = ReferenceDate) and (ReferenceTime > "Event Arrival Until Time")) then
                    exit(false);
            end;


            // Verify the general window of sales
            if (TicketBOM."Enforce Schedule Sales Limits") then begin
                if ("Sales From Date" <> 0D) then begin
                    if ("Sales From Date" > ReferenceDate) then
                        exit(false);
                    if ("Sales From Date" = ReferenceDate) then
                        if ("Sales From Time" > ReferenceTime) then
                            exit(false);
                end;

                if ("Sales Until Date" <> 0D) then begin
                    if (ReferenceDate > "Sales Until Date") then
                        exit(false);
                    if (ReferenceDate = "Sales Until Date") then
                        if (ReferenceTime > "Sales Until Time") then
                            exit(false);
                end;
            end;

        end;

        exit(true);
        //+TM1.45 [378339]
    end;

    local procedure CheckTicketAdmissionCapacityExceeded(FailWithError: Boolean; Ticket: Record "NPR TM Ticket"; AdmissionScheduleEntryNo: Integer; var ResponseMessage: Text): Integer
    var
        Admission: Record "NPR TM Admission";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Schedule: Record "NPR TM Admis. Schedule";
        AdmissionSchedule: Record "NPR TM Admis. Schedule Lines";
        WaitingListSetup: Record "NPR TM Waiting List Setup";
        AdmissionGroupConcurrency: Record "NPR TM Concurrent Admis. Setup";
        MaxCapacity: Integer;
        AdmittedCount: Integer;
        CapacityExceeded: Boolean;
        CapacityControl: Option;
        ResultCode: Integer;
    begin

        //-TM1.48 [411704] Renamed, Ticket param added

        //-#385922 [385922] Refactored
        //-NPR4.16 - New Function
        // This function should be called after the entry transaction have been created
        // That will allow us to catch a zero count as an error

        AdmissionScheduleEntry.Get(AdmissionScheduleEntryNo);
        Admission.Get(AdmissionScheduleEntry."Admission Code");
        Schedule.Get(AdmissionScheduleEntry."Schedule Code");
        AdmissionSchedule.Get(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code");

        //-TM1.48 [411704]
        //GetAdmissionCapacity (AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", AdmissionScheduleEntryNo, MaxCapacity, CapacityControl);
        GetTicketCapacity(Ticket."Item No.", Ticket."Variant Code", AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", AdmissionScheduleEntryNo, MaxCapacity, CapacityControl);
        //+TM1.48 [411704]

        //-TM90.1.46 [391018]
        if (CapacityControl = Admission."Capacity Control"::NONE) then
            exit(0);
        //+TM90.1.46 [391018]

        //-#385922 [385922] Refactored - implementation moved to function
        AdmittedCount := CalculateCurrentCapacity(CapacityControl, AdmissionScheduleEntryNo);
        //+#385922 [385922]

        if (AdmittedCount = 0) then
            Error(UNEXPECTED, AdmissionScheduleEntry.TableCaption(), Admission."Admission Code", AdmittedCount, SHOULD_NOT_BE_ZERO, 0, 0);

        CapacityExceeded := (AdmittedCount > MaxCapacity);

        if (CapacityExceeded) then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(CAPACITY_EXCEEDED, Admission."Admission Code"), CAPACITY_EXCEEDED_NO));

        //-#385922 [385922]
        if (CalculateConcurrentCapacity(AdmissionSchedule."Admission Code", AdmissionSchedule."Schedule Code", AdmissionScheduleEntry."Admission Start Date", AdmittedCount, MaxCapacity)) then begin
            AdmissionGroupConcurrency.Get(AdmissionSchedule."Concurrency Code");
            CapacityExceeded := (AdmittedCount > MaxCapacity);
            if (CapacityExceeded) then
                exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(CONCURRENT_CAPACITY_EXCEEDED, AdmissionGroupConcurrency.Code), CONCURRENT_CAPACITY_EXCEEDED_NO));
        end;
        //+#385922 [385922]

        //-#380754 [380754]
        if (Admission."Waiting List Setup Code" <> '') then begin
            if (not WaitingListSetup.Get(Admission."Waiting List Setup Code")) then
                WaitingListSetup.Init;

            if (AdmittedCount >= MaxCapacity - WaitingListSetup."Activate WL at Remaining Qty.") then begin
                AdmissionScheduleEntry."Allocation By" := AdmissionScheduleEntry."Allocation By"::WAITINGLIST;
                AdmissionScheduleEntry.Modify();
            end;
        end;
        //+#380754 [380754]

        exit(0);
    end;

    local procedure CalculateCurrentCapacity(CapacityControl: Option; AdmissionScheduleEntryNo: Integer) AdmittedCount: Integer
    var
        Admission: Record "NPR TM Admission";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        SeatingReservationEntry: Record "NPR TM Seating Reserv. Entry";
    begin

        //-#385922 [385922] (refactored)
        AdmissionScheduleEntry.Get(AdmissionScheduleEntryNo);

        case CapacityControl of
            Admission."Capacity Control"::NONE:
                // EXIT (CapacityExceeded);
                exit(0);

            Admission."Capacity Control"::SALES:
                begin
                    DetailedTicketAccessEntry.SetCurrentKey("External Adm. Sch. Entry No.", Type, Open);
                    DetailedTicketAccessEntry.SetFilter("External Adm. Sch. Entry No.", '=%1', AdmissionScheduleEntry."External Schedule Entry No.");
                    DetailedTicketAccessEntry.SetFilter(Type, '=%1', DetailedTicketAccessEntry.Type::INITIAL_ENTRY);
                    //AdmittedCount := DetailedTicketAccessEntry.COUNT ();
                    if (DetailedTicketAccessEntry.FindSet()) then begin
                        repeat
                            AdmittedCount += DetailedTicketAccessEntry.Quantity;
                        until (DetailedTicketAccessEntry.Next() = 0);
                    end;
                end;

            Admission."Capacity Control"::ADMITTED:
                begin
                    // Performance / Deadlock. SUM (x) flowfield issues SQL with statement for repeatable read "WITH(UPDLOCK)"
                    // TODO
                    AdmissionScheduleEntry.CalcFields("Open Admitted");
                    AdmittedCount := AdmissionScheduleEntry."Open Admitted";
                end;

            Admission."Capacity Control"::FULL:
                begin
                    // Performance / Deadlock. SUM (x) flowfield issues SQL with statement for repeatable read "WITH(UPDLOCK)"
                    // TODO
                    AdmissionScheduleEntry.CalcFields("Open Reservations", "Open Admitted");
                    AdmittedCount := AdmissionScheduleEntry."Open Admitted" + AdmissionScheduleEntry."Open Reservations";
                end;

            //-TM1.45 [357359]
            Admission."Capacity Control"::SEATING:
                begin
                    SeatingReservationEntry.SetCurrentKey("External Schedule Entry No.");
                    SeatingReservationEntry.SetFilter("External Schedule Entry No.", '=%1', AdmissionScheduleEntry."External Schedule Entry No.");
                    AdmittedCount := SeatingReservationEntry.Count();
                end;
            //+TM1.45 [357359]

            else
                Error(UNSUPPORTED_VALIDATION_METHOD);
        end;

        exit(AdmittedCount);
        //+#385922 [385922]
    end;

    procedure CalculateConcurrentCapacity(AdmissionCode: Code[20]; ScheduleCode: Code[20]; ReferenceDate: Date; var ActualCount: Integer; var MaxCount: Integer): Boolean
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        AdmissionSchedule: Record "NPR TM Admis. Schedule Lines";
        AdmissionGroupConcurrency: Record "NPR TM Concurrent Admis. Setup";
    begin

        //+#385922 [385922]
        ActualCount := 0;
        MaxCount := 0;
        if (not AdmissionSchedule.Get(AdmissionCode, ScheduleCode)) then
            exit;

        if (not AdmissionGroupConcurrency.Get(AdmissionSchedule."Concurrency Code")) then
            exit;

        if (AdmissionGroupConcurrency."Concurrency Type" = AdmissionGroupConcurrency."Concurrency Type"::NA) then
            exit;

        MaxCount := AdmissionGroupConcurrency."Total Capacity";
        if (MaxCount = 0) then
            exit;

        AdmissionSchedule.Reset();
        AdmissionSchedule.SetFilter("Concurrency Code", '=%1', AdmissionSchedule."Concurrency Code");

        with AdmissionGroupConcurrency do
            case "Concurrency Type" of
                "Concurrency Type"::CONCURRENCY_CODE:
                    ;
                "Concurrency Type"::ADMISSION:
                    AdmissionSchedule.SetFilter("Admission Code", '=%1', AdmissionCode);
                "Concurrency Type"::SCHEDULE:
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
        //+#385922 [385922]
    end;

    local procedure CheckTicketConstraintsExceeded(FailWithError: Boolean; TicketAccessEntryNo: Integer; var ResponseMessage: Text): Boolean
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
        MaxCapacity: Integer;
        EntryValidation: Option UNDEFINED,SINGLE,SAME_DAY,MULTIPLE;
        MaxNoOfEntries: Integer;
        FirstLastEntryDurationFormula: DateFormula;
        ResponseCode: Integer;
        FirstAccessTime: Time;
        LastAccessTime: Time;
    begin
        //-NPR4.16 - New Function
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

                    //-TM1.36 [316463]
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
                    //+TM1.36 [316463]
                end;

            EntryValidation::SAME_DAY:
                begin
                    // we cant allow access on different dates
                    DetailedTicketAccessEntry.SetFilter(Open, '');
                    FirstAccessDate := DT2Date(DetailedTicketAccessEntry."Created Datetime");
                    DetailedTicketAccessEntry.FindLast();
                    LastAccessDate := DT2Date(DetailedTicketAccessEntry."Created Datetime");
                    CapacityExceeded := (FirstAccessDate <> LastAccessDate);
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
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(CAPACITY_EXCEEDED, Ticket."External Ticket No."), CAPACITY_EXCEEDED_NO) <> 0);

        // Check if date of access violates ticket validity
        if (FirstAccessDate < Ticket."Valid From Date") then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(TICKET_NOT_VALID_YET, Ticket."External Ticket No.", Ticket."Valid From Date"), TICKET_NOT_VALID_YET_NO) <> 0);

        if (LastAccessDate > Ticket."Valid To Date") then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(TICKET_EXPIRED, Ticket."External Ticket No.", Ticket."Valid To Date"), TICKET_EXPIRED_NO) <> 0);

        //-TM1.28 [305707]
        ResponseCode := CheckTicketBaseCalendar(FailWithError, TicketAccessEntry."Admission Code", Ticket."Item No.", Ticket."Variant Code", LastAccessDate, ResponseMessage);
        if (ResponseCode <> 0) then
            exit(true);
        //+TM1.28 [305707]

        exit(false);
    end;

    local procedure CheckReservationCapacityExceeded(FailWithError: Boolean; Ticket: Record "NPR TM Ticket"; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; var ResponseMessage: Text): Integer
    var
        Admission: Record "NPR TM Admission";
        AdmissionText: Record "NPR TM Admission";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        Schedule: Record "NPR TM Admis. Schedule";
        AdmissionSchedule: Record "NPR TM Admis. Schedule Lines";
        AdmittedCount: Integer;
        CapacityExceeded: Boolean;
        MaxCapacity: Integer;
        CapacityControl: Option;
    begin

        Admission.Get(AdmissionScheduleEntry."Admission Code");
        CapacityExceeded := false;
        if (Admission.Type <> Admission.Type::OCCASION) then
            exit(0);

        Schedule.Get(AdmissionScheduleEntry."Schedule Code");
        AdmissionSchedule.Get(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code");

        //-TM1.48 [411704]
        // GetAdmissionCapacity (Admission."Admission Code", Schedule."Schedule Code", AdmissionScheduleEntry."Entry No.", MaxCapacity, CapacityControl);
        GetTicketCapacity(Ticket."Item No.", Ticket."Variant Code", Admission."Admission Code", Schedule."Schedule Code", AdmissionScheduleEntry."Entry No.", MaxCapacity, CapacityControl);
        //+TM1.48 [411704]

        AdmissionText."Capacity Control" := CapacityControl;

        case CapacityControl of
            Admission."Capacity Control"::NONE:
                exit(0);

            Admission."Capacity Control"::SALES:
                begin
                    DetailedTicketAccessEntry.SetCurrentKey("External Adm. Sch. Entry No.", Type, Open);
                    DetailedTicketAccessEntry.SetFilter("External Adm. Sch. Entry No.", '=%1', AdmissionScheduleEntry."External Schedule Entry No.");
                    DetailedTicketAccessEntry.SetFilter(Type, '=%1', DetailedTicketAccessEntry.Type::RESERVATION);
                    ////-+TM1.20 [269171] DetailedTicketAccessEntry.SETFILTER (Type, '=%1', DetailedTicketAccessEntry.Type::INITIAL_ENTRY);
                    if (DetailedTicketAccessEntry.FindSet()) then begin
                        repeat
                            AdmittedCount += DetailedTicketAccessEntry.Quantity;
                        until (DetailedTicketAccessEntry.Next() = 0);
                    end;
                end;

            Admission."Capacity Control"::ADMITTED, // Admitted and Full mode are the same when it comes to reservations
            Admission."Capacity Control"::FULL:
                begin
                    // Performance / Deadlock. SUM (x) flowfield issues SQL with statement for repeatable read "WITH(UPDLOCK)"
                    // TODO
                    AdmissionScheduleEntry.CalcFields("Open Reservations", "Open Admitted");
                    AdmittedCount := AdmissionScheduleEntry."Open Admitted" + AdmissionScheduleEntry."Open Reservations";
                end;

            //-TM1.45 [357359]
            Admission."Capacity Control"::SEATING:
                begin
                    AdmissionScheduleEntry.CalcFields("Open Reservations", "Open Admitted");
                    AdmittedCount := AdmissionScheduleEntry."Open Admitted" + AdmissionScheduleEntry."Open Reservations";
                end;
            //+TM1.45 [357359]

            else
                Error(UNSUPPORTED_VALIDATION_METHOD);
        end;

        if (AdmittedCount = 0) then
            Error(UNEXPECTED, AdmissionScheduleEntry.TableCaption(), Admission."Admission Code", AdmittedCount, SHOULD_NOT_BE_ZERO, 0, 0);

        CapacityExceeded := (AdmittedCount > MaxCapacity);

        if (CapacityExceeded) then
            exit(RaiseError(FailWithError, ResponseMessage,
              StrSubstNo(RESERVATION_EXCEEDED, Admission."Admission Code",
                StrSubstNo('%1 - %2', AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time"),
                MaxCapacity, AdmissionText."Capacity Control", AdmittedCount), RESERVATION_EXCEEDED_NO));

        exit(0);
    end;

    local procedure CheckTicketAdmissionReservationDate(FailWithError: Boolean; TicketAccessEntryNo: Integer; AdmissionScheduleEntryNo: Integer; var ResponseMessage: Text): Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
    begin

        //-TM1.16 [245455]
        TicketAccessEntry.Get(TicketAccessEntryNo);
        ScheduleEntry.Get(AdmissionScheduleEntryNo);
        Ticket.Get(TicketAccessEntry."Ticket No.");

        if ((ScheduleEntry."Admission Start Date" < Ticket."Valid From Date") or
            (ScheduleEntry."Admission Start Date" > Ticket."Valid To Date")) then
            exit(RaiseError(FailWithError, ResponseMessage, StrSubstNo(NOT_VALID, Ticket."No.", ScheduleEntry."Admission Start Date"), NOT_VALID_NO));

        exit(0);
        //+TM1.16 [245455]
    end;

    procedure CheckTicketBaseCalendar(FailWithError: Boolean; AdmissionCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionDate: Date; var ResponseMessage: Text): Integer
    var
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        NonWorking: Boolean;
        CustomizedCalendarChangeTemp: Record "Customized Calendar Change" temporary;
        CalendarManagement: Codeunit "Calendar Management";
        CalendarDesc: Text;
    begin

        //-TM1.28 [305707]
        ResponseMessage := '';
        TicketBOM.Get(ItemNo, VariantCode, AdmissionCode);
        if (TicketBOM."Ticket Base Calendar Code" <> '') then begin
            CustomizedCalendarChangeTemp.Init();
            CustomizedCalendarChangeTemp."Source Type" := CustomizedCalendarChangeTemp."Source Type"::Service;
            CustomizedCalendarChangeTemp."Base Calendar Code" := TicketBOM."Ticket Base Calendar Code";
            CustomizedCalendarChangeTemp."Date" := AdmissionDate;
            CustomizedCalendarChangeTemp.Description := CalendarDesc;
            CustomizedCalendarChangeTemp."Source Code" := AdmissionCode;
            CustomizedCalendarChangeTemp.Insert();

            CalendarManagement.CheckDateStatus(CustomizedCalendarChangeTemp);

            if (not CustomizedCalendarChangeTemp.Nonworking) then begin
                CustomizedCalendarChangeTemp.DeleteAll();
                CustomizedCalendarChangeTemp.Init();
                CustomizedCalendarChangeTemp."Source Type" := CustomizedCalendarChangeTemp."Source Type"::Service;
                CustomizedCalendarChangeTemp."Base Calendar Code" := TicketBOM."Ticket Base Calendar Code";
                CustomizedCalendarChangeTemp."Date" := AdmissionDate;
                CustomizedCalendarChangeTemp.Description := CalendarDesc;
                CustomizedCalendarChangeTemp."Source Code" := AdmissionCode;
                CustomizedCalendarChangeTemp."Additional Source Code" := ItemNo;
                CustomizedCalendarChangeTemp.Insert();

                CalendarManagement.CheckDateStatus(CustomizedCalendarChangeTemp);
            end;

            if (CustomizedCalendarChangeTemp.Nonworking) then begin
                if (CalendarDesc = '') then
                    CalendarDesc := StrSubstNo(TICKET_CALENDAR, ItemNo, VariantCode, AdmissionCode, AdmissionDate);

                exit(RaiseError(FailWithError, ResponseMessage, CalendarDesc, TICKET_CALENDAR_NO));
            end;
        end;

        exit(0);
        //+TM1.28 [305707]
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
            MaxEntryCount := TicketBom."Max No. Of Entries";
            TimespanFormula := TicketBom."Duration Formula";
        end;
    end;

    local procedure "--PostPaidTicketManagement"()
    begin
    end;

    procedure HandlePostpaidTickets(Preview: Boolean)
    var
        TmpTicket: Record "NPR TM Ticket" temporary;
        TmpAggregatedPerRequest: Record "NPR TM Ticket Access Entry" temporary;
        TmpAdmissionPerDate: Record "NPR TM Det. Ticket AccessEntry" temporary;
        TmpDetailedAccessEntries: Record "NPR TM Det. Ticket AccessEntry" temporary;
        TmpInvoiceHeader: Record "Sales Header" temporary;
        FirstInvoiceNo: Code[20];
        LastInvoiceNo: Code[20];
        InvoiceDetailsMessage: Text;
        ShowDialog: Boolean;
    begin

        if (not Confirm(HANDLE_POSTPAID)) then
            Error('');

        ShowDialog := (true and GuiAllowed);

        if (ShowDialog) then
            gWindow.Open(HANDLE_POSTPAID_STATUS);

        CollectUnhandledPostpaidTickets(ShowDialog, TmpTicket, TmpDetailedAccessEntries);
        AggregatePaymentEntries(ShowDialog, TmpTicket, TmpAggregatedPerRequest, TmpAdmissionPerDate);

        if (not Preview) then begin
            CreatePostpaidTicketInvoice(ShowDialog, TmpAggregatedPerRequest, TmpAdmissionPerDate);
            MarkPostpaidTicketAsInvoiced(ShowDialog, TmpDetailedAccessEntries, TmpAggregatedPerRequest, TmpTicket);
            if (not TmpAggregatedPerRequest.IsEmpty) then begin
                TmpAggregatedPerRequest.FindFirst();
                FirstInvoiceNo := CopyStr(TmpAggregatedPerRequest.Description, 1, 20);
                TmpAggregatedPerRequest.FindLast();
                LastInvoiceNo := CopyStr(TmpAggregatedPerRequest.Description, 1, 20);
                InvoiceDetailsMessage := StrSubstNo('{%1..%2}', FirstInvoiceNo, LastInvoiceNo);
            end;
        end;

        if (ShowDialog) then
            gWindow.Close();

        Message(POSTPAID_RESULT, TmpTicket.Count(), TmpAggregatedPerRequest.Count(), InvoiceDetailsMessage);

        // When TmpTicket.COUNT > 0 and TmpAggregatedPerRequest.COUNT == 0, then customer number might be missing on request
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
                DetTicketAccessEntry2.SetFilter(Type, '=%1|=%2', DetTicketAccessEntry2.Type::ADMITTED, DetTicketAccessEntry2.Type::CANCELED);
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

        TmpAggregatedPerRequest.Reset;
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
                        TmpAggregatedPerRequest.Init;
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
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ItemNumber: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
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
                SalesHeader.Init;
                SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
                SalesHeader."No." := '';
                SalesHeader.Insert(true);

                SalesHeader.SetHideValidationDialog(true);
                SalesHeader.Validate("Sell-to Customer No.", TmpAggregatedPerRequest."Customer No.");
                SalesHeader."NPR External Order No." := TicketReservationRequest."External Order No.";
                SalesHeader."External Document No." := TicketReservationRequest."External Order No.";
                SalesHeader.Modify(true);

                TmpAggregatedPerRequest.Description := SalesHeader."No.";
                TmpAggregatedPerRequest.Modify;

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

                        //-#368043 [368043]
                        // //-TM1.41 [352873]
                        // //SalesLine.VALIDATE ("No.", TicketReservationRequest."External Item Code");
                        // IF (TicketRequestManager.TranslateBarcodeToItemVariant (
                        //   TicketReservationRequest."External Item Code", ItemNumber, VariantCode, ResolvingTable)) THEN BEGIN
                        //   SalesLine.VALIDATE ("No.", ItemNumber);
                        //   SalesLine.VALIDATE ("Variant Code", VariantCode);
                        // END ELSE BEGIN
                        //   // Blow-up
                        //   SalesLine.VALIDATE ("No.", TicketReservationRequest."External Item Code");
                        // END;
                        //+TM1.41 [352873]
                        SalesLine.Validate("No.", TicketReservationRequest."Item No.");
                        SalesLine.Validate("Variant Code", TicketReservationRequest."Variant Code");
                        //+#368043 [368043]

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

    local procedure "--Utils"()
    begin
    end;

    local procedure ToMD5(ToMd5: Text) Hash: Text[250]
    var
        FormsAuthentication: DotNet NPRNetFormsAuthentication;
    begin

        Hash := FormsAuthentication.HashPasswordForStoringInConfigFile(ToMd5, 'MD5');
        exit(LowerCase(Hash));
    end;

    local procedure "--Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDetailedTicketEvent(DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry")
    begin
    end;

    local procedure "--Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 344, 'OnAfterNavigateFindRecords', '', true, true)]
    local procedure OnAfterNavigateFindRecordsSubscriber(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    var
        Ticket: Record "NPR TM Ticket";
    begin

        //-#414208 [414208]
        if (Ticket.ReadPermission()) then begin
            if (not Ticket.SetCurrentKey("Sales Receipt No.")) then;
            Ticket.SetFilter("Sales Receipt No.", '%1', DocNoFilter);
            InsertIntoDocEntry(DocumentEntry, DATABASE::"NPR TM Ticket", 0, CopyStr(DocNoFilter, 1, 20), Ticket.TableCaption, Ticket.Count());
        end;
        //+#414208 [414208]
    end;

    [EventSubscriber(ObjectType::Page, 344, 'OnAfterNavigateShowRecords', '', true, true)]
    local procedure OnAfterNavigateShowRecordsSubscriber(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean)
    var
        Ticket: Record "NPR TM Ticket";
    begin

        //-#414208 [414208]
        if (TableID = DATABASE::"NPR TM Ticket") then begin
            if (not Ticket.SetCurrentKey("Sales Receipt No.")) then;
            Ticket.SetFilter("Sales Receipt No.", DocNoFilter);
            if (Ticket.IsEmpty()) then
                exit;

            PAGE.Run(PAGE::"NPR TM Ticket List", Ticket);

        end;
        //+#414208 [414208]
    end;

    local procedure InsertIntoDocEntry(var DocumentEntry: Record "Document Entry" temporary; DocTableID: Integer; DocType: Integer; DocNoFilter: Code[20]; DocTableName: Text[1024]; DocNoOfRecords: Integer): Integer
    begin

        //-#414208 [414208]
        if (DocNoOfRecords = 0) then
            exit(DocNoOfRecords);

        with DocumentEntry do begin
            Init;
            "Entry No." := "Entry No." + 1;
            "Table ID" := DocTableID;
            "Document Type" := DocType;
            "Document No." := DocNoFilter;
            "Table Name" := CopyStr(DocTableName, 1, MaxStrLen("Table Name"));
            "No. of Records" := DocNoOfRecords;
            Insert;
        end;

        exit(DocNoOfRecords);
        //+#414208 [414208]
    end;
}

