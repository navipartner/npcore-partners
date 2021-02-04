page 6151241 "NPR Retail POS- Sales Person R"
{
    Caption = 'NP Retail Salesperson';
    PageType = RoleCenter;
    UsageCategory = None;
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
                    Caption = 'VAT - VIES Declaration Tax A&uth';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Tax Auth";
                    ApplicationArea = All;
                    ToolTip = 'Executes the VAT - VIES Declaration Tax A&uth action';
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
            group(Reports)
            {
                Caption = 'List & Reports';
                group(ActionGroup6014408)
                {
                    Caption = 'Retail';
                    Image = Report; 
                    group(Management)
                    {
                        Caption = 'Management';
                        group(Salespersons)

                        {
                            Caption = 'Salespersons';
                            Image = SalesPerson; 
                            action("NPR Sales Person Top 20")
                            {
                                Caption = 'NPR Sales Person Top 20';
                                Image = Report2;
                                RunObject = Report "NPR Sales Person Top 20";
                                ApplicationArea = All;
                                ToolTip = 'Executes the NPR Sales Person Top 20 action';
                            }
                            action("NPR Sales code/Item group top")
                            {
                                Caption = 'NPR  Sales code/Item group top';
                                Image = Report2;
                                RunObject = Report "NPR Salesperson/Item Group Top";
                                ApplicationArea = All;
                                ToolTip = 'Executes the NPR  Sales code/Item group top action';
                            }
                            action("NPR Sale Statistics per Vendor")
                            {
                                Caption = 'NPR Sale Statistics per Vendor';
                                Image = Report2;
                                RunObject = Report "NPR Sale Statistics per Vendor";
                                ApplicationArea = All;
                                ToolTip = 'Executes the NPR Sale Statistics per Vendor action';
                            }
                        }
                        group(Webshop)
                        {
                            Caption = 'Webshop';
                            Image = Web;
                            action("NPR List of Sales Invoices")
                            {
                                Caption = 'NPR List of Sales Invoices';
                                Image = Report2;
                                RunObject = Report "NPR List of Sales Invoices";
                                ApplicationArea = All;
                                ToolTip = 'Executes the NPR List of Sales Invoices action';
                            }
                            action("NPR Item Wise Sales Figures")
                            {
                                Caption = 'NPR Item Wise Sales Figures';
                                Image = Report2;
                                RunObject = Report "NPR Item Wise Sales Figures";
                                ApplicationArea = All;
                                ToolTip = 'Executes the NPR Item Wise Sales Figures action';
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
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Sales Ticket Statistics action';
                                }
                                action("Advanced Sales Statistics")
                                {
                                    Caption = 'Advanced Sales Statistics';
                                    Image = ListPage;
                                    RunObject = page "NPR Advanced Sales Stats";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Advanced Sales Statistics action';
                                }
                                action(Periods)
                                {
                                    Caption = 'Periods';
                                    Image = ListPage;
                                    RunObject = page "NPR Periods";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Periods action';
                                }
                            }
                            group(HistoryReport)
                            {
                                Caption = 'Reports and Analysis';
                                Image = AnalysisView; 
                                action("NPR Sales per week year/Last year")
                                {
                                    Caption = 'NPR Sales per week year/Last year';
                                    Image = Report2;
                                    RunObject = Report "NPR Sales per week year/Last";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Sales per week year/Last year action';
                                }
                                action("NPR Discount Statistics")
                                {
                                    Caption = 'NPR Discount Statistics';
                                    Image = Report2;
                                    RunObject = Report "NPR Discount Statistics";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Discount Statistics action';
                                }
                                action("NPR Sales Ticket Statistics/Date")
                                {
                                    Caption = 'NPR Sales Ticket Statistics/Date';
                                    Image = Report2;
                                    RunObject = Report "NPR Sales Ticket Stats/Date";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Sales Ticket Statistics/Date action';
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

                            group(Lists)
                            {
                                Caption = 'Lists';
                                Image = List; 
                                action("Retail Item List")
                                {
                                    Caption = 'Retail Item';
                                    Image = ListPage;
                                    RunObject = page "Item List";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Retail Item action';
                                }
                                action(Items)
                                {
                                    Caption = 'Items';
                                    Image = ListPage;
                                    RunObject = page "Item List";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Items action';
                                }
                                action("Item AddOns")
                                {
                                    Caption = 'Item AddOns';
                                    Image = ListPage;
                                    RunObject = page "NPR NpIa Item AddOns";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Item AddOns action';
                                }
                            }
                            group(ReportsGoods)
                            {
                                Caption = 'Reports and Analysis';
                                Image = AnalysisView; 
                                action("NPR Inventory by age")
                                {
                                    Caption = 'NPR Inventory by age';
                                    Image = Report;
                                    RunObject = report "NPR Inventory by age";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Inventory by age action';
                                }
                                action("NPR Inv. Sales Statistics")
                                {
                                    Caption = 'NPR Inv. Sales Statistics';
                                    Image = Report;
                                    RunObject = report "NPR Item Sales Stats/Provider";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Inv. Sales Statistics action';
                                }
                                action("NPR Inventory per Date")
                                {
                                    Caption = 'NPR Inventory per Date';
                                    Image = Report;
                                    RunObject = report "NPR Inventory per Date";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Inventory per Date action';
                                }
                                action("NPR Item Group Inventory Value")
                                {
                                    Caption = 'NPR Item Group Inventory Value';
                                    Image = Report;
                                    RunObject = report "NPR Item Group Inv. Value";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Item Group Inventory Value action';
                                }

                                action("NPR Statistic - Sales")
                                {
                                    Caption = 'NPR Statistic - Sales';
                                    Image = Report;
                                    RunObject = report "NPR Item Sales Postings";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Statistic - Sales action';
                                }

                                action("NPR Low Sales")
                                {
                                    Caption = 'NPR Low Sales';
                                    Image = Report;
                                    RunObject = report "NPR Items With Low Sales";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Low Sales action';
                                }

                                action("NPR Shrinkage")
                                {
                                    Caption = 'NPR Shrinkage';
                                    Image = Report;
                                    RunObject = report "NPR Item - Loss";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Shrinkage action';
                                }

                                action("NPR Item Loss - Return Reason")
                                {
                                    Caption = 'NPR Item Loss - Return Reason';
                                    Image = Report;
                                    RunObject = report "NPR Item Loss - Ret. Reason";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Item Loss - Return Reason action';
                                }
                                action("NPR Sales Statistics Variant")
                                {
                                    Caption = 'NPR Sales Statistics Variant';
                                    Image = Report;
                                    RunObject = report "NPR Sales Stats Per Variety";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Sales Statistics Variant action';
                                }
                                action("NPR Inventory per Variant at date")
                                {
                                    Caption = 'NPR Inventory per Variant at date';
                                    Image = Report;
                                    RunObject = report "NPR Inventory per Variant/date";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Inventory per Variant at date action';
                                }
                                action("NPR Item Group Statistic M/Y")
                                {
                                    Caption = 'NPR Item Group Statistic M/Y';
                                    Image = Report;
                                    RunObject = report "NPR Item Group Stat M/Y";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Item Group Statistic M/Y action';
                                }

                                action("NPR Item Group Listing M/Y")
                                {
                                    Caption = 'NPR Item Group Listing M/Y';
                                    Image = Report;
                                    RunObject = report "NPR Item Group Listing M/Y";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Item Group Listing M/Y action';
                                }

                                action("NPR Item Barcode Sheet")
                                {
                                    Caption = 'NPR Item Barcode Sheet';
                                    Image = Report;
                                    RunObject = report "NPR Item Barcode Status Sheet";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Item Barcode Sheet action';
                                }
                                action("NPR Return Reason Code Statistics")
                                {
                                    Caption = 'NPR Return Reason Code Statistics';
                                    Image = Report;
                                    RunObject = report "NPR Return Reason Code Stat.";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Return Reason Code Statistics action';
                                }

                                action("NPR Adjust Cost - Item Entries")
                                {
                                    Caption = 'NPR Adjust Cost - Item Entries';
                                    Image = Report;
                                    RunObject = report "NPR Adjust Cost: ItemEntriesTQ";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Adjust Cost - Item Entries action';
                                }

                                action("NPR Item Sales Statistics")
                                {
                                    Caption = 'NPR Item Sales Statistics';
                                    Image = Report;
                                    RunObject = report "NPR Item Sales Statistics";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Item Sales Statistics action';
                                }
                                action("NPR Item Group Top")
                                {
                                    Caption = 'NPR Item Group Top';
                                    Image = Report;
                                    RunObject = report "NPR Item Group Top";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Item Group Top action';
                                }
                            }
                        }
                        group(Lines)
                        {
                            Caption = 'Lines';
                            Image = AllLines; 

                            group(ListsLine)
                            {

                                Caption = 'Lists';
                                Image = List; 
                                action("Item Groups")
                                {
                                    Caption = 'Item AddOns';
                                    Image = ListPage;
                                    RunObject = page "NPR NpIa Item AddOns";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Item AddOns action';
                                }
                                action("Sales Price Maintenance Setup")
                                {
                                    Caption = 'Sales Price Maintenance Setup';
                                    Image = ListPage;
                                    RunObject = page "NPR Sales Price Maint. Setup";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Sales Price Maintenance Setup action';
                                }
                                action("Retail Price Log Entries")
                                {
                                    Caption = 'Retail Price Log Entries';
                                    Image = ListPage;
                                    RunObject = page "NPR Retail Price Log Entries";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Retail Price Log Entries action';
                                }
                            }
                            group(LineReports)
                            {

                                Caption = 'Reports and Analysis';
                                Image = AnalysisView; 
                                action("NPR Item Group Overview")
                                {
                                    Caption = 'NPR Item Group Overview';
                                    Image = Report;
                                    RunObject = Report "NPR Item Group Overview";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Item Group Overview action';
                                }
                                action("NPR Vendor sales per line")
                                {
                                    Caption = 'NPR Vendor sales per line';
                                    Image = Report;
                                    RunObject = report "NPR Vendor trx by Item group";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Vendor sales per line action';
                                }
                                action("NPR Sales Person Trn. by Item Gr.")
                                {
                                    Caption = 'NPR Sales Person Trn. by Item Gr.';
                                    Image = Report;
                                    RunObject = Report "NPR S.Person Trx by Item Gr.";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Sales Person Trn. by Item Gr. action';
                                }
                                action("NPR Sales Stat/Analysis")
                                {
                                    Caption = 'NPR Sales Stat/Analysis';
                                    Image = Report;
                                    RunObject = Report "NPR Sales Stat/Analysis";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Sales Stat/Analysis action';
                                }
                            }
                        }
                        group(Discount)
                        {
                            Caption = 'Discount';
                            Image = Discount; 
                            group(DiscountList)
                            {
                                Caption = 'Lists';
                                Image = List; 
                                action("Item Groups Tree")
                                {
                                    Caption = 'Mix Discounts';
                                    Image = ListPage;
                                    RunObject = page "NPR Mixed Discount List";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Mix Discounts action';
                                }
                                action("Period Discounts")
                                {
                                    Caption = 'Period Discounts';
                                    Image = ListPage;
                                    RunObject = page "NPR Campaign Discount List";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Period Discounts action';
                                }
                                action("Retail Campaigns")
                                {
                                    Caption = 'Retail Campaigns';
                                    Image = ListPage;
                                    RunObject = page "NPR Retail Campaigns";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Retail Campaigns action';
                                }
                            }
                            group(DiscountReports)
                            {

                                Caption = 'Reports and Analysis';
                                Image = AnalysisView; 
                                action("NPR Period Discount Statistics")
                                {
                                    Caption = 'NPR Period Discount Statistics';
                                    Image = Report;
                                    RunObject = report "NPR Period Discount Stat.";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the NPR Period Discount Statistics action';
                                }

                                action("Inventory Campaign Stat.")
                                {
                                    Caption = 'Inventory Campaign Stat.';
                                    Image = Report;
                                    RunObject = Report "NPR Inventory Campaign Stat.";
                                    ApplicationArea = All;
                                    ToolTip = 'Executes the Inventory Campaign Stat. action';
                                }
                            }
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
                    ToolTip = 'Executes the Retail Item List action';
                }
                action("Item Group Tree")
                {
                    Caption = 'Item Group Tree';
                    RunObject = Page "NPR Item Group Tree";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Group Tree action';
                }
                action("Stockkeeping Unit List")
                {
                    Caption = 'Stockkeeping Unit List';
                    RunObject = Page "Stockkeeping Unit List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Stockkeeping Unit List action';
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
                    ToolTip = 'Executes the Item Journal List action';
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
                action("Retail Journal List")
                {
                    Caption = 'Retail Journal List';
                    RunObject = page "NPR Retail Journal List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Journal List action';
                }
                action(ItemWorksheets)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Item Worksheets';
                    RunObject = page "NPR Item Worksheets";
                    ToolTip = 'Executes the Item Worksheets action';
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
                    ApplicationArea = All;
                }

                action(POSQuotes)
                {
                    Caption = 'POS Quotes';
                    Image = RegisteredDocs;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = page "NPR POS Quotes";
                    ToolTip = 'View POS Quotes that have been done.';
                    ApplicationArea = All;

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
                    ApplicationArea = All;
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
                    ApplicationArea = All;
                }
                action("Repair Document List")
                {
                    Caption = 'Repair Document List';
                    Image = RegisteredDocs;
                    Promoted = true;
				    PromotedOnly = true;
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
                    ToolTip = 'Executes the Campaign Discount List action';
                }

                action("Mixed Discount List")
                {
                    Caption = 'Mixed Discount List';
                    RunObject = page "NPR Mixed Discount List";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Mixed Discount List action';
                }
                action("Coupon List")
                {
                    Caption = 'Coupon List';
                    RunObject = page "NPR NpDc Coupons";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Coupon List action';
                }
                action("Voucher List")
                {
                    Caption = 'Voucher List';
                    RunObject = page "NPR NpRv Vouchers";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Voucher List action';
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
                RunObject = Page "Sales Credit Memo";
                RunPageMode = Create;
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Credit &Memo action';
            }
            action("&Transfer Order")
            {
                Caption = '&Transfer Order';
                Image = TransferOrder;
                RunObject = Page "Transfer Order";
                RunPageMode = Create;
                ApplicationArea = All;
                ToolTip = 'Executes the &Transfer Order action';
            }
            action("&Purchase Order")
            {
                Caption = '&Purchase Order';
                Image = Document;
                Promoted = false;
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
        area(Processing){
            
            group(Vendor)
            {
                Caption = 'Vendor';
                action("NPR Vendor Top/Sale")
                {
                    Caption = 'NPR Vendor Top/Sale';
                    Image = Report2;
                    RunObject = Report "NPR Vendor Top/Sale";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NPR Vendor Top/Sale action';
                }
                action("NPR Vendor/Item Group")
                {
                    Caption = 'NPR Vendor/Item Group';
                    Image = Report2;
                    RunObject = Report "NPR Vendor/Item Group";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NPR Vendor/Item Group action';
                }
                action("NPR Vendor/Salesperson")
                {
                    Caption = 'NPR Vendor/Salesperson';
                    Image = Report2;
                    RunObject = Report "NPR Vendor/Salesperson";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NPR Vendor/Salesperson action';
                }

                action("NPR Vendor Sales Stat")
                {
                    Caption = 'NPR Vendor Sales Stat';
                    Image = Report2;
                    RunObject = Report "NPR Vendor Sales Stat";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NPR Vendor Sales Stat action';
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
                    ToolTip = 'Executes the NPR Sales Statistics action';
                }
                action("NPR Salesperson Statistics")
                {
                    Caption = 'NPR Salesperson Statistics';
                    Image = Report2;
                    RunObject = Report "NPR Salesperson Stats";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NPR Salesperson Statistics action';
                }
                action("NPR Sales Time")
                {
                    Caption = 'NPR  Sales Time';
                    Image = Report2;
                    RunObject = Report "NPR Sale Time Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NPR  Sales Time action';
                }
                action("NPR Sales Statistics By Department")
                {
                    Caption = 'NPR Sales Statistics By Department';
                    Image = Report2;
                    RunObject = Report "NPR Sales Statistics By Dept.";
                    ApplicationArea = All;
                    ToolTip = 'Executes the NPR Sales Statistics By Department action';
                }
            }
        }
    }
}
