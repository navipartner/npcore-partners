page 6151367 "NPR MM AchMemberActivityEntry"
{
    Extensible = False;

    Caption = 'Membership Achievements - Entries';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM AchActivityEntry";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field(ActivityCode; Rec.ActivityCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Activity Code field.';
                }
                field(GoalCode; Rec.GoalCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Goal Code field.';
                }
                field(ActivityDateTime; Rec.ActivityDateTime)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Activity Datetime field.';
                }
                field(ActivityWeight; Rec.ActivityWeight)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Activity Weight field.';
                }
                field(MembershipEntryNo; Rec.MembershipEntryNo)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Membership Entry No. field.';
                }
            }
        }
    }
}