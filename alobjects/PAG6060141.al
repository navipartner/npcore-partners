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
                field("Alteration Type";"Alteration Type")
                {
                }
                field("From Membership Code";"From Membership Code")
                {
                }
                field("Sales Item No.";"Sales Item No.")
                {
                }
                field(Description;Description)
                {
                }
                field("To Membership Code";"To Membership Code")
                {
                }
                field("Alteration Activate From";"Alteration Activate From")
                {
                }
                field("Alteration Date Formula";"Alteration Date Formula")
                {
                }
                field("Membership Duration";"Membership Duration")
                {
                }
                field("Activate Grace Period";"Activate Grace Period")
                {
                }
                field("Grace Period Relates To";"Grace Period Relates To")
                {
                }
                field("Grace Period Calculation";"Grace Period Calculation")
                {
                    Visible = false;
                }
                field("Grace Period Before";"Grace Period Before")
                {
                }
                field("Grace Period After";"Grace Period After")
                {
                }
                field("Price Calculation";"Price Calculation")
                {
                }
                field("Stacking Allowed";"Stacking Allowed")
                {
                }
                field("Upgrade With New Duration";"Upgrade With New Duration")
                {
                }
                field("Member Unit Price";"Member Unit Price")
                {
                }
                field("Member Count Calculation";"Member Count Calculation")
                {
                }
                field("Auto-Renew To";"Auto-Renew To")
                {
                }
                field("Not Available Via Web Service";"Not Available Via Web Service")
                {
                    Visible = false;
                }
                field("Assign Loyalty Points On Sale";"Assign Loyalty Points On Sale")
                {
                    Visible = false;
                }
                field("Card Expired Action";"Card Expired Action")
                {
                }
                field("Auto-Admit Member On Sale";"Auto-Admit Member On Sale")
                {
                }
            }
        }
    }

    actions
    {
    }
}

