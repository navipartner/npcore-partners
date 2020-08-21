page 6014557 "POS - Sales Person Role Center"
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

    layout
    {
        area(rolecenter)
        {
            group(Control6150641)
            {
                ShowCaption = false;
                part(Control6150638; "Discount Activities")
                {
                    Visible = false;
                }
                part(Control6150616; "Retail Activities")
                {
                }
                part(Control6150617; "Retail Sales Chart")
                {
                }
                part(Control6014405; "RSS Reader Activities")
                {
                    Visible = false;
                }
                part(Control6014403; "Retail Sales Chart by Shop")
                {
                }
            }
            group(Control6151405)
            {
                ShowCaption = false;
                part(Control1; "Power BI Report Spinner Part")
                {
                    ApplicationArea = Basic, Suite;
                }
                part(Control6150615; "Retail Top 10 Customers")
                {
                    Visible = false;
                }
                part(Control6150614; "Retail 10 Items by Qty.")
                {
                }
                part(Control6150613; "Retail Top 10 Salesperson")
                {
                }
                part("<Retail Top 10 Salesperson>"; "My Reports")
                {
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
            }
            action(Action6014569)
            {
                Caption = 'Vendor';
                RunObject = Page "Vendor List";
            }
            action("Audit Roll")
            {
                Caption = 'Audit Roll';
                RunObject = Page "Audit Roll";
            }
            action("POS Entry List")
            {
                Caption = 'POS Entry List';
                RunObject = Page "POS Entry List";
            }
            action("Retail Item List")
            {
                Caption = 'Retail Item List';
                RunObject = Page "Retail Item List";
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
                }
                separator(Separator6150667)
                {
                }
                action("Customer - Order Su&mmary")
                {
                    Caption = 'Customer - Order Su&mmary';
                    Image = "Report";
                    RunObject = Report "Customer - Order Summary";
                }
                action("Customer - T&op 10 List")
                {
                    Caption = 'Customer - T&op 10 List';
                    Image = "Report";
                    RunObject = Report "Customer - Top 10 List";
                }
                action("Customer/&Item Sales")
                {
                    Caption = 'Customer/&Item Sales';
                    Image = "Report";
                    RunObject = Report "Customer/Item Sales";
                }
                separator(Separator6150663)
                {
                }
                action("Salesperson - Sales &Statistics")
                {
                    Caption = 'Salesperson - Sales &Statistics';
                    Image = "Report";
                    RunObject = Report "Salesperson - Sales Statistics";
                }
                action("Price &List")
                {
                    Caption = 'Price &List';
                    Image = "Report";
                    RunObject = Report "Price List";
                }
                separator(Separator6150660)
                {
                }
                action("Inventory - Sales &Back Orders")
                {
                    Caption = 'Inventory - Sales &Back Orders';
                    Image = "Report";
                    RunObject = Report "Inventory - Sales Back Orders";
                }
                separator(Separator6150658)
                {
                }
                action("&G/L Trial Balance")
                {
                    Caption = '&G/L Trial Balance';
                    Image = "Report";
                    RunObject = Report "Trial Balance";
                }
                action("Trial Balance by &Period")
                {
                    Caption = 'Trial Balance by &Period';
                    Image = "Report";
                    RunObject = Report "Trial Balance by Period";
                }
                action("Closing T&rial Balance")
                {
                    Caption = 'Closing T&rial Balance';
                    Image = "Report";
                    RunObject = Report "Closing Trial Balance";
                }
                separator(Separator6150654)
                {
                }
                action("Aged Ac&counts Receivable")
                {
                    Caption = 'Aged Ac&counts Receivable';
                    Image = "Report";
                    RunObject = Report "Aged Accounts Receivable";
                }
                action("Aged Accounts Pa&yable")
                {
                    Caption = 'Aged Accounts Pa&yable';
                    Image = "Report";
                    RunObject = Report "Aged Accounts Payable";
                }
                action("Reconcile Cust. and &Vend. Accs")
                {
                    Caption = 'Reconcile Cust. and &Vend. Accs';
                    Image = "Report";
                    RunObject = Report "Reconcile Cust. and Vend. Accs";
                }
                separator(Separator6150650)
                {
                }
                action("VAT Registration No. Chec&k")
                {
                    Caption = 'VAT Registration No. Chec&k';
                    Image = "Report";
                    RunObject = Report "VAT Registration No. Check";
                }
                action("VAT E&xceptions")
                {
                    Caption = 'VAT E&xceptions';
                    Image = "Report";
                    RunObject = Report "VAT Exceptions";
                }
                action("V&AT Statement")
                {
                    Caption = 'V&AT Statement';
                    Image = "Report";
                    RunObject = Report "VAT Statement";
                }
                action("VAT-VIES Declaration Tax A&uth")
                {
                    Caption = 'VAT-VIES Declaration Tax A&uth';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Tax Auth";
                }
                action("VAT - VIES Declaration &Disk")
                {
                    Caption = 'VAT - VIES Declaration &Disk';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Disk";
                }
                action("EC Sal&es List")
                {
                    Caption = 'EC Sal&es List';
                    Image = "Report";
                    RunObject = Report "EC Sales List";
                }
            }
            group(ActionGroup6014408)
            {
                Caption = 'Retail';
                action("Sales Statistics")
                {
                    Caption = 'Sales Statistics';
                    Image = Report2;
                    RunObject = Report "Sales Ticket Statistics";
                }
                action("Sale Report")
                {
                    Caption = 'Sale Report';
                    Image = Report2;
                    RunObject = Report "Sale Time Report";
                }
                separator(Separator6014423)
                {
                }
                action("Sales Person Top 20")
                {
                    Caption = 'Sales Person Top 20';
                    Image = Report2;
                    RunObject = Report "Sales Person Top 20";
                }
                action("Salesperson/Item Group Top")
                {
                    Caption = 'Salesperson/Item Group Top';
                    Image = Report2;
                    RunObject = Report "Salesperson/Item Group Top";
                }
                separator(Separator6014432)
                {
                }
                action("Item Wise Sales Figures")
                {
                    Caption = 'Item Wise Sales Figures';
                    Image = Report2;
                    RunObject = Report "Item Wise Sales Figures";
                }
                separator(Separator6014462)
                {
                }
                action("Discount Statistics")
                {
                    Caption = 'Discount Statistics';
                    Image = Report2;
                    RunObject = Report "Discount Statistics";
                }
            }
            group("Item & Prices")
            {
                Caption = 'Item & Prices';
                action("Item Sales Statistics")
                {
                    Caption = 'Item Sales Statistics';
                    Image = Report2;
                    RunObject = Report "Item Sales Statistics/Provider";
                }
                action("Top 10 List")
                {
                    Caption = 'Top 10 List';
                    Image = Report2;
                    RunObject = Report "Inventory - Top 10 List";
                }
                action("Low Sales")
                {
                    Caption = 'Low Sales';
                    Image = Report2;
                    RunObject = Report "Items With Low Sales";
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
                    RunObject = Page "Audit Roll";
                }
                action("Credit Vouchers")
                {
                    Caption = 'Credit Vouchers';
                    RunObject = Page "Credit Voucher List";
                }
                action("Gift Vouchers")
                {
                    Caption = 'Gift Vouchers';
                    RunObject = Page "Gift Voucher List";
                }
                action("Exchange Labels")
                {
                    Caption = 'Exchange Labels';
                    RunObject = Page "Exchange Label";
                }
                action("Tax Free Voucher")
                {
                    Caption = 'Tax Free Voucher';
                    RunObject = Page "Tax Free Voucher";
                }
                separator(Miscellaneous)
                {
                    Caption = 'Miscellaneous';
                }
                action("Retail Document List")
                {
                    Caption = 'Retail Document List';
                    RunObject = Page "Retail Document List";
                }
                action("Customer Repairs List")
                {
                    Caption = 'Customer Repairs List';
                    RunObject = Page "Customer Repair List";
                }
                action("Warranty Catalog List")
                {
                    Caption = 'Warranty Catalog List';
                    RunObject = Page "Warranty Catalog List";
                }
                separator(Separator6014512)
                {
                    Caption = 'Miscellaneous';
                }
                action(Coupons)
                {
                    Caption = 'Coupons';
                    RunObject = Page "NpDc Coupons";
                }
                action("Coupon Types")
                {
                    Caption = 'Coupon Types';
                    RunObject = Page "NpDc Coupon Types";
                }
            }
            group(ActionGroup6014513)
            {
                Caption = 'Item & Prices';
                Image = ProductDesign;
                action(Action6014418)
                {
                    Caption = 'Retail Item List';
                    RunObject = Page "Retail Item List";
                }
                action("Item Group Tree")
                {
                    Caption = 'Item Group Tree';
                    RunObject = Page "Item Group Tree";
                }
                action("Stockkeeping Unit List")
                {
                    Caption = 'Stockkeeping Unit List';
                    RunObject = Page "Stockkeeping Unit List";
                }
                action("Item Worksheets")
                {
                    Caption = 'Item Worksheets';
                    RunObject = Page "Item Worksheets";
                }
                action("Campaign Discount List")
                {
                    Caption = 'Campaign Discount List';
                    RunObject = Page "Campaign Discount List";
                }
                action("Mixed Discount List")
                {
                    Caption = 'Mixed Discount List';
                    RunObject = Page "Mixed Discount List";
                }
                action("Item Journals")
                {
                    Caption = 'Item Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Item),
                                        Recurring = CONST(false));
                }
                action("Physical Inventory Journals")
                {
                    Caption = 'Physical Inventory Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Phys. Inventory"),
                                        Recurring = CONST(false));
                }
                action("Revaluation Journals")
                {
                    Caption = 'Revaluation Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Revaluation),
                                        Recurring = CONST(false));
                }
                action("Retail Journal List")
                {
                    Caption = 'Retail Journal List';
                    Image = ResourceJournal;
                    RunObject = Page "Retail Journal List";
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
                }
                action(Items)
                {
                    Caption = 'Items';
                    RunObject = Page "Retail Item List";
                    RunPageView = WHERE("Magento Item" = CONST(true));
                }
                action("Item Groups")
                {
                    Caption = 'Item Groups';
                    RunObject = Page "Magento Categories";
                }
                action(Brands)
                {
                    Caption = 'Brands';
                    RunObject = Page "Magento Brands";
                }
                action("Custom Options")
                {
                    Caption = 'Custom Options';
                    RunObject = Page "Magento Custom Option List";
                }
                action(Attributes)
                {
                    Caption = 'Attributes';
                    RunObject = Page "Magento Attributes";
                }
                action("Attribute Sets")
                {
                    Caption = 'Attribute Sets';
                    RunObject = Page "Magento Attribute Sets";
                }
                separator(Separator6014546)
                {
                    Caption = 'Sales';
                }
                action("Payment Lines")
                {
                    Caption = 'Payment Lines';
                    RunObject = Page "Magento Payment Line List";
                }
                separator(Mapping)
                {
                    Caption = 'Mapping';
                }
                action("Shipment Method Mapping")
                {
                    Caption = 'Shipment Method Mapping';
                    RunObject = Page "Magento Shipment Mapping";
                }
                action("Payment Method Mapping")
                {
                    Caption = 'Payment Method Mapping';
                    RunObject = Page "Magento Payment Mapping";
                }
                separator(Separator6014556)
                {
                }
                action("NaviDocs Document List")
                {
                    Caption = 'NaviDocs Document List';
                    RunObject = Page "NaviDocs Document List";
                }
            }
            group(Member)
            {
                Caption = 'Member';
                Image = HumanResources;
                action(Members)
                {
                    Caption = 'Members';
                    RunObject = Page "MM Members";
                }
                action(Memberships)
                {
                    Caption = 'Memberships';
                    RunObject = Page "MM Memberships";
                }
                action("Member Card List")
                {
                    Caption = 'Member Card List';
                    RunObject = Page "MM Member Card List";
                }
                action("MCS Faces")
                {
                    Caption = 'MCS Faces';
                    RunObject = Page "MCS Faces";
                }
            }
            group(Ticket)
            {
                Caption = 'Ticket';
                Image = Worksheets;
                action("Ticket List")
                {
                    Caption = 'Ticket List';
                    RunObject = Page "TM Ticket List";
                }
                action("Ticket Request")
                {
                    Caption = 'Ticket Request';
                    RunObject = Page "TM Ticket Request";
                }
                action("Ticket Type")
                {
                    Caption = 'Ticket Type';
                    RunObject = Page "TM Ticket Type";
                }
                action("Ticket BOM")
                {
                    Caption = 'Ticket BOM';
                    RunObject = Page "TM Ticket BOM";
                }
                action("Ticket Admissions")
                {
                    Caption = 'Ticket Admissions';
                    RunObject = Page "TM Ticket Admissions";
                }
                action("<Page TM Ticket Access Entry List>")
                {
                    Caption = 'Ticket Access Entry List';
                    RunObject = Page "TM Ticket Access Entry List";
                }
                action("Event List")
                {
                    Caption = 'Event List';
                    RunObject = Page "Event List";
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
                }
                action("VAT Statements")
                {
                    Caption = 'VAT Statements';
                    RunObject = Page "VAT Statement Names";
                }
                action("Bank Accounts")
                {
                    Caption = 'Bank Accounts';
                    Image = BankAccount;
                    RunObject = Page "Bank Account List";
                }
                action(Currencies)
                {
                    Caption = 'Currencies';
                    Image = Currency;
                    RunObject = Page Currencies;
                }
                action("Accounting Periods")
                {
                    Caption = 'Accounting Periods';
                    Image = AccountingPeriods;
                    RunObject = Page "Accounting Periods";
                }
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page Dimensions;
                }
                action("Issued Reminders")
                {
                    Caption = 'Issued Reminders';
                    Image = OrderReminder;
                    RunObject = Page "Issued Reminder List";
                }
                action("Issued Fin. Charge Memos")
                {
                    Caption = 'Issued Fin. Charge Memos';
                    Image = PostedMemo;
                    RunObject = Page "Issued Fin. Charge Memo List";
                }
                action("Resource Journals")
                {
                    Caption = 'Resource Journals';
                    RunObject = Page "Resource Jnl. Batches";
                    RunPageView = WHERE(Recurring = CONST(false));
                }
                action("FA Journals")
                {
                    Caption = 'FA Journals';
                    RunObject = Page "FA Journal Batches";
                    RunPageView = WHERE(Recurring = CONST(false));
                }
                action("Cash Receipt Journals")
                {
                    Caption = 'Cash Receipt Journals';
                    Image = Journals;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Cash Receipts"),
                                        Recurring = CONST(false));
                }
                action("Payment Journals")
                {
                    Caption = 'Payment Journals';
                    Image = Journals;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Payments),
                                        Recurring = CONST(false));
                }
                action("General Journals")
                {
                    Caption = 'General Journals';
                    Image = Journal;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(General),
                                        Recurring = CONST(false));
                }
                action("Recurring Journals")
                {
                    Caption = 'Recurring Journals';
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(General),
                                        Recurring = CONST(true));
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
                }
                action("Salespeople/Purchasers")
                {
                    Caption = 'Salespeople/Purchasers';
                    RunObject = Page "Salespersons/Purchasers";
                }
                action("Contact List ")
                {
                    Caption = 'Contact List';
                    RunObject = Page "Contact List";
                }
                action(Orders)
                {
                    Caption = 'Orders';
                    RunObject = Page "Sales Order List";
                }
                action(Invoices)
                {
                    Caption = 'Invoices';
                    RunObject = Page "Sales Invoice List";
                }
                action("Return Orders")
                {
                    Caption = 'Return Orders';
                    RunObject = Page "Sales Return Order List";
                }
                action("Credit Memos")
                {
                    Caption = 'Credit Memos';
                    RunObject = Page "Sales Credit Memos";
                }
                action("Customer Invoice Discount")
                {
                    Caption = 'Customer Invoice Discount';
                    RunObject = Page "Cust. Invoice Discounts";
                }
                action("Posted Sales Shipments")
                {
                    Caption = 'Posted Sales Shipments';
                    Image = PostedShipment;
                    RunObject = Page "Posted Sales Shipments";
                }
                action("Posted Sales Invoices")
                {
                    Caption = 'Posted Sales Invoices';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Invoices";
                }
                action("Posted Sales Return Orders")
                {
                    Caption = 'Posted Sales Return Orders';
                    RunObject = Page "Posted Return Receipts";
                }
                action("Posted Sales Credit Memos")
                {
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
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
                }
                action("Purchase Orders")
                {
                    Caption = 'Purchase Orders';
                    RunObject = Page "Purchase Order List";
                }
                action("Purchase Return Orders")
                {
                    Caption = 'Purchase Return Orders';
                    RunObject = Page "Purchase Return Order List";
                }
                action("Purchase Invoices")
                {
                    Caption = 'Purchase Invoices';
                    RunObject = Page "Purchase Invoices";
                }
                action("Purchase Credit Memos")
                {
                    Caption = 'Purchase Credit Memos';
                    RunObject = Page "Purchase Credit Memos";
                }
                action("Posted Purchase Receipts")
                {
                    Caption = 'Posted Purchase Receipts';
                    RunObject = Page "Posted Purchase Receipts";
                }
                action("Posted Purchase Invoices")
                {
                    Caption = 'Posted Purchase Invoices';
                    RunObject = Page "Posted Purchase Invoices";
                }
                action("Posted Return Shipments")
                {
                    Caption = 'Posted Return Shipments';
                    RunObject = Page "Posted Return Shipments";
                }
                action("Posted Purchase Credit Memos")
                {
                    Caption = 'Posted Purchase Credit Memos';
                    RunObject = Page "Posted Purchase Credit Memos";
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
                }
                action("Membership Setup")
                {
                    Caption = 'Membership Setup';
                    RunObject = Page "MM Membership Setup";
                }
                action("Data Templates List")
                {
                    Caption = 'Data Templates List';
                    RunObject = Page "Config. Template List";
                }
                action("Reason Codes")
                {
                    Caption = 'Reason Codes';
                    RunObject = Page "Reason Codes";
                }
                action("Extended Texts")
                {
                    Caption = 'Extended Texts';
                    Image = Text;
                    RunObject = Page "Extended Text List";
                }
                action("POS Stores")
                {
                    Caption = 'POS Stores';
                    RunObject = Page "POS Store List";
                }
                action("POS Units")
                {
                    Caption = 'POS Units';
                    RunObject = Page "POS Unit List";
                }
                action("Stock-Take Configurations")
                {
                    Caption = 'Stock-Take Configurations';
                    RunObject = Page "Stock-Take Configurations";
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
            }
            action("Sales &Return Order")
            {
                Caption = 'Sales &Return Order';
                Image = ReturnOrder;
                RunObject = Page "Sales Return Order";
                RunPageMode = Create;
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
            }
            action("&Transfer Order")
            {
                Caption = '&Transfer Order';
                Image = TransferOrder;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "Transfer Order";
                RunPageMode = Create;
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
            }
            action("Purchase Credit Memo")
            {
                Caption = 'Purchase Credit Memo';
                Image = PurchaseTaxStatement;
                RunObject = Page "Purchase Credit Memo";
            }
            action("Purchase Return Order")
            {
                Caption = 'Purchase Return Order';
                Image = Document;
                RunObject = Page "Purchase Return Order";
            }
        }
        area(processing)
        {
            action("Adjust &Item Costs/Prices")
            {
                Caption = 'Adjust &Item Costs/Prices';
                Image = AdjustItemCost;
                RunObject = Report "Adjust Item Costs/Prices";
            }
            action("Adjust &Cost - Item Entries")
            {
                Caption = 'Adjust &Cost - Item Entries';
                Image = AdjustEntries;
                RunObject = Report "Adjust Cost - Item Entries";
            }
            action("Application Worksheet")
            {
                Caption = 'Application Worksheet';
                Image = ApplicationWorksheet;
                RunObject = Page "Application Worksheet";
                Visible = false;
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
            }
            action("S&ales && Receivables Setup")
            {
                Caption = 'S&ales && Receivables Setup';
                Image = Setup;
                RunObject = Page "Sales & Receivables Setup";
                Visible = false;
            }
            action("Company Information")
            {
                Caption = 'Company Information';
                Image = CompanyInformation;
                RunObject = Page "Company Information";
                Visible = false;
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
            }
            action("NP Retail Setup")
            {
                Caption = 'NP Retail Setup';
                Image = Setup;
                RunObject = Page "NP Retail Setup";
            }
            action(Action6014574)
            {
                Caption = 'Company Information';
                Image = CompanyInformation;
                RunObject = Page "Company Information";
            }
            group(Retail)
            {
                Caption = 'Retail';
                Visible = false;
                action(Action6014417)
                {
                    Caption = 'NP Retail Setup';
                    Image = Setup;
                    RunObject = Page "NP Retail Setup";
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
                    RunObject = Report "Sales - Invoice";
                }
                action("Period Discount Statistics")
                {
                    Caption = 'Period Discount Statistics';
                    Image = "Report";
                    RunObject = Report "Period Discount Statistics";
                }
                action("Sales per week year/Last year")
                {
                    Caption = 'Sales per week year/Last year';
                    Image = "Report";
                    RunObject = Report "Sales per week year/Last year";
                }
                action("Sales Stat/Analysis")
                {
                    Caption = 'Sales Stat/Analysis';
                    Image = "Report";
                    RunObject = Report "Sales Stat/Analysis";
                }
                action("Sales Statistics Per Variety")
                {
                    Caption = 'Sales Statistics Per Variety';
                    Image = "Report";
                    RunObject = Report "Sales Statistics Per Variety";
                }
                action("Return Reason Code Statistics")
                {
                    Caption = 'Return Reason Code Statistics';
                    Image = "Report";
                    RunObject = Report "Return Reason Code Statistics";
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
                }
                action("Inventory by age")
                {
                    Caption = 'Inventory by age';
                    Image = "Report";
                    RunObject = Report "Inventory by age";
                }
                action("Item Group Overview")
                {
                    Caption = 'Item Group Overview';
                    Image = "Report";
                    RunObject = Report "Item Group Overview";
                }
                action("Inventory per Date")
                {
                    Caption = 'Inventory per Date';
                    Image = "Report";
                    RunObject = Report "Inventory per Date";
                }
                action("Item Group Stat M/Y")
                {
                    Caption = 'Item Group Stat M/Y';
                    Image = "Report";
                    RunObject = Report "Item Group Stat M/Y";
                }
                action("Sales Person Trn. by Item Gr.")
                {
                    Caption = 'Sales Person Trn. by Item Gr.';
                    Image = "Report";
                    RunObject = Report "Sales Person Trn. by Item Gr.";
                }
                action("Item Group Inventory Value")
                {
                    Caption = 'Item Group Inventory Value';
                    Image = "Report";
                    RunObject = Report "Item Group Inventory Value";
                }
                action("Item Barcode Status Sheet")
                {
                    Caption = 'Item Barcode Status Sheet';
                    Image = "Report";
                    RunObject = Report "Item Barcode Status Sheet";
                }
                action("Item Replenishment by Store")
                {
                    Caption = 'Item Replenishment by Store';
                    Image = "Report";
                    RunObject = Report "Item Replenishment by Store";
                }
                action("Lager Kampagnestat")
                {
                    Caption = 'Lager Kampagnestat';
                    Image = "Report";
                    RunObject = Report "Inventory Campaign Stat.";
                }
                action("Item - Loss")
                {
                    Caption = 'Item - Loss';
                    Image = "Report";
                    RunObject = Report "Item - Loss";
                }
                action("Item Loss - Return Reason")
                {
                    Caption = 'Item Loss - Return Reason';
                    Image = "Report";
                    RunObject = Report "Item Loss - Return Reason";
                }
                action("Inventory per Variant at date")
                {
                    Caption = 'Inventory per Variant at date';
                    Image = "Report";
                    RunObject = Report "Inventory per Variant at date";
                }
                action("Adjust Cost - Item Entries TQ")
                {
                    Caption = 'Adjust Cost - Item Entries TQ';
                    Image = "Report";
                    RunObject = Report "Adjust Cost - Item Entries TQ";
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
                    RunObject = Report "Sale Statistics per Vendor";
                }
                action("Vendor Sales Stat")
                {
                    Caption = 'Vendor Sales Stat';
                    Image = "Report";
                    RunObject = Report "Vendor Sales Stat";
                }
                action("Vendor Top/Sale")
                {
                    Caption = 'Vendor Top/Sale';
                    Image = "Report";
                    RunObject = Report "Vendor Top/Sale";
                }
                action("Vendor/Item Group")
                {
                    Caption = 'Vendor/Item Group';
                    Image = "Report";
                    RunObject = Report "Vendor/Item Group";
                }
                action("Vendor trn. by Item group")
                {
                    Caption = 'Vendor trn. by Item group';
                    Image = "Report";
                    RunObject = Report "Vendor trn. by Item group";
                }
                action("Vendor/Salesperson")
                {
                    Caption = 'Vendor/Salesperson';
                    Image = "Report";
                    RunObject = Report "Vendor/Salesperson";
                }
            }
        }
    }
}

