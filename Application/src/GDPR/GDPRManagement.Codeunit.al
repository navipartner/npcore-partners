codeunit 6151120 "NPR GDPR Management"
{
    Access = Internal;

    procedure CreateAgreementPendingEntry(AgreementNo: Code[20]; Version: Integer; DataSubjectId: Text[35])
    var
        GDPRConsentLog: Record "NPR GDPR Consent Log";
    begin

        if (Version = 0) then
            Version := GetCurrentVersion(AgreementNo);

        CreateConsentLogEntry(AgreementNo, Version, GDPRConsentLog."Entry Approval State"::PENDING, DataSubjectId);
    end;

    procedure CreateAgreementAcceptEntry(AgreementNo: Code[20]; Version: Integer; DataSubjectId: Text[35])
    var
        GDPRConsentLog: Record "NPR GDPR Consent Log";
    begin

        if (Version = 0) then
            Version := GetCurrentVersion(AgreementNo);

        CreateConsentLogEntry(AgreementNo, Version, GDPRConsentLog."Entry Approval State"::ACCEPTED, DataSubjectId);
    end;

    procedure CreateAgreementRejectEntry(AgreementNo: Code[20]; Version: Integer; DataSubjectId: Text[35])
    var
        GDPRConsentLog: Record "NPR GDPR Consent Log";
    begin

        if (Version = 0) then
            Version := GetCurrentVersion(AgreementNo);

        CreateConsentLogEntry(AgreementNo, Version, GDPRConsentLog."Entry Approval State"::REJECTED, DataSubjectId);
    end;

    procedure CreateAgreementDelegateToGuardianEntry(AgreementNo: Code[20]; Version: Integer; DataSubjectId: Text[35])
    var
        GDPRConsentLog: Record "NPR GDPR Consent Log";
    begin

        if (Version = 0) then
            Version := GetCurrentVersion(AgreementNo);

        CreateConsentLogEntry(AgreementNo, Version, GDPRConsentLog."Entry Approval State"::DELEGATED, DataSubjectId);
    end;

    local procedure CreateConsentLogEntry(AgreementNo: Code[20]; Version: Integer; State: Integer; DataSubjectId: Text[35])
    var
        GDPRAgreementVersion: Record "NPR GDPR Agreement Version";
        GDPRConsentLog: Record "NPR GDPR Consent Log";
    begin

        GDPRAgreementVersion.Get(AgreementNo, Version);

        GDPRConsentLog.SetFilter("Agreement No.", '=%1', AgreementNo);
        GDPRConsentLog.SetFilter("Agreement Version", '=%1', Version);
        GDPRConsentLog.SetFilter("Data Subject Id", '=%1', DataSubjectId);
        if (GDPRConsentLog.FindLast()) then
            if (GDPRConsentLog."Entry Approval State" = State) then
                exit;

        GDPRConsentLog.Init();
        GDPRConsentLog."Entry No." := 0;
        GDPRConsentLog."Entry Approval State" := State;
        GDPRConsentLog."Agreement No." := AgreementNo;
        GDPRConsentLog."Agreement Version" := Version;
        GDPRConsentLog."State Change" := CurrentDateTime();
        GDPRConsentLog."Valid From Date" := GDPRAgreementVersion."Activation Date";
        GDPRConsentLog."Data Subject Id" := DataSubjectId;
        GDPRConsentLog.Insert(true);
    end;

    local procedure GetCurrentVersion(AgreementNo: Code[20]) Version: Integer
    var
        GDPRAgreement: Record "NPR GDPR Agreement";
    begin
        GDPRAgreement.Get(AgreementNo);
        GDPRAgreement.SetRange("Date Filter", Today);
        GDPRAgreement.CalcFields("Current Version");
        Version := GDPRAgreement."Current Version";
    end;

    procedure GetAnonymizeDateFormula(AgreementNo: Code[20]; DataSubjectId: Text[35]; var AnonymizeDateFormula: DateFormula; var ReasonText: Text): Boolean
    var
        GDPRAgreement: Record "NPR GDPR Agreement";
        GDPRAgreementVersion: Record "NPR GDPR Agreement Version";
        GDPRConsentLog: Record "NPR GDPR Consent Log";
        AnonymizeDateFormulaEmptyLbl: Label '%1 is not specified for %2 version %3', Locked = true;
    begin
        GDPRConsentLog.SetFilter("Agreement No.", '=%1', AgreementNo);
        GDPRConsentLog.SetFilter("Data Subject Id", '=%1', DataSubjectId);
        GDPRConsentLog.SetFilter("Entry Approval State", '=%1', GDPRConsentLog."Entry Approval State"::ACCEPTED);
        if (GDPRConsentLog.FindLast()) then begin
            GDPRAgreementVersion.Get(AgreementNo, GDPRConsentLog."Agreement Version");
            AnonymizeDateFormula := GDPRAgreementVersion."Anonymize After";
        end else begin
            GDPRAgreement.Get(AgreementNo);
            AnonymizeDateFormula := GDPRAgreement."Anonymize After";
            GDPRAgreementVersion.Version := 0;
        end;

        if (Format(AnonymizeDateFormula) = '') then begin
            ReasonText := StrSubstNo(AnonymizeDateFormulaEmptyLbl, GDPRAgreementVersion.FieldCaption("Anonymize After"), AgreementNo, GDPRAgreementVersion.Version);
            exit(false);
        end;

        exit(true);
    end;

    procedure VerifyAcceptEntryExist(AgreementNo: Code[20]; Version: Integer; DataSubjectId: Text[35]): Boolean
    var
        GDPRConsentLog: Record "NPR GDPR Consent Log";
    begin
        GDPRConsentLog.SetFilter("Agreement No.", '=%1', AgreementNo);

        if (Version > 0) then
            GDPRConsentLog.SetFilter("Agreement Version", '=%1', Version);

        GDPRConsentLog.SetFilter("Data Subject Id", '=%1', DataSubjectId);
        GDPRConsentLog.SetFilter("Entry Approval State", '=%1', GDPRConsentLog."Entry Approval State"::ACCEPTED);

        exit(not GDPRConsentLog.IsEmpty());
    end;

    procedure GetApprovalState(AgreementNo: Code[20]; Version: Integer; DataSubjectId: Text[35]): Integer
    var
        GDPRConsentLog: Record "NPR GDPR Consent Log";
    begin
        GDPRConsentLog.SetFilter("Agreement No.", '=%1', AgreementNo);

        if (Version > 0) then
            GDPRConsentLog.SetFilter("Agreement Version", '=%1', Version);

        GDPRConsentLog.SetFilter("Data Subject Id", '=%1', DataSubjectId);
        if (GDPRConsentLog.FindLast()) then;

        exit(GDPRConsentLog."Entry Approval State");
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnNewAgreementVersion(AgreementNo: Code[20])
    begin
    end;
}

