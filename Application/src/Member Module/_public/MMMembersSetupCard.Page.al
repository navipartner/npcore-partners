﻿page 6060076 "NPR MM Members.Setup Card"
{
    Caption = 'Membership Setup Card';
    ContextSensitiveHelpPage = 'docs/entertainment/membership/intro/';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR MM Membership Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Community Code"; Rec."Community Code")
                {

                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked At"; Rec."Blocked At")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(Setup)
            {
                field("Membership Type"; Rec."Membership Type")
                {

                    ToolTip = 'Specifies the value of the Membership Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Information"; Rec."Member Information")
                {

                    ToolTip = 'Specifies the value of the Member Information field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Perpetual; Rec.Perpetual)
                {

                    ToolTip = 'Specifies the value of the Perpetual field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Role Assignment"; Rec."Member Role Assignment")
                {

                    ToolTip = 'Specifies the value of the Member Role Assignment field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Member Cardinality"; Rec."Membership Member Cardinality")
                {

                    ToolTip = 'Specifies the value of the Membership Member Cardinality field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Anonymous Member Cardinality"; Rec."Anonymous Member Cardinality")
                {

                    ToolTip = 'Specifies the value of the Anonymous Member Cardinality field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Confirm Member On Card Scan"; Rec."Confirm Member On Card Scan")
                {

                    ToolTip = 'Specifies the value of the Confirm Member On Card Scan field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Allow Membership Delete"; Rec."Allow Membership Delete")
                {

                    ToolTip = 'Specifies the value of the Allow Membership Delete field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew Model"; Rec."Auto-Renew Model")
                {

                    ToolTip = 'Specifies the value of the Auto-Renew Model field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Recurring Payment Code"; Rec."Recurring Payment Code")
                {

                    ToolTip = 'Specifies the value of the Recurring Payment Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                group("Age Verification")
                {
                    Caption = 'Age Verification';
                    field("Enable Age Verification"; Rec."Enable Age Verification")
                    {

                        ToolTip = 'Specifies the value of the Enable Age Verification field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Validate Age Against"; Rec."Validate Age Against")
                    {

                        ToolTip = 'Specifies the value of the Validate Age Against field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                }
            }
            group(Print)
            {
                field("POS Print Action"; Rec."POS Print Action")
                {

                    ToolTip = 'Specifies the value of the POS Print Action field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Web Service Print Action"; Rec."Web Service Print Action")
                {

                    ToolTip = 'Specifies the value of the Web Service Print Action field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                group(Account)
                {
                    field("Account Print Object Type"; Rec."Account Print Object Type")
                    {

                        ToolTip = 'Specifies the value of the Account Print Object Type field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Account Print Template Code"; Rec."Account Print Template Code")
                    {

                        ToolTip = 'Specifies the value of the Account Print Template Code field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Account Print Object ID"; Rec."Account Print Object ID")
                    {

                        ToolTip = 'Specifies the value of the Account Print Object ID field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                }
                group(Receipt)
                {
                    field("Receipt Print Object Type"; Rec."Receipt Print Object Type")
                    {

                        ToolTip = 'Specifies the value of the Receipt Print Object Type field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Receipt Print Template Code"; Rec."Receipt Print Template Code")
                    {

                        ToolTip = 'Specifies the value of the Receipt Print Template Code field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Receipt Print Object ID"; Rec."Receipt Print Object ID")
                    {

                        ToolTip = 'Specifies the value of the Receipt Print Object ID field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                }
                group(Membercard)
                {
                    field("Card Print Object Type"; Rec."Card Print Object Type")
                    {

                        ToolTip = 'Specifies the value of the Card Print Object Type field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Card Print Template Code"; Rec."Card Print Template Code")
                    {

                        ToolTip = 'Specifies the value of the Card Print Template Code field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Card Print Object ID"; Rec."Card Print Object ID")
                    {

                        ToolTip = 'Specifies the value of the Card Print Object ID field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                }
                group("Membercard Swipe")
                {
                    Caption = 'On Membercard Swipe';
                    field("Ticket Print Model"; Rec."Ticket Print Model")
                    {

                        ToolTip = 'Specifies the value of the Ticket Print Model field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Ticket Print Object Type"; Rec."Ticket Print Object Type")
                    {

                        ToolTip = 'Specifies the value of the Ticket Print Object Type field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Ticket Print Object ID"; Rec."Ticket Print Object ID")
                    {

                        ToolTip = 'Specifies the value of the Ticket Print Object ID field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Ticket Print Template Code"; Rec."Ticket Print Template Code")
                    {

                        ToolTip = 'Specifies the value of the Ticket Print Template Code field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                }
            }
            group("CRM & Loyalty")
            {
                field("Loyalty Card"; Rec."Loyalty Card")
                {

                    ToolTip = 'Specifies the value of the Loyalty Card field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Loyalty Code"; Rec."Loyalty Code")
                {

                    ToolTip = 'Specifies the value of the Loyalty Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Contact Config. Template Code"; Rec."Contact Config. Template Code")
                {

                    ToolTip = 'Specifies the value of the Contact Config. Template Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {

                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Create Welcome Notification"; Rec."Create Welcome Notification")
                {

                    ToolTip = 'Specifies the value of the Create Welcome Notification field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Create Renewal Notifications"; Rec."Create Renewal Notifications")
                {

                    ToolTip = 'Specifies the value of the Create Renewal Notifications field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Customer No."; Rec."Membership Customer No.")
                {

                    ToolTip = 'Specifies the value of the Membership Customer No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(Card)
            {
                field("Card Expire Date Calculation"; Rec."Card Expire Date Calculation")
                {

                    ToolTip = 'Specifies the value of the Card Expire Date Calculation field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number Scheme"; Rec."Card Number Scheme")
                {

                    ToolTip = 'Specifies the value of the Card Number Scheme field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number Prefix"; Rec."Card Number Prefix")
                {

                    ToolTip = 'Specifies the value of the Card Number Prefix field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number Length"; Rec."Card Number Length")
                {

                    ToolTip = 'Specifies the value of the Card Number Length field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number Validation"; Rec."Card Number Validation")
                {

                    ToolTip = 'Specifies the value of the Card Number Validation field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number No. Series"; Rec."Card Number No. Series")
                {

                    ToolTip = 'Specifies the value of the Card Number No. Series field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number Valid Until"; Rec."Card Number Valid Until")
                {

                    ToolTip = 'Specifies the value of the Card Number Valid Until field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Number Pattern"; Rec."Card Number Pattern")
                {

                    ToolTip = 'Specifies the value of the Card Number Pattern field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Enable NP Pass Integration"; Rec."Enable NP Pass Integration")
                {

                    ToolTip = 'Specifies the value of the Enable NP Pass Integration field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group("On Membercard Swipe")
            {
                field("Ticket Item Barcode"; Rec."Ticket Item Barcode")
                {

                    ToolTip = 'Specifies the value of the Ticket Item Barcode field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(GDPR)
            {
                field("GDPR Mode"; Rec."GDPR Mode")
                {

                    ToolTip = 'Specifies the value of the GDPR Mode field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("GDPR Agreement No."; Rec."GDPR Agreement No.")
                {

                    ToolTip = 'Specifies the value of the GDPR Agreement No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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

                ToolTip = 'Executes the Recurring Payment Setup action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }
}

