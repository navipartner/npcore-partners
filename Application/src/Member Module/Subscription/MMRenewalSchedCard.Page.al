page 6185100 "NPR MM Renewal Sched Card"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR MM Renewal Sched Hdr";
    Extensible = false;
    Caption = 'Renewal Schedule';

    layout
    {
        area(Content)
        {
            group(General)
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
            part(SubForm; "NPR MM Renewal Sched Sub")
            {
                Caption = 'Lines';
                ShowFilter = false;
                SubPageLink = "Schedule Code" = FIELD(Code);
                UpdatePropagation = Both;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }

    }
}