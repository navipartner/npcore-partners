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
        RSF010Err: Label '[RSF010] No admission of this reservation can be rescheduled now. Reasons: %1.', Locked = true;
        RSF011Err: Label '[RSF011] No admission of this reservation has a time slot that can be rescheduled.', Locked = true;
        RSC001Err: Label '[RSC001] The request body must be a JSON object', Locked = true;
        RSC002Err: Label '[RSC002] Missing required property %1', Locked = true;
        RSC003Err: Label '[RSC003] Property %1 must be a string', Locked = true;
        RSC004Err: Label '[RSC004] Property %1 must not be empty', Locked = true;
        RSC005Err: Label '[RSC005] Property reservationLines must be an array with 1 to %1 elements', Locked = true;
        RSC006Err: Label '[RSC006] reservationLines[%1] must be an object', Locked = true;
        RSC007Err: Label '[RSC007] reservationLines[%1].systemId must be a GUID string', Locked = true;
        RSC008Err: Label '[RSC008] reservationLines[%1].systemId appears more than once', Locked = true;
        RSC009Err: Label '[RSC009] reservationLines[%1].admissions must be a non-empty array', Locked = true;
        RSC010Err: Label '[RSC010] reservationLines[%1].admissions[%2] must be an object', Locked = true;
        RSC011Err: Label '[RSC011] reservationLines[%1].admissions[%2].admissionCode must be a non-empty string of at most %3 characters', Locked = true;
        RSC012Err: Label '[RSC012] reservationLines[%1].admissions[%2].admissionCode appears more than once in the line', Locked = true;
        RSC013Err: Label '[RSC013] reservationLines[%1].admissions[%2].scheduleNumber must be a positive integer', Locked = true;
        RSC020Err: Label '[RSC020] Line %1, admission %2: the line, the admission or the slot is not valid for this reservation now. Call find again.', Locked = true;
        RSC021Err: Label '[RSC021] Line %1, admission %2: the admission cannot be rescheduled now (%3).', Locked = true;
        RSC022Err: Label '[RSC022] Line %1, admission %2: the slot does not have capacity for the line.', Locked = true;
        RSC023Err: Label '[RSC023] Line %1 changes no admission.', Locked = true;
        RSC024Err: Label '[RSC024] The reservation is being changed by another request. Call find again.', Locked = true;
        RSC030Err: Label '[RSC030] A selected admission can no longer be rescheduled. Call find again.', Locked = true;
        RSC031Err: Label '[RSC031] A selected slot no longer has capacity for the line. Call find again.', Locked = true;
        RSC032Err: Label '[RSC032] A selected slot is no longer valid. Call find again.', Locked = true;
        TicketPinNotValidLbl: Label 'The combination of ticket number and pin code is not valid.', Locked = true;
        TokenPinNotValidLbl: Label 'The combination of reservation token and pin code is not valid.', Locked = true;
        InternalErrorLbl: Label 'An internal error occurred. The request was logged.', Locked = true;
        ProgrammingBugLbl: Label '%1 This is a programming bug', Locked = true;
        ProgrammingBugSuffixLbl: Label 'This is a programming bug', Locked = true;
        PublishTokenFailedLbl: Label 'Publishing the confirmed change request %1 failed: %2', Locked = true;

        _TicketNumber: Code[30];
        _ReservationToken: Text[100];
        _PinCode: Text;
        _FromDate: Date;
        _ToDate: Date;
        _Found: Boolean;
        _ResponseBody: JsonObject;
        _NoMoveReasons: Text;
        _NoTimeSlot: Boolean;

    trigger OnRun()
    begin
        _Found := BuildFindResponse(_TicketNumber, _ReservationToken, _PinCode, _FromDate, _ToDate, _ResponseBody, _NoMoveReasons, _NoTimeSlot);
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
        NoMoveReasons: Text;
        NoTimeSlot: Boolean;
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

        if (not FindWorker.GetFindResult(ResponseBody, NoMoveReasons, NoTimeSlot)) then begin
            if (NoTimeSlot) then
                exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::reschedule_not_allowed, RSF011Err));
            if (NoMoveReasons <> '') then
                exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::reschedule_not_allowed, StrSubstNo(RSF010Err, NoMoveReasons)));
            exit(UniformNotFound(Response, HasTicketNumber));
        end;

        Response.RespondOK(ResponseBody);
        exit(Response);
    end;

    internal procedure ChangeReservation(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TempRequest: Record "NPR TM Reschedule Line Buffer" temporary;
        ChangeWorker: Codeunit "NPR TM Resched. Change Worker";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        Body: JsonObject;
        BodyToken: JsonToken;
        ResponseBody: JsonObject;
        ChangeTokens: List of [Text[100]];
        ReservationTokenText: Text;
        PinCode: Text;
        ValidationError: Text;
        Outcome: Enum "NPR TM Resched. Change Outcome";
        Refusal: Enum "NPR TM Reschedule Refusal";
        LineCount: Integer;
        FailedRequestEntryNo: Integer;
    begin
        BodyToken := Request.BodyJson();
        if (not BodyToken.IsObject()) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, RSC001Err));
        Body := BodyToken.AsObject();

        if (not GetRequiredString(Body, 'reservationToken', ReservationTokenText, ValidationError)) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, ValidationError));
        if (not GetRequiredString(Body, 'pinCode', PinCode, ValidationError)) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, ValidationError));
        if (not ReadChangeLines(Body, TempRequest, LineCount, ValidationError)) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, ValidationError));

        if (StrLen(ReservationTokenText) > MaxStrLen(TempRequest.OriginalToken)) then
            exit(UniformNotFound(Response, false));

        Sentry.StartSpan(Span, StrSubstNo('bc.ticket-api.reschedule.change (%1 lines)', LineCount));
        Sentry.AddTransactionData('reschedule-change.lines', Format(LineCount));
        ChangeWorker.SetChangeRequest(CopyStr(ReservationTokenText, 1, 100), PinCode, TempRequest);
        if (not ChangeWorker.Run()) then begin
            CapacityWebHook.ClearTouchedEntries();
            Span.Finish();
            ChangeWorker.GetChangeResult(ResponseBody, ChangeTokens, FailedRequestEntryNo, Refusal);
            exit(MapChangeError(Response, TempRequest, FailedRequestEntryNo));
        end;
        Span.Finish();

        Outcome := ChangeWorker.GetChangeResult(ResponseBody, ChangeTokens, FailedRequestEntryNo, Refusal);
        case Outcome of
            Outcome::CHANGED:
                begin
                    PublishChange(ChangeTokens);
                    exit(Response.RespondOK(ResponseBody));
                end;
            Outcome::NOT_FOUND:
                exit(UniformNotFound(Response, false));
            Outcome::BUSY:
                exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_reference, RSC024Err));
            Outcome::INVALID_INPUT:
                exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_input, RefusalMessage(RSC023Err, TempRequest, FailedRequestEntryNo)));
            Outcome::INVALID_REFERENCE:
                exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_reference, RefusalMessage(RSC020Err, TempRequest, FailedRequestEntryNo)));
            Outcome::NOT_ALLOWED:
                exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::reschedule_not_allowed, RefusalMessage(RSC021Err, TempRequest, FailedRequestEntryNo, ReasonCodeText(Refusal))));
            Outcome::CAPACITY_EXCEEDED:
                exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::capacity_exceeded, RefusalMessage(RSC022Err, TempRequest, FailedRequestEntryNo)));
        end;
    end;

    // The worker's Run committed the change, so an error of a confirm event subscriber or an e-ticket update is logged and the change is still answered.
    local procedure PublishChange(ChangeTokens: List of [Text[100]])
    var
        Token: Text[100];
    begin
        foreach Token in ChangeTokens do
            PublishChangeToken(Token);
    end;

    local procedure PublishChangeToken(Token: Text[100])
    var
        PublishWorker: Codeunit "NPR TM Resched. Change Worker";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Sentry: Codeunit "NPR Sentry";
        ErrorText: Text;
        ErrorCallStack: Text;
    begin
        PublishWorker.SetPublishRequest(Token);
        if (PublishWorker.Run()) then
            exit;
        CapacityWebHook.ClearTouchedEntries();
        Sentry.GetLastErrorInEnglish(ErrorText, ErrorCallStack);
        ErrorText := StrSubstNo(PublishTokenFailedLbl, Token, ErrorText);
        if (not ErrorText.EndsWith(ProgrammingBugSuffixLbl)) then
            ErrorText := StrSubstNo(ProgrammingBugLbl, ErrorText);
        Sentry.AddError(ErrorText, ErrorCallStack);
    end;

    local procedure GetRequiredString(Body: JsonObject; PropertyName: Text; var Value: Text; var ValidationError: Text): Boolean
    var
        Present: Boolean;
    begin
        if (not TryGetString(Body, PropertyName, Value, Present)) then begin
            ValidationError := StrSubstNo(RSC003Err, PropertyName);
            exit(false);
        end;
        if (not Present) then begin
            ValidationError := StrSubstNo(RSC002Err, PropertyName);
            exit(false);
        end;
        if (Value = '') then begin
            ValidationError := StrSubstNo(RSC004Err, PropertyName);
            exit(false);
        end;
        exit(true);
    end;

    local procedure ReadChangeLines(Body: JsonObject; var TempRequest: Record "NPR TM Reschedule Line Buffer" temporary; var LineCount: Integer; var ValidationError: Text): Boolean
    var
        LinesToken: JsonToken;
        LineToken: JsonToken;
        AdmissionsToken: JsonToken;
        Lines: JsonArray;
        Admissions: JsonArray;
        LineObject: JsonObject;
        SeenSystemIds: List of [Guid];
        SeenAdmissionCodes: List of [Code[20]];
        SystemIdText: Text;
        SystemId: Guid;
        Present: Boolean;
        LineIndex: Integer;
        AdmissionIndex: Integer;
        NextEntryNo: Integer;
    begin
        if (not Body.Get('reservationLines', LinesToken)) then begin
            ValidationError := StrSubstNo(RSC002Err, 'reservationLines');
            exit(false);
        end;
        if (not LinesToken.IsArray()) then begin
            ValidationError := StrSubstNo(RSC005Err, MaxChangeLines());
            exit(false);
        end;
        Lines := LinesToken.AsArray();
        LineCount := Lines.Count();
        if ((LineCount = 0) or (LineCount > MaxChangeLines())) then begin
            ValidationError := StrSubstNo(RSC005Err, MaxChangeLines());
            exit(false);
        end;

        for LineIndex := 1 to LineCount do begin
            Lines.Get(LineIndex - 1, LineToken);
            if (not LineToken.IsObject()) then begin
                ValidationError := StrSubstNo(RSC006Err, LineIndex - 1);
                exit(false);
            end;
            LineObject := LineToken.AsObject();

            if ((not TryGetString(LineObject, 'systemId', SystemIdText, Present)) or (not Present) or (not Evaluate(SystemId, SystemIdText))) then begin
                ValidationError := StrSubstNo(RSC007Err, LineIndex - 1);
                exit(false);
            end;
            if (SeenSystemIds.Contains(SystemId)) then begin
                ValidationError := StrSubstNo(RSC008Err, LineIndex - 1);
                exit(false);
            end;
            SeenSystemIds.Add(SystemId);

            if ((not LineObject.Get('admissions', AdmissionsToken)) or (not AdmissionsToken.IsArray())) then begin
                ValidationError := StrSubstNo(RSC009Err, LineIndex - 1);
                exit(false);
            end;
            Admissions := AdmissionsToken.AsArray();
            if (Admissions.Count() = 0) then begin
                ValidationError := StrSubstNo(RSC009Err, LineIndex - 1);
                exit(false);
            end;

            Clear(SeenAdmissionCodes);
            for AdmissionIndex := 1 to Admissions.Count() do
                if (not ReadChangeAdmission(Admissions, LineIndex, AdmissionIndex, SystemId, SeenAdmissionCodes, NextEntryNo, TempRequest, ValidationError)) then
                    exit(false);
        end;
        exit(true);
    end;

    local procedure ReadChangeAdmission(Admissions: JsonArray; LineIndex: Integer; AdmissionIndex: Integer; SystemId: Guid; var SeenAdmissionCodes: List of [Code[20]]; var NextEntryNo: Integer; var TempRequest: Record "NPR TM Reschedule Line Buffer" temporary; var ValidationError: Text): Boolean
    var
        AdmissionToken: JsonToken;
        AdmissionObject: JsonObject;
        AdmissionCodeText: Text;
        AdmissionCode: Code[20];
        ScheduleId: Integer;
        Present: Boolean;
    begin
        Admissions.Get(AdmissionIndex - 1, AdmissionToken);
        if (not AdmissionToken.IsObject()) then begin
            ValidationError := StrSubstNo(RSC010Err, LineIndex - 1, AdmissionIndex - 1);
            exit(false);
        end;
        AdmissionObject := AdmissionToken.AsObject();

        if ((not TryGetString(AdmissionObject, 'admissionCode', AdmissionCodeText, Present)) or (not Present) or (AdmissionCodeText = '') or (StrLen(AdmissionCodeText) > MaxStrLen(TempRequest.AdmissionCode))) then begin
            ValidationError := StrSubstNo(RSC011Err, LineIndex - 1, AdmissionIndex - 1, MaxStrLen(TempRequest.AdmissionCode));
            exit(false);
        end;
        // Code[20] upper-cases and trims, so the duplicate check compares the value that is stored and matched.
        AdmissionCode := CopyStr(AdmissionCodeText, 1, MaxStrLen(AdmissionCode));
        if (AdmissionCode = '') then begin
            ValidationError := StrSubstNo(RSC011Err, LineIndex - 1, AdmissionIndex - 1, MaxStrLen(TempRequest.AdmissionCode));
            exit(false);
        end;
        if (SeenAdmissionCodes.Contains(AdmissionCode)) then begin
            ValidationError := StrSubstNo(RSC012Err, LineIndex - 1, AdmissionIndex - 1);
            exit(false);
        end;
        SeenAdmissionCodes.Add(AdmissionCode);

        if ((not TryGetPositiveInteger(AdmissionObject, 'scheduleNumber', ScheduleId))) then begin
            ValidationError := StrSubstNo(RSC013Err, LineIndex - 1, AdmissionIndex - 1);
            exit(false);
        end;

        NextEntryNo += 1;
        TempRequest.Init();
        TempRequest.EntryNo := NextEntryNo;
        TempRequest.LineReferenceNo := LineIndex;
        TempRequest.CurrentPrimarySystemId := SystemId;
        TempRequest.AdmissionCode := AdmissionCode;
        TempRequest.RequestedExtScheduleEntryNo := ScheduleId;
        TempRequest.Insert();
        exit(true);
    end;

    // A JSON number written without quotes, sign, fraction or exponent; "5", 5.5 and 1e3 fail the format-9 Evaluate.
    local procedure TryGetPositiveInteger(Body: JsonObject; PropertyName: Text; var Value: Integer): Boolean
    var
        JToken: JsonToken;
        RawJson: Text;
    begin
        Value := 0;
        if (not Body.Get(PropertyName, JToken)) then
            exit(false);
        if (not JToken.IsValue()) then
            exit(false);
        if (JToken.AsValue().IsNull()) then
            exit(false);
        JToken.WriteTo(RawJson);
        if (not Evaluate(Value, RawJson, 9)) then
            exit(false);
        exit(Value > 0);
    end;

    local procedure MaxChangeLines(): Integer
    begin
        exit(100);
    end;

    local procedure RefusalMessage(MessageTemplate: Text; var TempRequest: Record "NPR TM Reschedule Line Buffer" temporary; FailedRequestEntryNo: Integer): Text
    begin
        exit(RefusalMessage(MessageTemplate, TempRequest, FailedRequestEntryNo, ''));
    end;

    local procedure RefusalMessage(MessageTemplate: Text; var TempRequest: Record "NPR TM Reschedule Line Buffer" temporary; FailedRequestEntryNo: Integer; ReasonCode: Text): Text
    begin
        TempRequest.Reset();
        TempRequest.Get(FailedRequestEntryNo);
        exit(StrSubstNo(MessageTemplate, Format(TempRequest.CurrentPrimarySystemId, 0, 4).ToLower(), TempRequest.AdmissionCode, ReasonCode));
    end;

    // FailedRequestEntryNo is the move that threw (set by ApplyChange before each admission's moves); 0 when the error came from elsewhere.
    local procedure MapChangeError(var Response: Codeunit "NPR API Response"; var TempRequest: Record "NPR TM Reschedule Line Buffer" temporary; FailedRequestEntryNo: Integer): Codeunit "NPR API Response"
    var
        Sentry: Codeunit "NPR Sentry";
        ErrorText: Text;
        ErrorCallStack: Text;
    begin
        ErrorText := GetLastErrorText();
        if (ErrorText.StartsWith('[-1031]')) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::reschedule_not_allowed, MappedMessage(RSC021Err, RSC030Err, TempRequest, FailedRequestEntryNo, ReasonCodeText(Enum::"NPR TM Reschedule Refusal"::NOT_ALLOWED))));
        if (ErrorText.StartsWith('[-1004]') or ErrorText.StartsWith('[-1030]') or ErrorText.StartsWith('[-1015]')) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::capacity_exceeded, MappedMessage(RSC022Err, RSC031Err, TempRequest, FailedRequestEntryNo)));
        if (ErrorText.StartsWith('[-1003]') or ErrorText.StartsWith('[-2002]')) then
            exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::invalid_reference, MappedMessage(RSC020Err, RSC032Err, TempRequest, FailedRequestEntryNo)));

        Sentry.GetLastErrorInEnglish(ErrorText, ErrorCallStack);
        if (not ErrorText.EndsWith(ProgrammingBugSuffixLbl)) then
            ErrorText := StrSubstNo(ProgrammingBugLbl, ErrorText);
        Sentry.AddError(ErrorText, ErrorCallStack);
        exit(Response.RespondBadRequest(Enum::"NPR API Error Code"::generic_error, InternalErrorLbl));
    end;

    local procedure MappedMessage(LineMessageTemplate: Text; FallbackMessage: Text; var TempRequest: Record "NPR TM Reschedule Line Buffer" temporary; FailedRequestEntryNo: Integer): Text
    begin
        exit(MappedMessage(LineMessageTemplate, FallbackMessage, TempRequest, FailedRequestEntryNo, ''));
    end;

    local procedure MappedMessage(LineMessageTemplate: Text; FallbackMessage: Text; var TempRequest: Record "NPR TM Reschedule Line Buffer" temporary; FailedRequestEntryNo: Integer; ReasonCode: Text): Text
    begin
        if (FailedRequestEntryNo = 0) then
            exit(FallbackMessage);
        exit(RefusalMessage(LineMessageTemplate, TempRequest, FailedRequestEntryNo, ReasonCode));
    end;

    internal procedure BuildChangeResponse(var TempResult: Record "NPR TM Reschedule Line Buffer" temporary): JsonObject
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ResponseJson: Codeunit "NPR JSON Builder";
        LastPrimaryEntryNo: Integer;
    begin
        ResponseJson.Initialize();
        ResponseJson.StartObject().StartArray('reservationLines');
        TempResult.Reset();
        TempResult.FindSet();
        repeat
            if (TempResult.CurrentPrimaryEntryNo <> LastPrimaryEntryNo) then begin
                if (LastPrimaryEntryNo <> 0) then
                    ResponseJson.EndArray().EndObject();
                LastPrimaryEntryNo := TempResult.CurrentPrimaryEntryNo;
                ResponseJson.StartObject()
                    .AddProperty('systemId', Format(TempResult.CurrentPrimarySystemId, 0, 4).ToLower())
                    .AddProperty('itemNumber', TempResult.ItemNo)
                    .AddProperty('variantCode', TempResult.VariantCode)
                    .AddProperty('quantity', TempResult.Quantity)
                    .StartArray('admissions');
            end;
            FindSlotEntry(TempResult.CurrentExtScheduleEntryNo, TempResult.OriginalToken, ScheduleEntry);
            ResponseJson.StartObject().AddProperty('admissionCode', TempResult.AdmissionCode);
            SlotProperties(ResponseJson, ScheduleEntry);
            ResponseJson.EndObject();
        until (TempResult.Next() = 0);
        ResponseJson.EndArray().EndObject();
        ResponseJson.EndArray().EndObject();
        exit(ResponseJson.Build());
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
        _NoMoveReasons := '';
        _NoTimeSlot := false;
    end;

    internal procedure GetFindResult(var ResponseBody: JsonObject; var NoMoveReasons: Text; var NoTimeSlot: Boolean): Boolean
    begin
        ResponseBody := _ResponseBody;
        NoMoveReasons := _NoMoveReasons;
        NoTimeSlot := _NoTimeSlot;
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

    local procedure BuildFindResponse(TicketNumber: Code[30]; ReservationToken: Text[100]; PinCode: Text; FromDate: Date; ToDate: Date; var ResponseBody: JsonObject; var NoMoveReasons: Text; var NoTimeSlot: Boolean): Boolean
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
        if (TempLineBuffer.IsEmpty()) then begin
            NoTimeSlot := true;
            exit(false);
        end;
        TicketReschedule.EvaluateEligibility(TempLineBuffer);
        if (not TicketReschedule.AnyAdmissionCanMove(TempLineBuffer)) then begin
            NoMoveReasons := RefusalReasonList(TempLineBuffer);
            exit(false);
        end;

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
    begin
        FindSlotEntry(ExtScheduleEntryNo, OriginalToken, ScheduleEntry);
        ResponseJson.StartObject('currentSchedule');
        SlotProperties(ResponseJson, ScheduleEntry);
        ResponseJson.EndObject();
    end;

    local procedure FindSlotEntry(ExtScheduleEntryNo: Integer; OriginalToken: Text[100]; var ScheduleEntry: Record "NPR TM Admis. Schedule Entry")
    var
        NoCurrentSlotErr: Label 'Ticket reschedule integrity failure for token %1: schedule entry %2 does not exist. This is a programming bug', Locked = true;
    begin
        ScheduleEntry.Reset();
        ScheduleEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        ScheduleEntry.SetCurrentKey("External Schedule Entry No.");
        ScheduleEntry.SetRange("External Schedule Entry No.", ExtScheduleEntryNo);
        ScheduleEntry.SetRange(Cancelled, false);
        if (not ScheduleEntry.FindLast()) then begin
            ScheduleEntry.SetRange(Cancelled);
            if (not ScheduleEntry.FindLast()) then
                Error(NoCurrentSlotErr, OriginalToken, ExtScheduleEntryNo);
        end;
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

    // Each reason code once, in line order and then admission order.
    local procedure RefusalReasonList(var TempLineBuffer: Record "NPR TM Reschedule Line Buffer" temporary) ReasonList: Text
    var
        SeenReasonCodes: List of [Text];
        ReasonCode: Text;
    begin
        TempLineBuffer.Reset();
        if (not TempLineBuffer.FindSet()) then
            exit;
        repeat
            ReasonCode := ReasonCodeText(TempLineBuffer.RefusalReason);
            if (not SeenReasonCodes.Contains(ReasonCode)) then begin
                SeenReasonCodes.Add(ReasonCode);
                if (ReasonList <> '') then
                    ReasonList += ', ';
                ReasonList += ReasonCode;
            end;
        until (TempLineBuffer.Next() = 0);
    end;

    local procedure ReasonCodeText(Refusal: Enum "NPR TM Reschedule Refusal"): Text
    begin
        if (Refusal = Refusal::NONE) then
            exit('');
        exit(Refusal.Names().Get(Refusal.Ordinals().IndexOf(Refusal.AsInteger())));
    end;
}
#endif
