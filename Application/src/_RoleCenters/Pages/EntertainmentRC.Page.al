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
                ApplicationArea = All;
                // ApplicationArea = Basic, Suite;
            }




            part(Control2; "NPR Retail Enter. Act - Ticket")
            {
                ApplicationArea = All;
            }
            part(Control20; "NPR RC Ticket Activities")
            {
                ApplicationArea = All;
            }
            part(RCMembershipBurndownChart; "NPR RC Members. Burndown Chart")
            {
                ApplicationArea = All;

            }

            part(RetailActivities; "NPR Retail Activities")
            {
                Caption = 'ACTIVITIES';
                ApplicationArea = All;
            }



            part(RetailSalesChart; "NPR Retail Sales Chart")
            {
                ApplicationArea = All;

            }


            part(MyJobQueue; "My Job Queue")
            {
                ApplicationArea = All;

            }
            part(MyReports; "NPR My Reports")
            {
                ApplicationArea = All;


            }
            part(PowerBi; "Power BI Report Spinner Part")
            {
                ApplicationArea = All;

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
                    ToolTip = 'Executes the Member Community action';
                }
                action("Membership Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Membership Setup';
                    RunObject = Page "NPR MM Membership Setup";
                    ToolTip = 'Executes the Membership Setup action';
                }
                action("Membership Sales Setup")
                {
                    Caption = 'Membership Sales Setup';
                    RunObject = Page "NPR MM Membership Sales Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Membership Sales Setup action';
                }
                action("Membership Alteration")
                {
                    Caption = 'Membership Alteration';
                    RunObject = Page "NPR MM Membership Alter.";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Membership Alteration action';
                }
                action("Sponsorship Ticket Setup")
                {
                    Caption = 'Sponsorship Ticket Setup';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sponsorship Ticket Setup action';
                    //RunObject = Page "MM Sponsorship Ticket Setup";
                }
                action("Member Notification Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Member Notification Setup';
                    RunObject = Page "NPR MM Member Notific. Setup";
                    ToolTip = 'Executes the Member Notification Setup action';
                }
                action("Membership Limitation Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Membership Limitation Setup';
                    RunObject = Page "NPR MM Membership Lim. Setup";
                    ToolTip = 'Executes the Membership Limitation Setup action';
                }
                action("Membership Admission Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Membership Admission Setup';
                    RunObject = Page "NPR MM Members. Admis. Setup";
                    ToolTip = 'Executes the Membership Admission Setup action';
                }
                action("MCS Person Groups")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'MCS Person Groups';
                    RunObject = Page "NPR MCS Person Groups";
                    ToolTip = 'Executes the MCS Person Groups action';
                }
                action("MCS Person Group Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'MCS Person Group Setup';
                    RunObject = Page "NPR MCS Person Group Setup";
                    ToolTip = 'Executes the MCS Person Group Setup action';
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
                    ToolTip = 'Executes the Loyalty Setup action';
                }
                action("Loyalty Points Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Points Setup';
                    RunObject = Page "NPR MM Loyalty Point Setup";
                    ToolTip = 'Executes the Loyalty Points Setup action';
                }
                action("Loyalty Item Point Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Item Point Setup';
                    RunObject = Page "NPR MM Loy. Item Point Setup";
                    ToolTip = 'Executes the Loyalty Item Point Setup action';
                }
                action("Loyalty Alter Membership")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Alter Membership';
                    ToolTip = 'Executes the Loyalty Alter Membership action';
                    //RunObject = Page "MM Loyalty Alter Membership";
                }
                action("Loyalty Store Setup Server")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Store Setup Server';
                    RunObject = Page "NPR MM Loy. Store Setup Server";
                    ToolTip = 'Executes the Loyalty Store Setup Server action';
                }
                action("Loyalty Store Setup Client")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Loyalty Store Setup Client';
                    RunObject = Page "NPR MM Loy. Store Setup Client";
                    ToolTip = 'Executes the Loyalty Store Setup Client action';
                }
                action("Foreign Membership Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Foreign Membership Setup';
                    RunObject = Page "NPR MM Foreign Members. Setup";
                    ToolTip = 'Executes the Foreign Membership Setup action';
                }
                action("NPR Endpoint Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'NPR Endpoint Setup';
                    RunObject = Page "NPR MM NPR Endpoint Setup";
                    ToolTip = 'Executes the NPR Endpoint Setup action';
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
                    ToolTip = 'Executes the Ticket Type action';
                }
                action("Ticket BOM")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ticket BOM';
                    RunObject = Page "NPR TM Ticket BOM";
                    ToolTip = 'Executes the Ticket BOM action';
                }
                action("Ticket Schedules")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ticket Schedules';
                    RunObject = Page "NPR TM Ticket Schedules";
                    ToolTip = 'Executes the Ticket Schedules action';
                }
                action("Ticket Admissions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ticket Admissions';
                    RunObject = Page "NPR TM Ticket Admissions";
                    ToolTip = 'Executes the Ticket Admissions action';
                }
                action("Admission Schedule Lines")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Admission Schedule Lines';
                    RunObject = Page "NPR TM Admis. Schedule Lines";
                    ToolTip = 'Executes the Admission Schedule Lines action';
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
                    ToolTip = 'Executes the Seating Location action';
                }
                action("Seating List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Seating List';
                    RunObject = Page "NPR NPRE Seating List";
                    ToolTip = 'Executes the Seating List action';
                }
                action("Flow Status")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Flow Status';
                    RunObject = Page "NPR NPRE Select Flow Status";
                    ToolTip = 'Executes the Flow Status action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Setup action';
                }
                action("Ticket Access Statistics Matrix")
                {
                    Caption = 'Ticket Access Statistics Matrix';
                    RunObject = Page "NPR TM Ticket Acc. Stat. Mtrx";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Access Statistics Matrix action';
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
                    ToolTip = 'Executes the GDPR Setup action';
                }
                action("Recurring Payment Setup")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Recurring Payment Setup';
                    RunObject = Page "NPR MM Recur. Payment Setup";
                    ToolTip = 'Executes the Recurring Payment Setup action';
                }
            }
            group(ActionGroup14)
            {
                Caption = 'Restaurant';
                action("Restaurant Setup")
                {
                    Caption = 'Restaurant Setup';
                    RunObject = Page "NPR NPRE Restaurant Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Restaurant Setup action';
                }
            }
            action("Import List")
            {
                Caption = 'Import List';
                RunObject = Page "NPR Nc Import List";
                ApplicationArea = All;
                ToolTip = 'Executes the Import List action';
            }
        }
    }
}

