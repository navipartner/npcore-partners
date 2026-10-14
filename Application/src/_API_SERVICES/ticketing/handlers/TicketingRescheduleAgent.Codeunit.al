#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6151261 "NPR TicketingRescheduleAgent"
{
    Access = Internal;

    var
        RSF001Err: Label '[RSF001] The request body must be a JSON object', Locked = true;
        RSF002Err: Label '[RSF002] Missing required property pinCode', Locked = true;
        RSF003Err: Label '[RSF003] Exactly one of ticketNumber and reservationToken is required', Locked = true;
        RSF004Err: Label '[RSF004] Invalid fromDate, expected format is yyyy-mm-dd', Locked = true;
        RSF005Err: Label '[RSF005] Invalid toDate, expected format is yyyy-mm-dd', Locked = true;
        RSF006Err: Label '[RSF006] fromDate must be on or before toDate', Locked = true;
        RSF007Err: Label '[RSF007] The window from fromDate to toDate exceeds the maximum of %1 days', Locked = true;
        RSF008Err: Label '[RSF008] Property %1 must be a string', Locked = true;
        RSF009Err: Label '[RSF009] Property %1 must not be empty', Locked = true;
        TicketPinNotValidLbl: Label 'The combination of ticket number and pin code is not valid.', Locked = true;
        TokenPinNotValidLbl: Label 'The combination of reservation token and pin code is not valid.', Locked = true;
        InternalErrorLbl: Label 'An internal error occurred. The request was logged.', Locked = true;
        ProgrammingBugLbl: Label '%1 This is a programming bug', Locked = true;
        ProgrammingBugSuffixLbl: Label 'This is a programming bug', Locked = true;

        _TicketNumber: Code[30];
        _ReservationToken: Text[100];
        _PinCode: Text;
        _FromDate: Date;
        _ToDate: Date;
        _Found: Boolean;
        _ResponseBody: JsonObject;

    trigger OnRun()
    begin
        _Found := BuildFindResponse(_TicketNumber, _ReservationToken, _PinCode, _FromDate, _ToDate, _ResponseBody);
    end;

    internal procedure FindReservation(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        FindWorker: Codeunit "NPR TicketingRescheduleAgent";
        Sentry: Codeunit "NPR Sentry";
        Body: JsonObject;
        BodyToken: JsonToken;
        ResponseBody: JsonObject;
        PinCode: Text;
        TicketNumberText: Text;
        ReservationTokenText: Text;
        FromDateText: Text;
        ToDateText: Text;
        HasPinCode: Boolean;
        HasTicketNumber: Boolean;
        HasReservationToken: Boolean;
        HasFromDate: Boolean;
        HasToDate: Boolean;
        FromDate: Date;
        ToDate: Date;
        ErrorText: Text;
        ErrorCallStack: Text;
    begin
        BodyToken := Request.BodyJson();
        if (not BodyToken.IsObject()) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, RSF001Err));
        Body := BodyToken.AsObject();

        if (not TryGetString(Body, 'pinCode', PinCode, HasPinCode)) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, StrSubstNo(RSF008Err, 'pinCode')));
        if ((not HasPinCode) or (PinCode = '')) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, RSF002Err));

        if (not TryGetString(Body, 'ticketNumber', TicketNumberText, HasTicketNumber)) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, StrSubstNo(RSF008Err, 'ticketNumber')));
        if (not TryGetString(Body, 'reservationToken', ReservationTokenText, HasReservationToken)) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, StrSubstNo(RSF008Err, 'reservationToken')));
        if (HasTicketNumber = HasReservationToken) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, RSF003Err));
        if (HasTicketNumber and (TicketNumberText = '')) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, StrSubstNo(RSF009Err, 'ticketNumber')));
        if (HasReservationToken and (ReservationTokenText = '')) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, StrSubstNo(RSF009Err, 'reservationToken')));

        FromDate := Today();
        if (not TryGetString(Body, 'fromDate', FromDateText, HasFromDate)) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, StrSubstNo(RSF008Err, 'fromDate')));
        if (HasFromDate) then
            if (not Evaluate(FromDate, FromDateText, 9)) then
                exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, RSF004Err));

        ToDate := CalcDate('<+1M>', FromDate);
        if (not TryGetString(Body, 'toDate', ToDateText, HasToDate)) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, StrSubstNo(RSF008Err, 'toDate')));
        if (HasToDate) then
            if (not Evaluate(ToDate, ToDateText, 9)) then
                exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, RSF005Err));

        if (FromDate > ToDate) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, RSF006Err));
        if ((ToDate - FromDate) > MaxWindowDays()) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, StrSubstNo(RSF007Err, MaxWindowDays())));

        // Identifier and pin shape failures are identity failures (uniform 404), never invalid_input.
        if ((StrLen(TicketNumberText) > 30) or (StrLen(ReservationTokenText) > 100)) then
            exit(UniformNotFound(Response, HasTicketNumber));

        FindWorker.SetFindRequest(CopyStr(UpperCase(TicketNumberText), 1, 30), CopyStr(ReservationTokenText, 1, 100), PinCode, FromDate, ToDate);
        if (not FindWorker.Run()) then begin
            Sentry.GetLastErrorInEnglish(ErrorText, ErrorCallStack);
            if (not ErrorText.EndsWith(ProgrammingBugSuffixLbl)) then
                ErrorText := StrSubstNo(ProgrammingBugLbl, ErrorText);
            Sentry.AddError(ErrorText, ErrorCallStack);
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::generic_error, InternalErrorLbl));
        end;

        if (not FindWorker.GetFindResult(ResponseBody)) then
            exit(UniformNotFound(Response, HasTicketNumber));

        Response.RespondOK(ResponseBody);
        exit(Response);
    end;

    internal procedure SetFindRequest(TicketNumber: Code[30]; ReservationToken: Text[100]; PinCode: Text; FromDate: Date; ToDate: Date)
    begin
        _TicketNumber := TicketNumber;
        _ReservationToken := ReservationToken;
        _PinCode := PinCode;
        _FromDate := FromDate;
        _ToDate := ToDate;
        _Found := false;
        Clear(_ResponseBody);
    end;

    internal procedure GetFindResult(var ResponseBody: JsonObject): Boolean
    begin
        ResponseBody := _ResponseBody;
        exit(_Found);
    end;

    local procedure MaxWindowDays(): Integer
    begin
        exit(62);
    end;

    local procedure UniformNotFound(var Response: Codeunit "NPR API Response"; ByTicketNumber: Boolean): Codeunit "NPR API Response"
    begin
        if (ByTicketNumber) then
            exit(Response.CreateErrorResponse(Enum::"NPR API Error Code"::resource_not_found, TicketPinNotValidLbl, Enum::"NPR API HTTP Status Code"::"Not Found"));
        exit(Response.CreateErrorResponse(Enum::"NPR API Error Code"::resource_not_found, TokenPinNotValidLbl, Enum::"NPR API HTTP Status Code"::"Not Found"));
    end;

    local procedure TryGetString(Body: JsonObject; PropertyName: Text; var Value: Text; var Present: Boolean): Boolean
    var
        JToken: JsonToken;
        RawJson: Text;
    begin
        Value := '';
        Present := false;
        if (not Body.Get(PropertyName, JToken)) then
            exit(true);
        if (not JToken.IsValue()) then
            exit(false);
        if (JToken.AsValue().IsNull()) then
            exit(true);
        JToken.WriteTo(RawJson);
        if (not RawJson.StartsWith('"')) then
            exit(false);
        Present := true;
        Value := JToken.AsValue().AsText();
        exit(true);
    end;

    local procedure BuildFindResponse(TicketNumber: Code[30]; ReservationToken: Text[100]; PinCode: Text; FromDate: Date; ToDate: Date; var ResponseBody: JsonObject): Boolean
    var
        TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary;
        TempSlot: Record "NPR TM Admis. Schedule Entry" temporary;
        TicketReschedule: Codeunit "NPR TM Ticket Reschedule";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        ResponseJson: Codeunit "NPR JSON Builder";
        RemainingByEntryNo: Dictionary of [Integer, Integer];
        OriginalToken: Text[100];
        LastPrimaryEntryNo: Integer;
    begin
        if (not TicketReschedule.ResolveIdentity(TicketNumber, ReservationToken, PinCode, OriginalToken)) then
            exit(false);
        if (not TicketReschedule.IsOriginalRequestConfirmed(OriginalToken)) then
            exit(false);

        TicketReschedule.LoadCurrentLines(OriginalToken, TempLineBuffer);
        TicketReschedule.EvaluateEligibility(TempLineBuffer);
        if (not TicketReschedule.AnyAdmissionCanMove(TempLineBuffer)) then
            exit(false);

        Sentry.StartSpan(Span, StrSubstNo('bc.ticket-api.reschedule.find.slots %1..%2 (%3 days)', Format(FromDate, 0, 9), Format(ToDate, 0, 9), ToDate - FromDate + 1));
        Sentry.AddTransactionData('reschedule-find.days', Format(ToDate - FromDate + 1));
        ResponseJson.Initialize();
        ResponseJson.StartObject()
            .StartObject('reservation')
                .AddProperty('reservationToken', OriginalToken)
                .StartArray('reservationLines');

        TempLineBuffer.Reset();
        TempLineBuffer.FindSet();
        LastPrimaryEntryNo := 0;
        repeat
            if (TempLineBuffer.CurrentPrimaryEntryNo <> LastPrimaryEntryNo) then begin
                if (LastPrimaryEntryNo <> 0) then
                    ResponseJson.EndArray().EndObject();
                LastPrimaryEntryNo := TempLineBuffer.CurrentPrimaryEntryNo;
                ResponseJson.StartObject()
                    .AddProperty('systemId', Format(TempLineBuffer.CurrentPrimarySystemId, 0, 4).ToLower())
                    .AddProperty('externalLineReference', TempLineBuffer.LineReferenceNo)
                    .AddProperty('itemNumber', TempLineBuffer.ItemNo)
                    .AddProperty('variantCode', TempLineBuffer.VariantCode)
                    .AddProperty('quantity', TempLineBuffer.Quantity)
                    .AddProperty('validFromDate', TempLineBuffer.ValidFromDate)
                    .AddProperty('validToDate', TempLineBuffer.ValidToDate)
                    .StartArray('admissions');
            end;

            ResponseJson.StartObject()
                .AddProperty('admissionCode', TempLineBuffer.AdmissionCode)
                .AddProperty('description', TempLineBuffer.AdmissionDescription);
            CurrentScheduleDTO(ResponseJson, TempLineBuffer.CurrentExtScheduleEntryNo, OriginalToken);
            ResponseJson
                .AddProperty('rescheduleAllowed', TempLineBuffer.RescheduleAllowed)
                .AddProperty('reasonCode', ReasonCodeText(TempLineBuffer.RefusalReason))
                .StartArray('slots');

            TicketReschedule.GetSlots(TempLineBuffer, FromDate, ToDate, TempSlot, RemainingByEntryNo);
            TempSlot.Reset();
            TempSlot.SetCurrentKey("Admission Start Date", "Admission Start Time");
            if (TempSlot.FindSet()) then
                repeat
                    ResponseJson.StartObject();
                    SlotProperties(ResponseJson, TempSlot);
                    if (RemainingByEntryNo.ContainsKey(TempSlot."Entry No.")) then
                        ResponseJson.AddProperty('remainingCapacity', RemainingByEntryNo.Get(TempSlot."Entry No."))
                    else
                        ResponseJson.AddProperty('remainingCapacity');
                    ResponseJson.EndObject();
                until (TempSlot.Next() = 0);

            ResponseJson.EndArray().EndObject();
        until (TempLineBuffer.Next() = 0);

        ResponseJson.EndArray().EndObject();
        ResponseJson.EndArray().EndObject().EndObject();
        Span.Finish();
        ResponseBody := ResponseJson.Build();
        exit(true);
    end;

    local procedure CurrentScheduleDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ExtScheduleEntryNo: Integer; OriginalToken: Text[100])
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        NoCurrentSlotErr: Label 'Ticket reschedule integrity failure for token %1: schedule entry %2 does not exist. This is a programming bug', Locked = true;
    begin
        ScheduleEntry.SetCurrentKey("External Schedule Entry No.");
        ScheduleEntry.SetRange("External Schedule Entry No.", ExtScheduleEntryNo);
        ScheduleEntry.SetRange(Cancelled, false);
        if (not ScheduleEntry.FindLast()) then begin
            ScheduleEntry.SetRange(Cancelled);
            if (not ScheduleEntry.FindLast()) then
                Error(NoCurrentSlotErr, OriginalToken, ExtScheduleEntryNo);
        end;
        ResponseJson.StartObject('currentSchedule');
        SlotProperties(ResponseJson, ScheduleEntry);
        ResponseJson.EndObject();
    end;

    local procedure SlotProperties(var ResponseJson: Codeunit "NPR JSON Builder"; ScheduleEntry: Record "NPR TM Admis. Schedule Entry")
    begin
        ResponseJson
            .AddProperty('scheduleNumber', ScheduleEntry."External Schedule Entry No.")
            .AddProperty('startDate', ScheduleEntry."Admission Start Date")
            .AddProperty('startTime', ScheduleEntry."Admission Start Time")
            .AddProperty('endDate', ScheduleEntry."Admission End Date")
            .AddProperty('endTime', ScheduleEntry."Admission End Time");
    end;

    local procedure ReasonCodeText(Refusal: Enum "NPR TM Reschedule Refusal"): Text
    begin
        if (Refusal = Refusal::NONE) then
            exit('');
        exit(Refusal.Names().Get(Refusal.Ordinals().IndexOf(Refusal.AsInteger())));
    end;
}
#endif
