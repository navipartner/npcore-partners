page 6151245 "NPR Setup RC"
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
                ApplicationArea = All;
            }
            part(Control1904484608; "NPR Setup Act - POS")
            {
                ApplicationArea = All;

            }

            part(Control14; "NPR Setup Act - Scenarios")
            {
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the POS Menus action';
            }
            action("POS Posting Setup_top")
            {
                Caption = 'POS Posting Setup';
                RunObject = Page "NPR POS Posting Setup";
                ApplicationArea = All;
                ToolTip = 'Executes the POS Posting Setup action';
            }
            action("Coupon Types_top")
            {
                Caption = 'Coupon Types';
                RunObject = Page "NPR NpDc Coupon Types";
                ApplicationArea = All;
                ToolTip = 'Executes the Coupon Types action';
            }
            action("E-mail Templates_top")
            {
                Caption = 'E-mail Templates';
                RunObject = Page "NPR E-mail Templates";
                ApplicationArea = All;
                ToolTip = 'Executes the E-mail Templates action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Menus action';
                }
                action("POS Actions")
                {
                    Caption = 'POS Actions';
                    Image = "Action";
                    RunObject = Page "NPR POS Actions";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Actions action';
                }
                action("POS Default View")
                {
                    Caption = 'POS Default View';
                    Image = View;
                    RunObject = Page "NPR POS Default Views";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Default View action';
                }
                action("POS View List")
                {
                    Caption = 'POS View List';
                    Image = ViewDocumentLine;
                    RunObject = Page "NPR POS View List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS View List action';
                }
                action("POS Scenarios")
                {
                    Caption = 'POS Scenarios';
                    Image = Allocate;
                    RunObject = Page "NPR POS Scenarios";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Scenarios action';
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
                action("POS Unit Identity")
                {
                    Caption = 'POS Unit Identity';
                    Image = List;
                    RunObject = page "NPR POS Unit Identity List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Unit Identity action';

                }
                action("POS Themes")
                {
                    Caption = 'POS Themes';
                    RunObject = Page "NPR POS Themes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Themes action';
                }
                action("POS Display Setup")
                {
                    Caption = 'POS Display Setup';
                    RunObject = Page "NPR Display Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Display Setup action';
                }
                action("POS Scenarios Sets")
                {
                    Caption = 'POS Scenarios Sets';
                    RunObject = Page "NPR POS Scenarios Sets";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Scenarios Sets action';
                }
                action("POS Input Box Events")
                {
                    Caption = 'POS Input Box Events';
                    Image = List;
                    RunObject = Page "NPR POS Input Box Events";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Input Box Events action';
                }
                action("POS Input Box Setups")
                {
                    Caption = 'POS Input Box Setups';
                    Image = List;
                    RunObject = Page "NPR POS Input Box Setups";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Input Box Setups action';
                }
            }
            group(PaymentCard)
            {
                Caption = 'Payment';
                Image = CostAccounting;
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
                action("POS Payment view Event Setup")
                {
                    Caption = 'POS Payment View Event Setup';
                    Image = List;
                    RunObject = page "NPR POS Paym. View Event Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Payment View Event Setup action';
                }
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
                action("POS Info List")
                {
                    Caption = 'POS Info List';
                    RunObject = Page "NPR POS Info List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Info List action';
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

                action("POS Stargate Packages")
                {
                    Caption = 'POS Stargate Packages';
                    RunObject = Page "NPR POS Stargate Packages";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Stargate Packages action';
                }
                action("Item Worksheet Templates")
                {
                    Caption = 'Item Worksheet Templates';
                    RunObject = page "NPR Item Worksheet Templates";
                    ApplicationArea = All;
                    ToolTip = 'Executes the item worksheet Templates action';
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
                action("Global POS Sales Setups")
                {
                    Caption = 'Global POS Sales Setups';
                    RunObject = Page "NPR NpGp Global POSSalesSetups";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Global POS Sales Setups action';
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
                action("No. Series")
                {
                    Caption = 'No. Series';
                    RunObject = Page "No. Series";
                    ApplicationArea = All;
                    ToolTip = 'Executes the No. Series action';
                }
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
                action("NP Retail Setup")
                {
                    Caption = 'NP Retail Setup';
                    RunObject = Page "NPR NP Retail Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NP Retail Setup action';
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
                action("POS Posting Setup")
                {
                    Caption = 'POS Posting Setup';
                    RunObject = Page "NPR POS Posting Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Posting Setup action';
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

