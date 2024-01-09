page 6151372 "NPR MM AchActivityCondition"
{
    Extensible = false;

    Caption = 'Membership Achievements - Activity Condition';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM AchActivityCondition";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ConditionName; Rec.ConditionName)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Condition Name field.';
                }
                field(ConditionValue; Rec.ConditionValue)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Condition Value field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
        }
    }
}