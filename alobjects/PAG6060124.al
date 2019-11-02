page 6060124 "MM Membership Setup"
{
    // TM1.00/TSA/20151215  CASE 228982 NaviPartner Ticket Management
    // MM80.1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM80.1.01/TSA/20151222  CASE 230149 NaviPartner Member Management
    // MM80.1.02/TSA/20151228  CASE 229980 Print setup for member card
    // MM1.09/TSA/20160229 CASE 235812 Member Receipt Printing
    // MM1.09/TSA/20160311  CASE 235634 Transport MM1.09 - 11 March 2016
    // MM1.10/TSA/20160405  CASE 234209 Transport MM1.10 - 22 March 2016
    // MM1.11/TSA/20160502  CASE 233824 Transport MM1.11 - 29 April 2016
    // MM1.14/TSA/20160603  CASE 240871 Transport MM1.13 - 1 June 2016
    // MM1.17/TSA/20161214  CASE 243075 Member Point System added field Loyalty Program
    // MM1.18/TSA/20170220 CASE 266768 Added default filter to not show blocked entries
    // NPR5.33/MHA /20170608  CASE 279229 Added field 80 "Contact Config. Template Code"
    // MM1.21/TSA /20170721 CASE 284653 Added Limition Setup Button
    // MM1.22/NPKNAV/20170914  CASE 287080 Transport MM1.22 - 13 September 2017
    // MM1.25/TSA /20180115 CASE 299537 Added fields for template print code
    // MM1.25/TSA /20180117 CASE 300256 Added fields "Card Expire Date Calculation", "Card Expired Action"
    // MM1.29/TSA /20180510 CASE 313795 GDPR fields
    // NPR5.43/CLVA/20180627 CASE 318490 Added Action Turnstile Setup
    // MM1.32/TSA/20180725  CASE 323333 Transport MM1.32 - 25 July 2018
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019
    // MM1.41/TSA  /20191010 CASE 367471 Added Sponsorship Ticket Setup related action

    Caption = 'Membership Setup';
    CardPageID = "MM Membership Setup Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "MM Membership Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'General';
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Membership Type";"Membership Type")
                {
                }
                field("Loyalty Card";"Loyalty Card")
                {
                }
                field("Loyalty Code";"Loyalty Code")
                {
                    Visible = false;
                }
                field("Customer Config. Template Code";"Customer Config. Template Code")
                {
                }
                field("Contact Config. Template Code";"Contact Config. Template Code")
                {
                }
                field("Membership Customer No.";"Membership Customer No.")
                {
                    Visible = false;
                }
                field("Member Information";"Member Information")
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("Blocked At";"Blocked At")
                {
                }
                field(Perpetual;Perpetual)
                {
                }
                field("Member Role Assignment";"Member Role Assignment")
                {
                }
                field("Create Welcome Notification";"Create Welcome Notification")
                {
                }
                field("Create Renewal Notifications";"Create Renewal Notifications")
                {
                }
                field("Membership Member Cardinality";"Membership Member Cardinality")
                {
                }
                field("Anonymous Member Cardinality";"Anonymous Member Cardinality")
                {
                }
                field("Community Code";"Community Code")
                {
                }
                field("Allow Membership Delete";"Allow Membership Delete")
                {
                }
                field("Confirm Member On Card Scan";"Confirm Member On Card Scan")
                {
                }
                field("Web Service Print Action";"Web Service Print Action")
                {
                }
                field("POS Print Action";"POS Print Action")
                {
                }
                field("Account Print Object Type";"Account Print Object Type")
                {
                }
                field("Account Print Template Code";"Account Print Template Code")
                {
                }
                field("Account Print Object ID";"Account Print Object ID")
                {
                }
                field("Receipt Print Object Type";"Receipt Print Object Type")
                {
                }
                field("Receipt Print Template Code";"Receipt Print Template Code")
                {
                }
                field("Receipt Print Object ID";"Receipt Print Object ID")
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
                    ToolTip = '<any text><[MA|MS|NS|N*x|A*x|X*x]><[...]><...>';
                }
                field("Card Print Object Type";"Card Print Object Type")
                {
                }
                field("Card Print Template Code";"Card Print Template Code")
                {
                }
                field("Card Print Object ID";"Card Print Object ID")
                {
                }
                field("Card Expire Date Calculation";"Card Expire Date Calculation")
                {
                }
                field("Ticket Item Barcode";"Ticket Item Barcode")
                {
                }
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
                field("GDPR Mode";"GDPR Mode")
                {
                }
                field("GDPR Agreement No.";"GDPR Agreement No.")
                {
                }
                field("Enable NP Pass Integration";"Enable NP Pass Integration")
                {
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
                RunObject = Page "MM Member Community";
            }
            action("Membership Sales Setup")
            {
                Caption = 'Membership Sales Setup';
                Image = SetupList;
                Promoted = true;
                RunObject = Page "MM Membership Sales Setup";
                RunPageLink = "Membership Code"=FIELD(Code);
            }
            action("Membership Alteration")
            {
                Caption = 'Membership Alteration';
                Image = SetupList;
                Promoted = true;
                RunObject = Page "MM Membership Alteration";
                RunPageLink = "From Membership Code"=FIELD(Code);
            }
            separator(Separator6014404)
            {
            }
            action("Membership Admission Setup")
            {
                Caption = 'Membership Admission Setup';
                Image = SetupLines;
                RunObject = Page "MM Membership Admission Setup";
                RunPageLink = "Membership  Code"=FIELD(Code);
            }
            action("Membership Limitation Setup")
            {
                Caption = 'Membership Limitation Setup';
                Ellipsis = true;
                Image = Lock;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "MM Membership Limitation Setup";
                RunPageLink = "Membership  Code"=FIELD(Code);
            }
            action("Sponsorship Ticket Setup")
            {
                Ellipsis = true;
                Image = SetupLines;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "MM Sponsorship Ticket Setup";
                RunPageLink = "Membership Code"=FIELD(Code);
            }
            separator(Separator6014405)
            {
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = List;
                RunObject = Page "MM Memberships";
                RunPageLink = "Membership Code"=FIELD(Code);
            }
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "Retail Item List";
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
                RunObject = Page "MM Admission Service Setup";
            }
        }
    }

    trigger OnOpenPage()
    begin

        //-+MM1.18 [266769]
        Rec.SetFilter (Blocked, '=%1', false);
    end;
}

