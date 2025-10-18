codeunit 6060119 "NPR TM Ticket Request Manager"
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        CHANGE_NOT_ALLOWED: Label 'Confirmed tickets can''t be changed.';

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
        INVALID_TICKET_PIN: Label 'The combination of ticket number and pin code is not valid.';
        NOT_CONFIRMED: Label 'The ticket request must be confirmed prior to change.';
        BAD_REFERENCE: Label 'The template field reference %1 on line %2 is invalid.';

        SALES_NOT_STARTED_1200: Label 'Ticket sales does not start until %1 for %2 using ticket item %3 %4.';
        SALES_STOPPED_1201: Label 'Ticket sales ended at %1 for %2 using ticket item %3 %4.';
        WAITINGLIST_REQUIRED_1202: Label 'Waiting list reference code is required to book a ticket for this time schedule.';
        UNCONFIRMED_TOKEN_NOT_FOUND_1203: Label 'An unconfirmed ticket-token with value %1 was not found.';
        TOKEN_EXPIRED_1204: Label 'The ticket-token %1 has expired. Use PreConfirm to re-reserve tickets.';
        TOKEN_PROCESSING_CONFLICT_1205: Label 'Another request is currently processing this token. Please retry shortly.';
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        TOKEN_ALREADY_CONFIRMED_1206: Label 'The ticket-token %1 has already been confirmed and can not be confirmed again.';
        _FeatureFlagManagement: Codeunit "NPR Feature Flags Management";
#endif  

    procedure LockResources(Source: Text)
    var
        TMTicket: Record "NPR TM Ticket";
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
        StartTime, EndTime : Time;
        DurationMs: Decimal;
        MessageTextLbl: Label '%1: (%2)', Locked = true;
    begin

        StartTime := Time();
        TMTicket.LockTable(true);
        if (TMTicket.FindFirst()) then;
        EndTime := Time();
        DurationMs := EndTime - StartTime;

        if (not ActiveSession.Get(ServiceInstanceId(), SessionId())) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_LockRequestedBy', Source);
        CustomDimensions.Add('NPR_WaitDurationMs', Format(DurationMs, 0, 9));

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");

        Session.LogMessage('NPR_TM_LockResources', StrSubstNo(MessageTextLbl, Source, DurationMs), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
        exit;

    end;

    procedure GetNewToken() Token: Code[40]
    begin
#pragma warning disable AA0139
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
#pragma warning restore
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
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        if (_FeatureFlagManagement.IsEnabled('enableTriStateLockingFeaturesInTicketModule')) then begin
            DeleteReservationRequestV2(Token, RemoveRequest);
            exit;
        end;
#endif
        DeleteReservationRequestV1(Token, RemoveRequest);

    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    [CommitBehavior(CommitBehavior::Error)]
    procedure DeleteReservationRequestV2(Token: Text[100]; RemoveRequest: Boolean)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        Ticket, TicketUpdate : Record "NPR TM Ticket";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketAccessStatistics: Record "NPR TM Ticket Access Stats";
        TicketNotification: Record "NPR TM Ticket Notif. Entry";
        ExpireDateTime: DateTime;
    begin

        TicketReservationRequest.ReadIsolation := IsolationLevel::ReadUncommitted;
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);
        TicketReservationRequest.SetLoadFields("Session Token ID", "Request Status", "Entry Type");
        if (TicketReservationRequest.FindFirst()) then
            Error(CHANGE_NOT_ALLOWED);

        TicketReservationRequest.SetFilter("Request Status", '<>%1 & <>%2', TicketReservationRequest."Request Status"::RESERVED, TicketReservationRequest."Request Status"::WAITINGLIST);
        if (not TicketReservationRequest.FindSet()) then
            exit;

        // If the entries we are about to delete has been included in statistics, we need to reverse the statistics
        // (when the detailed entries entry number is less than or equal to the highest access entry number in the statistics)
        TicketAccessStatistics.SetCurrentKey("Highest Access Entry No.");
        if (not TicketAccessStatistics.FindLast()) then
            TicketAccessStatistics.Init();

        ExpireDateTime := CalculateNewExpireTime();
        repeat

            if (TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::PRIMARY) then begin

                Ticket.SetLoadFields("No.");
                Ticket.ReadIsolation := IsolationLevel::ReadUnCommitted;
                Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                if (Ticket.FindSet()) then begin
                    repeat
                        // Clean up ticket statistics in case it was aggregated before completion
                        // NOTE: Statistics are not aggregated for tickets when job is run and regardless of the status of the ticket, aggregation tracks highest entry numbers only
                        DetailedTicketAccessEntry.Reset();
                        DetailedTicketAccessEntry.ReadIsolation := IsolationLevel::ReadUncommitted;
                        DetailedTicketAccessEntry.SetCurrentKey("Ticket No.");
                        DetailedTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                        if (DetailedTicketAccessEntry.FindSet()) then begin
                            repeat
                                if (DetailedTicketAccessEntry."Entry No." <= TicketAccessStatistics."Highest Access Entry No.") then // Reverse aggregated statistics
                                    ReverseInitialEntryStatistics(DetailedTicketAccessEntry, TicketAccessStatistics."Highest Access Entry No.");
                            until (DetailedTicketAccessEntry.Next() = 0);
                        end;

                        DetailedTicketAccessEntryDelete(Ticket."No.");
                        TicketAccessEntryDelete(Ticket."No.");

                        TicketNotification.ReadIsolation := IsolationLevel::UpdLock;
                        TicketNotification.SetCurrentKey("Ticket No.");
                        TicketNotification.SetLoadFields("Ticket No.");
                        TicketNotification.SetFilter("Ticket No.", '=%1', Ticket."No.");
                        if (TicketNotification.FindSet()) then
                            repeat
                                TicketNotification.Delete();
                            until TicketNotification.Next() = 0;

                        TicketUpdate.ReadIsolation := IsolationLevel::UpdLock;
                        TicketUpdate.Get(Ticket."No.");
                        TicketUpdate.Delete();

                    until (Ticket.Next() = 0);
                end;
            end;

            TicketReservationRequest2.ReadIsolation := IsolationLevel::UpdLock;
            TicketReservationRequest2.SetLoadFields("Entry No.", "Admission Created", "Request Status", "Expires Date Time");
            TicketReservationRequest2.Get(TicketReservationRequest."Entry No.");
            if (not RemoveRequest) then begin
                TicketReservationRequest2."Admission Created" := false;
                TicketReservationRequest2."Request Status" := TicketReservationRequest."Request Status"::EXPIRED;
                TicketReservationRequest2."Expires Date Time" := ExpireDateTime;
                TicketReservationRequest2.Modify();
            end;

            if (RemoveRequest) then begin
                TicketReservationResponse.SetCurrentKey("Session Token ID");
                TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
                TicketReservationResponse.SetLoadFields("Session Token ID");
                if (TicketReservationResponse.FindSet()) then
                    repeat
                        TicketReservationResponse.Delete();
                    until (TicketReservationResponse.Next() = 0);
                TicketReservationRequest2.Delete();
            end;

        until (TicketReservationRequest.Next() = 0);

    end;

    local procedure DetailedTicketAccessEntryDelete(TicketNo: Code[20])
    var
        DetailedTicketAccessEntry, DetailedTicketAccessEntryUpdate : Record "NPR TM Det. Ticket AccessEntry";
    begin

        DetailedTicketAccessEntry.ReadIsolation := IsolationLevel::ReadUnCommitted;
        DetailedTicketAccessEntry.SetCurrentKey("Ticket No.");
        DetailedTicketAccessEntry.SetLoadFields("Ticket No.");
        DetailedTicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);

        if (DetailedTicketAccessEntry.FindSet()) then begin
            DetailedTicketAccessEntryUpdate.ReadIsolation := IsolationLevel::UpdLock;
            repeat
                DetailedTicketAccessEntryUpdate.Get(DetailedTicketAccessEntry."Entry No.");
                DetailedTicketAccessEntryUpdate.Delete();
            until (DetailedTicketAccessEntry.Next() = 0);
        end;
    end;

    local procedure TicketAccessEntryDelete(TicketNo: Code[20])
    var
        TicketAccessEntry, TicketAccessEntryUpdate : Record "NPR TM Ticket Access Entry";
    begin
        TicketAccessEntry.ReadIsolation := IsolationLevel::ReadUnCommitted;
        TicketAccessEntry.SetCurrentKey("Ticket No.");
        TicketAccessEntry.SetLoadFields("Entry No.");
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TicketNo);
        if (TicketAccessEntry.FindSet()) then begin
            TicketAccessEntryUpdate.ReadIsolation := IsolationLevel::UpdLock;
            repeat
                TicketAccessEntryUpdate.Get(TicketAccessEntry."Entry No.");
                TicketAccessEntryUpdate.Delete();
            until (TicketAccessEntry.Next() = 0);
        end;

    end;
