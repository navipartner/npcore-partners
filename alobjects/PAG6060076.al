page 6060076 "MM Membership Setup Card"
{
    // MM1.25/TSA /20180119 CASE 302934
    // MM1.29/NPKNAV/20180524  CASE 313795 Transport MM1.29 - 24 May 2018
    // #334163/JDH /20181109 CASE 334163 Added Caption to Object
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019
    // MM1.42/TSA /20191105 CASE 375381 Added Auto-Renew setup fields
    // MM1.43/TSA /20200319 CASE 337112 Moved the ticket print setting to ticket tab

    Caption = 'Membership Setup Card';
    PageType = Card;
    SourceTable = "MM Membership Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Community Code";"Community Code")
                {
                }
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("Blocked At";"Blocked At")
                {
                    Editable = false;
                }
            }
            group(Setup)
            {
                field("Membership Type";"Membership Type")
                {
                }
                field("Member Information";"Member Information")
                {
                }
                field(Perpetual;Perpetual)
                {
                }
                field("Member Role Assignment";"Member Role Assignment")
                {
                }
                field("Membership Member Cardinality";"Membership Member Cardinality")
                {
                }
                field("Anonymous Member Cardinality";"Anonymous Member Cardinality")
                {
                }
                field("Confirm Member On Card Scan";"Confirm Member On Card Scan")
                {
                }
                field("Allow Membership Delete";"Allow Membership Delete")
                {
                }
                field("Auto-Renew Model";"Auto-Renew Model")
                {
                }
                field("Recurring Payment Code";"Recurring Payment Code")
                {
                }
            }
            group(Print)
            {
                field("POS Print Action";"POS Print Action")
                {
                }
                field("Web Service Print Action";"Web Service Print Action")
                {
                }
                group(Account)
                {
                    field("Account Print Object Type";"Account Print Object Type")
                    {
                    }
                    field("Account Print Template Code";"Account Print Template Code")
                    {
                    }
                    field("Account Print Object ID";"Account Print Object ID")
                    {
                    }
                }
                group(Receipt)
                {
                    field("Receipt Print Object Type";"Receipt Print Object Type")
                    {
                    }
                    field("Receipt Print Template Code";"Receipt Print Template Code")
                    {
                    }
                    field("Receipt Print Object ID";"Receipt Print Object ID")
                    {
                    }
                }
                group(Membercard)
                {
                    field("Card Print Object Type";"Card Print Object Type")
                    {
                    }
                    field("Card Print Template Code";"Card Print Template Code")
                    {
                    }
                    field("Card Print Object ID";"Card Print Object ID")
                    {
                    }
                }
                group("Membercard Swipe")
                {
                    Caption = 'On Membercard Swipe';
                    field("Ticket Print Model";"Ticket Print Model")
                    {
                    }
                    field("Ticket Print Object Type";"Ticket Print Object Type")
                    {
                    }
                    field("Ticket Print Object ID";"Ticket Print Object ID")
                    {
                    }
                    field("Ticket Print Template Code";"Ticket Print Template Code")
                    {
                    }
                }
            }
            group("CRM & Loyalty")
            {
                field("Loyalty Card";"Loyalty Card")
                {
                }
                field("Loyalty Code";"Loyalty Code")
                {
                }
                field("Contact Config. Template Code";"Contact Config. Template Code")
                {
                }
                field("Customer Config. Template Code";"Customer Config. Template Code")
                {
                }
                field("Create Welcome Notification";"Create Welcome Notification")
                {
                }
                field("Create Renewal Notifications";"Create Renewal Notifications")
                {
                }
                field("Membership Customer No.";"Membership Customer No.")
                {
                }
            }
            group(Card)
            {
                field("Card Expire Date Calculation";"Card Expire Date Calculation")
                {
                }
                field("Card Number Scheme";"Card Number Scheme")
                {
                }
                field("Card Number Prefix";"Card Number Prefix")
                {
                }
                field("Card Number Length";"Card Number Length")
                {
                }
                field("Card Number Validation";"Card Number Validation")
                {
                }
                field("Card Number No. Series";"Card Number No. Series")
                {
                }
                field("Card Number Valid Until";"Card Number Valid Until")
                {
                }
                field("Card Number Pattern";"Card Number Pattern")
                {
                }
                field("Enable NP Pass Integration";"Enable NP Pass Integration")
                {
                }
            }
            group("On Membercard Swipe")
            {
                field("Ticket Item Barcode";"Ticket Item Barcode")
                {
                }
            }
            group(GDPR)
            {
                field("GDPR Mode";"GDPR Mode")
                {
                }
                field("GDPR Agreement No.";"GDPR Agreement No.")
                {
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
                RunObject = Page "MM Recurring Payment Setup";
            }
        }
    }
}

