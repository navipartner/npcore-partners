page 6060138 "NPR MM Member Members.ListPart"
{

    Caption = 'Member Memberships';
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
                field("External Membership No."; Rec."External Membership No.")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR MM Membership Card";
                    LookupPageID = "NPR MM Membership Card";
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("GDPR Approval"; Rec."GDPR Approval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GDPR Approval field';

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
                    ApplicationArea = All;
                    DrillDownPageID = "NPR MM Membership Setup";
                    LookupPageID = "NPR MM Membership Setup";
                    TableRelation = "NPR MM Membership Setup".Code;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("User Logon ID"; Rec."User Logon ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Logon ID field';
                }
                field("Password Hash"; Rec."Password Hash")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Password field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field("GDPR Agreement No."; Rec."GDPR Agreement No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the GDPR Agreement No. field';
                }
                field("GDPR Data Subject Id"; Rec."GDPR Data Subject Id")
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

    procedure GetSelectedMembershipEntryNo(): Integer
    begin

        exit(Rec."Membership Entry No.");
    end;
}

