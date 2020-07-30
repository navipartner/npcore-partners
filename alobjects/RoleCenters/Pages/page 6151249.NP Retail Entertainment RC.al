page 6151249 "NP Retail Entertainment RC"
{
    Caption = 'Entertainment RC', Comment = '{Dependency=Match,"ProfileDescription_PRESIDENT-SMALLBUSINESS"}';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {

            part(Control7; "NP Retail Ent Headline")
            {
                // ApplicationArea = Basic, Suite;
            }




            part(Control2; "NP Retail Enter. Act - Ticket")
            {
            }
            part(Control20; "RC Ticket Activities")
            {
            }
            part(RCMembershipBurndownChart; "RC Membership Burndown Chart")
            {

            }

            part(RetailActivities; "Retail Activities")
            {
                Caption = 'ACTIVITIES';
            }



            part(RetailSalesChart; "Retail Sales Chart")
            {

            }


            part(MyJobQueue; "My Job Queue")
            {

            }
            part(MyReports; "My Reports")
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
                    RunObject = Page "MM Member Community";
                }
                action("Membership Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Membership Setup';
                    RunObject = Page "MM Membership Setup";
                }
                action("Membership Sales Setup")
                {
                    Caption = 'Membership Sales Setup';
                    RunObject = Page "MM Membership Sales Setup";
                }
                action("Membership Alteration")
                {
                    Caption = 'Membership Alteration';
                    RunObject = Page "MM Membership Alteration";
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
                    RunObject = Page "MM Member Notification Setup";
                }
                action("Membership Limitation Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Membership Limitation Setup';
                    RunObject = Page "MM Membership Limitation Setup";
                }
                action("Membership Admission Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Membership Admission Setup';
                    RunObject = Page "MM Membership Admission Setup";
                }
                action("MCS Person Groups")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'MCS Person Groups';
                    RunObject = Page "MCS Person Groups";
                }
                action("MCS Person Group Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'MCS Person Group Setup';
                    RunObject = Page "MCS Person Group Setup";
                }
            }
            group(Loyalty)
            {
                Caption = 'Loyalty';
                action("Loyalty Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Setup';
                    RunObject = Page "MM Loyalty Setup";
                }
                action("Loyalty Points Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Points Setup';
                    RunObject = Page "MM Loyalty Points Setup";
                }
                action("Loyalty Item Point Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Item Point Setup';
                    RunObject = Page "MM Loyalty Item Point Setup";
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
                    RunObject = Page "MM Loyalty Store Setup Server";
                }
                action("Loyalty Store Setup Client")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Store Setup Client';
                    RunObject = Page "MM Loyalty Store Setup Client";
                }
                action("Foreign Membership Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Foreign Membership Setup';
                    RunObject = Page "MM Foreign Membership Setup";
                }
                action("NPR Endpoint Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'NPR Endpoint Setup';
                    RunObject = Page "MM NPR Endpoint Setup";
                }
            }
            group(Ticket)
            {
                Caption = 'Ticket';
                action("Ticket Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ticket Type';
                    RunObject = Page "TM Ticket Type";
                }
                action("Ticket BOM")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ticket BOM';
                    RunObject = Page "TM Ticket BOM";
                }
                action("Ticket Schedules")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ticket Schedules';
                    RunObject = Page "TM Ticket Schedules";
                }
                action("Ticket Admissions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ticket Admissions';
                    RunObject = Page "TM Ticket Admissions";
                }
                action("Admission Schedule Lines")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Admission Schedule Lines';
                    RunObject = Page "TM Admission Schedule Lines";
                }
            }
            group(Restaurant)
            {
                Caption = 'Restaurant';
                action("Seating Location")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Seating Location';
                    RunObject = Page "NPRE Seating Location";
                }
                action("Seating List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Seating List';
                    RunObject = Page "NPRE Seating List";
                }
                action("Flow Status")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Flow Status';
                    RunObject = Page "NPRE Flow Status";
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
                    RunObject = Page "TM Ticket Setup";
                }
                action("Ticket Access Statistics Matrix")
                {
                    Caption = 'Ticket Access Statistics Matrix';
                    RunObject = Page "TM Ticket Access Stat. Mtrx";
                }
            }
            group(ActionGroup18)
            {
                Caption = 'Member';
                action("GDPR Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'GDPR Setup';
                    RunObject = Page "GDPR Setup";
                }
                action("Recurring Payment Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Recurring Payment Setup';
                    RunObject = Page "MM Recurring Payment Setup";
                }
            }
            group(ActionGroup14)
            {
                Caption = 'Restaurant';
                action("Restaurant Setup")
                {
                    Caption = 'Restaurant Setup';
                    RunObject = Page "NPRE Restaurant Setup";
                }
            }
            action("Import List")
            {
                Caption = 'Import List';
                RunObject = Page "Nc Import List";
            }
        }
    }
}

