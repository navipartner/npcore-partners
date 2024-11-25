#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22   
codeunit 6185080 "NPR TicketingTicketAgent"
{
    Access = Internal;

    internal procedure GetTicket(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TicketId: Text;
        StoreCode: Code[32];
        Ticket: Record "NPR TM Ticket";
    begin
        TicketId := Request.Paths().Get(3);
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketId, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (not Ticket.FindFirst()) then
            exit(Response.RespondResourceNotFound('Invalid Ticket - Ticket not found'));

        if (Request.QueryParams().ContainsKey('storeCode')) then
            StoreCode := CopyStr(UpperCase(Request.QueryParams().Get('storeCode')), 1, MaxStrLen(StoreCode));

        exit(SingleTicket(Ticket."No.", StoreCode));

    end;

    internal procedure RequestRevokeTicket(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Ticket: Record "NPR TM Ticket";
        Item: Record Item;
        TicketId: Text;

        Amount: Decimal;
        PinCode: Code[10];
        PinCodeToken: JsonToken;
    begin

        TicketId := Request.Paths().Get(3);
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketId, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (not Ticket.FindFirst()) then
            exit(Response.RespondResourceNotFound('Invalid Ticket - Ticket not found'));

        // Request body should contain required parameter pinCode
        Request.BodyJson().AsObject().Get('pinCode', PinCodeToken);
        PinCode := CopyStr(PinCodeToken.AsValue().AsText(), 1, MaxStrLen(PinCode));

        Amount := Ticket.AmountInclVat;
        if (Amount = 0) then begin
            Item.Get(Ticket."Item No.");
            Amount := Item."Unit Price";
        end;

        exit(RequestRevokeTicket(Ticket."No.", PinCode, Amount));
    end;

    internal procedure ConfirmRevokeTicket(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Body: JsonObject;
        RevokeId: Text[100];
        NotificationAddress: Text[100];
        PaymentReference: Code[20];
        TicketHolder: Text[100];
        Token: JsonToken;
    begin
        Body := Request.BodyJson().AsObject();

        Body.Get('revokeId', Token);
        RevokeId := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(RevokeId));

        if (Body.Get('notificationAddress', Token)) then
            NotificationAddress := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(NotificationAddress));

        if (Body.Get('externalDocumentNo', Token)) then
            PaymentReference := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(PaymentReference));

        if (Body.Get('paymentReference', Token)) then
            TicketHolder := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(TicketHolder));

        exit(ConfirmRevokeTicket(RevokeId, NotificationAddress, PaymentReference, TicketHolder));
    end;

    internal procedure ValidateArrival(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Body: JsonObject;
        Token: JsonToken;
        TicketId: Text[50];
        AdmissionCode: Code[20];
        ScannerStation: Code[10];
    begin

        TicketId := CopyStr(Request.Paths().Get(3), 1, MaxStrLen(TicketId));
        if (TicketId = '') then
            exit(Response.RespondBadRequest('Invalid Ticket - Ticket ID not found'));

        Body := Request.BodyJson().AsObject();
        if (Body.Get('admissionCode', Token)) then
            AdmissionCode := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(AdmissionCode));

        if (Body.Get('scannerStation', Token)) then
            ScannerStation := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(ScannerStation));

        exit(ValidateArrival(TicketId, AdmissionCode, ScannerStation));
    end;

    internal procedure ValidateDeparture(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Body: JsonObject;
        Token: JsonToken;
        TicketId: Text[50];
        AdmissionCode: Code[20];
        ScannerStation: Code[10];
    begin

        TicketId := CopyStr(Request.Paths().Get(3), 1, MaxStrLen(TicketId));
        if (TicketId = '') then
            exit(Response.RespondBadRequest('Invalid Ticket - Ticket ID not found'));

        Body := Request.BodyJson().AsObject();
        if (Body.Get('admissionCode', Token)) then
            AdmissionCode := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(AdmissionCode));

        if (Body.Get('scannerStation', Token)) then
            ScannerStation := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(ScannerStation));

        exit(ValidateDeparture(TicketId, AdmissionCode, ScannerStation));
    end;

    internal procedure ValidateMemberArrival(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        exit(Response.RespondBadRequest('Not implemented yet'));
    end;

    internal procedure SendToWallet(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Body: JsonObject;
        Token: JsonToken;
        TicketId: Text[50];
        SendTo: Text[100];
    begin

        TicketId := CopyStr(Request.Paths().Get(3), 1, MaxStrLen(TicketId));
        if (TicketId = '') then
            exit(Response.RespondBadRequest('Invalid Ticket - Ticket ID not found'));

        Body := Request.BodyJson().AsObject();
        if (Body.Get('notificationAddress', Token)) then
            SendTo := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(SendTo));

        exit(SendToWallet(TicketId, SendTo));
    end;

    internal procedure ExchangeTicketForCoupon(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Body: JsonObject;
        Token: JsonToken;
        TicketId: Text[30];
        CouponCodeAlias: Text[20];
    begin
        TicketId := CopyStr(Request.Paths().Get(3), 1, MaxStrLen(TicketId));
        if (TicketId = '') then
            exit(Response.RespondBadRequest('Invalid Ticket - Ticket ID not found'));

        Body := Request.BodyJson().AsObject();
        if (Body.Get('couponCode', Token)) then
            CouponCodeAlias := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(CouponCodeAlias));

        exit(ExchangeTicketForCoupon(TicketId, CouponCodeAlias));

    end;

    // ****************************
    internal procedure RequestRevokeTicket(TicketNo: Code[20]; PinCode: Code[10]; Amount: Decimal) Response: Codeunit "NPR API Response"
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResponseJson: Codeunit "NPR JSON Builder";
        RevokeId: Text[100];
        RevokeQty: Integer;
    begin
        RevokeId := CreateDocumentId();
        TicketRequestManager.WS_CreateRevokeRequest(RevokeId, TicketNo, PinCode, Amount, RevokeQty);

        ResponseJson.StartObject()
            .AddProperty('revokeId', RevokeId)
            .AddProperty('quantityToRevoke', RevokeQty)
            .AddProperty('unitAmount', Amount)
        .EndObject();

        exit(Response.RespondOk(ResponseJson.Build()));
    end;

    internal procedure ConfirmRevokeTicket(DocumentId: Text[100]; SendNotificationTo: Text[100]; ExternalDocumentNo: Code[20]; TicketHolderName: Text[100]) Response: Codeunit "NPR API Response"
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        TicketRequestManager.SetReservationRequestExtraInfo(DocumentID,
              SendNotificationTo,
              ExternalDocumentNo,
              TicketHolderName);

        TicketRequestManager.RevokeReservationTokenRequest(DocumentID, false);

        ResponseJson.StartObject()
            .AddProperty('revokeId', DocumentID)
            .AddProperty('status', 'revoked')
        .EndObject();

        exit(Response.RespondOk(ResponseJson.Build()));
    end;

    internal procedure ValidateArrival(ExternalTicketNo: Text[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]) Response: Codeunit "NPR API Response"
    var
        AttemptTicket: Codeunit "NPR Ticket Attempt Create";
        ArrivalSuccess: Boolean;
        Ticket: Record "NPR TM Ticket";
        TicketNumberRequired: Label '[-2001] Ticket number. is required.';
        MessageText: Text;
        ResponseJson: Codeunit "NPR JSON Builder";
    begin

        if (ExternalTicketNo = '') then
            exit(Response.RespondBadRequest(TicketNumberRequired));

        // We don't want to reveal if the ticket was found as the order reference or ticket number
        // so we first check if the ticket exists by external ticket number and if not found, try validate by external order reference
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(ExternalTicketNo, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (Ticket.IsEmpty()) then
            ArrivalSuccess := AttemptTicket.AttemptValidateTicketForArrival("NPR TM TicketIdentifierType"::EXTERNAL_ORDER_REF, ExternalTicketNo, AdmissionCode, -1, '', ScannerStationId, MessageText);

        // if not yet successful, try validate by external ticket number
        if (not ArrivalSuccess) then
            ArrivalSuccess := AttemptTicket.AttemptValidateTicketForArrival("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, ExternalTicketNo, AdmissionCode, -1, '', ScannerStationId, MessageText);

        if (not ArrivalSuccess) then
            exit(Response.RespondBadRequest(MessageText));

        if (ArrivalSuccess) then begin
            ResponseJson.StartObject()
                .AddProperty('ticketNumber', ExternalTicketNo)
                .AddProperty('admissionCode', AdmissionCode)
                .AddProperty('scannerStation', ScannerStationId)
                .AddProperty('admitted', 'true')
                .EndObject();
            Response.RespondOk(ResponseJson.Build());
        end else begin
            Response.RespondBadRequest(MessageText);
        end;
    end;

    internal procedure ValidateDeparture(ExternalTicketNo: Text[50]; AdmissionCode: Code[20]; ScannerStationId: Code[20]) Response: Codeunit "NPR API Response"
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ResponseJson: Codeunit "NPR JSON Builder";
        TicketNumberRequired: Label '[-2001] Ticket number. is required.';
    begin

        if (ExternalTicketNo = '') then
            exit(Response.RespondBadRequest(TicketNumberRequired));

        TicketManagement.ValidateTicketForDeparture("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, ExternalTicketNo, AdmissionCode);

        ResponseJson.StartObject()
            .AddProperty('ticketNumber', ExternalTicketNo)
            .AddProperty('admissionCode', AdmissionCode)
            .AddProperty('scannerStation', ScannerStationId)
            .AddProperty('departed', 'true')
            .EndObject();
        Response.RespondOk(ResponseJson.Build());
    end;

    local procedure SendToWallet(TicketId: Text; SendTo: Text[100]) Response: Codeunit "NPR API Response"
    var
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResponseJson: Codeunit "NPR JSON Builder";
        ResponseText: Text;
    begin

        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketId, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (not Ticket.FindFirst()) then
            exit(Response.RespondResourceNotFound('Invalid Ticket - Ticket not found'));

        if (not TicketRequestManager.CreateAndSendETicket(Ticket."No.", SendTo, true, ResponseText)) then
            exit(Response.RespondBadRequest(ResponseText));

        ResponseJson.StartObject()
            .AddProperty('ticketNumber', TicketId)
            .AddProperty('sentTo', SendTo)
            .AddProperty('ticketSent', 'true')
            .EndObject();

        exit(Response.RespondOk(ResponseJson.Build()));
    end;

    local procedure ExchangeTicketForCoupon(TicketId: Text[30]; CouponCodeAlias: Text[20]) Response: Codeunit "NPR API Response"
    var
        CouponReferenceNo: Text[50];
        ReasonText: Text;
        TicketToCoupon: Codeunit "NPR TM TicketToCoupon";
        ResponseJson: Codeunit "NPR JSON Builder";
        ReasonNumber: Integer;
    begin
        if (not TicketToCoupon.ExchangeTicketForCoupon(TicketId, CouponCodeAlias, CouponReferenceNo, ReasonNumber, ReasonText)) then
            exit(Response.RespondBadRequest(ReasonText));

        ResponseJson.StartObject()
            .AddProperty('ticketNumber', TicketId)
            .AddProperty('couponId', CouponReferenceNo)
            .EndObject();

        exit(Response.RespondOk(ResponseJson.Build()));
    end;


    // ****************************
    internal procedure SingleTicket(TicketNo: Code[20]; StoreCode: Code[32]) Response: Codeunit "NPR API Response"
    var
        Ticket: Record "NPR TM Ticket";
        TicketingCatalog: Codeunit "NPR TicketingCatalogAgent";
        ResponseJson: Codeunit "NPR JSON Builder";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TicketDescriptionBuffer: Record "NPR TM TempTicketDescription";
    begin
        Ticket.Get(TicketNo);
        if (not ReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
            exit(Response.RespondBadRequest('Invalid Ticket - Reservation not found'));

        GeneralLedgerSetup.Get();
        TicketingCatalog.GetCatalogItemDescription(StoreCode, Ticket."Item No.", TicketDescriptionBuffer);

        ResponseJson.Initialize()
            .AddObject(SingleTicketDTO(ResponseJson, Ticket, GeneralLedgerSetup."LCY Code", TicketDescriptionBuffer, ReservationRequest));

        exit(Response.RespondOk(ResponseJson.Build()));
    end;

    internal procedure SingleTicketDTO(ResponseJson: Codeunit "NPR JSON Builder";
        Ticket: Record "NPR TM Ticket";
        CurrencyCode: Code[10];
        var TicketDescriptionBuffer: Record "NPR TM TempTicketDescription";
        ReservationRequest: Record "NPR TM Ticket Reservation Req."): Codeunit "NPR JSON Builder";
    begin
        ResponseJson.StartObject()
            .AddProperty('ticketNumber', Ticket."External Ticket No.")
            .AddProperty('reservationToken', ReservationRequest."Session Token ID")
            .AddProperty('validFrom', Format(Ticket."Valid From Date", 0, 9))
            .AddProperty('validUntil', Format(Ticket."Valid To Date", 0, 9))
            .AddArray(AdmissionDetailsDTO(ResponseJson, 'admissionDetails', Ticket, TicketDescriptionBuffer))
            .StartObject('description')
                .AddProperty('title', TicketDescriptionBuffer.Title)
                .AddProperty('subtitle', TicketDescriptionBuffer.Subtitle)
                .AddProperty('name', TicketDescriptionBuffer.Name)
                .AddProperty('description', TicketDescriptionBuffer.Description)
                .AddProperty('fullDescription', TicketDescriptionBuffer.FullDescription)
            .EndObject()
            .AddProperty('pinCode', ReservationRequest."Authorization Code")
            .AddProperty('unitPrice', Ticket.AmountExclVat)
            .AddProperty('unitPriceInclVat', Ticket.AmountInclVat)
            .AddProperty('currencyCode', CurrencyCode)
            .AddProperty('ticketHolder', ReservationRequest.TicketHolderName)
        .EndObject();

        exit(ResponseJson);
    end;

    local procedure AdmissionDetailsDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ArrayName: Text; Ticket: Record "NPR TM Ticket"; var TicketDescriptionBuffer: Record "NPR TM TempTicketDescription"): Codeunit "NPR JSON Builder";
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin
        ResponseJson.StartArray(ArrayName);

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (TicketAccessEntry.FindSet()) then begin
            repeat
                ResponseJson.AddObject(AdmissionDTO(ResponseJson, Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code", TicketDescriptionBuffer))
                    .AddObject(ScheduleDetailsDTO(ResponseJson, 'scheduleDetails', TicketAccessEntry."Entry No."))
                    .EndObject();
            until (TicketAccessEntry.Next() = 0);
        end;

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;

    internal procedure AdmissionDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; var TicketDescriptionBuffer: Record "NPR TM TempTicketDescription"): Codeunit "NPR JSON Builder"
    var
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission Bom";
        EnumEncoder: Codeunit "NPR TicketingApiTranslations";
    begin
        Admission.Get(AdmissionCode);
        TicketBom.Get(ItemNo, VariantCode, AdmissionCode);
        TicketDescriptionBuffer.Get(ItemNo, VariantCode, AdmissionCode);

        ResponseJson.StartObject()
            .AddProperty('code', TicketBom."Admission Code")
            .AddProperty('default', TicketBom.Default)
            .AddProperty('included', EnumEncoder.EncodeInclusion(TicketBom."Admission Inclusion"))
            .AddProperty('capacityControl', EnumEncoder.EncodeCapacity(Admission."Capacity Control"))
            .AddProperty('scheduleSelection', EnumEncoder.EncodeScheduleSelection(TicketBom."Ticket Schedule Selection", Admission."Default Schedule"))
            .AddProperty('maxCapacity', Format(Admission."Max Capacity Per Sch. Entry", 0, 9))
            .StartObject('description')
                .AddProperty('title', TicketDescriptionBuffer.Title)
                .AddProperty('subtitle', TicketDescriptionBuffer.Subtitle)
                .AddProperty('name', TicketDescriptionBuffer.Name)
                .AddProperty('description', TicketDescriptionBuffer.Description)
                .AddProperty('fullDescription', TicketDescriptionBuffer.FullDescription)
            .EndObject();

        exit(ResponseJson);
    end;

    local procedure ScheduleDetailsDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ObjectName: Text; EntryNo: Integer): Codeunit "NPR JSON Builder";
    var
        DetailAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        DetailAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', EntryNo);
        DetailAccessEntry.SetFilter(Type, '=%1', DetailAccessEntry.Type::RESERVATION);
        DetailAccessEntry.SetFilter(Quantity, '>%1', 0);
        if (not DetailAccessEntry.FindLast()) then
            DetailAccessEntry.Init();

        exit(ScheduleDTO(ResponseJson, ObjectName, DetailAccessEntry."External Adm. Sch. Entry No."));

    end;

    internal procedure ScheduleDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ObjectName: Text; ExtScheduleEntryNo: Integer): Codeunit "NPR JSON Builder";
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Schedule: Record "NPR TM Admis. Schedule";
    begin
        ResponseJson.StartObject(ObjectName);

        ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtScheduleEntryNo);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (ScheduleEntry.FindFirst()) then begin
            Schedule.Get(ScheduleEntry."Schedule Code");
            ResponseJson
                .AddProperty('id', ScheduleEntry."External Schedule Entry No.")
                .AddProperty('code', ScheduleEntry."Schedule Code")
                .AddProperty('startDate', Format(ScheduleEntry."Admission Start Date", 0, 9))
                .AddProperty('startTime', Format(ScheduleEntry."Admission Start Time", 0, 9))
                .AddProperty('endDate', Format(ScheduleEntry."Admission End Date", 0, 9))
                .AddProperty('endTime', Format(ScheduleEntry."Admission End Time", 0, 9))
                .AddProperty('duration', Format((ScheduleEntry."Admission End Time" - ScheduleEntry."Admission Start Time") / 1000, 0, 9))
                .AddProperty('description', Schedule.Description)
                .AddProperty('arrivalFromTime', Format(ScheduleEntry."Event Arrival From Time", 0, 9))
                .AddProperty('arrivalUntilTime', Format(ScheduleEntry."Event Arrival Until Time", 0, 9));
        end else begin
            ResponseJson
                .AddProperty('id', -1)
                .AddProperty('code', '')
                .AddProperty('description', 'No reservation required');
        end;

        ResponseJson.EndObject();
        exit(ResponseJson);
    end;

#pragma warning disable AA0139
    local procedure CreateDocumentId(): Text[50]
    begin
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;
#pragma warning restore
}
#endif