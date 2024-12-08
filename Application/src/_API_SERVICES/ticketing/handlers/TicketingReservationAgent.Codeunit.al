#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185083 "NPR TicketingReservationAgent"
{
    Access = Internal;

    var
        _Translation: Codeunit "NPR TicketingApiTranslations";

    internal procedure CreateReservation(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        exit(CreateUpdateReservation(Request, true));
    end;

    internal procedure UpdateReservation(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        exit(CreateUpdateReservation(Request, false));
    end;

    internal procedure CancelReservation(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ReservationId: Text[100];
    begin
        ReservationId := CopyStr(Request.Paths().Get(3), 1, MaxStrLen(ReservationId));
        exit(CancelReservation(ReservationId));
    end;

    internal procedure GetReservation(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ReservationId: Text[100];
    begin
        ReservationId := CopyStr(Request.Paths().Get(3), 1, MaxStrLen(ReservationId));
        exit(GetReservation(ReservationId));
    end;

    internal procedure PreConfirmReservation(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ReservationId: Text[100];
        TicketRequestManager: Codeunit "NPR TM Ticket WebService Mgr";
    begin
        ReservationId := CopyStr(Request.Paths().Get(3), 1, MaxStrLen(ReservationId));
        TicketRequestManager.PreConfirmReservationRequest(ReservationId);

        exit(GetReservation(ReservationId));
    end;

    internal procedure ConfirmReservation(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ReservationId: Text[100];
        Body: JsonObject;
        JValueToken: JsonToken;
        TicketHolderName: Text[100];
        NotificationAddress: Text[80];
        PaymentReference: Code[20];
        ErrorMessage: Text;
    begin
        ReservationId := CopyStr(Request.Paths().Get(3), 1, MaxStrLen(ReservationId));

        Body := Request.BodyJson().AsObject();
        if (Body.Get('ticketHolder', JValueToken)) then
            TicketHolderName := CopyStr(JValueToken.AsValue().AsText(), 1, MaxStrLen(TicketHolderName));

        if (Body.Get('notificationAddress', JValueToken)) then
            NotificationAddress := CopyStr(JValueToken.AsValue().AsText(), 1, MaxStrLen(NotificationAddress));

        if (Body.Get('paymentReference', JValueToken)) then
            PaymentReference := CopyStr(JValueToken.AsValue().AsText(), 1, MaxStrLen(PaymentReference));

        if (not ConfirmReservation(ReservationId, TicketHolderName, NotificationAddress, PaymentReference, ErrorMessage)) then
            exit(Response.RespondBadRequest('Error confirming reservation: ' + ErrorMessage));

        exit(GetReservation(ReservationId));
    end;

    internal procedure GetReservationTickets(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ReservationId: Text[100];
        StoreCode: Code[32];
    begin
        ReservationId := CopyStr(Request.Paths().Get(3), 1, MaxStrLen(ReservationId));

        if (Request.QueryParams().ContainsKey('storeCode')) then
            StoreCode := CopyStr(UpperCase(Request.QueryParams().Get('storeCode')), 1, MaxStrLen(StoreCode));

        exit(GetTickets(ReservationId, StoreCode));
    end;

    // ******************************
    // Internal functions
    internal procedure GetReservation(Token: Code[100]) Response: Codeunit "NPR API Response"
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        ResponseJson: Codeunit "NPR Json Builder";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        if (not TicketReservationRequest.FindFirst()) then
            exit(Response.RespondResourceNotFound(StrSubstNo('The reservation with ID %1 was not found.', Token)));

        ResponseJson.StartObject()
            .AddProperty('token', Token)
            .AddProperty('reservationStatus', _Translation.EncodeRequestStatus(TicketReservationRequest."Request Status"))
            .AddProperty('expiresAt', GetExpiryDateTimeValue(TicketReservationRequest))
            .AddArray(ReservationDTO(ResponseJson, 'reservations', Token))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure CancelReservation(Token: Code[100]) Response: Codeunit "NPR API Response"
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        ResponseJson: Codeunit "NPR Json Builder";
    begin
        TicketRequestManager.DeleteReservationTokenRequest(Token);

        ResponseJson.StartObject()
            .AddProperty('token', Token)
            .AddProperty('reservationStatus', _Translation.EncodeRequestStatus(TicketReservationRequest."Request Status"::CANCELED))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure CreateUpdateReservation(var Request: Codeunit "NPR API Request"; Create: Boolean) Response: Codeunit "NPR API Response"
    var
        ReservationId: Text;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Body, Reservation, ContentLine : JsonObject;
        ReservationToken, ContentLineToken : JsonToken;
        ItemNo: Code[20];
        Quantity: Integer;
        AdmissionCode: Code[20];
        ScheduleId: Integer;
        JValueToken: JsonToken;
        Lines, Reservations : JsonArray;
        Line: JsonObject;
        ExternalLineNo: Integer;
        Token: Text[100];
        Success: Boolean;
        ResponseMessage: Text;
        TicketBOM: Record "NPR TM Ticket Admission BOM";
    begin
        if (not Create) then begin
            ReservationId := Request.Paths().Get(3);
            TicketReservationRequest.SetCurrentKey("Session Token ID");
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', CopyStr(ReservationId, 1, MaxStrLen(TicketReservationRequest."Session Token ID")));
            if (not TicketReservationRequest.FindFirst()) then
                exit(Response.RespondResourceNotFound(StrSubstNo('The reservation with ID %1 was not found or has an invalid state.', ReservationId)));
            Token := TicketReservationRequest."Session Token ID";
        end;

        Body := Request.BodyJson().AsObject();
        if (not Body.Get('reserve', JValueToken)) then
            exit(Response.RespondBadRequest('The reserve property is missing in the request body.'));

        Reservations := JValueToken.AsArray();
        foreach ReservationToken in Reservations do begin
            Reservation := ReservationToken.AsObject();

            if (not Reservation.Get('itemNumber', JValueToken)) then
                exit(Response.RespondBadRequest('The itemNumber property is missing in the request body.'));
            ItemNo := CopyStr(JValueToken.AsValue().AsText(), 1, MaxStrLen(ItemNo));

            if (not Reservation.Get('quantity', JValueToken)) then
                exit(Response.RespondBadRequest('The quantity property is missing in the request body.'));
            Quantity := JValueToken.AsValue().AsInteger();

            ExternalLineNo += 1;

            if (Reservation.Get('content', JValueToken)) then begin
                if (not JValueToken.IsArray()) then
                    exit(Response.RespondBadRequest('The content property must be an array.'));
                if (JValueToken.AsArray().Count() = 0) then
                    exit(Response.RespondBadRequest('The content property must contain at least one item.'));

                foreach ContentLineToken in JValueToken.AsArray() do begin
                    if (not ContentLineToken.IsObject()) then
                        exit(Response.RespondBadRequest('The content property must contain objects.'));

                    ContentLine := ContentLineToken.AsObject();
                    AdmissionCode := CopyStr(GetAsText(ContentLine, 'admissionCode', ''), 1, MaxStrLen(AdmissionCode));
                    ScheduleId := GetAsInteger(ContentLine, 'scheduleId', -1);

                    Clear(Line);
                    Line.Add('itemReference', ItemNo);
                    Line.Add('quantity', Quantity);
                    Line.Add('admissionCode', AdmissionCode);
                    Line.Add('scheduleId', ScheduleId);
                    Line.Add('externalLineReference', ExternalLineNo);
                    Line.Add('memberNumber', '');
                    Line.Add('notificationAddress', '');
                    Lines.Add(Line);
                end;
            end else begin
                TicketBOM.SetFilter("Item No.", '=%1', ItemNo);
                TicketBOM.SetFilter("Default", '=%1', true);
                if (not TicketBOM.FindFirst()) then
                    exit(Response.RespondBadRequest(StrSubstNo('The item number %1 does not have a default admission.', ItemNo)));
                Clear(Line);
                Line.Add('itemReference', ItemNo);
                Line.Add('quantity', Quantity);
                Line.Add('admissionCode', TicketBOM."Admission Code");
                Line.Add('scheduleId', -1);
                Line.Add('externalLineReference', ExternalLineNo);
                Line.Add('memberNumber', '');
                Line.Add('notificationAddress', '');
                Lines.Add(Line);
            end;
        end;

        if (not CreateReservation(Lines, Token, '', 0, Success, ResponseMessage)) then begin
            if (ResponseMessage.StartsWith('[-1015]')) then
                exit(Response.CreateErrorResponse(Enum::"NPR API Error Code"::capacity_exceeded, ResponseMessage));

            exit(Response.RespondBadRequest(ResponseMessage));
        end;

        exit(GetReservation(Token));
    end;

    internal procedure CreateReservation(Lines: JsonArray; var Token: Text[100]; SalesReceiptNumber: Code[20]; SalesReceiptLineNo: Integer; var Success: Boolean; var ResponseMessage: Text): Boolean
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
        LineToken: JsonToken;
        ExternalId: List of [Integer];
        ResolvingTable: Integer;
        INVALID_ITEM_REFERENCE: Label 'Reference %1 does not resolve to neither an item reference nor an item number.';
    begin
        TicketRequestManager.ExpireReservationRequests();

        if (Token <> '') then
            TicketRequestManager.DeleteReservationRequest(Token, true);

        if (Token = '') then
            Token := CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, MaxStrLen(Token));

        foreach LineToken in Lines do begin

            Clear(TicketRequest);
            TicketRequest."Session Token ID" := Token;
            TicketRequest."Request Status" := TicketRequest."Request Status"::WIP;
            TicketRequest."Request Status Date Time" := CurrentDateTime;
            TicketRequest."Created Date Time" := CurrentDateTime();
            TicketRequest."Ext. Line Reference No." := GetAsInteger(LineToken.AsObject(), 'externalLineReference', 1);

            TicketRequest."External Item Code" := CopyStr(GetAsText(LineToken.AsObject(), 'itemReference', ''), 1, MaxStrLen(TicketRequest."External Item Code"));
            TicketRequest.Quantity := GetAsInteger(LineToken.AsObject(), 'quantity', 0);
            TicketRequest."External Member No." := CopyStr(GetAsText(LineToken.AsObject(), 'memberNumber', ''), 1, MaxStrLen(TicketRequest."External Member No."));
            TicketRequest."Admission Code" := CopyStr(GetAsText(LineToken.AsObject(), 'admissionCode', ''), 1, MaxStrLen(TicketRequest."Admission Code"));
            TicketRequest."External Adm. Sch. Entry No." := GetAsInteger(LineToken.AsObject(), 'scheduleId', 0);
            TicketRequest."Notification Address" := CopyStr(GetAsText(LineToken.AsObject(), 'notificationAddress', ''), 1, MaxStrLen(TicketRequest."Notification Address"));

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

            if (not (ExternalId.Contains(TicketRequest."Ext. Line Reference No."))) then
                ExternalId.Add(TicketRequest."Ext. Line Reference No.");
        end;

        Success := TicketWebRequestManager.FinalizeTicketReservation(Token, ExternalId);
        if (not Success) then begin
            ResponseMessage := GetLastErrorText();
            exit(false);
        end;

        Ticket.Reset();
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketRequest.FindSet();
        repeat
            if (TicketRequest."Admission Created") then begin
                TicketResponse.SetFilter("Session Token ID", '=%1', Token);
                if (TicketResponse.FindFirst()) then begin
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

        // there is only one token, so only one response
        Success := TicketResponse.Status;
        ResponseMessage := TicketResponse."Response Message";

        exit(Success);
    end;

    local procedure GetTickets(Token: Text[100]; StoreCode: Code[32]) Response: Codeunit "NPR API Response"
    var
        TicketHandler: Codeunit "NPR TicketingTicketAgent";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TicketingCatalog: Codeunit "NPR TicketingCatalogAgent";
        TicketDescriptionBuffer: Record "NPR TM TempTicketDescription";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin

        TicketRequest.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TicketRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketRequest.FindSet();
        GeneralLedgerSetup.Get();

        ResponseJson.Initialize().StartArray();
        repeat
            TicketingCatalog.GetCatalogItemDescription(StoreCode, Ticket."Item No.", TicketDescriptionBuffer);
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
            if (Ticket.FindSet()) then begin
                repeat
                    ResponseJson.AddArray(TicketHandler.SingleTicketDTO(ResponseJson, Ticket, GeneralLedgerSetup."LCY Code", TicketDescriptionBuffer, TicketRequest));
                until (Ticket.Next() = 0);
            end;

        until (TicketRequest.Next() = 0);
        ResponseJson.EndArray();
        Response.RespondOK(ResponseJson.BuildAsArray());
    end;

    // ******************************
    // local functions

    local procedure GetExpiryDateTimeValue(TicketReservationRequest: Record "NPR TM Ticket Reservation Req."): Text
    var
    begin
        if (TicketReservationRequest."Request Status" = TicketReservationRequest."Request Status"::Confirmed) then
            exit('');
        exit(Format(TicketReservationRequest."Expires Date Time", 0, 9));
    end;


    local procedure ReservationDTO(ResponseJson: Codeunit "NPR Json Builder"; PropertyName: Text; Token: Code[100]): Codeunit "NPR Json Builder";
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        ResponseJson.StartArray(PropertyName);

        TicketReservationRequest.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindSet();
        repeat
            ResponseJson.AddObject(ReservationDetailsDTO(ResponseJson, TicketReservationRequest."Entry No.", Token, TicketReservationRequest."Ext. Line Reference No."));
        until (TicketReservationRequest.Next() = 0);
        ResponseJson.EndArray();

        exit(ResponseJson);
    end;

    local procedure ReservationDetailsDTO(ResponseJson: Codeunit "NPR Json Builder"; PrimaryEntryNo: Integer; Token: Code[100]; LineNo: Integer): Codeunit "NPR Json Builder";
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketingCatalog: Codeunit "NPR TicketingCatalogAgent";
        TicketDescriptionBuffer: Record "NPR TM TempTicketDescription";
        TicketAgent: Codeunit "NPR TicketingTicketAgent";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID", "Ext. Line Reference No.");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', LineNo);
        TicketReservationRequest.FindSet();

        TicketingCatalog.GetCatalogItemDescription('', TicketReservationRequest."Item No.", TicketDescriptionBuffer);

        ResponseJson.StartObject('reservations')
            .AddProperty('itemNumber', TicketReservationRequest."Item No.")
            .AddProperty('quantity', TicketReservationRequest."Quantity")
            .AddObject(CompactTicketDetailsDTO(ResponseJson, PrimaryEntryNo))
            .StartArray('admissions');
        repeat
            ResponseJson
                .AddObject(TicketAgent.AdmissionDTO(ResponseJson, TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", TicketReservationRequest."Admission Code", TicketDescriptionBuffer))
                .AddObject(TicketAgent.ScheduleDTO(ResponseJson, 'scheduleDetails', TicketReservationRequest."External Adm. Sch. Entry No."))
                .EndObject()
        until (TicketReservationRequest.Next() = 0);

        ResponseJson.EndArray()
            .EndObject();
        exit(ResponseJson);
    end;

    local procedure CompactTicketDetailsDTO(ResponseJson: Codeunit "NPR Json Builder"; PrimaryEntryNo: Integer): Codeunit "NPR Json Builder";
    var
        Ticket: Record "NPR TM Ticket";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', PrimaryEntryNo);
        if (not Ticket.FindFirst()) then
            exit(ResponseJson);

        ResponseJson.StartObject('ticket')
            .AddProperty('validFrom', Ticket."Valid From Date")
            .AddProperty('validUntil', Ticket."Valid To Date")
            .AddProperty('unitPrice', Ticket.AmountExclVat)
            .AddProperty('unitPriceInclVat', Ticket.AmountInclVat)
            .AddProperty('currencyCode', GeneralLedgerSetup."LCY Code")
            .AddArray(CompactTicketList(ResponseJson, PrimaryEntryNo, 'ticketNumbers'))
            .EndObject();
        exit(ResponseJson);
    end;

    local procedure CompactTicketList(ResponseJson: Codeunit "NPR Json Builder"; PrimaryEntryNo: Integer; PropertyName: Text): Codeunit "NPR Json Builder";
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.Get(PrimaryEntryNo);
        if (TicketReservationRequest."Request Status" <> TicketReservationRequest."Request Status"::Confirmed) then
            exit(ResponseJson);

        ResponseJson.StartArray(PropertyName);

        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', PrimaryEntryNo);
        Ticket.FindSet();
        repeat
            ResponseJson.StartObject()
                .AddProperty('ticketId', Format(Ticket.SystemId, 0, 4))
                .AddProperty('ticketNumber', Ticket."External Ticket No.")
                .EndObject();
        until (Ticket.Next() = 0);

        ResponseJson.EndArray();
        exit(ResponseJson);

    end;



    local procedure ConfirmReservation(Token: Code[100]; TicketHolderName: Text[100]; NotificationAddress: Text[80]; PaymentReference: Code[20]; ErrorMessage: Text): Boolean
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketRequestManager.SetReservationRequestExtraInfo(Token, NotificationAddress, PaymentReference, TicketHolderName);
        if (not (TicketRequestManager.ConfirmReservationRequest(Token, ErrorMessage))) then
            exit(false);

        exit(true);
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
}
#endif