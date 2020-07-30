page 6151334 "NP Retail Resturant RC"
{
    // TM1.16/TSA/20160816  CASE 233430 Transport TM1.16 - 19 July 2016
    // NPR5.29/TSA /20161121  CASE 258974 Page Navigation enhancements - Switched to Retail Item List
    // NPR5.29/TS  /20170127  CASE 264733 Added My reports
    // MM1.26/TSA /20180222 CASE 304705 Added button for setup actions in ticket and member module
    // MM1.29/TSA /20180509 CASE 313795 Added GDPR actions
    // TM1.39/TS  /20181206 CASE 343939 Added Missing Picture to Action

    Caption = 'Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {


            part(Control7; "Headline RC Order Processor")
            {
                ApplicationArea = Basic, Suite;
            }
            part("NP Retail Resturant Cue"; "NP Retail Resturant Cue")
            {

            }

            part(Control6150614; "Retail 10 Items by Qty.")
            {



            }

            /* part(Control6150615; "Retail Top 10 Customers")
             {

             }
             */

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




        }
    }

    actions
    {

        area(reporting)
        {
            group(ActionGroup6014406)
            {
                Visible = false;
                action("POS Item Sales")
                {
                    Caption = 'POS Item Sales';
                    Image = "Report";
                    //RunObject = Repo;
                }
                separator(Separator6150667)
                {
                }
                action("Rest. Daily Turnover")
                {
                    Caption = 'Rest. Daily Turnover';
                    Image = "Report";
                    //RunObject = Report "Customer - Order Summary";
                }
                /*
                 action("Customer - T&op 10 List")
                 {
                     Caption = 'Customer - T&op 10 List';
                     Image = "Report";
                     RunObject = Report "Customer - Top 10 List";
                 }
                 */

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
                    //ToolTip = 'View or edit detailed information for the customers that you trade with. From each customer card, you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
                }

                action("Waiter Pad List")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Waiter pad List';
                    Image = Customer;
                    //RunObject = Page "NPRE Waiter Pad List";
                    //ToolTip = 'View or edit detailed information for the customers that you trade with. From each contact card, you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
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
            }
            group(ActionGroup6014513)
            {
                Caption = 'Resturant';
                Image = ProductDesign;
                action(Action6014418)
                {
                    Caption = 'Print Category';
                    RunObject = Page "NPRE Print Categories";
                }
                action("Seating list")
                {
                    Caption = 'Seating list';
                    RunObject = Page "NPRE Seating List";
                }
                action("Restaurant Setup")
                {
                    Caption = 'Restaurant Setup';
                    RunObject = Page "NPRE Restaurant Setup";
                }


            }




            group("Retail Documents")
            {
                Caption = 'Documents';
                Image = RegisteredDocs;
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

                action("Coupon Types")
                {
                    Caption = 'Coupon Types';
                    RunObject = page "NpDc Coupon Types";

                }

                action("Coupon List")
                {
                    Caption = 'Coupon List';
                    RunObject = page "NpDc Coupons";
                }
                action("Voucher Types")
                {
                    Caption = 'Voucher Types';
                    RunObject = page "NpRv Voucher Types";
                }
                action("Voucher List")
                {
                    Caption = 'Voucher List';
                    RunObject = page "NpRv Vouchers";
                }
            }



        }


    }




}

