page 6060128 "NPR MM Members.Member ListPart"
{
    // TM1.00/TSA/20151215  CASE 228982 NaviPartner Ticket Management
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.22/TSA /20170816 CASE 287080 Added field "Anonymous Member Count" and filter <> Anonymous
    // MM1.29/TSA /20180509 CASE 313795 Added GDPR fields

    Caption = 'Membership Members';
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
                field("Member Role"; "Member Role")
                {
                    ApplicationArea = All;
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR MM Member Card";
                    LookupPageID = "NPR MM Member Card";
                }
                field("Member Display Name"; "Member Display Name")
                {
                    ApplicationArea = All;
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
                field("User Logon ID"; "User Logon ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Password Hash"; "Password Hash")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                }
                field("Member Count"; "Member Count")
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

    trigger OnOpenPage()
    begin

        //-MM1.22 [287080]
        SetFilter("Member Role", '<> %1', "Member Role"::ANONYMOUS);
    end;
}

