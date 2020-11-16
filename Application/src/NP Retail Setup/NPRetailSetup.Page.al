page 6150613 "NPR NP Retail Setup"
{
    // NPR5.29/AP  /20170126  CASE 261728 Recreated ENU-captions
    // NPR5.31/MMV /20170404  CASE 263473 Added environment fields.
    // NPR5.32/AP  /20170501  CASE 274285 Possible to re-run Build Steps. Better visibilty for log entries.
    // NPR5.32/AP  /20170518  CASE 262628 Added field "Poseidon POS Entries Activated"
    // NPR5.34/KENU/20170623  CASE 281051 Added Navigate button and added retails setups, added Configuration menu
    // NPR5.34/KENU/20170623  CASE 282010 Added Menu Groups to Navigate
    // NPR5.34/KENU/20170630  CASE 282645 Added Variety Group
    // NPR5.34/KENU/20170630  CASE 282654 Added E-mail Group
    // NPR5.34/KENU/20170630  CASE 282653 Added Import/Export Group
    // NPR5.34/KENU/20170630  CASE 282651 Added Doc. Exchange Group
    // NPR5.34/KENU/20170630  CASE 282650 Added Pacsoft Group
    // NPR5.34/KENU/20170630  CASE 282643 Added Page Manager Group
    // NPR5.34/KENU/20170630  CASE 282649 Added NaviConnect Group
    // NPR5.34/KENU/20170707  CASE 283393 Added POS Info List under POS
    // NPR5.34/KENU/20170707  CASE 283391 Added Hospitality sub menu
    // NPR5.36/MHA /20170803  CASE 285800 Added ActionGroup: DiscountCoupon
    // NPR5.36/KENU/20170807  CASE 285965 Added Page "NPH Flow Status" under "Hospitality"
    // NPR5.36/KENU/20170810  CASE 286363 Added "POS List" drop down
    // NPR5.36/BR  /20170907  CASE 277103 Added Group "Posting", fields "Default POS Entry No. Series", "Max. POS Posting Diff. (LCY)" and "POS Posting Diff. Account"
    // NPR5.36/CLVA/20170915  CASE 283587 Added "Azure Functions" drop down
    // NPR5.36/BR  /20170918  CASE 277103 Added field Poseidon Posting Activated
    // NPR5.36/CLVA/20170919  CASE 283587 Added "Trigger Permission Set Mgt." to the Configuration drop down
    // NPR5.37/VB  /20171002  CASE 292193 Added "POS Stargate Packages" action to the Configuration drop down
    // NPR5.37/BR  /20170910  CASE 292364 Changed "Poseidon" names and Captions to Advanced Posting
    // NPR5.38/TS  /20171122  CASE 295501 Added Action Magento Setup
    // NPR5.38/BR  /20171214  CASE 299888 Changed ENU Caption from POS Ledger Register to POS Period Register No.
    // NPR5.38/BR  /20180105  CASE 294723 Added Fields Automatic Item Posting, Automatic POS Posting, Automatic Posting Method, "Adj. Cost after Item Posting", "Post to G/L after Item Posting"
    // NPR5.38/TS  /20180105  CASE 300893 Action Containers cannot have caption
    // NPR5.38/TS  /20180111  CASE 302005 Added Action Hotkeys
    // NPR5.38/TS  /20180123  CASE 299999 Added Action Dynamic Modules
    // NPR5.38/CLVA/20180124  CASE 293179 Added field Enable Client Diagnostics
    // NPR5.38.01 /JKL /20180205  CASE 289017 Added Group Distribution And replenishmen + action retail replenishMent setup
    // NPR5.39/MHA /20180205  CASE 302779 Added Action POS Sales Workflows
    // NPR5.39/BR  /20180215  CASE 305016 Added field Fiscal No. Series
    // NPR5.40/MMV /20180309  CASE 307817 Removed action for opening rp template setup.
    // NPR5.40/MMV /20180316  CASE 308457 New fiscal no. fields
    // NPR5.40/TS  /20180227  CASE 306550 Added Report Selection under Print.
    // NPR5.40/TS  /20180306  CASE 292365 Retire Action and Regroup
    // NPR5.40/MHA /20180328  CASE 308907 Added Action ClientDiagnostics
    // NPR5.41/THRO/20180425  CASE 311567 Added action NPR Version history
    // NPR5.42/CLVA/20180329  CASE 306407 Added button "Capture Service" to the Accessories group
    // NPR5.42/TSA /20180502  CASE 312104 Added field "Allow Zero Amount Sales"
    // NPR5.45/MHA /20180803  CASE 323705 Added fields 300, 305, 310 to enable overload of Item Price functionality
    // NPR5.46/MHA /20180911  CASE 327708 Updated caption on Ean Box Event actions
    // NPR5.46/TS  /20180918  CASE 327709 Added Vouchers
    // NPR5.47/BHR /20181010  CASE 331858 Move Pos store action
    // NPR5.47/BHR /20181011  CASE 331857 Remove "NPR POS" action group
    // NPR5.48/LS  /20181121  CASE 334335 Added Action "UpgradeBalV3Setup" when upgrading to Balancing V3
    // NPR5.48/MMV /20181206  CASE 327107 Added action RFIDSetup
    // NPR5.48/MMV /20181026  CASE 318028 French certification
    // NPR5.50/MHA /20190422  CASE 337539 Added field 400 "Global Sales Setup"
    // NPR5.50/MMV /20190521  CASE 355848 Added action LastErrorCallstack
    // NPR5.51/CLVA/20190710  CASE 355871 Added Action Raptor
    // NPR5.51/MHA /20190816  CASE 365332 Removed Page Manager actions
    // NPR5.52/ALPO/20190923  CASE 365326 The following fields moved to POS Posting Profiles and deleted from this table/page:
    //                                       Default POS Entry No. Series, Max. POS Posting Diff. (LCY), POS Posting Diff. AccountCode, Automatic Item Posting,
    //                                       Automatic POS Posting, Automatic Posting Method, Adj. Cost after Item Posting, Post to G/L after Item Posting
    //                                    New field added: "Default POS Posting Profile"
    // NPR5.52/BHR /20190925  CASE 368143 Moved the Action RFID setup to "Navigate and other configuration"
    // NPR5.52/BHR /20191002  CASE 370447 remove Actions Step 1 to step 5 and rename action 'Upgrade to Balancing V3 Setups' to 'Upgrade Audit Roll to POS Entry '
    // NPR5.52/MHA /20191016  CASE 371388 Field 400 "Global POS Sales Setup" moved from Np Retail Setup to POS Unit
    // NPR5.55/BHR /20200408  CASE 399443 Removed Fields300Item Price Codeunit ID,305Item Price Codeunit ,310Item Price Function
    // NPR5.55/YAHA/20200227  CASE 393297 Moved transaction types,Transaction subtype & Result code into pepper group
    // NPR5.55/CLVA/20200804  CASE 416793 Added action "MCS API Setup"

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
                action("Capture Service")
                {
                    Caption = 'Capture Service';
                    Image = BarCode;
                    RunObject = Page "NPR CS Setup";
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

