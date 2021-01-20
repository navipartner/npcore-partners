page 6151263 "NPR Retail Ticket Role Center"
{
    Caption = 'Role Center';
    PageType = RoleCenter;
    UsageCategory = None;

    layout
    {
        area(rolecenter)
        {
            part(Control7; "Headline RC Order Processor")
            {
                ApplicationArea = Basic, Suite;
            }

            part(Control6150614; "NPR RC Ticket Activities")
            {
                ApplicationArea = All;
            }
            part(Control6150626; "NPR Retail Activities")
            {
                ApplicationArea = All;
            }

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
        }
    }
    actions
    {
        area(reporting)
        {
            action("Campaign - &Details")
            {
                Caption = 'Campaign - &Details';
                Image = "Report";
                RunObject = Report "Campaign - Details";
                ApplicationArea = All;
                ToolTip = 'Executes the Campaign - &Details action';
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
                ToolTip = 'Executes the Ticket List action';
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = CustomerList;
                RunObject = Page "NPR MM Memberships";
                ApplicationArea = All;
                ToolTip = 'Executes the Memberships action';
            }
            action(Action6150625)
            {
                Caption = 'Members';
                Image = Customer;
                RunObject = Page "NPR MM Members";
                ApplicationArea = All;
                ToolTip = 'Executes the Members action';
            }
            action(Membercards)
            {
                Caption = 'Membercards';
                Image = CreditCard;
                RunObject = Page "NPR MM Member Card List";
                ApplicationArea = All;
                ToolTip = 'Executes the Membercards action';
            }
            action(Items)
            {
                Caption = 'Items';
                Image = Item;
                RunObject = Page "Item List";
                ApplicationArea = All;
                ToolTip = 'Executes the Items action';
            }
            action(Contacts)
            {
                Caption = 'Contacts';
                Image = CustomerContact;
                RunObject = Page "Contact List";
                ApplicationArea = All;
                ToolTip = 'Executes the Contacts action';
            }
            action(Customers)
            {
                Caption = 'Customers';
                Image = Customer;
                RunObject = Page "Customer List";
                ApplicationArea = All;
                ToolTip = 'Executes the Customers action';
            }
            action(Campaigns)
            {
                Caption = 'Campaigns';
                Image = Campaign;
                RunObject = Page "Campaign List";
                ApplicationArea = All;
                ToolTip = 'Executes the Campaigns action';
            }
            action(Segments)
            {
                Caption = 'Segments';
                Image = Segment;
                RunObject = Page "Segment List";
                ApplicationArea = All;
                ToolTip = 'Executes the Segments action';
            }
            action("To-dos")
            {
                Caption = 'To-dos';
                Image = TaskList;
                RunObject = Page "Task List";
                ApplicationArea = All;
                ToolTip = 'Executes the To-dos action';
            }
            action(Teams)
            {
                Caption = 'Teams';
                Image = TeamSales;
                RunObject = Page Teams;
                ApplicationArea = All;
                ToolTip = 'Executes the Teams action';
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
                    ToolTip = 'Executes the Salespeople/Purchasers action';
                }
                action("Item Disc. Groups")
                {
                    Caption = 'Item Disc. Groups';
                    RunObject = Page "Item Disc. Groups";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Disc. Groups action';
                }
            }
        }
        area(processing)
        {
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "Item List";
                ApplicationArea = All;
                ToolTip = 'Executes the Item List action';
            }
            action("Sales Price &Worksheet")
            {
                Caption = 'Sales Price &Worksheet';
                Image = PriceWorksheet;
                RunObject = Page "Sales Price Worksheet";
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Price &Worksheet action';
            }
            action("Sales &Prices")
            {
                Caption = 'Sales &Prices';
                Image = SalesPrices;
                RunObject = Page "Sales Prices";
                ApplicationArea = All;
                ToolTip = 'Executes the Sales &Prices action';
            }
            action("Sales Line &Discounts")
            {
                Caption = 'Sales Line &Discounts';
                Image = SalesLineDisc;
                RunObject = Page "Sales Line Discounts";
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Line &Discounts action';
            }
            group(Membership)
            {
                action(Community)
                {
                    Caption = 'Community';
                    Image = Group;
                    RunObject = Page "NPR MM Member Community";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Community action';
                }
                action("Membership Setup")
                {
                    Caption = 'Membership Setup';
                    Image = SetupList;
                    RunObject = Page "NPR MM Membership Setup";
                    RunPageMode = View;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Membership Setup action';
                }
                action("Membership Sales Setup")
                {
                    Caption = 'Membership Sales Setup';
                    Image = SetupList;
                    RunObject = Page "NPR MM Membership Sales Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Membership Sales Setup action';
                }
                action("Membership Alteration")
                {
                    Caption = 'Membership Alteration';
                    Image = SetupList;
                    RunObject = Page "NPR MM Membership Alter.";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Membership Alteration action';
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
                    ToolTip = 'Executes the Membership Admission Setup action';
                }
                action("Membership Limitation Setup")
                {
                    Caption = 'Membership Limitation Setup';
                    Ellipsis = true;
                    Image = Lock;
                    Promoted = true;
                    RunObject = Page "NPR MM Membership Lim. Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Membership Limitation Setup action';
                }
                action("Loyalty Setup")
                {
                    Caption = 'Membership Loyalty Setup';
                    Image = SalesLineDisc;
                    Promoted = true;
                    RunObject = Page "NPR MM Loyalty Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Membership Loyalty Setup action';
                }
                action(Notifications)
                {
                    Caption = 'Membership Notification Setup';
                    Image = InteractionTemplateSetup;
                    RunObject = Page "NPR MM Member Notific. Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Membership Notification Setup action';
                }
                action("Foreign Membership Setup")
                {
                    Caption = 'Foreign Membership Setup';
                    Ellipsis = true;
                    Image = ElectronicBanking;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "NPR MM Foreign Members. Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Foreign Membership Setup action';
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
                    ToolTip = 'Executes the Ticket Setup action';
                }
                action("Ticket Type")
                {
                    Caption = 'Ticket Types';
                    Image = Group;
                    RunObject = Page "NPR TM Ticket Type";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Types action';
                }
                action(Admission)
                {
                    Caption = 'Ticket Admission Setup';
                    Image = WorkCenter;
                    RunObject = Page "NPR TM Ticket Admissions";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Admission Setup action';
                }
                action(Schedule)
                {
                    Caption = 'Ticket Schedule Setup';
                    Image = Workdays;
                    RunObject = Page "NPR TM Ticket Schedules";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Schedule Setup action';
                }
                action("Admission Schedules")
                {
                    Caption = 'Ticket Admission Schedules';
                    Image = CalendarWorkcenter;
                    RunObject = Page "NPR TM Admis. Schedule Lines";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Admission Schedules action';
                }
                action("Ticket BOM")
                {
                    Caption = 'Ticket Bill-of-Material';
                    Image = BOM;
                    RunObject = Page "NPR TM Ticket BOM";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Bill-of-Material action';
                }
                action(Statistics)
                {
                    Caption = 'Ticket Statistics';
                    Image = Statistics;
                    RunObject = Page "NPR TM Ticket Acc. Stat. Mtrx";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Statistics action';
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
                    ToolTip = 'Executes the GDPR Setup action';
                }
                action("GDPR Agreement List")
                {
                    Caption = 'GDPR Agreement List';
                    Image = SetupLines;
                    RunObject = Page "NPR GDPR Agreement List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the GDPR Agreement List action';
                }
            }
        }
    }
}