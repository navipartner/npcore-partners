codeunit 6151074 "NPR MM GDPR Mgt. Wrapper"
{
    var
        GDPRMgt: Codeunit "NPR MM GDPR Management";

    procedure AnonymizeMembership(MembershipEntryNo: Integer; AgreementCheck: Boolean; var ReasonText: Text): Boolean
    begin
        GDPRMgt.AnonymizeMembership(MembershipEntryNo, AgreementCheck, ReasonText);
    end;

    procedure AnonymizeMember(MemberEntryNo: Integer; AgreementCheck: Boolean; var ReasonText: Text) Anonymized: Boolean
    begin
        GDPRMgt.AnonymizeMember(MemberEntryNo, AgreementCheck, ReasonText);
    end;

    procedure DeleteMembership(MembershipEntryNo: Integer): Boolean
    begin
        GDPRMgt.DeleteMembership(MembershipEntryNo);
    end;
}