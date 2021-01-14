page 6014557 "NPR POS: SalesPerson R.Center"
{
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
                ToolTip = 'Executes the Customer action';
            }
            action(Action6014569)
            {
                Caption = 'Vendor';
                RunObject = Page "Vendor List";
                ApplicationArea = All;
                ToolTip = 'Executes the Vendor action';
            }
            action("Audit Roll")
            {
                Caption = 'Audit Roll';
                RunObject = Page "NPR Audit Roll";
                ApplicationArea = All;
                ToolTip = 'Executes the Audit Roll action';
            }
            action("POS Entry List")
            {
                Caption = 'POS Entry List';
                RunObject = Page "NPR POS Entry List";
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entry List action';
            }
            action("Retail Item List")
            {
                Caption = 'Retail Item List';
                RunObject = Page "Item List";
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Item List action';
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
                    ToolTip = 'Executes the S&tatement action';
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
                    ToolTip = 'Executes the Customer - Order Su&mmary action';
                }
                action("Customer - T&op 10 List")
                {
                    Caption = 'Customer - T&op 10 List';
                    Image = "Report";
                    RunObject = Report "Customer - Top 10 List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Customer - T&op 10 List action';
                }
                separator(Separator6150663)
                {
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
                    ToolTip = 'Executes the Inventory - Sales &Back Orders action';
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
                    ToolTip = 'Executes the &G/L Trial Balance action';
                }
                action("Trial Balance by &Period")
                {
                    Caption = 'Trial Balance by &Period';
                    Image = "Report";
                    RunObject = Report "Trial Balance by Period";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Trial Balance by &Period action';
                }
                action("Closing T&rial Balance")
                {
                    Caption = 'Closing T&rial Balance';
                    Image = "Report";
                    RunObject = Report "Closing Trial Balance";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Closing T&rial Balance action';
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
                    ToolTip = 'Executes the Aged Ac&counts Receivable action';
                }
                action("Aged Accounts Pa&yable")
                {
                    Caption = 'Aged Accounts Pa&yable';
                    Image = "Report";
                    RunObject = Report "Aged Accounts Payable";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Aged Accounts Pa&yable action';
                }
                action("Reconcile Cust. and &Vend. Accs")
                {
                    Caption = 'Reconcile Cust. and &Vend. Accs';
                    Image = "Report";
                    RunObject = Report "Reconcile Cust. and Vend. Accs";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Reconcile Cust. and &Vend. Accs action';
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
                    ToolTip = 'Executes the VAT Registration No. Chec&k action';
                }
                action("VAT E&xceptions")
                {
                    Caption = 'VAT E&xceptions';
                    Image = "Report";
                    RunObject = Report "VAT Exceptions";
                    ApplicationArea = All;
                    ToolTip = 'Executes the VAT E&xceptions action';
                }
                action("V&AT Statement")
                {
                    Caption = 'V&AT Statement';
                    Image = "Report";
                    RunObject = Report "VAT Statement";
                    ApplicationArea = All;
                    ToolTip = 'Executes the V&AT Statement action';
                }
                action("VAT-VIES Declaration Tax A&uth")
                {
                    Caption = 'VAT-VIES Declaration Tax A&uth';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Tax Auth";
                    ApplicationArea = All;
                    ToolTip = 'Executes the VAT-VIES Declaration Tax A&uth action';
                }
                action("VAT - VIES Declaration &Disk")
                {
                    Caption = 'VAT - VIES Declaration &Disk';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Disk";
                    ApplicationArea = All;
                    ToolTip = 'Executes the VAT - VIES Declaration &Disk action';
                }
                action("EC Sal&es List")
                {
                    Caption = 'EC Sal&es List';
                    Image = "Report";
                    RunObject = Report "EC Sales List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the EC Sal&es List action';
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
                    ToolTip = 'Executes the Sales Statistics action';
                }
                action("Sale Report")
                {
                    Caption = 'Sale Report';
                    Image = Report2;
                    RunObject = Report "NPR Sale Time Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sale Report action';
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
                    ToolTip = 'Executes the Sales Person Top 20 action';
                }
                action("Salesperson/Item Group Top")
                {
                    Caption = 'Salesperson/Item Group Top';
                    Image = Report2;
                    RunObject = Report "NPR Salesperson/Item Group Top";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Salesperson/Item Group Top action';
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
                    ToolTip = 'Executes the Item Wise Sales Figures action';
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
                    ToolTip = 'Executes the Discount Statistics action';
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
                    ToolTip = 'Executes the Item Sales Statistics action';
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
                    ToolTip = 'Executes the Audit Roll action';
                }
                action("Credit Vouchers")
                {
                    Caption = 'Credit Vouchers';
                    RunObject = Page "NPR Credit Voucher List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Credit Vouchers action';
                }
                action("Gift Vouchers")
                {
                    Caption = 'Gift Vouchers';
                    RunObject = Page "NPR Gift Voucher List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Gift Vouchers action';
                }
                action("Exchange Labels")
                {
                    Caption = 'Exchange Labels';
                    RunObject = Page "NPR Exchange Label";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Exchange Labels action';
                }
                action("Tax Free Voucher")
                {
                    Caption = 'Tax Free Voucher';
                    RunObject = Page "NPR Tax Free Voucher";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Tax Free Voucher action';
                }
                action("Retail Document List")
                {
                    Caption = 'Retail Document List';
                    RunObject = Page "NPR Retail Document List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Document List action';
                }
                action("Customer Repairs List")
                {
                    Caption = 'Customer Repairs List';
                    RunObject = Page "NPR Customer Repair List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Customer Repairs List action';
                }
                action("Warranty Catalog List")
                {
                    Caption = 'Warranty Catalog List';
                    RunObject = Page "NPR Warranty Catalog List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Warranty Catalog List action';
                }
                action(Coupons)
                {
                    Caption = 'Coupons';
                    RunObject = Page "NPR NpDc Coupons";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Coupons action';
                }
                action("Coupon Types")
                {
                    Caption = 'Coupon Types';
                    RunObject = Page "NPR NpDc Coupon Types";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Coupon Types action';
                }
            }
            group(ActionGroup6014513)
            {
                Caption = 'Item & Prices';
                Image = ProductDesign;
                action(Action6014418)
                {
                    Caption = 'Retail Item List';
                    RunObject = Page "Item List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Item List action';
                }
                action("Item Group Tree")
                {
                    Caption = 'Item Group Tree';
                    RunObject = Page "NPR Item Group Tree";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Group Tree action';
                }
                action("Item Worksheets")
                {
                    Caption = 'Item Worksheets';
                    RunObject = Page "NPR Item Worksheets";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Worksheets action';
                }
                action("Campaign Discount List")
                {
                    Caption = 'Campaign Discount List';
                    RunObject = Page "NPR Campaign Discount List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Campaign Discount List action';
                }
                action("Mixed Discount List")
                {
                    Caption = 'Mixed Discount List';
                    RunObject = Page "NPR Mixed Discount List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Mixed Discount List action';
                }
                action("Item Journals")
                {
                    Caption = 'Item Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Item),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Journals action';
                }
                action("Physical Inventory Journals")
                {
                    Caption = 'Physical Inventory Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Phys. Inventory"),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Physical Inventory Journals action';
                }
                action("Revaluation Journals")
                {
                    Caption = 'Revaluation Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Revaluation),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Revaluation Journals action';
                }
                action("Retail Journal List")
                {
                    Caption = 'Retail Journal List';
                    Image = ResourceJournal;
                    RunObject = Page "NPR Retail Journal List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Journal List action';
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
                    ToolTip = 'Executes the Sales Orders action';
                }
                action(Items)
                {
                    Caption = 'Items';
                    RunObject = Page "Item List";
                    RunPageView = WHERE("NPR Magento Item" = CONST(true));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Items action';
                }
                action("Item Groups")
                {
                    Caption = 'Item Groups';
                    RunObject = Page "NPR Magento Categories";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Groups action';
                }
                action(Brands)
                {
                    Caption = 'Brands';
                    RunObject = Page "NPR Magento Brands";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Brands action';
                }
                action("Custom Options")
                {
                    Caption = 'Custom Options';
                    RunObject = Page "NPR Magento Custom Option List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Custom Options action';
                }
                action(Attributes)
                {
                    Caption = 'Attributes';
                    RunObject = Page "NPR Magento Attributes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Attributes action';
                }
                action("Attribute Sets")
                {
                    Caption = 'Attribute Sets';
                    RunObject = Page "NPR Magento Attribute Sets";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Attribute Sets action';
                }
                action("Payment Lines")
                {
                    Caption = 'Payment Lines';
                    RunObject = Page "NPR Magento Payment Line List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Payment Lines action';
                }
                action("Shipment Method Mapping")
                {
                    Caption = 'Shipment Method Mapping';
                    RunObject = Page "NPR Magento Shipment Mapping";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Shipment Method Mapping action';
                }
                action("Payment Method Mapping")
                {
                    Caption = 'Payment Method Mapping';
                    RunObject = Page "NPR Magento Payment Mapping";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Payment Method Mapping action';
                }

                action("NaviDocs Document List")
                {
                    Caption = 'NaviDocs Document List';
                    RunObject = Page "NPR NaviDocs Document List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NaviDocs Document List action';
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
                    ToolTip = 'Executes the Members action';
                }
                action(Memberships)
                {
                    Caption = 'Memberships';
                    RunObject = Page "NPR MM Memberships";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Memberships action';
                }
                action("Member Card List")
                {
                    Caption = 'Member Card List';
                    RunObject = Page "NPR MM Member Card List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Member Card List action';
                }
                action("MCS Faces")
                {
                    Caption = 'MCS Faces';
                    RunObject = Page "NPR MCS Faces";
                    ApplicationArea = All;
                    ToolTip = 'Executes the MCS Faces action';
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
                    ToolTip = 'Executes the Ticket List action';
                }
                action("Ticket Request")
                {
                    Caption = 'Ticket Request';
                    RunObject = Page "NPR TM Ticket Request";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Request action';
                }
                action("Ticket Type")
                {
                    Caption = 'Ticket Type';
                    RunObject = Page "NPR TM Ticket Type";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Type action';
                }
                action("Ticket BOM")
                {
                    Caption = 'Ticket BOM';
                    RunObject = Page "NPR TM Ticket BOM";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket BOM action';
                }
                action("Ticket Admissions")
                {
                    Caption = 'Ticket Admissions';
                    RunObject = Page "NPR TM Ticket Admissions";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Admissions action';
                }
                action("<Page TM Ticket Access Entry List>")
                {
                    Caption = 'Ticket Access Entry List';
                    RunObject = Page "NPR TM Ticket AccessEntry List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Ticket Access Entry List action';
                }
                action("Event List")
                {
                    Caption = 'Event List';
                    RunObject = Page "NPR Event List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Event List action';
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
                    ToolTip = 'Executes the Chart of Accounts action';
                }
                action("VAT Statements")
                {
                    Caption = 'VAT Statements';
                    RunObject = Page "VAT Statement Names";
                    ApplicationArea = All;
                    ToolTip = 'Executes the VAT Statements action';
                }
                action("Bank Accounts")
                {
                    Caption = 'Bank Accounts';
                    Image = BankAccount;
                    RunObject = Page "Bank Account List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Bank Accounts action';
                }
                action(Currencies)
                {
                    Caption = 'Currencies';
                    Image = Currency;
                    RunObject = Page Currencies;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Currencies action';
                }
                action("Accounting Periods")
                {
                    Caption = 'Accounting Periods';
                    Image = AccountingPeriods;
                    RunObject = Page "Accounting Periods";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Accounting Periods action';
                }
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page Dimensions;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions action';
                }
                action("Issued Reminders")
                {
                    Caption = 'Issued Reminders';
                    Image = OrderReminder;
                    RunObject = Page "Issued Reminder List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Issued Reminders action';
                }
                action("Issued Fin. Charge Memos")
                {
                    Caption = 'Issued Fin. Charge Memos';
                    Image = PostedMemo;
                    RunObject = Page "Issued Fin. Charge Memo List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Issued Fin. Charge Memos action';
                }
                action("Resource Journals")
                {
                    Caption = 'Resource Journals';
                    RunObject = Page "Resource Jnl. Batches";
                    RunPageView = WHERE(Recurring = CONST(false));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Resource Journals action';
                }
                action("FA Journals")
                {
                    Caption = 'FA Journals';
                    RunObject = Page "FA Journal Batches";
                    RunPageView = WHERE(Recurring = CONST(false));
                    ApplicationArea = All;
                    ToolTip = 'Executes the FA Journals action';
                }
                action("Cash Receipt Journals")
                {
                    Caption = 'Cash Receipt Journals';
                    Image = Journals;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Cash Receipts"),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Cash Receipt Journals action';
                }
                action("Payment Journals")
                {
                    Caption = 'Payment Journals';
                    Image = Journals;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Payments),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Payment Journals action';
                }
                action("General Journals")
                {
                    Caption = 'General Journals';
                    Image = Journal;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(General),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                    ToolTip = 'Executes the General Journals action';
                }
                action("Recurring Journals")
                {
                    Caption = 'Recurring Journals';
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(General),
                                        Recurring = CONST(true));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Recurring Journals action';
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
                    ToolTip = 'Executes the Customers action';
                }
                action("Salespeople/Purchasers")
                {
                    Caption = 'Salespeople/Purchasers';
                    RunObject = Page "Salespersons/Purchasers";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Salespeople/Purchasers action';
                }
                action("Contact List ")
                {
                    Caption = 'Contact List';
                    RunObject = Page "Contact List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Contact List action';
                }
                action(Orders)
                {
                    Caption = 'Orders';
                    RunObject = Page "Sales Order List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Orders action';
                }
                action(Invoices)
                {
                    Caption = 'Invoices';
                    RunObject = Page "Sales Invoice List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Invoices action';
                }
                action("Return Orders")
                {
                    Caption = 'Return Orders';
                    RunObject = Page "Sales Return Order List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Return Orders action';
                }
                action("Credit Memos")
                {
                    Caption = 'Credit Memos';
                    RunObject = Page "Sales Credit Memos";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Credit Memos action';
                }
                action("Customer Invoice Discount")
                {
                    Caption = 'Customer Invoice Discount';
                    RunObject = Page "Cust. Invoice Discounts";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Customer Invoice Discount action';
                }
                action("Posted Sales Shipments")
                {
                    Caption = 'Posted Sales Shipments';
                    Image = PostedShipment;
                    RunObject = Page "Posted Sales Shipments";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posted Sales Shipments action';
                }
                action("Posted Sales Invoices")
                {
                    Caption = 'Posted Sales Invoices';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Invoices";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posted Sales Invoices action';
                }
                action("Posted Sales Return Orders")
                {
                    Caption = 'Posted Sales Return Orders';
                    RunObject = Page "Posted Return Receipts";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posted Sales Return Orders action';
                }
                action("Posted Sales Credit Memos")
                {
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posted Sales Credit Memos action';
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
                    ToolTip = 'Executes the Vendor List action';
                }
                action("Purchase Orders")
                {
                    Caption = 'Purchase Orders';
                    RunObject = Page "Purchase Order List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Purchase Orders action';
                }
                action("Purchase Return Orders")
                {
                    Caption = 'Purchase Return Orders';
                    RunObject = Page "Purchase Return Order List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Purchase Return Orders action';
                }
                action("Purchase Invoices")
                {
                    Caption = 'Purchase Invoices';
                    RunObject = Page "Purchase Invoices";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Purchase Invoices action';
                }
                action("Purchase Credit Memos")
                {
                    Caption = 'Purchase Credit Memos';
                    RunObject = Page "Purchase Credit Memos";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Purchase Credit Memos action';
                }
                action("Posted Purchase Receipts")
                {
                    Caption = 'Posted Purchase Receipts';
                    RunObject = Page "Posted Purchase Receipts";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posted Purchase Receipts action';
                }
                action("Posted Purchase Invoices")
                {
                    Caption = 'Posted Purchase Invoices';
                    RunObject = Page "Posted Purchase Invoices";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posted Purchase Invoices action';
                }
                action("Posted Return Shipments")
                {
                    Caption = 'Posted Return Shipments';
                    RunObject = Page "Posted Return Shipments";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posted Return Shipments action';
                }
                action("Posted Purchase Credit Memos")
                {
                    Caption = 'Posted Purchase Credit Memos';
                    RunObject = Page "Posted Purchase Credit Memos";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posted Purchase Credit Memos action';
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
                    ToolTip = 'Executes the User Setup action';
                }
                action("Membership Setup")
                {
                    Caption = 'Membership Setup';
                    RunObject = Page "NPR MM Membership Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Membership Setup action';
                }
                action("Data Templates List")
                {
                    Caption = 'Data Templates List';
                    RunObject = Page "Config. Template List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Data Templates List action';
                }
                action("Reason Codes")
                {
                    Caption = 'Reason Codes';
                    RunObject = Page "Reason Codes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Reason Codes action';
                }
                action("Extended Texts")
                {
                    Caption = 'Extended Texts';
                    Image = Text;
                    RunObject = Page "Extended Text List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Extended Texts action';
                }
                action("POS Stores")
                {
                    Caption = 'POS Stores';
                    RunObject = Page "NPR POS Store List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Stores action';
                }
                action("POS Units")
                {
                    Caption = 'POS Units';
                    RunObject = Page "NPR POS Unit List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Units action';
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
                ToolTip = 'Executes the Sales &Order action';
            }
            action("Sales &Return Order")
            {
                Caption = 'Sales &Return Order';
                Image = ReturnOrder;
                RunObject = Page "Sales Return Order";
                RunPageMode = Create;
                ApplicationArea = All;
                ToolTip = 'Executes the Sales &Return Order action';
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
                ToolTip = 'Executes the Sales Credit &Memo action';
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
                ToolTip = 'Executes the &Transfer Order action';
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
                ToolTip = 'Executes the &Purchase Order action';
            }
            action("Purchase Credit Memo")
            {
                Caption = 'Purchase Credit Memo';
                Image = PurchaseTaxStatement;
                RunObject = Page "Purchase Credit Memo";
                ApplicationArea = All;
                ToolTip = 'Executes the Purchase Credit Memo action';
            }
            action("Purchase Return Order")
            {
                Caption = 'Purchase Return Order';
                Image = Document;
                RunObject = Page "Purchase Return Order";
                ApplicationArea = All;
                ToolTip = 'Executes the Purchase Return Order action';
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
                ToolTip = 'Executes the Adjust &Item Costs/Prices action';
            }
            action("Adjust &Cost - Item Entries")
            {
                Caption = 'Adjust &Cost - Item Entries';
                Image = AdjustEntries;
                RunObject = Report "Adjust Cost - Item Entries";
                ApplicationArea = All;
                ToolTip = 'Executes the Adjust &Cost - Item Entries action';
            }
            action("Application Worksheet")
            {
                Caption = 'Application Worksheet';
                Image = ApplicationWorksheet;
                RunObject = Page "Application Worksheet";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Application Worksheet action';
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
                ToolTip = 'Executes the General Le&dger Setup action';
            }
            action("S&ales && Receivables Setup")
            {
                Caption = 'S&ales && Receivables Setup';
                Image = Setup;
                RunObject = Page "Sales & Receivables Setup";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the S&ales && Receivables Setup action';
            }
            action("Company Information")
            {
                Caption = 'Company Information';
                Image = CompanyInformation;
                RunObject = Page "Company Information";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Company Information action';
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
                ToolTip = 'Executes the Navi&gate action';
            }
            action("NP Retail Setup")
            {
                Caption = 'NP Retail Setup';
                Image = Setup;
                RunObject = Page "NPR NP Retail Setup";
                ApplicationArea = All;
                ToolTip = 'Executes the NP Retail Setup action';
            }
            action(Action6014574)
            {
                Caption = 'Company Information';
                Image = CompanyInformation;
                RunObject = Page "Company Information";
                ApplicationArea = All;
                ToolTip = 'Executes the Company Information action';
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
                    ToolTip = 'Executes the NP Retail Setup action';
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
                    ToolTip = 'Executes the Sales - Invoice action';
                }
                action("Period Discount Statistics")
                {
                    Caption = 'Period Discount Statistics';
                    Image = "Report";
                    RunObject = Report "NPR Period Discount Stat.";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Period Discount Statistics action';
                }
                action("Sales per week year/Last year")
                {
                    Caption = 'Sales per week year/Last year';
                    Image = "Report";
                    RunObject = Report "NPR Sales per week year/Last";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales per week year/Last year action';
                }
                action("Sales Stat/Analysis")
                {
                    Caption = 'Sales Stat/Analysis';
                    Image = "Report";
                    RunObject = Report "NPR Sales Stat/Analysis";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Stat/Analysis action';
                }
                action("Sales Statistics Per Variety")
                {
                    Caption = 'Sales Statistics Per Variety';
                    Image = "Report";
                    RunObject = Report "NPR Sales Stats Per Variety";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Statistics Per Variety action';
                }
                action("Return Reason Code Statistics")
                {
                    Caption = 'Return Reason Code Statistics';
                    Image = "Report";
                    RunObject = Report "NPR Return Reason Code Stat.";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Return Reason Code Statistics action';
                }
            }
            group(Item)
            {
                Caption = 'Item';
                Visible = false;
                action("Inventory by age")
                {
                    Caption = 'Inventory by age';
                    Image = "Report";
                    RunObject = Report "NPR Inventory by age";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Inventory by age action';
                }
                action("Item Group Overview")
                {
                    Caption = 'Item Group Overview';
                    Image = "Report";
                    RunObject = Report "NPR Item Group Overview";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Group Overview action';
                }
                action("Inventory per Date")
                {
                    Caption = 'Inventory per Date';
                    Image = "Report";
                    RunObject = Report "NPR Inventory per Date";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Inventory per Date action';
                }
                action("Item Group Stat M/Y")
                {
                    Caption = 'Item Group Stat M/Y';
                    Image = "Report";
                    RunObject = Report "NPR Item Group Stat M/Y";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Group Stat M/Y action';
                }
                action("Sales Person Trn. by Item Gr.")
                {
                    Caption = 'Sales Person Trn. by Item Gr.';
                    Image = "Report";
                    RunObject = Report "NPR S.Person Trx by Item Gr.";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Person Trn. by Item Gr. action';
                }
                action("Item Group Inventory Value")
                {
                    Caption = 'Item Group Inventory Value';
                    Image = "Report";
                    RunObject = Report "NPR Item Group Inv. Value";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Group Inventory Value action';
                }
                action("Item Barcode Status Sheet")
                {
                    Caption = 'Item Barcode Status Sheet';
                    Image = "Report";
                    RunObject = Report "NPR Item Barcode Status Sheet";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Barcode Status Sheet action';
                }
                action("Item Replenishment by Store")
                {
                    Caption = 'Item Replenishment by Store';
                    Image = "Report";
                    RunObject = Report "NPR Item Replenish. by Store";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Replenishment by Store action';
                }
                action("Lager Kampagnestat")
                {
                    Caption = 'Lager Kampagnestat';
                    Image = "Report";
                    RunObject = Report "NPR Inventory Campaign Stat.";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Lager Kampagnestat action';
                }
                action("Item - Loss")
                {
                    Caption = 'Item - Loss';
                    Image = "Report";
                    RunObject = Report "NPR Item - Loss";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item - Loss action';
                }
                action("Item Loss - Return Reason")
                {
                    Caption = 'Item Loss - Return Reason';
                    Image = "Report";
                    RunObject = Report "NPR Item Loss - Ret. Reason";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Loss - Return Reason action';
                }
                action("Inventory per Variant at date")
                {
                    Caption = 'Inventory per Variant at date';
                    Image = "Report";
                    RunObject = Report "NPR Inventory per Variant/date";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Inventory per Variant at date action';
                }
                action("Adjust Cost - Item Entries TQ")
                {
                    Caption = 'Adjust Cost - Item Entries TQ';
                    Image = "Report";
                    RunObject = Report "NPR Adjust Cost: ItemEntriesTQ";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Adjust Cost - Item Entries TQ action';
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
                    ToolTip = 'Executes the Sales Statistics per Vendor action';
                }
                action("Vendor Sales Stat")
                {
                    Caption = 'Vendor Sales Stat';
                    Image = "Report";
                    RunObject = Report "NPR Vendor Sales Stat";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Vendor Sales Stat action';
                }
                action("Vendor Top/Sale")
                {
                    Caption = 'Vendor Top/Sale';
                    Image = "Report";
                    RunObject = Report "NPR Vendor Top/Sale";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Vendor Top/Sale action';
                }
                action("Vendor/Item Group")
                {
                    Caption = 'Vendor/Item Group';
                    Image = "Report";
                    RunObject = Report "NPR Vendor/Item Group";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Vendor/Item Group action';
                }
                action("Vendor trn. by Item group")
                {
                    Caption = 'Vendor trn. by Item group';
                    Image = "Report";
                    RunObject = Report "NPR Vendor trx by Item group";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Vendor trn. by Item group action';
                }
                action("Vendor/Salesperson")
                {
                    Caption = 'Vendor/Salesperson';
                    Image = "Report";
                    RunObject = Report "NPR Vendor/Salesperson";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Vendor/Salesperson action';
                }
            }
        }
    }
}

