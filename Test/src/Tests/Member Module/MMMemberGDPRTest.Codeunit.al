codeunit 85115 "NPR MM Member GDPR Test"
{
    Subtype = Test;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_01_1()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        MembershipEntryNo, MemberEntryNo : Integer;
    begin
        MembershipEntryNo := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));
        MemberEntryNo := LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);

        LibraryMemberGDPR.AnonymizeMembership(MembershipEntryNo);
        LibraryMemberGDPR.DeleteMembership(MembershipEntryNo, CalcDate('<-2D>'));

        LibraryMemberGDPR.Assert_AllIsNotAnonymized(MembershipEntryNo, MemberEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_01_2()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        MembershipEntryNo, MemberEntryNo : Integer;
    begin
        MembershipEntryNo := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        MemberEntryNo := LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);

        LibraryMemberGDPR.AnonymizeMembership(MembershipEntryNo);
        LibraryMemberGDPR.DeleteMembership(MembershipEntryNo, CalcDate('<-2D>'));

        LibraryMemberGDPR.Assert_AllIsAnonymized(MembershipEntryNo, MemberEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_02_1()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        MembershipEntryNo, Member_1, Member_2 : Integer;
    begin
        MembershipEntryNo := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));
        Member_1 := LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);
        Member_2 := LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);

        LibraryMemberGDPR.AnonymizeMembership(MembershipEntryNo);

        LibraryMemberGDPR.Assert_AllIsNotAnonymized(MembershipEntryNo, Member_1);
        LibraryMemberGDPR.Assert_AllIsNotAnonymized(MembershipEntryNo, Member_2);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_02_2()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        MembershipEntryNo, Member_1, Member_2 : Integer;
    begin
        MembershipEntryNo := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        Member_1 := LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);
        Member_2 := LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);

        LibraryMemberGDPR.AnonymizeMembership(MembershipEntryNo);
        LibraryMemberGDPR.DeleteMembership(MembershipEntryNo, CalcDate('<-2D>'));

        LibraryMemberGDPR.Assert_AllIsAnonymized(MembershipEntryNo, Member_1);
        LibraryMemberGDPR.Assert_AllIsAnonymized(MembershipEntryNo, Member_2);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_03_1()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership_1, Membership_2, Member_1 : Integer;
    begin
        Membership_1 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));
        Membership_2 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));
        Member_1 := LibraryMemberGDPR.AddAdminMember(Membership_1);
        LibraryMemberGDPR.AddAdminRole(Membership_2, Member_1);

        LibraryMemberGDPR.AnonymizeMembership(Membership_1);
        LibraryMemberGDPR.AnonymizeMembership(Membership_2);

        LibraryMemberGDPR.Assert_AllIsNotAnonymized(Membership_1, Member_1);
        LibraryMemberGDPR.Assert_AllIsNotAnonymized(Membership_2, Member_1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_03_2()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership_1, Membership_2, Member_1 : Integer;
    begin
        Membership_1 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        Membership_2 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        Member_1 := LibraryMemberGDPR.AddAdminMember(Membership_1);
        LibraryMemberGDPR.AddAdminRole(Membership_2, Member_1);

        LibraryMemberGDPR.AnonymizeMembership(Membership_1);
        LibraryMemberGDPR.DeleteMembership(Membership_1, CalcDate('<-2D>'));

        LibraryMemberGDPR.Assert_AllIsAnonymized(Membership_1, Member_1);
        LibraryMemberGDPR.Assert_RoleIsAnonymized(Membership_2, Member_1);
        LibraryMemberGDPR.Assert_MembershipIsNotAnonymized(Membership_2);

        LibraryMemberGDPR.AnonymizeMembership(Membership_2);
        LibraryMemberGDPR.DeleteMembership(Membership_2);

        LibraryMemberGDPR.Assert_AllIsAnonymized(Membership_1, Member_1);
        LibraryMemberGDPR.Assert_AllIsAnonymized(Membership_2, Member_1);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_03_3()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership_1, Membership_2, Member_1 : Integer;
    begin
        Membership_1 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        Membership_2 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));

        Member_1 := LibraryMemberGDPR.AddAdminMember(Membership_1);
        LibraryMemberGDPR.AddAdminRole(Membership_2, Member_1);

        LibraryMemberGDPR.AnonymizeMembership(Membership_1);
        LibraryMemberGDPR.DeleteMembership(Membership_1, CalcDate('<-2D>'));

        LibraryMemberGDPR.Assert_MembershipIsAnonymized(Membership_1);
        LibraryMemberGDPR.Assert_RoleIsAnonymized(Membership_1, Member_1);
        LibraryMemberGDPR.Assert_MemberIsNotAnonymized(Member_1);
        LibraryMemberGDPR.Assert_RoleIsNotAnonymized(Membership_2, Member_1);
        LibraryMemberGDPR.Assert_MembershipIsNotAnonymized(Membership_2);

        LibraryMemberGDPR.AnonymizeMembership(Membership_2);
        LibraryMemberGDPR.DeleteMembership(Membership_2, CalcDate('<-2D>'));

        LibraryMemberGDPR.Assert_MembershipIsAnonymized(Membership_1);
        LibraryMemberGDPR.Assert_RoleIsAnonymized(Membership_1, Member_1);
        LibraryMemberGDPR.Assert_MemberIsNotAnonymized(Member_1);
        LibraryMemberGDPR.Assert_RoleIsNotAnonymized(Membership_2, Member_1);
        LibraryMemberGDPR.Assert_MembershipIsNotAnonymized(Membership_2);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_04_1()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership_1, Membership_2, Member_1, Member_2 : Integer;
    begin
        Membership_1 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));
        Membership_2 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));

        Member_1 := LibraryMemberGDPR.AddDependantMember(Membership_1);
        Member_2 := LibraryMemberGDPR.AddAdminMember(Membership_2);
        LibraryMemberGDPR.AddGuardianRole(Membership_1, Member_2);

        LibraryMemberGDPR.AnonymizeMembership(Membership_1);
        LibraryMemberGDPR.AnonymizeMembership(Membership_2);

        LibraryMemberGDPR.Assert_AllIsNotAnonymized(Membership_1, Member_1);
        LibraryMemberGDPR.Assert_AllIsNotAnonymized(Membership_2, Member_2);
        LibraryMemberGDPR.Assert_RoleIsNotAnonymized(Membership_1, Member_2);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_04_2()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership_1, Membership_2, Member_1, Member_2 : Integer;
    begin
        Membership_1 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));
        Membership_2 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));

        Member_1 := LibraryMemberGDPR.AddDependantMember(Membership_1);
        Member_2 := LibraryMemberGDPR.AddAdminMember(Membership_2);
        LibraryMemberGDPR.AddGuardianRole(Membership_1, Member_2);

        LibraryMemberGDPR.AnonymizeMembership(Membership_1);
        LibraryMemberGDPR.AnonymizeMembership(Membership_2);
        LibraryMemberGDPR.DeleteMembership(Membership_1, CalcDate('<-2D>'));
        LibraryMemberGDPR.DeleteMembership(Membership_2, CalcDate('<-2D>'));

        LibraryMemberGDPR.Assert_AllIsNotAnonymized(Membership_1, Member_1);
        LibraryMemberGDPR.Assert_MembershipIsAnonymized(Membership_2);
        LibraryMemberGDPR.Assert_RoleIsAnonymized(Membership_2, Member_2);
        LibraryMemberGDPR.Assert_MemberIsNotAnonymized(Member_2);
        LibraryMemberGDPR.Assert_RoleIsNotAnonymized(Membership_1, Member_2);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_04_3()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership_1, Membership_2, Member_1, Member_2 : Integer;
    begin
        Membership_1 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        Membership_2 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));

        Member_1 := LibraryMemberGDPR.AddDependantMember(Membership_1);
        Member_2 := LibraryMemberGDPR.AddAdminMember(Membership_2);
        LibraryMemberGDPR.AddGuardianRole(Membership_1, Member_2);

        LibraryMemberGDPR.AnonymizeMembership(Membership_1);
        LibraryMemberGDPR.AnonymizeMembership(Membership_2);

        LibraryMemberGDPR.Assert_AllIsAnonymized(Membership_1, Member_1);
        LibraryMemberGDPR.Assert_AllIsNotAnonymized(Membership_2, Member_2);
        LibraryMemberGDPR.Assert_RoleIsAnonymized(Membership_1, Member_2);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_04_4()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership_1, Membership_2, Member_1, Member_2 : Integer;
    begin
        Membership_1 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        Membership_2 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));

        Member_1 := LibraryMemberGDPR.AddDependantMember(Membership_1);
        Member_2 := LibraryMemberGDPR.AddAdminMember(Membership_2);
        LibraryMemberGDPR.AddGuardianRole(Membership_1, Member_2);

        LibraryMemberGDPR.AnonymizeMembership(Membership_1);
        LibraryMemberGDPR.AnonymizeMembership(Membership_2);

        LibraryMemberGDPR.Assert_AllIsAnonymized(Membership_1, Member_1);
        LibraryMemberGDPR.Assert_AllIsAnonymized(Membership_2, Member_2);
        LibraryMemberGDPR.Assert_RoleIsAnonymized(Membership_1, Member_2);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_05_1()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership_1, Membership_2, Membership_3, Member_1, Member_2, Member_3 : Integer;
    begin
        Membership_1 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        Membership_2 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));
        Membership_3 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));

        Member_1 := LibraryMemberGDPR.AddDependantMember(Membership_1);
        Member_2 := LibraryMemberGDPR.AddAdminMember(Membership_2);
        LibraryMemberGDPR.AddGuardianRole(Membership_1, Member_2);

        Member_3 := LibraryMemberGDPR.AddDependantMember(Membership_3);
        LibraryMemberGDPR.AddGuardianRole(Membership_3, Member_2);

        LibraryMemberGDPR.AnonymizeMembership(Membership_1);
        LibraryMemberGDPR.AnonymizeMembership(Membership_2);
        LibraryMemberGDPR.AnonymizeMembership(Membership_3);

        LibraryMemberGDPR.Assert_AllIsAnonymized(Membership_1, Member_1);

        LibraryMemberGDPR.Assert_AllIsNotAnonymized(Membership_2, Member_2);
        LibraryMemberGDPR.Assert_RoleIsAnonymized(Membership_1, Member_2);
        LibraryMemberGDPR.Assert_RoleIsAnonymized(Membership_3, Member_2);

        LibraryMemberGDPR.Assert_AllIsAnonymized(Membership_3, Member_3);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_05_2()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership_1, Membership_2, Membership_3, Member_1, Member_2, Member_3 : Integer;
    begin
        Membership_1 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));
        Membership_2 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        Membership_3 := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));

        Member_1 := LibraryMemberGDPR.AddDependantMember(Membership_1);
        Member_2 := LibraryMemberGDPR.AddAdminMember(Membership_2);
        LibraryMemberGDPR.AddGuardianRole(Membership_1, Member_2);

        Member_3 := LibraryMemberGDPR.AddDependantMember(Membership_3);
        LibraryMemberGDPR.AddGuardianRole(Membership_3, Member_2);

        LibraryMemberGDPR.AnonymizeMembership(Membership_1);
        LibraryMemberGDPR.AnonymizeMembership(Membership_2);
        LibraryMemberGDPR.AnonymizeMembership(Membership_3);

        LibraryMemberGDPR.Assert_AllIsNotAnonymized(Membership_1, Member_1);

        LibraryMemberGDPR.Assert_MemberIsNotAnonymized(Member_2);
        LibraryMemberGDPR.Assert_MembershipIsAnonymized(Membership_2);
        LibraryMemberGDPR.Assert_RoleIsAnonymized(Membership_2, Member_2);

        LibraryMemberGDPR.Assert_AllIsNotAnonymized(Membership_3, Member_3);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_06_1()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        MembershipEntryNo, MemberEntryNo : Integer;
    begin
        MembershipEntryNo := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<+10D>'));
        MemberEntryNo := LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);
        LibraryMemberGDPR.AddAnonymousRole(MembershipEntryNo);

        LibraryMemberGDPR.AnonymizeMembership(MembershipEntryNo);

        LibraryMemberGDPR.Assert_AllIsNotAnonymized(MembershipEntryNo, MemberEntryNo);
        LibraryMemberGDPR.Assert_RoleIsNotAnonymized(MembershipEntryNo, 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeBasic_06_2()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        MembershipEntryNo, MemberEntryNo : Integer;
    begin
        MembershipEntryNo := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        MemberEntryNo := LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);
        LibraryMemberGDPR.AddAnonymousRole(MembershipEntryNo);

        LibraryMemberGDPR.AnonymizeMembership(MembershipEntryNo);

        LibraryMemberGDPR.Assert_AllIsAnonymized(MembershipEntryNo, MemberEntryNo);
        LibraryMemberGDPR.Assert_RoleIsAnonymized(MembershipEntryNo, 0);
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeAgreement_01_1()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        MembershipEntryNo, MemberEntryNo : Integer;

    begin
        MembershipEntryNo := LibraryMemberGDPR.CreateGdprMembership(CalcDate('<-10D>'));
        MemberEntryNo := LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);

        LibraryMemberGDPR.AnonymizeMembershipAgreementCheck(MembershipEntryNo);
        LibraryMemberGDPR.DeleteMembership(MembershipEntryNo); // Should not delete membership since there is a keep time on agreement

        LibraryMemberGDPR.Assert_AllIsAnonymized(MembershipEntryNo, MemberEntryNo);

        LibraryMemberGDPR.DeleteMembership(MembershipEntryNo, CalcDate('<-2D>'));

        LibraryMemberGDPR.Assert_MembershipIsDeleted(MembershipEntryNo);
        LibraryMemberGDPR.Assert_MemberIsDeleted(MemberEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeAgreement_01_2()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        MembershipEntryNo, MemberEntryNo : Integer;
    begin
        MembershipEntryNo := LibraryMemberGDPR.CreateGdprMembership(CalcDate('<-5D>'));
        MemberEntryNo := LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);

        LibraryMemberGDPR.AnonymizeMembershipAgreementCheck(MembershipEntryNo); // Should not anonymize due to agreement.
        LibraryMemberGDPR.DeleteMembership(MembershipEntryNo); // Should not delete membership since membership is not anonymized

        LibraryMemberGDPR.Assert_AllIsNotAnonymized(MembershipEntryNo, MemberEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeAgreement_05_1()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership_1, Membership_2, Membership_3, Member_1, Member_2, Member_3 : Integer;
    begin
        Membership_1 := LibraryMemberGDPR.CreateGdprMembership(CalcDate('<-10D>'));
        Membership_2 := LibraryMemberGDPR.CreateGdprMembership(CalcDate('<+10D>'));
        Membership_3 := LibraryMemberGDPR.CreateGdprMembership(CalcDate('<-10D>'));

        Member_1 := LibraryMemberGDPR.AddDependantMember(Membership_1);
        Member_2 := LibraryMemberGDPR.AddAdminMember(Membership_2);
        LibraryMemberGDPR.AddGuardianRole(Membership_1, Member_2);

        Member_3 := LibraryMemberGDPR.AddDependantMember(Membership_3);
        LibraryMemberGDPR.AddGuardianRole(Membership_3, Member_2);

        LibraryMemberGDPR.AnonymizeMembership(Membership_1);
        LibraryMemberGDPR.AnonymizeMembership(Membership_2);
        LibraryMemberGDPR.AnonymizeMembership(Membership_3);
        LibraryMemberGDPR.DeleteMembership(Membership_1);
        LibraryMemberGDPR.DeleteMembership(Membership_2);
        LibraryMemberGDPR.DeleteMembership(Membership_3);

        LibraryMemberGDPR.Assert_AllIsAnonymized(Membership_1, Member_1);

        LibraryMemberGDPR.Assert_AllIsNotAnonymized(Membership_2, Member_2);
        LibraryMemberGDPR.Assert_RoleIsAnonymized(Membership_1, Member_2);
        LibraryMemberGDPR.Assert_RoleIsAnonymized(Membership_3, Member_2);

        LibraryMemberGDPR.Assert_AllIsAnonymized(Membership_3, Member_3);

        LibraryMemberGDPR.DeleteMembership(Membership_1, CalcDate('<-2D>'));
        LibraryMemberGDPR.DeleteMembership(Membership_2, CalcDate('<-2D>'));
        LibraryMemberGDPR.DeleteMembership(Membership_3, CalcDate('<-2D>'));

        LibraryMemberGDPR.Assert_AllIsNotAnonymized(Membership_2, Member_2);

        LibraryMemberGDPR.Assert_MembershipIsDeleted(Membership_1);
        LibraryMemberGDPR.Assert_MemberIsDeleted(Member_1);
        LibraryMemberGDPR.Assert_MembershipIsDeleted(Membership_3);
        LibraryMemberGDPR.Assert_MemberIsDeleted(Member_3);
    end;

}