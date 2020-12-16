page 6151241 "NPR Retail POS- Sales Person R"
{
    Caption = 'NP Retail Salesperson';
    PageType = RoleCenter;
    UsageCategory = Administration;

    layout
    {
        area(rolecenter)
        {


            part(Control7; "Headline RC Order Processor")
            {
                ApplicationArea = Basic, Suite;
            }

            part("NP Retail SO Processor Act"; "NPR SO Processor Act")
            {
                ApplicationArea = All;
            }

            part(Control6150616; "NPR Activities")
            {
                ApplicationArea = All;
            }
            part(Control6150613; "NPR Retail Top 10 S.person")
            {
                ApplicationArea = All;

            }
            part(NPRetailPOSEntryCue; "NPR POS Entry Cue")
            {
                Caption = 'POS Activities';
                ApplicationArea = All;
            }
            part(ControlPurchase; "NPR Acc. Payables Act")
            {
                Caption = 'Purchase Activities';
                ApplicationArea = All;
            }

            part(Control6150614; "NPR Retail 10 Items by Qty.")
            {
                ApplicationArea = All;
            }

            part(Control6150615; "NPR Retail Top 10 Customers")
            {
                ApplicationArea = All;
            }
            part(RetailTop10Vendors; "NPR Top 10 Vendors")
            {
                ApplicationArea = All;

            }
            part(PowerBi; "Power BI Report Spinner Part")
            {
                ApplicationArea = All;
            }
            part("MyReports"; "NPR My Reports")
            {
                ApplicationArea = All;
            }

            part(Control21; "Report Inbox Part")
            {
                AccessByPermission = TableData "Report Inbox" = R;
                ApplicationArea = Suite;
            }

            part(MyjobQueue; "My Job Queue")
            {
                ApplicationArea = All;
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
                    Caption = 'VAT - VIES Declaration Tax A&uth';
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

        }
        area(sections)
        {
            group("Reference Data")
            {
                Caption = 'Reference Data';
                Image = ReferenceData;
                action(Customers)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Customers';
                    Image = Customer;
                    RunObject = Page "Customer List";
                    ToolTip = 'View or edit detailed information for the customers that you trade with. From each customer card, you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
                }

                action(Contact)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Contact';
                    Image = Customer;
                    RunObject = Page "Contact List";
                    ToolTip = 'View or edit detailed information for the customers that you trade with. From each contact card, you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
                }
                action(Vendors)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Vendors';
                    Image = Vendor;
                    RunObject = Page "Vendor List";
                    ToolTip = 'View or edit detailed information for the vendors that you trade with. From each vendor card, you can open related information, such as purchase statistics and ongoing orders, and you can define special prices and line discounts that the vendor grants you if certain conditions are met.';
                }

                action(MemberList)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Member List';
                    Image = Customer;
                    RunObject = page "NPR MM Member Card List";
                    ToolTip = 'View Member List';
                }

                action(Membership)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Memberships';
                    Image = Customer;
                    RunObject = page "NPR MM Memberships";
                    ToolTip = 'View Membership List';

                }

                action(ShopperRecognition)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'EFT Shopper Recognition';
                    Image = Customer;
                    RunObject = page "NPR EFT Shopper Recognition";
                    ToolTip = 'View the shopper recognition details';
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
                }
                action("Item Group Tree")
                {
                    Caption = 'Item Group Tree';
                    RunObject = Page "NPR Item Group Tree";
                    ApplicationArea = All;
                }
                action("Stockkeeping Unit List")
                {
                    Caption = 'Stockkeeping Unit List';
                    RunObject = Page "Stockkeeping Unit List";
                    ApplicationArea = All;
                }

            }


            group(Journals)
            {
                Caption = 'Journals';
                Image = Journals;

                action(ItemJournalList)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Item Journal List';
                    RunObject = page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Item));
                }

                action("Physical Inventory Journals")
                {
                    Caption = 'Physical Inventory Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Phys. Inventory"),
                                         Recurring = CONST(false));
                    ApplicationArea = All;
                }

                action("Retail Journal List")
                {
                    Caption = 'Retail Journal List';
                    RunObject = page "NPR Retail Journal List";
                    ApplicationArea = All;
                }
                action(ItemWorksheets)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Item Worksheets';
                    RunObject = page "NPR Item Worksheets";
                }

            }


            group("Retail Documents")
            {
                Caption = 'Documents';
                Image = RegisteredDocs;

                action("POS Entry List")
                {
                    //ApplicationArea = Documents;
                    Caption = 'POS Entry List';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = page "NPR POS Entry List";
                    ToolTip = 'View POS Entry that have been done.';
                    ApplicationArea = All;
                }

                action(POSQuotes)
                {
                    Caption = 'POS Quotes';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = page "NPR POS Quotes";
                    ToolTip = 'View POS Quotes that have been done.';
                    ApplicationArea = All;

                }
                action("Posted Sales Invoices")
                {
                    //ApplicationArea = Documents;
                    Caption = 'Posted Sales Invoices List';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Posted Sales Invoices";
                    ToolTip = 'View Sales Invoices that have been done.';
                    ApplicationArea = All;
                }

                action("Posted Sales Credit Memos List")
                {
                    //ApplicationArea = Documents;
                    Caption = 'Posted Sales Credit Memos List';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'View Sales Credit Memos that have been done.';
                    ApplicationArea = All;
                }
                action("Repair Document List")
                {
                    //ApplicationArea = Warehouse;
                    Caption = 'Repair Document List';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Customer Repair List";
                    ToolTip = 'View the list of Repair List.';
                    ApplicationArea = All;
                }
            }

            group("Discount, Coupons & Vouchers")
            {
                action("Campaign Discount List")
                {
                    Caption = 'Campaign Discount List';
                    RunObject = page "NPR Campaign Discount List";
                    ApplicationArea = All;
                }

                action("Mixed Discount List")
                {
                    Caption = 'Mixed Discount List';
                    RunObject = page "NPR Mixed Discount List";
                    ApplicationArea = All;
                }
                action("Coupon List")
                {
                    Caption = 'Coupon List';
                    RunObject = page "NPR NpDc Coupons";
                    ApplicationArea = All;
                }
                action("Voucher List")
                {
                    Caption = 'Voucher List';
                    RunObject = page "NPR NpRv Vouchers";
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
                RunObject = Page "Sales Credit Memo";
                RunPageMode = Create;
                ApplicationArea = All;
            }
            action("&Transfer Order")
            {
                Caption = '&Transfer Order';
                Image = TransferOrder;
                RunObject = Page "Transfer Order";
                RunPageMode = Create;
                ApplicationArea = All;
            }
            action("&Purchase Order")
            {
                Caption = '&Purchase Order';
                Image = Document;
                Promoted = false;
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


            group(Reports)
            {
                Caption = 'List & Reports';

                group(ActionGroup6014408)
                {
                    Caption = 'Retail';

                    group(Management)
                    {
                        Caption = 'Management';

                        group(Salespersons)

                        {
                            Caption = 'Salespersons';
                            action("NPR Sales Person Top 20")
                            {
                                Caption = 'NPR Sales Person Top 20';
                                Image = Report2;
                                RunObject = Report "NPR Sales Person Top 20";
                                ApplicationArea = All;
                            }
                            action("NPR Sales code/Item group top")
                            {
                                Caption = 'NPR  Sales code/Item group top';
                                Image = Report2;
                                RunObject = Report "NPR Salesperson/Item Group Top";
                                ApplicationArea = All;
                            }
                            action("NPR Sale Statistics per Vendor")
                            {
                                Caption = 'NPR Sale Statistics per Vendor';
                                Image = Report2;
                                RunObject = Report "NPR Sale Statistics per Vendor";
                                ApplicationArea = All;
                            }


                        }

                        group(Webshop)
                        {
                            Caption = 'Webshop';
                            action("NPR List of Sales Invoices")
                            {
                                Caption = 'NPR List of Sales Invoices';
                                Image = Report2;
                                RunObject = Report "NPR List of Sales Invoices";
                                ApplicationArea = All;
                            }
                            action("NPR Item Wise Sales Figures")
                            {
                                Caption = 'NPR Item Wise Sales Figures';
                                Image = Report2;
                                RunObject = Report "NPR Item Wise Sales Figures";
                                ApplicationArea = All;
                            }


                        }

                        group(History)
                        {
                            Caption = 'History';

                            group(HistoryList)
                            {
                                Caption = 'Lists';

                                action("Sales Ticket Statistics")
                                {
                                    Caption = 'Sales Ticket Statistics';
                                    Image = Report2;
                                    RunObject = page "NPR Sales Ticket Statistics";
                                    ApplicationArea = All;
                                }
                                action("Advanced Sales Statistics")
                                {
                                    Caption = 'Advanced Sales Statistics';
                                    Image = ListPage;
                                    RunObject = page "NPR Advanced Sales Stats";
                                    ApplicationArea = All;
                                }
                                action("Sales Statistics by Date Time")
                                {
                                    Caption = 'Sales Statistics by Date Time';
                                    Image = ListPage;
                                    ApplicationArea = All;
                                    //RunObject = page sales st
                                }
                                action(Periods)
                                {
                                    Caption = 'Periods';
                                    Image = ListPage;
                                    RunObject = page "NPR Periods";
                                    ApplicationArea = All;
                                }

                            }
                            group(HistoryReport)
                            {
                                Caption = 'Reports and Analysis';
                                action("NPR Sales per week year/Last year")
                                {
                                    Caption = 'NPR Sales per week year/Last year';
                                    Image = Report2;
                                    RunObject = Report "NPR Sales per week year/Last";
                                    ApplicationArea = All;
                                }


                                action("NPR Discount Statistics")
                                {
                                    Caption = 'NPR Discount Statistics';
                                    Image = Report2;
                                    RunObject = Report "NPR Discount Statistics";
                                    ApplicationArea = All;
                                }
                                action("NPR Sales Ticket Statistics/Date")
                                {
                                    Caption = 'NPR Sales Ticket Statistics/Date';
                                    Image = Report2;
                                    RunObject = Report "NPR Sales Ticket Stats/Date";
                                    ApplicationArea = All;
                                }
                            }
                        }

                    }

                    group(ItemandPrices)
                    {
                        Caption = 'Item & Prices';
                        group(Goods)
                        {
                            Caption = 'Goods';

                            group(Lists)
                            {
                                Caption = 'Lists';
                                action("Retail Item List")
                                {
                                    Caption = 'Retail Item';
                                    Image = ListPage;
                                    RunObject = page "Item List";
                                    ApplicationArea = All;
                                }
                                action(Items)
                                {
                                    Caption = 'Items';
                                    Image = ListPage;
                                    RunObject = page "Item List";
                                    ApplicationArea = All;
                                }
                                action("Item AddOns")
                                {
                                    Caption = 'Item AddOns';
                                    Image = ListPage;
                                    RunObject = page "NPR NpIa Item AddOns";
                                    ApplicationArea = All;
                                }
                            }

                            group(ReportsGoods)
                            {
                                Caption = 'Reports and Analysis';
                                action("NPR Inventory by age")
                                {
                                    Caption = 'NPR Inventory by age';
                                    Image = Report;
                                    RunObject = report "NPR Inventory by age";
                                    ApplicationArea = All;
                                }
                                action("NPR Inv. Sales Statistics")
                                {
                                    Caption = 'NPR Inv. Sales Statistics';
                                    Image = Report;
                                    RunObject = report "NPR Item Sales Stats/Provider";
                                    ApplicationArea = All;
                                }
                                action("NPR Inventory per Date")
                                {
                                    Caption = 'NPR Inventory per Date';
                                    Image = Report;
                                    RunObject = report "NPR Inventory per Date";
                                    ApplicationArea = All;
                                }
                                action("NPR Item Group Inventory Value")
                                {
                                    Caption = 'NPR Item Group Inventory Value';
                                    Image = Report;
                                    RunObject = report "NPR Item Group Inv. Value";
                                    ApplicationArea = All;
                                }

                                action("NPR Statistic - Sales")
                                {
                                    Caption = 'NPR Statistic - Sales';
                                    Image = Report;
                                    RunObject = report "NPR Item Sales Postings";
                                    ApplicationArea = All;
                                }

                                action("NPR Low Sales")
                                {
                                    Caption = 'NPR Low Sales';
                                    Image = Report;
                                    RunObject = report "NPR Items With Low Sales";
                                    ApplicationArea = All;
                                }

                                action("NPR Shrinkage")
                                {
                                    Caption = 'NPR Shrinkage';
                                    Image = Report;
                                    RunObject = report "NPR Item - Loss";
                                    ApplicationArea = All;
                                }

                                action("NPR Item Loss - Return Reason")
                                {
                                    Caption = 'NPR Item Loss - Return Reason';
                                    Image = Report;
                                    RunObject = report "NPR Item Loss - Ret. Reason";
                                    ApplicationArea = All;
                                }
                                action("NPR Sales Statistics Variant")
                                {
                                    Caption = 'NPR Sales Statistics Variant';
                                    Image = Report;
                                    RunObject = report "NPR Sales Stats Per Variety";
                                    ApplicationArea = All;
                                }
                                action("NPR Inventory per Variant at date")
                                {
                                    Caption = 'NPR Inventory per Variant at date';
                                    Image = Report;
                                    RunObject = report "NPR Inventory per Variant/date";
                                    ApplicationArea = All;
                                }
                                action("NPR Item Group Statistic M/Y")
                                {
                                    Caption = 'NPR Item Group Statistic M/Y';
                                    Image = Report;
                                    RunObject = report "NPR Item Group Stat M/Y";
                                    ApplicationArea = All;
                                }

                                action("NPR Item Group Listing M/Y")
                                {
                                    Caption = 'NPR Item Group Listing M/Y';
                                    Image = Report;
                                    RunObject = report "NPR Item Group Listing M/Y";
                                    ApplicationArea = All;
                                }

                                action("NPR Item Barcode Sheet")
                                {
                                    Caption = 'NPR Item Barcode Sheet';
                                    Image = Report;
                                    RunObject = report "NPR Item Barcode Status Sheet";
                                    ApplicationArea = All;
                                }
                                action("NPR Return Reason Code Statistics")
                                {
                                    Caption = 'NPR Return Reason Code Statistics';
                                    Image = Report;
                                    RunObject = report "NPR Return Reason Code Stat.";
                                    ApplicationArea = All;
                                }

                                action("NPR Adjust Cost - Item Entries")
                                {
                                    Caption = 'NPR Adjust Cost - Item Entries';
                                    Image = Report;
                                    RunObject = report "NPR Adjust Cost: ItemEntriesTQ";
                                    ApplicationArea = All;
                                }

                                action("NPR Item Sales Statistics")
                                {
                                    Caption = 'NPR Item Sales Statistics';
                                    Image = Report;
                                    RunObject = report "NPR Item Sales Statistics";
                                    ApplicationArea = All;
                                }
                                action("NPR Item Group Top")
                                {
                                    Caption = 'NPR Item Group Top';
                                    Image = Report;
                                    RunObject = report "NPR Item Group Top";
                                    ApplicationArea = All;
                                }


                            }
                        }
                        group(Lines)
                        {
                            Caption = 'Lines';

                            group(ListsLine)
                            {

                                Caption = 'Lists';
                                action("Item Groups")
                                {
                                    Caption = 'Item AddOns';
                                    Image = ListPage;
                                    RunObject = page "NPR NpIa Item AddOns";
                                    ApplicationArea = All;
                                }

                                action("Sales Price Maintenance Setup")
                                {
                                    Caption = 'Sales Price Maintenance Setup';
                                    Image = ListPage;
                                    RunObject = page "NPR Sales Price Maint. Setup";
                                    ApplicationArea = All;
                                }

                                action("Retail Price Log Entries")
                                {
                                    Caption = 'Retail Price Log Entries';
                                    Image = ListPage;
                                    RunObject = page "NPR Retail Price Log Entries";
                                    ApplicationArea = All;
                                }
                            }
                            group(LineReports)
                            {

                                Caption = 'Reports and Analysis';
                                action("NPR Item Group Overview")
                                {
                                    Caption = 'NPR Item Group Overview';
                                    Image = Report;
                                    RunObject = Report "NPR Item Group Overview";
                                    ApplicationArea = All;
                                }

                                action("NPR Vendor sales per line")
                                {
                                    Caption = 'NPR Vendor sales per line';
                                    Image = Report;
                                    RunObject = report "NPR Vendor trx by Item group";
                                    ApplicationArea = All;
                                }

                                action("NPR Sales Person Trn. by Item Gr.")
                                {
                                    Caption = 'NPR Sales Person Trn. by Item Gr.';
                                    Image = Report;
                                    RunObject = Report "NPR S.Person Trx by Item Gr.";
                                    ApplicationArea = All;
                                }
                                action("NPR Sales Stat/Analysis")
                                {
                                    Caption = 'NPR Sales Stat/Analysis';
                                    Image = Report;
                                    RunObject = Report "NPR Sales Stat/Analysis";
                                    ApplicationArea = All;
                                }
                            }


                        }

                        group(Discount)
                        {
                            Caption = 'Discount';
                            group(DiscountList)
                            {
                                Caption = 'Lists';
                                action("Item Groups Tree")
                                {
                                    Caption = 'Mix Discounts';
                                    Image = ListPage;
                                    RunObject = page "NPR Mixed Discount List";
                                    ApplicationArea = All;
                                }
                                action("Period Discounts")
                                {
                                    Caption = 'Period Discounts';
                                    Image = ListPage;
                                    RunObject = page "NPR Campaign Discount List";
                                    ApplicationArea = All;
                                }
                                action("Retail Campaigns")
                                {
                                    Caption = 'Retail Campaigns';
                                    Image = ListPage;
                                    RunObject = page "NPR Retail Campaigns";
                                    ApplicationArea = All;
                                }

                            }
                            group(DiscountReports)
                            {

                                Caption = 'Reports and Analysis';
                                action("NPR Stock Campaign stat.")
                                {
                                    Caption = 'NPR Stock Campaign stat.';
                                    Image = Report;
                                    RunObject = Report "NPR Inventory Campaign Stat.";
                                    ApplicationArea = All;
                                }

                                action("NPR Period Discount Statistics")
                                {
                                    Caption = 'NPR Period Discount Statistics';
                                    Image = Report;
                                    RunObject = report "NPR Period Discount Stat.";
                                    ApplicationArea = All;
                                }

                                action("Inventory Campaign Stat.")
                                {
                                    Caption = 'Inventory Campaign Stat.';
                                    Image = Report;
                                    RunObject = Report "NPR Inventory Campaign Stat.";
                                    ApplicationArea = All;
                                }
                            }

                        }

                    }


                }

            }



            /*
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
            */

            group(Vendor)
            {
                Caption = 'Vendor';
                action("NPR Vendor Top/Sale")
                {
                    Caption = 'NPR Vendor Top/Sale';
                    Image = Report2;
                    RunObject = Report "NPR Vendor Top/Sale";
                    ApplicationArea = All;
                }
                action("NPR Vendor/Item Group")
                {
                    Caption = 'NPR Vendor/Item Group';
                    Image = Report2;
                    RunObject = Report "NPR Vendor/Item Group";
                    ApplicationArea = All;
                }
                action("NPR Vendor/Salesperson")
                {
                    Caption = 'NPR Vendor/Salesperson';
                    Image = Report2;
                    RunObject = Report "NPR Vendor/Salesperson";
                    ApplicationArea = All;
                }

                action("NPR Vendor Sales Stat")
                {
                    Caption = 'NPR Vendor Sales Stat';
                    Image = Report2;
                    RunObject = Report "NPR Vendor Sales Stat";
                    ApplicationArea = All;
                }

            }


            group(SalesAssistent)
            {
                Caption = 'Sales Assistent';
                action("NPR Sales Statistics")
                {
                    Caption = 'NPR Sales Statistics';
                    Image = Report2;
                    RunObject = Report "NPR Sales Ticket Stat.";
                    ApplicationArea = All;
                }
                action("NPR Salesperson Statistics")
                {
                    Caption = 'NPR Salesperson Statistics';
                    Image = Report2;
                    RunObject = Report "NPR Salesperson Stats";
                    ApplicationArea = All;
                }
                action("NPR Sales Time")
                {
                    Caption = 'NPR  Sales Time';
                    Image = Report2;
                    RunObject = Report "NPR Sale Time Report";
                    ApplicationArea = All;
                }

                action("NPR Sales Statistics By Department")
                {
                    Caption = 'NPR Sales Statistics By Department';
                    Image = Report2;
                    RunObject = Report "NPR Sales Statistics By Dept.";
                    ApplicationArea = All;
                }
                action("POS Item Sales with Dimensions")
                {
                    Caption = 'POS Item Sales with Dimensions';
                    Image = Report2;
                    ApplicationArea = All;
                    //RunObject = Report "pos item with dimension";
                }
            }
        }
    }
}