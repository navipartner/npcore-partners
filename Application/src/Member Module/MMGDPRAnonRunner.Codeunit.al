codeunit 6248192 "NPR MM GDPR Anon. Runner"
{
    Access = Internal;

    // Per-membership isolation wrapper for the batch in "NPR MM GDPR Management".OnRun. The Job Queue runs
    // that OnRun via a guarded Codeunit.Run. With the Customer GDPR V2 feature enabled, the
    // OnBeforeAnonymizeMembership subscriber throws for a customer that is not yet due, which would otherwise
    // abort the whole batch and starve every later membership. Running each membership through this codeunit's
    // guarded Run confines a failure to that one membership. The caller Commits pending writes before invoking
    // Run and after it returns (see "NPR MM GDPR Management".OnRun).

    trigger OnRun()
    var
        GDPRManagement: Codeunit "NPR MM GDPR Management";
        Membership: Record "NPR MM Membership";
        ReasonText: Text;
    begin
        if not Membership.Get(_MembershipEntryNo) then
            exit;

        // Read "Block Reason" once and reuse it for both branches: this keeps the batch's original two-phase
        // behaviour where a membership anonymized in this run is only considered for deletion in a later run
        // (AnonymizeMembership modifies a separate record instance, so this local snapshot stays unchanged).
        if Membership."Block Reason" <> Membership."Block Reason"::ANONYMIZED then
            GDPRManagement.AnonymizeMembership(_MembershipEntryNo, true, ReasonText);

        if Membership."Block Reason" = Membership."Block Reason"::ANONYMIZED then
            GDPRManagement.DeleteMembership(_MembershipEntryNo);
    end;

    var
        _MembershipEntryNo: Integer;

    procedure SetMembershipEntryNo(MembershipEntryNo: Integer)
    begin
        _MembershipEntryNo := MembershipEntryNo;
    end;
}
