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
                }
                field("Last Data Model Build Upgrade"; "Last Data Model Build Upgrade")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Last Data Model Build User ID"; "Last Data Model Build User ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Prev. Data Model Build"; "Prev. Data Model Build")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Advanced POS Entries Activated"; "Advanced POS Entries Activated")
                {
                    ApplicationArea = All;
                }
                field("Advanced Posting Activated"; "Advanced Posting Activated")
                {
                    ApplicationArea = All;
                }
                field("Default POS Posting Profile"; "Default POS Posting Profile")
                {
                    ApplicationArea = All;
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
                        }
                        field("ActiveSession.""Database Name"""; ActiveSession."Database Name")
                        {
                            ApplicationArea = All;
                            Caption = 'Current';
                            Editable = false;
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
                        }
                        field(CURRENTCOMPANY; CurrentCompany)
                        {
                            ApplicationArea = All;
                            Caption = 'Current';
                            Editable = false;
                            ShowCaption = false;
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
                        }
                        field(TENANTID; TenantId)
                        {
                            ApplicationArea = All;
                            Caption = 'Current';
                            Editable = false;
                            ShowCaption = false;
                        }
                    }
                }
                group(Settings)
                {
                    Caption = 'Settings';
                    field("Environment Type"; "Environment Type")
                    {
                        ApplicationArea = All;
                    }
                    field("Environment Verified"; "Environment Verified")
                    {
                        ApplicationArea = All;
                    }
                    field("Environment Template"; "Environment Template")
                    {
                        ApplicationArea = All;
                        Importance = Additional;
                    }
                    field("Enable Client Diagnostics"; "Enable Client Diagnostics")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Legal)
            {
                field("Standard Conditions"; "Standard Conditions")
                {
                    ApplicationArea = All;
                }
                field(Privacy; Privacy)
                {
                    ApplicationArea = All;
                }
                field("License Agreement"; "License Agreement")
                {
                    ApplicationArea = All;
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
                    }
                    action("Default Views")
                    {
                        Caption = 'Default Views';
                        Image = View;
                        RunObject = Page "NPR POS Default Views";
                        ApplicationArea = All;
                    }
                    action("Actions")
                    {
                        Caption = 'Actions';
                        Image = "Action";
                        RunObject = Page "NPR POS Actions";
                        ApplicationArea = All;
                    }
                    action(Action6014556)
                    {
                        Caption = 'Setup';
                        Image = SetupPayment;
                        RunObject = Page "NPR POS Setup";
                        ApplicationArea = All;
                    }
                    action("View List")
                    {
                        Caption = 'View List';
                        Image = ViewDocumentLine;
                        RunObject = Page "NPR POS View List";
                        ApplicationArea = All;
                    }
                    action("Menu Filter")
                    {
                        Caption = 'Menu Filter';
                        Image = "Filter";
                        RunObject = Page "NPR POS Menu Filter";
                        ApplicationArea = All;
                    }
                    action("POS Sales Workflows")
                    {
                        Caption = 'POS Sales Workflows';
                        Image = Allocate;
                        RunObject = Page "NPR POS Sales Workflows";
                        ApplicationArea = All;
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
                    }
                    action("Ean Box Setups")
                    {
                        Caption = 'Ean Box Setups';
                        Image = List;
                        RunObject = Page "NPR Ean Box Setups";
                        ApplicationArea = All;
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
                    }
                    action("POS Units")
                    {
                        Caption = 'POS Units';
                        Image = MiniForm;
                        RunObject = Page "NPR POS Unit List";
                        ApplicationArea = All;
                    }
                    action("POS Payment Bins")
                    {
                        Caption = 'POS Payment Bins';
                        Image = Bin;
                        RunObject = Page "NPR POS Payment Bins";
                        ApplicationArea = All;
                    }
                    action("POS Posting Setup")
                    {
                        Caption = 'POS Posting Setup';
                        Image = GeneralPostingSetup;
                        RunObject = Page "NPR POS Posting Setup";
                        ApplicationArea = All;
                    }
                    action("POS Payment Method")
                    {
                        Caption = 'POS Payment Method';
                        Image = SetupPayment;
                        RunObject = Page "NPR POS Payment Method List";
                        ApplicationArea = All;
                    }
                    action("Unit Identity")
                    {
                        Caption = 'Unit Identity';
                        Image = UnitConversions;
                        RunObject = Page "NPR POS Unit Identity List";
                        ApplicationArea = All;
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
                    }
                    action("POS Entries")
                    {
                        Caption = 'POS Entries';
                        Image = LedgerEntries;
                        RunObject = Page "NPR POS Entries";
                        ApplicationArea = All;
                    }
                    action("POS Entries (Detailed)")
                    {
                        Caption = 'POS Entries (Detailed)';
                        Image = EntriesList;
                        RunObject = Page "NPR POS Entry List";
                        ApplicationArea = All;
                    }
                    action("POS Posting Log")
                    {
                        Caption = 'POS Posting Log';
                        Image = Log;
                        RunObject = Page "NPR POS Posting Log";
                        ApplicationArea = All;
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
                    }
                    action("POS Stargate Packages")
                    {
                        Caption = 'POS Stargate Packages';
                        Image = MachineCenter;
                        RunObject = Page "NPR POS Stargate Packages";
                        ApplicationArea = All;
                    }
                    action("Dependency Management Setup")
                    {
                        Caption = 'Dependency Management Setup';
                        Image = Setup;
                        RunObject = Page "NPR Dependency Mgt. Setup";
                        ApplicationArea = All;
                    }
                    action("RFID Setup")
                    {
                        Caption = 'RFID Setup';
                        Image = Setup;
                        RunObject = Page "NPR RFID Setup";
                        ApplicationArea = All;
                    }
                    action("MCS API Setup")
                    {
                        Caption = 'MCS API Setup';
                        Image = Setup;
                        RunObject = Page "NPR MCS API Setup";
                        ApplicationArea = All;
                    }
                    action("Lookup Templates")
                    {
                        Caption = 'Lookup Templates';
                        Image = List;
                        RunObject = Page "NPR Lookup Templates";
                        ApplicationArea = All;
                    }
                }
                action("Client Diagnostics")
                {
                    Caption = 'Client Diagnostics';
                    Image = AnalysisView;
                    RunObject = Page "NPR Client Diagnostics";
                    ApplicationArea = All;
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
                    }
                    action("Variety Setup")
                    {
                        Caption = 'Variety Setup';
                        Image = List;
                        RunObject = Page "NPR Variety Setup";
                        ApplicationArea = All;
                    }
                    action("Variety Fields Setup")
                    {
                        Caption = 'Variety Fields Setup';
                        Image = List;
                        RunObject = Page "NPR Variety Fields Setup";
                        ApplicationArea = All;
                    }
                    action("Variety Group")
                    {
                        Caption = 'Variety Group';
                        Image = List;
                        RunObject = Page "NPR Variety Group";
                        ApplicationArea = All;
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
                    }
                    action("E-mail Setup")
                    {
                        Caption = 'E-mail Setup';
                        Image = List;
                        RunObject = Page "NPR E-mail Setup";
                        ApplicationArea = All;
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
                    }
                    action("Table Import")
                    {
                        Caption = 'Table Import';
                        Image = List;
                        RunObject = Page "NPR Table Import Wizard";
                        ApplicationArea = All;
                    }
                    action("Object List")
                    {
                        Caption = 'Object List';
                        Image = List;
                        RunObject = Page "NPR Object List";
                        ApplicationArea = All;
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
                    }
                    action("Hospitality Setup")
                    {
                        Caption = 'Hospitality Setup';
                        Image = List;
                        RunObject = Page "NPR NPRE Restaurant Setup";
                        ApplicationArea = All;
                    }
                    action("Seating Locations")
                    {
                        Caption = 'Seating Locations';
                        Image = List;
                        RunObject = Page "NPR NPRE Seating Location";
                        ApplicationArea = All;
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
                    }
                    action("Coupon Types")
                    {
                        Caption = 'Coupon Types';
                        Image = List;
                        RunObject = Page "NPR NpDc Coupon Types";
                        ApplicationArea = All;
                    }
                    action("Posted Coupons")
                    {
                        Caption = 'Posted Coupons';
                        Image = List;
                        RunObject = Page "NPR NpDc Arch. Coupons";
                        ApplicationArea = All;
                    }
                    action("Coupon Setup")
                    {
                        Caption = 'Coupon Setup';
                        Image = List;
                        RunObject = Page "NPR NpDc Coupon Setup";
                        ApplicationArea = All;
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
                    }
                    action("Voucher Types")
                    {
                        Caption = 'Voucher Types';
                        Image = List;
                        RunObject = Page "NPR NpRv Voucher Types";
                        ApplicationArea = All;
                    }
                    action("Posted Vouchers")
                    {
                        Caption = 'Posted Vouchers';
                        Image = List;
                        RunObject = Page "NPR NpRv Arch. Vouchers";
                        ApplicationArea = All;
                    }
                    action("Voucher Setup")
                    {
                        Caption = 'Voucher Setup';
                        Image = List;
                        RunObject = Page "NPR NpRv Global Voucher Setup";
                        ApplicationArea = All;
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
                    }
                    action("Spire Barcode")
                    {
                        Caption = 'Spire Barcode';
                        Image = List;
                        RunObject = Page "NPR AF Test Services";
                        ApplicationArea = All;
                    }
                    action(Notifications)
                    {
                        Caption = 'Notifications';
                        Image = List;
                        RunObject = Page "NPR AF Notification Hub List";
                        ApplicationArea = All;
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
                    }
                    action("Tax Jurisdictions")
                    {
                        Caption = 'Tax Jurisdictions';
                        Image = List;
                        RunObject = Page "Tax Jurisdictions";
                        ApplicationArea = All;
                    }
                    action("Tax Areas")
                    {
                        Caption = 'Tax Areas';
                        Image = List;
                        RunObject = Page "Tax Area List";
                        ApplicationArea = All;
                    }
                    action("Tax Details")
                    {
                        Caption = 'Tax Details';
                        Image = List;
                        RunObject = Page "Tax Details";
                        ApplicationArea = All;
                    }
                    action("Copy Tax Setup")
                    {
                        Caption = 'Copy Tax Setup';
                        Image = List;
                        RunObject = Page "Copy Tax Setup";
                        ApplicationArea = All;
                    }
                }
                action("POS Info list")
                {
                    Caption = 'POS Info list';
                    Image = Planning;
                    RunObject = Page "NPR POS Info List";
                    ApplicationArea = All;
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
                    }
                    action(List)
                    {
                        Caption = 'List';
                        Image = List;
                        RunObject = Page "NPR Nc Endpoints";
                        ApplicationArea = All;
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
                    }
                    action(Collections)
                    {
                        Caption = 'Collections';
                        Image = List;
                        RunObject = Page "NPR Nc Collection List";
                        ApplicationArea = All;
                    }
                    action("Collection Lines")
                    {
                        Caption = 'Collection Lines';
                        Image = List;
                        RunObject = Page "NPR Nc Collection Lines";
                        ApplicationArea = All;
                    }
                    action("Create Outgoing Collector Req.")
                    {
                        Caption = 'Create Outgoing Collector Req.';
                        Image = List;
                        RunObject = Page "NPR Nc Coll. Create Outg. Req.";
                        ApplicationArea = All;
                    }
                    action("Collector Request Lines")
                    {
                        Caption = 'Collector Request Lines';
                        Image = List;
                        RunObject = Page "NPR Nc Collector Req. Lines";
                        ApplicationArea = All;
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
                    }
                    action("Task Queue")
                    {
                        Caption = 'Task Queue';
                        Image = List;
                        RunObject = Page "NPR Task Queue";
                        ApplicationArea = All;
                    }
                    action("Task Log")
                    {
                        Caption = 'Task Log';
                        Image = List;
                        RunObject = Page "NPR Task Log (Task)";
                        ApplicationArea = All;
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
                    }
                    action("Data Log Subscribers")
                    {
                        Caption = 'Data Log Subscribers';
                        Image = List;
                        RunObject = Page "NPR Data Log Subscribers";
                        ApplicationArea = All;
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
                    }
                    action("Import List")
                    {
                        Caption = 'Import List';
                        Image = Task;
                        RunObject = Page "NPR Nc Import List";
                        ApplicationArea = All;
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
                    }
                    action("Task Processors")
                    {
                        Caption = 'Task Processors';
                        Image = Setup;
                        RunObject = Page "NPR Nc Task Proces. List";
                        ApplicationArea = All;
                    }
                    action("Task Setup")
                    {
                        Caption = 'Task Setup';
                        Image = Setup;
                        RunObject = Page "NPR Nc Task Setup";
                        ApplicationArea = All;
                    }
                    action("Import Types")
                    {
                        Caption = 'Import Types';
                        Image = Setup;
                        RunObject = Page "NPR Nc Import Types";
                        ApplicationArea = All;
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
                }
                action("Scanner Setups")
                {
                    Caption = 'Scanner Setups';
                    Image = BarCode;
                    RunObject = Page "NPR Scanner - List";
                    ApplicationArea = All;
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
                    }
                    action("Retail Print Template List")
                    {
                        Caption = 'Retail Print Template List';
                        Image = Setup;
                        RunObject = Page "NPR RP Template List";
                        ApplicationArea = All;
                    }
                    action("Object Output Selection")
                    {
                        Caption = 'Object Output Selection';
                        Image = Setup;
                        RunObject = Page "NPR Object Output Selection";
                        ApplicationArea = All;
                    }
                    action("Retail Logo Setup")
                    {
                        Caption = 'Retail Logo Setup';
                        Image = Setup;
                        RunObject = Page "NPR Retail Logo Setup";
                        ApplicationArea = All;
                    }
                    action("Google Cloud Print Setup")
                    {
                        Caption = 'Google Cloud Print Setup';
                        Image = Setup;
                        RunObject = Page "NPR GCP Setup";
                        ApplicationArea = All;
                    }
                    action("Retail Print Template Setup")
                    {
                        Caption = 'Retail Print Template Setup';
                        Image = Setup;
                        RunObject = Page "NPR RP Template Setup";
                        ApplicationArea = All;
                    }
                    action("Report Selection Retail")
                    {
                        Caption = 'Report Selection Retail';
                        Image = Print;
                        RunObject = Page "NPR Report Selection: Retail";
                        ApplicationArea = All;
                    }
                    action("Report Selection Contract")
                    {
                        Caption = 'Report Selection Contract';
                        Image = Print;
                        RunObject = Page "NPR Report Selection: Contract";
                        ApplicationArea = All;
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
                    }
                    action("Transaction Subtypes")
                    {
                        Caption = 'Transaction Subtypes';
                        Image = Setup;
                        RunObject = Page "NPR Pepper EFT Trx Subtype";
                        ApplicationArea = All;
                    }
                    action("Result Codes")
                    {
                        Caption = 'Result Codes';
                        Image = Setup;
                        RunObject = Page "NPR Pepper EFT Result Codes";
                        ApplicationArea = All;
                    }
                    action("Terminal Types")
                    {
                        Caption = 'Terminal Types';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Terminal Types";
                        ApplicationArea = All;
                    }
                    action(Terminals)
                    {
                        Caption = 'Terminals';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Terminal List";
                        ApplicationArea = All;
                    }
                    action(Versions)
                    {
                        Caption = 'Versions';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Version List";
                        ApplicationArea = All;
                    }
                    action(Instances)
                    {
                        Caption = 'Instances';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Instances";
                        ApplicationArea = All;
                    }
                    action(Configurations)
                    {
                        Caption = 'Configurations';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Config. List";
                        ApplicationArea = All;
                    }
                    action("Card Types")
                    {
                        Caption = 'Card Types';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Card Types";
                        ApplicationArea = All;
                    }
                    action("Card Type Group")
                    {
                        Caption = 'Card Type Group';
                        Image = Setup;
                        RunObject = Page "NPR Pepper Card Type Group";
                        ApplicationArea = All;
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
                    }
                    action("Audit Roll List")
                    {
                        Caption = 'Audit Roll List';
                        Image = List;
                        RunObject = Page "NPR CleanCash Audit Roll List";
                        ApplicationArea = All;
                    }
                    action("Register List")
                    {
                        Caption = 'Register List';
                        Image = Setup;
                        RunObject = Page "NPR CleanCash Register List";
                        ApplicationArea = All;
                    }
                    action("Error List")
                    {
                        Caption = 'Error List';
                        Image = List;
                        RunObject = Page "NPR CleanCash Error List";
                        ApplicationArea = All;
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
                    }
                    action("Pacsoft Shipment Document Services")
                    {
                        Caption = 'Pacsoft Shipment Document Services';
                        Image = List;
                        RunObject = Page "NPR Pacsoft Shipm. Doc. Serv.";
                        ApplicationArea = All;
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
                    }
                    action(Paths)
                    {
                        Caption = 'Paths';
                        Image = List;
                        RunObject = Page "NPR Doc. Exchange Paths";
                        ApplicationArea = All;
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

