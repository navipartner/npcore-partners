page 6014697 "NPR Customers Smart Search"
{
    Extensible = False;
    Caption = 'Customers';
    CardPageID = "Customer Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    Editable = true;
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,Approve,New Document,Request Approval,Customer,Navigate';
    SourceTable = Customer;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field(Search; _SearchTerm)
            {
                Editable = true;
                Caption = 'Smart Search';
                ApplicationArea = NPRRetail;
                ToolTip = 'This search is optimized to search relevant columns only.';
                trigger OnValidate()
                var
                    Customer: Record Customer;
                    SmartSearch: Codeunit "NPR Smart Search";
                begin
                    Rec.Reset();
                    Rec.ClearMarks();
                    Rec.MarkedOnly(false);

                    if TableView <> '' then begin
                        Rec.SetView(TableView);
                        Customer.SetView(TableView);
                    end;

                    if (_SearchTerm = '') then begin
                        CurrPage.Update(false);
                        exit;
                    end;

                    SmartSearch.SearchCustomer(_SearchTerm, Customer);

                    Rec.Copy(Customer);
                    Rec.SetLoadFields();
                    Rec.MarkedOnly(true);
                    CurrPage.Update(false);
                end;
            }

            repeater(Control1)
            {
                ShowCaption = false;
                Editable = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the customer''s name. This name will appear on all sales documents for the customer.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code of the responsibility center, such as a distribution hub, that is associated with the involved user, company, customer, or vendor.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies from which location sales to this customer will be processed by default.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the customer''s telephone number.';
                }
                field(Contact; Rec.Contact)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the name of the person you regularly contact when you do business with this customer.';
                }
                field("Balance (LCY)"; Rec."Balance (LCY)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the payment amount that the customer owes for completed sales. This value is also known as the customer''s balance.';

                    trigger OnDrillDown()
                    begin
                        Rec.OpenCustomerLedgerEntries(false);
                    end;
                }
                field("Balance Due (LCY)"; Rec."Balance Due (LCY)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies payments from the customer that are overdue per today''s date.';

                    trigger OnDrillDown()
                    begin
                        Rec.OpenCustomerLedgerEntries(true);
                    end;
                }
                field("Sales (LCY)"; Rec."Sales (LCY)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the total net amount of sales to the customer in LCY.';
                }
                field("Payments (LCY)"; Rec."Payments (LCY)")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the sum of payments received from the customer.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Customer")
            {
                Caption = '&Customer';
                Image = Customer;
                action("Co&mments")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category7;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST(Customer),
                                  "No." = FIELD("No.");
                    ToolTip = 'View or add comments for the record.';
                }

                action(New)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'New';
                    Image = NewCustomer;
                    Promoted = true;
                    ToolTip = 'Create a customer from a template';

                    trigger OnAction()
                    begin
                        CreateCustomerFromTemplate();
                    end;
                }

                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action(DimensionsSingle)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(18),
                                      "No." = FIELD("No.");
                        ShortCutKey = 'Alt+D';
                        ToolTip = 'View or edit the single set of dimensions that are set up for the selected record.';
                    }
                    action(DimensionsMultiple)
                    {
                        AccessByPermission = TableData Dimension = R;
                        ApplicationArea = NPRRetail;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';

                        trigger OnAction()
                        var
                            Cust: Record Customer;
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(Cust);
                            DefaultDimMultiple.SetMultiRecord(Cust, Rec.FieldNo("No."));
                            DefaultDimMultiple.RunModal();
                        end;
                    }
                }
                action("Bank Accounts")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Bank Accounts';
                    Image = BankAccount;
                    RunObject = Page "Customer Bank Account List";
                    RunPageLink = "Customer No." = FIELD("No.");
                    ToolTip = 'View or set up the customer''s bank accounts. You can set up any number of bank accounts for each customer.';
                }
                action("Direct Debit Mandates")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Direct Debit Mandates';
                    Image = MakeAgreement;
                    RunObject = Page "SEPA Direct Debit Mandates";
                    RunPageLink = "Customer No." = FIELD("No.");
                    ToolTip = 'View the direct-debit mandates that reflect agreements with customers to collect invoice payments from their bank account.';
                }
                action(ShipToAddresses)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Ship-&to Addresses';
                    Image = ShipAddress;
                    RunObject = Page "Ship-to Address List";
                    RunPageLink = "Customer No." = FIELD("No.");
                    ToolTip = 'View or edit alternate shipping addresses where the customer wants items delivered if different from the regular address.';
                }
                action("C&ontact")
                {
                    AccessByPermission = TableData Contact = R;
                    ApplicationArea = NPRRetail;
                    Caption = 'C&ontact';
                    Image = ContactPerson;
                    Promoted = true;
                    PromotedCategory = Category8;
                    ToolTip = 'View or edit detailed information about the contact person at the customer.';

                    trigger OnAction()
                    begin
                        Rec.ShowContact();
                    end;
                }
                action("Item References")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Item Refe&rences';
