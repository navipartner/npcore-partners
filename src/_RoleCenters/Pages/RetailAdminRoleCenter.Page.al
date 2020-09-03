page 6014556 "NPR Retail Admin Role Center"
{
    // NPR5.51/ZESO/20190725  CASE 343621 New Role Centre Page

    Caption = 'Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control6014448)
            {
                ShowCaption = false;
                part(Control6014447; "NPR Retail Admin Activ. - POS")
                {
                }
                part(Control6014446; "NPR Retail Admin Activ. - Tick")
                {
                }
            }
            group(Control6014445)
            {
                ShowCaption = false;
                part(Control6014444; "NPR Retail Admin Activ. - Memb")
                {
                }
                part(Control6014443; "NPR Retail Admin Activ. - Tick")
                {
                }
                part(Control6014442; "NPR Retail Admin Activ. - Tick")
                {
                }
            }
            group(Control6014429)
            {
                ShowCaption = false;
                part(Control6014412; "CRM Synch. Job Status Part")
                {
                    Visible = false;
                }
                part(Control6014411; "Service Connections Part")
                {
                    Visible = false;
                }
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
            ToolTip = 'Set up users and cross-product values, such as number series and post codes.';
        }
        area(sections)
        {
            group(POS)
            {
                Caption = 'POS';
                Image = Reconcile;
                action("POS Menus")
                {
                    Caption = 'POS Menus';
                    Image = PaymentJournal;
                    RunObject = Page "NPR POS Menus";
                }
                action("Default Views")
                {
                    Caption = 'Default Views';
                    Image = View;
                    RunObject = Page "NPR POS Default Views";
                }
                action("POS Actions")
                {
                    Caption = 'POS Actions';
                    Image = "Action";
                    RunObject = Page "NPR POS Actions";
                }
                action("View List")
                {
                    Caption = 'View List';
                    Image = ViewDocumentLine;
                    RunObject = Page "NPR POS View List";
                }
                action("POS Sales Workflows")
                {
                    Caption = 'POS Sales Workflows';
                    Image = Allocate;
                    RunObject = Page "NPR POS Sales Workflows";
                }
                action("POS Store List")
                {
                    Caption = 'POS Store List';
                    RunObject = Page "NPR POS Store List";
                }
                action("POS Unit List")
                {
                    Caption = 'POS Unit List';
                    RunObject = Page "NPR POS Unit List";
                }
                action("POS Posting Setup")
                {
                    Caption = 'POS Posting Setup';
                    RunObject = Page "NPR POS Posting Setup";
                }
                action("POS Payment Method List")
                {
                    Caption = 'POS Payment Method List';
                    RunObject = Page "NPR POS Payment Method List";
                }
                action("POS Payment Bins")
                {
                    Caption = 'POS Payment Bins';
                    RunObject = Page "NPR POS Payment Bins";
                }
                action("Cash Registers")
                {
                    Caption = 'Cash Registers';
                    RunObject = Page "NPR Register List";
                }
                action("Display Setup")
                {
                    Caption = 'Display Setup';
                    RunObject = Page "NPR Display Setup";
                }
                action(Action6014434)
                {
                    Caption = 'POS Sales Workflows';
                    RunObject = Page "NPR POS Sales Workflows";
                }
                action("POS Sales Workflow Sets")
                {
                    Caption = 'POS Sales Workflow Sets';
                    RunObject = Page "NPR POS Sales Workflow Sets";
                }
                action("Dynamic Modules")
                {
                    Caption = 'Dynamic Modules';
                    RunObject = Page "NPR Dynamic Modules";
                }
                action("User Setup")
                {
                    Caption = 'User Setup';
                    Image = UserSetup;
                    RunObject = Page "User Setup";
                }
                action("No. Series")
                {
                    Caption = 'No. Series';
                    RunObject = Page "No. Series";
                }
            }
            group("Ean Box Events")
            {
                Caption = 'Ean Box Events';
                Image = LotInfo;
                action(Action6014427)
                {
                    Caption = 'Ean Box Events';
                    Image = List;
                    RunObject = Page "NPR Ean Box Events";
                }
                action("Ean Box Setups")
                {
                    Caption = 'Ean Box Setups';
                    Image = List;
                    RunObject = Page "NPR Ean Box Setups";
                }
            }
            group(PaymentCard)
            {
                Caption = 'Payment';
                Image = CostAccounting;
                action("<Page Payment Type - List>")
                {
                    Caption = 'Types';
                    Image = Payment;
                    RunObject = Page "NPR Payment Type - List";
                }
            }
            group(Member)
            {
                Caption = 'Member';
                action("Membership Setup")
                {
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
                action("Member Community")
                {
                    Caption = 'Member Community';
                    RunObject = Page "NPR MM Member Community";
                }
            }
            group(Ticket)
            {
                Caption = 'Ticket';
                action("Ticket Type")
                {
                    Caption = 'Ticket Type';
                    RunObject = Page "NPR TM Ticket Type";
                }
                action("Ticket Admission BOM")
                {
                    Caption = 'Ticket Admission BOM';
                    RunObject = Page "NPR TM Ticket BOM";
                }
                action("Ticket Schedules")
                {
                    Caption = 'Ticket Schedules';
                    RunObject = Page "NPR TM Ticket Schedules";
                }
                action("Ticket Admissions")
                {
                    Caption = 'Ticket Admissions';
                    RunObject = Page "NPR TM Ticket Admissions";
                }
                action("Ticket Admission Object Schedules")
                {
                    Caption = 'Ticket Admission Object Schedules';
                    RunObject = Page "NPR TM Admis. Schedule Lines";
                }
            }
            group(Configuration)
            {
                Caption = 'Configuration';
                action("Configuration Templates")
                {
                    Caption = 'Configuration Templates';
                    RunObject = Page "Config. Template List";
                }
                action("Configuration Packages")
                {
                    Caption = 'Configuration Packages';
                    RunObject = Page "Config. Packages";
                }
                action("Configuration Questionnaire")
                {
                    Caption = 'Configuration Questionnaire';
                    RunObject = Page "Config. Questionnaire";
                }
            }
        }
        area(processing)
        {
            action("NP Retail Setup")
            {
                Caption = 'NP Retail Setup';
                RunObject = Page "NPR NP Retail Setup";
            }
            action("Retail Setup")
            {
                Caption = 'Retail Setup';
                RunObject = Page "NPR Retail Setup";
            }
            action("MPOS App Setup")
            {
                Caption = 'MPOS App Setup';
                RunObject = Page "NPR MPOS App Setup Card";
            }
            action("Company Information")
            {
                Caption = 'Company Information';
                RunObject = Page "Company Information";
            }
            action("Table Export")
            {
                Caption = 'Table Export';
                RunObject = Page "NPR Table Export Wizard";
            }
            action("Table Import")
            {
                Caption = 'Table Import';
                RunObject = Page "NPR Table Import Wizard";
            }
        }
    }
}

