page 6151246 "NPR Retail Store Man. RC"
{
    // NPR4.10/JDH/20150515 CASE 213618 Removed weather widget, since it created problems with ClickOnce deployments
    // NPR5.31/TS  /20170328  CASE 270740 My Reports added
    // NPR5.38/BR  /20180118  CASE 302790 Added POS Entry List

    Caption = 'NP Retail Store Manager Role Center';
    PageType = RoleCenter;


    layout
    {
        area(rolecenter)
        {

            part(headline; "Headline RC Order Processor")
            {

            }
            part(NPRetailVoucherCue; "NPR Voucher Cue")
            {

            }
            part(Retail10ItemsbyQty; "NPR Retail 10 Items by Qty.")
            {
            }
            part(RetailTop10Salesperson; "NPR Retail Top 10 S.person")
            {

            }
            part(RetailTop10Customers; "NPR Retail Top 10 Customers")
            {

            }
            part(RetailTop10Vendors; "NPR Top 10 Vendors")
            {

            }
            part(Control6014400; "NPR My Reports")
            {
            }
            systempart(Control6150613; MyNotes)
            {
            }
            //    }
        }
    }

    actions
    {

        area(sections)
        {
            group(Item)
            {


                action("Item List")
                {
                    Caption = 'Item List';
                    RunObject = Page "NPR Retail Item List";
                }
                action("Item Groups")
                {
                    Caption = 'Item Groups';
                    RunObject = Page "NPR Item Group Tree";
                }
            }
            group(Retail)
            {
                action("Retail Journal")
                {
                    Caption = 'Retail Journal';
                    RunObject = Page "NPR Retail Journal List";
                }
                action("Retail Documents")
                {
                    Caption = 'Retail Documents';
                    RunObject = Page "NPR Retail Document List";
                }
            }

            Group("List")
            {

                /* action("Audit Roll")
                 {
                     Caption = 'Audit Roll';
                     RunObject = Page "Audit Roll";
                 }
                 */
                action("POS Entry List")
                {
                    Caption = 'POS Entry List';
                    RunObject = Page "NPR POS Entry List";
                }


                action("Gift Vouchers")
                {
                    Caption = 'Gift Vouchers';
                    RunObject = Page "NPR Gift Voucher List";
                }
                action("Credit Vouchers")
                {
                    Caption = 'Credit Vouchers';
                    RunObject = Page "NPR Credit Voucher List";
                }
                action("Sales Ticket Statistics")
                {
                    Caption = 'Sales Ticket Statistics';
                    RunObject = Page "NPR Sales Ticket Statistics";
                }
                action("Contacts ")
                {
                    Caption = 'Contact List';
                    RunObject = Page "Contact List";
                }
                action(Customers)
                {
                    Caption = 'Customer List';
                    RunObject = Page "Customer List";
                }
                action(MixedDiscounts)
                {
                    Caption = 'Mixed Discounts';
                    RunObject = Page "NPR Mixed Discount List";
                }
                action(PeriodDiscounts)
                {
                    Caption = 'Period Discounts';
                    RunObject = Page "NPR Campaign Discount List";
                }
            }

        }
        area(reporting)
        {
            action("Sale Statistics")
            {
                Caption = 'Sale Statistics';
                Image = "Report";
                RunObject = Report "NPR Sales Ticket Stat.";
            }
            action("Discount Statistics")
            {
                Caption = 'Discount Statistics';
                Image = "Report";
                RunObject = Report "NPR Discount Statistics";
            }
            action("Customer Analysis")
            {
                Caption = 'Customer Analysis';
                Image = "Report";
                RunObject = Report "NPR Customer Analysis";
            }
            action("Gift Voucher/Credit Voucher")
            {
                Caption = 'Gift Voucher/Credit Voucher';
                Image = "Report";
                RunObject = Report "NPR Gift/Credit Voucher";
            }
            action("Sales Person Top 20")
            {
                Caption = 'Sales Person Top 20';
                Image = "Report";
                RunObject = Report "NPR Sales Person Top 20";
            }
            action("Sale Statistics per Vendor")
            {
                Caption = 'Sale Statistics per Vendor';
                Image = "Report";
                RunObject = Report "NPR Sale Statistics per Vendor";
            }
            action("Vendor/Salesperson")
            {
                Caption = 'Vendor/Salesperson';
                Image = "Report";
                RunObject = Report "NPR Vendor/Salesperson";
            }

            action("Item Group Overview")
            {
                Caption = 'Item Group Overview';
                Image = "Report";
                RunObject = Report "NPR Item Group Overview";
            }
        }
    }

}

