page 6060138 "NPR MM Member Members.ListPart"
{

    Caption = 'Member Memberships';
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR MM Membership Role";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR MM Membership Card";
                    LookupPageID = "NPR MM Membership Card";
                }
                field("GDPR Approval"; "GDPR Approval")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GDPRConsentLog: Record "NPR GDPR Consent Log";
                        GDPRConsentLogPage: Page "NPR GDPR Consent Log";
                    begin
                        GDPRConsentLog.FilterGroup(2);
                        GDPRConsentLog.SetFilter("Agreement No.", '=%1', "GDPR Agreement No.");
                        GDPRConsentLog.SetFilter("Data Subject Id", '=%1', "GDPR Data Subject Id");
                        GDPRConsentLog.FilterGroup(0);
                        GDPRConsentLogPage.SetTableView(GDPRConsentLog);
                        GDPRConsentLogPage.RunModal();
                    end;
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR MM Membership Setup";
                    LookupPageID = "NPR MM Membership Setup";
                    TableRelation = "NPR MM Membership Setup".Code;
                }
                field("User Logon ID"; "User Logon ID")
                {
                    ApplicationArea = All;
                }
                field("Password Hash"; "Password Hash")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                }
                field("GDPR Agreement No."; "GDPR Agreement No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("GDPR Data Subject Id"; "GDPR Data Subject Id")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
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

