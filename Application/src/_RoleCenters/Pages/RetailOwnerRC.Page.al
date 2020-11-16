page 6151259 "NPR Retail Owner RC"
{
    Caption = 'NP Retail Owner RC';
    PageType = RoleCenter;
    UsageCategory = Administration;

    layout
    {
        area(rolecenter)
        {

            part(Control6150616; "NPR Activities")
            {
                ApplicationArea = All;
            }

            part(Control16; "NPR Retail 10 Items by Qty.")
            {
                ApplicationArea = All;
            }
            part(NPRetailPOSEntryCue; "NPR POS Entry Cue")
            {
                Caption = 'POS Activities';
                ApplicationArea = All;
            }
            part(Control17; "NPR Retail Top 10 S.person")
            {
                ApplicationArea = All;
            }
            part(Control72; "NPR Retail Top 10 Customers")
            {
                ApplicationArea = All;
            }
            part(ControlPurchase; "NPR Acc. Payables Act")
            {
                Caption = 'Purchase Activities';
                ApplicationArea = All;
            }

            part(Top10vendors; "NPR Top 10 Vendors")
            {
                ApplicationArea = All;
            }
            part(Control73; "NPR My Reports")
            {
                ApplicationArea = All;
            }
            part(Control69; "Finance Performance")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control70; "Sales Performance")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control2; "Trailing Sales Orders Chart")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control66; "NPR Retail Sales Chart")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control78; "Small Business Owner Act.")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part(Control68; "Sales Performance")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part(Control12; "Report Inbox Part")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part(Control1907692008; "My Customers")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part(Control1902476008; "My Vendors")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part(Control99; "My Job Queue")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part(Control1905989608; "My Items")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            systempart(Control67; MyNotes)
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }

            part(PowerBi; "Power BI Report Spinner Part")
            {
                ApplicationArea = All;
            }

        }
    }

    actions
    {
        /*area(reporting)
        {
            separator(Separator75)
            {
            }
            action("Salesperson - Sales &Statistics")
            {
                ApplicationArea = Suite;
                Caption = 'Salesperson - Sales &Statistics';
                Image = "Report";
                RunObject = Report "Salesperson - Sales Statistics";
                ToolTip = 'View amounts for sales, profit, invoice discount, and payment discount, as well as profit percentage, for each salesperson for a selected period. The report also shows the adjusted profit and adjusted profit percentage, which reflect any changes to the original costs of the items in the sales.';
            }
            action("Price &List")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Price &List';
                Image = "Report";
                RunObject = Report "Price List";
                ToolTip = 'View a list of your items and their prices, for example, to send to customers. You can create the list for specific customers, campaigns, currencies, or other criteria.';
            }
            separator(Separator93)
            {
            }
            action("Inventory - Sales &Back Orders")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Inventory - Sales &Back Orders';
                Image = "Report";
                RunObject = Report "Inventory - Sales Back Orders";
                ToolTip = 'View a list with the order lines whose shipment date has been exceeded. The following information is shown for the individual orders for each item: number, customer name, customer''s telephone number, shipment date, order quantity and quantity on back order. The report also shows whether there are other items for the customer on back order.';
            }
            separator(Separator129)
            {
            }

        }
        */
        area(embedding)
        {
            /*
               action("Sales Quotes")
               {
                   ApplicationArea = Basic, Suite;
                   Caption = 'Sales Quotes';
                   Image = Quote;
                   RunObject = Page "Sales Quotes";
                   ToolTip = 'Make offers to customers to sell certain products on certain delivery and payment terms. While you negotiate with a customer, you can change and resend the sales quote as much as needed. When the customer accepts the offer, you convert the sales quote to a sales invoice or a sales order in which you process the sale.';
               }
               action("Sales Orders")
               {
                   ApplicationArea = Basic, Suite;
                   Caption = 'Sales Orders';
                   Image = "Order";
                   RunObject = Page "Sales Order List";
                   ToolTip = 'Record your agreements with customers to sell certain products on certain delivery and payment terms. Sales orders, unlike sales invoices, allow you to ship partially, deliver directly from your vendor to your customer, initiate warehouse handling, and print various customer-facing documents. Sales invoicing is integrated in the sales order process.';
               }
               action("Sales Orders - Microsoft Dynamics 365 for Sales")
               {
                   ApplicationArea = Suite;
                   Caption = 'Sales Orders - Microsoft Dynamics 365 for Sales';
                   RunObject = Page "CRM Sales Order List";
                   RunPageView = WHERE (StateCode = FILTER (Submitted),
                                       LastBackofficeSubmit = FILTER (0D));
                   ToolTip = 'View sales orders in Dynamics 365 for Sales that are coupled with sales orders in Business Central.';
               }
               action(CustomersBalance)
               {
                   ApplicationArea = Basic, Suite;
                   Caption = 'Balance';
                   Image = Balance;
                   RunObject = Page "Customer List";
                   RunPageView = WHERE ("Balance (LCY)" = FILTER (<> 0));
                   ToolTip = 'View a summary of the bank account balance in different periods.';
               }
               action("Purchase Orders")
               {
                   ApplicationArea = Basic, Suite;
                   Caption = 'Purchase Orders';
                   RunObject = Page "Purchase Order List";
                   ToolTip = 'Create purchase orders to mirror sales documents that vendors send to you. This enables you to record the cost of purchases and to track accounts payable. Posting purchase orders dynamically updates inventory levels so that you can minimize inventory costs and provide better customer service. Purchase orders allow partial receipts, unlike with purchase invoices, and enable drop shipment directly from your vendor to your customer. Purchase orders can be created automatically from PDF or image files from your vendors by using the Incoming Documents feature.';
               }
               action(VendorsBalance)
               {
                   ApplicationArea = Basic, Suite;
                   Caption = 'Balance';
                   Image = Balance;
                   RunObject = Page "Vendor List";
                   RunPageView = WHERE ("Balance (LCY)" = FILTER (<> 0));
                   ToolTip = 'View a summary of the bank account balance in different periods.';
               }
               */
        }
        area(sections)
        {
            group("Reference Data")
            {
                Caption = 'Reference Data';
                Image = Journals;
                action(Customers)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customers';
                    Image = Customer;
                    RunObject = Page "Customer List";
                    ToolTip = 'View or edit detailed information for the customers that you trade with. From each customer card, you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
                }
                action(Contacts)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Contacts';
                    Image = CustomerContact;
                    RunObject = Page "Contact List";
                    ToolTip = 'View a list of all your contacts.';
                }
                action(Vendors)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendors';
                    Image = Vendor;
                    RunObject = Page "Vendor List";
                    ToolTip = 'View or edit detailed information for the vendors that you trade with. From each vendor card, you can open related information, such as purchase statistics and ongoing orders, and you can define special prices and line discounts that the vendor grants you if certain conditions are met.';
                }
                /*
                action("POS Entry List")
                {
                    ApplicationArea = Basic, Suite;
                    Image = List;
                    RunObject = Page "POS Entry List";
                }
                */
                action("Retail Item List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Retail Item List';
                    Image = Item;
                    RunObject = Page "NPR Retail Item List";
                    ToolTip = 'View or edit detailed information for the products that you trade in. The item card can be of type Inventory or Service to specify if the item is a physical unit or a labor time unit. Here you also define if items in inventory or on incoming orders are automatically reserved for outbound documents and whether order tracking links are created between demand and supply to reflect planning actions.';
                }
                action("Salespeople/Purchasers")
                {
                    ApplicationArea = Suite;
                    Caption = 'Salespeople/Purchasers';
                    RunObject = Page "Salespersons/Purchasers";
                    ToolTip = 'View a list of your sales people and your purchasers.';
                }
            }
            group(Finance)
            {
                Caption = 'Finance';
                Image = Bank;
                action("VAT Statements")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Statements';
                    RunObject = Page "VAT Statement Names";
                    ToolTip = 'View a statement of posted VAT amounts, calculate your VAT settlement amount for a certain period, such as a quarter, and prepare to send the settlement to the tax authorities.';
                }
                action("Chart of Accounts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Chart of Accounts';
                    RunObject = Page "Chart of Accounts";
                    ToolTip = 'View the chart of accounts.';
                }
                action("Bank Accounts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Accounts';
                    Image = BankAccount;
                    RunObject = Page "Bank Account List";
                    ToolTip = 'View or set up detailed information about your bank account, such as which currency to use, the format of bank files that you import and export as electronic payments, and the numbering of checks.';
                }
                action(Currencies)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Currencies';
                    Image = Currency;
                    RunObject = Page Currencies;
                    ToolTip = 'View the different currencies that you trade in or update the exchange rates by getting the latest rates from an external service provider.';
                }
                action("Accounting Periods")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Accounting Periods';
                    Image = AccountingPeriods;
                    RunObject = Page "Accounting Periods";
                    ToolTip = 'Set up the number of accounting periods, such as 12 monthly periods, within the fiscal year and specify which period is the start of the new fiscal year.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page Dimensions;
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
                action("Bank Account Posting Groups")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Account Posting Groups';
                    RunObject = Page "Bank Account Posting Groups";
                    ToolTip = 'Set up posting groups, so that payments in and out of each bank account are posted to the specified general ledger account.';
                }
                action("Page Customer Ledger Entries")
                {
                    Caption = 'Customer Ledger Entries';
                    Image = Customer;
                    RunObject = Page "Customer Ledger Entries";
                    ApplicationArea = All;
                }
                action("Vendor Ledger Entries")
                {
                    Caption = 'Vendor Ledger Entries';
                    Image = Vendor;
                    RunObject = Page "Vendor Ledger Entries";
                    ApplicationArea = All;
                }
            }
            group("Posted Documents")
            {
                Caption = 'Posted Documents';
                Image = FiledPosted;
                action("Posted Sales Shipments")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Shipments';
                    Image = PostedShipment;
                    RunObject = Page "Posted Sales Shipments";
                    ToolTip = 'Open the list of posted sales shipments.';
                }
                action("Posted Sales Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Invoices';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Invoices";
                    ToolTip = 'Open the list of posted sales invoices.';
                }
                action("Posted Sales Credit Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'Open the list of posted sales credit memos.';
                }
                action("Posted Purchase Receipts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Receipts';
                    RunObject = Page "Posted Purchase Receipts";
                    ToolTip = 'Open the list of posted purchase receipts.';
                }
                action("Posted Purchase Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Invoices';
                    RunObject = Page "Posted Purchase Invoices";
                    ToolTip = 'Open the list of posted purchase invoices.';
                }
                action("Posted Purchase Credit Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Credit Memos';
                    RunObject = Page "Posted Purchase Credit Memos";
                    ToolTip = 'Open the list of posted purchase credit memos.';
                }
                action("Issued Reminders")
                {
                    ApplicationArea = Suite;
                    Caption = 'Issued Reminders';
                    Image = OrderReminder;
                    RunObject = Page "Issued Reminder List";
                    ToolTip = 'View the list of issued reminders.';
                }
                action("Retail Document List")
                {
                    ApplicationArea = Suite;
                    Caption = 'Retail Document List';
                    Image = Document;
                    RunObject = Page "NPR Retail Document List";
                }
                action("Repair Document List")
                {
                    Caption = 'Repair Document List';
                    Image = List;
                    RunObject = Page "NPR Customer Repair List";
                    ApplicationArea = All;
                }
                action("Warranty Catalog List")
                {
                    Caption = 'Warranty Catalog List';
                    Image = List;
                    RunObject = Page "NPR Warranty Catalog List";
                    ApplicationArea = All;
                }
            }
            group("Discount, Coupons & Vouchers")
            {
                Caption = 'Discount, Coupons & Vouchers';
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
                action("Coupon Types")
                {
                    Caption = 'Coupon Types';
                    RunObject = Page "NPR NpDc Coupon Types";
                    ApplicationArea = All;
                }
                action("Coupon List")
                {
                    Caption = 'Coupon List';
                    RunObject = Page "NPR NpDc Coupons";
                    ApplicationArea = All;
                }
                action("Voucher Types")
                {
                    Caption = 'Voucher Types';
                    RunObject = Page "NPR NpRv Voucher Types";
                    ApplicationArea = All;
                }
                action("Voucher List")
                {
                    Caption = 'Voucher List';
                    RunObject = Page "NPR NpRv Vouchers";
                    ApplicationArea = All;
                }
            }
        }

        area(Reporting)
        {



            group(Receivables)
            {
                Caption = 'Receivables';

                action(Customer)
                {
                    Caption = 'Customer';
                    Image = Customer;
                    RunObject = Page "Customer List";
                    ApplicationArea = All;
                }
                action("Cash Receipt Journal")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Receipt &Journal';
                    Image = CashReceiptJournal;
                    RunObject = Page "Cash Receipt Journal";
                    ToolTip = 'Open the cash receipt journal to post incoming payments.';
                }
                action("Sales Order")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Order';
                    Image = "Order";
                    RunObject = Page "Sales Order List";
                    ToolTip = 'Record your agreements with customers to sell certain products on certain delivery and payment terms. Sales orders, unlike sales invoices, allow you to ship partially, deliver directly from your vendor to your customer, initiate warehouse handling, and print various customer-facing documents. Sales invoicing is integrated in the sales order process.';

                }
                action("Sales Reminder")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Sales Reminder';
                    Image = Reminder;
                    Promoted = false;
                    RunObject = Page Reminder;
                    RunPageMode = Create;
                    ToolTip = 'Create a reminder to remind a customer of overdue payment.';
                }

                action("Sales Credit Memo")
                {
                    Caption = 'Sales Credit Memo';
                    ApplicationArea = Basic, Suite;
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'Open the list of posted sales credit memos.';
                }

            }

            group(Payables)
            {
                Caption = 'Payables';
                action(Vendor)
                {
                    Caption = 'Vendor';
                    ApplicationArea = Basic, Suite;
                    Image = Vendor;
                    RunObject = Page "Vendor List";

                }
                action("Vendor Payment Journal")
                {

                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendor Pa&yment Journal';
                    Image = VendorPaymentJournal;
                    RunObject = Page "Payment Journal";
                    ToolTip = 'Pay your vendors by filling the payment journal automatically according to payments due, and potentially export all payment to your bank for automatic processing.';

                }
                action("Purchase Order")
                {

                    ApplicationArea = Basic, Suite;
                    Caption = '&Purchase Order';
                    Image = Document;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Page "Purchase Order";
                    RunPageMode = Create;
                    ToolTip = 'Purchase goods or services from a vendor.';
                }


            }

            group(Bank)
            {
                Caption = 'Bank';
                action("Bank Account Reconciliation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Bank Account Reconciliation';
                    Image = BankAccountRec;
                    RunObject = Page "Bank Acc. Reconciliation";
                    ToolTip = 'Reconcile entries in your bank account ledger entries with the actual transactions in your bank account, according to the latest bank statement. ';
                }

            }

            group("Prices/Discounts")
            {
                Caption = 'Prices/Discounts';

                action("Sales Price Worksheet")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Price &Worksheet';
                    Image = PriceWorksheet;
                    RunObject = Page "Sales Price Worksheet";
                    ToolTip = 'Manage sales prices for individual customers, for a group of customers, for all customers, or for a campaign.';
                }

                action("Sales Prices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales P&rices';
                    Image = SalesPrices;
                    RunObject = Page "Sales Prices";
                    ToolTip = 'View or edit special sales prices that you grant when certain conditions are met, such as customer, quantity, or ending date. The price agreements can be for individual customers, for a group of customers, for all customers or for a campaign.';

                }
                action("Sales Line Discounts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales &Line Discounts';
                    Image = SalesLineDisc;
                    RunObject = Page "Sales Line Discounts";
                    ToolTip = 'View the sales line discounts that are available. These discount agreements can be for individual customers, for a group of customers, for all customers or for a campaign.';
                }

                action("Adjust Item Costs Prices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Adjust &Item Costs/Prices';
                    Image = AdjustItemCost;
                    RunObject = Report "Adjust Item Costs/Prices";
                    ToolTip = 'Adjusts the Last Direct Cost, Standard Cost, Unit Price, Profit %, and Indirect Cost % fields on the item or stockkeeping unit cards. For example, you can change Last Direct Cost by 5% on all items from a specific vendor. The changes are processed immediately when the batch job is started. The fields on the item card that are dependent on the adjusted field are also changed.';
                }


            }

            group(Reports)
            {

                Caption = 'Reports';
                group(RetailReport)
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

                group(ItemPricesReport)
                {
                    Caption = 'Item & Prices';

                    action("Price List")
                    {
                        Caption = 'Price List';
                        Image = Report2;
                        RunObject = Report "Price List";
                        ApplicationArea = All;
                    }
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
                group(ReceivablesReport)
                {
                    Caption = 'Receviables';
                    action("S&tatement")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'S&tatement';
                        Image = "Report";
                        RunObject = Report "Customer Statement";
                        ToolTip = 'View all entries for selected customers for a selected period. You can choose to have all overdue balances displayed, regardless of the period specified. You can also choose to include an aging band. For each currency, the report displays open entries and, if specified in the report, overdue entries. The statement can be sent to customers, for example, at the close of an accounting period or as a reminder of overdue balances.';
                    }
                    separator(Separator61)
                    {
                    }
                    action("Customer - Order Su&mmary")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customer - Order Su&mmary';
                        Image = "Report";
                        RunObject = Report "Customer - Order Summary";
                        ToolTip = 'View the order detail (the quantity not yet shipped) for each customer in three periods of 30 days each, starting from a selected date. There are also columns with orders to be shipped before and after the three periods and a column with the total order detail for each customer. The report can be used to analyze a company''s expected sales volume.';
                    }
                    action("Customer - T&op 10 List")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customer - T&op 10 List';
                        Image = "Report";
                        RunObject = Report "Customer - Top 10 List";
                        ToolTip = 'View which customers purchase the most or owe the most in a selected period. Only customers that have either purchases during the period or a balance at the end of the period will be included.';
                    }
                    action("Customer/&Item Sales")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customer/&Item Sales';
                        Image = "Report";
                        RunObject = Report "Customer/Item Sales";
                        ToolTip = 'View a list of item sales for each customer during a selected time period. The report contains information on quantity, sales amount, profit, and possible discounts. It can be used, for example, to analyze a company''s customer groups.';
                    }

                    action("Aged Ac&counts Receivable")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Aged Ac&counts Receivable';
                        Image = "Report";
                        RunObject = Report "Aged Accounts Receivable";
                        ToolTip = 'View an overview of when your receivables from customers are due or overdue (divided into four periods). You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
                    }


                }
                group(PayablesReport)
                {
                    Caption = 'Payables';

                    action("Top 10 Vendor List")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Top 10 Vendor List';
                        Image = "Report";
                        RunObject = Report "Vendor - Top 10 List";


                    }
                    action("Aged Accounts Pa&yable")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Aged Accounts Pa&yable';
                        Image = "Report";
                        RunObject = Report "Aged Accounts Payable";
                        ToolTip = 'View an overview of when your payables to vendors are due or overdue (divided into four periods). You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
                    }



                }
                group(FinanceReport)
                {
                    Caption = 'Finance';
                    action("&G/L Trial Balance")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = '&G/L Trial Balance';
                        Image = "Report";
                        RunObject = Report "Trial Balance";
                        ToolTip = 'View, print, or send a report that shows the balances for the general ledger accounts, including the debits and credits. You can use this report to ensure accurate accounting practices.';
                    }
                    action("Trial Balance by &Period")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Trial Balance by &Period';
                        Image = "Report";
                        RunObject = Report "Trial Balance by Period";
                        ToolTip = 'Show the opening balance by general ledger account, the movements in the selected period of month, quarter, or year, and the resulting closing balance.';
                    }
                    action("Closing T&rial Balance")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Closing T&rial Balance';
                        Image = "Report";
                        RunObject = Report "Closing Trial Balance";
                        ToolTip = 'View this year''s and last year''s figures as an ordinary trial balance. For income statement accounts, the balances are shown without closing entries. Closing entries are listed on a fictitious date that falls between the last day of one fiscal year and the first day of the next one. The closing of the income statement accounts is posted at the end of a fiscal year. The report can be used in connection with closing a fiscal year.';
                    }

                    separator(Separator53)
                    {
                    }
                    action("VAT Registration No. Chec&k")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Registration No. Chec&k';
                        Image = "Report";
                        RunObject = Report "VAT Registration No. Check";
                        ToolTip = 'Use an EU VAT number validation service to validated the VAT number of a business partner.';
                    }
                    action("VAT E&xceptions")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT E&xceptions';
                        Image = "Report";
                        RunObject = Report "VAT Exceptions";
                        ToolTip = 'View the VAT entries that were posted and placed in a general ledger register in connection with a VAT difference. The report is used to document adjustments made to VAT amounts that were calculated for use in internal or external auditing.';
                    }
                    action("V&AT Statement")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'V&AT Statement';
                        Image = "Report";
                        RunObject = Report "VAT Statement";
                        ToolTip = 'View a statement of posted VAT and calculate the duty liable to the customs authorities for the selected period.';
                    }

                    action("Reconcile Cust. and Vend. Accs")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Reconcile Cust. and Vend. Accs';
                        Image = "Report";
                        RunObject = Report "Reconcile Cust. and Vend. Accs";

                    }

                }

            }

        }
    }
}

