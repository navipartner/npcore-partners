codeunit 6060144 "NPR MM Member Lim. Mgr."
{
    // MM1.21/NPKNAV/20170728  CASE 284653 Transport MM1.21 - 28 July 2017
    // MM1.22/TSA /20170911 CASE 284560 Handling of Temp_membercard constraint type
    // MM1.23/TSA /20171004 CASE 257011 Extending Card number length (inconsistent)
    // MM1.29/TSA /20180511 CASE 313795 GDPR Constraint Source
    // MM1.29/TSA /20180525 CASE 316468 When rules where processed by webservice, the there were no rollback on created artifacts
    // MM1.32/TSA/20180725  CASE 323333 Transport MM1.32 - 25 July 2018
    // MM1.45/TSA /20200729 CASE 416671 Added a feature to check without actual logging Signature change, added ReUseLogEntryNo parameter


    trigger OnRun()
    begin
    end;

    var
        ResponseSourceType: Option EXTERNAL,ADMISSTION_LIMIT;
        ContraintText: Text;
        USER_CONFIRM_MESSAGE: Label '%1\\Do you want to allow action anyway?';

    procedure LogMemberCardArrival(ExternalMemberCardNo: Text[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; ResponseMessage: Text; ResponseCode: Integer): Integer
    var
        ExternalMemberNo: Code[20];
        ExternalMembershipNo: Code[20];
        MembershipCode: Code[20];
        IgnoreMessage: Text;
        LogEntryNo: Integer;
    begin

        GetExternalMemberNo(ExternalMemberCardNo, ExternalMemberNo, IgnoreMessage);
        GetExternalMembershipNo(ExternalMemberCardNo, ExternalMembershipNo, MembershipCode, IgnoreMessage);

        InternalLogArrival(ExternalMembershipNo, ExternalMemberNo, ExternalMemberCardNo, AdmissionCode, ScannerStationId, LogEntryNo, ResponseMessage, ResponseCode, 0);

        exit(ResponseCode);
    end;

    procedure WS_CheckLimitMemberCardArrival(ExternalMemberCardNo: Text[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ReUseLogEntryNo: Integer; var ResponseMessage: Text; var ResponseCode: Integer) LogEntryNo: Integer
    begin

        CheckLimitMemberCardArrival(1, ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, ResponseMessage, ResponseCode);
    end;

    procedure POS_CheckLimitMemberCardArrival(ExternalMemberCardNo: Text[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ResponseMessage: Text; var ResponseCode: Integer) LogEntryNo: Integer
    var
        ReUseLogEntryNo: Integer;
    begin

        CheckLimitMemberCardArrival(0, ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, ResponseMessage, ResponseCode);
    end;

    local procedure "--Internal"()
    begin
    end;

    local procedure InternalLogArrival(ExternalMemberShipNo: Code[20]; ExternalMemberNo: Code[20]; ExternalMemberCardNo: Text[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ReUseLogEntryNo: Integer; ResponseMessage: Text; ResponseCode: Integer; ResponseRuleEntry: Integer)
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberArrivalLogEntry: Record "NPR MM Member Arr. Log Entry";
        DoReuseLogEntry: Boolean;
    begin

        //-MM1.45 [416671]
        //MemberArrivalLogEntry."Entry No." := 0;

        DoReuseLogEntry := (ReUseLogEntryNo > 0);
        if (DoReuseLogEntry) then DoReuseLogEntry := MemberArrivalLogEntry.Get(ReUseLogEntryNo);
        if (DoReuseLogEntry) then DoReuseLogEntry := (MemberArrivalLogEntry."External Card No." = ExternalMemberCardNo);
        if (DoReuseLogEntry) then MemberArrivalLogEntry.Init();

        if (not DoReuseLogEntry) then begin
            MemberArrivalLogEntry."Entry No." := 0;
            MemberArrivalLogEntry.Init();
            MemberArrivalLogEntry.Insert();
        end;
        //+MM1.45 [416671]

        MemberArrivalLogEntry."Event Type" := MemberArrivalLogEntry."Event Type"::ARRIVAL;
        MemberArrivalLogEntry."Created At" := CurrentDateTime();
        MemberArrivalLogEntry."Local Date" := Today;
        MemberArrivalLogEntry."Local Time" := Time; // TIME from webclient and webservice are different

        MemberArrivalLogEntry."External Membership No." := ExternalMemberShipNo;
        MemberArrivalLogEntry."External Member No." := ExternalMemberNo;
        MemberArrivalLogEntry."External Card No." := ExternalMemberCardNo;
        MemberArrivalLogEntry."Scanner Station Id" := ScannerStationId;
        MemberArrivalLogEntry."Admission Code" := AdmissionCode;

        //-MM1.22 [284560]
        MemberArrivalLogEntry."Temporary Card" := IsTemporaryCard(ExternalMemberCardNo);
        //+MM1.22 [284560]

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

        //-MM1.45 [416671]
        //MemberArrivalLogEntry.INSERT ();

        MemberArrivalLogEntry.Modify();
        ReUseLogEntryNo := MemberArrivalLogEntry."Entry No.";
        //+MM1.45 [416671]
    end;

    local procedure CheckLimitMemberCardArrival(ClientType: Option POS,WS; ExternalMemberCardNo: Text[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ReUseLogEntryNo: Integer; var ResponseMessage: Text; var ResponseCode: Integer) RuleNo: Integer
    var
        MembershipLimitationSetup: Record "NPR MM Membership Lim. Setup";
        ExternalMemberNo: Code[20];
        ExternalMembershipNo: Code[20];
        MembershipCode: Code[20];
        NewResponseMessage: Text;
        NewResponseCode: Integer;
        IgnoreMessage: Text;
    begin

        // Log the sent message and code
        if (ResponseCode <> 0) then begin
            //-MM1.45 [416671]
            // LogMemberCardArrival (ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, ResponseCode);
            GetExternalMemberNo(ExternalMemberCardNo, ExternalMemberNo, IgnoreMessage);
            GetExternalMembershipNo(ExternalMemberCardNo, ExternalMembershipNo, MembershipCode, IgnoreMessage);
            InternalLogArrival(ExternalMembershipNo, ExternalMemberNo, ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, ResponseMessage, ResponseCode, 0);
            //-MM1.45 [416671]
            exit;
        end;

        // Figure out who we are - be careful with references...
        if (ResponseCode = 0) then
            if (not GetExternalMemberNo(ExternalMemberCardNo, ExternalMemberNo, NewResponseMessage)) then
                NewResponseCode := -9998;

        if (ResponseCode = 0) then
            if (not GetExternalMembershipNo(ExternalMemberCardNo, ExternalMembershipNo, MembershipCode, NewResponseMessage)) then
                NewResponseCode := -9999;

        // IF we can not resolve who we are, dont bother checking the rules
        if (ResponseCode <> 0) then begin
            InternalLogArrival(ExternalMembershipNo, ExternalMemberNo, ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, NewResponseMessage, NewResponseCode, 0);
            exit;
        end;

        RuleNo := CheckAndLogArrival(ClientType, MembershipCode, ExternalMembershipNo, ExternalMemberNo, ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, ResponseMessage, ResponseCode);
    end;

    local procedure CheckAndLogArrival(ClientType: Option POS,WS; MembershipCode: Code[20]; ExternalMemberShipNo: Code[20]; ExternalMemberNo: Code[20]; ExternalMemberCardNo: Text[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ReUseLogEntryNo: Integer; var ResponseMessage: Text; var ResponseCode: Integer) RuleNo: Integer
    var
        MembershipLimitationSetup: Record "NPR MM Membership Lim. Setup";
        NewResponseMessage: Text;
        NewResponseCode: Integer;
    begin

        // Get first rule that is violated
        RuleNo := CheckAllLimitations(ClientType, MembershipCode, ExternalMemberShipNo, ExternalMemberNo, ExternalMemberCardNo, AdmissionCode, ScannerStationId, NewResponseMessage, NewResponseCode);

        // rollback our transaction if needed
        if (RuleNo <> 0) then begin
            MembershipLimitationSetup.Get(RuleNo);

            if (ClientType = ClientType::POS) then begin
                case MembershipLimitationSetup."POS Response Action" of
                    MembershipLimitationSetup."POS Response Action"::USER_ERROR:
                        asserterror Error(''); // This will rollback our successful transaction - whatever it did!!
                    MembershipLimitationSetup."POS Response Action"::USER_CONFIRM:
                        if (not Confirm(USER_CONFIRM_MESSAGE, true, NewResponseMessage)) then begin
                            asserterror Error(''); // This will rollback our successful transaction - whatever it did!!
                        end else begin
                            RuleNo := 0; // User confirmed that no rule was violated
                        end;
                    MembershipLimitationSetup."POS Response Action"::USER_MESSAGE:
                        begin
                            RuleNo := 0;
                            Message(NewResponseMessage);
                        end;
                end;
            end;

            //-#316468 [316468]
            if (ClientType = ClientType::WS) then
                if (MembershipLimitationSetup."WS Response Action" = MembershipLimitationSetup."WS Response Action"::USER_ERROR) then
                    asserterror Error(''); // This will rollback our successful transaction - whatever it did!!
                                           //+#316468 [316468]

        end;

        if (RuleNo <> 0) then begin
            ResponseCode := NewResponseCode;
            ResponseMessage := NewResponseMessage;
        end;

        InternalLogArrival(ExternalMemberShipNo, ExternalMemberNo, ExternalMemberCardNo, AdmissionCode, ScannerStationId, ReUseLogEntryNo, ResponseMessage, ResponseCode, RuleNo);

        if (RuleNo <> 0) then begin
            MembershipLimitationSetup.Get(RuleNo);
            if (ClientType = ClientType::POS) then begin
                case MembershipLimitationSetup."POS Response Action" of
                    // ASSERTERROR will rollback transaction, COMMIT must only effect log entry. Downstream code may error the responsemessage
                    MembershipLimitationSetup."POS Response Action"::USER_ERROR:
                        Commit;
                    MembershipLimitationSetup."POS Response Action"::USER_CONFIRM:
                        Commit;
                end;
            end;

            //-#316468 [316468]
            if (ClientType = ClientType::WS) then
                if (MembershipLimitationSetup."WS Response Action" = MembershipLimitationSetup."WS Response Action"::USER_ERROR) then
                    Commit;
            //+#316468 [316468]

        end;

        exit(RuleNo);
    end;

    local procedure CheckAllLimitations(ClientType: Option POS,WS; MembershipCode: Code[20]; ExternalMemberShipNo: Code[20]; ExternalMemberNo: Code[20]; ExternalMemberCardNo: Text[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ResponseMessage: Text; var ResponseCode: Integer) RuleNo: Integer
    var
        MembershipLimitationSetup: Record "NPR MM Membership Lim. Setup";
    begin


        if (IsTemporaryCard(ExternalMemberCardNo)) then begin
            RuleNo := CheckLimitations(ClientType, MembershipCode, MembershipLimitationSetup."Constraint Source"::TEMP_MEMBERCARD,
                                        ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, ResponseCode);
            if (RuleNo <> 0) then
                exit(RuleNo);
        end;

        RuleNo := CheckLimitations(ClientType, MembershipCode, MembershipLimitationSetup."Constraint Source"::MEMBERCARD,
                                    ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, ResponseCode);
        if (RuleNo <> 0) then
            exit(RuleNo);

        RuleNo := CheckLimitations(ClientType, MembershipCode, MembershipLimitationSetup."Constraint Source"::MEMBER,
                                    ExternalMemberNo, AdmissionCode, ScannerStationId, ResponseMessage, ResponseCode);
        if (RuleNo <> 0) then
            exit(RuleNo);

        RuleNo := CheckLimitations(ClientType, MembershipCode, MembershipLimitationSetup."Constraint Source"::MEMBERSHIP,
                                    ExternalMemberShipNo, AdmissionCode, ScannerStationId, ResponseMessage, ResponseCode);
        if (RuleNo <> 0) then
            exit(RuleNo);

        //-MM1.29 [313795]
        RuleNo := CheckLimitations(ClientType, MembershipCode, MembershipLimitationSetup."Constraint Source"::GDPR_PENDING,
                                    ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, ResponseCode);
        if (RuleNo <> 0) then
            exit(RuleNo);

        RuleNo := CheckLimitations(ClientType, MembershipCode, MembershipLimitationSetup."Constraint Source"::GDPR_REJECTED,
                                    ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, ResponseCode);
        if (RuleNo <> 0) then
            exit(RuleNo);
        //+MM1.29 [313795]

        // Also test rules without AdmissionCode
        // Has impact on how POS will handle action (error,confirm,message), WS will deny access either way.
        if (AdmissionCode <> '') then
            exit(CheckAllLimitations(ClientType, MembershipCode, ExternalMemberShipNo, ExternalMemberNo, ExternalMemberCardNo, '', ScannerStationId, ResponseMessage, ResponseCode));
    end;

    local procedure CheckLimitations(ClientType: Option POS,WS; MembershipCode: Code[20]; KeyValueType: Option; KeyValue: Text[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ResponseMessage: Text; var ResponseCode: Integer) RuleNo: Integer
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
                    LimitFound := DoesRuleApply(ClientType, MembershipLimitationSetup."Entry No.", KeyValue, AdmissionCode, RuleMatchCount, ContraintText, RuleCondition);

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
                            ResponseMessage := '[%5%4] - Membership Limitation Setup, rule %5 prevents this action. Threshold %1, Rule Match Count: %2, Entry Constraint %3';

                        ResponseMessage := StrSubstNo(ResponseMessage, RuleCondition, RuleMatchCount, ContraintText, MembershipLimitationSetup."Response Code", RuleNo);
                        ResponseCode := MembershipLimitationSetup."Response Code";
                    end;

                until (MembershipLimitationSetup.Next() = 0) or (LimitFound);
            end;
        end;

        exit(RuleNo);
    end;

    local procedure DoesRuleApply(ClientType: Option; RuleEntryNo: Integer; KeyValue: Text[50]; AdmissionCode: Code[20]; var MatchCount: Integer; var RuleConstraint: Text; var RuleConditionalValue: Text): Boolean
    var
        MembershipLimitationSetup: Record "NPR MM Membership Lim. Setup";
        MemberArrivalLogEntry: Record "NPR MM Member Arr. Log Entry";
        RelativeDateTime: DateTime;
        MyTime: Time;
    begin

        with MembershipLimitationSetup do begin

            Get(RuleEntryNo);
            MyTime := DT2Time(CurrentDateTime); // TIME from webclient and webservice is not same

            MemberArrivalLogEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            MemberArrivalLogEntry.SetFilter("Temporary Card", '=%1', false);

            case "Constraint Source" of
                "Constraint Source"::MEMBER:
                    MemberArrivalLogEntry.SetFilter("External Member No.", '=%1', CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Member No.")));
                "Constraint Source"::MEMBERCARD:
                    MemberArrivalLogEntry.SetFilter("External Card No.", '=%1', CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Card No.")));
                "Constraint Source"::MEMBERSHIP:
                    MemberArrivalLogEntry.SetFilter("External Membership No.", '=%1', CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Membership No.")));
                "Constraint Source"::TEMP_MEMBERCARD:
                    begin
                        MemberArrivalLogEntry.SetFilter("External Card No.", '=%1', CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Card No.")));
                        MemberArrivalLogEntry.SetFilter("Temporary Card", '=%1', true);
                    end;
                //-MM1.29 [313795]
                "Constraint Source"::GDPR_PENDING:
                    begin
                        if (not MemberHasPendingGDPRRequest(CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Card No.")))) then
                            exit(false);
                        MemberArrivalLogEntry.SetFilter("External Card No.", '=%1', CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Card No.")));
                    end;
                "Constraint Source"::GDPR_REJECTED:
                    exit(MemberHasRejectedGDPRRequest(CopyStr(KeyValue, 1, MaxStrLen(MemberArrivalLogEntry."External Card No."))));
            //+MM1.29 [313795]
            end;

            case "Event Type" of
                "Event Type"::SUCCESS_COUNT:
                    MemberArrivalLogEntry.SetFilter("Response Type", '=%1', MemberArrivalLogEntry."Response Type"::SUCCESS);
                "Event Type"::FAIL_COUNT:
                    MemberArrivalLogEntry.SetFilter("Response Type", '<>%1', MemberArrivalLogEntry."Response Type"::SUCCESS);
            end;

            case "Constraint Type" of
                "Constraint Type"::RELATIVE_TIME:
                    begin
                        RuleConditionalValue := StrSubstNo('%1', "Constraint Seconds");
                        RelativeDateTime := CurrentDateTime - ("Constraint Seconds" * 1000);
                        MemberArrivalLogEntry.SetFilter("Created At", '>=%1', RelativeDateTime);
                    end;

                "Constraint Type"::FIXED_TIME:
                    begin
                        RuleConditionalValue := StrSubstNo('%1 - %2', "Constraint From Time", "Constraint Until Time");
                        MemberArrivalLogEntry.SetFilter("Local Date", '=%1', Today);
                        MemberArrivalLogEntry.SetFilter("Local Time", '>=%1 & <=%2', "Constraint From Time", "Constraint Until Time");
                    end;

                "Constraint Type"::DATEFORMULA:
                    begin
                        RuleConditionalValue := StrSubstNo('%1', CalcDate("Constraint Dateformula", Today));
                        MemberArrivalLogEntry.SetFilter("Local Date", '>=%1', CalcDate("Constraint Dateformula", Today));
                    end;
            end;

            MatchCount := MemberArrivalLogEntry.Count();

            ContraintText := '';
            if (MemberArrivalLogEntry.FindFirst()) then begin
                case "Constraint Type" of
                    "Constraint Type"::RELATIVE_TIME:
                        ContraintText := StrSubstNo('%1', MembershipLimitationSetup."Constraint Seconds" - Round((CurrentDateTime - MemberArrivalLogEntry."Created At") / 1000, 1));
                    "Constraint Type"::FIXED_TIME:
                        ContraintText := StrSubstNo('%1 - %', MemberArrivalLogEntry."Local Date", MemberArrivalLogEntry."Local Time");
                    "Constraint Type"::DATEFORMULA:
                        ContraintText := StrSubstNo('%1 - %', MemberArrivalLogEntry."Local Date", MemberArrivalLogEntry."Local Time");
                end;
            end else begin
                case "Constraint Type" of
                    "Constraint Type"::RELATIVE_TIME:
                        ContraintText := StrSubstNo('%1', MembershipLimitationSetup."Constraint Seconds");
                    "Constraint Type"::FIXED_TIME:
                        ContraintText := StrSubstNo('%1 - %2', "Constraint From Time", "Constraint Until Time");
                    "Constraint Type"::DATEFORMULA:
                        ContraintText := StrSubstNo('%1', Today);
                end;
            end;

            if ("Event Limit" = 0) then begin
                case "Constraint Type" of
                    "Constraint Type"::RELATIVE_TIME:
                        exit(true);
                    "Constraint Type"::FIXED_TIME:
                        exit((Time > "Constraint From Time") and (Time < "Constraint Until Time"));
                    "Constraint Type"::DATEFORMULA:
                        exit(CalcDate("Constraint Dateformula", Today) = Today);
                end;
            end;

            exit(MatchCount >= "Event Limit");
        end;
    end;

    local procedure GetExternalMembershipNo(ExternalCardNo: Text[50]; var ExternalMembershipNo: Code[20]; var MembershipCode: Code[20]; var ResponseMessage: Text): Boolean
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Membership: Record "NPR MM Membership";
    begin

        if (Membership.Get(MembershipManagement.GetMembershipFromExtCardNo(ExternalCardNo, Today, ResponseMessage))) then begin
            ExternalMembershipNo := Membership."External Membership No.";
            MembershipCode := Membership."Membership Code";
        end;

        exit(ExternalMembershipNo <> '');
    end;

    local procedure GetExternalMemberNo(ExternalCardNo: Text[50]; var ExternalMemberNo: Code[20]; var ResponseMessage: Text): Boolean
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Member: Record "NPR MM Member";
    begin

        if (Member.Get(MembershipManagement.GetMemberFromExtCardNo(ExternalCardNo, Today, ResponseMessage))) then
            ExternalMemberNo := Member."External Member No.";

        exit(ExternalMemberNo <> '');
    end;

    local procedure IsTemporaryCard(ExternalCardNo: Code[100]): Boolean
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
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

        //-MM1.29 [313795]
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
        //+MM1.29 [313795]
    end;

    local procedure MemberHasRejectedGDPRRequest(ExternalCardNumber: Text[100]): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
        MembershipRole: Record "NPR MM Membership Role";
    begin

        //-MM1.29 [313795]
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
        //+MM1.29 [313795]
    end;
}

