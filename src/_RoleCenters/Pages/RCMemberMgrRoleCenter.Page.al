page 6060149 "NPR RC Member Mgr RoleCenter"
{
    // TM1.16/TSA/20160816  CASE 233430 Transport TM1.16 - 19 July 2016
    // NPR5.29/TSA /20161121  CASE 258974 Page Navigation enhancements - Switched to Retail Item List
    // NPR5.29/TS  /20170127  CASE 264733 Added My reports
    // MM1.26/TSA /20180222 CASE 304705 Added button for setup actions in ticket and member module
    // MM1.29/TSA /20180509 CASE 313795 Added GDPR actions
    // TM1.39/TS  /20181206 CASE 343939 Added Missing Picture to Action
    // TM1.46/TSA /20200323 CASE 397084 Added ticket wizard
    // TM1.48/TSA /20200703 CASE 409741 Added Admission Forecast

    Caption = 'Role Center';
    PageType = RoleCenter;
    UsageCategory = Administration;

    layout
    {
        area(rolecenter)
        {
            group(Control1900724808)
            {
                ShowCaption = false;
                part(Control6150614; "NPR RC Ticket Activities")
                {
                    ApplicationArea = All;
                }
                part(Control6150626; "NPR Retail Activities")
                {
                    ApplicationArea = All;
                }
            }
            group(Control1900724708)
            {
                ShowCaption = false;
                part(Control4; "NPR RC Members. Burndown Chart")
                {
                    ApplicationArea = All;
                }
                part(Control6150624; "NPR Retail Sales Chart")
                {
                    ApplicationArea = All;
                }
                part(Control1; "My Job Queue")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                part(Control6014401; "NPR My Reports")
                {
                    ApplicationArea = All;
                }
                systempart(Control31; MyNotes)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(reporting)
        {
            action("S&ales Statistics")
            {
                Caption = 'S&ales Statistics';
                Image = "Report";
                RunObject = Report "Sales Statistics";
                ApplicationArea = All;
            }
            action("Salesperson - Sales &Statistics")
            {
                Caption = 'Salesperson - Sales &Statistics';
                Image = "Report";
                RunObject = Report "Salesperson - Sales Statistics";
                ApplicationArea = All;
            }
            action("Campaign - &Details")
            {
                Caption = 'Campaign - &Details';
                Image = "Report";
                RunObject = Report "Campaign - Details";
                ApplicationArea = All;
            }
        }
        area(embedding)
        {
            action("Ticket List")
            {
                Caption = 'Ticket List';
                Image = List;
                RunObject = Page "NPR TM Ticket List";
                ApplicationArea = All;
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = CustomerList;
                RunObject = Page "NPR MM Memberships";
                ApplicationArea = All;
            }
            action(Action6150625)
            {
                Caption = 'Members';
                Image = Customer;
                RunObject = Page "NPR MM Members";
                ApplicationArea = All;
            }
            action(Membercards)
            {
                Caption = 'Membercards';
                Image = CreditCard;
                RunObject = Page "NPR MM Member Card List";
                ApplicationArea = All;
            }
            action(Items)
            {
                Caption = 'Items';
                Image = Item;
                RunObject = Page "NPR Retail Item List";
                ApplicationArea = All;
            }
            action(Contacts)
            {
                Caption = 'Contacts';
                Image = CustomerContact;
                RunObject = Page "Contact List";
                ApplicationArea = All;
            }
            action(Customers)
            {
                Caption = 'Customers';
                Image = Customer;
                RunObject = Page "Customer List";
                ApplicationArea = All;
            }
            action(Campaigns)
            {
                Caption = 'Campaigns';
                Image = Campaign;
                RunObject = Page "Campaign List";
                ApplicationArea = All;
            }
            action(Segments)
            {
                Caption = 'Segments';
                Image = Segment;
                RunObject = Page "Segment List";
                ApplicationArea = All;
            }
            action("To-dos")
            {
                Caption = 'To-dos';
                Image = TaskList;
                RunObject = Page "Task List";
                ApplicationArea = All;
            }
            action(Teams)
            {
                Caption = 'Teams';
                Image = TeamSales;
                RunObject = Page Teams;
                ApplicationArea = All;
            }
        }
        area(sections)
        {
            group("Administration Sales/Purchase")
            {
                Caption = 'Administration Sales/Purchase';
                Image = AdministrationSalesPurchases;
                action("Salespeople/Purchasers")
                {
                    Caption = 'Salespeople/Purchasers';
                    RunObject = Page "Salespersons/Purchasers";
                    ApplicationArea = All;
                }
                action("Item Disc. Groups")
                {
                    Caption = 'Item Disc. Groups';
                    RunObject = Page "Item Disc. Groups";
                    ApplicationArea = All;
                }
            }
        }
        area(processing)
        {
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "NPR Retail Item List";
                ApplicationArea = All;
            }
            action("Sales Price &Worksheet")
            {
                Caption = 'Sales Price &Worksheet';
                Image = PriceWorksheet;
                RunObject = Page "Sales Price Worksheet";
                ApplicationArea = All;
            }
            action("Sales &Prices")
            {
                Caption = 'Sales &Prices';
                Image = SalesPrices;
                RunObject = Page "Sales Prices";
                ApplicationArea = All;
            }
            action("Sales Line &Discounts")
            {
                Caption = 'Sales Line &Discounts';
                Image = SalesLineDisc;
                RunObject = Page "Sales Line Discounts";
                ApplicationArea = All;
            }
            group(Membership)
            {
                action(Community)
                {
                    Caption = 'Community';
                    Image = Group;
                    RunObject = Page "NPR MM Member Community";
                    ApplicationArea = All;
                }
                action("Membership Setup")
                {
                    Caption = 'Membership Setup';
                    Image = SetupList;
                    RunObject = Page "NPR MM Membership Setup";
                    RunPageMode = View;
                    ApplicationArea = All;
                }
                action("Membership Sales Setup")
                {
                    Caption = 'Membership Sales Setup';
                    Image = SetupList;
                    RunObject = Page "NPR MM Membership Sales Setup";
                    ApplicationArea = All;
                }
                action("Membership Alteration")
                {
                    Caption = 'Membership Alteration';
                    Image = SetupList;
                    RunObject = Page "NPR MM Membership Alter.";
                    ApplicationArea = All;
                }
                separator(Separator6014409)
                {
                }
                action("Membership Admission Setup")
                {
                    Caption = 'Membership Admission Setup';
                    Image = SetupLines;
                    RunObject = Page "NPR MM Members. Admis. Setup";
                    ApplicationArea = All;
                }
                action("Membership Limitation Setup")
                {
                    Caption = 'Membership Limitation Setup';
                    Ellipsis = true;
                    Image = Lock;
                    Promoted = true;
                    RunObject = Page "NPR MM Membership Lim. Setup";
                    ApplicationArea = All;
                }
                action("Loyalty Setup")
                {
                    Caption = 'Membership Loyalty Setup';
                    Image = SalesLineDisc;
                    Promoted = true;
                    RunObject = Page "NPR MM Loyalty Setup";
                    ApplicationArea = All;
                }
                action(Notifications)
                {
                    Caption = 'Membership Notification Setup';
                    Image = InteractionTemplateSetup;
                    RunObject = Page "NPR MM Member Notific. Setup";
                    ApplicationArea = All;
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
                    RunObject = Page "NPR MM Foreign Members. Setup";
                    ApplicationArea = All;
                }
            }
            group(Tickets)
            {
                action("Ticket Setup")
                {
                    Caption = 'Ticket Setup';
                    Image = Setup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR TM Ticket Setup";
                    ApplicationArea = All;
                }
                action("Ticket Item Wizard")
                {
                    Caption = 'Ticket Item Wizard';
                    Ellipsis = true;
                    Image = "Action";
                    Promoted = true;
                    PromotedIsBig = true;
                    RunObject = Codeunit "NPR TM Ticket Wizard";
                    ApplicationArea = All;
                }
                separator(Separator6014425)
                {
                }
                action("Ticket Type")
                {
                    Caption = 'Ticket Types';
                    Image = Group;
                    RunObject = Page "NPR TM Ticket Type";
                    ApplicationArea = All;
                }
                action(Admission)
                {
                    Caption = 'Ticket Admission Setup';
                    Image = WorkCenter;
                    RunObject = Page "NPR TM Ticket Admissions";
                    ApplicationArea = All;
                }
                action(Schedule)
                {
                    Caption = 'Ticket Schedule Setup';
                    Image = Workdays;
                    RunObject = Page "NPR TM Ticket Schedules";
                    ApplicationArea = All;
                }
                action("Admission Schedules")
                {
                    Caption = 'Ticket Admission Schedules';
                    Image = CalendarWorkcenter;
                    RunObject = Page "NPR TM Admis. Schedule Lines";
                    ApplicationArea = All;
                }
                action("Ticket BOM")
                {
                    Caption = 'Ticket Bill-of-Material';
                    Image = BOM;
                    RunObject = Page "NPR TM Ticket BOM";
                    ApplicationArea = All;
                }
                separator(Separator6014426)
                {
                }
                action(Forecast)
                {
                    Caption = 'Admission Forecast';
                    Image = Forecast;
                    RunObject = Page "NPR TM Admis. Forecast Matrix";
                    ApplicationArea = All;
                }
                action(Statistics)
                {
                    Caption = 'Ticket Statistics';
                    Image = Statistics;
                    RunObject = Page "NPR TM Ticket Acc. Stat. Mtrx";
                    ApplicationArea = All;
                }
            }
            group(GDPR)
            {
                action("GDPR Setup")
                {
                    Caption = 'GDPR Setup';
                    Image = Setup;
                    RunObject = Page "NPR GDPR Setup";
                    ApplicationArea = All;
                }
                action("GDPR Agreement List")
                {
                    Caption = 'GDPR Agreement List';
                    Image = SetupLines;
                    RunObject = Page "NPR GDPR Agreement List";
                    ApplicationArea = All;
                }
            }
        }
    }
}