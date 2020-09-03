page 6060138 "NPR MM Member Members.ListPart"
{
    // TM1.00/TSA/20151215  CASE 228982 NaviPartner Ticket Management
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.29/TSA /20180509 CASE 313795 Added GDPR fields
    // MM1.29/TSA /20180509 CASE 313795 New function GetSelectedMembershipEntryNo()

    Caption = 'Member Memberships';
    InsertAllowed = false;
    PageType = ListPart;
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

