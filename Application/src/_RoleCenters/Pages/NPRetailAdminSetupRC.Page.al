page 6151245 "NPR NP Retail Admin Setup RC"
{
    Caption = 'NP Retail Admin Setup';
    PageType = RoleCenter;
    UsageCategory = None;
    layout
    {
        area(rolecenter)
        {

            part(Control1904484608; "NPR Retail Admin Act - POS")
            {
                ApplicationArea = All;

            }

            part(Control14; "NPR Retail Admin Act - WFs")
            {
                ApplicationArea = All;
            }

        }
    }

    actions
    {
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
                action("POS Default View")
                {
                    Caption = 'POS Default View';
                    Image = View;
                    RunObject = Page "NPR POS Default Views";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Default View action';
                }
                action("POS Actions")
                {
                    Caption = 'POS Actions';
                    Image = "Action";
                    RunObject = Page "NPR POS Actions";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Actions action';
                }
                action("POS View List")
                {
                    Caption = 'POS View List';
                    Image = ViewDocumentLine;
                    RunObject = Page "NPR POS View List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS View List action';
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
                action("POS Themes")
                {
                    Caption = 'POS Themes';
                    RunObject = Page "NPR POS Themes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Themes action';
                }
                action("POS Info List")
                {
                    Caption = 'POS Info List';
                    RunObject = Page "NPR POS Info List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Info List action';
                }
                action("POS Customer Location")
                {
                    Caption = 'POS Customer Location';
                    RunObject = Page "NPR POS Customer Loc.";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Customer Location action';
                }
                action("POS Admin. Template List")
                {
                    Caption = 'POS Admin. Template List';
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Admin. Template List action';
                    // RunObject = Page "POS Admin. Template List";
                }
                action("Cash Registers")
                {
                    Caption = 'Cash Registers';
                    RunObject = Page "NPR Register List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Cash Registers action';
                }
                action("POS Display Setup")
                {
                    Caption = 'POS Display Setup';
                    RunObject = Page "NPR Display Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Display Setup action';
                }
                action(Action6014418)
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
                action("No. Series")
                {
                    Caption = 'No. Series';
                    RunObject = Page "No. Series";
                    ApplicationArea = All;
                    ToolTip = 'Executes the No. Series action';
                }
                action("Ean Box Events")
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
                action("POS Unit Identity")
                {
                    Caption = 'POS Unit Identity';
                    Image = List;
                    RunObject = page "NPR POS Unit Identity List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Unit Identity action';

                }
                action("POS Payment view Event Setup")
                {
                    Caption = 'POS Payment view Event Setup';
                    Image = List;
                    RunObject = page "NPR POS Paym. View Event Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Payment view Event Setup action';
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
                action("EFT Setup")
                {
                    Caption = 'EFT Setup';
                    RunObject = Page "NPR EFT Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the EFT Setup action';
                }
                action("EFT Integration Types")
                {
                    Caption = 'EFT Integration Types';
                    RunObject = Page "NPR EFT Integration Types";
                    ApplicationArea = All;
                    ToolTip = 'Executes the EFT Integration Types action';
                }
                action("EFT BIN Group List")
                {
                    Caption = 'EFT BIN Group List';
                    RunObject = Page "NPR EFT BIN Group List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the EFT BIN Group List action';
                }
                action("Tax Free POS Units")
                {
                    Caption = 'Tax Free POS Units';
                    RunObject = Page "NPR Tax Free POS Units";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Tax Free POS Units action';
                }
                action("Pepper Terminal Types")
                {
                    Caption = 'Pepper Terminal Types';
                    RunObject = Page "NPR Pepper Terminal Types";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Pepper Terminal Types action';
                }
                action("Pepper Terminals")
                {
                    Caption = 'Pepper Terminals';
                    RunObject = Page "NPR Pepper Terminal List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Pepper Terminals action';
                }
                action("Pepper Versions")
                {
                    Caption = 'Pepper Versions';
                    RunObject = Page "NPR Pepper Version List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Pepper Versions action';
                }
                action("Pepper Instances")
                {
                    Caption = 'Pepper Instances';
                    RunObject = Page "NPR Pepper Instances";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Pepper Instances action';
                }
                action("Pepper Configurations")
                {
                    Caption = 'Pepper Configurations';
                    RunObject = Page "NPR Pepper Config. List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Pepper Configurations action';
                }
                action("Pepper Card Types")
                {
                    Caption = 'Pepper Card Types';
                    RunObject = Page "NPR Pepper Card Types";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Pepper Card Types action';
                }
                action("Pepper Card Type Group")
                {
                    Caption = 'Pepper Card Type Group';
                    RunObject = Page "NPR Pepper Card Type Group";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Pepper Card Type Group action';
                }
            }
            group("Coupons & Vouchers")
            {
                Caption = 'Coupons & Vouchers';
                action("Coupon Types")
                {
                    Caption = 'Coupon Types';
                    RunObject = Page "NPR NpDc Coupon Types";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Coupon Types action';
                }
                action("Coupon Modules")
                {
                    Caption = 'Coupon Modules';
                    RunObject = Page "NPR NpDc Coupon Modules";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Coupon Modules action';
                }
                action("External Retail Voucher Types")
                {
                    Caption = 'External Retail Voucher Types';
                    RunObject = Page "NPR ExRv Voucher Types";
                    ApplicationArea = All;
                    ToolTip = 'Executes the External Retail Voucher Types action';
                }
                action("Voucher Types")
                {
                    Caption = 'Voucher Types';
                    RunObject = Page "NPR NpRv Voucher Types";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Voucher Types action';
                }
                action("Voucher Modules")
                {
                    Caption = 'Voucher Modules';
                    RunObject = Page "NPR NpRv Voucher Modules";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Voucher Modules action';
                }
                action("Retail Voucher Partners")
                {
                    Caption = 'Retail Voucher Partners';
                    RunObject = Page "NPR NpRv Partners";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Voucher Partners action';
                }
            }
            group("Global Setup")
            {
                Caption = 'Global Setup';
                action("Global POS Sales Setups")
                {
                    Caption = 'Global POS Sales Setups';
                    RunObject = Page "NPR NpGp Global POSSalesSetups";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Global POS Sales Setups action';
                }
            }
            group("Collect in Store")
            {
                Caption = 'Collect in Store';
                action("Collect Stores")
                {
                    Caption = 'Collect Stores';
                    RunObject = Page "NPR NpCs Stores";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Collect Stores action';
                }
                action("Collect Workflows")
                {
                    Caption = 'Collect Workflows';
                    RunObject = Page "NPR NpCs Workflows";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Collect Workflows action';
                }
                action("Collect Workflow Modules")
                {
                    Caption = 'Collect Workflow Modules';
                    RunObject = Page "NPR NpCs Workflow Modules";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Collect Workflow Modules action';
                }
                action("Collect Document Mapping")
                {
                    Caption = 'Collect Document Mapping';
                    RunObject = Page "NPR NpCs Document Mapping";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Collect Document Mapping action';
                }
            }
            group("Print & Email")
            {
                Caption = 'Print & Email';
                action("Printer Selections")
                {
                    Caption = 'Printer Selections';
                    RunObject = Page "Printer Selections";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Printer Selections action';
                }
                action("Retail Print Template List")
                {
                    Caption = 'Retail Print Template List';
                    RunObject = Page "NPR RP Template List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Print Template List action';
                }
                action("Object Output Selection")
                {
                    Caption = 'Object Output Selection';
                    RunObject = Page "NPR Object Output Selection";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Object Output Selection action';
                }
                action("Retail Logo Setup")
                {
                    Caption = 'Retail Logo Setup';
                    RunObject = Page "NPR Retail Logo Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Logo Setup action';
                }
                action("Google Cloud Print Setup")
                {
                    Caption = 'Google Cloud Print Setup';
                    RunObject = Page "NPR GCP Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Google Cloud Print Setup action';
                }
                action("E-mail Templates")
                {
                    Caption = 'E-mail Templates';
                    RunObject = Page "NPR E-mail Templates";
                    ApplicationArea = All;
                    ToolTip = 'Executes the E-mail Templates action';
                }

                action("SMS Template List")
                {
                    Caption = 'SMS Template List';
                    RunObject = page "NPR SMS Template List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the SMS Template List action';

                }
                action("Report Selection - Contract")
                {
                    Caption = 'Report Selection - Contract';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Report Selection - Contract action';

                }
            }
            group(Miscellaneous)
            {
                Caption = 'Miscellaneous';
                action("Retail Cross References")
                {
                    Caption = 'Retail Cross References';
                    RunObject = Page "NPR Retail Cross References";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Cross References action';
                }
                action(Scanners)
                {
                    Caption = 'Scanners';
                    RunObject = Page "NPR Scanner - List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Scanners action';
                }
                action("POS Keyboard Binding Setup")
                {
                    Caption = 'POS Keyboard Binding Setup';
                    RunObject = Page "NPR POS Keyboard Bind. Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Keyboard Binding Setup action';
                }
                action("NPR Attributes")
                {
                    Caption = 'NPR Attributes';
                    RunObject = Page "NPR Attributes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NPR Attributes action';
                }
                action("POS Web Fonts")
                {
                    Caption = 'POS Web Fonts';
                    RunObject = Page "NPR POS Web Fonts";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Web Fonts action';
                }
                action("Lookup Templates")
                {
                    Caption = 'Lookup Templates';
                    RunObject = Page "NPR Lookup Templates";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Lookup Templates action';
                }
                action("POS Stargate Packages")
                {
                    Caption = 'POS Stargate Packages';
                    RunObject = Page "NPR POS Stargate Packages";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Stargate Packages action';
                }
                action("Stock-Take Templates")
                {
                    Caption = 'Stock-Take Templates';
                    RunObject = page "NPR Item Worksheet Templates";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Stock-Take Templates action';
                }
                action("Task Queue")
                {
                    Caption = 'Task Queue';
                    RunObject = page "NPR Task Queue";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Task Queue action';
                }
                action("Job Queue")
                {
                    Caption = 'Job Queue';
                    RunObject = page "Job Queue Category List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Job Queue action';
                }
                action("CleanCash Setup List")
                {
                    Caption = 'CleanCash Setup List';
                    RunObject = page "NPR CleanCash Setup List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the CleanCash Setup List action';
                }
                action("Retail Replenisment Setup")
                {
                    Caption = 'Retail Replenisment Setup';
                    RunObject = page "NPR Retail Replenish. SKU List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Replenisment Setup action';
                }
            }


            group(Item)
            {
                Caption = 'Item';
                action("Sales Price Maintenance Setup")
                {
                    Caption = 'Sales Price Maintenance Setup';
                    RunObject = Page "NPR Sales Price Maint. Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Price Maintenance Setup action';
                }
                action("RIS Retail Inventory Sets")
                {
                    Caption = 'RIS Retail Inventory Sets';
                    RunObject = Page "NPR RIS Retail Inv. Sets";
                    ApplicationArea = All;
                    ToolTip = 'Executes the RIS Retail Inventory Sets action';
                }
                action("Item Category Mapping")
                {
                    Caption = 'Item Category Mapping';
                    RunObject = Page "NPR Item Category Mapping";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Category Mapping action';
                }
                action("Store Groups")
                {
                    Caption = 'Store Groups';
                    RunObject = Page "NPR Store Groups";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Store Groups action';
                }
                action("Variety Fields Setup")
                {
                    Caption = 'Variety Fields Setup';
                    RunObject = Page "NPR Variety Fields Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Variety Fields Setup action';
                }
                action("Variety Setup")
                {
                    Caption = 'Variety Setup';
                    RunObject = page "NPR Variety";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Variety Setup action';
                }
                action("Item Groups")
                {
                    Caption = 'Item Groups';
                    RunObject = page "NPR Item Group List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Groups action';
                }
                action(Locations)
                {
                    Caption = 'Locations';
                    RunObject = page "Location List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Locations action';
                }

                action("Mix Discounts")
                {
                    Caption = 'Mix Discounts List';
                    RunObject = page "NPR Mixed Discount List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Mix Discounts List action';
                }

                action("Period Discounts")
                {
                    Caption = 'Period Discounts List';
                    RunObject = page "NPR Campaign Discount List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Period Discounts List action';
                }

                action("Retail Campaigns")
                {
                    Caption = 'Retail Campaigns List';
                    RunObject = page "NPR Retail Campaigns";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Campaigns List action';
                }

                action("Discount Priority List")
                {
                    Caption = 'Discount Priority List';
                    RunObject = page "NPR Discount Priority List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Discount Priority List action';
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
                action("Export Wizard")
                {
                    Caption = 'Export Wizard';
                    RunObject = page "NPR Table Export Wizard";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Export Wizard action';
                }

                action("Import Wizard")
                {
                    Caption = 'Import Wizard';
                    RunObject = page "NPR Table Import Wizard";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Import Wizard action';
                }
                action(Users)
                {
                    Caption = 'Users';
                    RunObject = page Users;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Users action';
                }

                action("User Groups")
                {
                    Caption = 'User Group';
                    RunObject = page "User Groups";
                    ApplicationArea = All;
                    ToolTip = 'Executes the User Group action';
                }
                action("Permission Sets")
                {
                    Caption = 'Permission Sets';
                    RunObject = page "Permission Sets";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Permission Sets action';
                }
                action("User Group Permission Sets")
                {
                    Caption = 'User Group Permission Sets';
                    RunObject = page "User Group Permission Sets";
                    ApplicationArea = All;
                    ToolTip = 'Executes the User Group Permission Sets action';
                }

                action(Extensions)
                {
                    Caption = 'Extension';
                    RunObject = page "Extension Management";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Extension action';
                }

                action("Setup & Extensions")
                {
                    Caption = 'Setup & Extensions';
                    RunObject = page "Assisted Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Setup & Extensions action';
                }

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
                RunObject = page "NPR Retail Setup";
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
                group("CS Setup")
                {
                    Caption = 'Setup';
                    action("AF Setup")
                    {
                    Caption = 'AF Setup';
                    RunObject = page "NPR AF Setup";
                    Image = Setup;
                    ApplicationArea = All;
                    ToolTip = 'Executes the AF Setup action';
                    }
                }
            }
            group("Posting Setup")
            {
                Caption = 'Posting Setup';

                action("Gen Posting Setup")
                {
                    Caption = 'Gen. Posting Setup';
                    RunObject = page "General Posting Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Gen. Posting Setup action';
                }
                action("VAT Posting Setup")
                {
                    Caption = 'VAT Posting Setup';
                    RunObject = page "VAT Posting Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the VAT Posting Setup action';
                }
                action("Inventory Setup")
                {
                    Caption = 'Inventory Setup';
                    RunObject = page "Inventory Periods";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Inventory Setup action';
                }
                action(DimensionsList)
                {
                    Caption = 'Dimensions List';
                    RunObject = page "Dimension List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions List action';
                }

            }


        }
    }
}

