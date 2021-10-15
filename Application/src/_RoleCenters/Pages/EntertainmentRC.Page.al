page 6151249 "NPR Entertainment RC"
{
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
            part(RCMembershipBurndownChart; "NPR RC Members. Burndown Chart")
            {
                ApplicationArea = NPRRetail;


            }
            part(RetailActivities; "NPR Retail Activities")
            {
                Caption = 'ACTIVITIES';
                ApplicationArea = NPRRetail;

            }
            part(RetailSalesChart; "NPR Retail Sales Chart")
            {
                ApplicationArea = NPRRetail;

            }
            part(MyJobQueue; "My Job Queue")
            {
                Caption = 'Job Queue';
                ApplicationArea = NPRRetail;
            }
            part(MyReports; "NPR My Reports")
            {
                ApplicationArea = NPRRetail;

            }
            part(PowerBi; "Power BI Report Spinner Part")
            {
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
                    ToolTip = 'Executes the Member Community action';
                    ApplicationArea = NPRRetail;
                }
                action("Membership Setup")
                {

                    Caption = 'Membership Setup';
                    RunObject = Page "NPR MM Membership Setup";
                    ToolTip = 'Executes the Membership Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("Membership Sales Setup")
                {
                    Caption = 'Membership Sales Setup';
                    RunObject = Page "NPR MM Membership Sales Setup";

                    ToolTip = 'Executes the Membership Sales Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("Membership Alteration")
                {
                    Caption = 'Membership Alteration';
                    RunObject = Page "NPR MM Membership Alter.";

                    ToolTip = 'Executes the Membership Alteration action';
                    ApplicationArea = NPRRetail;
                }
                action("Member Notification Setup")
                {

                    Caption = 'Member Notification Setup';
                    RunObject = Page "NPR MM Member Notific. Setup";
                    ToolTip = 'Executes the Member Notification Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("Membership Limitation Setup")
                {

                    Caption = 'Membership Limitation Setup';
                    RunObject = Page "NPR MM Membership Lim. Setup";
                    ToolTip = 'Executes the Membership Limitation Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("Membership Admission Setup")
                {

                    Caption = 'Membership Admission Setup';
                    RunObject = Page "NPR MM Members. Admis. Setup";
                    ToolTip = 'Executes the Membership Admission Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("MCS Person Groups")
                {

                    Caption = 'MCS Person Groups';
                    RunObject = Page "NPR MCS Person Groups";
                    ToolTip = 'Executes the MCS Person Groups action';
                    ApplicationArea = NPRRetail;
                }
                action("MCS Person Group Setup")
                {

                    Caption = 'MCS Person Group Setup';
                    RunObject = Page "NPR MCS Person Group Setup";
                    ToolTip = 'Executes the MCS Person Group Setup action';
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
                    ToolTip = 'Executes the Loyalty Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("Loyalty Points Setup")
                {

                    Caption = 'Loyalty Points Setup';
                    RunObject = Page "NPR MM Loyalty Point Setup";
                    ToolTip = 'Executes the Loyalty Points Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("Loyalty Item Point Setup")
                {

                    Caption = 'Loyalty Item Point Setup';
                    RunObject = Page "NPR MM Loy. Item Point Setup";
                    ToolTip = 'Executes the Loyalty Item Point Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("Loyalty Store Setup Server")
                {

                    Caption = 'Loyalty Store Setup Server';
                    RunObject = Page "NPR MM Loy. Store Setup Server";
                    ToolTip = 'Executes the Loyalty Store Setup Server action';
                    ApplicationArea = NPRRetail;
                }
                action("Loyalty Store Setup Client")
                {

                    Caption = 'Loyalty Store Setup Client';
                    RunObject = Page "NPR MM Loy. Store Setup Client";
                    ToolTip = 'Executes the Loyalty Store Setup Client action';
                    ApplicationArea = NPRRetail;
                }
                action("Foreign Membership Setup")
                {

                    Caption = 'Foreign Membership Setup';
                    RunObject = Page "NPR MM Foreign Members. Setup";
                    ToolTip = 'Executes the Foreign Membership Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("NPR Endpoint Setup")
                {

                    Caption = 'NPR Endpoint Setup';
                    RunObject = Page "NPR MM NPR Endpoint Setup";
                    ToolTip = 'Executes the NPR Endpoint Setup action';
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
                    ToolTip = 'Executes the Ticket Type action';
                    ApplicationArea = NPRRetail;
                }
                action("Ticket BOM")
                {

                    Caption = 'Ticket BOM';
                    RunObject = Page "NPR TM Ticket BOM";
                    ToolTip = 'Executes the Ticket BOM action';
                    ApplicationArea = NPRRetail;
                }
                action("Ticket Schedules")
                {

                    Caption = 'Ticket Schedules';
                    RunObject = Page "NPR TM Ticket Schedules";
                    ToolTip = 'Executes the Ticket Schedules action';
                    ApplicationArea = NPRRetail;
                }
                action("Ticket Admissions")
                {

                    Caption = 'Ticket Admissions';
                    RunObject = Page "NPR TM Ticket Admissions";
                    ToolTip = 'Executes the Ticket Admissions action';
                    ApplicationArea = NPRRetail;
                }
                action("Admission Schedule Lines")
                {

                    Caption = 'Admission Schedule Lines';
                    RunObject = Page "NPR TM Admis. Schedule Lines";
                    ToolTip = 'Executes the Admission Schedule Lines action';
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
                    ToolTip = 'Executes the Seating Location action';
                    ApplicationArea = NPRRetail;
                }
                action("Seating List")
                {

                    Caption = 'Seating List';
                    RunObject = Page "NPR NPRE Seating List";
                    ToolTip = 'Executes the Seating List action';
                    ApplicationArea = NPRRetail;
                }
                action("Flow Status")
                {

                    Caption = 'Flow Status';
                    RunObject = Page "NPR NPRE Select Flow Status";
                    ToolTip = 'Executes the Flow Status action';
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

                    ToolTip = 'Executes the Ticket Setup action';
                    Image = Setup;
                    ApplicationArea = NPRRetail;
                }
                action("Ticket Access Statistics Matrix")
                {
                    Caption = 'Ticket Access Statistics Matrix';
                    RunObject = Page "NPR TM Ticket Acc. Stat. Mtrx";

                    ToolTip = 'Executes the Ticket Access Statistics Matrix action';
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
                    ToolTip = 'Executes the GDPR Setup action';
                    Image = Setup;
                    ApplicationArea = NPRRetail;
                }
                action("Recurring Payment Setup")
                {

                    Caption = 'Recurring Payment Setup';
                    RunObject = Page "NPR MM Recur. Payment Setup";
                    ToolTip = 'Executes the Recurring Payment Setup action';
                    Image = SetupPayment;
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

                    ToolTip = 'Executes the Restaurant Setup action';
                    Image = Setup;
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(Creation)
        {
            action("Import List")
            {
                Caption = 'Import List';
                RunObject = Page "NPR Nc Import List";

                ToolTip = 'Executes the Import List action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

