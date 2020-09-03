page 6151249 "NPR Entertainment RC"
{
    Caption = 'Entertainment RC', Comment = '{Dependency=Match,"ProfileDescription_PRESIDENT-SMALLBUSINESS"}';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {

            part(Control7; "NPR Retail Ent Headline")
            {
                // ApplicationArea = Basic, Suite;
            }




            part(Control2; "NPR Retail Enter. Act - Ticket")
            {
            }
            part(Control20; "NPR RC Ticket Activities")
            {
            }
            part(RCMembershipBurndownChart; "NPR RC Members. Burndown Chart")
            {

            }

            part(RetailActivities; "NPR Retail Activities")
            {
                Caption = 'ACTIVITIES';
            }



            part(RetailSalesChart; "NPR Retail Sales Chart")
            {

            }


            part(MyJobQueue; "My Job Queue")
            {

            }
            part(MyReports; "NPR My Reports")
            {


            }
            part(PowerBi; "Power BI Report Spinner Part")
            {

            }
        }
    }

    actions
    {
        area(reporting)
        {
        }
        area(embedding)
        {
        }
        area(sections)
        {
            group(Member)
            {
                Caption = 'Member';
                Image = Journals;
                action("Member Community")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Member Community';
                    RunObject = Page "NPR MM Member Community";
                }
                action("Membership Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Membership Setup';
                    RunObject = Page "NPR MM Membership Setup";
                }
                action("Membership Sales Setup")
                {
                    Caption = 'Membership Sales Setup';
                    RunObject = Page "NPR MM Membership Sales Setup";
                }
                action("Membership Alteration")
                {
                    Caption = 'Membership Alteration';
                    RunObject = Page "NPR MM Membership Alter.";
                }
                action("Sponsorship Ticket Setup")
                {
                    Caption = 'Sponsorship Ticket Setup';
                    //RunObject = Page "MM Sponsorship Ticket Setup";
                }
                action("Member Notification Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Member Notification Setup';
                    RunObject = Page "NPR MM Member Notific. Setup";
                }
                action("Membership Limitation Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Membership Limitation Setup';
                    RunObject = Page "NPR MM Membership Lim. Setup";
                }
                action("Membership Admission Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Membership Admission Setup';
                    RunObject = Page "NPR MM Members. Admis. Setup";
                }
                action("MCS Person Groups")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'MCS Person Groups';
                    RunObject = Page "NPR MCS Person Groups";
                }
                action("MCS Person Group Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'MCS Person Group Setup';
                    RunObject = Page "NPR MCS Person Group Setup";
                }
            }
            group(Loyalty)
            {
                Caption = 'Loyalty';
                action("Loyalty Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Setup';
                    RunObject = Page "NPR MM Loyalty Setup";
                }
                action("Loyalty Points Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Points Setup';
                    RunObject = Page "NPR MM Loyalty Point Setup";
                }
                action("Loyalty Item Point Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Item Point Setup';
                    RunObject = Page "NPR MM Loy. Item Point Setup";
                }
                action("Loyalty Alter Membership")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Alter Membership';
                    //RunObject = Page "MM Loyalty Alter Membership";
                }
                action("Loyalty Store Setup Server")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Store Setup Server';
                    RunObject = Page "NPR MM Loy. Store Setup Server";
                }
                action("Loyalty Store Setup Client")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Store Setup Client';
                    RunObject = Page "NPR MM Loy. Store Setup Client";
                }
                action("Foreign Membership Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Foreign Membership Setup';
                    RunObject = Page "NPR MM Foreign Members. Setup";
                }
                action("NPR Endpoint Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'NPR Endpoint Setup';
                    RunObject = Page "NPR MM NPR Endpoint Setup";
                }
            }
            group(Ticket)
            {
                Caption = 'Ticket';
                action("Ticket Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ticket Type';
                    RunObject = Page "NPR TM Ticket Type";
                }
                action("Ticket BOM")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ticket BOM';
                    RunObject = Page "NPR TM Ticket BOM";
                }
                action("Ticket Schedules")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ticket Schedules';
                    RunObject = Page "NPR TM Ticket Schedules";
                }
                action("Ticket Admissions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ticket Admissions';
                    RunObject = Page "NPR TM Ticket Admissions";
                }
                action("Admission Schedule Lines")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Admission Schedule Lines';
                    RunObject = Page "NPR TM Admis. Schedule Lines";
                }
            }
            group(Restaurant)
            {
                Caption = 'Restaurant';
                action("Seating Location")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Seating Location';
                    RunObject = Page "NPR NPRE Seating Location";
                }
                action("Seating List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Seating List';
                    RunObject = Page "NPR NPRE Seating List";
                }
                action("Flow Status")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Flow Status';
                    RunObject = Page "NPR NPRE Select Flow Status";
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
                }
                action("Ticket Access Statistics Matrix")
                {
                    Caption = 'Ticket Access Statistics Matrix';
                    RunObject = Page "NPR TM Ticket Acc. Stat. Mtrx";
                }
            }
            group(ActionGroup18)
            {
                Caption = 'Member';
                action("GDPR Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'GDPR Setup';
                    RunObject = Page "NPR GDPR Setup";
                }
                action("Recurring Payment Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Recurring Payment Setup';
                    RunObject = Page "NPR MM Recur. Payment Setup";
                }
            }
            group(ActionGroup14)
            {
                Caption = 'Restaurant';
                action("Restaurant Setup")
                {
                    Caption = 'Restaurant Setup';
                    RunObject = Page "NPR NPRE Restaurant Setup";
                }
            }
            action("Import List")
            {
                Caption = 'Import List';
                RunObject = Page "NPR Nc Import List";
            }
        }
    }
}

