#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22   
codeunit 6185080 "NPR TicketingTicketAgent"
{
    Access = Internal;

    internal procedure GetTicket(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        StoreCode: Code[32];
        WithAdmissionDetails, WithAccessHistory, WithAccessHistoryDetails : Boolean;
        Ticket: Record "NPR TM Ticket";
    begin
        if (not GetTicketById(Request, 2, Ticket, Response)) then
            exit(Response);

        if (Request.QueryParams().ContainsKey('storeCode')) then
            StoreCode := CopyStr(UpperCase(Request.QueryParams().Get('storeCode')), 1, MaxStrLen(StoreCode));

        WithAdmissionDetails := true; // DTO includes admission details as non-optional

        // accessHistory opt-in parameter
        if (Request.QueryParams().ContainsKey('withAccessHistory')) then
            WithAccessHistory := (Request.QueryParams().Get('withAccessHistory').ToLower() = 'true');

        // accessHistoryDetails opt-in parameter
        if (Request.QueryParams().ContainsKey('withAccessHistoryDetails')) then
            WithAccessHistoryDetails := (Request.QueryParams().Get('withAccessHistoryDetails').ToLower() = 'true');

        exit(Response.RespondOk(SingleTicketDTO(Ticket, StoreCode, WithAdmissionDetails, WithAccessHistory, WithAccessHistoryDetails).Build()));
    end;

    internal procedure FindTickets(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TicketIdText: Text[50];
        ExternalNumbers: List of [Text];
        NotificationAddress: Text[100];
        WithAdmissionDetails, WithAccessHistory, WithAccessHistoryDetails : Boolean;
        ActiveOnly: Boolean;
        StoreCode: Code[32];
    begin

        if (Request.QueryParams().ContainsKey('storeCode')) then
            StoreCode := CopyStr(UpperCase(Request.QueryParams().Get('storeCode')), 1, MaxStrLen(StoreCode));

        // What to include
        if (Request.ApiVersion() < DMY2Date(6, 11, 2025)) then
            if (Request.QueryParams().ContainsKey('withEvents')) then
                WithAccessHistoryDetails := (Request.QueryParams().Get('withEvents').ToLower() = 'true'); // This one should be obsoleted, use withAccessHistoryDetails instead

        // accessHistoryDetails opt-in parameter
        if (Request.QueryParams().ContainsKey('withAccessHistoryDetails')) then
            WithAccessHistoryDetails := (Request.QueryParams().Get('withAccessHistoryDetails').ToLower() = 'true');

        WithAccessHistory := true; // maintain non-breaking behavior, access history is included if details are requested

        // admissionContent opt-in
        if (Request.QueryParams().ContainsKey('withAdmissionContent')) then
            WithAdmissionDetails := (Request.QueryParams().Get('withAdmissionContent').ToLower() = 'true');

        // opt-out Active only
        ActiveOnly := true;
        if (Request.QueryParams().ContainsKey('activeOnly')) then
            ActiveOnly := (Request.QueryParams().Get('activeOnly').ToLower() = 'true');

        // How to find tickets
        if (Request.QueryParams().ContainsKey('ticketId')) then begin
            TicketIdText := CopyStr(UpperCase(Request.QueryParams().Get('ticketId')), 1, MaxStrLen(TicketIdText));
            exit(FindTicketByTicketID(TicketIdText, StoreCode, ActiveOnly, WithAdmissionDetails, WithAccessHistory, WithAccessHistoryDetails));
        end;

        if (Request.QueryParams().ContainsKey('externalNumber')) then begin
            ExternalNumbers.Add(UpperCase(Request.QueryParams().Get('externalNumber')));
            exit(FindTicketByExternalNumber(ExternalNumbers, StoreCode, ActiveOnly, WithAdmissionDetails, WithAccessHistory, WithAccessHistoryDetails));
        end;

        if (Request.QueryParams().ContainsKey('externalNumbers')) then begin
            ExternalNumbers := UpperCase(Request.QueryParams().Get('externalNumbers')).Split(',');
            exit(FindTicketByExternalNumber(ExternalNumbers, StoreCode, ActiveOnly, WithAdmissionDetails, WithAccessHistory, WithAccessHistoryDetails));
        end;


        if (Request.QueryParams().ContainsKey('notificationAddress')) then begin
            NotificationAddress := CopyStr(Request.QueryParams().Get('notificationAddress'), 1, MaxStrLen(NotificationAddress));
            exit(FindTicketByNotificationAddress(NotificationAddress, StoreCode, ActiveOnly, WithAdmissionDetails, WithAccessHistory, WithAccessHistoryDetails));
        end;

        exit(Response.RespondBadRequest('Invalid request - missing query parameter ticketId, externalNumber(s),  or notificationAddress'));
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
        TicketHolderLanguage: Code[10];
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

        if (Body.Get('ticketHolderLanguage', Token)) then
            TicketHolderLanguage := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(TicketHolderLanguage));

        exit(ConfirmRevokeTicket(RevokeId, NotificationAddress, PaymentReference, TicketHolder, TicketHolderLanguage));
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

    internal procedure ConfirmRevokeTicket(DocumentId: Text[100]; SendNotificationTo: Text[100]; ExternalDocumentNo: Code[20]; TicketHolderName: Text[100]; TicketHolderLanguage: Code[10]) Response: Codeunit "NPR API Response"
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        TicketRequestManager.SetReservationRequestExtraInfo(DocumentID,
              SendNotificationTo,
              ExternalDocumentNo,
              TicketHolderName,
              TicketHolderLanguage);

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
            .AddObject(AddPrintedTicketDetails(ResponseJson, Ticket))
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
            .AddObject(AddPrintedTicketDetails(ResponseJson, Ticket))
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

    local procedure FindTicketByTicketID(TicketIdText: Text[50]; StoreCode: Code[32]; ActiveOnly: Boolean; WithAdmissionDetails: Boolean; WithAccessHistory: Boolean; WithAccessHistoryDetails: Boolean) Response: Codeunit "NPR API Response"
    var
        Ticket: Record "NPR TM Ticket";
        TicketId: Guid;
        ResponseJson: Codeunit "NPR JSON Builder";
        HaveTicket: Boolean;
    begin

        HaveTicket := true;
        Ticket.Init();
        Ticket.SetLoadFields("External Ticket No.", "Item No.", "Valid From Date", "Valid From Time", "Valid To Date", "Valid To Time", "No.", AmountExclVat, AmountInclVat, Blocked, PrintedDateTime, PrintCount, SystemCreatedAt);

        if (Evaluate(TicketId, TicketIdText)) then
            if (not Ticket.GetBySystemId(TicketId)) then
                HaveTicket := false;

        if (HaveTicket) then begin
            if (ActiveOnly and Ticket.Blocked) then
                HaveTicket := false;

            if (ActiveOnly) then
                if (Ticket."Valid From Date" <> 0D) then
                    if (Ticket."Valid To Date" <> 0D) then
                        if (Ticket."Valid To Date" < Today()) then
                            HaveTicket := false;
        end;

        if (not HaveTicket) then
            exit(Response.RespondOk(ResponseJson.StartArray().EndArray().BuildAsArray()));

        ResponseJson.StartArray();
        ResponseJson.AddObject(SingleTicketDTO(ResponseJson, Ticket, StoreCode, WithAdmissionDetails, WithAccessHistory, WithAccessHistoryDetails));
        ResponseJson.EndArray();

        exit(Response.RespondOk(ResponseJson.BuildAsArray()));
    end;


    local procedure FindTicketByExternalNumber(ExternalNumbers: List of [Text]; StoreCode: Code[32]; ActiveOnly: Boolean; WithAdmissionDetails: Boolean; WithAccessHistory: Boolean; WithAccessHistoryDetails: Boolean) Response: Codeunit "NPR API Response"
    var
        Ticket: Record "NPR TM Ticket";
        ResponseJson: Codeunit "NPR JSON Builder";
        HaveTicket: Boolean;
        ExternalNumber: Text;
    begin
        ResponseJson.StartArray();
        foreach ExternalNumber in ExternalNumbers do begin

            HaveTicket := true;

            Ticket.SetCurrentKey("External Ticket No.");
            Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(ExternalNumber.Trim(), 1, MaxStrLen(Ticket."External Ticket No.")));
            Ticket.SetLoadFields("External Ticket No.", "Item No.", "Valid From Date", "Valid From Time", "Valid To Date", "Valid To Time", "No.", AmountExclVat, AmountInclVat, Blocked, PrintedDateTime, PrintCount, SystemCreatedAt);
            if (not Ticket.FindFirst()) then
                HaveTicket := false;

            if (HaveTicket) then begin
                if (ActiveOnly and Ticket.Blocked) then
                    HaveTicket := false;

                if (ActiveOnly) then
                    if (Ticket."Valid From Date" <> 0D) then
                        if (Ticket."Valid To Date" <> 0D) then
                            if (Ticket."Valid To Date" < Today()) then
                                HaveTicket := false;
            end;

            if (HaveTicket) then
                ResponseJson.AddObject(SingleTicketDTO(ResponseJson, Ticket, StoreCode, WithAdmissionDetails, WithAccessHistory, WithAccessHistoryDetails));
        end;
        ResponseJson.EndArray();

        exit(Response.RespondOk(ResponseJson.BuildAsArray()));
    end;

    local procedure FindTicketByNotificationAddress(NotificationAddress: Text; StoreCode: Code[32]; ActiveOnly: Boolean; WithAdmissionDetails: Boolean; WithAccessHistory: Boolean; WithAccessHistoryDetails: Boolean) Response: Codeunit "NPR API Response"
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        TicketDescriptionBuffer: Record "NPR TM TempTicketDescription";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        ResponseJson: Codeunit "NPR JSON Builder";
        TicketingCatalog: Codeunit "NPR TicketingCatalogAgent";
        BadFilter: Boolean;
        IncludeTicket: Boolean;
    begin
        BadFilter := false;

        if (NotificationAddress.Contains('@')) then
            if (StrLen(NotificationAddress.Replace('@', '')) + 1 <> StrLen(NotificationAddress)) then
                BadFilter := true;

        if (not NotificationAddress.Contains('@')) then
            if (NotificationAddress.ToUpper().StartsWith('%2B')) then
                NotificationAddress := NotificationAddress.ToUpper().Replace('%2B', '+');

        NotificationAddress := DelChr(NotificationAddress, '<=>', '*?|&');
        NotificationAddress := NotificationAddress.Replace('..', '');
        NotificationAddress := NotificationAddress.Replace('@', '?');
        if (NotificationAddress = '') then
            BadFilter := true;

        ReservationRequest.SetCurrentKey("Notification Address");
        ReservationRequest.SetFilter("Notification Address", '%1', CopyStr('@' + NotificationAddress, 1, MaxStrLen(ReservationRequest."Notification Address")));
        ReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        ReservationRequest.SetLoadFields("Notification Address", "Entry No.", "Primary Request Line", "Item No.", TicketHolderPreferredLanguage);

        ResponseJson.StartArray();
        if (not BadFilter) then begin
            if (ReservationRequest.FindSet()) then begin
                GeneralLedgerSetup.Get();

                repeat
                    TicketingCatalog.GetCatalogItemDescription(StoreCode, ReservationRequest."Item No.", TicketDescriptionBuffer, ReservationRequest.TicketHolderPreferredLanguage);

                    Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', ReservationRequest."Entry No.");
                    Ticket.SetLoadFields("External Ticket No.", "Item No.", "Valid From Date", "Valid From Time", "Valid To Date", "Valid To Time", "No.", AmountExclVat, AmountInclVat, Blocked, PrintedDateTime, PrintCount, SystemCreatedAt);
                    if (Ticket.FindSet()) then begin
                        repeat
                            IncludeTicket := true;
                            if (ActiveOnly and Ticket.Blocked) then
                                IncludeTicket := false;

                            if (ActiveOnly) then
                                if (Ticket."Valid From Date" <> 0D) then
                                    if (Ticket."Valid To Date" <> 0D) then
                                        if (Ticket."Valid To Date" < Today()) then
                                            IncludeTicket := false;

                            if (IncludeTicket) then
                                ResponseJson.AddObject(SingleTicketDTO(ResponseJson, Ticket, GeneralLedgerSetup."LCY Code", WithAdmissionDetails, WithAccessHistory, WithAccessHistoryDetails, TicketDescriptionBuffer, ReservationRequest));

                        until (Ticket.Next() = 0);
                    end;
                until (ReservationRequest.Next() = 0);
            end;
        end;
        ResponseJson.EndArray();

        exit(Response.RespondOk(ResponseJson.BuildAsArray()));
    end;

    internal procedure TicketHistoryDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ArrayName: Text; Ticket: Record "NPR TM Ticket"; WithEvents: Boolean): Codeunit "NPR JSON Builder";
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketAccessEntryLine: Record "NPR TM Det. Ticket AccessEntry";
        TimeHelper: Codeunit "NPR TM TimeHelper";
    begin
        ResponseJson.StartArray(ArrayName);

        TicketAccessEntry.SetCurrentKey("Ticket No.");
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.SetLoadFields("Admission Code", "Access Date", "Access Time", Status, "Entry No.");
        if (TicketAccessEntry.FindSet()) then begin
            repeat
                ResponseJson.StartObject()
                    .AddProperty('admissionCode', TicketAccessEntry."Admission Code")
                    .AddObject(AddRequiredProperty(ResponseJson, 'firstAdmissionAt', TimeHelper.FormatDateTimeWithAdmissionTimeZone(TicketAccessEntry."Admission Code", TicketAccessEntry."Access Date", TicketAccessEntry."Access Time")));

                if (WithEvents) then begin
                    ResponseJson.StartArray('events');
                    TicketAccessEntryLine.SetCurrentKey("Ticket Access Entry No.", Type);
                    TicketAccessEntryLine.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
                    TicketAccessEntryLine.SetFilter(Type, '=%1|=%2|=%3', TicketAccessEntryLine.Type::ADMITTED, TicketAccessEntryLine.Type::CANCELED_ADMISSION, TicketAccessEntryLine.Type::DEPARTED);
                    TicketAccessEntryLine.SetLoadFields(SystemCreatedAt, Type);
                    if (TicketAccessEntryLine.FindSet()) then begin
                        repeat
                            ResponseJson.StartObject()
                                .AddProperty('event', AdmissionTypeToText(TicketAccessEntryLine.Type))
                                .AddProperty('eventAt', TimeHelper.FormatDateTimeWithAdmissionTimeZone(TicketAccessEntry."Admission Code", TimeHelper.AdjustZuluToAdmissionLocalDateTime(TicketAccessEntry."Admission Code", TicketAccessEntryLine.SystemCreatedAt)))
                                .EndObject();
                        until (TicketAccessEntryLine.Next() = 0);
                    end;
                    ResponseJson.EndArray();
                end;

                ResponseJson.EndObject();
            until (TicketAccessEntry.Next() = 0);
        end;

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;


    local procedure SingleTicketDTO(Ticket: Record "NPR TM Ticket"; StoreCode: Code[32]; WithAdmissionDetails: Boolean; WithAccessHistory: Boolean; WithAccessHistoryDetails: Boolean) ResponseJson: Codeunit "NPR JSON Builder";
    begin
        exit(ResponseJson.Initialize().AddObject(SingleTicketDTO(ResponseJson, Ticket, StoreCode, WithAdmissionDetails, WithAccessHistory, WithAccessHistoryDetails)));
    end;

    local procedure SingleTicketDTO(ResponseJson: Codeunit "NPR JSON Builder"; Ticket: Record "NPR TM Ticket"; StoreCode: Code[32]; WithAdmissionDetails: Boolean; WithAccessHistory: Boolean; WithAccessHistoryDetails: Boolean): Codeunit "NPR JSON Builder";
    var
        TicketingCatalog: Codeunit "NPR TicketingCatalogAgent";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TicketDescriptionBuffer: Record "NPR TM TempTicketDescription";
    begin
        GeneralLedgerSetup.Get();

        ReservationRequest.SetLoadFields("Session Token ID", "Authorization Code", "TicketHolderName", "TicketHolderPreferredLanguage", "Notification Address");
        if (not ReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
            ReservationRequest.Init();

        TicketingCatalog.GetCatalogItemDescription(StoreCode, Ticket."Item No.", TicketDescriptionBuffer, ReservationRequest.TicketHolderPreferredLanguage);

        exit(ResponseJson.AddObject(SingleTicketDTO(ResponseJson, Ticket, GeneralLedgerSetup."LCY Code", WithAdmissionDetails, WithAccessHistory, WithAccessHistoryDetails, TicketDescriptionBuffer, ReservationRequest)));
    end;

    internal procedure SingleTicketDTO(ResponseJson: Codeunit "NPR JSON Builder";
                            Ticket: Record "NPR TM Ticket";
                            CurrencyCode: Code[10];
                            WithAdmissionDetails: Boolean; WithAccessHistory: Boolean; WithAccessHistoryDetails: Boolean;
                            var TicketDescriptionBuffer: Record "NPR TM TempTicketDescription";
                            ReservationRequest: Record "NPR TM Ticket Reservation Req."): Codeunit "NPR JSON Builder";
    begin
        ResponseJson.StartObject()
            .AddProperty('ticketId', Format(Ticket.SystemId, 0, 4).ToLower())
            .AddProperty('ticketNumber', Ticket."External Ticket No.")
            .AddProperty('itemNumber', Ticket."Item No.")
            .AddProperty('reservationToken', ReservationRequest."Session Token ID")
            .AddObject(TicketValidDateProperties(ResponseJson, Ticket));

        if (WithAdmissionDetails) then
            ResponseJson.AddArray(AdmissionDetailsDTO(ResponseJson, 'content', Ticket, TicketDescriptionBuffer));

        if (WithAdmissionDetails) then
            ResponseJson.StartObject('description')
                    .AddObject(AddPropertyNotNull(ResponseJson, 'title', TicketDescriptionBuffer.Title))
                    .AddObject(AddPropertyNotNull(ResponseJson, 'subtitle', TicketDescriptionBuffer.Subtitle))
                    .AddObject(AddPropertyNotNull(ResponseJson, 'name', TicketDescriptionBuffer.Name))
                    .AddObject(AddPropertyNotNull(ResponseJson, 'description', TicketDescriptionBuffer.Description))
                    .AddObject(AddPropertyNotNull(ResponseJson, 'fullDescription', TicketDescriptionBuffer.FullDescription))
                .EndObject();

        ResponseJson
            .AddProperty('pinCode', ReservationRequest."Authorization Code")
            .AddProperty('unitPrice', Ticket.AmountExclVat)
            .AddProperty('unitPriceInclVat', Ticket.AmountInclVat)
            .AddProperty('currencyCode', CurrencyCode)
            .AddProperty('ticketHolder', ReservationRequest.TicketHolderName)
            .AddProperty('ticketHolderLanguage', ReservationRequest.TicketHolderPreferredLanguage)
            .AddProperty('notificationAddress', ReservationRequest."Notification Address")
            .AddObject(AddPrintedTicketDetails(ResponseJson, Ticket));
        if (WithAccessHistory or WithAccessHistoryDetails) then
            ResponseJson.AddArray(TicketHistoryDTO(ResponseJson, 'accessHistory', Ticket, WithAccessHistoryDetails));

        ResponseJson.EndObject();

        exit(ResponseJson);
    end;

    internal procedure TicketValidDateProperties(ResponseJson: Codeunit "NPR JSON Builder"; Ticket: Record "NPR TM Ticket"): Codeunit "NPR JSON Builder";
    var
        TimeZoneHelper: Codeunit "NPR TM TimeHelper";
    begin
        ResponseJson
            .AddProperty('validFrom', TimeZoneHelper.FormatDateTimeWithAdmissionTimeZone('', Ticket."Valid From Date", Ticket."Valid From Time"))
            .AddProperty('validUntil', TimeZoneHelper.FormatDateTimeWithAdmissionTimeZone('', Ticket."Valid To Date", Ticket."Valid To Time"))
            .AddProperty('issuedAt', TimeZoneHelper.FormatDateTimeWithAdmissionTimeZone('', TimeZoneHelper.AdjustZuluToAdmissionLocalDateTime('', Ticket.SystemCreatedAt)))
            .AddProperty('blocked', Ticket.Blocked);
        exit(ResponseJson);
    end;

    local procedure AddPrintedTicketDetails(var ResponseJson: Codeunit "NPR JSON Builder"; Ticket: Record "NPR TM Ticket"): Codeunit "NPR JSON Builder"
    begin
        if (Ticket.PrintedDateTime > 0DT) then
            ResponseJson
                .AddProperty('printedAt', Ticket.PrintedDateTime)
                .AddProperty('printCount', Ticket.PrintCount)
        else
            ResponseJson
                .AddProperty('printedAt')
                .AddProperty('printCount', Ticket.PrintCount);

        exit(ResponseJson);
    end;

    local procedure AddPropertyNotNull(var ResponseJson: Codeunit "NPR JSON Builder"; PropertyName: Text; PropertyValue: Text): Codeunit "NPR JSON Builder"
    begin
        if (PropertyValue <> '') then
            ResponseJson.AddProperty(PropertyName, PropertyValue);
        exit(ResponseJson);
    end;

    // one of ticket inquiry use cases
    internal procedure AdmissionDetailsDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ArrayName: Text; Ticket: Record "NPR TM Ticket"): Codeunit "NPR JSON Builder";
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketDescriptionBuffer: Record "NPR TM TempTicketDescription";
        TicketingCatalog: Codeunit "NPR TicketingCatalogAgent";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        ResponseJson.StartArray(ArrayName);

        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (TicketAccessEntry.FindSet()) then begin
            ReservationRequest.SetLoadFields("TicketHolderPreferredLanguage");
            if (not ReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
                ReservationRequest.Init();
            TicketingCatalog.GetCatalogItemDescription('', Ticket."Item No.", TicketDescriptionBuffer, ReservationRequest.TicketHolderPreferredLanguage);
            repeat
                ResponseJson.StartObject()
                    .AddObject(AdmissionDTO(ResponseJson, 'admissionDetails', Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code", TicketAccessEntry.Status = TicketAccessEntry.Status::BLOCKED, 255, TicketDescriptionBuffer))
                    .AddObject(ScheduleDetailsDTO(ResponseJson, 'scheduleDetails', TicketAccessEntry."Entry No."))
                .EndObject();
            until (TicketAccessEntry.Next() = 0);
        end;

        ResponseJson.EndArray();
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
                    .AddObject(AdmissionDTO(ResponseJson, 'admissionDetails', Ticket."Item No.", Ticket."Variant Code", TicketAccessEntry."Admission Code", TicketAccessEntry.Status = TicketAccessEntry.Status::BLOCKED, 255, TicketDescriptionBuffer))
                    .AddObject(ScheduleDetailsDTO(ResponseJson, 'scheduleDetails', TicketAccessEntry."Entry No."))
                .EndObject();
            until (TicketAccessEntry.Next() = 0);
        end;

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;

    internal procedure AdmissionDTO(
        var ResponseJson: Codeunit "NPR JSON Builder";
        ObjectName: Text; ItemNo: Code[20]; VariantCode: Code[10];
        AdmissionCode: Code[20]; IsBlocked: Boolean; AdmissionInclusion: Option;
        var TicketDescriptionBuffer: Record "NPR TM TempTicketDescription"): Codeunit "NPR JSON Builder"
    var
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission Bom";
        EnumEncoder: Codeunit "NPR TicketingApiTranslations";
    begin
        Admission.Get(AdmissionCode);
        TicketBom.Get(ItemNo, VariantCode, AdmissionCode);
        TicketDescriptionBuffer.Get(ItemNo, VariantCode, AdmissionCode);
        if (AdmissionInclusion = 255) then begin
            AdmissionInclusion := TicketBom."Admission Inclusion"::REQUIRED;
            if (TicketBom."Admission Inclusion" <> TicketBom."Admission Inclusion"::REQUIRED) then
                AdmissionInclusion := TicketBom."Admission Inclusion"::SELECTED; // Actual tickets will not include admission you opted out of
        end;

        ResponseJson.StartObject(ObjectName)
            .AddProperty('code', TicketBom."Admission Code")
            .AddProperty('default', TicketBom.Default)
            .AddProperty('blocked', IsBlocked)
            .AddProperty('included', EnumEncoder.EncodeInclusion(AdmissionInclusion))
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

        if (ExtScheduleEntryNo = 0) then begin
            ResponseJson
                .AddProperty('externalNumber', 0)
                .AddProperty('code', '')
                .AddProperty('description', 'Reservation not found')
                .EndObject();
            exit(ResponseJson);
        end;

        ScheduleEntry.SetCurrentKey("External Schedule Entry No.");
        ScheduleEntry.SetLoadFields("External Schedule Entry No.", "Schedule Code", "Admission Start Date", "Admission Start Time", "Admission End Date", "Admission End Time", "Event Arrival From Time", "Event Arrival Until Time");
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

    local procedure AdmissionTypeToText(AdmissionType: Option): Text[50]
    var
        TicketAccessEntryLine: Record "NPR TM Det. Ticket AccessEntry";
    begin
        case AdmissionType of
            TicketAccessEntryLine.Type::INITIAL_ENTRY:
                exit('initialEntry');
            TicketAccessEntryLine.Type::RESERVATION:
                exit('reservation');
            TicketAccessEntryLine.Type::ADMITTED:
                exit('admitted');
            TicketAccessEntryLine.Type::DEPARTED:
                exit('departed');
            TicketAccessEntryLine.Type::CONSUMED:
                exit('consumed');
            TicketAccessEntryLine.Type::CANCELED_ADMISSION:
                exit('canceledAdmission');
            TicketAccessEntryLine.Type::PAYMENT:
                exit('payment');
            TicketAccessEntryLine.Type::PREPAID:
                exit('prePaid');
            TicketAccessEntryLine.Type::POSTPAID:
                exit('postPaid');
            TicketAccessEntryLine.Type::CANCELED_RESERVATION:
                exit('canceledReservation');
            else
                exit('unknown');
        end;
    end;

    local procedure AddRequiredProperty(var ResponseJson: Codeunit "NPR JSON Builder"; PropertyName: Text; PropertyValue: Text): Codeunit "NPR JSON Builder"
    begin
        if (PropertyValue = '') then
            exit(ResponseJson.AddProperty(PropertyName)); // Empty property with null value (not "")

        exit(ResponseJson.AddProperty(PropertyName, PropertyValue));
    end;
#pragma warning disable AA0139
    local procedure CreateDocumentId(): Text[50]
    begin
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;
#pragma warning restore
}
#endif