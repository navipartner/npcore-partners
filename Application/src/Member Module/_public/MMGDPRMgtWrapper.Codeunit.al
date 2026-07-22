codeunit 6151074 "NPR MM GDPR Mgt. Wrapper"
{
    var
        GDPRMgt: Codeunit "NPR MM GDPR Management";

    procedure AnonymizeMembership(MembershipEntryNo: Integer; AgreementCheck: Boolean; var ReasonText: Text): Boolean
    begin
        exit(GDPRMgt.AnonymizeMembership(MembershipEntryNo, AgreementCheck, ReasonText));
    end;

    procedure AnonymizeMember(MemberEntryNo: Integer; AgreementCheck: Boolean; var ReasonText: Text): Boolean
    begin
        exit(GDPRMgt.AnonymizeMember(MemberEntryNo, AgreementCheck, ReasonText));
    end;

    procedure DeleteMembership(MembershipEntryNo: Integer): Boolean
    begin
        exit(GDPRMgt.DeleteMembership(MembershipEntryNo));
    end;

    procedure SetApprovalState(AgreementNo: Code[20]; DataSubjectId: Text[35]; ApprovalState: Option NA,PENDING,ACCEPTED,REJECTED)
    var
        MMGDPRManagement: Codeunit "NPR MM GDPR Management";
    begin
        MMGDPRManagement.SetApprovalState(AgreementNo, DataSubjectId, ApprovalState);
    end;
}