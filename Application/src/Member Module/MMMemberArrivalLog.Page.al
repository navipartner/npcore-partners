page 6060088 "NPR MM Member Arrival Log"
{
    Extensible = False;

    Caption = 'Member Arrival Log';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Member Arr. Log Entry";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Event Type"; Rec."Event Type")
                {

                    ToolTip = 'Specifies the value of the Event Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Created At"; Rec."Created At")
                {

                    ToolTip = 'Specifies the value of the Created At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Local Date"; Rec."Local Date")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Local Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Local Time"; Rec."Local Time")
                {

                    ToolTip = 'Specifies the value of the Local Time field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Member No."; Rec."External Member No.")
                {

                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Card No."; Rec."External Card No.")
                {

                    ToolTip = 'Specifies the value of the External Card No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Admission Code"; Rec."Admission Code")
                {

                    ToolTip = 'Specifies the value of the Admission Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Response Type"; Rec."Response Type")
                {

                    ToolTip = 'Specifies the value of the Response Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Response Code"; Rec."Response Code")
                {

                    ToolTip = 'Specifies the value of the Response Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Response Rule Entry No."; Rec."Response Rule Entry No.")
                {

                    ToolTip = 'Specifies the value of the Response Rule Entry No. field';
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
    }
}

