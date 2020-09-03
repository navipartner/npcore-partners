page 6059980 "NPR Sales Person Role Center"
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
                part(Control6150615; "NPR Sale POS Activities")
                {
                }
                part(Control6150614; "NPR Retail Document Activities")
                {
                }
                part(Control21; "NPR Discount Activities")
                {
                }
            }
            group(Control6150634)
            {
                ShowCaption = false;
                part(Control6150631; "NPR Retail Top 10 Customers")
                {
                }
                part(Control6150632; "NPR Retail 10 Items by Qty.")
                {
                }
                part(Control6150613; "NPR Retail Top 10 S.person")
                {
                }
            }
            group(Control1900724708)
            {
                ShowCaption = false;
                part(Control6150635; "NPR Retail Sales Chart")
                {
                }
                part(Control31; "NPR RSS Reader Activ.")
                {
                }
                part(Control6014400; "NPR My Reports")
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
                RunObject = Page "NPR Retail Item List";
            }
            action("Item Group")
            {
                Caption = 'Item Group';
                RunObject = Page "NPR Item Group Tree";
            }
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
            action("Audit Roll")
            {
                Caption = 'Audit Roll';
                RunObject = Page "NPR Audit Roll";
            }
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

