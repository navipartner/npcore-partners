page 6060141 "MM Membership Alteration"
{
    // MM1.11/TSA/20160502  CASE 233824 Transport MM1.11 - 29 April 2016
    // MM1.14/TSA/20160603  CASE 240870 Transport MM1.13 - 1 June 2016
    // MM1.19/TSA/20170322  CASE 268166 Added field "Upgrade With New Duration"
    // MM1.22/TSA /20170816 CASE 287080 Added field "Anonymous Member Unit Price"
    // MM1.22/TSA /20170829 CASE 286922 Added field "Auto-Renew To"
    // MM1.23/TSA /20170918 CASE 276869 Added field "Not Available Via Web Service"
    // MM1.24/TSA /20171205 CASE 297852 Added field "Assign Loyalty Points On Sale"
    // MM1.25/NPKNAV/20180122  CASE 300256 Transport MM1.25 - 22 January 2018
    // MM1.30/TSA/20180615  CASE 317428 Transport MM1.30 - 15 June 2018
    // MM1.40/TSA /20190730 CASE 360275 Added field "Auto-Admit Member On Sale"
    // MM1.41/TSA /20191016 CASE 373297 Added "Grace Period Presets" and made some grace period settings fields not visible (by default)
    // MM1.43/TSA /20200331 CASE 398328 added "Presentation Order"
    // MM1.44/TSA /20200529 CASE 407401 Added Age Verification

    Caption = 'Membership Alteration';
    PageType = List;
    SourceTable = "MM Membership Alteration Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Alteration Type"; "Alteration Type")
                {
                    ApplicationArea = All;
                }
                field("From Membership Code"; "From Membership Code")
                {
                    ApplicationArea = All;
                }
                field("Sales Item No."; "Sales Item No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("To Membership Code"; "To Membership Code")
                {
                    ApplicationArea = All;
                }
                field("Presentation Order"; "Presentation Order")
                {
                    ApplicationArea = All;
                }
                field("Alteration Activate From"; "Alteration Activate From")
                {
                    ApplicationArea = All;
                }
                field("Alteration Date Formula"; "Alteration Date Formula")
                {
                    ApplicationArea = All;
                }
                field("Membership Duration"; "Membership Duration")
                {
                    ApplicationArea = All;
                }
                field("Activate Grace Period"; "Activate Grace Period")
                {
                    ApplicationArea = All;
                }
                field("Grace Period Presets"; "Grace Period Presets")
                {
                    ApplicationArea = All;
                }
                field("Grace Period Relates To"; "Grace Period Relates To")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Grace Period Calculation"; "Grace Period Calculation")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Grace Period Before"; "Grace Period Before")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Grace Period After"; "Grace Period After")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Price Calculation"; "Price Calculation")
                {
                    ApplicationArea = All;
                }
                field("Stacking Allowed"; "Stacking Allowed")
                {
                    ApplicationArea = All;
                }
                field("Upgrade With New Duration"; "Upgrade With New Duration")
                {
                    ApplicationArea = All;
                }
                field("Member Unit Price"; "Member Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Member Count Calculation"; "Member Count Calculation")
                {
                    ApplicationArea = All;
                }
                field("Auto-Renew To"; "Auto-Renew To")
                {
                    ApplicationArea = All;
                }
                field("Not Available Via Web Service"; "Not Available Via Web Service")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Assign Loyalty Points On Sale"; "Assign Loyalty Points On Sale")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Card Expired Action"; "Card Expired Action")
                {
                    ApplicationArea = All;
                }
                field("Auto-Admit Member On Sale"; "Auto-Admit Member On Sale")
                {
                    ApplicationArea = All;
                }
                field("Age Constraint Type"; "Age Constraint Type")
                {
                    ApplicationArea = All;
                }
                field("Age Constraint (Years)"; "Age Constraint (Years)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

