codeunit 6185130 "NPR SG SpeedGate"
{
    Access = Internal;

    var
        _NumberType: Option REJECTED,NOT_WHITELISTED,TICKET,MEMBER_CARD,WALLET,DOC_LX_CITY_CARD;
        _ApiErrors: Enum "NPR API Error Code";

        _TokenToAdmit: Guid;
        _QuantityToAdmit: Integer;


    trigger OnRun()
    begin
        if (not IsNullGuid(_TokenToAdmit)) then
            Admit(_TokenToAdmit, _QuantityToAdmit);
    end;

    internal procedure CreateAdmitToken(ReferenceNumber: Text[100]; AdmissionCode: Code[20]; ScannerId: Code[10]) AdmitToken: Guid
    var
        EntryNo: Integer;
        ValidationRequest: Record "NPR SGEntryLog";
    begin
        EntryNo := CreateInitialEntry(ReferenceNumber, AdmissionCode, ScannerId);
        CheckNumberAtGate(EntryNo);
        ValidationRequest.Get(EntryNo);

        AdmitToken := ValidationRequest.Token; // Note, multiple records can be created in CheckNumberAtGate having the same Token
    end;

    internal procedure Admit(Token: Guid; Quantity: Integer)
    var
        ValidationRequest: Record "NPR SGEntryLog";
        TicketId: Guid;
    begin
        ValidationRequest.SetCurrentKey(Token);
        ValidationRequest.SetFilter(Token, '=%1', Token);
        ValidationRequest.SetFilter(EntryStatus, '=%1', ValidationRequest.EntryStatus::PERMITTED_BY_GATE);
        if (not ValidationRequest.FindSet()) then
            Error('The admit token is not valid');

        repeat
            if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::TICKET) then
                ValidateAdmitTicket(ValidationRequest);

            if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::MEMBER_CARD) then begin
                if (not IsNullGuid(TicketId) and (ValidationRequest.ExtraEntityTableId = 0)) then begin
                    ValidationRequest.ExtraEntityId := TicketId;
                    ValidationRequest.ExtraEntityTableId := Database::"NPR TM Ticket";
                end;
                TicketId := ValidateAdmitMemberCard(ValidationRequest, Quantity);
            end;

            if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::WALLET) then
                ValidateAdmitWallet(ValidationRequest);

        until (ValidationRequest.Next() = 0);

    end;

    internal procedure CheckAdmit(Token: Guid; Quantity: Integer; var ResponseMessage: Text): Boolean
    var
        ThisCodeunit: Codeunit "NPR SG SpeedGate";
    begin
        ThisCodeunit.SetAdmitToken(Token, Quantity);
        ClearLastError();

        if (ThisCodeunit.Run()) then
            exit(true);

        ResponseMessage := GetLastErrorText();
        MarkAsDenied(Token, _ApiErrors::denied_by_speedgate, ResponseMessage);

        exit(false);
    end;

    internal procedure SetAdmitToken(Token: Guid; Quantity: Integer)
    begin
        _TokenToAdmit := Token;
        _QuantityToAdmit := Quantity;
    end;

    internal procedure CreateSystemGate(ObjectId: Integer) GateId: Code[10]
    var
        SpeedGateSetup: Record "NPR SG SpeedGate";
        ScannerId: Code[10];
    begin
        ScannerId := CopyStr(StrSubstNo('BC-%1', ObjectId), 1, MaxStrLen(SpeedGateSetup.ScannerId));
        SpeedGateSetup.SetFilter(ScannerId, '=%1', ScannerId);
        if (not SpeedGateSetup.FindFirst()) then begin
            SpeedGateSetup.Init();
            SpeedGateSetup.ScannerId := ScannerId;
            SpeedGateSetup.Enabled := true;
            SpeedGateSetup.Description := CopyStr(StrSubstNo('Created by system for internal validation, source is object: %1', ObjectId), 1, MaxStrLen(SpeedGateSetup.Description));
            SpeedGateSetup.PermitTickets := true;
            SpeedGateSetup.PermitMemberCards := true;
            SpeedGateSetup.PermitWallets := true;
            SpeedGateSetup.PermitDocLxCityCard := false; // true requires a city card profile
            SpeedGateSetup.Insert(true);
        end;
        exit(SpeedGateSetup.ScannerId);
    end;

    internal procedure CreateInitialEntry(ReferenceNumber: Text[100]; AdmissionCode: Code[20]; ScannerId: Code[10]) EntryNo: Integer
    var
        EntryLog: Record "NPR SGEntryLog";
    begin
        EntryLog.Init();
        EntryLog.Token := Format(CreateGuid(), 0, 4);
        EntryLog.EntryStatus := EntryLog.EntryStatus::INITIALIZED;
        EntryLog.ReferenceNo := ReferenceNumber;
        EntryLog.AdmissionCode := AdmissionCode;
        EntryLog.ScannerId := ScannerId;
        EntryLog.Insert();
        exit(EntryLog.EntryNo);
    end;

    internal procedure ValidateAdmitWallet(var ValidationRequest: Record "NPR SGEntryLog"): Guid
    begin
        if (ValidationRequest.ExtraEntityTableId = 0) then
            Error('The tryAdmit request was not able to preselect a product for admission.');

        if (not (ValidationRequest.ExtraEntityTableId in [Database::"NPR TM Ticket", Database::"NPR MM Member Card"])) then
            Error('The admit request contains an unhandled Entity: %1', ValidationRequest.ExtraEntityTableId);

        if (ValidationRequest.ExtraEntityTableId = Database::"NPR TM Ticket") then
            exit(ValidateAdmitTicket(ValidationRequest));

        if (ValidationRequest.ExtraEntityTableId = Database::"NPR MM Member Card") then
            exit(ValidateAdmitMemberCard(ValidationRequest, 1));

    end;

    internal procedure ValidateAdmitTicket(var ValidationRequest: Record "NPR SGEntryLog"): Guid
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        Ticket: Record "NPR TM Ticket";
        ResponseMessage: Text;
    begin
        ResponseMessage := 'Invalid Validation Request';
        if (not (ValidationRequest.ReferenceNumberType in [ValidationRequest.ReferenceNumberType::TICKET, ValidationRequest.ReferenceNumberType::WALLET])) then
            Error('The admit request contains an unhandled Type: %1', ValidationRequest.ReferenceNumberType);

        if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::TICKET) then
            if (not Ticket.GetBySystemId(ValidationRequest.EntityId)) then
                Error(ResponseMessage);

        if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::WALLET) then
            if (not Ticket.GetBySystemId(ValidationRequest.ExtraEntityId)) then
                Error(ResponseMessage);

        ValidationRequest.AdmittedReferenceNo := Ticket."External Ticket No.";
        TicketManagement.RegisterArrivalScanTicket("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO,
            CopyStr(ValidationRequest.AdmittedReferenceNo, 1, 30),
            ValidationRequest.AdmissionCode,
            -1, '', // PosUnitNo, 
            ValidationRequest.ScannerId, false);

        ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::ADMITTED;
        ValidationRequest.AdmittedAt := CurrentDateTime();
        ValidationRequest.Modify();

        exit(Ticket.SystemId);
    end;

    internal procedure ValidateAdmitMemberCard(var ValidationRequest: Record "NPR SGEntryLog"): Guid
    begin
        exit(ValidateAdmitMemberCard(ValidationRequest, 1));
    end;

    internal procedure ValidateAdmitMemberCard(var ValidationRequest: Record "NPR SGEntryLog"; Quantity: Integer): Guid
    var
        MemberTicketManager: Codeunit "NPR MM Member Ticket Manager";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        MemberCard: Record "NPR MM Member Card";
        ExtraGuestValidationRequest: Record "NPR SGEntryLog";
        MembershipAdmissionSetup: Record "NPR MM Members. Admis. Setup";
        ExternalTicketNo: Text[30];
        ResponseMessage: Text;
        ResponseCode: Integer;
        Ticket: Record "NPR TM Ticket";
        LogEntryNo: Integer;
        TicketCount: Integer;
        ValidFromDate, ValidUntilDate : Date;
        InvalidRequest: Label 'Invalid Validation Request';
    begin

        if (Quantity < 1) then
            Quantity := 1;

        if (not (ValidationRequest.ReferenceNumberType in [ValidationRequest.ReferenceNumberType::MEMBER_CARD, ValidationRequest.ReferenceNumberType::WALLET])) then
            Error('The admit request contains an unhandled Type: %1', ValidationRequest.ReferenceNumberType);

        if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::MEMBER_CARD) then begin
            if (not MemberCard.GetBySystemId(ValidationRequest.EntityId)) then
                Error(InvalidRequest);
        end;

        if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::WALLET) then begin
            if (not MemberCard.GetBySystemId(ValidationRequest.ExtraEntityId)) then
                Error(InvalidRequest);
        end;

        if (MemberManagement.MembershipNeedsActivation(MemberCard."Membership Entry No.")) then
            MemberManagement.ActivateMembershipLedgerEntry(MemberCard."Membership Entry No.", Today());

        if (not MemberManagement.GetMembershipValidDate(MemberCard."Membership Entry No.", Today(), ValidFromDate, ValidUntilDate)) then
            Error('Membership is not valid for today, it is valid from %1 until %2', ValidFromDate, ValidUntilDate);

        ResponseMessage := '';
        ValidationRequest.MemberCardLogEntryNo := MemberLimitationMgr.WS_CheckLimitMemberCardArrival(MemberCard."External Card No.", ValidationRequest.AdmissionCode, ValidationRequest.ScannerId, LogEntryNo, ResponseMessage, ResponseCode);
        ValidationRequest.Modify();
        if (ResponseCode <> 0) then
            Error(ResponseMessage);

        case ValidationRequest.ExtraEntityTableId of
            0: // Originates from a Member Card scan
               // Has a commit inside
                begin
                    MemberTicketManager.MemberFastCheckInNoPrint(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", ValidationRequest.AdmissionCode, '', 1, '', ExternalTicketNo);
                    MemberLimitationMgr.UpdateLogEntry(ValidationRequest.MemberCardLogEntryNo, 0, ExternalTicketNo);
                end;

            Database::"NPR MM Member Card": // Originates from Wallet number    
                begin
                    MemberTicketManager.MemberFastCheckInNoPrint(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", ValidationRequest.AdmissionCode, '', 1, '', ExternalTicketNo);
                    MemberLimitationMgr.UpdateLogEntry(ValidationRequest.MemberCardLogEntryNo, 0, ExternalTicketNo);
                end;

            Database::"NPR MM Members. Admis. Setup": // Guests
                begin
                    MembershipAdmissionSetup.GetBySystemId(ValidationRequest.ExtraEntityId);
                    if (MembershipAdmissionSetup."Cardinality Type" = MembershipAdmissionSetup."Cardinality Type"::LIMITED) then
                        if (Quantity > MembershipAdmissionSetup."Max Cardinality") then
                            Error('The number of guests requested (%1) exceeds the maximum cardinality for the guest setup (%2)', Quantity, MembershipAdmissionSetup."Max Cardinality");

                    for TicketCount := 2 to Quantity do begin
                        ExtraGuestValidationRequest := ValidationRequest;
                        ExtraGuestValidationRequest.EntryNo := 0;
                        MemberTicketManager.MemberGuestFastCheckInNoPrint(ValidationRequest.ExtraEntityId, false, MemberCard."Membership Entry No.", MemberCard."Member Entry No.", ValidationRequest.AdmissionCode, '', 1, '', ExternalTicketNo);

                        ExtraGuestValidationRequest.EntryStatus := ValidationRequest.EntryStatus::ADMITTED;
                        ExtraGuestValidationRequest.AdmittedAt := CurrentDateTime;
                        ExtraGuestValidationRequest.AdmittedReferenceNo := ExternalTicketNo;
                        ExtraGuestValidationRequest.Insert();
                    end;

                    MemberTicketManager.MemberGuestFastCheckInNoPrint(ValidationRequest.ExtraEntityId, false, MemberCard."Membership Entry No.", MemberCard."Member Entry No.", ValidationRequest.AdmissionCode, '', 1, '', ExternalTicketNo);
                    MemberLimitationMgr.UpdateLogEntry(ValidationRequest.MemberCardLogEntryNo, 0, StrSubstNo('%1 x %2', Quantity, MembershipAdmissionSetup."Description"));
                end;

            Database::"NPR TM Ticket":
                begin
                    if (not Ticket.GetBySystemId(ValidationRequest.ExtraEntityId)) then
                        Error(ResponseMessage);

                    ExternalTicketNo := Ticket."External Ticket No.";
                    ValidationRequest.AdmittedReferenceNo := Ticket."External Ticket No.";

                    TicketManagement.RegisterArrivalScanTicket("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO,
                        CopyStr(ValidationRequest.AdmittedReferenceNo, 1, 30),
                        ValidationRequest.AdmissionCode,
                        -1, '', // PosUnitNo, 
                        ValidationRequest.ScannerId, false);

                    MemberLimitationMgr.UpdateLogEntry(ValidationRequest.MemberCardLogEntryNo, 0, ExternalTicketNo);
                end;

            else
                Error('Unknown MemberCard ExtraEntityTableId');
        end;

        ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::ADMITTED;
        ValidationRequest.AdmittedAt := CurrentDateTime;
        ValidationRequest.AdmittedReferenceNo := ExternalTicketNo;
        ValidationRequest.Modify();

        Ticket.SetFilter("External Ticket No.", '=%1', ExternalTicketNo);
        if (not Ticket.FindFirst()) then
            Ticket.Init();

        exit(Ticket.SystemId);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    internal procedure CheckNumberAtGate(LogEntryNo: Integer)
    var
        ValidationRequest: Record "NPR SGEntryLog";
        Admission: Record "NPR TM Admission";
        WhiteListProfileCode: Code[10];
        TicketProfileCode: Code[10];
        MemberCardProfileCode: Code[10];
        WalletProfileCode: Code[10];
        CityCardProfileId: Guid;
        PermitTickets, PermitMemberships, PermitWallets, PermitCityCard : Boolean;
        DetectedNumberType: Option;
        ValidationModeStrict: Boolean;
        NumberPermitted: Boolean;
        AdmitToAdmissionCodes: List of [Code[20]];
        AdmissionCode: Code[20];
        EntityId: Guid;
        ProfileLineId: Guid;
    begin
        DetectedNumberType := _NumberType::NOT_WHITELISTED;
        ValidationRequest.Get(LogEntryNo);

        if (not GetValidationProfilesForScanner(ValidationRequest.ScannerId, WhiteListProfileCode, TicketProfileCode, PermitTickets, MemberCardProfileCode, PermitMemberships, WalletProfileCode, PermitWallets, CityCardProfileId, PermitCityCard, ValidationRequest.ApiErrorNumber)) then begin
            ValidationRequest.ReferenceNumberType := ValidationRequest.ReferenceNumberType::UNKNOWN;
            ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::DENIED_BY_GATE;
            ValidationRequest.Modify();
            exit;
        end;

        if (ValidationRequest.AdmissionCode <> '') then
            if (not Admission.Get(ValidationRequest.AdmissionCode)) then begin
                _ApiErrors := _ApiErrors::invalid_admission_code;
                ValidationRequest.ApiErrorNumber := _ApiErrors.AsInteger();
                ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::DENIED_BY_GATE;
                ValidationRequest.Modify();
                exit;
            end;

        NumberPermitted := false;

        if (WhiteListProfileCode <> '') then begin
            DetermineNumberType(WhiteListProfileCode, ValidationRequest.ReferenceNo, DetectedNumberType, ValidationModeStrict);
            case DetectedNumberType of
                _NumberType::TICKET:
                    if (PermitTickets) then
                        NumberPermitted := CheckForTicket(TicketProfileCode, ValidationRequest.ReferenceNo, ValidationRequest.AdmissionCode, EntityId, AdmitToAdmissionCodes, ProfileLineId);

                _NumberType::MEMBER_CARD:
                    if (PermitMemberships) then
                        NumberPermitted := CheckForMemberCard(MemberCardProfileCode, ValidationRequest.ReferenceNo, ValidationRequest.AdmissionCode, EntityId, AdmitToAdmissionCodes, ProfileLineId);

                _NumberType::WALLET:
                    if (PermitWallets) then
                        NumberPermitted := CheckForWallet(TicketProfileCode, MemberCardProfileCode, ValidationRequest, EntityId, AdmitToAdmissionCodes, ProfileLineId);

                _NumberType::DOC_LX_CITY_CARD:
                    if (PermitCityCard) then
                        NumberPermitted := true; // not yet implemented;

                _NumberType::NOT_WHITELISTED:
                    begin
                        if (ValidationModeStrict) then begin
                            _ApiErrors := _ApiErrors::number_not_whitelisted;
                            ValidationRequest.ApiErrorNumber := _ApiErrors.AsInteger();
                            ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::DENIED_BY_GATE;
                            ValidationRequest.Modify();
                            exit;
                        end;
                    end;

                _NumberType::REJECTED:
                    begin
                        _ApiErrors := _ApiErrors::number_rejected;
                        ValidationRequest.ApiErrorNumber := _ApiErrors.AsInteger();
                        ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::DENIED_BY_GATE;
                        ValidationRequest.Modify();
                        exit;
                    end;
            end;
        end;

        // When no whitelist profile is defined, check number in this order
        if (PermitTickets and not NumberPermitted) then begin
            NumberPermitted := CheckForTicket(TicketProfileCode, ValidationRequest.ReferenceNo, ValidationRequest.AdmissionCode, EntityId, AdmitToAdmissionCodes, ProfileLineId);
            if (NumberPermitted) then
                DetectedNumberType := _NumberType::TICKET;
        end;

        if (PermitMemberships and not NumberPermitted) then begin
            NumberPermitted := CheckForMemberCard(MemberCardProfileCode, ValidationRequest.ReferenceNo, ValidationRequest.AdmissionCode, EntityId, AdmitToAdmissionCodes, ProfileLineId);
            if (NumberPermitted) then
                DetectedNumberType := _NumberType::MEMBER_CARD;
        end;

        if (PermitWallets and not NumberPermitted) then begin
            NumberPermitted := CheckForWallet(TicketProfileCode, MemberCardProfileCode, ValidationRequest, EntityId, AdmitToAdmissionCodes, ProfileLineId);
            if (NumberPermitted) then
                DetectedNumberType := _NumberType::WALLET;
        end;

        /* Only allow when the city card number prefix is in the allowed number list?
        if (PermitCityCard and not NumberPermitted) then begin
            NumberPermitted := false; // not yet implemented
            if (NumberPermitted) then
                DetectedNumberType := _NumberType::DOC_LX_CITY_CARD;
        end;
        */

        // When still not permitted, exit out with error
        ValidationRequest.ReferenceNumberType := DetectedNumberType;
        if (not NumberPermitted) then begin
            _ApiErrors := _ApiErrors::denied_by_speedgate;
            ValidationRequest.ApiErrorNumber := _ApiErrors.AsInteger();
            ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::DENIED_BY_GATE;
            ValidationRequest.Modify();
            exit;
        end;

        // Happy path
        ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::PERMITTED_BY_GATE;
        ValidationRequest.EntityId := EntityId;
        ValidationRequest.ProfileLineId := ProfileLineId;
        ValidationRequest.Modify();

        if (AdmitToAdmissionCodes.Contains(ValidationRequest.AdmissionCode)) then
            AdmitToAdmissionCodes.Remove(ValidationRequest.AdmissionCode);

        if (ValidationRequest.AdmissionCode = '') and (AdmitToAdmissionCodes.Count > 0) then begin
            ValidationRequest.AdmissionCode := AdmitToAdmissionCodes.Get(1);
            ValidationRequest.Modify();
            AdmitToAdmissionCodes.RemoveAt(1);
        end;

        foreach AdmissionCode in AdmitToAdmissionCodes do begin
            ValidationRequest.EntryNo := 0;
            ValidationRequest.AdmissionCode := AdmissionCode;
            ValidationRequest.Insert();
        end;
    end;

    internal procedure AdmitTokenIsValid(Token: Guid): Boolean
    var
        ValidationRequest: Record "NPR SGEntryLog";
    begin
        ValidationRequest.SetCurrentKey(Token);
        ValidationRequest.SetFilter(Token, '=%1', Token);
        ValidationRequest.SetFilter(EntryStatus, '=%1', ValidationRequest.EntryStatus::PERMITTED_BY_GATE);
        exit(not ValidationRequest.IsEmpty());
    end;

    local procedure DetermineNumberType(ProfileCode: Code[10]; Number: Text[100]; var NumberType: Option; var ValidateModeStrict: Boolean)
    var
        NumberWhiteList: Record "NPR SG AllowedNumbersList";
        NumberWhiteListLine: Record "NPR SG NumberWhiteListLine";

        TmpNumber: Text[100];
        LengthMatch, PrefixMatch : Boolean;
    begin
        NumberType := _NumberType::NOT_WHITELISTED;
        ValidateModeStrict := false;

        if (ProfileCode = '') then
            exit;

        if (not NumberWhiteList.Get(ProfileCode)) then
            exit;
        ValidateModeStrict := (NumberWhiteList.ValidateMode = NumberWhiteList.ValidateMode::STRICT);

        NumberWhiteListLine.SetFilter(Code, '=%1', ProfileCode);
        if (ValidateModeStrict) then
            NumberWhiteListLine.SetFilter(RuleType, '=%1', NumberWhiteListLine.RuleType::ALLOW);

        if (not NumberWhiteListLine.FindSet()) then
            exit;

        repeat
            LengthMatch := true; // optional
            PrefixMatch := false;

            TmpNumber := Number;
            if (NumberWhiteListLine.NumberLength > 0) then
                LengthMatch := (StrLen(TmpNumber) = NumberWhiteListLine.NumberLength);

            if (StrLen(NumberWhiteListLine.Prefix) <= StrLen(TmpNumber)) then
                PrefixMatch := (CopyStr(TmpNumber, 1, StrLen(NumberWhiteListLine.Prefix)) = NumberWhiteListLine.Prefix);

            if (LengthMatch and PrefixMatch) then begin
                if (NumberWhiteListLine.RuleType = NumberWhiteListLine.RuleType::ALLOW) then begin
                    case NumberWhiteListLine.Type of
                        NumberWhiteListLine.Type::TICKET:
                            NumberType := _NumberType::TICKET;
                        NumberWhiteListLine.Type::MEMBER_CARD:
                            NumberType := _NumberType::MEMBER_CARD;
                        NumberWhiteListLine.Type::WALLET:
                            NumberType := _NumberType::WALLET;
                        NumberWhiteListLine.Type::DOC_LX_CITY_CARD:
                            NumberType := _NumberType::DOC_LX_CITY_CARD;
                    end;
                end else begin
                    NumberType := _NumberType::REJECTED;
                end;
            end;

        until ((NumberWhiteListLine.Next() = 0) or (NumberType = _NumberType::REJECTED));

    end;

    local procedure CheckForWallet(TicketProfileCode: Code[10]; MemberCardProfileCode: Code[10]; var ValidationRequest: Record "NPR SGEntryLog"; var EntityId: Guid; var AdmitToCodes: List of [Code[20]]; var ProfileLineId: Guid): Boolean
    var
        Number: Text[100];
        SuggestedAdmissionCode: Code[20];
        Wallet: Record "NPR AttractionWallet";
        TicketIds, MemberCardIds : List of [Guid];
        MemberCardId, TicketId : Guid;
        MemberCard: Record "NPR MM Member Card";
        Ticket: Record "NPR TM Ticket";
    begin
        Number := ValidationRequest.ReferenceNo;
        SuggestedAdmissionCode := ValidationRequest.AdmissionCode;

        Wallet.SetCurrentKey(ReferenceNumber);
        Wallet.SetFilter(ReferenceNumber, '=%1', CopyStr(UpperCase(Number), 1, MaxStrLen(Wallet.ReferenceNumber)));
        Wallet.SetFilter(ExpirationDate, '=%1|<=%2', 0DT, CurrentDateTime());
        if (not Wallet.FindFirst()) then
            exit(false);

        GetWalletTickets(Wallet.EntryNo, TicketProfileCode, SuggestedAdmissionCode, TicketIds);
        GetWalletMemberCards(Wallet.EntryNo, MemberCardProfileCode, SuggestedAdmissionCode, MemberCardIds);

        if (TicketIds.Count() = 1) and (MemberCardIds.Count() = 0) then begin
            Ticket.GetBySystemId(TicketIds.Get(1));
            ValidationRequest.ExtraEntityId := TicketIds.Get(1);
            ValidationRequest.ExtraEntityTableId := Database::"NPR TM Ticket";
            CheckForTicket(TicketProfileCode, Ticket."External Ticket No.", SuggestedAdmissionCode, TicketId, AdmitToCodes, ProfileLineId);
        end;

        if (TicketIds.Count() = 0) and (MemberCardIds.Count() = 1) then begin
            MemberCard.GetBySystemId(MemberCardIds.Get(1));
            ValidationRequest.ExtraEntityId := MemberCardIds.Get(1);
            ValidationRequest.ExtraEntityTableId := Database::"NPR MM Member Card";
            CheckForMemberCard(MemberCardProfileCode, MemberCard."External Card No.", SuggestedAdmissionCode, MemberCardId, AdmitToCodes, ProfileLineId);
        end;

        EntityId := Wallet.SystemId;
        exit(true);
    end;


    local procedure GetWalletTickets(WalletEntryNo: Integer; TicketProfileCode: Code[10]; SuggestedAdmissionCode: Code[20]; var TicketIds: List of [Guid]): Boolean
    var
        WalletAssetLine: Record "NPR WalletAssetLine";
        WalletAgent: Codeunit "NPR AttractionWallet";
        AdmitToCodes: List of [Code[20]];
        TicketId: Guid;
        ProfileLineId: Guid;
    begin
        WalletAssetLine.SetCurrentKey(TransactionId, Type);
        WalletAssetLine.SetFilter(TransactionId, '=%1', WalletAgent.GetWalletTransactionId(WalletEntryNo));
        WalletAssetLine.SetFilter(Type, '=%1', ENUM::"NPR WalletLineType"::Ticket);
        if (not WalletAssetLine.FindSet()) then
            exit(false);

        repeat
            Clear(AdmitToCodes);
            if (CheckForTicket(TicketProfileCode, WalletAssetLine.LineTypeReference, SuggestedAdmissionCode, TicketId, AdmitToCodes, ProfileLineId)) then
                TicketIds.Add(WalletAssetLine.LineTypeSystemId);
        until (WalletAssetLine.Next() = 0);

        exit(true);
    end;

    local procedure GetWalletMemberCards(WalletEntryNo: Integer; MemberCardProfileCode: Code[10]; SuggestedAdmissionCode: Code[20]; var MemberCardIds: List of [Guid]): Boolean
    var
        WalletAssetLine: Record "NPR WalletAssetLine";
        WalletAgent: Codeunit "NPR AttractionWallet";
        AdmitToCodes: List of [Code[20]];
        MemberCardId: Guid;
        ProfileLineId: Guid;
    begin
        WalletAssetLine.SetCurrentKey(TransactionId, Type);
        WalletAssetLine.SetFilter(TransactionId, '=%1', WalletAgent.GetWalletTransactionId(WalletEntryNo));
        WalletAssetLine.SetFilter(Type, '=%1', ENUM::"NPR WalletLineType"::MEMBERSHIP);
        if (not WalletAssetLine.FindSet()) then
            exit(false);

        repeat
            Clear(AdmitToCodes);
            if (CheckForMemberCard(MemberCardProfileCode, WalletAssetLine.LineTypeReference, SuggestedAdmissionCode, MemberCardId, AdmitToCodes, ProfileLineId)) then
                MemberCardIds.Add(WalletAssetLine.LineTypeSystemId);
        until (WalletAssetLine.Next() = 0);

        exit(true);
    end;

    internal procedure CheckTicket(ScannerId: Code[10]; TicketNo: Text[100]; AdmissionCode: Code[20]; var AdmitToCodes: List of [Code[20]]): Boolean
    var
        WhiteListProfileCode: Code[10];
        TicketProfileCode: Code[10];
        PermitTickets: Boolean;
        MemberCardProfileCode: Code[10];
        PermitMemberships: Boolean;
        WalletProfileCode: Code[10];
        PermitWallets: Boolean;
        CityCardProfileId: Guid;
        PermitCityCard: Boolean;
        ApiErrorNumber: Integer;
        TicketId: Guid;
        ProfileLineId: Guid;
    begin
        if (not GetValidationProfilesForScanner(ScannerId, WhiteListProfileCode, TicketProfileCode, PermitTickets, MemberCardProfileCode, PermitMemberships, WalletProfileCode, PermitWallets, CityCardProfileId, PermitCityCard, ApiErrorNumber)) then
            exit(false);
        exit(CheckForTicket(TicketProfileCode, TicketNo, AdmissionCode, TicketId, AdmitToCodes, ProfileLineId));
    end;

    local procedure CheckForTicket(TicketProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var TicketId: Guid; var AdmitToCodes: List of [Code[20]]; var ProfileLineId: Guid): Boolean
    var
        TicketProfile: Record "NPR SG TicketProfile";
        TicketProfileLine: Record "NPR SG TicketProfileLine";
    begin
        if (TicketProfileCode = '') then
            exit(IsTicket(TicketProfileCode, Number, SuggestedAdmissionCode, TicketId, AdmitToCodes, ProfileLineId));

        if (not TicketProfile.Get(TicketProfileCode)) then
            exit(false); // Ticket profile is invalid - all tickets are denied

        TicketProfileLine.SetFilter(Code, '=%1', TicketProfileCode);
        if (TicketProfile.ValidationMode = TicketProfile.ValidationMode::STRICT) then
            if (TicketProfileLine.IsEmpty()) then
                exit(false); // Ticket profile is empty - all tickets are denied

        exit(IsTicket(TicketProfileCode, Number, SuggestedAdmissionCode, TicketId, AdmitToCodes, ProfileLineId));
    end;

    local procedure IsTicket(TicketProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var TicketId: Guid; var AdmitToCodes: List of [Code[20]]; var ProfileLineId: Guid): Boolean
    var
        TicketProfile: Record "NPR SG TicketProfile";
        TicketProfileLine: Record "NPR SG TicketProfileLine";
        Ticket: Record "NPR TM Ticket";
        TicketBom: Record "NPR TM Ticket Admission BOM";

        AdmissionLocalTime: DateTime;
        LocalTime: Time;
        LocalDate: Date;
        TimeHelper: Codeunit "NPR TM TimeHelper";
        IsPermittedAdmission: Boolean;

    begin
        Ticket.SetCurrentKey("External Ticket No.");
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(UpperCase(Number), 1, MaxStrLen(Ticket."External Ticket No.")));
        Ticket.SetFilter(Blocked, '=%1', false);
        if (not Ticket.FindFirst()) then
            exit(false);

        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        if (SuggestedAdmissionCode <> '') then
            TicketBom.SetFilter("Admission Code", '=%1', SuggestedAdmissionCode);

        if (not TicketBom.FindSet()) then
            exit(false);

        repeat
            AdmissionLocalTime := TimeHelper.GetLocalTimeAtAdmission(TicketBom."Admission Code");
            LocalTime := DT2Time(AdmissionLocalTime);
            LocalDate := DT2Date(AdmissionLocalTime);

            TicketProfileLine.SetFilter(Code, '=%1', TicketProfileCode);
            TicketProfileLine.SetFilter(ItemNo, '=%1|=%2', Ticket."Item No.", '');
            TicketProfileLine.SetFilter(AdmissionCode, '=%1|=%2', TicketBom."Admission Code", '');
            TicketProfileLine.SetFilter(RuleType, '=%1', TicketProfileLine.RuleType::ALLOW);
            if (TicketProfileLine.FindSet()) then
                repeat
                    IsPermittedAdmission := true; // Assume working hours
                    if (TicketProfileLine.CalendarCode <> '') then
                        IsPermittedAdmission := not (CheckAdmissionIsNonWorking(TicketBom."Admission Code", TicketProfileLine.CalendarCode, LocalDate));

                    if (TicketProfileLine.PermitFromTime <> 0T) and (TicketProfileLine.PermitUntilTime <> 0T) then
                        IsPermittedAdmission := IsPermittedAdmission and (LocalTime >= TicketProfileLine.PermitFromTime) and (LocalTime <= TicketProfileLine.PermitUntilTime);

                    if (IsPermittedAdmission) then begin
                        if (not AdmitToCodes.Contains(TicketBom."Admission Code")) then
                            AdmitToCodes.Add(TicketBom."Admission Code");
                        ProfileLineId := TicketProfileLine.SystemId;
                    end;
                until (TicketProfileLine.Next() = 0);
        until (TicketBom.Next() = 0);

        if (AdmitToCodes.Count = 0) then begin
            if (TicketProfileCode = '') then begin
                TicketProfile.ValidationMode := TicketProfile.ValidationMode::FLEXIBLE;
            end else if (not TicketProfile.Get(TicketProfileCode)) then begin
                TicketProfile.ValidationMode := TicketProfile.ValidationMode::STRICT;
            end;

            if (TicketProfile.ValidationMode = TicketProfile.ValidationMode::FLEXIBLE) then begin
                TicketBom.Reset();
                TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
                TicketBom.SetFilter(Default, '=%1', true);
                if (TicketBom.FindFirst()) then
                    AdmitToCodes.Add(TicketBom."Admission Code");
            end;

            if (TicketProfile.ValidationMode = TicketProfile.ValidationMode::STRICT) then
                exit(false);
        end;

        TicketId := Ticket.SystemId;
        exit(true);
    end;

    local procedure CheckForMemberCard(MemberCardProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var MemberCardId: Guid; var AdmitToCodes: List of [Code[20]]; var ProfileLineId: Guid): Boolean
    var
        MemberCardProfile: Record "NPR SG MemberCardProfile";
        MemberCardProfileLine: Record "NPR SG MemberCardProfileLine";
    begin
        if (MemberCardProfileCode = '') then
            exit(IsMemberCard(MemberCardProfileCode, Number, SuggestedAdmissionCode, MemberCardId, AdmitToCodes, ProfileLineId));

        if (not MemberCardProfile.Get(MemberCardProfileCode)) then
            exit(false); // MemberCard profile is invalid - all cards are denied

        MemberCardProfileLine.SetFilter(Code, '=%1', MemberCardProfileCode);
        if (MemberCardProfile.ValidationMode = MemberCardProfile.ValidationMode::STRICT) then
            if (MemberCardProfileLine.IsEmpty()) then
                exit(false); // MemberCard profile is empty - all cards are denied

        exit(IsMemberCard(MemberCardProfileCode, Number, SuggestedAdmissionCode, MemberCardId, AdmitToCodes, ProfileLineId));
    end;

    local procedure IsMemberCard(MemberCardProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var MemberCardId: Guid; var AdmitToCodes: List of [Code[20]]; var ProfileLineId: Guid): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCardProfile: Record "NPR SG MemberCardProfile";
        MemberCardProfileLine: Record "NPR SG MemberCardProfileLine";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        IsPermitted: Boolean;

        AdmissionLocalTime: DateTime;
        LocalTime: Time;
        LocalDate: Date;
        TimeHelper: Codeunit "NPR TM TimeHelper";
    begin
        MemberCard.SetCurrentKey("External Card No.");
        MemberCard.SetFilter("External Card No.", '=%1', CopyStr(UpperCase(Number), 1, MaxStrLen(MemberCard."External Card No.")));
        MemberCard.SetFilter(Blocked, '=%1', false);
        if (not MemberCard.FindFirst()) then
            exit(false);

        if (not Membership.Get(MemberCard."Membership Entry No.")) then
            exit(false);

        if (Membership.Blocked) then
            exit(false);

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit(false);

        if (MembershipSetup."Ticket Item Barcode" = '') then
            exit(false);

        if (MembershipSetup."Card Expire Date Calculation" <> MembershipSetup."Card Expire Date Calculation"::NA) then
            if (MemberCard."Valid Until" < Today()) then
                exit(false);

        if (MembershipSetup."Ticket Item Type" = MembershipSetup."Ticket Item Type"::REFERENCE) then begin
            if (MemberRetailIntegration.TranslateBarcodeToItemVariant(MembershipSetup."Ticket Item Barcode", ItemNo, VariantCode, ResolvingTable)) then begin
                MembershipSetup."Ticket Item Type" := MembershipSetup."Ticket Item Type"::ITEM;
                MembershipSetup."Ticket Item Barcode" := ItemNo;
            end;
        end;

        if (MemberCardProfileCode <> '') then begin
            MemberCardProfileLine.SetFilter(Code, '=%1', MemberCardProfileCode);
            MemberCardProfileLine.SetFilter(MembershipCode, '=%1|=%2', '', Membership."Membership Code");
            MemberCardProfileLine.SetFilter(ItemNo, '=%1|=%2', '', MembershipSetup."Ticket Item Barcode");
            if (SuggestedAdmissionCode <> '') then
                MemberCardProfileLine.SetFilter(AdmissionCode, '=%1', SuggestedAdmissionCode);
            MemberCardProfileLine.SetFilter(RuleType, '=%1', MemberCardProfileLine.RuleType::ALLOW);
            if (not MemberCardProfileLine.FindSet()) then
                exit(false);

            repeat
                AdmissionLocalTime := TimeHelper.GetLocalTimeAtAdmission(MemberCardProfileLine.AdmissionCode);
                LocalTime := DT2Time(AdmissionLocalTime);
                LocalDate := DT2Date(AdmissionLocalTime);

                IsPermitted := true; // Assume working hours
                if (MemberCardProfileLine.CalendarCode <> '') and (MemberCardProfileLine.AdmissionCode <> '') then
                    IsPermitted := not (CheckAdmissionIsNonWorking(MemberCardProfileLine.AdmissionCode, MemberCardProfileLine.CalendarCode, LocalDate));

                if (MemberCardProfileLine.PermitFromTime <> 0T) and (MemberCardProfileLine.PermitUntilTime <> 0T) then
                    IsPermitted := IsPermitted and (LocalTime >= MemberCardProfileLine.PermitFromTime) and (LocalTime <= MemberCardProfileLine.PermitUntilTime);

                if (IsPermitted) then begin
                    if (MemberCardProfileLine.AdmissionCode = '') then begin
                        TicketBom.Reset();
                        TicketBom.SetFilter("Item No.", '=%1', MembershipSetup."Ticket Item Barcode");
                        TicketBom.SetFilter(Default, '=%1', true);
                        if (TicketBom.FindFirst()) then
                            if (not AdmitToCodes.Contains(TicketBom."Admission Code")) then
                                AdmitToCodes.Add(TicketBom."Admission Code");
                    end;

                    if (MemberCardProfileLine.AdmissionCode <> '') then
                        if (not AdmitToCodes.Contains(MemberCardProfileLine.AdmissionCode)) then
                            AdmitToCodes.Add(MemberCardProfileLine.AdmissionCode);

                    ProfileLineId := MemberCardProfileLine.SystemId;
                end;

            until (MemberCardProfileLine.Next() = 0);
        end;

        if (AdmitToCodes.Count = 0) and (SuggestedAdmissionCode = '') then begin
            if (MemberCardProfileCode = '') then begin
                MemberCardProfile.ValidationMode := MemberCardProfile.ValidationMode::FLEXIBLE;
            end else if (not MemberCardProfile.Get(MemberCardProfileCode)) then begin
                MemberCardProfile.ValidationMode := MemberCardProfile.ValidationMode::STRICT;
            end;

            if (MemberCardProfile.ValidationMode = MemberCardProfile.ValidationMode::FLEXIBLE) then begin
                TicketBom.Reset();
                TicketBom.SetFilter("Item No.", '=%1', MembershipSetup."Ticket Item Barcode");
                TicketBom.SetFilter(Default, '=%1', true);
                if (TicketBom.FindFirst()) then
                    if (not AdmitToCodes.Contains(TicketBom."Admission Code")) then
                        AdmitToCodes.Add(TicketBom."Admission Code");
            end;

            if (MemberCardProfile.ValidationMode = MemberCardProfile.ValidationMode::STRICT) then
                exit(false);
        end;

        MemberCardId := MemberCard.SystemId;
        exit(true);

    end;

    local procedure GetValidationProfilesForScanner(
        ScannerId: Code[20];
        var WhiteListProfileCode: Code[10];
        var TicketProfileCode: Code[10]; var AllowTickets: Boolean;
        var MemberCardProfileCode: Code[10]; var AllowMemberships: Boolean;
        var WalletProfileCode: Code[10]; var AllowWallets: Boolean;
        var CityCardProfileId: Guid; var AllowCityCards: Boolean;
        var ApiErrorNumber: Integer): Boolean
    var
        SpeedGateDefault: Record "NPR SG SpeedGateDefault";
        SpeedGate: Record "NPR SG SpeedGate";
    begin
        WhiteListProfileCode := '';
        TicketProfileCode := '';
        AllowTickets := true;
        MemberCardProfileCode := '';
        AllowMemberships := true;
        WalletProfileCode := '';
        AllowWallets := true;
        AllowCityCards := false;

        if (not SpeedGateDefault.Get()) then
            exit(true);

        WhiteListProfileCode := SpeedGateDefault.AllowedNumbersList;
        TicketProfileCode := SpeedGateDefault.DefaultTicketProfileCode;
        AllowTickets := SpeedGateDefault.PermitTickets;

        MemberCardProfileCode := SpeedGateDefault.DefaultMemberCardProfileCode;
        AllowMemberships := SpeedGateDefault.PermitMemberCards;

        //WalletProfile := SpeedGateDefault.WalletProfile;
        AllowWallets := SpeedGateDefault.PermitWallets;

        if (SpeedGateDefault.RequireScannerId) then
            if (ScannerId = '') then begin
                ApiErrorNumber := _ApiErrors::scanner_id_required.AsInteger();
                exit(false);
            end;

        SpeedGate.Init();
        SpeedGate.SetFilter(ScannerId, '=%1', ScannerId);
        if (not SpeedGate.FindFirst()) then
            if (SpeedGateDefault.RequireScannerId) then begin
                ApiErrorNumber := _ApiErrors::scanner_not_found.AsInteger();
                exit(false);
            end;

        if (not SpeedGate.FindFirst()) then
            exit(true); // No scanner specific settings

        if (SpeedGateDefault.RequireScannerId) and (not SpeedGate.Enabled) then begin
            ApiErrorNumber := _ApiErrors::scanner_not_enabled.AsInteger();
            exit(false);
        end;

        if (not SpeedGate.Enabled) then
            exit(true); // Scanner settings are disabled but not required

        WhiteListProfileCode := SpeedGate.AllowedNumbersList;
        TicketProfileCode := SpeedGate.TicketProfileCode;
        MemberCardProfileCode := SpeedGate.MemberCardProfileCode;
        WalletProfileCode := '';
        CityCardProfileId := SpeedGate.DocLxCityCardProfileId;

        AllowTickets := SpeedGate.PermitTickets;
        AllowMemberships := SpeedGate.PermitMemberCards;
        AllowWallets := SpeedGate.PermitWallets;
        AllowCityCards := SpeedGate.PermitDocLxCityCard;

        exit(true);
    end;

    procedure CheckAdmissionIsNonWorking(AdmissionCode: Code[20]; CalendarCode: Code[10]; ReferenceDate: Date) IsNonWorking: Boolean
    var
        TempCustomCalendarChange: Record "Customized Calendar Change" temporary;
        CalendarManagement: Codeunit "Calendar Management";
    begin
        TempCustomCalendarChange.SetSource(
            TempCustomCalendarChange."Source Type"::NPR_TM_Admission, AdmissionCode, '', CalendarCode);
        TempCustomCalendarChange.Date := ReferenceDate;
        TempCustomCalendarChange.Insert();
        CalendarManagement.CheckDateStatus(TempCustomCalendarChange);
        exit(TempCustomCalendarChange.Nonworking);
    end;

    internal procedure MarkAsDenied(Token: Guid; ErrorCode: Enum "NPR API Error Code"; ErrorMessage: Text)
    var
        ValidationRequest: Record "NPR SGEntryLog";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MemberCard: Record "NPR MM Member Card";
        ResponseMessage: Text;
        ResponseCode: Integer;
    begin
        if (ErrorCode.AsInteger() = 0) then
            ErrorCode := ErrorCode::denied_by_speedgate;

        ValidationRequest.SetCurrentKey(Token);
        ValidationRequest.SetFilter("Token", '=%1', Token);
        if (ValidationRequest.FindSet()) then begin
            repeat
                ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::DENIED;
                if (ValidationRequest.ApiErrorNumber = 0) then
                    ValidationRequest.ApiErrorNumber := ErrorCode.AsInteger();
                ValidationRequest.ApiErrorMessage := CopyStr(ErrorMessage, 1, MaxStrLen(ValidationRequest.ApiErrorMessage));
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
}