page 6014557 "NPR POS: SalesPerson R.Center"
{
    // NC1.17/MH/20150423        CASE 212263 Created NaviConnect Role Center
    // NC1.17/BHR/20150428       CASE 212069 Removed "retail Document Activities
    // NC1.20/BHR/20150925       CASE 223709 Added part 'NaviConnect Top 10 SalesPerson'
    // NPR5.22/TJ/20160415       CASE 233762 Added part RSS Reader Activities
    // NPR5.23/TS/20160509       CASE 240912  Removed Naviconnect Activities
    // NPR5.23.03/SANK/20161517  CASE 234035 Menu Reorganised. Sales Activities Removed
    // NPR5.23.03/MHA/20160726   CASE 242557 Magento references updated according to MAG2.00
    // NPR5.27/JLK /20160908  CASE 251366 Removed POS Activity button
    // NPR5.27/JLK /20160915  CASE 249468 Added Sales Orders, Purchase Orders, Customer Repair Lists, Transfer Orders Activity buttons
    // NPR5.29/JLK /20161223  CASE 249468 Corrected Sales Orders and Purchase Orders to 9305 & 9307
    // NPR5.29/BHR /20170104  CASE 262439 Hide RSS feed, Add New Chart "Retail Sales Chart by Shop"
    // NPR5.31/TS  /20170328  CASE 270740 My Reports added
    // NPR5.32/MHA /20170515  CASE 276241 Charts group moved into first column to reduce total column qty. from 3 to 2
    // NPR5.33/KENU/20170511  CASE 275923 Modified the navigation pane
    // NPR5.33/LS  /20170605  CASE 279275 Set Visible = False for Retail Top 10 Customers
    // NPR5.33/MHA /20170616  CASE 281047 ActionGroup added: Magento
    // NPR5.33/TS  /20170616  CASE 281061 Added Transfer Order in New
    // NPR5.33/TS  /20170616  CASE 280913 Removed Fixed Assets,Human Resources and Marketing
    // NPR5.33/TS  /20170616  CASE 281060 Removed Items described in attached images.
    // NPR5.33/TS  /20170616  CASE 281137 Added Sales Return Order in New
    // NPR5.33/TS  /20170616  CASE 281135 Removed Worksheets,(281133,281132) Removed Item list,SalesOrders,SalesTicketSatistics,Resources
    // NPR5.33/TS  /20170616  CASE 281134 Moved Contact and Customer List to SalesMenu
    // NPR5.34/TS  /20170620  CASE 281207 Removed Actions
    // NPR5.34/TS  /20170620  CASE 281207 Added Company Information
    // NPR5.34/KENU/20170623  CASE 281805 Added "TM Ticket Access Entry List" to Ticket Menu
    // NPR5.34/KENU/20170623  CASE 281062 Added Menu Group POS and added Lists from Departments/Retail/Sale
    // NPR5.34/KENU/20170623  CASE 281814 Added Menu Group Item & Prices and added Lists: 6014511, 6014427, 6014455, 6060041
    // NPR5.34/KENU/20170623  CASE 281909 Ordered Menu Home Items
    // NPR5.34/KENU/20170623  CASE 281933 12 Removed reports
    // NPR5.34/KENU/20170623  CASE 282001 Removed 2 Page List
    // NPR5.34/KENU/20170623  CASE 282002 Removed Retail - Manager Role Center
    // NPR5.34/KENU/20170623  CASE 281997 Added Audit Roll to POS Menu
    // NPR5.34/KENU/20170623  CASE 282006 Added Item List to Home Items
    // NPR5.34/KENU/20170623  CASE 282016 Removed Customer Analysis report from Retail
    // NPR5.34/KENU/20170623  CASE 282014 Added Event List to Ticket menu
    // NPR5.34/KENU/20170627  CASE 282111 Moved Customer and Vendor to General Group
    // NPR5.34/KENU/20170627  CASE 282001 New section called Retail
    // NPR5.34/KENU/20170630  CASE 282644 Added Stock-Take Configurations(6014665) to "Item & Prices"
    // NPR5.34/KENU/20170703  CASE 282782 Added report "Inventory by Date"
    // NPR5.34/KENU/20170704  CASE 282977 Moved "My Reports" to 2nd Column
    // NPR5.34/KENU/20170704  CASE 282959 Conforming to NPR RC Comments, added Home tabs: Sales, Item, Vendor
    // NPR5.35/JDH /20170831  CASE        Replaced Item List with Retail Item List
    // NPR5.36/MHA /20170803  CASE 285800 Added Discount Coupon Actions under ActionGroup POS: Coupons, Coupon Types
    // NPR5.36/KENU/20170810  CASE 286465 Added "NP Retail Setup" page link to "General" section
    // NPR5.36/KENU/20170828  CASE 288295 Added "Company Information" page link to "General" section
    // NPR5.37/TS  /20171016  CASE 293530 Removed actions
    // NPR5.37/JLK /20171025  CASE 294057 Changed property page run for Sales Order List, Sales Return Order List, Purchase Order List and Purchase Return Order List
    // NPR5.38/TS  /20171108  CASE 295500 Removed actions
    // NPR5.38/BR  /20180118  CASE 302790 Added POS Entry List
    // NPR5.38.06/THRO/20180219  CASE 305188 Added Power BI Spinner part for NAV2017 + removed subgroups
    // NPR5.40/TS  /20180320  CASE 307510 Added Page Retail Journal List
    // NPR5.42/JLK /20180523  CASE 315306 Corrected ENU Caption to ENU=Retail Salesperson
    // NPR5.55/YAHA/20200715  CASE 412525 Moved Customer list above Salesperson/purchasers action

    Caption = 'Retail Salesperson';
    PageType = RoleCenter;
    UsageCategory = Administration;

    layout
    {
        area(rolecenter)
        {
            group(Control6150641)
            {
                ShowCaption = false;
                part(Control6150638; "NPR Discount Activities")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                part(Control6150616; "NPR Retail Activities")
                {
                    ApplicationArea = All;
                }
                part(Control6150617; "NPR Retail Sales Chart")
                {
                    ApplicationArea = All;
                }
                part(Control6014405; "NPR RSS Reader Activ.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                part(Control6014403; "NPR Retail Sales Chart by Shop")
                {
                    ApplicationArea = All;
                }
            }
            group(Control6151405)
            {
                ShowCaption = false;
                part(Control1; "Power BI Report Spinner Part")
                {
                    ApplicationArea = Basic, Suite;
                }
                part(Control6150615; "NPR Retail Top 10 Customers")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                part(Control6150614; "NPR Retail 10 Items by Qty.")
                {
                    ApplicationArea = All;
                }
                part(Control6150613; "NPR Retail Top 10 S.person")
                {
                    ApplicationArea = All;
                }
                part("<Retail Top 10 Salesperson>"; "NPR My Reports")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(embedding)
        {
            action(Customer)
            {
                Caption = 'Customer';
                RunObject = Page "Customer List";
                ApplicationArea = All;
            }
            action(Action6014569)
            {
                Caption = 'Vendor';
                RunObject = Page "Vendor List";
                ApplicationArea = All;
            }
            action("Audit Roll")
            {
                Caption = 'Audit Roll';
                RunObject = Page "NPR Audit Roll";
                ApplicationArea = All;
            }
            action("POS Entry List")
            {
                Caption = 'POS Entry List';
                RunObject = Page "NPR POS Entry List";
                ApplicationArea = All;
            }
            action("Retail Item List")
            {
                Caption = 'Retail Item List';
                RunObject = Page "NPR Retail Item List";
                ApplicationArea = All;
            }
        }
        area(reporting)
        {
            group(ActionGroup6014406)
            {
                Visible = false;
                action("S&tatement")
                {
                    Caption = 'S&tatement';
                    Image = "Report";
                    RunObject = Report Statement;
                    ApplicationArea = All;
                }
                separator(Separator6150667)
                {
                }
                action("Customer - Order Su&mmary")
                {
                    Caption = 'Customer - Order Su&mmary';
                    Image = "Report";
                    RunObject = Report "Customer - Order Summary";
                    ApplicationArea = All;
                }
                action("Customer - T&op 10 List")
                {
                    Caption = 'Customer - T&op 10 List';
                    Image = "Report";
                    RunObject = Report "Customer - Top 10 List";
                    ApplicationArea = All;
                }
                action("Customer/&Item Sales")
                {
                    Caption = 'Customer/&Item Sales';
                    Image = "Report";
                    RunObject = Report "Customer/Item Sales";
                    ApplicationArea = All;
                }
                separator(Separator6150663)
                {
                }
                action("Salesperson - Sales &Statistics")
                {
                    Caption = 'Salesperson - Sales &Statistics';
                    Image = "Report";
                    RunObject = Report "Salesperson - Sales Statistics";
                    ApplicationArea = All;
                }
                action("Price &List")
                {
                    Caption = 'Price &List';
                    Image = "Report";
                    RunObject = Report "Price List";
                    ApplicationArea = All;
                }
                separator(Separator6150660)
                {
                }
                action("Inventory - Sales &Back Orders")
                {
                    Caption = 'Inventory - Sales &Back Orders';
                    Image = "Report";
                    RunObject = Report "Inventory - Sales Back Orders";
                    ApplicationArea = All;
                }
                separator(Separator6150658)
                {
                }
                action("&G/L Trial Balance")
                {
                    Caption = '&G/L Trial Balance';
                    Image = "Report";
                    RunObject = Report "Trial Balance";
                    ApplicationArea = All;
                }
                action("Trial Balance by &Period")
                {
                    Caption = 'Trial Balance by &Period';
                    Image = "Report";
                    RunObject = Report "Trial Balance by Period";
                    ApplicationArea = All;
                }
                action("Closing T&rial Balance")
                {
                    Caption = 'Closing T&rial Balance';
                    Image = "Report";
                    RunObject = Report "Closing Trial Balance";
                    ApplicationArea = All;
                }
                separator(Separator6150654)
                {
                }
                action("Aged Ac&counts Receivable")
                {
                    Caption = 'Aged Ac&counts Receivable';
                    Image = "Report";
                    RunObject = Report "Aged Accounts Receivable";
                    ApplicationArea = All;
                }
                action("Aged Accounts Pa&yable")
                {
                    Caption = 'Aged Accounts Pa&yable';
                    Image = "Report";
                    RunObject = Report "Aged Accounts Payable";
                    ApplicationArea = All;
                }
                action("Reconcile Cust. and &Vend. Accs")
                {
                    Caption = 'Reconcile Cust. and &Vend. Accs';
                    Image = "Report";
                    RunObject = Report "Reconcile Cust. and Vend. Accs";
                    ApplicationArea = All;
                }
                separator(Separator6150650)
                {
                }
                action("VAT Registration No. Chec&k")
                {
                    Caption = 'VAT Registration No. Chec&k';
                    Image = "Report";
                    RunObject = Report "VAT Registration No. Check";
                    ApplicationArea = All;
                }
                action("VAT E&xceptions")
                {
                    Caption = 'VAT E&xceptions';
                    Image = "Report";
                    RunObject = Report "VAT Exceptions";
                    ApplicationArea = All;
                }
                action("V&AT Statement")
                {
                    Caption = 'V&AT Statement';
                    Image = "Report";
                    RunObject = Report "VAT Statement";
                    ApplicationArea = All;
                }
                action("VAT-VIES Declaration Tax A&uth")
                {
                    Caption = 'VAT-VIES Declaration Tax A&uth';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Tax Auth";
                    ApplicationArea = All;
                }
                action("VAT - VIES Declaration &Disk")
                {
                    Caption = 'VAT - VIES Declaration &Disk';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Disk";
                    ApplicationArea = All;
                }
                action("EC Sal&es List")
                {
                    Caption = 'EC Sal&es List';
                    Image = "Report";
                    RunObject = Report "EC Sales List";
                    ApplicationArea = All;
                }
            }
            group(ActionGroup6014408)
            {
                Caption = 'Retail';
                action("Sales Statistics")
                {
                    Caption = 'Sales Statistics';
                    Image = Report2;
                    RunObject = Report "NPR Sales Ticket Stat.";
                    ApplicationArea = All;
                }
                action("Sale Report")
                {
                    Caption = 'Sale Report';
                    Image = Report2;
                    RunObject = Report "NPR Sale Time Report";
                    ApplicationArea = All;
                }
                separator(Separator6014423)
                {
                }
                action("Sales Person Top 20")
                {
                    Caption = 'Sales Person Top 20';
                    Image = Report2;
                    RunObject = Report "NPR Sales Person Top 20";
                    ApplicationArea = All;
                }
                action("Salesperson/Item Group Top")
                {
                    Caption = 'Salesperson/Item Group Top';
                    Image = Report2;
                    RunObject = Report "NPR Salesperson/Item Group Top";
                    ApplicationArea = All;
                }
                separator(Separator6014432)
                {
                }
                action("Item Wise Sales Figures")
                {
                    Caption = 'Item Wise Sales Figures';
                    Image = Report2;
                    RunObject = Report "NPR Item Wise Sales Figures";
                    ApplicationArea = All;
                }
                separator(Separator6014462)
                {
                }
                action("Discount Statistics")
                {
                    Caption = 'Discount Statistics';
                    Image = Report2;
                    RunObject = Report "NPR Discount Statistics";
                    ApplicationArea = All;
                }
            }
            group("Item & Prices")
            {
                Caption = 'Item & Prices';
                action("Item Sales Statistics")
                {
                    Caption = 'Item Sales Statistics';
                    Image = Report2;
                    RunObject = Report "NPR Item Sales Stats/Provider";
                    ApplicationArea = All;
                }
                action("Top 10 List")
                {
                    Caption = 'Top 10 List';
                    Image = Report2;
                    RunObject = Report "Inventory - Top 10 List";
                    ApplicationArea = All;
                }
                action("Low Sales")
                {
                    Caption = 'Low Sales';
                    Image = Report2;
                    RunObject = Report "NPR Items With Low Sales";
                    ApplicationArea = All;
                }
            }
        }
        area(sections)
        {
            group(POS)
            {
                Caption = 'POS';
                Image = Ledger;
                action(Action6014493)
                {
                    Caption = 'Audit Roll';
                    RunObject = Page "NPR Audit Roll";
                    ApplicationArea = All;
                }
                action("Credit Vouchers")
                {
                    Caption = 'Credit Vouchers';
                    RunObject = Page "NPR Credit Voucher List";
                    ApplicationArea = All;
                }
                action("Gift Vouchers")
                {
                    Caption = 'Gift Vouchers';
                    RunObject = Page "NPR Gift Voucher List";
                    ApplicationArea = All;
                }
                action("Exchange Labels")
                {
                    Caption = 'Exchange Labels';
                    RunObject = Page "NPR Exchange Label";
                    ApplicationArea = All;
                }
                action("Tax Free Voucher")
                {
                    Caption = 'Tax Free Voucher';
                    RunObject = Page "NPR Tax Free Voucher";
                    ApplicationArea = All;
                }
                action("Retail Document List")
                {
                    Caption = 'Retail Document List';
                    RunObject = Page "NPR Retail Document List";
                    ApplicationArea = All;
                }
                action("Customer Repairs List")
                {
                    Caption = 'Customer Repairs List';
                    RunObject = Page "NPR Customer Repair List";
                    ApplicationArea = All;
                }
                action("Warranty Catalog List")
                {
                    Caption = 'Warranty Catalog List';
                    RunObject = Page "NPR Warranty Catalog List";
                    ApplicationArea = All;
                }
                action(Coupons)
                {
                    Caption = 'Coupons';
                    RunObject = Page "NPR NpDc Coupons";
                    ApplicationArea = All;
                }
                action("Coupon Types")
                {
                    Caption = 'Coupon Types';
                    RunObject = Page "NPR NpDc Coupon Types";
                    ApplicationArea = All;
                }
            }
            group(ActionGroup6014513)
            {
                Caption = 'Item & Prices';
                Image = ProductDesign;
                action(Action6014418)
                {
                    Caption = 'Retail Item List';
                    RunObject = Page "NPR Retail Item List";
                    ApplicationArea = All;
                }
                action("Item Group Tree")
                {
                    Caption = 'Item Group Tree';
                    RunObject = Page "NPR Item Group Tree";
                    ApplicationArea = All;
                }
                action("Item Worksheets")
                {
                    Caption = 'Item Worksheets';
                    RunObject = Page "NPR Item Worksheets";
                    ApplicationArea = All;
                }
                action("Campaign Discount List")
                {
                    Caption = 'Campaign Discount List';
                    RunObject = Page "NPR Campaign Discount List";
                    ApplicationArea = All;
                }
                action("Mixed Discount List")
                {
                    Caption = 'Mixed Discount List';
                    RunObject = Page "NPR Mixed Discount List";
                    ApplicationArea = All;
                }
                action("Item Journals")
                {
                    Caption = 'Item Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Item),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                }
                action("Physical Inventory Journals")
                {
                    Caption = 'Physical Inventory Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Phys. Inventory"),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                }
                action("Revaluation Journals")
                {
                    Caption = 'Revaluation Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Revaluation),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                }
                action("Retail Journal List")
                {
                    Caption = 'Retail Journal List';
                    Image = ResourceJournal;
                    RunObject = Page "NPR Retail Journal List";
                    ApplicationArea = All;
                }
            }
            group(Magento)
            {
                Caption = 'Magento';
                Image = AdministrationSalesPurchases;
                action("Sales Orders")
                {
                    Caption = 'Sales Orders';
                    RunObject = Page "Sales Order List";
                    ApplicationArea = All;
                }
                action(Items)
                {
                    Caption = 'Items';
                    RunObject = Page "NPR Retail Item List";
                    RunPageView = WHERE("NPR Magento Item" = CONST(true));
                    ApplicationArea = All;
                }
                action("Item Groups")
                {
                    Caption = 'Item Groups';
                    RunObject = Page "NPR Magento Categories";
                    ApplicationArea = All;
                }
                action(Brands)
                {
                    Caption = 'Brands';
                    RunObject = Page "NPR Magento Brands";
                    ApplicationArea = All;
                }
                action("Custom Options")
                {
                    Caption = 'Custom Options';
                    RunObject = Page "NPR Magento Custom Option List";
                    ApplicationArea = All;
                }
                action(Attributes)
                {
                    Caption = 'Attributes';
                    RunObject = Page "NPR Magento Attributes";
                    ApplicationArea = All;
                }
                action("Attribute Sets")
                {
                    Caption = 'Attribute Sets';
                    RunObject = Page "NPR Magento Attribute Sets";
                    ApplicationArea = All;
                }
                action("Payment Lines")
                {
                    Caption = 'Payment Lines';
                    RunObject = Page "NPR Magento Payment Line List";
                    ApplicationArea = All;
                }
                action("Shipment Method Mapping")
                {
                    Caption = 'Shipment Method Mapping';
                    RunObject = Page "NPR Magento Shipment Mapping";
                    ApplicationArea = All;
                }
                action("Payment Method Mapping")
                {
                    Caption = 'Payment Method Mapping';
                    RunObject = Page "NPR Magento Payment Mapping";
                    ApplicationArea = All;
                }

                action("NaviDocs Document List")
                {
                    Caption = 'NaviDocs Document List';
                    RunObject = Page "NPR NaviDocs Document List";
                    ApplicationArea = All;
                }
            }
            group(Member)
            {
                Caption = 'Member';
                Image = HumanResources;
                action(Members)
                {
                    Caption = 'Members';
                    RunObject = Page "NPR MM Members";
                    ApplicationArea = All;
                }
                action(Memberships)
                {
                    Caption = 'Memberships';
                    RunObject = Page "NPR MM Memberships";
                    ApplicationArea = All;
                }
                action("Member Card List")
                {
                    Caption = 'Member Card List';
                    RunObject = Page "NPR MM Member Card List";
                    ApplicationArea = All;
                }
                action("MCS Faces")
                {
                    Caption = 'MCS Faces';
                    RunObject = Page "NPR MCS Faces";
                    ApplicationArea = All;
                }
            }
            group(Ticket)
            {
                Caption = 'Ticket';
                Image = Worksheets;
                action("Ticket List")
                {
                    Caption = 'Ticket List';
                    RunObject = Page "NPR TM Ticket List";
                    ApplicationArea = All;
                }
                action("Ticket Request")
                {
                    Caption = 'Ticket Request';
                    RunObject = Page "NPR TM Ticket Request";
                    ApplicationArea = All;
                }
                action("Ticket Type")
                {
                    Caption = 'Ticket Type';
                    RunObject = Page "NPR TM Ticket Type";
                    ApplicationArea = All;
                }
                action("Ticket BOM")
                {
                    Caption = 'Ticket BOM';
                    RunObject = Page "NPR TM Ticket BOM";
                    ApplicationArea = All;
                }
                action("Ticket Admissions")
                {
                    Caption = 'Ticket Admissions';
                    RunObject = Page "NPR TM Ticket Admissions";
                    ApplicationArea = All;
                }
                action("<Page TM Ticket Access Entry List>")
                {
                    Caption = 'Ticket Access Entry List';
                    RunObject = Page "NPR TM Ticket AccessEntry List";
                    ApplicationArea = All;
                }
                action("Event List")
                {
                    Caption = 'Event List';
                    RunObject = Page "NPR Event List";
                    ApplicationArea = All;
                }
            }
            group(Finance)
            {
                Caption = 'Finance';
                Image = Bank;
                action("Chart of Accounts")
                {
                    Caption = 'Chart of Accounts';
                    RunObject = Page "Chart of Accounts";
                    ApplicationArea = All;
                }
                action("VAT Statements")
                {
                    Caption = 'VAT Statements';
                    RunObject = Page "VAT Statement Names";
                    ApplicationArea = All;
                }
                action("Bank Accounts")
                {
                    Caption = 'Bank Accounts';
                    Image = BankAccount;
                    RunObject = Page "Bank Account List";
                    ApplicationArea = All;
                }
                action(Currencies)
                {
                    Caption = 'Currencies';
                    Image = Currency;
                    RunObject = Page Currencies;
                    ApplicationArea = All;
                }
                action("Accounting Periods")
                {
                    Caption = 'Accounting Periods';
                    Image = AccountingPeriods;
                    RunObject = Page "Accounting Periods";
                    ApplicationArea = All;
                }
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page Dimensions;
                    ApplicationArea = All;
                }
                action("Issued Reminders")
                {
                    Caption = 'Issued Reminders';
                    Image = OrderReminder;
                    RunObject = Page "Issued Reminder List";
                    ApplicationArea = All;
                }
                action("Issued Fin. Charge Memos")
                {
                    Caption = 'Issued Fin. Charge Memos';
                    Image = PostedMemo;
                    RunObject = Page "Issued Fin. Charge Memo List";
                    ApplicationArea = All;
                }
                action("Resource Journals")
                {
                    Caption = 'Resource Journals';
                    RunObject = Page "Resource Jnl. Batches";
                    RunPageView = WHERE(Recurring = CONST(false));
                    ApplicationArea = All;
                }
                action("FA Journals")
                {
                    Caption = 'FA Journals';
                    RunObject = Page "FA Journal Batches";
                    RunPageView = WHERE(Recurring = CONST(false));
                    ApplicationArea = All;
                }
                action("Cash Receipt Journals")
                {
                    Caption = 'Cash Receipt Journals';
                    Image = Journals;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Cash Receipts"),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                }
                action("Payment Journals")
                {
                    Caption = 'Payment Journals';
                    Image = Journals;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Payments),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                }
                action("General Journals")
                {
                    Caption = 'General Journals';
                    Image = Journal;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(General),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                }
                action("Recurring Journals")
                {
                    Caption = 'Recurring Journals';
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(General),
                                        Recurring = CONST(true));
                    ApplicationArea = All;
                }
            }
            group(ActionGroup6014529)
            {
                Caption = 'Sales';
                Image = Sales;
                action("Customers ")
                {
                    Caption = 'Customers';
                    RunObject = Page "Customer List";
                    ApplicationArea = All;
                }
                action("Salespeople/Purchasers")
                {
                    Caption = 'Salespeople/Purchasers';
                    RunObject = Page "Salespersons/Purchasers";
                    ApplicationArea = All;
                }
                action("Contact List ")
                {
                    Caption = 'Contact List';
                    RunObject = Page "Contact List";
                    ApplicationArea = All;
                }
                action(Orders)
                {
                    Caption = 'Orders';
                    RunObject = Page "Sales Order List";
                    ApplicationArea = All;
                }
                action(Invoices)
                {
                    Caption = 'Invoices';
                    RunObject = Page "Sales Invoice List";
                    ApplicationArea = All;
                }
                action("Return Orders")
                {
                    Caption = 'Return Orders';
                    RunObject = Page "Sales Return Order List";
                    ApplicationArea = All;
                }
                action("Credit Memos")
                {
                    Caption = 'Credit Memos';
                    RunObject = Page "Sales Credit Memos";
                    ApplicationArea = All;
                }
                action("Customer Invoice Discount")
                {
                    Caption = 'Customer Invoice Discount';
                    RunObject = Page "Cust. Invoice Discounts";
                    ApplicationArea = All;
                }
                action("Posted Sales Shipments")
                {
                    Caption = 'Posted Sales Shipments';
                    Image = PostedShipment;
                    RunObject = Page "Posted Sales Shipments";
                    ApplicationArea = All;
                }
                action("Posted Sales Invoices")
                {
                    Caption = 'Posted Sales Invoices';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Invoices";
                    ApplicationArea = All;
                }
                action("Posted Sales Return Orders")
                {
                    Caption = 'Posted Sales Return Orders';
                    RunObject = Page "Posted Return Receipts";
                    ApplicationArea = All;
                }
                action("Posted Sales Credit Memos")
                {
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    ApplicationArea = All;
                }
            }
            group(Purchase)
            {
                Caption = 'Purchase';
                Image = Purchasing;
                action("Vendor List")
                {
                    Caption = 'Vendor List';
                    RunObject = Page "Vendor List";
                    ApplicationArea = All;
                }
                action("Purchase Orders")
                {
                    Caption = 'Purchase Orders';
                    RunObject = Page "Purchase Order List";
                    ApplicationArea = All;
                }
                action("Purchase Return Orders")
                {
                    Caption = 'Purchase Return Orders';
                    RunObject = Page "Purchase Return Order List";
                    ApplicationArea = All;
                }
                action("Purchase Invoices")
                {
                    Caption = 'Purchase Invoices';
                    RunObject = Page "Purchase Invoices";
                    ApplicationArea = All;
                }
                action("Purchase Credit Memos")
                {
                    Caption = 'Purchase Credit Memos';
                    RunObject = Page "Purchase Credit Memos";
                    ApplicationArea = All;
                }
                action("Posted Purchase Receipts")
                {
                    Caption = 'Posted Purchase Receipts';
                    RunObject = Page "Posted Purchase Receipts";
                    ApplicationArea = All;
                }
                action("Posted Purchase Invoices")
                {
                    Caption = 'Posted Purchase Invoices';
                    RunObject = Page "Posted Purchase Invoices";
                    ApplicationArea = All;
                }
                action("Posted Return Shipments")
                {
                    Caption = 'Posted Return Shipments';
                    RunObject = Page "Posted Return Shipments";
                    ApplicationArea = All;
                }
                action("Posted Purchase Credit Memos")
                {
                    Caption = 'Posted Purchase Credit Memos';
                    RunObject = Page "Posted Purchase Credit Memos";
                    ApplicationArea = All;
                }
            }
            group(Administration)
            {
                Caption = 'Administration';
                Image = Administration;
                action("User Setup")
                {
                    Caption = 'User Setup';
                    Image = UserSetup;
                    RunObject = Page "User Setup";
                    ApplicationArea = All;
                }
                action("Membership Setup")
                {
                    Caption = 'Membership Setup';
                    RunObject = Page "NPR MM Membership Setup";
                    ApplicationArea = All;
                }
                action("Data Templates List")
                {
                    Caption = 'Data Templates List';
                    RunObject = Page "Config. Template List";
                    ApplicationArea = All;
                }
                action("Reason Codes")
                {
                    Caption = 'Reason Codes';
                    RunObject = Page "Reason Codes";
                    ApplicationArea = All;
                }
                action("Extended Texts")
                {
                    Caption = 'Extended Texts';
                    Image = Text;
                    RunObject = Page "Extended Text List";
                    ApplicationArea = All;
                }
                action("POS Stores")
                {
                    Caption = 'POS Stores';
                    RunObject = Page "NPR POS Store List";
                    ApplicationArea = All;
                }
                action("POS Units")
                {
                    Caption = 'POS Units';
                    RunObject = Page "NPR POS Unit List";
                    ApplicationArea = All;
                }
                action("Stock-Take Configurations")
                {
                    Caption = 'Stock-Take Configurations';
                    RunObject = Page "NPR Stock-Take Configs";
                    ApplicationArea = All;
                }
            }
        }
        area(creation)
        {
            action("Sales &Order")
            {
                Caption = 'Sales &Order';
                Image = Document;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "Sales Order";
                RunPageMode = Create;
                ApplicationArea = All;
            }
            action("Sales &Return Order")
            {
                Caption = 'Sales &Return Order';
                Image = ReturnOrder;
                RunObject = Page "Sales Return Order";
                RunPageMode = Create;
                ApplicationArea = All;
            }
            action("Sales Credit &Memo")
            {
                Caption = 'Sales Credit &Memo';
                Image = CreditMemo;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "Sales Credit Memo";
                RunPageMode = Create;
                ApplicationArea = All;
            }
            action("&Transfer Order")
            {
                Caption = '&Transfer Order';
                Image = TransferOrder;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "Transfer Order";
                RunPageMode = Create;
                ApplicationArea = All;
            }
            separator(Separator6014494)
            {
            }
            action("&Purchase Order")
            {
                Caption = '&Purchase Order';
                Image = Document;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "Purchase Order";
                RunPageMode = Create;
                ApplicationArea = All;
            }
            action("Purchase Credit Memo")
            {
                Caption = 'Purchase Credit Memo';
                Image = PurchaseTaxStatement;
                RunObject = Page "Purchase Credit Memo";
                ApplicationArea = All;
            }
            action("Purchase Return Order")
            {
                Caption = 'Purchase Return Order';
                Image = Document;
                RunObject = Page "Purchase Return Order";
                ApplicationArea = All;
            }
        }
        area(processing)
        {
            action("Adjust &Item Costs/Prices")
            {
                Caption = 'Adjust &Item Costs/Prices';
                Image = AdjustItemCost;
                RunObject = Report "Adjust Item Costs/Prices";
                ApplicationArea = All;
            }
            action("Adjust &Cost - Item Entries")
            {
                Caption = 'Adjust &Cost - Item Entries';
                Image = AdjustEntries;
                RunObject = Report "Adjust Cost - Item Entries";
                ApplicationArea = All;
            }
            action("Application Worksheet")
            {
                Caption = 'Application Worksheet';
                Image = ApplicationWorksheet;
                RunObject = Page "Application Worksheet";
                Visible = false;
                ApplicationArea = All;
            }
            separator(Separator6014441)
            {
                Caption = 'Administration';
                IsHeader = true;
            }
            action("General Le&dger Setup")
            {
                Caption = 'General Le&dger Setup';
                Image = Setup;
                RunObject = Page "General Ledger Setup";
                Visible = false;
                ApplicationArea = All;
            }
            action("S&ales && Receivables Setup")
            {
                Caption = 'S&ales && Receivables Setup';
                Image = Setup;
                RunObject = Page "Sales & Receivables Setup";
                Visible = false;
                ApplicationArea = All;
            }
            action("Company Information")
            {
                Caption = 'Company Information';
                Image = CompanyInformation;
                RunObject = Page "Company Information";
                Visible = false;
                ApplicationArea = All;
            }
            separator(History)
            {
                Caption = 'History';
                IsHeader = true;
            }
            action("Navi&gate")
            {
                Caption = 'Navi&gate';
                Image = Navigate;
                RunObject = Page Navigate;
                ApplicationArea = All;
            }
            action("NP Retail Setup")
            {
                Caption = 'NP Retail Setup';
                Image = Setup;
                RunObject = Page "NPR NP Retail Setup";
                ApplicationArea = All;
            }
            action(Action6014574)
            {
                Caption = 'Company Information';
                Image = CompanyInformation;
                RunObject = Page "Company Information";
                ApplicationArea = All;
            }
            group(Retail)
            {
                Caption = 'Retail';
                Visible = false;
                action(Action6014417)
                {
                    Caption = 'NP Retail Setup';
                    Image = Setup;
                    RunObject = Page "NPR NP Retail Setup";
                    ApplicationArea = All;
                }
            }
            group(Sales)
            {
                Caption = 'Sales';
                Visible = false;
                action("Sales - Invoice")
                {
                    Caption = 'Sales - Invoice';
                    Image = "Report";
                    RunObject = Report "Standard Sales - Invoice";
                    ApplicationArea = All;
                }
                action("Period Discount Statistics")
                {
                    Caption = 'Period Discount Statistics';
                    Image = "Report";
                    RunObject = Report "NPR Period Discount Stat.";
                    ApplicationArea = All;
                }
                action("Sales per week year/Last year")
                {
                    Caption = 'Sales per week year/Last year';
                    Image = "Report";
                    RunObject = Report "NPR Sales per week year/Last";
                    ApplicationArea = All;
                }
                action("Sales Stat/Analysis")
                {
                    Caption = 'Sales Stat/Analysis';
                    Image = "Report";
                    RunObject = Report "NPR Sales Stat/Analysis";
                    ApplicationArea = All;
                }
                action("Sales Statistics Per Variety")
                {
                    Caption = 'Sales Statistics Per Variety';
                    Image = "Report";
                    RunObject = Report "NPR Sales Stats Per Variety";
                    ApplicationArea = All;
                }
                action("Return Reason Code Statistics")
                {
                    Caption = 'Return Reason Code Statistics';
                    Image = "Report";
                    RunObject = Report "NPR Return Reason Code Stat.";
                    ApplicationArea = All;
                }
            }
            group(Item)
            {
                Caption = 'Item';
                Visible = false;
                action("Inventory - Sales Statistics")
                {
                    Caption = 'Inventory - Sales Statistics';
                    Image = "Report";
                    RunObject = Report "Inventory - Sales Statistics";
                    ApplicationArea = All;
                }
                action("Inventory by age")
                {
                    Caption = 'Inventory by age';
                    Image = "Report";
                    RunObject = Report "NPR Inventory by age";
                    ApplicationArea = All;
                }
                action("Item Group Overview")
                {
                    Caption = 'Item Group Overview';
                    Image = "Report";
                    RunObject = Report "NPR Item Group Overview";
                    ApplicationArea = All;
                }
                action("Inventory per Date")
                {
                    Caption = 'Inventory per Date';
                    Image = "Report";
                    RunObject = Report "NPR Inventory per Date";
                    ApplicationArea = All;
                }
                action("Item Group Stat M/Y")
                {
                    Caption = 'Item Group Stat M/Y';
                    Image = "Report";
                    RunObject = Report "NPR Item Group Stat M/Y";
                    ApplicationArea = All;
                }
                action("Sales Person Trn. by Item Gr.")
                {
                    Caption = 'Sales Person Trn. by Item Gr.';
                    Image = "Report";
                    RunObject = Report "NPR S.Person Trx by Item Gr.";
                    ApplicationArea = All;
                }
                action("Item Group Inventory Value")
                {
                    Caption = 'Item Group Inventory Value';
                    Image = "Report";
                    RunObject = Report "NPR Item Group Inv. Value";
                    ApplicationArea = All;
                }
                action("Item Barcode Status Sheet")
                {
                    Caption = 'Item Barcode Status Sheet';
                    Image = "Report";
                    RunObject = Report "NPR Item Barcode Status Sheet";
                    ApplicationArea = All;
                }
                action("Item Replenishment by Store")
                {
                    Caption = 'Item Replenishment by Store';
                    Image = "Report";
                    RunObject = Report "NPR Item Replenish. by Store";
                    ApplicationArea = All;
                }
                action("Lager Kampagnestat")
                {
                    Caption = 'Lager Kampagnestat';
                    Image = "Report";
                    RunObject = Report "NPR Inventory Campaign Stat.";
                    ApplicationArea = All;
                }
                action("Item - Loss")
                {
                    Caption = 'Item - Loss';
                    Image = "Report";
                    RunObject = Report "NPR Item - Loss";
                    ApplicationArea = All;
                }
                action("Item Loss - Return Reason")
                {
                    Caption = 'Item Loss - Return Reason';
                    Image = "Report";
                    RunObject = Report "NPR Item Loss - Ret. Reason";
                    ApplicationArea = All;
                }
                action("Inventory per Variant at date")
                {
                    Caption = 'Inventory per Variant at date';
                    Image = "Report";
                    RunObject = Report "NPR Inventory per Variant/date";
                    ApplicationArea = All;
                }
                action("Adjust Cost - Item Entries TQ")
                {
                    Caption = 'Adjust Cost - Item Entries TQ';
                    Image = "Report";
                    RunObject = Report "NPR Adjust Cost: ItemEntriesTQ";
                    ApplicationArea = All;
                }
            }
            group(Vendor)
            {
                Caption = 'Vendor';
                Visible = false;
                action("Sales Statistics per Vendor")
                {
                    Caption = 'Sales Statistics per Vendor';
                    Image = "Report";
                    RunObject = Report "NPR Sale Statistics per Vendor";
                    ApplicationArea = All;
                }
                action("Vendor Sales Stat")
                {
                    Caption = 'Vendor Sales Stat';
                    Image = "Report";
                    RunObject = Report "NPR Vendor Sales Stat";
                    ApplicationArea = All;
                }
                action("Vendor Top/Sale")
                {
                    Caption = 'Vendor Top/Sale';
                    Image = "Report";
                    RunObject = Report "NPR Vendor Top/Sale";
                    ApplicationArea = All;
                }
                action("Vendor/Item Group")
                {
                    Caption = 'Vendor/Item Group';
                    Image = "Report";
                    RunObject = Report "NPR Vendor/Item Group";
                    ApplicationArea = All;
                }
                action("Vendor trn. by Item group")
                {
                    Caption = 'Vendor trn. by Item group';
                    Image = "Report";
                    RunObject = Report "NPR Vendor trx by Item group";
                    ApplicationArea = All;
                }
                action("Vendor/Salesperson")
                {
                    Caption = 'Vendor/Salesperson';
                    Image = "Report";
                    RunObject = Report "NPR Vendor/Salesperson";
                    ApplicationArea = All;
                }
            }
        }
    }
}

