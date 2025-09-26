page 6185099 "NPR MM Renewal Sched List"
{
    PageType = List;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    UsageCategory = Administration;
    SourceTable = "NPR MM Renewal Sched Hdr";
    CardPageId = "NPR MM Renewal Sched Card";
    Extensible = false;
    Caption = 'Renewal Schedules';
    InsertAllowed = true;
    ModifyAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the code of the renewal schedule.';
                }
                field(Description; Rec."Description")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the description of the renewal schedule.';
                }
            }
        }
    }
}