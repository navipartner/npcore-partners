page 6060124 "NPR MM Membership Setup"
{

    Caption = 'Membership Setup';
    CardPageID = "NPR MM Members.Setup Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Membership Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Membership Type"; "Membership Type")
                {
                    ApplicationArea = All;
                }
                field("Loyalty Card"; "Loyalty Card")
                {
                    ApplicationArea = All;
                }
                field("Loyalty Code"; "Loyalty Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Customer Config. Template Code"; "Customer Config. Template Code")
                {
                    ApplicationArea = All;
                }
                field("Contact Config. Template Code"; "Contact Config. Template Code")
                {
                    ApplicationArea = All;
                }
                field("Membership Customer No."; "Membership Customer No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Member Information"; "Member Information")
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
                field(Perpetual; Perpetual)
                {
                    ApplicationArea = All;
                }
                field("Member Role Assignment"; "Member Role Assignment")
                {
                    ApplicationArea = All;
                }
                field("Create Welcome Notification"; "Create Welcome Notification")
                {
                    ApplicationArea = All;
                }
                field("Create Renewal Notifications"; "Create Renewal Notifications")
                {
                    ApplicationArea = All;
                }
                field("Membership Member Cardinality"; "Membership Member Cardinality")
                {
                    ApplicationArea = All;
                }
                field("Anonymous Member Cardinality"; "Anonymous Member Cardinality")
                {
                    ApplicationArea = All;
                }
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                }
                field("Allow Membership Delete"; "Allow Membership Delete")
                {
                    ApplicationArea = All;
                }
                field("Confirm Member On Card Scan"; "Confirm Member On Card Scan")
                {
                    ApplicationArea = All;
                }
                field("Web Service Print Action"; "Web Service Print Action")
                {
                    ApplicationArea = All;
                }
                field("POS Print Action"; "POS Print Action")
                {
                    ApplicationArea = All;
                }
                field("Account Print Object Type"; "Account Print Object Type")
                {
                    ApplicationArea = All;
                }
                field("Account Print Template Code"; "Account Print Template Code")
                {
                    ApplicationArea = All;
                }
                field("Account Print Object ID"; "Account Print Object ID")
                {
                    ApplicationArea = All;
                }
                field("Receipt Print Object Type"; "Receipt Print Object Type")
                {
                    ApplicationArea = All;
                }
                field("Receipt Print Template Code"; "Receipt Print Template Code")
                {
                    ApplicationArea = All;
                }
                field("Receipt Print Object ID"; "Receipt Print Object ID")
                {
                    ApplicationArea = All;
                }
                field("Card Number Scheme"; "Card Number Scheme")
                {
                    ApplicationArea = All;
                }
                field("Card Number Prefix"; "Card Number Prefix")
                {
                    ApplicationArea = All;
                }
                field("Card Number Length"; "Card Number Length")
                {
                    ApplicationArea = All;
                }
                field("Card Number Validation"; "Card Number Validation")
                {
                    ApplicationArea = All;
                }
                field("Card Number No. Series"; "Card Number No. Series")
                {
                    ApplicationArea = All;
                }
                field("Card Number Valid Until"; "Card Number Valid Until")
                {
                    ApplicationArea = All;
                }
                field("Card Number Pattern"; "Card Number Pattern")
                {
                    ApplicationArea = All;
                    ToolTip = '<any text><[MA|MS|NS|N*x|A*x|X*x]><[...]><...>';
                }
                field("Card Print Object Type"; "Card Print Object Type")
                {
                    ApplicationArea = All;
                }
                field("Card Print Template Code"; "Card Print Template Code")
                {
                    ApplicationArea = All;
                }
                field("Card Print Object ID"; "Card Print Object ID")
                {
                    ApplicationArea = All;
                }
                field("Card Expire Date Calculation"; "Card Expire Date Calculation")
                {
                    ApplicationArea = All;
                }
                field("Ticket Item Barcode"; "Ticket Item Barcode")
                {
                    ApplicationArea = All;
                }
                field("Ticket Print Model"; "Ticket Print Model")
                {
                    ApplicationArea = All;
                }
                field("Ticket Print Object Type"; "Ticket Print Object Type")
                {
                    ApplicationArea = All;
                }
                field("Ticket Print Object ID"; "Ticket Print Object ID")
                {
                    ApplicationArea = All;
                }
                field("Ticket Print Template Code"; "Ticket Print Template Code")
                {
                    ApplicationArea = All;
                }
                field("GDPR Mode"; "GDPR Mode")
                {
                    ApplicationArea = All;
                }
                field("GDPR Agreement No."; "GDPR Agreement No.")
                {
                    ApplicationArea = All;
                }
                field("Enable NP Pass Integration"; "Enable NP Pass Integration")
                {
                    ApplicationArea = All;
                }
                field("Enable Age Verification"; "Enable Age Verification")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Validate Age Against"; "Validate Age Against")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Community)
            {
                Caption = 'Community';
                Image = Group;
                RunObject = Page "NPR MM Member Community";
                ApplicationArea = All;
            }
            action("Membership Sales Setup")
            {
                Caption = 'Membership Sales Setup';
                Image = SetupList;
                Promoted = true;
                RunObject = Page "NPR MM Membership Sales Setup";
                RunPageLink = "Membership Code" = FIELD(Code);
                ApplicationArea = All;
            }
            action("Membership Alteration")
            {
                Caption = 'Membership Alteration';
                Image = SetupList;
                Promoted = true;
                RunObject = Page "NPR MM Membership Alter.";
                RunPageLink = "From Membership Code" = FIELD(Code);
                ApplicationArea = All;
            }
            action("Member Communication Setup")
            {
                Caption = 'Member Communication Setup';
                Image = ChangeDimensions;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Comm. Setup";
                RunPageLink = "Membership Code" = FIELD(Code);
                ApplicationArea = All;
            }
            separator(Separator6014404)
            {
            }
            action("Membership Admission Setup")
            {
                Caption = 'Membership Admission Setup';
                Image = SetupLines;
                RunObject = Page "NPR MM Members. Admis. Setup";
                RunPageLink = "Membership  Code" = FIELD(Code);
                ApplicationArea = All;
            }
            action("Membership Limitation Setup")
            {
                Caption = 'Membership Limitation Setup';
                Ellipsis = true;
                Image = Lock;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Lim. Setup";
                RunPageLink = "Membership  Code" = FIELD(Code);
                ApplicationArea = All;
            }
            action("Sponsorship Ticket Setup")
            {
                Caption = 'Sponsorship Ticket Setup';
                Ellipsis = true;
                Image = SetupLines;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "NPR MM Sponsors. Ticket Setup";
                RunPageLink = "Membership Code" = FIELD(Code);
                ApplicationArea = All;
            }
            separator(Separator6014405)
            {
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = List;
                RunObject = Page "NPR MM Memberships";
                RunPageLink = "Membership Code" = FIELD(Code);
                ApplicationArea = All;
            }
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "NPR Retail Item List";
                ApplicationArea = All;
            }
            separator(Separator6014416)
            {
            }
            action("Turnstile Setup")
            {
                Caption = 'Turnstile Setup';
                Ellipsis = true;
                Image = BarCode;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Admission Service Setup";
                ApplicationArea = All;
            }
        }
    }

    trigger OnOpenPage()
    begin

        Rec.SetFilter(Blocked, '=%1', false);
    end;
}

