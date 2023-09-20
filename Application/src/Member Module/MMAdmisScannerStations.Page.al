page 6060069 "NPR MM Admis. Scanner Stations"
{
    Extensible = False;

    Caption = 'MM Admission Scanner Stations';
    PageType = ListPart;
    CardPageId = "NPR Admis. Scanner Stat. Card";
    UsageCategory = None;
    SourceTable = "NPR MM Admis. Scanner Stations";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {

                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Guest Avatar"; Rec."Guest Avatar Image")
                {

                    ToolTip = 'Specifies the value of the Guest Avatar field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Turnstile Default Image"; Rec."Default Turnstile Image")
                {

                    ToolTip = 'Specifies the value of the Turnstile Default Image field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Turnstile Error Image"; Rec."Error Image of Turnstile")
                {

                    ToolTip = 'Specifies the value of the Turnstile Error Image field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Admission Code"; Rec."Admission Code")
                {

                    ToolTip = 'Specifies the value of the Admission Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Activated; Rec.Activated)
                {

                    ToolTip = 'Specifies the value of the Activated field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(IsMultiAdmissionGate; Rec.IsDynamicAdmissionGate)
                {

                    ToolTip = 'Specifies the value of the Is Multi-Admission Gate field. When true, the scanner station id is used to determine which admission to admit during ticket scan.';
                    ApplicationArea = NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            Action(NavigateDefaultAdmission)
            {
                ToolTip = 'Navigate to Admissions per Scanner Station';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Admissions per Scanner Station';
                Image = Default;
                Scope = Repeater;
                RunObject = Page "NPR TM POS Default Admission";
                RunPageLink = "Station Type" = const(SCANNER_STATION), "Station Identifier" = field("Scanner Station Id");
            }
        }

    }

}

