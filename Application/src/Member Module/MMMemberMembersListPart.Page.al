page 6060138 "NPR MM Member Members.ListPart"
{
    Extensible = False;

    Caption = 'Member Memberships';
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR MM Membership Role";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Membership No."; Rec."External Membership No.")
                {

                    DrillDownPageID = "NPR MM Membership Card";
                    LookupPageID = "NPR MM Membership Card";
                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRRetail;
                }
                field("GDPR Approval"; Rec."GDPR Approval")
                {

                    ToolTip = 'Specifies the value of the GDPR Approval field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
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
                    end;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    DrillDownPageID = "NPR MM Membership Setup";
                    LookupPageID = "NPR MM Membership Setup";
                    TableRelation = "NPR MM Membership Setup".Code;
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("User Logon ID"; Rec."User Logon ID")
                {

                    ToolTip = 'Specifies the value of the User Logon ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Password Hash"; Rec."Password Hash")
                {

                    ToolTip = 'Specifies the value of the Password field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked At"; Rec."Blocked At")
                {

                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRRetail;
                }
                field("GDPR Agreement No."; Rec."GDPR Agreement No.")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the GDPR Agreement No. field';
                    ApplicationArea = NPRRetail;
                }
                field("GDPR Data Subject Id"; Rec."GDPR Data Subject Id")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the GDPR Data Subject Id field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    procedure GetSelectedMembershipEntryNo(): Integer
    begin

        exit(Rec."Membership Entry No.");
    end;
}

