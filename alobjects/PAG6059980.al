page 6059980 "Sales Person Role Center"
{
    // NPR70.00.00.03/TS/20150130  CASE 205255 Removed Page Part Weather Activities
    // NPR5.31/TS  /20170328  CASE 270740 My Reports added
    // NPR5.38/BR  /20180118  CASE 302790 Added POS Entry List

    Caption = 'Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control1900724808)
            {
                ShowCaption = false;
                part(Control6150615;"Sale POS Activities")
                {
                }
                part(Control6150614;"Retail Document Activities")
                {
                }
                part(Control21;"Discount Activities")
                {
                }
            }
            group(Control6150634)
            {
                ShowCaption = false;
                part(Control6150631;"Retail Top 10 Customers")
                {
                }
                part(Control6150632;"Retail 10 Items by Qty.")
                {
                }
                part(Control6150613;"Retail Top 10 Salesperson")
                {
                }
            }
            group(Control1900724708)
            {
                ShowCaption = false;
                part(Control6150635;"Retail Sales Chart")
                {
                }
                part(Control31;"RSS Reader Activities")
                {
                }
                part(Control6014400;"My Reports")
                {
                }
            }
        }
    }

    actions
    {
        area(reporting)
        {
        }
        area(embedding)
        {
            action("Item List")
            {
                Caption = 'Item List';
                RunObject = Page "Retail Item List";
            }
            action("Item Group")
            {
                Caption = 'Item Group';
                RunObject = Page "Item Group Tree";
            }
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
            action("Audit Roll")
            {
                Caption = 'Audit Roll';
                RunObject = Page "Audit Roll";
            }
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
        area(sections)
        {
            group(Statistics)
            {
                Caption = 'Statistics';
                Image = Statistics;
            }
        }
    }
}

