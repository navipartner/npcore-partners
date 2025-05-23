﻿page 6060128 "NPR MM Members.Member ListPart"
{
    Extensible = False;

    Caption = 'Membership Members';
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR MM Membership Role";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Member Role"; Rec."Member Role")
                {

                    ToolTip = 'Specifies the value of the Member Role field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Member No."; Rec."External Member No.")
                {

                    DrillDownPageID = "NPR MM Member Card";
                    LookupPageID = "NPR MM Member Card";
                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Display Name"; Rec."Member Display Name")
                {

                    ToolTip = 'Specifies the value of the Member Display Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("GDPR Approval"; Rec."GDPR Approval")
                {

                    ToolTip = 'Specifies the value of the GDPR Approval field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnDrillDown()
                    var
                        GDPRConsentLog: Record "NPR GDPR Consent Log";
                        GDPRConsentLogPage: Page "NPR GDPR Consent Log";
                    begin
                        GDPRConsentLog.FilterGroup(2);
                        GDPRConsentLog.SetFilter("Agreement No.", '=%1', Rec."GDPR Agreement No.");
                        GDPRConsentLog.SetFilter("Data Subject Id", '=%1', Rec."GDPR Data Subject Id");
                        GDPRConsentLog.FilterGroup(0);
                        GDPRConsentLogPage.SetTableView(GDPRConsentLog);
                        GDPRConsentLogPage.RunModal();
                        CurrPage.Update(false);
                    end;
                }
                field("User Logon ID"; Rec."User Logon ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the User Logon ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Password Hash"; Rec."Password Hash")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Password field';
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
                field("Member Count"; Rec."Member Count")
                {

                    ToolTip = 'Specifies the value of the Member Count field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("GDPR Agreement No."; Rec."GDPR Agreement No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the GDPR Agreement No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("GDPR Data Subject Id"; Rec."GDPR Data Subject Id")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the GDPR Data Subject Id field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin

        Rec.SetFilter("Member Role", '<> %1', Rec."Member Role"::ANONYMOUS);
    end;
}

