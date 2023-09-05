page 6151249 "NPR Entertainment RC"
{
    Extensible = False;
    Caption = 'Entertainment RC', Comment = '{Dependency=Match,"ProfileDescription_PRESIDENT-SMALLBUSINESS"}';
    PageType = RoleCenter;
    UsageCategory = None;

    layout
    {
        area(rolecenter)
        {

            part(Control7; "NPR Retail Ent Headline")
            {
                ApplicationArea = NPRRetail;

            }
            part(Control2; "NPR Retail Enter. Act - Ticket")
            {
                ApplicationArea = NPRRetail;

            }
            part(Control20; "NPR RC Ticket Activities")
            {
                ApplicationArea = NPRRetail;

            }
            part(MembershipStats; "NPR RC Membership Statistics")
            {
                ApplicationArea = NPRRetail;
            }
            part(RCMembershipBurndownChart; "NPR RC Members. Burndown Chart")
            {
                ApplicationArea = NPRRetail;
            }
            part(RetailActivities; "NPR Retail Activities")
            {
                Caption = 'ACTIVITIES';
                ApplicationArea = NPRRetail;
            }
#IF NOT BC17
            part(RetailSalesChart; "NPR Retail Sales Chart")
            {
                ApplicationArea = NPRRetail;
                ObsoleteReason = 'Replaced with page "NPR Chart Wrapper".';
                ObsoleteState = Pending;
                ObsoleteTag = 'NPR26.0';
                Visible = false;
            }
            part(RetailPerformance; "NPR Chart Wrapper")
            {
                ApplicationArea = NPRRetail;
            }
#ENDIF
            part(MyReports; "NPR My Reports")
            {
                ApplicationArea = NPRRetail;
            }
            part(MyJobQueue; "My Job Queue")
            {
                Caption = 'Job Queue';
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(sections)
        {
            group(Member)
            {
                Caption = 'Member';
                Image = Journals;
                action("Member Community")
                {

                    Caption = 'Member Community';
                    RunObject = Page "NPR MM Member Community";
                    ToolTip = 'View or edit detailed information about the community members such as code, type etc.';

                    ApplicationArea = NPRRetail;
                }
                action("Membership Setup")
                {

                    Caption = 'Membership Setup';
                    RunObject = Page "NPR MM Membership Setup";
                    ToolTip = 'View or edit detailed information about membership setups and related entities.';

                    ApplicationArea = NPRRetail;
                }
                action("Membership Sales Setup")
                {
                    Caption = 'Membership Sales Setup';
                    RunObject = Page "NPR MM Membership Sales Setup";
                    ToolTip = 'View or edit detailed information about membership sales setup such as relation to the Item or Gl Account, validity etc.';
                    ApplicationArea = NPRRetail;
                }
                action("Membership Alteration")
                {
                    Caption = 'Membership Alteration';
                    RunObject = Page "NPR MM Membership Alter.";

                    ToolTip = 'View or edit detailed information about membership alterations such as renewal, upgrades, cancellation, etc.';

                    ApplicationArea = NPRRetail;
                }
                action("Member Notification Setup")
                {

                    Caption = 'Member Notification Setup';
                    RunObject = Page "NPR MM Member Notific. Setup";
                    ToolTip = 'View or edit detailed information about member notification setups such as notification templates, events, days before, days past, etc.';

                    ApplicationArea = NPRRetail;
                }
                action("Membership Limitation Setup")
                {

                    Caption = 'Membership Limitation Setup';
                    RunObject = Page "NPR MM Membership Lim. Setup";
                    ToolTip = 'View or edit detailed information about membership limitation setups such as different constraints, event limits, etc."';

                    ApplicationArea = NPRRetail;
                }
                action("Membership Admission Setup")
                {

                    Caption = 'Membership Admission Setup';
                    RunObject = Page "NPR MM Members. Admis. Setup";
                    ToolTip = 'View or edit detailed information about membership admission setups such as membership code, admission code, ticket type, ticket number, etc.';

                    ApplicationArea = NPRRetail;
                }
                action("MCS Person Groups")
                {

                    Caption = 'MCS Person Groups';
                    RunObject = Page "NPR MCS Person Groups";
                    ToolTip = 'View or edit detailed information about MCS Person Groups.';

                    ApplicationArea = NPRRetail;
                }
                action("MCS Person Group Setup")
                {

                    Caption = 'MCS Person Group Setup';
                    RunObject = Page "NPR MCS Person Group Setup";
                    ToolTip = 'View or edit detailed information about MCS Person Group setups.';

                    ApplicationArea = NPRRetail;
                }
            }
            group(Loyalty)
            {
                Caption = 'Loyalty';
                action("Loyalty Setup")
                {

                    Caption = 'Loyalty Setup';
                    RunObject = Page "NPR MM Loyalty Setup";
                    ToolTip = 'View or edit detailed information about the loyalty setups such as collection period, fixed period start and length, voucher point source etc.';
                    ApplicationArea = NPRRetail;
                }
                action("Loyalty Points Setup")
                {

                    Caption = 'Loyalty Points Setup';
                    RunObject = Page "NPR MM Loyalty Point Setup";
                    ToolTip = 'View or edit detailed information about the loyalty points setups such as coupon type code, points threshold, amount and point rate etc.';
                    ApplicationArea = NPRRetail;
                }
                action("Loyalty Item Point Setup")
                {

                    Caption = 'Loyalty Item Point Setup';
                    RunObject = Page "NPR MM Loy. Item Point Setup";
                    ToolTip = 'View or edit detailed information about the loyalty item points setups such as type, contraint, points etc.';
                    ApplicationArea = NPRRetail;
                }
                action("Loyalty Store Setup Server")
                {

                    Caption = 'Loyalty Store Setup Server';
                    RunObject = Page "NPR MM Loy. Store Setup Server";
                    ToolTip = 'View or edit detailed information about the loyalty store setup server such as company, store code, unit code etc.';
                    ApplicationArea = NPRRetail;
                }
                action("Loyalty Store Setup Client")
                {

                    Caption = 'Loyalty Store Setup Client';
                    RunObject = Page "NPR MM Loy. Store Setup Client";
                    ToolTip = 'Executes the Loyalty Store Setup Client action.';
                    ApplicationArea = NPRRetail;
                }
                action("Foreign Membership Setup")
                {

                    Caption = 'Foreign Membership Setup';
                    RunObject = Page "NPR MM Foreign Members. Setup";
                    ToolTip = 'View or edit detailed information about the foreign membership setups to configure the append/remove local prefixes/suffixes for each community code.';

                    ApplicationArea = NPRRetail;
                }
                action("NPR Endpoint Setup")
                {

                    Caption = 'NPR Endpoint Setup';
                    RunObject = Page "NPR MM NPR Endpoint Setup";
                    ToolTip = 'View or edit detailed information about the NPR endpoint setups such as type, authentication, username etc';

                    ApplicationArea = NPRRetail;
                }
            }
            group(Ticket)
            {
                Caption = 'Ticket';
                action("Ticket Type")
                {

                    Caption = 'Ticket Type';
                    RunObject = Page "NPR TM Ticket Type";
                    ToolTip = 'View or edit detailed information about the ticket types such as admission registration, number of series, activation method etc.';

                    ApplicationArea = NPRRetail;
                }
                action(TicketItems)
                {

                    Caption = 'Ticket Items';
                    RunObject = Page "NPR TM Ticket Item List";
                    ToolTip = 'View or edit detailed information about the ticket Items, such as the ticket item configuration and constraints, etc.';

                    ApplicationArea = NPRRetail;
                }

                action("Ticket BOM")
                {

                    Caption = 'Ticket BOM';
                    RunObject = Page "NPR TM Ticket BOM";
                    ToolTip = 'View or edit detailed information about the ticket BOMs, such as the admission code, item number, admission entry validation, etc.';

                    ApplicationArea = NPRRetail;
                }
                action("Ticket Schedules")
                {

                    Caption = 'Ticket Schedules';
                    RunObject = Page "NPR TM Ticket Schedules";
                    ToolTip = 'View or edit detailed information about the ticket schedules such as schedule code and type, start from, recurrence pattern etc.';

                    ApplicationArea = NPRRetail;
                }
                action("Ticket Admissions")
                {

                    Caption = 'Ticket Admissions';
                    RunObject = Page "NPR TM Ticket Admissions";
                    ToolTip = 'View or edit detailed information about the ticket admissions such as capacity limits, default schedule, capacity control etc.';

                    ApplicationArea = NPRRetail;
                }
                action("Admission Schedule Lines")
                {

                    Caption = 'Admission Schedule Lines';
                    RunObject = Page "NPR TM Admis. Schedule Lines";
                    ToolTip = 'View or edit detailed information about the admission schedule lines such as admission code, schedule code, process order, scheduled start time and stop time etc.';

                    ApplicationArea = NPRRetail;
                }
            }
            group(Restaurant)
            {
                Caption = 'Restaurant';
                action("Seating Location")
                {

                    Caption = 'Seating Location';
                    RunObject = Page "NPR NPRE Seating Location";
                    ToolTip = 'View or edit detailed information about the seating locations for different zones of a restaurant.';

                    ApplicationArea = NPRRetail;
                }
                action("Seating List")
                {

                    Caption = 'Seating List';
                    RunObject = Page "NPR NPRE Seating List";
                    ToolTip = 'View or edit detailed information about the seating lists with statuses and capacity for each seating location.';

                    ApplicationArea = NPRRetail;
                }
                action("Flow Status")
                {

                    Caption = 'Flow Status';
                    RunObject = Page "NPR NPRE Select Flow Status";
                    ToolTip = 'View detailed information about the flow statuses for each object. ';

                    ApplicationArea = NPRRetail;
                }
            }
            group(POS)
            {
                action("POS Menus")
                {
                    Caption = 'POS Menus';
                    Image = PaymentJournal;
                    RunObject = Page "NPR POS Menus";
                    ToolTip = 'View or edit detailed information about the POS menus and related entities like Buttons for each menu.';

                    ApplicationArea = NPRRetail;
                }
                action(POSDragonglass)
                {

                    Caption = 'Open POS';
                    RunObject = Codeunit "NPR Open POS Page";
                    ToolTip = 'Opens the POS created to another window.';

                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(processing)
        {
            group(ActionGroup27)
            {
                Caption = 'Ticket';
                action("Ticket Setup")
                {
                    Caption = 'Ticket Setup';
                    RunObject = Page "NPR TM Ticket Setup";
                    ToolTip = 'View or edit detailed information about the ticket setup and related information.';
                    Image = ShowMatrix;
                    ApplicationArea = NPRRetail;
                }
                action("Ticket Access Statistics Matrix")
                {
                    Caption = 'Ticket Access Statistics Matrix';
                    RunObject = Page "NPR TM Ticket Acc. Stat. Mtrx";
                    ToolTip = 'View detailed information about the ticket access statistics by specifying rows and columns and also different filtering criteria.';

                    Image = ShowMatrix;
                    ApplicationArea = NPRRetail;
                }
                action("Admission Forecast Matrix")
                {
                    Caption = 'Admission Forecast Matrix';
                    RunObject = Page "NPR TM Admis. Forecast Matrix";
                    ToolTip = 'View detailed information about the admission forecasts by specifying rows and columns and also different filtering criteria.';

                    Image = ShowMatrix;
                    ApplicationArea = NPRRetail;
                }
                action(TicketWizard)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Create all required setup for a ticket from a single page.';
                    Caption = 'Ticket Wizard';
                    Image = Action;
                    RunObject = Codeunit "NPR TM Ticket Wizard";
                }
            }
            group(ActionGroup18)
            {
                Caption = 'Member';
                action("GDPR Setup")
                {

                    Caption = 'GDPR Setup';
                    RunObject = Page "NPR GDPR Setup";
                    ToolTip = 'View the list of the GDPR setup options.';

                    Image = Setup;
                    ApplicationArea = NPRRetail;
                }
                action("Recurring Payment Setup")
                {

                    Caption = 'Recurring Payment Setup';
                    RunObject = Page "NPR MM Recur. Payment Setup";
                    ToolTip = 'View or edit detailed information about the recurring payment setup and its posting.';


                    Image = SetupPayment;
                    ApplicationArea = NPRRetail;
                }
                action("Membership Alteration Journal")
                {

                    Caption = 'Membership Alteration Journal';
                    RunObject = Page "NPR MM Members. Alteration Jnl";
                    ToolTip = 'Create a journal for the membership alterations such as upgrade, cancelation, renewal, etc.';

                    Image = Journal;
                    ApplicationArea = NPRRetail;
                }
            }
            group(ActionGroup14)
            {
                Caption = 'Restaurant';
                action("Restaurant Setup")
                {
                    Caption = 'Restaurant Setup';
                    RunObject = Page "NPR NPRE Restaurant Setup";
                    ToolTip = 'View or edit detailed information about the restaurant setup, configure seating statuses, kitchen integration etc.';

                    Image = Setup;
                    ApplicationArea = NPRRetail;
                }
            }
            group(Reports)
            {
                Caption = 'List & Reports';
                group(Ticketing)
                {
                    Caption = 'Ticketing';
                    Image = Report;
                    action("NPR TM Ticket Reservation List")
                    {
                        Caption = 'List of Attendees';
                        Image = Report;
                        RunObject = Report "NPR TM Ticket Reservation List";
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Executes the List of Attendees action.';
                    }
                    action("NPR TM Visiting Report")
                    {
                        Caption = 'Admission Statistics';
                        Image = Report;
                        RunObject = Report "NPR TM Visiting Report";
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Executes the Admission Statistics action.';
                    }
                }
                group(Membership)
                {
                    Caption = 'Membership';
                    Image = Report;
                    action("NPR MM Membership Status")
                    {
                        Caption = 'Membership Status';
                        Image = Report;
                        RunObject = Report "NPR MM Membership Status";
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Executes the Membership Status action.';
                    }
                    action("NPR MM Membership Not Renewed")
                    {
                        Caption = 'Memberships not yet Renewed';
                        Image = Report;
                        RunObject = Report "NPR MM Membership Not Renewed";
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Executes the Memberships not yet Renewed action.';
                    }
                }
                group(LoyaltyProcessing)
                {
                    Caption = 'Loyalty';
                    Image = Report;
                    action("NPR MM Membersh. Points Summ.")
                    {
                        Caption = 'Membership Point Summary';
                        Image = Report;
                        RunObject = Report "NPR MM Membersh. Points Summ.";
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Executes the Membership Point Summary action.';
                    }
                    action("NPR MM Membership Points Value")
                    {
                        Caption = 'Membership Points Value';
                        Image = Report;
                        RunObject = Report "NPR MM Membership Points Value";
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Executes the Membership Points Value action.';
                    }

                    action("NPR MM Membership Points Det.")
                    {
                        Caption = 'Membership Point Detailed';
                        Image = Report;
                        RunObject = Report "NPR MM Membership Points Det.";
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Executes the Membership Point Detailed action.';
                    }
                }
            }
            group(Web)
            {
                Caption = 'Web';
                action("Task List")
                {
                    Caption = 'List of Tasks';
                    Image = TaskList;
                    RunObject = Page "NPR Nc Task List";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Executes the List of Tasks action';
                }
                action("Import List")
                {
                    Caption = 'Import List';
                    RunObject = Page "NPR Nc Import List";
                    ToolTip = 'View, edit or execute different imports.';
                    Image = Add;
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