#endif
    local procedure DeleteReservationRequestV1(Token: Text[100]; RemoveRequest: Boolean)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        SeatingReservationEntry: Record "NPR TM Seating Reserv. Entry";
        TicketAccessStatistics: Record "NPR TM Ticket Access Stats";
        TicketNotification: Record "NPR TM Ticket Notif. Entry";
        TokenExpired: Label 'Token %1/%2 is marked as expired.';
        TokenDeleted: Label 'Token %1/%2 was deleted.';
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '<>%1 & <>%2', TicketReservationRequest."Request Status"::RESERVED, TicketReservationRequest."Request Status"::WAITINGLIST);

        TicketAccessStatistics.SetCurrentKey("Highest Access Entry No.");
        TicketAccessStatistics.LockTable();
        if (not TicketAccessStatistics.FindLast()) then
            TicketAccessStatistics.Init();

        if (TicketReservationRequest.FindSet(true)) then begin

            if (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CONFIRMED) then
                Error(CHANGE_NOT_ALLOWED);

            repeat

                if (TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::PRIMARY) then begin
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");

                    if (Ticket.FindSet(true)) then begin
                        repeat

                            DetailedTicketAccessEntry.SetCurrentKey("Ticket No.");
                            DetailedTicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                            if (DetailedTicketAccessEntry.Find('-')) then begin
                                if (DetailedTicketAccessEntry."Entry No." <= TicketAccessStatistics."Highest Access Entry No.") then // Reverse aggregated statistics
                                    repeat
                                        ReverseInitialEntryStatistics(DetailedTicketAccessEntry, TicketAccessStatistics."Highest Access Entry No.");
                                    until (DetailedTicketAccessEntry.Next() = 0);
                                DetailedTicketAccessEntry.DeleteAll();
                            end;

                            TicketAccessEntry.SetCurrentKey("Ticket No.");
                            TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                            if (not TicketAccessEntry.IsEmpty()) then
                                TicketAccessEntry.DeleteAll();

                            TicketNotification.SetCurrentKey("Ticket No.");
                            TicketNotification.SetFilter("Ticket No.", '=%1', Ticket."No.");
                            TicketNotification.DeleteAll();

                            Ticket.Delete();

                        until (Ticket.Next() = 0);
                    end;

                    SeatingReservationEntry.SetCurrentKey("Ticket Token");
                    SeatingReservationEntry.SetFilter("Ticket Token", '=%1', Token);
                    if (not SeatingReservationEntry.IsEmpty()) then
                        SeatingReservationEntry.DeleteAll();
                end;

                if (not RemoveRequest) then begin
                    EmitMessageToTelemetry(StrSubstNo(TokenExpired, Token, TicketReservationRequest."Admission Code"));
                    TicketReservationRequest."Admission Created" := false;
                    TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::EXPIRED;
                    TicketReservationRequest."Expires Date Time" := CalculateNewExpireTime();
                    TicketReservationRequest.Modify();
                end;

                if (RemoveRequest) then begin
                    EmitMessageToTelemetry(StrSubstNo(TokenDeleted, Token, TicketReservationRequest."Admission Code"));
                    TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
                    TicketReservationResponse.DeleteAll();
                    TicketReservationRequest.Delete();
                end;

            until (TicketReservationRequest.Next() = 0);

        end;
    end;

    procedure DeleteReservationRequestDynamicTicket(Token: Text[100]; RemoveRequest: Boolean; POSSalesLineNo: Integer)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '<>%1 & <>%2', TicketReservationRequest."Request Status"::RESERVED, TicketReservationRequest."Request Status"::WAITINGLIST);
        if MoreSalesLinesForTicket(Token, POSSalesLineNo) then
            TicketReservationRequest.SetRange("Line No.", POSSalesLineNo);


        if (TicketReservationRequest.FindSet(true)) then begin
            repeat
                if TicketReservationRequest."Line No." = POSSalesLineNo then begin
                    FindTicketByToken(Ticket, Token, TicketReservationRequest."Admission Code", false, TicketReservationRequest."Ext. Line Reference No.");
                    if Ticket."No." = '' then
                        FindTicketByToken(Ticket, Token, TicketReservationRequest."Admission Code", true, TicketReservationRequest."Ext. Line Reference No.");
                    TicketReservationRequest.Quantity := 0;
                    TicketReservationRequest."Admission Inclusion" := TicketReservationRequest."Admission Inclusion"::NOT_SELECTED;
                    TicketReservationRequest."Line No." := 0;
                    TicketReservationRequest."Admission Created" := false; //DeleteAdmission
                    TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                    TicketAccessEntry.SetRange("Admission Code", TicketReservationRequest."Admission Code");
                    if TicketAccessEntry.FindFirst() then begin
                        DetailedTicketAccessEntry.SetRange("Ticket Access Entry No.", TicketAccessEntry."Entry No.");
                        DetailedTicketAccessEntry.DeleteAll();
                        TicketAccessEntry.Delete(true);
                    end;
                    TicketReservationRequest.Modify();
                end;
            until (TicketReservationRequest.Next() = 0);

        end;
    end;

    local procedure ReverseInitialEntryStatistics(DetailedTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry"; MaxAccessEntryNo: Integer)
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        StatisticsMgr: Codeunit "NPR TM Ticket Access Stats";
    begin
        if (DetailedTicketAccessEntry.type <> DetailedTicketAccessEntry.type::INITIAL_ENTRY) then
            exit;

        if (not TicketAccessEntry.Get(DetailedTicketAccessEntry."Ticket Access Entry No.")) then
            exit;

        if (not Ticket.Get(TicketAccessEntry."Ticket No.")) then
            exit;

        TicketAccessEntry."Access Date" := DT2Date(DetailedTicketAccessEntry."Created Datetime");
        TicketAccessEntry."Access Time" := DT2Time(DetailedTicketAccessEntry."Created Datetime");
        TicketAccessEntry.Quantity *= -1;
        StatisticsMgr.AdjustStatistics(TicketAccessEntry, Ticket, MaxAccessEntryNo, DetailedTicketAccessEntry.Type, false);

    end;

    procedure IssueTicketFromReservationToken(Token: Text[100]; FailWithError: Boolean; var ResponseMessage: Text) ResponseCode: Integer
    var
        AttemptTicket: Codeunit "NPR Ticket Attempt Create";
    begin

        if (not FailWithError) then begin
            Commit();
            if (not AttemptTicket.AttemptIssueTicketFromReservationToken(Token, ResponseMessage)) then
                exit(-901);
            exit(0);
        end;

        DoIssueTicketFromReservationToken(Token);
        exit(0);
    end;

    internal procedure DoIssueTicketFromReservationToken(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        AssignPrimaryReservationEntry(Token);
        AssignListPrice(Token);

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FindSet();
        repeat
            IssueTicketFromReservation(TicketReservationRequest);
        until (TicketReservationRequest.Next() = 0);
    end;

    procedure IssueTicketFromReservation(TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        if (_FeatureFlagManagement.IsEnabled('enableTriStateLockingFeaturesInTicketModule')) then begin
            IssueTicketFromReservationV2(TicketReservationRequest);
            exit;
        end;
#endif
        IssueTicketFromReservationV1(TicketReservationRequest);
    end;

    local procedure IssueTicketFromReservationV1(TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        Ticket: Record "NPR TM Ticket";
        TicketManager: Codeunit "NPR TM Ticket Request Manager";
        AdmissionAllowOverAllocationConfirmed: Enum "NPR TM Ternary";
    begin

        TicketManager.LockResources('IssueTicketFromReservation');

        if (TicketReservationRequest."Request Status" <> TicketReservationRequest."Request Status"::CONFIRMED) then begin
            if (not TicketReservationRequest."Admission Created") then
                _IssueNewTickets(TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", TicketReservationRequest.Quantity, TicketReservationRequest."Entry No.");
        end;

        if ((TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CONFIRMED) and
            (not TicketReservationRequest."Admission Created")) then begin

            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            AdmissionAllowOverAllocationConfirmed := AdmissionAllowOverAllocationConfirmed::TERNARY_FALSE;
            if (Ticket.FindSet()) then begin
                repeat
                    _IssueOneAdmission(TicketReservationRequest, Ticket, TicketReservationRequest."Admission Code", 1, true, AdmissionAllowOverAllocationConfirmed);
                until (Ticket.Next() = 0);
            end;
        end;
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    local procedure IssueTicketFromReservationV2(TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        Ticket: Record "NPR TM Ticket";
        AdmissionAllowOverAllocationConfirmed: Enum "NPR TM Ternary";
    begin

        if (TicketReservationRequest."Request Status" <> TicketReservationRequest."Request Status"::CONFIRMED) then begin
            if (not TicketReservationRequest."Admission Created") then
                _IssueNewTickets(TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", TicketReservationRequest.Quantity, TicketReservationRequest."Entry No.");
        end;

        if ((TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CONFIRMED) and
            (not TicketReservationRequest."Admission Created")) then begin

            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            AdmissionAllowOverAllocationConfirmed := AdmissionAllowOverAllocationConfirmed::TERNARY_FALSE;
            if (Ticket.FindSet()) then begin
                repeat
                    _IssueOneAdmission(TicketReservationRequest, Ticket, TicketReservationRequest."Admission Code", 1, true, AdmissionAllowOverAllocationConfirmed);
                until (Ticket.Next() = 0);

            end;
        end;
    end;
#endif

    local procedure _IssueNewTickets(ItemNo: Code[20]; VariantCode: Code[10]; Quantity: Integer; RequestEntryNo: Integer)
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        TicketSetup: Record "NPR TM Ticket Setup";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        NumberOfTickets: Integer;
        TicketQuantity: Integer;
        i: Integer;
        Window: Dialog;
        OverAllocationConfirmed: Dictionary of [Code[20], Enum "NPR TM Ternary"];
        StartTime: DateTime;
        CheckMaxDuration: Boolean;
        DurationExceeded: Label 'Service has exceeded the maximum allowed duration for making tickets. Please try again.';
        QuantityExceeded: Label 'The number of tickets requested exceeds the maximum allowed per request-line.';
    begin

        if (not TicketSetup.Get()) then
            TicketSetup.Init();

        CheckMaxDuration := not ((TicketSetup.MaxDurationSOAPMakeTicketRes = 0) or (TicketSetup.CheckSOAPProgressAfterPct = 0));
        if (CurrentClientType() = ClientType::SOAP) then
            if (TicketSetup.MaxTicketsPerSOAPRequest <> 0) then
                if (Abs(Quantity) > TicketSetup.MaxTicketsPerSOAPRequest) then
                    Error(QuantityExceeded);

        Item.Get(ItemNo);
        if (not TicketType.Get(Item."NPR Ticket Type")) then
            Error(NOT_TICKET_ITEM, ItemNo, Item.FieldCaption("NPR Ticket Type"), Item."NPR Ticket Type");

        if ((not TicketType."Is Ticket") or (TicketType.Code = '')) then
            Error(NOT_TICKET_ITEM, ItemNo, Item.FieldCaption("NPR Ticket Type"), Item."NPR Ticket Type");

        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.SetFilter("Variant Code", '=%1', VariantCode);
        if (TicketBom.IsEmpty()) then
            Error(NO_TICKET_BOM, TicketBom.TableCaption(), TicketBom.GetFilters());

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
        if ReservationRequest."Receipt No." <> '' then
            CreateAdditionalExperienceLine(ReservationRequest);

        ReservationRequest."Admission Created" := false;
        ReservationRequest."Request Status" := ReservationRequest."Request Status"::REGISTERED;
        ReservationRequest."Expires Date Time" := CalculateNewExpireTime();
        ReservationRequest.Modify();

        StartTime := CurrentDateTime();
        for i := 1 to Abs(NumberOfTickets) do begin

            _IssueOneTicket(ItemNo, VariantCode, TicketQuantity, TicketType, ReservationRequest, OverAllocationConfirmed);

            if (GetShowProgressBar()) then
                if (i mod 10 = 0) then
                    Window.Update(1, Round(i / NumberOfTickets * 10000, 1));

            // Check progress after some percentage of the max duration
            if ((CurrentClientType() = ClientType::SOAP) and (CheckMaxDuration)) then
                if (CurrentDateTime() > StartTime + TicketSetup.MaxDurationSOAPMakeTicketRes * 1000 * TicketSetup.CheckSOAPProgressAfterPct / 100) then begin
                    if (NumberOfTickets * TicketSetup.CheckSOAPProgressAfterPct / 100 > i) then
                        Error(DurationExceeded);
                    CheckMaxDuration := false; // Only check once
                end;
        end;

        if (GetShowProgressBar()) then
            Window.Close();

    end;

    internal procedure AssignListPrice(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketPriceDict: Dictionary of [Integer, Dictionary of [Integer, Decimal]];
        ExtLineReferenceNo: Integer;
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter(AmountSource, '=%1', TicketReservationRequest.AmountSource::BC);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                if (SetListPriceForRequestEntry(TicketReservationRequest)) then
                    TicketReservationRequest.Modify();

                if (TicketReservationRequest."Admission Inclusion" <> TicketReservationRequest."Admission Inclusion"::NOT_SELECTED) then
                    AggregateTicketPriceDetails(TicketReservationRequest, TicketPriceDict);

            until (TicketReservationRequest.Next() = 0);

            TicketReservationRequest.Reset();
            TicketReservationRequest.SetCurrentKey("Session Token ID");
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);

            foreach ExtLineReferenceNo in TicketPriceDict.Keys() do begin
                TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', ExtLineReferenceNo);
                if (TicketReservationRequest.FindFirst()) then begin
                    TicketReservationRequest.TicketUnitAmountExclVat := TicketPriceDict.Get(ExtLineReferenceNo).Get(1);
                    TicketReservationRequest.TicketUnitAmountInclVat := TicketPriceDict.Get(ExtLineReferenceNo).Get(2);
                    TicketReservationRequest.TicketListPriceExclVat := TicketPriceDict.Get(ExtLineReferenceNo).Get(1);
                    TicketReservationRequest.TicketListPriceInclVat := TicketPriceDict.Get(ExtLineReferenceNo).Get(2);
                    TicketReservationRequest.Modify();
                end;
            end;
        end;
    end;

    internal procedure SetListPriceForRequestEntry(var TicketReservationRequest: Record "NPR TM Ticket Reservation Req.") PriceUpdated: Boolean
    var
        AdmScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        PriceCalculation: Codeunit "NPR TM Dynamic Price";
        UnitPrice: Decimal;
        DiscountPct: Decimal;
        UnitPriceIncludesVat: Boolean;
        UnitPriceVatPercentage: Decimal;
        ReferenceDate: Date;
        TimeHelper: Codeunit "NPR TM TimeHelper";
        LocalDateTime: DateTime;
        TicketManager: Codeunit "NPR TM Ticket Management";
        EntryNo: Integer;
    begin
        ReferenceDate := Today();
        PriceUpdated := false;
        LocalDateTime := TimeHelper.GetLocalTimeAtAdmission(AdmScheduleEntry."Admission Code");

        // Get Schedule Entry - if not set, use the current schedule entry
        if (TicketReservationRequest."External Adm. Sch. Entry No." <= 0) then begin
            EntryNo := TicketManager.GetCurrentScheduleEntryForSales(TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", TicketReservationRequest."Admission Code");
            if (AdmScheduleEntry.Get(EntryNo)) then begin
                ReferenceDate := AdmScheduleEntry."Admission Start Date";
                TicketReservationRequest."External Adm. Sch. Entry No." := AdmScheduleEntry."External Schedule Entry No.";
            end;

        end else begin
            AdmScheduleEntry.SetCurrentKey("External Schedule Entry No.");
            AdmScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest."External Adm. Sch. Entry No.");
            AdmScheduleEntry.SetFilter(Cancelled, '=%1', false);
            if (AdmScheduleEntry.FindFirst()) then
                ReferenceDate := AdmScheduleEntry."Admission Start Date";
        end;

        if (TicketReservationRequest."Admission Inclusion" = TicketReservationRequest."Admission Inclusion"::REQUIRED) then begin
            PriceCalculation.CalculateErpUnitPrice(
                TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", TicketReservationRequest."Customer No.", ReferenceDate, TicketReservationRequest.Quantity,
                UnitPrice, DiscountPct, UnitPriceIncludesVat, UnitPriceVatPercentage);
            PriceCalculation.SetTicketAdmissionDynamicUnitPrice(TicketReservationRequest, AdmScheduleEntry, UnitPrice, DiscountPct, UnitPriceIncludesVat, UnitPriceVatPercentage, LocalDateTime);
            PriceUpdated := true;
        end;

        if (TicketReservationRequest."Admission Inclusion" <> TicketReservationRequest."Admission Inclusion"::REQUIRED) then begin
            if (Admission.Get(TicketReservationRequest."Admission Code")) then begin
                PriceCalculation.CalculateErpUnitPrice(
                    Admission."Additional Experience Item No.", '', TicketReservationRequest."Customer No.", ReferenceDate, TicketReservationRequest.Quantity,
                    UnitPrice, DiscountPct, UnitPriceIncludesVat, UnitPriceVatPercentage);
                PriceCalculation.SetTicketAdmissionDynamicUnitPrice(TicketReservationRequest, AdmScheduleEntry, UnitPrice, DiscountPct, UnitPriceIncludesVat, UnitPriceVatPercentage, LocalDateTime);
                PriceUpdated := true;
            end;
        end;

        exit(PriceUpdated);
    end;

    local procedure AggregateTicketPriceDetails(TicketReservationRequest: Record "NPR TM Ticket Reservation Req."; TicketPriceDict: Dictionary of [Integer, Dictionary of [Integer, Decimal]])
    var
        TicketPriceDetails: Dictionary of [Integer, Decimal];
    begin
        if (not TicketPriceDict.ContainsKey(TicketReservationRequest."Ext. Line Reference No.")) then begin
            TicketPriceDetails.Set(1, TicketReservationRequest.UnitAmount);
            TicketPriceDetails.Set(2, TicketReservationRequest.UnitAmountInclVat);
            TicketPriceDict.Set(TicketReservationRequest."Ext. Line Reference No.", TicketPriceDetails);
        end else begin
            TicketPriceDict.Get(TicketReservationRequest."Ext. Line Reference No.", TicketPriceDetails);
            TicketPriceDetails.Set(1, (TicketPriceDetails.Get(1) + TicketReservationRequest.UnitAmount));
            TicketPriceDetails.Set(2, (TicketPriceDetails.Get(2) + TicketReservationRequest.UnitAmountInclVat));
        end;
    end;

    local procedure _IssueOneTicket(ItemNo: Code[20]; VariantCode: Code[10]; QuantityPerTicket: Integer; TicketType: Record "NPR TM Ticket Type"; ReservationRequest: Record "NPR TM Ticket Reservation Req."; var OverAllocationConfirmed: Dictionary of [Code[20], Enum "NPR TM Ternary"])
    var
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        LowDate: Date;
        HighDate: Date;
        ScheduleSelectionError: Label 'Ticket is not valid for selected schedule. Ticket is valid until %1 but you have selected a schedule on %2';
    begin

        if (ReservationRequest."Primary Request Line") then begin
            InsertTicket(ItemNo, VariantCode, TicketType, ReservationRequest, Ticket, TicketManagement);
        end else begin
            FindTicketByToken(Ticket, ReservationRequest."Session Token ID", ReservationRequest."Admission Code", true, ReservationRequest."Ext. Line Reference No.");
        end;

        _IssueAdmissionsAppendToTicket(Ticket, QuantityPerTicket, ReservationRequest, OverAllocationConfirmed);

        TicketManagement.GetTicketAccessEntryValidDateBoundary(Ticket, LowDate, HighDate);
        if (HighDate > Ticket."Valid To Date") then
            Error(ScheduleSelectionError, Ticket."Valid To Date", HighDate);

    end;

    local procedure _IssueAdmissionsAppendToTicket(Ticket: Record "NPR TM Ticket"; QuantityPerTicket: Integer; ReservationRequest: Record "NPR TM Ticket Reservation Req."; var OverAllocationConfirmed: Dictionary of [Code[20], Enum "NPR TM Ternary"])
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        AdmissionOverAllocationConfirmed: Enum "NPR TM Ternary";
    begin
        // Create Ticket Content
        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBom.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        if (ReservationRequest."Admission Code" <> '') then
            TicketBom.SetFilter("Admission Code", '=%1', ReservationRequest."Admission Code");
        if (TicketBom.FindSet()) then begin

            ValidateTicketBomSalesDateLimit(TicketBom, QuantityPerTicket, Today);
            repeat

                if (not OverAllocationConfirmed.ContainsKey(TicketBom."Admission Code")) then begin
                    OverAllocationConfirmed.Add(TicketBom."Admission Code", Enum::"NPR TM Ternary"::TERNARY_FALSE);
                    if (TicketBom."POS Sale May Exceed Capacity") then
                        OverAllocationConfirmed.Set(TicketBom."Admission Code", Enum::"NPR TM Ternary"::TERNARY_UNKNOWN)
                end;

                OverAllocationConfirmed.Get(TicketBom."Admission Code", AdmissionOverAllocationConfirmed);

                _IssueOneAdmission(ReservationRequest, Ticket, TicketBom."Admission Code", QuantityPerTicket, true, AdmissionOverAllocationConfirmed);
                OverAllocationConfirmed.Set(TicketBom."Admission Code", AdmissionOverAllocationConfirmed);

            until (TicketBom.Next() = 0);
        end;
    end;

    local procedure _IssueOneAdmission(SourceRequest: Record "NPR TM Ticket Reservation Req."; Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; QuantityPerTicket: Integer; ValidateWaitinglistReference: Boolean; var AdmissionOverAllocationConfirmed: Enum "NPR TM Ternary")
    var
        AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        WaitingListReferenceCode: Code[10];
        CreateAdmission: Boolean;
        DateTimeLbl: Label '%1 - %2', Locked = true;
    begin

        Clear(AdmissionSchEntry);

        Admission.Get(AdmissionCode);
        TicketBom.Get(Ticket."Item No.", Ticket."Variant Code", AdmissionCode);
        CreateAdmission := (TicketBom."Admission Inclusion" <> TicketBom."Admission Inclusion"::NOT_SELECTED);
        if (TicketBom."Admission Inclusion" <> TicketBom."Admission Inclusion"::REQUIRED) then
            Admission.TestField("Additional Experience Item No.");

        // Lets see if (there is a specific request for the admission code,) then it might carry some additional scheduling information
        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetLoadFields("Session Token ID", "Ext. Line Reference No.", "Item No.", "Variant Code", "Admission Code", "External Adm. Sch. Entry No.", "Scheduled Time Description", "Admission Created", "Request Status", "Admission Description", "Expires Date Time", "Waiting List Reference Code", "Admission Inclusion");
        ReservationRequest.SetFilter("Session Token ID", '=%1', SourceRequest."Session Token ID");
        ReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', SourceRequest."Ext. Line Reference No.");
        ReservationRequest.SetFilter("Item No.", '=%1', Ticket."Item No.");
        ReservationRequest.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        ReservationRequest.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (ReservationRequest.FindFirst()) then begin

            WaitingListReferenceCode := ReservationRequest."Waiting List Reference Code";

            // Does the request carry schedule info for this admission?
            if (ReservationRequest."External Adm. Sch. Entry No." <> 0) then begin
                AdmissionSchEntry.SetCurrentKey("External Schedule Entry No.");
                AdmissionSchEntry.SetFilter("External Schedule Entry No.", '=%1', ReservationRequest."External Adm. Sch. Entry No.");
                AdmissionSchEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionSchEntry.FindFirst()) then begin

                    if (AdmissionSchEntry."Admission Code" <> AdmissionCode) then
                        Error(WRONG_SCH_ENTRY, ReservationRequest."External Adm. Sch. Entry No.", AdmissionCode);

                    ReservationRequest."Scheduled Time Description" := StrSubstNo(DateTimeLbl, AdmissionSchEntry."Admission Start Date", AdmissionSchEntry."Admission Start Time");
                end;
            end;

            ReservationRequest."Admission Created" := (ReservationRequest."Admission Inclusion" <> ReservationRequest."Admission Inclusion"::NOT_SELECTED);
            CreateAdmission := ReservationRequest."Admission Created";
            ReservationRequest."Request Status" := ReservationRequest."Request Status"::REGISTERED;
            ReservationRequest."Admission Description" := Admission.Description;
            ReservationRequest."Expires Date Time" := CalculateNewExpireTime();
            ReservationRequest.Modify();

        end else begin

            WaitingListReferenceCode := SourceRequest."Waiting List Reference Code";

            // Does the source requests schedule info apply to this admission?
            if (SourceRequest."External Adm. Sch. Entry No." <> 0) then begin
                AdmissionSchEntry.SetCurrentKey("External Schedule Entry No.");
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
            ValidateWaitingListReferenceCode(WaitingListReferenceCode, Ticket, Admission."Admission Code", AdmissionSchEntry);

        TicketManagement.CreateAdmissionAccessEntry(Ticket, QuantityPerTicket * TicketBom.Quantity, AdmissionCode, AdmissionSchEntry, AdmissionOverAllocationConfirmed);
    end;

    local procedure ValidateWaitingListReferenceCode(WaitingListReferenceCode: Code[10]; Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; var AdmissionSchEntry: Record "NPR TM Admis. Schedule Entry")
    var
        AdmissionSchEntryWaitingList: Record "NPR TM Admis. Schedule Entry";
        TicketWaitingList: Record "NPR TM Ticket Wait. List";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketWaitingListMgr: Codeunit "NPR TM Ticket WaitingList Mgr.";
        ResponseMessage: Text;
    begin

        if (AdmissionSchEntry."Entry No." <= 0) then
            if (not AdmissionSchEntry.Get(TicketManagement.GetCurrentScheduleEntry(Ticket, AdmissionCode, false))) then
                exit; // No default schedule - let someone else worry about that

        if (AdmissionSchEntry."Allocation By" = AdmissionSchEntry."Allocation By"::CAPACITY) then
            exit; // Normal

        if (WaitingListReferenceCode = '') then
            RaiseError(WAITINGLIST_REQUIRED_1202, '-1202');

        if (not TicketWaitingListMgr.GetWaitingListAdmSchEntry(WaitingListReferenceCode, CreateDateTime(Today, Time), true, AdmissionSchEntryWaitingList, TicketWaitingList, ResponseMessage)) then
            Error(ResponseMessage);

    end;

    local procedure ValidateTicketBomSalesDateLimit(TicketBom: Record "NPR TM Ticket Admission BOM"; Quantity: Integer; ReferenceDate: Date)
    begin

        if ((TicketBom.Default) and (Quantity > 0)) then begin

            if ((TicketBom."Sales From Date" <> 0D) and (ReferenceDate < TicketBom."Sales From Date")) then
                RaiseError(StrSubstNo(SALES_NOT_STARTED_1200, TicketBom."Sales From Date", TicketBom."Admission Code", TicketBom."Item No.", TicketBom."Variant Code"), '-1200');

            if ((TicketBom."Sales Until Date" <> 0D) and (ReferenceDate > TicketBom."Sales Until Date")) then
                RaiseError(StrSubstNo(SALES_STOPPED_1201, TicketBom."Sales Until Date", TicketBom."Admission Code", TicketBom."Item No.", TicketBom."Variant Code"), '-1201');

        end;

    end;

    local procedure FinalizePayment(Token: Text[100]; TokenLineNumber: Integer)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        EntryNos: List of [Integer];
        EntryNo: Integer;
    begin
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TokenLineNumber <> 0) then
            TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TokenLineNumber);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);

        TicketReservationRequest.SetFilter("Admission Inclusion", '=%1', TicketReservationRequest."Admission Inclusion"::REQUIRED);
        TicketReservationRequest.FindSet();
        repeat
            if (TicketReservationRequest.Default) then
                SwitchTicketReservationEntryNo(TicketReservationRequest);

            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (Ticket.FindSet()) then begin
                EntryNos.Add(Ticket."Ticket Reservation Entry No.");
                repeat

                    if (TicketReservationRequest."Payment Option" <> TicketReservationRequest."Payment Option"::UNPAID) then
                        TicketManagement.CreatePaymentEntryType(Ticket, TicketReservationRequest."Payment Option", TicketReservationRequest."External Order No.", TicketReservationRequest."Customer No.");

                until (Ticket.Next() = 0);
            end;
        until (TicketReservationRequest.Next() = 0);

        TicketReservationRequest.SetFilter("Admission Inclusion", '=%1', TicketReservationRequest."Admission Inclusion"::SELECTED);
        if TicketReservationRequest.FindSet() then
            repeat
                foreach EntryNo in EntryNos do begin
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', EntryNo);
                    if (Ticket.FindSet()) then begin
                        repeat
                            if (TicketReservationRequest."Payment Option" <> TicketReservationRequest."Payment Option"::UNPAID) then
                                TicketManagement.CreatePaymentEntryType(Ticket, TicketReservationRequest."Payment Option", TicketReservationRequest."External Order No.", TicketReservationRequest."Customer No.", TicketReservationRequest."Admission Code");

                        until (Ticket.Next() = 0);
                    end;
                end;
            until (TicketReservationRequest.Next() = 0);
    end;

    procedure ConfirmReservationRequest(Token: Text[100]; var ResponseMessage: Text) ReservationConfirmed: Boolean
    var
        ResponseCode: Code[10];
    begin
        exit(ConfirmReservationRequest(Token, 0, ResponseCode, ResponseMessage));
    end;

    internal procedure ConfirmReservationRequest(Token: Text[100]; TokenLineNumber: Integer; var ResponseCode: Code[10]; var ResponseMessage: Text) ReservationConfirmed: Boolean
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        if (_FeatureFlagManagement.IsEnabled('enableTriStateLockingFeaturesInTicketModule')) then
            exit(ConfirmReservationRequestV2(Token, TokenLineNumber, ResponseCode, ResponseMessage));
#endif
        exit(ConfirmReservationRequestV1(Token, TokenLineNumber, ResponseCode, ResponseMessage));
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure ConfirmReservationRequestV1(Token: Text[100]; TokenLineNumber: Integer; var ResponseCode: Code[10]; var ResponseMessage: Text) ReservationConfirmed: Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
    begin

        ReservationConfirmed := true;
        ResponseMessage := '';

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TokenLineNumber <> 0) then
            TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TokenLineNumber);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::EXPIRED);
        if (not TicketReservationRequest.IsEmpty()) then begin
            ResponseMessage := StrSubstNo(TOKEN_EXPIRED_1204, Token);
            ResponseCode := '-1204';
            ReservationConfirmed := false;
        end;

        if (ReservationConfirmed) then begin
            TicketReservationRequest.SetFilter("Request Status", '=%1|=%2', TicketReservationRequest."Request Status"::REGISTERED, TicketReservationRequest."Request Status"::RESERVED);
            if (not TicketReservationRequest.FindSet()) then begin
                ResponseMessage := StrSubstNo(UNCONFIRMED_TOKEN_NOT_FOUND_1203, Token);
                ResponseCode := '-1203';
                ReservationConfirmed := false;
            end;
        end;

        if (not ReservationConfirmed) then
            EmitMessageToTelemetry(ResponseMessage);

        // Update the response object
        TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
        if (TokenLineNumber <> 0) then
            TicketReservationResponse.SetFilter("Ext. Line Reference No.", '=%1', TokenLineNumber);
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
        if (TokenLineNumber <> 0) then
            TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TokenLineNumber);
        TicketReservationRequest.SetFilter("Request Status", '=%1|=%2', TicketReservationRequest."Request Status"::REGISTERED, TicketReservationRequest."Request Status"::RESERVED);

        // Filter only on Required and Selected
        TicketReservationRequest.SetFilter("Admission Inclusion", '=%1|=%2', TicketReservationRequest."Admission Inclusion"::REQUIRED, TicketReservationRequest."Admission Inclusion"::SELECTED);
        TicketReservationRequest.ModifyAll("Request Status", TicketReservationRequest."Request Status"::CONFIRMED);
        TicketReservationRequest.ModifyAll("Request Status Date Time", CurrentDateTime());
        TicketReservationRequest.ModifyAll("Expires Date Time", CreateDateTime(0D, 0T));

        // Filter only on not Selected
        TicketReservationRequest.SetFilter("Admission Inclusion", '=%1', TicketReservationRequest."Admission Inclusion"::NOT_SELECTED);
        TicketReservationRequest.ModifyAll("Request Status", TicketReservationRequest."Request Status"::OPTIONAL);
        TicketReservationRequest.ModifyAll("Request Status Date Time", CurrentDateTime);
        TicketReservationRequest.ModifyAll("Expires Date Time", CreateDateTime(0D, 0T));

        FinalizePayment(Token, TokenLineNumber);

        exit(true);
    end;

    // BC22 and later
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    [CommitBehavior(CommitBehavior::Error)]
    local procedure ConfirmReservationRequestV2(Token: Text[100]; TokenLineNumber: Integer; var ResponseCode: Code[10]; var ResponseMessage: Text) FinalizeReservation: Boolean
    var
        TicketReservationRequest, TicketReservationRequestRead : Record "NPR TM Ticket Reservation Req.";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        Now: DateTime;
        RequestMutex: Record "NPR TM TicketRequestMutex";
        MutexKey: Text[100];
    begin
        Now := CurrentDateTime();
        FinalizeReservation := true;
        ResponseMessage := '';

        // Check if expired
        if (FinalizeReservation) then begin
            TicketReservationRequestRead.ReadIsolation := IsolationLevel::ReadUncommitted;
            TicketReservationRequestRead.SetLoadFields("Session Token ID", "Ext. Line Reference No.", "Request Status", "Admission Inclusion");
            TicketReservationRequestRead.SetCurrentKey("Session Token ID");
            TicketReservationRequestRead.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationRequestRead.SetFilter("Request Status", '=%1', TicketReservationRequestRead."Request Status"::EXPIRED);
            if (TokenLineNumber <> 0) then
                TicketReservationRequestRead.SetFilter("Ext. Line Reference No.", '=%1', TokenLineNumber);
            if (TicketReservationRequestRead.FindFirst()) then begin
                ResponseMessage := StrSubstNo(TOKEN_EXPIRED_1204, Token);
                ResponseCode := '-1204';
                FinalizeReservation := false;
            end;
        end;

        // Check if REGISTERED or RESERVED exists
        if (FinalizeReservation) then begin
            TicketReservationRequestRead.SetFilter("Request Status", '=%1|=%2', TicketReservationRequestRead."Request Status"::REGISTERED, TicketReservationRequestRead."Request Status"::RESERVED);
            if (not TicketReservationRequestRead.FindFirst()) then begin
                ResponseMessage := StrSubstNo(UNCONFIRMED_TOKEN_NOT_FOUND_1203, Token);
                ResponseCode := '-1203';
                FinalizeReservation := false;
            end;
        end;

        // Check if already CONFIRMED
        if (not FinalizeReservation) then begin
            TicketReservationRequestRead.SetFilter("Request Status", '<>%1', TicketReservationRequestRead."Request Status"::CONFIRMED);
            TicketReservationRequestRead.SetFilter("Admission Inclusion", '=%1|=%2', TicketReservationRequestRead."Admission Inclusion"::REQUIRED, TicketReservationRequestRead."Admission Inclusion"::SELECTED);
            if (not TicketReservationRequestRead.FindFirst()) then begin
                ResponseMessage := StrSubstNo(TOKEN_ALREADY_CONFIRMED_1206, Token);
                ResponseCode := '-1206';
                exit(true);
            end;
        end;

        if (FinalizeReservation) then begin
            // ##### Success path #####

            MutexKey := StrSubstNo('%1:%2', Token, TokenLineNumber);
            if (not RequestMutex.Acquire(MutexKey, SessionId())) then begin
                ResponseMessage := StrSubstNo(TOKEN_PROCESSING_CONFLICT_1205);
                ResponseCode := '-1205';
                FinalizeReservation := false;
            end;

            if (FinalizeReservation) then begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.ReadIsolation := IsolationLevel::UpdLock;
                TicketReservationRequest.SetCurrentKey("Session Token ID");
                TicketReservationRequest.SetLoadFields("Session Token ID", "Ext. Line Reference No.", "Request Status", "Admission Inclusion", "Payment Option");
                TicketReservationRequest.SetCurrentKey("Session Token ID");
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                if (TokenLineNumber <> 0) then
                    TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TokenLineNumber);
                TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::RESERVED);
                if (TicketReservationRequest.FindSet()) then
                    repeat
                        TicketReservationRequest."Payment Option" := TicketReservationRequest."Payment Option"::DIRECT;
                        TicketReservationRequest.Modify();
                    until (TicketReservationRequest.Next()) = 0;

                // Confirm required and selected admissions
                TicketReservationRequest.Reset();
                TicketReservationRequest.ReadIsolation := IsolationLevel::UpdLock;
                TicketReservationRequest.SetCurrentKey("Session Token ID");
                TicketReservationRequest.SetLoadFields("Session Token ID", "Ext. Line Reference No.", "Request Status", "Admission Inclusion", "Request Status Date Time", "Expires Date Time");
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                if (TokenLineNumber <> 0) then
                    TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TokenLineNumber);
                TicketReservationRequest.SetFilter("Request Status", '=%1|=%2', TicketReservationRequest."Request Status"::REGISTERED, TicketReservationRequest."Request Status"::RESERVED);
                TicketReservationRequest.SetFilter("Admission Inclusion", '=%1|=%2', TicketReservationRequest."Admission Inclusion"::REQUIRED, TicketReservationRequest."Admission Inclusion"::SELECTED);
                if (TicketReservationRequest.FindSet()) then
                    repeat
                        TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::CONFIRMED;
                        TicketReservationRequest."Request Status Date Time" := Now;
                        TicketReservationRequest."Expires Date Time" := CreateDateTime(0D, 0T);
                        TicketReservationRequest.Modify();
                    until (TicketReservationRequest.Next()) = 0;

                // Set OPTIONAL for not selected
                TicketReservationRequest.Reset();
                TicketReservationRequest.ReadIsolation := IsolationLevel::UpdLock;
                TicketReservationRequest.SetCurrentKey("Session Token ID");
                TicketReservationRequest.SetLoadFields("Session Token ID", "Ext. Line Reference No.", "Request Status", "Admission Inclusion", "Request Status Date Time", "Expires Date Time");
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                if (TokenLineNumber <> 0) then
                    TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TokenLineNumber);
                TicketReservationRequest.SetFilter("Request Status", '=%1|=%2', TicketReservationRequest."Request Status"::REGISTERED, TicketReservationRequest."Request Status"::RESERVED);
                TicketReservationRequest.SetFilter("Admission Inclusion", '=%1', TicketReservationRequest."Admission Inclusion"::NOT_SELECTED);
                if (TicketReservationRequest.FindSet()) then
                    repeat
                        TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::OPTIONAL;
                        TicketReservationRequest."Request Status Date Time" := Now;
                        TicketReservationRequest."Expires Date Time" := CreateDateTime(0D, 0T);
                        TicketReservationRequest.Modify();
                    until (TicketReservationRequest.Next() = 0);

                FinalizePayment(Token, TokenLineNumber);
                RequestMutex.Release(MutexKey);

                ResponseCode := '';
                ResponseMessage := 'OK';
            end;
        end;

        // Update response object with status and message
        // (Somewhat legacy - used by SOAP)
        TicketReservationResponse.ReadIsolation := IsolationLevel::UpdLock;
        TicketReservationResponse.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
        if (TokenLineNumber <> 0) then
            TicketReservationResponse.SetFilter("Ext. Line Reference No.", '=%1', TokenLineNumber);
        if (TicketReservationResponse.FindSet()) then
            repeat
                TicketReservationResponse.Status := FinalizeReservation;
                TicketReservationResponse.Confirmed := FinalizeReservation;
                TicketReservationResponse."Response Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketReservationResponse."Response Message"));
                TicketReservationResponse.Modify();
            until (TicketReservationResponse.Next()) = 0;

        if (not FinalizeReservation) then
            EmitMessageToTelemetry(ResponseMessage);

        exit(FinalizeReservation);
    end;
