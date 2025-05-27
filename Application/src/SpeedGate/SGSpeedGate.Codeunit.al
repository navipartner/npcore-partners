codeunit 6185130 "NPR SG SpeedGate"
{
    Access = Internal;

    var
        _NumberType: Option REJECTED,NOT_WHITELISTED,TICKET,MEMBER_CARD,WALLET,DOC_LX_CITY_CARD,TICKET_REQUEST;
        _ApiErrors: Enum "NPR API Error Code";

        _TokenToAdmit: Guid;
        _QuantityToAdmit: Integer;
        _EndOfSaleAdmitMode: Boolean;


    trigger OnRun()
    begin
        if (not IsNullGuid(_TokenToAdmit)) then
            Admit(_TokenToAdmit, _QuantityToAdmit);
    end;

    internal procedure SetEndOfSalesAdmitMode()
    begin
        _EndOfSaleAdmitMode := true;
    end;

    internal procedure SetEndOfSalesAdmitMode(NewMode: Boolean) CurrentMode: Boolean
    begin
        CurrentMode := _EndOfSaleAdmitMode;
        _EndOfSaleAdmitMode := NewMode;
    end;


    internal procedure CreateAdmitToken(ReferenceNumber: Text[100]; AdmissionCode: Code[20]; ScannerId: Code[10]) AdmitToken: Guid
    var
        ErrorMessage: Text;
        HaveError: Boolean;
    begin
        exit(CreateAdmitToken(ReferenceNumber, AdmissionCode, ScannerId, false, HaveError, ErrorMessage));
    end;

    internal procedure CreateAdmitToken(ReferenceNumber: Text[100]; AdmissionCode: Code[20]; ScannerId: Code[10]; FailWithError: Boolean; var HaveError: Boolean; var ErrorMessage: Text) AdmitToken: Guid
    var
        EntryNo: Integer;
        ValidationRequest: Record "NPR SGEntryLog";
    begin
        EntryNo := CreateInitialEntry(ReferenceNumber, AdmissionCode, ScannerId);
        CheckNumberAtGate(EntryNo);
        ValidationRequest.Get(EntryNo);

        HaveError := CheckAdmitTokenForError(ValidationRequest.Token, FailWithError, ErrorMessage);

        AdmitToken := ValidationRequest.Token; // Note, multiple records can be created in CheckNumberAtGate having the same Token
    end;

    internal procedure CheckAdmitTokenForError(Token: Guid; ThrowError: Boolean; var ErrorMessage: Text) InvalidToken: Boolean
    var
        ValidationRequest: Record "NPR SGEntryLog";
        ApiError: Enum "NPR API Error Code";
    begin
        InvalidToken := true;

        ValidationRequest.SetCurrentKey(Token);
        ValidationRequest.SetFilter(Token, '=%1', Token);
        ValidationRequest.SetFilter(EntryStatus, '<>%1', ValidationRequest.EntryStatus::PERMITTED_BY_GATE);
        if (not ValidationRequest.FindSet()) then
            exit(not InvalidToken);

        InvalidToken := true;

        if (ValidationRequest.ApiErrorNumber <> 0) then begin
            ApiError := Enum::"NPR API Error Code".FromInteger(ValidationRequest.ApiErrorNumber);
            ErrorMessage := StrSubstNo('%1 %2', Format(ApiError, 0, 1), ValidationRequest.ApiErrorMessage);
        end;

        if (ValidationRequest.ApiErrorNumber = 0) then
            ErrorMessage := ValidationRequest.ApiErrorMessage;

        if (ErrorMessage = '') then
            ErrorMessage := StrSubstNo('The admit token is not valid: %1', ValidationRequest.EntryStatus);

        if (ThrowError) then
            Error(ErrorMessage);

        exit(InvalidToken);
    end;

    internal procedure CreateMemberGuestAdmissionToken(SourceValidationRequest: Record "NPR SGEntryLog"; MembershipGuest: Record "NPR MM Members. Admis. Setup"): Guid
    var
        MemberValidationRequest: Record "NPR SGEntryLog";
    begin
        MemberValidationRequest := SourceValidationRequest;
        MemberValidationRequest.EntryNo := 0;
        MemberValidationRequest.Token := CreateGuid();
        MemberValidationRequest.ExtraEntityTableId := Database::"NPR MM Members. Admis. Setup";
        MemberValidationRequest.ExtraEntityId := MembershipGuest.SystemId;
        MemberValidationRequest.EntryStatus := MemberValidationRequest.EntryStatus::PERMITTED_BY_GATE;
        MemberValidationRequest.AdmittedAt := 0DT;
        MemberValidationRequest.AdmittedReferenceNo := '';
        Clear(MemberValidationRequest.AdmittedReferenceId);
        MemberValidationRequest.ParentToken := SourceValidationRequest.Token;
        MemberValidationRequest.Insert();
        exit(MemberValidationRequest.Token);
    end;

    internal procedure Admit(Token: Guid; Quantity: Integer)
    var
        ValidationRequest: Record "NPR SGEntryLog";
        TicketId: Guid;
        ReasonMessage: Text;
    begin
        ValidationRequest.SetCurrentKey(Token);
        ValidationRequest.SetFilter(Token, '=%1', Token);
        ValidationRequest.SetFilter(EntryStatus, '=%1', ValidationRequest.EntryStatus::PERMITTED_BY_GATE);
        if (not ValidationRequest.FindSet()) then
            CheckAdmitTokenForError(Token, true, ReasonMessage);

        repeat
            if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::TICKET) then
                ValidateAdmitTicket(ValidationRequest, Quantity);

            if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::MEMBER_CARD) then begin
                if (not IsNullGuid(TicketId) and (ValidationRequest.ExtraEntityTableId = 0)) then begin
                    ValidationRequest.ExtraEntityId := TicketId;
                    ValidationRequest.ExtraEntityTableId := Database::"NPR TM Ticket";
                end;
                TicketId := ValidateAdmitMemberCard(ValidationRequest, Quantity);
            end;

            if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::WALLET) then
                ValidateAdmitWallet(ValidationRequest);

            if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::DOC_LX_CITY_CARD) then
                ValidateAdmitDocLXCityCard(ValidationRequest);

            if (ValidationRequest.ReferenceNumberType = ValidationRequest.ReferenceNumberType::TICKET_REQUEST) then
                ValidateAdmitTicket(ValidationRequest);

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
        Scanners: Record "NPR SG SpeedGate";
        PosUnit: Record "NPR POS Unit";
    begin
        Scanners.SetCurrentKey(ScannerId);
        Scanners.SetFilter(ScannerId, '=%1', ScannerId);
        if (not Scanners.FindFirst()) then begin
            Scanners.Init();
            PosUnit.SetLoadFields(Name);
            if (PosUnit.Get(ScannerId)) then
                Scanners.Description := PosUnit.Name
        end;

        EntryLog.Init();
        EntryLog.Token := Format(CreateGuid(), 0, 4);
        EntryLog.EntryStatus := EntryLog.EntryStatus::INITIALIZED;
        EntryLog.ReferenceNo := ReferenceNumber;
        EntryLog.AdmissionCode := AdmissionCode;
        EntryLog.ScannerId := ScannerId;
        EntryLog.ScannerDescription := Scanners.Description;
        EntryLog.SuggestedQuantity := 1;
        EntryLog.Insert();
        exit(EntryLog.EntryNo);
    end;

    internal procedure ValidateAdmitDocLXCityCard(var ValidationRequest: Record "NPR SGEntryLog"): Guid
    var
        DocLXCityCard: Codeunit "NPR DocLXCityCard";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        LogEntryNo: Integer;
        LogEntry: Record "NPR DocLXCityCardHistory";
        Ticket: Record "NPR TM Ticket";
        TicketId: Guid;
        CityCardNo: Code[20];
    begin
        if (IsNullGuid(ValidationRequest.EntityId)) then
            Error('The tryAdmit request was not able to validate the city card.');

        if (not LogEntry.GetBySystemId(ValidationRequest.EntityId)) then
            Error('The tryAdmit request was not able to validate the city card.');

        if (not (LogEntry.ValidationResultCode = '200')) then
            Error('The city card is not valid: %1', LogEntry.ValidationResultMessage);

        CityCardNo := CopyStr(ValidationRequest.ReferenceNo, 1, MaxStrLen(CityCardNo));
        DocLXCityCard.RedeemCityCard(CityCardNo, LogEntry.CityCode, LogEntry.LocationCode, LogEntryNo);
        LogEntry.GetBySystemId(ValidationRequest.EntityId);
        if (not (LogEntry.RedemptionResultCode = '200')) then
            Error('The city card could not be redeemed: %1', LogEntry.RedemptionResultMessage);

        DocLXCityCard.AcquireCoupon(CityCardNo, LogEntry.CityCode, LogEntry.LocationCode, ValidationRequest.ScannerId, LogEntryNo);

        LogEntry.Get(LogEntryNo);
        if (not DocLXCityCard.ExchangeCouponForTicket(LogEntry.CouponNo, LogEntryNo, TicketId)) then
            Error('The city card could not be exchanged for a ticket.');

        Ticket.GetBySystemId(TicketId);

        ValidationRequest.AdmissionCode := TicketManagement.GetDefaultAdmissionCode(Ticket."No.");
        ValidationRequest.ExtraEntityTableId := Database::"NPR TM Ticket";
        ValidationRequest.ExtraEntityId := Ticket.SystemId;
        ValidationRequest.Modify();

        exit(ValidateAdmitTicket(ValidationRequest));

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
    begin
        exit(ValidateAdmitTicket(ValidationRequest, 1));
    end;

    internal procedure ValidateAdmitTicket(var ValidationRequest: Record "NPR SGEntryLog"; Quantity: Integer): Guid
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Ticket: Record "NPR TM Ticket";
        ResponseMessage: Label 'Invalid Validation Request';
    begin
        case ValidationRequest.ReferenceNumberType of

            ValidationRequest.ReferenceNumberType::TICKET:
                if (not Ticket.GetBySystemId(ValidationRequest.EntityId)) then
                    Error(ResponseMessage);

            ValidationRequest.ReferenceNumberType::WALLET,
            ValidationRequest.ReferenceNumberType::DOC_LX_CITY_CARD,
            ValidationRequest.ReferenceNumberType::TICKET_REQUEST:
                if (not Ticket.GetBySystemId(ValidationRequest.ExtraEntityId)) then
                    Error(ResponseMessage);
            else
                Error('This is a programming error. The admit request contains an unhandled Type: %1', ValidationRequest.ReferenceNumberType);
        end;

        ValidationRequest.AdmittedReferenceNo := Ticket."External Ticket No.";
        ValidationRequest.AdmittedReferenceId := Ticket.SystemId;
        ValidationRequest.AdmittedQuantity := Quantity;

        if ((Quantity <> ValidationRequest.SuggestedQuantity) and (ValidationRequest.SuggestedQuantity > 1)) then
            TicketManagement.ChangeConfirmedTicketQuantity(Ticket."No.", ValidationRequest.AdmissionCode, Quantity);

        TicketManagement.ValidateTicketForArrival(Ticket, ValidationRequest.AdmissionCode, -1, TimeHelper.GetLocalTimeAtAdmission(ValidationRequest.AdmissionCode), ValidationRequest.ScannerId);

        ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::ADMITTED;
        ValidationRequest.AdmittedAt := CurrentDateTime();
        ValidationRequest.Modify();

        exit(Ticket.SystemId);
    end;


    local procedure GetTicketId(ExternalTicketNo: Text[100]): Guid
    var
        Ticket: Record "NPR TM Ticket";
    begin
        Ticket.SetCurrentKey("External Ticket No.");
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(ExternalTicketNo, 1, MaxStrLen(Ticket."External Ticket No.")));
        Ticket.SetLoadFields(SystemId);
        if (Ticket.FindFirst()) then
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
        NoTimeFramesError: Label 'Membership is not valid, it has no timeframes. Please contact the support team for assistance.';
        NotValidForTodayError: Label 'Membership is not valid for today, it is valid from %1 until %2.';
        GuestCardinalityError: Label 'The number of guests requested (%1) exceeds the maximum number of guests in setup (%2)';
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

        if (not MemberManagement.GetMembershipValidDate(MemberCard."Membership Entry No.", Today(), ValidFromDate, ValidUntilDate)) then begin
            if (ValidFromDate = 0D) and (ValidUntilDate = 0D) then
                Error(NoTimeFramesError);
            Error(NotValidForTodayError, ValidFromDate, ValidUntilDate);
        end;

        ResponseMessage := '';
        ValidationRequest.MemberCardLogEntryNo := MemberLimitationMgr.WS_CheckLimitMemberCardArrival(MemberCard."External Card No.", ValidationRequest.AdmissionCode, ValidationRequest.ScannerId, LogEntryNo, ResponseMessage, ResponseCode);
        ValidationRequest.Modify();
        if (ResponseCode <> 0) then
            Error(ResponseMessage);

        ValidationRequest.AdmittedQuantity := 1;
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
                            Error(GuestCardinalityError, Quantity, MembershipAdmissionSetup."Max Cardinality");

                    for TicketCount := 2 to Quantity do begin
                        ExtraGuestValidationRequest := ValidationRequest;
                        ExtraGuestValidationRequest.EntryNo := 0;
                        MemberTicketManager.MemberGuestFastCheckInNoPrint(ValidationRequest.ExtraEntityId, false, MemberCard."Membership Entry No.", MemberCard."Member Entry No.", ValidationRequest.AdmissionCode, '', 1, '', ExternalTicketNo);

                        ExtraGuestValidationRequest.EntryStatus := ValidationRequest.EntryStatus::ADMITTED;
                        ExtraGuestValidationRequest.AdmittedAt := CurrentDateTime;
                        ExtraGuestValidationRequest.AdmittedReferenceNo := ExternalTicketNo;
                        ExtraGuestValidationRequest.AdmittedReferenceId := GetTicketId(ExtraGuestValidationRequest.AdmittedReferenceNo);
                        ExtraGuestValidationRequest.ParentToken := ValidationRequest.Token;
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
                    TicketManagement.RegisterArrivalScanTicket("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO,
                        ExternalTicketNo,
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
        ValidationRequest.AdmittedReferenceId := GetTicketId(ValidationRequest.AdmittedReferenceNo);
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
        ReferenceNumberIdentified: Boolean;
        SuggestedQuantity: Integer;
    begin
        _ApiErrors := _ApiErrors::denied_by_speedgate;
        DetectedNumberType := _NumberType::NOT_WHITELISTED;
        ValidationRequest.Get(LogEntryNo);
        SuggestedQuantity := ValidationRequest.SuggestedQuantity;

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

        if (_EndOfSaleAdmitMode) then begin
            NumberPermitted := HandleEndOfSaleTryAdmitTicket(ValidationRequest.ReferenceNo, EntityId, AdmitToAdmissionCodes, ReferenceNumberIdentified, SuggestedQuantity);
            if (ReferenceNumberIdentified) then
                DetectedNumberType := _NumberType::TICKET;

            if (not NumberPermitted) then begin // No admit during end of sale.
                _ApiErrors := _ApiErrors::ticket_setup_prevents_admit_during_end_of_sale;
                ValidationRequest.ReferenceNumberType := "NPR SG ReferenceNumberType".FromInteger(DetectedNumberType);
                ValidationRequest.ApiErrorNumber := _ApiErrors.AsInteger();
                ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::DENIED_BY_GATE;
                ValidationRequest.Modify();
                exit;
            end;

            if (ReferenceNumberIdentified and NumberPermitted and (AdmitToAdmissionCodes.Count() = 0)) then begin
                // Per Unit Configuration - treat as regular ticket admission using the scanner id setup to select admission codes
                PermitTickets := true;
                NumberPermitted := false; // Reset to false to check for tickets again
            end;
        end;

        if (WhiteListProfileCode <> '') and (not NumberPermitted) then begin
            DetermineNumberType(WhiteListProfileCode, ValidationRequest.ReferenceNo, DetectedNumberType, ValidationModeStrict);
            case DetectedNumberType of
                _NumberType::TICKET:
                    if (PermitTickets) then
                        NumberPermitted := CheckForTicket(TicketProfileCode, ValidationRequest.ReferenceNo, ValidationRequest.AdmissionCode, EntityId, AdmitToAdmissionCodes, ProfileLineId, ReferenceNumberIdentified, SuggestedQuantity);

                _NumberType::MEMBER_CARD:
                    if (PermitMemberships) then
                        NumberPermitted := CheckForMemberCard(MemberCardProfileCode, ValidationRequest.ReferenceNo, ValidationRequest.AdmissionCode, EntityId, AdmitToAdmissionCodes, ProfileLineId, ReferenceNumberIdentified);

                _NumberType::WALLET:
                    if (PermitWallets) then
                        NumberPermitted := CheckForWallet(TicketProfileCode, MemberCardProfileCode, ValidationRequest, EntityId, AdmitToAdmissionCodes, ProfileLineId, ReferenceNumberIdentified, SuggestedQuantity);

                _NumberType::DOC_LX_CITY_CARD:
                    if (PermitCityCard) then
                        NumberPermitted := CheckForDocLXCityCard(CityCardProfileId, ValidationRequest.ReferenceNo, ValidationRequest.ScannerId, EntityId);

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
            NumberPermitted := CheckForTicket(TicketProfileCode, ValidationRequest.ReferenceNo, ValidationRequest.AdmissionCode, EntityId, AdmitToAdmissionCodes, ProfileLineId, ReferenceNumberIdentified, SuggestedQuantity);
            if (ReferenceNumberIdentified) then
                DetectedNumberType := _NumberType::TICKET;

            if (not NumberPermitted) then begin
                NumberPermitted := CheckForTicketRequest(TicketProfileCode, ValidationRequest, ReferenceNumberIdentified);
                if ((ReferenceNumberIdentified) and (NumberPermitted)) then
                    exit;
            end;
        end;

        if (PermitMemberships and not NumberPermitted) then begin
            NumberPermitted := CheckForMemberCard(MemberCardProfileCode, ValidationRequest.ReferenceNo, ValidationRequest.AdmissionCode, EntityId, AdmitToAdmissionCodes, ProfileLineId, ReferenceNumberIdentified);
            if (ReferenceNumberIdentified) then
                DetectedNumberType := _NumberType::MEMBER_CARD;
        end;

        if (PermitWallets and not NumberPermitted) then begin
            NumberPermitted := CheckForWallet(TicketProfileCode, MemberCardProfileCode, ValidationRequest, EntityId, AdmitToAdmissionCodes, ProfileLineId, ReferenceNumberIdentified, SuggestedQuantity);
            if (ReferenceNumberIdentified) then
                DetectedNumberType := _NumberType::WALLET;
        end;

        // When still not permitted, exit out with error
        ValidationRequest.ReferenceNumberType := "NPR SG ReferenceNumberType".FromInteger(DetectedNumberType);
        if (not NumberPermitted) then begin
            //_ApiErrors := _ApiErrors::denied_by_speedgate;
            ValidationRequest.ApiErrorNumber := _ApiErrors.AsInteger();
            ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::DENIED_BY_GATE;
            ValidationRequest.Modify();
            exit; // Error exit
        end;

        // **** Happy path ****
        ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::PERMITTED_BY_GATE;
        ValidationRequest.EntityId := EntityId;
        ValidationRequest.ProfileLineId := ProfileLineId;
        ValidationRequest.SuggestedQuantity := SuggestedQuantity;
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

    local procedure SetApiError(ApiError: Enum "NPR API Error Code"): Boolean
    begin
        _ApiErrors := ApiError;
        exit(false);
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

    local procedure CheckForDocLXCityCard(CityCardProfileId: Guid; Number: Text[100]; ScannerId: Code[10]; var EntityId: Guid): Boolean
    var
        DocLXCityCard: Codeunit "NPR DocLXCityCard";
        CityCardLocation: Record "NPR DocLXCityCardLocation";
        LogEntryNo: Integer;
        LogEntry: Record "NPR DocLXCityCardHistory";
        CityCardNo: Code[20];
    begin
        if (IsNullGuid(CityCardProfileId)) then
            exit(false);

        if (not CityCardLocation.GetBySystemId(CityCardProfileId)) then
            exit(false);

        CityCardNo := CopyStr(Number, 1, MaxStrLen(CityCardNo));
        DocLXCityCard.ValidateCityCard(CityCardNo, CityCardLocation.CityCode, CityCardLocation.Code, ScannerId, LogEntryNo);

        if (not LogEntry.Get(LogEntryNo)) then
            exit(false);

        EntityId := LogEntry.SystemId;

        // Requires the whitelist to precisely match the city card numbers
        if (not (LogEntry.ValidationResultCode = '200')) then
            exit(SetApiError(_ApiErrors::city_card_not_valid));

        exit(true);
    end;

    local procedure CheckForWallet(TicketProfileCode: Code[10]; MemberCardProfileCode: Code[10]; var ValidationRequest: Record "NPR SGEntryLog"; var EntityId: Guid; var AdmitToCodes: List of [Code[20]]; var ProfileLineId: Guid; var NumberIdentified: Boolean; SuggestedQuantity: Integer): Boolean
    var
        Number: Text[100];
        SuggestedAdmissionCode: Code[20];
        Wallet: Record "NPR AttractionWallet";
        WalletExternalReference: Record "NPR AttractionWalletExtRef";
        TicketIds, MemberCardIds : List of [Guid];
        MemberCardId, TicketId : Guid;
        MemberCard: Record "NPR MM Member Card";
        Ticket: Record "NPR TM Ticket";
        ReferenceNumberIsTicket, ReferenceNumberIsMemberCard : Boolean;
    begin
        Number := ValidationRequest.ReferenceNo;
        SuggestedAdmissionCode := ValidationRequest.AdmissionCode;

        WalletExternalReference.SetLoadFields(WalletEntryNo, BlockedAt, ExpiresAt);
        if (WalletExternalReference.Get(Number)) then begin
            if (WalletExternalReference.BlockedAt <> 0DT) then
                exit(SetApiError(_ApiErrors::wallet_expired));
            if (WalletExternalReference.ExpiresAt <> 0DT) and (WalletExternalReference.ExpiresAt < CurrentDateTime()) then
                exit(SetApiError(_ApiErrors::wallet_expired));
            Wallet.SetRange(EntryNo, WalletExternalReference.WalletEntryNo);
        end else begin
            Wallet.SetCurrentKey(ReferenceNumber);
            Wallet.SetFilter(ReferenceNumber, '=%1', CopyStr(UpperCase(Number), 1, MaxStrLen(Wallet.ReferenceNumber)));
        end;
        NumberIdentified := Wallet.FindFirst();

        if (not NumberIdentified) then
            exit(false);

        if (Wallet.ExpirationDate <> 0DT) and (Wallet.ExpirationDate < CurrentDateTime()) then
            exit(SetApiError(_ApiErrors::wallet_expired));

        GetWalletTickets(Wallet.EntryNo, TicketProfileCode, SuggestedAdmissionCode, TicketIds);
        GetWalletMemberCards(Wallet.EntryNo, MemberCardProfileCode, SuggestedAdmissionCode, MemberCardIds);

        if (TicketIds.Count() = 1) and (MemberCardIds.Count() = 0) then begin
            Ticket.GetBySystemId(TicketIds.Get(1));
            ValidationRequest.ExtraEntityId := TicketIds.Get(1);
            ValidationRequest.ExtraEntityTableId := Database::"NPR TM Ticket";
            CheckForTicket(TicketProfileCode, Ticket."External Ticket No.", SuggestedAdmissionCode, TicketId, AdmitToCodes, ProfileLineId, ReferenceNumberIsTicket, SuggestedQuantity);
        end;

        if (TicketIds.Count() = 0) and (MemberCardIds.Count() = 1) then begin
            MemberCard.GetBySystemId(MemberCardIds.Get(1));
            ValidationRequest.ExtraEntityId := MemberCardIds.Get(1);
            ValidationRequest.ExtraEntityTableId := Database::"NPR MM Member Card";
            CheckForMemberCard(MemberCardProfileCode, MemberCard."External Card No.", SuggestedAdmissionCode, MemberCardId, AdmitToCodes, ProfileLineId, ReferenceNumberIsMemberCard);
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
        ReferenceNumberIdentified: Boolean;
    begin
        WalletAssetLine.SetCurrentKey(TransactionId, Type);
        WalletAssetLine.SetFilter(TransactionId, '=%1', WalletAgent.GetWalletTransactionId(WalletEntryNo));
        WalletAssetLine.SetFilter(Type, '=%1', ENUM::"NPR WalletLineType"::Ticket);
        if (not WalletAssetLine.FindSet()) then
            exit(false);

        repeat
            Clear(AdmitToCodes);
            if (CheckForTicket(TicketProfileCode, WalletAssetLine.LineTypeReference, SuggestedAdmissionCode, TicketId, AdmitToCodes, ProfileLineId, ReferenceNumberIdentified)) then
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
        ReferenceNumberIdentified: Boolean;
    begin
        WalletAssetLine.SetCurrentKey(TransactionId, Type);
        WalletAssetLine.SetFilter(TransactionId, '=%1', WalletAgent.GetWalletTransactionId(WalletEntryNo));
        WalletAssetLine.SetFilter(Type, '=%1', ENUM::"NPR WalletLineType"::MEMBERSHIP);
        if (not WalletAssetLine.FindSet()) then
            exit(false);

        repeat
            Clear(AdmitToCodes);
            if (CheckForMemberCard(MemberCardProfileCode, WalletAssetLine.LineTypeReference, SuggestedAdmissionCode, MemberCardId, AdmitToCodes, ProfileLineId, ReferenceNumberIdentified)) then
                MemberCardIds.Add(WalletAssetLine.LineTypeSystemId);
        until (WalletAssetLine.Next() = 0);

        exit(true);
    end;

    internal procedure CheckTicket(ScannerId: Code[10]; TicketNo: Text[100]; AdmissionCode: Code[20]; var AdmitToCodes: List of [Code[20]]; var ResponseCode: Integer): Boolean
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
        ReferenceNumberIdentified: Boolean;
        SuggestedQuantity: Integer;
    begin
        if (not GetValidationProfilesForScanner(ScannerId, WhiteListProfileCode, TicketProfileCode, PermitTickets, MemberCardProfileCode, PermitMemberships, WalletProfileCode, PermitWallets, CityCardProfileId, PermitCityCard, ApiErrorNumber)) then begin
            ResponseCode := ApiErrorNumber;
            exit(false);
        end;

        if (_EndOfSaleAdmitMode) then begin
            if (not HandleEndOfSaleTryAdmitTicket(TicketNo, TicketId, AdmitToCodes, ReferenceNumberIdentified, SuggestedQuantity)) then begin
                ResponseCode := _ApiErrors.AsInteger();
                exit(false);
            end;

            if (AdmitToCodes.Count() > 0) then
                exit(true);
        end;

        if (not CheckForTicket(TicketProfileCode, TicketNo, AdmissionCode, TicketId, AdmitToCodes, ProfileLineId, ReferenceNumberIdentified)) then begin
            ResponseCode := _ApiErrors.AsInteger();
            exit(false);
        end;

        exit(true);
    end;

    local procedure CheckForTicketRequest(TicketProfileCode: Code[10]; ValidationRequest: Record "NPR SGEntryLog"; var NumberIdentified: Boolean): Boolean
    var
        TicketProfile: Record "NPR SG TicketProfile";
        TicketRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketId: Guid;
        AdmitToCodes: List of [Code[20]];
        TicketIds: List of [Guid];
        ProfileLineId: Guid;
        TicketNumberIdentified: Boolean;
        AdmissionCode, RequestedAdmissionCode : Code[20];
        FirstValidationRequestHandled: Boolean;
        SuggestedQuantity: Integer;
    begin
        NumberIdentified := false;
        SuggestedQuantity := ValidationRequest.SuggestedQuantity;

        if (TicketProfileCode = '') then
            exit(false);

        if (not TicketProfile.Get(TicketProfileCode)) then
            exit(false);

        if (not TicketProfile.PermitTicketRequestToken) then
            exit(false);

        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', CopyStr(UpperCase(ValidationRequest.ReferenceNo), 1, MaxStrLen(TicketRequest."Session Token ID")));
        NumberIdentified := not (TicketRequest.IsEmpty());

        if (not NumberIdentified) then
            exit(false);

        if (ValidationRequest.AdmissionCode <> '') then
            TicketRequest.SetFilter("Admission Code", '=%1', ValidationRequest.AdmissionCode);

        if (TicketRequest.IsEmpty()) then
            exit(SetApiError(_ApiErrors::ticket_not_valid_for_suggested_admission));

        FirstValidationRequestHandled := false;
        RequestedAdmissionCode := ValidationRequest.AdmissionCode;

        TicketRequest.Reset();
        TicketRequest.SetCurrentKey("Session Token ID");
        TicketRequest.SetFilter("Session Token ID", '=%1', CopyStr(UpperCase(ValidationRequest.ReferenceNo), 1, MaxStrLen(TicketRequest."Session Token ID")));
        TicketRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketRequest.FindSet();
        repeat
            Clear(TicketIds);
            Clear(AdmitToCodes);

            // Get all the tickets for the request
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketRequest."Entry No.");
            if (not Ticket.FindSet()) then
                exit(SetApiError(_ApiErrors::ticket_reservation_has_no_tickets));

            repeat
                TicketIds.Add(Ticket.SystemId);
            until (Ticket.Next() = 0);

            // all tickets are the same for the primary request line - check one and get list of admission codes 
            if (not IsTicketValidForAdmit(TicketProfileCode, Ticket."External Ticket No.", RequestedAdmissionCode, TicketId, AdmitToCodes, ProfileLineId, TicketNumberIdentified, SuggestedQuantity)) then
                exit(false);

            // Set the validation request template fields
            ValidationRequest.ExtraEntityTableId := Database::"NPR TM Ticket";
            ValidationRequest.ReferenceNumberType := ValidationRequest.ReferenceNumberType::TICKET_REQUEST;
            ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::PERMITTED_BY_GATE;
            ValidationRequest.EntityId := TicketRequest.SystemId;
            ValidationRequest.ProfileLineId := ProfileLineId;
            ValidationRequest.SuggestedQuantity := SuggestedQuantity;
            if (not FirstValidationRequestHandled) then begin
                // The initial validation request is already created for the first ticket and admission code
                // Update the existing validation request with the ticket id
                ValidationRequest.ExtraEntityId := TicketId;
                ValidationRequest.Modify();

                ManageValidationRequestForFirstTicket(ValidationRequest, AdmitToCodes);

                TicketIds.Remove(TicketId);
                FirstValidationRequestHandled := true;
            end;

            // create a validation request for each remaining ticket and admission code
            foreach TicketId in TicketIds do begin
                ValidationRequest.ExtraEntityId := TicketId;
                foreach AdmissionCode in AdmitToCodes do begin
                    ValidationRequest.ExtraEntityId := TicketId;
                    ValidationRequest.AdmissionCode := AdmissionCode;
                    ValidationRequest.EntryNo := 0;
                    ValidationRequest.Insert();
                end;
            end;
        until (TicketRequest.Next() = 0);

        exit(true);
    end;

    local procedure ManageValidationRequestForFirstTicket(ValidationRequest: Record "NPR SGEntryLog"; var AdmitToCodes: List of [Code[20]])
    var
        AdmissionCode, TempAdmissionCode : Code[20];
    begin
        if (AdmitToCodes.Contains(ValidationRequest.AdmissionCode)) then begin
            AdmitToCodes.Remove(ValidationRequest.AdmissionCode);
            TempAdmissionCode := ValidationRequest.AdmissionCode;
        end;

        if (ValidationRequest.AdmissionCode = '') and (AdmitToCodes.Count > 0) then begin
            ValidationRequest.AdmissionCode := AdmitToCodes.Get(1);
            ValidationRequest.Modify();
            AdmitToCodes.RemoveAt(1);
            TempAdmissionCode := ValidationRequest.AdmissionCode;
        end;

        foreach AdmissionCode in AdmitToCodes do begin
            ValidationRequest.EntryNo := 0;
            ValidationRequest.AdmissionCode := AdmissionCode;
            ValidationRequest.Insert();
        end;

        if (TempAdmissionCode <> '') then
            AdmitToCodes.Add(TempAdmissionCode);

    end;

    internal procedure CheckForTicket(TicketProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var TicketId: Guid; var AdmitToCodes: List of [Code[20]]; var ProfileLineId: Guid; var NumberIdentified: Boolean): Boolean
    var
        SuggestedQuantity: Integer;
    begin
        exit(CheckForTicket(TicketProfileCode, Number, SuggestedAdmissionCode, TicketId, AdmitToCodes, ProfileLineId, NumberIdentified, SuggestedQuantity));
    end;

    local procedure CheckForTicket(TicketProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var TicketId: Guid; var AdmitToCodes: List of [Code[20]]; var ProfileLineId: Guid; var NumberIdentified: Boolean; var SuggestedQuantity: Integer): Boolean
    var
        TicketProfile: Record "NPR SG TicketProfile";
        TicketProfileLine: Record "NPR SG TicketProfileLine";
    begin
        NumberIdentified := false;

        if (TicketProfileCode = '') then
            exit(IsTicketValidForAdmit(TicketProfileCode, Number, SuggestedAdmissionCode, TicketId, AdmitToCodes, ProfileLineId, NumberIdentified, SuggestedQuantity));

        if (not TicketProfile.Get(TicketProfileCode)) then
            exit(false); // Ticket profile is invalid - all tickets are denied

        TicketProfileLine.SetFilter(Code, '=%1', TicketProfileCode);
        if (TicketProfile.ValidationMode = TicketProfile.ValidationMode::STRICT) then
            if (TicketProfileLine.IsEmpty()) then
                exit(false); // Ticket profile is empty - all tickets are denied

        exit(IsTicketValidForAdmit(TicketProfileCode, Number, SuggestedAdmissionCode, TicketId, AdmitToCodes, ProfileLineId, NumberIdentified, SuggestedQuantity));
    end;

    local procedure HandleEndOfSaleTryAdmitTicket(Number: Text[100]; var TicketId: Guid; var AdmitToCodes: List of [Code[20]]; var NumberIdentified: Boolean; var SuggestedQuantity: Integer): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        AttemptAdmission: Boolean;
        PerUnit: Boolean;
    begin
        Ticket.SetCurrentKey("External Ticket No.");
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(UpperCase(Number), 1, MaxStrLen(Ticket."External Ticket No.")));
        NumberIdentified := Ticket.FindFirst();

        if (not NumberIdentified) then
            exit(false);

        if (Ticket.Blocked) then
            exit(SetApiError(_ApiErrors::ticket_blocked));

        TicketId := Ticket.SystemId;
        SuggestedQuantity := 1;
        TicketType.Get(Ticket."Ticket Type Code");

        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_TYPE) then begin
            if (TicketType."Activation Method" = "NPR TM ActivationMethod_Type"::POS_DEFAULT) then
                AdmitToCodes.Add(TicketManagement.GetDefaultAdmissionCode(Ticket."No."));

            if (TicketType."Activation Method" = "NPR TM ActivationMethod_Type"::POS_ALL) then begin
                TicketBom.SetCurrentKey("Item No.");
                TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
                TicketBom.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
                TicketBom.FindSet();
                repeat
                    if (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::REQUIRED) then
                        AdmitToCodes.Add(TicketBom."Admission Code");
                until (TicketBom.Next() = 0);
            end;

            exit(AdmitToCodes.Count() > 0); // This will handle the unlisted options as well
        end;

        if (TicketType."Ticket Configuration Source" = TicketType."Ticket Configuration Source"::TICKET_BOM) then begin
            TicketBom.SetCurrentKey("Item No.");
            TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
            TicketBom.SetFilter("Variant Code", '=%1', Ticket."Variant Code");
            TicketBom.FindSet();
            repeat
                AttemptAdmission := (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::REQUIRED);
                if (AttemptAdmission) then
                    case TicketBom."Activation Method" of
                        "NPR TM ActivationMethod_Bom"::POS:
                            AdmitToCodes.Add(TicketBom."Admission Code");
                        "NPR TM ActivationMethod_Bom"::ALWAYS:
                            AdmitToCodes.Add(TicketBom."Admission Code");
                        "NPR TM ActivationMethod_Bom"::PER_UNIT:
                            PerUnit := true; // Fallback to check the admission codes specified for the scanner station (like regular admission)
                        "NPR TM ActivationMethod_Bom"::SCAN:
                            ; // No action needed, we are in sales mode
                        "NPR TM ActivationMethod_Bom"::NA:
                            ; // Not applicable, no action needed
                        else
                            Error('This is a programming error. Unhandled activation method for end of sale ticket admission: Speed Gate -> Ticket BOM -> Activation Method %1', TicketBom."Activation Method");
                    end;
            until (TicketBom.Next() = 0);

            if (AdmitToCodes.Count() = 0) and (not PerUnit) then
                exit(false); // Ticket not intended for admission on sales

            exit(true);
        end;

        exit(false);
    end;

    local procedure IsTicketValidForAdmit(TicketProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var TicketId: Guid; var AdmitToCodes: List of [Code[20]]; var ProfileLineId: Guid; var NumberIdentified: Boolean; var SuggestedQuantity: Integer): Boolean
    var
        TicketProfile: Record "NPR SG TicketProfile";
        TicketProfileLine: Record "NPR SG TicketProfileLine";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        AdmissionCode: Code[20];
        RejectedAdmitToCodes: List of [Code[20]];

        AdmissionLocalTime: DateTime;
        LocalTime: Time;
        LocalDate: Date;
        TimeHelper: Codeunit "NPR TM TimeHelper";
        IsRuleValid: Boolean;
    begin
        Ticket.SetCurrentKey("External Ticket No.");
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(UpperCase(Number), 1, MaxStrLen(Ticket."External Ticket No.")));
        NumberIdentified := Ticket.FindFirst();

        if (not NumberIdentified) then
            exit(false);

        if (Ticket.Blocked) then
            exit(SetApiError(_ApiErrors::ticket_blocked));

        TicketBom.SetFilter("Item No.", '=%1', Ticket."Item No.");
        if (SuggestedAdmissionCode <> '') then
            TicketBom.SetFilter("Admission Code", '=%1', SuggestedAdmissionCode);

        if (not TicketBom.FindSet()) then
            exit(SetApiError(_ApiErrors::ticket_not_valid_for_suggested_admission));

        if (not TicketType.Get(Ticket."Ticket Type Code")) then
            TicketType.Init();

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
                    IsRuleValid := true; // Assume working hours
                    if (TicketProfileLine.CalendarCode <> '') then
                        IsRuleValid := not (CheckAdmissionIsNonWorking(TicketBom."Admission Code", TicketProfileLine.CalendarCode, LocalDate));

                    if (TicketProfileLine.PermitFromTime <> 0T) and (TicketProfileLine.PermitUntilTime <> 0T) then
                        IsRuleValid := IsRuleValid and (LocalTime >= TicketProfileLine.PermitFromTime) and (LocalTime <= TicketProfileLine.PermitUntilTime);

                    if (IsRuleValid) then begin
                        if (not AdmitToCodes.Contains(TicketBom."Admission Code")) then
                            AdmitToCodes.Add(TicketBom."Admission Code");
                        ProfileLineId := TicketProfileLine.SystemId;
                    end;
                until (TicketProfileLine.Next() = 0);

            TicketAccessEntry.SetCurrentKey("Ticket No.", "Admission Code");
            TicketAccessEntry.SetLoadFields(Quantity, Status);
            TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
            TicketAccessEntry.SetFilter("Admission Code", '=%1', TicketBom."Admission Code");
            TicketAccessEntry.FindFirst();

            if (TicketAccessEntry.Status = TicketAccessEntry.Status::BLOCKED) then
                exit(SetApiError(_ApiErrors::ticket_blocked));

            if (TicketType."Admission Registration" = TicketType."Admission Registration"::GROUP) then
                SuggestedQuantity := TicketAccessEntry.Quantity;

        until (TicketBom.Next() = 0);

        if (AdmitToCodes.Count = 0) then begin
            if (TicketProfileCode = '') then begin
                TicketProfile.ValidationMode := TicketProfile.ValidationMode::FLEXIBLE;
            end else
                if (not TicketProfile.Get(TicketProfileCode)) then begin
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
                exit(SetApiError(_ApiErrors::ticket_not_allowed));
        end;

        foreach AdmissionCode in AdmitToCodes do begin
            AdmissionLocalTime := TimeHelper.GetLocalTimeAtAdmission(TicketBom."Admission Code");
            LocalTime := DT2Time(AdmissionLocalTime);
            LocalDate := DT2Date(AdmissionLocalTime);

            TicketProfileLine.SetFilter(Code, '=%1', TicketProfileCode);
            TicketProfileLine.SetFilter(ItemNo, '=%1', Ticket."Item No.");
            TicketProfileLine.SetFilter(RuleType, '=%1', TicketProfileLine.RuleType::REJECT);
            TicketProfileLine.SetFilter(AdmissionCode, '=%1', AdmissionCode);
            if (TicketProfileLine.IsEmpty()) then
                TicketProfileLine.SetFilter(AdmissionCode, '=%1', '');

            if (TicketProfileLine.FindFirst()) then begin
                IsRuleValid := true;
                if (TicketProfileLine.CalendarCode <> '') then
                    IsRuleValid := not (CheckAdmissionIsNonWorking(TicketBom."Admission Code", TicketProfileLine.CalendarCode, LocalDate));

                if (TicketProfileLine.PermitFromTime <> 0T) and (TicketProfileLine.PermitUntilTime <> 0T) then
                    IsRuleValid := IsRuleValid and (LocalTime >= TicketProfileLine.PermitFromTime) and (LocalTime <= TicketProfileLine.PermitUntilTime);

                if (IsRuleValid) then
                    RejectedAdmitToCodes.Add(AdmissionCode);
            end;
        end;

        foreach AdmissionCode in RejectedAdmitToCodes do
            if (AdmitToCodes.Contains(AdmissionCode)) then
                AdmitToCodes.Remove(AdmissionCode);

        if (AdmitToCodes.Count = 0) then
            exit(SetApiError(_ApiErrors::ticket_is_rejected_by_profile));

        TicketId := Ticket.SystemId;
        exit(true);
    end;

    local procedure CheckForMemberCard(MemberCardProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var MemberCardId: Guid; var AdmitToCodes: List of [Code[20]]; var ProfileLineId: Guid; var NumberIdentified: Boolean): Boolean
    var
        MemberCardProfile: Record "NPR SG MemberCardProfile";
        MemberCardProfileLine: Record "NPR SG MemberCardProfileLine";
    begin
        NumberIdentified := false;

        if (MemberCardProfileCode = '') then
            exit(IsMemberCardValidForAdmit(MemberCardProfileCode, Number, SuggestedAdmissionCode, MemberCardId, AdmitToCodes, ProfileLineId, NumberIdentified));

        if (not MemberCardProfile.Get(MemberCardProfileCode)) then
            exit(false); // MemberCard profile is invalid - all cards are denied

        MemberCardProfileLine.SetFilter(Code, '=%1', MemberCardProfileCode);
        if (MemberCardProfile.ValidationMode = MemberCardProfile.ValidationMode::STRICT) then
            if (MemberCardProfileLine.IsEmpty()) then
                exit(false); // MemberCard profile is empty - all cards are denied

        exit(IsMemberCardValidForAdmit(MemberCardProfileCode, Number, SuggestedAdmissionCode, MemberCardId, AdmitToCodes, ProfileLineId, NumberIdentified));
    end;

    local procedure IsMemberCardValidForAdmit(MemberCardProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var MemberCardId: Guid; var AdmitToCodes: List of [Code[20]]; var ProfileLineId: Guid; var NumberIdentified: Boolean): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
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
        NumberIdentified := MemberCard.FindFirst();

        if (not NumberIdentified) then
            exit(false);

        if (not Membership.Get(MemberCard."Membership Entry No.")) then
            exit(false);

        if (not Member.Get(MemberCard."Member Entry No.")) then
            exit(false);

        if (MemberCard.Blocked) then
            exit(SetApiError(_ApiErrors::member_card_blocked));

        if (Membership.Blocked) then
            exit(SetApiError(_ApiErrors::membership_blocked));

        if Member.Blocked then
            exit(SetApiError(_ApiErrors::member_blocked));

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit(SetApiError(_ApiErrors::membership_setup_missing));

        if (MembershipSetup."Ticket Item Barcode" = '') then
            exit(SetApiError(_ApiErrors::membership_setup_missing_ticket_item));

        if (MembershipSetup."Card Expire Date Calculation" <> MembershipSetup."Card Expire Date Calculation"::NA) then
            if (MemberCard."Valid Until" < Today()) then
                exit(SetApiError(_ApiErrors::member_card_expired));

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
                exit(SetApiError(_ApiErrors::member_card_not_allowed));

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
                        if (TicketBom.Get(MembershipSetup."Ticket Item Barcode", '', MemberCardProfileLine.AdmissionCode)) then
                            if (not AdmitToCodes.Contains(MemberCardProfileLine.AdmissionCode)) then
                                AdmitToCodes.Add(MemberCardProfileLine.AdmissionCode);

                    ProfileLineId := MemberCardProfileLine.SystemId;
                end;

            until (MemberCardProfileLine.Next() = 0);
        end;

        if (AdmitToCodes.Count = 0) and (SuggestedAdmissionCode = '') then begin
            if (MemberCardProfileCode = '') then begin
                MemberCardProfile.ValidationMode := MemberCardProfile.ValidationMode::FLEXIBLE;
            end else
                if (not MemberCardProfile.Get(MemberCardProfileCode)) then begin
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
                exit(SetApiError(_ApiErrors::member_card_not_allowed));
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
        POSUnit: Record "NPR POS Unit";
        TicketProfile: Record "NPR TM POS Ticket Profile";
    begin
        WhiteListProfileCode := '';
        TicketProfileCode := '';
        AllowTickets := true;
        MemberCardProfileCode := '';
        AllowMemberships := true;
        WalletProfileCode := '';
        AllowWallets := true;
        AllowCityCards := false;

        if (_EndOfSaleAdmitMode) then begin
            POSUnit.SetLoadFields("No.", "POS Ticket Profile");
            if (not POSUnit.Get(CopyStr(ScannerId, 1, MaxStrLen(POSUnit."No.")))) then
                exit(false);

            if (TicketProfile.Get(POSUnit."POS Ticket Profile")) then
                if (SpeedGate.Get(TicketProfile.ScannerIdForUnitAdmitEoSId)) then
                    ScannerId := SpeedGate.ScannerId;
        end;

        if (not SpeedGateDefault.Get()) then
            exit(true);

        WhiteListProfileCode := SpeedGateDefault.AllowedNumbersList;
        TicketProfileCode := SpeedGateDefault.DefaultTicketProfileCode;
        AllowTickets := SpeedGateDefault.PermitTickets;

        MemberCardProfileCode := SpeedGateDefault.DefaultMemberCardProfileCode;
        AllowMemberships := SpeedGateDefault.PermitMemberCards;

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