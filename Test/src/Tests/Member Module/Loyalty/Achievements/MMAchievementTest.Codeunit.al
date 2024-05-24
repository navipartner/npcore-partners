codeunit 85175 "NPR MM AchievementTest"
{
    Subtype = Test;

    var
        _IsInitialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivity_01()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", 7);

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        Assert.AreEqual(1, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivity_02()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", 7);
        Goal.Get(GoalCode);
        Goal.Activated := false;
        Goal.Modify();

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        Assert.AreEqual(0, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivity_03()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", 7);
        Goal.Get(GoalCode);
        Goal.EnableFromDate := 0D;
        Goal.EnableUntilDate := 0D;
        Goal.Modify();

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        Assert.AreEqual(1, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivity_04()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", 7);
        Goal.Get(GoalCode);
        Goal.EnableFromDate := 0D;
        Goal.EnableUntilDate := CalcDate('<-1D>');
        Goal.Modify();

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        Assert.AreEqual(0, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivity_05()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", 7);
        Goal.Get(GoalCode);
        Goal.EnableFromDate := 0D;
        Goal.EnableUntilDate := CalcDate('<-1D>');
        Goal.Modify();

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        Assert.AreEqual(0, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivity_06()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", 7);
        Goal.Get(GoalCode);
        Goal.EnableFromDate := CalcDate('<+1D');
        Goal.EnableUntilDate := CalcDate('<+10D>');
        Goal.Modify();

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        Assert.AreEqual(0, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivity_07()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", 7);
        Goal.Get(GoalCode);
        Goal.EnableFromDate := CalcDate('<-1D');
        Goal.EnableUntilDate := CalcDate('<+1D>');
        Goal.Modify();

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        Assert.AreEqual(1, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivity_10()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Activity: Record "NPR MM AchActivity";

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", 7);

        Activity.SetFilter(GoalCode, '=%1', GoalCode);
        Activity.SetFilter(Activity, '=%1', ActivityType::MANUAL);
        Activity.FindFirst();
        Activity.EnableFromDate := 0D;
        Activity.EnableUntilDate := CalcDate('<-1D>');
        Activity.Modify();

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        Assert.AreEqual(0, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivity_11()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Activity: Record "NPR MM AchActivity";

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", 7);

        Activity.SetFilter(GoalCode, '=%1', GoalCode);
        Activity.SetFilter(Activity, '=%1', ActivityType::MANUAL);
        Activity.FindFirst();
        Activity.EnableFromDate := CalcDate('<+1D>');
        Activity.EnableUntilDate := CalcDate('<+10D>');
        Activity.Modify();

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        Assert.AreEqual(0, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivity_12()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Activity: Record "NPR MM AchActivity";

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", 7);

        Activity.SetFilter(GoalCode, '=%1', GoalCode);
        Activity.SetFilter(Activity, '=%1', ActivityType::MANUAL);
        Activity.FindFirst();
        Activity.EnableFromDate := 0D;
        Activity.EnableUntilDate := 0D;
        Activity.Modify();

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        Assert.AreEqual(1, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivity_20()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership1: Record "NPR MM Membership";
        Membership2EntryNo: Integer;
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";

        Assert: Codeunit Assert;
    begin
        Membership1.Get(CreateMembershipAndMember());
        Membership2EntryNo := CreateMembershipAndMember();

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership1."Community Code", Membership1."Membership Code", 7);

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership1."Entry No.");
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership2EntryNo);

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership1."Entry No.");
        Goal.Get(GoalCode);

        Assert.AreEqual(1, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));

        // Membership2 should not have any activity
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership2EntryNo);
        Goal.Get(GoalCode);

        Assert.AreEqual(0, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivityAchieved_01()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Threshold, I : Integer;

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        Threshold := 7;
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", Threshold);

        // Manual adds weight 1
        for i := 1 to Threshold + 3 do
            ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(Threshold, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsTrue(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateManualActivityAchieved_02()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership1: Record "NPR MM Membership";
        Membership2EntryNo: Integer;
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Threshold, I : Integer;

        Assert: Codeunit Assert;
    begin
        Membership1.Get(CreateMembershipAndMember());
        Membership2EntryNo := CreateMembershipAndMember(); // Membership gets different community code and membership code

        Threshold := 7;
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership1."Community Code", Membership1."Membership Code", Threshold);

        // Manual adds weight 1
        for i := 1 to Threshold + 3 do begin
            ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership1."Entry No.");
            ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership2EntryNo);
        end;

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership1."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(Threshold, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsTrue(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));

        // Membership2 should not have any activity
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership2EntryNo);
        Goal.Get(GoalCode);

        Assert.AreEqual(0, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateArrivalActivity_01()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Constraints: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", 7);

        // Arrival adds weight 3
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", Constraints);

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        Assert.AreEqual(3, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateArrivalActivity_02()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Constraints: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        GoalCode := MemberLibrary.SetupAchievementScenarioSimple(Membership."Community Code", Membership."Membership Code", 7);

        // Arrival adds weight 3
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", Constraints);
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", Constraints);
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", Constraints);
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", Constraints);

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold but activity weight is added from last valid entry
        Assert.AreEqual(9, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsTrue(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateArrivalActivity_03()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        ConstraintsSetup: Dictionary of [Text[30], Text[30]];
        ConstraintsActivity: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        ConstraintsSetup.Add('AdmissionCode', 'foo');
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", 7, ConstraintsSetup);

        // Arrival adds weight 3
        ConstraintsActivity.Add('AdmissionCode', 'bar');
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity);
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity);

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(0, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateArrivalActivity_04()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        ConstraintsSetup: Dictionary of [Text[30], Text[30]];
        ConstraintsActivity: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        ConstraintsSetup.Add('AdmissionCode', 'foo');
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", 7, ConstraintsSetup);

        // Arrival adds weight 3
        ConstraintsActivity.Add('AdmissionCode', 'foo');
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity);
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity);

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(6, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateArrivalActivity_05()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        ConstraintsSetup: Dictionary of [Text[30], Text[30]];
        ConstraintsActivity: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Goal threshold is 7
        ConstraintsSetup.Add('AdmissionCode', 'foo');
        ConstraintsSetup.Add('Frequency', 'CD'); // limit to once per day
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", 7, ConstraintsSetup);

        // Arrival adds weight 3
        ConstraintsActivity.Add('AdmissionCode', 'foo');
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity);
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity);

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(3, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateAchievementActivity_01()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCodeArrival1, GoalCodeArrival2, GoalCodeArrival3, GoalCodeReward : Code[20];
        Goal: Record "NPR MM AchGoal";
        ConstraintsSetup1, ConstraintsSetup2, ConstraintsSetup3, ConstraintsSetup4, ConstraintsSetup5 : Dictionary of [Text[30], Text[30]];
        ConstraintsActivity1, ConstraintsActivity2, ConstraintsActivity3 : Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        // Create 3 arrival goals
        ConstraintsSetup1.Add('AdmissionCode', 'foo');
        GoalCodeArrival1 := MemberLibrary.CreateAchievementGoal('T-G-01', Membership."Community Code", Membership."Membership Code", 'T-G01-R', '', 3);
        MemberLibrary.CreateAchievementAddActivity(GoalCodeArrival1, 'T-G-A1', "NPR MM AchActivity"::MEMBER_ARRIVAL, 1, ConstraintsSetup1);

        ConstraintsSetup2.Add('AdmissionCode', 'bar');
        GoalCodeArrival2 := MemberLibrary.CreateAchievementGoal('T-G-02', Membership."Community Code", Membership."Membership Code", 'T-G02-R', '', 3);
        MemberLibrary.CreateAchievementAddActivity(GoalCodeArrival2, 'T-G-A2', "NPR MM AchActivity"::MEMBER_ARRIVAL, 1, ConstraintsSetup2);

        ConstraintsSetup3.Add('AdmissionCode', 'baz');
        GoalCodeArrival3 := MemberLibrary.CreateAchievementGoal('T-G-03', Membership."Community Code", Membership."Membership Code", 'T-G03-R', '', 3);
        MemberLibrary.CreateAchievementAddActivity(GoalCodeArrival3, 'T-G-A3', "NPR MM AchActivity"::MEMBER_ARRIVAL, 1, ConstraintsSetup3);

        // Create 1 achievement goal with activators for foo and bar arrival goal
        GoalCodeReward := MemberLibrary.CreateAchievementGoal('T-ACH-01', Membership."Community Code", Membership."Membership Code", 'T-ACH-R', '', 2);
        ConstraintsSetup4.Add('GoalFilter', GoalCodeArrival1);
        MemberLibrary.CreateAchievementAddActivity(GoalCodeReward, 'T-ACH-A1', "NPR MM AchActivity"::NAMED_ACHIEVEMENT, 1, ConstraintsSetup4);
        ConstraintsSetup5.Add('GoalFilter', GoalCodeArrival2);
        MemberLibrary.CreateAchievementAddActivity(GoalCodeReward, 'T-ACH-A2', "NPR MM AchActivity"::NAMED_ACHIEVEMENT, 1, ConstraintsSetup5);


        // #############
        // Adds to achievement goal
        // Arrival adds weight 3
        ConstraintsActivity1.Add('AdmissionCode', 'foo');
        ConstraintsActivity2.Add('AdmissionCode', 'bar');
        ConstraintsActivity3.Add('AdmissionCode', 'baz'); // should not contribute to 'foo' & 'bar' reward goal

        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity1);
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity1);
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity1);

        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity2);
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity2);

        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity3);
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity3);

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCodeReward);

        // Reward Goal is not reached
        Assert.AreEqual(1, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));


        // #############
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity3);
        Goal.Get(GoalCodeReward);

        // Reward Goal is not affected by 'baz' arrival goal being achieved
        Assert.AreEqual(1, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));

        // #############
        ActivityFacade.RegisterActivity(ActivityType::MEMBER_ARRIVAL, Membership."Entry No.", ConstraintsActivity2);
        Goal.Get(GoalCodeReward);

        // Reward Goal is reached
        Assert.AreEqual(2, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsTrue(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;




    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateActivityConditionFrequency_CD01()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Threshold, I : Integer;
        Constraints: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        Threshold := 7;
        Constraints.Add('Frequency', 'CD');
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", Threshold, Constraints);

        // Manual adds weight 1
        SimulateActivity(GoalCode, "NPR MM AchActivity"::MANUAL, Membership."Entry No.", Today(), 1);
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(1, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateActivityConditionFrequency_CD02()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Threshold, I : Integer;
        Constraints: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        Threshold := 7;
        Constraints.Add('Frequency', 'CD');
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", Threshold, Constraints);

        // Manual adds weight 1
        SimulateActivity(GoalCode, "NPR MM AchActivity"::MANUAL, Membership."Entry No.", CalcDate('<-1D>'), 1);
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No.");

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(2, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateActivityConditionFrequency_CW01()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Threshold, I : Integer;
        Constraints: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        Threshold := 7;
        Constraints.Add('Frequency', 'CW');
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", Threshold, Constraints);

        // Manual adds weight 1
        SimulateActivity(GoalCode, "NPR MM AchActivity"::MANUAL, Membership."Entry No.", Today(), 1);
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No."); // Should be blocked

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(1, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateActivityConditionFrequency_CW02()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Threshold, I : Integer;
        Constraints: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        Threshold := 7;
        Constraints.Add('Frequency', 'CW');
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", Threshold, Constraints);

        // Manual adds weight 1
        SimulateActivity(GoalCode, "NPR MM AchActivity"::MANUAL, Membership."Entry No.", CalcDate('<-1W>'), 1);
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No."); // Should work

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(2, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateActivityConditionFrequency_CM01()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Threshold, I : Integer;
        Constraints: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        Threshold := 7;
        Constraints.Add('Frequency', 'CM');
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", Threshold, Constraints);

        // Manual adds weight 1
        SimulateActivity(GoalCode, "NPR MM AchActivity"::MANUAL, Membership."Entry No.", Today(), 1);
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No."); // Should be blocked

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(1, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateActivityConditionFrequency_CM02()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Threshold, I : Integer;
        Constraints: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        Threshold := 7;
        Constraints.Add('Frequency', 'CM');
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", Threshold, Constraints);

        // Manual adds weight 1
        SimulateActivity(GoalCode, "NPR MM AchActivity"::MANUAL, Membership."Entry No.", CalcDate('<-1M>'), 1);
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No."); // Should work

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(2, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateActivityConditionWeekday_01()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Threshold, I : Integer;
        Constraints: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        Threshold := 7;
        Constraints.Add('Weekday', StrSubstNo('WD%1', Date2DWY(Today(), 1)));
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", Threshold, Constraints);

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No."); // Should work

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(1, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateActivityConditionWeekday_02()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Threshold, I : Integer;
        Constraints: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        Threshold := 7;
        Constraints.Add('Weekday', StrSubstNo('WD%1', (Date2DWY(Today(), 1) mod 7) + 1)); // day number for tomorrow
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", Threshold, Constraints);

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No."); // Should not work

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(0, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateActivityConditionMonth_01()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Threshold, I : Integer;
        Constraints: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        Threshold := 7;
        Constraints.Add('Month', StrSubstNo('M%1', Date2DMY(Today(), 2)));
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", Threshold, Constraints);

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No."); // Should work

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(1, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ValidateActivityConditionMonth_02()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        ActivityType: Enum "NPR MM AchActivity";
        ActivityFacade: Codeunit "NPR MM AchievementFacade";

        Membership: Record "NPR MM Membership";
        GoalCode: Code[20];
        Goal: Record "NPR MM AchGoal";
        Threshold, I : Integer;
        Constraints: Dictionary of [Text[30], Text[30]];

        Assert: Codeunit Assert;
    begin
        Membership.Get(CreateMembershipAndMember());

        Threshold := 7;
        Constraints.Add('Month', StrSubstNo('M%1', (Date2DMY(Today(), 2) mod 12) + 1)); // month number for next month
        GoalCode := MemberLibrary.SetupAchievementScenarioConstraints(Membership."Community Code", Membership."Membership Code", Threshold, Constraints);

        // Manual adds weight 1
        ActivityFacade.RegisterActivity(ActivityType::MANUAL, Membership."Entry No."); // Should not work

        Goal.SetAutoCalcFields(ActivityCount, AchievementAcquired);
        Goal.SetFilter(MembershipEntryNoFilter, '=%1', Membership."Entry No.");
        Goal.Get(GoalCode);

        // tops out at threshold
        Assert.AreEqual(0, Goal.ActivityCount, Goal.FieldCaption(ActivityCount));
        Assert.IsFalse(Goal.AchievementAcquired, Goal.FieldCaption(AchievementAcquired));
    end;


    local procedure Initialize()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
    begin
        if (_IsInitialized) then
            exit;

        MemberLibrary.Initialize();
        _IsInitialized := true;

    end;

    local procedure SimulateActivity(GoalCode: Code[20]; ActivityType: Enum "NPR MM AchActivity"; MembershipEntryNo: Integer; ActivityDate: Date; Weight: Integer)
    var
        Activity: Record "NPR MM AchActivity";
        ActivityEntry: Record "NPR MM AchActivityEntry";
    begin
        Activity.SetFilter(GoalCode, '=%1', GoalCode);
        Activity.SetFilter(Activity, '=%1', ActivityType);
        if (Activity.FindSet()) then begin
            repeat
                ActivityEntry.EntryNo := 0;
                ActivityEntry.MembershipEntryNo := MembershipEntryNo;
                ActivityEntry.GoalCode := GoalCode;
                ActivityEntry.ActivityCode := Activity.Code;
                ActivityEntry.ActivityDescription := Activity.Description;
                ActivityEntry.ActivityDateTime := CreateDateTime(ActivityDate, Time());
                ActivityEntry.ActivityWeight := Weight;
                ActivityEntry.Insert();
            until (Activity.Next() = 0);
        end;
    end;

    procedure CreateMembershipAndMember() MembershipEntryNo: Integer
    var
        MemberApiLibrary: Codeunit "NPR Library - Member XML API";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        LibraryInventory: Codeunit "NPR Library - Inventory";
        Assert: Codeunit Assert;
        ResponseMessage: Text;
        ApiStatus: Boolean;

        MemberItem: Record Item;
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        Membership: Record "NPR MM Membership";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberEntryNo: Integer;

        MembershipCode: Code[20];
        LoyaltyProgramCode: Code[20];
        Description: Text[50];
    begin

        Initialize();
        LibraryInventory.CreateItem(MemberItem);
        MembershipCode := MemberLibrary.GenerateCode20();
        MemberCommunity.Get(MemberLibrary.SetupCommunity_Simple());
        MembershipSetup.Get(MemberLibrary.SetupMembership_Simple(MemberCommunity.Code, MembershipCode, LoyaltyProgramCode, Description));
        MemberLibrary.SetupSimpleMembershipSalesItem(MemberItem."No.", MembershipCode);

        MemberApiLibrary.CreateMembership(MemberItem."No.", MembershipEntryNo, ResponseMessage);
        Membership.Get(MembershipEntryNo);

        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);
        MemberApiLibrary.AddMembershipMember(Membership, MemberInfoCapture, MemberEntryNo, ResponseMessage);
    end;

}