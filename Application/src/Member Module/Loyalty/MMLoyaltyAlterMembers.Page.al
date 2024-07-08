page 6151163 "NPR MM Loyalty Alter Members."
{
    Extensible = False;

    Caption = 'Loyalty Alter Membership';
    PageType = List;
    UsageCategory = None;

    SourceTable = "NPR MM Loyalty Alter Members.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Loyalty Code"; Rec."Loyalty Code")
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("From Membership Code"; Rec."From Membership Code")
                {

                    ToolTip = 'Specifies the value of the From Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Change Direction"; Rec."Change Direction")
                {

                    ToolTip = 'Specifies the value of the Change Direction field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("To Membership Code"; Rec."To Membership Code")
                {

                    ToolTip = 'Specifies the value of the To Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Points Threshold"; Rec."Points Threshold")
                {

                    ToolTip = 'Specifies the value of the Points Threshold field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Sales Item No."; Rec."Sales Item No.")
                {

                    ToolTip = 'Specifies the value of the Sales Item No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
    }
}

