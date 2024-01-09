codeunit 6184718 "NPR MM AchievementFacade"
{

    #region RegisterActivity
    procedure RegisterActivity(ActivitySource: Enum "NPR MM AchActivity"; MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]])
    var
        ActivityInterface: Interface "NPR MM AchActivity";
    begin
        ActivityInterface := ActivitySource;
        ActivityInterface.RegisterActivity(MembershipEntryNo, GoalCode, ActivityCode, Constraints);
    end;

    procedure RegisterActivity(ActivitySource: Enum "NPR MM AchActivity"; MembershipEntryNo: Integer; Constraints: Dictionary of [Text[30], Text[30]])
    begin
        RegisterActivity(ActivitySource, MembershipEntryNo, '', '', Constraints);
    end;

    procedure RegisterActivity(ActivitySource: Enum "NPR MM AchActivity"; MembershipEntryNo: Integer)
    var
        Constraints: Dictionary of [Text[30], Text[30]];
    begin
        RegisterActivity(ActivitySource, MembershipEntryNo, Constraints);
    end;
    #endregion

    #region ReverseActivity
    procedure ReverseActivity(ActivitySource: Enum "NPR MM AchActivity"; MembershipEntryNo: Integer; GoalCode: Code[20]; ActivityCode: Code[20]; Constraints: Dictionary of [Text[30], Text[30]])
    var
        ActivityInterface: Interface "NPR MM AchActivity";
    begin
        ActivityInterface := ActivitySource;
        ActivityInterface.ReverseActivity(MembershipEntryNo, GoalCode, ActivityCode, Constraints);
    end;

    procedure ReverseActivity(ActivitySource: Enum "NPR MM AchActivity"; MembershipEntryNo: Integer; Constraints: Dictionary of [Text[30], Text[30]])
    begin
        ReverseActivity(ActivitySource, MembershipEntryNo, '', '', Constraints);
    end;

    procedure ReverseActivity(ActivitySource: Enum "NPR MM AchActivity"; MembershipEntryNo: Integer)
    var
        Constraints: Dictionary of [Text[30], Text[30]];
    begin
        ReverseActivity(ActivitySource, MembershipEntryNo, Constraints);
    end;
    #endregion
}