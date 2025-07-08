codeunit 6151543 "NPR TM Client API BL"
{
    Access = Internal;

    var
        _CapacityStatusCodeOption: Option ,OK,CAPACITY_EXCEEDED,NON_WORKING,CALENDAR_WARNING,CLOSED;

    internal procedure GetReservationAction(ReservationRequest: JsonArray) ResponseText: Text
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketResponse: Record "NPR TM Ticket Reserv. Resp.";
        JBuilder: Codeunit "Json Text Reader/Writer";
        ValidationErrorList: List of [Text];
        Token: Text[100];
        RequestToken: JsonToken;
    begin
        JBuilder.WriteStartObject('');

        // request validation
        JBuilder.WriteStartArray('request');
        foreach RequestToken in ReservationRequest do begin
            Token := CopyStr(GetAsText(RequestToken.AsObject(), 'token', ValidationErrorList), 1, MaxStrLen(Token));

            JBuilder.WriteStartObject('');
            JBuilder.WriteStringProperty('token', Token);
            JBuilder.WriteEndObject();

            TicketRequest.SetCurrentKey("Session Token ID");
            TicketRequest.SetFilter("Session Token ID", '=%1', Token);
            if (not TicketRequest.FindFirst()) then
                ValidationErrorList.Add(StrSubstNo('Invalid token %1', Token));

            if (not (TicketRequest."Request Status" in [TicketRequest."Request Status"::REGISTERED, TicketRequest."Request Status"::WIP, TicketRequest."Request Status"::EXPIRED])) then
                ValidationErrorList.Add(StrSubstNo('Invalid status on token %1', Token));
        end;
        JBuilder.WriteEndArray(); // request

        JBuilder.WriteStartArray('response');
        if (ValidationErrorList.Count() > 0) then
            DumpValidationErrorList(JBuilder, 'Invalid token', -102, ValidationErrorList);

        if (ValidationErrorList.Count() = 0) then begin
            foreach RequestToken in ReservationRequest do begin
                Token := CopyStr(GetAsText(RequestToken.AsObject(), 'token', ValidationErrorList), 1, MaxStrLen(Token));
                TicketResponse.SetFilter("Session Token ID", '=%1', Token);
                if (not TicketResponse.FindFirst()) then begin
                    // for now, there is only 1 ticket set per request so only 1 response
                    TicketResponse.Status := false;
                    TicketResponse."Response Message" := StrSubstNo('No response was found for token %1', token);
                end;
                GetRequestDetails(JBuilder, Token, TicketResponse.Status, TicketResponse."Response Message");
            end;
        end;
        JBuilder.WriteEndArray(); // response
        JBuilder.WriteEndObject(); // root

        ResponseText := JBuilder.GetJSonAsText();
        exit(ResponseText);

    end;

    internal procedure CancelRequestAction(ReservationRequest: JsonArray) ResponseText: Text
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        JBuilder: Codeunit "Json Text Reader/Writer";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ValidationErrorList: List of [Text];
        Token: Text[100];
        RequestToken: JsonToken;
        Request: JsonObject;
    begin
        JBuilder.WriteStartObject('');

        // request validation
        JBuilder.WriteStartArray('request');
        foreach RequestToken in ReservationRequest do begin
            Request := RequestToken.AsObject();
            Token := CopyStr(GetAsText(Request, 'token', ValidationErrorList), 1, MaxStrLen(Token));

            JBuilder.WriteStartObject('');
            JBuilder.WriteStringProperty('token', Token);
            JBuilder.WriteEndObject();

            TicketRequest.SetCurrentKey("Session Token ID");
            TicketRequest.SetFilter("Session Token ID", '=%1', Token);
            if (not TicketRequest.FindFirst()) then
                ValidationErrorList.Add(StrSubstNo('Invalid token %1', Token));

            if (TicketRequest."Request Status" = TicketRequest."Request Status"::CONFIRMED) then
                ValidationErrorList.Add(StrSubstNo('Invalid status on token %1', Token));
        end;
        JBuilder.WriteEndArray(); // request

        JBuilder.WriteStartArray('response');
        if (ValidationErrorList.Count() > 0) then
            DumpValidationErrorList(JBuilder, 'Invalid token', -102, ValidationErrorList);

        if (ValidationErrorList.Count() = 0) then begin
            foreach RequestToken in ReservationRequest do begin
                Request := RequestToken.AsObject();
                Token := CopyStr(GetAsText(Request, 'token', ValidationErrorList), 1, MaxStrLen(Token));
                TicketRequestManager.DeleteReservationTokenRequest(Token);

                TicketRequest.SetCurrentKey("Session Token ID");
                TicketRequest.SetFilter("Session Token ID", '=%1', Token);
                JBuilder.WriteStartObject('');
                JBuilder.WriteStringProperty('token', Token);
                JBuilder.WriteBooleanProperty('cancelled', TicketRequest.IsEmpty());
                JBuilder.WriteEndObject(); // token
            end;
        end;
        JBuilder.WriteEndArray(); // response
        JBuilder.WriteEndObject(); // root

        ResponseText := JBuilder.GetJSonAsText();
        exit(ResponseText);
    end;


    internal procedure PreConfirmRequestAction(ReservationRequest: JsonArray) ResponseText: Text
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        JBuilder: Codeunit "Json Text Reader/Writer";
        TicketRequestManager: Codeunit "NPR TM Ticket WebService Mgr";
        ValidationErrorList: List of [Text];
        Token: Text[100];
        RequestToken: JsonToken;
        Request: JsonObject;
    begin
        JBuilder.WriteStartObject('');

        // request validation
        JBuilder.WriteStartArray('request');
        foreach RequestToken in ReservationRequest do begin
            Request := RequestToken.AsObject();
            Token := CopyStr(GetAsText(Request, 'token', ValidationErrorList), 1, MaxStrLen(Token));

            JBuilder.WriteStartObject('');
            JBuilder.WriteStringProperty('token', Token);
            JBuilder.WriteEndObject();

            TicketRequest.SetCurrentKey("Session Token ID");
            TicketRequest.SetFilter("Session Token ID", '=%1', Token);
            if (not TicketRequest.FindFirst()) then
                ValidationErrorList.Add(StrSubstNo('Invalid token %1', Token));

            if (not (TicketRequest."Request Status" in [TicketRequest."Request Status"::REGISTERED, TicketRequest."Request Status"::EXPIRED])) then
                ValidationErrorList.Add(StrSubstNo('Invalid status on token %1', Token));
        end;
        JBuilder.WriteEndArray(); // request

        JBuilder.WriteStartArray('response');
        if (ValidationErrorList.Count() > 0) then
            DumpValidationErrorList(JBuilder, 'Invalid token', -102, ValidationErrorList);

        if (ValidationErrorList.Count() = 0) then begin
            foreach RequestToken in ReservationRequest do begin
                Request := RequestToken.AsObject();
                Token := CopyStr(GetAsText(Request, 'token', ValidationErrorList), 1, MaxStrLen(Token));
                TicketRequestManager.PreConfirmReservationRequest(Token);

                TicketRequest.SetCurrentKey("Session Token ID");
                TicketRequest.SetFilter("Session Token ID", '=%1', Token);
                TicketRequest.FindFirst();

                JBuilder.WriteStartObject('');
                JBuilder.WriteStringProperty('token', Token);
                JBuilder.WriteStringProperty('expiresAt', Format(TicketRequest."Expires Date Time", 0, 9));
                JBuilder.WriteEndObject(); // token
            end;
        end;
        JBuilder.WriteEndArray(); // response
        JBuilder.WriteEndObject(); // root

        ResponseText := JBuilder.GetJSonAsText();
        exit(ResponseText);
    end;

    internal procedure MakeReservationAction(ReservationRequest: JsonArray) ResponseText: Text
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        JBuilder: Codeunit "Json Text Reader/Writer";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ValidationErrorList: List of [Text];
        Token: Text[100];
        RequestToken, RequestTokenLine : JsonToken;
        Request, RequestLine : JsonObject;
        LinesArray: JsonArray;
        ResponseMessage: Text;
        TicketCreateSuccess: Boolean;
        TicketUpdateSuccess: Boolean;
        SalesReceipt: Code[20];
        SalesReceiptLineNo: Integer;
    begin
        JBuilder.WriteStartObject('');

        // request validation
        JBuilder.WriteStartArray('request');
        foreach RequestToken in ReservationRequest do begin
            Request := RequestToken.AsObject();
            Token := CopyStr(GetAsText(Request, 'token', ''), 1, MaxStrLen(Token));

            JBuilder.WriteStartObject('');
            JBuilder.WriteStringProperty('token', Token);
            JBuilder.WriteStartArray('lines');
            Request.Get('lines', RequestTokenLine);
            LinesArray := RequestTokenLine.AsArray();
            foreach RequestTokenLine in LinesArray do begin
                RequestLine := RequestTokenLine.AsObject();
                JBuilder.WriteStartObject('');
                JBuilder.WriteStringProperty('itemReference', GetAsText(RequestLine, 'itemReference', ValidationErrorList));
                JBuilder.WriteStringProperty('admissionCode', GetAsText(RequestLine, 'admissionCode', ValidationErrorList));
                JBuilder.WriteRawProperty('quantity', GetAsInteger(RequestLine, 'quantity', ValidationErrorList));
                JBuilder.WriteRawProperty('scheduleId', GetAsInteger(RequestLine, 'scheduleId', 0));
                JBuilder.WriteStringProperty('memberNumber', GetAsText(RequestLine, 'memberNumber', ''));
                JBuilder.WriteStringProperty('notificationAddress', GetAsText(RequestLine, 'notificationAddress', ''));
                JBuilder.WriteEndObject();

                CheckScheduleId(GetAsText(RequestLine, 'admissionCode', ''), GetAsInteger(RequestLine, 'scheduleId', 0), ValidationErrorList);
            end;
            JBuilder.WriteEndArray();
            JBuilder.WriteEndObject();

            if (Token <> '') then begin
                TicketRequest.SetCurrentKey("Session Token ID");
                TicketRequest.SetFilter("Session Token ID", '=%1', Token);
                if (TicketRequest.FindFirst()) then
                    if (not (TicketRequest."Request Status" in [TicketRequest."Request Status"::REGISTERED, TicketRequest."Request Status"::WIP, TicketRequest."Request Status"::EXPIRED])) then
                        ValidationErrorList.Add(StrSubstNo('Invalid status on token %1', Token));
            end;
        end;
        JBuilder.WriteEndArray(); // request

        JBuilder.WriteStartArray('response');
        if (ValidationErrorList.Count() > 0) then
            DumpValidationErrorList(JBuilder, 'Invalid parameters', -101, ValidationErrorList);

        if (ValidationErrorList.Count() = 0) then begin
            foreach RequestToken in ReservationRequest do begin
                Request := RequestToken.AsObject();
                Token := CopyStr(GetAsText(Request, 'token', ValidationErrorList), 1, MaxStrLen(Token));

                Request.Get('lines', RequestTokenLine);

                Clear(TicketRequest);
                if (Token <> '') then begin
                    TicketRequest.SetCurrentKey("Session Token ID");
                    TicketRequest.SetFilter("Session Token ID", '=%1', Token);
                    if TicketRequest.FindFirst() then
                        if TicketRequest."Entry Type" = TicketRequest."Entry Type"::CHANGE then begin
                            UpdateReservation(RequestTokenLine.AsArray(), TicketRequest, Token, SalesReceipt, TicketUpdateSuccess);
                        end;
                end;

                if (not TicketUpdateSuccess) then begin
                    if (TicketRequestManager.TokenRequestExists(Token)) then begin
                        TicketRequestManager.GetReceiptFromToken(SalesReceipt, SalesReceiptLineNo, Token);
                        TicketRequestManager.DeleteReservationRequest(Token, true);
                    end;

                    CreateReservation(RequestTokenLine.AsArray(), Token, SalesReceipt, SalesReceiptLineNo, TicketCreateSuccess, ResponseMessage);
                    if (TicketCreateSuccess) then
                        UpdateSalesLine(SalesReceipt, SalesReceiptLineNo, Token);
                end;

                GetRequestDetails(JBuilder, Token, TicketCreateSuccess or TicketUpdateSuccess, ResponseMessage);
            end;
        end;
        JBuilder.WriteEndArray(); // response
        JBuilder.WriteEndObject(); // root

        ResponseText := JBuilder.GetJSonAsText();
        exit(ResponseText);
    end;

    local procedure UpdateReservation(Lines: JsonArray; TicketRequest: Record "NPR TM Ticket Reservation Req."; Token: Text[100]; var SalesReceiptNumber: Code[20]; var Success: Boolean)
    var
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        POSSession: Codeunit "NPR POS Session";
        TicketWebRequestManager: Codeunit "NPR TM Ticket WebService Mgr";
        ExternalId: List of [Integer];
    begin
        if not SetTicketRequestInfo(TicketRequest, Lines, Token) then
            exit;

        Commit();
        Ticket.SetRange("Ticket Reservation Entry No.", TicketRequest."Superseeds Entry No.");
        if (Ticket.FindSet()) then
            repeat
                TicketRequest.Reset();
                TicketRequest.SetFilter(Quantity, '<>0');
                TicketRequest.SetRange("Session Token ID", Token);
                TicketRequest.FindSet();
                repeat
                    TicketManagement.RescheduleDynamicTicketAdmission(Ticket."No.", TicketRequest."External Adm. Sch. Entry No.", true, TicketRequest."Request Status Date Time", POSSession, SalesReceiptNumber, TicketRequest."Entry No.");
                until (TicketRequest.Next() = 0);
            until (Ticket.Next() = 0);

        Commit();

        ExternalId.Add(TicketRequest."Ext. Line Reference No.");
        TicketWebRequestManager.FinalizeTicketReservation(Token, ExternalId);

        Commit();

        UpdateTicketReservationAfterFinalize(Token, SalesReceiptNumber, Ticket."No.");

        Success := true;
    end;

    local procedure UpdateTicketReservationAfterFinalize(Token: Text[100]; SalesReceiptNumber: Code[20]; TicketNo: Code[20])
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DtldTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        TicketRequest.SetFilter(Quantity, '<>0');
        TicketRequest.SetRange("Session Token ID", Token);
        if TicketRequest.FindSet() then
            repeat
                if (TicketRequest."External Adm. Sch. Entry No." > 0) then begin
                    ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketRequest."External Adm. Sch. Entry No.");
                    ScheduleEntry.SetFilter(Cancelled, '=%1', false);
                    if (ScheduleEntry.FindFirst()) then
                        TicketRequest."Scheduled Time Description" := StrSubstNo('%1 - %2', ScheduleEntry."Admission Start Date", ScheduleEntry."Admission Start Time");

                    if TicketRequest."Admission Inclusion" = TicketRequest."Admission Inclusion"::REQUIRED then
                        TicketRequest."Payment Option" := TicketRequest."Payment Option"::UNPAID;
                end else begin
                    if TicketRequest."Admission Inclusion" = TicketRequest."Admission Inclusion"::NOT_SELECTED then begin
                        TicketRequest."Request Status" := TicketRequest."Request Status"::OPTIONAL;
                        TicketRequest.Quantity := 0;

                        Clear(TicketAccessEntry);
                        TicketAccessEntry.SetRange("Ticket No.", TicketNo);
                        TicketAccessEntry.SetRange("Admission Code", TicketRequest."Admission Code");
                        TicketAccessEntry.FindFirst();

                        DtldTicketAccessEntry.SetRange("Ticket Access Entry No.", TicketAccessEntry."Entry No.");
                        DtldTicketAccessEntry.SetRange(Type, DtldTicketAccessEntry.Type::PAYMENT);
                        if not DtldTicketAccessEntry.IsEmpty() then begin
                            case TicketAccessEntry.Status of
                                TicketAccessEntry.Status::ACCESS:
                                    TicketAccessEntry.Status := TicketAccessEntry.Status::BLOCKED;
                            end;
                            TicketAccessEntry.Modify();
                        end;
                    end;
                end;

                TicketRequest."Receipt No." := SalesReceiptNumber;
                TicketRequest.Modify();
            until (TicketRequest.Next() = 0);

        Commit();
    end;

    local procedure SetTicketRequestInfo(TicketRequest: Record "NPR TM Ticket Reservation Req."; Lines: JsonArray; Token: Text[100]): Boolean
    var
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Line: JsonToken;
        ResolvingTable: Integer;
        INVALID_ITEM_REFERENCE: Label 'Reference %1 does not resolve to neither an item reference nor an item number.';
    begin
        Clear(TicketRequest);
        TicketRequest.SetFilter("Session Token ID", '=%1', Token);
        if not TicketRequest.FindSet() then
            exit(false);

        foreach Line in Lines do begin
            TicketRequest."External Item Code" := CopyStr(GetAsText(Line.AsObject(), 'itemReference', ''), 1, MaxStrLen(TicketRequest."External Item Code"));
            TicketRequest.Quantity := GetAsInteger(Line.AsObject(), 'quantity', 0);
            TicketRequest."External Member No." := CopyStr(GetAsText(Line.AsObject(), 'memberNumber', ''), 1, MaxStrLen(TicketRequest."External Member No."));
            TicketRequest."Admission Code" := CopyStr(GetAsText(Line.AsObject(), 'admissionCode', ''), 1, MaxStrLen(TicketRequest."Admission Code"));
            TicketRequest."External Adm. Sch. Entry No." := GetAsInteger(Line.AsObject(), 'scheduleId', 0);
            TicketRequest."Notification Address" := CopyStr(GetAsText(Line.AsObject(), 'notificationAddress', ''), 1, MaxStrLen(TicketRequest."Notification Address"));
            TicketRequest."Admission Created" := TicketRequest."External Adm. Sch. Entry No." > 0;

            if (not TicketRequestManager.TranslateBarcodeToItemVariant(TicketRequest."External Item Code", TicketRequest."Item No.", TicketRequest."Variant Code", ResolvingTable)) then
                Error(INVALID_ITEM_REFERENCE, TicketRequest."External Item Code");

            TicketBOM.Get(TicketRequest."Item No.", TicketRequest."Variant Code", TicketRequest."Admission Code");
            Admission.Get(TicketRequest."Admission Code");

            TicketRequest.Default := TicketBOM.Default;
            TicketRequest."Admission Inclusion" := TicketBOM."Admission Inclusion";
            if (TicketBOM."Admission Inclusion" <> TicketBOM."Admission Inclusion"::REQUIRED) then
                TicketRequest."Admission Inclusion" := TicketBOM."Admission Inclusion"::SELECTED;

            if ((TicketRequest."Admission Inclusion" = TicketBOM."Admission Inclusion"::SELECTED) and (TicketRequest.Quantity = 0)) then
                TicketRequest."Admission Inclusion" := TicketBOM."Admission Inclusion"::NOT_SELECTED;

            TicketRequest."Admission Description" := Admission.Description;
            TicketRequest.Modify();

            TicketRequest.Next(); //Move to next request line
        end;

        exit(true);
    end;

    local procedure UpdateSalesLine(SalesReceiptNumber: Code[20]; SalesReceiptLineNo: Integer; Token: Text[100])
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRetailManager: Codeunit "NPR TM Ticket Retail Mgt.";
        WalletManager: Codeunit "NPR AttractionWalletCreate";
    begin
        if (SalesReceiptNumber = '') then
            exit;

        SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', SalesReceiptNumber);
        SaleLinePOS.SetFilter("Line No.", '=%1', SalesReceiptLineNo);
        if (not SaleLinePOS.FindFirst()) then
            exit;

        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketRequest.SetFilter("Admission Inclusion", '=%1', TicketRequest."Admission Inclusion"::REQUIRED);
        if (not TicketRequest.FindFirst()) then
            exit;

        TicketRetailManager.AdjustPriceOnSalesLine(SaleLinePOS, TicketRequest.Quantity, Token, TicketRequest."Ext. Line Reference No.");
        SaleLinePOS."Description 2" := TicketRequest."Scheduled Time Description";
        SaleLinePOS.Modify();

        WalletManager.SetQuantityPOSSaleLineWorker(SaleLinePOS, TicketRequest.Quantity);

    end;

    local procedure CheckScheduleId(AdmissionCode: Text; ExternalScheduleId: Integer; var ValidationErrorList: List of [Text])
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        if (not Admission.Get(CopyStr(AdmissionCode, 1, MaxStrLen(Admission."Admission Code")))) then begin
            ValidationErrorList.Add(StrSubstNo('Admission Code %1 is not valid.', AdmissionCode));
            exit;
        end;

        if (ExternalScheduleId > 0) then begin
            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', Admission."Admission Code");
            AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExternalScheduleId);
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
            if (AdmissionScheduleEntry.IsEmpty()) then begin
                ValidationErrorList.Add(StrSubstNo('Schedule Id %1 for Admission Code %2 is not valid.', ExternalScheduleId, AdmissionCode));
                exit;
            end
        end;
    end;

    internal procedure ConfirmRequestAction(ReservationRequest: JsonArray) ResponseText: Text
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        JBuilder: Codeunit "Json Text Reader/Writer";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        RequestToken: JsonToken;
        Request: JsonObject;
        ValidationErrorList: List of [Text];
        Token: Text[100];
        ErrorMessage: Text;
    begin

        JBuilder.WriteStartObject('');

        // request validation
        JBuilder.WriteStartArray('request');
        foreach RequestToken in ReservationRequest do begin
            Request := RequestToken.AsObject();
            Token := CopyStr(GetAsText(Request, 'token', ValidationErrorList), 1, MaxStrLen(Token));

            JBuilder.WriteStartObject('');
            JBuilder.WriteStringProperty('token', Token);
            JBuilder.WriteStringProperty('notificationAddress', GetAsText(Request, 'notificationAddress', ''));
            JBuilder.WriteStringProperty('paymentReference', GetAsText(Request, 'paymentReference', ''));
            JBuilder.WriteStringProperty('ticketHolderName', GetAsText(Request, 'ticketHolderName', ''));

            if (Token <> '') then begin
                TicketRequest.SetCurrentKey("Session Token ID");
                TicketRequest.SetFilter("Session Token ID", '=%1', Token);
                if (not TicketRequest.FindFirst()) then
                    ValidationErrorList.Add(StrSubstNo('Invalid token %1', Token));

                if (not (TicketRequest."Request Status" in [TicketRequest."Request Status"::REGISTERED])) then
                    ValidationErrorList.Add(StrSubstNo('Invalid status on token %1', Token));
            end;
        end;
        JBuilder.WriteEndArray(); // request
        JBuilder.WriteStartArray('response');
        if (ValidationErrorList.Count() = 0) then begin
            // Confirm tickets
            foreach RequestToken in ReservationRequest do begin
                Request := RequestToken.AsObject();
                Token := CopyStr(GetAsText(Request, 'token', ''), 1, MaxStrLen(Token));

                TicketRequestManager.SetReservationRequestExtraInfo(Token,
                    CopyStr(GetAsText(Request, 'notificationAddress', ''), 1, 80),
                    CopyStr(GetAsText(Request, 'paymentReference', ''), 1, 20),
                    CopyStr(GetAsText(Request, 'ticketHolderName', ''), 1, 100)
                    );

                if not (TicketRequestManager.ConfirmReservationRequest(Token, ErrorMessage)) then
                    ValidationErrorList.Add(ErrorMessage);
            end;
        end;

        if (ValidationErrorList.Count() > 0) then
            DumpValidationErrorList(JBuilder, 'Invalid parameters', -101, ValidationErrorList);

        if (ValidationErrorList.Count() = 0) then begin
            // Produce tickets output
            foreach RequestToken in ReservationRequest do begin
                Request := RequestToken.AsObject();
                Token := CopyStr(GetAsText(Request, 'token', ''), 1, MaxStrLen(Token));
                GenerateTicketJson(JBuilder, Token);
            end;
        end;

        JBuilder.WriteEndArray(); // response

        JBuilder.WriteEndObject(); // root
        ResponseText := JBuilder.GetJSonAsText();
        exit(ResponseText);
    end;


    local procedure GetRequestDetails(var JBuilder: Codeunit "Json Text Reader/Writer"; Token: Text[100]; Success: Boolean; ResponseMessage: Text)
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        HaveScheduleEntry: Boolean;
        DurationAsInt: Integer;
    begin
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketRequest.FindSet();

        JBuilder.WriteStartObject('');
        JBuilder.WriteStringProperty('token', Token);
        JBuilder.WriteStringProperty('expiresAt', Format(TicketRequest."Expires Date Time", 0, 9));

        if (Success) then begin
            JBuilder.WriteStringProperty('status', 'OK');
            JBuilder.WriteStringProperty('message', 'Confirmed');
        end else begin
            JBuilder.WriteStringProperty('status', 'ERROR');
            JBuilder.WriteStringProperty('message', ResponseMessage);
        end;

        JBuilder.WriteStartArray('lines');
        repeat

            HaveScheduleEntry := false;
            if (TicketRequest."External Adm. Sch. Entry No." > 0) then begin
                AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketRequest."External Adm. Sch. Entry No.");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                HaveScheduleEntry := AdmissionScheduleEntry.FindFirst();
            end;

            if (not TicketRequest."Admission Created") then begin
                TicketRequest."External Adm. Sch. Entry No." := 0;
                HaveScheduleEntry := false;
            end;

            DurationAsInt := Round((AdmissionScheduleEntry."Admission End Time" - AdmissionScheduleEntry."Admission Start Time") / 1000, 1);

            JBuilder.WriteStartObject('');
            JBuilder.WriteRawProperty('id', TicketRequest."Entry No.");
            JBuilder.WriteStringProperty('itemReference', TicketRequest."External Item Code");
            JBuilder.WriteStringProperty('admissionCode', TicketRequest."Admission Code");
            JBuilder.WriteStringProperty('admissionDescription', TicketRequest."Admission Description");
            JBuilder.WriteBooleanProperty('admissionCreated', TicketRequest."Admission Created");
            JBuilder.WriteRawProperty('quantity', TicketRequest.Quantity);
            JBuilder.WriteBooleanProperty('quantityIsFixed', IsQuantityFixed(TicketRequest));

            JBuilder.WriteStartObject('schedule');
            JBuilder.WriteRawProperty('id', TicketRequest."External Adm. Sch. Entry No.");
            if (HaveScheduleEntry) then begin
                JBuilder.WriteStringProperty('description', StrSubstNo('%1 - %2', Format(AdmissionScheduleEntry."Admission Start Date", 0, 9), Format(AdmissionScheduleEntry."Admission Start Time", 0, 9)));
                JBuilder.WriteStringProperty('startDate', Format(AdmissionScheduleEntry."Admission Start Date", 0, 9));
                JBuilder.WriteStringProperty('startTime', Format(AdmissionScheduleEntry."Admission Start Time", 0, 9));
                JBuilder.WriteStringProperty('endDate', Format(AdmissionScheduleEntry."Admission End Date", 0, 9));
                JBuilder.WriteStringProperty('endTime', Format(AdmissionScheduleEntry."Admission End Time", 0, 9));
                JBuilder.WriteStringProperty('duration', Format(DurationAsInt, 0, 9));
            end else begin
                JBuilder.WriteStringProperty('description', '');
            end;

            JBuilder.WriteEndObject();

            JBuilder.WriteStartObject('included');
            JBuilder.WriteRawProperty('option', TicketRequest."Admission Inclusion");
            JBuilder.WriteStringProperty('description', GetInclusionDescription(TicketRequest."Admission Inclusion"));
            JBuilder.WriteEndObject();

            JBuilder.WriteStartObject('status');
            JBuilder.WriteRawProperty('option', TicketRequest."Request Status");
            JBuilder.WriteStringProperty('description', GetRequestStatusDescription(TicketRequest."Request Status"));
            JBuilder.WriteEndObject();

            JBuilder.WriteEndObject();
        until (TicketRequest.Next() = 0);

        JBuilder.WriteEndArray(); // lines
        JBuilder.WriteEndObject(); // token

    end;

    internal procedure GetAdmissionCapacityAction(AdmissionCapacityRequest: JsonArray) ResponseText: Text
    var
        Request: JsonObject;
        RequestToken: JsonToken;
        ValidationErrorList: List of [Text];
        JBuilder: Codeunit "Json Text Reader/Writer";
    begin
        JBuilder.WriteStartObject('');
        JBuilder.WriteStartArray('request');

        // Validate request - fail fast
        foreach RequestToken in AdmissionCapacityRequest do begin
            Request := RequestToken.AsObject();

            JBuilder.WriteStartObject('');
            JBuilder.WriteStringProperty('requestId', GetAsText(Request, 'requestId', ''));
            JBuilder.WriteStringProperty('itemReference', GetAsText(Request, 'itemReference', ValidationErrorList));
            JBuilder.WriteStringProperty('admissionCode', GetAsText(Request, 'admissionCode', ''));
            JBuilder.WriteStringProperty('referenceDate', Format(GetAsDate(Request, 'referenceDate', ValidationErrorList), 0, 9));
            JBuilder.WriteStringProperty('customerNumber', GetAsText(Request, 'customerNumber', ''));
            JBuilder.WriteNumberProperty('quantity', GetAsInteger(Request, 'quantity', ValidationErrorList));
            JBuilder.WriteEndObject();
        end;
        JBuilder.WriteEndArray(); // request
        JBuilder.WriteStartArray('response');

        if (ValidationErrorList.Count() > 0) then
            DumpValidationErrorList(JBuilder, 'Invalid parameter', -101, ValidationErrorList);

        if (ValidationErrorList.Count() = 0) then
            foreach RequestToken in AdmissionCapacityRequest do begin
                Request := RequestToken.AsObject();
                GenerateAdmissionSchedules(
                    JBuilder,
                    GetAsText(Request, 'requestId', ''),
                    GetAsText(Request, 'itemReference', ValidationErrorList),
                    0,
                    GetAsText(Request, 'admissionCode', ''),
                    GetAsDate(Request, 'referenceDate', ValidationErrorList),
                    GetAsText(Request, 'customerNumber', ''),
                    GetAsInteger(Request, 'quantity', ValidationErrorList)
                );
            end;

        JBuilder.WriteEndArray(); // response
        JBuilder.WriteEndObject(); // root

        ResponseText := JBuilder.GetJSonAsText();
        exit(ResponseText);
    end;

    internal procedure GetScheduleCapacityAction(ScheduleCapacityRequest: JsonArray) ResponseText: Text
    var
        Request: JsonObject;
        ScheduleRequest: JsonToken;
        ValidationErrorList: List of [Text];
        JBuilder: Codeunit "Json Text Reader/Writer";
    begin
        JBuilder.WriteStartObject('');
        JBuilder.WriteStartArray('request');

        // Validate request - fail fast
        foreach ScheduleRequest in ScheduleCapacityRequest do begin
            Request := ScheduleRequest.AsObject();

            JBuilder.WriteStartObject('');
            JBuilder.WriteStringProperty('requestId', GetAsText(Request, 'requestId', ''));
            JBuilder.WriteStringProperty('scheduleId', GetAsInteger(Request, 'scheduleId', ValidationErrorList));
            JBuilder.WriteStringProperty('itemReference', GetAsText(Request, 'itemReference', ValidationErrorList));
            JBuilder.WriteStringProperty('customerNumber', GetAsText(Request, 'customerNumber', ''));
            JBuilder.WriteNumberProperty('quantity', GetAsInteger(Request, 'quantity', ValidationErrorList));
            JBuilder.WriteEndObject();
        end;
        JBuilder.WriteEndArray(); // request
        JBuilder.WriteStartArray('response');

        if (ValidationErrorList.Count() > 0) then
            DumpValidationErrorList(JBuilder, 'Invalid parameter', -101, ValidationErrorList);

        if (ValidationErrorList.Count() = 0) then
            foreach ScheduleRequest in ScheduleCapacityRequest do begin
                Request := ScheduleRequest.AsObject();
                GenerateAdmissionSchedules(
                    JBuilder,
                    GetAsText(Request, 'requestId', ''),
                    GetAsText(Request, 'itemReference', ValidationErrorList),
                    GetAsInteger(Request, 'scheduleId', ValidationErrorList),
                    '',
                    0D,
                    GetAsText(Request, 'customerNumber', ''),
                    GetAsInteger(Request, 'quantity', ValidationErrorList)
                );
            end;

        JBuilder.WriteEndArray(); // response
        JBuilder.WriteEndObject(); // root

        ResponseText := JBuilder.GetJSonAsText();
        exit(ResponseText);
    end;

    local procedure DumpValidationErrorList(var JBuilder: Codeunit "Json Text Reader/Writer"; ReasonText: Text; ReasonId: Integer; ValidationErrorList: List of [Text])
    var
        errorText: Text;
    begin
        JBuilder.WriteStartObject('');
        JBuilder.WriteStringProperty('error', ReasonText);
        JBuilder.WriteStringProperty('errorId', ReasonId);

        JBuilder.WriteStartArray('errorList');
        foreach errorText in ValidationErrorList do begin
            JBuilder.WriteStartObject('');
            JBuilder.WriteStringProperty('error', errorText);
            JBuilder.WriteEndObject();
        end;
        JBuilder.WriteEndArray(); // errorList

        JBuilder.WriteEndObject();
    end;

    local procedure CreateReservation(Lines: JsonArray; var Token: Text[100]; SalesReceiptNumber: Code[20]; SalesReceiptLineNo: Integer; var Success: Boolean; var ResponseMessage: Text)
    var
        TicketWebRequestManager: Codeunit "NPR TM Ticket WebService Mgr";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        TicketResponse: Record "NPR TM Ticket Reserv. Resp.";
        Ticket: Record "NPR TM Ticket";
        AccessEntry: Record "NPR TM Ticket Access Entry";
        DetailedEntry: Record "NPR TM Det. Ticket AccessEntry";
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        Line: JsonToken;
        ExternalId: List of [Integer];
        ResolvingTable: Integer;
        INVALID_ITEM_REFERENCE: Label 'Reference %1 does not resolve to neither an item reference nor an item number.';
    begin
        if (Token = '') then
            Token := CreateToken();

        foreach Line in Lines do begin

            Clear(TicketRequest);
            TicketRequest."Session Token ID" := Token;
            TicketRequest."Request Status" := TicketRequest."Request Status"::WIP;
            TicketRequest."Request Status Date Time" := CurrentDateTime;
            TicketRequest."Created Date Time" := CurrentDateTime();
            TicketRequest."Ext. Line Reference No." := 4711; // External id is to group multiple different tickets withing same token. Not used in this API.

            TicketRequest."External Item Code" := CopyStr(GetAsText(Line.AsObject(), 'itemReference', ''), 1, MaxStrLen(TicketRequest."External Item Code"));
            TicketRequest.Quantity := ValidateChangeQuantity(SalesReceiptNumber, SalesReceiptLineNo, GetAsInteger(Line.AsObject(), 'quantity', 0));
            TicketRequest."External Member No." := CopyStr(GetAsText(Line.AsObject(), 'memberNumber', ''), 1, MaxStrLen(TicketRequest."External Member No."));
            TicketRequest."Admission Code" := CopyStr(GetAsText(Line.AsObject(), 'admissionCode', ''), 1, MaxStrLen(TicketRequest."Admission Code"));
            TicketRequest."External Adm. Sch. Entry No." := GetAsInteger(Line.AsObject(), 'scheduleId', 0);
            TicketRequest."Notification Address" := CopyStr(GetAsText(Line.AsObject(), 'notificationAddress', ''), 1, MaxStrLen(TicketRequest."Notification Address"));

            if (not TicketRequestManager.TranslateBarcodeToItemVariant(TicketRequest."External Item Code", TicketRequest."Item No.", TicketRequest."Variant Code", ResolvingTable)) then
                Error(INVALID_ITEM_REFERENCE, TicketRequest."External Item Code");

            TicketBOM.Get(TicketRequest."Item No.", TicketRequest."Variant Code", TicketRequest."Admission Code");
            Admission.Get(TicketRequest."Admission Code");

            TicketRequest.Default := TicketBOM.Default;
            TicketRequest."Admission Inclusion" := TicketBOM."Admission Inclusion";
            if (TicketBOM."Admission Inclusion" <> TicketBOM."Admission Inclusion"::REQUIRED) then
                TicketRequest."Admission Inclusion" := TicketBOM."Admission Inclusion"::SELECTED;

            if ((TicketRequest."Admission Inclusion" = TicketBOM."Admission Inclusion"::SELECTED) and (TicketRequest.Quantity = 0)) then
                TicketRequest."Admission Inclusion" := TicketBOM."Admission Inclusion"::NOT_SELECTED;

            TicketRequest."Admission Description" := Admission.Description;
            TicketRequest."Receipt No." := SalesReceiptNumber;
            TicketRequest."Line No." := SalesReceiptLineNo;
            TicketRequest.Insert();
        end;

        ExternalId.Add(TicketRequest."Ext. Line Reference No.");
        TicketWebRequestManager.FinalizeTicketReservation(Token, ExternalId);

        // there is only one token primary line, so only one response
        TicketResponse.SetFilter("Session Token ID", '=%1', Token);
        if (TicketResponse.FindFirst()) then
            Success := TicketResponse.Status;

        ResponseMessage := TicketResponse."Response Message";
        if (not Success) then
            exit;

        Ticket.Reset();
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketRequest.FindSet();
        repeat
            if (TicketRequest."Admission Created") then begin
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketResponse."Request Entry No.");
                if (Ticket.FindFirst()) then begin
                    AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                    AccessEntry.SetFilter("Admission Code", '=%1', TicketRequest."Admission Code");
                    if (AccessEntry.FindFirst()) then begin
                        DetailedEntry.SetFilter("Ticket Access Entry No.", '=%1', AccessEntry."Entry No.");
                        DetailedEntry.SetFilter(Quantity, '>%1', 0);
                        DetailedEntry.SetFilter(Type, '=%1', DetailedEntry.Type::RESERVATION);
                        if (not DetailedEntry.FindLast()) then
                            DetailedEntry.SetFilter(Type, '=%1', DetailedEntry.Type::INITIAL_ENTRY);
                        if (not DetailedEntry.FindLast()) then
                            DetailedEntry.init();
                        if (DetailedEntry."External Adm. Sch. Entry No." <> 0) then
                            TicketRequest."External Adm. Sch. Entry No." := DetailedEntry."External Adm. Sch. Entry No.";
                    end;
                end;

                if (TicketRequest."External Adm. Sch. Entry No." > 0) then begin
                    ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TicketRequest."External Adm. Sch. Entry No.");
                    ScheduleEntry.SetFilter(Cancelled, '=%1', false);
                    if (ScheduleEntry.FindFirst()) then
                        TicketRequest."Scheduled Time Description" := StrSubstNo('%1 - %2', ScheduleEntry."Admission Start Date", ScheduleEntry."Admission Start Time");
                end;

                TicketRequest.Modify();
            end;

        until (TicketRequest.Next() = 0);

        // Success = true;
        // ResponseMessage := 'Reservation created successfully.';

    end;

    local procedure GenerateAdmissionSchedules(var JBuilder: Codeunit "Json Text Reader/Writer"; RequestId: Text; ItemReference: Text; ScheduleId: Integer; AdmissionCode: Text; ReferenceDate: Date; CustomerNumber: Text; Quantity: Integer)
    var
        AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer";
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        AdmissionSchedule: Record "NPR TM Admis. Schedule Entry";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        ItemResolver: Integer;
        BomIndex: Integer;
    begin

        if (ScheduleId > 0) and (ReferenceDate = 0D) then begin
            AdmissionSchedule.SetFilter("External Schedule Entry No.", '=%1', ScheduleId);
            AdmissionSchedule.SetFilter(Cancelled, '=%1', false);
            if (not AdmissionSchedule.FindFirst()) then
                Error('Invalid Schedule Id.');
            AdmissionCode := AdmissionSchedule."Admission Code";
            ReferenceDate := AdmissionSchedule."Admission Start Date";
        end;

        AdmCapacityPriceBuffer.RequestId := CopyStr(RequestId, 1, MaxStrLen(AdmCapacityPriceBuffer.RequestId));
        AdmCapacityPriceBuffer.ReferenceDate := ReferenceDate;
        AdmCapacityPriceBuffer.CustomerNo := CopyStr(CustomerNumber, 1, MaxStrLen(AdmCapacityPriceBuffer.CustomerNo));
        AdmCapacityPriceBuffer.Quantity := Quantity;

        AdmCapacityPriceBuffer.ItemReference := CopyStr(ItemReference, 1, MaxStrLen(AdmCapacityPriceBuffer.ItemReference));
        if (not TicketRequestManager.TranslateBarcodeToItemVariant(AdmCapacityPriceBuffer.ItemReference, AdmCapacityPriceBuffer.RequestItemNumber, AdmCapacityPriceBuffer.RequestVariantCode, ItemResolver)) then
            Error('Invalid ItemReference.');

        AdmCapacityPriceBuffer.ItemNumber := AdmCapacityPriceBuffer.RequestItemNumber;
        AdmCapacityPriceBuffer.VariantCode := AdmCapacityPriceBuffer.RequestVariantCode;

        TicketBom.SetFilter("Item No.", '=%1', AdmCapacityPriceBuffer.RequestItemNumber);
        TicketBom.SetFilter("Variant Code", '=%1', AdmCapacityPriceBuffer.RequestVariantCode);
        if (AdmissionCode <> '') then
            TicketBom.SetFilter("Admission Code", '=%1', CopyStr(AdmissionCode, 1, MaxStrLen(TicketBom."Admission Code")));

        if (not TicketBom.FindSet()) then
            Error('Invalid ItemReference.');

        BomIndex := 1;
        repeat
            Admission.Get(TicketBom."Admission Code");

            AdmCapacityPriceBuffer.EntryNo := BomIndex;
            AdmCapacityPriceBuffer.AdmissionCode := TicketBom."Admission Code";
            AdmCapacityPriceBuffer.DefaultAdmission := TicketBom.Default;
            AdmCapacityPriceBuffer.AdmissionInclusion := TicketBom."Admission Inclusion";

            if (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::REQUIRED) then
                if (TicketBom.Default) then
                    TicketPrice.CalculateErpPrice(AdmCapacityPriceBuffer);

            if (TicketBom."Admission Inclusion" <> TicketBom."Admission Inclusion"::REQUIRED) then begin
                AdmCapacityPriceBuffer.ItemNumber := Admission."Additional Experience Item No.";
                AdmCapacityPriceBuffer.VariantCode := '';
                if (AdmCapacityPriceBuffer.ItemNumber <> '') then
                    TicketPrice.CalculateErpPrice(AdmCapacityPriceBuffer);
            end;

            JBuilder.WriteStartObject('');

            JBuilder.WriteStringProperty('requestId', RequestId);
            JBuilder.WriteStringProperty('admissionCode', TicketBom."Admission Code");
            JBuilder.WriteBooleanProperty('default', TicketBom.Default);

            JBuilder.WriteStartObject('included');
            JBuilder.WriteRawProperty('option', TicketBom."Admission Inclusion");
            JBuilder.WriteStringProperty('description', GetInclusionDescription(TicketBom."Admission Inclusion"));
            JBuilder.WriteEndObject();

            JBuilder.WriteStartObject('capacity-control');
            JBuilder.WriteRawProperty('option', Admission."Capacity Control");
            JBuilder.WriteStringProperty('description', GetCapacityControlDescription(Admission."Capacity Control"));
            JBuilder.WriteEndObject();

            JBuilder.WriteStringProperty('customerNumber', CustomerNumber);
            JBuilder.WriteStringProperty('referenceDate', format(ReferenceDate, 0, 9));
            JBuilder.WriteRawProperty('quantity', Quantity);
            JBuilder.WriteNumberProperty('unitPrice', AdmCapacityPriceBuffer.UnitPrice);
            JBuilder.WriteNumberProperty('discountPct', AdmCapacityPriceBuffer.DiscountPct);
            JBuilder.WriteBooleanProperty('priceIncludesVat', AdmCapacityPriceBuffer.UnitPriceIncludesVat);
            JBuilder.WriteNumberProperty('vatPct', AdmCapacityPriceBuffer.UnitPriceVatPercentage);

            JBuilder.WriteStartArray('schedule');
            GenerateAdmissionScheduleEntries(JBuilder, AdmCapacityPriceBuffer, Admission, ScheduleId);
            JBuilder.WriteEndArray();
            JBuilder.WriteEndObject();

            BomIndex += 1;

        until (TicketBom.Next() = 0)
    end;

    local procedure GenerateAdmissionScheduleEntries(var JBuilder: Codeunit "Json Text Reader/Writer"; AdmCapacityPriceBufferResponse: Record "NPR TM AdmCapacityPriceBuffer"; Admission: Record "NPR TM Admission"; ScheduleId: Integer)
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        PriceRule: Record "NPR TM Dynamic Price Rule";
        TicketPrice: Codeunit "NPR TM Dynamic Price";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        BlockSaleReason: Enum "NPR TM Sch. Block Sales Reason";
        HavePriceRule: Boolean;
        IsNonWorking: Boolean;
        BasePrice, AddonPrice : Decimal;
        RemainingCapacity: Integer;
        CapacityStatusCode: Integer;
        CalendarExceptionText: Text;
        DynamicPriceOptionText: Text;
        DynamicPriceOptionId: Integer;
        DynamicCustomerPrice: Decimal;
        CustomerPriceOut: Decimal;
        TimeHelper: Codeunit "NPR TM TimeHelper";
        LocalDateTime: DateTime;
        LocalDate: Date;
        LocalTime: Time;
    begin

        AdmissionScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', AdmCapacityPriceBufferResponse.ReferenceDate);
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmCapacityPriceBufferResponse.AdmissionCode);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (ScheduleId > 0) then
            AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ScheduleId);

        if (not AdmissionScheduleEntry.FindSet()) then
            exit;

        LocalDateTime := TimeHelper.GetLocalTimeAtAdmission(AdmCapacityPriceBufferResponse.AdmissionCode);
        LocalDate := DT2Date(LocalDateTime);
        LocalTime := DT2Time(LocalDateTime);

        AdmissionScheduleEntry.FindSet();
        repeat
            CapacityStatusCode := _CapacityStatusCodeOption::OK;

            if (not TicketManagement.ValidateAdmSchEntryForSales(AdmissionScheduleEntry,
                        AdmCapacityPriceBufferResponse.RequestItemNumber,
                        AdmCapacityPriceBufferResponse.RequestVariantCode,
                        LocalDate, LocalTime,
                        BlockSaleReason, RemainingCapacity)) then begin
                CapacityStatusCode := _CapacityStatusCodeOption::CAPACITY_EXCEEDED;
                if (BlockSaleReason = BlockSaleReason::ScheduleExceedTicketDuration) then
                    exit;
            end;

            if (RemainingCapacity < 1) and (Admission."Capacity Control" <> Admission."Capacity Control"::NONE) then begin
                CapacityStatusCode := _CapacityStatusCodeOption::CAPACITY_EXCEEDED;
                BlockSaleReason := BlockSaleReason::RemainingCapacityZeroOrLess;
            end;

            HavePriceRule := TicketPrice.SelectPriceRule(AdmissionScheduleEntry, AdmCapacityPriceBufferResponse.ItemNumber, AdmCapacityPriceBufferResponse.VariantCode, Today(), Time(), PriceRule);
            if (HavePriceRule) then
                TicketPrice.EvaluatePriceRule(PriceRule, AdmCapacityPriceBufferResponse.UnitPrice, AdmCapacityPriceBufferResponse.UnitPriceIncludesVat, AdmCapacityPriceBufferResponse.UnitPriceVatPercentage, false, BasePrice, AddonPrice);

            TicketManagement.CheckTicketBaseCalendar(AdmCapacityPriceBufferResponse.AdmissionCode,
                AdmCapacityPriceBufferResponse.RequestItemNumber,
                AdmCapacityPriceBufferResponse.RequestVariantCode,
                AdmCapacityPriceBufferResponse.ReferenceDate,
                IsNonWorking,
                CalendarExceptionText);

            if (IsNonWorking) then
                CapacityStatusCode := _CapacityStatusCodeOption::NON_WORKING;

            if ((CapacityStatusCode = _CapacityStatusCodeOption::OK) and (CalendarExceptionText <> '')) then
                CapacityStatusCode := _CapacityStatusCodeOption::CALENDAR_WARNING;

            if (CapacityStatusCode = _CapacityStatusCodeOption::OK) then begin
                if (AdmissionScheduleEntry."Admission Is" = AdmissionScheduleEntry."Admission Is"::CLOSED) then
                    CapacityStatusCode := _CapacityStatusCodeOption::CLOSED;
                if (AdmissionScheduleEntry."Admission End Date" < LocalDate) then
                    CapacityStatusCode := _CapacityStatusCodeOption::CLOSED;
                if ((AdmissionScheduleEntry."Admission End Date" = LocalDate) and (AdmissionScheduleEntry."Admission End Time" < LocalTime)) then
                    CapacityStatusCode := _CapacityStatusCodeOption::CLOSED;
            end;

            DynamicCustomerPrice := AdmCapacityPriceBufferResponse.UnitPrice;
            if (HavePriceRule) then begin
                case (PriceRule.PricingOption) of
                    PriceRule.PricingOption::NA:
                        begin
                            DynamicPriceOptionText := '';
                            DynamicPriceOptionId := 0;
                            DynamicCustomerPrice := AdmCapacityPriceBufferResponse.UnitPrice;
                        end;
                    PriceRule.PricingOption::FIXED:
                        begin
                            DynamicPriceOptionText := 'fixed_amount';
                            DynamicPriceOptionId := 1;
                            DynamicCustomerPrice := BasePrice;
                        end;
                    PriceRule.PricingOption::RELATIVE:
                        begin
                            DynamicPriceOptionText := 'relative_amount';
                            DynamicPriceOptionId := 2;
                            DynamicCustomerPrice := AdmCapacityPriceBufferResponse.UnitPrice + AddonPrice;
                        end;
                    PriceRule.PricingOption::PERCENT:
                        begin
                            DynamicPriceOptionText := 'percentage';
                            DynamicPriceOptionId := 3;
                            DynamicCustomerPrice := AdmCapacityPriceBufferResponse.UnitPrice + AddonPrice;
                        end;
                end;
            end;

            if (DynamicCustomerPrice < 0) then
                DynamicCustomerPrice := 0;

            CustomerPriceOut := (AdmCapacityPriceBufferResponse.Quantity * DynamicCustomerPrice - AdmCapacityPriceBufferResponse.Quantity * DynamicCustomerPrice * AdmCapacityPriceBufferResponse.DiscountPct / 100);

            if (RemainingCapacity < 0) then
                RemainingCapacity := 0;

            JBuilder.WriteStartObject('');
            JBuilder.WriteRawProperty('id', AdmissionScheduleEntry."External Schedule Entry No.");
            JBuilder.WriteStringProperty('scheduleCode', AdmissionScheduleEntry."Schedule Code");
            JBuilder.WriteStringProperty('startDate', Format(AdmissionScheduleEntry."Admission Start Date", 0, 9));
            JBuilder.WriteStringProperty('startTime', Format(AdmissionScheduleEntry."Admission Start Time", 0, 9));
            JBuilder.WriteStringProperty('endDate', Format(AdmissionScheduleEntry."Admission End Date", 0, 9));
            JBuilder.WriteStringProperty('endTime', Format(AdmissionScheduleEntry."Admission End Time", 0, 9));
            JBuilder.WriteBooleanProperty('status', CapacityStatusCode in [_CapacityStatusCodeOption::OK, _CapacityStatusCodeOption::CALENDAR_WARNING]);
            JBuilder.WriteRawProperty('remaining', RemainingCapacity);

            JBuilder.WriteStartObject('message');
            JBuilder.WriteRawProperty('option', CapacityStatusCode);
            JBuilder.WriteStringProperty('description', GetMessageText(CapacityStatusCode, CalendarExceptionText, BlockSaleReason.AsInteger()));
            JBuilder.WriteEndObject();

            JBuilder.WriteStartObject('allocationBy');
            JBuilder.WriteRawProperty('option', AdmissionScheduleEntry."Allocation By");
            JBuilder.WriteStringProperty('description', GetAllocationByCaption(AdmissionScheduleEntry."Allocation By"));
            JBuilder.WriteEndObject();

            JBuilder.WriteStringProperty('eventArrivalFromTime', Format(AdmissionScheduleEntry."Event Arrival From Time", 0, 9));
            JBuilder.WriteStringProperty('eventArrivalUntilTime', Format(AdmissionScheduleEntry."Event Arrival Until Time", 0, 9));
            JBuilder.WriteStringProperty('salesFromDate', Format(AdmissionScheduleEntry."Sales From Date", 0, 9));
            JBuilder.WriteStringProperty('salesFromTime', Format(AdmissionScheduleEntry."Sales From Time", 0, 9));
            JBuilder.WriteStringProperty('salesUntilDate', Format(AdmissionScheduleEntry."Sales Until Date", 0, 9));
            JBuilder.WriteStringProperty('salesUntilTime', Format(AdmissionScheduleEntry."Sales Until Time", 0, 9));

            JBuilder.WriteStartObject('dynamicPrice');
            JBuilder.WriteRawProperty('option', DynamicPriceOptionId);
            JBuilder.WriteStringProperty('description', DynamicPriceOptionText);
            JBuilder.WriteNumberProperty('priceAmount', PriceRule.Amount);
            JBuilder.WriteNumberProperty('pricePercentage', PriceRule.Percentage);
            JBuilder.WriteNumberProperty('unitPrice', DynamicCustomerPrice);
            JBuilder.WriteEndObject();

            JBuilder.WriteNumberProperty('customerPriceInclDiscount', TicketPrice.RoundAmount(CustomerPriceOut, PriceRule.RoundingPrecision, PriceRule.RoundingDirection));
            JBuilder.WriteEndObject();

        until (AdmissionScheduleEntry.Next() = 0);
    end;

    local procedure GenerateTicketJson(var JBuilder: Codeunit "Json Text Reader/Writer"; Token: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        TicketResponse: Record "NPR TM Ticket Reserv. Resp.";
        Ticket: Record "NPR TM Ticket";
        AccessEntry: Record "NPR TM Ticket Access Entry";
        DetailedEntry: Record "NPR TM Det. Ticket AccessEntry";
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketDescription: Record "NPR TM TempTicketDescription";
        CastToInteger: Integer;
    begin
        if (not TicketSetup.Get()) then
            TicketSetup.Init();

        JBuilder.WriteStartObject('');
        JBuilder.WriteStringProperty('token', Token);

        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketRequest.FindFirst();

        TicketResponse.SetCurrentKey("Session Token ID");
        TicketResponse.SetFilter("Session Token ID", '=%1', Token);
        if (TicketResponse.FindFirst()) then begin
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketResponse."Request Entry No.");
            if (Ticket.FindSet()) then begin

                JBuilder.WriteStartArray('tickets');
                repeat

                    JBuilder.WriteStartObject('');
                    JBuilder.WriteStringProperty('itemReference', TicketRequest."External Item Code");
                    JBuilder.WriteStringProperty('ticketId', Ticket."External Ticket No.");
                    JBuilder.WriteStringProperty('barcode', Ticket."External Ticket No.");
                    JBuilder.WriteStringProperty('validFrom', Format(Ticket."Valid From Date", 0, 9));
                    JBuilder.WriteStringProperty('validUntil', Format(Ticket."Valid To Date", 0, 9));
                    JBuilder.WriteStringProperty('availableAsETicket', TicketRequestManager.IsETicket(Ticket."No."));
                    JBuilder.WriteStringProperty('pinCode', TicketRequest."Authorization Code");

                    AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                    if (AccessEntry.FindSet()) then begin

                        JBuilder.WriteStartArray('admissions');
                        repeat

                            TicketDescription.Init();
                            TicketDescription.SetKeyAndDescription(Ticket."Item No.", Ticket."Variant Code", AccessEntry."Admission Code", TicketSetup."Store Code");
                            if (Admission.Get(AccessEntry."Admission Code")) then
                                if (Admission."Additional Experience Item No." <> '') then
                                    TicketDescription.SetDescription(Admission."Additional Experience Item No.", '', AccessEntry."Admission Code", TicketSetup."Store Code");

                            JBuilder.WriteStartObject('');
                            JBuilder.WriteStringProperty('admissionCode', AccessEntry."Admission Code");
                            CastToInteger := AccessEntry.Quantity;
                            JBuilder.WriteRawProperty('quantity', CastToInteger);
                            JBuilder.WriteStringProperty('name', TicketDescription.Name);
                            JBuilder.WriteStringProperty('description', TicketDescription.Description);

                            DetailedEntry.SetFilter("Ticket Access Entry No.", '=%1', AccessEntry."Entry No.");
                            DetailedEntry.SetFilter(Quantity, '>%1', 0);
                            DetailedEntry.SetFilter(Type, '=%1', DetailedEntry.Type::RESERVATION);
                            if (DetailedEntry.FindLast()) then begin
                                JBuilder.WriteStartObject('reservation');
                                JBuilder.WriteRawProperty('id', DetailedEntry."External Adm. Sch. Entry No.");

                                ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetailedEntry."External Adm. Sch. Entry No.");
                                ScheduleEntry.SetFilter(Cancelled, '=%1', false);
                                if (ScheduleEntry.FindFirst()) then begin
                                    JBuilder.WriteStringProperty('startDate', Format(ScheduleEntry."Admission Start Date", 0, 9));
                                    JBuilder.WriteStringProperty('startTime', Format(ScheduleEntry."Admission Start Time", 0, 9));
                                    JBuilder.WriteStringProperty('endDate', Format(ScheduleEntry."Admission End Date", 0, 9));
                                    JBuilder.WriteStringProperty('endTime', Format(ScheduleEntry."Admission End Time", 0, 9));
                                end;
                                JBuilder.WriteEndObject();
                            end;
                            JBuilder.WriteEndObject();

                        until (AccessEntry.Next() = 0);
                        JBuilder.WriteEndArray();

                    end;
                    JBuilder.WriteEndObject();

                until (Ticket.Next() = 0);
                JBuilder.WriteEndArray();

            end;
        end;

        JBuilder.WriteEndObject();
    end;

    local procedure ValidateChangeQuantity(SalesReceiptNo: Code[20]; SalesReceiptLineNo: Integer; NewQuantity: Integer): Integer
    var
        QUANTITY_IS_FIXED: Label 'The quantity of Item AddOn dependent line is fixed and cannot be changed in this way.';
        CurrentQuantity: Decimal;
    begin
        if (IsQuantityFixed(SalesReceiptNo, SalesReceiptLineNo, CurrentQuantity)) then
            if (CurrentQuantity <> NewQuantity) then begin
                Message(QUANTITY_IS_FIXED);
                exit(CurrentQuantity);
            end;

        exit(NewQuantity);
    end;

    local procedure IsQuantityFixed(TicketRequest: Record "NPR TM Ticket Reservation Req."): Boolean
    var
        SalesQuantity: Decimal;
    begin
        exit(IsQuantityFixed(TicketRequest."Receipt No.", TicketRequest."Line No.", SalesQuantity));
    end;

    local procedure IsQuantityFixed(SalesReceiptNo: Code[20]; SalesReceiptLineNo: Integer; var SalesQuantity: Decimal) FixedQuantity: Boolean
    var
        PosSaleLine: Record "NPR POS Sale Line";
        ItemSaleAddOn: Record "NPR NpIa SaleLinePOS AddOn";
    begin
        FixedQuantity := false;

        PosSaleLine.SetFilter("Sales Ticket No.", '=%1', SalesReceiptNo);
        PosSaleLine.SetFilter("Line No.", '=%1', SalesReceiptLineNo);
        if (not PosSaleLine.FindFirst()) then
            exit(false);

        SalesQuantity := PosSaleLine.Quantity;

        if (PosSaleLine.Indentation > 0) then begin
            ItemSaleAddOn.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Type", "Sale Date", "Sale Line No.", "Line No.");
            ItemSaleAddOn.SetFilter("Register No.", '=%1', PosSaleLine."Register No.");
            ItemSaleAddOn.SetFilter("Sales Ticket No.", '=%1', PosSaleLine."Sales Ticket No.");
            ItemSaleAddOn.SetFilter("Sale Type", '=%1', PosSaleLine."Sale Type");
            ItemSaleAddOn.SetFilter("Sale Date", '=%1', PosSaleLine."Date");
            ItemSaleAddOn.SetFilter("Sale Line No.", '=%1', PosSaleLine."Line No.");
            if (ItemSaleAddOn.FindFirst()) then begin
                FixedQuantity := ItemSaleAddOn."Fixed Quantity";
            end;
        end;

    end;


    local procedure GetMessageText(CapacityStatusCode: Option; ReasonText: Text; BlockSalesReason: Integer): Text
    var
        ResponseLbl: Label 'Capacity Status Code %1 does not have a dedicated message.';
        OK: Label 'Ok.';
        CAPACITY_EXCEEDED: Label 'Capacity Exceeded (code %1).';
        CLOSED: Label 'Closed.';
    begin
        case CapacityStatusCode of
            _CapacityStatusCodeOption::OK:
                exit(OK);
            _CapacityStatusCodeOption::NON_WORKING:
                exit(ReasonText);
            _CapacityStatusCodeOption::CAPACITY_EXCEEDED:
                exit(StrSubstNo(CAPACITY_EXCEEDED, BlockSalesReason));
            _CapacityStatusCodeOption::CALENDAR_WARNING:
                exit(ReasonText);
            _CapacityStatusCodeOption::CLOSED:
                exit(CLOSED);
            else
                exit(StrSubstNo(ResponseLbl, CapacityStatusCode));
        end;
    end;

    local procedure GetAllocationByCaption(AllocationBy: Option) Description: Text
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        case AllocationBy of
            AdmissionScheduleEntry."Allocation By"::CAPACITY:
                Description := 'capacity';
            AdmissionScheduleEntry."Allocation By"::WAITINGLIST:
                Description := 'waitinglist';
        end;
    end;

    local procedure GetInclusionDescription(AdmissionIncluded: Option) Description: Text
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        case AdmissionIncluded of
            TicketBom."Admission Inclusion"::REQUIRED:
                Description := 'required';
            TicketBom."Admission Inclusion"::SELECTED:
                Description := 'selected';
            TicketBom."Admission Inclusion"::NOT_SELECTED:
                Description := 'not_selected';
        end;
    end;

    local procedure GetCapacityControlDescription(CapacityControl: Option) Description: Text
    var
        Admission: Record "NPR TM Admission";
    begin
        case CapacityControl of
            Admission."Capacity Control"::SALES:
                Description := 'sales';
            Admission."Capacity Control"::ADMITTED:
                Description := 'admitted';
            Admission."Capacity Control"::FULL:
                Description := 'admitted_and_departed';
            Admission."Capacity Control"::NONE:
                Description := 'none';
        end;
    end;

    local procedure GetRequestStatusDescription(RequestStatus: Option) Description: Text
    var
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        case RequestStatus of
            TicketRequest."Request Status"::CANCELED:
                Description := 'canceled';
            TicketRequest."Request Status"::CONFIRMED:
                Description := 'confirmed';
            TicketRequest."Request Status"::EXPIRED:
                Description := 'expired';
            TicketRequest."Request Status"::OPTIONAL:
                Description := 'optional';
            TicketRequest."Request Status"::REGISTERED:
                Description := 'registered';
            TicketRequest."Request Status"::RESERVED:
                Description := 'reserved';
            TicketRequest."Request Status"::WAITINGLIST:
                Description := 'waitinglist';
            TicketRequest."Request Status"::WIP:
                Description := 'work-in-progress';
        end;
    end;

    local procedure GetAsText(JObject: JsonObject; JKey: Text; ValidationErrorList: List of [Text]) TextValue: Text
    var
        JToken: JsonToken;
    begin
        TextValue := '';
        if (not JObject.Contains(JKey)) then
            ValidationErrorList.Add(StrSubstNo('Mandatory key %1 missing in request.', JKey));

        JObject.Get(JKey, JToken);
        TextValue := JToken.AsValue().AsText();
        if (TextValue = '') then
            ValidationErrorList.Add(StrSubstNo('Mandatory key %1 is missing value.', JKey));
    end;

    local procedure GetAsText(JObject: JsonObject; JKey: Text; DefaultValue: Text): Text
    var
        JToken: JsonToken;
    begin
        if (not JObject.Contains(JKey)) then
            exit(DefaultValue);

        JObject.Get(JKey, JToken);
        exit(JToken.AsValue().AsText());
    end;

    local procedure GetAsInteger(JObject: JsonObject; JKey: Text; ValidationErrorList: List of [Text]) IntValue: Integer
    var
        JToken: JsonToken;
    begin
        IntValue := 0;
        if (not JObject.Contains(JKey)) then
            ValidationErrorList.Add(StrSubstNo('Mandatory key %1 missing in request.', JKey));

        JObject.Get(JKey, JToken);
        if (not Evaluate(IntValue, JToken.AsValue().AsText(), 9)) then
            ValidationErrorList.Add(StrSubstNo('Integer value %1 not in expected format.', JToken.AsValue().AsText()));
    end;

    local procedure GetAsInteger(JObject: JsonObject; JKey: Text; DefaultValue: Integer) IntValue: Integer
    var
        JToken: JsonToken;
    begin
        IntValue := 0;
        if (not JObject.Contains(JKey)) then
            exit(DefaultValue);

        JObject.Get(JKey, JToken);
        if (not Evaluate(IntValue, JToken.AsValue().AsText(), 9)) then
            exit(DefaultValue);

        exit(IntValue);
    end;

    local procedure GetAsDate(JObject: JsonObject; JKey: Text; ValidationErrorList: List of [Text]) DateValue: Date
    var
        JToken: JsonToken;
    begin
        DateValue := 0D;
        if (not JObject.Contains(JKey)) then
            ValidationErrorList.Add(StrSubstNo('Mandatory key %1 missing in request.', JKey));

        JObject.Get(JKey, JToken);
        if (not Evaluate(DateValue, JToken.AsValue().AsText(), 9)) then
            ValidationErrorList.Add(StrSubstNo('Date value %1 not in expected format (YYYY-MM-DD).', JToken.AsValue().AsText()));
    end;

#pragma warning disable AA0139
    local procedure CreateToken(): Text[100]
    begin
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;

#pragma warning restore

}