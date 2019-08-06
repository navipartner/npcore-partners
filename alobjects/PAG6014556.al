page 6014556 "Retail Admin Role Center"
{
    // #343621/ZESO/20190725  CASE 343621 New Role Centre Page
    // #363739/ZESO/20190805  CASE 363739 Added Pages 6014485 - Table Import Wizard and 6014480 - Object List

    Caption = 'Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control1900724808)
            {
                ShowCaption = false;
                part(Control1904484608;"IT Operations Activities")
                {
                }
                part(Control58;"CRM Synch. Job Status Part")
                {
                    Visible = false;
                }
                part(Control52;"Service Connections Part")
                {
                    Visible = false;
                }
            }
            group(Control1900724708)
            {
                ShowCaption = false;
                part(Control36;"Report Inbox Part")
                {
                }
                part(Control32;"My Job Queue")
                {
                    Visible = false;
                }
                systempart(Control1901377608;MyNotes)
                {
                }
            }
        }
    }

    actions
    {
        area(reporting)
        {
            action("Check on Ne&gative Inventory")
            {
                Caption = 'Check on Ne&gative Inventory';
                Image = "Report";
                RunObject = Report "Items with Negative Inventory";
            }
        }
        area(embedding)
        {
            ToolTip = 'Set up users and cross-product values, such as number series and post codes.';
            action("Job Queue Entries")
            {
                Caption = 'Job Queue Entries';
                RunObject = Page "Job Queue Entries";
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
            action("Approval User Setup")
            {
                Caption = 'Approval User Setup';
                RunObject = Page "Approval User Setup";
            }
            action("Workflow User Groups")
            {
                Caption = 'Workflow User Groups';
                Image = Users;
                RunObject = Page "Workflow User Groups";
            }
            action(Action57)
            {
                Caption = 'Workflows';
                Image = ApprovalSetup;
                RunObject = Page Workflows;
            }
            action("Data Templates List")
            {
                Caption = 'Data Templates List';
                RunObject = Page "Config. Template List";
            }
            action("Base Calendar List")
            {
                Caption = 'Base Calendar List';
                RunObject = Page "Base Calendar List";
            }
            action("Post Codes")
            {
                Caption = 'Post Codes';
                RunObject = Page "Post Codes";
            }
            action("Reason Codes")
            {
                Caption = 'Reason Codes';
                RunObject = Page "Reason Codes";
            }
            action("Extended Text")
            {
                Caption = 'Extended Text';
                RunObject = Page "Extended Text List";
            }
            action("Table Import Wizard")
            {
                Caption = 'Table Import Wizard';
                Image = ImportDatabase;
                RunObject = Page "Table Import Wizard";
            }
            action("Object List")
            {
                Caption = 'Object List';
                Image = Ranges;
                RunObject = Page "Object List";
            }
        }
        area(sections)
        {
            group("Job Queue")
            {
                Caption = 'Job Queue';
                Image = ExecuteBatch;
                ToolTip = 'Specify how reports, batch jobs, and codeunits are run.';
                action(JobQueue_JobQueueEntries)
                {
                    Caption = 'Job Queue Entries';
                    RunObject = Page "Job Queue Entries";
                }
                action("Job Queue Category List")
                {
                    Caption = 'Job Queue Category List';
                    RunObject = Page "Job Queue Category List";
                }
                action("Job Queue Log Entries")
                {
                    Caption = 'Job Queue Log Entries';
                    RunObject = Page "Job Queue Log Entries";
                }
            }
            group(Workflow)
            {
                Caption = 'Workflow';
                ToolTip = 'Set up workflow and approval users, and create workflows that govern how the users interact in processes.';
                action(Workflows)
                {
                    Caption = 'Workflows';
                    Image = ApprovalSetup;
                    RunObject = Page Workflows;
                }
                action("Workflow Templates")
                {
                    Caption = 'Workflow Templates';
                    Image = Setup;
                    RunObject = Page "Workflow Templates";
                }
                action(ApprovalUserSetup)
                {
                    Caption = 'Approval User Setup';
                    RunObject = Page "Approval User Setup";
                }
                action(WorkflowUserGroups)
                {
                    Caption = 'Workflow User Groups';
                    Image = Users;
                    RunObject = Page "Workflow User Groups";
                }
            }
            group(Intrastat)
            {
                Caption = 'Intrastat';
                Image = Intrastat;
                ToolTip = 'Set up Intrastat reporting values, such as tariff numbers.';
                action("Tariff Numbers")
                {
                    Caption = 'Tariff Numbers';
                    RunObject = Page "Tariff Numbers";
                }
                action("Transaction Types")
                {
                    Caption = 'Transaction Types';
                    RunObject = Page "Transaction Types";
                }
                action("Transaction Specifications")
                {
                    Caption = 'Transaction Specifications';
                    RunObject = Page "Transaction Specifications";
                }
                action("Transport Methods")
                {
                    Caption = 'Transport Methods';
                    RunObject = Page "Transport Methods";
                }
                action("Entry/Exit Points")
                {
                    Caption = 'Entry/Exit Points';
                    RunObject = Page "Entry/Exit Points";
                }
                action(Areas)
                {
                    Caption = 'Areas';
                    RunObject = Page Areas;
                }
            }
            group("VAT Registration Numbers")
            {
                Caption = 'VAT Registration Numbers';
                Image = Bank;
                ToolTip = 'Set up and maintain VAT registration number formats.';
                action("VAT Registration No. Formats")
                {
                    Caption = 'VAT Registration No. Formats';
                    RunObject = Page "VAT Registration No. Formats";
                }
            }
            group("Analysis View")
            {
                Caption = 'Analysis View';
                Image = AnalysisView;
                ToolTip = 'Set up views for analysis of sales, purchases, and inventory.';
                action("Sales Analysis View List")
                {
                    Caption = 'Sales Analysis View List';
                    RunObject = Page "Analysis View List Sales";
                }
                action("Purchase Analysis View List")
                {
                    Caption = 'Purchase Analysis View List';
                    RunObject = Page "Analysis View List Purchase";
                }
                action("Inventory Analysis View List")
                {
                    Caption = 'Inventory Analysis View List';
                    RunObject = Page "Analysis View List Inventory";
                }
            }
            group(ActionGroup6014410)
            {
                Caption = 'POS';
                Image = Reconcile;
                action(Menus)
                {
                    Caption = 'Menus';
                    Image = PaymentJournal;
                    RunObject = Page "POS Menus";
                }
                action("Default Views")
                {
                    Caption = 'Default Views';
                    Image = View;
                    RunObject = Page "POS Default Views";
                }
                action("Actions")
                {
                    Caption = 'Actions';
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
            }
            group("Ean Box Events")
            {
                Caption = 'Ean Box Events';
                Image = LotInfo;
                action(Action6014403)
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
        }
        area(creation)
        {
            action("Purchase &Order")
            {
                Caption = 'Purchase &Order';
                Image = Document;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "Purchase Order";
                RunPageMode = Create;
            }
        }
        area(processing)
        {
            separator(Tasks)
            {
                Caption = 'Tasks';
                IsHeader = true;
            }
            action("Com&pany Information")
            {
                Caption = 'Com&pany Information';
                Image = CompanyInformation;
                RunObject = Page "Company Information";
            }
            action("&Manage Style Sheets")
            {
                Caption = '&Manage Style Sheets';
                Image = StyleSheet;
                RunObject = Page "Manage Style Sheets - Pages";
            }
            action("Migration O&verview")
            {
                Caption = 'Migration O&verview';
                Image = Migration;
                RunObject = Page "Config. Package Card";
            }
            action("Relocate &Attachments")
            {
                Caption = 'Relocate &Attachments';
                Image = ChangeTo;
                RunObject = Report "Relocate Attachments";
            }
            action("Create Warehouse &Location")
            {
                Caption = 'Create Warehouse &Location';
                Image = NewWarehouse;
                RunObject = Report "Create Warehouse Location";
            }
            action("C&hange Log Setup")
            {
                Caption = 'C&hange Log Setup';
                Image = LogSetup;
                RunObject = Page "Change Log Setup";
            }
            separator(Separator30)
            {
            }
            group(POSSection)
            {
                Caption = 'POS Setup';
                Image = Loaner;
                group(POS)
                {
                    Caption = 'POS';
                    Image = Loaner;
                    action(Setup)
                    {
                        Caption = 'Setup';
                        Image = SetupPayment;
                        RunObject = Page "POS Setup";
                    }
                    action("Menu Filter")
                    {
                        Caption = 'Menu Filter';
                        Image = "Filter";
                        RunObject = Page "POS Menu Filter";
                    }
                }
            }
            separator(Separator6014411)
            {
            }
            group("&Change Setup")
            {
                Caption = '&Change Setup';
                Image = Setup;
                action("Setup &Questionnaire")
                {
                    Caption = 'Setup &Questionnaire';
                    Image = QuestionaireSetup;
                    RunObject = Page "Config. Questionnaire";
                }
                action("&General Ledger Setup")
                {
                    Caption = '&General Ledger Setup';
                    Image = Setup;
                    RunObject = Page "General Ledger Setup";
                }
                action("Sales && Re&ceivables Setup")
                {
                    Caption = 'Sales && Re&ceivables Setup';
                    Image = Setup;
                    RunObject = Page "Sales & Receivables Setup";
                }
                action("Purchase && &Payables Setup")
                {
                    Caption = 'Purchase && &Payables Setup';
                    Image = ReceivablesPayablesSetup;
                    RunObject = Page "Purchases & Payables Setup";
                }
                action("Fixed &Asset Setup")
                {
                    Caption = 'Fixed &Asset Setup';
                    Image = Setup;
                    RunObject = Page "Fixed Asset Setup";
                }
                action("Mar&keting Setup")
                {
                    Caption = 'Mar&keting Setup';
                    Image = MarketingSetup;
                    RunObject = Page "Marketing Setup";
                }
                action("Or&der Promising Setup")
                {
                    Caption = 'Or&der Promising Setup';
                    Image = OrderPromisingSetup;
                    RunObject = Page "Order Promising Setup";
                }
                action("Nonstock &Item Setup")
                {
                    Caption = 'Nonstock &Item Setup';
                    Image = NonStockItemSetup;
                    RunObject = Page "Catalog Item Setup";
                }
                action("Interaction &Template Setup")
                {
                    Caption = 'Interaction &Template Setup';
                    Image = InteractionTemplateSetup;
                    RunObject = Page "Interaction Template Setup";
                }
                action("Inve&ntory Setup")
                {
                    Caption = 'Inve&ntory Setup';
                    Image = InventorySetup;
                    RunObject = Page "Inventory Setup";
                }
                action("&Warehouse Setup")
                {
                    Caption = '&Warehouse Setup';
                    Image = WarehouseSetup;
                    RunObject = Page "Warehouse Setup";
                }
                action("Mini&forms")
                {
                    Caption = 'Mini&forms';
                    Image = MiniForm;
                    RunObject = Page Miniforms;
                }
                action("Man&ufacturing Setup")
                {
                    Caption = 'Man&ufacturing Setup';
                    Image = ProductionSetup;
                    RunObject = Page "Manufacturing Setup";
                }
                action("Res&ources Setup")
                {
                    Caption = 'Res&ources Setup';
                    Image = ResourceSetup;
                    RunObject = Page "Resources Setup";
                }
                action("&Service Setup")
                {
                    Caption = '&Service Setup';
                    Image = ServiceSetup;
                    RunObject = Page "Service Mgt. Setup";
                }
                action("&Human Resource Setup")
                {
                    Caption = '&Human Resource Setup';
                    Image = HRSetup;
                    RunObject = Page "Human Resources Setup";
                }
                action("&Service Order Status Setup")
                {
                    Caption = '&Service Order Status Setup';
                    Image = ServiceOrderSetup;
                    RunObject = Page "Service Order Status Setup";
                }
                action("&Repair Status Setup")
                {
                    Caption = '&Repair Status Setup';
                    Image = ServiceSetup;
                    RunObject = Page "Repair Status Setup";
                }
                action(Action77)
                {
                    Caption = 'C&hange Log Setup';
                    Image = LogSetup;
                    RunObject = Page "Change Log Setup";
                }
                action("&MapPoint Setup")
                {
                    Caption = '&MapPoint Setup';
                    Image = MapSetup;
                    RunObject = Page "Online Map Setup";
                }
                action("SMTP Mai&l Setup")
                {
                    Caption = 'SMTP Mai&l Setup';
                    Image = MailSetup;
                    RunObject = Page "SMTP Mail Setup";
                }
                action("Job Qu&eue Setup")
                {
                    Caption = 'Job Qu&eue Setup';
                    Image = JobListSetup;
                    RunObject = Page "Concurrent Session List";
                }
                action("Profile Quest&ionnaire Setup")
                {
                    Caption = 'Profile Quest&ionnaire Setup';
                    Image = QuestionaireSetup;
                    RunObject = Page "Profile Questionnaire Setup";
                }
            }
            group("&Report Selection")
            {
                Caption = '&Report Selection';
                Image = SelectReport;
                action("Report Selection - &Bank Account")
                {
                    Caption = 'Report Selection - &Bank Account';
                    Image = SelectReport;
                    RunObject = Page "Report Selection - Bank Acc.";
                }
                action("Report Selection - &Reminder && Finance Charge")
                {
                    Caption = 'Report Selection - &Reminder && Finance Charge';
                    Image = SelectReport;
                    RunObject = Page "Report Selection - Reminder";
                }
                action("Report Selection - &Sales")
                {
                    Caption = 'Report Selection - &Sales';
                    Image = SelectReport;
                    RunObject = Page "Report Selection - Sales";
                }
                action("Report Selection - &Purchase")
                {
                    Caption = 'Report Selection - &Purchase';
                    Image = SelectReport;
                    RunObject = Page "Report Selection - Purchase";
                }
                action("Report Selection - &Inventory")
                {
                    Caption = 'Report Selection - &Inventory';
                    Image = SelectReport;
                    RunObject = Page "Report Selection - Inventory";
                }
                action("Report Selection - Prod. &Order")
                {
                    Caption = 'Report Selection - Prod. &Order';
                    Image = SelectReport;
                    RunObject = Page "Report Selection - Prod. Order";
                }
                action("Report Selection - S&ervice")
                {
                    Caption = 'Report Selection - S&ervice';
                    Image = SelectReport;
                    RunObject = Page "Report Selection - Service";
                }
                action("Report Selection - Cash Flow")
                {
                    Caption = 'Report Selection - Cash Flow';
                    Image = SelectReport;
                    RunObject = Page "Report Selection - Cash Flow";
                }
            }
            group("&Date Compression")
            {
                Caption = '&Date Compression';
                Image = Compress;
                action("Date Compress &G/L Entries")
                {
                    Caption = 'Date Compress &G/L Entries';
                    Image = GeneralLedger;
                    RunObject = Report "Date Compress General Ledger";
                }
                action("Date Compress &VAT Entries")
                {
                    Caption = 'Date Compress &VAT Entries';
                    Image = VATStatement;
                    RunObject = Report "Date Compress VAT Entries";
                }
                action("Date Compress Bank &Account Ledger Entries")
                {
                    Caption = 'Date Compress Bank &Account Ledger Entries';
                    Image = BankAccount;
                    RunObject = Report "Date Compress Bank Acc. Ledger";
                }
                action("Date Compress G/L &Budget Entries")
                {
                    Caption = 'Date Compress G/L &Budget Entries';
                    Image = LedgerBudget;
                    RunObject = Report "Date Compr. G/L Budget Entries";
                }
                action("Date Compress &Customer Ledger Entries")
                {
                    Caption = 'Date Compress &Customer Ledger Entries';
                    Image = Customer;
                    RunObject = Report "Date Compress Customer Ledger";
                }
                action("Date Compress V&endor Ledger Entries")
                {
                    Caption = 'Date Compress V&endor Ledger Entries';
                    Image = Vendor;
                    RunObject = Report "Date Compress Vendor Ledger";
                }
                action("Date Compress &Resource Ledger Entries")
                {
                    Caption = 'Date Compress &Resource Ledger Entries';
                    Image = Resource;
                    RunObject = Report "Date Compress Resource Ledger";
                }
                action("Date Compress &FA Ledger Entries")
                {
                    Caption = 'Date Compress &FA Ledger Entries';
                    Image = FixedAssets;
                    RunObject = Report "Date Compress FA Ledger";
                }
                action("Date Compress &Maintenance Ledger Entries")
                {
                    Caption = 'Date Compress &Maintenance Ledger Entries';
                    Image = Tools;
                    RunObject = Report "Date Compress Maint. Ledger";
                }
                action("Date Compress &Insurance Ledger Entries")
                {
                    Caption = 'Date Compress &Insurance Ledger Entries';
                    Image = Insurance;
                    RunObject = Report "Date Compress Insurance Ledger";
                }
                action("Date Compress &Warehouse Entries")
                {
                    Caption = 'Date Compress &Warehouse Entries';
                    Image = Bin;
                    RunObject = Report "Date Compress Whse. Entries";
                }
            }
            separator(Separator264)
            {
            }
            group("Con&tacts")
            {
                Caption = 'Con&tacts';
                Image = CustomerContact;
                action("Create Contacts from &Customer")
                {
                    Caption = 'Create Contacts from &Customer';
                    Image = CustomerContact;
                    RunObject = Report "Create Conts. from Customers";
                }
                action("Create Contacts from &Vendor")
                {
                    Caption = 'Create Contacts from &Vendor';
                    Image = VendorContact;
                    RunObject = Report "Create Conts. from Vendors";
                }
                action("Create Contacts from &Bank Account")
                {
                    Caption = 'Create Contacts from &Bank Account';
                    Image = BankContact;
                    RunObject = Report "Create Conts. from Bank Accs.";
                }
                action("To-do &Activities")
                {
                    Caption = 'To-do &Activities';
                    Image = TaskList;
                    RunObject = Page Activity;
                }
            }
            separator(Separator47)
            {
            }
            action("Service Trou&bleshooting")
            {
                Caption = 'Service Trou&bleshooting';
                Image = Troubleshoot;
                RunObject = Page Troubleshooting;
            }
            group("&Import")
            {
                Caption = '&Import';
                Image = Import;
                action("Import IRIS to &Area/Symptom Code")
                {
                    Caption = 'Import IRIS to &Area/Symptom Code';
                    Image = Import;
                    RunObject = XMLport "Imp. IRIS to Area/Symptom Code";
                }
                action("Import IRIS to &Fault Codes")
                {
                    Caption = 'Import IRIS to &Fault Codes';
                    Image = Import;
                    RunObject = XMLport "Import IRIS to Fault Codes";
                }
                action("Import IRIS to &Resolution Codes")
                {
                    Caption = 'Import IRIS to &Resolution Codes';
                    Image = Import;
                    RunObject = XMLport "Import IRIS to Resol. Codes";
                }
            }
            separator(Separator263)
            {
            }
            group("&Sales Analysis")
            {
                Caption = '&Sales Analysis';
                Image = Segment;
                action(SalesAnalysisLineTmpl)
                {
                    Caption = 'Sales Analysis &Line Templates';
                    Image = SetupLines;
                    RunObject = Page "Analysis Line Templates";
                    RunPageView = SORTING("Analysis Area",Name)
                                  WHERE("Analysis Area"=CONST(Sales));
                }
                action(SalesAnalysisColumnTmpl)
                {
                    Caption = 'Sales Analysis &Column Templates';
                    Image = SetupColumns;
                    RunObject = Page "Analysis Column Templates";
                    RunPageView = SORTING("Analysis Area",Name)
                                  WHERE("Analysis Area"=CONST(Sales));
                }
            }
            group("P&urchase Analysis")
            {
                Caption = 'P&urchase Analysis';
                Image = Purchasing;
                action(PurchaseAnalysisLineTmpl)
                {
                    Caption = 'Purchase &Analysis Line Templates';
                    Image = SetupLines;
                    RunObject = Page "Analysis Line Templates";
                    RunPageView = SORTING("Analysis Area",Name)
                                  WHERE("Analysis Area"=CONST(Purchase));
                }
                action(PurchaseAnalysisColumnTmpl)
                {
                    Caption = 'Purchase Analysis &Column Templates';
                    Image = SetupColumns;
                    RunObject = Page "Analysis Column Templates";
                    RunPageView = SORTING("Analysis Area",Name)
                                  WHERE("Analysis Area"=CONST(Purchase));
                }
            }
        }
    }
}

