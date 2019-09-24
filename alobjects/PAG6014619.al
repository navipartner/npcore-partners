page 6014619 "Retail - Sales RC My Report"
{
    // #6014618/JC/20160110  CASE 258075 Created Object Retail Sales Role center Reports based on RC 6014557 Retail -Sales Psn Role center
    // NPR5.29/NPKNAV/20170127  CASE 258075 Transport NPR5.29 - 27 januar 2017
    // NPR5.31/TS  /20170328  CASE 270740 My Reports added
    // NPR5.41/TS  /20180405  CASE 300893 Removed Action Electronic Invoices

    Caption = 'Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control6150641)
            {
                ShowCaption = false;
                part(Control6150638;"Discount Activities")
                {
                    Visible = false;
                }
                group(Control6151401)
                {
                    ShowCaption = false;
                    part(Control6150616;"Retail Activities")
                    {
                    }
                }
            }
            group(Control6151405)
            {
                ShowCaption = false;
                part(Control6150615;"Retail Top 10 Customers")
                {
                }
                part(Control6150614;"Retail 10 Items by Qty.")
                {
                }
                part(Control6150613;"Retail Top 10 Salesperson")
                {
                }
            }
            group(Control6150632)
            {
                ShowCaption = false;
                part(Control6150617;"Retail Sales Chart")
                {
                }
                part(Control6014405;"RSS Reader Activities")
                {
                    Visible = false;
                }
                part(Control6014403;"Retail Sales Chart by Shop")
                {
                }
                part(Control6014406;"My Reports")
                {
                }
            }
        }
    }

    actions
    {
        area(embedding)
        {
            action(Attributes)
            {
                Caption = 'Attributes';
                RunObject = Page "Magento Attributes";
                Visible = false;
            }
            action("Attribute Sets")
            {
                Caption = 'Attribute Sets';
                RunObject = Page "Magento Attribute Sets";
                Visible = false;
            }
            action("Audit Roll")
            {
                Caption = 'Audit Roll';
                RunObject = Page "Audit Roll";
            }
            action(Brands)
            {
                Caption = 'Brands';
                RunObject = Page "Magento Brands";
                Visible = false;
            }
            action("Customers ")
            {
                Caption = 'Customers';
                RunObject = Page "Customer List";
            }
            action("Customer Repair")
            {
                Caption = 'Customer Repair';
                RunObject = Page "Customer Repair List";
            }
            action("Contact List ")
            {
                Caption = 'Contact List';
                RunObject = Page "Contact List";
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
            action("Item List")
            {
                Caption = 'Item List';
                RunObject = Page "Retail Item List";
            }
            action("Magento Item List")
            {
                Caption = '  Magento Items';
                RunObject = Page "Retail Item List";
                RunPageLink = "Magento Item"=CONST(true);
            }
            action("Item Groups")
            {
                Caption = 'Item Groups';
                RunObject = Page "Item Group Tree";
            }
            action("Magento Item Groups")
            {
                Caption = 'Magento Item Groups';
                RunObject = Page "Magento Item Groups";
                Visible = false;
            }
            action(MixedDiscounts)
            {
                Caption = 'Mixed Discounts';
                RunObject = Page "Mixed Discount List";
            }
            action(PeriodDiscounts)
            {
                Caption = 'Period Discounts';
                RunObject = Page "Campaign Discount List";
            }
            action(Pictures)
            {
                Caption = 'Pictures';
                RunObject = Page "Magento Pictures";
                Visible = false;
            }
            action("Purchase Orders")
            {
                Caption = 'Purchase Orders';
                RunObject = Page "Purchase Order List";
            }
            action("Retail Documents")
            {
                Caption = 'Retail Documents';
                RunObject = Page "Retail Document List";
            }
            action("Retail Journal")
            {
                Caption = 'Retail Journal';
                RunObject = Page "Retail Journal List";
            }
            action("Sales Orders")
            {
                Caption = 'Sales Orders';
                RunObject = Page "Sales Order List";
            }
            action("Sales Ticket Statistics")
            {
                Caption = 'Sales Ticket Statistics';
                RunObject = Page "Sales Ticket Statistics";
            }
            action("Transfer Orders")
            {
                Caption = 'Transfer Orders';
                RunObject = Page "Transfer Orders";
            }
        }
        area(reporting)
        {
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
        area(sections)
        {
            group(Journals)
            {
                Caption = 'Journals';
                Image = Journals;
                action("Item Journals")
                {
                    Caption = 'Item Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type"=CONST(Item),
                                        Recurring=CONST(false));
                }
                action("Physical Inventory Journals")
                {
                    Caption = 'Physical Inventory Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type"=CONST("Phys. Inventory"),
                                        Recurring=CONST(false));
                }
                action("Revaluation Journals")
                {
                    Caption = 'Revaluation Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type"=CONST(Revaluation),
                                        Recurring=CONST(false));
                }
                action("Resource Journals")
                {
                    Caption = 'Resource Journals';
                    RunObject = Page "Resource Jnl. Batches";
                    RunPageView = WHERE(Recurring=CONST(false));
                }
                action("FA Journals")
                {
                    Caption = 'FA Journals';
                    RunObject = Page "FA Journal Batches";
                    RunPageView = WHERE(Recurring=CONST(false));
                }
                action("Cash Receipt Journals")
                {
                    Caption = 'Cash Receipt Journals';
                    Image = Journals;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type"=CONST("Cash Receipts"),
                                        Recurring=CONST(false));
                }
                action("Payment Journals")
                {
                    Caption = 'Payment Journals';
                    Image = Journals;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type"=CONST(Payments),
                                        Recurring=CONST(false));
                }
                action("General Journals")
                {
                    Caption = 'General Journals';
                    Image = Journal;
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type"=CONST(General),
                                        Recurring=CONST(false));
                }
                action("Recurring Journals")
                {
                    Caption = 'Recurring Journals';
                    RunObject = Page "General Journal Batches";
                    RunPageView = WHERE("Template Type"=CONST(General),
                                        Recurring=CONST(true));
                }
            }
            group(Worksheets)
            {
                Caption = 'Worksheets';
                Image = Worksheets;
                action("Requisition Worksheets")
                {
                    Caption = 'Requisition Worksheets';
                    RunObject = Page "Req. Wksh. Names";
                    RunPageView = WHERE("Template Type"=CONST("Req."),
                                        Recurring=CONST(false));
                }
            }
            group("Posted Documents")
            {
                Caption = 'Posted Documents';
                Image = FiledPosted;
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
                action("Posted Sales Credit Memos")
                {
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
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
                action("Posted Purchase Credit Memos")
                {
                    Caption = 'Posted Purchase Credit Memos';
                    RunObject = Page "Posted Purchase Credit Memos";
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
            }
            group(Finance)
            {
                Caption = 'Finance';
                Image = Bank;
                action("VAT Statements")
                {
                    Caption = 'VAT Statements';
                    RunObject = Page "VAT Statement Names";
                }
                action("Chart of Accounts")
                {
                    Caption = 'Chart of Accounts';
                    RunObject = Page "Chart of Accounts";
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
                action("Bank Account Posting Groups")
                {
                    Caption = 'Bank Account Posting Groups';
                    RunObject = Page "Bank Account Posting Groups";
                }
            }
            group(Marketing)
            {
                Caption = 'Marketing';
                Image = Marketing;
                action(Contacts)
                {
                    Caption = 'Contacts';
                    Image = CustomerContact;
                    RunObject = Page "Contact List";
                }
                action("To-dos")
                {
                    Caption = 'To-dos';
                    Image = TaskList;
                    RunObject = Page "Task List";
                }
            }
            group(Sales)
            {
                Caption = 'Sales';
                Image = Sales;
                action("Assembly BOM")
                {
                    Caption = 'Assembly BOM';
                    Image = AssemblyBOM;
                    RunObject = Page "Assembly BOM";
                }
                action("Sales Credit Memos")
                {
                    Caption = 'Sales Credit Memos';
                    RunObject = Page "Sales Credit Memos";
                }
                action("Standard Sales Codes")
                {
                    Caption = 'Standard Sales Codes';
                    RunObject = Page "Standard Sales Codes";
                }
                action("Salespeople/Purchasers")
                {
                    Caption = 'Salespeople/Purchasers';
                    RunObject = Page "Salespersons/Purchasers";
                }
                action("Customer Invoice Discount")
                {
                    Caption = 'Customer Invoice Discount';
                    RunObject = Page "Cust. Invoice Discounts";
                }
            }
            group(Purchase)
            {
                Caption = 'Purchase';
                Image = purchasing;
                action("Standard Purchase Codes")
                {
                    Caption = 'Standard Purchase Codes';
                    RunObject = Page "Standard Purchase Codes";
                }
                action("Vendor Invoice Discounts")
                {
                    Caption = 'Vendor Invoice Discounts';
                    RunObject = Page "Vend. Invoice Discounts";
                }
                action("Item Discount Groups")
                {
                    Caption = 'Item Discount Groups';
                    RunObject = Page "Item Disc. Groups";
                }
            }
            group(Resources)
            {
                Caption = 'Resources';
                Image = ResourcePlanning;
                action(Action6150718)
                {
                    Caption = 'Resources';
                    RunObject = Page "Resource List";
                }
                action("Resource Groups")
                {
                    Caption = 'Resource Groups';
                    RunObject = Page "Resource Groups";
                }
                action("Resource Price Changes")
                {
                    Caption = 'Resource Price Changes';
                    Image = ResourcePrice;
                    RunObject = Page "Resource Price Changes";
                }
                action("Resource Registers")
                {
                    Caption = 'Resource Registers';
                    Image = ResourceRegisters;
                    RunObject = Page "Resource Registers";
                }
            }
            group("Human Resources")
            {
                Caption = 'Human Resources';
                Image = HumanResources;
                action(Employees)
                {
                    Caption = 'Employees';
                    Image = Employee;
                    RunObject = Page "Employee List";
                }
            }
            group("Fixed Assets")
            {
                Caption = 'Fixed Assets';
                Image = FixedAssets;
                action(Action6150711)
                {
                    Caption = 'Fixed Assets';
                    RunObject = Page "Fixed Asset List";
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
                action("Data Templates List")
                {
                    Caption = 'Data Templates List';
                    RunObject = Page "Config. Template List";
                }
                action("Base Calendar List")
                {
                    Caption = 'Base Calendar List';
                    RunObject = Page "Base Calendar List";
                }
                action("Post Codes")
                {
                    Caption = 'Post Codes';
                    RunObject = Page "Post Codes";
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
            }
        }
        area(creation)
        {
            action("C&ustomer")
            {
                Caption = 'C&ustomer';
                Image = Customer;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "Customer Card";
                RunPageMode = Create;
            }
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
            action("&Sales Reminder")
            {
                Caption = '&Sales Reminder';
                Image = Reminder;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page Reminder;
                RunPageMode = Create;
            }
            separator(Separator6150698)
            {
            }
            action("&Vendor")
            {
                Caption = '&Vendor';
                Image = Vendor;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "Vendor Card";
                RunPageMode = Create;
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
        }
        area(processing)
        {
            separator(Tasks)
            {
                Caption = 'Tasks';
                IsHeader = true;
            }
            action("Cash Receipt &Journal")
            {
                Caption = 'Cash Receipt &Journal';
                Image = CashReceiptJournal;
                RunObject = Page "Cash Receipt Journal";
            }
            action("Vendor Pa&yment Journal")
            {
                Caption = 'Vendor Pa&yment Journal';
                Image = VendorPaymentJournal;
                RunObject = Page "Payment Journal";
            }
            action("Sales Price &Worksheet")
            {
                Caption = 'Sales Price &Worksheet';
                Image = PriceWorksheet;
                RunObject = Page "Sales Price Worksheet";
            }
            action("Sales P&rices")
            {
                Caption = 'Sales P&rices';
                Image = SalesPrices;
                RunObject = Page "Sales Prices";
            }
            action("Sales &Line Discounts")
            {
                Caption = 'Sales &Line Discounts';
                Image = SalesLineDisc;
                RunObject = Page "Sales Line Discounts";
            }
            action("Create Electronic Credit Memos")
            {
                Caption = 'Create Electronic Credit Memos';
                Image = ElectronicDoc;
                //RunObject = Report Report13601;
            }
            action("Create Electronic Reminders")
            {
                Caption = 'Create Electronic Reminders';
                Image = "Report";
                //RunObject = Report Report13602;
            }
            action("Create Electronic Fin. Chrg. Memos")
            {
                Caption = 'Create Electronic Fin. Chrg. Memos';
                Image = ElectronicDoc;
                //RunObject = Report Report13603;
            }
            action("Create Electronic Service Invoices")
            {
                Caption = 'Create Electronic Service Invoices';
                Image = ElectronicDoc;
                //RunObject = Report Report13604;
            }
            action("Create Electronic Service Credit Memos")
            {
                Caption = 'Create Electronic Service Credit Memos';
                Image = ElectronicDoc;
                //RunObject = Report Report13605;
            }
            separator(Separator6150682)
            {
            }
            action("&Bank Account Reconciliation")
            {
                Caption = '&Bank Account Reconciliation';
                Image = BankAccountRec;
                RunObject = Page "Bank Acc. Reconciliation";
            }
            action("Payment Registration")
            {
                Caption = 'Payment Registration';
                Image = Payment;
                RunObject = Codeunit "Payment Registration Mgt.";
            }
            action("Adjust E&xchange Rates")
            {
                Caption = 'Adjust E&xchange Rates';
                Ellipsis = true;
                Image = AdjustExchangeRates;
                RunObject = Report "Adjust Exchange Rates";
            }
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
            action("Post Inve&ntory Cost to G/L")
            {
                Caption = 'Post Inve&ntory Cost to G/L';
                Ellipsis = true;
                Image = PostInventoryToGL;
                RunObject = Report "Post Inventory Cost to G/L";
            }
            action("Calc. and Post VAT Settlem&ent")
            {
                Caption = 'Calc. and Post VAT Settlem&ent';
                Ellipsis = true;
                Image = SettleOpenTransactions;
                RunObject = Report "Calc. and Post VAT Settlement";
            }
            separator(Separator6150674)
            {
                Caption = 'Administration';
                IsHeader = true;
            }
            action("General Le&dger Setup")
            {
                Caption = 'General Le&dger Setup';
                Image = Setup;
                RunObject = Page "General Ledger Setup";
            }
            action("S&ales && Receivables Setup")
            {
                Caption = 'S&ales && Receivables Setup';
                Image = Setup;
                RunObject = Page "Sales & Receivables Setup";
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
        }
    }
}

