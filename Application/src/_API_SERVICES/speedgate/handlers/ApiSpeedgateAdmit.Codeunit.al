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

            if (not SpeedGateMgr.AdmitTokenIsValid(Token)) then
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
        TicketId: Guid;
    begin
        ValidationRequest.SetCurrentKey(Token);
        ValidationRequest.SetFilter(Token, '=%1', Token);
        ValidationRequest.SetFilter(EntryStatus, '=%1', ValidationRequest.EntryStatus::PERMITTED_BY_GATE);
        if (ValidationRequest.FindSet()) then begin
            repeat
                if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::TICKET) then
                    AdmitTicket(ValidationRequest, ResponseJson);

                if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::MEMBER_CARD) then begin
                    if (not IsNullGuid(TicketId) and (ValidationRequest.ExtraEntityTableId = 0)) then begin
                        ValidationRequest.ExtraEntityId := TicketId;
                        ValidationRequest.ExtraEntityTableId := Database::"NPR TM Ticket";
                    end;
                    TicketId := AdmitMemberCard(ValidationRequest, ResponseJson, Quantity);
                end;

                if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::WALLET) then
                    AdmitWallet(ValidationRequest, ResponseJson);

            until (ValidationRequest.Next() = 0);
        end;

        exit(ResponseJson);
    end;

    local procedure AdmitWallet(ValidationRequest: Record "NPR SGEntryLog"; ResponseJson: Codeunit "NPR JSON Builder")
    begin
        if (ValidationRequest.ExtraEntityTableId = 0) then
            Error('The tryAdmit request was not able to preselect a product for admission.');

        if (not (ValidationRequest.ExtraEntityTableId in [Database::"NPR TM Ticket", Database::"NPR MM Member Card"])) then
            Error('The admit request contains an unhandled Entity: %1', ValidationRequest.ExtraEntityTableId);

        if (ValidationRequest.ExtraEntityTableId = Database::"NPR TM Ticket") then
            AdmitTicket(ValidationRequest, ResponseJson);

        if (ValidationRequest.ExtraEntityTableId = Database::"NPR MM Member Card") then
            AdmitMemberCard(ValidationRequest, ResponseJson, 1);
    end;

    local procedure AdmitTicket(ValidationRequest: Record "NPR SGEntryLog"; ResponseJson: Codeunit "NPR JSON Builder")
    var
        SpeedGateMgr: Codeunit "NPR SG SpeedGate";
        Ticket: Record "NPR TM Ticket";
    begin
        Ticket.GetBySystemId(SpeedGateMgr.ValidateAdmitTicket(ValidationRequest));

        ResponseJson
            .StartObject()
            .AddProperty('token', Format(ValidationRequest.Token, 0, 4).ToLower())
            .AddProperty('referenceNumberType', 'ticket')
            .AddProperty('referenceNumber', Ticket."External Ticket No.")
            .AddProperty('ticketId', Format(ValidationRequest.EntityId, 0, 4).ToLower())
            .AddProperty('status', 'admitted')
            .AddProperty('itemNo', Ticket."Item No.")
            .AddProperty('admissionCode', ValidationRequest.AdmissionCode)
            .AddObject(AddPrintedTicketDetails(ResponseJson, Ticket))
            .EndObject();
    end;

    local procedure AdmitMemberCard(ValidationRequest: Record "NPR SGEntryLog"; ResponseJson: Codeunit "NPR JSON Builder"; Quantity: Integer): Guid
    var
        SpeedGateMgr: Codeunit "NPR SG SpeedGate";
        Ticket: Record "NPR TM Ticket";
        ValidationRequestResponse: Record "NPR SGEntryLog";
    begin
        Ticket.GetBySystemId(SpeedGateMgr.ValidateAdmitMemberCard(ValidationRequest, Quantity));

        if (Quantity = 1) then
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
                .AddProperty('ticketNumber', ValidationRequest.AdmittedReferenceNo)
                .EndObject();

        if (Quantity > 1) then begin
            ValidationRequestResponse.SetFilter(Token, '=%1', ValidationRequest.Token);
            ValidationRequestResponse.SetFilter(EntryStatus, '=%1', ValidationRequest.EntryStatus::ADMITTED);
            if (ValidationRequestResponse.FindSet()) then begin
                repeat
                    ResponseJson
                        .StartObject()
                        .AddProperty('token', Format(ValidationRequestResponse.Token, 0, 4).ToLower())
                        .AddProperty('referenceNumberType', 'memberCard')
                        .AddProperty('referenceNumber', ValidationRequestResponse.ReferenceNo)
                        .AddProperty('ticketId', Format(Ticket.SystemId, 0, 4).ToLower())
                        .AddProperty('status', 'admitted')
                        .AddProperty('itemNo', Ticket."Item No.")
                        .AddProperty('admissionCode', ValidationRequestResponse.AdmissionCode)
                        .AddObject(AddPrintedTicketDetails(ResponseJson, Ticket))
                        .AddProperty('memberCardId', Format(ValidationRequestResponse.EntityId, 0, 4).ToLower())
                        .AddProperty('ticketNumber', ValidationRequestResponse.AdmittedReferenceNo)
                        .EndObject();
                until (ValidationRequestResponse.Next() = 0);
            end;
        end;

        exit(Ticket.SystemId);
    end;

    internal procedure MarkAsDenied(var Request: Codeunit "NPR API Request"; ErrorCode: Enum "NPR API Error Code"; ErrorMessage: Text) Response: Codeunit "NPR API Response"
    var
        SpeedGateMgr: Codeunit "NPR SG SpeedGate";
        Body: JsonObject;
        JTokens, JTokenElements : JsonToken;
        ArrayOfTokens: JsonArray;
        TokenObject: JsonObject;
        TokenText: Text[100];
        Token: Guid;
    begin
        Body := Request.BodyJson().AsObject();
        if (not Body.Get('tokens', JTokens)) then
            exit;

        ArrayOfTokens := JTokens.AsArray();
        foreach JTokenElements in ArrayOfTokens do begin
            TokenObject := JTokenElements.AsObject();
            if (TokenObject.Get('token', JTokens)) then begin
                TokenText := CopyStr(JTokens.AsValue().AsText(), 1, MaxStrLen(TokenText));
                if (Evaluate(Token, TokenText)) then
                    SpeedGateMgr.MarkAsDenied(Token, ErrorCode, ErrorMessage);
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
                exit(StartSingleTicketDTO(ResponseJson, ValidationRequest));
            ValidationRequest.ReferenceNumberType::MEMBER_CARD:
                exit(SingleMembershipDTO(ResponseJson, ValidationRequest));
            ValidationRequest.ReferenceNumberType::WALLET:
                exit(SingleWalletDTO(ResponseJson, ValidationRequest));
            ValidationRequest.ReferenceNumberType::DOC_LX_CITY_CARD:
                exit(ResponseJson.AddProperty('docLxCityCard', ValidationRequest.ReferenceNo));
            else
                exit(ResponseJson.AddProperty('unknown', ValidationRequest.ReferenceNo));
        end;
    end;

    local procedure SingleWalletDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ValidationRequest: Record "NPR SGEntryLog"): Codeunit "NPR JSON Builder"
    var
        Wallet: Record "NPR AttractionWallet";
        WalletAssetLine: Record "NPR WalletAssetLine";
        WalletAgent: Codeunit "NPR AttractionWallet";
    begin

        Wallet.GetBySystemId(ValidationRequest.EntityId);

        ResponseJson
            .StartObject('wallet')
            .AddProperty('walletId', Format(ValidationRequest.EntityId, 0, 4).ToLower())
            .AddProperty('referenceNumber', ValidationRequest.ReferenceNo)
            .AddProperty('validToAdmit', ValidationRequest.ExtraEntityTableId in [Database::"NPR TM Ticket", Database::"NPR MM Member Card"]);

        ResponseJson.StartArray('tickets');
        WalletAssetLine.SetCurrentKey(TransactionId, Type);
        WalletAssetLine.SetFilter(TransactionId, '=%1', WalletAgent.GetWalletTransactionId(Wallet.EntryNo));
        WalletAssetLine.SetFilter(Type, '=%1', ENUM::"NPR WalletLineType"::Ticket);
        if (WalletAssetLine.FindSet()) then begin
            repeat
                StartSingleTicketAnonymousDTO(ResponseJson, ValidationRequest.ScannerId, WalletAssetLine.LineTypeSystemId, ValidationRequest.AdmissionCode);
            until (WalletAssetLine.Next() = 0);
        end;
        ResponseJson.EndArray();

        ResponseJson.StartArray('memberships');
        WalletAssetLine.SetFilter(Type, '=%1', ENUM::"NPR WalletLineType"::Membership);
        if (WalletAssetLine.FindSet()) then begin
            repeat
                SingleMembershipAnonymousDTO(ResponseJson, WalletAssetLine.LineTypeSystemId);
            until (WalletAssetLine.Next() = 0);
        end;
        ResponseJson.EndArray();

        ResponseJson.EndObject();
        exit(ResponseJson);
    end;

    local procedure StartSingleTicketDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ValidationRequest: Record "NPR SGEntryLog"): Codeunit "NPR JSON Builder"
    var
        Ticket: Record "NPR TM Ticket";
        AccessEntry: Record "NPR TM Ticket Access Entry";
    begin
        if (not Ticket.GetBySystemId(ValidationRequest.EntityId)) then
            exit(ResponseJson);

        AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        AccessEntry.SetFilter("Admission Code", '=%1', ValidationRequest.AdmissionCode);
        if (not AccessEntry.FindFirst()) then
            exit(ResponseJson);

        ResponseJson
            .StartObject('ticket')
            .AddObject(SingleTicketDTO(ResponseJson, Ticket, AccessEntry))
            .EndObject();
        exit(ResponseJson);
    end;

    local procedure StartSingleTicketAnonymousDTO(var ResponseJson: Codeunit "NPR JSON Builder"; ScannerId: Code[10]; TicketId: Guid; AdmissionCode: Code[20]): Codeunit "NPR JSON Builder"
    var
        Ticket: Record "NPR TM Ticket";
        AccessEntry: Record "NPR TM Ticket Access Entry";
        SpeedGate: Codeunit "NPR SG SpeedGate";
        ValidAdmitToCodes: List of [Code[20]];
    begin
        if (not Ticket.GetBySystemId(TicketId)) then
            exit(ResponseJson);

        if (AdmissionCode = '') then begin
            if (not (SpeedGate.CheckTicket(ScannerId, Ticket."External Ticket No.", AdmissionCode, ValidAdmitToCodes))) then
                exit(ResponseJson);
        end else begin
            ValidAdmitToCodes.Add(AdmissionCode);
        end;

        foreach AdmissionCode in ValidAdmitToCodes do begin
            AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
            AccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);

            if (AccessEntry.FindFirst()) then
                ResponseJson
                    .StartObject()
                    .AddObject(SingleTicketDTO(ResponseJson, Ticket, AccessEntry))
                    .EndObject();
        end;

        exit(ResponseJson);
    end;

    local procedure SingleTicketDTO(var ResponseJson: Codeunit "NPR JSON Builder"; Ticket: Record "NPR TM Ticket"; AccessEntry: Record "NPR TM Ticket Access Entry"): Codeunit "NPR JSON Builder"
    var
        DetAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmitCount: Integer;
    begin

        if (AccessEntry."Access Date" > 0D) then begin
            DetAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', AccessEntry."Entry No.");
            DetAccessEntry.SetFilter(Type, '=%1', DetAccessEntry.Type::ADMITTED);
            DetAccessEntry.SetFilter(Quantity, '>%1', 0);
            AdmitCount := DetAccessEntry.Count;
            if (AdmitCount > 0) then
                DetAccessEntry.FindLast();
        end;

        ResponseJson
            .AddProperty('ticketId', Format(Ticket.SystemId, 0, 4).ToLower())
            .AddProperty('ticketNumber', Ticket."External Ticket No.")
            .AddProperty('itemNo', Ticket."Item No.")
            .AddProperty('admissionCode', AccessEntry."Admission Code")
            .AddProperty('admitCount', AdmitCount)
            .AddObject(AddRequiredProperty(ResponseJson, 'admittedAt', DetAccessEntry.SystemCreatedAt))
            .AddObject(AddPrintedTicketDetails(ResponseJson, Ticket));

        exit(ResponseJson);
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
        MemberCardProfileLine: Record "NPR SG MemberCardProfileLine";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        Base64StringImage: Text;
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

        MemberCardProfileLine.Init();
        if (not (IsNullGuid(ValidationRequest.ProfileLineId))) then
            if (not MemberCardProfileLine.GetBySystemId(ValidationRequest.ProfileLineId)) then
                MemberCardProfileLine.Init();

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
                .AddProperty('memberId', Format(Member.SystemId, 0, 4).ToLower());

        if (MemberCardProfileLine.IncludeMemberDetails) then
            ResponseJson
                .AddProperty('firstName', Member."First Name")
                .AddProperty('lastName', Member."Last Name")
                .AddProperty('hasPicture', Member.Image.HasValue());

        if (MemberCardProfileLine.IncludeMemberPhoto) then
            if (MembershipManagement.GetMemberImage(Member."Entry No.", Base64StringImage)) then
                ResponseJson.AddProperty('picture', Base64StringImage)
            else
                ResponseJson.AddProperty('picture');

        ResponseJson.EndObject()
            .AddArray(AddMembershipGuestDetails(ResponseJson, Membership."Membership Code", ValidationRequest))
            .EndObject();

        exit(ResponseJson);
    end;

    local procedure SingleMembershipAnonymousDTO(var ResponseJson: Codeunit "NPR JSON Builder"; MemberCardId: Guid): Codeunit "NPR JSON Builder"
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MemberCardSwipe: Record "NPR MM Member Arr. Log Entry";
    begin
        if (not MemberCard.GetBySystemId(MemberCardId)) then
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
            .StartObject()
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
            .EndObject();

        exit(ResponseJson);
    end;

    local procedure AddMembershipGuestDetails(var ResponseJson: Codeunit "NPR JSON Builder"; MembershipCode: Code[20]; SourceValidationRequest: Record "NPR SGEntryLog"): Codeunit "NPR JSON Builder"
    var
        MembershipGuest: Record "NPR MM Members. Admis. Setup";
        AdmitToken: Guid;
        MemberCard: Record "NPR MM Member Card";
        Member: Record "NPR MM Member";
        Tickets: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ItemNumber: Code[20];
        ItemVariantCode: Code[10];
        Resolver: Integer;
        TicketsCreatedToday: Integer;
        ShowGuests: Boolean;
        MemberCardProfileLine: Record "NPR SG MemberCardProfileLine";
    begin
        ResponseJson.StartArray('guests');

        MemberCardProfileLine.Init();
        if (not (IsNullGuid(SourceValidationRequest.ProfileLineId))) then
            if (not MemberCardProfileLine.GetBySystemId(SourceValidationRequest.ProfileLineId)) then
                MemberCardProfileLine.Init();

        MembershipGuest.SetFilter("Membership  Code", '=%1', MembershipCode);
        if (SourceValidationRequest.AdmissionCode <> '') then
            MembershipGuest.SetFilter("Admission Code", '=%1', SourceValidationRequest.AdmissionCode);

        ShowGuests := MembershipGuest.FindSet()
                      and MemberCard.GetBySystemId(SourceValidationRequest.EntityId)
                      and MemberCardProfileLine.AllowGuests;

        if (ShowGuests) then begin
            repeat
                if (Member.Get(MemberCard."Member Entry No.")) then begin

                    Tickets.SetCurrentKey("External Member Card No.", "Item No.", "Variant Code", "Document Date");
                    Tickets.SetFilter("External Member Card No.", '=%1', Member."External Member No.");

                    if (MembershipGuest."Ticket No. Type" = MembershipGuest."Ticket No. Type"::ITEM) then
                        Tickets.SetFilter("Item No.", '=%1', MembershipGuest."Ticket No.");

                    if (MembershipGuest."Ticket No. Type" = MembershipGuest."Ticket No. Type"::ITEM_CROSS_REF) then begin
                        if (not TicketRequestManager.TranslateBarcodeToItemVariant(MembershipGuest."Ticket No.", ItemNumber, ItemVariantCode, Resolver)) then
                            Error('Could not resolve barcode to item number for membership code %1, reference %2', MembershipGuest."Membership  Code", MembershipGuest."Ticket No.");
                        Tickets.SetFilter("Item No.", '=%1', ItemNumber);
                    end;

                    Tickets.SetFilter("Document Date", '=%1', Today());
                    TicketsCreatedToday := Tickets.Count();
                end;

                AdmitToken := CreateMemberGuestAdmissionToken(SourceValidationRequest, MembershipGuest);
                if (MembershipGuest."Cardinality Type" = MembershipGuest."Cardinality Type"::UNLIMITED) then
                    MembershipGuest."Max Cardinality" := -1;

                ResponseJson
                    .StartObject()
                    .AddProperty('token', Format(AdmitToken, 0, 4).ToLower())
                    .AddProperty('admissionCode', MembershipGuest."Admission Code")
                    .AddProperty('description', MembershipGuest.Description)
                    .AddProperty('maxNumberOfGuests', MembershipGuest."Max Cardinality")
                    .AddProperty('guestsAdmittedToday', TicketsCreatedToday)
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