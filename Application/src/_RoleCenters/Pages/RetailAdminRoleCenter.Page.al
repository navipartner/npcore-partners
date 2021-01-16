page 6014556 "NPR Retail Admin Role Center"
{
    // NPR5.51/ZESO/20190725  CASE 343621 New Role Centre Page

    Caption = 'Role Center';
    PageType = RoleCenter;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(rolecenter)
        {
            group(Control6014448)
            {
                ShowCaption = false;
                part(Control6014447; "NPR Retail Admin Activ. - POS")
                {
                    ApplicationArea = All;
                }
                part(Control6014446; "NPR Retail Admin Activ. - Tick")
                {
                    ApplicationArea = All;
                }
            }
            group(Control6014445)
            {
                ShowCaption = false;
                part(Control6014444; "NPR Retail Admin Activ. - Memb")
                {
                    ApplicationArea = All;
                }
                part(Control6014443; "NPR Retail Admin Activ. - Tick")
                {
                    ApplicationArea = All;
                }
                part(Control6014442; "NPR Retail Admin Activ. - Tick")
                {
                    ApplicationArea = All;
                }
            }
            group(Control6014429)
            {
                ShowCaption = false;
                part(Control6014412; "CRM Synch. Job Status Part")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                part(Control6014411; "Service Connections Part")
                {
                    Visible = false;
                    ApplicationArea = All;
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Menus action';
                }
                action("Default Views")
                {
                    Caption = 'Default Views';
                    Image = View;
                    RunObject = Page "NPR POS Default Views";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Default Views action';
                }
                action("POS Actions")
                {
                    Caption = 'POS Actions';
                    Image = "Action";
                    RunObject = Page "NPR POS Actions";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Actions action';
                }
                action("View List")
                {
                    Caption = 'View List';
                    Image = ViewDocumentLine;
                    RunObject = Page "NPR POS View List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the View List action';
                }
                action("POS Sales Workflows")
                {
                    Caption = 'POS Sales Workflows';
                    Image = Allocate;
                    RunObject = Page "NPR POS Sales Workflows";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Sales Workflows action';
                }
                action("POS Store List")
                {
                    Caption = 'POS Store List';
                    RunObject = Page "NPR POS Store List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Store List action';
                }
                action("POS Unit List")
                {
                    Caption = 'POS Unit List';
                    RunObject = Page "NPR POS Unit List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Unit List action';
                }
                action("POS Posting Setup")
                {
                    Caption = 'POS Posting Setup';
                    RunObject = Page "NPR POS Posting Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Posting Setup action';
                }
                action("POS Payment Method List")
                {
                    Caption = 'POS Payment Method List';
                    RunObject = Page "NPR POS Payment Method List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Payment Method List action';
                }
                action("POS Payment Bins")
                {
                    Caption = 'POS Payment Bins';
                    RunObject = Page "NPR POS Payment Bins";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Payment Bins action';
                }
                action("Cash Registers")
                {
                    Caption = 'Cash Registers';
                    RunObject = Page "NPR Register List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Cash Registers action';
                }
                action("Display Setup")
                {
                    Caption = 'Display Setup';
                    RunObject = Page "NPR Display Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Display Setup action';
                }
                action(Action6014434)
                {
                    Caption = 'POS Sales Workflows';
                    RunObject = Page "NPR POS Sales Workflows";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Sales Workflows action';
                }
                action("POS Sales Workflow Sets")
                {
                    Caption = 'POS Sales Workflow Sets';
                    RunObject = Page "NPR POS Sales Workflow Sets";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Sales Workflow Sets action';
                }
                action("Dynamic Modules")
                {
                    Caption = 'Dynamic Modules';
                    RunObject = Page "NPR Dynamic Modules";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dynamic Modules action';
                }
                action("User Setup")
                {
                    Caption = 'User Setup';
                    Image = UserSetup;
                    RunObject = Page "User Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the User Setup action';
                }
                action("No. Series")
                {
                    Caption = 'No. Series';
                    RunObject = Page "No. Series";
                    ApplicationArea = All;
                    ToolTip = 'Executes the No. Series action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ean Box Events action';
                }
                action("Ean Box Setups")
                {
                    Caption = 'Ean Box Setups';
                    Image = List;
                    RunObject = Page "NPR Ean Box Setups";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ean Box Setups action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Types action';
                }
            }
            group(Member)
            {
                Caption = 'Member';
                action("Membership Setup")
                {
                    Caption = 'Membership Setup';
                    RunObject = Page "NPR MM Membership Setup";
                    ApplicationArea = All;
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
                action("Member Community")
                {
                    Caption = 'Member Community';
                    RunObject = Page "NPR MM Member Community";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Member Community action';
                }
            }
            group(Ticket)
            {
                Caption = 'Ticket';
                action("Ticket Type")
                {
                    Caption = 'Ticket Type';
                    RunObject = Page "NPR TM Ticket Type";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Type action';
                }
                action("Ticket Admission BOM")
                {
                    Caption = 'Ticket Admission BOM';
                    RunObject = Page "NPR TM Ticket BOM";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Admission BOM action';
                }
                action("Ticket Schedules")
                {
                    Caption = 'Ticket Schedules';
                    RunObject = Page "NPR TM Ticket Schedules";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Schedules action';
                }
                action("Ticket Admissions")
                {
                    Caption = 'Ticket Admissions';
                    RunObject = Page "NPR TM Ticket Admissions";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Admissions action';
                }
                action("Ticket Admission Object Schedules")
                {
                    Caption = 'Ticket Admission Object Schedules';
                    RunObject = Page "NPR TM Admis. Schedule Lines";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Admission Object Schedules action';
                }
            }
            group(Configuration)
            {
                Caption = 'Configuration';
                action("Configuration Templates")
                {
                    Caption = 'Configuration Templates';
                    RunObject = Page "Config. Template List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Configuration Templates action';
                }
                action("Configuration Packages")
                {
                    Caption = 'Configuration Packages';
                    RunObject = Page "Config. Packages";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Configuration Packages action';
                }
                action("Configuration Questionnaire")
                {
                    Caption = 'Configuration Questionnaire';
                    RunObject = Page "Config. Questionnaire";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Configuration Questionnaire action';
                }
            }
        }
        area(processing)
        {
            action("NP Retail Setup")
            {
                Caption = 'NP Retail Setup';
                RunObject = Page "NPR NP Retail Setup";
                ApplicationArea = All;
                ToolTip = 'Executes the NP Retail Setup action';
            }
            action("Retail Setup")
            {
                Caption = 'Retail Setup';
                RunObject = Page "NPR Retail Setup";
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Setup action';
            }
            action("MPOS App Setup")
            {
                Caption = 'MPOS App Setup';
                RunObject = Page "NPR MPOS App Setup Card";
                ApplicationArea = All;
                ToolTip = 'Executes the MPOS App Setup action';
            }
            action("Company Information")
            {
                Caption = 'Company Information';
                RunObject = Page "Company Information";
                ApplicationArea = All;
                ToolTip = 'Executes the Company Information action';
            }
            action("Table Export")
            {
                Caption = 'Table Export';
                RunObject = Page "NPR Table Export Wizard";
                ApplicationArea = All;
                ToolTip = 'Executes the Table Export action';
            }
            action("Table Import")
            {
                Caption = 'Table Import';
                RunObject = Page "NPR Table Import Wizard";
                ApplicationArea = All;
                ToolTip = 'Executes the Table Import action';
            }
        }
    }
}

