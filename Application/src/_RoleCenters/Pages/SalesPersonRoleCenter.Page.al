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
                ToolTip = 'Executes the Item List action';
            }
            action("Item Group")
            {
                Caption = 'Item Group';
                RunObject = Page "NPR Item Group Tree";
                ApplicationArea = All;
                ToolTip = 'Executes the Item Group action';
            }
            action("Retail Journal")
            {
                Caption = 'Retail Journal';
                RunObject = Page "NPR Retail Journal List";
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Journal action';
            }
            action("Retail Documents")
            {
                Caption = 'Retail Documents';
                RunObject = Page "NPR Retail Document List";
                ApplicationArea = All;
                ToolTip = 'Executes the Retail Documents action';
            }
            action("Audit Roll")
            {
                Caption = 'Audit Roll';
                RunObject = Page "NPR Audit Roll";
                ApplicationArea = All;
                ToolTip = 'Executes the Audit Roll action';
            }
            action("POS Entry List")
            {
                Caption = 'POS Entry List';
                RunObject = Page "NPR POS Entry List";
                ApplicationArea = All;
                ToolTip = 'Executes the POS Entry List action';
            }
            action("Gift Vouchers")
            {
                Caption = 'Gift Vouchers';
                RunObject = Page "NPR Gift Voucher List";
                ApplicationArea = All;
                ToolTip = 'Executes the Gift Vouchers action';
            }
            action("Credit Vouchers")
            {
                Caption = 'Credit Vouchers';
                RunObject = Page "NPR Credit Voucher List";
                ApplicationArea = All;
                ToolTip = 'Executes the Credit Vouchers action';
            }
            action("Sales Ticket Statistics")
            {
                Caption = 'Sales Ticket Statistics';
                RunObject = Page "NPR Sales Ticket Statistics";
                ApplicationArea = All;
                ToolTip = 'Executes the Sales Ticket Statistics action';
            }
            action("Contacts ")
            {
                Caption = 'Contact List';
                RunObject = Page "Contact List";
                ApplicationArea = All;
                ToolTip = 'Executes the Contact List action';
            }
            action(Customers)
            {
                Caption = 'Customer List';
                RunObject = Page "Customer List";
                ApplicationArea = All;
                ToolTip = 'Executes the Customer List action';
            }
            action(MixedDiscounts)
            {
                Caption = 'Mixed Discounts';
                RunObject = Page "NPR Mixed Discount List";
                ApplicationArea = All;
                ToolTip = 'Executes the Mixed Discounts action';
            }
            action(PeriodDiscounts)
            {
                Caption = 'Period Discounts';
                RunObject = Page "NPR Campaign Discount List";
                ApplicationArea = All;
                ToolTip = 'Executes the Period Discounts action';
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

