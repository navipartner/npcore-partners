page 6151245 "NP Retail Admin Setup RC"
{
    // #343621/ZESO/20190725  CASE 343621 New Role Centre Page

    Caption = 'NP Retail Admin Setup';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {



            part(Control1904484608; "NP Retail Admin Act - POS")
            {

            }


            part(Control14; "NP Retail Admin Act - WFs")
            {
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
                action("POS Themes")
                {
                    Caption = 'POS Themes';
                    RunObject = Page "POS Themes";
                }
                action("POS Info List")
                {
                    Caption = 'POS Info List';
                    RunObject = Page "POS Info List";
                }
                action("POS Customer Location")
                {
                    Caption = 'POS Customer Location';
                    RunObject = Page "POS Customer Location";
                }
                action("POS Admin. Template List")
                {
                    Caption = 'POS Admin. Template List';
                    // RunObject = Page "POS Admin. Template List";
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
                action(Action6014418)
                {
                    Caption = 'POS Sales Workflows';
                    RunObject = Page "POS Sales Workflows";
                }
                action("POS Sales Workflow Sets")
                {
                    Caption = 'POS Sales Workflow Sets';
                    RunObject = Page "POS Sales Workflow Sets";
                }
                action("No. Series")
                {
                    Caption = 'No. Series';
                    RunObject = Page "No. Series";
                }
                action("Ean Box Events")
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
                action("POS Unit Identity")
                {
                    Caption = 'POS Unit Identity';
                    Image = List;
                    RunObject = page "POS Unit Identity List";

                }
                action("POS Payment view Event Setup")
                {
                    Caption = 'POS Payment view Event Setup';
                    Image = List;
                    RunObject = page "POS Payment View Event Setup";
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
                action("EFT Setup")
                {
                    Caption = 'EFT Setup';
                    RunObject = Page "EFT Setup";
                }
                action("EFT Integration Types")
                {
                    Caption = 'EFT Integration Types';
                    RunObject = Page "EFT Integration Types";
                }
                action("EFT BIN Group List")
                {
                    Caption = 'EFT BIN Group List';
                    RunObject = Page "EFT BIN Group List";
                }
                action("Tax Free POS Units")
                {
                    Caption = 'Tax Free POS Units';
                    RunObject = Page "Tax Free POS Units";
                }
                action("Pepper Terminal Types")
                {
                    Caption = 'Pepper Terminal Types';
                    RunObject = Page "Pepper Terminal Types";
                }
                action("Pepper Terminals")
                {
                    Caption = 'Pepper Terminals';
                    RunObject = Page "Pepper Terminal List";
                }
                action("Pepper Versions")
                {
                    Caption = 'Pepper Versions';
                    RunObject = Page "Pepper Version List";
                }
                action("Pepper Instances")
                {
                    Caption = 'Pepper Instances';
                    RunObject = Page "Pepper Instances";
                }
                action("Pepper Configurations")
                {
                    Caption = 'Pepper Configurations';
                    RunObject = Page "Pepper Configuration List";
                }
                action("Pepper Card Types")
                {
                    Caption = 'Pepper Card Types';
                    RunObject = Page "Pepper Card Types";
                }
                action("Pepper Card Type Group")
                {
                    Caption = 'Pepper Card Type Group';
                    RunObject = Page "Pepper Card Type Group";
                }
            }
            group("Coupons & Vouchers")
            {
                Caption = 'Coupons & Vouchers';
                action("Coupon Types")
                {
                    Caption = 'Coupon Types';
                    RunObject = Page "NpDc Coupon Types";
                }
                action("Coupon Modules")
                {
                    Caption = 'Coupon Modules';
                    RunObject = Page "NpDc Coupon Modules";
                }
                action("External Retail Voucher Types")
                {
                    Caption = 'External Retail Voucher Types';
                    RunObject = Page "ExRv Voucher Types";
                }
                action("Voucher Types")
                {
                    Caption = 'Voucher Types';
                    RunObject = Page "NpRv Voucher Types";
                }
                action("Voucher Modules")
                {
                    Caption = 'Voucher Modules';
                    RunObject = Page "NpRv Voucher Modules";
                }
                action("Retail Voucher Partners")
                {
                    Caption = 'Retail Voucher Partners';
                    RunObject = Page "NpRv Partners";
                }
            }
            group("Global Setup")
            {
                Caption = 'Global Setup';
                action("Global POS Sales Setups")
                {
                    Caption = 'Global POS Sales Setups';
                    RunObject = Page "NpGp Global POS Sales Setups";
                }
                action("Cross Companies Setup")
                {
                    Caption = 'Cross Companies Setup';
                    // RunObject = Page "NpGp Cross Companies Setup";

                }
            }
            group("Collect in Store")
            {
                Caption = 'Collect in Store';
                action("Collect Stores")
                {
                    Caption = 'Collect Stores';
                    RunObject = Page "NpCs Stores";
                }
                action("Collect Workflows")
                {
                    Caption = 'Collect Workflows';
                    RunObject = Page "NpCs Workflows";
                }
                action("Store Opening Hours Setup")
                {
                    Caption = 'Store Opening Hours Setup';
                    //  RunObject = Page "NpCs Store Opening Hours Setup";
                }
                action("Collect Workflow Modules")
                {
                    Caption = 'Collect Workflow Modules';
                    RunObject = Page "NpCs Workflow Modules";
                }
                action("Collect Document Mapping")
                {
                    Caption = 'Collect Document Mapping';
                    RunObject = Page "NpCs Document Mapping";
                }
            }
            group("Print & Email")
            {
                Caption = 'Print & Email';
                action("Printer Selections")
                {
                    Caption = 'Printer Selections';
                    RunObject = Page "Printer Selections";
                }
                action("Retail Print Template List")
                {
                    Caption = 'Retail Print Template List';
                    RunObject = Page "RP Template List";
                }
                action("Object Output Selection")
                {
                    Caption = 'Object Output Selection';
                    RunObject = Page "Object Output Selection";
                }
                action("Retail Logo Setup")
                {
                    Caption = 'Retail Logo Setup';
                    RunObject = Page "Retail Logo Setup";
                }
                action("Google Cloud Print Setup")
                {
                    Caption = 'Google Cloud Print Setup';
                    RunObject = Page "GCP Setup";
                }
                action("E-mail Templates")
                {
                    Caption = 'E-mail Templates';
                    RunObject = Page "E-mail Templates";
                }

                action("Report Selection - Retail")
                {
                    Caption = 'Report Selection - Retail';
                    //RunObject = page "Report Selection - Retail";
                }

                action("SMS Template List")
                {
                    Caption = 'SMS Template List';
                    RunObject = page "SMS Template List";

                }
                action("Report Selection - Contract")
                {
                    Caption = 'Report Selection - Contract';

                }
            }
            group(Miscellaneous)
            {
                Caption = 'Miscellaneous';
                action("Retail Cross References")
                {
                    Caption = 'Retail Cross References';
                    RunObject = Page "Retail Cross References";
                }
                action(Scanners)
                {
                    Caption = 'Scanners';
                    RunObject = Page "Scanner - List";
                }
                action("POS Keyboard Binding Setup")
                {
                    Caption = 'POS Keyboard Binding Setup';
                    RunObject = Page "POS Keyboard Binding Setup";
                }
                action("NPR Attributes")
                {
                    Caption = 'NPR Attributes';
                    RunObject = Page "NPR Attributes";
                }
                action("POS Web Fonts")
                {
                    Caption = 'POS Web Fonts';
                    RunObject = Page "POS Web Fonts";
                }
                action(".NET Assemblies")
                {
                    Caption = '.NET Assemblies';
                    RunObject = Page ".NET Assemblies";
                }
                action("Proxy Assemblies")
                {
                    Caption = 'Proxy Assemblies';
                    // RunObject = Page "Proxy Assemblies";
                }
                action("Lookup Templates")
                {
                    Caption = 'Lookup Templates';
                    RunObject = Page "Lookup Templates";
                }
                action("Doc. Exchange Paths")
                {
                    Caption = 'Doc. Exchange Paths';
                    RunObject = Page "Doc. Exchange Paths";
                }
                action("POS Stargate Packages")
                {
                    Caption = 'POS Stargate Packages';
                    RunObject = Page "POS Stargate Packages";
                }
                action("Stock-Take Templates")
                {
                    Caption = 'Stock-Take Templates';
                    RunObject = page "Item Worksheet Templates";
                }
                action("Task Queue")
                {
                    Caption = 'Task Queue';
                    RunObject = page "Task Queue";
                }
                action("Job Queue")
                {
                    Caption = 'Job Queue';
                    RunObject = page "Job Queue Category List";
                }
                action("Hotkeys")
                {
                    Caption = 'Hotkeys';
                    RunObject = page Hotkeys;
                }
                action("CleanCash Setup List")
                {
                    Caption = 'CleanCast Setup List';
                    RunObject = page "CleanCash Setup List";
                }
                action("Retail Replenisment Setup")
                {
                    Caption = 'Retail Replenisment Setup';
                    RunObject = page "Retail Replenishment SKU List";
                }



            }


            group(Item)
            {
                Caption = 'Item';
                action("Sales Price Maintenance Setup")
                {
                    Caption = 'Sales Price Maintenance Setup';
                    RunObject = Page "Sales Price Maintenance Setup";
                }
                action("RIS Retail Inventory Sets")
                {
                    Caption = 'RIS Retail Inventory Sets';
                    RunObject = Page "RIS Retail Inventory Sets";
                }
                action("Item Category Mapping")
                {
                    Caption = 'Item Category Mapping';
                    RunObject = Page "Item Category Mapping";
                }
                action("Store Groups")
                {
                    Caption = 'Store Groups';
                    RunObject = Page "Store Groups";
                }
                action("Variety Fields Setup")
                {
                    Caption = 'Variety Fields Setup';
                    RunObject = Page "Variety Fields Setup";
                }
                action("Variety Setup")
                {
                    Caption = 'Variety Setup';
                    RunObject = page "Variety";
                }
                action("Item Groups")
                {
                    Caption = 'Item Groups';
                    RunObject = page "Item Group List";
                }
                action("Locations")
                {
                    Caption = 'Locations';
                    RunObject = page "Location List";
                }

                action("Mix Discounts")
                {
                    Caption = 'Mix Discounts List';
                    RunObject = page "Mixed Discount List";
                }

                action("Period Discounts")
                {
                    Caption = 'Period Discounts List';
                    RunObject = page "Campaign Discount List";
                }

                action("Retail Campaigns")
                {
                    Caption = 'Retail Campaigns List';
                    RunObject = page "Retail Campaigns";
                }

                action("Discount Priority List")
                {
                    Caption = 'Discount Priority List';
                    RunObject = page "Discount Priority List";
                }

                action("Retail Price Log Setup")
                {
                    Caption = 'Retail Price Log Setup';
                    //RunObject = page "Retail Price Log Setup";
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
                action("Export Wizard")
                {
                    Caption = 'Export Wizard';
                    RunObject = page "Table Export Wizard";
                }

                action("Import Wizard")
                {
                    Caption = 'Import Wizard';
                    RunObject = page "Table Import Wizard";
                }
                action("Users")
                {
                    Caption = 'Users';
                    RunObject = page Users;
                }

                action("User Groups")
                {
                    Caption = 'User Group';
                    RunObject = page "User Groups";
                }
                action("Permission Sets")
                {
                    Caption = 'Permission Sets';
                    RunObject = page "Permission Sets";
                }
                action("User Group Permission Sets")
                {
                    Caption = 'User Group Permission Sets';
                    RunObject = page "User Group Permission Sets";
                }

                action("Extensions")
                {
                    Caption = 'Extension';
                    RunObject = page "Extension Management";
                }

                action("Setup & Extensions")
                {
                    Caption = 'Setup & Extensions';
                    RunObject = page "Assisted Setup";
                }
            }
            group("Posting Setup")
            {
                Caption = 'Posting Setup';

                action("Gen Posting Setup")
                {
                    Caption = 'Gen. Posting Setup';
                    RunObject = page "General Posting Setup";
                }
                action("VAT Posting Setup")
                {
                    Caption = 'VAT Posting Setup';
                    RunObject = page "VAT Posting Setup";
                }
                action("Inventory Setup")
                {
                    Caption = 'Inventory Setup';
                    RunObject = page "Inventory Periods";
                }

                action("Default Dimension Prorities")
                {
                    Caption = 'Default Dimension Prorities';
                    //RunObject = page "Default Dimension Priorities";
                }

                action(DimensionsList)
                {
                    Caption = 'Dimensions List';
                    RunObject = page "Dimension List";
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
                RunObject = page "Retail Setup";
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
            group("CS Setup")
            {
                Caption = 'Setup';

                action("CS Setup1")
                {
                    Caption = 'CS Setup';
                    RunObject = page "CS Setup";
                }
                action("AF Setup")
                {
                    Caption = 'AF Setup';
                    RunObject = page "AF Setup";
                }
            }


        }
    }

}

