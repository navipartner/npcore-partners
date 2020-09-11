page 6151240 "NPR Retail: Manager RoleCenter"
{
    // NC1.17/MH/20150423       CASE 212263 Created NaviConnect Role Center
    // NC1.17/BHR/20150428      CASE 212069 Removed "retail Document Activities
    // NC1.20/BHR/20150925      CASE 223709 Added part 'NaviConnect Top 10 SalesPerson'
    // NPR5.23/TS/20160509      CASE 240912 Removed Naviconnect Activities
    // NPR5.23.03/MHA/20160726  CASE 242557 Magento references updated according to MAG2.00
    // NPR5.31/TS  /20170328  CASE 270740 My Reports added
    // NPR5.32/MHA /20170515  CASE 276241 Charts group moved into first column to reduce total column qty. from 3 to 2
    // NPR5.38/BR  /20180118  CASE 302790 Added POS Entry List

    Caption = 'NP Retail - Manager Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {

            part(Control7; "Headline RC Order Processor")
            {
                ApplicationArea = All;
                // ApplicationArea = Basic, Suite;
            }

            /*
            group(Cue)
            {
                */
            part(Control6150616; "NPR Activities")
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
            part(Control1904484608; "NPR Retail Admin Act - POS")
            {
                ApplicationArea = All;

            }
            part(Control66; "NPR Retail Sales Chart")
            {
                ApplicationArea = Basic, Suite;
            }

            part(Control70; "Sales Performance")
            {
                ApplicationArea = Basic, Suite;
            }





            part(Control2; "NPR Purchase Ord Chart")
            {
                ApplicationArea = Basic, Suite;
            }


            part(Control6150614; "NPR Retail 10 Items by Qty.")
            {
                ApplicationArea = All;
            }


            part(Control6150613; "NPR Retail Top 10 S.person")
            {
                ApplicationArea = All;

            }

            part(Control6150615; "NPR Retail Top 10 Customers")
            {
                ApplicationArea = All;

            }
            part(Top10vendors; "NPR Top 10 Vendors")
            {
                ApplicationArea = All;

            }
            part("MyReports"; "NPR My Reports")
            {
                ApplicationArea = All;
            }


        }
    }

    actions
    {
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
                action("POS Entry List")
                {
                    ApplicationArea = Basic, Suite;
                    Image = List;
                    RunObject = Page "NPR POS Entry List";
                    RunPageView = SORTING("Entry No.") ORDER(Descending);

                }
                action("Retail Item List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Retail Item List';
                    Image = Item;
                    RunObject = Page "NPR Retail Item List";
                    ToolTip = 'View or edit detailed information for the products that you trade in. The item card can be of type Inventory or Service to specify if the item is a physical unit or a labor time unit. Here you also define if items in inventory or on incoming orders are automatically reserved for outbound documents and whether order tracking links are created between demand and supply to reflect planning actions.';
                }

                action("Item Group Tree")
                {
                    ApplicationArea = Suite;
                    Caption = 'Item Group Tree';
                    RunObject = page "NPR Item Group Tree";

                }

                action("Stockkeeping Unit List")
                {
                    ApplicationArea = Suite;
                    Caption = 'Stockkeeping Unit List';
                    RunObject = page "Stockkeeping Unit List";
                }
                action("Salespeople/Purchasers")
                {
                    ApplicationArea = Suite;
                    Caption = 'Salespeople/Purchasers';
                    RunObject = Page "Salespersons/Purchasers";
                    ToolTip = 'View a list of your sales people and your purchasers.';
                }
            }


            group(Item)
            {
                Caption = 'Item & Prices';
                Image = ProductDesign;
                action(RetailItemList)
                {
                    Caption = 'Retail Item List';
                    RunObject = Page "NPR Retail Item List";
                    ApplicationArea = All;
                }

                action(ItemGroupTree)
                {
                    Caption = 'Item Group Tree';
                    RunObject = page "NPR Item Group Tree";
                    ApplicationArea = All;

                }
                action("Sales Price Maintenance Setup")
                {
                    Caption = 'Sales Price Maintenance Setup';
                    RunObject = Page "NPR Sales Price Maint. Setup";
                    ApplicationArea = All;
                }
                action("RIS Retail Inventory Sets")
                {
                    Caption = 'RIS Retail Inventory Sets';
                    RunObject = Page "NPR RIS Retail Inv. Sets";
                    ApplicationArea = All;
                }
                action("Item Category Mapping")
                {
                    Caption = 'Item Category Mapping';
                    RunObject = Page "NPR Item Category Mapping";
                    ApplicationArea = All;
                }
                action("Store Groups")
                {
                    Caption = 'Store Groups';
                    RunObject = Page "NPR Store Groups";
                    ApplicationArea = All;
                }
                action("Variety Fields Setup")
                {
                    Caption = 'Variety Fields Setup';
                    RunObject = Page "NPR Variety Fields Setup";
                    ApplicationArea = All;
                }
                action("Variety Setup")
                {
                    Caption = 'Variety Setup';
                    RunObject = page "NPR Variety";
                    ApplicationArea = All;
                }
                action("Item Groups")
                {
                    Caption = 'Item Groups';
                    RunObject = page "NPR Item Group List";
                    ApplicationArea = All;
                }
                action(Locations)
                {
                    Caption = 'Locations';
                    RunObject = page "Location List";
                    ApplicationArea = All;
                }

                /*
                action("Mix Discounts")
                {
                    Caption = 'Mix Discounts List';
                    RunObject = page "Mixed Discount List";
                }

                action("Period Discounts")
                {
                    Caption = 'Period Discounts List';
                    RunObject = page "Campaign Discount List";
                }

                action("Retail Campaigns")
                {
                    Caption = 'Retail Campaigns List';
                    RunObject = page "Retail Campaigns";
                }

                action("Discount Priority List")
                {
                    Caption = 'Discount Priority List';
                    RunObject = page "Discount Priority List";
                }
                */

            }

            group(POS)
            {
                Caption = 'POS';
                Image = Reconcile;

                action("Cash Registers")
                {
                    Caption = 'Cash Registers';
                    RunObject = Page "NPR Register List";
                    ApplicationArea = All;
                }

                action("Payment Type")
                {
                    Caption = 'Payment Type';
                    RunObject = page "NPR Payment Type - List";
                    ApplicationArea = All;
                }
                action("POS Menus")
                {
                    Caption = 'POS Menus';
                    Image = PaymentJournal;
                    RunObject = Page "NPR POS Menus";
                    ApplicationArea = All;
                }
                /*
                 action("Default Views")
                 {
                     Caption = 'Default Views';
                     Image = View;
                     RunObject = Page "POS Default Views";
                 }
                 action("POS Actions")
                 {
                     Caption = 'POS Actions';
                     Image = "Action";
                     RunObject = Page "POS Actions";
                 }
                 action("View List")
                 {
                     Caption = 'View List';
                     Image = ViewDocumentLine;
                     RunObject = Page "POS View List";
                 }
                 */
                action("POS Sales Workflows")
                {
                    Caption = 'POS Sales Workflows';
                    Image = Allocate;
                    RunObject = Page "NPR POS Sales Workflows";
                    ApplicationArea = All;
                }
                action("POS Store List")
                {
                    Caption = 'POS Store List';
                    RunObject = Page "NPR POS Store List";
                    ApplicationArea = All;
                }
                action("POS Unit List")
                {
                    Caption = 'POS Unit List';
                    RunObject = Page "NPR POS Unit List";
                    ApplicationArea = All;
                }
                action("POS Posting Setup")
                {
                    Caption = 'POS Posting Setup';
                    RunObject = Page "NPR POS Posting Setup";
                    ApplicationArea = All;
                }
                action("POS Payment Method List")
                {
                    Caption = 'POS Payment Method List';
                    RunObject = Page "NPR POS Payment Method List";
                    ApplicationArea = All;
                }
                action("POS Payment Bins")
                {
                    Caption = 'POS Payment Bins';
                    RunObject = Page "NPR POS Payment Bins";
                    ApplicationArea = All;
                }
                /*
                  action("POS Themes")
                  {
                      Caption = 'POS Themes';
                      RunObject = Page "POS Themes";
                  }
              */
                action("POS Info List")
                {
                    Caption = 'POS Info List';
                    RunObject = Page "NPR POS Info List";
                    ApplicationArea = All;
                }
                action("POS Customer Location")
                {
                    Caption = 'POS Customer Location';
                    RunObject = Page "NPR POS Customer Loc.";
                    ApplicationArea = All;
                }
                /*
                 action("POS Admin. Template List")
                 {
                     Caption = 'POS Admin. Template List';
                     // RunObject = Page "POS Admin. Template List";
                 }
                */

                action("Display Setup")
                {
                    Caption = 'Display Setup';
                    RunObject = Page "NPR Display Setup";
                    ApplicationArea = All;
                }
                action(Action6014418)
                {
                    Caption = 'POS Sales Workflows';
                    RunObject = Page "NPR POS Sales Workflows";
                    ApplicationArea = All;
                }
                action("POS Sales Workflow Sets")
                {
                    Caption = 'POS Sales Workflow Sets';
                    RunObject = Page "NPR POS Sales Workflow Sets";
                    ApplicationArea = All;
                }
                action("No. Series")
                {
                    Caption = 'No. Series';
                    RunObject = Page "No. Series";
                    ApplicationArea = All;
                }
                action("Ean Box Events")
                {
                    Caption = 'Ean Box Events';
                    Image = List;
                    RunObject = Page "NPR Ean Box Events";
                    ApplicationArea = All;
                }
                action("Ean Box Setups")
                {
                    Caption = 'Ean Box Setups';
                    Image = List;
                    RunObject = Page "NPR Ean Box Setups";
                    ApplicationArea = All;
                }
                action("POS Unit Identity")
                {
                    Caption = 'POS Unit Identity';
                    Image = List;
                    ApplicationArea = All;
                    // RunObject = page "POS Unit Identity List";

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
                action("Item Journals")
                {
                    Caption = 'Item Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = WHERE("Template Type" = CONST(Item),
                                         Recurring = CONST(false));
                    ApplicationArea = All;
                }

                action("Item Worksheet")
                {
                    Caption = 'Item Worksheet';
                    RunObject = page "NPR Item Worksheet Templates";
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

                action("Discount Priority List")
                {
                    Caption = 'Discount Priority List';
                    RunObject = page "NPR Discount Priority List";
                    ApplicationArea = All;
                }


                action("Coupon Types")
                {
                    Caption = 'Coupon Types';
                    RunObject = page "NPR NpDc Coupon Types";
                    ApplicationArea = All;

                }

                action("Coupon List")
                {
                    Caption = 'Coupon List';
                    RunObject = page "NPR NpDc Coupons";
                    ApplicationArea = All;
                }
                action("Voucher Types")
                {
                    Caption = 'Voucher Types';
                    RunObject = page "NPR NpRv Voucher Types";
                    ApplicationArea = All;
                }
                action("Voucher List")
                {
                    Caption = 'Voucher List';
                    RunObject = page "NPR NpRv Vouchers";
                    ApplicationArea = All;
                }
            }

            group("Global Setup")
            {
                Caption = 'Global Setup';
                action("Global POS Sales Setups")
                {
                    Caption = 'Global POS Sales Setups';
                    RunObject = Page "NPR NpGp Global POSSalesSetups";
                    ApplicationArea = All;
                }
                action("Cross Companies Setup")
                {
                    Caption = 'Cross Companies Setup';
                    ApplicationArea = All;
                    // RunObject = Page "NpGp Cross Companies Setup";

                }
            }
            group("Collect in Store")
            {
                Caption = 'Collect in Store';
                action("Collect Stores")
                {
                    Caption = 'Collect Stores';
                    RunObject = Page "NPR NpCs Stores";
                    ApplicationArea = All;
                }
                action("Collect Workflows")
                {
                    Caption = 'Collect Workflows';
                    RunObject = Page "NPR NpCs Workflows";
                    ApplicationArea = All;
                }
                action("Store Opening Hours Setup")
                {
                    Caption = 'Store Opening Hours Setup';
                    ApplicationArea = All;
                    //  RunObject = Page "NpCs Store Opening Hours Setup";
                }
                action("Collect Workflow Modules")
                {
                    Caption = 'Collect Workflow Modules';
                    RunObject = Page "NPR NpCs Workflow Modules";
                    ApplicationArea = All;
                }
                action("Collect Document Mapping")
                {
                    Caption = 'Collect Document Mapping';
                    RunObject = Page "NPR NpCs Document Mapping";
                    ApplicationArea = All;
                }
            }
            group("Print & Email")
            {
                Caption = 'Print & Email';
                action("Printer Selections")
                {
                    Caption = 'Printer Selections';
                    RunObject = Page "Printer Selections";
                    ApplicationArea = All;
                }
                action("Retail Print Template List")
                {
                    Caption = 'Retail Print Template List';
                    RunObject = Page "NPR RP Template List";
                    ApplicationArea = All;
                }
                action("Object Output Selection")
                {
                    Caption = 'Object Output Selection';
                    RunObject = Page "NPR Object Output Selection";
                    ApplicationArea = All;
                }
                action("Retail Logo Setup")
                {
                    Caption = 'Retail Logo Setup';
                    RunObject = Page "NPR Retail Logo Setup";
                    ApplicationArea = All;
                }
                action("Google Cloud Print Setup")
                {
                    Caption = 'Google Cloud Print Setup';
                    RunObject = Page "NPR GCP Setup";
                    ApplicationArea = All;
                }
                action("E-mail Templates")
                {
                    Caption = 'E-mail Templates';
                    RunObject = Page "NPR E-mail Templates";
                    ApplicationArea = All;
                }

                action("Report Selection - Retail")
                {
                    Caption = 'Report Selection - Retail';
                    ApplicationArea = All;
                    //RunObject = page "Report Selection - Retail";
                }

                action("SMS Template List")
                {
                    Caption = 'SMS Template List';
                    RunObject = page "NPR SMS Template List";
                    ApplicationArea = All;

                }
                action("Report Selection - Contract")
                {
                    Caption = 'Report Selection - Contract';
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
            group(RetailSetup)
            {
                Caption = 'Retail Setup';
                action("NP Retail Setup")
                {
                    Caption = 'NP Retail Setup';
                    RunObject = Page "NPR NP Retail Setup";
                    ApplicationArea = All;
                }
                action("Retail Setup")
                {
                    Caption = 'Retail Setup';
                    RunObject = page "NPR Retail Setup";
                    ApplicationArea = All;
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

