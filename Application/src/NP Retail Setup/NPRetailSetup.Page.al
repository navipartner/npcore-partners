page 6150613 "NPR NP Retail Setup"
{

    Caption = 'NP Retail Setup';
    SourceTable = "NPR NP Retail Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Code field';
                }
            }
            group("System")
            {
                Caption = 'System';
                field("Data Model Build"; "Data Model Build")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR Retail Data Model Upg.Log";
                    Editable = false;
                    ToolTip = 'Specifies the value of the Data Model Build field';
                }
                field("Last Data Model Build Upgrade"; "Last Data Model Build Upgrade")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Data Model Build Upgrade field';
                }
                field("Last Data Model Build User ID"; "Last Data Model Build User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Data Model Build User ID field';
                }
                field("Prev. Data Model Build"; "Prev. Data Model Build")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Prev. Data Model Build field';
                }
                field("Advanced POS Entries Activated"; "Advanced POS Entries Activated")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Advanced POS Entries Activated field';
                }
                field("Advanced Posting Activated"; "Advanced Posting Activated")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Advanced Posting Activated field';
                }
                field("Default POS Posting Profile"; "Default POS Posting Profile")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Posting Profile field';
                }
            }
            group(Environment)
            {
                Caption = 'Environment';
                grid(Control6014418)
                {
                    Editable = false;
                    GridLayout = Rows;
                    ShowCaption = false;
                    group("Database Name")
                    {
                        Caption = 'Database Name';
                        field("Environment Database Name"; "Environment Database Name")
                        {
                            ApplicationArea = All;
                            Caption = 'Stored';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Stored field';
                        }
                        field("ActiveSession.""Database Name"""; ActiveSession."Database Name")
                        {
                            ApplicationArea = All;
                            Caption = 'Current';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Current field';
                        }
                    }
                    group("Company Name")
                    {
                        Caption = 'Company Name';
                        field("Environment Company Name"; "Environment Company Name")
                        {
                            ApplicationArea = All;
                            Caption = 'Stored';
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Stored field';
                        }
                        field(CURRENTCOMPANY; CurrentCompany)
                        {
                            ApplicationArea = All;
                            Caption = 'Current';
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Current field';
                        }
                    }
                    group("Tenant Name")
                    {
                        Caption = 'Tenant Name';
                        field("Environment Tenant Name"; "Environment Tenant Name")
                        {
                            ApplicationArea = All;
                            Caption = 'Stored';
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Stored field';
                        }
                        field(TENANTID; TenantId)
                        {
                            ApplicationArea = All;
                            Caption = 'Current';
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies the value of the Current field';
                        }
                    }
                }
                group(Settings)
                {
                    Caption = 'Settings';
                    field("Environment Type"; "Environment Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Environment Type field';
                    }
                    field("Environment Verified"; "Environment Verified")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Environment Verified field';
                    }
                    field("Environment Template"; "Environment Template")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Environment Template field';
                    }
                    field("Enable Client Diagnostics"; "Enable Client Diagnostics")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Enable Client Diagnostics field';
                    }
                }
            }
            group(Legal)
            {
                field("Standard Conditions"; "Standard Conditions")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Standard Conditions field';
                }
                field(Privacy; Privacy)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Privacy field';
                }
                field("License Agreement"; "License Agreement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the License Agreement field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(POSSection)
            {
                Caption = 'POS Setup';
                Image = Loaner;
                group(POS)
                {
                    Caption = 'POS';
                    Image = Loaner;
                    action(Menus)
                    {
                        Caption = 'Menus';
                        Image = PaymentJournal;
                        RunObject = Page "NPR POS Menus";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Menus action';
                    }
                    action("Default Views")
                    {
                        Caption = 'Default Views';
                        Image = View;
                        RunObject = Page "NPR POS Default Views";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Default Views action';
                    }
                    action("Actions")
                    {
                        Caption = 'Actions';
                        Image = "Action";
                        RunObject = Page "NPR POS Actions";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Actions action';
                    }
                    action(Action6014556)
                    {
                        Caption = 'Setup';
                        Image = SetupPayment;
                        RunObject = Page "NPR POS Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup action';
                    }
                    action("View List")
                    {
                        Caption = 'View List';
                        Image = ViewDocumentLine;
                        RunObject = Page "NPR POS View List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the View List action';
                    }
                    action("Menu Filter")
                    {
                        Caption = 'Menu Filter';
                        Image = "Filter";
                        RunObject = Page "NPR POS Menu Filter";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Menu Filter action';
                    }
                    action("POS Sales Workflows")
                    {
                        Caption = 'POS Sales Workflows';
                        Image = Allocate;
                        RunObject = Page "NPR POS Sales Workflows";
                        ApplicationArea = All;
                        ToolTip = 'Executes the POS Sales Workflows action';
                    }
                }
                group("Ean Box Events")
                {
                    Caption = 'Ean Box Events';
                    Image = ItemRegisters;
                    action(Action6014541)
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
            }
            group(AdvancedPosting)
            {
                Caption = 'Advanced POS';
                group(Setup)
                {
                    Caption = 'Setup';
                    Image = Setup;
                    action("POS Stores")
                    {
                        Caption = 'POS Stores';
                        Image = Warehouse;
                        RunObject = Page "NPR POS Store List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the POS Stores action';
                    }
                    action("POS Units")
                    {
                        Caption = 'POS Units';
                        Image = MiniForm;
                        RunObject = Page "NPR POS Unit List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the POS Units action';
                    }
                    action("POS Payment Bins")
                    {
                        Caption = 'POS Payment Bins';
                        Image = Bin;
                        RunObject = Page "NPR POS Payment Bins";
                        ApplicationArea = All;
                        ToolTip = 'Executes the POS Payment Bins action';
                    }
                    action("POS Posting Setup")
                    {
                        Caption = 'POS Posting Setup';
                        Image = GeneralPostingSetup;
                        RunObject = Page "NPR POS Posting Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the POS Posting Setup action';
                    }
                    action("POS Payment Method")
                    {
                        Caption = 'POS Payment Method';
                        Image = SetupPayment;
                        RunObject = Page "NPR POS Payment Method List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the POS Payment Method action';
                    }
                    action("Unit Identity")
                    {
                        Caption = 'Unit Identity';
                        Image = UnitConversions;
                        RunObject = Page "NPR POS Unit Identity List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Unit Identity action';
                    }
                }
                group(Transactions)
                {
                    Caption = 'Transactions';
                    Image = Job;
                    action("POS Period Registers")
                    {
                        Caption = 'POS Period Registers';
                        Image = Register;
                        RunObject = Page "NPR POS Period Register List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the POS Period Registers action';
                    }
                    action("POS Entries")
                    {
                        Caption = 'POS Entries';
                        Image = LedgerEntries;
                        RunObject = Page "NPR POS Entries";
                        ApplicationArea = All;
                        ToolTip = 'Executes the POS Entries action';
                    }
                    action("POS Entries (Detailed)")
                    {
                        Caption = 'POS Entries (Detailed)';
                        Image = EntriesList;
                        RunObject = Page "NPR POS Entry List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the POS Entries (Detailed) action';
                    }
                    action("POS Posting Log")
                    {
                        Caption = 'POS Posting Log';
                        Image = Log;
                        RunObject = Page "NPR POS Posting Log";
                        ApplicationArea = All;
                        ToolTip = 'Executes the POS Posting Log action';
                    }
                }
                group(Upgrade)
                {
                    Caption = 'Upgrade';
                    Image = MoveUp;
                    action(UpgradeBalV3Setup)
                    {
                        Caption = 'Upgrade Audit Roll to POS Entry';
                        ApplicationArea = All;
                        ToolTip = 'Executes the Upgrade Audit Roll to POS Entry action';

                        trigger OnAction()
                        var
                            RetailDataModelARUpgrade: Codeunit "NPR RetailDataModel AR Upgr.";
                        begin
                            //-NPR5.48 [334335]
                            RetailDataModelARUpgrade.UpgradeSetupsBalancingV3;
                            //+NPR5.48 [334335]
                        end;
                    }
                }
                group(Configuration)
                {
                    Caption = 'Other Configuration';
                    Image = Setup;
                    action("POS Web Fonts")
                    {
                        Caption = 'POS Web Fonts';
                        Image = List;
                        RunObject = Page "NPR POS Web Fonts";
                        ApplicationArea = All;
                        ToolTip = 'Executes the POS Web Fonts action';
                    }
                    action("POS Stargate Packages")
                    {
                        Caption = 'POS Stargate Packages';
                        Image = MachineCenter;
                        RunObject = Page "NPR POS Stargate Packages";
                        ApplicationArea = All;
                        ToolTip = 'Executes the POS Stargate Packages action';
                    }
                    action("Dependency Management Setup")
                    {
                        Caption = 'Dependency Management Setup';
                        Image = Setup;
                        RunObject = Page "NPR Dependency Mgt. Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Dependency Management Setup action';
                    }
                    action("RFID Setup")
                    {
                        Caption = 'RFID Setup';
                        Image = Setup;
                        RunObject = Page "NPR RFID Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the RFID Setup action';
                    }
                    action("MCS API Setup")
                    {
                        Caption = 'MCS API Setup';
                        Image = Setup;
                        RunObject = Page "NPR MCS API Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the MCS API Setup action';
                    }
                    action("Lookup Templates")
                    {
                        Caption = 'Lookup Templates';
                        Image = List;
                        RunObject = Page "NPR Lookup Templates";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Lookup Templates action';
                    }
                }
                action("Client Diagnostics")
                {
                    Caption = 'Client Diagnostics';
                    Image = AnalysisView;
                    RunObject = Page "NPR Client Diagnostics";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Client Diagnostics action';
                }
            }
            group(PaymentCard)
            {
                Caption = 'Payment';
                action("<Page Payment Type - List>")
                {
                    Caption = 'Types';
                    Image = Payment;
                    RunObject = Page "NPR Payment Type - List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Types action';
                }
            }
            group(ModuleSection)
            {
                Caption = 'Module';
                Image = Components;
                group(Variety)
                {
                    Caption = 'Variety';
                    Image = ItemVariant;
                    action(Action6014595)
                    {
                        Caption = 'Variety';
                        Image = List;
                        RunObject = Page "NPR Variety";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Variety action';
                    }
                    action("Variety Setup")
                    {
                        Caption = 'Variety Setup';
                        Image = List;
                        RunObject = Page "NPR Variety Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Variety Setup action';
                    }
                    action("Variety Fields Setup")
                    {
                        Caption = 'Variety Fields Setup';
                        Image = List;
                        RunObject = Page "NPR Variety Fields Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Variety Fields Setup action';
                    }
                    action("Variety Group")
                    {
                        Caption = 'Variety Group';
                        Image = List;
                        RunObject = Page "NPR Variety Group";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Variety Group action';
                    }
                }
                group("E-mail")
                {
                    Caption = 'E-mail';
                    Image = MailSetup;
                    action("E-mail Templates")
                    {
                        Caption = 'E-mail Templates';
                        Image = List;
                        RunObject = Page "NPR E-mail Templates";
                        ApplicationArea = All;
                        ToolTip = 'Executes the E-mail Templates action';
                    }
                    action("E-mail Setup")
                    {
                        Caption = 'E-mail Setup';
                        Image = List;
                        RunObject = Page "NPR E-mail Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the E-mail Setup action';
                    }
                }
                group(ImportExport)
                {
                    Caption = 'Import/Export';
                    Image = Change;
                    action("Table Export")
                    {
                        Caption = 'Table Export';
                        Image = List;
                        RunObject = Page "NPR Table Export Wizard";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Table Export action';
                    }
                    action("Table Import")
                    {
                        Caption = 'Table Import';
                        Image = List;
                        RunObject = Page "NPR Table Import Wizard";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Table Import action';
                    }
                    action("Object List")
                    {
                        Caption = 'Object List';
                        Image = List;
                        RunObject = Page "NPR Object List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Object List action';
                    }
                }
                group(Hospitality)
                {
                    Caption = 'Hospitality';
                    Image = Relatives;
                    action("Seating List")
                    {
                        Caption = 'Seating List';
                        Image = List;
                        RunObject = Page "NPR NPRE Seating List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Seating List action';
                    }
                    action("Hospitality Setup")
                    {
                        Caption = 'Hospitality Setup';
                        Image = List;
                        RunObject = Page "NPR NPRE Restaurant Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Hospitality Setup action';
                    }
                    action("Seating Locations")
                    {
                        Caption = 'Seating Locations';
                        Image = List;
                        RunObject = Page "NPR NPRE Seating Location";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Seating Locations action';
                    }
                }
                group(DiscountCoupon)
                {
                    Caption = 'Discount Coupon';
                    Image = Voucher;
                    action(Coupons)
                    {
                        Caption = 'Coupons';
                        Image = List;
                        RunObject = Page "NPR NpDc Coupons";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Coupons action';
                    }
                    action("Coupon Types")
                    {
                        Caption = 'Coupon Types';
                        Image = List;
                        RunObject = Page "NPR NpDc Coupon Types";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Coupon Types action';
                    }
                    action("Posted Coupons")
                    {
                        Caption = 'Posted Coupons';
                        Image = List;
                        RunObject = Page "NPR NpDc Arch. Coupons";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Posted Coupons action';
                    }
                    action("Coupon Setup")
                    {
                        Caption = 'Coupon Setup';
                        Image = List;
                        RunObject = Page "NPR NpDc Coupon Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Coupon Setup action';
                    }
                }
                group(Voucher)
                {
                    Caption = 'Voucher';
                    Image = Voucher;
                    action(Vouchers)
                    {
                        Caption = 'Vouchers';
                        Image = List;
                        RunObject = Page "NPR NpRv Vouchers";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Vouchers action';
                    }
                    action("Voucher Types")
                    {
                        Caption = 'Voucher Types';
                        Image = List;
                        RunObject = Page "NPR NpRv Voucher Types";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Voucher Types action';
                    }
                    action("Posted Vouchers")
                    {
                        Caption = 'Posted Vouchers';
                        Image = List;
                        RunObject = Page "NPR NpRv Arch. Vouchers";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Posted Vouchers action';
                    }
                    action("Voucher Setup")
                    {
                        Caption = 'Voucher Setup';
                        Image = List;
                        RunObject = Page "NPR NpRv Global Voucher Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Voucher Setup action';
                    }
                }
                group("Azure Functions")
                {
                    Caption = 'Azure Functions';
                    Image = Relatives;
                    action(Action6014455)
                    {
                        Caption = 'Setup';
                        Image = List;
                        RunObject = Page "NPR AF Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup action';
                    }
                    action("Spire Barcode")
                    {
                        Caption = 'Spire Barcode';
                        Image = List;
                        RunObject = Page "NPR AF Test Services";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Spire Barcode action';
                    }
                    action(Notifications)
                    {
                        Caption = 'Notifications';
                        Image = List;
                        RunObject = Page "NPR AF Notification Hub List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Notifications action';
                    }
                }
                group(Raptor)
                {
                    Caption = 'Raptor';
                    Image = Setup;
                    action(Action6014612)
                    {
                        Caption = 'Setup';
                        Image = List;
                        RunObject = Page "NPR Raptor Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup action';
                    }
                }
                group(SalesTax)
                {
                    Caption = 'Sales Tax';
                    Image = SalesTaxStatement;
                    action("Tax Groups")
                    {
                        Caption = 'Tax Groups';
                        Image = List;
                        RunObject = Page "Tax Groups";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Tax Groups action';
                    }
                    action("Tax Jurisdictions")
                    {
                        Caption = 'Tax Jurisdictions';
                        Image = List;
                        RunObject = Page "Tax Jurisdictions";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Tax Jurisdictions action';
                    }
                    action("Tax Areas")
                    {
                        Caption = 'Tax Areas';
                        Image = List;
                        RunObject = Page "Tax Area List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Tax Areas action';
                    }
                    action("Tax Details")
                    {
                        Caption = 'Tax Details';
                        Image = List;
                        RunObject = Page "Tax Details";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Tax Details action';
                    }
                    action("Copy Tax Setup")
                    {
                        Caption = 'Copy Tax Setup';
                        Image = List;
                        RunObject = Page "Copy Tax Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Copy Tax Setup action';
                    }
                }
                action("POS Info list")
                {
                    Caption = 'POS Info list';
                    Image = Planning;
                    RunObject = Page "NPR POS Info List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Info list action';
                }
                group("Dynamic Modules")
                {
                    Caption = 'Dynamic Modules';
                    Image = Travel;
                    action("Dynamic Module")
                    {
                        Caption = 'Dynamic Module';
                        Image = Skills;
                        RunObject = Page "NPR Dynamic Modules";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Dynamic Module action';
                    }
                }
                group(DistributionReplenishment)
                {
                    Caption = 'Distribution And Replenishment';
                    Image = Setup;
                    action("Retail Replenishment Setup")
                    {
                        Caption = 'Retail Replenishment Setup';
                        Image = Replan;
                        RunObject = Page "NPR Retail Replenishment Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Retail Replenishment Setup action';
                    }
                }
                group("Other Functions")
                {
                    Caption = 'Other Functions';
                    Image = Alerts;
                    action(LastErrorCallstack)
                    {
                        Caption = 'Show Last Error';
                        Image = ErrorLog;
                        ApplicationArea = All;
                        ToolTip = 'Executes the Show Last Error action';

                        trigger OnAction()
                        var
                            LastErrorString: Text;
                        begin
                            //-NPR5.50 [355848]
                            LastErrorString := StrSubstNo('%1\\%2', Format(GetLastErrorText), GetLastErrorCallstack);
                            Message(LastErrorString);
                            //+NPR5.50 [355848]
                        end;
                    }
                }
            }
            group(Magento)
            {
                Caption = 'Magento Setup';
                action("Magento Setup")
                {
                    Caption = 'Magento Setup';
                    Image = Setup;
                    RunObject = Page "NPR Magento Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Magento Setup action';
                }
            }
            group(NaviConnect)
            {
                Caption = 'NaviConnect';
                Image = ServiceAccessories;
                group(NaviConnectNpXml)
                {
                    Caption = 'NpXml';
                    Image = ElectronicDoc;
                    separator(Administration)
                    {
                        Caption = 'Administration';
                    }
                    action("NpXml Templates")
                    {
                        Caption = 'NpXml Templates';
                        Image = Setup;
                        RunObject = Page "NPR NpXml Template List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the NpXml Templates action';
                    }
                }
                group(NaviConnectTriggers)
                {
                    Caption = 'Triggers';
                    Image = Continue;
                    separator(Lists)
                    {
                        Caption = 'Lists';
                    }
                    action(Triggers)
                    {
                        Caption = 'Triggers';
                        Image = List;
                        RunObject = Page "NPR Nc Triggers";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Triggers action';
                    }
                    separator(Separator6014497)
                    {
                        Caption = 'Administration';
                    }
                    action("Trigger Setup")
                    {
                        Caption = 'Trigger Setup';
                        Image = Setup;
                        RunObject = Page "NPR Nc Trigger Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Trigger Setup action';
                    }
                }
                group(NaviConnectEndpoints)
                {
                    Caption = 'Endpoints';
                    Image = EnableBreakpoint;
                    action(Types)
                    {
                        Caption = 'Types';
                        Image = List;
                        RunObject = Page "NPR Nc Endpoint Types";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Types action';
                    }
                    action(List)
                    {
                        Caption = 'List';
                        Image = List;
                        RunObject = Page "NPR Nc Endpoints";
                        ApplicationArea = All;
                        ToolTip = 'Executes the List action';
                    }
                }
                group(NaviConnectCollectors)
                {
                    Caption = 'Collectors';
                    Image = BinContent;
                    action(Collectors)
                    {
                        Caption = 'Collectors';
                        Image = List;
                        RunObject = Page "NPR Nc Collector List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Collectors action';
                    }
                    action(Collections)
                    {
                        Caption = 'Collections';
                        Image = List;
                        RunObject = Page "NPR Nc Collection List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Collections action';
                    }
                    action("Collection Lines")
                    {
                        Caption = 'Collection Lines';
                        Image = List;
                        RunObject = Page "NPR Nc Collection Lines";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Collection Lines action';
                    }
                    action("Create Outgoing Collector Req.")
                    {
                        Caption = 'Create Outgoing Collector Req.';
                        Image = List;
                        RunObject = Page "NPR Nc Coll. Create Outg. Req.";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Create Outgoing Collector Req. action';
                    }
                    action("Collector Request Lines")
                    {
                        Caption = 'Collector Request Lines';
                        Image = List;
                        RunObject = Page "NPR Nc Collector Req. Lines";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Collector Request Lines action';
                    }
                }
                group(NaviConnectTaskQueue)
                {
                    Caption = 'Task Queue';
                    Image = TaskList;
                    separator("Period Activities")
                    {
                        Caption = 'Period Activities';
                    }
                    action(Tasks)
                    {
                        Caption = 'Tasks';
                        Image = List;
                        RunObject = Page "NPR Task Journal";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Tasks action';
                    }
                    separator(History)
                    {
                        Caption = 'History';
                    }
                    action("Task Workers")
                    {
                        Caption = 'Task Workers';
                        Image = List;
                        RunObject = Page "NPR Task Worker";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Task Workers action';
                    }
                    action("Task Queue")
                    {
                        Caption = 'Task Queue';
                        Image = List;
                        RunObject = Page "NPR Task Queue";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Task Queue action';
                    }
                    action("Task Log")
                    {
                        Caption = 'Task Log';
                        Image = List;
                        RunObject = Page "NPR Task Log (Task)";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Task Log action';
                    }
                    separator(Separator6014479)
                    {
                        Caption = 'Setup';
                    }
                    action("Task Worker Groups")
                    {
                        Caption = 'Task Worker Groups';
                        Image = List;
                        RunObject = Page "NPR Task Worker Group";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Task Worker Groups action';
                    }
                }
                group(NaviConnectDataLog)
                {
                    Caption = 'Data Log';
                    Image = Log;
                    action("Data Log Setup")
                    {
                        Caption = 'Data Log Setup';
                        Image = Setup;
                        RunObject = Page "NPR Data Log Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Data Log Setup action';
                    }
                    action("Data Log Subscribers")
                    {
                        Caption = 'Data Log Subscribers';
                        Image = List;
                        RunObject = Page "NPR Data Log Subscribers";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Data Log Subscribers action';
                    }
                }
                group(NaviConnectPeriodicActivities)
                {
                    Caption = 'Periodic Activities';
                    Image = Period;
                    action("Task List")
                    {
                        Caption = 'Task List';
                        Image = Task;
                        RunObject = Page "NPR Nc Task List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Task List action';
                    }
                    action("Import List")
                    {
                        Caption = 'Import List';
                        Image = Task;
                        RunObject = Page "NPR Nc Import List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Import List action';
                    }
                }
                group(NaviConnectSetup)
                {
                    Caption = 'Setup';
                    Image = Setup;
                    action("NaviConnect Setup")
                    {
                        Caption = 'NaviConnect Setup';
                        Image = Setup;
                        RunObject = Page "NPR Nc Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the NaviConnect Setup action';
                    }
                    action("Task Processors")
                    {
                        Caption = 'Task Processors';
                        Image = Setup;
                        RunObject = Page "NPR Nc Task Proces. List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Task Processors action';
                    }
                    action("Task Setup")
                    {
                        Caption = 'Task Setup';
                        Image = Setup;
                        RunObject = Page "NPR Nc Task Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Task Setup action';
                    }
                    action("Import Types")
                    {
                        Caption = 'Import Types';
                        Image = Setup;
                        RunObject = Page "NPR Nc Import Types";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Import Types action';
                    }
                }
            }
            group(NPRVersionHistory)
            {
                Caption = 'Version';
                action(Action6014615)
                {
                    Caption = 'History';
                    Image = History;
                    RunObject = Page "NPR Upgrade History";
                    ApplicationArea = All;
                    ToolTip = 'Executes the History action';
                }
            }
        }
        area(processing)
        {
            group(AccessoriesSection)
            {
                Caption = 'Accessories';
                Image = ServiceAccessories;
                action("Display Setup")
                {
                    Caption = 'Display Setup';
                    Image = SetupList;
                    RunObject = Page "NPR Display Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Display Setup action';
                }
                action("Scanner Setups")
                {
                    Caption = 'Scanner Setups';
                    Image = BarCode;
                    RunObject = Page "NPR Scanner - List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Scanner Setups action';
                }

                group(Print)
                {
                    Caption = 'Print';
                    Image = Print;
                    action("Printer Selections")
                    {
                        Caption = 'Printer Selections';
                        Image = Setup;
                        RunObject = Page "Printer Selections";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Printer Selections action';
                    }
                    action("Retail Print Template List")
                    {
                        Caption = 'Retail Print Template List';
                        Image = Setup;
                        RunObject = Page "NPR RP Template List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Retail Print Template List action';
                    }
                    action("Object Output Selection")
                    {
                        Caption = 'Object Output Selection';
                        Image = Setup;
                        RunObject = Page "NPR Object Output Selection";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Object Output Selection action';
                    }
                    action("Retail Logo Setup")
                    {
                        Caption = 'Retail Logo Setup';
                        Image = Setup;
                        RunObject = Page "NPR Retail Logo Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Retail Logo Setup action';
                    }
                    action("Google Cloud Print Setup")
                    {
                        Caption = 'Google Cloud Print Setup';
                        Image = Setup;
                        RunObject = Page "NPR GCP Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Google Cloud Print Setup action';
                    }
                    action("Retail Print Template Setup")
                    {
                        Caption = 'Retail Print Template Setup';
                        Image = Setup;
                        RunObject = Page "NPR RP Template Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Retail Print Template Setup action';
                    }
                    action("Report Selection Retail")
                    {
                        Caption = 'Report Selection Retail';
                        Image = Print;
                        RunObject = Page "NPR Report Selection: Retail";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Report Selection Retail action';
                    }
                    action("Report Selection Contract")
                    {
                        Caption = 'Report Selection Contract';
                        Image = Print;
                        RunObject = Page "NPR Report Selection: Contract";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Report Selection Contract action';
                    }
                }
                group(EFTIntegration)
                {
                    Caption = 'EFT Integration';
                    Image = Components;
                    action("Integration Types")
                    {
                        Caption = 'Integration Types';
                        Image = Setup;
                        RunObject = Page "NPR EFT Integration Types";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Integration Types action';
                    }
                }
                group(Pepper)
                {
                    Caption = 'Pepper';
                    Image = Administration;
                    action("Transaction Types")
                    {
                        Caption = 'Transaction Types';
                        Image = Setup;
                        RunObject = Page "NPR Pepper EFT Trans. Types";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Transaction Types action';
                    }
                    action("Transaction Subtypes")
                    {
                        Caption = 'Transaction Subtypes';
                        Image = Setup;
                        RunObject = Page "NPR Pepper EFT Trx Subtype";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Transaction Subtypes action';
                    }
                    action("Result Codes")
                    {
                        Caption = 'Result Codes';
                        Image = Setup;
                        RunObject = Page "NPR Pepper EFT Result Codes";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Result Codes action';
                    }
                    action("Terminal Types")
                    {
                        Caption = 'Terminal Types';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Terminal Types";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Terminal Types action';
                    }
                    action(Terminals)
                    {
                        Caption = 'Terminals';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Terminal List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Terminals action';
                    }
                    action(Versions)
                    {
                        Caption = 'Versions';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Version List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Versions action';
                    }
                    action(Instances)
                    {
                        Caption = 'Instances';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Instances";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Instances action';
                    }
                    action(Configurations)
                    {
                        Caption = 'Configurations';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Config. List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Configurations action';
                    }
                    action("Card Types")
                    {
                        Caption = 'Card Types';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Card Types";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Card Types action';
                    }
                    action("Card Type Group")
                    {
                        Caption = 'Card Type Group';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Card Type Group";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Card Type Group action';
                    }
                }
                group(CleanCash)
                {
                    Caption = 'CleanCash';
                    Image = PayrollStatistics;
                    action("Setup List")
                    {
                        Caption = 'Setup List';
                        Image = Setup;
                        RunObject = Page "NPR CleanCash Setup List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup List action';
                    }
                    action("Audit Roll List")
                    {
                        Caption = 'Audit Roll List';
                        Image = List;
                        RunObject = Page "NPR CleanCash Audit Roll List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Audit Roll List action';
                    }
                    action("Register List")
                    {
                        Caption = 'Register List';
                        Image = Setup;
                        RunObject = Page "NPR CleanCash Register List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Register List action';
                    }
                    action("Error List")
                    {
                        Caption = 'Error List';
                        Image = List;
                        RunObject = Page "NPR CleanCash Error List";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Error List action';
                    }
                }
            }
            group(ThirdPartyInterfaceSection)
            {
                Caption = 'Third Party Interface';
                Image = Components;
                group(Pacsoft)
                {
                    Caption = 'Pacsoft';
                    Image = Delivery;
                    separator(Separator6014437)
                    {
                        Caption = 'Lists';
                    }
                    action("Pacsoft Package Codes")
                    {
                        Caption = 'Pacsoft Package Codes';
                        Image = List;
                        RunObject = Page "NPR Pacsoft Package Codes";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Pacsoft Package Codes action';
                    }
                    action("Pacsoft Shipment Document Services")
                    {
                        Caption = 'Pacsoft Shipment Document Services';
                        Image = List;
                        RunObject = Page "NPR Pacsoft Shipm. Doc. Serv.";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Pacsoft Shipment Document Services action';
                    }
                    separator(Documents)
                    {
                        Caption = 'Documents';
                    }
                    action("Pacsoft Shipment Documents")
                    {
                        Caption = 'Pacsoft Shipment Documents';
                        Image = List;
                        RunObject = Page "NPR Pacsoft Shipment Documents";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Pacsoft Shipment Documents action';
                    }
                    separator(Separator6014434)
                    {
                        Caption = 'Administration';
                    }
                    action("Pacsoft Setup")
                    {
                        Caption = 'Pacsoft Setup';
                        Image = Setup;
                        RunObject = Page "NPR Pacsoft Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Pacsoft Setup action';
                    }
                }
                group(Packages)
                {
                    Caption = 'Packages';
                    Image = WorkCenter;
                    action("Package Module Admin")
                    {
                        Caption = 'Package Module Admin';
                        Image = List;
                        RunObject = Page "NPR Package Module Admin";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Package Module Admin action';
                    }
                }
                group(DocExchange)
                {
                    Caption = 'Doc. Exchange';
                    Image = ExportElectronicDocument;
                    action(Action6014427)
                    {
                        Caption = 'Setup';
                        Image = Setup;
                        RunObject = Page "NPR Doc. Exch. Setup";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Setup action';
                    }
                    action(Paths)
                    {
                        Caption = 'Paths';
                        Image = List;
                        RunObject = Page "NPR Doc. Exchange Paths";
                        ApplicationArea = All;
                        ToolTip = 'Executes the Paths action';
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        //-NPR5.31 [263473]
        ActiveSession.Get(ServiceInstanceId, SessionId);
        //+NPR5.31 [263473]
        //-NPR5.38 [294723]
        if not InventorySetup.Get then
            InventorySetup.Init;
        PostToGLAfterItemPostingEditable := (not InventorySetup."Automatic Cost Posting");
        AdjCostAfterItemPostingEditable := (InventorySetup."Automatic Cost Adjustment" < InventorySetup."Automatic Cost Adjustment"::Day);
        //+NPR5.38 [294723]
    end;

    var
        ActiveSession: Record "Active Session";
        InventorySetup: Record "Inventory Setup";
        [InDataSet]
        PostToGLAfterItemPostingEditable: Boolean;
        [InDataSet]
        AdjCostAfterItemPostingEditable: Boolean;
}

