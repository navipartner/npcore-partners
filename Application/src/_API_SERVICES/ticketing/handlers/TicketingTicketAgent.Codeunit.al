#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22   
codeunit 6185080 "NPR TicketingTicketAgent"
{
    Access = Internal;

    internal procedure GetTicket(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        StoreCode: Code[32];
        Ticket: Record "NPR TM Ticket";
    begin
        if (not GetTicketById(Request, 2, Ticket, Response)) then
            exit(Response);

        if (Request.QueryParams().ContainsKey('storeCode')) then
            StoreCode := CopyStr(UpperCase(Request.QueryParams().Get('storeCode')), 1, MaxStrLen(StoreCode));

        exit(SingleTicket(Ticket, StoreCode));

    end;

    internal procedure FindTickets(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ExternalNumber: Text[30];
    begin
        if (Request.QueryParams().ContainsKey('externalNumber')) then
            ExternalNumber := CopyStr(UpperCase(Request.QueryParams().Get('externalNumber')), 1, MaxStrLen(ExternalNumber));

        exit(FindTicketByExternalNumber(ExternalNumber));
    end;

    internal procedure RequestRevokeTicket(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Ticket: Record "NPR TM Ticket";
        Item: Record Item;
        Amount: Decimal;
        PinCode: Code[10];
        PinCodeToken: JsonToken;
    begin

        if (not GetTicketById(Request, 2, Ticket, Response)) then
            exit(Response);

        // Request body should contain required parameter pinCode
        Request.BodyJson().AsObject().Get('pinCode', PinCodeToken);
        PinCode := CopyStr(PinCodeToken.AsValue().AsText(), 1, MaxStrLen(PinCode));

        Amount := Ticket.AmountInclVat;
        if (Amount = 0) then begin
            Item.Get(Ticket."Item No.");
            Amount := Item."Unit Price";
        end;

        exit(RequestRevokeTicket(Ticket, PinCode, Amount));
    end;

    internal procedure ConfirmRevokeTicket(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Body: JsonObject;
        Ticket: Record "NPR TM Ticket";
        RevokeId: Text[100];
        NotificationAddress: Text[100];
        PaymentReference: Code[20];
        TicketHolder: Text[100];
        Token: JsonToken;
    begin

        if (not GetTicketById(Request, 2, Ticket, Response)) then
            exit(Response);

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
        Ticket: Record "NPR TM Ticket";
        Body: JsonObject;
        Token: JsonToken;
        AdmissionCode: Code[20];
        ScannerStation: Code[10];
    begin

        if (not GetTicketById(Request, 2, Ticket, Response)) then
            exit(Response);

        Body := Request.BodyJson().AsObject();
        if (Body.Get('admissionCode', Token)) then
            AdmissionCode := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(AdmissionCode));

        if (Body.Get('scannerStation', Token)) then
            ScannerStation := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(ScannerStation));

        exit(ValidateArrival(Ticket, AdmissionCode, ScannerStation));
    end;

    internal procedure ValidateDeparture(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Ticket: Record "NPR TM Ticket";
        Body: JsonObject;
        Token: JsonToken;
        AdmissionCode: Code[20];
        ScannerStation: Code[10];
    begin

        if (not GetTicketById(Request, 2, Ticket, Response)) then
            exit(Response);

        Body := Request.BodyJson().AsObject();
        if (Body.Get('admissionCode', Token)) then
            AdmissionCode := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(AdmissionCode));

        if (Body.Get('scannerStation', Token)) then
            ScannerStation := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(ScannerStation));

        exit(ValidateDeparture(Ticket, AdmissionCode, ScannerStation));
    end;

    internal procedure ValidateMemberArrival(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        exit(Response.RespondBadRequest('Not implemented yet'));
    end;

    internal procedure SendToWallet(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Ticket: Record "NPR TM Ticket";
        Body: JsonObject;
        Token: JsonToken;
        SendTo: Text[100];
    begin
        if (not GetTicketById(Request, 2, Ticket, Response)) then
            exit(Response);

        Body := Request.BodyJson().AsObject();
        if (Body.Get('notificationAddress', Token)) then
            SendTo := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(SendTo));

        exit(SendToWallet(Ticket, SendTo));
    end;

    internal procedure ExchangeTicketForCoupon(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Ticket: Record "NPR TM Ticket";
        Body: JsonObject;
        Token: JsonToken;
        CouponCodeAlias: Text[20];
    begin
        if (not GetTicketById(Request, 2, Ticket, Response)) then
            exit(Response);

        Body := Request.BodyJson().AsObject();
        if (Body.Get('couponCode', Token)) then
            CouponCodeAlias := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(CouponCodeAlias));

        exit(ExchangeTicketForCoupon(Ticket, CouponCodeAlias));

    end;

    internal procedure ConfirmPrintTicket(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Ticket: Record "NPR TM Ticket";
        Body: JsonObject;
        Token: JsonToken;
        printCount: Integer;
    begin
        if (not GetTicketById(Request, 2, Ticket, Response)) then
            exit(Response);

        Body := Request.BodyJson().AsObject();
        if (not Body.Get('printCount', Token)) then
            exit(Response.RespondBadRequest('Missing printCount in request'));

        printCount := Token.AsValue().AsInteger();

        exit(ConfirmPrintTicket(Ticket, printCount));
    end;

    internal procedure ClearConfirmPrintTicket(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Ticket: Record "NPR TM Ticket";
    begin
        if (not GetTicketById(Request, 2, Ticket, Response)) then
            exit(Response);

        exit(ClearConfirmPrintTicket(Ticket));
    end;


    // ****************************
    internal procedure RequestRevokeTicket(Ticket: Record "NPR TM Ticket"; PinCode: Code[10]; Amount: Decimal) Response: Codeunit "NPR API Response"
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResponseJson: Codeunit "NPR JSON Builder";
        RevokeId: Text[100];
        RevokeQty: Integer;
    begin
        RevokeId := CreateDocumentId();
        TicketRequestManager.WS_CreateRevokeRequest(RevokeId, Ticket."No.", PinCode, Amount, RevokeQty);

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

    internal procedure ValidateArrival(Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; ScannerStationId: Code[10]) Response: Codeunit "NPR API Response"
    var
        AttemptTicket: Codeunit "NPR Ticket Attempt Create";
        ArrivalSuccess: Boolean;
        MessageText: Text;
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        ArrivalSuccess := AttemptTicket.AttemptValidateTicketForArrival("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, Ticket."External Ticket No.", AdmissionCode, -1, '', ScannerStationId, MessageText);

        if (not ArrivalSuccess) then
            exit(Response.RespondBadRequest(MessageText));

        if (ArrivalSuccess) then begin
            ResponseJson.StartObject()
                .AddProperty('ticketId', format(Ticket.SystemId, 0, 4).ToLower())
                .AddProperty('ticketNumber', Ticket."External Ticket No.")
                .AddProperty('admissionCode', AdmissionCode)
                .AddProperty('scannerStation', ScannerStationId)
                .AddProperty('admitted', true)
                .EndObject();
            Response.RespondOk(ResponseJson.Build());
        end else begin
            Response.RespondBadRequest(MessageText);
        end;
    end;

    internal procedure ValidateDeparture(Ticket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; ScannerStationId: Code[20]) Response: Codeunit "NPR API Response"
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        TicketManagement.ValidateTicketForDeparture("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, Ticket."External Ticket No.", AdmissionCode);

        ResponseJson.StartObject()
            .AddProperty('ticketId', format(Ticket.SystemId, 0, 4).ToLower())
            .AddProperty('ticketNumber', Ticket."External Ticket No.")
            .AddProperty('admissionCode', AdmissionCode)
            .AddProperty('scannerStation', ScannerStationId)
            .AddProperty('departed', true)
            .EndObject();
        Response.RespondOk(ResponseJson.Build());
    end;

    local procedure SendToWallet(Ticket: Record "NPR TM Ticket"; SendTo: Text[100]) Response: Codeunit "NPR API Response"
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResponseJson: Codeunit "NPR JSON Builder";
        ResponseText: Text;
    begin

        if (not TicketRequestManager.CreateAndSendETicket(Ticket."No.", SendTo, true, ResponseText)) then
            exit(Response.RespondBadRequest(ResponseText));

        ResponseJson.StartObject()
            .AddProperty('ticketNumber', Ticket."External Ticket No.")
            .AddProperty('sentTo', SendTo)
            .AddProperty('ticketSent', 'true')
            .EndObject();

        exit(Response.RespondOk(ResponseJson.Build()));
    end;

    local procedure ExchangeTicketForCoupon(Ticket: Record "NPR TM Ticket"; CouponCodeAlias: Text[20]) Response: Codeunit "NPR API Response"
    var
        CouponReferenceNo: Text[50];
        ReasonText: Text;
        TicketToCoupon: Codeunit "NPR TM TicketToCoupon";
        ResponseJson: Codeunit "NPR JSON Builder";
        ReasonNumber: Integer;
    begin
        if (not TicketToCoupon.ExchangeTicketForCoupon(Ticket."External Ticket No.", CouponCodeAlias, CouponReferenceNo, ReasonNumber, ReasonText)) then
            exit(Response.RespondBadRequest(ReasonText));

        ResponseJson.StartObject()
            .AddProperty('ticketNumber', Ticket."External Ticket No.")
            .AddProperty('couponId', CouponReferenceNo)
            .EndObject();

        exit(Response.RespondOk(ResponseJson.Build()));
    end;


    local procedure ConfirmPrintTicket(Ticket: Record "NPR TM Ticket"; PrintCount: Integer) Response: Codeunit "NPR API Response"
    var
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        if (PrintCount < -1) then
            exit(Response.RespondBadRequest('Invalid print count'));

        if (PrintCount >= 0) then
            if (not (PrintCount = Ticket.PrintCount)) then
                exit(Response.RespondBadRequest('Invalid print count'));

        Ticket.PrintCount += 1;
        Ticket.PrintedDateTime := CurrentDateTime();
        Ticket."Printed Date" := Today(); // slight issue with timezone, but we can live with that
        Ticket.Modify();

        ResponseJson.StartObject()
            .AddProperty('printCount', Ticket.PrintCount)
            .AddProperty('printedAt', Ticket.PrintedDateTime)
            .EndObject();

        exit(Response.RespondOk(ResponseJson.Build()));
    end;

    local procedure ClearConfirmPrintTicket(Ticket: Record "NPR TM Ticket") Response: Codeunit "NPR API Response"
    var
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        Ticket.PrintedDateTime := CreateDateTime(0D, 0T);
        Ticket."Printed Date" := 0D;
        Ticket.Modify();

        ResponseJson.StartObject()
            .AddProperty('printCount', Ticket.PrintCount)
            .EndObject();

        exit(Response.RespondOk(ResponseJson.Build()));
    end;

    // ****************************
    local procedure GetTicketById(var Request: Codeunit "NPR API Request"; PathPosition: Integer; var Ticket: Record "NPR TM Ticket"; var Response: Codeunit "NPR API Response"): Boolean
    var
        TicketIdText: Text[50];
        TicketId: Guid;
    begin
        TicketIdText := CopyStr(Request.Paths().Get(PathPosition), 1, MaxStrLen(TicketIdText));
        if (TicketIdText = '') then begin
            Response.RespondBadRequest('Invalid Ticket - Ticket Id not valid');
            exit(false);
        end;

        if (not Evaluate(TicketId, TicketIdText)) then begin
            Response.RespondBadRequest('Invalid Ticket - Ticket Id not valid');
            exit(false);
        end;

        if (not Ticket.GetBySystemId(TicketId)) then begin
            Response.RespondResourceNotFound('Invalid Ticket - Ticket not found');
            exit(false);
        end;

        exit(true);
    end;

    local procedure FindTicketByExternalNumber(ExternalNumber: Text[30]) Response: Codeunit "NPR API Response"
    var
        Ticket: Record "NPR TM Ticket";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        Ticket.SetFilter("External Ticket No.", '=%1', ExternalNumber);
        if (not Ticket.FindFirst()) then
            exit(Response.RespondResourceNotFound('Invalid Ticket - Ticket not found'));

        ResponseJson.StartArray().AddArray(TicketIdDTO(ResponseJson, Ticket)).EndArray();

        exit(Response.RespondOk(ResponseJson.BuildAsArray()));
    end;

    local procedure TicketIdDTO(var ResponseJson: Codeunit "NPR JSON Builder"; Ticket: Record "NPR TM Ticket"): Codeunit "NPR JSON Builder";
    begin

        ResponseJson.StartObject()
            .AddProperty('ticketId', Format(Ticket.SystemId, 0, 4).ToLower())
            .AddProperty('ticketNumber', Ticket."External Ticket No.")
            .AddProperty('validFrom', Ticket."Valid From Date")
            .AddProperty('validUntil', Ticket."Valid To Date")
            .AddProperty('unitPrice', Ticket.AmountExclVat)
            .AddProperty('unitPriceInclVat', Ticket.AmountInclVat)
        .EndObject();

        exit(ResponseJson);
    end;

    internal procedure SingleTicket(Ticket: Record "NPR TM Ticket"; StoreCode: Code[32]) Response: Codeunit "NPR API Response"
    var
        TicketingCatalog: Codeunit "NPR TicketingCatalogAgent";
        ResponseJson: Codeunit "NPR JSON Builder";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TicketDescriptionBuffer: Record "NPR TM TempTicketDescription";
    begin
        GeneralLedgerSetup.Get();
        TicketingCatalog.GetCatalogItemDescription(StoreCode, Ticket."Item No.", TicketDescriptionBuffer);
        if (not ReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
            ReservationRequest.Init();

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
            .AddProperty('ticketId', Format(Ticket.SystemId, 0, 4).ToLower())
            .AddProperty('ticketNumber', Ticket."External Ticket No.")
            .AddProperty('reservationToken', ReservationRequest."Session Token ID")
            .AddProperty('validFrom', CreateDateTime(Ticket."Valid From Date", Ticket."Valid From Time"))
            .AddProperty('validUntil', CreateDateTime(Ticket."Valid To Date", Ticket."Valid To Time"))
            .AddArray(AdmissionDetailsDTO(ResponseJson, 'content', Ticket, TicketDescriptionBuffer))
            .StartObject('description')
                .AddObject(AddPropertyNotNull(ResponseJson, 'title', TicketDescriptionBuffer.Title))
                .AddObject(AddPropertyNotNull(ResponseJson, 'subtitle', TicketDescriptionBuffer.Subtitle))
                .AddObject(AddPropertyNotNull(ResponseJson, 'name', TicketDescriptionBuffer.Name))
                .AddObject(AddPropertyNotNull(ResponseJson, 'description', TicketDescriptionBuffer.Description))
                .AddObject(AddPropertyNotNull(ResponseJson, 'fullDescription', TicketDescriptionBuffer.FullDescription))
            .EndObject()
            .AddProperty('pinCode', ReservationRequest."Authorization Code")
            .AddProperty('unitPrice', Ticket.AmountExclVat)
            .AddProperty('unitPriceInclVat', Ticket.AmountInclVat)
            .AddProperty('currencyCode', CurrencyCode)
            .AddProperty('ticketHolder', ReservationRequest.TicketHolderName)
            .AddProperty('printCount', Ticket.PrintCount)
            .AddProperty('printedAt', Ticket.PrintedDateTime)
        .EndObject();

        exit(ResponseJson);
    end;

    local procedure AddPropertyNotNull(var ResponseJson: Codeunit "NPR JSON Builder"; PropertyName: Text; PropertyValue: Text): Codeunit "NPR JSON Builder"
    begin
        if (PropertyValue <> '') then
            ResponseJson.AddProperty(PropertyName, PropertyValue);
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
                ResponseJson.StartObject()
                    .AddObject(AdmissionDTO(ResponseJson, 'admissionDetails', Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code", TicketDescriptionBuffer))
                    .AddObject(ScheduleDetailsDTO(ResponseJson, 'scheduleDetails', TicketAccessEntry."Entry No."))
                .EndObject();
            until (TicketAccessEntry.Next() = 0);
        end;

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;

    internal procedure AdmissionDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ObjectName: Text; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; var TicketDescriptionBuffer: Record "NPR TM TempTicketDescription"): Codeunit "NPR JSON Builder"
    var
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission Bom";
        EnumEncoder: Codeunit "NPR TicketingApiTranslations";
    begin
        Admission.Get(AdmissionCode);
        TicketBom.Get(ItemNo, VariantCode, AdmissionCode);
        TicketDescriptionBuffer.Get(ItemNo, VariantCode, AdmissionCode);

        ResponseJson.StartObject(ObjectName)
            .AddProperty('code', TicketBom."Admission Code")
            .AddProperty('default', TicketBom.Default)
            .AddProperty('included', EnumEncoder.EncodeInclusion(TicketBom."Admission Inclusion"))
            .AddProperty('capacityControl', EnumEncoder.EncodeCapacity(Admission."Capacity Control"))
            .StartObject('description')
                .AddProperty('title', TicketDescriptionBuffer.Title)
                .AddProperty('subtitle', TicketDescriptionBuffer.Subtitle)
                .AddProperty('name', TicketDescriptionBuffer.Name)
                .AddProperty('description', TicketDescriptionBuffer.Description)
                .AddProperty('fullDescription', TicketDescriptionBuffer.FullDescription)
            .EndObject()
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
        if (not DetailAccessEntry.FindLast()) then begin
            DetailAccessEntry.SetFilter(Type, '=%1', DetailAccessEntry.Type::INITIAL_ENTRY);
            if (not DetailAccessEntry.FindLast()) then
                DetailAccessEntry.Init();
        end;

        exit(ScheduleDTO(ResponseJson, ObjectName, DetailAccessEntry."External Adm. Sch. Entry No."));

    end;

    internal procedure ScheduleDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ObjectName: Text; ExtScheduleEntryNo: Integer): Codeunit "NPR JSON Builder";
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Schedule: Record "NPR TM Admis. Schedule";
        DurationAsInt: Integer;
    begin
        ResponseJson.StartObject(ObjectName);

        ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ExtScheduleEntryNo);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (ScheduleEntry.FindFirst()) then begin
            Schedule.Get(ScheduleEntry."Schedule Code");

            DurationAsInt := Round((ScheduleEntry."Admission End Time" - ScheduleEntry."Admission Start Time") / 1000, 1);

            ResponseJson
                .AddProperty('externalNumber', ScheduleEntry."External Schedule Entry No.")
                .AddProperty('code', ScheduleEntry."Schedule Code")
                .AddProperty('startDate', ScheduleEntry."Admission Start Date")
                .AddProperty('startTime', ScheduleEntry."Admission Start Time")
                .AddProperty('endDate', ScheduleEntry."Admission End Date")
                .AddProperty('endTime', ScheduleEntry."Admission End Time")
                .AddProperty('duration', DurationAsInt)
                .AddProperty('description', Schedule.Description)
                .AddProperty('arrivalFromTime', ScheduleEntry."Event Arrival From Time")
                .AddProperty('arrivalUntilTime', ScheduleEntry."Event Arrival Until Time");
        end else begin
            ResponseJson
                .AddProperty('externalNumber', -1)
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