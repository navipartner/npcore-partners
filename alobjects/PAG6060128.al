page 6060128 "MM Membership Member ListPart"
{
    // TM1.00/TSA/20151215  CASE 228982 NaviPartner Ticket Management
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.22/TSA /20170816 CASE 287080 Added field "Anonymous Member Count" and filter <> Anonymous
    // MM1.29/TSA /20180509 CASE 313795 Added GDPR fields

    Caption = 'Membership Members';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "MM Membership Role";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Member Role";"Member Role")
                {
                }
                field("External Member No.";"External Member No.")
                {
                    DrillDownPageID = "MM Member Card";
                    LookupPageID = "MM Member Card";
                }
                field("Member Display Name";"Member Display Name")
                {
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
                field("User Logon ID";"User Logon ID")
                {
                    Visible = false;
                }
                field("Password Hash";"Password Hash")
                {
                    Visible = false;
                }
                field(Blocked;Blocked)
                {
                }
                field("Blocked At";"Blocked At")
                {
                }
                field("Member Count";"Member Count")
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

    trigger OnOpenPage()
    begin

        //-MM1.22 [287080]
        SetFilter ("Member Role", '<> %1', "Member Role"::ANONYMOUS);
    end;
}

