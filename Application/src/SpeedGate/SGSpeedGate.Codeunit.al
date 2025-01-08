codeunit 6185130 "NPR SG SpeedGate"
{
    Access = Internal;

    var
        _NumberType: Option REJECTED,NOT_WHITELISTED,TICKET,MEMBER_CARD,WALLET,DOC_LX_CITY_CARD;
        _ApiErrors: Enum "NPR API Error Code";

    internal procedure CreateInitialEntry(ReferenceNumber: Text[100]; AdmissionCode: Code[20]; ScannerId: Code[10]) EntryNo: Integer
    var
        EntryLog: Record "NPR SGEntryLog";
    begin
        EntryLog.Init();
        EntryLog.EntryStatus := EntryLog.EntryStatus::INITIALIZED;
        EntryLog.ReferenceNo := ReferenceNumber;
        EntryLog.AdmissionCode := AdmissionCode;
        EntryLog.ScannerId := ScannerId;
        EntryLog.Insert();
        exit(EntryLog.EntryNo);
    end;

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
                        NumberPermitted := CheckForTicket(TicketProfileCode, ValidationRequest.ReferenceNo, ValidationRequest.AdmissionCode, EntityId, AdmitToAdmissionCodes);
                _NumberType::MEMBER_CARD:
                    if (PermitMemberships) then
                        NumberPermitted := CheckForMemberCard(MemberCardProfileCode, ValidationRequest.ReferenceNo, ValidationRequest.AdmissionCode, EntityId, AdmitToAdmissionCodes);
                _NumberType::WALLET:
                    if (PermitWallets) then
                        NumberPermitted := false; // not yet implemented
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
            NumberPermitted := CheckForTicket(TicketProfileCode, ValidationRequest.ReferenceNo, ValidationRequest.AdmissionCode, EntityId, AdmitToAdmissionCodes);
            if (NumberPermitted) then
                DetectedNumberType := _NumberType::TICKET;
        end;

        if (PermitMemberships and not NumberPermitted) then begin
            NumberPermitted := CheckForMemberCard(MemberCardProfileCode, ValidationRequest.ReferenceNo, ValidationRequest.AdmissionCode, EntityId, AdmitToAdmissionCodes);
            if (NumberPermitted) then
                DetectedNumberType := _NumberType::MEMBER_CARD;
        end;

        if (PermitWallets and not NumberPermitted) then begin
            NumberPermitted := false; // not yet implemented
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
        ValidationRequest.Token := Format(CreateGuid(), 0, 4);
        ValidationRequest.EntryStatus := ValidationRequest.EntryStatus::PERMITTED_BY_GATE;
        ValidationRequest.EntityId := EntityId;
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

    internal procedure ValidateAdmitToken(Token: Guid): Boolean
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

    local procedure CheckForTicket(TicketProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var TicketId: Guid; var AdmitToCodes: List of [Code[20]]): Boolean
    var
        TicketProfile: Record "NPR SG TicketProfile";
        TicketProfileLine: Record "NPR SG TicketProfileLine";
    begin
        if (TicketProfileCode = '') then
            exit(IsTicket(TicketProfileCode, Number, SuggestedAdmissionCode, TicketId, AdmitToCodes));

        if (not TicketProfile.Get(TicketProfileCode)) then
            exit(false); // Ticket profile is invalid - all tickets are denied

        TicketProfileLine.SetFilter(Code, '=%1', TicketProfileCode);
        if (TicketProfile.ValidationMode = TicketProfile.ValidationMode::STRICT) then
            if (TicketProfileLine.IsEmpty()) then
                exit(false); // Ticket profile is empty - all tickets are denied

        exit(IsTicket(TicketProfileCode, Number, SuggestedAdmissionCode, TicketId, AdmitToCodes));
    end;

    local procedure IsTicket(TicketProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var TicketId: Guid; var AdmitToCodes: List of [Code[20]]): Boolean
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

                    if (IsPermittedAdmission) then
                        if (not AdmitToCodes.Contains(TicketBom."Admission Code")) then
                            AdmitToCodes.Add(TicketBom."Admission Code");
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

    local procedure CheckForMemberCard(MemberCardProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var MemberCardId: Guid; var AdmitToCodes: List of [Code[20]]): Boolean
    var
        MemberCardProfile: Record "NPR SG MemberCardProfile";
        MemberCardProfileLine: Record "NPR SG MemberCardProfileLine";
    begin
        if (MemberCardProfileCode = '') then
            exit(IsMemberCard(MemberCardProfileCode, Number, SuggestedAdmissionCode, MemberCardId, AdmitToCodes));

        if (not MemberCardProfile.Get(MemberCardProfileCode)) then
            exit(false); // MemberCard profile is invalid - all cards are denied

        MemberCardProfileLine.SetFilter(Code, '=%1', MemberCardProfileCode);
        if (MemberCardProfile.ValidationMode = MemberCardProfile.ValidationMode::STRICT) then
            if (MemberCardProfileLine.IsEmpty()) then
                exit(false); // MemberCard profile is empty - all cards are denied

        exit(IsMemberCard(MemberCardProfileCode, Number, SuggestedAdmissionCode, MemberCardId, AdmitToCodes));
    end;

    local procedure IsMemberCard(MemberCardProfileCode: Code[10]; Number: Text[100]; SuggestedAdmissionCode: Code[20]; var MemberCardId: Guid; var AdmitToCodes: List of [Code[20]]): Boolean
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
        ProfileLineId: Guid;
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
            MemberCardProfileLine.SetFilter(AdmissionCode, '=%1|=%2', '', SuggestedAdmissionCode);
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
                            AdmitToCodes.Add(TicketBom."Admission Code");
                    end;

                    if (MemberCardProfileLine.AdmissionCode <> '') then
                        if (not AdmitToCodes.Contains(MemberCardProfileLine.AdmissionCode)) then
                            AdmitToCodes.Add(MemberCardProfileLine.AdmissionCode);
                end;
                ProfileLineId := MemberCardProfileLine.SystemId;

            until (MemberCardProfileLine.Next() = 0) or (IsPermitted = true);
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
        //WalletProfile := SpeedGate.WalletProfileCode;
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


}