#endif


    local procedure EmitMessageToTelemetry(MessageText: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin
        if (not ActiveSession.Get(ServiceInstanceId(), SessionId())) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");

        Session.LogMessage('NPR_TM_RequestManager', MessageText, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    procedure ConfirmReservationRequestWithValidate(Token: Text[100])
    var
        ResponseMessage: Text;
    begin
        if (not ConfirmReservationRequest(Token, ResponseMessage)) then
            Error(ResponseMessage);
    end;

    procedure ConfirmReservationRequestWithValidate(Token: Text[100]; TokenLineNumber: Integer)
    var
        ResponseMessage: Text;
        ResponseCode: Code[10];
    begin
        if (not ConfirmReservationRequest(Token, TokenLineNumber, ResponseCode, ResponseMessage)) then
            RaiseError(ResponseMessage, ResponseCode);
    end;

    procedure ConfirmChangeRequest(Token: Text[100]);
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        DateTimeLbl: Label '%1 - %2', Locked = true;
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FindSet();
        repeat
            TicketReservationRequest."Request Status Date Time" := CurrentDateTime();
            TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::CONFIRMED;
            TicketReservationRequest."Admission Created" := (TicketReservationRequest."Admission Inclusion" <> TicketReservationRequest."Admission Inclusion"::NOT_SELECTED);
            TicketReservationRequest."Scheduled Time Description" := '';
            if (TicketReservationRequest."External Adm. Sch. Entry No." <> 0) then begin
                AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest."External Adm. Sch. Entry No.");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionScheduleEntry.FindLast()) then
                    TicketReservationRequest."Scheduled Time Description" := StrSubstNo(DateTimeLbl, AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
            end;
            TicketReservationRequest.Modify();

        until (TicketReservationRequest.Next() = 0);

        OnAfterConfirmTicketChangeRequestPublisher(Token);

    end;

    procedure ConfirmChangeRequestDynamicTicket(Token: Text[100]);
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        DateTimeLbl: Label '%1 - %2', Locked = true;
    begin

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter(Quantity, '<>0');
        TicketReservationRequest.FindSet();
        repeat
            TicketReservationRequest."Request Status Date Time" := CurrentDateTime();
            TicketReservationRequest."Admission Created" := (TicketReservationRequest."Admission Inclusion" <> TicketReservationRequest."Admission Inclusion"::NOT_SELECTED);
            TicketReservationRequest."Scheduled Time Description" := '';
            if (TicketReservationRequest."External Adm. Sch. Entry No." <> 0) then begin
                AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketReservationRequest."External Adm. Sch. Entry No.");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionScheduleEntry.FindLast()) then
                    TicketReservationRequest."Scheduled Time Description" := StrSubstNo(DateTimeLbl, AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
            end;
            TicketReservationRequest.Modify();

        until (TicketReservationRequest.Next() = 0);

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

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    procedure DeleteReservationTokenRequestV2(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        // Cancel a ticket request by deleting it - possible when it has not yet been confirmed.
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FindSet();

        DeleteReservationRequestV2(TicketReservationRequest."Session Token ID", true);
    end;
#endif

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

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure ExpireReservationRequestsV2(): Integer
    begin
        exit(ExpireReservationRequestsV2(30));
    end;

    [CommitBehavior(CommitBehavior::Error)]
    internal procedure ExpireReservationRequestsV2(MaxNumberOfTokensPerSession: Integer): Integer
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        RequestMutex: Record "NPR TM TicketRequestMutex";
        ExpiredTokens, DeletedTokens : List of [Text[100]];
        Token: Text[100];
        MySessionId: Integer;
    begin
        if (MaxNumberOfTokensPerSession <= 0) then
            MaxNumberOfTokensPerSession := 30;

        MySessionId := SessionId();

        // Scan REGISTERED and expire tokens that are older than X minutes
        TicketReservationRequest.Reset();
        TicketReservationRequest.ReadIsolation := IsolationLevel::ReadUnCommitted;
        TicketReservationRequest.SetLoadFields("Session Token ID", "Request Status", "Expires Date Time");
        TicketReservationRequest.SetCurrentKey("Request Status", "Expires Date Time");
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::REGISTERED);
        TicketReservationRequest.SetFilter("Expires Date Time", '>%1 & <%2', CreateDateTime(0D, 0T), CurrentDateTime());
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);

        if (TicketReservationRequest.FindSet()) then
            repeat
                Token := TicketReservationRequest."Session Token ID";
                if (not ExpiredTokens.Contains(Token)) then
                    if (RequestMutex.Acquire(Token, MySessionId)) then
                        ExpiredTokens.Add(Token);
            until (TicketReservationRequest.Next() = 0) or (ExpiredTokens.Count() >= MaxNumberOfTokensPerSession);

        foreach Token in ExpiredTokens do
            DeleteReservationRequestV2(Token, false);

        // Scan EXPIRED and delete tokens that are older than X minutes
        if (ExpiredTokens.Count() < MaxNumberOfTokensPerSession) then begin
            TicketReservationRequest.Reset();
            TicketReservationRequest.ReadIsolation := IsolationLevel::ReadUnCommitted;
            TicketReservationRequest.SetLoadFields("Session Token ID", "Request Status", "Expires Date Time");
            TicketReservationRequest.SetCurrentKey("Request Status", "Expires Date Time");
            TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::EXPIRED);
            TicketReservationRequest.SetFilter("Expires Date Time", '>%1 & <%2', CreateDateTime(0D, 0T), CurrentDateTime());

            if (TicketReservationRequest.FindSet()) then
                repeat
                    Token := TicketReservationRequest."Session Token ID";
                    if (not DeletedTokens.Contains(Token)) then
                        if (RequestMutex.Acquire(Token, MySessionId)) then
                            DeletedTokens.Add(Token);

                until (TicketReservationRequest.Next() = 0) or (DeletedTokens.Count() + ExpiredTokens.Count() >= MaxNumberOfTokensPerSession);

            foreach Token in DeletedTokens do
                DeleteReservationRequestV2(Token, true);
        end;

        // Client up the mutex table
        foreach Token in ExpiredTokens do
            if (RequestMutex.Get(Token)) then
                RequestMutex.Delete();

        foreach Token in DeletedTokens do
            if (RequestMutex.Get(Token)) then
                RequestMutex.Delete();

        if (ExpiredTokens.Count() + DeletedTokens.Count() > 0) then begin
            if (ExpiredTokens.Count() + DeletedTokens.Count() >= MaxNumberOfTokensPerSession) then
                EmitExpiryMessageToTelemetry(StrSubstNo('Reservation Request Expiry: was capped by max number to handle per session: %1, expired: %2, deleted: %3.', MaxNumberOfTokensPerSession, ExpiredTokens.Count(), DeletedTokens.Count()), Verbosity::Warning)
            else
                EmitExpiryMessageToTelemetry(StrSubstNo('Reservation Request Expiry: expired: %1, deleted: %2.', ExpiredTokens.Count(), DeletedTokens.Count()), Verbosity::Normal);
        end;

        exit(ExpiredTokens.Count() + DeletedTokens.Count());
    end;

    local procedure EmitExpiryMessageToTelemetry(MessageText: Text; MsgVerbosity: Verbosity)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin
        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");

        Session.LogMessage('NPR_TM_TicketRequestExpiry', MessageText, MsgVerbosity, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;
#endif

    procedure ExpireReservationRequests()
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        if (_FeatureFlagManagement.IsEnabled('enableTriStateLockingFeaturesInTicketModule')) then begin
            ExpireReservationRequestsV2(30);
            exit;
        end;
#endif
        ExpireReservationRequestsV1();
    end;

    local procedure ExpireReservationRequestsV1()
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
    begin

        // Performance enhancement
        TicketReservationRequest.SetCurrentKey("Request Status");
        TicketReservationRequest.SetFilter("Expires Date Time", '>%1 & <%2', CreateDateTime(0D, 0T), CurrentDateTime());
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::REGISTERED);
        if (not TicketReservationRequest.IsEmpty()) then begin
            LockResources('ExpireReservationRequests-1');
            if (TicketReservationRequest.FindSet()) then begin
                repeat
                    DeleteReservationRequest(TicketReservationRequest."Session Token ID", false);

                    TicketReservationRequest2.SetCurrentKey("Session Token ID");
                    TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
                    TicketReservationRequest2.ModifyAll("Request Status", TicketReservationRequest2."Request Status"::EXPIRED);

                    if (TicketReservationRequest."Revoke Ticket Request") then begin
                        TicketReservationRequest2.ModifyAll("Expires Date Time", CurrentDateTime() - 10 * 1000); // Revoke transactions will not be retained when it has expired
                    end else begin
                        TicketReservationRequest2.ModifyAll("Expires Date Time", CurrentDateTime() + 3600 * 1000); // Expired transactions will be retained 1 hour
                    end;

                until (TicketReservationRequest.Next() = 0);

                Commit();
                LockResources('ExpireReservationRequests-1a');
            end;
        end;

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Request Status");
        TicketReservationRequest.SetFilter("Expires Date Time", '>%1 & <%2', CreateDateTime(0D, 0T), CurrentDateTime());
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::EXPIRED);
        if (not TicketReservationRequest.IsEmpty()) then begin
            LockResources('ExpireReservationRequests-2');
            if (TicketReservationRequest.FindSet()) then begin
                repeat
                    DeleteReservationRequest(TicketReservationRequest."Session Token ID", true);
                until (TicketReservationRequest.Next() = 0);

                Commit();
                LockResources('ExpireReservationRequests-2a');
            end;
        end;
    end;

    procedure RegisterArrivalRequest(Token: Text[100]; PosUnitNo: Code[10])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TOKEN_NOT_FOUND: Label 'The ticket-token %1 with status confirmed, was not found.';
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);

        if (not (TicketReservationRequest.FindSet())) then begin
            EmitMessageToTelemetry(StrSubstNo(TOKEN_NOT_FOUND, Token));
            Error(TOKEN_NOT_FOUND, Token);
        end;

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
                        TicketManagement.RegisterArrivalScanTicket("NPR TM TicketIdentifierType"::INTERNAL_TICKET_NO, Ticket."No.", TicketReservationRequest2."Admission Code", TicketReservationRequest2."External Adm. Sch. Entry No.", PosUnitNo, '', false);
                    until (TicketReservationRequest2.Next() = 0);

                until (Ticket.Next() = 0);
            end;

        until (TicketReservationRequest.Next() = 0);

    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure UpdateReservationQuantity(Token: Text[100]; Quantity: Integer)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        ChangeQuantityNotPossible: Label 'Quantity for configurable tickets must be changed in the edit ticket reservation page.';
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
        TicketReservationRequest.SetFilter("Admission Inclusion", '=%1|=%2', TicketReservationRequest."Admission Inclusion"::SELECTED, TicketReservationRequest."Admission Inclusion"::NOT_SELECTED);
        if (not TicketReservationRequest.IsEmpty()) then
            Error(ChangeQuantityNotPossible);

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
                ResolvingTable := Database::Item;
                ItemNo := Item."No.";
                exit(true);
            end;
        end;

        if (StrLen(Barcode) <= MaxStrLen(ItemReference."Reference No.")) then begin
            ItemReference.SetCurrentKey("Reference Type", "Reference No.");
            ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetFilter("Reference No.", '=%1', UpperCase(Barcode));
            if (ItemReference.FindFirst()) then begin
                ResolvingTable := Database::"Item Reference";
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
        DateTimeLbl: Label '%1-%2', Locked = true;
    begin

        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNo);
        Ticket.SetFilter(Blocked, '=%1', false);
        if (not Ticket.FindFirst()) then begin
            ResponseMessage := INVALID_TICKET_PIN;
            exit(false);
        end;

        if (not TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then begin
            ResponseMessage := INVALID_TICKET_PIN;
            exit(false);
        end;

        if (TicketReservationRequest."Authorization Code" <> AuthorizationCode) then begin
            ResponseMessage := INVALID_TICKET_PIN;
            exit(false);
        end;

        TicketReservationRequest.CalcFields("Is Superseeded");
        repeat
            if (TicketReservationRequest."Is Superseeded") then begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetFilter("Superseeds Entry No.", '=%1', TicketReservationRequest."Entry No.");
                TicketReservationRequest.FindFirst();
                TicketReservationRequest.CalcFields("Is Superseeded");
            end;
        until (not TicketReservationRequest."Is Superseeded");

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
        TicketReservationRequest.SetFilter("Admission Inclusion", '%1|%2', TicketReservationRequest."Admission Inclusion"::REQUIRED, TicketReservationRequest."Admission Inclusion"::SELECTED);
        if (not TicketReservationRequest.FindSet()) then begin
            ResponseMessage := 'Houston, - we have a problem with ticket request table integrity.';
            exit(false);
        end;

        if ((TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::PRIMARY) and
            (TicketReservationRequest."Request Status" <> TicketReservationRequest."Request Status"::CONFIRMED)) then begin
            ResponseMessage := NOT_CONFIRMED;
            exit(false);
        end;

        if ((TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::CHANGE) and
            (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::REGISTERED)) then begin
            if ((MessageToken <> TicketReservationRequest."Session Token ID") and (MessageToken <> '')) then begin
                TicketReservationRequest.ModifyAll("Expires Date Time", CalculateNewExpireTime());
                TicketReservationRequest.ModifyAll("Request Status Date Time", CurrentDateTime());
                TicketReservationRequest.ModifyAll("Session Token ID", MessageToken, false); // Multiple change requests - invalidate the previous one
            end;
            if (MessageToken = '') then begin
                TicketReservationRequest.ModifyAll("Expires Date Time", CalculateNewExpireTime());
                MessageToken := TicketReservationRequest."Session Token ID";
            end;
            exit(true);
        end;

        if (MessageToken = '') then
            MessageToken := GetNewToken();

        TicketReservationRequest.SetRange("Admission Inclusion");
        TicketReservationRequest.FindSet();
        repeat
            TicketChangeRequest.TransferFields(TicketReservationRequest, false);
            TicketChangeRequest."Session Token ID" := MessageToken;
            TicketChangeRequest."Entry Type" := TicketChangeRequest."Entry Type"::CHANGE;
            TicketChangeRequest."Created Date Time" := CurrentDateTime();
            TicketChangeRequest."Request Status" := TicketChangeRequest."Request Status"::REGISTERED;
            TicketChangeRequest."Request Status Date Time" := CurrentDateTime();
            TicketChangeRequest."Expires Date Time" := CalculateNewExpireTime();
            TicketChangeRequest."DIY Print Order Requested" := false;
            TicketChangeRequest."DIY Print Order At" := CreateDateTime(0D, 0T);
            TicketChangeRequest."Admission Created" := false;
            TicketChangeRequest."Superseeds Entry No." := Ticket."Ticket Reservation Entry No.";
            TicketChangeRequest."Receipt No." := '';
            TicketChangeRequest."Line No." := 0;

            TicketAccessEntry.SetFilter(TicketAccessEntry."Ticket No.", '=%1', Ticket."No.");
            if (TicketReservationRequest."Admission Code" <> '') then
                TicketAccessEntry.SetFilter("Admission Code", '=%1', TicketChangeRequest."Admission Code");

            if TicketAccessEntry.FindSet() then
                repeat
                    TicketChangeRequest."Entry No." := 0;
                    TicketChangeRequest."Admission Code" := TicketAccessEntry."Admission Code";
                    Admission.Get(TicketChangeRequest."Admission Code");
                    TicketBom.Get(TicketChangeRequest."Item No.", TicketChangeRequest."Variant Code", TicketChangeRequest."Admission Code");
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
                    AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                    AdmissionScheduleEntry.FindLast();
                    TicketChangeRequest."Scheduled Time Description" := StrSubstNo(DateTimeLbl, AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");

                    TicketChangeRequest.Insert();
                until (TicketAccessEntry.Next() = 0);

            if (TicketReservationRequest."Admission Code" = '') then
                exit(true); // either the request is complete with all admission codes, or it is created in lazy mode with just the item

        until (TicketReservationRequest.Next() = 0);

        exit(true);

    end;


    procedure CreateChangeRequestDynamicTicket(ExternalTicketNo: Code[30]; AuthorizationCode: Code[10]; var MessageToken: Text[100]; var ResponseMessage: Text): Boolean;
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketChangeRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        BlankAdmissionCode: Label 'Dynamic Ticket Contents require admission codes for each source ticket request line.';
    begin

        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNo);
        Ticket.SetFilter(Blocked, '=%1', false);
        if (not Ticket.FindFirst()) then begin
            ResponseMessage := INVALID_TICKET_PIN;
            exit(false);
        end;

        if (not TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then begin
            ResponseMessage := INVALID_TICKET_PIN;
            exit(false);
        end;

        if (TicketReservationRequest."Authorization Code" <> AuthorizationCode) then begin
            ResponseMessage := INVALID_TICKET_PIN;
            exit(false);
        end;

        TicketReservationRequest.CalcFields("Is Superseeded");
        repeat
            if (TicketReservationRequest."Is Superseeded") then begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetFilter("Superseeds Entry No.", '=%1', TicketReservationRequest."Entry No.");
                TicketReservationRequest.FindFirst();
                TicketReservationRequest.CalcFields("Is Superseeded");
            end;
        until (not TicketReservationRequest."Is Superseeded");

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
        TicketReservationRequest.SetFilter("Admission Inclusion", '%1|%2', TicketReservationRequest."Admission Inclusion"::REQUIRED, TicketReservationRequest."Admission Inclusion"::SELECTED);
        if (not TicketReservationRequest.FindSet()) then begin
            ResponseMessage := 'Houston, - we have a problem with ticket request table integrity.';
            exit(false);
        end;

        if ((TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::PRIMARY) and
            (TicketReservationRequest."Request Status" <> TicketReservationRequest."Request Status"::CONFIRMED)) then begin
            ResponseMessage := NOT_CONFIRMED;
            exit(false);
        end;

        TicketReservationRequest.SetRange("Admission Inclusion");

        if ((TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::CHANGE) and
            (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::REGISTERED)) then begin
            if ((MessageToken <> TicketReservationRequest."Session Token ID") and (MessageToken <> '')) then begin
                TicketReservationRequest.ModifyAll("Expires Date Time", CalculateNewExpireTime());
                TicketReservationRequest.ModifyAll("Session Token ID", MessageToken, false); // Multiple change requests - invalidate the previous one
            end;
            if (MessageToken = '') then begin
                TicketReservationRequest.ModifyAll("Expires Date Time", CalculateNewExpireTime());
                MessageToken := TicketReservationRequest."Session Token ID";
            end;
            exit(true);
        end;

        if (MessageToken = '') then
            MessageToken := GetNewToken();

        TicketReservationRequest.FindSet();
        repeat
            if (TicketReservationRequest."Admission Code" = '') then
                Error(BlankAdmissionCode);

            TicketChangeRequest.TransferFields(TicketReservationRequest, false);
            if TicketChangeRequest.Quantity <> 0 then
                TicketChangeRequest.Quantity := 1;
            TicketChangeRequest."Session Token ID" := MessageToken;
            TicketChangeRequest."Entry Type" := TicketChangeRequest."Entry Type"::CHANGE;
            TicketChangeRequest."Created Date Time" := CURRENTDATETIME();
            TicketChangeRequest."Request Status" := TicketChangeRequest."Request Status"::WIP;
            TicketChangeRequest."Request Status Date Time" := CURRENTDATETIME();
            TicketChangeRequest."Expires Date Time" := CalculateNewExpireTime();
            TicketChangeRequest."DIY Print Order Requested" := false;
            TicketChangeRequest."DIY Print Order At" := CreateDateTime(0D, 0T);
            TicketChangeRequest."Superseeds Entry No." := Ticket."Ticket Reservation Entry No.";
            TicketChangeRequest."Receipt No." := '';
            TicketChangeRequest."Line No." := 0;

            TicketChangeRequest."Entry No." := 0;
            TicketChangeRequest.Insert();
        until (TicketReservationRequest.Next() = 0);

        exit(true);
    end;

    procedure SetReservationRequestExtraInfo(Token: Text[100]; NotificationAddress: Text[100]; ExternalOrderNo: Code[20]; TicketHolderName: Text[100]; TicketHolderLanguage: Code[10]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.Reset();
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        TicketReservationRequest.ReadIsolation := IsolationLevel::UpdLock;
#endif
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetLoadFields("Request Status", "Receipt No.", "Notification Method", "Notification Address", "Payment Option", "External Order No.", "TicketHolderName", TicketHolderPreferredLanguage);
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

            if ((TicketReservationRequest."Receipt No." = '') and (ExternalOrderNo = '')) then
                TicketReservationRequest."Payment Option" := TicketReservationRequest."Payment Option"::UNPAID;

            if (TicketHolderName <> '') then
                TicketReservationRequest.TicketHolderName := TicketHolderName;

            if (TicketHolderLanguage <> '') then
                TicketReservationRequest.Validate(TicketHolderPreferredLanguage, TicketHolderLanguage);

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
        TicketBom.SetFilter(Default, '=%1', true);
        if (TicketBom.FindSet()) then
            repeat
                POS_AppendToReservationRequest(Token, SalesReceiptNo, SalesLineNo, ItemNo, VariantCode, TicketBom."Admission Code", Quantity, 0, ExternalMemberNo, 0);
            until (TicketBom.Next() = 0);

        TicketBom.SetFilter(Default, '=%1', false);
        if (TicketBom.FindSet()) then
            repeat
                POS_AppendToReservationRequest(Token, SalesReceiptNo, SalesLineNo, ItemNo, VariantCode, TicketBom."Admission Code", Quantity, 0, ExternalMemberNo, 0);
            until (TicketBom.Next() = 0);

        exit(Token);
    end;

    procedure POS_AppendToReservationRequest(Token: Text[100]; SalesReceiptNo: Code[20]; SalesLineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; Quantity: Integer; ExternalAdmissionScheduleEntryNo: Integer; ExternalMemberNo: Code[20]; ExtLineReferenceNo: Integer)
    begin
        POS_AppendToReservationRequest2(Token, SalesReceiptNo, SalesLineNo, ItemNo, VariantCode, AdmissionCode, Quantity, ExternalAdmissionScheduleEntryNo, ExternalMemberNo, '', '', '', ExtLineReferenceNo);
    end;

    procedure POS_AppendToReservationRequest2(Token: Text[100]; SalesReceiptNo: Code[20]; SalesLineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; Quantity: Integer; ExternalAdmissionScheduleEntryNo: Integer; ExternalMemberNo: Code[20]; ExternalOrderNo: Code[20]; CustomerNo: Code[20]; NotificationAddress: Text[100]; ExtLineReferenceNo: Integer)
    var
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Admission: Record "NPR TM Admission";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        AdmSchEntry: Record "NPR TM Admis. Schedule Entry";
        DateTimeLbl: Label '%1 - %2', Locked = true;
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
        ReservationRequest.Default := TicketAdmissionBOM.Default;
        ReservationRequest."External Item Code" := GetExternalNo(ItemNo, VariantCode);
        ReservationRequest."Ext. Line Reference No." := ExtLineReferenceNo;

        ReservationRequest."Item No." := ItemNo;
        ReservationRequest."Variant Code" := VariantCode;

        if ReservationRequest."Admission Inclusion" <> ReservationRequest."Admission Inclusion"::NOT_SELECTED then
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
            case TicketManagement.GetAdmissionSchedule(ItemNo, VariantCode, AdmissionCode) of
                Admission."Default Schedule"::TODAY,
                Admission."Default Schedule"::NEXT_AVAILABLE:
                    begin
                        if (AdmSchEntry.Get(TicketManagement.GetCurrentScheduleEntry(ItemNo, VariantCode, Admission."Admission Code", true, 1))) then begin
                            if (AdmSchEntry."Admission Is" = AdmSchEntry."Admission Is"::OPEN) then begin
                                ReservationRequest."External Adm. Sch. Entry No." := AdmSchEntry."External Schedule Entry No.";
                                ReservationRequest."Scheduled Time Description" := StrSubstNo(DateTimeLbl, AdmSchEntry."Admission Start Date", AdmSchEntry."Admission Start Time");
                            end;
                        end;
                    end;
            end;

        end else begin
            if (ReservationRequest."External Adm. Sch. Entry No." <> ExternalAdmissionScheduleEntryNo) then begin
                ReservationRequest."External Adm. Sch. Entry No." := ExternalAdmissionScheduleEntryNo;
                AdmSchEntry.SetFilter("External Schedule Entry No.", '=%1', ExternalAdmissionScheduleEntryNo);
                AdmSchEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmSchEntry.FindLast()) then
                    ReservationRequest."Scheduled Time Description" := StrSubstNo(DateTimeLbl, AdmSchEntry."Admission Start Date", AdmSchEntry."Admission Start Time");
            end;
        end;

        ReservationRequest."Created Date Time" := CurrentDateTime();
        if (ReservationRequest."Receipt No." <> '') or (ReservationRequest."Ext. Line Reference No." <> 0) then
            ReservationRequest."Request Status" := ReservationRequest."Request Status"::WIP;
        ReservationRequest."Request Status Date Time" := CurrentDateTime();
        ReservationRequest."Expires Date Time" := CalculateNewExpireTime();
        ReservationRequest.Insert();
    end;

    internal procedure POS_CreateRevokeRequest(var Token: Text[100]; TicketNo: Code[20]; SalesReceiptNo: Code[20]; SalesLineNo: Integer; var AmountInOut: Decimal; var RevokeQuantity: Integer): Boolean
    var
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin
        ResponseCode := POS_CreateRevokeRequestWorker(Token, TicketNo, SalesReceiptNo, SalesLineNo, AmountInOut, RevokeQuantity, ResponseMessage);

        if (ResponseCode = 0) then
            exit(false);

        if (ResponseCode < 0) then
            Error(ResponseMessage);

        ResponseMessage := '';
        exit(true);
    end;

    internal procedure POS_CreateRevokeRequest(var Token: Text[100]; TicketNo: Code[20]; SalesReceiptNo: Code[20]; SalesLineNo: Integer; var AmountInOut: Decimal; var RevokeQuantity: Integer; var ResponseMessage: Text): Integer
    begin
        exit(POS_CreateRevokeRequestWorker(Token, TicketNo, SalesReceiptNo, SalesLineNo, AmountInOut, RevokeQuantity, ResponseMessage));
    end;

    local procedure POS_CreateRevokeRequestWorker(var Token: Text[100]; TicketNo: Code[20]; SalesReceiptNo: Code[20]; SalesLineNo: Integer; var AmountInOut: Decimal; var QuantityToRevoke: Integer; var ResponseMessage: Text): Integer
    var
        Ticket: Record "NPR TM Ticket";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        DetTicketAccessEntry2: Record "NPR TM Det. Ticket AccessEntry";

        TotalRefundAmount: Decimal;
        AdmissionRefundAmount: Decimal;
        TotalPct: Decimal;
        UsePctDistribution: Boolean;
        NumberOfAdmissions: Integer;
        PaidQuantity, QuantityPerUnit : Integer;
        UnitPrice: Decimal;
        AlreadyAsked: Boolean;
        AllowRevoke: Boolean;
        TICKET_BLOCKED: Label 'Ticket %1 is blocked.';
        PrimaryRequestLine: Boolean;
        REVOKE_FAIL_BLOCKED, REVOKE_OK, REVOKE_FAIL_CANCEL, REVOKE_FAIL_POLICY : integer;
    begin
        REVOKE_OK := 10;
        REVOKE_FAIL_BLOCKED := 0;
        REVOKE_FAIL_CANCEL := -10;
        REVOKE_FAIL_POLICY := -20;

        Ticket.Get(TicketNo);
        if (Ticket.Blocked) then begin
            ResponseMessage := StrSubstNo(TICKET_BLOCKED, TicketNo);
            exit(REVOKE_FAIL_BLOCKED);
        end;

        if (Token = '') then
            Token := GetNewToken();
        PrimaryRequestLine := true;

#if (BC17 or BC18 or BC19 or BC20 or BC21)
        LockResources('POS_CreateRevokeRequest');
#endif

        TicketBOM.SetFilter("Item No.", '=%1', Ticket."Item No.");
        TicketBOM.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
        TicketBOM.FindSet();
        repeat
            TotalPct += TicketBOM."Refund Price %";
        until (TicketBOM.Next() = 0);
        UsePctDistribution := (TotalPct = 100);

        TicketAccessEntry.Reset();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        NumberOfAdmissions := TicketAccessEntry.Count;

        TicketAccessEntry.FindSet();
        repeat
            TicketBOM.Get(Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code");
            QuantityPerUnit := TicketBOM.Quantity; // TicketBOM.Quantity is the ticket quantity per uom (normally 1)
            if (QuantityPerUnit < 1) then
                QuantityPerUnit := 1;

            AdmissionRefundAmount := 0;
            QuantityToRevoke := TicketAccessEntry.Quantity;

            DetTicketAccessEntry2.Reset();
            DetTicketAccessEntry2.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry2.SetFilter(Type, '=%1|=%2|=%3', DetTicketAccessEntry.Type::PAYMENT, DetTicketAccessEntry.Type::PREPAID, DetTicketAccessEntry.Type::POSTPAID);
            if (DetTicketAccessEntry2.FindFirst()) then
                PaidQuantity := DetTicketAccessEntry2.Quantity;

            if (PaidQuantity = 0) then
                UnitPrice := 0
            else
                UnitPrice := AmountInOut / QuantityPerUnit;

            case TicketBOM."Revoke Policy" of
                TicketBOM."Revoke Policy"::UNUSED:
                    begin

                        DetTicketAccessEntry.Reset();
                        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
                        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
                        if (DetTicketAccessEntry.FindFirst()) then begin

                            if (PaidQuantity = QuantityToRevoke) then begin
                                ResponseMessage := StrSubstNo(REVOKE_UNUSED_ERROR, TicketNo, TicketBOM.Description, DetTicketAccessEntry."Created Datetime", Ticket."Item No.", TicketAccessEntry."Admission Code");
                                exit(REVOKE_FAIL_POLICY);
                            end;

                            // Group tickets will get the non-admitted quantity refunded
                            QuantityToRevoke := PaidQuantity - QuantityToRevoke;
                        end;

                        if (UsePctDistribution) then
                            AdmissionRefundAmount := QuantityToRevoke * UnitPrice * TicketBOM."Refund Price %" / 100;

                        if (not UsePctDistribution) then
                            AdmissionRefundAmount := QuantityToRevoke * UnitPrice / NumberOfAdmissions;

                    end;
                TicketBOM."Revoke Policy"::NEVER:
                    Error(REVOKE_NEVER_ERROR, TicketNo, Ticket."Item No.", TicketAccessEntry."Admission Code");

                TicketBOM."Revoke Policy"::ALWAYS:
                    begin
                        if (UsePctDistribution) then
                            AdmissionRefundAmount := PaidQuantity * UnitPrice * TicketBOM."Refund Price %" / 100;

                        if (not UsePctDistribution) then
                            AdmissionRefundAmount := PaidQuantity * UnitPrice / NumberOfAdmissions;
                    end;
                else
                    Error(INVALID_POLICY, TicketBOM."Revoke Policy");
            end;

            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::CANCELED_ADMISSION);
            if (DetTicketAccessEntry.FindFirst()) then begin
                ResponseMessage := StrSubstNo(TICKET_CANCELLED, TicketNo, DetTicketAccessEntry."Created Datetime");
                exit(REVOKE_FAIL_CANCEL);
            end;

            // Ticket is prepaid by third party
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::PREPAID);
            if (DetTicketAccessEntry.FindFirst()) then begin
                if (AdmissionRefundAmount <> 0) then begin
                    if (not AlreadyAsked) then begin
                        AlreadyAsked := true;
                        AllowRevoke := Confirm(PREPAID_REFUND, false, TicketAccessEntry."Admission Code", DetTicketAccessEntry."Sales Channel No.");
                    end;
                    if (not AllowRevoke) then
                        AdmissionRefundAmount := 0;
                end;
            end;

            // Ticket will be post paid after admission, by claim from us to third party. we will claim ticket if admission was registered.
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::POSTPAID);
            if (DetTicketAccessEntry.FindFirst()) then begin
                if (AdmissionRefundAmount <> 0) then begin
                    if (not AlreadyAsked) then begin
                        AlreadyAsked := true;
                        AllowRevoke := Confirm(POSTPAID_REFUND, false, TicketAccessEntry."Admission Code", DetTicketAccessEntry."Sales Channel No.");
                    end;
                    if (not AllowRevoke) then
                        AdmissionRefundAmount := 0;
                end;
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
            ReservationRequest."Primary Request Line" := PrimaryRequestLine;
            ReservationRequest."Revoke Access Entry No." := TicketAccessEntry."Entry No.";
            ReservationRequest.Quantity := 1;
            ReservationRequest.Amount := AdmissionRefundAmount;
            ReservationRequest."AmountInclVat" := 0; //AdmissionRefundAmount;

            ReservationRequest."External Member No." := Ticket."External Member Card No.";
            ReservationRequest."Admission Description" := TicketBOM."Admission Description";

            ReservationRequest."Created Date Time" := CurrentDateTime();

            ReservationRequest."Request Status" := ReservationRequest."Request Status"::REGISTERED;
            ReservationRequest."Request Status Date Time" := CurrentDateTime();
            ReservationRequest."Expires Date Time" := CalculateNewExpireTime();

            ReservationRequest."Entry Type" := ReservationRequest."Entry Type"::REVOKE;
            ReservationRequest."Superseeds Entry No." := Ticket."Ticket Reservation Entry No.";

            ReservationRequest.Insert();
            PrimaryRequestLine := false;

        until (TicketAccessEntry.Next() = 0);

        QuantityToRevoke := 1;
        AmountInOut := Round(TotalRefundAmount, 0.01);

        exit(REVOKE_OK);
    end;

    procedure WS_CreateRevokeRequest(var Token: Text[100]; TicketNo: Code[20]; AuthorizationCode: Code[10]; VAR AmountInclVatInOut: Decimal; VAR RevokeQuantity: Integer)
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
            Error('Ticket is blocked and cannot be revoked.');

        ReservationRequest.Get(Ticket."Ticket Reservation Entry No.");
        if (ReservationRequest."Authorization Code" <> AuthorizationCode) then
            Error(INVALID_TICKET_PIN);

        ReservationRequest.CalcFields("Is Superseeded");
        if (ReservationRequest."Is Superseeded") then begin
            // Invalidate the other request
            ReservationRequest.SetFilter("Superseeds Entry No.", '=%1', ReservationRequest."Entry No.");
            ReservationRequest.ModifyAll("Request Status", ReservationRequest."Request Status"::CANCELED);
        end;

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
            UnitPrice := AmountInclVatInOut / InitialQuantity;

            CASE TicketBOM."Revoke Policy" OF
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
                            AmountInclVatInOut := UnitPrice * RevokeQuantity;

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
                    AdmissionRefundAmount := AmountInclVatInOut / AdmissionCount;

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
                if (AdmissionRefundAmount <> 0) then begin
                    // Pickup price from sales order - should be referenced in DetTicketAccessEntry."Sales Channel No."
                    // AdmissionRefundAmount := 0;
                    // Default to Unit Price (AmountIn)
                end;
            end;

            // Ticket will be post paid after admission, by claim from us to third party. we will claim ticket if admission was registered.
            DetTicketAccessEntry.Reset();
            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::POSTPAID);
            if (DetTicketAccessEntry.FindFirst()) then begin
                if (AdmissionRefundAmount <> 0) then
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
            ReservationRequest."Receipt No." := '';
            ReservationRequest."Line No." := 0;

            ReservationRequest."External Ticket Number" := Ticket."External Ticket No.";

            ReservationRequest."Revoke Ticket Request" := true;
            ReservationRequest."Revoke Access Entry No." := TicketAccessEntry."Entry No.";
            ReservationRequest.Quantity := RevokeQuantity;
            ReservationRequest.Amount := 0; //AdmissionRefundAmount;
            ReservationRequest."AmountInclVat" := AdmissionRefundAmount;

            ReservationRequest."External Member No." := Ticket."External Member Card No.";
            ReservationRequest."Admission Description" := Admission.Description;

            ReservationRequest."Created Date Time" := CurrentDateTime();

            ReservationRequest."Request Status" := ReservationRequest."Request Status"::REGISTERED;
            ReservationRequest."Request Status Date Time" := CurrentDateTime();
            ReservationRequest."Expires Date Time" := CalculateNewExpireTime();

            ReservationRequest."Entry Type" := ReservationRequest."Entry Type"::REVOKE;
            ReservationRequest."Superseeds Entry No." := Ticket."Ticket Reservation Entry No.";

            ReservationRequest.Insert();

        until (TicketAccessEntry.Next() = 0);

        AmountInclVatInOut := ROUND(TotalRefundAmount, 0.01);

    end;

    procedure IsReservationRequest(Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then
            exit((not TicketReservationRequest."Revoke Ticket Request") and (TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::PRIMARY));

        exit(false);
    end;

    procedure IsChangeRequest(Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then
            exit((not TicketReservationRequest."Revoke Ticket Request") and (TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::CHANGE));

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

    procedure IsConfirmedRevokeRequest(Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then
            exit((TicketReservationRequest."Revoke Ticket Request") and (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CANCELED));

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

    procedure IsRequestStatusConfirmed(Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindFirst()) then
            exit(TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::CONFIRMED);

        exit(false);
    end;

    procedure RequestRequiresAttention(Token: Text[100]): boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        NotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
        RequireParticipantInformation: Option NOT_REQUIRED,OPTIONAL,REQUIRED;
        AdmissionCode: Code[20];
        SuggestNotificationMethod: Enum "NPR TM NotificationMethod";
        SuggestNotificationAddress: Text[100];
        SuggestTicketHolderName: Text[100];
        SuggestTicketHolderLanguage: Code[10];
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Admission Inclusion", '=%1|=%2', TicketReservationRequest."Admission Inclusion"::SELECTED, TicketReservationRequest."Admission Inclusion"::NOT_SELECTED);
        if (not TicketReservationRequest.IsEmpty()) then
            exit(true); // dynamic contents requires attention

        RequireParticipantInformation := NotifyParticipant.RequireParticipantInfo(Token, AdmissionCode, SuggestNotificationMethod, SuggestNotificationAddress, SuggestTicketHolderName, SuggestTicketHolderLanguage);
        if (RequireParticipantInformation <> RequireParticipantInformation::NOT_REQUIRED) then
            exit(true); // notifying participant requires attention

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Admission Inclusion", '=%1', TicketReservationRequest."Admission Inclusion"::REQUIRED);
        TicketReservationRequest.SetFilter("Admission Created", '=%1', false);
        exit(not TicketReservationRequest.IsEmpty());
    end;

    internal procedure GetTokenFromReceipt(ReceiptNo: Code[20]; LineNumber: Integer; var Token: Text[100]): Boolean
    var
        TokenLineNumber: Integer;
    begin
        exit(GetTokenFromReceipt(ReceiptNo, LineNumber, Token, TokenLineNumber));
    end;

    internal procedure GetTokenFromReceipt(ReceiptNo: Code[20]; LineNumber: Integer; var Token: Text[100]; var TokenLineNumber: Integer): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        Token := '';
        TokenLineNumber := 0;
        if (ReceiptNo = '') then
            exit(false);

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        TicketReservationRequest.ReadIsolation(IsolationLevel::ReadUncommitted);
#ENDIF

        TicketReservationRequest.SetCurrentKey("Receipt No.");
        TicketReservationRequest.SetFilter("Receipt No.", '=%1', ReceiptNo);
        TicketReservationRequest.SetFilter("Line No.", '=%1', LineNumber);

        TicketReservationRequest.SetLoadFields("Session Token ID", "Ext. Line Reference No.");
        if (TicketReservationRequest.FindFirst()) then begin
            Token := TicketReservationRequest."Session Token ID";
            TokenLineNumber := TicketReservationRequest."Ext. Line Reference No.";
        end;

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

    procedure GetTicketToken(TicketNo: Code[30]; var Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketFound: Boolean;
    begin
        Token := '';


        if (StrLen(TicketNo) <= MaxStrLen(Ticket."No.")) then
            TicketFound := Ticket.Get(TicketNo);

        if (not TicketFound) then begin
            Ticket.SetFilter("External Ticket No.", '=%1', TicketNo);
            TicketFound := Ticket.FindFirst();
        end;

        if (not TicketFound) then
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
        ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
        if (ItemReference.FindFirst()) then
            ExternalNo := ItemReference."Reference No.";

        exit(ExternalNo);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure POS_OnModifyQuantity(SaleLinePOS: Record "NPR POS Sale Line")
    var
        Token: Text[100];
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        OriginalSaleLine: Record "NPR POS Entry Sales Line";
        Ticket: Record "NPR TM Ticket";
        TicketCount: Integer;
        RevokeQuantity: Integer;
        ChangeQuantityNotPossible: Label 'Quantity for configurable tickets must be changed in the edit ticket reservation page.';
        RequestMutex: Record "NPR TM TicketRequestMutex";
    begin

        if (not (GetTokenFromReceipt(SaleLinePOS."Sales Ticket No.", SaleLinePOS."Line No.", Token))) then
            exit;

        if (not RequestMutex.Acquire(Token, SessionId())) then
            Error('[-1205] %1', TOKEN_PROCESSING_CONFLICT_1205);

#if (BC17 or BC18 or BC19 or BC20 or BC21)
        LockResources('POS_OnModifyQuantity');
#endif

        ReservationRequest.SetCurrentKey("Session Token ID");
        ReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        ReservationRequest.SetFilter("Receipt No.", '=%1', SaleLinePOS."Sales Ticket No.");
        ReservationRequest.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");
        if (ReservationRequest.FindFirst()) then begin

            if (SaleLinePOS.Quantity > 0) then begin
                if (ReservationRequest.Quantity = SaleLinePOS.Quantity) then begin
                    RequestMutex.Release(Token);
                    exit;
                end;

                if (ReservationRequest."Admission Inclusion" <> ReservationRequest."Admission Inclusion"::REQUIRED) then
                    Error(ChangeQuantityNotPossible);

                if (ReservationRequest."Item No." <> SaleLinePOS."No.") or (ReservationRequest."Variant Code" <> SaleLinePOS."Variant Code") then begin
                    if (ReservationRequest."Admission Created") then
                        Error(EXTERNAL_ITEM_CHANGE);

                    ReservationRequest.DeleteAll();
                    RequestMutex.Release(Token);
                    exit;
                end;

                if (ReservationRequest."Request Status" = ReservationRequest."Request Status"::CONFIRMED) then
                    Error(CHANGE_NOT_ALLOWED);

                DeleteReservationRequest(Token, false);
                UpdateReservationQuantity(Token, SaleLinePOS.Quantity);
                DoIssueTicketFromReservationToken(Token);
            end;

            // Return sales
            if (SaleLinePOS.Quantity < 0) then begin
                OriginalSaleLine."Document No." := SaleLinePOS."Return Sale Sales Ticket No.";
                OriginalSaleLine."Line No." := SaleLinePOS."Line No.";

                // A return sales ticket line number can not be trusted to be the same as the original ticket line number
                if (not (IsNullGuid(SaleLinePOS."Orig.POS Entry S.Line SystemId"))) then
                    OriginalSaleLine.GetBySystemId(SaleLinePOS."Orig.POS Entry S.Line SystemId");

                Ticket.SetFilter("Sales Receipt No.", '=%1', OriginalSaleLine."Document No.");
                Ticket.SetFilter("Line No.", '=%1', OriginalSaleLine."Line No.");

                // Ticket.SetFilter("Sales Receipt No.", '=%1', SaleLinePOS."Return Sale Sales Ticket No.");
                // Ticket.SetFilter("Line No.", '=%1', SaleLinePOS."Line No.");

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

        RequestMutex.Release(Token);

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
            DeleteReservationRequestDynamicTicket(Token, true, SaleLinePOS."Line No.");
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
        showProgressBar := (ShowProgressBarIn and GuiAllowed());
    end;

    local procedure GetShowProgressBar(): Boolean
    begin
        exit(showProgressBar);
    end;

    procedure ExportTicketRequestListToClientExcel(var TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        DataTypeMgt: Codeunit "Data Type Management";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        OutStr: OutStream;
        NewStream: InStream;
        ToFile: Text;
    begin

        // The link to ticket is only on the first request
        TempBlob.CreateOutStream(OutStr);
        DataTypeMgt.GetRecordRef(TicketReservationRequest, RecRef);
        Report.SaveAs(Report::"NPR TM Ticket Batch Resp.", '', ReportFormat::Excel, OutStr, RecRef);
        TempBlob.CreateInStream(NewStream);
        ToFile := 'TicketReport.xlsx';

        DownloadFromStream(
          NewStream,
          'Save file to client',
          '',
          'Excel File *.xlsx| *.xlsx',
          ToFile);
    end;

    internal procedure CalculateNewExpireTime(): DateTime;
    begin
        exit(CurrentDateTime() + (GetExpirySeconds() * 1000));
    end;

    internal procedure GetExpirySeconds() ExpirySeconds: Integer
    var
        UserSetup: Record "User Setup";
        Pos: Record "NPR POS Unit";
        TicketSetup: Record "NPR TM Ticket Setup";
    begin

        ExpirySeconds := 0;
        if (not TicketSetup.Get()) then
            ExpirySeconds := 1500;

        if (ExpirySeconds = 0) then
            if ((TicketSetup.DefaultExpireTimeSeconds = TicketSetup.UserDefaultExpireTimeSeconds) and
                (TicketSetup.UserDefaultExpireTimeSeconds = TicketSetup.PosUnattendedExpireTimeSeconds) and
                (TicketSetup.PosUnattendedExpireTimeSeconds = TicketSetup.PosExternalExpireTimeSeconds)) then
                ExpirySeconds := TicketSetup.DefaultExpireTimeSeconds;

        if (ExpirySeconds = 0) then begin
            if (UserSetup.Get(CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID")))) then begin
                if (Pos.Get(UserSetup."NPR POS Unit No.") and (UserSetup."NPR POS Unit No." <> '')) then begin
                    case (Pos."POS Type") of
                        Pos."POS Type"::UNATTENDED:
                            ExpirySeconds := TicketSetup.PosUnattendedExpireTimeSeconds;
                        Pos."POS Type"::EXTERNAL:
                            ExpirySeconds := TicketSetup.PosExternalExpireTimeSeconds;
                    end;
                end;
                if (ExpirySeconds = 0) then
                    ExpirySeconds := TicketSetup.UserDefaultExpireTimeSeconds;
            end;
        end;

        if (ExpirySeconds = 0) then
            ExpirySeconds := TicketSetup.DefaultExpireTimeSeconds;

        if (ExpirySeconds = 0) then
            ExpirySeconds := 1500;

    end;

    // ***************** EVENTS
    [IntegrationEvent(false, false)]
    internal procedure OnAfterBlockTicketPublisher(TicketNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUnblockTicketPublisher(TicketNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterConfirmTicketChangeRequestPublisher(Token: Text[100])
    begin

    end;

    // ****************** NP-Pass eTicket Integration

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR TM Ticket Request Manager", 'OnAfterBlockTicketPublisher', '', true, true)]
    local procedure OnAfterBlockTicketSubscriber(TicketNo: Code[20])
    var
        ResponseText: Text;
    begin

        SendETicketVoidRequest(TicketNo, true, ResponseText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR TM Ticket Request Manager", 'OnAfterUnblockTicketPublisher', '', true, true)]
    local procedure OnAfterUnblockTicketSubscriber(TicketNo: Code[20])
    var
        ResponseText: Text;
    begin

        SendETicketVoidRequest(TicketNo, false, ResponseText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR TM Ticket Request Manager", 'OnAfterConfirmTicketChangeRequestPublisher', '', true, true)]
    local procedure OnAfterConfirmTicketChangeRequestSubscriber(Token: Text[100]);
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
        ResponseMessage: Text;
    begin

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (not TicketReservationRequest.FindFirst()) then
            exit;

        while (true) do begin
            TicketNotificationEntry.SetFilter("Ticket Token", '=%1', TicketReservationRequest."Session Token ID");
            if (TicketNotificationEntry.FindSet()) then begin
                repeat
                    if (not (SendETicketUpdateRequest(Token, TicketNotificationEntry."Ticket No.", TicketNotificationEntry."Admission Code", ResponseMessage))) then
                        Message(ResponseMessage);
                until (TicketNotificationEntry.Next() = 0);
                exit;

            end else begin
                if (TicketReservationRequest."Entry Type" = TicketReservationRequest."Entry Type"::PRIMARY) then
                    exit;
                TicketReservationRequest.Get(TicketReservationRequest."Superseeds Entry No.");
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
        if (TicketNotificationEntry.IsEmpty()) then
            exit(false);

        RecordToText := Format(TicketNotificationEntry, 0, 9);

        TicketNotificationEntry.FindLast();
        TicketNotificationEntry."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_UPDATE;

        Admission.Get(AdmissionCode);

        if (Admission."Capacity Control" <> Admission."Capacity Control"::SEATING) then
            AssignAdmissionInformation(TicketNo, AdmissionCode, TicketNotificationEntry);

        if ((RecordToText = Format(TicketNotificationEntry, 0, 9)) and
            (TicketNotificationEntry."Notification Send Status" <> TicketNotificationEntry."Notification Send Status"::FAILED)) then
            exit(false); // We have already sent this message

        TicketNotificationEntry."Entry No." := 0;
        TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::PENDING;
        TicketNotificationEntry."Ticket Token" := Token;

        TicketNotificationEntry.Insert();
        exit(SendETicketNotification(TicketNotificationEntry."Entry No.", false, ResponseMessage));

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
    begin
        exit(CreateAndSendETicket(TicketNo, '', false, ReasonText));
    end;

    procedure CreateAndSendETicket(TicketNo: Code[20]; SendTo: Text[100]; ForceCreateNew: Boolean; var ReasonText: Text): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TempTicketNotificationEntry: Record "NPR TM Ticket Notif. Entry" temporary;
    begin

        Ticket.Get(TicketNo);
        if (not CreateETicketNotificationEntry(Ticket, TempTicketNotificationEntry, SendTo, false, ForceCreateNew, ReasonText)) then
            exit(false);

        TempTicketNotificationEntry.Reset();
        TempTicketNotificationEntry.FindSet();
        repeat
            if (not SendETicketNotification(TempTicketNotificationEntry."Entry No.", false, ReasonText)) then
                exit(false);
        until (TempTicketNotificationEntry.Next() = 0);

        ReasonText := '';
        exit(true);
    end;


    procedure CreateETicketNotificationEntry(Ticket: Record "NPR TM Ticket"; var TmpNotificationsCreated: Record "NPR TM Ticket Notif. Entry" temporary; SendTo: Text[100]; NotifyWithExternalModule: Boolean; ForceCreateNew: Boolean; var ReasonText: Text): Boolean
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
        NPDesignerSetup: Record "NPR NPDesignerSetup";
        NpDesignerImpl: Codeunit "NPR NPDesigner";
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
                    if (ForceCreateNew) then
                        TicketNotificationEntry2."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_CREATE;

                    TicketNotificationEntry2."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::PENDING;

                    TicketNotificationEntry2."Notification Address" := TicketReservationRequest."Notification Address";
                    if (SendTo <> '') then
                        TicketNotificationEntry2."Notification Address" := SendTo;

                    TicketNotificationEntry2."Notification Method" := TicketNotificationEntry."Notification Method"::SMS;
                    if (StrPos(TicketNotificationEntry2."Notification Address", '@') > 0) then
                        TicketNotificationEntry2."Notification Method" := TicketNotificationEntry."Notification Method"::EMAIL;

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

        if (not ((ForceCreateNew) and (SendTo <> ''))) then
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

            TicketNotificationEntry."Notification Address" := TicketReservationRequest."Notification Address";
            if (SendTo <> '') then
                TicketNotificationEntry."Notification Address" := SendTo;

            TicketNotificationEntry."Ticket Holder Preferred Lang" := TicketReservationRequest.TicketHolderPreferredLanguage;

            TicketNotificationEntry."Notification Method" := TicketNotificationEntry."Notification Method"::SMS;
            if (StrPos(TicketNotificationEntry."Notification Address", '@') > 0) then
                TicketNotificationEntry."Notification Method" := TicketNotificationEntry."Notification Method"::EMAIL;

            if (NotifyWithExternalModule) then begin
                TicketNotificationEntry."Notification Method" := TicketNotificationEntry."Notification Method"::NA;
            end;

            TicketNotificationEntry."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_UPDATE;

            TicketNotificationEntry2.SetFilter("Ticket No.", '=%1', Ticket."No.");
            TicketNotificationEntry2.SetFilter("Notification Send Status", '=%1', TicketNotificationEntry2."Notification Send Status"::SENT);
            if ((TicketNotificationEntry2.IsEmpty()) or (ForceCreateNew)) then
                TicketNotificationEntry."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_CREATE;

            TicketNotificationEntry."Ticket Type Code" := TicketType.Code;
            TicketNotificationEntry."eTicket Type Code" := TicketType."eTicket Type Code";

            TicketNotificationEntry."Ticket BOM Adm. Description" := TicketAdmissionBOM."Admission Description";
            TicketNotificationEntry."Ticket BOM Description" := TicketAdmissionBOM.Description;
            TicketNotificationEntry.NPDesignerTemplateId := TicketAdmissionBOM.NPDesignerTemplateId;
            if (TicketNotificationEntry.NPDesignerTemplateId <> '') then begin
                // https://tickets.npretail.app?reservation=%1&design=%2
                if (NPDesignerSetup.Get('')) then begin
                    if (NPDesignerSetup.EnableManifest) then begin
                        if (IsNullGuid(TicketNotificationEntry.NPDesignerManifestId)) then begin
                            TicketNotificationEntry.NPDesignerManifestId := NpDesignerImpl.CreateManifest();
                            NPDesignerImpl.AddAssetToManifest(TicketNotificationEntry.NPDesignerManifestId, Database::"NPR TM Ticket Reservation Req.", TicketReservationRequest.SystemId, TicketReservationRequest."Session Token ID", TicketNotificationEntry.NPDesignerTemplateId);
                        end;
                        NPDesignerImpl.GetManifestUrl(TicketNotificationEntry.NPDesignerManifestId, TicketNotificationEntry."Published Ticket URL");
                    end;

                    if (not NPDesignerSetup.EnableManifest and (NPDesignerSetup.PublicOrderURL <> '')) then
                        TicketNotificationEntry."Published Ticket URL" := StrSubstNo(NPDesignerSetup.PublicOrderURL, TicketReservationRequest."Session Token ID", TicketNotificationEntry.NPDesignerTemplateId);
                end;
            end;

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
                            TicketNotificationEntry.Seat := CopyStr(SeatingTemplate.Description, 1, MaxStrLen(TicketNotificationEntry.Seat));
                            if (SeatingTemplate.Get(SeatingTemplate."Parent Entry No.")) then begin
                                TicketNotificationEntry.Row := CopyStr(SeatingTemplate.Description, 1, MaxStrLen(TicketNotificationEntry.Row));
                                if (SeatingTemplate.Get(SeatingTemplate."Parent Entry No.")) then begin
                                    TicketNotificationEntry.Section := CopyStr(SeatingTemplate.Description, 1, MaxStrLen(TicketNotificationEntry.Section));
                                end;
                            end;
                        end;
                        TicketNotificationEntry."Entry No." := 0;
                        TicketNotificationEntry.Insert();
                        TmpNotificationsCreated.TransferFields(TicketNotificationEntry, true);
                        TmpNotificationsCreated.SystemId := TicketNotificationEntry.SystemId;
                        TmpNotificationsCreated.Insert();
                    until (SeatingReservationEntry.Next() = 0);
                end;
            end;

            if (Admission."Capacity Control" <> Admission."Capacity Control"::SEATING) then begin
                AssignAdmissionInformation(Ticket."No.", TicketAdmissionBOM."Admission Code", TicketNotificationEntry);
                TicketNotificationEntry."Entry No." := 0;
                TicketNotificationEntry.Insert();
                TmpNotificationsCreated.TransferFields(TicketNotificationEntry, true);
                TmpNotificationsCreated.SystemId := TicketNotificationEntry.SystemId;
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
            if (DetTicketAccessEntry.IsEmpty()) then
                DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);

            if (DetTicketAccessEntry.FindFirst()) then begin
                AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
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
        TicketNotifyParticipant: Codeunit "NPR TM Ticket Notify Particpt.";
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
                Commit();
                if (TicketNotificationEntry."Notification Method" = TicketNotificationEntry."Notification Method"::SMS) then begin
                    if (not TicketNotifyParticipant.SendSmsNotificationEntry(TicketNotificationEntry, ResponseMessage)) then begin
                        TicketNotificationEntry."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketNotificationEntry."Failed With Message"));
                        TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::FAILED;
                        TicketNotificationEntry.Modify();
                        Commit();
                        exit(false);
                    end;
                end;

                if (TicketNotificationEntry."Notification Method" = TicketNotificationEntry."Notification Method"::EMAIL) then begin
                    if (not TicketNotifyParticipant.SendMailNotificationEntry(TicketNotificationEntry, ResponseMessage)) then begin
                        TicketNotificationEntry."Failed With Message" := CopyStr(ResponseMessage, 1, MaxStrLen(TicketNotificationEntry."Failed With Message"));
                        TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::FAILED;
                        TicketNotificationEntry.Modify();
                        Commit();
                        exit(false);
                    end;
                end;
            end;
        end;

        TicketNotificationEntry."Notification Send Status" := TicketNotificationEntry."Notification Send Status"::SENT;
        TicketNotificationEntry."Notification Sent At" := CurrentDateTime();
        TicketNotificationEntry."Notification Sent By User" := CopyStr(UserId(), 1, MaxStrLen(TicketNotificationEntry."Notification Sent By User"));
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

        if (not (NPPassServerInvokeApi('GET', TicketNotificationEntry, ReasonMessage, '', JSONResult))) then
            exit(false);

        if (JSONResult = '') then
            exit(false);

        JObject.ReadFrom(JSONResult);

        TicketNotificationEntry."eTicket Pass Default URL" := CopyStr(GetStringValue(JObject, 'public_url.default'), 1, MaxStrLen(TicketNotificationEntry."eTicket Pass Default URL"));
        TicketNotificationEntry."eTicket Pass Andriod URL" := CopyStr(GetStringValue(JObject, 'public_url.android'), 1, MaxStrLen(TicketNotificationEntry."eTicket Pass Andriod URL"));
        TicketNotificationEntry."eTicket Pass Landing URL" := CopyStr(GetStringValue(JObject, 'public_url.landing'), 1, MaxStrLen(TicketNotificationEntry."eTicket Pass Landing URL"));

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
        OptionAsText: Text;
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

                FieldRef := RecRef.field(FieldNo);
                if (FieldRef.Class = FieldClass::FlowField) then
                    FieldRef.CalcField();
                NewLine := DelStr(NewLine, StartPos, EndPos - StartPos + SeparatorLength);

                case FieldRef.Type of
                    FieldType::Option:
                        begin
                            OptionAsText := '';
                            if (StrPos(UpperCase(FieldRef.OptionCaption), UpperCase(Format(FieldRef.Value))) > 0) then
                                OptionAsText := UpperCase(FieldRef.OptionCaption);

                            if (StrPos(UpperCase(FieldRef.OptionMembers), UpperCase(Format(FieldRef.Value))) > 0) then
                                OptionAsText := UpperCase(FieldRef.OptionMembers);

                            if (OptionAsText <> '') then begin

                                if (OptionAsText[1] = ',') then OptionInt := 2 else OptionInt := 1;
                                while StrPos(SelectStr(OptionInt, OptionAsText), UpperCase(Format(FieldRef.Value))) = 0 do
                                    OptionInt += 1;
                                OptionInt -= 1;

                            end else begin

                                if (not Evaluate(OptionInt, Format(FieldRef.Value, 0, 9), 9)) then
                                    OptionInt := 0;
                            end;

                            OptionCaption := Format(FieldRef.OptionCaption);
                            for i := 1 to OptionInt do
                                OptionCaption := DelStr(OptionCaption, 1, StrPos(OptionCaption, ','));
                            if (StrPos(OptionCaption, ',') <> 0) then
                                OptionCaption := DelStr(OptionCaption, StrPos(OptionCaption, ','));

                            NewLine := InsStr(NewLine, OptionCaption, StartPos);
                        end;
                    FieldType::DateTime:
                        NewLine := InsStr(NewLine, Format(FieldRef.Value, 0, 9), StartPos);
                    FieldType::Boolean:
                        NewLine := InsStr(NewLine, LowerCase(Format(FieldRef.Value, 0, 9)), StartPos);
                    else
                        NewLine := InsStr(NewLine, DelChr(Format(FieldRef.Value), '<=>', '"'), StartPos);
                end;
            end else
                Error(BAD_REFERENCE, FieldNo, Line);
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

    local procedure FindTicketByToken(var Ticket: Record "NPR TM Ticket"; SessionTokenID: Text[100]; AdmissionCode: Code[20]; Current: Boolean; ExtLineReferenceNo: Integer): Boolean

    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TMTicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin
        TicketReservationRequest.SetRange("Session Token ID", SessionTokenID);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.SetRange("Ext. Line Reference No.", ExtLineReferenceNo);
        if TicketReservationRequest.FindSet() then begin
            repeat
                if Current then
                    Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationRequest."Entry No.")
                else
                    Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationRequest."Superseeds Entry No.");

                if (Ticket.FindSet()) then
                    repeat
                        TMTicketAccessEntry.Reset();
                        TMTicketAccessEntry.SetRange("Ticket No.", Ticket."No.");
                        TMTicketAccessEntry.SetRange("Admission Code", AdmissionCode);
                        if TMTicketAccessEntry.IsEmpty() then
                            exit;
                    until Ticket.Next() = 0;
            until (TicketReservationRequest.Next() = 0);
        end;
    end;

    local procedure InsertTicket(ItemNo: Code[20]; VariantCode: Code[10]; TicketType: Record "NPR TM Ticket Type"; ReservationRequest: Record "NPR TM Ticket Reservation Req."; var Ticket: Record "NPR TM Ticket"; var TicketManagement: Codeunit "NPR TM Ticket Management")
    var
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
        Ticket."Sales Header Type" := Ticket."Sales Header Type"::External;
        Ticket."Sales Header No." := ReservationRequest."External Order No.";
        Ticket."External Ticket No." := ReservationRequest.PreAssignedTicketNumber;
        Ticket.AmountInclVat := ReservationRequest.TicketUnitAmountInclVat;
        Ticket.AmountExclVat := ReservationRequest.TicketUnitAmountExclVat;
        Ticket.ListPriceInclVat := ReservationRequest.TicketListPriceInclVat;
        Ticket.ListPriceExclVat := ReservationRequest.TicketListPriceExclVat;

        if (UserSetup.Get(CopyStr(UserId(), 1, MaxStrLen(UserSetup."User ID")))) then
            Ticket."Salesperson Code" := UserSetup."Salespers./Purch. Code";

        if (Ticket."Salesperson Code" = '') then
            Ticket."Salesperson Code" := CopyStr(UserId(), 1, MaxStrLen(Ticket."Salesperson Code"));

        TicketManagement.SetTicketProperties(Ticket, ReservationRequest."Request Status Date Time");
        Ticket.Insert(true);
    end;

    local procedure CreateAdditionalExperienceLine(var ReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        Admission: Record "NPR TM Admission";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLine: Codeunit "NPR POS Sale Line";
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        BasePrice, AddonPrice : Decimal;
    begin
        if ReservationRequest."Admission Inclusion" <> ReservationRequest."Admission Inclusion"::SELECTED then
            exit;
        Admission.Get(ReservationRequest."Admission Code");
        if Admission."Additional Experience Item No." = '' then
            exit;

        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        SaleLinePOS."No." := Admission."Additional Experience Item No.";
        SaleLinePOS.Description := Admission.Description;
        SaleLinePOS."Description 2" := ReservationRequest."Scheduled Time Description";
        SaleLinePOS.Quantity := ReservationRequest.Quantity;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.InsertLine(SaleLinePOS, false);
        TicketPrice.CalculateScheduleEntryPrice(ReservationRequest."Item No.", ReservationRequest."Variant Code", ReservationRequest."Admission Code", ReservationRequest."External Adm. Sch. Entry No.", SaleLinePOS."Unit Price", SaleLinePOS."Price Includes VAT", SaleLinePOS."VAT %", Today(), Time(), BasePrice, AddonPrice);
        SaleLinePOS.Validate("Unit Price", BasePrice + AddonPrice);
        SaleLinePOS.Modify();

        ReservationRequest."Line No." := SaleLinePOS."Line No.";

    end;

    local procedure MoreSalesLinesForTicket(Token: Text[100]; POSSalesLineNo: Integer): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        if POSSalesLineNo = 0 then
            exit(true);
        TicketReservationRequest.SetRange("Session Token ID", Token);
        TicketReservationRequest.SetFilter("Line No.", '<>0&<>%1', POSSalesLineNo);
        exit(not TicketReservationRequest.IsEmpty());
    end;

    local procedure SwitchTicketReservationEntryNo(TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    var
        Ticket: Record "NPR TM Ticket";
    begin
        if TicketReservationRequest."Entry Type" <> TicketReservationRequest."Entry Type"::CHANGE then
            exit;
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Superseeds Entry No.");
        if Ticket.FindSet() then
            repeat
                Ticket."Ticket Reservation Entry No." := TicketReservationRequest."Entry No.";
                Ticket.Modify();
            until Ticket.Next() = 0;
    end;

    internal procedure AssignPrimaryReservationEntry(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        AuthorizationCode: Code[10];
        OldLineReference: Integer;
        PrimaryAssigned: Boolean;
        PrimaryLineQuantity: integer;
    begin
        OldLineReference := Power(2, 31) - 1;

        if (not TicketSetup.Get()) then
            TicketSetup.Init();

        if (TicketSetup."Authorization Code Scheme" = '') then
            TicketSetup."Authorization Code Scheme" := '[N*4]-[N*4]';

        AuthorizationCode := CopyStr(TicketManagement.GenerateNumberPattern(TicketSetup."Authorization Code Scheme", '-'), 1, MaxStrLen(TicketReservationRequest."Authorization Code"));

        TicketReservationRequest.SetCurrentKey("Session Token ID", "Ext. Line Reference No.", "Admission Inclusion");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            repeat

                TicketReservationRequest."Primary Request Line" := false;
                if (TicketReservationRequest."Ext. Line Reference No." <> OldLineReference) then
                    PrimaryAssigned := false;

                if ((TicketReservationRequest."Admission Inclusion" = TicketReservationRequest."Admission Inclusion"::REQUIRED) and not (PrimaryAssigned)) then begin
                    TicketReservationRequest."Primary Request Line" := true;
                    PrimaryLineQuantity := TicketReservationRequest.Quantity;
                    PrimaryAssigned := true;
                end;

                TicketReservationRequest.Quantity := PrimaryLineQuantity;
                TicketReservationRequest."Authorization Code" := AuthorizationCode;
                TicketReservationRequest.Modify();
                OldLineReference := TicketReservationRequest."Ext. Line Reference No.";
            until (TicketReservationRequest.Next() = 0);
        end;
    end;

    procedure NPPassServerInvokeApi(RequestMethod: Code[10]; TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; var ReasonText: Text; JSONIn: Text; var JSONOut: Text): Boolean
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
        TicketSetup: Record "NPR TM Ticket Setup";
        Url: Text;
        UrlLbl: Label '%1%2?sync=%3', Locked = true;
    begin
        if (NPPassServerInvokeApiWorker(RequestMethod, TicketNotificationEntry, ReasonText, JSONIn, JSONOut)) then
            exit(true);

        TicketSetup.Get();
        Url := StrSubstNo(UrlLbl, TicketSetup."NP-Pass Server Base URL",
                                           StrSubstNo(TicketSetup."NP-Pass API", TicketNotificationEntry."eTicket Type Code", TicketNotificationEntry."eTicket Pass Id"),
                                           Format(TicketSetup."NP-Pass Notification Method", 0, 9));

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());

        CustomDimensions.Add('NPR_EntryNumber', Format(TicketNotificationEntry."Entry No.", 0, 9));
        CustomDimensions.Add('NPR_WalletPassId', TicketNotificationEntry."eTicket Pass Id");
        CustomDimensions.Add('NPR_Method', Format(TicketNotificationEntry."Notification Method", 0, 9));

        CustomDimensions.Add('NPR_Token', TicketNotificationEntry."Ticket Token");

        CustomDimensions.Add('NPR_Wallet', 'true');
        CustomDimensions.Add('NPR_HttpVerb', RequestMethod);
        CustomDimensions.Add('NPR_Endpoint', Url);

        Session.LogMessage('NPR_TicketWalletNotification', ReasonText, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);

        exit(false);
    end;

    [TryFunction]
    local procedure NPPassServerInvokeApiWorker(RequestMethod: Code[10]; TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry"; var ReasonText: Text; JSONIn: Text; var JSONOut: Text)
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
        UrlLbl: Label '%1%2?sync=%3', Locked = true;
        BearerLbl: Label 'Bearer %1', Locked = true;
    begin

        TicketSetup.Get();

        ReasonText := '';
        JSONOut := '';
        ClearLastError();

        Url := StrSubstNo(UrlLbl, TicketSetup."NP-Pass Server Base URL",
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
        RequestHeaders.Add(AuthorizationTok, StrSubstNo(BearerLbl, TicketSetup."NP-Pass Token"));

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

    internal procedure CalculateAdmissionPrice(TMTicketReservationReq: Record "NPR TM Ticket Reservation Req."): Decimal
    var
        Item: Record Item;
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        BasePrice, AddonPrice : Decimal;
    begin
        if TMTicketReservationReq.Default then
            if Item.Get(TMTicketReservationReq."Item No.") then
                exit(Item."Unit Price");
        if TMTicketReservationReq."Admission Inclusion" = TMTicketReservationReq."Admission Inclusion"::REQUIRED then
            exit(0);

        if TicketPrice.CalculateScheduleEntryPrice(TMTicketReservationReq."Item No.", TMTicketReservationReq."Variant Code", TMTicketReservationReq."Admission Code", TMTicketReservationReq."External Adm. Sch. Entry No.", Today, Time, BasePrice, AddonPrice) then
            exit(BasePrice + AddonPrice);
        exit(0)
    end;

    internal procedure CalculateAdmissionPrice(AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines"): Decimal
    var
        TMAdmission: Record "NPR TM Admission";
        Item: Record Item;
    begin

        if TMAdmission.Get(AdmissionScheduleLines."Admission Code") then
            if Item.Get(TMAdmission."Additional Experience Item No.") then
                exit(Item."Unit Price");
        exit(0)

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

}


