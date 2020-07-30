page 6151246 "NP Retail Store Manager RC"
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
            part(NPRetailVoucherCue; "NP Retail Voucher Cue")
            {

            }
            part(Retail10ItemsbyQty; "Retail 10 Items by Qty.")
            {
            }
            part(RetailTop10Salesperson; "Retail Top 10 Salesperson")
            {

            }
            part(RetailTop10Customers; "Retail Top 10 Customers")
            {

            }
            part(RetailTop10Vendors; "NP Retail Top 10 Vendors")
            {

            }
            part(Control6014400; "My Reports")
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
            group("Item")
            {


                action("Item List")
                {
                    Caption = 'Item List';
                    RunObject = Page "Retail Item List";
                }
                action("Item Groups")
                {
                    Caption = 'Item Groups';
                    RunObject = Page "Item Group Tree";
                }
            }
            group("Retail")
            {
                action("Retail Journal")
                {
                    Caption = 'Retail Journal';
                    RunObject = Page "Retail Journal List";
                }
                action("Retail Documents")
                {
                    Caption = 'Retail Documents';
                    RunObject = Page "Retail Document List";
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
                    RunObject = Page "POS Entry List";
                }


                action("Gift Vouchers")
                {
                    Caption = 'Gift Vouchers';
                    RunObject = Page "Gift Voucher List";
                }
                action("Credit Vouchers")
                {
                    Caption = 'Credit Vouchers';
                    RunObject = Page "Credit Voucher List";
                }
                action("Sales Ticket Statistics")
                {
                    Caption = 'Sales Ticket Statistics';
                    RunObject = Page "Sales Ticket Statistics";
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
                    RunObject = Page "Mixed Discount List";
                }
                action(PeriodDiscounts)
                {
                    Caption = 'Period Discounts';
                    RunObject = Page "Campaign Discount List";
                }
            }

        }
        area(reporting)
        {
            action("Sale Statistics")
            {
                Caption = 'Sale Statistics';
                Image = "Report";
                RunObject = Report "Sales Ticket Statistics";
            }
            action("Discount Statistics")
            {
                Caption = 'Discount Statistics';
                Image = "Report";
                RunObject = Report "Discount Statistics";
            }
            action("Customer Analysis")
            {
                Caption = 'Customer Analysis';
                Image = "Report";
                RunObject = Report "Customer Analysis";
            }
            action("Gift Voucher/Credit Voucher")
            {
                Caption = 'Gift Voucher/Credit Voucher';
                Image = "Report";
                RunObject = Report "Gift Voucher/Credit Voucher";
            }
            action("Sales Person Top 20")
            {
                Caption = 'Sales Person Top 20';
                Image = "Report";
                RunObject = Report "Sales Person Top 20";
            }
            action("Sale Statistics per Vendor")
            {
                Caption = 'Sale Statistics per Vendor';
                Image = "Report";
                RunObject = Report "Sale Statistics per Vendor";
            }
            action("Vendor/Salesperson")
            {
                Caption = 'Vendor/Salesperson';
                Image = "Report";
                RunObject = Report "Vendor/Salesperson";
            }

            action("Item Group Overview")
            {
                Caption = 'Item Group Overview';
                Image = "Report";
                RunObject = Report "Item Group Overview";
            }
        }
    }

}

