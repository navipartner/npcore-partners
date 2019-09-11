page 6014556 "Retail Admin Role Center"
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
                part(Control6014447;"Retail Admin Activities - POS")
                {
                }
                part(Control6014446;"Retail Admin Activities - Tick")
                {
                }
            }
            group(Control6014445)
            {
                ShowCaption = false;
                part(Control6014444;"Retail Admin Activities - Memb")
                {
                }
                part(Control6014443;"Retail Admin Activities - Tick")
                {
                }
                part(Control6014442;"Retail Admin Activities - Tick")
                {
                }
            }
            group(Control6014429)
            {
                ShowCaption = false;
                part(Control6014412;"CRM Synch. Job Status Part")
                {
                    Visible = false;
                }
                part(Control6014411;"Service Connections Part")
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
                    RunObject = Page "POS Menus";
                }
                action("Default Views")
                {
                    Caption = 'Default Views';
                    Image = View;
                    RunObject = Page "POS Default Views";
                }
                action("POS Actions")
                {
                    Caption = 'POS Actions';
                    Image = "Action";
                    RunObject = Page "POS Actions";
                }
                action("View List")
                {
                    Caption = 'View List';
                    Image = ViewDocumentLine;
                    RunObject = Page "POS View List";
                }
                action("POS Sales Workflows")
                {
                    Caption = 'POS Sales Workflows';
                    Image = Allocate;
                    RunObject = Page "POS Sales Workflows";
                }
                action("POS Store List")
                {
                    Caption = 'POS Store List';
                    RunObject = Page "POS Store List";
                }
                action("POS Unit List")
                {
                    Caption = 'POS Unit List';
                    RunObject = Page "POS Unit List";
                }
                action("POS Posting Setup")
                {
                    Caption = 'POS Posting Setup';
                    RunObject = Page "POS Posting Setup";
                }
                action("POS Payment Method List")
                {
                    Caption = 'POS Payment Method List';
                    RunObject = Page "POS Payment Method List";
                }
                action("POS Payment Bins")
                {
                    Caption = 'POS Payment Bins';
                    RunObject = Page "POS Payment Bins";
                }
                action("Cash Registers")
                {
                    Caption = 'Cash Registers';
                    RunObject = Page "Register List";
                }
                action("Display Setup")
                {
                    Caption = 'Display Setup';
                    RunObject = Page "Display Setup";
                }
                action(Action6014434)
                {
                    Caption = 'POS Sales Workflows';
                    RunObject = Page "POS Sales Workflows";
                }
                action("POS Sales Workflow Sets")
                {
                    Caption = 'POS Sales Workflow Sets';
                    RunObject = Page "POS Sales Workflow Sets";
                }
                action("Dynamic Modules")
                {
                    Caption = 'Dynamic Modules';
                    RunObject = Page "Dynamic Modules";
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
                    RunObject = Page "Ean Box Events";
                }
                action("Ean Box Setups")
                {
                    Caption = 'Ean Box Setups';
                    Image = List;
                    RunObject = Page "Ean Box Setups";
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
                    RunObject = Page "Payment Type - List";
                }
            }
            group(Member)
            {
                Caption = 'Member';
                action("Membership Setup")
                {
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
                action("Member Community")
                {
                    Caption = 'Member Community';
                    RunObject = Page "MM Member Community";
                }
            }
            group(Ticket)
            {
                Caption = 'Ticket';
                action("Ticket Type")
                {
                    Caption = 'Ticket Type';
                    RunObject = Page "TM Ticket Type";
                }
                action("Ticket Admission BOM")
                {
                    Caption = 'Ticket Admission BOM';
                    RunObject = Page "TM Ticket BOM";
                }
                action("Ticket Schedules")
                {
                    Caption = 'Ticket Schedules';
                    RunObject = Page "TM Ticket Schedules";
                }
                action("Ticket Admissions")
                {
                    Caption = 'Ticket Admissions';
                    RunObject = Page "TM Ticket Admissions";
                }
                action("Ticket Admission Object Schedules")
                {
                    Caption = 'Ticket Admission Object Schedules';
                    RunObject = Page "TM Admission Schedule Lines";
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
                RunObject = Page "NP Retail Setup";
            }
            action("Retail Setup")
            {
                Caption = 'Retail Setup';
                RunObject = Page "Retail Setup";
            }
            action("MPOS App Setup")
            {
                Caption = 'MPOS App Setup';
                RunObject = Page "MPOS App Setup Card";
            }
            action("Company Information")
            {
                Caption = 'Company Information';
                RunObject = Page "Company Information";
            }
            action("Table Export")
            {
                Caption = 'Table Export';
                RunObject = Page "Table Export Wizard";
            }
            action("Table Import")
            {
                Caption = 'Table Import';
                RunObject = Page "Table Import Wizard";
            }
        }
    }
}

