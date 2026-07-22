codeunit 6248193 "NPR GDPR Cust-Member Anon Run"
{
    Access = Internal;

    // Atomic isolation wrapper for the interactive "anonymize a customer who is also a member" request path
    // (page "NPR GDPR Anonymization Req."). BC SaaS does NOT roll back writes made inside a [TryFunction],
    // so the previous try-function version could leave a membership anonymized while the customer was not.
    // Running the whole cancel -> member-anonymize -> customer-anonymize sequence inside this codeunit's
    // guarded Codeunit.Run makes it one all-or-nothing transaction: if any step fails, every write rolls back.
    // The caller reads GetReason() after a successful Run and GetLastErrorText() after a failed Run.

    trigger OnRun()
    var
        GDPRManagement: Codeunit "NPR MM GDPR Management";
        NPGDPRManagement: Codeunit "NPR NP GDPR Management";
    begin
        _Reason := '';

        if not CancelMembership(_MembershipEntryNo) then
            Error(FailedToCancelMembershipErr);

        if not GDPRManagement.AnonymizeMembership(_MembershipEntryNo, false, _Reason) then
            Error(NonEmptyReason());

        if not NPGDPRManagement.DoAnonymization(_CustomerNo, _Reason) then
            Error(NonEmptyReason());
    end;

    var
        _CustomerNo: Code[20];
        _MembershipEntryNo: Integer;
        _Reason: Text;
        FailedToCancelMembershipErr: Label 'Failed to cancel membership.';
        AnonymizationNotCompletedLbl: Label 'The customer could not be anonymized.';

    procedure SetCustomer(CustomerNo: Code[20])
    begin
        _CustomerNo := CustomerNo;
    end;

    procedure SetMembership(MembershipEntryNo: Integer)
    begin
        _MembershipEntryNo := MembershipEntryNo;
    end;

    procedure GetReason(): Text
    begin
        exit(_Reason);
    end;

    internal procedure CancelMembership(MembershipEntryNo: Integer): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        MemberManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
    begin
        if not Membership.Get(MembershipEntryNo) then
            exit(false);

        Membership.Validate(Blocked, true);
        Membership."Block Reason" := Membership."Block Reason"::ANONYMIZED;
        Membership.Modify(true);

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Membership Code" := Membership."Membership Code";
        MemberInfoCapture."Item No." := GetItemNo(Membership."Membership Code");
        MemberInfoCapture.Insert();

        MemberManagement.CancelMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price");
        exit(true);
    end;

    local procedure GetItemNo(MembershipCode: Code[20]): Code[20]
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin
        if MembershipCode = '' then
            exit('');

        AlterationSetup.Reset();
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::CANCEL);
        AlterationSetup.SetRange("From Membership Code", MembershipCode);
        if AlterationSetup.FindFirst() then
            exit(AlterationSetup."Sales Item No.");
        exit('');
    end;

    local procedure NonEmptyReason(): Text
    begin
        // AnonymizeMembership/DoAnonymization can return false without setting a reason (e.g. "not time yet").
        // Never raise an empty Error, or GetLastErrorText() at the call site would be blank.
        if _Reason = '' then
            exit(AnonymizationNotCompletedLbl);
        exit(_Reason);
    end;
}
