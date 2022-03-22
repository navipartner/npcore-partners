page 6014634 "NPR MM Member Card FactBox"
{
    Extensible = False;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR MM Member Card";
    Editable = false;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Details';
                field("External Card No."; Rec."External Card No.")
                {
                    ToolTip = 'Specifies the value of the External Card No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid Until"; Rec."Valid Until")
                {
                    ToolTip = 'Specifies the value of the Valid Until field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Is Temporary"; Rec."Card Is Temporary")
                {
                    ToolTip = 'Specifies the value of the Card Is Temporary field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Document ID"; Rec."Document ID")
                {
                    ToolTip = 'Specifies the value of the Document ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Pin Code"; Rec."Pin Code")
                {
                    ToolTip = 'Specifies the value of the Pin Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Type"; Rec."Card Type")
                {
                    ToolTip = 'Specifies the value of the Card Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }

            }

            group(GroupTwo)
            {
                Caption = 'Member Details';

                field("Display Name"; Rec."Display Name")
                {
                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Member Card";
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Member Card";
                }
                field("External Member No."; Rec."External Member No.")
                {
                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Member Card";
                }
                field("Member Blocked"; Rec."Member Blocked")
                {
                    ToolTip = 'Specifies the value of the Member Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Member Card";
                }
            }

            group(Membership)
            {
                Caption = 'Membership Details';

                field("External Membership No."; Rec."External Membership No.")
                {
                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Membership Card";
                }
                field("Company Name"; Rec."Company Name")
                {
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Membership Card";
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Membership Card";
                }
                field("Membership Blocked"; Rec."Membership Blocked")
                {
                    ToolTip = 'Specifies the value of the Membership Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Membership Card";
                }

            }

            group(SystemFields)
            {
                Caption = 'System';

                field("Block Reason"; Rec."Block Reason")
                {
                    ToolTip = 'Specifies the value of the Block Reason field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked By"; Rec."Blocked By")
                {
                    ToolTip = 'Specifies the value of the Blocked By field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }

                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Entry No."; Rec."Member Entry No.")
                {
                    ToolTip = 'Specifies the value of the Member Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

}
