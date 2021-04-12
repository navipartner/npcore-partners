codeunit 6060119 "NPR TM Ticket Request Manager"
{

    trigger OnRun()
    begin
    end;

    var
        CHANGE_NOT_ALLOWED: Label 'Confirmed tickets can''t be changed.';
        TOKEN_NOT_FOUND: Label 'The ticket-token %1 was not found, or has incorrect state.';
        TOKEN_EXPIRED: Label 'The ticket-token %1 has expired. Use PreConfirm to re-reserve tickets.';
        EXTERNAL_ITEM_CHANGE: Label 'Changing the sales item when there is an active ticket reservation, is not supported. Please delete the POS line and start over.';
        REVOKE_UNUSED_ERROR: Label 'Ticket %1 has been used for entry to %2 at %3 and can''t be revoked due to the revoke policy set on item %4 for admission %5.';
        TICKET_CANCELLED: Label 'Ticket %1 has already been revoked at %2 and can''t be revoked again.';
        REVOKE_NEVER_ERROR: Label 'The revoke policy for ticket %1 set on item %2 for admission %3, does not allow revoke.';
        NOT_TICKET_ITEM: Label 'The item %1 is not configured to be used as a ticket item. Verify that the item has a valid value in field "%2", current value is %3.';
        WRONG_SCH_ENTRY: Label 'Specified admission schedule entry %1 is not for admission %2';
        INVALID_SCH_ENTRY: Label 'Admission schedule entry %1 is not valid.';
        INVALID_POLICY: Label 'Revoke Policy %1 not implemented.';
        showProgressBar: Boolean;
        PREPAID_REFUND: Label 'The ticket admission %1 is prepaid by a different issuer (ref: %2). Do you allow a monetary refund for this admission?';
        POSTPAID_REFUND: Label 'The ticket admission %1 is postpaid by a different issuer (ref: %2). Do you allow a monetary refund for this admission?';
        NO_TICKET_BOM: Label 'The ticket contents has not been defined yet. There are no admissions in the %1 table for %2.';
        MAX_TO_REVOKE: Label 'Maximum number of tickets to revoke is %1.';
        MISSING_RECIPIENT: Label '%1 is blank.';
        NOT_ETICKET: Label '%1 has no %2 marked for %3 in %4.';
        SALES_NOT_STARTED_1200: Label 'Ticket sales does not start until %1 for %2 using ticket item %3 %4.';
        SALES_STOPPED_1201: Label 'Ticket sales ended at %1 for %2 using ticket item %3 %4.';
        WAITINGLIST_REQUIRED_1202: Label 'Waitinglist reference code is required to book a ticket for this time schedule.';

        INVALID_TICKET_PIN: Label 'The combination of ticket number and pin code is not valid.';
        NOT_CONFIRMED: Label 'The ticket request must be confirmed prior to change.';
        BAD_REFERENCE: Label 'The template field reference %1 on line %2 is invalid.';

    procedure LockResources()
    var
        TMTicket: Record "NPR TM Ticket";
    begin

        TMTicket.LockTable(true);
        if (TMTicket.FindFirst()) then;
        exit;

    end;

    procedure GetNewToken() Token: Code[40]
    begin
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;

    procedure TokenRequestExists(Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        exit(TicketReservationRequest.FindFirst());
    end;

    procedure DeleteReservationRequest(Token: Text[100]; RemoveRequest: Boolean)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        SeatingReservationEntry: Record "NPR TM Seating Reserv. Entry";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '<>%1 & <>%2', TicketReservationRequest."Request Status"::RESERVED, TicketReservationRequest."Request Status"::WAITINGLIST);

        if (TicketReservationRequest.FindSet(true, false)) then begin

            if (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CONFIRMED) then
                Error(CHANGE_NOT_ALLOWED);

            repeat

                if (TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::PRIMARY) then begin
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");

                    if (Ticket.FindSet(true, true)) then begin
                        repeat
                            Ticket.Delete();
                            TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                            if (not TicketAccessEntry.IsEmpty()) then
                                TicketAccessEntry.DeleteAll();
                            DetailedTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                            if (not DetailedTicketAccessEntry.IsEmpty()) then
                                DetailedTicketAccessEntry.DeleteAll();
                        until (Ticket.Next() = 0);
                    end;

                    SeatingReservationEntry.SetCurrentKey("Ticket Token");
                    SeatingReservationEntry.SetFilter("Ticket Token", '=%1', Token);
                    if (not SeatingReservationEntry.IsEmpty()) then
                        SeatingReservationEntry.DeleteAll();
                end;

                if (not RemoveRequest) then begin
                    TicketReservationRequest."Admission Created" := false;
                    TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::EXPIRED;
                    TicketReservationRequest."Expires Date Time" := CalculateNewExpireTime();
                    TicketReservationRequest.Modify();
                end;

                if (RemoveRequest) then begin
                    TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
                    TicketReservationResponse.DeleteAll();
                    TicketReservationRequest.Delete();
                end;

            until (TicketReservationRequest.Next() = 0);

        end;
    end;

    procedure IssueTicketFromReservationToken(Token: Text[100]; FailWithError: Boolean; var ResponseMessage: Text) ResponseCode: Integer
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        AttemptTicket: Codeunit "NPR Ticket Attempt Create";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FindSet();

        if (not FailWithError) then begin
            Commit();
            if (not AttemptTicket.AttemptIssueTicketFromReservationToken(Token, ResponseMessage)) then
                exit(-901);
            exit(0);
        end;

        repeat
            IssueTicketFromReservation(TicketReservationRequest);
        until (TicketReservationRequest.Next() = 0);

        exit(0);
    end;

    procedure IssueTicketFromReservation(TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        Ticket: Record "NPR TM Ticket";
        AdmissionUnitPrice: Decimal;
    begin

        TicketReservationRequest.Get(TicketReservationRequest."Entry No.");
        if (TicketReservationRequest."Admission Created") then
            exit;

        if (TicketReservationRequest."Request Status" <> TicketReservationRequest."Request Status"::CONFIRMED) then
            _IssueNewTickets(TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", TicketReservationRequest.Quantity, TicketReservationRequest."Entry No.", AdmissionUnitPrice);

        if ((TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CONFIRMED) and
            (not TicketReservationRequest."Admission Created")) then begin

            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (Ticket.FindSet()) then begin
                repeat
                    _IssueOneAdmission(TicketReservationRequest, Ticket, TicketReservationRequest."Admission Code", 1, true, AdmissionUnitPrice);

                until (Ticket.Next() = 0);

                if (AdmissionUnitPrice > 0) then begin

                end;
            end;
        end;
    end;

    local procedure _IssueNewTickets(ItemNo: Code[20]; VariantCode: Code[10]; Quantity: Integer; RequestEntryNo: Integer; AdditionCost: Decimal)
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        TicketSetup: Record "NPR TM Ticket Setup";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        NumberOfTickets: Integer;
        TicketQuantity: Integer;
        i: Integer;
        Window: Dialog;
        AdditionalAdmissionCosts: Decimal;
    begin


        Item.Get(ItemNo);
        if (not TicketType.Get(Item."NPR Ticket Type")) then
            Error(StrSubstNo(NOT_TICKET_ITEM, ItemNo, Item.FieldCaption("NPR Ticket Type"), Item."NPR Ticket Type"));

        if ((not TicketType."Is Ticket") or (TicketType.Code = '')) then
            Error(StrSubstNo(NOT_TICKET_ITEM, ItemNo, Item.FieldCaption("NPR Ticket Type"), Item."NPR Ticket Type"));

        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.SetFilter("Variant Code", '=%1', VariantCode);
        if (TicketBom.IsEmpty()) then
            Error(StrSubstNo(NO_TICKET_BOM, TicketBom.TableCaption, TicketBom.GetFilters));

        TicketBom.Reset();

        TicketQuantity := Quantity;
        NumberOfTickets := Quantity;

        if (TicketType."Admission Registration" = TicketType."Admission Registration"::GROUP) then
            NumberOfTickets := 1;

        if (TicketType."Admission Registration" = TicketType."Admission Registration"::INDIVIDUAL) then
            TicketQuantity := 1;

        if (Quantity < 0) then
            TicketQuantity := Abs(TicketQuantity) * -1;

        ReservationRequest.Get(RequestEntryNo);
        if (ReservationRequest."Revoke Ticket Request") then
            exit;

        if (GetShowProgressBar()) then
            Window.Open('Creating tickets... @1@@@@@@@@@@@@@');

        ReservationRequest."Primary Request Line" := true;
        ReservationRequest."Admission Created" := true;
        ReservationRequest."Request Status" := ReservationRequest."Request Status"::REGISTERED;
        ReservationRequest."Expires Date Time" := CalculateNewExpireTime();

        if (NOT TicketSetup.GET()) then
            TicketSetup.INIT();

        if (TicketSetup."Authorization Code Scheme" = '') then
            TicketSetup."Authorization Code Scheme" := '[N*4]-[N*4]';

        ReservationRequest."Authorization Code" := TicketManagement.GenerateCertificateNumber(TicketSetup."Authorization Code Scheme", '-');
        ReservationRequest.Modify();

        for i := 1 to Abs(NumberOfTickets) do begin
            AdditionalAdmissionCosts := 0;

            _IssueOneTicket(ItemNo, VariantCode, TicketQuantity, TicketType, ReservationRequest, AdditionalAdmissionCosts);

            if (GetShowProgressBar()) then
                if (i mod 10 = 0) then
                    Window.Update(1, Round(i / NumberOfTickets * 10000, 1));

            AdditionCost += AdditionalAdmissionCosts;

        end;

        if (GetShowProgressBar()) then
            Window.Close();

    end;

    local procedure _IssueOneTicket(ItemNo: Code[20]; VariantCode: Code[10]; QuantityPerTicket: Integer; TicketType: Record "NPR TM Ticket Type"; ReservationRequest: Record "NPR TM Ticket Reservation Req."; var AdditionalAdmissionCosts: Decimal)
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        LowDate: Date;
        HighDate: Date;
        UserSetup: Record "User Setup";
    begin

        Ticket.Init();
        Ticket."No." := '';
        Ticket."No. Series" := TicketType."No. Series";
        Ticket."Ticket Type Code" := TicketType.Code;
        Ticket."Item No." := ItemNo;
        Ticket."Variant Code" := VariantCode;
        Ticket."Customer No." := ReservationRequest."Customer No.";
        Ticket."Ticket Reservation Entry No." := ReservationRequest."Entry No.";
        Ticket."External Member Card No." := ReservationRequest."External Member No.";
        Ticket."Sales Receipt No." := ReservationRequest."Receipt No.";
        Ticket."Line No." := ReservationRequest."Line No.";

        if (UserSetup.Get(CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID")))) then
            Ticket."Salesperson Code" := UserSetup."Salespers./Purch. Code";

        if (Ticket."Salesperson Code" = '') then
            Ticket."Salesperson Code" := CopyStr(UserId, 1, MaxStrLen(Ticket."Salesperson Code"));

        TicketManagement.SetTicketProperties(Ticket, Today);
        Ticket.Insert(true);

        _IssueAdmissionsAppendToTicket(Ticket, QuantityPerTicket, ReservationRequest, AdditionalAdmissionCosts);

        // Update ticket valid from / to dates based on contents
        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then begin
            TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
            if (TicketAccessEntry.FindSet()) then begin
                repeat
                    TicketManagement.GetTicketAccessEntryValidDateBoundary(Ticket, LowDate, HighDate);
                    Ticket."Valid From Date" := LowDate;
                    Ticket."Valid To Date" := HighDate;
                    Ticket.Modify();
                until (TicketAccessEntry.Next() = 0);
            end;
        end;
    end;

    local procedure _IssueAdmissionsAppendToTicket(Ticket: Record "NPR TM Ticket"; QuantityPerTicket: Integer; ReservationRequest: Record "NPR TM Ticket Reservation Req."; var AdditionalAdmissionCosts: Decimal)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        AdmissionUnitPrice: Decimal;
    begin

        // Create Ticket Content
        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        if (TicketBom.FindSet()) then begin

            ValidateTicketBomSalesDateLimit(TicketBom, QuantityPerTicket, Today);

            repeat
                AdmissionUnitPrice := 0;

                _IssueOneAdmission(ReservationRequest, Ticket, TicketBom."Admission Code", QuantityPerTicket, true, AdmissionUnitPrice);
                AdditionalAdmissionCosts += AdmissionUnitPrice;

            until (TicketBom.Next() = 0);
        end;

    end;

    local procedure _IssueOneAdmission(SourceRequest: Record "NPR TM Ticket Reservation Req."; Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; QuantityPerTicket: Integer; ValidateWaitinglistReference: Boolean; var AdmissionUnitPrice: Decimal)
    var
        AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        WaitingListReferenceCode: Code[10];
        CreateAdmission: Boolean;
    begin

        Clear(AdmissionSchEntry);

        Admission.Get(AdmissionCode);
        TicketBom.Get(Ticket."Item No.", Ticket."Variant Code", AdmissionCode);
        CreateAdmission := (TicketBom."Admission Inclusion" <> TicketBom."Admission Inclusion"::NOT_SELECTED);

        // Lets see if there is a specific request for the admission code, then it might carry some additional scheduling information
        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetFilter("Session Token ID", '=%1', SourceRequest."Session Token ID");
        ReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', SourceRequest."Ext. Line Reference No.");
        ReservationRequest.SetFilter("Item No.", '=%1', Ticket."Item No.");
        ReservationRequest.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        ReservationRequest.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (ReservationRequest.FindFirst()) then begin

            WaitingListReferenceCode := ReservationRequest."Waiting List Reference Code";

            // Does the request carry schedule info for this admission?
            if (ReservationRequest."External Adm. Sch. Entry No." <> 0) then begin
                AdmissionSchEntry.SetFilter("External Schedule Entry No.", '=%1', ReservationRequest."External Adm. Sch. Entry No.");
                AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionSchEntry.FindFirst()) then begin

                    if (AdmissionSchEntry."Admission Code" <> AdmissionCode) then
                        Error(WRONG_SCH_ENTRY, ReservationRequest."External Adm. Sch. Entry No.", AdmissionCode);

                end;
            end;

            ReservationRequest."Admission Created" := (ReservationRequest."Admission Inclusion" <> ReservationRequest."Admission Inclusion"::NOT_SELECTED);
            CreateAdmission := ReservationRequest."Admission Created";
            ReservationRequest."Request Status" := ReservationRequest."Request Status"::REGISTERED;
            ReservationRequest."Expires Date Time" := CalculateNewExpireTime();
            ReservationRequest.Modify();

        end else begin

            WaitingListReferenceCode := SourceRequest."Waiting List Reference Code";

            // Does the source requests schedule info apply to this admission?
            if (SourceRequest."External Adm. Sch. Entry No." <> 0) then begin
                AdmissionSchEntry.SetFilter("External Schedule Entry No.", '=%1', SourceRequest."External Adm. Sch. Entry No.");
                AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);
                if (not AdmissionSchEntry.FindFirst()) then
                    Error(INVALID_SCH_ENTRY, SourceRequest."External Adm. Sch. Entry No.");

                if (AdmissionSchEntry."Admission Code" <> AdmissionCode) then
                    Clear(AdmissionSchEntry); // Schedule Entry is not for this admission

            end;
        end;

        if (not CreateAdmission) then
            exit;

        if (ValidateWaitinglistReference) then
            ValidateWaitingListReferenceCode(WaitingListReferenceCode, Admission."Admission Code", AdmissionSchEntry);

        TicketManagement.CreateAdmissionAccessEntry(Ticket, QuantityPerTicket * TicketBom.Quantity, AdmissionCode, AdmissionSchEntry);

        AdmissionUnitPrice := TicketBom."Admission Unit Price";
        if ((TicketBom."Admission Inclusion" <> SourceRequest."Admission Inclusion") and (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::NOT_SELECTED)) then
            AdmissionUnitPrice *= -1;

    end;

    local procedure ValidateWaitingListReferenceCode(WaitingListReferenceCode: Code[10]; AdmissionCode: Code[20]; var AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry")
    var
        AdmissionSchEntryWaitingList: Record "NPR TM Admis. Schedule Entry";
        TicketWaitingList: Record "NPR TM Ticket Wait. List";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketWaitingListMgr: Codeunit "NPR TM Ticket WaitingList Mgr.";
        ResponseMessage: Text;
    begin

        if (AdmissionSchEntry."Entry No." <= 0) then
            if (not AdmissionSchEntry.Get(TicketManagement.GetCurrentScheduleEntry(AdmissionCode, false))) then
                exit; // No default schedule - let someone else worry about that

        if (AdmissionSchEntry."Allocation By" = AdmissionSchEntry."Allocation By"::CAPACITY) then
            exit; // Normal

        if (WaitingListReferenceCode = '') then
            Error(StrSubstNo('[%1] - %2', -1202, WAITINGLIST_REQUIRED_1202));

        if (not TicketWaitingListMgr.GetWaitingListAdmSchEntry(WaitingListReferenceCode, CreateDateTime(Today, Time), true, AdmissionSchEntryWaitingList, TicketWaitingList, ResponseMessage)) then
            Error(ResponseMessage);

    end;

    local procedure ValidateTicketBomSalesDateLimit(TicketBom: Record "NPR TM Ticket Admission BOM"; Quantity: Integer; ReferenceDate: Date)
    begin

        if ((TicketBom.Default) and (Quantity > 0)) then begin

            if ((TicketBom."Sales From Date" <> 0D) and (ReferenceDate < TicketBom."Sales From Date")) then
                Error(StrSubstNo(SALES_NOT_STARTED_1200, TicketBom."Sales From Date", TicketBom."Admission Code", TicketBom."Item No.", TicketBom."Variant Code"));

            if ((TicketBom."Sales Until Date" <> 0D) and (ReferenceDate > TicketBom."Sales Until Date")) then
                Error(StrSubstNo(SALES_STOPPED_1201, TicketBom."Sales Until Date", TicketBom."Admission Code", TicketBom."Item No.", TicketBom."Variant Code"));

        end;

    end;

    procedure FinalizePayment(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);
        TicketReservationRequest.FindSet();
        repeat
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (Ticket.FindSet()) then begin
                repeat

                    if (TicketReservationRequest."Payment Option" <> TicketReservationRequest."Payment Option"::UNPAID) then
                        TicketManagement.CreatePaymentEntryType(Ticket, TicketReservationRequest."Payment Option", TicketReservationRequest."External Order No.", TicketReservationRequest."Customer No.");

                until (Ticket.Next() = 0);
            end;
        until (TicketReservationRequest.Next() = 0);
    end;

    procedure ConfirmReservationRequest(Token: Text[100]; var ResponseMessage: Text) ReservationConfirmed: Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
    begin

        ReservationConfirmed := true;
        ResponseMessage := '';

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::EXPIRED);
        if (not TicketReservationRequest.IsEmpty()) then begin
            ResponseMessage := StrSubstNo(TOKEN_EXPIRED, Token);
            ReservationConfirmed := false;
        end;

        TicketReservationRequest.SetFilter("Request Status", '=%1|=%2', TicketReservationRequest."Request Status"::REGISTERED, TicketReservationRequest."Request Status"::RESERVED);
        if (not TicketReservationRequest.FindSet()) then begin
            ResponseMessage := StrSubstNo(TOKEN_NOT_FOUND, Token);
            ReservationConfirmed := false;
        end;

        // Update the response object
        TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationResponse.ModifyAll(Status, ReservationConfirmed);
        TicketReservationResponse.ModifyAll(Confirmed, ReservationConfirmed);
        TicketReservationResponse.ModifyAll("Response Message", ResponseMessage);
        if (not ReservationConfirmed) then
            exit(false);

        // **************************
        // Success path
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::RESERVED);
        if (not TicketReservationRequest.IsEmpty()) then
            TicketReservationRequest.ModifyAll("Payment Option", TicketReservationRequest."Payment Option"::DIRECT);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1|=%2', TicketReservationRequest."Request Status"::REGISTERED, TicketReservationRequest."Request Status"::RESERVED);

        TicketReservationRequest.ModifyAll("Request Status", TicketReservationRequest."Request Status"::CONFIRMED);
        TicketReservationRequest.ModifyAll("Request Status Date Time", CurrentDateTime);
        TicketReservationRequest.ModifyAll("Expires Date Time", CreateDateTime(0D, 0T));

        FinalizePayment(Token);

        exit(true);
    end;

    procedure ConfirmReservationRequestWithValidate(Token: Text[100])
    var
        ResponseMessage: Text;
    begin
        if (not ConfirmReservationRequest(Token, ResponseMessage)) then
            Error(ResponseMessage);
    end;

    procedure ConfirmChangeRequest(Token: Text[100]);
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        TicketReservationRequest.RESET();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FindSet();
        repeat
            TicketReservationRequest."Request Status Date Time" := CurrentDateTime();
            TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::CONFIRMED;
            TicketReservationRequest."Admission Created" := (TicketReservationRequest."Admission Inclusion" <> TicketReservationRequest."Admission Inclusion"::NOT_SELECTED);
            TicketReservationRequest."Scheduled Time Description" := '';
            if (TicketReservationRequest."External Adm. Sch. Entry No." <> 0) then begin
                AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest."External Adm. Sch. Entry No.");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', FALSE);
                if (AdmissionScheduleEntry.FindLast()) then
                    TicketReservationRequest."Scheduled Time Description" := StrSubstNo('%1 - %2', AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
            end;
            TicketReservationRequest.Modify();

        until (TicketReservationRequest.NEXT() = 0);

        OnAfterConfirmTicketChangeRequestPublisher(Token);

    end;

    procedure DeleteReservationTokenRequest(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        // Cancel a ticket request by deleting it - possible when it has not yet been confirmed.
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FindSet();

        DeleteReservationRequest(TicketReservationRequest."Session Token ID", true);
    end;

    procedure RevokeReservationTokenRequest(Token: Text[100]; DeferUntilPosting: Boolean)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin

        // revoke a ticket request when a ticket has been issued. This will block the created tickets
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::CANCELED;
                TicketReservationRequest.Modify();

                if (not DeferUntilPosting) then
                    TicketManagement.RevokeTicketAccessEntry(TicketReservationRequest."Revoke Access Entry No.");

            until (TicketReservationRequest.Next() = 0);

        end;

    end;

    procedure ExpireReservationRequests()
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
    begin

        // Perforance enhancement
        TicketReservationRequest.SetCurrentKey("Request Status");
        TicketReservationRequest.SetFilter("Expires Date Time", '>%1 & <%2', CreateDateTime(0D, 0T), CurrentDateTime);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::REGISTERED);
        if (not TicketReservationRequest.IsEmpty()) then begin
            if (TicketReservationRequest.FindSet()) then begin
                repeat
                    DeleteReservationRequest(TicketReservationRequest."Session Token ID", false);

                    TicketReservationRequest2.SetCurrentKey("Session Token ID");
                    TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
                    TicketReservationRequest2.ModifyAll("Request Status", TicketReservationRequest2."Request Status"::EXPIRED);

                    if (TicketReservationRequest."Revoke Ticket Request") then begin
                        TicketReservationRequest2.ModifyAll("Expires Date Time", CurrentDateTime - 10 * 1000); // Revoke transactions will not be retained when it has expired
                    end else begin
                        TicketReservationRequest2.ModifyAll("Expires Date Time", CurrentDateTime + 3600 * 1000); // Expired transactions will be retained 1 hour
                    end;

                until (TicketReservationRequest.Next() = 0);

                Commit();
                LockResources();
            end;
        end;

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Request Status");
        TicketReservationRequest.SetFilter("Expires Date Time", '>%1 & <%2', CreateDateTime(0D, 0T), CurrentDateTime);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::EXPIRED);
        if (TicketReservationRequest.FindFirst()) then begin
            if (TicketReservationRequest.FindSet()) then begin
                repeat
                    DeleteReservationRequest(TicketReservationRequest."Session Token ID", true);
                until (TicketReservationRequest.Next() = 0);

                Commit();
                LockResources();
            end;
        end;
    end;

    procedure RegisterArrivalRequest(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);

        if (not (TicketReservationRequest.FindSet())) then
            Error(TOKEN_NOT_FOUND, Token);

        repeat
            // Find the linked tickets, ticket can only have reference to one request line (eg the first).
            TicketReservationRequest.TestField("Admission Code");
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (Ticket.FindSet()) then begin
                repeat

                    // For multiple request lines, loop the admission codes
                    TicketReservationRequest2.SetCurrentKey("Session Token ID");
                    TicketReservationRequest2.SetFilter("Session Token ID", '=%1', Token);
                    TicketReservationRequest2.SetFilter("Item No.", '=%1', TicketReservationRequest."Item No.");
                    TicketReservationRequest2.SetFilter("Variant Code", '=%1', TicketReservationRequest."Variant Code");
                    TicketReservationRequest2.FindSet();
                    repeat
                        TicketManagement.ValidateTicketForArrival(0, Ticket."No.", TicketReservationRequest2."Admission Code", TicketReservationRequest2."External Adm. Sch. Entry No.");
                    until (TicketReservationRequest2.Next() = 0);

                until (Ticket.Next() = 0);
            end;

        until (TicketReservationRequest.Next() = 0);

    end;

    procedure UpdateReservationQuantity(Token: Text[100]; Quantity: Integer)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);
        if (TicketReservationRequest.FindFirst()) then
            Error(CHANGE_NOT_ALLOWED);

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.ModifyAll(Quantity, Quantity);
    end;

    procedure TranslateBarcodeToItemVariant(Barcode: Text[50]; var ItemNo: Code[20]; var VariantCode: Code[10]; var ResolvingTable: Integer) Found: Boolean
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
    begin

        ResolvingTable := 0;
        ItemNo := '';
        VariantCode := '';
        if (Barcode = '') then exit(false);

        if (StrLen(Barcode) <= MaxStrLen(Item."No.")) then begin
            if (Item.Get(UpperCase(Barcode))) then begin
                ResolvingTable := DATABASE::Item;
                ItemNo := Item."No.";
                exit(true);
            end;
        end;

        if (StrLen(Barcode) <= MaxStrLen(ItemReference."Reference No.")) then begin
            ItemReference.SetCurrentKey("Reference Type", "Reference No.");
            ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetFilter("Reference No.", '=%1', UpperCase(Barcode));
            ItemReference.SetFilter("Discontinue Bar Code", '=%1', false);
            if ItemReference.FindFirst() then begin
                ResolvingTable := DATABASE::"Item Reference";
                ItemNo := ItemReference."Item No.";
                VariantCode := ItemReference."Variant Code";
                exit(true);
            end;
        end;

        exit(false);
    end;

    procedure CreateReservationRequest(ItemNo: Code[20]; VariantCode: Code[10]; Quantity: Integer; ExternalMemberNo: Code[20]) Token: Text[100]
    begin

        exit(POS_CreateReservationRequest('', 0, ItemNo, VariantCode, Quantity, ExternalMemberNo));
    end;

    procedure CreateChangeRequest(ExternalTicketNo: Code[30]; AuthorizationCode: Code[10]; var MessageToken: Text[100]; var ResponseMessage: Text): Boolean;
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketChangeRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin

        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNo);
        Ticket.SetFilter(Blocked, '=%1', FALSE);
        if (NOT Ticket.FindFirst()) then begin
            ResponseMessage := INVALID_TICKET_PIN;
            exit(FALSE);
        end;

        if (NOT TicketReservationRequest.GET(Ticket."Ticket Reservation Entry No.")) then begin
            ResponseMessage := INVALID_TICKET_PIN;
            exit(FALSE);
        end;

        if (TicketReservationRequest."Authorization Code" <> AuthorizationCode) then begin
            ResponseMessage := INVALID_TICKET_PIN;
            exit(FALSE);
        end;

        TicketReservationRequest.CALCFIELDS("Is Superseeded");
        repeat
            if (TicketReservationRequest."Is Superseeded") then begin
                TicketReservationRequest.RESET();
                TicketReservationRequest.SetFilter("Superseeds Entry No.", '=%1', TicketReservationRequest."Entry No.");
                TicketReservationRequest.FindFirst();
                TicketReservationRequest.CALCFIELDS("Is Superseeded");
            end;
        until (NOT TicketReservationRequest."Is Superseeded");

        TicketReservationRequest.RESET();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        if (NOT TicketReservationRequest.FindSet()) then begin
            ResponseMessage := 'Houston, - we have a problem with ticket request table integrity.';
            exit(FALSE);
        end;

        if ((TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::PRIMARY) AND
            (TicketReservationRequest."Request Status" <> TicketReservationRequest."Request Status"::CONFIRMED)) then begin
            ResponseMessage := NOT_CONFIRMED;
            exit(FALSE);
        end;

        if ((TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::CHANGE) AND
            (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::REGISTERED)) then begin
            if ((MessageToken <> TicketReservationRequest."Session Token ID") AND (MessageToken <> '')) then begin
                TicketReservationRequest.ModifyALL("Expires Date Time", CalculateNewExpireTime());
                TicketReservationRequest.ModifyALL("Session Token ID", MessageToken, FALSE); // Multiple change requests - invalidate the previous one
            end;
            if (MessageToken = '') then begin
                TicketReservationRequest.ModifyALL("Expires Date Time", CalculateNewExpireTime());
                MessageToken := TicketReservationRequest."Session Token ID";
            end;
            exit(TRUE);
        end;

        if (MessageToken = '') then
            MessageToken := GetNewToken();

        repeat
            TicketChangeRequest.TransferFields(TicketReservationRequest, FALSE);
            TicketChangeRequest."Session Token ID" := MessageToken;
            TicketChangeRequest."Entry Type" := TicketChangeRequest."Entry Type"::CHANGE;
            TicketChangeRequest."Created Date Time" := CURRENTDATETIME();
            TicketChangeRequest."Request Status" := TicketChangeRequest."Request Status"::REGISTERED;
            TicketChangeRequest."Request Status Date Time" := CURRENTDATETIME();
            TicketChangeRequest."Expires Date Time" := CalculateNewExpireTime();
            TicketChangeRequest."Admission Created" := FALSE;
            TicketChangeRequest."Superseeds Entry No." := TicketReservationRequest."Entry No.";
            TicketChangeRequest."Receipt No." := '';
            TicketChangeRequest."Line No." := 0;

            TicketAccessEntry.SetFilter(TicketAccessEntry."Ticket No.", '=%1', Ticket."No.");
            if (TicketReservationRequest."Admission Code" <> '') then
                TicketAccessEntry.SetFilter("Admission Code", '=%1', TicketChangeRequest."Admission Code");

            TicketAccessEntry.FindSet();
            repeat
                TicketChangeRequest."Entry No." := 0;
                TicketChangeRequest."Admission Code" := TicketAccessEntry."Admission Code";
                Admission.GET(TicketChangeRequest."Admission Code");
                TicketBom.GET(TicketChangeRequest."Item No.", TicketChangeRequest."Variant Code", TicketChangeRequest."Admission Code");
                TicketChangeRequest."Primary Request Line" := TicketBom.Default;
                TicketChangeRequest."Admission Description" := Admission.Description;

                DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
                DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
                DetTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
                if (DetTicketAccessEntry.FindLast()) then
                    TicketChangeRequest."External Adm. Sch. Entry No." := DetTicketAccessEntry."External Adm. Sch. Entry No.";

                DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
                if (DetTicketAccessEntry.FindLast()) then
                    TicketChangeRequest."External Adm. Sch. Entry No." := DetTicketAccessEntry."External Adm. Sch. Entry No.";

                AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketChangeRequest."External Adm. Sch. Entry No.");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', FALSE);
                AdmissionScheduleEntry.FindLast();
                TicketChangeRequest."Scheduled Time Description" := StrSubstNo('%1-%2', AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");

                TicketChangeRequest.Insert();
            until (TicketAccessEntry.NEXT() = 0);

            if (TicketReservationRequest."Admission Code" = '') then
                exit(TRUE); // either the request is complete with all admission codes, or it is created in lazy mode with just the item

        until (TicketReservationRequest.NEXT() = 0);

        exit(TRUE);

    end;

    procedure SetReservationRequestExtraInfo(Token: Text[100]; NotificationAddress: Text[80]; ExternalOrderNo: Code[20]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (not TicketReservationRequest.FindSet()) then
            exit(false);

        repeat
            TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::NA;

            if (NotificationAddress <> '') then begin
                if (StrPos(NotificationAddress, '@') > 1) then
                    TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::EMAIL;

                if (DelChr(NotificationAddress, '=', '0123456789+- ') = '') then
                    TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::SMS;

                TicketReservationRequest."Notification Address" := NotificationAddress;
            end;

            TicketReservationRequest."External Order No." := ExternalOrderNo;

            if (ExternalOrderNo <> '') then
                TicketReservationRequest."Payment Option" := TicketReservationRequest."Payment Option"::PREPAID;

            if ((TicketReservationRequest."Receipt No." = '') and (TicketReservationRequest."External Order No." = '')) then
                TicketReservationRequest."Payment Option" := TicketReservationRequest."Payment Option"::UNPAID;

            TicketReservationRequest.Modify();
        until (TicketReservationRequest.Next() = 0);

        exit(true);
    end;

    procedure POS_CreateReservationRequest(SalesReceiptNo: Code[20]; SalesLineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; Quantity: Integer; ExternalMemberNo: Code[20]) Token: Text[100]
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin

        Token := GetNewToken();

        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.SetFilter("Variant Code", '=%1', VariantCode);
        TicketBom.FindSet();

        repeat
            POS_AppendToReservationRequest(Token, SalesReceiptNo, SalesLineNo, ItemNo, VariantCode, TicketBom."Admission Code", Quantity, 0, ExternalMemberNo);
        until (TicketBom.Next() = 0);


        exit(Token);
    end;

    procedure POS_AppendToReservationRequest(Token: Text[100]; SalesReceiptNo: Code[20]; SalesLineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; Quantity: Integer; ExternalAdmissionScheduleEntryNo: Integer; ExternalMemberNo: Code[20])
    begin
        POS_AppendToReservationRequest2(Token, SalesReceiptNo, SalesLineNo, ItemNo, VariantCode, AdmissionCode, Quantity, ExternalAdmissionScheduleEntryNo, ExternalMemberNo, '', '', '');
    end;

    procedure POS_AppendToReservationRequest2(Token: Text[100]; SalesReceiptNo: Code[20]; SalesLineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; Quantity: Integer; ExternalAdmissionScheduleEntryNo: Integer; ExternalMemberNo: Code[20]; ExternalOrderNo: Code[20]; CustomerNo: Code[20]; NotificationAddress: Text[100])
    var
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Admission: Record "NPR TM Admission";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        AdmSchEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        Admission.Get(AdmissionCode);

        Clear(ReservationRequest);
        ReservationRequest."Entry No." := 0;
        ReservationRequest."Session Token ID" := Token;
        ReservationRequest."Ext. Line Reference No." := 1;
        ReservationRequest."Admission Code" := AdmissionCode;
        ReservationRequest."Receipt No." := SalesReceiptNo;
        ReservationRequest."Line No." := SalesLineNo;

        TicketAdmissionBOM.Get(ItemNo, VariantCode, AdmissionCode);
        ReservationRequest."Admission Inclusion" := TicketAdmissionBOM."Admission Inclusion";
        ReservationRequest."External Item Code" := GetExternalNo(ItemNo, VariantCode);

        ReservationRequest."Item No." := ItemNo;
        ReservationRequest."Variant Code" := VariantCode;

        ReservationRequest.Quantity := Quantity;
        ReservationRequest."External Member No." := ExternalMemberNo;
        ReservationRequest."Admission Description" := Admission.Description;

        ReservationRequest."External Order No." := ExternalOrderNo;
        ReservationRequest."Customer No." := CustomerNo;

        ReservationRequest."Notification Method" := ReservationRequest."Notification Method"::NA;
        if (NotificationAddress <> '') then begin
            ReservationRequest."Notification Address" := NotificationAddress;
            ReservationRequest."Notification Method" := ReservationRequest."Notification Method"::SMS;
            if (StrPos(ReservationRequest."Notification Address", '@') > 1) then
                ReservationRequest."Notification Method" := ReservationRequest."Notification Method"::EMAIL;
        end;


        if (ExternalAdmissionScheduleEntryNo = 0) then begin
            case Admission."Default Schedule" of
                Admission."Default Schedule"::TODAY,
                Admission."Default Schedule"::NEXT_AVAILABLE:
                    begin
                        if (AdmSchEntry.Get(TicketManagement.GetCurrentScheduleEntry(Admission."Admission Code", true))) then begin
                            if (AdmSchEntry."Admission Is" = AdmSchEntry."Admission Is"::OPEN) then begin
                                ReservationRequest."External Adm. Sch. Entry No." := AdmSchEntry."External Schedule Entry No.";
                                ReservationRequest."Scheduled Time Description" := StrSubstNo('%1 - %2', AdmSchEntry."Admission Start Date", AdmSchEntry."Admission Start Time");
                            end;
                        end;
                    end;
            end;

        end else begin
            ReservationRequest."External Adm. Sch. Entry No." := ExternalAdmissionScheduleEntryNo;
        end;

        ReservationRequest."Created Date Time" := CurrentDateTime();
        ReservationRequest."Request Status" := ReservationRequest."Request Status"::WIP;
        ReservationRequest."Request Status Date Time" := CurrentDateTime();
        ReservationRequest."Expires Date Time" := CalculateNewExpireTime();
        ReservationRequest.Insert();

    end;

    procedure POS_CreateRevokeRequest(var Token: Text[100]; TicketNo: Code[20]; SalesReceiptNo: Code[20]; SalesLineNo: Integer; var AmountInOut: Decimal; var RevokeQuantity: Integer): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Admission: Record "NPR TM Admission";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        DetTicketAccessEntry2: Record "NPR TM Det. Ticket AccessEntry";
        InitialQuantity: Integer;
        TotalRefundAmount: Decimal;
        AdmissionRefundAmount: Decimal;
        TotalPct: Decimal;
        UsePctDistribution: Boolean;
        AdmissionCount: Integer;
        UnitPrice: Decimal;
    begin

        Ticket.Get(TicketNo);

        if (Ticket.Blocked) then
            exit(false);

        TicketBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code"); // -+ #333705 [333705]
        TicketBOM.FindSet();
        repeat
            TotalPct += TicketBOM."Refund Price %";
            AdmissionCount += 1;
        until (TicketBOM.Next() = 0);
        UsePctDistribution := (TotalPct = 100);

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.FindSet();

        if (Token = '') then
            Token := GetNewToken();

        repeat

            DetTicketAccessEntry2.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry2.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
            DetTicketAccessEntry2.FindFirst();
            InitialQuantity := DetTicketAccessEntry2.Quantity;

            Admission.Get(TicketAccessEntry."Admission Code");
            AdmissionRefundAmount := 0;


            TicketBOM.Get(Ticket."Item No.", Ticket."Variant Code", Admission."Admission Code");
            RevokeQuantity := TicketAccessEntry.Quantity;

            UnitPrice := AmountInOut / InitialQuantity;

            case TicketBOM."Revoke Policy" of
                TicketBOM."Revoke Policy"::UNUSED:
                    begin

                        DetTicketAccessEntry.Reset();
                        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
                        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
                        if (DetTicketAccessEntry.FindFirst()) then begin

                            DetTicketAccessEntry2.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
                            DetTicketAccessEntry2.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
                            DetTicketAccessEntry2.FindFirst();
                            if (TicketAccessEntry.Quantity >= DetTicketAccessEntry2.Quantity) then
                                Error(REVOKE_UNUSED_ERROR, TicketNo, Admission.Description, DetTicketAccessEntry."Created Datetime", Ticket."Item No.", TicketAccessEntry."Admission Code");

                            RevokeQuantity := DetTicketAccessEntry2.Quantity - TicketAccessEntry.Quantity;
                            AmountInOut := UnitPrice * RevokeQuantity;

                            if (UsePctDistribution) then
                                AdmissionRefundAmount := RevokeQuantity * UnitPrice * TicketBOM."Refund Price %" / 100;

                            if (not UsePctDistribution) then
                                AdmissionRefundAmount := RevokeQuantity * UnitPrice / AdmissionCount;

                        end else begin
                            if (UsePctDistribution) then
                                AdmissionRefundAmount := TicketAccessEntry.Quantity * UnitPrice * TicketBOM."Refund Price %" / 100;

                            if (not UsePctDistribution) then
                                AdmissionRefundAmount := TicketAccessEntry.Quantity * UnitPrice / AdmissionCount;
                        end;

                    end;
                TicketBOM."Revoke Policy"::NEVER:
                    Error(REVOKE_NEVER_ERROR, TicketNo, Ticket."Item No.", TicketAccessEntry."Admission Code");

                TicketBOM."Revoke Policy"::ALWAYS:
                    AdmissionRefundAmount := AmountInOut / AdmissionCount;

                else
                    Error(INVALID_POLICY, TicketBOM."Revoke Policy");
            end;

            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::CANCELED_ADMISSION);
            if (DetTicketAccessEntry.FindFirst()) then
                Error(TICKET_CANCELLED, TicketNo, DetTicketAccessEntry."Created Datetime");

            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
            DetTicketAccessEntry.FindFirst();

            // Ticket is prepaid by third party
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::PREPAID);
            if (DetTicketAccessEntry.FindFirst()) then begin
                if (AdmissionRefundAmount <> 0) then
                    if (not Confirm(PREPAID_REFUND, false, Admission."Admission Code", DetTicketAccessEntry."Sales Channel No.")) then
                        AdmissionRefundAmount := 0;
            end;

            // Ticket will be post paid after admission, by claim from us to third party. we will claim ticket if admission was registered.
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::POSTPAID);
            if (DetTicketAccessEntry.FindFirst()) then begin
                if (AdmissionRefundAmount <> 0) then
                    if (not Confirm(POSTPAID_REFUND, false, Admission."Admission Code", DetTicketAccessEntry."Sales Channel No.")) then
                        AdmissionRefundAmount := 0;
            end;

            TotalRefundAmount += AdmissionRefundAmount;

            Clear(ReservationRequest);
            ReservationRequest."Entry No." := 0;
            ReservationRequest."Session Token ID" := Token;
            ReservationRequest."Ext. Line Reference No." := 1;

            ReservationRequest."Item No." := Ticket."Item No.";
            ReservationRequest."Variant Code" := Ticket."Variant Code";
            ReservationRequest."External Item Code" := GetExternalNo(Ticket."Item No.", Ticket."Variant Code");

            ReservationRequest."Admission Code" := TicketAccessEntry."Admission Code";
            ReservationRequest."Receipt No." := SalesReceiptNo;
            ReservationRequest."Line No." := SalesLineNo;

            ReservationRequest."External Ticket Number" := Ticket."External Ticket No.";

            ReservationRequest."Revoke Ticket Request" := true;
            ReservationRequest."Revoke Access Entry No." := TicketAccessEntry."Entry No.";
            ReservationRequest.Quantity := RevokeQuantity;

            ReservationRequest."External Member No." := Ticket."External Member Card No.";
            ReservationRequest."Admission Description" := Admission.Description;

            ReservationRequest."Created Date Time" := CurrentDateTime();

            ReservationRequest."Request Status" := ReservationRequest."Request Status"::REGISTERED;

            ReservationRequest."Request Status Date Time" := CurrentDateTime();
            ReservationRequest."Expires Date Time" := CalculateNewExpireTime();
            ReservationRequest.Insert();

        until (TicketAccessEntry.Next() = 0);

        AmountInOut := Round(TotalRefundAmount, 0.01);

        exit(true);
    end;

    procedure IsReservationRequest(Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then
            exit(not TicketReservationRequest."Revoke Ticket Request");

        exit(false);
    end;

    procedure IsRevokeRequest(Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then
            exit(TicketReservationRequest."Revoke Ticket Request");

        exit(false);
    end;

    procedure IsRequestStatusReservation(Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then
            exit(TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::RESERVED);

        exit(false);
    end;

    procedure GetTokenFromReceipt(ReceiptNo: Code[20]; LineNumber: Integer; var Token: Text[100]): Boolean
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

    procedure GetReceiptFromToken(var ReceiptNo: Code[20]; var LineNumber: Integer; Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        ReceiptNo := '';
        LineNumber := 0;

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (not TicketReservationRequest.FindFirst()) then
            exit(false);

        ReceiptNo := TicketReservationRequest."Receipt No.";
        LineNumber := TicketReservationRequest."Line No.";

        exit(true);
    end;

    procedure SetReceiptForToken(ReceiptNo: Code[20]; LineNumber: Integer; Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            repeat


            until (TicketReservationRequest.Next() = 0);
            exit(true);

        end;
        exit(false);
    end;

    procedure GetTokenTicket(Token: Text[100]; var TicketNo: Code[20]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                if (TicketReservationRequest."Admission Created") then begin
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                    if (Ticket.FindFirst()) then begin
                        TicketNo := Ticket."No.";
                        exit(true);
                    end;
                end;
            until (TicketReservationRequest.Next() = 0);
        end;

        exit(false);
    end;

    procedure GetTicketToken(InternalTicketNo: Code[20]; var Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        Token := '';

        if (not Ticket.Get(InternalTicketNo)) then
            exit(false);

        if (not TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
            exit(false);

        Token := TicketReservationRequest."Session Token ID";
        exit(true);
    end;

    procedure GetExternalNo(ItemNo: Code[20]; VariantCode: Code[10]) ExternalNo: Code[50]
    var
        ItemReference: Record "Item Reference";
    begin
        ExternalNo := ItemNo;

        ItemReference.SetFilter("Item No.", '=%1', ItemNo);
        ItemReference.SetFilter("Variant Code", '=%1', VariantCode);
        ItemReference.SetFilter("Discontinue Bar Code", '=%1', false);
        ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
        if (ItemReference.FindFirst()) then
            ExternalNo := ItemReference."Reference No.";

        exit(ExternalNo);
    end;

    procedure POS_OnModifyQuantity(SaleLinePOS: Record "NPR POS Sale Line")
    var
        Token: Text[100];
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        ResponseMessage: Text;
        ResponseCode: Integer;
        Ticket: Record "NPR TM Ticket";
        TicketCount: Integer;
        RevokeQuantity: Integer;
    begin

        if (not (GetTokenFromReceipt(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token))) then
            exit;

        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (ReservationRequest.FindFirst()) then begin


            if (SaleLinePOS.Quantity > 0) then begin
                if (ReservationRequest.Quantity = SaleLinePOS.Quantity) then
                    exit;

                if (ReservationRequest."Item No." <> SaleLinePOS."No.") or (ReservationRequest."Variant Code" <> SaleLinePOS."Variant Code") then begin

                    if (ReservationRequest."Admission Created") then
                        Error(EXTERNAL_ITEM_CHANGE);

                    ReservationRequest.DeleteAll();
                    exit;
                end;

                if (ReservationRequest."Request Status" = ReservationRequest."Request Status"::CONFIRMED) then
                    Error(CHANGE_NOT_ALLOWED);

                DeleteReservationRequest(Token, false);
                UpdateReservationQuantity(Token, SaleLinePOS.Quantity);
                ResponseCode := IssueTicketFromReservationToken(Token, false, ResponseMessage);
                if (ResponseCode <> 0) then
                    Error(ResponseMessage);
            end;

            // Return sales
            if (SaleLinePOS.Quantity < 0) then begin
                Ticket.SetFilter("Sales Receipt No.", '=%1', SaleLinePOS."Return Sale Sales Ticket No.");
                Ticket.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
                if (Ticket.FindSet()) then begin
                    DeleteReservationRequest(Token, true);
                    repeat

                        if (POS_CreateRevokeRequest(Token, Ticket."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", SaleLinePOS."Unit Price", RevokeQuantity)) then
                            TicketCount += RevokeQuantity;

                    until ((Ticket.Next() = 0) or (TicketCount >= Abs(SaleLinePOS.Quantity)));

                    if (TicketCount < Abs(SaleLinePOS.Quantity)) then
                        Error(MAX_TO_REVOKE, TicketCount);

                end;
            end;


        end;
    end;

    procedure OnDeleteSaleLinePos(SaleLinePOS: Record "NPR POS Sale Line")
    var
        Token: Text[100];
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        if (not (GetTokenFromReceipt(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token))) then
            exit;

        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        ReservationRequest.SetFilter("Request Status", '=%1', ReservationRequest."Request Status"::CONFIRMED);
        if (ReservationRequest.IsEmpty()) then
            DeleteReservationRequest(Token, true);
    end;

    procedure ReadyToConfirm(Token: Text[100]): Boolean
    var
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        ReservationRequest.SetFilter("Request Status", '=%1', ReservationRequest."Request Status"::REGISTERED);
        exit(ReservationRequest.FindFirst());
    end;

    procedure ReadyToCancel(Token: Text[100]): Boolean
    var
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        ReservationRequest.SetFilter("Request Status", '=%1', ReservationRequest."Request Status"::CONFIRMED);
        exit(ReservationRequest.FindFirst());
    end;

    procedure SetTicketMember(Token: Text[100]; ExternalMemberNo: Code[20])
    var
        Ticket: Record "NPR TM Ticket";
        TicketNo: Code[20];
    begin

        if (not (GetTokenTicket(Token, TicketNo))) then
            exit;

        Ticket.Get(TicketNo);
        Ticket."External Member Card No." := ExternalMemberNo;
        Ticket.Modify();
    end;

    procedure SetShowProgressBar(ShowProgressBarIn: Boolean)
    begin
        showProgressBar := (ShowProgressBarIn and GuiAllowed);
    end;

    local procedure GetShowProgressBar(): Boolean
    begin
        exit(showProgressBar);
    end;

    procedure ExportTicketRequestListToClientExcel(var TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        TempFile: File;
        Name: Text;
        NewStream: InStream;
        ToFile: Text;
        ReturnValue: Boolean;
        FileManagement: Codeunit "File Management";
    begin

        // The link to ticket is only on the first request
        TicketReservationRequest.FindFirst();
        TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest2.FindFirst();

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Entry No.", '=%1', TicketReservationRequest2."Entry No.");
        TicketReservationRequest.FindFirst();

        TempFile.TextMode(false);
        TempFile.WriteMode(true);

        Name := FileManagement.ServerTempFileName('tmp');

        TempFile.Create(Name);
        TempFile.Close();

        REPORT.SaveAsExcel(REPORT::"NPR TM Ticket Batch Resp.", Name, TicketReservationRequest);

        TempFile.Open(Name);
        TempFile.CreateInStream(NewStream);
        ToFile := 'TicketReport.xls';

        ReturnValue := DownloadFromStream(
          NewStream,
          'Save file to client',
          '',
          'Excel File *.xls| *.xls',
          ToFile);

        TempFile.Close();
    end;

    local procedure CalculateNewExpireTime(): DateTime;
    begin
        exit(CurrentDateTime() + 1500 * 1000);
    end;

    // ***************** EVENTS

    [IntegrationEvent(FALSE, FALSE)]
    procedure OnAfterBlockTicketPublisher(TicketNo: Code[20])
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    procedure OnAfterUnblockTicketPublisher(TicketNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterConfirmTicketChangeRequestPublisher(Token: Text[100])
    begin

    end;

    // ****************** NP-Pass eTicket Integration

    [EventSubscriber(ObjectType::Codeunit, 6060119, 'OnAfterBlockTicketPublisher', '', true, true)]
    local procedure OnAfterBlockTicketSubscriber(TicketNo: Code[20])
    var
        ResponseText: Text;
    begin

        SendETicketVoidRequest(TicketNo, true, ResponseText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060119, 'OnAfterUnblockTicketPublisher', '', true, true)]
    local procedure OnAfterUnblockTicketSubscriber(TicketNo: Code[20])
    var
        ResponseText: Text;
    begin

        SendETicketVoidRequest(TicketNo, false, ResponseText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060119, 'OnAfterConfirmTicketChangeRequestPublisher', '', true, true)]
    local procedure OnAfterConfirmTicketChangeRequestSubscriber(Token: Text[100]);
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
        ResponseMessage: Text;
    begin

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (NOT TicketReservationRequest.FindFirst()) then
            exit;

        while (TRUE) do begin
            TicketNotificationEntry.SetFilter("Ticket Token", '=%1', TicketReservationRequest."Session Token ID");
            if (TicketNotificationEntry.FindSet()) then begin
                repeat
                    if (NOT (SendETicketUpdateRequest(Token, TicketNotificationEntry."Ticket No.", TicketNotificationEntry."Admission Code", ResponseMessage))) then
                        MESSAGE(ResponseMessage);
                until (TicketNotificationEntry.NEXT() = 0);
                exit;

            end else begin
                if (TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::PRIMARY) then
                    exit;
                TicketReservationRequest.GET(TicketReservationRequest."Superseeds Entry No.");
            end;
        end;

    end;

    local procedure SendETicketVoidRequest(TicketNo: Code[20]; VoidETicket: Boolean; var ResponseMessage: Text): Boolean
    var
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
        RecordToText: Text;
    begin

        TicketNotificationEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketNotificationEntry.SetFilter("Notification Trigger", '=%1', TicketNotificationEntry."Notification Trigger"::ETICKET_CREATE);
        if (TicketNotificationEntry.IsEmpty()) then
            exit(false);

        RecordToText := Format(TicketNotificationEntry, 0, 9);

        TicketNotificationEntry.FindLast();
        TicketNotificationEntry."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_UPDATE;
        TicketNotificationEntry.Voided := VoidETicket;

        if ((RecordToText = Format(TicketNotificationEntry, 0, 9)) and
            (TicketNotificationEntry."Notification Send Status" <> TicketNotificationEntry."Notification Send Status"::FAILED)) then
            exit(false); // We have already sent this message

        TicketNotificationEntry."Entry No." := 0;
        TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::PENDING;

        case VoidETicket of
            true:
                TicketNotificationEntry."Ticket Trigger Type" := TicketNotificationEntry."Ticket Trigger Type"::CANCEL_RESERVE;
            false:
                TicketNotificationEntry."Ticket Trigger Type" := TicketNotificationEntry."Ticket Trigger Type"::RESERVE;
        end;

        TicketNotificationEntry.Insert();

        exit(SendETicketNotification(TicketNotificationEntry."Entry No.", false, ResponseMessage));

    end;

    local procedure SendETicketUpdateRequest(Token: Text[100]; TicketNo: Code[20]; AdmissionCode: Code[20]; var ResponseMessage: Text): Boolean;
    var
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
        Admission: Record "NPR TM Admission";
        RecordToText: Text;
    begin

        TicketNotificationEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketNotificationEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        TicketNotificationEntry.SetFilter("Notification Trigger", '=%1', TicketNotificationEntry."Notification Trigger"::ETICKET_CREATE);
        if (TicketNotificationEntry.ISEMPTY()) then
            exit(FALSE);

        RecordToText := FORMAT(TicketNotificationEntry, 0, 9);

        TicketNotificationEntry.FindLast();
        TicketNotificationEntry."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_UPDATE;

        Admission.GET(AdmissionCode);

        if (Admission."Capacity Control" <> Admission."Capacity Control"::SEATING) then
            AssignAdmissionInformation(TicketNo, AdmissionCode, TicketNotificationEntry);

        if ((RecordToText = FORMAT(TicketNotificationEntry, 0, 9)) AND
            (TicketNotificationEntry."Notification Send Status" <> TicketNotificationEntry."Notification Send Status"::FAILED)) then
            exit(FALSE); // We have already sent this message

        TicketNotificationEntry."Entry No." := 0;
        TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::PENDING;
        TicketNotificationEntry."Ticket Token" := Token;

        TicketNotificationEntry.Insert();
        exit(SendETicketNotification(TicketNotificationEntry."Entry No.", FALSE, ResponseMessage));

    end;

    procedure IsETicket(TicketNo: Code[20]): Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        Ticket: Record "NPR TM Ticket";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
    begin

        if (not TicketSetup.Get()) then
            exit(false);

        if (not Ticket.Get(TicketNo)) then
            exit(false);

        TicketAdmissionBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketAdmissionBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        TicketAdmissionBOM.SetFilter("Publish As eTicket", '=%1', true);
        exit(not TicketAdmissionBOM.IsEmpty());
    end;

    procedure CreateAndSendETicket(TicketNo: Code[20]; var ReasonText: Text): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TmpTicketNotificationEntry: Record "NPR TM Ticket Notif. Entry" temporary;
    begin

        Ticket.Get(TicketNo);
        if (not CreateETicketNotificationEntry(Ticket, TmpTicketNotificationEntry, false, ReasonText)) then
            exit(false);

        TmpTicketNotificationEntry.Reset();
        TmpTicketNotificationEntry.FindSet();
        repeat

            if (not SendETicketNotification(TmpTicketNotificationEntry."Entry No.", false, ReasonText)) then
                exit(false);

        until (TmpTicketNotificationEntry.Next() = 0);

        ReasonText := '';
        exit(true);
    end;

    procedure CreateETicketNotificationEntry(Ticket: Record "NPR TM Ticket"; var TmpNotificationsCreated: Record "NPR TM Ticket Notif. Entry" temporary; NotifyWithExternalModule: Boolean; var ReasonText: Text): Boolean
    var
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
        TicketNotificationEntry2: Record "NPR TM Ticket Notif. Entry";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        Admission2: Record "NPR TM Admission";
        TicketType: Record "NPR TM Ticket Type";
        Item: Record Item;
        TicketSetup: Record "NPR TM Ticket Setup";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        SeatingReservationEntry: Record "NPR TM Seating Reserv. Entry";
        SeatingTemplate: Record "NPR TM Seating Template";
    begin

        TicketNotificationEntry.Init();
        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");

        // If this is an update, duplicate the lines (one per admission code) and set status pending
        TicketNotificationEntry.SetFilter("Ticket Token", '=%1', TicketReservationRequest."Session Token ID");
        TicketNotificationEntry.SetFilter("Notification Trigger", '=%1|=%2', TicketNotificationEntry."Notification Trigger"::ETICKET_UPDATE, TicketNotificationEntry."Notification Trigger"::ETICKET_CREATE);
        if (TicketNotificationEntry.FindLast()) then begin

            TicketNotificationEntry.SetFilter("Notification Group Id", '=%1', TicketNotificationEntry."Notification Group Id");
            TicketNotificationEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
            if (TicketNotificationEntry.FindSet()) then begin
                repeat
                    TicketNotificationEntry2.TransferFields(TicketNotificationEntry, false);
                    TicketNotificationEntry2."Entry No." := 0;
                    TicketNotificationEntry2."Notification Group Id" += 1;
                    TicketNotificationEntry2."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_UPDATE;

                    TicketNotificationEntry2."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::PENDING;


                    case TicketReservationRequest."Notification Method" of
                        TicketReservationRequest."Notification Method"::SMS:
                            TicketNotificationEntry2."Notification Method" := TicketNotificationEntry."Notification Method"::SMS;
                        TicketReservationRequest."Notification Method"::EMAIL:
                            TicketNotificationEntry2."Notification Method" := TicketNotificationEntry."Notification Method"::EMAIL;
                    end;
                    TicketNotificationEntry2."Notification Address" := TicketReservationRequest."Notification Address";

                    if (NotifyWithExternalModule) then begin
                        TicketNotificationEntry2."Notification Method" := TicketNotificationEntry2."Notification Method"::NA;
                    end;
                    TicketNotificationEntry2.Insert();

                    TmpNotificationsCreated.TransferFields(TicketNotificationEntry2, true);
                    TmpNotificationsCreated.Insert();
                until (TicketNotificationEntry.Next() = 0);

                exit(true);
            end;
        end;


        if (TicketReservationRequest."Notification Method" = TicketReservationRequest."Notification Method"::NA) then begin
            if (not NotifyWithExternalModule) then begin
                ReasonText := StrSubstNo(MISSING_RECIPIENT, TicketReservationRequest.FieldCaption("Notification Method"));
                exit(false);
            end;
        end;

        TicketAdmissionBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketAdmissionBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        TicketAdmissionBOM.SetFilter("Publish As eTicket", '=%1', true);
        if (TicketAdmissionBOM.IsEmpty()) then begin
            ReasonText := StrSubstNo(NOT_ETICKET, Ticket."Item No.", TicketAdmissionBOM.FieldCaption("Admission Code"), TicketAdmissionBOM.FieldCaption("Publish As eTicket"), TicketAdmissionBOM.TableCaption());
            exit(false);
        end;

        TicketSetup.Get();
        Item.Get(Ticket."Item No.");
        TicketType.Get(Ticket."Ticket Type Code");

        TicketAdmissionBOM.FindSet();
        repeat
            Admission.Get(TicketAdmissionBOM."Admission Code");

            TicketNotificationEntry.Init();
            TicketNotificationEntry."Entry No." := 0;
            TicketNotificationEntry."Notification Group Id" := 1;

            TicketNotificationEntry."Ticket Token" := TicketReservationRequest."Session Token ID";
            TicketNotificationEntry."eTicket Pass Id" := GetNewToken();
            TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::PENDING;
            case TicketReservationRequest."Notification Method" of
                TicketReservationRequest."Notification Method"::SMS:
                    TicketNotificationEntry."Notification Method" := TicketNotificationEntry."Notification Method"::SMS;
                TicketReservationRequest."Notification Method"::EMAIL:
                    TicketNotificationEntry."Notification Method" := TicketNotificationEntry."Notification Method"::EMAIL;
            end;
            TicketNotificationEntry."Notification Address" := TicketReservationRequest."Notification Address";

            if (NotifyWithExternalModule) then begin
                TicketNotificationEntry."Notification Method" := TicketNotificationEntry."Notification Method"::NA;
            end;

            TicketNotificationEntry."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_UPDATE;

            TicketNotificationEntry2.SetFilter("Ticket No.", '=%1', Ticket."No.");
            TicketNotificationEntry2.SetFilter("Notification Send Status", '=%1', TicketNotificationEntry2."Notification Send Status"::SENT);
            if (TicketNotificationEntry2.IsEmpty()) then
                TicketNotificationEntry."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_CREATE;

            TicketNotificationEntry."Ticket Type Code" := TicketType.Code;
            TicketNotificationEntry."eTicket Type Code" := TicketType."eTicket Type Code";

            TicketNotificationEntry."Ticket BOM Adm. Description" := TicketAdmissionBOM."Admission Description";
            TicketNotificationEntry."Ticket BOM Description" := TicketAdmissionBOM.Description;

            // Ticket Level data
            TicketNotificationEntry."Ticket No." := Ticket."No.";
            TicketNotificationEntry."Ticket List Price" := Item."Unit Price";
            TicketNotificationEntry."External Ticket No." := Ticket."External Ticket No.";
            TicketNotificationEntry."Ticket No. for Printing" := Ticket."Ticket No. for Printing";
            TicketNotificationEntry."Relevant Datetime" := CreateDateTime(Ticket."Valid From Date", Ticket."Valid From Time");
            TicketNotificationEntry."Relevant Date" := Ticket."Valid From Date";
            TicketNotificationEntry."Relevant Time" := Ticket."Valid From Time";
            TicketNotificationEntry."Expire Datetime" := CreateDateTime(Ticket."Valid To Date", Ticket."Valid To Time");
            TicketNotificationEntry."Expire Date" := Ticket."Valid To Date";
            TicketNotificationEntry."Expire Time" := Ticket."Valid To Time";
            TicketNotificationEntry."Authorization Code" := TicketReservationRequest."Authorization Code";

            // Admission Level Data
            TicketNotificationEntry."Admission Code" := Admission."Admission Code";
            TicketNotificationEntry."Adm. Event Description" := Admission.Description;
            if (Admission."eTicket Type Code" <> '') then
                TicketNotificationEntry."eTicket Type Code" := Admission."eTicket Type Code";

            TicketNotificationEntry."Adm. Location Description" := Admission.Description;
            if (Admission."Location Admission Code" <> '') then
                if (Admission2.Get(Admission."Location Admission Code")) then
                    TicketNotificationEntry."Adm. Location Description" := Admission2.Description;

            if (Admission."Capacity Control" = Admission."Capacity Control"::SEATING) then begin
                SeatingReservationEntry.SetFilter("Ticket Token", '=%1', TicketNotificationEntry."Ticket Token");
                SeatingReservationEntry.SetFilter("Admission Code", '=%1', TicketNotificationEntry."Admission Code");
                if (SeatingReservationEntry.FindSet()) then begin
                    AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', SeatingReservationEntry."External Schedule Entry No.");
                    AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                    if (AdmissionScheduleEntry.FindFirst()) then begin
                        TicketNotificationEntry."Event Start Date" := AdmissionScheduleEntry."Admission Start Date";
                        TicketNotificationEntry."Event Start Time" := AdmissionScheduleEntry."Admission Start Time";
                        TicketNotificationEntry."Relevant Date" := AdmissionScheduleEntry."Admission Start Date";
                        TicketNotificationEntry."Relevant Time" := AdmissionScheduleEntry."Event Arrival From Time";
                    end;
                    TicketNotificationEntry."Quantity To Admit" := 1;
                    repeat
                        SeatingTemplate.SetFilter("Admission Code", '=%1', TicketNotificationEntry."Admission Code");
                        SeatingTemplate.SetFilter(ElementId, '=%1', SeatingReservationEntry.ElementId);
                        if (SeatingTemplate.FindFirst()) then begin
                            TicketNotificationEntry.Seat := SeatingTemplate.Description;
                            if (SeatingTemplate.Get(SeatingTemplate."Parent Entry No.")) then begin
                                TicketNotificationEntry.Row := SeatingTemplate.Description;
                                if (SeatingTemplate.Get(SeatingTemplate."Parent Entry No.")) then begin
                                    TicketNotificationEntry.Section := SeatingTemplate.Description;
                                end;
                            end;
                        end;
                        TicketNotificationEntry."Entry No." := 0;
                        TicketNotificationEntry.Insert();
                        TmpNotificationsCreated.TransferFields(TicketNotificationEntry, true);
                        TmpNotificationsCreated.Insert();
                    until (SeatingReservationEntry.Next() = 0);
                end;
            end;

            if (Admission."Capacity Control" <> Admission."Capacity Control"::SEATING) then begin
                AssignAdmissionInformation(Ticket."No.", TicketAdmissionBOM."Admission Code", TicketNotificationEntry);
                TicketNotificationEntry."Entry No." := 0;
                TicketNotificationEntry.Insert();
                TmpNotificationsCreated.TransferFields(TicketNotificationEntry, true);
                TmpNotificationsCreated.Insert();
            end;

        until (TicketAdmissionBOM.Next() = 0);

        exit(true);
    end;

    local procedure AssignAdmissionInformation(TicketNo: Code[20]; AdmissionCode: Code[20]; var TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry");
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (TicketAccessEntry.FindFirst()) then begin

            TicketNotificationEntry."Quantity To Admit" := TicketAccessEntry.Quantity;

            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
            if (DetTicketAccessEntry.ISEMPTY()) then
                DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);

            if (DetTicketAccessEntry.FindFirst()) then begin
                AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', FALSE);
                if (AdmissionScheduleEntry.FindFirst()) then begin
                    TicketNotificationEntry."Event Start Date" := AdmissionScheduleEntry."Admission Start Date";
                    TicketNotificationEntry."Event Start Time" := AdmissionScheduleEntry."Admission Start Time";
                    TicketNotificationEntry."Relevant Date" := AdmissionScheduleEntry."Admission Start Date";
                    TicketNotificationEntry."Relevant Time" := AdmissionScheduleEntry."Event Arrival From Time";
                    TicketNotificationEntry."Relevant Datetime" := CreateDateTime(TicketNotificationEntry."Relevant Date", TicketNotificationEntry."Relevant Time");
                    TicketNotificationEntry."Admission Schedule Entry No." := AdmissionScheduleEntry."Entry No.";
                    TicketNotificationEntry."Det. Ticket Access Entry No." := DetTicketAccessEntry."Entry No.";
                end;
            end;
        end;
    end;

    procedure SendETicketNotification(NotificationEntryNo: Integer; NotifyWithExternalModule: Boolean; var ResponseMessage: Text): Boolean
    var
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
    begin
        TicketNotificationEntry.Get(NotificationEntryNo);

        if (TicketNotificationEntry."Notification Send Status" <> TicketNotificationEntry."Notification Send Status"::PENDING) then begin
            ResponseMessage := 'Incorrect send status.';
            exit(false);
        end;

        if (not NotifyWithExternalModule) then begin
            if (TicketNotificationEntry."Notification Address" = '') then begin
                ResponseMessage := 'Missing notification address.';
                exit(false);
            end;

            if (TicketNotificationEntry."Notification Method" <> TicketNotificationEntry."Notification Method"::SMS) then begin
                ResponseMessage := 'Only SMS is supported.';
                exit(false);
            end;
        end;

        if (not CreateETicket(TicketNotificationEntry, ResponseMessage)) then begin
            TicketNotificationEntry."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketNotificationEntry."Failed With Message"));
            TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::FAILED;
            TicketNotificationEntry.Modify();
            Commit();
            exit(false);
        end;

        if (not NotifyWithExternalModule) then begin
            if (TicketNotificationEntry."Notification Trigger" = TicketNotificationEntry."Notification Trigger"::ETICKET_CREATE) then begin
                if (not SendSMS(TicketNotificationEntry, ResponseMessage)) then begin
                    TicketNotificationEntry."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketNotificationEntry."Failed With Message"));
                    TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::FAILED;
                    TicketNotificationEntry.Modify();
                    Commit();
                    exit(false);
                end;
            end;
        end;

        TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::SENT;
        TicketNotificationEntry."Notification Sent At" := CurrentDateTime();
        TicketNotificationEntry."Notification Sent By User" := UserId;
        TicketNotificationEntry.Modify();
        ResponseMessage := '';
        Commit(); // External System State can not roll back

        exit(true);
    end;

    local procedure CreateETicket(var TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; var ReasonMessage: Text): Boolean
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        PassData: Text;
    begin

        PassData := GetETicketPassData(TicketNotificationEntry);

        if (TicketSetup.Get()) then
            if (TicketSetup."Show Message Body (Debug)") then
                Message('Pass Data %1', CopyStr(PassData, 1, 2048));

        if (not CreatePass(TicketNotificationEntry, PassData, ReasonMessage)) then
            exit(false);

        if (not SetPassUrl(TicketNotificationEntry, ReasonMessage)) then
            exit(false);

        exit(true);
    end;

    procedure GetETicketPassData(TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry") PassData: Text
    var
        TicketType: Record "NPR TM Ticket Type";
        RecRef: RecordRef;
        TemplateInStream: InStream;
        templateText: Text;
    begin

        TicketType.Get(TicketNotificationEntry."Ticket Type Code");
        if (not TicketType."eTicket Activated") then
            exit('');

        RecRef.GetTable(TicketNotificationEntry);

        TicketType.CalcFields("eTicket Template");
        if (TicketType."eTicket Template".HasValue()) then begin
            TicketType."eTicket Template".CreateInStream(TemplateInStream);
            while (not TemplateInStream.EOS()) do begin
                TemplateInStream.ReadText(templateText);
                PassData += AssignDataToPassTemplate(RecRef, templateText);
            end;

            if (templateText = '') then begin
                templateText := GetDefaultTemplate();
                PassData += AssignDataToPassTemplate(RecRef, templateText);
            end;

        end else begin
            templateText := GetDefaultTemplate();
            PassData += AssignDataToPassTemplate(RecRef, templateText);
        end;
    end;

    local procedure CreatePass(var TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; PassData: Text; var ReasonMessage: Text): Boolean
    var
        JSONResult: Text;
    begin

        exit(NPPassServerInvokeApi('PUT', TicketNotificationEntry, ReasonMessage, PassData, JSONResult));
    end;

    local procedure SetPassUrl(var TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; var ReasonMessage: Text): Boolean
    var
        JSONResult: Text;
        JObject: JsonObject;

    begin

        if not (NPPassServerInvokeApi('GET', TicketNotificationEntry, ReasonMessage, '', JSONResult)) then
            exit(false);

        if (JSONResult = '') then
            exit(false);

        JObject.ReadFrom(JSONResult);

        TicketNotificationEntry."eTicket Pass Default URL" := GetStringValue(JObject, 'public_url.default');
        TicketNotificationEntry."eTicket Pass Andriod URL" := GetStringValue(JObject, 'public_url.android');
        TicketNotificationEntry."eTicket Pass Landing URL" := GetStringValue(JObject, 'public_url.landing');

        exit(true);
    end;

    local procedure GetStringValue(JObject: JsonObject; JKey: Text) JValue: Text
    var
        JToken: JsonToken;
    begin

        if (not JObject.SelectToken(JKey, JToken)) then
            exit('');

        JToken.WriteTo(JValue);
    end;

    procedure AssignDataToPassTemplate(var RecRef: RecordRef; Line: Text) NewLine: Text
    var
        FieldRef: FieldRef;
        EndPos: Integer;
        FieldNo: Integer;
        i: Integer;
        OptionInt: Integer;
        SeparatorLength: Integer;
        StartPos: Integer;
        EndSeparator: Text[10];
        StartSeparator: Text[10];
        OptionCaption: Text[1024];
    begin
        StartSeparator := '{[';
        EndSeparator := ']}';
        SeparatorLength := StrLen(StartSeparator);

        NewLine := Line;
        while (StrPos(NewLine, StartSeparator) > 0) do begin
            StartPos := StrPos(NewLine, StartSeparator);
            EndPos := StrPos(NewLine, EndSeparator);

            Evaluate(FieldNo, CopyStr(NewLine, StartPos + SeparatorLength, EndPos - StartPos - SeparatorLength));
            if (RecRef.FieldExist(FieldNo)) then begin

                FieldRef := RecRef.Field(FieldNo);
                if UpperCase(Format(FieldRef.Class)) = 'FLOWFIELD' then
                    FieldRef.CalcField;

                NewLine := DelStr(NewLine, StartPos, EndPos - StartPos + SeparatorLength);

                if (UpperCase(Format(Format(FieldRef.Type)))) = 'OPTION' then begin
                    OptionCaption := Format(FieldRef.OptionMembers);
                    Evaluate(OptionInt, Format(FieldRef.Value));
                    for i := 1 to OptionInt do
                        OptionCaption := DelStr(OptionCaption, 1, StrPos(OptionCaption, ','));
                    if (StrPos(OptionCaption, ',') <> 0) then
                        OptionCaption := DelStr(OptionCaption, StrPos(OptionCaption, ','));
                    NewLine := InsStr(NewLine, OptionCaption, StartPos);
                end else
                    if (UpperCase(Format(Format(FieldRef.Type)))) = 'DATETIME' then begin
                        NewLine := InsStr(NewLine, Format(FieldRef.Value, 0, 9), StartPos);
                    end else
                        if (UpperCase(Format(Format(FieldRef.Type)))) = 'BOOLEAN' then begin
                            NewLine := InsStr(NewLine, LowerCase(Format(FieldRef.Value, 0, 9)), StartPos);
                        end else begin
                            NewLine := InsStr(NewLine, DelChr(Format(FieldRef.Value), '<=>', '"'), StartPos);
                        end;
            end else
                ERROR(BAD_REFERENCE, FieldNo, Line);
        end;

        exit(NewLine);
    end;

    procedure GetDefaultTemplate() template: Text
    var
        CRLF: Text[2];
    begin

        CRLF[1] := 13;
        CRLF[2] := 10;

        template :=
        '{"data":{' + CRLF +
            '"customer": {' + CRLF +
            '"email": "{[160]}",' + CRLF +
            '"name": "{[165]}"' + CRLF +
            '},' + CRLF +
            '"event": {' + CRLF +
            ' "description": "{[170]}",' + CRLF +
            '"date": "{[175]}",' + CRLF +
            '"time": "{[176]}",' + CRLF +
            '"title": "{[173]}",' + CRLF +
            '"venue": "{[172]}"' + CRLF +
            '},' + CRLF +
            '"expiration_date": "{[97]}",' + CRLF +
            '"relevant_date": "{[92]}",' + CRLF +
            '"voided": {[98]},' + CRLF +
            '"ticket": {' + CRLF +
            '"barcode": {' + CRLF +
            '"alt_text": "{[100]}",' + CRLF +
            '"value": "{[100]}"' + CRLF +
            '},' + CRLF +
            '"price": "{[65]} DKK",' + CRLF +
            '"quantity": {[180]},' + CRLF +
            '"url": "http://ticket.shop.dummyshop.dk/ticket/{[100]}"' + CRLF +
            '}' + CRLF +
          '}}';

        exit(template);
    end;

    local procedure SendSMS(TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; var ResponseMessage: Text): Boolean
    var
        RecordRef: RecordRef;
        SMSManagement: Codeunit "NPR SMS Management";
        SMSTemplateHeader: Record "NPR SMS Template Header";
        SmsBody: Text;
    begin

        RecordRef.GetTable(TicketNotificationEntry);

        if (TicketNotificationEntry."Notification Address" = '') then
            ResponseMessage := 'Phone number is missing.';

        if (TicketNotificationEntry."Notification Address" <> '') then begin
            Commit();
            ResponseMessage := 'Template not found.';
            if (SMSManagement.FindTemplate(RecordRef, SMSTemplateHeader)) then begin
                SmsBody := SMSManagement.MakeMessage(SMSTemplateHeader, TicketNotificationEntry);
                SMSManagement.SendSMS(TicketNotificationEntry."Notification Address", SMSTemplateHeader."Alt. Sender", SmsBody);
                ResponseMessage := '';
            end;
        end;

        exit(ResponseMessage = '');
    end;

    [TryFunction]
    procedure NPPassServerInvokeApi(RequestMethod: Code[10]; TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; var ReasonText: Text; JSONIn: Text; var JSONOut: Text)
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        Response: HttpResponseMessage;
        AcceptTok: Label 'Accept', Locked = true;
        ContentTypeTxt: Label 'application/json', Locked = true;
        AuthorizationTok: Label 'Authorization', Locked = true;
        ContentTypeTok: Label 'Content-Type', Locked = true;
        UserAgentTxt: Label 'NP Dynamics Retail / Dynamics 365 Business Central', Locked = true;
        ConnectErrorTxt: Label 'NP Pass Service connection error. (HTTP Reason Code: %1)';
        UserAgentTok: Label 'User-Agent', Locked = true;
        RequestOk: Boolean;
        Url: Text;
    begin

        TicketSetup.Get();

        ReasonText := '';
        JSONOut := '';
        ClearLastError();

        Url := StrSubstNo('%1%2?sync=%3', TicketSetup."NP-Pass Server Base URL",
                                           StrSubstNo(TicketSetup."NP-Pass API", TicketNotificationEntry."eTicket Type Code", TicketNotificationEntry."eTicket Pass Id"),
                                           Format(TicketSetup."NP-Pass Notification Method", 0, 9));

        Content.WriteFrom(JSONIn);
        Content.GetHeaders(ContentHeaders);
        if (ContentHeaders.Contains(ContentTypeTok)) then
            ContentHeaders.Remove(ContentTypeTok);
        ContentHeaders.Add(ContentTypeTok, ContentTypeTxt);

        RequestHeaders := Client.DefaultRequestHeaders();
        RequestHeaders.Clear();
        RequestHeaders.Add(UserAgentTok, UserAgentTxt);
        RequestHeaders.Add(AcceptTok, ContentTypeTxt);
        RequestHeaders.Add(AuthorizationTok, StrSubstNo('Bearer %1', TicketSetup."NP-Pass Token"));

        Client.Timeout := 10000;
        if (TicketSetup."Timeout (ms)" > 0) then
            Client.Timeout := TicketSetup."Timeout (ms)";

        if (RequestMethod = 'PUT') then
            RequestOk := Client.Put(Url, Content, Response);

        if (RequestMethod = 'GET') then
            RequestOk := Client.Get(Url, Response);

        if (RequestOk) then begin
            if (Response.IsSuccessStatusCode()) then begin
                Response.Content.ReadAs(JSONOut);
                exit;
            end;

            if (Response.Content.ReadAs(ReasonText)) then
                Error(ReasonText);

            ReasonText := StrSubstNo(ConnectErrorTxt, Response.HttpStatusCode());
            Error(ReasonText);
        end;

        ReasonText := GetLastErrorText();
        Error(ReasonText);

    end;

}