#if BC17 or BC18
                    Visible = ItemReferenceVisible;
#endif
                    Image = Change;
                    Promoted = true;
                    PromotedCategory = Category7;
                    RunObject = Page "Item References";
                    RunPageLink = "Reference Type" = CONST(Customer),
                                  "Reference Type No." = FIELD("No.");
                    RunPageView = SORTING("Reference Type", "Reference Type No.");
                    ToolTip = 'Set up the customer''s own identification of items that you sell to the customer. Item references to the customer''s item number means that the item number is automatically shown on sales documents instead of the number that you use.';
                }
                action(ApprovalEntries)
                {
                    AccessByPermission = TableData "Approval Entry" = R;
                    ApplicationArea = NPRRetail;
                    Caption = 'Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Category7;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction()
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action(CustomerLedgerEntries)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Ledger E&ntries';
                    Image = CustomerLedger;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = true;
                    RunObject = Page "Customer Ledger Entries";
                    RunPageLink = "Customer No." = FIELD("No.");
                    RunPageView = SORTING("Customer No.")
                                  ORDER(Descending);
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                }
                action(Statistics)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = true;
                    RunObject = Page "Customer Statistics";
                    RunPageLink = "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter"),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                }
                action("S&ales")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'S&ales';
                    Image = Sales;
                    RunObject = Page "Customer Sales";
                    RunPageLink = "No." = FIELD("No."),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter");
                    ToolTip = 'Shows a summary of customer ledger entries. You select the time interval in the View by field. The Period column on the left contains a series of dates that are determined by the time interval you have selected.';
                }
                action("Entry Statistics")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Entry Statistics';
                    Image = EntryStatistics;
                    RunObject = Page "Customer Entry Statistics";
                    RunPageLink = "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter"),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter");
                    ToolTip = 'View entry statistics for the record.';
                }
                action("Statistics by C&urrencies")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Statistics by C&urrencies';
                    Image = Currencies;
                    RunObject = Page "Cust. Stats. by Curr. Lines";
                    RunPageLink = "Customer Filter" = FIELD("No."),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                                  "Date Filter" = FIELD("Date Filter");
                    ToolTip = 'View statistics for customers that use multiple currencies.';
                }
            }
            group(Action24)
            {
                Caption = 'S&ales';
                Image = Sales;
                action("Sales_InvoiceDiscounts")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Invoice &Discounts';
                    Image = CalculateInvoiceDiscount;
                    RunObject = Page "Cust. Invoice Discounts";
                    RunPageLink = Code = FIELD("Invoice Disc. Code");
                    ToolTip = 'Set up different discounts that are applied to invoices for the customer. An invoice discount is automatically granted to the customer when the total on a sales invoice exceeds a certain amount.';
                }
                action("Prepa&yment Percentages")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Prepa&yment Percentages';
                    Image = PrepaymentPercentages;
                    RunObject = Page "Sales Prepayment Percentages";
                    RunPageLink = "Sales Type" = CONST(Customer),
                                  "Sales Code" = FIELD("No.");
                    RunPageView = SORTING("Sales Type", "Sales Code");
                    ToolTip = 'View or edit the percentages of the price that can be paid as a prepayment. ';
                }
                action("Recurring Sales Lines")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Recurring Sales Lines';
                    Image = CodesList;
                    RunObject = Page "Standard Customer Sales Codes";
                    RunPageLink = "Customer No." = FIELD("No.");
                    ToolTip = 'Set up recurring sales lines for the customer, such as a monthly replenishment order, that can quickly be inserted on a sales document for the customer.';
                }
            }
            group(Documents)
            {
                Caption = 'Documents';
                Image = Documents;
                action(Quotes)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Quotes';
                    Image = Quote;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Sales Quotes";
                    RunPageLink = "Sell-to Customer No." = FIELD("No.");
                    RunPageView = SORTING("Sell-to Customer No.");
                    ToolTip = 'View a list of ongoing sales quotes.';
                }
                action(Orders)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Orders';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Sales Order List";
                    RunPageLink = "Sell-to Customer No." = FIELD("No.");
                    RunPageView = SORTING("Sell-to Customer No.");
                    ToolTip = 'View a list of ongoing sales orders for the customer.';
                }
                action("Return Orders")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Return Orders';
                    Image = ReturnOrder;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Sales Return Order List";
                    RunPageLink = "Sell-to Customer No." = FIELD("No.");
                    RunPageView = SORTING("Sell-to Customer No.");
                    ToolTip = 'Open the list of ongoing return orders.';
                }
                group("Issued Documents")
                {
                    Caption = 'Issued Documents';
                    Image = Documents;
                    action("Issued &Reminders")
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Issued &Reminders';
                        Image = OrderReminder;
                        RunObject = Page "Issued Reminder List";
                        RunPageLink = "Customer No." = FIELD("No.");
                        RunPageView = SORTING("Customer No.", "Posting Date");
                        ToolTip = 'View the reminders that you have sent to the customer.';
                    }
                    action("Issued &Finance Charge Memos")
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Issued &Finance Charge Memos';
                        Image = FinChargeMemo;
                        RunObject = Page "Issued Fin. Charge Memo List";
                        RunPageLink = "Customer No." = FIELD("No.");
                        RunPageView = SORTING("Customer No.", "Posting Date");
                        ToolTip = 'View the finance charge memos that you have sent to the customer.';
                    }
                }
                action("Blanket Orders")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Blanket Orders';
                    Image = BlanketOrder;
                    RunObject = Page "Blanket Sales Orders";
                    RunPageLink = "Sell-to Customer No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", "Sell-to Customer No.");
                    ToolTip = 'Open the list of ongoing blanket orders.';
                }
            }
            group(Service)
            {
                Caption = 'Service';
                Image = ServiceItem;
                action("Service Orders")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Service Orders';
                    Image = Document;
                    RunObject = Page "Service Orders";
                    RunPageLink = "Customer No." = FIELD("No.");
                    RunPageView = SORTING("Document Type", "Customer No.");
                    ToolTip = 'Open the list of ongoing service orders.';
                }
                action("Ser&vice Contracts")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Ser&vice Contracts';
                    Image = ServiceAgreement;
                    RunObject = Page "Customer Service Contracts";
                    RunPageLink = "Customer No." = FIELD("No.");
                    RunPageView = SORTING("Customer No.", "Ship-to Code");
                    ToolTip = 'Open the list of ongoing service contracts.';
                }
                action("Service &Items")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Service &Items';
                    Image = ServiceItem;
                    RunObject = Page "Service Items";
                    RunPageLink = "Customer No." = FIELD("No.");
                    RunPageView = SORTING("Customer No.", "Ship-to Code", "Item No.", "Serial No.");
                    ToolTip = 'View or edit the service items that are registered for the customer.';
                }
            }
        }
        area(creation)
        {
            action(NewSalesBlanketOrder)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Blanket Sales Order';
                Image = BlanketOrder;
                RunObject = Page "Blanket Sales Order";
                RunPageLink = "Sell-to Customer No." = FIELD("No.");
                RunPageMode = Create;
                ToolTip = 'Create a blanket sales order for the customer.';
            }
            action(NewSalesQuote)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Sales Quote';
                Image = NewSalesQuote;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Sales Quote";
                RunPageLink = "Sell-to Customer No." = FIELD("No.");
                RunPageMode = Create;
                ToolTip = 'Offer items or services to a customer.';
            }
            action(NewSalesInvoice)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Sales Invoice';
                Image = NewSalesInvoice;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Sales Invoice";
                RunPageLink = "Sell-to Customer No." = FIELD("No.");
                RunPageMode = Create;
                ToolTip = 'Create a sales invoice for the customer.';
            }
            action(NewSalesOrder)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Sales Order';
                Image = Document;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Sales Order";
                RunPageLink = "Sell-to Customer No." = FIELD("No.");
                RunPageMode = Create;
                ToolTip = 'Create a sales order for the customer.';
            }
            action(NewSalesCrMemo)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Sales Credit Memo';
                Image = CreditMemo;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Sales Credit Memo";
                RunPageLink = "Sell-to Customer No." = FIELD("No.");
                RunPageMode = Create;
                ToolTip = 'Create a new sales credit memo to revert a posted sales invoice.';
            }
            action(NewSalesReturnOrder)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Sales Return Order';
                Image = ReturnOrder;
                RunObject = Page "Sales Return Order";
                RunPageLink = "Sell-to Customer No." = FIELD("No.");
                RunPageMode = Create;
                ToolTip = 'Create a new sales return order for items or services.';
            }
            action(NewServiceQuote)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Service Quote';
                Image = Quote;
                RunObject = Page "Service Quote";
                RunPageLink = "Customer No." = FIELD("No.");
                RunPageMode = Create;
                ToolTip = 'Create a new service quote for the customer.';
            }
            action(NewServiceInvoice)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Service Invoice';
                Image = Invoice;
                RunObject = Page "Service Invoice";
                RunPageLink = "Customer No." = FIELD("No.");
                RunPageMode = Create;
                ToolTip = 'Create a new service invoice for the customer.';
            }
            action(NewServiceOrder)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Service Order';
                Image = Document;
                RunObject = Page "Service Order";
                RunPageLink = "Customer No." = FIELD("No.");
                RunPageMode = Create;
                ToolTip = 'Create a new service order for the customer.';
            }
            action(NewServiceCrMemo)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Service Credit Memo';
                Image = CreditMemo;
                RunObject = Page "Service Credit Memo";
                RunPageLink = "Customer No." = FIELD("No.");
                RunPageMode = Create;
                ToolTip = 'Create a new service credit memo for the customer.';
            }
            action(NewReminder)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Reminder';
                Image = Reminder;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                RunObject = Page Reminder;
                RunPageLink = "Customer No." = FIELD("No.");
                RunPageMode = Create;
                ToolTip = 'Create a new reminder for the customer.';
            }
            action(NewFinChargeMemo)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Finance Charge Memo';
                Image = FinChargeMemo;
                RunObject = Page "Finance Charge Memo";
                RunPageLink = "Customer No." = FIELD("No.");
                RunPageMode = Create;
                ToolTip = 'Create a new finance charge memo.';
            }
        }
        area(processing)
        {
            group(Action104)
            {
                Caption = 'History';
                Image = History;
                action(CustomerLedgerEntriesHistory)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Ledger E&ntries';
                    Image = CustomerLedger;
                    RunObject = Page "Customer Ledger Entries";
                    RunPageLink = "Customer No." = FIELD("No.");
                    RunPageView = SORTING("Customer No.");
                    Scope = Repeater;
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                }
            }
            action("Cash Receipt Journal")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Cash Receipt Journal';
                Image = CashReceiptJournal;
                Promoted = true;
                PromotedCategory = Category8;
                RunObject = Page "Cash Receipt Journal";
                ToolTip = 'Open the cash receipt journal to post incoming payments.';
            }
            action("Sales Journal")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Sales Journal';
                Image = Journals;
                Promoted = true;
                PromotedCategory = Category8;
                RunObject = Page "Sales Journal";
                ToolTip = 'Post any sales transaction for the customer.';
            }
            action(PaymentRegistration)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Register Customer Payments';
                Image = Payment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Payment Registration";
                RunPageLink = "Source No." = FIELD("No.");
                ToolTip = 'Process your customer payments by matching amounts received on your bank account with the related unpaid sales invoices, and then post the payments.';
            }
        }
        area(reporting)
        {
            group(Reports)
            {
                Caption = 'Reports';
                group(SalesReports)
                {
                    Caption = 'Sales Reports';
                    Image = "Report";
                    action(ReportCustomerTop10List)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Customer - Top 10 List';
                        Image = "Report";
                        RunObject = Report "Customer - Top 10 List";
                        ToolTip = 'View which customers purchase the most or owe the most in a selected period. Only customers that have either purchases during the period or a balance at the end of the period will be included.';
                    }
                    action(ReportCustomerSalesList)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Customer - Sales List';
                        Image = "Report";
                        RunObject = Report "Customer - Sales List";
                        ToolTip = 'View customer sales for a period, for example, to report sales activity to customs and tax authorities. You can choose to include only customers with total sales that exceed a minimum amount. You can also specify whether you want the report to show address details for each customer.';
                    }

                }
                group(FinanceReports)
                {
                    Caption = 'Finance Reports';
                    Image = "Report";
                    action(Statement)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Statement';
                        Image = "Report";
                        RunObject = Report "Customer Statement";
                        ToolTip = 'View a list of a customer''s transactions for a selected period, for example, to send to the customer at the close of an accounting period. You can choose to have all overdue balances displayed regardless of the period specified, or you can choose to include an aging band.';
                    }
                    action(BackgroundStatement)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Scheduled Statements';
                        Image = "Report";
                        ToolTip = 'Schedule Customer Statements in the Job Queue.';

                        trigger OnAction()
                        var
                            CustomerLayoutStatement: Codeunit "Customer Layout - Statement";
                        begin
                            CustomerLayoutStatement.EnqueueReport();
                        end;
                    }
                    action(ReportCustomerBalanceToDate)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Customer - Balance to Date';
                        Image = "Report";
                        RunObject = Report "Customer - Balance to Date";
                        ToolTip = 'View a list with customers'' payment history up until a certain date. You can use the report to extract your total sales income at the close of an accounting period or fiscal year.';
                    }
                    action(ReportCustomerTrialBalance)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Customer - Trial Balance';
                        Image = "Report";
                        RunObject = Report "Customer - Trial Balance";
                        ToolTip = 'View the beginning and ending balance for customers with entries within a specified period. The report can be used to verify that the balance for a customer posting group is equal to the balance on the corresponding general ledger account on a certain date.';
                    }
                    action(ReportCustomerDetailTrial)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Customer - Detail Trial Bal.';
                        Image = "Report";
                        RunObject = Report "Customer - Detail Trial Bal.";
                        ToolTip = 'View the balance for customers with balances on a specified date. The report can be used at the close of an accounting period, for example, or for an audit.';
                    }
                    action(ReportAgedAccountsReceivable)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Aged Accounts Receivable';
                        Image = "Report";
                        RunObject = Report "Aged Accounts Receivable";
                        ToolTip = 'View an overview of when customer payments are due or overdue, divided into four periods. You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
                    }
                    action(ReportCustomerPaymentReceipt)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Customer - Payment Receipt';
                        Image = "Report";
                        RunObject = Report "Customer - Payment Receipt";
                        ToolTip = 'View a document showing which customer ledger entries that a payment has been applied to. This report can be used as a payment receipt that you send to the customer.';
                    }
                }
                action(Reminder)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Reminder';
                    Image = Reminder;
                    RunObject = Report Reminder;
                    ToolTip = 'Create a new reminder for the customer.';
                }
            }
            group(General)
            {
                Caption = 'General';
                action("Customer Register")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Customer Register';
                    Image = "Report";
                    RunObject = Report "Customer Register";
                    ToolTip = 'View posted customer ledger entries divided into, and sorted according to, registers. By using a filter, you can select exactly the entries in the registers that you need to see. If you have created many entries and you do not set a filter, the report will print a large amount of information.';
                }
                action("Customer - Top 10 List")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Customer - Top 10 List';
                    Image = "Report";
                    RunObject = Report "Customer - Top 10 List";
                    ToolTip = 'View which customers purchase the most or owe the most in a selected period. Only customers that have either purchases during the period or a balance at the end of the period will be included.';
                }
            }
            group(Sales)
            {
                Caption = 'Sales';
                Image = Sales;
                action("Customer - Order Summary")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Customer - Order Summary';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Report "Customer - Order Summary";
                    ToolTip = 'View the order detail (the quantity not yet shipped) for each customer in three periods of 30 days each, starting from a selected date. There are also columns with orders to be shipped before and after the three periods and a column with the total order detail for each customer. The report can be used to analyze a company''s expected sales volume.';
                }
                action("Customer - Order Detail")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Customer - Order Detail';
                    Image = "Report";
                    RunObject = Report "Customer - Order Detail";
                    ToolTip = 'View a list of orders divided by customer. The order amounts are totaled for each customer and for the entire list. The report can be used, for example, to obtain an overview of sales over the short term or to analyze possible shipment problems.';
                }
                action("Customer - Sales List")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Customer - Sales List';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = "Report";
                    RunObject = Report "Customer - Sales List";
                    ToolTip = 'View customer sales for a period, for example, to report sales activity to customs and tax authorities. You can choose to include only customers with total sales that exceed a minimum amount. You can also specify whether you want the report to show address details for each customer.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
#if BC17 or BC18
        ItemReferenceMgt: Codeunit "Item Reference Management";
#endif
    begin
#if BC17 or BC18
        ItemReferenceVisible := ItemReferenceMgt.IsEnabled();
#endif

        TableView := Rec.GetView(false);
    end;

    local procedure CreateCustomerFromTemplate()
    var
        Customer: Record Customer;
        CustomerCard: Page "Customer Card";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
    begin
        if CustomerTemplMgt.InsertCustomerFromTemplate(Customer) then begin
            CustomerCard.SetRecord(Customer);
            CustomerCard.Run();
        end;
    end;

    var
        _SearchTerm: Text[100];
#if BC17 or BC18
        ItemReferenceVisible: Boolean;
#endif
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        TableView: Text;
}
