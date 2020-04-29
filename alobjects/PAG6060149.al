page 6060149 "RC Member Mgr Role Center"
{
    // TM1.16/TSA/20160816  CASE 233430 Transport TM1.16 - 19 July 2016
    // NPR5.29/TSA /20161121  CASE 258974 Page Navigation enhancements - Switched to Retail Item List
    // NPR5.29/TS  /20170127  CASE 264733 Added My reports
    // MM1.26/TSA /20180222 CASE 304705 Added button for setup actions in ticket and member module
    // MM1.29/TSA /20180509 CASE 313795 Added GDPR actions
    // TM1.39/TS  /20181206 CASE 343939 Added Missing Picture to Action
    // TM90.1.46/TSA /20200323 CASE 397084 Added ticket wizard

    Caption = 'Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control1900724808)
            {
                ShowCaption = false;
                part(Control6150614;"RC Ticket Activities")
                {
                }
                part(Control6150626;"Retail Activities")
                {
                }
            }
            group(Control1900724708)
            {
                ShowCaption = false;
                part(Control4;"RC Membership Burndown Chart")
                {
                }
                part(Control6150624;"Retail Sales Chart")
                {
                }
                part(Control1;"My Job Queue")
                {
                    Visible = false;
                }
                part(Control6014401;"My Reports")
                {
                }
                systempart(Control31;MyNotes)
                {
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
            }
            action("Salesperson - Sales &Statistics")
            {
                Caption = 'Salesperson - Sales &Statistics';
                Image = "Report";
                RunObject = Report "Salesperson - Sales Statistics";
            }
            action("Campaign - &Details")
            {
                Caption = 'Campaign - &Details';
                Image = "Report";
                RunObject = Report "Campaign - Details";
            }
        }
        area(embedding)
        {
            group(Members)
            {
                Caption = 'Members';
                action("Ticket List")
                {
                    Caption = 'Ticket List';
                    Image = List;
                    RunObject = Page "TM Ticket List";
                }
                separator(Separator6150618)
                {
                }
                action(Memberships)
                {
                    Caption = 'Memberships';
                    Image = CustomerList;
                    RunObject = Page "MM Memberships";
                }
                action(Action6150625)
                {
                    Caption = 'Members';
                    Image = Customer;
                    RunObject = Page "MM Members";
                }
                action(Membercards)
                {
                    Caption = 'Membercards';
                    Image = CreditCard;
                    RunObject = Page "MM Member Card List";
                }
                separator(Separator6150616)
                {
                }
            }
            group(General)
            {
                Caption = 'General';
                action(Items)
                {
                    Caption = 'Items';
                    Image = Item;
                    RunObject = Page "Retail Item List";
                }
                action(Contacts)
                {
                    Caption = 'Contacts';
                    Image = CustomerContact;
                    RunObject = Page "Contact List";
                }
                action(Customers)
                {
                    Caption = 'Customers';
                    Image = Customer;
                    RunObject = Page "Customer List";
                }
                action(Campaigns)
                {
                    Caption = 'Campaigns';
                    Image = Campaign;
                    RunObject = Page "Campaign List";
                }
                action(Segments)
                {
                    Caption = 'Segments';
                    Image = Segment;
                    RunObject = Page "Segment List";
                }
                action("To-dos")
                {
                    Caption = 'To-dos';
                    Image = TaskList;
                    RunObject = Page "Task List";
                }
                action(Teams)
                {
                    Caption = 'Teams';
                    Image = TeamSales;
                    RunObject = Page Teams;
                }
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
                }
                action("Item Disc. Groups")
                {
                    Caption = 'Item Disc. Groups';
                    RunObject = Page "Item Disc. Groups";
                }
            }
        }
        area(processing)
        {
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "Retail Item List";
            }
            action("Sales Price &Worksheet")
            {
                Caption = 'Sales Price &Worksheet';
                Image = PriceWorksheet;
                RunObject = Page "Sales Price Worksheet";
            }
            action("Sales &Prices")
            {
                Caption = 'Sales &Prices';
                Image = SalesPrices;
                RunObject = Page "Sales Prices";
            }
            action("Sales Line &Discounts")
            {
                Caption = 'Sales Line &Discounts';
                Image = SalesLineDisc;
                RunObject = Page "Sales Line Discounts";
            }
            group(Membership)
            {
                action(Community)
                {
                    Caption = 'Community';
                    Image = Group;
                    RunObject = Page "MM Member Community";
                }
                action("Membership Setup")
                {
                    Caption = 'Membership Setup';
                    Image = SetupList;
                    RunObject = Page "MM Membership Setup";
                    RunPageMode = View;
                }
                action("Membership Sales Setup")
                {
                    Caption = 'Membership Sales Setup';
                    Image = SetupList;
                    RunObject = Page "MM Membership Sales Setup";
                }
                action("Membership Alteration")
                {
                    Caption = 'Membership Alteration';
                    Image = SetupList;
                    RunObject = Page "MM Membership Alteration";
                }
                separator(Separator6014409)
                {
                }
                action("Membership Admission Setup")
                {
                    Caption = 'Membership Admission Setup';
                    Image = SetupLines;
                    RunObject = Page "MM Membership Admission Setup";
                }
                action("Membership Limitation Setup")
                {
                    Caption = 'Membership Limitation Setup';
                    Ellipsis = true;
                    Image = Lock;
                    Promoted = true;
                    RunObject = Page "MM Membership Limitation Setup";
                }
                action("Loyalty Setup")
                {
                    Caption = 'Membership Loyalty Setup';
                    Image = SalesLineDisc;
                    Promoted = true;
                    RunObject = Page "MM Loyalty Setup";
                }
                action(Notifications)
                {
                    Caption = 'Membership Notification Setup';
                    Image = InteractionTemplateSetup;
                    RunObject = Page "MM Member Notification Setup";
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
                    RunObject = Page "TM Ticket Setup";
                }
                action("Ticket Item Wizard")
                {
                    Caption = 'Ticket Item Wizard';
                    Ellipsis = true;
                    Image = "Action";
                    Promoted = true;
                    PromotedIsBig = true;
                    RunObject = Codeunit "TM Ticket Wizard";
                }
                separator(Separator6014425)
                {
                }
                action("Ticket Type")
                {
                    Caption = 'Ticket Types';
                    Image = Group;
                    RunObject = Page "TM Ticket Type";
                }
                action(Admission)
                {
                    Caption = 'Ticket Admission Setup';
                    Image = WorkCenter;
                    RunObject = Page "TM Ticket Admissions";
                }
                action(Schedule)
                {
                    Caption = 'Ticket Schedule Setup';
                    Image = Workdays;
                    RunObject = Page "TM Ticket Schedules";
                }
                action("Admission Schedules")
                {
                    Caption = 'Ticket Admission Schedules';
                    Image = CalendarWorkcenter;
                    RunObject = Page "TM Admission Schedule Lines";
                }
                action("Ticket BOM")
                {
                    Caption = 'Ticket Bill-of-Material';
                    Image = BOM;
                    RunObject = Page "TM Ticket BOM";
                }
                action(Statistics)
                {
                    Caption = 'Ticket Statistics';
                    Image = Statistics;
                    RunObject = Page "TM Ticket Access Stat. Mtrx";
                }
            }
            group(GDPR)
            {
                action("GDPR Setup")
                {
                    Caption = 'GDPR Setup';
                    Image = Setup;
                    RunObject = Page "GDPR Setup";
                }
                action("GDPR Agreement List")
                {
                    Caption = 'GDPR Agreement List';
                    Image = SetupLines;
                    RunObject = Page "GDPR Agreement List";
                }
            }
        }
    }

    local procedure InvokeTicketWizard()
    begin
    end;
}

