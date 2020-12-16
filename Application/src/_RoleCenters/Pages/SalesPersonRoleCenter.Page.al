page 6059980 "NPR Sales Person Role Center"
{
    // NPR70.00.00.03/TS/20150130  CASE 205255 Removed Page Part Weather Activities
    // NPR5.31/TS  /20170328  CASE 270740 My Reports added
    // NPR5.38/BR  /20180118  CASE 302790 Added POS Entry List

    Caption = 'Role Center';
    PageType = RoleCenter;
    UsageCategory = Administration;

    layout
    {
        area(rolecenter)
        {
            group(Control1900724808)
            {
                ShowCaption = false;
                part(Control6150615; "NPR Sale POS Activities")
                {
                    ApplicationArea = All;
                }
                part(Control6150614; "NPR Retail Document Activities")
                {
                    ApplicationArea = All;
                }
                part(Control21; "NPR Discount Activities")
                {
                    ApplicationArea = All;
                }
            }
            group(Control6150634)
            {
                ShowCaption = false;
                part(Control6150631; "NPR Retail Top 10 Customers")
                {
                    ApplicationArea = All;
                }
                part(Control6150632; "NPR Retail 10 Items by Qty.")
                {
                    ApplicationArea = All;
                }
                part(Control6150613; "NPR Retail Top 10 S.person")
                {
                    ApplicationArea = All;
                }
            }
            group(Control1900724708)
            {
                ShowCaption = false;
                part(Control6150635; "NPR Retail Sales Chart")
                {
                    ApplicationArea = All;
                }
                part(Control31; "NPR RSS Reader Activ.")
                {
                    ApplicationArea = All;
                }
                part(Control6014400; "NPR My Reports")
                {
                    ApplicationArea = All;
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
                RunObject = Page "Item List";
                ApplicationArea = All;
            }
            action("Item Group")
            {
                Caption = 'Item Group';
                RunObject = Page "NPR Item Group Tree";
                ApplicationArea = All;
            }
            action("Retail Journal")
            {
                Caption = 'Retail Journal';
                RunObject = Page "NPR Retail Journal List";
                ApplicationArea = All;
            }
            action("Retail Documents")
            {
                Caption = 'Retail Documents';
                RunObject = Page "NPR Retail Document List";
                ApplicationArea = All;
            }
            action("Audit Roll")
            {
                Caption = 'Audit Roll';
                RunObject = Page "NPR Audit Roll";
                ApplicationArea = All;
            }
            action("POS Entry List")
            {
                Caption = 'POS Entry List';
                RunObject = Page "NPR POS Entry List";
                ApplicationArea = All;
            }
            action("Gift Vouchers")
            {
                Caption = 'Gift Vouchers';
                RunObject = Page "NPR Gift Voucher List";
                ApplicationArea = All;
            }
            action("Credit Vouchers")
            {
                Caption = 'Credit Vouchers';
                RunObject = Page "NPR Credit Voucher List";
                ApplicationArea = All;
            }
            action("Sales Ticket Statistics")
            {
                Caption = 'Sales Ticket Statistics';
                RunObject = Page "NPR Sales Ticket Statistics";
                ApplicationArea = All;
            }
            action("Contacts ")
            {
                Caption = 'Contact List';
                RunObject = Page "Contact List";
                ApplicationArea = All;
            }
            action(Customers)
            {
                Caption = 'Customer List';
                RunObject = Page "Customer List";
                ApplicationArea = All;
            }
            action(MixedDiscounts)
            {
                Caption = 'Mixed Discounts';
                RunObject = Page "NPR Mixed Discount List";
                ApplicationArea = All;
            }
            action(PeriodDiscounts)
            {
                Caption = 'Period Discounts';
                RunObject = Page "NPR Campaign Discount List";
                ApplicationArea = All;
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

