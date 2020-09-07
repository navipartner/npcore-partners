page 6060076 "NPR MM Members.Setup Card"
{
    // MM1.25/TSA /20180119 CASE 302934
    // MM1.29/NPKNAV/20180524  CASE 313795 Transport MM1.29 - 24 May 2018
    // #334163/JDH /20181109 CASE 334163 Added Caption to Object
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019
    // MM1.42/TSA /20191105 CASE 375381 Added Auto-Renew setup fields
    // MM1.43/TSA /20200319 CASE 337112 Moved the ticket print setting to ticket tab
    // MM1.44/TSA /20200529 CASE 407401 Add Age Verification

    Caption = 'Membership Setup Card';
    PageType = Card;
    SourceTable = "NPR MM Membership Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
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
                    Editable = false;
                }
            }
            group(Setup)
            {
                field("Membership Type"; "Membership Type")
                {
                    ApplicationArea = All;
                }
                field("Member Information"; "Member Information")
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
                field("Membership Member Cardinality"; "Membership Member Cardinality")
                {
                    ApplicationArea = All;
                }
                field("Anonymous Member Cardinality"; "Anonymous Member Cardinality")
                {
                    ApplicationArea = All;
                }
                field("Confirm Member On Card Scan"; "Confirm Member On Card Scan")
                {
                    ApplicationArea = All;
                }
                field("Allow Membership Delete"; "Allow Membership Delete")
                {
                    ApplicationArea = All;
                }
                field("Auto-Renew Model"; "Auto-Renew Model")
                {
                    ApplicationArea = All;
                }
                field("Recurring Payment Code"; "Recurring Payment Code")
                {
                    ApplicationArea = All;
                }
                group("Age Verification")
                {
                    Caption = 'Age Verification';
                    field("Enable Age Verification"; "Enable Age Verification")
                    {
                        ApplicationArea = All;
                    }
                    field("Validate Age Against"; "Validate Age Against")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Print)
            {
                field("POS Print Action"; "POS Print Action")
                {
                    ApplicationArea = All;
                }
                field("Web Service Print Action"; "Web Service Print Action")
                {
                    ApplicationArea = All;
                }
                group(Account)
                {
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
                }
                group(Receipt)
                {
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
                }
                group(Membercard)
                {
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
                }
                group("Membercard Swipe")
                {
                    Caption = 'On Membercard Swipe';
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
                }
            }
            group("CRM & Loyalty")
            {
                field("Loyalty Card"; "Loyalty Card")
                {
                    ApplicationArea = All;
                }
                field("Loyalty Code"; "Loyalty Code")
                {
                    ApplicationArea = All;
                }
                field("Contact Config. Template Code"; "Contact Config. Template Code")
                {
                    ApplicationArea = All;
                }
                field("Customer Config. Template Code"; "Customer Config. Template Code")
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
                field("Membership Customer No."; "Membership Customer No.")
                {
                    ApplicationArea = All;
                }
            }
            group(Card)
            {
                field("Card Expire Date Calculation"; "Card Expire Date Calculation")
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
                }
                field("Enable NP Pass Integration"; "Enable NP Pass Integration")
                {
                    ApplicationArea = All;
                }
            }
            group("On Membercard Swipe")
            {
                field("Ticket Item Barcode"; "Ticket Item Barcode")
                {
                    ApplicationArea = All;
                }
            }
            group(GDPR)
            {
                field("GDPR Mode"; "GDPR Mode")
                {
                    ApplicationArea = All;
                }
                field("GDPR Agreement No."; "GDPR Agreement No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Recurring Payment Setup")
            {
                Caption = 'Recurring Payment Setup';
                Image = PaymentHistory;
                RunObject = Page "NPR MM Recur. Payment Setup";
                ApplicationArea=All;
            }
        }
    }
}

