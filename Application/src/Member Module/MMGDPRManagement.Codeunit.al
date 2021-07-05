codeunit 6151121 "NPR MM GDPR Management"
{

    trigger OnRun()
    var
        Membership: Record "NPR MM Membership";
        ReasonText: Text;
    begin

        // For automation of anonymisation
        if (Membership.FindSet()) then begin
            repeat

                AnonymizeMembership(Membership."Entry No.", true, ReasonText);
                Commit();

            until (Membership.Next() = 0);
        end;
    end;

    var
        MISSING_APPROVAL: Label 'The GDPR setup for this membership type require that GDPR terms must be approved prior to member creation. Member %1 has not approved the GDPR terms yet.';
        HideDialog: Boolean;

    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"NPR MM Membership Events", 'OnAfterMemberCreateEvent', '', true, true)]
    local procedure OnNewMember(var Membership: Record "NPR MM Membership"; var Member: Record "NPR MM Member")
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit;

        CheckLogEntry(MembershipSetup."GDPR Agreement No.", MembershipSetup."GDPR Mode", Membership."Entry No.", Member."Entry No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"NPR MM Membership Events", 'OnAfterInsertMembershipEntry', '', true, true)]
    local procedure OnNewMembershipTimeEntry(MembershipEntry: Record "NPR MM Membership Entry")
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        case MembershipEntry."Original Context" of
            MembershipEntry."Original Context"::CANCEL:
                exit;
            MembershipEntry."Original Context"::REGRET:
                exit;
        end;

        if (not MembershipSetup.Get(MembershipEntry."Membership Code")) then
            exit;

        CreateLogEntryMembership(MembershipSetup."GDPR Agreement No.", MembershipSetup."GDPR Mode", MembershipEntry."Membership Entry No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151120, 'OnNewAgreementVersion', '', true, true)]
    local procedure OnNewAgreementVersion(AgreementNo: Code[20])
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        MembershipSetup.SetFilter("GDPR Agreement No.", '=%1', AgreementNo);
        if (MembershipSetup.FindSet()) then begin
            repeat
                OnMembershipGDPRAgreementChangeWorker(MembershipSetup.Code, '', AgreementNo);
            until (MembershipSetup.Next() = 0);
        end;
    end;

    procedure OnMembershipGDPRAgreementChangeWorker(MembershipCode: Code[20]; OldAgreementNo: Code[20]; NewAgreementNo: Code[20])
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        window: Dialog;
        "max": Integer;
        current: Integer;
    begin

        if (NewAgreementNo = OldAgreementNo) then
            exit;

        MembershipSetup.Get(MembershipCode);

        Membership.SetFilter("Membership Code", '=%1', MembershipCode);
        if (Membership.FindSet()) then begin

            if ((GuiAllowed) and (not HideDialog)) then
                window.Open('@1@@@@@@@@@@@@@@@@@');

            max := Membership.Count();

            repeat
                CreateLogEntryMembership(NewAgreementNo, MembershipSetup."GDPR Mode", Membership."Entry No.");

                if ((GuiAllowed) and (not HideDialog)) then
                    window.Update(1, Round(current / max * 10000, 1));
                current += 1;

            until (Membership.Next() = 0);

            if ((GuiAllowed) and (not HideDialog)) then
                window.Close();

        end;
    end;

    procedure OnMembershipGDPRModeChangeWorker(MembershipCode: Code[20]; OldMode: Option; NewMode: Option)
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        if (OldMode = NewMode) then
            exit;

        MembershipSetup.Get(MembershipCode);

        Membership.SetFilter("Membership Code", '=%1', MembershipCode);
        if (Membership.FindSet()) then begin
            repeat
                CreateLogEntryMembership(MembershipSetup."GDPR Agreement No.", NewMode, Membership."Entry No.");
            until (Membership.Next() = 0);
        end;
    end;

    procedure AnonymizeMembership(MembershipEntryNo: Integer; AgreementCheck: Boolean; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipSetup: Record "NPR MM Membership Setup";
        GDPRAgreement: Record "NPR GDPR Agreement";
        PointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        AnonymizationDate: Date;
        ReasonLbl: Label 'Membership %1 has active roles and was not anonymized.';
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");

        AnonymizationDate := GetMembershipValidUntil(MembershipEntryNo);

        if (AgreementCheck) then begin
            GDPRAgreement.Get(MembershipSetup."GDPR Agreement No.");
            AnonymizationDate := CalcDate(GDPRAgreement."Anonymize After", AnonymizationDate);
        end;

        if (AnonymizationDate > Today) then
            exit; // Not time

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (MembershipRole.FindSet()) then begin
            repeat
                AnonymizeMember(MembershipRole."Member Entry No.", AgreementCheck, ReasonText);
            until (MembershipRole.Next() = 0);
        end;

        MembershipRole.Reset();
        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (not MembershipRole.IsEmpty()) then begin
            ReasonText := StrSubstNo(ReasonLbl, Membership."External Membership No.");
            exit(false);
        end;

        Membership.CalcFields("Remaining Points");
        if (Membership."Remaining Points" > 0) then
            PointManagement.ManualExpirePoints(Membership."Entry No.", '', Membership."Remaining Points", 0, 'Membership Anonymized');

        DoAnonymizeMembership(MembershipEntryNo);

        exit(true);
    end;

    procedure AnonymizeMember(MemberEntryNo: Integer; AgreementCheck: Boolean; var ReasonText: Text) Anonymized: Boolean
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipRoleGuardian: Record "NPR MM Membership Role";
        ReasonLbl: Label 'Member %1 has been anonymized.';
        Reason2Lbl: Label 'Member %1 has active roles and was not anonymized.';
    begin

        Member.Get(MemberEntryNo);

        // First active guardian role will determine anonymization date for all members
        MembershipRole.Reset();
        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
        if (MembershipRole.FindFirst()) then begin
            if (ValidateAnonymizeMemberRole(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", AgreementCheck, ReasonText)) then begin

                MembershipRoleGuardian.SetFilter("Membership Entry No.", '=%1', MembershipRole."Membership Entry No.");
                if (MembershipRoleGuardian.FindSet()) then begin
                    repeat
                        if (MembershipRole."Wallet Pass Id" <> '') then
                            ; //VoidWallet ();
                        DoAnonymizeRole(MembershipRole);
                        MembershipRole.Modify(true);

                    until (MembershipRoleGuardian.Next() = 0);
                end;
            end;
        end;

        MembershipRole.Reset();
        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::GUARDIAN);
        if (MembershipRole.FindSet(true, true)) then begin
            repeat

                if (ValidateAnonymizeMemberRole(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.", AgreementCheck, ReasonText)) then begin
                    if (MembershipRole."Wallet Pass Id" <> '') then
                        ; //VoidWallet ();
                    DoAnonymizeRole(MembershipRole);
                    MembershipRole.Modify(true);
                end;

            until (MembershipRole.Next() = 0)
        end;

        if (MembershipRole.IsEmpty()) then begin
            DoAnonymizeMember(MemberEntryNo);
            ReasonText := StrSubstNo(ReasonLbl, Member."External Member No.");
            exit(true);
        end;

        if (ReasonText = '') then
            ReasonText := StrSubstNo(Reason2Lbl, Member."External Member No.");

        exit(false);
    end;

    local procedure DoAnonymizeMember(MemberEntryNo: Integer)
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        DummyEMailAddressLbl: Label 'anonymous%1@nowhere.com', Locked = true;
    begin

        Member.Get(MemberEntryNo);

        Member."First Name" := '------';
        Member."Middle Name" := '-';
        Member."Last Name" := '--------';
        Member."Phone No." := '';
        Member."Social Security No." := '';
        Member.Address := '-------- --';
        Member."Post Code Code" := '';
        Member.City := '--------';
        Member."Country Code" := '';
        Member.Country := '';
        Member.Gender := Member.Gender::NOT_SPECIFIED;
        Member.Birthday := 0D;
        // Clear(Member.Image);
        Clear(Member.Picture);
        Member."E-Mail Address" := StrSubstNo(DummyEMailAddressLbl, Member."External Member No.");
        Member."Notification Method" := Member."Notification Method"::NONE;
        Member."E-Mail News Letter" := Member."E-Mail News Letter"::NOT_SPECIFIED;
        Member."Display Name" := '------ - -------';

        Member.Blocked := true;
        Member."Blocked At" := CurrentDateTime();
        Member."Blocked By" := UserId;
        Member."Block Reason" := Member."Block Reason"::ANONYMIZED;

        Member.Modify(true);

        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        if (MemberCard.FindSet()) then begin
            repeat
                MemberCard.Blocked := true;
                MemberCard."Blocked At" := CurrentDateTime();
                MemberCard."Blocked By" := UserId;
                MemberCard."Block Reason" := MemberCard."Block Reason"::ANONYMIZED;
                MemberCard.Modify();
            until (MemberCard.Next() = 0);
        end;
    end;

    local procedure DoAnonymizeRole(var MembershipRole: Record "NPR MM Membership Role")
    var
        Contact: Record Contact;
    begin

        MembershipRole.Blocked := true;
        MembershipRole."Blocked At" := CurrentDateTime();
        MembershipRole."Blocked By" := UserId;
        MembershipRole."Block Reason" := MembershipRole."Block Reason"::ANONYMIZED;

        MembershipRole."User Logon ID" := '--------';
        MembershipRole."Password Hash" := 'NO_PWD';

        if (MembershipRole."Contact No." <> '') then begin
            if (Contact.Get(MembershipRole."Contact No.")) then begin
                Contact."NPR Magento Contact" := false;
                Contact.Modify(true);
            end;
        end;
    end;

    local procedure DoAnonymizeMembership(MembershipEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
    begin

        Membership.Get(MembershipEntryNo);

        Membership.Description := '';
        Membership."Company Name" := '';

        //Membership."Auto-Renew" := FALSE;
        Membership."Auto-Renew" := Membership."Auto-Renew"::NO;
        Membership."Auto-Renew External Data" := '';

        Membership."Auto-Renew Payment Method Code" := '';

        // Membership."Customer No."

        Membership.Blocked := true;
        Membership."Blocked At" := CurrentDateTime();
        Membership."Blocked By" := UserId;
        Membership."Block Reason" := Membership."Block Reason"::ANONYMIZED;

        Membership.Modify(true); // This will cause a customer sync.
    end;

    local procedure ValidateAnonymizeMemberRole(MembershipEntryNo: Integer; MemberEntryNo: Integer; AgreementCheck: Boolean; var ReasonText: Text): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
        GDPRManagement: Codeunit "NPR GDPR Management";
        ValidUntil: Date;
        AnonymizationDate: Date;
        AnonymizationDateformula: DateFormula;
        ReasonLbl: Label 'Membership %1 has not expired yet.';
    begin

        MembershipRole.Get(MembershipEntryNo, MemberEntryNo);
        ValidUntil := GetMembershipValidUntil(MembershipEntryNo);
        if (ValidUntil > Today) then begin
            ReasonText := StrSubstNo(ReasonLbl, MembershipRole."External Membership No.");
            exit(false);
        end;

        if (not AgreementCheck) or (MembershipRole."Member Role" = MembershipRole."Member Role"::ANONYMOUS) then
            exit(ValidUntil < Today);

        if (not GDPRManagement.GetAnonymizationDateformula(MembershipRole."GDPR Agreement No.", MembershipRole."GDPR Data Subject Id", AnonymizationDateformula, ReasonText)) then
            exit(false);

        AnonymizationDate := CalcDate(AnonymizationDateformula, ValidUntil);
        exit(AnonymizationDate < Today);
    end;

    local procedure GetMembershipValidUntil(MembershipEntryNo: Integer) ValidUntil: Date
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        ValidUntil := 0D;

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipEntry.SetFilter(Blocked, '=%1', false);

        if (MembershipEntry.FindSet()) then begin
            repeat
                if (MembershipEntry."Valid Until Date" > ValidUntil) then
                    ValidUntil := MembershipEntry."Valid Until Date";
            until (MembershipEntry.Next() = 0);
        end;

        if (ValidUntil = 0D) then begin
            // not activated yet?
            if (MembershipEntry.FindFirst()) then
                if (MembershipEntry."Activate On First Use") then
                    if (Format(MembershipEntry."Duration Dateformula") <> '') then
                        ValidUntil := CalcDate(MembershipEntry."Duration Dateformula", DT2Date(MembershipEntry."Created At"));
        end;

        if (ValidUntil = 0D) then
            ValidUntil := CalcDate('<-5Y-1D>', Today);

        exit(ValidUntil);
    end;

    procedure SetApprovalState(AgreementNo: Code[20]; DataSubjectId: Text[35]; InfoCaptureApprovalState: Option)
    var
        GDPRManagement: Codeunit "NPR GDPR Management";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        GDPRConsentLog: Record "NPR GDPR Consent Log";
    begin

        if (AgreementNo = '') then
            exit;

        if (GDPRManagement.GetApprovalState(AgreementNo, 0, DataSubjectId) = GDPRConsentLog."Entry Approval State"::DELEGATED) then
            exit;

        case InfoCaptureApprovalState of
            MemberInfoCapture."GDPR Approval"::ACCEPTED:
                GDPRManagement.CreateAgreementAcceptEntry(AgreementNo, 0, DataSubjectId);
            MemberInfoCapture."GDPR Approval"::REJECTED:
                GDPRManagement.CreateAgreementRejectEntry(AgreementNo, 0, DataSubjectId);
            MemberInfoCapture."GDPR Approval"::PENDING:
                GDPRManagement.CreateAgreementPendingEntry(AgreementNo, 0, DataSubjectId);
        end;
    end;

    local procedure CreateLogEntryMembership(GDPRAgreementNo: Code[20]; GDPRMode: Option; MembershipEntryNo: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (MembershipRole.FindSet()) then begin
            repeat
                CreateLogEntry(GDPRAgreementNo, GDPRMode, MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.");
            until (MembershipRole.Next() = 0);
        end;
    end;

    local procedure CreateLogEntry(GDPRAgreementNo: Code[20]; GDPRMode: Option; MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        GDPRManagement: Codeunit "NPR GDPR Management";
        GDPRConsentLog: Record "NPR GDPR Consent Log";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit;

        if (GDPRMode = MembershipSetup."GDPR Mode"::NA) then
            exit;

        MembershipRole.Get(MembershipEntryNo, MemberEntryNo);

        if (GDPRAgreementNo = '') and (MembershipRole."GDPR Agreement No." = '') then
            exit;

        //IF ((MembershipRole."GDPR Agreement No." <> MembershipSetup."GDPR Agreement No.") OR (MembershipRole."GDPR Data Subject Id" = '')) THEN BEGIN
        if ((MembershipRole."GDPR Agreement No." <> MembershipSetup."GDPR Agreement No.") or (MembershipRole."GDPR Data Subject Id" = '') or (MembershipRole."GDPR Agreement No." = '')) then begin

            MembershipRole."GDPR Agreement No." := GDPRAgreementNo;
            if (MembershipRole."GDPR Data Subject Id" = '') then
                MembershipRole."GDPR Data Subject Id" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
            MembershipRole.Modify();
        end;

        case (GDPRMode) of
            MembershipSetup."GDPR Mode"::IMPLIED:
                GDPRManagement.CreateAgreementAcceptEntry(MembershipRole."GDPR Agreement No.", 0, MembershipRole."GDPR Data Subject Id");

            MembershipSetup."GDPR Mode"::REQUIRED:
                if not (GDPRManagement.VerifyAcceptEntryExist(MembershipRole."GDPR Agreement No.", 0, MembershipRole."GDPR Data Subject Id")) then begin
                    MembershipRole.CalcFields("External Member No.");
                    Error(MISSING_APPROVAL, MembershipRole."External Member No.");
                end;

            MembershipSetup."GDPR Mode"::CONSENT:
                if (GDPRManagement.GetApprovalState(MembershipRole."GDPR Agreement No.", 0, MembershipRole."GDPR Data Subject Id") <> GDPRConsentLog."Entry Approval State"::DELEGATED) then
                    GDPRManagement.CreateAgreementPendingEntry(MembershipRole."GDPR Agreement No.", 0, MembershipRole."GDPR Data Subject Id");
        end;
    end;

    local procedure CheckLogEntry(GDPRAgreementNo: Code[20]; GDPRMode: Option; MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipRole: Record "NPR MM Membership Role";
        GDPRManagement: Codeunit "NPR GDPR Management";
    begin

        if (GDPRMode = MembershipSetup."GDPR Mode"::NA) then
            exit;

        MembershipRole.Get(MembershipEntryNo, MemberEntryNo);

        if (GDPRAgreementNo = '') and (MembershipRole."GDPR Agreement No." = '') then
            exit;

        if ((MembershipRole."GDPR Agreement No." <> MembershipSetup."GDPR Agreement No.") or (MembershipRole."GDPR Data Subject Id" = '')) then begin
            MembershipRole."GDPR Agreement No." := GDPRAgreementNo;
            if (MembershipRole."GDPR Data Subject Id" = '') then
                MembershipRole."GDPR Data Subject Id" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
            MembershipRole.Modify();
        end;

        case (GDPRMode) of

            MembershipSetup."GDPR Mode"::REQUIRED:
                if not (GDPRManagement.VerifyAcceptEntryExist(MembershipRole."GDPR Agreement No.", 0, MembershipRole."GDPR Data Subject Id")) then begin
                    MembershipRole.CalcFields("External Member No.");
                    Error(MISSING_APPROVAL, MembershipRole."External Member No.");
                end;

        end;
    end;
}

