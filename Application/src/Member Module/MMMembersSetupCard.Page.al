page 6060076 "NPR MM Members.Setup Card"
{

    Caption = 'Membership Setup Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Membership Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Community Code"; Rec."Community Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
            }
            group(Setup)
            {
                field("Membership Type"; Rec."Membership Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Type field';
                }
                field("Member Information"; Rec."Member Information")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Information field';
                }
                field(Perpetual; Rec.Perpetual)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Perpetual field';
                }
                field("Member Role Assignment"; Rec."Member Role Assignment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member Role Assignment field';
                }
                field("Membership Member Cardinality"; Rec."Membership Member Cardinality")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Member Cardinality field';
                }
                field("Anonymous Member Cardinality"; Rec."Anonymous Member Cardinality")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Anonymous Member Cardinality field';
                }
                field("Confirm Member On Card Scan"; Rec."Confirm Member On Card Scan")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Confirm Member On Card Scan field';
                }
                field("Allow Membership Delete"; Rec."Allow Membership Delete")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Membership Delete field';
                }
                field("Auto-Renew Model"; Rec."Auto-Renew Model")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto-Renew Model field';
                }
                field("Recurring Payment Code"; Rec."Recurring Payment Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recurring Payment Code field';
                }
                group("Age Verification")
                {
                    Caption = 'Age Verification';
                    field("Enable Age Verification"; Rec."Enable Age Verification")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Enable Age Verification field';
                    }
                    field("Validate Age Against"; Rec."Validate Age Against")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Validate Age Against field';
                    }
                }
            }
            group(Print)
            {
                field("POS Print Action"; Rec."POS Print Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Print Action field';
                }
                field("Web Service Print Action"; Rec."Web Service Print Action")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Print Action field';
                }
                group(Account)
                {
                    field("Account Print Object Type"; Rec."Account Print Object Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Account Print Object Type field';
                    }
                    field("Account Print Template Code"; Rec."Account Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Account Print Template Code field';
                    }
                    field("Account Print Object ID"; Rec."Account Print Object ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Account Print Object ID field';
                    }
                }
                group(Receipt)
                {
                    field("Receipt Print Object Type"; Rec."Receipt Print Object Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Receipt Print Object Type field';
                    }
                    field("Receipt Print Template Code"; Rec."Receipt Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Receipt Print Template Code field';
                    }
                    field("Receipt Print Object ID"; Rec."Receipt Print Object ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Receipt Print Object ID field';
                    }
                }
                group(Membercard)
                {
                    field("Card Print Object Type"; Rec."Card Print Object Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Card Print Object Type field';
                    }
                    field("Card Print Template Code"; Rec."Card Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Card Print Template Code field';
                    }
                    field("Card Print Object ID"; Rec."Card Print Object ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Card Print Object ID field';
                    }
                }
                group("Membercard Swipe")
                {
                    Caption = 'On Membercard Swipe';
                    field("Ticket Print Model"; Rec."Ticket Print Model")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ticket Print Model field';
                    }
                    field("Ticket Print Object Type"; Rec."Ticket Print Object Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ticket Print Object Type field';
                    }
                    field("Ticket Print Object ID"; Rec."Ticket Print Object ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ticket Print Object ID field';
                    }
                    field("Ticket Print Template Code"; Rec."Ticket Print Template Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Ticket Print Template Code field';
                    }
                }
            }
            group("CRM & Loyalty")
            {
                field("Loyalty Card"; Rec."Loyalty Card")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Loyalty Card field';
                }
                field("Loyalty Code"; Rec."Loyalty Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Loyalty Code field';
                }
                field("Contact Config. Template Code"; Rec."Contact Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Config. Template Code field';
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                }
                field("Create Welcome Notification"; Rec."Create Welcome Notification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Welcome Notification field';
                }
                field("Create Renewal Notifications"; Rec."Create Renewal Notifications")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Renewal Notifications field';
                }
                field("Membership Customer No."; Rec."Membership Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Customer No. field';
                }
            }
            group(Card)
            {
                field("Card Expire Date Calculation"; Rec."Card Expire Date Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Expire Date Calculation field';
                }
                field("Card Number Scheme"; Rec."Card Number Scheme")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Scheme field';
                }
                field("Card Number Prefix"; Rec."Card Number Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Prefix field';
                }
                field("Card Number Length"; Rec."Card Number Length")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Length field';
                }
                field("Card Number Validation"; Rec."Card Number Validation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Validation field';
                }
                field("Card Number No. Series"; Rec."Card Number No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number No. Series field';
                }
                field("Card Number Valid Until"; Rec."Card Number Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Valid Until field';
                }
                field("Card Number Pattern"; Rec."Card Number Pattern")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Number Pattern field';
                }
                field("Enable NP Pass Integration"; Rec."Enable NP Pass Integration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable NP Pass Integration field';
                }
            }
            group("On Membercard Swipe")
            {
                field("Ticket Item Barcode"; Rec."Ticket Item Barcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Item Barcode field';
                }
            }
            group(GDPR)
            {
                field("GDPR Mode"; Rec."GDPR Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the GDPR Mode field';
                }
                field("GDPR Agreement No."; Rec."GDPR Agreement No.")
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

