page 6151368 "NPR MM AchActivitySetup"
{
    Extensible = False;

    Caption = 'Membership Achievements - Activity Setup';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM AchActivity";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Activity; Rec.Activity)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Activity field.';
                }
                field(EnableFromDate; Rec.EnableFromDate)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Enable From Date field.';
                }
                field(EnableUntilDate; Rec.EnableUntilDate)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Enable Until Date field.';
                }
                field(GoalCode; Rec.GoalCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Goal Code field.';
                    ShowMandatory = true;
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Weight field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Configure)
            {
                Caption = 'Configure Condition';
                ToolTip = 'This actions shows the conditions configured fot this activity.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = SetupLines;

                trigger OnAction()
                var
                    ActivityInterface: Interface "NPR MM AchActivity";
                    Condition: Record "NPR MM AchActivityCondition";
                    ConditionPage: Page "NPR MM AchActivityCondition";
                begin
                    ActivityInterface := Rec.Activity;
                    ActivityInterface.InitializeConditions(Rec.Code);
                    Commit();

                    Condition.FilterGroup(248);
                    Condition.SetFilter(ActivityCode, '=%1', Rec.Code);
                    Condition.FilterGroup(0);
                    ConditionPage.SetTableView(Condition);
                    ConditionPage.Run();
                end;
            }
        }
    }
}