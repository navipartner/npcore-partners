page 6014619 "NPR Retail - Sales RC MyReport"
{
    Caption = 'Role Center';
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
                group(Control6151401)
                {
                    ShowCaption = false;
                    part(Control6150616; "NPR Retail Activities")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Control6151405)
            {
                ShowCaption = false;
                part(Control6150615; "NPR Retail Top 10 Customers")
                {
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
            }
            group(Control6150632)
            {
                ShowCaption = false;
                part(Control6150617; "NPR Retail Sales Chart")
                {
                    ApplicationArea = All;
                }

                part(Control6014403; "NPR Retail Sales Chart by Shop")
                {
                    ApplicationArea = All;
                }
                part(Control6014406; "NPR My Reports")
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
            action(Attributes)
            {
                Caption = 'Attributes';
                RunObject = Page "NPR Magento Attributes";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Attributes action';
            }
            action("Attribute Sets")
            {
                Caption = 'Attribute Sets';
                RunObject = Page "NPR Magento Attribute Sets";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Attribute Sets action';
            }
            action("Audit Roll")
            {
                Caption = 'Audit Roll';
                RunObject = Page "NPR Audit Roll";
                ApplicationArea = All;
                ToolTip = 'Executes the Audit Roll action';
            }
            action(Brands)
            {
                Caption = 'Brands';
                RunObject = Page "NPR Magento Brands";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Brands action';
            }
            action("Customers ")
            {
                Caption = 'Customers';
                RunObject = Page "Customer List";
                ApplicationArea = All;
                ToolTip = 'Executes the Customers action';
            }
            action("Customer Repair")
            {
                Caption = 'Customer Repair';
                RunObject = Page "NPR Customer Repair List";
                ApplicationArea = All;
                ToolTip = 'Executes the Customer Repair action';
            }
            action("Contact List ")
            {
                Caption = 'Contact List';
                RunObject = Page "Contact List";
                ApplicationArea = All;
                ToolTip = 'Executes the Contact List action';
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
            action("Item List")
            {
                Caption = 'Item List';
                RunObject = Page "Item List";
                ApplicationArea = All;
                ToolTip = 'Executes the Item List action';
            }
            action("Magento Item List")
            {
                Caption = '  Magento Items';
                RunObject = Page "Item List";
                RunPageLink = "NPR Magento Item" = CONST(true);
                ApplicationArea = All;
                ToolTip = 'Executes the   Magento Items action';
            }
            action("Item Groups")
            {
                Caption = 'Item Groups';
                RunObject = Page "NPR Item Group Tree";
                ApplicationArea = All;
                ToolTip = 'Executes the Item Groups action';
            }
            action("Magento Item Groups")
            {
                Caption = 'Magento Item Groups';
                RunObject = Page "NPR Magento Categories";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Magento Item Groups action';
            }
            action(MixedDiscounts)
            {
                Caption = 'Mixed Discounts';
                RunObject = Page "NPR Mixed Discount List";
                ApplicationArea = All;
                ToolTip = 'Executes the Mixed Discounts action';
            }
            action(PeriodDiscounts)
            {
                Caption = 'Period Discounts';
                RunObject = Page "NPR Campaign Discount List";
                ApplicationArea = All;
                ToolTip = 'Executes the Period Discounts action';
            }
            action(Pictures)
            {
                Caption = 'Pictures';
                RunObject = Page "NPR Magento Pictures";
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Pictures action';
            }
            action("Purchase Orders")
            {
                Caption = 'Purchase Orders';
                RunObject = Page "Purchase Order List";
                ApplicationArea = All;
                ToolTip = 'Executes the Purchase Orders action';
            }
            action("Retail Documents")
            {
                Caption = 'Retail Documents';
                RunObject = Page "NPR Retail Document List";
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Documents action';
            }
            action("Retail Journal")
            {
                Caption = 'Retail Journal';
                RunObject = Page "NPR Retail Journal List";
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Journal action';
            }
            action("Sales Orders")
            {
                Caption = 'Sales Orders';
                RunObject = Page "Sales Order List";
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Orders action';
            }
            action("Sales Ticket Statistics")
            {
                Caption = 'Sales Ticket Statistics';
                RunObject = Page "NPR Sales Ticket Statistics";
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Ticket Statistics action';
            }
            action("Transfer Orders")
            {
                Caption = 'Transfer Orders';
                RunObject = Page "Transfer Orders";
                ApplicationArea = All;
                ToolTip = 'Executes the Transfer Orders action';
            }
        }
        area(reporting)
        {
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
            group(Worksheets)
            {
                Caption = 'Worksheets';
                Image = Worksheets;
                action("Requisition Worksheets")
                {
                    Caption = 'Requisition Worksheets';
                    RunObject = Page "Req. Wksh. Names";
                    RunPageView = WHERE("Template Type" = CONST("Req."),
                                        Recurring = CONST(false));
                    ApplicationArea = All;
                    ToolTip = 'Executes the Requisition Worksheets action';
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
                action("Posted Sales Credit Memos")
                {
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posted Sales Credit Memos action';
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
                action("Posted Purchase Credit Memos")
                {
                    Caption = 'Posted Purchase Credit Memos';
                    RunObject = Page "Posted Purchase Credit Memos";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Posted Purchase Credit Memos action';
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
            }
            group(Finance)
            {
                Caption = 'Finance';
                Image = Bank;
                action("VAT Statements")
                {
                    Caption = 'VAT Statements';
                    RunObject = Page "VAT Statement Names";
                    ApplicationArea = All;
                    ToolTip = 'Executes the VAT Statements action';
                }
                action("Chart of Accounts")
                {
                    Caption = 'Chart of Accounts';
                    RunObject = Page "Chart of Accounts";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Chart of Accounts action';
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
                action("Bank Account Posting Groups")
                {
                    Caption = 'Bank Account Posting Groups';
                    RunObject = Page "Bank Account Posting Groups";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Bank Account Posting Groups action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Contacts action';
                }
                action("To-dos")
                {
                    Caption = 'To-dos';
                    Image = TaskList;
                    RunObject = Page "Task List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the To-dos action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Assembly BOM action';
                }
                action("Sales Credit Memos")
                {
                    Caption = 'Sales Credit Memos';
                    RunObject = Page "Sales Credit Memos";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales Credit Memos action';
                }
                action("Standard Sales Codes")
                {
                    Caption = 'Standard Sales Codes';
                    RunObject = Page "Standard Sales Codes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Standard Sales Codes action';
                }
                action("Salespeople/Purchasers")
                {
                    Caption = 'Salespeople/Purchasers';
                    RunObject = Page "Salespersons/Purchasers";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Salespeople/Purchasers action';
                }
                action("Customer Invoice Discount")
                {
                    Caption = 'Customer Invoice Discount';
                    RunObject = Page "Cust. Invoice Discounts";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Customer Invoice Discount action';
                }
            }
            group(Purchase)
            {
                Caption = 'Purchase';
                Image = Purchasing;
                action("Standard Purchase Codes")
                {
                    Caption = 'Standard Purchase Codes';
                    RunObject = Page "Standard Purchase Codes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Standard Purchase Codes action';
                }
                action("Vendor Invoice Discounts")
                {
                    Caption = 'Vendor Invoice Discounts';
                    RunObject = Page "Vend. Invoice Discounts";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Vendor Invoice Discounts action';
                }
                action("Item Discount Groups")
                {
                    Caption = 'Item Discount Groups';
                    RunObject = Page "Item Disc. Groups";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Discount Groups action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Resources action';
                }
                action("Resource Groups")
                {
                    Caption = 'Resource Groups';
                    RunObject = Page "Resource Groups";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Resource Groups action';
                }
                action("Resource Price Changes")
                {
                    Caption = 'Resource Price Changes';
                    Image = ResourcePrice;
                    RunObject = Page "Resource Price Changes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Resource Price Changes action';
                }
                action("Resource Registers")
                {
                    Caption = 'Resource Registers';
                    Image = ResourceRegisters;
                    RunObject = Page "Resource Registers";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Resource Registers action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Employees action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Fixed Assets action';
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
                action("Data Templates List")
                {
                    Caption = 'Data Templates List';
                    RunObject = Page "Config. Template List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Data Templates List action';
                }
                action("Base Calendar List")
                {
                    Caption = 'Base Calendar List';
                    RunObject = Page "Base Calendar List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Base Calendar List action';
                }
                action("Post Codes")
                {
                    Caption = 'Post Codes';
                    RunObject = Page "Post Codes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Post Codes action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the C&ustomer action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Sales &Order action';
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
            action("&Sales Reminder")
            {
                Caption = '&Sales Reminder';
                Image = Reminder;
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page Reminder;
                RunPageMode = Create;
                ApplicationArea = All;
                ToolTip = 'Executes the &Sales Reminder action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the &Vendor action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Cash Receipt &Journal action';
            }
            action("Vendor Pa&yment Journal")
            {
                Caption = 'Vendor Pa&yment Journal';
                Image = VendorPaymentJournal;
                RunObject = Page "Payment Journal";
                ApplicationArea = All;
                ToolTip = 'Executes the Vendor Pa&yment Journal action';
            }
            action("Sales Price &Worksheet")
            {
                Caption = 'Sales Price &Worksheet';
                Image = PriceWorksheet;
                RunObject = Page "Sales Price Worksheet";
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Price &Worksheet action';
            }
            action("Sales P&rices")
            {
                Caption = 'Sales P&rices';
                Image = SalesPrices;
                RunObject = Page "Sales Prices";
                ApplicationArea = All;
                ToolTip = 'Executes the Sales P&rices action';
            }
            action("Sales &Line Discounts")
            {
                Caption = 'Sales &Line Discounts';
                Image = SalesLineDisc;
                RunObject = Page "Sales Line Discounts";
                ApplicationArea = All;
                ToolTip = 'Executes the Sales &Line Discounts action';
            }
            action("Create Electronic Credit Memos")
            {
                Caption = 'Create Electronic Credit Memos';
                Image = ElectronicDoc;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Electronic Credit Memos action';
                //RunObject = Report Report13601;
            }
            action("Create Electronic Reminders")
            {
                Caption = 'Create Electronic Reminders';
                Image = "Report";
                ApplicationArea = All;
                ToolTip = 'Executes the Create Electronic Reminders action';
                //RunObject = Report Report13602;
            }
            action("Create Electronic Fin. Chrg. Memos")
            {
                Caption = 'Create Electronic Fin. Chrg. Memos';
                Image = ElectronicDoc;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Electronic Fin. Chrg. Memos action';
                //RunObject = Report Report13603;
            }
            action("Create Electronic Service Invoices")
            {
                Caption = 'Create Electronic Service Invoices';
                Image = ElectronicDoc;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Electronic Service Invoices action';
                //RunObject = Report Report13604;
            }
            action("Create Electronic Service Credit Memos")
            {
                Caption = 'Create Electronic Service Credit Memos';
                Image = ElectronicDoc;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Electronic Service Credit Memos action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the &Bank Account Reconciliation action';
            }
            action("Payment Registration")
            {
                Caption = 'Payment Registration';
                Image = Payment;
                RunObject = Codeunit "Payment Registration Mgt.";
                ApplicationArea = All;
                ToolTip = 'Executes the Payment Registration action';
            }
            action("Adjust E&xchange Rates")
            {
                Caption = 'Adjust E&xchange Rates';
                Ellipsis = true;
                Image = AdjustExchangeRates;
                RunObject = Report "Adjust Exchange Rates";
                ApplicationArea = All;
                ToolTip = 'Executes the Adjust E&xchange Rates action';
            }
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
            action("Post Inve&ntory Cost to G/L")
            {
                Caption = 'Post Inve&ntory Cost to G/L';
                Ellipsis = true;
                Image = PostInventoryToGL;
                RunObject = Report "Post Inventory Cost to G/L";
                ApplicationArea = All;
                ToolTip = 'Executes the Post Inve&ntory Cost to G/L action';
            }
            action("Calc. and Post VAT Settlem&ent")
            {
                Caption = 'Calc. and Post VAT Settlem&ent';
                Ellipsis = true;
                Image = SettleOpenTransactions;
                RunObject = Report "Calc. and Post VAT Settlement";
                ApplicationArea = All;
                ToolTip = 'Executes the Calc. and Post VAT Settlem&ent action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the General Le&dger Setup action';
            }
            action("S&ales && Receivables Setup")
            {
                Caption = 'S&ales && Receivables Setup';
                Image = Setup;
                RunObject = Page "Sales & Receivables Setup";
                ApplicationArea = All;
                ToolTip = 'Executes the S&ales && Receivables Setup action';
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
        }
    }
}

