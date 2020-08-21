page 6060132 "MM Member Community"
{
    // TM1.00/TSA/20151215  CASE 228982 NaviPartner Ticket Management
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.09/TSA/20160226  case 235634 Membership connection to Customer & Contacts
    // MM1.10/TSA/20160405  CASE 237670 Transport MM1.10 - 22 March 2016
    // MM1.10/TSA/20160404  CASE 233948 Added a the Update Customer button to sync customer and contact
    // MM1.14/TSA/20160603  CASE 240871 Transport MM1.13 - 1 June 2016
    // MM1.17/TSA/20161116  CASE 258582 Added related information action Notification and Notification Setup
    // MM1.17/TSA/20161214  CASE 243075 Member Point System added field Activate Loyalty Program
    // MM1.23/TSA/20170614  CASE 257011 Navigate to Foreign Card Validation Setup
    // MM1.23/TSA /20170831 CASE 286922 Added Navigation to Auto Renew Process List
    // MM1.30/TSA /20180614 CASE 319296 Added "Customer No. Series"
    // MM1.40/TSA /20190612 CASE 357360 Added "Foreign Membership" field, and made the "Activate Loyalty Program" default visible

    Caption = 'Member Community';
    PageType = List;
    SourceTable = "MM Member Community";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("External No. Search Order"; "External No. Search Order")
                {
                    ApplicationArea = All;
                }
                field("External Membership No. Series"; "External Membership No. Series")
                {
                    ApplicationArea = All;
                }
                field("External Member No. Series"; "External Member No. Series")
                {
                    ApplicationArea = All;
                }
                field("Customer No. Series"; "Customer No. Series")
                {
                    ApplicationArea = All;
                }
                field("Member Unique Identity"; "Member Unique Identity")
                {
                    ApplicationArea = All;
                }
                field("Create Member UI Violation"; "Create Member UI Violation")
                {
                    ApplicationArea = All;
                }
                field("Member Logon Credentials"; "Member Logon Credentials")
                {
                    ApplicationArea = All;
                }
                field("Membership to Cust. Rel."; "Membership to Cust. Rel.")
                {
                    ApplicationArea = All;
                }
                field("Create Renewal Notifications"; "Create Renewal Notifications")
                {
                    ApplicationArea = All;
                }
                field("Activate Loyalty Program"; "Activate Loyalty Program")
                {
                    ApplicationArea = All;
                }
                field("Foreign Membership"; "Foreign Membership")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Membership Setup")
            {
                Caption = 'Membership Setup';
                Image = SetupList;
                RunObject = Page "MM Membership Setup";
                RunPageLink = "Community Code" = FIELD(Code);
            }
            action("Loyalty Setup")
            {
                Caption = 'Loyalty Setup';
                Image = SalesLineDisc;
                Promoted = true;
                RunObject = Page "MM Loyalty Setup";
            }
            action("Notification Setup")
            {
                Caption = 'Notification Setup';
                Image = SetupList;
                RunObject = Page "MM Member Notification Setup";
                RunPageLink = "Community Code" = FIELD(Code);
            }
            separator(Separator6150626)
            {
            }
            action("Process Auto Renew")
            {
                Caption = 'Auto Renew Process';
                Ellipsis = true;
                Image = AutoReserve;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "MM Membership Auto Renew List";
                RunPageLink = "Community Code" = FIELD(Code);
            }
            separator(Separator6014406)
            {
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = List;
                RunObject = Page "MM Memberships";
                RunPageLink = "Community Code" = FIELD(Code);
            }
            separator(Separator6014405)
            {
            }
            action(Notifications)
            {
                Caption = 'Notifications';
                Image = InteractionLog;
                RunObject = Page "MM Membership Notification";
            }
            action("Foreign Membership Setup")
            {
                Caption = 'Foreign Membership Setup';
                Ellipsis = true;
                Image = ElectronicBanking;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "MM Foreign Membership Setup";
                RunPageLink = "Community Code" = FIELD(Code);
            }
        }
        area(processing)
        {
            action("Update Memberships Customer")
            {
                Caption = 'Update Memberships Customer';
                Image = CreateInteraction;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Report "MM Sync. Community Customers";
            }
        }
    }
}

