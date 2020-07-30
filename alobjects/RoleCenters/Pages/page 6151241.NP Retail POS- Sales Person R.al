page 6151241 "NP Retail POS- Sales Person R"
{

    // #369128/YAHA/20190918  CASE 369128 Removing/Adding new menu

    Caption = 'NP Retail Salesperson';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {


            part(Control7; "Headline RC Order Processor")
            {
                ApplicationArea = Basic, Suite;
            }
            /* part("O365 Activities Ext"; "O365 Activities Ext")
            {

            }
             */
            part("NP Retail SO Processor Act"; "NP Retail SO Processor Act")
            {

            }

            part(Control6150616; "NP Retail Activities")
            {
            }
            part(Control6150613; "Retail Top 10 Salesperson")
            {

            }
            part(NPRetailPOSEntryCue; "NP Retail POS Entry Cue")
            {
                Caption = 'POS Activities';
            }


            part(ControlPurchase; "NP Retail Acc. Payables Act")
            {
                Caption = 'Purchase Activities';
            }

            part(Control6150614; "Retail 10 Items by Qty.")
            {
            }

            part(Control6150615; "Retail Top 10 Customers")
            {

            }
            part(RetailTop10Vendors; "NP Retail Top 10 Vendors")
            {

            }

            part(PowerBi; "Power BI Report Spinner Part")
            {

            }

            part("MyReports"; "My Reports")
            {
            }

            part(Control21; "Report Inbox Part")
            {
                AccessByPermission = TableData "Report Inbox" = R;
                ApplicationArea = Suite;
            }

            part(MyjobQueue; "My Job Queue")
            {
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
                    RunObject = page "MM Member Card List";
                    ToolTip = 'View Member List';
                }

                action(Membership)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Memberships';
                    Image = Customer;
                    RunObject = page "MM Memberships";
                    ToolTip = 'View Membership List';

                }

                action(ShopperRecognition)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'EFT Shopper Recognition';
                    Image = Customer;
                    RunObject = page "EFT Shopper Recognition";
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
                }

                action("Retail Journal List")
                {
                    Caption = 'Retail Journal List';
                    RunObject = page "Retail Journal List";
                }
                action(ItemWorksheets)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Item Worksheets';
                    RunObject = page "Item Worksheets";
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
                    RunObject = page "POS Entry List";
                    ToolTip = 'View POS Entry that have been done.';
                }

                action(POSQuotes)
                {
                    Caption = 'POS Quotes';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = page "POS Quotes";
                    ToolTip = 'View POS Quotes that have been done.';

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
                }



                action("Retail Document")
                {
                    //ApplicationArea = Warehouse;
                    Caption = 'Retail Document';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Retail Document List";
                    ToolTip = 'View the list of Retail Document.';
                }
                action("Repair Document List")
                {
                    //ApplicationArea = Warehouse;
                    Caption = 'Repair Document List';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Customer Repair List";
                    ToolTip = 'View the list of Repair List.';
                }
                action("Warranty Catalog List")
                {

                    Caption = 'Warranty Catalog List';
                    Image = PostedReceipts;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Warranty Catalog List";
                    ToolTip = 'View the Warranty Catalog List.';
                }
                /*
                action("Posted Purchase Invoices List")
                {
                    //ApplicationArea = Warehouse;
                    Caption = 'Posted Purchase Invoices List';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Posted Purchase Invoices";
                    ToolTip = 'View the Posted Purchase Invoices.';
                }

                action("Posted Purchase Credit Memos List")
                {
                    //ApplicationArea = Warehouse;
                    Caption = 'Posted Purchase Credit Memos List';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Posted Purchase Credit Memos";
                    ToolTip = 'View the Posted Purchase Credit Memos.';
                }
                */

            }

            group("Discount, Coupons & Vouchers")
            {
                action("Campaign Discount List")
                {
                    Caption = 'Campaign Discount List';
                    RunObject = page "Campaign Discount List";
                }

                action("Mixed Discount List")
                {
                    Caption = 'Mixed Discount List';
                    RunObject = page "Mixed Discount List";
                }
                action("Coupon List")
                {
                    Caption = 'Coupon List';
                    RunObject = page "NpDc Coupons";
                }
                action("Voucher List")
                {
                    Caption = 'Voucher List';
                    RunObject = page "NpRv Vouchers";
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
                RunObject = Page "Sales Credit Memo";
                RunPageMode = Create;
            }
            action("&Transfer Order")
            {
                Caption = '&Transfer Order';
                Image = TransferOrder;
                RunObject = Page "Transfer Order";
                RunPageMode = Create;
            }
            action("&Purchase Order")
            {
                Caption = '&Purchase Order';
                Image = Document;
                Promoted = false;
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


            group(Reports)
            {
                CaptionML = DAN = 'Rapporter',
                ENU = 'List & Reports';

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
                                RunObject = Report "Sales Person Top 20";
                            }
                            action("NPR Sales code/Item group top")
                            {
                                Caption = 'NPR  Sales code/Item group top';
                                Image = Report2;
                                RunObject = Report "Salesperson/Item Group Top";
                            }
                            action("NPR Sale Statistics per Vendor")
                            {
                                Caption = 'NPR Sale Statistics per Vendor';
                                Image = Report2;
                                RunObject = Report "Sale Statistics per Vendor";
                            }


                        }

                        group(Webshop)
                        {
                            Caption = 'Webshop';
                            action("NPR List of Sales Orders")
                            {
                                Caption = 'NPR List of Sales Orders';
                                Image = Report2;
                                RunObject = Report "List of Sales Orders";
                            }
                            action("NPR List of Sales Invoices")
                            {
                                Caption = 'NPR List of Sales Invoices';
                                Image = Report2;
                                RunObject = Report "List of Sales Invoices";
                            }
                            action("NPR Item Wise Sales Figures")
                            {
                                Caption = 'NPR Item Wise Sales Figures';
                                Image = Report2;
                                RunObject = Report "Item Wise Sales Figures";
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
                                    RunObject = page "Sales Ticket Statistics";
                                }
                                action("Advanced Sales Statistics")
                                {
                                    Caption = 'Advanced Sales Statistics';
                                    Image = ListPage;
                                    RunObject = page "Advanced Sales Statistics";
                                }
                                action("Sales Statistics by Date Time")
                                {
                                    Caption = 'Sales Statistics by Date Time';
                                    Image = ListPage;
                                    //RunObject = page sales st
                                }
                                action("Periods")
                                {
                                    Caption = 'Periods';
                                    Image = ListPage;
                                    RunObject = page Periods;
                                }

                            }
                            group(HistoryReport)
                            {
                                Caption = 'Reports and Analysis';
                                action("NPR Sales per week year/Last year")
                                {
                                    Caption = 'NPR Sales per week year/Last year';
                                    Image = Report2;
                                    RunObject = Report "Sales per week year/Last year";
                                }


                                action("NPR Discount Statistics")
                                {
                                    Caption = 'NPR Discount Statistics';
                                    Image = Report2;
                                    RunObject = Report "Discount Statistics";
                                }
                                action("NPR Sales Ticket Statistics/Date")
                                {
                                    Caption = 'NPR Sales Ticket Statistics/Date';
                                    Image = Report2;
                                    RunObject = Report "Sales Ticket Statistics/Date";
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
                                    RunObject = page "Retail Item List";
                                }
                                action("Items")
                                {
                                    Caption = 'Items';
                                    Image = ListPage;
                                    RunObject = page "Item List";
                                }
                                action("Item AddOns")
                                {
                                    Caption = 'Item AddOns';
                                    Image = ListPage;
                                    RunObject = page "NpIa Item AddOns";
                                }
                            }

                            group(ReportsGoods)
                            {
                                Caption = 'Reports and Analysis';
                                action("NPR Inventory by age")
                                {
                                    Caption = 'NPR Inventory by age';
                                    Image = Report;
                                    RunObject = report "Inventory by age";
                                }
                                action("NPR Inv. Sales Statistics")
                                {
                                    Caption = 'NPR Inv. Sales Statistics';
                                    Image = Report;
                                    RunObject = report "Item Sales Statistics/Provider";
                                }
                                action("NPR Inventory per Date")
                                {
                                    Caption = 'NPR Inventory per Date';
                                    Image = Report;
                                    RunObject = report "Inventory per Date";
                                }
                                action("NPR Item Group Inventory Value")
                                {
                                    Caption = 'NPR Item Group Inventory Value';
                                    Image = Report;
                                    RunObject = report "Item Group Inventory Value";
                                }

                                action("NPR Statistic - Sales")
                                {
                                    Caption = 'NPR Statistic - Sales';
                                    Image = Report;
                                    RunObject = report "Item Sales Postings";
                                }

                                action("NPR Low Sales")
                                {
                                    Caption = 'NPR Low Sales';
                                    Image = Report;
                                    RunObject = report "Items With Low Sales";
                                }

                                action("NPR Shrinkage")
                                {
                                    Caption = 'NPR Shrinkage';
                                    Image = Report;
                                    RunObject = report "Item - Loss";
                                }

                                action("NPR Item Loss - Return Reason")
                                {
                                    Caption = 'NPR Item Loss - Return Reason';
                                    Image = Report;
                                    RunObject = report "Item Loss - Return Reason";
                                }
                                action("NPR Sales Statistics Variant")
                                {
                                    Caption = 'NPR Sales Statistics Variant';
                                    Image = Report;
                                    RunObject = report "Sales Statistics Per Variety";
                                }
                                action("NPR Inventory per Variant at date")
                                {
                                    Caption = 'NPR Inventory per Variant at date';
                                    Image = Report;
                                    RunObject = report "Inventory per Variant at date";
                                }
                                action("NPR Item Group Statistic M/Y")
                                {
                                    Caption = 'NPR Item Group Statistic M/Y';
                                    Image = Report;
                                    RunObject = report "Item Group Stat M/Y";
                                }

                                action("NPR Item Group Listing M/Y")
                                {
                                    Caption = 'NPR Item Group Listing M/Y';
                                    Image = Report;
                                    RunObject = report "Item Group Listing M/Y";
                                }

                                action("NPR Item Barcode Sheet")
                                {
                                    Caption = 'NPR Item Barcode Sheet';
                                    Image = Report;
                                    RunObject = report "Item Barcode Status Sheet";
                                }
                                action("NPR Return Reason Code Statistics")
                                {
                                    Caption = 'NPR Return Reason Code Statistics';
                                    Image = Report;
                                    RunObject = report "Return Reason Code Statistics";
                                }

                                action("NPR Adjust Cost - Item Entries")
                                {
                                    Caption = 'NPR Adjust Cost - Item Entries';
                                    Image = Report;
                                    RunObject = report "Adjust Cost - Item Entries TQ";
                                }

                                action("NPR Item Sales Statistics")
                                {
                                    Caption = 'NPR Item Sales Statistics';
                                    Image = Report;
                                    RunObject = report "Item Sales Statistics NPR";
                                }
                                action("NPR Item Group Top")
                                {
                                    Caption = 'NPR Item Group Top';
                                    Image = Report;
                                    RunObject = report "Item Group Top";
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
                                    RunObject = page "NpIa Item AddOns";
                                }

                                action("Sales Price Maintenance Setup")
                                {
                                    Caption = 'Sales Price Maintenance Setup';
                                    Image = ListPage;
                                    RunObject = page "Sales Price Maintenance Setup";
                                }

                                action("Retail Price Log Entries")
                                {
                                    Caption = 'Retail Price Log Entries';
                                    Image = ListPage;
                                    RunObject = page "Retail Price Log Entries";
                                }
                            }
                            group(LineReports)
                            {

                                Caption = 'Reports and Analysis';
                                action("NPR Item Group Overview")
                                {
                                    Caption = 'NPR Item Group Overview';
                                    Image = Report;
                                    RunObject = Report "Item Group Overview";
                                }

                                action("NPR Vendor sales per line")
                                {
                                    Caption = 'NPR Vendor sales per line';
                                    Image = Report;
                                    RunObject = report "Vendor trn. by Item group";
                                }

                                action("NPR Sales Person Trn. by Item Gr.")
                                {
                                    Caption = 'NPR Sales Person Trn. by Item Gr.';
                                    Image = Report;
                                    RunObject = Report "Sales Person Trn. by Item Gr.";
                                }
                                action("NPR Sales Stat/Analysis")
                                {
                                    Caption = 'NPR Sales Stat/Analysis';
                                    Image = Report;
                                    RunObject = Report "Sales Stat/Analysis";
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
                                    RunObject = page "Mixed Discount List";
                                }
                                action("Period Discounts")
                                {
                                    Caption = 'Period Discounts';
                                    Image = ListPage;
                                    RunObject = page "Campaign Discount List";
                                }
                                action("Retail Campaigns")
                                {
                                    Caption = 'Retail Campaigns';
                                    Image = ListPage;
                                    RunObject = page "Retail Campaigns";
                                }

                            }
                            group(DiscountReports)
                            {

                                Caption = 'Reports and Analysis';
                                action("NPR Stock Campaign stat.")
                                {
                                    Caption = 'NPR Stock Campaign stat.';
                                    Image = Report;
                                    RunObject = Report "Inventory Campaign Stat.";
                                }

                                action("NPR Period Discount Statistics")
                                {
                                    Caption = 'NPR Period Discount Statistics';
                                    Image = Report;
                                    RunObject = report "Period Discount Statistics";
                                }

                                action("Inventory Campaign Stat.")
                                {
                                    Caption = 'Inventory Campaign Stat.';
                                    Image = Report;
                                    RunObject = Report "Inventory Campaign Stat.";
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
                    RunObject = Report "Vendor Top/Sale";
                }
                action("NPR Vendor/Item Group")
                {
                    Caption = 'NPR Vendor/Item Group';
                    Image = Report2;
                    RunObject = Report "Vendor/Item Group";
                }
                action("NPR Vendor/Salesperson")
                {
                    Caption = 'NPR Vendor/Salesperson';
                    Image = Report2;
                    RunObject = Report "Vendor/Salesperson";
                }

                action("NPR Vendor Sales Stat")
                {
                    Caption = 'NPR Vendor Sales Stat';
                    Image = Report2;
                    RunObject = Report "Vendor Sales Stat";
                }

            }


            group(SalesAssistent)
            {
                Caption = 'Sales Assistent';
                action("NPR Sales Statistics")
                {
                    Caption = 'NPR Sales Statistics';
                    Image = Report2;
                    RunObject = Report "Sales Ticket Statistics";
                }
                action("NPR Salesperson Statistics")
                {
                    Caption = 'NPR Salesperson Statistics';
                    Image = Report2;
                    RunObject = Report "Salesperson Statistics";
                }
                action("NPR Sales Time")
                {
                    Caption = 'NPR  Sales Time';
                    Image = Report2;
                    RunObject = Report "Sale Time Report";
                }

                action("NPR Sales Statistics By Department")
                {
                    Caption = 'NPR Sales Statistics By Department';
                    Image = Report2;
                    RunObject = Report "Sales Statistics By Department";
                }
                action("POS Item Sales with Dimensions")
                {
                    Caption = 'POS Item Sales with Dimensions';
                    Image = Report2;
                    //RunObject = Report "pos item with dimension";
                }


            }



        }
    }

}


