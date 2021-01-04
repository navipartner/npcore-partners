page 6060076 "NPR MM Members.Setup Card"
{

    Caption = 'Membership Setup Card';
    PageType = Card;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
            }
            group(Setup)
            {
                field("Membership Type"; "Membership Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Type field';
                }
                field("Member Information"; "Member Information")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Information field';
                }
                field(Perpetual; Perpetual)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Perpetual field';
                }
                field("Member Role Assignment"; "Member Role Assignment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Role Assignment field';
                }
                field("Membership Member Cardinality"; "Membership Member Cardinality")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Member Cardinality field';
                }
                field("Anonymous Member Cardinality"; "Anonymous Member Cardinality")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Anonymous Member Cardinality field';
                }
                field("Confirm Member On Card Scan"; "Confirm Member On Card Scan")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Confirm Member On Card Scan field';
                }
                field("Allow Membership Delete"; "Allow Membership Delete")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Membership Delete field';
                }
                field("Auto-Renew Model"; "Auto-Renew Model")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto-Renew Model field';
                }
                field("Recurring Payment Code"; "Recurring Payment Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recurring Payment Code field';
                }
                group("Age Verification")
                {
                    Caption = 'Age Verification';
                    field("Enable Age Verification"; "Enable Age Verification")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Enable Age Verification field';
                    }
                    field("Validate Age Against"; "Validate Age Against")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Validate Age Against field';
                    }
                }
            }
            group(Print)
            {
                field("POS Print Action"; "POS Print Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Print Action field';
                }
                field("Web Service Print Action"; "Web Service Print Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Print Action field';
                }
                group(Account)
                {
                    field("Account Print Object Type"; "Account Print Object Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Account Print Object Type field';
                    }
                    field("Account Print Template Code"; "Account Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Account Print Template Code field';
                    }
                    field("Account Print Object ID"; "Account Print Object ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Account Print Object ID field';
                    }
                }
                group(Receipt)
                {
                    field("Receipt Print Object Type"; "Receipt Print Object Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Receipt Print Object Type field';
                    }
                    field("Receipt Print Template Code"; "Receipt Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Receipt Print Template Code field';
                    }
                    field("Receipt Print Object ID"; "Receipt Print Object ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Receipt Print Object ID field';
                    }
                }
                group(Membercard)
                {
                    field("Card Print Object Type"; "Card Print Object Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Card Print Object Type field';
                    }
                    field("Card Print Template Code"; "Card Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Card Print Template Code field';
                    }
                    field("Card Print Object ID"; "Card Print Object ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Card Print Object ID field';
                    }
                }
                group("Membercard Swipe")
                {
                    Caption = 'On Membercard Swipe';
                    field("Ticket Print Model"; "Ticket Print Model")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ticket Print Model field';
                    }
                    field("Ticket Print Object Type"; "Ticket Print Object Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ticket Print Object Type field';
                    }
                    field("Ticket Print Object ID"; "Ticket Print Object ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ticket Print Object ID field';
                    }
                    field("Ticket Print Template Code"; "Ticket Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ticket Print Template Code field';
                    }
                }
            }
            group("CRM & Loyalty")
            {
                field("Loyalty Card"; "Loyalty Card")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Loyalty Card field';
                }
                field("Loyalty Code"; "Loyalty Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Loyalty Code field';
                }
                field("Contact Config. Template Code"; "Contact Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Config. Template Code field';
                }
                field("Customer Config. Template Code"; "Customer Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                }
                field("Create Welcome Notification"; "Create Welcome Notification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Welcome Notification field';
                }
                field("Create Renewal Notifications"; "Create Renewal Notifications")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Renewal Notifications field';
                }
                field("Membership Customer No."; "Membership Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Customer No. field';
                }
            }
            group(Card)
            {
                field("Card Expire Date Calculation"; "Card Expire Date Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Expire Date Calculation field';
                }
                field("Card Number Scheme"; "Card Number Scheme")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Scheme field';
                }
                field("Card Number Prefix"; "Card Number Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Prefix field';
                }
                field("Card Number Length"; "Card Number Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Length field';
                }
                field("Card Number Validation"; "Card Number Validation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Validation field';
                }
                field("Card Number No. Series"; "Card Number No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number No. Series field';
                }
                field("Card Number Valid Until"; "Card Number Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Valid Until field';
                }
                field("Card Number Pattern"; "Card Number Pattern")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Pattern field';
                }
                field("Enable NP Pass Integration"; "Enable NP Pass Integration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable NP Pass Integration field';
                }
            }
            group("On Membercard Swipe")
            {
                field("Ticket Item Barcode"; "Ticket Item Barcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Item Barcode field';
                }
            }
            group(GDPR)
            {
                field("GDPR Mode"; "GDPR Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GDPR Mode field';
                }
                field("GDPR Agreement No."; "GDPR Agreement No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GDPR Agreement No. field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Recurring Payment Setup action';
            }
        }
    }
}

