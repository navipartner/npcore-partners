page 6151245 "NPR Retail Setup RC"
{
    Extensible = False;
    Caption = 'NP Retail Setup';
    PageType = RoleCenter;
    UsageCategory = None;
    layout
    {
        area(rolecenter)
        {
            part(control1246; "NPR generic retail Headline")
            {
                ApplicationArea = NPRRetail;

            }
            part(Control1904484608; "NPR Setup Act - POS")
            {
                ApplicationArea = NPRRetail;


            }

            part(Control14; "NPR Retail - Setups")
            {
                ApplicationArea = NPRRetail;

            }

        }
    }

    actions
    {
        area(embedding)
        {
            action("POS Menus_top")
            {
                Caption = 'POS Menus';
                Image = PaymentJournal;
                RunObject = Page "NPR POS Menus";

                ToolTip = 'View or edit the POS Menus';
                ApplicationArea = NPRRetail;
            }
            action("POS Posting Setup_top")
            {
                Caption = 'POS Posting Setup';
                RunObject = Page "NPR POS Posting Setup";

                ToolTip = 'View or edit the POS Posting Setups';
                ApplicationArea = NPRRetail;
            }
            action("Object Output_Selection")
            {
                Caption = 'Print Template Output Setup';
                RunObject = Page "NPR Object Output Selection";

                ToolTip = 'View or edit the Object Output Selections';
                ApplicationArea = NPRRetail;
            }
            action("RP Template List")
            {
                Caption = 'RP Template List';
                RunObject = Page "NPR RP Template List";

                ToolTip = 'View or edit the RP Template';
                ApplicationArea = NPRRetail;
            }
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

                    ToolTip = 'View or edit the the POS Menus';
                    ApplicationArea = NPRRetail;
                }
                action("POS Actions")
                {
                    Caption = 'POS Actions';
                    Image = "Action";
                    RunObject = Page "NPR POS Actions";

                    ToolTip = 'Opens the POS Actions list';
                    ApplicationArea = NPRRetail;
                }
                action("POS View List")
                {
                    Caption = 'POS View List';
                    Image = ViewDocumentLine;
                    RunObject = Page "NPR POS View List";

                    ToolTip = 'View or edit the POS View List';
                    ApplicationArea = NPRRetail;
                }
                action("POS Default View")
                {
                    Caption = 'POS Default View';
                    Image = View;
                    RunObject = Page "NPR POS Default Views";

                    ToolTip = 'View or edit the POS Default View';
                    ApplicationArea = NPRRetail;
                }

                action("POS Scenarios")
                {
                    Caption = 'POS Scenarios';
                    Image = Allocate;
                    RunObject = Page "NPR POS Scenarios";

                    ToolTip = 'View or edit the POS Scenarios';
                    ApplicationArea = NPRRetail;
                }
                action("POS Scenarios Sets")
                {
                    Caption = 'POS Scenarios Sets';
                    RunObject = Page "NPR POS Scenarios Sets";

                    ToolTip = 'View or edit the POS Scenarios Sets';
                    ApplicationArea = NPRRetail;
                }
                action("POS Store List")
                {
                    Caption = 'POS Store List';
                    RunObject = Page "NPR POS Store List";

                    ToolTip = 'View or edit the POS Store List';
                    ApplicationArea = NPRRetail;
                }
                action("POS Unit List")
                {
                    Caption = 'POS Unit List';
                    RunObject = Page "NPR POS Unit List";

                    ToolTip = 'View or edit the POS Unit List';
                    ApplicationArea = NPRRetail;
                }
                action("POS Themes")
                {
                    Caption = 'POS Themes';
                    RunObject = Page "NPR POS Themes";

                    ToolTip = 'View or edit the POS Themes';
                    ApplicationArea = NPRRetail;
                }
                action("POS Input Box Events")
                {
                    Caption = 'POS Input Box Events';
                    Image = List;
                    RunObject = Page "NPR POS Input Box Events";

                    ToolTip = 'View or edit the POS Input Box Events';
                    ApplicationArea = NPRRetail;
                }
                action("POS Input Box Setups")
                {
                    Caption = 'POS Input Box Setups';
                    Image = List;
                    RunObject = Page "NPR POS Input Box Setups";

                    ToolTip = 'View or edit the POS Input Box Setups';
                    ApplicationArea = NPRRetail;
                }
            }
            group(PaymentCard)
            {
                Caption = 'Payment';
                Image = CostAccounting;
                action("POS Payment Method List")
                {
                    Caption = 'POS Payment Methods';
                    RunObject = Page "NPR POS Payment Method List";

                    ToolTip = 'View or edit the POS Payment Methods';
                    ApplicationArea = NPRRetail;
                }
                action("POS Payment Bins")
                {
                    Caption = 'POS Payment Bins';
                    RunObject = Page "NPR POS Payment Bins";

                    ToolTip = 'View or edit the POS Payment Bins';
                    ApplicationArea = NPRRetail;
                }
                action("POS Payment view Event Setup")
                {
                    Caption = 'POS Payment View Event Setup';
                    Image = List;
                    RunObject = page "NPR POS Paym. View Event Setup";

                    ToolTip = 'View or edit the POS Payment View Event Setup';
                    ApplicationArea = NPRRetail;
                }

                action("EFT Setup")
                {
                    Caption = 'EFT Setup';
                    RunObject = Page "NPR EFT Setup";

                    ToolTip = 'View or edit the EFT Setup';
                    ApplicationArea = NPRRetail;
                }
                action("EFT Integration Types")
                {
                    Caption = 'EFT Integration Types';
                    RunObject = Page "NPR EFT Integration Types";

                    ToolTip = 'View or edit the EFT Integration Types';
                    ApplicationArea = NPRRetail;
                }
                action("EFT BIN Group List")
                {
                    Caption = 'EFT BIN Groups';
                    RunObject = Page "NPR EFT BIN Group List";

                    ToolTip = 'View or edit the EFT BIN Groups';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Terminal Types")
                {
                    Caption = 'Pepper Terminal Types';
                    RunObject = Page "NPR Pepper Terminal Types";

                    ToolTip = 'View or edit the Pepper Terminal Types';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Terminals")
                {
                    Caption = 'Pepper Terminals';
                    RunObject = Page "NPR Pepper Terminal List";

                    ToolTip = 'View or edit the Pepper Terminals';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Versions")
                {
                    Caption = 'Pepper Versions';
                    RunObject = Page "NPR Pepper Version List";

                    ToolTip = 'View or edit the Pepper Versions';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Instances")
                {
                    Caption = 'Pepper Instances';
                    RunObject = Page "NPR Pepper Instances";

                    ToolTip = 'View or edit the Pepper Instances';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Configurations")
                {
                    Caption = 'Pepper Configurations';
                    RunObject = Page "NPR Pepper Config. List";

                    ToolTip = 'View or edit the Pepper Configurations';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Card Types")
                {
                    Caption = 'Pepper Card Types';
                    RunObject = Page "NPR Pepper Card Types";

                    ToolTip = 'View or edit the Pepper Card Types';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Card Type Group")
                {
                    Caption = 'Pepper Card Type Group';
                    RunObject = Page "NPR Pepper Card Type Group";

                    ToolTip = 'View or edit the Pepper Card Type Group';
                    ApplicationArea = NPRRetail;
                }
                action("EFT Reconciliations")
                {
                    Caption = 'EFT Reconciliations';
                    RunObject = Page "NPR EFT Reconciliation List";

                    ToolTip = 'View or edit the EFT Reconciliations';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Coupons & Vouchers")
            {
                Caption = 'Coupons & Vouchers';
                action("Coupon Types")
                {
                    Caption = 'Coupon Types';
                    RunObject = Page "NPR NpDc Coupon Types";

                    ToolTip = 'View or edit the Coupon Types';
                    ApplicationArea = NPRRetail;
                }
                action("Coupon Modules")
                {
                    Caption = 'Coupon Modules';
                    RunObject = Page "NPR NpDc Coupon Modules";

                    ToolTip = 'View or edit the Coupon Modules';
                    ApplicationArea = NPRRetail;
                }
                action("Voucher Types")
                {
                    Caption = 'Voucher Types';
                    RunObject = Page "NPR NpRv Voucher Types";

                    ToolTip = 'View or edit the Voucher Types';
                    ApplicationArea = NPRRetail;
                }
                action("Voucher Modules")
                {
                    Caption = 'Voucher Modules';
                    RunObject = Page "NPR NpRv Voucher Modules";

                    ToolTip = 'View or edit the Voucher Modules';
                    ApplicationArea = NPRRetail;
                }
                action("Retail Voucher Partners")
                {
                    Caption = 'Retail Voucher Partners';
                    RunObject = Page "NPR NpRv Partners";

                    ToolTip = 'View or edit the Retail Voucher Partners';
                    ApplicationArea = NPRRetail;
                }
                action("Reimbursement Modules")
                {
                    Caption = 'Reimbursement Modules';
                    RunObject = Page "NPR NpRi Reimburs. Modules";

                    ToolTip = 'View the Reimbursement Modules';
                    ApplicationArea = NPRRetail;
                }
                action("Reimbursement List")
                {
                    Caption = 'Reimbursements';
                    RunObject = Page "NPR NpRi Reimbursements";

                    ToolTip = 'View the Reimbursements';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Collect in Store")
            {
                Caption = 'Collect in Store';
                action("Collect Stores")
                {
                    Caption = 'Collect Stores';
                    RunObject = Page "NPR NpCs Stores";

                    ToolTip = 'View or edit the Collect Stores';
                    ApplicationArea = NPRRetail;
                }
                action("Collect Workflows")
                {
                    Caption = 'Collect Workflows';
                    RunObject = Page "NPR NpCs Workflows";

                    ToolTip = 'View or edit the Collect Workflows';
                    ApplicationArea = NPRRetail;
                }
                action("Collect Workflow Modules")
                {
                    Caption = 'Collect Workflow Modules';
                    RunObject = Page "NPR NpCs Workflow Modules";

                    ToolTip = 'View or edit the Collect Workflow Modules';
                    ApplicationArea = NPRRetail;
                }
                action("Collect Document Mapping")
                {
                    Caption = 'Collect Document Mapping';
                    RunObject = Page "NPR NpCs Document Mapping";

                    ToolTip = 'View or edit the Collect Document Mapping';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Print & Email")
            {
                Caption = 'Print & Email';
                action("Printer Selections")
                {
                    Caption = 'Printer Selections';
                    RunObject = Page "Printer Selections";

                    ToolTip = 'View or edit the Printer Selections';
                    ApplicationArea = NPRRetail;
                }
                action("Retail Print Template List")
                {
                    Caption = 'Retail Print Template List';
                    RunObject = Page "NPR RP Template List";

                    ToolTip = 'View or edit the Retail Print Template List';
                    ApplicationArea = NPRRetail;
                }
                action("Report Selection Retail")
                {
                    Caption = 'Report Selection - Retail';
                    RunObject = Page "NPR Report Selection: Retail";

                    ToolTip = 'Runs the page for selecting retail reports';
                    ApplicationArea = NPRRetail;
                }
                action("Retail Logo Setup")
                {
                    Caption = 'Retail Logo Setup';
                    RunObject = Page "NPR Retail Logo Setup";

                    ToolTip = 'View or edit the Retail Logo Setup';
                    ApplicationArea = NPRRetail;
                }
                action("E-mail Templates")
                {
                    Caption = 'E-mail Templates';
                    RunObject = Page "NPR E-mail Templates";

                    ToolTip = 'View or edit the E-mail Templates';
                    ApplicationArea = NPRRetail;
                }
                action("Smart Email List")
                {
                    Caption = 'Smart Email List';
                    RunObject = Page "NPR Smart Email List";

                    ToolTip = 'Open the Smart Email List page';
                    ApplicationArea = NPRRetail;
                }

                action("SMS Template List")
                {
                    Caption = 'SMS Template List';
                    RunObject = page "NPR SMS Template List";

                    ToolTip = 'View or edit the SMS Template List';
                    ApplicationArea = NPRRetail;

                }
                action("Exchange Label Setup")
                {
                    Caption = 'Exchange Label Setup';
                    RunObject = Page "NPR Exchange Label Setup";
                    RunPageMode = Create;

                    ToolTip = 'View or edit the Exchange Label Setup';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Miscellaneous)
            {
                Caption = 'Miscellaneous';
                action("Retail Cross References")
                {
                    Caption = 'POS Cross References';
                    RunObject = Page "NPR POS Cross References";

                    ToolTip = 'View or edit the POS Cross References';
                    ApplicationArea = NPRRetail;
                }
                action("POS Info List")
                {
                    Caption = 'POS Info List';
                    RunObject = Page "NPR POS Info List";

                    ToolTip = 'View or edit the POS Info List';
                    ApplicationArea = NPRRetail;
                }
                action("Item Worksheet Templates")
                {
                    Caption = 'Item Worksheet Templates';
                    RunObject = page "NPR Item Worksheet Templates";

                    ToolTip = 'View or edit the item worksheet Templates';
                    ApplicationArea = NPRRetail;
                }
                action("Job Queue")
                {
                    Caption = 'Job Queue';
                    RunObject = page "Job Queue Category List";

                    ToolTip = 'View or edit the Job Queue';
                    ApplicationArea = NPRRetail;
                }
                action("Job Queue Entries")
                {
                    Caption = 'Job Queue Entries';
                    RunObject = page "Job Queue Entries";

                    Tooltip = 'View Job Queue Entries';
                    ApplicationArea = NPRRetail;
                }
                action("Retention Policy Setup List")
                {
                    Caption = 'Retention Policy Setup List';
                    RunObject = page "Retention Policy Setup List";

                    ToolTip = 'View or edit the Retention Policy Setup List';
                    ApplicationArea = NPRRetail;
                }
                action("SMS Setup")
                {
                    Caption = 'SMS Setup';
                    RunObject = page "NPR SMS Setup";

                    ToolTip = 'Open the SMS setup page';
                    ApplicationArea = NPRRetail;
                }
                action("Global POS Sales Setups")
                {
                    Caption = 'Global POS Sales Setups';
                    RunObject = page "NPR NpGp Global POSSalesSetups";

                    ToolTip = 'Open the Global POS Sales Setups page';
                    ApplicationArea = NPRRetail;
                }

            }


            group(Item)
            {
                Caption = 'Item';
                action("Sales Price Maintenance Setup")
                {
                    Caption = 'Sales Price Maintenance Setup';
                    RunObject = Page "NPR Sales Price Maint. Setup";

                    ToolTip = 'View or edit the Sales Price Maintenance Setup';
                    ApplicationArea = NPRRetail;
                }
                action("Retail Inventory Sets")
                {
                    Caption = 'Retail Inventory Sets';
                    RunObject = Page "NPR RIS Retail Inv. Sets";

                    ToolTip = 'View or edit the Retail Inventory Sets';
                    ApplicationArea = NPRRetail;
                }
                action("Store Groups")
                {
                    Caption = 'Store Groups';
                    RunObject = Page "NPR Store Groups";

                    ToolTip = 'View or edit the Store Groups';
                    ApplicationArea = NPRRetail;
                }
                action("Variety Setup")
                {
                    Caption = 'Variety Setup';
                    RunObject = Page "NPR Variety Setup";
                    ToolTip = 'Runs the Variety Setup Page';
                    ApplicationArea = NPRRetail;
                }
                action(Variety)
                {
                    Caption = 'Variety';
                    RunObject = page "NPR Variety";

                    ToolTip = 'Runs the Variety page';
                    ApplicationArea = NPRRetail;
                }



                action("Variety Fields Setup")
                {
                    Caption = 'Variety Fields Setup';
                    RunObject = Page "NPR Variety Fields Setup";

                    ToolTip = 'View or edit the Variety Fields Setup';
                    ApplicationArea = NPRRetail;
                }
                action("Item Categories")
                {
                    Caption = 'Item Categories';
                    RunObject = Page "Item Categories";

                    ToolTip = 'View or edit the Item Categories';
                    ApplicationArea = NPRRetail;
                }
                action(Locations)
                {
                    Caption = 'Locations';
                    RunObject = page "Location List";

                    ToolTip = 'View or edit the Locations';
                    ApplicationArea = NPRRetail;
                }

                action("Mix Discounts")
                {
                    Caption = 'Mix Discounts List';
                    RunObject = page "NPR Mixed Discount List";

                    ToolTip = 'View or edit the Mix Discounts List';
                    ApplicationArea = NPRRetail;
                }

                action("Period Discounts")
                {
                    Caption = 'Campaign Discounts List';
                    RunObject = page "NPR Campaign Discount List";

                    ToolTip = 'View or edit the Period Discounts List';
                    ApplicationArea = NPRRetail;
                }

                action("Retail Campaigns")
                {
                    Caption = 'Retail Campaigns List';
                    RunObject = page "NPR Retail Campaigns";

                    ToolTip = 'View or edit the Retail Campaigns List';
                    ApplicationArea = NPRRetail;
                }

                action("Discount Priority List")
                {
                    Caption = 'Discount Priority List';
                    RunObject = page "NPR Discount Priority List";

                    ToolTip = 'View or edit the Discount Priority List';
                    ApplicationArea = NPRRetail;
                }
                action("Retail Replenisment Setup")
                {
                    Caption = 'Retail Replenisment Setup';
                    RunObject = page "NPR Retail Replenish. SKU List";

                    ToolTip = 'View or edit the Retail Replenisment Setup';
                    ApplicationArea = NPRRetail;
                }

            }



            group(Configuration)
            {
                Caption = 'Configuration';
                action("Configuration Templates")
                {
                    Caption = 'Configuration Templates';
                    RunObject = Page "Config. Template List";

                    ToolTip = 'View or edit the Configuration Templates';
                    ApplicationArea = NPRRetail;
                }
                action("Configuration Packages")
                {
                    Caption = 'Configuration Packages';
                    RunObject = Page "Config. Packages";

                    ToolTip = 'View or edit the Configuration Packages';
                    ApplicationArea = NPRRetail;
                }
                action("No. Series")
                {
                    Caption = 'No. Series';
                    RunObject = Page "No. Series";

                    ToolTip = 'View or edit the No. Series';
                    ApplicationArea = NPRRetail;
                }
                action("NPR Attributes")
                {
                    Caption = 'Client Attributes';
                    RunObject = Page "NPR Attributes";

                    ToolTip = 'View or edit the Client Attributes';
                    ApplicationArea = NPRRetail;
                }

                action("Replication API Setup")
                {
                    Caption = 'Replication API Setup List';
                    RunObject = Page "NPR Replication Setup List";

                    ToolTip = 'Opens the page Replication Setup (Source Company)';
                    ApplicationArea = NPRRetail;
                }

                action("Replication Setup (Source Company)")
                {
                    Caption = 'Replication Setup (Source Company)';
                    RunObject = Page "NPR Replication Setup (Source)";

                    ToolTip = 'View or edit the Gen. Posting Setup';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Posting Setup")
            {
                Caption = 'Posting Setup';

                action("Gen Posting Setup")
                {
                    Caption = 'Gen. Posting Setup';
                    RunObject = page "General Posting Setup";

                    ToolTip = 'View or edit the Gen. Posting Setup';
                    ApplicationArea = NPRRetail;
                }
                action("VAT Posting Setup")
                {
                    Caption = 'VAT Posting Setup';
                    RunObject = page "VAT Posting Setup";

                    ToolTip = 'View or edit the VAT Posting Setup';
                    ApplicationArea = NPRRetail;
                }
                action("Inventory Setup")
                {
                    Caption = 'Inventory Setup';
                    RunObject = page "Inventory Periods";

                    ToolTip = 'View or edit the Inventory Setup';
                    ApplicationArea = NPRRetail;
                }
                action(DimensionsList)
                {
                    Caption = 'Dimensions List';
                    RunObject = page "Dimension List";

                    ToolTip = 'View or edit the Dimensions List';
                    ApplicationArea = NPRRetail;
                }
                action("POS Posting Setup")
                {
                    Caption = 'POS Posting Setup';
                    RunObject = Page "NPR POS Posting Setup";

                    ToolTip = 'View or edit the POS Posting Setup';
                    ApplicationArea = NPRRetail;
                }

            }


        }

        area(Creation)
        {
            action(POSDragonglass)
            {

                Caption = 'Open POS';
                RunObject = Codeunit "NPR Open POS Page";
                ToolTip = 'View or edit the Open POS';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

