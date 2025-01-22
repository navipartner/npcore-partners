#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185119 "NPR ApiSpeedgateAdmit"
{
    Access = Internal;

    internal procedure GetSetup(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin

    end;

    internal procedure TryAdmit(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SpeedGateMgr: Codeunit "NPR SG SpeedGate";
        LogEntryNo: Integer;
        Body: JsonObject;
        JValueToken: JsonToken;
        ReferenceNumber: Text[100];
        AdmissionCode: Code[20];
        ScannerId: Code[10];
    begin
        Body := Request.BodyJson().AsObject();

        if (Body.Get('referenceNumber', JValueToken)) then
            ReferenceNumber := CopyStr(JValueToken.AsValue().AsText(), 1, MaxStrLen(ReferenceNumber));

        if (Body.Get('admissionCode', JValueToken)) then
            AdmissionCode := CopyStr(JValueToken.AsValue().AsText(), 1, MaxStrLen(AdmissionCode));

        if (Body.Get('scannerId', JValueToken)) then
            ScannerId := CopyStr(JValueToken.AsValue().AsText(), 1, MaxStrLen(ScannerId));

        LogEntryNo := SpeedGateMgr.CreateInitialEntry(ReferenceNumber, AdmissionCode, ScannerId);
        Commit();

        exit(TryAdmit(LogEntryNo));

    end;

    internal procedure Admit(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        SpeedGateMgr: Codeunit "NPR SG SpeedGate";

        Body: JsonObject;
        JTokens, JTokenElements : JsonToken;
        ArrayOfTokens: JsonArray;
        TokenObject: JsonObject;

        TokenText: Text[100];
        Token: Guid;
        Quantity: Integer;

        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        Body := Request.BodyJson().AsObject();
        if (not Body.Get('tokens', JTokens)) then
            exit(Response.RespondBadRequest('No tokens provided'));

        ArrayOfTokens := JTokens.AsArray();

        // Payload Validation
        foreach JTokenElements in ArrayOfTokens do begin
            TokenObject := JTokenElements.AsObject();
            if (not TokenObject.Get('token', JTokens)) then
                exit(Response.RespondBadRequest('No token provided'));

            TokenText := CopyStr(JTokens.AsValue().AsText(), 1, MaxStrLen(TokenText));
            if (not Evaluate(Token, TokenText)) then
                exit(Response.RespondBadRequest('Invalid token provided'));

            if (TokenObject.Get('quantity', JTokens)) then begin
                Quantity := JTokens.AsValue().AsInteger();
                if (Quantity < 1) then
                    exit(Response.RespondBadRequest('Invalid quantity provided'));
            end;

            if (not SpeedGateMgr.ValidateAdmitToken(Token)) then
                exit(Response.RespondBadRequest('Invalid token provided'));
        end;

        ResponseJson
            .StartObject()
            .StartArray('admittedTokens');

        // Execute Admit
        foreach JTokenElements in ArrayOfTokens do begin
            TokenObject := JTokenElements.AsObject();

            TokenObject.Get('token', JTokens);
            TokenText := CopyStr(JTokens.AsValue().AsText(), 1, MaxStrLen(TokenText));
            Evaluate(Token, TokenText);

            if (TokenObject.Get('quantity', JTokens)) then
                Quantity := JTokens.AsValue().AsInteger()
            else
                Quantity := 1;

            ResponseJson := Admit(ResponseJson, Token, Quantity);

        end;

        ResponseJson
            .EndArray()
            .EndObject();

        Response.RespondOK(ResponseJson.Build());
    end;

    internal procedure Admit(ResponseJson: Codeunit "NPR JSON Builder"; Token: Guid; Quantity: Integer): Codeunit "NPR JSON Builder"
    var
        ValidationRequest: Record "NPR SGEntryLog";
    begin
        ValidationRequest.SetCurrentKey(Token);
        ValidationRequest.SetFilter(Token, '=%1', Token);
        ValidationRequest.SetFilter(EntryStatus, '=%1', ValidationRequest.EntryStatus::PERMITTED_BY_GATE);
        if (ValidationRequest.FindSet()) then begin
            repeat
                if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::TICKET) then
                    AdmitTicket(ValidationRequest, ResponseJson);

                if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::MEMBER_CARD) then
                    AdmitMemberCard(ValidationRequest, ResponseJson);

            until (ValidationRequest.Next() = 0);
        end;

        exit(ResponseJson);
    end;

    local procedure AdmitTicket(ValidationRequest: Record "NPR SGEntryLog"; ResponseJson: Codeunit "NPR JSON Builder")
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Ticket: Record "NPR TM Ticket";
    begin
        TicketManagement.RegisterArrivalScanTicket("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO,
            CopyStr(ValidationRequest.ReferenceNo, 1, 30),
            ValidationRequest.AdmissionCode,
            -1, '', // PosUnitNo, 
            ValidationRequest.ScannerId, false);

        ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::ADMITTED;
        ValidationRequest.AdmittedAt := CurrentDateTime;
        ValidationRequest.Modify();

        Ticket.GetBySystemId(ValidationRequest.EntityId);

        ResponseJson
            .StartObject()
            .AddProperty('token', Format(ValidationRequest.Token, 0, 4).ToLower())
            .AddProperty('referenceNumberType', 'ticket')
            .AddProperty('referenceNumber', ValidationRequest.ReferenceNo)
            .AddProperty('ticketId', Format(ValidationRequest.EntityId, 0, 4).ToLower())
            .AddProperty('status', 'admitted')
            .AddProperty('itemNo', Ticket."Item No.")
            .AddProperty('admissionCode', ValidationRequest.AdmissionCode)
            .AddObject(AddPrintedTicketDetails(ResponseJson, Ticket))
            .EndObject();
    end;

    local procedure AdmitMemberCard(ValidationRequest: Record "NPR SGEntryLog"; ResponseJson: Codeunit "NPR JSON Builder")
    var
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberCard: Record "NPR MM Member Card";
        ExternalTicketNo: Text[30];
        ResponseMessage: Text;
        ResponseCode: Integer;
        Ticket: Record "NPR TM Ticket";
        LogEntryNo: Integer;
    begin
        ResponseMessage := 'Invalid Validation Request';

        if (not MemberCard.GetBySystemId(ValidationRequest.EntityId)) then
            Error(ResponseMessage);

        if (MemberManagement.MembershipNeedsActivation(MemberCard."Membership Entry No.")) then
            MemberManagement.ActivateMembershipLedgerEntry(MemberCard."Membership Entry No.", Today());

        ValidationRequest.MemberCardLogEntryNo := MemberLimitationMgr.WS_CheckLimitMemberCardArrival(MemberCard."External Card No.", ValidationRequest.AdmissionCode, ValidationRequest.ScannerId, LogEntryNo, ResponseMessage, ResponseCode);
        ValidationRequest.Modify();
        if (ResponseCode <> 0) then begin
            Commit();
            ResponseMessage := Strsubstno('[-3149] %1', ResponseMessage);
            Error(ResponseMessage);
        end;

        case ValidationRequest.ExtraEntityTableId of
            0: // Member Card
               // Has a commit inside
                MemberTicketManager.MemberFastCheckInNoPrint(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", ValidationRequest.AdmissionCode, '', 1, '', ExternalTicketNo);
            Database::"NPR MM Members. Admis. Setup": // Guest
                Error('Guest check-in not implemented');
            else
                Error('Unknown MemberCard ExtraEntityTableId');
        end;

        ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::ADMITTED;
        ValidationRequest.AdmittedAt := CurrentDateTime;
        ValidationRequest.Modify();

        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNo);
        if (not Ticket.FindFirst()) then
            Ticket.Init();

        ResponseJson
            .StartObject()
            .AddProperty('token', Format(ValidationRequest.Token, 0, 4).ToLower())
            .AddProperty('referenceNumberType', 'memberCard')
            .AddProperty('referenceNumber', ValidationRequest.ReferenceNo)
            .AddProperty('ticketId', Format(Ticket.SystemId, 0, 4).ToLower())
            .AddProperty('status', 'admitted')
            .AddProperty('itemNo', Ticket."Item No.")
            .AddProperty('admissionCode', ValidationRequest.AdmissionCode)
            .AddObject(AddPrintedTicketDetails(ResponseJson, Ticket))
            .AddProperty('memberCardId', Format(ValidationRequest.EntityId, 0, 4).ToLower())
            .AddProperty('externalTicketNo', ExternalTicketNo)
            .EndObject();

    end;


    internal procedure MarkAsDenied(var Request: Codeunit "NPR API Request"; ErrorCode: Enum "NPR API Error Code"; ErrorMessage: Text) Response: Codeunit "NPR API Response"
    var
        Body: JsonObject;
        JTokens, JTokenElements : JsonToken;
        ArrayOfTokens: JsonArray;
        TokenObject: JsonObject;
        TokenText: Text[100];
        Token: Guid;
        ValidationRequest: Record "NPR SGEntryLog";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MemberCard: Record "NPR MM Member Card";
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin
        Body := Request.BodyJson().AsObject();
        if (not Body.Get('tokens', JTokens)) then
            exit;

        if (ErrorCode.AsInteger() = 0) then
            ErrorCode := ErrorCode::denied_by_speedgate;

        ArrayOfTokens := JTokens.AsArray();
        foreach JTokenElements in ArrayOfTokens do begin
            TokenObject := JTokenElements.AsObject();
            if (TokenObject.Get('token', JTokens)) then begin
                TokenText := CopyStr(JTokens.AsValue().AsText(), 1, MaxStrLen(TokenText));
                if (Evaluate(Token, TokenText)) then begin
                    ValidationRequest.SetCurrentKey(Token);
                    ValidationRequest.SetFilter("Token", '=%1', Token);
                    if (ValidationRequest.FindSet()) then begin
                        repeat
                            ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::DENIED;
                            if (ValidationRequest.ApiErrorNumber = 0) then
                                ValidationRequest.ApiErrorNumber := ErrorCode.AsInteger();
                            ValidationRequest.Modify();

                            if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::MEMBER_CARD) then begin
                                if (MemberCard.GetBySystemId(ValidationRequest.EntityId)) then begin
                                    if (ValidationRequest.MemberCardLogEntryNo = 0) then
                                        ValidationRequest.MemberCardLogEntryNo := MemberLimitationMgr.WS_CheckLimitMemberCardArrival(MemberCard."External Card No.", ValidationRequest.AdmissionCode, ValidationRequest.ScannerId, ValidationRequest.MemberCardLogEntryNo, ResponseMessage, ResponseCode);
                                    MemberLimitationMgr.UpdateLogEntry(ValidationRequest.MemberCardLogEntryNo, ErrorCode.AsInteger(), ErrorMessage);
                                end;
                            end;

                        until (ValidationRequest.Next() = 0);
                    end;
                end;
            end;
        end;

        Response.RespondNoContent();
    end;

    // **********************
    internal procedure TryAdmit(LogEntryNo: Integer) Response: Codeunit "NPR API Response"
    var
        SpeedGateMgr: Codeunit "NPR SG SpeedGate";
        ValidationRequest: Record "NPR SGEntryLog";
        ApiError: Enum "NPR API Error Code";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin

        SpeedGateMgr.CheckNumberAtGate(LogEntryNo);
        ValidationRequest.Get(LogEntryNo);

        if (not (ValidationRequest.EntryStatus = ValidationRequest.EntryStatus::PERMITTED_BY_GATE)) then begin
            ApiError := Enum::"NPR API Error Code".FromInteger(ValidationRequest.ApiErrorNumber);
            exit(Response.CreateErrorResponse(ApiError, Format(ApiError, 0, 1), Enum::"NPR API HTTP Status Code"::"Bad Request"));
        end;

        ResponseJson
            .StartObject()
            .AddProperty('token', Format(ValidationRequest.Token, 0, 4).ToLower())
            .AddProperty('referenceNumberType', ReferenceNumberTypeAsText(ValidationRequest.ReferenceNumberType))
            .AddObject(EntityDetails(ResponseJson, ValidationRequest))
            .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));

    end;

    local procedure EntityDetails(var ResponseJson: Codeunit "NPR JSON Builder"; ValidationRequest: Record "NPR SGEntryLog"): Codeunit "NPR JSON Builder"
    begin

        case ValidationRequest.ReferenceNumberType of
            ValidationRequest.ReferenceNumberType::TICKET:
                exit(SingleTicketDTO(ResponseJson, ValidationRequest));
            ValidationRequest.ReferenceNumberType::MEMBER_CARD:
                exit(SingleMembershipDTO(ResponseJson, ValidationRequest));
            ValidationRequest.ReferenceNumberType::WALLET:
                exit(ResponseJson.AddProperty('wallet', ValidationRequest.EntityId));
            ValidationRequest.ReferenceNumberType::DOC_LX_CITY_CARD:
                exit(ResponseJson.AddProperty('docLxCityCard', ValidationRequest.ReferenceNo));
            else
                exit(ResponseJson.AddProperty('unknown', ValidationRequest.ReferenceNo));
        end;
    end;

    local procedure SingleTicketDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ValidationRequest: Record "NPR SGEntryLog"): Codeunit "NPR JSON Builder"
    var
        Ticket: Record "NPR TM Ticket";
        AccessEntry: Record "NPR TM Ticket Access Entry";
        DetAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmitCount: Integer;
    begin
        if (not Ticket.GetBySystemId(ValidationRequest.EntityId)) then
            exit(ResponseJson.AddProperty('ticket', 'not found'));

        AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        AccessEntry.SetFilter("Admission Code", '=%1', ValidationRequest.AdmissionCode);
        if (not AccessEntry.FindFirst()) then
            exit(ResponseJson.AddProperty('ticket', 'not found'));

        if (AccessEntry."Access Date" > 0D) then begin
            DetAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', AccessEntry."Entry No.");
            DetAccessEntry.SetFilter(Type, '=%1', DetAccessEntry.Type::ADMITTED);
            AdmitCount := DetAccessEntry.Count;
            if (AdmitCount > 0) then
                DetAccessEntry.FindLast();
        end;

        ResponseJson
            .StartObject('ticket')
            .AddProperty('ticketId', Format(ValidationRequest.EntityId, 0, 4).ToLower())
            .AddProperty('itemNo', Ticket."Item No.")
            .AddProperty('admissionCode', ValidationRequest.AdmissionCode)
            .AddProperty('admitCount', AdmitCount)
            .AddObject(AddRequiredProperty(ResponseJson, 'admittedAt', DetAccessEntry.SystemCreatedAt))
            .AddObject(AddPrintedTicketDetails(ResponseJson, Ticket))
            .EndObject()
    end;

    local procedure AddPrintedTicketDetails(var ResponseJson: Codeunit "NPR JSON Builder"; Ticket: Record "NPR TM Ticket"): Codeunit "NPR JSON Builder"
    begin
        ResponseJson
            .AddObject(AddRequiredProperty(ResponseJson, 'printedAt', Ticket.PrintedDateTime))
            .AddProperty('printCount', Ticket.PrintCount);

        exit(ResponseJson);
    end;

    local procedure AddRequiredProperty(var ResponseJson: Codeunit "NPR JSON Builder"; PropertyName: Text; PropertyValue: DateTime): Codeunit "NPR JSON Builder"
    begin
        if (PropertyValue = 0DT) then
            exit(ResponseJson.AddProperty(PropertyName)); // Empty property with null value (not "")

        exit(ResponseJson.AddProperty(PropertyName, PropertyValue));
    end;

    local procedure SingleMembershipDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ValidationRequest: Record "NPR SGEntryLog"): Codeunit "NPR JSON Builder"
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MemberCardSwipe: Record "NPR MM Member Arr. Log Entry";
    begin
        if (not MemberCard.GetBySystemId(ValidationRequest.EntityId)) then
            exit(ResponseJson.AddProperty('memberCard', 'not found'));

        if (not Membership.Get(MemberCard."Membership Entry No.")) then
            exit(ResponseJson.AddProperty('membership', 'not found'));

        if (not Member.Get(MemberCard."Member Entry No.")) then
            exit(ResponseJson.AddProperty('member', 'not found'));

        MemberCardSwipe.SetCurrentKey("External Membership No.", "External Member No.");
        MemberCardSwipe.SetFilter("External Membership No.", '=%1', Membership."External Membership No.");
        MemberCardSwipe.SetFilter("External Member No.", '=%1', Member."External Member No.");
        if (not MemberCardSwipe.FindLast()) then begin
            MemberCardSwipe.Init();
            MemberCardSwipe."Response Type" := 99; // Unknown 
        end;

        ResponseJson
            .StartObject('memberCard')
            .AddProperty('memberCardId', Format(MemberCard.SystemId, 0, 4).ToLower())
            .AddProperty('membershipId', Format(Membership.SystemId, 0, 4).ToLower())
            .StartObject('previousScan')
                .AddObject(AddRequiredProperty(ResponseJson, 'scannedAt', MemberCardSwipe."Created At"))
                .AddProperty('scannerId', MemberCardSwipe."Scanner Station Id")
                .AddProperty('admissionCode', MemberCardSwipe."Admission Code")
                .AddProperty('status', ResponseTypeToText(MemberCardSwipe."Response Type"))
            .EndObject()
            .StartObject('member')
                .AddProperty('memberId', Format(Member.SystemId, 0, 4).ToLower())
                .AddProperty('firstName', Member."First Name")
                .AddProperty('lastName', Member."Last Name")
                .AddProperty('hasPicture', Member.Image.HasValue())
            .EndObject()
            .AddArray(AddMembershipGuestDetails(ResponseJson, Membership."Membership Code", ValidationRequest))
            .EndObject();
    end;

    local procedure AddMembershipGuestDetails(var ResponseJson: Codeunit "NPR JSON Builder"; MembershipCode: Code[20]; SourceValidationRequest: Record "NPR SGEntryLog"): Codeunit "NPR JSON Builder"
    var
        MembershipGuest: Record "NPR MM Members. Admis. Setup";
        AdmitToken: Guid;
    begin
        ResponseJson.StartArray('guests');
        MembershipGuest.SetFilter("Membership  Code", '=%1', MembershipCode);
        MembershipGuest.SetFilter("Admission Code", '=%1', SourceValidationRequest.AdmissionCode);
        if (MembershipGuest.FindSet()) then begin
            repeat
                AdmitToken := CreateMemberGuestAdmissionToken(SourceValidationRequest, MembershipGuest);
                if (MembershipGuest."Cardinality Type" = MembershipGuest."Cardinality Type"::UNLIMITED) then
                    MembershipGuest."Max Cardinality" := -1;
                ResponseJson
                    .StartObject()
                    .AddProperty('token', Format(AdmitToken, 0, 4).ToLower())
                    .AddProperty('admissionCode', MembershipGuest."Admission Code")
                    .AddProperty('description', MembershipGuest.Description)
                    .AddProperty('maxNumberOfGuests', MembershipGuest."Max Cardinality")
                    .EndObject();
            until (MembershipGuest.Next() = 0);
        end;

        ResponseJson.EndArray();
        exit(ResponseJson);
    end;

    local procedure CreateMemberGuestAdmissionToken(SourceValidationRequest: Record "NPR SGEntryLog"; MembershipGuest: Record "NPR MM Members. Admis. Setup"): Guid
    var
        MemberValidationRequest: Record "NPR SGEntryLog";
    begin
        MemberValidationRequest := SourceValidationRequest;
        MemberValidationRequest.EntryNo := 0;
        MemberValidationRequest.Token := CreateGuid();
        MemberValidationRequest.ExtraEntityTableId := Database::"NPR MM Members. Admis. Setup";
        MemberValidationRequest.ExtraEntityId := MembershipGuest.SystemId;
        MemberValidationRequest.Insert();
        exit(MemberValidationRequest.Token);
    end;

    local procedure ReferenceNumberTypeAsText(ReferenceNumberType: Option): Text
    var
        ValidationRequest: Record "NPR SGEntryLog";
    begin

        case ReferenceNumberType of
            ValidationRequest.ReferenceNumberType::TICKET:
                exit('ticket');
            ValidationRequest.ReferenceNumberType::MEMBER_CARD:
                exit('memberCard');
            ValidationRequest.ReferenceNumberType::WALLET:
                exit('wallet');
            ValidationRequest.ReferenceNumberType::DOC_LX_CITY_CARD:
                exit('docLxCityCard');
            else
                exit('unknown');
        end;
    end;

    local procedure ResponseTypeToText(ResponseType: Option): Text
    var
        MemberCardSwipe: Record "NPR MM Member Arr. Log Entry";
    begin
        case ResponseType of
            MemberCardSwipe."Response Type"::ACCESS_DENIED:
                exit('denied');
            MemberCardSwipe."Response Type"::SUCCESS:
                exit('admitted');
            MemberCardSwipe."Response Type"::VALIDATION_FAILURE:
                exit('validationFailure');
            else
                exit('unknown');
        end;
    end;
}
#endif