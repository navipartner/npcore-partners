page 6060087 "NPR MM Membership Lim. Setup"
{
    Extensible = False;

    Caption = 'Membership Limitation Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Membership Lim. Setup";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership  Code"; Rec."Membership  Code")
                {

                    ToolTip = 'Specifies the value of the Membership  Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Admission Code"; Rec."Admission Code")
                {

                    ToolTip = 'Specifies the value of the Admission Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Constraint Type"; Rec."Constraint Type")
                {

                    ToolTip = 'Specifies the value of the Constraint Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Constraint Source"; Rec."Constraint Source")
                {

                    ToolTip = 'Specifies the value of the Constraint Source field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Constraint Seconds"; Rec."Constraint Seconds")
                {

                    ToolTip = 'Specifies the value of the Constraint Seconds field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Constraint From Time"; Rec."Constraint From Time")
                {

                    ToolTip = 'Specifies the value of the Constraint From Time field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Constraint Until Time"; Rec."Constraint Until Time")
                {

                    ToolTip = 'Specifies the value of the Constraint Until Time field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Constraint Dateformula"; Rec."Constraint Dateformula")
                {

                    ToolTip = 'Specifies the value of the Constraint Dateformula field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Event Type"; Rec."Event Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Event Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Event Limit"; Rec."Event Limit")
                {

                    ToolTip = 'Specifies the value of the Event Limit field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("POS Response Action"; Rec."POS Response Action")
                {

                    ToolTip = 'Specifies the value of the POS Response Action field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("POS Response Message"; Rec."POS Response Message")
                {

                    ToolTip = 'Specifies the value of the POS Response Message field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("WS Response Action"; Rec."WS Response Action")
                {

                    ToolTip = 'Specifies the value of the WS Response Action field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("WS Deny Message"; Rec."WS Deny Message")
                {

                    ToolTip = 'Specifies the value of the WS Deny Message field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Response Code"; Rec."Response Code")
                {

                    ToolTip = 'Specifies the value of the Response Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
    }
}

