page 6060075 "NPR MM Members. Auto-Renew Log"
{
    Extensible = False;

    Caption = 'Membership Auto-Renew Log';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Member Info Capture";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Response Status"; Rec."Response Status")
                {

                    ToolTip = 'Specifies the value of the Response Status field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Response Message"; Rec."Response Message")
                {

                    ToolTip = 'Specifies the value of the Response Message field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Membership)
            {
                Caption = 'Membership';
                Image = CustomerList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Membership Entry No.");

                ToolTip = 'Executes the Membership action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }
}

