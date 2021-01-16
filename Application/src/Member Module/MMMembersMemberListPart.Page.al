page 6060128 "NPR MM Members.Member ListPart"
{

    Caption = 'Membership Members';
    InsertAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Member Role field';
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR MM Member Card";
                    LookupPageID = "NPR MM Member Card";
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("Member Display Name"; "Member Display Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Display Name field';
                }
                field("GDPR Approval"; "GDPR Approval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GDPR Approval field';

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
                    ToolTip = 'Specifies the value of the User Logon ID field';
                }
                field("Password Hash"; "Password Hash")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Password field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field("Member Count"; "Member Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Count field';
                }
                field("GDPR Agreement No."; "GDPR Agreement No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the GDPR Agreement No. field';
                }
                field("GDPR Data Subject Id"; "GDPR Data Subject Id")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the GDPR Data Subject Id field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin

        SetFilter("Member Role", '<> %1', "Member Role"::ANONYMOUS);
    end;
}

