codeunit 85114 "NPR Library - Member GDPR"
{
    internal procedure CreateBogusMembershipScenario_01(MembershipCode: Code[20])
    var
        ExpiredDate, NotExpiredDate : Date;
        MembershipEntryNo: Integer;
    begin
        ExpiredDate := CalcDate('<-10D>');
        NotExpiredDate := CalcDate('<+10D>');

        // Single member membership
        AddAdminMember(CreateMembership(ExpiredDate, MembershipCode));
        AddAdminMember(CreateMembership(NotExpiredDate, MembershipCode));

        // Dual member membership
        MembershipEntryNo := CreateMembership(ExpiredDate, MembershipCode);
        AddAdminMember(MembershipEntryNo);
        AddRegularMember(MembershipEntryNo);

        // 1 membership with dependant and 1 membership with dual member role guardian and admin
        MembershipEntryNo := CreateMembership(ExpiredDate, MembershipCode);
        AddDependantMember(MembershipEntryNo);
        AddGuardianRole(MembershipEntryNo, AddAdminMember(CreateMembership(ExpiredDate, MembershipCode)));
    end;

    internal procedure AnonymizeMembership(MembershipEntry: Integer)
    var
        GDPRManagement: Codeunit "NPR MM GDPR Management";
        ReasonText: Text;
    begin
        GDPRManagement.AnonymizeMembership(MembershipEntry, false, ReasonText);
    end;

    internal procedure CreateMembership(ValidUntilDate: Date; MembershipCode: Code[20]) EntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        // bare minimum
        Membership."Membership Code" := MembershipCode;
        Membership."Company Name" := 'Abc';
        Membership.Insert();

        MembershipEntry."Membership Entry No." := Membership."Entry No.";
        MembershipEntry."Valid Until Date" := ValidUntilDate;
        MembershipEntry."Valid From Date" := CalcDate('<-12M>', ValidUntilDate);
        MembershipEntry."Created At" := CreateDateTime(MembershipEntry."Valid From Date", Time());
        MembershipEntry.Insert();

        exit(Membership."Entry No.");
    end;

    internal procedure CreateMember(): Integer
    var
        Member: Record "NPR MM Member";
    begin
        Member.Insert();
        Member."First Name" := 'Foo';
        exit(Member."Entry No.");
    end;

    internal procedure AddAdminMember(MembershipEntryNo: Integer) EntryNo: Integer;
    begin
        EntryNo := CreateMember();
        AddAdminRole(MembershipEntryNo, EntryNo);
    end;

    internal procedure AddRegularMember(MembershipEntryNo: Integer) EntryNo: Integer;
    begin
        EntryNo := CreateMember();
        AddMemberRole(MembershipEntryNo, EntryNo);
    end;

    internal procedure AddDependantMember(MembershipEntryNo: Integer) EntryNo: Integer;
    begin
        EntryNo := CreateMember();
        AddDependantRole(MembershipEntryNo, EntryNo);
    end;

    internal procedure AddGuardianRole(DependentMembershipEntryNo: Integer; GuardianMemberEntryNo: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        AddRole(DependentMembershipEntryNo, GuardianMemberEntryNo, MembershipRole."Member Role"::GUARDIAN);
    end;

    internal procedure AddAdminRole(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        AddRole(MembershipEntryNo, MemberEntryNo, MembershipRole."Member Role"::ADMIN);
    end;

    internal procedure AddMemberRole(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        AddRole(MembershipEntryNo, MemberEntryNo, MembershipRole."Member Role"::MEMBER);
    end;

    internal procedure AddDependantRole(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        AddRole(MembershipEntryNo, MemberEntryNo, MembershipRole."Member Role"::DEPENDENT);
    end;

    internal procedure AddAnonymousRole(MembershipEntryNo: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        AddRole(MembershipEntryNo, 0, MembershipRole."Member Role"::ANONYMOUS);
    end;

    local procedure AddRole(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberRole: Option)
    var
        MembershipRole: Record "NPR MM Membership Role";

    begin
        If (MembershipEntryNo = 0) then
            Error('A role can not be created for membership entry 0');

        if (MemberEntryNo = 0) then
            if (MemberRole <> MembershipRole."Member Role"::ANONYMOUS) then
                Error('A role can not be created for member entry 0');

        MembershipRole."Membership Entry No." := MembershipEntryNo;
        MembershipRole."Member Role" := MemberRole;
        MembershipRole."Member Entry No." := MemberEntryNo;
        MembershipRole.Insert();
    end;

    // Assert collection for verifying objects are anonymized
    internal procedure Assert_AllIsAnonymized(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    begin
        Assert_MembershipIsAnonymized(MembershipEntryNo);
        Assert_MemberIsAnonymized(MemberEntryNo);
        Assert_RoleIsAnonymized(MembershipEntryNo, MemberEntryNo);
    end;

    internal procedure Assert_MemberIsAnonymized(MemberEntryNo: Integer)
    var
        Member: Record "NPR MM Member";
        Assert: Codeunit "Assert";
    begin
        Assert.IsTrue(Member.Get(MemberEntryNo), 'Member not found.');
        Assert.IsTrue(Member.Blocked, 'Anonymized member must be blocked.');
        Assert.AreEqual(Member."Block Reason"::ANONYMIZED, Member."Block Reason", 'Anonymized member has incorrect block reason.');

        Assert_IsAnonymousValue(Member."First Name", Member.FieldCaption("First Name"));
    end;

    internal procedure Assert_MembershipIsAnonymized(MembershipEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        Assert: Codeunit "Assert";
    begin
        Assert.IsTrue(Membership.Get(MembershipEntryNo), 'Membership not found.');
        Assert.IsTrue(Membership.Blocked, 'Anonymized membership must be blocked.');
        Assert.AreEqual(Membership."Block Reason"::ANONYMIZED, Membership."Block Reason", 'Anonymized membership has incorrect block reason.');

        Assert_IsAnonymousValue(Membership."Company Name", Membership.FieldCaption("Company Name"));
    end;

    internal procedure Assert_AllIsNotAnonymized(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    begin
        Assert_MembershipIsNotAnonymized(MembershipEntryNo);
        Assert_MemberIsNotAnonymized(MemberEntryNo);
        Assert_RoleIsNotAnonymized(MembershipEntryNo, MemberEntryNo);
    end;

    internal procedure Assert_RoleIsAnonymized(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MemberRole: Record "NPR MM Membership Role";
        Assert: Codeunit "Assert";
    begin
        Assert.IsTrue(MemberRole.Get(MembershipEntryNo, MemberEntryNo), 'Membership role not found.');
        Assert.IsTrue(MemberRole.Blocked, 'Anonymized membership role must be blocked.');
        Assert.AreEqual(MemberRole."Block Reason"::ANONYMIZED, MemberRole."Block Reason", 'Anonymized membership role has incorrect block reason.');
    end;

    internal procedure Assert_RoleIsNotAnonymized(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MemberRole: Record "NPR MM Membership Role";
        Assert: Codeunit "Assert";
    begin
        Assert.IsTrue(MemberRole.Get(MembershipEntryNo, MemberEntryNo), 'Membership role not found.');
        Assert.IsFalse(MemberRole.Blocked, 'Membership role should not be blocked.');
        Assert.AreNotEqual(MemberRole."Block Reason"::ANONYMIZED, MemberRole."Block Reason", 'Membership role has incorrect block reason.');
    end;

    internal procedure Assert_MemberIsNotAnonymized(MemberEntryNo: Integer)
    var
        Member: Record "NPR MM Member";
        Assert: Codeunit "Assert";
    begin
        Assert.IsTrue(Member.Get(MemberEntryNo), 'Member not found.');
        Assert.IsFalse(Member.Blocked, 'Member should not be blocked.');
        Assert.AreNotEqual(Member."Block Reason"::ANONYMIZED, Member."Block Reason", 'Member has incorrect block reason.');
    end;

    internal procedure Assert_MembershipIsNotAnonymized(MembershipEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        Assert: Codeunit "Assert";
    begin
        Assert.IsTrue(Membership.Get(MembershipEntryNo), 'Membership not found.');
        Assert.IsFalse(Membership.Blocked, 'Membership should be blocked.');
        Assert.AreNotEqual(Membership."Block Reason"::ANONYMIZED, Membership."Block Reason", 'Membership has incorrect block reason.');
    end;

    internal procedure Assert_IsAnonymousValue(FieldValue: Text; FieldCaption: Text)
    var
        Assert: Codeunit "Assert";
    begin
        Assert.AreEqual('', DelChr(FieldValue, '<=>', ' -'), StrSubstNo('Anonymized field %1 contains unexpected characters.', FieldCaption));
    end;

}