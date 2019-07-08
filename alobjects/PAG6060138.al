page 6060138 "MM Member Membership ListPart"
{
    // TM1.00/TSA/20151215  CASE 228982 NaviPartner Ticket Management
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.29/TSA /20180509 CASE 313795 Added GDPR fields
    // MM1.29/TSA /20180509 CASE 313795 New function GetSelectedMembershipEntryNo()

    Caption = 'Member Memberships';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "MM Membership Role";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Membership No.";"External Membership No.")
                {
                    DrillDownPageID = "MM Membership Card";
                    LookupPageID = "MM Membership Card";
                }
                field("GDPR Approval";"GDPR Approval")
                {

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GDPRConsentLog: Record "GDPR Consent Log";
                        GDPRConsentLogPage: Page "GDPR Consent Log";
                    begin
                        GDPRConsentLog.FilterGroup (2);
                        GDPRConsentLog.SetFilter ("Agreement No.", '=%1', "GDPR Agreement No.");
                        GDPRConsentLog.SetFilter ("Data Subject Id", '=%1', "GDPR Data Subject Id");
                        GDPRConsentLog.FilterGroup (0);
                        GDPRConsentLogPage.SetTableView (GDPRConsentLog);
                        GDPRConsentLogPage.RunModal ();
                    end;
                }
                field("Membership Code";"Membership Code")
                {
                    DrillDownPageID = "MM Membership Setup";
                    LookupPageID = "MM Membership Setup";
                    TableRelation = "MM Membership Setup".Code;
                }
                field("User Logon ID";"User Logon ID")
                {
                }
                field("Password Hash";"Password Hash")
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("Blocked At";"Blocked At")
                {
                }
                field("GDPR Agreement No.";"GDPR Agreement No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("GDPR Data Subject Id";"GDPR Data Subject Id")
                {
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

        exit (Rec."Membership Entry No.");
    end;
}

