﻿codeunit 6060144 "NPR MM Member Lim. Mgr."
{
    Access = Internal;

    trigger OnRun()
    begin
    end;

    var
        ConstraintText: Text;
        USER_CONFIRM_MESSAGE: Label '%1\\Do you want to allow action anyway?';

    procedure LogMemberCardArrival(ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; ResponseMessage: Text; ResponseCode: Integer): Integer
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        LogEntryNo: Integer;
    begin

        if (MemberCard.Get(MembershipManagement.GetCardEntryNoFromExtCardNo(ExternalMemberCardNo))) then begin
            if (not Membership.Get(MemberCard."Membership Entry No.")) then
                Clear(Membership);
            if (not Member.Get(MemberCard."Member Entry No.")) then
                Clear(Member);
            ExternalMemberCardNo := MemberCard."External Card No.";
        end;

        InternalLogArrival(Membership."External Membership No.", Member."External Member No.", ExternalMemberCardNo, AdmissionCode, ScannerStationId, LogEntryNo, ResponseMessage, ResponseCode, 0);

        exit(ResponseCode);
    end;

    procedure WS_CheckLimitMemberCardArrival(ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ReUseLogEntryNo: Integer; var ResponseMessage: Text; var ResponseCode: Integer) LogEntryNo: Integer
    begin

        CheckLimitMemberCardArrival(1, ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, ResponseMessage, ResponseCode);
        exit(ReUseLogEntryNo);
    end;

    procedure POS_CheckLimitMemberCardArrival(ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ReUseLogEntryNo: Integer; var ResponseMessage: Text; var ResponseCode: Integer) LogEntryNo: Integer
    begin
        CheckLimitMemberCardArrival(0, ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, ResponseMessage, ResponseCode);
        exit(ReUseLogEntryNo);
    end;

    procedure UpdateLogEntry(EntryNo: Integer; MessageCode: Integer; MessageText: Text)
    var
        MemberArrivalLogEntry: Record "NPR MM Member Arr. Log Entry";
    begin
        if (not MemberArrivalLogEntry.Get(EntryNo)) then
            exit;

        MemberArrivalLogEntry."Response Code" := MessageCode;
        MemberArrivalLogEntry."Response Message" := CopyStr(MessageText, 1, MaxStrLen(MemberArrivalLogEntry."Response Message"));
        if (MessageCode = 0) then
            MemberArrivalLogEntry."Response Type" := MemberArrivalLogEntry."Response Type"::SUCCESS else
            MemberArrivalLogEntry."Response Type" := MemberArrivalLogEntry."Response Type"::ACCESS_DENIED;

        MemberArrivalLogEntry.Modify();
    end;

    local procedure InternalLogArrival(ExternalMemberShipNo: Code[20]; ExternalMemberNo: Code[20]; ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ReUseLogEntryNo: Integer; ResponseMessage: Text; ResponseCode: Integer; ResponseRuleEntry: Integer)
    var
        MemberArrivalLogEntry: Record "NPR MM Member Arr. Log Entry";
        DoReuseLogEntry: Boolean;
        TimeHelper: Codeunit "NPR TM TimeHelper";
    begin

        DoReuseLogEntry := (ReUseLogEntryNo > 0);
        if (DoReuseLogEntry) then DoReuseLogEntry := MemberArrivalLogEntry.Get(ReUseLogEntryNo);
        if (DoReuseLogEntry) then DoReuseLogEntry := (MemberArrivalLogEntry."External Card No." = ExternalMemberCardNo);
        if (DoReuseLogEntry) then MemberArrivalLogEntry.Init();

        if (not DoReuseLogEntry) then begin
            MemberArrivalLogEntry."Entry No." := 0;
            MemberArrivalLogEntry.Init();
            MemberArrivalLogEntry.Insert();
        end;

        MemberArrivalLogEntry."Event Type" := MemberArrivalLogEntry."Event Type"::ARRIVAL;
        MemberArrivalLogEntry."Created At" := CurrentDateTime();
        MemberArrivalLogEntry."Local Date" := DT2Date(TimeHelper.GetLocalTimeAtAdmission(AdmissionCode));
        MemberArrivalLogEntry."Local Time" := DT2Time(TimeHelper.GetLocalTimeAtAdmission(AdmissionCode)); // Time() from web client and web service are different

        MemberArrivalLogEntry."External Membership No." := ExternalMemberShipNo;
        MemberArrivalLogEntry."External Member No." := ExternalMemberNo;
        MemberArrivalLogEntry."External Card No." := ExternalMemberCardNo;
        MemberArrivalLogEntry."Scanner Station Id" := ScannerStationId;
        MemberArrivalLogEntry."Admission Code" := AdmissionCode;

        MemberArrivalLogEntry."Temporary Card" := IsTemporaryCard(ExternalMemberCardNo);

        MemberArrivalLogEntry."Response Message" := CopyStr(ResponseMessage, 1, MaxStrLen(MemberArrivalLogEntry."Response Message"));

        MemberArrivalLogEntry."Response Code" := ResponseCode;
        if (ResponseCode = 0) then begin
            MemberArrivalLogEntry."Response Type" := MemberArrivalLogEntry."Response Type"::SUCCESS
        end else begin
            if (ResponseRuleEntry = 0) then
                MemberArrivalLogEntry."Response Type" := MemberArrivalLogEntry."Response Type"::VALIDATION_FAILURE;
            if (ResponseRuleEntry <> 0) then
                MemberArrivalLogEntry."Response Type" := MemberArrivalLogEntry."Response Type"::ACCESS_DENIED
        end;

        MemberArrivalLogEntry."Response Rule Entry No." := ResponseRuleEntry;

        //MemberArrivalLogEntry.Insert ();

        MemberArrivalLogEntry.Modify();
        ReUseLogEntryNo := MemberArrivalLogEntry."Entry No.";

    end;

    local procedure CheckLimitMemberCardArrival(ClientType: Option POS,WS; ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ReUseLogEntryNo: Integer; var ResponseMessage: Text; var ResponseCode: Integer) RuleNo: Integer
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        NewResponseMessage: Text;
        NewResponseCode: Integer;
        MembershipNotFoundLbl: Label 'Membership not found.';
    begin

        // We are logging an external ResponseMessage. 
        if (ResponseCode <> 0) then begin
            if (MemberCard.Get(MembershipManagement.GetCardEntryNoFromExtCardNo(ExternalMemberCardNo))) then
                InternalLogArrival(Membership."External Membership No.", Member."External Member No.", ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, ResponseMessage, ResponseCode, 0);
            exit;
        end;

        NewResponseCode := 0;
        if (MemberCard.Get(MembershipManagement.GetCardEntryNoFromExtCardNo(ExternalMemberCardNo))) then begin
            if (not Member.Get(MemberCard."Member Entry No.")) then begin
                NewResponseCode := -9998;
                MembershipManagement.ValidateGetMember(MemberCard."Member Entry No.", MemberCard."Membership Entry No.", NewResponseMessage);
                Clear(Member);
            end;

            if (not Membership.Get(MemberCard."Membership Entry No.")) then begin
                NewResponseCode := -9999;
                Clear(Membership);
                NewResponseMessage := MembershipNotFoundLbl;
            end;
            ExternalMemberCardNo := MemberCard."External Card No.";

            if (NewResponseCode = 0) then begin
                if (MembershipManagement.ValidateGetMember(MemberCard."Member Entry No.", MemberCard."Membership Entry No.", NewResponseMessage) = 0) then
                    NewResponseCode := -9898;
            end;

        end else begin
            exit;
        end;

        // We are logging internal problem. 
        if (NewResponseCode <> 0) then begin
            InternalLogArrival(Membership."External Membership No.", Member."External Member No.", ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, NewResponseMessage, NewResponseCode, 0);
            exit;
        end;

        RuleNo := CheckAndLogArrival(ClientType, Membership."Membership Code", Membership."External Membership No.", Member."External Member No.", ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, ResponseMessage, ResponseCode);
    end;



    local procedure CheckAndLogArrival(ClientType: Option POS,WS; MembershipCode: Code[20]; ExternalMemberShipNo: Code[20]; ExternalMemberNo: Code[20]; ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ReUseLogEntryNo: Integer; var ResponseMessage: Text; var ResponseCode: Integer) RuleNo: Integer
    var
        MembershipLimitationSetup: Record "NPR MM Membership Lim. Setup";
        NewResponseMessage: Text;
        NewResponseCode: Integer;
    begin

        // Get first rule that is violated
        RuleNo := CheckAllLimitations(ClientType, MembershipCode, ExternalMemberShipNo, ExternalMemberNo, ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, NewResponseMessage, NewResponseCode);

        // rollback our transaction if needed
        if (RuleNo <> 0) then begin
            MembershipLimitationSetup.Get(RuleNo);

            if (ClientType = ClientType::POS) then begin
                case MembershipLimitationSetup."POS Response Action" of
                    MembershipLimitationSetup."POS Response Action"::USER_ERROR:
                        ; // When a response code is returned, invoker must decide how to handle the error

                    MembershipLimitationSetup."POS Response Action"::USER_CONFIRM:
                        if (Confirm(USER_CONFIRM_MESSAGE, true, NewResponseMessage)) then begin
                            RuleNo := 0; // User confirmed that no rule was violated
                            ResponseCode := 0;
                            ResponseMessage := '';
                        end;

                    MembershipLimitationSetup."POS Response Action"::USER_MESSAGE:
                        begin
                            RuleNo := 0;
                            ResponseCode := 0;
                            ResponseMessage := '';
                            Message(NewResponseMessage);
                        end;
                end;
            end;

        end;

        if (RuleNo <> 0) then begin
            ResponseCode := NewResponseCode;
            ResponseMessage := NewResponseMessage;
        end;

        InternalLogArrival(ExternalMemberShipNo, ExternalMemberNo, ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, ResponseMessage, ResponseCode, RuleNo);

        exit(RuleNo);
    end;

    local procedure CheckAllLimitations(ClientType: Option POS,WS; MembershipCode: Code[20]; ExternalMemberShipNo: Code[20]; ExternalMemberNo: Code[20]; ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; IgnoreLogEntryNo: Integer; var ResponseMessage: Text; var ResponseCode: Integer) RuleNo: Integer
    var
        MembershipLimitationSetup: Record "NPR MM Membership Lim. Setup";
    begin

        if (IsTemporaryCard(ExternalMemberCardNo)) then begin
            RuleNo := CheckLimitations(ClientType, MembershipCode, MembershipLimitationSetup."Constraint Source"::TEMP_MEMBERCARD,
                                        ExternalMemberCardNo, AdmissionCode, IgnoreLogEntryNo, ResponseMessage, ResponseCode);
            if (RuleNo <> 0) then
                exit(RuleNo);
        end;

        RuleNo := CheckLimitations(ClientType, MembershipCode, MembershipLimitationSetup."Constraint Source"::MEMBERCARD,
                                    ExternalMemberCardNo, AdmissionCode, IgnoreLogEntryNo, ResponseMessage, ResponseCode);
        if (RuleNo <> 0) then
            exit(RuleNo);

        RuleNo := CheckLimitations(ClientType, MembershipCode, MembershipLimitationSetup."Constraint Source"::MEMBER,
                                    ExternalMemberNo, AdmissionCode, IgnoreLogEntryNo, ResponseMessage, ResponseCode);
        if (RuleNo <> 0) then
            exit(RuleNo);

        RuleNo := CheckLimitations(ClientType, MembershipCode, MembershipLimitationSetup."Constraint Source"::MEMBERSHIP,
                                    ExternalMemberShipNo, AdmissionCode, IgnoreLogEntryNo, ResponseMessage, ResponseCode);
        if (RuleNo <> 0) then
            exit(RuleNo);

        RuleNo := CheckLimitations(ClientType, MembershipCode, MembershipLimitationSetup."Constraint Source"::GDPR_PENDING,
                                    ExternalMemberCardNo, AdmissionCode, IgnoreLogEntryNo, ResponseMessage, ResponseCode);
        if (RuleNo <> 0) then
            exit(RuleNo);

        RuleNo := CheckLimitations(ClientType, MembershipCode, MembershipLimitationSetup."Constraint Source"::GDPR_REJECTED,
                                    ExternalMemberCardNo, AdmissionCode, IgnoreLogEntryNo, ResponseMessage, ResponseCode);
        if (RuleNo <> 0) then
            exit(RuleNo);

        // Also test rules without AdmissionCode
        // Has impact on how POS will handle action (error,confirm,message), WS will deny access either way.
        if (AdmissionCode <> '') then
            exit(CheckAllLimitations(ClientType, MembershipCode, ExternalMemberShipNo, ExternalMemberNo, ExternalMemberCardNo, '', ScannerStationId, IgnoreLogEntryNo, ResponseMessage, ResponseCode));
    end;

    local procedure CheckLimitations(ClientType: Option POS,WS; MembershipCode: Code[20]; KeyValueType: Option; KeyValue: Text[100]; AdmissionCode: Code[20]; IgnoreLogEntryNo: Integer; var ResponseMessage: Text; var ResponseCode: Integer) RuleNo: Integer
    var
        MembershipLimitationSetup: Record "NPR MM Membership Lim. Setup";
        LimitFound: Boolean;
        RuleMatchCount: Integer;
        RuleCondition: Text;
    begin

        if (KeyValue <> '') then begin
            if (ClientType = ClientType::POS) then begin
                MembershipLimitationSetup.SetCurrentKey("Constraint Source", "Membership  Code", "Admission Code", "POS Response Action");
                MembershipLimitationSetup.SetFilter("POS Response Action", '<>%1', MembershipLimitationSetup."POS Response Action"::ALLOW);
            end else begin
                MembershipLimitationSetup.SetCurrentKey("Constraint Source", "Membership  Code", "Admission Code", "WS Response Action");
                MembershipLimitationSetup.SetFilter("WS Response Action", '<>%1', MembershipLimitationSetup."WS Response Action"::ALLOW);
            end;

            MembershipLimitationSetup.SetFilter("Membership  Code", '=%1', MembershipCode);
            MembershipLimitationSetup.SetFilter("Admission Code", '=%1', AdmissionCode);
            MembershipLimitationSetup.SetFilter("Constraint Source", '=%1', KeyValueType);
            MembershipLimitationSetup.SetFilter(Blocked, '=%1', false);

            if (MembershipLimitationSetup.FindSet()) then begin
                repeat
                    LimitFound := DoesRuleApply(MembershipLimitationSetup."Entry No.", KeyValue, AdmissionCode, IgnoreLogEntryNo, RuleMatchCount, RuleCondition);

                    if (LimitFound) then begin
                        RuleNo := MembershipLimitationSetup."Entry No.";
                        case ClientType of
                            ClientType::WS:
                                ResponseMessage := MembershipLimitationSetup."WS Deny Message";
                            ClientType::POS:
                                ResponseMessage := MembershipLimitationSetup."POS Response Message"
                            else
                                ResponseMessage := '';
                        end;
                        if (ResponseMessage = '') then
                            ResponseMessage := '[%5%4] - Membership Limitation Setup, rule %5 prevents this action. Threshold %1, Rule Match Count: %2, Entry Constraint: %3';

                        ResponseMessage := StrSubstNo(ResponseMessage, RuleCondition, RuleMatchCount, ConstraintText, MembershipLimitationSetup."Response Code", RuleNo);
                        ResponseCode := MembershipLimitationSetup."Response Code";
                    end;

                until (MembershipLimitationSetup.Next() = 0) or (LimitFound);
            end;
        end;

        exit(RuleNo);
    end;

    local procedure DoesRuleApply(RuleEntryNo: Integer; KeyValue: Text[100]; AdmissionCode: Code[20]; IgnoreLogEntryNo: Integer; var MatchCount: Integer; var RuleConditionalValue: Text): Boolean
    var
        MembershipLimitationSetup: Record "NPR MM Membership Lim. Setup";
        MemberArrivalLogEntry: Record "NPR MM Member Arr. Log Entry";
        RelativeDateTime: DateTime;
        PlaceHolderLbl: Label '%1', Locked = true;
        PlaceHolder2Lbl: Label '%1 - %2', Locked = true;
    begin

        MembershipLimitationSetup.Get(RuleEntryNo);

        MemberArrivalLogEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        MemberArrivalLogEntry.SetFilter("Entry No.", '<>%1', IgnoreLogEntryNo);

        case MembershipLimitationSetup."Constraint Source" of
            MembershipLimitationSetup."Constraint Source"::MEMBER:
                MemberArrivalLogEntry.SetFilter("External Member No.", '=%1', CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Member No.")));
            MembershipLimitationSetup."Constraint Source"::MEMBERCARD:
                MemberArrivalLogEntry.SetFilter("External Card No.", '=%1', CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Card No.")));
            MembershipLimitationSetup."Constraint Source"::MEMBERSHIP:
                MemberArrivalLogEntry.SetFilter("External Membership No.", '=%1', CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Membership No.")));
            MembershipLimitationSetup."Constraint Source"::TEMP_MEMBERCARD:
                begin
                    MemberArrivalLogEntry.SetFilter("External Card No.", '=%1', CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Card No.")));
                    MemberArrivalLogEntry.SetFilter("Temporary Card", '=%1', true);
                end;

            MembershipLimitationSetup."Constraint Source"::GDPR_PENDING:
                begin
                    if (not MemberHasPendingGDPRRequest(CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Card No.")))) then
                        exit(false);
                    MemberArrivalLogEntry.SetFilter("External Card No.", '=%1', CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Card No.")));
                end;
            MembershipLimitationSetup."Constraint Source"::GDPR_REJECTED:
                exit(MemberHasRejectedGDPRRequest(CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Card No."))));

        end;

        case MembershipLimitationSetup."Event Type" of
            MembershipLimitationSetup."Event Type"::SUCCESS_COUNT:
                MemberArrivalLogEntry.SetFilter("Response Type", '=%1', MemberArrivalLogEntry."Response Type"::SUCCESS);
            MembershipLimitationSetup."Event Type"::FAIL_COUNT:
                MemberArrivalLogEntry.SetFilter("Response Type", '<>%1', MemberArrivalLogEntry."Response Type"::SUCCESS);
        end;

        case MembershipLimitationSetup."Constraint Type" of
            MembershipLimitationSetup."Constraint Type"::RELATIVE_TIME:
                begin
                    RuleConditionalValue := StrSubstNo(PlaceHolderLbl, MembershipLimitationSetup."Constraint Seconds");
                    RelativeDateTime := CurrentDateTime() - (MembershipLimitationSetup."Constraint Seconds" * 1000);
                    MemberArrivalLogEntry.SetFilter("Created At", '>=%1', RelativeDateTime);
                end;

            MembershipLimitationSetup."Constraint Type"::FIXED_TIME:
                begin
                    RuleConditionalValue := StrSubstNo(PlaceHolder2Lbl, MembershipLimitationSetup."Constraint From Time", MembershipLimitationSetup."Constraint Until Time");
                    MemberArrivalLogEntry.SetFilter("Local Date", '=%1', Today);
                    MemberArrivalLogEntry.SetFilter("Local Time", '>=%1 & <=%2', MembershipLimitationSetup."Constraint From Time", MembershipLimitationSetup."Constraint Until Time");
                end;

            MembershipLimitationSetup."Constraint Type"::DATEFORMULA:
                begin
                    RuleConditionalValue := StrSubstNo(PlaceHolderLbl, CalcDate(MembershipLimitationSetup."Constraint Dateformula", Today));
                    MemberArrivalLogEntry.SetFilter("Local Date", '>=%1', CalcDate(MembershipLimitationSetup."Constraint Dateformula", Today));
                end;
        end;

        MatchCount := MemberArrivalLogEntry.Count();

        ConstraintText := '';
        if (MemberArrivalLogEntry.FindFirst()) then begin
            case MembershipLimitationSetup."Constraint Type" of
                MembershipLimitationSetup."Constraint Type"::RELATIVE_TIME:
                    ConstraintText := StrSubstNo(PlaceHolderLbl, MembershipLimitationSetup."Constraint Seconds" - Round((CurrentDateTime() - MemberArrivalLogEntry."Created At") / 1000, 1));
                MembershipLimitationSetup."Constraint Type"::FIXED_TIME:
                    ConstraintText := StrSubstNo(PlaceHolder2Lbl, MemberArrivalLogEntry."Local Date", MemberArrivalLogEntry."Local Time");
                MembershipLimitationSetup."Constraint Type"::DATEFORMULA:
                    ConstraintText := StrSubstNo(PlaceHolder2Lbl, MemberArrivalLogEntry."Local Date", MemberArrivalLogEntry."Local Time");
            end;
        end else begin
            case MembershipLimitationSetup."Constraint Type" of
                MembershipLimitationSetup."Constraint Type"::RELATIVE_TIME:
                    ConstraintText := StrSubstNo(PlaceHolderLbl, MembershipLimitationSetup."Constraint Seconds");
                MembershipLimitationSetup."Constraint Type"::FIXED_TIME:
                    ConstraintText := StrSubstNo(PlaceHolder2Lbl, MembershipLimitationSetup."Constraint From Time", MembershipLimitationSetup."Constraint Until Time");
                MembershipLimitationSetup."Constraint Type"::DATEFORMULA:
                    ConstraintText := StrSubstNo(PlaceHolderLbl, Today());
            end;
        end;

        if (MembershipLimitationSetup."Event Limit" = 0) then begin
            case MembershipLimitationSetup."Constraint Type" of
                MembershipLimitationSetup."Constraint Type"::RELATIVE_TIME:
                    exit(true);
                MembershipLimitationSetup."Constraint Type"::FIXED_TIME:
                    exit((Time > MembershipLimitationSetup."Constraint From Time") and (Time < MembershipLimitationSetup."Constraint Until Time"));
                MembershipLimitationSetup."Constraint Type"::DATEFORMULA:
                    exit(CalcDate(MembershipLimitationSetup."Constraint Dateformula", Today) = Today);
            end;
        end;

        exit(MatchCount >= MembershipLimitationSetup."Event Limit");
    end;

    local procedure IsTemporaryCard(ExternalCardNo: Code[100]): Boolean
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberCard: Record "NPR MM Member Card";
    begin

        MemberCard.Get(MembershipManagement.GetCardEntryNoFromExtCardNo(ExternalCardNo));
        exit(MemberCard."Card Is Temporary");
    end;

    local procedure MemberHasPendingGDPRRequest(ExternalCardNumber: Text[100]): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
        MembershipRole: Record "NPR MM Membership Role";
    begin

        MemberCard.SetFilter("External Card No.", '=%1', ExternalCardNumber);
        if (not MemberCard.FindFirst()) then
            exit(false);

        if (not MembershipRole.Get(MemberCard."Membership Entry No.", MemberCard."Member Entry No.")) then
            exit(false);

        MembershipRole.CalcFields("GDPR Approval");

        if (MembershipRole."GDPR Approval" = MembershipRole."GDPR Approval"::DELEGATED) then begin
            MembershipRole.Reset();
            MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipRole."Membership Entry No.");
            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
            MembershipRole.SetFilter(Blocked, '=%1', false);
            if (not MembershipRole.FindSet()) then
                exit(false); // This should be fatal error
            repeat
                MembershipRole.CalcFields("GDPR Approval");
                if (MembershipRole."GDPR Approval" = MembershipRole."GDPR Approval"::PENDING) then
                    exit(true);
            until (MembershipRole.Next() = 0);
        end;

        exit(MembershipRole."GDPR Approval" = MembershipRole."GDPR Approval"::PENDING);

    end;

    local procedure MemberHasRejectedGDPRRequest(ExternalCardNumber: Text[100]): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
        MembershipRole: Record "NPR MM Membership Role";
    begin

        MemberCard.SetFilter("External Card No.", '=%1', ExternalCardNumber);
        if (not MemberCard.FindFirst()) then
            exit(false);

        if (not MembershipRole.Get(MemberCard."Membership Entry No.", MemberCard."Member Entry No.")) then
            exit(false);

        MembershipRole.CalcFields("GDPR Approval");

        if (MembershipRole."GDPR Approval" = MembershipRole."GDPR Approval"::DELEGATED) then begin
            MembershipRole.Reset();
            MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipRole."Membership Entry No.");
            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
            MembershipRole.SetFilter(Blocked, '=%1', false);
            if (not MembershipRole.FindSet()) then
                exit(false); // This should be fatal error
            repeat
                MembershipRole.CalcFields("GDPR Approval");
                if (MembershipRole."GDPR Approval" = MembershipRole."GDPR Approval"::REJECTED) then
                    exit(true);
            until (MembershipRole.Next() = 0);
        end;

        exit(MembershipRole."GDPR Approval" = MembershipRole."GDPR Approval"::REJECTED);

    end;
}

