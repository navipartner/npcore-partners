page 6151241 "NPR Retail Manager Role Center"
{
    Extensible = false;
    Caption = 'NP Retail Manager';
    PageType = RoleCenter;
    UsageCategory = None;
    layout
    {
        area(rolecenter)
        {
            part(Headline; "NPR generic retail Headline")
            {
                ApplicationArea = NPRRetail;
            }
            part(Control6150616; "NPR Activities")
            {
                ApplicationArea = NPRRetail;
            }
            part(NPRetailPOSEntryCue; "NPR POS Entry Cue")
            {
                Caption = 'POS Activities';
                ApplicationArea = NPRRetail;
            }
#IF NOT BC17
            part(RetailSalesChart; "NPR Retail Sales Chart")
            {
                ApplicationArea = NPRRetail;
                ObsoleteReason = 'Replaced with page "NPR Chart Wrapper".';
                ObsoleteState = Pending;
                ObsoleteTag = 'NPR26.0';
                Visible = false;
            }
            part(RetailSalesByShopChart; "NPR Retail Sales Chart by Shop")
            {
                ApplicationArea = NPRRetail;
                ObsoleteReason = 'Replaced with page "NPR Chart Wrapper".';
                ObsoleteState = Pending;
                ObsoleteTag = 'NPR26.0';
                Visible = false;
            }
            //NOTE: If this part is to be deleted from RoleCenter, Logo will be deleted as well
            part(RetailPerformance; "NPR Chart Wrapper")
            {
                ApplicationArea = NPRRetail;
            }
#ENDIF
            part("MyReports"; "NPR My Reports")
            {
                ApplicationArea = NPRRetail;
            }
            part(Control21; "Report Inbox Part")
            {
                AccessByPermission = TableData "Report Inbox" = R;
                ApplicationArea = NPRRetail;
            }
            part(MyJobQueue; "My Job Queue")
            {
                Caption = 'Job Queue';
                ApplicationArea = NPRRetail;
            }

        }
    }
    actions
    {
        area(reporting)
        {
            group(ActionGroup6014406)
            {
                Visible = false;
                Action("S&tatement")
                {
                    Caption = 'S&tatement';
                    Image = "Report";
                    RunObject = Report Statement;
                    ToolTip = 'Opens the Statement report.';
                    ApplicationArea = NPRRetail;
                }
                separator(Separator6150667)
                {
                }
                Action("Customer - Order Su&mmary")
                {
                    Caption = 'Customer - Order Su&mmary';
                    Image = "Report";
                    RunObject = Report "Customer - Order Summary";
                    ToolTip = 'Opens the Customer - Order Summary report.';
                    ApplicationArea = NPRRetail;
                }
                Action("Customer - T&op 10 List")
                {
                    Caption = 'Customer - T&op 10 List';
                    Image = "Report";
                    RunObject = Report "Customer - Top 10 List";
                    ToolTip = 'Opens the Customer Top 10 List report';
                    ApplicationArea = NPRRetail;
                }
                separator(Separator6150663)
                {
                }
                separator(Separator6150660)
                {
                }
                Action("Inventory - Sales &Back Orders")
                {
                    Caption = 'Inventory - Sales &Back Orders';
                    Image = "Report";
                    RunObject = Report "Inventory - Sales Back Orders";
                    ToolTip = 'Opens the Inventory - Sales Back Orders report.';
                    ApplicationArea = NPRRetail;
                }
                separator(Separator6150658)
                {
                }
                Action("&G/L Trial Balance")
                {
                    Caption = '&G/L Trial Balance';
                    Image = "Report";
                    RunObject = Report "Trial Balance";
                    ToolTip = 'Runs the &G/L Trial Balance report.';
                    ApplicationArea = NPRRetail;
                }
                Action("Trial Balance by &Period")
                {
                    Caption = 'Trial Balance by &Period';
                    Image = "Report";
                    RunObject = Report "Trial Balance by Period";
                    ToolTip = 'Runs the Trial Balance by &Period report.';
                    ApplicationArea = NPRRetail;
                }
                Action("Closing T&rial Balance")
                {
                    Caption = 'Closing T&rial Balance';
                    Image = "Report";
                    RunObject = Report "Closing Trial Balance";
                    ToolTip = 'Runs the Closing T&rial Balance report.';
                    ApplicationArea = NPRRetail;
                }
                separator(Separator6150654)
                {
                }
                Action("Aged Ac&counts Receivable")
                {
                    Caption = 'Aged Ac&counts Receivable';
                    Image = "Report";
                    RunObject = Report "Aged Accounts Receivable";
                    ToolTip = 'Runs the Aged Ac&counts Receivable report.';
                    ApplicationArea = NPRRetail;
                }
                Action("Aged Accounts Pa&yable")
                {
                    Caption = 'Aged Accounts Pa&yable';
                    Image = "Report";
                    RunObject = Report "Aged Accounts Payable";
                    ToolTip = 'Runs the Aged Accounts Pa&yable report.';
                    ApplicationArea = NPRRetail;
                }
                Action("Reconcile Cust. and &Vend. Accs")
                {
                    Caption = 'Reconcile Cust. and &Vend. Accs';
                    Image = "Report";
                    RunObject = Report "Reconcile Cust. and Vend. Accs";
                    ToolTip = 'Runs the Reconcile Cust. and &Vend. Accs report.';
                    ApplicationArea = NPRRetail;
                }
                separator(Separator6150650)
                {
                }
                Action("VAT Registration No. Chec&k")
                {
                    Caption = 'VAT Registration No. Chec&k';
                    Image = "Report";
                    RunObject = Report "VAT Registration No. Check";
                    ToolTip = 'Runs the VAT Registration No. Chec&k report.';
                    ApplicationArea = NPRRetail;
                }
                Action("VAT E&xceptions")
                {
                    Caption = 'VAT E&xceptions';
                    Image = "Report";
                    RunObject = Report "VAT Exceptions";
                    ToolTip = 'Runs the VAT E&xceptions report.';
                    ApplicationArea = NPRRetail;
                }
                Action("V&AT Statement")
                {
                    Caption = 'V&AT Statement';
                    Image = "Report";
                    RunObject = Report "VAT Statement";
                    ToolTip = 'Runs the V&AT Statement report.';
                    ApplicationArea = NPRRetail;
                }
                Action("VAT-VIES Declaration Tax A&uth")
                {
                    Caption = 'VAT - VIES Declaration Tax A&uth';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Tax Auth";
                    ToolTip = 'Runs the VAT - VIES Declaration Tax A&uth report.';
                    ApplicationArea = NPRRetail;
                }
                Action("VAT - VIES Declaration &Disk")
                {
                    Caption = 'VAT - VIES Declaration &Disk';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Disk";
                    ToolTip = 'Runs the VAT - VIES Declaration &Disk report.';
                    ApplicationArea = NPRRetail;
                }
                Action("EC Sal&es List")
                {
                    Caption = 'EC Sal&es List';
                    Image = "Report";
                    RunObject = Report "EC Sales List";
                    ToolTip = 'Runs the EC Sal&es List report.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(sections)
        {
            group("Reference Data")
            {
                Caption = 'Reference Data';
                Image = ReferenceData;
                Action(Customers)
                {

                    Caption = 'Customers';
                    Image = Customer;
                    RunObject = Page "Customer List";
                    ToolTip = 'View or edit detailed information for the customers that you trade with. From each customer card, you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
                    ApplicationArea = NPRRetail;
                }

                Action(Contact)
                {

                    Caption = 'Contact';
                    Image = Customer;
                    RunObject = Page "Contact List";
                    ToolTip = 'View or edit detailed information for the customers that you trade with. From each contact card, you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
                    ApplicationArea = NPRRetail;
                }
                Action(Vendors)
                {

                    Caption = 'Vendors';
                    Image = Vendor;
                    RunObject = Page "Vendor List";
                    ToolTip = 'View or edit detailed information for the vendors that you trade with. From each vendor card, you can open related information, such as purchase statistics and ongoing orders, and you can define special prices and line discounts that the vendor grants you if certain conditions are met.';
                    ApplicationArea = NPRRetail;
                }

                Action(MemberList)
                {

                    Caption = 'Member List';
                    Image = Customer;
                    RunObject = Page "NPR MM Member Card List";
                    ToolTip = 'View Member List.';
                    ApplicationArea = NPRRetail;
                }

                Action(Membership)
                {

                    Caption = 'Memberships';
                    Image = Customer;
                    RunObject = Page "NPR MM Memberships";
                    ToolTip = 'View Membership List.';
                    ApplicationArea = NPRRetail;

                }
                Action(ShopperRecognition)
                {
                    Caption = 'EFT Shopper Recognition';
                    Image = Customer;
                    RunObject = Page "NPR EFT Shopper Recognition";
                    ToolTip = 'View the shopper recognition details.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(ActionGroup6014513)
            {
                Caption = 'Item & Prices';
                Image = ProductDesign;
                Action(Action6014418)
                {
                    Caption = 'Retail Item List';
                    RunObject = Page "Item List";

                    ToolTip = 'Executes the Retail Item List action.';
                    ApplicationArea = NPRRetail;
                }
                Action("Item Categories")
                {
                    Caption = 'Item Categories';
                    RunObject = Page "Item Categories";

                    ToolTip = 'Executes the Item Categories action.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Journals)
            {
                Caption = 'Journals';
                Image = Journals;

                Action(ItemJournalList)
                {

                    Caption = 'Item Journal List';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = where("Template Type" = const(Item));
                    ToolTip = 'Executes the Item Journal List action.';
                    ApplicationArea = NPRRetail;
                }
                Action("Physical Inventory Journals")
                {
                    Caption = 'Physical Inventory Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = where("Template Type" = const("Phys. Inventory"),
                                         Recurring = const(false));

                    ToolTip = 'Executes the Physical Inventory Journals action.';
                    ApplicationArea = NPRRetail;
                }
                Action(ItemWorksheets)
                {

                    Caption = 'Item Worksheets';
                    RunObject = Page "NPR Item Worksheets";
                    ToolTip = 'Executes the Item Worksheets action.';
                    ApplicationArea = NPRRetail;
                }
                Action("Retail Journal List")
                {
                    Caption = 'Retail Journal List';
                    RunObject = Page "NPR Retail Journal List";

                    ToolTip = 'Executes the Retail Journal List action.';
                    ApplicationArea = NPRRetail;
                }
                action("EFT Reconciliations")
                {
                    Caption = 'EFT Reconciliations';
                    RunObject = Page "NPR EFT Reconciliation List";

                    ToolTip = 'View or edit the EFT Reconciliations';
                    ApplicationArea = NPRRetail;
                }

            }
            group("Retail Documents")
            {
                Caption = 'Documents';
                Image = RegisteredDocs;

                Action("POS Entry List")
                {
                    Caption = 'POS Entry List';
                    Image = RegisteredDocs;
                    RunObject = Page "NPR POS Entry List";
                    ToolTip = 'View POS Entry that have been done.';
                    ApplicationArea = NPRRetail;

                }
                Action("POS Entry Sales & Payment List")
                {
                    Caption = 'POS Entry Sales & Payment List';
                    Image = RegisteredDocs;
                    RunObject = Page "NPR POS Entry Sales & Payments";
                    ToolTip = 'View POS Entry Sales & Payment List that have been done.';
                    ApplicationArea = NPRRetail;

                }
                Action("EFT Transaction Request")
                {
                    Caption = 'EFT Transaction Request';
                    Image = RegisteredDocs;
                    RunObject = Page "NPR EFT Transaction Requests";
                    ToolTip = 'View EFT Transaction Requests.';
                    ApplicationArea = NPRRetail;

                }
                Action("Global POS Sales Entries")
                {
                    Caption = 'Global POS Sales Entries';
                    Image = RegisteredDocs;
                    RunObject = Page "NPR NpGp POS Sales Entries";
                    ToolTip = 'View Global POS Sales Entries.';
                    ApplicationArea = NPRRetail;
                }
                Action(POSQuotes)
                {
                    Caption = 'POS Saved Sales';
                    Image = RegisteredDocs;
                    RunObject = Page "NPR POS Saved Sales";
                    ToolTip = 'View POS Saved Sales that have been done.';
                    ApplicationArea = NPRRetail;
                }
                action("NpCs Document List")
                {
                    Caption = 'Collect Document List';
                    Image = RegisteredDocs;
                    RunObject = Page "NPR NpCs Document List";
                    ToolTip = 'View Collect Document List.';
                    ApplicationArea = NPRRetail;
                }
                Action("Posted Sales Invoices")
                {
                    Caption = 'Posted Sales Invoices List';
                    Image = RegisteredDocs;
                    RunObject = Page "Posted Sales Invoices";
                    ToolTip = 'View Sales Invoices that have been done.';
                    ApplicationArea = NPRRetail;
                }
                Action("Posted Sales Shipment List")
                {
                    Caption = 'Posted Sales Shipment List';
                    Image = RegisteredDocs;
                    RunObject = Page "Posted Sales Shipments";
                    ToolTip = 'View Posted Sales Shipments that have been done.';
                    ApplicationArea = NPRRetail;
                }
                Action("Posted Sales Credit Memos List")
                {
                    Caption = 'Posted Sales Credit Memos List';
                    Image = RegisteredDocs;
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'View Sales Credit Memos that have been done.';
                    ApplicationArea = NPRRetail;

                }
            }
            group("Discount, Coupons & Vouchers")
            {
                Action("Period Discount List")
                {
                    Caption = 'Period Discount List';
                    RunObject = Page "NPR Campaign Discount List";

                    ToolTip = 'Displays the period discount list.';
                    ApplicationArea = NPRRetail;
                }

                Action("Mixed Discount List")
                {
                    Caption = 'Mixed Discount List';
                    RunObject = Page "NPR Mixed Discount List";

                    ToolTip = 'Displays the mixed discount list.';
                    ApplicationArea = NPRRetail;
                }

                Action("Total Discount List")
                {
                    Caption = 'Total Discount List';
                    RunObject = Page "NPR Total Discount List";

                    ToolTip = 'Displays the total discount list.';
                    ApplicationArea = NPRRetail;
                }

                Action("Coupon List")
                {
                    Caption = 'Coupon List';
                    Image = List;
                    RunObject = Page "NPR NpDc Coupons";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Coupon List';
                }
                Action("Voucher List")
                {
                    Caption = 'Voucher List';
                    Image = List;
                    RunObject = Page "NPR NpRv Vouchers";
                    ApplicationArea = NPRRetail;
                    ToolTip = 'View or edit the Voucher List';
                }
                action("Tax Free Vouchers")
                {
                    Caption = 'Tax Free Vouchers List';
                    Image = Voucher;
                    RunObject = Page "NPR Tax Free Voucher";
                    ToolTip = 'View Tax Free Vouchers List';
                    ApplicationArea = NPRRetail;
                }
            }
            group("NP Retail Reports")
            {
                Caption = 'NP Retail Reports';
                Image = AnalysisView;

                group(Management)
                {
                    Caption = 'Management';
                    group(Sales)
                    {
                        Caption = 'Sales';
                        Action("NPR Sales Stat/Analysis")
                        {
                            Caption = 'Sales Statistics by Item Category';
                            Image = Report;
                            RunObject = Report "NPR Sales Stat/Analysis";
                            ToolTip = 'Generate the Turnover/Profit report per category.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Sales Statistics By Department")
                        {
                            Caption = 'Sales Statistics By Department';
                            Image = Report;
                            RunObject = Report "NPR Sales Statistics By Dept.";
                            ToolTip = 'View the report which measures sales proceeds achieved per a department.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Sales Statistics Variant")
                        {
                            Caption = 'Sales Statistics Variant';
                            Image = Report;
                            RunObject = Report "NPR Sales Stats Per Variety";
                            ToolTip = 'Generate the Sales/Profit report per Variant.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Sale Time Report POS")
                        {
                            Caption = 'Sale Time Report';
                            Image = Report;
                            RunObject = Report "NPR Sale Time Report POS";
                            ToolTip = 'Generate the sale time report.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Turnover Rate")
                        {
                            Caption = 'Turnover Rate';
                            Image = Report;
                            RunObject = Report "NPR Turnover Rate";
                            ToolTip = 'Executes the Turnover Rate action.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("Sales Ticket Statistics")
                        {
                            Caption = 'Sales Ticket Statistics';
                            Image = ListPage;
                            RunObject = Page "NPR Sales Ticket Statistics";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Sales Ticket Statistics action.';
                        }
                        Action("Monthly Advance Sales Statistics")
                        {
                            Caption = 'Monthly Advance Sales Statistics';
                            Image = ListPage;
                            RunObject = Page "NPR Advanced Sales Stats";
                            ToolTip = 'Generate the daily sales report per quantity and amount';
                            ApplicationArea = NPRRetail;
                        }
                        Action("Sales per month year/Last")
                        {
                            Caption = 'Sales Per Month Current Year/Last Year';
                            Image = Report;
                            RunObject = Report "NPR Sales per month year";
                            ToolTip = 'View the report of sales for a specified month, along with the comparison with the last year''s report for the same month.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("Sales Statistics by POS Store/Unit")
                        {
                            Caption = 'Sales Statistics by POS Store/Unit';
                            Image = Report;
                            RunObject = Report "NPR Sales Statistics A4 POS";
                            ToolTip = 'Executes the Sales Statistics by POS Store/Unit action.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Salespersons)
                    {
                        Caption = 'Salespersons';
                        Action("NPR S.Person POS Sales Stats")
                        {
                            Caption = 'Salesperson POS Sales Statistics';
                            Image = Report;
                            RunObject = Report "NPR S.Person POS Sales Stats";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Salesperson POS Sales Statistics action.';
                        }
                        Action("NPR Sold Items by Sales Person")
                        {
                            Caption = 'Sold Items By Salesperson';
                            Image = Report;
                            RunObject = Report "NPR Sold Items by Sales Person";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Sold Items By Salesperson action.';
                        }
                        Action("NPR S.Person Trn by Item Cat.")
                        {
                            Caption = 'Salesperson Turnover per Item Category';
                            Image = Report;
                            RunObject = Report "NPR S.Person Trn by Item Cat.";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Salesperson Turnover per Item Category action.';
                        }
                        Action("NPR Sales Person Top 20")
                        {
                            Caption = 'Sales Person Top 20';
                            Image = Report;
                            RunObject = Report "NPR Sales person Top 20";
                            ToolTip = 'View the report which measures the salespeoples'' effectiveness.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Salesp./Item Cat Top 20")
                        {
                            Caption = 'Salesperson/Item Category Top';
                            Image = Report;
                            RunObject = Report "NPR Salesp./Item Cat Top 20";
                            ToolTip = 'View the report which measures which salesperson was most successful with a certain category of items.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Item/Sales Person Top")
                        {
                            Caption = 'Item/Salesperson Top';
                            Image = Report;
                            RunObject = Report "NPR Item/Sales Person Top";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Item/Salesperson Top action.';
                        }
                        Action("NPR Vendor/Salesperson")
                        {
                            Caption = 'Vendor/Salesperson';
                            Image = Report;
                            RunObject = Report "NPR Vendor/Salesperson";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Vendor/Salesperson action.';
                        }
                    }
                    group(History)
                    {
                        Caption = 'History';
                        Action("NPR Advanced Sales Stat.")
                        {
                            Caption = 'Advanced Sales Statistics';
                            Image = Report;
                            RunObject = Report "NPR Advanced Sales Stat.";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Advanced Sales Statistics action.';
                        }
                        Action("NPR Discount Statistics")
                        {
                            Caption = 'Discount Statistics';
                            Image = Report;
                            RunObject = Report "NPR Discount Statistics";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Discount Statistics action.';

                        }
                        Action("NPR POS Entry Overview")
                        {
                            Caption = 'POS Entry Overview';
                            Image = Report;
                            RunObject = Report "NPR POS Entry Overview";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the POS Entry Overview action.';
                        }
                        Action("NPR POS Entry Sales Details")
                        {
                            Caption = 'POS Entry Sales Details';
                            Image = Report;
                            RunObject = Report "NPR POS Entry Sales Details";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the POS Entry Sales Details action.';
                        }
                        Action("NPR POS Entry Payment Details")
                        {
                            Caption = 'POS Entry Payment Details';
                            Image = Report;
                            RunObject = Report "NPR POS Entry Payment Details";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the POS Entry Payment Details action.';
                        }
                    }
                    group(Vouchers)
                    {
                        Caption = 'Vouchers';
                        Action("NPR Voucher List")
                        {
                            Caption = 'Voucher List';
                            Image = Report;
                            RunObject = Report "NPR Voucher List";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Voucher List action.';
                        }
                        Action("NPR Voucher Entries")
                        {
                            Caption = 'Voucher Entries';
                            Image = Report;
                            RunObject = Report "NPR Voucher Entries";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Voucher Entries action.';
                        }
                        Action("NPR Archived Voucher List")
                        {
                            Caption = 'Archived Voucher List';
                            Image = Report;
                            RunObject = Report "NPR Archived Voucher List";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Archived Voucher List action.';
                        }
                    }
                    group("Discount Coupons")
                    {
                        Caption = 'Discount Coupons';
                        Action("NPR Open/Archive Coupon Stat.")
                        {
                            Caption = 'Open/Archive Coupon Statistics';
                            Image = Report;
                            RunObject = Report "NPR Open/Archive Coupon Stat.";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Open/Archive Coupon Statistics action.';
                        }
                    }
                    group(Vendor)
                    {
                        Caption = 'Vendor';
                        Action("NPR Sale Statistics per Vendor")
                        {
                            Caption = 'Sale Statistics Per Vendor';
                            Image = Report;
                            RunObject = Report "NPR Sale Statistics per Vendor";
                            ToolTip = 'View the report which measures sales proceeds achieved per a vendor.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Vendor Sales Stat")
                        {
                            Caption = 'Vendor Sales Statistics';
                            Image = Report;
                            RunObject = Report "NPR Vendor Sales Stat";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Vendor Sales Statistics action.';
                        }
                        Action("NPR Item Sales Stats by Vendor")
                        {
                            Caption = 'Item Sales Statistics by Vendor';
                            Image = Report;
                            RunObject = Report "NPR Item Sales Stats/Provider";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Item Sales Statistics by Vendor action.';
                        }
                        Action("NPR Vendor Top/Sale")
                        {
                            Caption = 'Vendor Top/Sale';
                            Image = Report;
                            RunObject = Report "NPR Vendor Top/Sale";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Vendor Top/Sale action.';
                        }
                        Action("NPR Vendor/Debtor by date")
                        {
                            Caption = 'Vendor/Customer by date';
                            Image = Report;
                            RunObject = Report "NPR Vendor/Debtor by date";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Vendor/Customer by date action.';
                        }
                        Action("NPR Vendor/Item Category")
                        {
                            Caption = 'Vendor/Item Category';
                            Image = Report;
                            RunObject = Report "NPR Vendor/Item Category";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Vendor/Item Category action.';
                        }
                        Action("NPR Vendor Trn. by Item Cat.")
                        {
                            Caption = 'Vendor Turnover by Item Category';
                            Image = Report;
                            RunObject = Report "NPR Vendor Trn. by Item Cat.";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Vendor Turnover by Item Category action.';
                        }
                    }
                    group(Customer)
                    {
                        Caption = 'Customer';
                        Action("NPR Customer Analysis")
                        {
                            Caption = 'Customer Analysis';
                            Image = Report;
                            RunObject = Report "NPR Customer Analysis";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Customer Analysis action.';
                        }
                    }
                    group(Cash)
                    {
                        Caption = 'Cash';
                        action("NPR Cash Summary")
                        {
                            Caption = 'Cash Summary';
                            Image = Report;
                            RunObject = Report "NPR Cash Summary";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Opens the "Cash Summary" report, displaying the amount of cash per POS Unit, Payment Bin, and Payment Method in both local and default currencies.';
                        }
                    }
                }
                group(ItemandPrices)
                {
                    Caption = 'Item & Prices';
                    group(Goods)
                    {
                        Caption = 'Goods';
                        Action("NPR Inventory by Age")
                        {
                            Caption = 'Inventory by Age';
                            Image = Report;
                            RunObject = Report "NPR Inventory by age";
                            ToolTip = 'Generate Inventory Ageing Report.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Inventory per Date")
                        {
                            Caption = 'Inventory per Date';
                            Image = Report;
                            RunObject = Report "NPR Inventory per Date";
                            ToolTip = 'View the report listing the inventory per date.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Inventory - flow")
                        {
                            Caption = 'Inventory Flow';
                            Image = Report;
                            RunObject = Report "NPR Inventory - flow";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Inventory Flow action.';
                        }
                        Action("NPR Item Category Inventory Value")
                        {
                            Caption = 'Item Category Inventory Value';
                            Image = Report;
                            RunObject = Report "NPR Item Cat. Inv. Value";
                            ToolTip = 'View the report containing stock movement by item category.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Inventory per Variant at Date")
                        {
                            Caption = 'Inventory per Variant at Date';
                            Image = Report;
                            RunObject = Report "NPR Inventory per Variant/date";
                            ToolTip = 'Generate the Stock Inventory report per Variant.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Item Sales Postings")
                        {
                            Caption = 'Item Sales Postings';
                            Image = Report;
                            RunObject = Report "NPR Item Sales Postings";
                            ToolTip = 'Generate statistic per item/item category.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Items With Low Sales")
                        {
                            Caption = 'Items With Low Sales';
                            Image = Report;
                            RunObject = Report "NPR Items With Low Sales";
                            ToolTip = 'Generate Sales/Profit per item.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Item Sales Statistics")
                        {
                            Caption = 'Item Sales Statistics';
                            Image = Report;
                            RunObject = Report "NPR Item Sales Statistics";
                            ToolTip = 'Generate Inventory Movement per Document Type.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Retail Inv.: Sales Stat.")
                        {
                            Caption = 'Item Sales Statistics Per Inventory Posting Group';
                            Image = Report;
                            RunObject = Report "NPR Retail Inv.: Sales Stat.";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Item Sales Statistics Per Inventory Posting Group action.';
                        }
                        Action("NPR POS Item Sales with Dim.")
                        {
                            Caption = 'POS Item Sales With Dimensions';
                            Image = Report;
                            RunObject = Report "NPR POS Item Sales with Dim.";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the POS Item Sales With Dimensions action.';
                        }
                        action("NPR POS Item Sal. Gl. Dim. Set")
                        {
                            Caption = 'POS Item Sales per Global Dimensions Set';
                            Image = Report;
                            RunObject = report "NPR POS Item Sal. Gl. Dim. Set";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the POS Item Sales per Global Dimensions Set action.';
                        }
                        action("NPR Item - Loss")
                        {
                            Caption = 'Item - Loss';
                            Image = Report;
                            RunObject = Report "NPR Item - Loss";
                            ToolTip = 'View the summary of item quantity modified by negative adjustments and the Reason code.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Item - Loss - Top 10")
                        {
                            Caption = 'Item Loss - Top 10';
                            Image = Report;
                            RunObject = Report "NPR Item - Loss - Top 10";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Item Loss - Top 10 action.';
                        }
                        Action("NPR Return Reason Code Statistics")
                        {
                            Caption = 'Return Reason Code Statistics';
                            Image = Report;
                            RunObject = Report "NPR Return Reason Code Stat.";
                            ToolTip = 'View the summary of items with quantity and value modified by negative adjustments and the Reason code. The report is sorted according to the Reason code and Item Number.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Item Group Top")
                        {
                            Caption = 'Item Category Top per Department';
                            Image = Report;
                            RunObject = Report "NPR Item Category Top";
                            ToolTip = 'Generate Top Sales/Profit per Department & Item Category.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Item Categ. List. M/Y new")
                        {
                            Caption = 'Item Category Listing M/Y';
                            Image = Report;
                            RunObject = Report "NPR Item Categ. List. M/Y new";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Item Category Listing M/Y action.';
                        }
                    }
                    group(Discount)
                    {
                        Caption = 'Discount';
                        Action("Inventory Campaign Stat.")
                        {
                            Caption = 'Inventory Campaign Statistics';
                            Image = Report;
                            RunObject = Report "NPR Inventory Campaign Stat.";
                            ToolTip = 'Generate the Turnover/Profit report per Mix Discount.';
                            ApplicationArea = NPRRetail;
                        }
                        Action("NPR Campaign Vendor List")
                        {
                            Caption = 'Campaign Vendor List';
                            Image = Report;
                            RunObject = Report "NPR Campaign Vendor List";
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Executes the Campaign Vendor List action.';
                        }
                    }
                }
            }
        }
        area(creation)
        {
            Action("Sales &Order")
            {
                Caption = 'Sales &Order';
                Image = Document;
                RunObject = Page "Sales Order";
                RunPageMode = Create;

                ToolTip = 'Create Sales Order.';
                ApplicationArea = NPRRetail;
            }
            Action("Sales &Return Order")
            {
                Caption = 'Sales &Return Order';
                Image = ReturnOrder;
                RunObject = Page "Sales Return Order";
                RunPageMode = Create;

                ToolTip = 'Create Sales Return Order.';
                ApplicationArea = NPRRetail;
            }
            Action("Sales Credit Memos")
            {
                Caption = 'Sales Credit Memos';
                Image = RegisteredDocs;
                RunObject = Page "Sales Credit Memos";

                ToolTip = 'View Sales Credit Memos that have been done.';
                ApplicationArea = NPRRetail;
            }
            Action("&Transfer Order")
            {
                Caption = '&Transfer Order';
                Image = TransferOrder;
                RunObject = Page "Transfer Order";
                RunPageMode = Create;

                ToolTip = 'Create Transfer Order.';
                ApplicationArea = NPRRetail;
            }
            Action("&Purchase Quote")
            {
                Caption = '&Purchase Quote';
                Image = PurchaseInvoice;
                RunObject = Page "Purchase Quote";
                RunPageMode = Create;

                ToolTip = 'Create Purchase Quote.';
                ApplicationArea = NPRRetail;
            }
            Action("&Purchase Order")
            {
                Caption = '&Purchase Order';
                Image = Document;
                RunObject = Page "Purchase Order";
                RunPageMode = Create;

                ToolTip = 'Create Purchase Order.';
                ApplicationArea = NPRRetail;
            }
            Action("Purchase Return Order")
            {
                Caption = 'Purchase Return Order';
                Image = Document;
                RunObject = Page "Purchase Return Order";

                ToolTip = 'Executes the Purchase Return Order action.';
                ApplicationArea = NPRRetail;
            }
        }
        area(Processing)
        {
            Action("Find Entries")
            {
                Caption = 'Find Entries';
                RunObject = Page Navigate;
                image = Entries;
                ToolTip = 'Find entries and documents according to the document number and posting date.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}
