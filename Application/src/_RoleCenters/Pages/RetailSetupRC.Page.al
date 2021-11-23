page 6151245 "NPR Retail Setup RC"
{
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

                ToolTip = 'Executes the POS Menus action';
                ApplicationArea = NPRRetail;
            }
            action("POS Posting Setup_top")
            {
                Caption = 'POS Posting Setup';
                RunObject = Page "NPR POS Posting Setup";

                ToolTip = 'Executes the POS Posting Setup action';
                ApplicationArea = NPRRetail;
            }
            action("Coupon Types_top")
            {
                Caption = 'Coupon Types';
                RunObject = Page "NPR NpDc Coupon Types";

                ToolTip = 'Executes the Coupon Types action';
                ApplicationArea = NPRRetail;
            }
            action("E-mail Templates_top")
            {
                Caption = 'E-mail Templates';
                RunObject = Page "NPR E-mail Templates";

                ToolTip = 'Executes the E-mail Templates action';
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

                    ToolTip = 'Executes the POS Menus action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Actions")
                {
                    Caption = 'POS Actions';
                    Image = "Action";
                    RunObject = Page "NPR POS Actions";

                    ToolTip = 'Executes the POS Actions action';
                    ApplicationArea = NPRRetail;
                }
                action("POS View List")
                {
                    Caption = 'POS View List';
                    Image = ViewDocumentLine;
                    RunObject = Page "NPR POS View List";

                    ToolTip = 'Executes the POS View List action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Default View")
                {
                    Caption = 'POS Default View';
                    Image = View;
                    RunObject = Page "NPR POS Default Views";

                    ToolTip = 'Executes the POS Default View action';
                    ApplicationArea = NPRRetail;
                }

                action("POS Scenarios")
                {
                    Caption = 'POS Scenarios';
                    Image = Allocate;
                    RunObject = Page "NPR POS Scenarios";

                    ToolTip = 'Executes the POS Scenarios action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Scenarios Sets")
                {
                    Caption = 'POS Scenarios Sets';
                    RunObject = Page "NPR POS Scenarios Sets";

                    ToolTip = 'Executes the POS Scenarios Sets action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Store List")
                {
                    Caption = 'POS Store List';
                    RunObject = Page "NPR POS Store List";

                    ToolTip = 'Executes the POS Store List action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Unit List")
                {
                    Caption = 'POS Unit List';
                    RunObject = Page "NPR POS Unit List";

                    ToolTip = 'Executes the POS Unit List action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Themes")
                {
                    Caption = 'POS Themes';
                    RunObject = Page "NPR POS Themes";

                    ToolTip = 'Executes the POS Themes action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Input Box Events")
                {
                    Caption = 'POS Input Box Events';
                    Image = List;
                    RunObject = Page "NPR POS Input Box Events";

                    ToolTip = 'Executes the POS Input Box Events action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Input Box Setups")
                {
                    Caption = 'POS Input Box Setups';
                    Image = List;
                    RunObject = Page "NPR POS Input Box Setups";

                    ToolTip = 'Executes the POS Input Box Setups action';
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

                    ToolTip = 'Executes the POS Payment Methods action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Payment Bins")
                {
                    Caption = 'POS Payment Bins';
                    RunObject = Page "NPR POS Payment Bins";

                    ToolTip = 'Executes the POS Payment Bins action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Payment view Event Setup")
                {
                    Caption = 'POS Payment View Event Setup';
                    Image = List;
                    RunObject = page "NPR POS Paym. View Event Setup";

                    ToolTip = 'Executes the POS Payment View Event Setup action';
                    ApplicationArea = NPRRetail;
                }

                action("EFT Setup")
                {
                    Caption = 'EFT Setup';
                    RunObject = Page "NPR EFT Setup";

                    ToolTip = 'Executes the EFT Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("EFT Integration Types")
                {
                    Caption = 'EFT Integration Types';
                    RunObject = Page "NPR EFT Integration Types";

                    ToolTip = 'Executes the EFT Integration Types action';
                    ApplicationArea = NPRRetail;
                }
                action("EFT BIN Group List")
                {
                    Caption = 'EFT BIN Groups';
                    RunObject = Page "NPR EFT BIN Group List";

                    ToolTip = 'Executes the EFT BIN Groups action';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Terminal Types")
                {
                    Caption = 'Pepper Terminal Types';
                    RunObject = Page "NPR Pepper Terminal Types";

                    ToolTip = 'Executes the Pepper Terminal Types action';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Terminals")
                {
                    Caption = 'Pepper Terminals';
                    RunObject = Page "NPR Pepper Terminal List";

                    ToolTip = 'Executes the Pepper Terminals action';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Versions")
                {
                    Caption = 'Pepper Versions';
                    RunObject = Page "NPR Pepper Version List";

                    ToolTip = 'Executes the Pepper Versions action';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Instances")
                {
                    Caption = 'Pepper Instances';
                    RunObject = Page "NPR Pepper Instances";

                    ToolTip = 'Executes the Pepper Instances action';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Configurations")
                {
                    Caption = 'Pepper Configurations';
                    RunObject = Page "NPR Pepper Config. List";

                    ToolTip = 'Executes the Pepper Configurations action';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Card Types")
                {
                    Caption = 'Pepper Card Types';
                    RunObject = Page "NPR Pepper Card Types";

                    ToolTip = 'Executes the Pepper Card Types action';
                    ApplicationArea = NPRRetail;
                }
                action("Pepper Card Type Group")
                {
                    Caption = 'Pepper Card Type Group';
                    RunObject = Page "NPR Pepper Card Type Group";

                    ToolTip = 'Executes the Pepper Card Type Group action';
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

                    ToolTip = 'Executes the Coupon Types action';
                    ApplicationArea = NPRRetail;
                }
                action("Coupon Modules")
                {
                    Caption = 'Coupon Modules';
                    RunObject = Page "NPR NpDc Coupon Modules";

                    ToolTip = 'Executes the Coupon Modules action';
                    ApplicationArea = NPRRetail;
                }
                action("Voucher Types")
                {
                    Caption = 'Voucher Types';
                    RunObject = Page "NPR NpRv Voucher Types";

                    ToolTip = 'Executes the Voucher Types action';
                    ApplicationArea = NPRRetail;
                }
                action("Voucher Modules")
                {
                    Caption = 'Voucher Modules';
                    RunObject = Page "NPR NpRv Voucher Modules";

                    ToolTip = 'Executes the Voucher Modules action';
                    ApplicationArea = NPRRetail;
                }
                action("Retail Voucher Partners")
                {
                    Caption = 'Retail Voucher Partners';
                    RunObject = Page "NPR NpRv Partners";

                    ToolTip = 'Executes the Retail Voucher Partners action';
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

                    ToolTip = 'Executes the Collect Stores action';
                    ApplicationArea = NPRRetail;
                }
                action("Collect Workflows")
                {
                    Caption = 'Collect Workflows';
                    RunObject = Page "NPR NpCs Workflows";

                    ToolTip = 'Executes the Collect Workflows action';
                    ApplicationArea = NPRRetail;
                }
                action("Collect Workflow Modules")
                {
                    Caption = 'Collect Workflow Modules';
                    RunObject = Page "NPR NpCs Workflow Modules";

                    ToolTip = 'Executes the Collect Workflow Modules action';
                    ApplicationArea = NPRRetail;
                }
                action("Collect Document Mapping")
                {
                    Caption = 'Collect Document Mapping';
                    RunObject = Page "NPR NpCs Document Mapping";

                    ToolTip = 'Executes the Collect Document Mapping action';
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

                    ToolTip = 'Executes the Printer Selections action';
                    ApplicationArea = NPRRetail;
                }
                action("Retail Print Template List")
                {
                    Caption = 'Retail Print Template List';
                    RunObject = Page "NPR RP Template List";

                    ToolTip = 'Executes the Retail Print Template List action';
                    ApplicationArea = NPRRetail;
                }
                action("Report Selection Retail")
                {
                    Caption = 'Report Selection - Retail';
                    RunObject = Page "NPR Retail Report Select. List";

                    ToolTip = 'Runs the page for selecting retail reports';
                    ApplicationArea = NPRRetail;
                }
                action("Object Output Selection")
                {
                    Caption = 'Object Output Selection';
                    RunObject = Page "NPR Object Output Selection";

                    ToolTip = 'Executes the Object Output Selection action';
                    ApplicationArea = NPRRetail;
                }
                action("Retail Logo Setup")
                {
                    Caption = 'Retail Logo Setup';
                    RunObject = Page "NPR Retail Logo Setup";

                    ToolTip = 'Executes the Retail Logo Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("E-mail Templates")
                {
                    Caption = 'E-mail Templates';
                    RunObject = Page "NPR E-mail Templates";

                    ToolTip = 'Executes the E-mail Templates action';
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

                    ToolTip = 'Executes the SMS Template List action';
                    ApplicationArea = NPRRetail;

                }
                action("Exchange Label Setup")
                {
                    Caption = 'Exchange Label Setup';
                    RunObject = Page "NPR Exchange Label Setup";
                    RunPageMode = Create;

                    ToolTip = 'Executes the Exchange Label Setup action';
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

                    ToolTip = 'Executes the POS Cross References action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Info List")
                {
                    Caption = 'POS Info List';
                    RunObject = Page "NPR POS Info List";

                    ToolTip = 'Executes the POS Info List action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Web Fonts")
                {
                    Caption = 'POS Web Fonts';
                    RunObject = Page "NPR POS Web Fonts";

                    ToolTip = 'Executes the POS Web Fonts action';
                    ApplicationArea = NPRRetail;
                }

                action("POS Stargate Packages")
                {
                    Caption = 'POS Stargate Packages';
                    RunObject = Page "NPR POS Stargate Packages";

                    ToolTip = 'Executes the POS Stargate Packages action';
                    ApplicationArea = NPRRetail;
                }
                action("Item Worksheet Templates")
                {
                    Caption = 'Item Worksheet Templates';
                    RunObject = page "NPR Item Worksheet Templates";

                    ToolTip = 'Executes the item worksheet Templates action';
                    ApplicationArea = NPRRetail;
                }
                action("Job Queue")
                {
                    Caption = 'Job Queue';
                    RunObject = page "Job Queue Category List";

                    ToolTip = 'Executes the Job Queue action';
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

                    ToolTip = 'Executes the Retention Policy Setup List action';
                    ApplicationArea = NPRRetail;
                }
                action("SMS Setup")
                {
                    Caption = 'SMS Setup';
                    RunObject = page "NPR SMS Setup";

                    ToolTip = 'Open the SMS setup page';
                    ApplicationArea = NPRRetail;
                }
                action("Config. Template Lines Fix")
                {
                    Caption = 'Config. Template Lines Fix';
                    RunObject = report "NPR Config. Template Line Fix";
                    ToolTip = 'Runs Config. Template Line Fix report';
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

                    ToolTip = 'Executes the Sales Price Maintenance Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("RIS Retail Inventory Sets")
                {
                    Caption = 'RIS Retail Inventory Sets';
                    RunObject = Page "NPR RIS Retail Inv. Sets";

                    ToolTip = 'Executes the RIS Retail Inventory Sets action';
                    ApplicationArea = NPRRetail;
                }
                action("Store Groups")
                {
                    Caption = 'Store Groups';
                    RunObject = Page "NPR Store Groups";

                    ToolTip = 'Executes the Store Groups action';
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

                    ToolTip = 'Executes the Variety Fields Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("Item Categories")
                {
                    Caption = 'Item Categories';
                    RunObject = Page "Item Categories";

                    ToolTip = 'Executes the Item Categories action';
                    ApplicationArea = NPRRetail;
                }
                action(Locations)
                {
                    Caption = 'Locations';
                    RunObject = page "Location List";

                    ToolTip = 'Executes the Locations action';
                    ApplicationArea = NPRRetail;
                }

                action("Mix Discounts")
                {
                    Caption = 'Mix Discounts List';
                    RunObject = page "NPR Mixed Discount List";

                    ToolTip = 'Executes the Mix Discounts List action';
                    ApplicationArea = NPRRetail;
                }

                action("Period Discounts")
                {
                    Caption = 'Period Discounts List';
                    RunObject = page "NPR Campaign Discount List";

                    ToolTip = 'Executes the Period Discounts List action';
                    ApplicationArea = NPRRetail;
                }

                action("Retail Campaigns")
                {
                    Caption = 'Retail Campaigns List';
                    RunObject = page "NPR Retail Campaigns";

                    ToolTip = 'Executes the Retail Campaigns List action';
                    ApplicationArea = NPRRetail;
                }

                action("Discount Priority List")
                {
                    Caption = 'Discount Priority List';
                    RunObject = page "NPR Discount Priority List";

                    ToolTip = 'Executes the Discount Priority List action';
                    ApplicationArea = NPRRetail;
                }
                action("Retail Replenisment Setup")
                {
                    Caption = 'Retail Replenisment Setup';
                    RunObject = page "NPR Retail Replenish. SKU List";

                    ToolTip = 'Executes the Retail Replenisment Setup action';
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

                    ToolTip = 'Executes the Configuration Templates action';
                    ApplicationArea = NPRRetail;
                }
                action("Configuration Packages")
                {
                    Caption = 'Configuration Packages';
                    RunObject = Page "Config. Packages";

                    ToolTip = 'Executes the Configuration Packages action';
                    ApplicationArea = NPRRetail;
                }
                action("No. Series")
                {
                    Caption = 'No. Series';
                    RunObject = Page "No. Series";

                    ToolTip = 'Executes the No. Series action';
                    ApplicationArea = NPRRetail;
                }
                action("NPR Attributes")
                {
                    Caption = 'Client Attributes';
                    RunObject = Page "NPR Attributes";

                    ToolTip = 'Executes the Client Attributes action';
                    ApplicationArea = NPRRetail;
                }

                action("Replication API Setup")
                {
                    Caption = 'Replication API Setup List';
                    RunObject = Page "NPR Replication Setup List";

                    ToolTip = 'Executes the Replication API Setup List action';
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

                    ToolTip = 'Executes the Gen. Posting Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("VAT Posting Setup")
                {
                    Caption = 'VAT Posting Setup';
                    RunObject = page "VAT Posting Setup";

                    ToolTip = 'Executes the VAT Posting Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("Inventory Setup")
                {
                    Caption = 'Inventory Setup';
                    RunObject = page "Inventory Periods";

                    ToolTip = 'Executes the Inventory Setup action';
                    ApplicationArea = NPRRetail;
                }
                action(DimensionsList)
                {
                    Caption = 'Dimensions List';
                    RunObject = page "Dimension List";

                    ToolTip = 'Executes the Dimensions List action';
                    ApplicationArea = NPRRetail;
                }
                action("POS Posting Setup")
                {
                    Caption = 'POS Posting Setup';
                    RunObject = Page "NPR POS Posting Setup";

                    ToolTip = 'Executes the POS Posting Setup action';
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
                ToolTip = 'Executes the Open POS action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

