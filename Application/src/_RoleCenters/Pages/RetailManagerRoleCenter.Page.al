page 6151241 "NPR Retail Manager Role Center"
{
    Caption = 'NP Retail Manager';
    PageType = RoleCenter;
    UsageCategory = None;
    layout
    {
        area(rolecenter)
        {
            part(Control6150616; "NPR Activities")
            {
                ApplicationArea = NPRRetail;

            }
            part(NPRetailPOSEntryCue; "NPR POS Entry Cue")
            {
                Caption = 'POS Activities';
                ApplicationArea = NPRRetail;

            }
            part(ControlPurchase; "NPR Acc. Payables Act")
            {
                Caption = 'Purchase Activities';
                ApplicationArea = NPRRetail;

            }
            part(RetailSalesChart; "NPR Retail Sales Chart")
            {

                Visible = false;
                ApplicationArea = NPRRetail;
            }
            part(RetailSalesByShopChart; "NPR Retail Sales Chart by Shop")
            {

                Visible = false;
                ApplicationArea = NPRRetail;
            }
            part("MyReports"; "NPR My Reports")
            {
                ApplicationArea = NPRRetail;
            }
            part(MyjobQueue; "My Job Queue")
            {
                Caption = 'Job Queue';
                ApplicationArea = NPRRetail;

            }
            part(Control21; "Report Inbox Part")
            {
                AccessByPermission = TableData "Report Inbox" = R;
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
                action("S&tatement")
                {
                    Caption = 'S&tatement';
                    Image = "Report";
                    RunObject = Report Statement;

                    ToolTip = 'Executes the S&tatement action';
                    ApplicationArea = NPRRetail;
                }
                separator(Separator6150667)
                {
                }
                action("Customer - Order Su&mmary")
                {
                    Caption = 'Customer - Order Su&mmary';
                    Image = "Report";
                    RunObject = Report "Customer - Order Summary";

                    ToolTip = 'Executes the Customer - Order Su&mmary action';
                    ApplicationArea = NPRRetail;
                }
                action("Customer - T&op 10 List")
                {
                    Caption = 'Customer - T&op 10 List';
                    Image = "Report";
                    RunObject = Report "Customer - Top 10 List";

                    ToolTip = 'Executes the Customer - T&op 10 List action';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Inventory - Sales &Back Orders action';
                    ApplicationArea = NPRRetail;
                }
                separator(Separator6150658)
                {
                }
                action("&G/L Trial Balance")
                {
                    Caption = '&G/L Trial Balance';
                    Image = "Report";
                    RunObject = Report "Trial Balance";

                    ToolTip = 'Executes the &G/L Trial Balance action';
                    ApplicationArea = NPRRetail;
                }
                action("Trial Balance by &Period")
                {
                    Caption = 'Trial Balance by &Period';
                    Image = "Report";
                    RunObject = Report "Trial Balance by Period";

                    ToolTip = 'Executes the Trial Balance by &Period action';
                    ApplicationArea = NPRRetail;
                }
                action("Closing T&rial Balance")
                {
                    Caption = 'Closing T&rial Balance';
                    Image = "Report";
                    RunObject = Report "Closing Trial Balance";

                    ToolTip = 'Executes the Closing T&rial Balance action';
                    ApplicationArea = NPRRetail;
                }
                separator(Separator6150654)
                {
                }
                action("Aged Ac&counts Receivable")
                {
                    Caption = 'Aged Ac&counts Receivable';
                    Image = "Report";
                    RunObject = Report "Aged Accounts Receivable";

                    ToolTip = 'Executes the Aged Ac&counts Receivable action';
                    ApplicationArea = NPRRetail;
                }
                action("Aged Accounts Pa&yable")
                {
                    Caption = 'Aged Accounts Pa&yable';
                    Image = "Report";
                    RunObject = Report "Aged Accounts Payable";

                    ToolTip = 'Executes the Aged Accounts Pa&yable action';
                    ApplicationArea = NPRRetail;
                }
                action("Reconcile Cust. and &Vend. Accs")
                {
                    Caption = 'Reconcile Cust. and &Vend. Accs';
                    Image = "Report";
                    RunObject = Report "Reconcile Cust. and Vend. Accs";

                    ToolTip = 'Executes the Reconcile Cust. and &Vend. Accs action';
                    ApplicationArea = NPRRetail;
                }
                separator(Separator6150650)
                {
                }
                action("VAT Registration No. Chec&k")
                {
                    Caption = 'VAT Registration No. Chec&k';
                    Image = "Report";
                    RunObject = Report "VAT Registration No. Check";

                    ToolTip = 'Executes the VAT Registration No. Chec&k action';
                    ApplicationArea = NPRRetail;
                }
                action("VAT E&xceptions")
                {
                    Caption = 'VAT E&xceptions';
                    Image = "Report";
                    RunObject = Report "VAT Exceptions";

                    ToolTip = 'Executes the VAT E&xceptions action';
                    ApplicationArea = NPRRetail;
                }
                action("V&AT Statement")
                {
                    Caption = 'V&AT Statement';
                    Image = "Report";
                    RunObject = Report "VAT Statement";

                    ToolTip = 'Executes the V&AT Statement action';
                    ApplicationArea = NPRRetail;
                }
                action("VAT-VIES Declaration Tax A&uth")
                {
                    Caption = 'VAT - VIES Declaration Tax A&uth';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Tax Auth";

                    ToolTip = 'Executes the VAT - VIES Declaration Tax A&uth action';
                    ApplicationArea = NPRRetail;
                }
                action("VAT - VIES Declaration &Disk")
                {
                    Caption = 'VAT - VIES Declaration &Disk';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Disk";

                    ToolTip = 'Executes the VAT - VIES Declaration &Disk action';
                    ApplicationArea = NPRRetail;
                }
                action("EC Sal&es List")
                {
                    Caption = 'EC Sal&es List';
                    Image = "Report";
                    RunObject = Report "EC Sales List";

                    ToolTip = 'Executes the EC Sal&es List action';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Reports)
            {
                Caption = 'List & Reports';
                group(Management)
                {
                    Caption = 'Management';
                    group(Salespersons)

                    {
                        Caption = 'Salespersons';
                        Image = SalesPerson;
                        action("NPR Sales Person Top 20")
                        {
                            Caption = 'Sales Person Top 20';
                            Image = Report2;
                            RunObject = Report "NPR Sales Person Top 20";

                            ToolTip = 'Executes the NPR Sales Person Top 20 action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Sales code/Item group top")
                        {
                            Caption = 'Sales code/Item group top';
                            Image = Report2;
                            RunObject = Report "NPR Salesperson/Item Group Top";

                            ToolTip = 'Executes the NPR  Sales code/Item group top action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Sale Statistics per Vendor")
                        {
                            Caption = 'Sale Statistics per Vendor';
                            Image = Report2;
                            RunObject = Report "NPR Sale Statistics per Vendor";

                            ToolTip = 'Executes the NPR Sale Statistics per Vendor action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Sales Statistics By Department")
                        {
                            Caption = 'Sales Statistics By Department';
                            Image = Report2;
                            RunObject = Report "NPR Sales Statistics By Dept.";

                            ToolTip = 'Executes the NPR Sales Statistics By Department action';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(History)
                    {
                        Caption = 'History';
                        Image = History;

                        group(HistoryList)
                        {
                            Caption = 'Lists';
                            Image = List;

                            action("Sales Ticket Statistics")
                            {
                                Caption = 'Sales Ticket Statistics';
                                Image = Report2;
                                RunObject = page "NPR Sales Ticket Statistics";

                                ToolTip = 'Executes the Sales Ticket Statistics action';
                                ApplicationArea = NPRRetail;
                            }
                            action("Advanced Sales Statistics")
                            {
                                Caption = 'Advanced Sales Statistics';
                                Image = ListPage;
                                RunObject = page "NPR Advanced Sales Stats";

                                ToolTip = 'Executes the Advanced Sales Statistics action';
                                ApplicationArea = NPRRetail;
                            }
                        }
                        group(HistoryReport)
                        {
                            Caption = 'Reports and Analysis';
                            Image = AnalysisView;
                            action("NPR Sales per week year/Last year")
                            {
                                Caption = 'Sales per week year/Last year';
                                Image = Report2;
                                RunObject = Report "NPR Sales per week year/Last";

                                ToolTip = 'Executes the NPR Sales per week year/Last year action';
                                ApplicationArea = NPRRetail;
                            }
                            action("NPR Discount Statistics")
                            {
                                Caption = 'Discount Statistics';
                                Image = Report2;
                                RunObject = Report "NPR Discount Statistics";

                                ToolTip = 'Executes the NPR Discount Statistics action';
                                ApplicationArea = NPRRetail;
                            }
                        }
                    }
                }
                group(ItemandPrices)
                {
                    Caption = 'Item & Prices';
                    Image = ItemCosts;
                    group(Goods)
                    {
                        Caption = 'Goods';
                        Image = Item;

                        action("NPR Inventory by age")
                        {
                            Caption = 'Inventory by age';
                            Image = Report;
                            RunObject = report "NPR Inventory by age";

                            ToolTip = 'Executes the NPR Inventory by age action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Inv. Sales Statistics")
                        {
                            Caption = 'Inv. Sales Statistics';
                            Image = Report;
                            RunObject = report "NPR Item Sales Stats/Provider";

                            ToolTip = 'Executes the NPR Inv. Sales Statistics action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Inventory per Date")
                        {
                            Caption = 'Inventory per Date';
                            Image = Report;
                            RunObject = report "NPR Inventory per Date";

                            ToolTip = 'Executes the NPR Inventory per Date action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Item Group Inventory Value")
                        {
                            Caption = 'Item Group Inventory Value';
                            Image = Report;
                            RunObject = report "NPR Item Group Inv. Value";

                            ToolTip = 'Executes the NPR Item Group Inventory Value action';
                            ApplicationArea = NPRRetail;
                        }

                        action("NPR Statistic - Sales")
                        {
                            Caption = 'Statistic - Sales';
                            Image = Report;
                            RunObject = report "NPR Item Sales Postings";

                            ToolTip = 'Executes the NPR Statistic - Sales action';
                            ApplicationArea = NPRRetail;
                        }

                        action("NPR Low Sales")
                        {
                            Caption = 'Low Sales';
                            Image = Report;
                            RunObject = report "NPR Items With Low Sales";

                            ToolTip = 'Executes the NPR Low Sales action';
                            ApplicationArea = NPRRetail;
                        }

                        action("NPR Shrinkage")
                        {
                            Caption = 'Shrinkage';
                            Image = Report;
                            RunObject = report "NPR Item - Loss";

                            ToolTip = 'Executes the NPR Shrinkage action';
                            ApplicationArea = NPRRetail;
                        }

                        action("NPR Item Loss - Return Reason")
                        {
                            Caption = 'Item Loss - Return Reason';
                            Image = Report;
                            RunObject = report "NPR Item Loss - Ret. Reason";

                            ToolTip = 'Executes the NPR Item Loss - Return Reason action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Sales Statistics Variant")
                        {
                            Caption = 'Sales Statistics Variant';
                            Image = Report;
                            RunObject = report "NPR Sales Stats Per Variety";

                            ToolTip = 'Executes the NPR Sales Statistics Variant action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Inventory per Variant at date")
                        {
                            Caption = 'Inventory per Variant at date';
                            Image = Report;
                            RunObject = report "NPR Inventory per Variant/date";

                            ToolTip = 'Executes the NPR Inventory per Variant at date action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Item Barcode Sheet")
                        {
                            Caption = 'Item Barcode Sheet';
                            Image = Report;
                            RunObject = report "NPR Item Barcode Status Sheet";

                            ToolTip = 'Executes the NPR Item Barcode Sheet action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Return Reason Code Statistics")
                        {
                            Caption = 'Return Reason Code Statistics';
                            Image = Report;
                            RunObject = report "NPR Return Reason Code Stat.";

                            ToolTip = 'Executes the NPR Return Reason Code Statistics action';
                            ApplicationArea = NPRRetail;
                        }

                        action("NPR Adjust Cost - Item Entries")
                        {
                            Caption = 'Adjust Cost - Item Entries';
                            Image = Report;
                            RunObject = report "NPR Adjust Cost: ItemEntriesTQ";

                            ToolTip = 'Executes the NPR Adjust Cost - Item Entries action';
                            ApplicationArea = NPRRetail;
                        }

                        action("NPR Item Sales Statistics")
                        {
                            Caption = 'Item Sales Statistics';
                            Image = Report;
                            RunObject = report "NPR Item Sales Statistics";

                            ToolTip = 'Executes the NPR Item Sales Statistics action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Item Group Top")
                        {
                            Caption = 'Item Group Top';
                            Image = Report;
                            RunObject = report "NPR Item Group Top";

                            ToolTip = 'Executes the NPR Item Group Top action';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Lines)
                    {
                        Caption = 'Lines';
                        Image = AllLines;

                        action("NPR Item Group Overview")
                        {
                            Caption = 'Item Group Overview';
                            Image = Report;
                            RunObject = Report "NPR Item Group Overview";

                            ToolTip = 'Executes the NPR Item Group Overview action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Vendor sales per line")
                        {
                            Caption = 'Vendor sales per line';
                            Image = Report;
                            RunObject = report "NPR Vendor trx by Item group";

                            ToolTip = 'Executes the NPR Vendor sales per line action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Sales Person Trn. by Item Gr.")
                        {
                            Caption = 'Sales Person Trn. by Item Gr.';
                            Image = Report;
                            RunObject = Report "NPR S.Person Trx by Item Gr.";

                            ToolTip = 'Executes the NPR Sales Person Trn. by Item Gr. action';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Sales Stat/Analysis")
                        {
                            Caption = 'Sales Stat/Analysis';
                            Image = Report;
                            RunObject = Report "NPR Sales Stat/Analysis";

                            ToolTip = 'Executes the NPR Sales Stat/Analysis action';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Discount)
                    {
                        Caption = 'Discount';
                        Image = Discount;
                        action("NPR Period Discount Statistics")
                        {
                            Caption = 'Period Discount Statistics';
                            Image = Report;
                            RunObject = report "NPR Period Discount Stat.";

                            ToolTip = 'Executes the NPR Period Discount Statistics action';
                            ApplicationArea = NPRRetail;
                        }

                        action("Inventory Campaign Stat.")
                        {
                            Caption = 'Inventory Campaign Stat.';
                            Image = Report;
                            RunObject = Report "NPR Inventory Campaign Stat.";

                            ToolTip = 'Executes the Inventory Campaign Stat. action';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }

            }

        }
        area(sections)
        {
            group("Reference Data")
            {
                Caption = 'Reference Data';
                Image = ReferenceData;
                action(Customers)
                {

                    Caption = 'Customers';
                    Image = Customer;
                    RunObject = Page "Customer List";
                    ToolTip = 'View or edit detailed information for the customers that you trade with. From each customer card, you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
                    ApplicationArea = NPRRetail;
                }

                action(Contact)
                {

                    Caption = 'Contact';
                    Image = Customer;
                    RunObject = Page "Contact List";
                    ToolTip = 'View or edit detailed information for the customers that you trade with. From each contact card, you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
                    ApplicationArea = NPRRetail;
                }
                action(Vendors)
                {

                    Caption = 'Vendors';
                    Image = Vendor;
                    RunObject = Page "Vendor List";
                    ToolTip = 'View or edit detailed information for the vendors that you trade with. From each vendor card, you can open related information, such as purchase statistics and ongoing orders, and you can define special prices and line discounts that the vendor grants you if certain conditions are met.';
                    ApplicationArea = NPRRetail;
                }

                action(MemberList)
                {

                    Caption = 'Member List';
                    Image = Customer;
                    RunObject = page "NPR MM Member Card List";
                    ToolTip = 'View Member List';
                    ApplicationArea = NPRRetail;
                }

                action(Membership)
                {

                    Caption = 'Memberships';
                    Image = Customer;
                    RunObject = page "NPR MM Memberships";
                    ToolTip = 'View Membership List';
                    ApplicationArea = NPRRetail;

                }

                action(ShopperRecognition)
                {

                    Caption = 'EFT Shopper Recognition';
                    Image = Customer;
                    RunObject = page "NPR EFT Shopper Recognition";
                    ToolTip = 'View the shopper recognition details';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Retail Item List action';
                    ApplicationArea = NPRRetail;
                }
                action("Item Categories")
                {
                    Caption = 'Item Categories';
                    RunObject = Page "Item Categories";

                    ToolTip = 'Executes the Item Categories action';
                    ApplicationArea = NPRRetail;
                }
                action("Stockkeeping Unit List")
                {
                    Caption = 'Stockkeeping Unit List';
                    RunObject = Page "Stockkeeping Unit List";

                    ToolTip = 'Executes the Stockkeeping Unit List action';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Journals)
            {
                Caption = 'Journals';
                Image = Journals;

                action(ItemJournalList)
                {

                    Caption = 'Item Journal List';
                    RunObject = page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Item));
                    ToolTip = 'Executes the Item Journal List action';
                    ApplicationArea = NPRRetail;
                }
                action("Physical Inventory Journals")
                {
                    Caption = 'Physical Inventory Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Phys. Inventory"),
                                         Recurring = CONST(false));

                    ToolTip = 'Executes the Physical Inventory Journals action';
                    ApplicationArea = NPRRetail;
                }
                action("Retail Journal List")
                {
                    Caption = 'Retail Journal List';
                    RunObject = page "NPR Retail Journal List";

                    ToolTip = 'Executes the Retail Journal List action';
                    ApplicationArea = NPRRetail;
                }
                action(ItemWorksheets)
                {

                    Caption = 'Item Worksheets';
                    RunObject = page "NPR Item Worksheets";
                    ToolTip = 'Executes the Item Worksheets action';
                    ApplicationArea = NPRRetail;
                }

            }
            group("Retail Documents")
            {
                Caption = 'Documents';
                Image = RegisteredDocs;

                action("POS Entry List")
                {
                    Caption = 'POS Entry List';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = page "NPR POS Entry List";
                    ToolTip = 'View POS Entry that have been done.';
                    ApplicationArea = NPRRetail;

                }
                action("EFT Transaction Request")
                {
                    Caption = 'EFT Transaction Request';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = page "NPR EFT Transaction Requests";
                    ToolTip = 'View EFT Transaction Requests.';
                    ApplicationArea = NPRRetail;

                }

                action(POSQuotes)
                {
                    Caption = 'POS Saved Sales';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = page "NPR POS Saved Sales";
                    ToolTip = 'View POS Saved Sales that have been done.';
                    ApplicationArea = NPRRetail;


                }
                action("Posted Sales Invoices")
                {
                    Caption = 'Posted Sales Invoices List';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "Posted Sales Invoices";
                    ToolTip = 'View Sales Invoices that have been done.';
                    ApplicationArea = NPRRetail;

                }

                action("Posted Sales Shipment List")
                {
                    Caption = 'Posted Sales Shipment List';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "Posted Sales Shipments";
                    ToolTip = 'View Posted Sales Shipments that have been done.';
                    ApplicationArea = NPRRetail;
                }

                action("Posted Sales Credit Memos List")
                {
                    Caption = 'Posted Sales Credit Memos List';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'View Sales Credit Memos that have been done.';
                    ApplicationArea = NPRRetail;

                }
            }
            group("Discount, Coupons & Vouchers")
            {
                action("Campaign Discount List")
                {
                    Caption = 'Campaign Discount List';
                    RunObject = page "NPR Campaign Discount List";

                    ToolTip = 'Executes the Campaign Discount List action';
                    ApplicationArea = NPRRetail;
                }

                action("Mixed Discount List")
                {
                    Caption = 'Mixed Discount List';
                    RunObject = page "NPR Mixed Discount List";

                    ToolTip = 'Executes the Mixed Discount List action';
                    ApplicationArea = NPRRetail;
                }
                action("Coupon List")
                {
                    Caption = 'Coupon List';
                    RunObject = page "NPR NpDc Coupons";

                    ToolTip = 'Executes the Coupon List action';
                    ApplicationArea = NPRRetail;
                }
                action("Voucher List")
                {
                    Caption = 'Voucher List';
                    RunObject = page "NPR NpRv Vouchers";

                    ToolTip = 'Executes the Voucher List action';
                    ApplicationArea = NPRRetail;
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
                RunObject = Page "Sales Order";
                RunPageMode = Create;

                ToolTip = 'Executes the Sales &Order action';
                ApplicationArea = NPRRetail;
            }
            action("Sales &Return Order")
            {
                Caption = 'Sales &Return Order';
                Image = ReturnOrder;
                RunObject = Page "Sales Return Order";
                RunPageMode = Create;

                ToolTip = 'Executes the Sales &Return Order action';
                ApplicationArea = NPRRetail;
            }
            action("&Transfer Order")
            {
                Caption = '&Transfer Order';
                Image = TransferOrder;
                RunObject = Page "Transfer Order";
                RunPageMode = Create;

                ToolTip = 'Executes the &Transfer Order action';
                ApplicationArea = NPRRetail;
            }
            action("&Purchase Order")
            {
                Caption = '&Purchase Order';
                Image = Document;
                Promoted = false;
                RunObject = Page "Purchase Order";
                RunPageMode = Create;

                ToolTip = 'Executes the &Purchase Order action';
                ApplicationArea = NPRRetail;
            }
            action("Purchase Return Order")
            {
                Caption = 'Purchase Return Order';
                Image = Document;
                RunObject = Page "Purchase Return Order";

                ToolTip = 'Executes the Purchase Return Order action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}
