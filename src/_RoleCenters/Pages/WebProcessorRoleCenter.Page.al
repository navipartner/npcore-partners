page 6059982 "NPR Web Processor Role Center"
{
    // NPR5.23.03/MHA/20160726  CASE 242557 Invalid PagePart removed: VisitorStatistics
    // NPR5.31/TS  /20170328  CASE 270740 My Reports added
    // NPR5.38/BR  /20180118  CASE 302790 Added POS Entry List

    Caption = 'Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control6150615)
            {
                ShowCaption = false;
                part(Control6150616; "NPR Web Manager Activ.")
                {
                    ApplicationArea = All;
                }
                part(Control6150618; "NPR Item List")
                {
                    ApplicationArea = All;
                }
            }
            group(Control6150617)
            {
                ShowCaption = false;
                part(SaleStatistics; "NPR Sale Stats Activities")
                {
                    SubPageView = SORTING(ID)
                                  WHERE(ID = CONST(1337));
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
            action("Sale Statistics")
            {
                Caption = 'Sale Statistics';
                Image = "Report";
                RunObject = Report "NPR Sales Ticket Stat.";
                ApplicationArea = All;
            }
            action("Discount Statistics")
            {
                Caption = 'Discount Statistics';
                Image = "Report";
                RunObject = Report "NPR Discount Statistics";
                ApplicationArea = All;
            }
            action("Customer Analysis")
            {
                Caption = 'Customer Analysis';
                Image = "Report";
                RunObject = Report "NPR Customer Analysis";
                ApplicationArea = All;
            }
            action("Gift Voucher/Credit Voucher")
            {
                Caption = 'Gift Voucher/Credit Voucher';
                Image = "Report";
                RunObject = Report "NPR Gift/Credit Voucher";
                ApplicationArea = All;
            }
            action("Sales Person Top 20")
            {
                Caption = 'Sales Person Top 20';
                Image = "Report";
                RunObject = Report "NPR Sales Person Top 20";
                ApplicationArea = All;
            }
            action("Sale Statistics per Vendor")
            {
                Caption = 'Sale Statistics per Vendor';
                Image = "Report";
                RunObject = Report "NPR Sale Statistics per Vendor";
                ApplicationArea = All;
            }
            action("Vendor/Salesperson")
            {
                Caption = 'Vendor/Salesperson';
                Image = "Report";
                RunObject = Report "NPR Vendor/Salesperson";
                ApplicationArea = All;
            }
            action("Item Group Overview")
            {
                Caption = 'Item Group Overview';
                Image = "Report";
                RunObject = Report "NPR Item Group Overview";
                ApplicationArea = All;
            }
        }
        area(embedding)
        {
            action("Item List")
            {
                Caption = 'Item List';
                RunObject = Page "NPR Retail Item List";
                ApplicationArea = All;
            }
            action("Item Groups")
            {
                Caption = 'Item Groups';
                RunObject = Page "NPR Item Group Tree";
                ApplicationArea = All;
            }
            action("Sale Orders")
            {
                Caption = 'Sale Orders';
                RunObject = Page "Sales Order List";
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

