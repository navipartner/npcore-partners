page 6151241 "NPR Retail Manager Role Center"
{
    Extensible = False;
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
            part(PowerBI; "Power BI Report Spinner Part")
            {
                AccessByPermission = TableData "Power BI User Configuration" = I;
                ApplicationArea = NPRRetail;
            }
            part(MyJobQueue; "My Job Queue")
            {
                Caption = 'Job Queue';
                ApplicationArea = NPRRetail;
            }
            part("MyReports"; "NPR My Reports")
            {
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

                    ToolTip = 'Executes the S&tatement action.';
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

                    ToolTip = 'Executes the Customer - Order Su&mmary action.';
                    ApplicationArea = NPRRetail;
                }
                action("Customer - T&op 10 List")
                {
                    Caption = 'Customer - T&op 10 List';
                    Image = "Report";
                    RunObject = Report "Customer - Top 10 List";

                    ToolTip = 'Executes the Customer - T&op 10 List action.';
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

                    ToolTip = 'Executes the Inventory - Sales &Back Orders action.';
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

                    ToolTip = 'Executes the &G/L Trial Balance action.';
                    ApplicationArea = NPRRetail;
                }
                action("Trial Balance by &Period")
                {
                    Caption = 'Trial Balance by &Period';
                    Image = "Report";
                    RunObject = Report "Trial Balance by Period";

                    ToolTip = 'Executes the Trial Balance by &Period action.';
                    ApplicationArea = NPRRetail;
                }
                action("Closing T&rial Balance")
                {
                    Caption = 'Closing T&rial Balance';
                    Image = "Report";
                    RunObject = Report "Closing Trial Balance";

                    ToolTip = 'Executes the Closing T&rial Balance action.';
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

                    ToolTip = 'Executes the Aged Ac&counts Receivable action.';
                    ApplicationArea = NPRRetail;
                }
                action("Aged Accounts Pa&yable")
                {
                    Caption = 'Aged Accounts Pa&yable';
                    Image = "Report";
                    RunObject = Report "Aged Accounts Payable";

                    ToolTip = 'Executes the Aged Accounts Pa&yable action.';
                    ApplicationArea = NPRRetail;
                }
                action("Reconcile Cust. and &Vend. Accs")
                {
                    Caption = 'Reconcile Cust. and &Vend. Accs';
                    Image = "Report";
                    RunObject = Report "Reconcile Cust. and Vend. Accs";

                    ToolTip = 'Executes the Reconcile Cust. and &Vend. Accs action.';
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

                    ToolTip = 'Executes the VAT Registration No. Chec&k action.';
                    ApplicationArea = NPRRetail;
                }
                action("VAT E&xceptions")
                {
                    Caption = 'VAT E&xceptions';
                    Image = "Report";
                    RunObject = Report "VAT Exceptions";

                    ToolTip = 'Executes the VAT E&xceptions action.';
                    ApplicationArea = NPRRetail;
                }
                action("V&AT Statement")
                {
                    Caption = 'V&AT Statement';
                    Image = "Report";
                    RunObject = Report "VAT Statement";

                    ToolTip = 'Executes the V&AT Statement action.';
                    ApplicationArea = NPRRetail;
                }
                action("VAT-VIES Declaration Tax A&uth")
                {
                    Caption = 'VAT - VIES Declaration Tax A&uth';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Tax Auth";

                    ToolTip = 'Executes the VAT - VIES Declaration Tax A&uth action.';
                    ApplicationArea = NPRRetail;
                }
                action("VAT - VIES Declaration &Disk")
                {
                    Caption = 'VAT - VIES Declaration &Disk';
                    Image = "Report";
                    RunObject = Report "VAT- VIES Declaration Disk";

                    ToolTip = 'Executes the VAT - VIES Declaration &Disk action.';
                    ApplicationArea = NPRRetail;
                }
                action("EC Sal&es List")
                {
                    Caption = 'EC Sal&es List';
                    Image = "Report";
                    RunObject = Report "EC Sales List";

                    ToolTip = 'Executes the EC Sal&es List action.';
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

                            ToolTip = 'View the report which measures the salespeoples'' effectiveness.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Sales code/Item Category top")
                        {
                            Caption = 'Sales Code/Item Category Top';
                            Image = Report2;
                            RunObject = Report "NPR Salesp./Item Cat Top 20";

                            ToolTip = 'View the report which measures which salesperson was most successful with a certain category of items.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Sale Statistics per Vendor")
                        {
                            Caption = 'Sale Statistics Per Vendor';
                            Image = Report2;
                            RunObject = Report "NPR Sale Statistics per Vendor";

                            ToolTip = 'View the report which measures sales proceeds achieved per a vendor.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Sales Statistics By Department")
                        {
                            Caption = 'Sales Statistics By Department';
                            Image = Report2;
                            RunObject = Report "NPR Sales Statistics By Dept.";

                            ToolTip = 'View the report which measures sales proceeds achieved per a department.';
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

                                ToolTip = 'Generate the daily sales report per quantity.';
                                ApplicationArea = NPRRetail;
                            }
                            action("Advanced Sales Statistics")
                            {
                                Caption = 'Advanced Sales Statistics';
                                Image = ListPage;
                                RunObject = page "NPR Advanced Sales Stats";

                                ToolTip = 'Generate the daily sales report per quantity and amount';
                                ApplicationArea = NPRRetail;
                            }
                        }
                        group(HistoryReport)
                        {
                            Caption = 'Reports and Analysis';
                            Image = AnalysisView;
                            action("NPR Sales per Week Year/Last Year")
                            {
                                Caption = 'Sales per Week Year/Last Year';
                                Image = Report2;
                                RunObject = Report "NPR Sales per week year/Last";
                                ToolTip = 'View the report of sales for a specified month, along with the comparison with the last year''s report for the same month.';
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

                        action("NPR Inventory by Age")
                        {
                            Caption = 'Inventory by Age';
                            Image = Report;
                            RunObject = report "NPR Inventory by age";
                            ToolTip = 'Generate Inventory Ageing Report.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Inv. Sales Statistics")
                        {
                            Caption = 'Inv. Sales Statistics';
                            Image = Report;
                            RunObject = report "NPR Item Sales Stats/Provider";

                            ToolTip = 'Generate sales per item/item category.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Inventory per Date")
                        {
                            Caption = 'Inventory per Date';
                            Image = Report;
                            RunObject = report "NPR Inventory per Date";

                            ToolTip = 'View the report listing the inventory per date.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Item Group Inventory Value")
                        {
                            Caption = 'Item Category Inventory Value';
                            Image = Report;
                            RunObject = report "NPR Item Cat. Inv. Value";

                            ToolTip = 'View the report containing stock movement by item group.';
                            ApplicationArea = NPRRetail;
                        }

                        action("NPR Statistic - Sales")
                        {
                            Caption = 'Statistic - Sales';
                            Image = Report;
                            RunObject = report "NPR Item Sales Postings";

                            ToolTip = 'Generate statistic per item/item category.';
                            ApplicationArea = NPRRetail;
                        }

                        action("NPR Low Sales")
                        {
                            Caption = 'Low Sales';
                            Image = Report;
                            RunObject = report "NPR Items With Low Sales";

                            ToolTip = 'Generate Sales/Profit per item.';
                            ApplicationArea = NPRRetail;
                        }

                        action("NPR Shrinkage")
                        {
                            Caption = 'Shrinkage';
                            Image = Report;
                            RunObject = report "NPR Item - Loss";

                            ToolTip = 'View the summary of item quantity modified by negative adjustments and the Reason code.';
                            ApplicationArea = NPRRetail;
                        }

                        action("NPR Item Loss - Return Reason")
                        {
                            Caption = 'Item Loss - Return Reason';
                            Image = Report;
                            RunObject = report "NPR Item Loss - Ret. Reason";

                            ToolTip = 'Generate the list for Loss of item, with the Return Reason.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Sales Statistics Variant")
                        {
                            Caption = 'Sales Statistics Variant';
                            Image = Report;
                            RunObject = report "NPR Sales Stats Per Variety";

                            ToolTip = 'Generate the Sales/Profit report per Variant.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Inventory per Variant at Date")
                        {
                            Caption = 'Inventory per Variant at Date';
                            Image = Report;
                            RunObject = report "NPR Inventory per Variant/date";
                            ToolTip = 'Generate the Stock Inventory report per Variant.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Item Barcode Sheet")
                        {
                            Caption = 'Item Barcode Sheet';
                            Image = Report;
                            RunObject = report "NPR Item Barcode Status Sheet";

                            ToolTip = 'Generate Item Barcodes per Item/Variant.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Return Reason Code Statistics")
                        {
                            Caption = 'Return Reason Code Statistics';
                            Image = Report;
                            RunObject = report "NPR Return Reason Code Stat.";

                            ToolTip = 'View the summary of items with quantity and value modified by negative adjustments and the Reason code. The report is sorted according to the Reason code and Item Number.';
                            ApplicationArea = NPRRetail;
                        }

                        action("NPR Adjust Cost - Item Entries")
                        {
                            Caption = 'Adjust Cost - Item Entries';
                            Image = Report;
                            RunObject = report "NPR Adjust Cost: ItemEntriesTQ";

                            ToolTip = 'Generate the Adjust Cost - Item Entries.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Item Sales Statistics")
                        {
                            Caption = 'Item Sales Statistics';
                            Image = Report;
                            RunObject = report "NPR Item Sales Statistics";

                            ToolTip = 'Generate Inventory Movement per Document Type.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Item Group Top")
                        {
                            Caption = 'Item Category Top';
                            Image = Report;
                            RunObject = report "NPR Item Category Top";

                            ToolTip = 'Generate Top 20 Sales/Profit per Store & Item Category.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Lines)
                    {
                        Caption = 'Lines';
                        Image = AllLines;
                        action("NPR Vendor Sales per Line")
                        {
                            Caption = 'Vendor Sales per Line';
                            Image = Report;
                            RunObject = report "NPR Vendor Trn. by Item Cat.";
                            ToolTip = 'Generate the Turnover/Profit report per category & vendor.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Sales Person Trn. by Item Cat.")
                        {
                            Caption = 'Sales Person Trn. by Item Cat.';
                            Image = Report;
                            RunObject = Report "NPR S.Person Trn by Item Cat.";
                            ToolTip = 'Generate the Turnover/Profit report per category & salesperson.';
                            ApplicationArea = NPRRetail;
                        }
                        action("NPR Sales Stat/Analysis")
                        {
                            Caption = 'Sales Stat/Analysis';
                            Image = Report;
                            RunObject = Report "NPR Sales Stat/Analysis";

                            ToolTip = 'Generate the Turnover/Profit report per category.';
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

                            ToolTip = 'Generate the Turnover/Profit report per Period Discount.';
                            ApplicationArea = NPRRetail;
                        }

                        action("Inventory Campaign Stat.")
                        {
                            Caption = 'Inventory Campaign Stat.';
                            Image = Report;
                            RunObject = Report "NPR Inventory Campaign Stat.";

                            ToolTip = 'Generate the Turnover/Profit report per Mix Discount.';
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
                    ToolTip = 'View Member List.';
                    ApplicationArea = NPRRetail;
                }

                action(Membership)
                {

                    Caption = 'Memberships';
                    Image = Customer;
                    RunObject = page "NPR MM Memberships";
                    ToolTip = 'View Membership List.';
                    ApplicationArea = NPRRetail;

                }

                action(ShopperRecognition)
                {

                    Caption = 'EFT Shopper Recognition';
                    Image = Customer;
                    RunObject = page "NPR EFT Shopper Recognition";
                    ToolTip = 'View the shopper recognition details.';
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

                    ToolTip = 'Executes the Retail Item List action.';
                    ApplicationArea = NPRRetail;
                }
                action("Item Categories")
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

                action(ItemJournalList)
                {

                    Caption = 'Item Journal List';
                    RunObject = page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Item));
                    ToolTip = 'Executes the Item Journal List action.';
                    ApplicationArea = NPRRetail;
                }
                action("Physical Inventory Journals")
                {
                    Caption = 'Physical Inventory Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST("Phys. Inventory"),
                                         Recurring = CONST(false));

                    ToolTip = 'Executes the Physical Inventory Journals action.';
                    ApplicationArea = NPRRetail;
                }
                action(ItemWorksheets)
                {

                    Caption = 'Item Worksheets';
                    RunObject = page "NPR Item Worksheets";
                    ToolTip = 'Executes the Item Worksheets action.';
                    ApplicationArea = NPRRetail;
                }
                action("Retail Journal List")
                {
                    Caption = 'Retail Journal List';
                    RunObject = page "NPR Retail Journal List";

                    ToolTip = 'Executes the Retail Journal List action.';
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
                action("Global POS Sales Entries")
                {
                    Caption = 'Global POS Sales Entries';
                    Image = RegisteredDocs;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = page "NPR NpGp POS Sales Entries";
                    ToolTip = 'View Global POS Sales Entries.';
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

                    ToolTip = 'Executes the Campaign Discount List action.';
                    ApplicationArea = NPRRetail;
                }

                action("Mixed Discount List")
                {
                    Caption = 'Mixed Discount List';
                    RunObject = page "NPR Mixed Discount List";

                    ToolTip = 'Executes the Mixed Discount List action.';
                    ApplicationArea = NPRRetail;
                }
                action("Coupon List")
                {
                    Caption = 'Coupon List';
                    RunObject = page "NPR NpDc Coupons";

                    ToolTip = 'Executes the Coupon List action.';
                    ApplicationArea = NPRRetail;
                }
                action("Voucher List")
                {
                    Caption = 'Voucher List';
                    RunObject = page "NPR NpRv Vouchers";

                    ToolTip = 'Executes the Voucher List action.';
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

                ToolTip = 'Create Sales Order.';
                ApplicationArea = NPRRetail;
            }
            action("Sales &Return Order")
            {
                Caption = 'Sales &Return Order';
                Image = ReturnOrder;
                RunObject = Page "Sales Return Order";
                RunPageMode = Create;

                ToolTip = 'Create Sales Return Order.';
                ApplicationArea = NPRRetail;
            }
            action("&Transfer Order")
            {
                Caption = '&Transfer Order';
                Image = TransferOrder;
                RunObject = Page "Transfer Order";
                RunPageMode = Create;

                ToolTip = 'Create Transfer Order.';
                ApplicationArea = NPRRetail;
            }
            action("&Purchase Order")
            {
                Caption = '&Purchase Order';
                Image = Document;
                Promoted = false;
                RunObject = Page "Purchase Order";
                RunPageMode = Create;

                ToolTip = 'Create Purchase Order.';
                ApplicationArea = NPRRetail;
            }
            action("Purchase Return Order")
            {
                Caption = 'Purchase Return Order';
                Image = Document;
                RunObject = Page "Purchase Return Order";

                ToolTip = 'Executes the Purchase Return Order action.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}
